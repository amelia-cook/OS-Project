#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "file.h"
#include "proc.h"
#include "defs.h"

extern uint ticks;  // from trap.c

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void wakeup1(struct proc *chan);

extern char trampoline[]; // trampoline.S

// Map "nice" range [-20, 19] to weights 
const int sched_prio_to_weight[40] = {
  /* -20 */ 88761, 71755, 56483, 46273, 36291,
  /* -15 */ 29154, 23254, 18705, 14949, 11916,
  /* -10 */  9548,  7620,  6100,  4904,  3906,
  /*  -5 */  3121,  2501,  1991,  1586,  1277,
  /*   0 */  1024,   820,   655,   526,   423,
  /*   5 */   335,   272,   215,   172,   137,
  /*  10 */   110,    87,    70,    56,    45,
  /*  15 */    36,    29,    23,    18,    15,
};

// Compute how much virtual runtime to add for a given
// real execution time delta in ticks
static inline uint64
eevdf_calc_delta_vruntime(uint64 delta_exec, struct proc *p)
{
  if(delta_exec == 0)
    return 0;

  int w = p->weight;
  if(w <= 0)
    w = NICE_0_WEIGHT;

  // vruntime += delta * NICE_0_WEIGHT / weight
  return delta_exec * (uint64)NICE_0_WEIGHT / (uint64)w;
}

static inline void
eevdf_update_deadline(struct proc *p)
{
  int w = p->weight;
  if(w <= 0)
    w = NICE_0_WEIGHT;

  p->vdeadline = p->vruntime + p->slice / (uint64)w;
}

// Called right before the process is scheduled on the CPU.
static void
eevdf_on_run_start(struct proc *p)
{
  p->last_start_time = ticks;  // real time in timer ticks
}

// Called right after the process stops running (yields, sleeps, exits).
static void
eevdf_on_run_end(struct proc *p)
{
  uint64 now   = ticks;
  uint64 delta = now - p->last_start_time;
  if(delta == 0)
    return;

  // Real CPU time this process just used
  p->actual_runtime += delta;

  // Update virtual runtime using weight
  uint64 virt_delta = eevdf_calc_delta_vruntime(delta, p);
  p->vruntime += virt_delta;

  eevdf_update_deadline(p);
}

// Compute weighted average vruntime V using RUNNABLE/RUNNING tasks.
static uint64
eevdf_compute_avg_vruntime(void)
{
  uint64 min_vr = (uint64)-1;
  uint64 sum_w  = 0;
  uint64 sum_weighted = 0;
  struct proc *p;

  // First pass: find minimum vruntime among active tasks.
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == RUNNABLE || p->state == RUNNING){
      if(min_vr == (uint64)-1 || p->vruntime < min_vr)
        min_vr = p->vruntime;
    }
  }

  if(min_vr == (uint64)-1)
    return 0;  // no active tasks

  //Second pass: compute weighted offsets from min_vr.
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == RUNNABLE || p->state == RUNNING){
      uint64 w = (p->weight > 0) ? (uint64)p->weight : (uint64)NICE_0_WEIGHT;
      sum_w       += w;
      sum_weighted += (p->vruntime - min_vr) * w;
    }
  }

  if(sum_w == 0)
    return min_vr;

  uint64 offset = sum_weighted / sum_w;

  //Keep global minimum vruntime updated for new tasks.
  min_vruntime = min_vr;

  return min_vr + offset;
}

// Update lag for all active tasks
// lag_i = w_i * (V - v_i)
// Positive lag: process is behind and should be picked
static void
eevdf_update_lag_all(void)
{
  uint64 V = eevdf_compute_avg_vruntime();
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == RUNNABLE || p->state == RUNNING){
      int diff = (int)V - (int)p->vruntime;
      int w    = (p->weight > 0) ? p->weight : NICE_0_WEIGHT;
      p->lag     = diff * w;
    } else {
      p->lag = 0;
    }
  }
}

// Pick the RUNNABLE process to run next according to EEVD
// Only tasks with lag >= 0 are eligible to run, 
// among them we pick the one with the earliest virtual deadline.
// If no task has lag >= 0, we fall back to earliest deadline.
static struct proc *
pick_eevdf_proc(void)
{
  struct proc *p;
  struct proc *best = 0;

  //Only consider tasks with positive lag (eligible).
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state != RUNNABLE)
      continue;

    if(p->lag < 0)
      continue;

    if(best == 0 || p->vdeadline < best->vdeadline)
      best = p;
  }

  if(best != 0)
    return best;

  //Ignore lag, just choose earliest deadline RUNNABLE task.
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state != RUNNABLE)
      continue;
    if(best == 0 || p->vdeadline < best->vdeadline)
      best = p;
  }

  return best;
}

static inline int
nice_to_index(int nice)
{
  int idx = nice - NICE_MIN;
  if(idx < 0)
    idx = 0;
  if(idx >= NICE_WIDTH)
    idx = NICE_WIDTH - 1;
  return idx;
}

static inline int
nice_to_weight(int nice)
{
  return sched_prio_to_weight[nice_to_index(nice)];
}

/*----- Initialization of EEVDF global parameters ----- */
uint64 min_vruntime = 0;      // minimum virtual runtime among all RUNNABLE processes
int    default_weight = NICE_0_WEIGHT; // default weight for processes
uint64 default_slice  = 10;   // default time slice, can be adjusted later

void
procinit(void)
{
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
  for(p = proc; p < &proc[NPROC]; p++) {
      initlock(&p->lock, "proc");

      // Allocate a page for the process's kernel stack.
      // Map it high in memory, followed by an invalid
      // guard page.
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) (p - proc));
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
      p->kstack = va;
  }
  kvminithart();
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  p->trap_va = TRAPFRAME;

  // Initialize EEVDF-related parameters
  p->nice            = 0;
  p->weight          = nice_to_weight(p->nice);

  p->vruntime = min_vruntime; //start new process at current minimum vruntime
  //p->vdeadline = p->vruntime + (default_slice * default_weight) / default_weight;; // should be computed before scheduling (vruntime + slice/weight)
  p->vdeadline       = 0;            // updated in line 171
  p->lag = 0;
  
  p->slice = default_slice;

  p->last_start_time = 0;
  p->actual_runtime  = 0;

  eevdf_update_deadline(p);

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;

  // TIMING DATA - init timing metrics 
  p->creation_time = getTime();
  p->first_run_time = 0;
  p->total_run_time = 0;
  p->last_scheduled = 0;
  p->total_wait_time = 0;
  p->completion_time = 0;
  p->wait_start = 0;
  p->context_switches = 0;
  p->first_run = 0;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if(p->trapframe)
    kfree((void*)p->trapframe);
  p->trapframe = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
}

// Create a page table for a given process,
// with no user pages, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  mappages(pagetable, TRAMPOLINE, PGSIZE,
           (uint64)trampoline, PTE_R | PTE_X);

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  mappages(pagetable, TRAPFRAME, PGSIZE,
           (uint64)(p->trapframe), PTE_R | PTE_W);

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
  if(sz > 0)
    uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
  p->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  // TIMING DATA - wait timing data
  p->wait_start = getTime();

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  np->parent = p;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));
  
  /*-----EEVDF: inherit scheduling parameters from parent-----*/
  // 1. All processes share the same weight and slice for now;
  // 2. The child starts with the same vruntime as its parent.
  np->nice            = p->nice;

  np->vruntime        = p->vruntime;
  np->vdeadline       = 0;   // be computed before scheduling
  np->lag             = 0;   // no lag at fork time
  np->weight          = p->weight;
  np->slice           = p->slice;
  np->last_start_time = 0;   // not started yet
  np->actual_runtime  = 0;   // reset actual runtime
  eevdf_update_deadline(np);

  pid = np->pid;

  np->state = RUNNABLE;

  // TIMING DATA - wait timing data
  np->wait_start = getTime();

  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold p->lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    // this code uses pp->parent without holding pp->lock.
    // acquiring the lock first could cause a deadlock
    // if pp or a child of pp were also in exit()
    // and about to try to lock p.
    if(pp->parent == p){
      // pp->parent can't change between the check and the acquire()
      // because only the parent changes it, and we're the parent.
      acquire(&pp->lock);
      pp->parent = initproc;
      // we should wake up init here, but that would require
      // initproc->lock, which would be a deadlock, since we hold
      // the lock on one of init's children (pp). this is why
      // exit() always wakes init (before acquiring any locks).
      release(&pp->lock);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
  struct proc *p = myproc();

  if(p == initproc)
    panic("init exiting");

  // TIMING DATA - update run timing
  if(p->last_scheduled != 0) {
    p->total_run_time += getTime() - p->last_scheduled;
  }

  // TIMING DATA - completion timing 
  p->completion_time = getTime();
  
  // Print metrics for this process
  uint64 turnaround = p->completion_time - p->creation_time;
  uint64 response = (p->first_run == 1) ? (p->first_run_time - p->creation_time) : 0;
  uint64 cpu_percent = turnaround > 0 ? (p->total_run_time * 100) / turnaround : 0;
  
  // Print metrics for this process
  printf("\n ***Process Exit Metrics***\n");
  printf("PID: %d\n", p->pid);
  printf("Name: %s\n", p->name);
  printf("Turnaround Time: %d ticks\n", (int)turnaround);
  printf("Waiting Time: %d ticks\n", (int)p->total_wait_time);
  printf("Response Time: %d ticks\n", (int)response);
  printf("Total Run Time: %d ticks\n", (int)p->total_run_time); 
  printf("Context Switches: %d\n", p->context_switches);
  printf("CPU Share: %d%%\n", (int)cpu_percent);

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  // we might re-parent a child to init. we can't be precise about
  // waking up init, since we can't acquire its lock once we've
  // acquired any other proc lock. so wake up init whether that's
  // necessary or not. init may miss this wakeup, but that seems
  // harmless.
  acquire(&initproc->lock);
  wakeup1(initproc);
  release(&initproc->lock);

  // grab a copy of p->parent, to ensure that we unlock the same
  // parent we locked. in case our parent gives us away to init while
  // we're waiting for the parent lock. we may then race with an
  // exiting parent, but the result will be a harmless spurious wakeup
  // to a dead or wrong process; proc structs are never re-allocated
  // as anything else.
  acquire(&p->lock);
  struct proc *original_parent = p->parent;
  release(&p->lock);
  
  // we need the parent's lock in order to wake it up from wait().
  // the parent-then-child rule says we have to lock it first.
  acquire(&original_parent->lock);

  acquire(&p->lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup1(original_parent);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&original_parent->lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  // hold p->lock for the whole time to avoid lost
  // wakeups from a child's exit().
  acquire(&p->lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      // this code uses np->parent without holding np->lock.
      // acquiring the lock first would cause a deadlock,
      // since np might be an ancestor, and we already hold p->lock.
      if(np->parent == p){
        // np->parent can't change between the check and the acquire()
        // because only the parent changes it, and we're the parent.
        acquire(&np->lock);
        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&p->lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&p->lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed){
      release(&p->lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &p->lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  
  c->proc = 0;
  for(;;){
    // Avoid deadlock by giving devices a chance to interrupt.
    intr_on();

    // Run the for loop with interrupts off to avoid
    // a race between an interrupt and WFI, which would
    // cause a lost wakeup.
    intr_off();

    int found = 0;
    for(p = proc; p < &proc[NPROC]; p++) {
      acquire(&p->lock);
      if(p->state == RUNNABLE) {
        // TIMING DATA - wait timing 
        if(p->wait_start != 0){
          p->total_wait_time += getTime() - p->wait_start;
          p->wait_start = 0;
        }

        // TIMING DATA - reponse timing 
        if(p->first_run == 0) {
          p->first_run_time = getTime();
          p->first_run = 1;
        }

        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;

        // TIMING DATA - scheduling timing 
        p->last_scheduled = getTime();
        p->context_switches++;

        swtch(&c->scheduler, &p->context);

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;

        found = 1;
      }

      // ensure that release() doesn't enable interrupts.
      // again to avoid a race between interrupt and WFI.
      c->intena = 0;

      release(&p->lock);
    }
    if(found == 0){
      asm volatile("wfi");
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&p->lock))
    panic("sched p->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;

  // TIMING DATA - wait timing data
  p->wait_start = getTime();

  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  if(lk != &p->lock){  //DOC: sleeplock0
    acquire(&p->lock);  //DOC: sleeplock1
    release(lk);
  }

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &p->lock){
    release(&p->lock);
    acquire(lk);
  }
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;

      // TIMING DATA - wait timing data
      p->wait_start = getTime();
    }
    release(&p->lock);
  }
}

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
  if(!holding(&p->lock))
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    p->state = RUNNABLE;

    // TIMING DATA - wait timing data
    p->wait_start = getTime();
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->killed = 1;
      if(p->state == SLEEPING){
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

// TIMING DATA - timing functions
unsigned long getTime() { 
  unsigned long time; 
  asm volatile ("rdtime %0" : "=r" (time)); 
  return time; 
}

unsigned long getCycles() { 
  unsigned long cycles; 
  asm volatile ("rdcycle %0" : "=r" (cycles)); 
  return cycles; 
}
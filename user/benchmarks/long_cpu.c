//long CPU-bound benchmark for scheduling evaluation.

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

//10 MHz timer.
unsigned long getTime(void)
{
  unsigned long time;
  asm volatile ("rdtime %0" : "=r" (time));
  return time;
}

//tight & pure arithmetic loop that does not perform I/O
static void burn(unsigned long iters)
{
  volatile unsigned long x = 0;
  for (unsigned long i = 0; i < iters; i++) {
    x += i * 7 + (i & 3);
  }

  // Prevent the compiler from optimizing the loop away.
  if (x == 42) {
    printf("magic=%d\n", (int)x);
  }
}

int main(int argc, char *argv[])
{
  // # of CPU-bound processes to run
  int nprocs = 4;
  // # of iterations per process.
  unsigned long iters = 500000000UL;

  if (argc >= 2) {
    nprocs = atoi(argv[1]);
  }
  if (argc >= 3) {
    iters = (unsigned long)atoi(argv[2]);
  }

  printf("cpu_long: nprocs=%d, iters=%d\n", nprocs, (int)iters);

  unsigned long global_start = getTime();

  // create nprocs children, each running a CPU-bound loop
  for (int i = 0; i < nprocs; i++) {
    int pid = fork();
    if (pid < 0) {
      printf("cpu_long: fork failed\n");
      exit(1);
    }
    if (pid == 0) {
      unsigned long t0 = getTime();
      burn(iters);
      unsigned long t1 = getTime();

      printf("child %d: run_time=%d ticks\n",
             getpid(), (int)(t1 - t0));

      exit(0);
    }
  }

  // parent waits for all children to finish.
  for (int i = 0; i < nprocs; i++) {
    wait(0);
  }

  unsigned long global_end = getTime();
  printf("cpu_long: total elapsed=%d ticks\n",
         (int)(global_end - global_start));

  exit(0);
}
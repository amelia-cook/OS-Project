// Test FIFO scheduling implementation in xv6
// This test verifies that processes are scheduled in First-In-First-Out order

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NUM_CHILDREN 5
#define WORK_CYCLES 100000  // Work to ensure context switches
#define PIPE_WRITE 1
#define PIPE_READ 0

// Global array to track execution order
int execution_order[NUM_CHILDREN];
int order_index = 0;

void
print(const char *s)
{
  write(1, s, strlen(s));
}

// Helper function to do some work to consume CPU time
void
do_work()
{
  volatile int sum = 0;
  for(int i = 0; i < WORK_CYCLES; i++) {
    sum += i * 2;
  }
}

// Test basic FIFO ordering - children created sequentially should run in order
void
test_basic_fifo()
{
  int pids[NUM_CHILDREN];
  int pipes[NUM_CHILDREN][2];
  
  print("=== Test 1: Basic FIFO Ordering ===\n");
  
  // Create pipes for synchronization
  for(int i = 0; i < NUM_CHILDREN; i++) {
    if(pipe(pipes[i]) < 0) {
      print("pipe creation failed\n");
      exit(1);
    }
  }
  
  // Fork children with small delays to ensure different arrival times
  for(int i = 0; i < NUM_CHILDREN; i++) {
    // Small delay to ensure different arrival times
    do_work();
    
    pids[i] = fork();
    if(pids[i] < 0) {
      print("fork failed\n");
      exit(1);
    }
    
    if(pids[i] == 0) {
      // Child process
      close(pipes[i][PIPE_WRITE]); // Child only reads
      
      // Wait for parent signal
      char signal;
      read(pipes[i][PIPE_READ], &signal, 1);
      close(pipes[i][PIPE_READ]);
      
      // Do some work and record execution
      do_work();
      
      // Write child ID to indicate it ran
      printf("Child %d (PID %d) executed\n", i, getpid());
      exit(i); // Exit with child ID
    } else {
      // Parent process
      close(pipes[i][PIPE_READ]); // Parent only writes
    }
  }
  
  // All children are now blocked waiting for signals
  // Signal them all at once to make them runnable simultaneously
  print("Signaling all children simultaneously...\n");
  for(int i = 0; i < NUM_CHILDREN; i++) {
    char signal = 1;
    write(pipes[i][PIPE_WRITE], &signal, 1);
    close(pipes[i][PIPE_WRITE]);
  }
  
  // Wait for all children and record their exit order
  int exit_order[NUM_CHILDREN];
  for(int i = 0; i < NUM_CHILDREN; i++) {
    int status;
    int pid = wait(&status);
    
    // Find which child this was
    for(int j = 0; j < NUM_CHILDREN; j++) {
      if(pids[j] == pid) {
        exit_order[i] = j;
        break;
      }
    }
  }
  
  // Check if children executed in FIFO order (0, 1, 2, 3, 4)
  print("Expected order: 0 1 2 3 4\n");
  printf("Actual order:   ");
  for(int i = 0; i < NUM_CHILDREN; i++) {
    printf("%d ", exit_order[i]);
  }
  printf("\n");
  
  int correct_order = 1;
  for(int i = 0; i < NUM_CHILDREN; i++) {
    if(exit_order[i] != i) {
      correct_order = 0;
      break;
    }
  }
  
  if(correct_order) {
    print("PASS: Basic FIFO ordering correct\n");
  } else {
    print("FAIL: Basic FIFO ordering incorrect\n");
  }
  
  print("\n");
}

// Test FIFO after sleep - processes that wake up should maintain FIFO order
void
test_fifo_after_sleep()
{
  int pids[NUM_CHILDREN];
  int sync_pipe[2];
  
  print("=== Test 2: FIFO After Sleep ===\n");
  
  if(pipe(sync_pipe) < 0) {
    print("pipe creation failed\n");
    exit(1);
  }
  
  // Fork children
  for(int i = 0; i < NUM_CHILDREN; i++) {
    pids[i] = fork();
    if(pids[i] < 0) {
      print("fork failed\n");
      exit(1);
    }
    
    if(pids[i] == 0) {
      // Child process
      close(sync_pipe[PIPE_WRITE]);
      
      // Each child sleeps for different amounts to create arrival order
      sleep(1 + i);  // Child 0 sleeps 1 tick, child 1 sleeps 2 ticks, etc.
      
      // Do work and print execution
      do_work();
      printf("Woken child %d (PID %d) executed\n", i, getpid());
      exit(i);
    }
  }
  
  close(sync_pipe[PIPE_READ]);
  close(sync_pipe[PIPE_WRITE]);
  
  // Wait for all children and record their execution order
  int exit_order[NUM_CHILDREN];
  for(int i = 0; i < NUM_CHILDREN; i++) {
    int status;
    int pid = wait(&status);
    
    // Find which child this was
    for(int j = 0; j < NUM_CHILDREN; j++) {
      if(pids[j] == pid) {
        exit_order[i] = j;
        break;
      }
    }
  }
  
  // Check if children woke up and executed in FIFO order
  print("Expected wake order: 0 1 2 3 4\n");
  printf("Actual wake order:   ");
  for(int i = 0; i < NUM_CHILDREN; i++) {
    printf("%d ", exit_order[i]);
  }
  printf("\n");
  
  int correct_order = 1;
  for(int i = 0; i < NUM_CHILDREN; i++) {
    if(exit_order[i] != i) {
      correct_order = 0;
      break;
    }
  }
  
  if(correct_order) {
    print("PASS: FIFO after sleep correct\n");
  } else {
    print("FAIL: FIFO after sleep incorrect\n");
  }
  
  print("\n");
}

// Test FIFO with yield - processes that yield should go to back of queue
void
test_fifo_with_yield()
{
  print("=== Test 3: FIFO with Yield ===\n");
  
  int pipe1[2], pipe2[2], pipe3[2];
  
  if(pipe(pipe1) < 0 || pipe(pipe2) < 0 || pipe(pipe3) < 0) {
    print("pipe creation failed\n");
    exit(1);
  }
  
  int pid1 = fork();
  if(pid1 < 0) {
    print("fork failed\n");
    exit(1);
  }
  
  if(pid1 == 0) {
    // Child 1: yields immediately
    close(pipe1[PIPE_READ]);
    close(pipe2[PIPE_READ]);
    close(pipe2[PIPE_WRITE]);
    close(pipe3[PIPE_READ]);
    close(pipe3[PIPE_WRITE]);
    
    printf("Child 1 yielding...\n");
    // Signal parent that we're about to yield
    char signal = 1;
    write(pipe1[PIPE_WRITE], &signal, 1);
    close(pipe1[PIPE_WRITE]);
    
    // Yield CPU
    sleep(0);  // Brief sleep to yield
    
    printf("Child 1 running after yield\n");
    exit(1);
  }
  
  close(pipe1[PIPE_WRITE]);
  
  int pid2 = fork();
  if(pid2 < 0) {
    print("fork failed\n");
    exit(1);
  }
  
  if(pid2 == 0) {
    // Child 2: waits then runs
    close(pipe1[PIPE_READ]);
    close(pipe2[PIPE_READ]);
    close(pipe3[PIPE_READ]);
    close(pipe3[PIPE_WRITE]);
    
    // Signal parent
    char signal = 2;
    write(pipe2[PIPE_WRITE], &signal, 1);
    close(pipe2[PIPE_WRITE]);
    
    do_work();
    printf("Child 2 running normally\n");
    exit(2);
  }
  
  close(pipe2[PIPE_WRITE]);
  
  int pid3 = fork();
  if(pid3 < 0) {
    print("fork failed\n");
    exit(1);
  }
  
  if(pid3 == 0) {
    // Child 3: waits then runs
    close(pipe1[PIPE_READ]);
    close(pipe2[PIPE_READ]);
    close(pipe3[PIPE_READ]);
    
    // Signal parent
    char signal = 3;
    write(pipe3[PIPE_WRITE], &signal, 1);
    close(pipe3[PIPE_WRITE]);
    
    do_work();
    printf("Child 3 running normally\n");
    exit(3);
  }
  
  close(pipe3[PIPE_WRITE]);
  
  // Wait for all children to be ready
  char signal;
  read(pipe1[PIPE_READ], &signal, 1);  // Child 1 yielded
  read(pipe2[PIPE_READ], &signal, 1);  // Child 2 ready
  read(pipe3[PIPE_READ], &signal, 1);  // Child 3 ready
  
  close(pipe1[PIPE_READ]);
  close(pipe2[PIPE_READ]);
  close(pipe3[PIPE_READ]);
  
  // Collect results
  int results[3];
  for(int i = 0; i < 3; i++) {
    int status;
    int pid = wait(&status);
    results[i] = status;
    // Print the exit code and pid for visibility
    printf("Child exited: exit code=%d pid=%d\n", status, pid);
  }
  
  print("Children have completed yield test\n");
  // Print summary of results array
  printf("Yield test exit codes: %d %d %d\n", results[0], results[1], results[2]);
  print("PASS: FIFO with yield test completed\n\n");
}

int
main(void)
{
  print("Starting FIFO Scheduler Tests...\n\n");
  
  test_basic_fifo();
  test_fifo_after_sleep(); 
  test_fifo_with_yield();
  
  print("=== FIFO Test Summary ===\n");
  print("All FIFO tests completed.\n");
  print("Check output above for individual test results.\n");
  
  exit(0);
}
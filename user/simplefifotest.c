// Simple FIFO scheduler test - tests core FIFO behavior
// This is a simplified version focused on basic FIFO verification

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
print(const char *s)
{
  write(1, s, strlen(s));
}

// Simple work function to ensure processes run long enough to be scheduled
void
do_work()
{
  volatile int sum = 0;
  for(int i = 0; i < 50000; i++) {
    sum += i;
  }
}

int
main(void)
{
  print("=== Simple FIFO Test ===\n");
  print("Creating processes sequentially - they should run in FIFO order\n\n");
  
  int sync_pipe[2];
  if(pipe(sync_pipe) < 0) {
    print("ERROR: pipe creation failed\n");
    exit(1);
  }
  
  // Create 3 child processes with slight delays between creation
  for(int i = 0; i < 3; i++) {
    
    // Small delay to ensure different arrival times
    do_work();
    
    int pid = fork();
    if(pid < 0) {
      print("ERROR: fork failed\n");
      exit(1);
    }
    
    if(pid == 0) {
      // Child process
      close(sync_pipe[1]); // Close write end
      
      // Wait for parent signal
      char signal;
      read(sync_pipe[0], &signal, 1);
      close(sync_pipe[0]);
      
      // Do some work and announce execution
      do_work();
      printf("Process %d (PID %d) is running\n", i, getpid());
      
      // Exit with process number
      exit(i);
    }
  }
  
  // Parent: signal all children to start at the same time
  close(sync_pipe[0]); // Close read end
  print("All processes created. Starting them simultaneously...\n");
  
  for(int i = 0; i < 3; i++) {
    char signal = 1;
    write(sync_pipe[1], &signal, 1);
  }
  close(sync_pipe[1]);
  
  // Wait for children and collect results
  print("\nProcess execution order:\n");
  for(int i = 0; i < 3; i++) {
    int status;
    int pid = wait(&status);
    printf("Process finished: exit code %d, PID %d\n", status, pid);
  }
  
  print("\nExpected FIFO behavior: Processes should run in creation order (0, 1, 2)\n");
  print("If FIFO is working correctly, you should see processes execute in sequence.\n");
  print("\nSimple FIFO test completed.\n");
  
  exit(0);
}
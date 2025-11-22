#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define N_HOGS 4
#define N_ITERS 50
#define SLEEP_TICKS 20

void interactive_task() {
  printf(1, "Starting interactive task.\n");

  for (int i = 0; i < N_ITERS; i++) {
    int t0 = uptime();

    // Simulate a "wake-up", do small work
    for (volatile int j = 0; j < 20000; j++);

    int t1 = uptime();
    printf(1, "Iteration %d: wake latency = %d ticks\n", i, t1 - t0);

    // Sleep as if waiting for user input
    sleep(SLEEP_TICKS);
  }

  printf(1, "Interactive task done.\n");
}

int main(void) {
  // Spawn CPU hogs
  for (int i = 0; i < N_HOGS; i++) {
    if (fork() == 0) {
      volatile int x = 0;
      while (1) x++;
    }
  }

  sleep(10); // Let hogs stabilize

  if (fork() == 0) {
    interactive_task();
    exit();
  }

  // Parent waits for interactive child to finish
  wait();
  exit();
}

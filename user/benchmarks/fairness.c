#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NPROC 5
#define WORK  80000000

int main(void) {
  printf(1, "Fairness test with %d processes\n", NPROC);

  for (int i = 0; i < NPROC; i++) {
    if (fork() == 0) {
      int start = uptime();
      volatile int x = 0;
      for (int j = 0; j < WORK; j++) x++;
      int end = uptime();
      printf(1, "PID %d done: time=%d ticks\n", getpid(), end-start);
      exit(0);
    }
  }

  while (wait(0) > 0);
  exit(0);
}

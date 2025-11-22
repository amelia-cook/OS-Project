#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void short_job() {
  int s = uptime();
  for (int i = 0; i < 100000; i++) ;   // trivial work
  int e = uptime();
  printf(1, "Short job latency: %d ticks\n", e - s);
}

int main() {
  // Create CPU hogs
  for(int i = 0; i < 4; i++) {
    if (fork() == 0) {
      volatile int x = 0;
      while(1) x++;
    }
  }

  sleep(5);  // let hogs start

  // Run short job
  if (fork() == 0) {
    short_job();
    exit(0);
  }

  // Should not reach here—kill hogs manually in testing
  for(int i = 0; i < 5; i++) wait(0);
  exit(0);
}
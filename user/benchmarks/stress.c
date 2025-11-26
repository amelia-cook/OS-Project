#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define DEFAULT_CHILDREN  32
#define DEFAULT_ITERS     50000

void
child_worker(int iters)
{
    volatile int x = 0;

    for (int i = 0; i < iters; i++) {
        // tiny, non-optimizable computation
        x = x * 17 + i;

        // A quick syscall forces entry/exit of kernel → good preemption point
        getpid();

        // sleep(0) intentionally forces the scheduler to requeue this proc
        if ((i & 63) == 0) {
            sleep(0);  // no explicit yield() needed
        }
    }

    exit(0);
}

int
main(int argc, char *argv[])
{
    int nchildren = DEFAULT_CHILDREN;
    int iters = DEFAULT_ITERS;

    for (int i = 0; i < nchildren; i++) {
        int pid = fork();
        if (pid < 0) {
            printf("fork failed at %d\n", i);
            exit(1);
        }
        if (pid == 0) {
            child_worker(iters);
        }
    }

    for (int i = 0; i < nchildren; i++)
        wait(0);
    
    exit(0);
}

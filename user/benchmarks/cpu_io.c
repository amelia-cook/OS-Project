#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"

int main(int argc, char *argv[])
{
    int nprocs = 10;
    
    // create nprocs children, each running a CPU-bound loop
    for (int i = 0; i < nprocs; i++) {
        int pid = fork();
        if (pid < 0) {
            printf("cpu_long: fork failed\n");
            exit(1);
        }
        if (pid == 0) {
            for (int i = 0; i < 5; i++) {
                int fd1 = open("peter-pan.txt", O_RDONLY);
                char buf;
                
                while (read(fd1, &buf, sizeof(buf)) > 0) {
                    printf("%c", buf);
                }
                
                close(fd1);
            }
            
            exit(0);
        }
    }
    
    // parent waits for all children to finish.
    for (int i = 0; i < nprocs; i++) {
        wait(0);
    }

    exit(0);
}

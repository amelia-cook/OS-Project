// a long io-bound program for benchmarking the scheduling algorithm

#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"


int
main(int argc, char *argv[])
{
    for (int i = 0; i < 5; i++) {
        int fd1 = open("peter-pan.txt", O_RDONLY);
        char buf;
        
        while (read(fd1, &buf, sizeof(buf)) > 0) {
            printf("%c", buf);
        }
        
        close(fd1);
    }
    return 0;
}

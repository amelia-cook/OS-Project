// a long io-bound program for benchmarking the scheduling algorithm

#include "../kernel/param.h"
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "../user/user.h"
#include "../kernel/fs.h"
#include "../kernel/fcntl.h"
#include "../kernel/syscall.h"
#include "../kernel/memlayout.h"
#include "../kernel/riscv.h"


int
main(int argc, char *argv[])
{
    int fd = open("pride-and-prejudice.txt", O_RDONLY);
    char buf;
    while (read(fd, buf, 1) != 0) {
        printf("%c", buf);
    }
    close(fd);
}
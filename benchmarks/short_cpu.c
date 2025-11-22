#include "kernel/types.h"
#include "user/user.h"

int main() {
    volatile long x = 0;
    for (long i = 0; i < 5e7; i++) {   // short CPU loop
        x += i;
    }
    printf("cpu_short done: %ld\n", x);
    exit(0);
}
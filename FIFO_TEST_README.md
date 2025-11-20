# FIFO Scheduler Test for xv6

This directory contains a comprehensive test for the FIFO (First-In-First-Out) scheduling implementation in xv6.

## Files Added

- `user/fifotest.c` - Main FIFO test program
- Updated `Makefile` to include the FIFO test

## FIFO Implementation Overview

The FIFO scheduler implementation in `kernel/proc.c` uses:
- `uint64 arrival_counter` - Global counter for tracking process arrival order
- `uint64 arrival` field in `struct proc` - Stores the arrival time for each process
- Modified `scheduler()` function that selects the RUNNABLE process with the earliest arrival time
- `wakeup()` function assigns new arrival times when processes become runnable again

## Test Description

The `fifotest.c` program contains three comprehensive tests:

### Test 1: Basic FIFO Ordering
- Creates 5 child processes sequentially with small delays
- Makes them all runnable simultaneously using pipes for synchronization
- Verifies they execute in the order they were created (FIFO order)
- **Expected behavior**: Children should execute in order 0, 1, 2, 3, 4

### Test 2: FIFO After Sleep
- Creates 5 child processes that sleep for different durations
- Tests that processes waking up maintain FIFO order based on wake time
- **Expected behavior**: Children wake up and execute in the order they finish sleeping

### Test 3: FIFO with Yield
- Tests behavior when processes yield the CPU
- Verifies that yielding processes maintain proper FIFO ordering
- **Expected behavior**: Processes that yield should go to the back of the ready queue

## How to Build and Run

1. **Prerequisites**: Install RISC-V GNU toolchain
   ```bash
   # On macOS
   brew install riscv-gnu-toolchain
   
   # On Ubuntu/Debian
   sudo apt-get install gcc-riscv64-unknown-elf
   ```

2. **Build xv6 with the FIFO test**:
   ```bash
   cd OS-Project
   make clean
   make qemu
   ```

3. **Run the FIFO test in xv6**:
   ```bash
   # Inside xv6 shell
   fifotest
   ```

## Expected Output

The test will output detailed results for each test case:

```
Starting FIFO Scheduler Tests...

=== Test 1: Basic FIFO Ordering ===
Signaling all children simultaneously...
Child 0 (PID X) executed
Child 1 (PID Y) executed
Child 2 (PID Z) executed
Child 3 (PID A) executed
Child 4 (PID B) executed
Expected order: 0 1 2 3 4
Actual order:   0 1 2 3 4
PASS: Basic FIFO ordering correct

=== Test 2: FIFO After Sleep ===
Woken child 0 (PID X) executed
Woken child 1 (PID Y) executed
Woken child 2 (PID Z) executed
Woken child 3 (PID A) executed
Woken child 4 (PID B) executed
Expected wake order: 0 1 2 3 4
Actual wake order:   0 1 2 3 4
PASS: FIFO after sleep correct

=== Test 3: FIFO with Yield ===
Child 1 yielding...
Child 2 running normally
Child 3 running normally
Child 1 running after yield
Children have completed yield test
PASS: FIFO with yield test completed

=== FIFO Test Summary ===
All FIFO tests completed.
Check output above for individual test results.
```

## Key Testing Features

1. **Synchronization**: Uses pipes to precisely control when processes become runnable
2. **Arrival Time Verification**: Tests both initial process creation and re-arrival after sleep
3. **Comprehensive Coverage**: Tests basic FIFO, sleep/wake behavior, and yield scenarios
4. **Clear Output**: Provides expected vs actual results for easy verification

## FIFO Implementation Details Tested

- **Process Creation**: New processes get assigned `arrival = arrival_counter++`
- **Wake from Sleep**: `wakeup()` assigns new arrival time when transitioning SLEEPING → RUNNABLE
- **Scheduler Selection**: `scheduler()` picks RUNNABLE process with minimum `arrival` value
- **Lock Safety**: Tests work correctly with process locks and scheduler synchronization

## Troubleshooting

If the test fails:
1. Check that the FIFO scheduler is properly implemented in `kernel/proc.c`
2. Verify the `arrival` field is being set correctly on process creation and wakeup
3. Ensure the scheduler loop correctly finds the process with minimum arrival time
4. Check that the global `arrival_counter` is being incremented properly

## Alternative Testing

If you cannot build xv6, you can:
1. Review the test code to understand the testing methodology
2. Manually trace through the FIFO scheduler logic
3. Add debug prints to the kernel scheduler to observe behavior
4. Use the test structure as a template for other scheduling algorithm tests
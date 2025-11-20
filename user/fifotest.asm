
user/_fifotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:
int execution_order[NUM_CHILDREN];
int order_index = 0;

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00001097          	auipc	ra,0x1
  10:	848080e7          	jalr	-1976(ra) # 854 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00001097          	auipc	ra,0x1
  20:	a7e080e7          	jalr	-1410(ra) # a9a <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <do_work>:

// Helper function to do some work to consume CPU time
void
do_work()
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec22                	sd	s0,24(sp)
  32:	1000                	addi	s0,sp,32
  volatile int sum = 0;
  34:	fe042623          	sw	zero,-20(s0)
  38:	4781                	li	a5,0
  for(int i = 0; i < WORK_CYCLES; i++) {
  3a:	000316b7          	lui	a3,0x31
  3e:	d4068693          	addi	a3,a3,-704 # 30d40 <__global_pointer$+0x2f19f>
    sum += i * 2;
  42:	fec42703          	lw	a4,-20(s0)
  46:	9f3d                	addw	a4,a4,a5
  48:	fee42623          	sw	a4,-20(s0)
  for(int i = 0; i < WORK_CYCLES; i++) {
  4c:	2789                	addiw	a5,a5,2
  4e:	fed79ae3          	bne	a5,a3,42 <do_work+0x14>
  }
}
  52:	6462                	ld	s0,24(sp)
  54:	6105                	addi	sp,sp,32
  56:	8082                	ret

0000000000000058 <test_basic_fifo>:

// Test basic FIFO ordering - children created sequentially should run in order
void
test_basic_fifo()
{
  58:	7135                	addi	sp,sp,-160
  5a:	ed06                	sd	ra,152(sp)
  5c:	e922                	sd	s0,144(sp)
  5e:	e526                	sd	s1,136(sp)
  60:	e14a                	sd	s2,128(sp)
  62:	fcce                	sd	s3,120(sp)
  64:	f8d2                	sd	s4,112(sp)
  66:	f4d6                	sd	s5,104(sp)
  68:	1100                	addi	s0,sp,160
  int pids[NUM_CHILDREN];
  int pipes[NUM_CHILDREN][2];
  
  print("=== Test 1: Basic FIFO Ordering ===\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	f3e50513          	addi	a0,a0,-194 # fa8 <malloc+0xe8>
  72:	00000097          	auipc	ra,0x0
  76:	f8e080e7          	jalr	-114(ra) # 0 <print>
  
  // Create pipes for synchronization
  for(int i = 0; i < NUM_CHILDREN; i++) {
  7a:	fa840913          	addi	s2,s0,-88
  print("=== Test 1: Basic FIFO Ordering ===\n");
  7e:	f8040493          	addi	s1,s0,-128
    if(pipe(pipes[i]) < 0) {
  82:	8526                	mv	a0,s1
  84:	00001097          	auipc	ra,0x1
  88:	a06080e7          	jalr	-1530(ra) # a8a <pipe>
  8c:	08054a63          	bltz	a0,120 <test_basic_fifo+0xc8>
  for(int i = 0; i < NUM_CHILDREN; i++) {
  90:	04a1                	addi	s1,s1,8
  92:	ff2498e3          	bne	s1,s2,82 <test_basic_fifo+0x2a>
  96:	f8040993          	addi	s3,s0,-128
  9a:	fa840913          	addi	s2,s0,-88
      exit(1);
    }
  }
  
  // Fork children with small delays to ensure different arrival times
  for(int i = 0; i < NUM_CHILDREN; i++) {
  9e:	4481                	li	s1,0
  a0:	4a15                	li	s4,5
    // Small delay to ensure different arrival times
    do_work();
  a2:	00000097          	auipc	ra,0x0
  a6:	f8c080e7          	jalr	-116(ra) # 2e <do_work>
    
    pids[i] = fork();
  aa:	00001097          	auipc	ra,0x1
  ae:	9c8080e7          	jalr	-1592(ra) # a72 <fork>
  b2:	00a92023          	sw	a0,0(s2)
    if(pids[i] < 0) {
  b6:	08054263          	bltz	a0,13a <test_basic_fifo+0xe2>
      print("fork failed\n");
      exit(1);
    }
    
    if(pids[i] == 0) {
  ba:	cd49                	beqz	a0,154 <test_basic_fifo+0xfc>
      // Write child ID to indicate it ran
      printf("Child %d (PID %d) executed\n", i, getpid());
      exit(i); // Exit with child ID
    } else {
      // Parent process
      close(pipes[i][PIPE_READ]); // Parent only writes
  bc:	0009a503          	lw	a0,0(s3)
  c0:	00001097          	auipc	ra,0x1
  c4:	9e2080e7          	jalr	-1566(ra) # aa2 <close>
  for(int i = 0; i < NUM_CHILDREN; i++) {
  c8:	2485                	addiw	s1,s1,1
  ca:	0911                	addi	s2,s2,4
  cc:	09a1                	addi	s3,s3,8
  ce:	fd449ae3          	bne	s1,s4,a2 <test_basic_fifo+0x4a>
    }
  }
  
  // All children are now blocked waiting for signals
  // Signal them all at once to make them runnable simultaneously
  print("Signaling all children simultaneously...\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	f4650513          	addi	a0,a0,-186 # 1018 <malloc+0x158>
  da:	00000097          	auipc	ra,0x0
  de:	f26080e7          	jalr	-218(ra) # 0 <print>
  for(int i = 0; i < NUM_CHILDREN; i++) {
  e2:	f8440493          	addi	s1,s0,-124
  e6:	fac40993          	addi	s3,s0,-84
    char signal = 1;
  ea:	4905                	li	s2,1
  ec:	f7240223          	sb	s2,-156(s0)
    write(pipes[i][PIPE_WRITE], &signal, 1);
  f0:	864a                	mv	a2,s2
  f2:	f6440593          	addi	a1,s0,-156
  f6:	4088                	lw	a0,0(s1)
  f8:	00001097          	auipc	ra,0x1
  fc:	9a2080e7          	jalr	-1630(ra) # a9a <write>
    close(pipes[i][PIPE_WRITE]);
 100:	4088                	lw	a0,0(s1)
 102:	00001097          	auipc	ra,0x1
 106:	9a0080e7          	jalr	-1632(ra) # aa2 <close>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 10a:	04a1                	addi	s1,s1,8
 10c:	ff3490e3          	bne	s1,s3,ec <test_basic_fifo+0x94>
 110:	f6840993          	addi	s3,s0,-152
 114:	f7c40a13          	addi	s4,s0,-132
 118:	894e                	mv	s2,s3
  for(int i = 0; i < NUM_CHILDREN; i++) {
    int status;
    int pid = wait(&status);
    
    // Find which child this was
    for(int j = 0; j < NUM_CHILDREN; j++) {
 11a:	4a81                	li	s5,0
 11c:	4495                	li	s1,5
 11e:	a04d                	j	1c0 <test_basic_fifo+0x168>
      print("pipe creation failed\n");
 120:	00001517          	auipc	a0,0x1
 124:	eb050513          	addi	a0,a0,-336 # fd0 <malloc+0x110>
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <print>
      exit(1);
 130:	4505                	li	a0,1
 132:	00001097          	auipc	ra,0x1
 136:	948080e7          	jalr	-1720(ra) # a7a <exit>
      print("fork failed\n");
 13a:	00001517          	auipc	a0,0x1
 13e:	eae50513          	addi	a0,a0,-338 # fe8 <malloc+0x128>
 142:	00000097          	auipc	ra,0x0
 146:	ebe080e7          	jalr	-322(ra) # 0 <print>
      exit(1);
 14a:	4505                	li	a0,1
 14c:	00001097          	auipc	ra,0x1
 150:	92e080e7          	jalr	-1746(ra) # a7a <exit>
      close(pipes[i][PIPE_WRITE]); // Child only reads
 154:	00349913          	slli	s2,s1,0x3
 158:	fc040793          	addi	a5,s0,-64
 15c:	993e                	add	s2,s2,a5
 15e:	fc492503          	lw	a0,-60(s2)
 162:	00001097          	auipc	ra,0x1
 166:	940080e7          	jalr	-1728(ra) # aa2 <close>
      read(pipes[i][PIPE_READ], &signal, 1);
 16a:	4605                	li	a2,1
 16c:	f6440593          	addi	a1,s0,-156
 170:	fc092503          	lw	a0,-64(s2)
 174:	00001097          	auipc	ra,0x1
 178:	91e080e7          	jalr	-1762(ra) # a92 <read>
      close(pipes[i][PIPE_READ]);
 17c:	fc092503          	lw	a0,-64(s2)
 180:	00001097          	auipc	ra,0x1
 184:	922080e7          	jalr	-1758(ra) # aa2 <close>
      do_work();
 188:	00000097          	auipc	ra,0x0
 18c:	ea6080e7          	jalr	-346(ra) # 2e <do_work>
      printf("Child %d (PID %d) executed\n", i, getpid());
 190:	00001097          	auipc	ra,0x1
 194:	96a080e7          	jalr	-1686(ra) # afa <getpid>
 198:	862a                	mv	a2,a0
 19a:	85a6                	mv	a1,s1
 19c:	00001517          	auipc	a0,0x1
 1a0:	e5c50513          	addi	a0,a0,-420 # ff8 <malloc+0x138>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	c5e080e7          	jalr	-930(ra) # e02 <printf>
      exit(i); // Exit with child ID
 1ac:	8526                	mv	a0,s1
 1ae:	00001097          	auipc	ra,0x1
 1b2:	8cc080e7          	jalr	-1844(ra) # a7a <exit>
      if(pids[j] == pid) {
        exit_order[i] = j;
 1b6:	00e92023          	sw	a4,0(s2)
  for(int i = 0; i < NUM_CHILDREN; i++) {
 1ba:	0911                	addi	s2,s2,4
 1bc:	03490363          	beq	s2,s4,1e2 <test_basic_fifo+0x18a>
    int pid = wait(&status);
 1c0:	f6440513          	addi	a0,s0,-156
 1c4:	00001097          	auipc	ra,0x1
 1c8:	8be080e7          	jalr	-1858(ra) # a82 <wait>
 1cc:	fa840793          	addi	a5,s0,-88
    for(int j = 0; j < NUM_CHILDREN; j++) {
 1d0:	8756                	mv	a4,s5
      if(pids[j] == pid) {
 1d2:	4394                	lw	a3,0(a5)
 1d4:	fea681e3          	beq	a3,a0,1b6 <test_basic_fifo+0x15e>
    for(int j = 0; j < NUM_CHILDREN; j++) {
 1d8:	2705                	addiw	a4,a4,1
 1da:	0791                	addi	a5,a5,4
 1dc:	fe971be3          	bne	a4,s1,1d2 <test_basic_fifo+0x17a>
 1e0:	bfe9                	j	1ba <test_basic_fifo+0x162>
      }
    }
  }
  
  // Check if children executed in FIFO order (0, 1, 2, 3, 4)
  print("Expected order: 0 1 2 3 4\n");
 1e2:	00001517          	auipc	a0,0x1
 1e6:	e6650513          	addi	a0,a0,-410 # 1048 <malloc+0x188>
 1ea:	00000097          	auipc	ra,0x0
 1ee:	e16080e7          	jalr	-490(ra) # 0 <print>
  printf("Actual order:   ");
 1f2:	00001517          	auipc	a0,0x1
 1f6:	e7650513          	addi	a0,a0,-394 # 1068 <malloc+0x1a8>
 1fa:	00001097          	auipc	ra,0x1
 1fe:	c08080e7          	jalr	-1016(ra) # e02 <printf>
 202:	84ce                	mv	s1,s3
  for(int i = 0; i < NUM_CHILDREN; i++) {
    printf("%d ", exit_order[i]);
 204:	00001917          	auipc	s2,0x1
 208:	e7c90913          	addi	s2,s2,-388 # 1080 <malloc+0x1c0>
 20c:	408c                	lw	a1,0(s1)
 20e:	854a                	mv	a0,s2
 210:	00001097          	auipc	ra,0x1
 214:	bf2080e7          	jalr	-1038(ra) # e02 <printf>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 218:	0491                	addi	s1,s1,4
 21a:	ff4499e3          	bne	s1,s4,20c <test_basic_fifo+0x1b4>
  }
  printf("\n");
 21e:	00001517          	auipc	a0,0x1
 222:	e2250513          	addi	a0,a0,-478 # 1040 <malloc+0x180>
 226:	00001097          	auipc	ra,0x1
 22a:	bdc080e7          	jalr	-1060(ra) # e02 <printf>
  
  int correct_order = 1;
  for(int i = 0; i < NUM_CHILDREN; i++) {
 22e:	4781                	li	a5,0
 230:	4695                	li	a3,5
    if(exit_order[i] != i) {
 232:	0009a703          	lw	a4,0(s3)
 236:	02f71f63          	bne	a4,a5,274 <test_basic_fifo+0x21c>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 23a:	2785                	addiw	a5,a5,1
 23c:	0991                	addi	s3,s3,4
 23e:	fed79ae3          	bne	a5,a3,232 <test_basic_fifo+0x1da>
      break;
    }
  }
  
  if(correct_order) {
    print("PASS: Basic FIFO ordering correct\n");
 242:	00001517          	auipc	a0,0x1
 246:	e4650513          	addi	a0,a0,-442 # 1088 <malloc+0x1c8>
 24a:	00000097          	auipc	ra,0x0
 24e:	db6080e7          	jalr	-586(ra) # 0 <print>
  } else {
    print("FAIL: Basic FIFO ordering incorrect\n");
  }
  
  print("\n");
 252:	00001517          	auipc	a0,0x1
 256:	dee50513          	addi	a0,a0,-530 # 1040 <malloc+0x180>
 25a:	00000097          	auipc	ra,0x0
 25e:	da6080e7          	jalr	-602(ra) # 0 <print>
}
 262:	60ea                	ld	ra,152(sp)
 264:	644a                	ld	s0,144(sp)
 266:	64aa                	ld	s1,136(sp)
 268:	690a                	ld	s2,128(sp)
 26a:	79e6                	ld	s3,120(sp)
 26c:	7a46                	ld	s4,112(sp)
 26e:	7aa6                	ld	s5,104(sp)
 270:	610d                	addi	sp,sp,160
 272:	8082                	ret
    print("FAIL: Basic FIFO ordering incorrect\n");
 274:	00001517          	auipc	a0,0x1
 278:	e3c50513          	addi	a0,a0,-452 # 10b0 <malloc+0x1f0>
 27c:	00000097          	auipc	ra,0x0
 280:	d84080e7          	jalr	-636(ra) # 0 <print>
 284:	b7f9                	j	252 <test_basic_fifo+0x1fa>

0000000000000286 <test_fifo_after_sleep>:

// Test FIFO after sleep - processes that wake up should maintain FIFO order
void
test_fifo_after_sleep()
{
 286:	7119                	addi	sp,sp,-128
 288:	fc86                	sd	ra,120(sp)
 28a:	f8a2                	sd	s0,112(sp)
 28c:	f4a6                	sd	s1,104(sp)
 28e:	f0ca                	sd	s2,96(sp)
 290:	ecce                	sd	s3,88(sp)
 292:	e8d2                	sd	s4,80(sp)
 294:	e4d6                	sd	s5,72(sp)
 296:	0100                	addi	s0,sp,128
  int pids[NUM_CHILDREN];
  int sync_pipe[2];
  
  print("=== Test 2: FIFO After Sleep ===\n");
 298:	00001517          	auipc	a0,0x1
 29c:	e4050513          	addi	a0,a0,-448 # 10d8 <malloc+0x218>
 2a0:	00000097          	auipc	ra,0x0
 2a4:	d60080e7          	jalr	-672(ra) # 0 <print>
  
  if(pipe(sync_pipe) < 0) {
 2a8:	fa040513          	addi	a0,s0,-96
 2ac:	00000097          	auipc	ra,0x0
 2b0:	7de080e7          	jalr	2014(ra) # a8a <pipe>
 2b4:	04054763          	bltz	a0,302 <test_fifo_after_sleep+0x7c>
 2b8:	fa840913          	addi	s2,s0,-88
    print("pipe creation failed\n");
    exit(1);
  }
  
  // Fork children
  for(int i = 0; i < NUM_CHILDREN; i++) {
 2bc:	4481                	li	s1,0
 2be:	4995                	li	s3,5
    pids[i] = fork();
 2c0:	00000097          	auipc	ra,0x0
 2c4:	7b2080e7          	jalr	1970(ra) # a72 <fork>
 2c8:	00a92023          	sw	a0,0(s2)
    if(pids[i] < 0) {
 2cc:	04054863          	bltz	a0,31c <test_fifo_after_sleep+0x96>
      print("fork failed\n");
      exit(1);
    }
    
    if(pids[i] == 0) {
 2d0:	c13d                	beqz	a0,336 <test_fifo_after_sleep+0xb0>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 2d2:	2485                	addiw	s1,s1,1
 2d4:	0911                	addi	s2,s2,4
 2d6:	ff3495e3          	bne	s1,s3,2c0 <test_fifo_after_sleep+0x3a>
      printf("Woken child %d (PID %d) executed\n", i, getpid());
      exit(i);
    }
  }
  
  close(sync_pipe[PIPE_READ]);
 2da:	fa042503          	lw	a0,-96(s0)
 2de:	00000097          	auipc	ra,0x0
 2e2:	7c4080e7          	jalr	1988(ra) # aa2 <close>
  close(sync_pipe[PIPE_WRITE]);
 2e6:	fa442503          	lw	a0,-92(s0)
 2ea:	00000097          	auipc	ra,0x0
 2ee:	7b8080e7          	jalr	1976(ra) # aa2 <close>
  
  // Wait for all children and record their execution order
  int exit_order[NUM_CHILDREN];
  for(int i = 0; i < NUM_CHILDREN; i++) {
 2f2:	f8840993          	addi	s3,s0,-120
 2f6:	f9c40a13          	addi	s4,s0,-100
  close(sync_pipe[PIPE_WRITE]);
 2fa:	894e                	mv	s2,s3
    int status;
    int pid = wait(&status);
    
    // Find which child this was
    for(int j = 0; j < NUM_CHILDREN; j++) {
 2fc:	4a81                	li	s5,0
 2fe:	4495                	li	s1,5
 300:	a059                	j	386 <test_fifo_after_sleep+0x100>
    print("pipe creation failed\n");
 302:	00001517          	auipc	a0,0x1
 306:	cce50513          	addi	a0,a0,-818 # fd0 <malloc+0x110>
 30a:	00000097          	auipc	ra,0x0
 30e:	cf6080e7          	jalr	-778(ra) # 0 <print>
    exit(1);
 312:	4505                	li	a0,1
 314:	00000097          	auipc	ra,0x0
 318:	766080e7          	jalr	1894(ra) # a7a <exit>
      print("fork failed\n");
 31c:	00001517          	auipc	a0,0x1
 320:	ccc50513          	addi	a0,a0,-820 # fe8 <malloc+0x128>
 324:	00000097          	auipc	ra,0x0
 328:	cdc080e7          	jalr	-804(ra) # 0 <print>
      exit(1);
 32c:	4505                	li	a0,1
 32e:	00000097          	auipc	ra,0x0
 332:	74c080e7          	jalr	1868(ra) # a7a <exit>
      close(sync_pipe[PIPE_WRITE]);
 336:	fa442503          	lw	a0,-92(s0)
 33a:	00000097          	auipc	ra,0x0
 33e:	768080e7          	jalr	1896(ra) # aa2 <close>
      sleep(1 + i);  // Child 0 sleeps 1 tick, child 1 sleeps 2 ticks, etc.
 342:	0014851b          	addiw	a0,s1,1
 346:	00000097          	auipc	ra,0x0
 34a:	7c4080e7          	jalr	1988(ra) # b0a <sleep>
      do_work();
 34e:	00000097          	auipc	ra,0x0
 352:	ce0080e7          	jalr	-800(ra) # 2e <do_work>
      printf("Woken child %d (PID %d) executed\n", i, getpid());
 356:	00000097          	auipc	ra,0x0
 35a:	7a4080e7          	jalr	1956(ra) # afa <getpid>
 35e:	862a                	mv	a2,a0
 360:	85a6                	mv	a1,s1
 362:	00001517          	auipc	a0,0x1
 366:	d9e50513          	addi	a0,a0,-610 # 1100 <malloc+0x240>
 36a:	00001097          	auipc	ra,0x1
 36e:	a98080e7          	jalr	-1384(ra) # e02 <printf>
      exit(i);
 372:	8526                	mv	a0,s1
 374:	00000097          	auipc	ra,0x0
 378:	706080e7          	jalr	1798(ra) # a7a <exit>
      if(pids[j] == pid) {
        exit_order[i] = j;
 37c:	00e92023          	sw	a4,0(s2)
  for(int i = 0; i < NUM_CHILDREN; i++) {
 380:	0911                	addi	s2,s2,4
 382:	03490363          	beq	s2,s4,3a8 <test_fifo_after_sleep+0x122>
    int pid = wait(&status);
 386:	f8440513          	addi	a0,s0,-124
 38a:	00000097          	auipc	ra,0x0
 38e:	6f8080e7          	jalr	1784(ra) # a82 <wait>
 392:	fa840793          	addi	a5,s0,-88
    for(int j = 0; j < NUM_CHILDREN; j++) {
 396:	8756                	mv	a4,s5
      if(pids[j] == pid) {
 398:	4394                	lw	a3,0(a5)
 39a:	fea681e3          	beq	a3,a0,37c <test_fifo_after_sleep+0xf6>
    for(int j = 0; j < NUM_CHILDREN; j++) {
 39e:	2705                	addiw	a4,a4,1
 3a0:	0791                	addi	a5,a5,4
 3a2:	fe971be3          	bne	a4,s1,398 <test_fifo_after_sleep+0x112>
 3a6:	bfe9                	j	380 <test_fifo_after_sleep+0xfa>
      }
    }
  }
  
  // Check if children woke up and executed in FIFO order
  print("Expected wake order: 0 1 2 3 4\n");
 3a8:	00001517          	auipc	a0,0x1
 3ac:	d8050513          	addi	a0,a0,-640 # 1128 <malloc+0x268>
 3b0:	00000097          	auipc	ra,0x0
 3b4:	c50080e7          	jalr	-944(ra) # 0 <print>
  printf("Actual wake order:   ");
 3b8:	00001517          	auipc	a0,0x1
 3bc:	d9050513          	addi	a0,a0,-624 # 1148 <malloc+0x288>
 3c0:	00001097          	auipc	ra,0x1
 3c4:	a42080e7          	jalr	-1470(ra) # e02 <printf>
 3c8:	84ce                	mv	s1,s3
  for(int i = 0; i < NUM_CHILDREN; i++) {
    printf("%d ", exit_order[i]);
 3ca:	00001917          	auipc	s2,0x1
 3ce:	cb690913          	addi	s2,s2,-842 # 1080 <malloc+0x1c0>
 3d2:	408c                	lw	a1,0(s1)
 3d4:	854a                	mv	a0,s2
 3d6:	00001097          	auipc	ra,0x1
 3da:	a2c080e7          	jalr	-1492(ra) # e02 <printf>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 3de:	0491                	addi	s1,s1,4
 3e0:	ff4499e3          	bne	s1,s4,3d2 <test_fifo_after_sleep+0x14c>
  }
  printf("\n");
 3e4:	00001517          	auipc	a0,0x1
 3e8:	c5c50513          	addi	a0,a0,-932 # 1040 <malloc+0x180>
 3ec:	00001097          	auipc	ra,0x1
 3f0:	a16080e7          	jalr	-1514(ra) # e02 <printf>
  
  int correct_order = 1;
  for(int i = 0; i < NUM_CHILDREN; i++) {
 3f4:	4781                	li	a5,0
 3f6:	4695                	li	a3,5
    if(exit_order[i] != i) {
 3f8:	0009a703          	lw	a4,0(s3)
 3fc:	02f71f63          	bne	a4,a5,43a <test_fifo_after_sleep+0x1b4>
  for(int i = 0; i < NUM_CHILDREN; i++) {
 400:	2785                	addiw	a5,a5,1
 402:	0991                	addi	s3,s3,4
 404:	fed79ae3          	bne	a5,a3,3f8 <test_fifo_after_sleep+0x172>
      break;
    }
  }
  
  if(correct_order) {
    print("PASS: FIFO after sleep correct\n");
 408:	00001517          	auipc	a0,0x1
 40c:	d5850513          	addi	a0,a0,-680 # 1160 <malloc+0x2a0>
 410:	00000097          	auipc	ra,0x0
 414:	bf0080e7          	jalr	-1040(ra) # 0 <print>
  } else {
    print("FAIL: FIFO after sleep incorrect\n");
  }
  
  print("\n");
 418:	00001517          	auipc	a0,0x1
 41c:	c2850513          	addi	a0,a0,-984 # 1040 <malloc+0x180>
 420:	00000097          	auipc	ra,0x0
 424:	be0080e7          	jalr	-1056(ra) # 0 <print>
}
 428:	70e6                	ld	ra,120(sp)
 42a:	7446                	ld	s0,112(sp)
 42c:	74a6                	ld	s1,104(sp)
 42e:	7906                	ld	s2,96(sp)
 430:	69e6                	ld	s3,88(sp)
 432:	6a46                	ld	s4,80(sp)
 434:	6aa6                	ld	s5,72(sp)
 436:	6109                	addi	sp,sp,128
 438:	8082                	ret
    print("FAIL: FIFO after sleep incorrect\n");
 43a:	00001517          	auipc	a0,0x1
 43e:	d4650513          	addi	a0,a0,-698 # 1180 <malloc+0x2c0>
 442:	00000097          	auipc	ra,0x0
 446:	bbe080e7          	jalr	-1090(ra) # 0 <print>
 44a:	b7f9                	j	418 <test_fifo_after_sleep+0x192>

000000000000044c <test_fifo_with_yield>:

// Test FIFO with yield - processes that yield should go to back of queue
void
test_fifo_with_yield()
{
 44c:	711d                	addi	sp,sp,-96
 44e:	ec86                	sd	ra,88(sp)
 450:	e8a2                	sd	s0,80(sp)
 452:	e4a6                	sd	s1,72(sp)
 454:	e0ca                	sd	s2,64(sp)
 456:	fc4e                	sd	s3,56(sp)
 458:	1080                	addi	s0,sp,96
  print("=== Test 3: FIFO with Yield ===\n");
 45a:	00001517          	auipc	a0,0x1
 45e:	d4e50513          	addi	a0,a0,-690 # 11a8 <malloc+0x2e8>
 462:	00000097          	auipc	ra,0x0
 466:	b9e080e7          	jalr	-1122(ra) # 0 <print>
  
  int pipe1[2], pipe2[2], pipe3[2];
  
  if(pipe(pipe1) < 0 || pipe(pipe2) < 0 || pipe(pipe3) < 0) {
 46a:	fc840513          	addi	a0,s0,-56
 46e:	00000097          	auipc	ra,0x0
 472:	61c080e7          	jalr	1564(ra) # a8a <pipe>
 476:	14054863          	bltz	a0,5c6 <test_fifo_with_yield+0x17a>
 47a:	fc040513          	addi	a0,s0,-64
 47e:	00000097          	auipc	ra,0x0
 482:	60c080e7          	jalr	1548(ra) # a8a <pipe>
 486:	14054063          	bltz	a0,5c6 <test_fifo_with_yield+0x17a>
 48a:	fb840513          	addi	a0,s0,-72
 48e:	00000097          	auipc	ra,0x0
 492:	5fc080e7          	jalr	1532(ra) # a8a <pipe>
 496:	12054863          	bltz	a0,5c6 <test_fifo_with_yield+0x17a>
    print("pipe creation failed\n");
    exit(1);
  }
  
  int pid1 = fork();
 49a:	00000097          	auipc	ra,0x0
 49e:	5d8080e7          	jalr	1496(ra) # a72 <fork>
  if(pid1 < 0) {
 4a2:	12054f63          	bltz	a0,5e0 <test_fifo_with_yield+0x194>
    print("fork failed\n");
    exit(1);
  }
  
  if(pid1 == 0) {
 4a6:	14050a63          	beqz	a0,5fa <test_fifo_with_yield+0x1ae>
    
    printf("Child 1 running after yield\n");
    exit(1);
  }
  
  close(pipe1[PIPE_WRITE]);
 4aa:	fcc42503          	lw	a0,-52(s0)
 4ae:	00000097          	auipc	ra,0x0
 4b2:	5f4080e7          	jalr	1524(ra) # aa2 <close>
  
  int pid2 = fork();
 4b6:	00000097          	auipc	ra,0x0
 4ba:	5bc080e7          	jalr	1468(ra) # a72 <fork>
  if(pid2 < 0) {
 4be:	1c054863          	bltz	a0,68e <test_fifo_with_yield+0x242>
    print("fork failed\n");
    exit(1);
  }
  
  if(pid2 == 0) {
 4c2:	1e050363          	beqz	a0,6a8 <test_fifo_with_yield+0x25c>
    do_work();
    printf("Child 2 running normally\n");
    exit(2);
  }
  
  close(pipe2[PIPE_WRITE]);
 4c6:	fc442503          	lw	a0,-60(s0)
 4ca:	00000097          	auipc	ra,0x0
 4ce:	5d8080e7          	jalr	1496(ra) # aa2 <close>
  
  int pid3 = fork();
 4d2:	00000097          	auipc	ra,0x0
 4d6:	5a0080e7          	jalr	1440(ra) # a72 <fork>
  if(pid3 < 0) {
 4da:	24054263          	bltz	a0,71e <test_fifo_with_yield+0x2d2>
    print("fork failed\n");
    exit(1);
  }
  
  if(pid3 == 0) {
 4de:	24050d63          	beqz	a0,738 <test_fifo_with_yield+0x2ec>
    do_work();
    printf("Child 3 running normally\n");
    exit(3);
  }
  
  close(pipe3[PIPE_WRITE]);
 4e2:	fbc42503          	lw	a0,-68(s0)
 4e6:	00000097          	auipc	ra,0x0
 4ea:	5bc080e7          	jalr	1468(ra) # aa2 <close>
  
  // Wait for all children to be ready
  char signal;
  read(pipe1[PIPE_READ], &signal, 1);  // Child 1 yielded
 4ee:	4605                	li	a2,1
 4f0:	fb740593          	addi	a1,s0,-73
 4f4:	fc842503          	lw	a0,-56(s0)
 4f8:	00000097          	auipc	ra,0x0
 4fc:	59a080e7          	jalr	1434(ra) # a92 <read>
  read(pipe2[PIPE_READ], &signal, 1);  // Child 2 ready
 500:	4605                	li	a2,1
 502:	fb740593          	addi	a1,s0,-73
 506:	fc042503          	lw	a0,-64(s0)
 50a:	00000097          	auipc	ra,0x0
 50e:	588080e7          	jalr	1416(ra) # a92 <read>
  read(pipe3[PIPE_READ], &signal, 1);  // Child 3 ready
 512:	4605                	li	a2,1
 514:	fb740593          	addi	a1,s0,-73
 518:	fb842503          	lw	a0,-72(s0)
 51c:	00000097          	auipc	ra,0x0
 520:	576080e7          	jalr	1398(ra) # a92 <read>
  
  close(pipe1[PIPE_READ]);
 524:	fc842503          	lw	a0,-56(s0)
 528:	00000097          	auipc	ra,0x0
 52c:	57a080e7          	jalr	1402(ra) # aa2 <close>
  close(pipe2[PIPE_READ]);
 530:	fc042503          	lw	a0,-64(s0)
 534:	00000097          	auipc	ra,0x0
 538:	56e080e7          	jalr	1390(ra) # aa2 <close>
  close(pipe3[PIPE_READ]);
 53c:	fb842503          	lw	a0,-72(s0)
 540:	00000097          	auipc	ra,0x0
 544:	562080e7          	jalr	1378(ra) # aa2 <close>
  
  // Collect results
  int results[3];
  for(int i = 0; i < 3; i++) {
 548:	fa840493          	addi	s1,s0,-88
 54c:	fb440993          	addi	s3,s0,-76
    int status;
    int pid = wait(&status);
    results[i] = status;
    // Print the exit code and pid for visibility
    printf("Child exited: exit code=%d pid=%d\n", status, pid);
 550:	00001917          	auipc	s2,0x1
 554:	cf890913          	addi	s2,s2,-776 # 1248 <malloc+0x388>
    int pid = wait(&status);
 558:	fa440513          	addi	a0,s0,-92
 55c:	00000097          	auipc	ra,0x0
 560:	526080e7          	jalr	1318(ra) # a82 <wait>
 564:	862a                	mv	a2,a0
    results[i] = status;
 566:	fa442583          	lw	a1,-92(s0)
 56a:	c08c                	sw	a1,0(s1)
    printf("Child exited: exit code=%d pid=%d\n", status, pid);
 56c:	854a                	mv	a0,s2
 56e:	00001097          	auipc	ra,0x1
 572:	894080e7          	jalr	-1900(ra) # e02 <printf>
  for(int i = 0; i < 3; i++) {
 576:	0491                	addi	s1,s1,4
 578:	ff3490e3          	bne	s1,s3,558 <test_fifo_with_yield+0x10c>
  }
  
  print("Children have completed yield test\n");
 57c:	00001517          	auipc	a0,0x1
 580:	cf450513          	addi	a0,a0,-780 # 1270 <malloc+0x3b0>
 584:	00000097          	auipc	ra,0x0
 588:	a7c080e7          	jalr	-1412(ra) # 0 <print>
  // Print summary of results array
  printf("Yield test exit codes: %d %d %d\n", results[0], results[1], results[2]);
 58c:	fb042683          	lw	a3,-80(s0)
 590:	fac42603          	lw	a2,-84(s0)
 594:	fa842583          	lw	a1,-88(s0)
 598:	00001517          	auipc	a0,0x1
 59c:	d0050513          	addi	a0,a0,-768 # 1298 <malloc+0x3d8>
 5a0:	00001097          	auipc	ra,0x1
 5a4:	862080e7          	jalr	-1950(ra) # e02 <printf>
  print("PASS: FIFO with yield test completed\n\n");
 5a8:	00001517          	auipc	a0,0x1
 5ac:	d1850513          	addi	a0,a0,-744 # 12c0 <malloc+0x400>
 5b0:	00000097          	auipc	ra,0x0
 5b4:	a50080e7          	jalr	-1456(ra) # 0 <print>
}
 5b8:	60e6                	ld	ra,88(sp)
 5ba:	6446                	ld	s0,80(sp)
 5bc:	64a6                	ld	s1,72(sp)
 5be:	6906                	ld	s2,64(sp)
 5c0:	79e2                	ld	s3,56(sp)
 5c2:	6125                	addi	sp,sp,96
 5c4:	8082                	ret
    print("pipe creation failed\n");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	a0a50513          	addi	a0,a0,-1526 # fd0 <malloc+0x110>
 5ce:	00000097          	auipc	ra,0x0
 5d2:	a32080e7          	jalr	-1486(ra) # 0 <print>
    exit(1);
 5d6:	4505                	li	a0,1
 5d8:	00000097          	auipc	ra,0x0
 5dc:	4a2080e7          	jalr	1186(ra) # a7a <exit>
    print("fork failed\n");
 5e0:	00001517          	auipc	a0,0x1
 5e4:	a0850513          	addi	a0,a0,-1528 # fe8 <malloc+0x128>
 5e8:	00000097          	auipc	ra,0x0
 5ec:	a18080e7          	jalr	-1512(ra) # 0 <print>
    exit(1);
 5f0:	4505                	li	a0,1
 5f2:	00000097          	auipc	ra,0x0
 5f6:	488080e7          	jalr	1160(ra) # a7a <exit>
    close(pipe1[PIPE_READ]);
 5fa:	fc842503          	lw	a0,-56(s0)
 5fe:	00000097          	auipc	ra,0x0
 602:	4a4080e7          	jalr	1188(ra) # aa2 <close>
    close(pipe2[PIPE_READ]);
 606:	fc042503          	lw	a0,-64(s0)
 60a:	00000097          	auipc	ra,0x0
 60e:	498080e7          	jalr	1176(ra) # aa2 <close>
    close(pipe2[PIPE_WRITE]);
 612:	fc442503          	lw	a0,-60(s0)
 616:	00000097          	auipc	ra,0x0
 61a:	48c080e7          	jalr	1164(ra) # aa2 <close>
    close(pipe3[PIPE_READ]);
 61e:	fb842503          	lw	a0,-72(s0)
 622:	00000097          	auipc	ra,0x0
 626:	480080e7          	jalr	1152(ra) # aa2 <close>
    close(pipe3[PIPE_WRITE]);
 62a:	fbc42503          	lw	a0,-68(s0)
 62e:	00000097          	auipc	ra,0x0
 632:	474080e7          	jalr	1140(ra) # aa2 <close>
    printf("Child 1 yielding...\n");
 636:	00001517          	auipc	a0,0x1
 63a:	b9a50513          	addi	a0,a0,-1126 # 11d0 <malloc+0x310>
 63e:	00000097          	auipc	ra,0x0
 642:	7c4080e7          	jalr	1988(ra) # e02 <printf>
    char signal = 1;
 646:	4785                	li	a5,1
 648:	faf40223          	sb	a5,-92(s0)
    write(pipe1[PIPE_WRITE], &signal, 1);
 64c:	4605                	li	a2,1
 64e:	fa440593          	addi	a1,s0,-92
 652:	fcc42503          	lw	a0,-52(s0)
 656:	00000097          	auipc	ra,0x0
 65a:	444080e7          	jalr	1092(ra) # a9a <write>
    close(pipe1[PIPE_WRITE]);
 65e:	fcc42503          	lw	a0,-52(s0)
 662:	00000097          	auipc	ra,0x0
 666:	440080e7          	jalr	1088(ra) # aa2 <close>
    sleep(0);  // Brief sleep to yield
 66a:	4501                	li	a0,0
 66c:	00000097          	auipc	ra,0x0
 670:	49e080e7          	jalr	1182(ra) # b0a <sleep>
    printf("Child 1 running after yield\n");
 674:	00001517          	auipc	a0,0x1
 678:	b7450513          	addi	a0,a0,-1164 # 11e8 <malloc+0x328>
 67c:	00000097          	auipc	ra,0x0
 680:	786080e7          	jalr	1926(ra) # e02 <printf>
    exit(1);
 684:	4505                	li	a0,1
 686:	00000097          	auipc	ra,0x0
 68a:	3f4080e7          	jalr	1012(ra) # a7a <exit>
    print("fork failed\n");
 68e:	00001517          	auipc	a0,0x1
 692:	95a50513          	addi	a0,a0,-1702 # fe8 <malloc+0x128>
 696:	00000097          	auipc	ra,0x0
 69a:	96a080e7          	jalr	-1686(ra) # 0 <print>
    exit(1);
 69e:	4505                	li	a0,1
 6a0:	00000097          	auipc	ra,0x0
 6a4:	3da080e7          	jalr	986(ra) # a7a <exit>
    close(pipe1[PIPE_READ]);
 6a8:	fc842503          	lw	a0,-56(s0)
 6ac:	00000097          	auipc	ra,0x0
 6b0:	3f6080e7          	jalr	1014(ra) # aa2 <close>
    close(pipe2[PIPE_READ]);
 6b4:	fc042503          	lw	a0,-64(s0)
 6b8:	00000097          	auipc	ra,0x0
 6bc:	3ea080e7          	jalr	1002(ra) # aa2 <close>
    close(pipe3[PIPE_READ]);
 6c0:	fb842503          	lw	a0,-72(s0)
 6c4:	00000097          	auipc	ra,0x0
 6c8:	3de080e7          	jalr	990(ra) # aa2 <close>
    close(pipe3[PIPE_WRITE]);
 6cc:	fbc42503          	lw	a0,-68(s0)
 6d0:	00000097          	auipc	ra,0x0
 6d4:	3d2080e7          	jalr	978(ra) # aa2 <close>
    char signal = 2;
 6d8:	4789                	li	a5,2
 6da:	faf40223          	sb	a5,-92(s0)
    write(pipe2[PIPE_WRITE], &signal, 1);
 6de:	4605                	li	a2,1
 6e0:	fa440593          	addi	a1,s0,-92
 6e4:	fc442503          	lw	a0,-60(s0)
 6e8:	00000097          	auipc	ra,0x0
 6ec:	3b2080e7          	jalr	946(ra) # a9a <write>
    close(pipe2[PIPE_WRITE]);
 6f0:	fc442503          	lw	a0,-60(s0)
 6f4:	00000097          	auipc	ra,0x0
 6f8:	3ae080e7          	jalr	942(ra) # aa2 <close>
    do_work();
 6fc:	00000097          	auipc	ra,0x0
 700:	932080e7          	jalr	-1742(ra) # 2e <do_work>
    printf("Child 2 running normally\n");
 704:	00001517          	auipc	a0,0x1
 708:	b0450513          	addi	a0,a0,-1276 # 1208 <malloc+0x348>
 70c:	00000097          	auipc	ra,0x0
 710:	6f6080e7          	jalr	1782(ra) # e02 <printf>
    exit(2);
 714:	4509                	li	a0,2
 716:	00000097          	auipc	ra,0x0
 71a:	364080e7          	jalr	868(ra) # a7a <exit>
    print("fork failed\n");
 71e:	00001517          	auipc	a0,0x1
 722:	8ca50513          	addi	a0,a0,-1846 # fe8 <malloc+0x128>
 726:	00000097          	auipc	ra,0x0
 72a:	8da080e7          	jalr	-1830(ra) # 0 <print>
    exit(1);
 72e:	4505                	li	a0,1
 730:	00000097          	auipc	ra,0x0
 734:	34a080e7          	jalr	842(ra) # a7a <exit>
    close(pipe1[PIPE_READ]);
 738:	fc842503          	lw	a0,-56(s0)
 73c:	00000097          	auipc	ra,0x0
 740:	366080e7          	jalr	870(ra) # aa2 <close>
    close(pipe2[PIPE_READ]);
 744:	fc042503          	lw	a0,-64(s0)
 748:	00000097          	auipc	ra,0x0
 74c:	35a080e7          	jalr	858(ra) # aa2 <close>
    close(pipe3[PIPE_READ]);
 750:	fb842503          	lw	a0,-72(s0)
 754:	00000097          	auipc	ra,0x0
 758:	34e080e7          	jalr	846(ra) # aa2 <close>
    char signal = 3;
 75c:	478d                	li	a5,3
 75e:	faf40223          	sb	a5,-92(s0)
    write(pipe3[PIPE_WRITE], &signal, 1);
 762:	4605                	li	a2,1
 764:	fa440593          	addi	a1,s0,-92
 768:	fbc42503          	lw	a0,-68(s0)
 76c:	00000097          	auipc	ra,0x0
 770:	32e080e7          	jalr	814(ra) # a9a <write>
    close(pipe3[PIPE_WRITE]);
 774:	fbc42503          	lw	a0,-68(s0)
 778:	00000097          	auipc	ra,0x0
 77c:	32a080e7          	jalr	810(ra) # aa2 <close>
    do_work();
 780:	00000097          	auipc	ra,0x0
 784:	8ae080e7          	jalr	-1874(ra) # 2e <do_work>
    printf("Child 3 running normally\n");
 788:	00001517          	auipc	a0,0x1
 78c:	aa050513          	addi	a0,a0,-1376 # 1228 <malloc+0x368>
 790:	00000097          	auipc	ra,0x0
 794:	672080e7          	jalr	1650(ra) # e02 <printf>
    exit(3);
 798:	450d                	li	a0,3
 79a:	00000097          	auipc	ra,0x0
 79e:	2e0080e7          	jalr	736(ra) # a7a <exit>

00000000000007a2 <main>:

int
main(void)
{
 7a2:	1141                	addi	sp,sp,-16
 7a4:	e406                	sd	ra,8(sp)
 7a6:	e022                	sd	s0,0(sp)
 7a8:	0800                	addi	s0,sp,16
  print("Starting FIFO Scheduler Tests...\n\n");
 7aa:	00001517          	auipc	a0,0x1
 7ae:	b3e50513          	addi	a0,a0,-1218 # 12e8 <malloc+0x428>
 7b2:	00000097          	auipc	ra,0x0
 7b6:	84e080e7          	jalr	-1970(ra) # 0 <print>
  
  test_basic_fifo();
 7ba:	00000097          	auipc	ra,0x0
 7be:	89e080e7          	jalr	-1890(ra) # 58 <test_basic_fifo>
  test_fifo_after_sleep(); 
 7c2:	00000097          	auipc	ra,0x0
 7c6:	ac4080e7          	jalr	-1340(ra) # 286 <test_fifo_after_sleep>
  test_fifo_with_yield();
 7ca:	00000097          	auipc	ra,0x0
 7ce:	c82080e7          	jalr	-894(ra) # 44c <test_fifo_with_yield>
  
  print("=== FIFO Test Summary ===\n");
 7d2:	00001517          	auipc	a0,0x1
 7d6:	b3e50513          	addi	a0,a0,-1218 # 1310 <malloc+0x450>
 7da:	00000097          	auipc	ra,0x0
 7de:	826080e7          	jalr	-2010(ra) # 0 <print>
  print("All FIFO tests completed.\n");
 7e2:	00001517          	auipc	a0,0x1
 7e6:	b4e50513          	addi	a0,a0,-1202 # 1330 <malloc+0x470>
 7ea:	00000097          	auipc	ra,0x0
 7ee:	816080e7          	jalr	-2026(ra) # 0 <print>
  print("Check output above for individual test results.\n");
 7f2:	00001517          	auipc	a0,0x1
 7f6:	b5e50513          	addi	a0,a0,-1186 # 1350 <malloc+0x490>
 7fa:	00000097          	auipc	ra,0x0
 7fe:	806080e7          	jalr	-2042(ra) # 0 <print>
  
  exit(0);
 802:	4501                	li	a0,0
 804:	00000097          	auipc	ra,0x0
 808:	276080e7          	jalr	630(ra) # a7a <exit>

000000000000080c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 80c:	1141                	addi	sp,sp,-16
 80e:	e422                	sd	s0,8(sp)
 810:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 812:	87aa                	mv	a5,a0
 814:	0585                	addi	a1,a1,1
 816:	0785                	addi	a5,a5,1
 818:	fff5c703          	lbu	a4,-1(a1)
 81c:	fee78fa3          	sb	a4,-1(a5)
 820:	fb75                	bnez	a4,814 <strcpy+0x8>
    ;
  return os;
}
 822:	6422                	ld	s0,8(sp)
 824:	0141                	addi	sp,sp,16
 826:	8082                	ret

0000000000000828 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 828:	1141                	addi	sp,sp,-16
 82a:	e422                	sd	s0,8(sp)
 82c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 82e:	00054783          	lbu	a5,0(a0)
 832:	cb91                	beqz	a5,846 <strcmp+0x1e>
 834:	0005c703          	lbu	a4,0(a1)
 838:	00f71763          	bne	a4,a5,846 <strcmp+0x1e>
    p++, q++;
 83c:	0505                	addi	a0,a0,1
 83e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 840:	00054783          	lbu	a5,0(a0)
 844:	fbe5                	bnez	a5,834 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 846:	0005c503          	lbu	a0,0(a1)
}
 84a:	40a7853b          	subw	a0,a5,a0
 84e:	6422                	ld	s0,8(sp)
 850:	0141                	addi	sp,sp,16
 852:	8082                	ret

0000000000000854 <strlen>:

uint
strlen(const char *s)
{
 854:	1141                	addi	sp,sp,-16
 856:	e422                	sd	s0,8(sp)
 858:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 85a:	00054783          	lbu	a5,0(a0)
 85e:	cf91                	beqz	a5,87a <strlen+0x26>
 860:	0505                	addi	a0,a0,1
 862:	87aa                	mv	a5,a0
 864:	4685                	li	a3,1
 866:	9e89                	subw	a3,a3,a0
 868:	00f6853b          	addw	a0,a3,a5
 86c:	0785                	addi	a5,a5,1
 86e:	fff7c703          	lbu	a4,-1(a5)
 872:	fb7d                	bnez	a4,868 <strlen+0x14>
    ;
  return n;
}
 874:	6422                	ld	s0,8(sp)
 876:	0141                	addi	sp,sp,16
 878:	8082                	ret
  for(n = 0; s[n]; n++)
 87a:	4501                	li	a0,0
 87c:	bfe5                	j	874 <strlen+0x20>

000000000000087e <memset>:

void*
memset(void *dst, int c, uint n)
{
 87e:	1141                	addi	sp,sp,-16
 880:	e422                	sd	s0,8(sp)
 882:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 884:	ca19                	beqz	a2,89a <memset+0x1c>
 886:	87aa                	mv	a5,a0
 888:	1602                	slli	a2,a2,0x20
 88a:	9201                	srli	a2,a2,0x20
 88c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 890:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 894:	0785                	addi	a5,a5,1
 896:	fee79de3          	bne	a5,a4,890 <memset+0x12>
  }
  return dst;
}
 89a:	6422                	ld	s0,8(sp)
 89c:	0141                	addi	sp,sp,16
 89e:	8082                	ret

00000000000008a0 <strchr>:

char*
strchr(const char *s, char c)
{
 8a0:	1141                	addi	sp,sp,-16
 8a2:	e422                	sd	s0,8(sp)
 8a4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 8a6:	00054783          	lbu	a5,0(a0)
 8aa:	cb99                	beqz	a5,8c0 <strchr+0x20>
    if(*s == c)
 8ac:	00f58763          	beq	a1,a5,8ba <strchr+0x1a>
  for(; *s; s++)
 8b0:	0505                	addi	a0,a0,1
 8b2:	00054783          	lbu	a5,0(a0)
 8b6:	fbfd                	bnez	a5,8ac <strchr+0xc>
      return (char*)s;
  return 0;
 8b8:	4501                	li	a0,0
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret
  return 0;
 8c0:	4501                	li	a0,0
 8c2:	bfe5                	j	8ba <strchr+0x1a>

00000000000008c4 <gets>:

char*
gets(char *buf, int max)
{
 8c4:	711d                	addi	sp,sp,-96
 8c6:	ec86                	sd	ra,88(sp)
 8c8:	e8a2                	sd	s0,80(sp)
 8ca:	e4a6                	sd	s1,72(sp)
 8cc:	e0ca                	sd	s2,64(sp)
 8ce:	fc4e                	sd	s3,56(sp)
 8d0:	f852                	sd	s4,48(sp)
 8d2:	f456                	sd	s5,40(sp)
 8d4:	f05a                	sd	s6,32(sp)
 8d6:	ec5e                	sd	s7,24(sp)
 8d8:	1080                	addi	s0,sp,96
 8da:	8baa                	mv	s7,a0
 8dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8de:	892a                	mv	s2,a0
 8e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 8e2:	4aa9                	li	s5,10
 8e4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 8e6:	89a6                	mv	s3,s1
 8e8:	2485                	addiw	s1,s1,1
 8ea:	0344d863          	bge	s1,s4,91a <gets+0x56>
    cc = read(0, &c, 1);
 8ee:	4605                	li	a2,1
 8f0:	faf40593          	addi	a1,s0,-81
 8f4:	4501                	li	a0,0
 8f6:	00000097          	auipc	ra,0x0
 8fa:	19c080e7          	jalr	412(ra) # a92 <read>
    if(cc < 1)
 8fe:	00a05e63          	blez	a0,91a <gets+0x56>
    buf[i++] = c;
 902:	faf44783          	lbu	a5,-81(s0)
 906:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 90a:	01578763          	beq	a5,s5,918 <gets+0x54>
 90e:	0905                	addi	s2,s2,1
 910:	fd679be3          	bne	a5,s6,8e6 <gets+0x22>
  for(i=0; i+1 < max; ){
 914:	89a6                	mv	s3,s1
 916:	a011                	j	91a <gets+0x56>
 918:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 91a:	99de                	add	s3,s3,s7
 91c:	00098023          	sb	zero,0(s3)
  return buf;
}
 920:	855e                	mv	a0,s7
 922:	60e6                	ld	ra,88(sp)
 924:	6446                	ld	s0,80(sp)
 926:	64a6                	ld	s1,72(sp)
 928:	6906                	ld	s2,64(sp)
 92a:	79e2                	ld	s3,56(sp)
 92c:	7a42                	ld	s4,48(sp)
 92e:	7aa2                	ld	s5,40(sp)
 930:	7b02                	ld	s6,32(sp)
 932:	6be2                	ld	s7,24(sp)
 934:	6125                	addi	sp,sp,96
 936:	8082                	ret

0000000000000938 <stat>:

int
stat(const char *n, struct stat *st)
{
 938:	1101                	addi	sp,sp,-32
 93a:	ec06                	sd	ra,24(sp)
 93c:	e822                	sd	s0,16(sp)
 93e:	e426                	sd	s1,8(sp)
 940:	e04a                	sd	s2,0(sp)
 942:	1000                	addi	s0,sp,32
 944:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 946:	4581                	li	a1,0
 948:	00000097          	auipc	ra,0x0
 94c:	172080e7          	jalr	370(ra) # aba <open>
  if(fd < 0)
 950:	02054563          	bltz	a0,97a <stat+0x42>
 954:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 956:	85ca                	mv	a1,s2
 958:	00000097          	auipc	ra,0x0
 95c:	17a080e7          	jalr	378(ra) # ad2 <fstat>
 960:	892a                	mv	s2,a0
  close(fd);
 962:	8526                	mv	a0,s1
 964:	00000097          	auipc	ra,0x0
 968:	13e080e7          	jalr	318(ra) # aa2 <close>
  return r;
}
 96c:	854a                	mv	a0,s2
 96e:	60e2                	ld	ra,24(sp)
 970:	6442                	ld	s0,16(sp)
 972:	64a2                	ld	s1,8(sp)
 974:	6902                	ld	s2,0(sp)
 976:	6105                	addi	sp,sp,32
 978:	8082                	ret
    return -1;
 97a:	597d                	li	s2,-1
 97c:	bfc5                	j	96c <stat+0x34>

000000000000097e <atoi>:

int
atoi(const char *s)
{
 97e:	1141                	addi	sp,sp,-16
 980:	e422                	sd	s0,8(sp)
 982:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 984:	00054603          	lbu	a2,0(a0)
 988:	fd06079b          	addiw	a5,a2,-48
 98c:	0ff7f793          	andi	a5,a5,255
 990:	4725                	li	a4,9
 992:	02f76963          	bltu	a4,a5,9c4 <atoi+0x46>
 996:	86aa                	mv	a3,a0
  n = 0;
 998:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 99a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 99c:	0685                	addi	a3,a3,1
 99e:	0025179b          	slliw	a5,a0,0x2
 9a2:	9fa9                	addw	a5,a5,a0
 9a4:	0017979b          	slliw	a5,a5,0x1
 9a8:	9fb1                	addw	a5,a5,a2
 9aa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 9ae:	0006c603          	lbu	a2,0(a3)
 9b2:	fd06071b          	addiw	a4,a2,-48
 9b6:	0ff77713          	andi	a4,a4,255
 9ba:	fee5f1e3          	bgeu	a1,a4,99c <atoi+0x1e>
  return n;
}
 9be:	6422                	ld	s0,8(sp)
 9c0:	0141                	addi	sp,sp,16
 9c2:	8082                	ret
  n = 0;
 9c4:	4501                	li	a0,0
 9c6:	bfe5                	j	9be <atoi+0x40>

00000000000009c8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9c8:	1141                	addi	sp,sp,-16
 9ca:	e422                	sd	s0,8(sp)
 9cc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9ce:	02b57463          	bgeu	a0,a1,9f6 <memmove+0x2e>
    while(n-- > 0)
 9d2:	00c05f63          	blez	a2,9f0 <memmove+0x28>
 9d6:	1602                	slli	a2,a2,0x20
 9d8:	9201                	srli	a2,a2,0x20
 9da:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 9de:	872a                	mv	a4,a0
      *dst++ = *src++;
 9e0:	0585                	addi	a1,a1,1
 9e2:	0705                	addi	a4,a4,1
 9e4:	fff5c683          	lbu	a3,-1(a1)
 9e8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 9ec:	fee79ae3          	bne	a5,a4,9e0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 9f0:	6422                	ld	s0,8(sp)
 9f2:	0141                	addi	sp,sp,16
 9f4:	8082                	ret
    dst += n;
 9f6:	00c50733          	add	a4,a0,a2
    src += n;
 9fa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 9fc:	fec05ae3          	blez	a2,9f0 <memmove+0x28>
 a00:	fff6079b          	addiw	a5,a2,-1
 a04:	1782                	slli	a5,a5,0x20
 a06:	9381                	srli	a5,a5,0x20
 a08:	fff7c793          	not	a5,a5
 a0c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 a0e:	15fd                	addi	a1,a1,-1
 a10:	177d                	addi	a4,a4,-1
 a12:	0005c683          	lbu	a3,0(a1)
 a16:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a1a:	fee79ae3          	bne	a5,a4,a0e <memmove+0x46>
 a1e:	bfc9                	j	9f0 <memmove+0x28>

0000000000000a20 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a20:	1141                	addi	sp,sp,-16
 a22:	e422                	sd	s0,8(sp)
 a24:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a26:	ca05                	beqz	a2,a56 <memcmp+0x36>
 a28:	fff6069b          	addiw	a3,a2,-1
 a2c:	1682                	slli	a3,a3,0x20
 a2e:	9281                	srli	a3,a3,0x20
 a30:	0685                	addi	a3,a3,1
 a32:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a34:	00054783          	lbu	a5,0(a0)
 a38:	0005c703          	lbu	a4,0(a1)
 a3c:	00e79863          	bne	a5,a4,a4c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a40:	0505                	addi	a0,a0,1
    p2++;
 a42:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a44:	fed518e3          	bne	a0,a3,a34 <memcmp+0x14>
  }
  return 0;
 a48:	4501                	li	a0,0
 a4a:	a019                	j	a50 <memcmp+0x30>
      return *p1 - *p2;
 a4c:	40e7853b          	subw	a0,a5,a4
}
 a50:	6422                	ld	s0,8(sp)
 a52:	0141                	addi	sp,sp,16
 a54:	8082                	ret
  return 0;
 a56:	4501                	li	a0,0
 a58:	bfe5                	j	a50 <memcmp+0x30>

0000000000000a5a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a5a:	1141                	addi	sp,sp,-16
 a5c:	e406                	sd	ra,8(sp)
 a5e:	e022                	sd	s0,0(sp)
 a60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a62:	00000097          	auipc	ra,0x0
 a66:	f66080e7          	jalr	-154(ra) # 9c8 <memmove>
}
 a6a:	60a2                	ld	ra,8(sp)
 a6c:	6402                	ld	s0,0(sp)
 a6e:	0141                	addi	sp,sp,16
 a70:	8082                	ret

0000000000000a72 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a72:	4885                	li	a7,1
 ecall
 a74:	00000073          	ecall
 ret
 a78:	8082                	ret

0000000000000a7a <exit>:
.global exit
exit:
 li a7, SYS_exit
 a7a:	4889                	li	a7,2
 ecall
 a7c:	00000073          	ecall
 ret
 a80:	8082                	ret

0000000000000a82 <wait>:
.global wait
wait:
 li a7, SYS_wait
 a82:	488d                	li	a7,3
 ecall
 a84:	00000073          	ecall
 ret
 a88:	8082                	ret

0000000000000a8a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a8a:	4891                	li	a7,4
 ecall
 a8c:	00000073          	ecall
 ret
 a90:	8082                	ret

0000000000000a92 <read>:
.global read
read:
 li a7, SYS_read
 a92:	4895                	li	a7,5
 ecall
 a94:	00000073          	ecall
 ret
 a98:	8082                	ret

0000000000000a9a <write>:
.global write
write:
 li a7, SYS_write
 a9a:	48c1                	li	a7,16
 ecall
 a9c:	00000073          	ecall
 ret
 aa0:	8082                	ret

0000000000000aa2 <close>:
.global close
close:
 li a7, SYS_close
 aa2:	48d5                	li	a7,21
 ecall
 aa4:	00000073          	ecall
 ret
 aa8:	8082                	ret

0000000000000aaa <kill>:
.global kill
kill:
 li a7, SYS_kill
 aaa:	4899                	li	a7,6
 ecall
 aac:	00000073          	ecall
 ret
 ab0:	8082                	ret

0000000000000ab2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 ab2:	489d                	li	a7,7
 ecall
 ab4:	00000073          	ecall
 ret
 ab8:	8082                	ret

0000000000000aba <open>:
.global open
open:
 li a7, SYS_open
 aba:	48bd                	li	a7,15
 ecall
 abc:	00000073          	ecall
 ret
 ac0:	8082                	ret

0000000000000ac2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 ac2:	48c5                	li	a7,17
 ecall
 ac4:	00000073          	ecall
 ret
 ac8:	8082                	ret

0000000000000aca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 aca:	48c9                	li	a7,18
 ecall
 acc:	00000073          	ecall
 ret
 ad0:	8082                	ret

0000000000000ad2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 ad2:	48a1                	li	a7,8
 ecall
 ad4:	00000073          	ecall
 ret
 ad8:	8082                	ret

0000000000000ada <link>:
.global link
link:
 li a7, SYS_link
 ada:	48cd                	li	a7,19
 ecall
 adc:	00000073          	ecall
 ret
 ae0:	8082                	ret

0000000000000ae2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 ae2:	48d1                	li	a7,20
 ecall
 ae4:	00000073          	ecall
 ret
 ae8:	8082                	ret

0000000000000aea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 aea:	48a5                	li	a7,9
 ecall
 aec:	00000073          	ecall
 ret
 af0:	8082                	ret

0000000000000af2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 af2:	48a9                	li	a7,10
 ecall
 af4:	00000073          	ecall
 ret
 af8:	8082                	ret

0000000000000afa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 afa:	48ad                	li	a7,11
 ecall
 afc:	00000073          	ecall
 ret
 b00:	8082                	ret

0000000000000b02 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 b02:	48b1                	li	a7,12
 ecall
 b04:	00000073          	ecall
 ret
 b08:	8082                	ret

0000000000000b0a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 b0a:	48b5                	li	a7,13
 ecall
 b0c:	00000073          	ecall
 ret
 b10:	8082                	ret

0000000000000b12 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 b12:	48b9                	li	a7,14
 ecall
 b14:	00000073          	ecall
 ret
 b18:	8082                	ret

0000000000000b1a <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 b1a:	48d9                	li	a7,22
 ecall
 b1c:	00000073          	ecall
 ret
 b20:	8082                	ret

0000000000000b22 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 b22:	48dd                	li	a7,23
 ecall
 b24:	00000073          	ecall
 ret
 b28:	8082                	ret

0000000000000b2a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b2a:	1101                	addi	sp,sp,-32
 b2c:	ec06                	sd	ra,24(sp)
 b2e:	e822                	sd	s0,16(sp)
 b30:	1000                	addi	s0,sp,32
 b32:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b36:	4605                	li	a2,1
 b38:	fef40593          	addi	a1,s0,-17
 b3c:	00000097          	auipc	ra,0x0
 b40:	f5e080e7          	jalr	-162(ra) # a9a <write>
}
 b44:	60e2                	ld	ra,24(sp)
 b46:	6442                	ld	s0,16(sp)
 b48:	6105                	addi	sp,sp,32
 b4a:	8082                	ret

0000000000000b4c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b4c:	7139                	addi	sp,sp,-64
 b4e:	fc06                	sd	ra,56(sp)
 b50:	f822                	sd	s0,48(sp)
 b52:	f426                	sd	s1,40(sp)
 b54:	f04a                	sd	s2,32(sp)
 b56:	ec4e                	sd	s3,24(sp)
 b58:	0080                	addi	s0,sp,64
 b5a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b5c:	c299                	beqz	a3,b62 <printint+0x16>
 b5e:	0805c863          	bltz	a1,bee <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b62:	2581                	sext.w	a1,a1
  neg = 0;
 b64:	4881                	li	a7,0
 b66:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b6a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b6c:	2601                	sext.w	a2,a2
 b6e:	00001517          	auipc	a0,0x1
 b72:	82250513          	addi	a0,a0,-2014 # 1390 <digits>
 b76:	883a                	mv	a6,a4
 b78:	2705                	addiw	a4,a4,1
 b7a:	02c5f7bb          	remuw	a5,a1,a2
 b7e:	1782                	slli	a5,a5,0x20
 b80:	9381                	srli	a5,a5,0x20
 b82:	97aa                	add	a5,a5,a0
 b84:	0007c783          	lbu	a5,0(a5)
 b88:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b8c:	0005879b          	sext.w	a5,a1
 b90:	02c5d5bb          	divuw	a1,a1,a2
 b94:	0685                	addi	a3,a3,1
 b96:	fec7f0e3          	bgeu	a5,a2,b76 <printint+0x2a>
  if(neg)
 b9a:	00088b63          	beqz	a7,bb0 <printint+0x64>
    buf[i++] = '-';
 b9e:	fd040793          	addi	a5,s0,-48
 ba2:	973e                	add	a4,a4,a5
 ba4:	02d00793          	li	a5,45
 ba8:	fef70823          	sb	a5,-16(a4)
 bac:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 bb0:	02e05863          	blez	a4,be0 <printint+0x94>
 bb4:	fc040793          	addi	a5,s0,-64
 bb8:	00e78933          	add	s2,a5,a4
 bbc:	fff78993          	addi	s3,a5,-1
 bc0:	99ba                	add	s3,s3,a4
 bc2:	377d                	addiw	a4,a4,-1
 bc4:	1702                	slli	a4,a4,0x20
 bc6:	9301                	srli	a4,a4,0x20
 bc8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 bcc:	fff94583          	lbu	a1,-1(s2)
 bd0:	8526                	mv	a0,s1
 bd2:	00000097          	auipc	ra,0x0
 bd6:	f58080e7          	jalr	-168(ra) # b2a <putc>
  while(--i >= 0)
 bda:	197d                	addi	s2,s2,-1
 bdc:	ff3918e3          	bne	s2,s3,bcc <printint+0x80>
}
 be0:	70e2                	ld	ra,56(sp)
 be2:	7442                	ld	s0,48(sp)
 be4:	74a2                	ld	s1,40(sp)
 be6:	7902                	ld	s2,32(sp)
 be8:	69e2                	ld	s3,24(sp)
 bea:	6121                	addi	sp,sp,64
 bec:	8082                	ret
    x = -xx;
 bee:	40b005bb          	negw	a1,a1
    neg = 1;
 bf2:	4885                	li	a7,1
    x = -xx;
 bf4:	bf8d                	j	b66 <printint+0x1a>

0000000000000bf6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 bf6:	7119                	addi	sp,sp,-128
 bf8:	fc86                	sd	ra,120(sp)
 bfa:	f8a2                	sd	s0,112(sp)
 bfc:	f4a6                	sd	s1,104(sp)
 bfe:	f0ca                	sd	s2,96(sp)
 c00:	ecce                	sd	s3,88(sp)
 c02:	e8d2                	sd	s4,80(sp)
 c04:	e4d6                	sd	s5,72(sp)
 c06:	e0da                	sd	s6,64(sp)
 c08:	fc5e                	sd	s7,56(sp)
 c0a:	f862                	sd	s8,48(sp)
 c0c:	f466                	sd	s9,40(sp)
 c0e:	f06a                	sd	s10,32(sp)
 c10:	ec6e                	sd	s11,24(sp)
 c12:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 c14:	0005c903          	lbu	s2,0(a1)
 c18:	18090f63          	beqz	s2,db6 <vprintf+0x1c0>
 c1c:	8aaa                	mv	s5,a0
 c1e:	8b32                	mv	s6,a2
 c20:	00158493          	addi	s1,a1,1
  state = 0;
 c24:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c26:	02500a13          	li	s4,37
      if(c == 'd'){
 c2a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c2e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c32:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c36:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c3a:	00000b97          	auipc	s7,0x0
 c3e:	756b8b93          	addi	s7,s7,1878 # 1390 <digits>
 c42:	a839                	j	c60 <vprintf+0x6a>
        putc(fd, c);
 c44:	85ca                	mv	a1,s2
 c46:	8556                	mv	a0,s5
 c48:	00000097          	auipc	ra,0x0
 c4c:	ee2080e7          	jalr	-286(ra) # b2a <putc>
 c50:	a019                	j	c56 <vprintf+0x60>
    } else if(state == '%'){
 c52:	01498f63          	beq	s3,s4,c70 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c56:	0485                	addi	s1,s1,1
 c58:	fff4c903          	lbu	s2,-1(s1)
 c5c:	14090d63          	beqz	s2,db6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c60:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c64:	fe0997e3          	bnez	s3,c52 <vprintf+0x5c>
      if(c == '%'){
 c68:	fd479ee3          	bne	a5,s4,c44 <vprintf+0x4e>
        state = '%';
 c6c:	89be                	mv	s3,a5
 c6e:	b7e5                	j	c56 <vprintf+0x60>
      if(c == 'd'){
 c70:	05878063          	beq	a5,s8,cb0 <vprintf+0xba>
      } else if(c == 'l') {
 c74:	05978c63          	beq	a5,s9,ccc <vprintf+0xd6>
      } else if(c == 'x') {
 c78:	07a78863          	beq	a5,s10,ce8 <vprintf+0xf2>
      } else if(c == 'p') {
 c7c:	09b78463          	beq	a5,s11,d04 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c80:	07300713          	li	a4,115
 c84:	0ce78663          	beq	a5,a4,d50 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c88:	06300713          	li	a4,99
 c8c:	0ee78e63          	beq	a5,a4,d88 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c90:	11478863          	beq	a5,s4,da0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c94:	85d2                	mv	a1,s4
 c96:	8556                	mv	a0,s5
 c98:	00000097          	auipc	ra,0x0
 c9c:	e92080e7          	jalr	-366(ra) # b2a <putc>
        putc(fd, c);
 ca0:	85ca                	mv	a1,s2
 ca2:	8556                	mv	a0,s5
 ca4:	00000097          	auipc	ra,0x0
 ca8:	e86080e7          	jalr	-378(ra) # b2a <putc>
      }
      state = 0;
 cac:	4981                	li	s3,0
 cae:	b765                	j	c56 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 cb0:	008b0913          	addi	s2,s6,8
 cb4:	4685                	li	a3,1
 cb6:	4629                	li	a2,10
 cb8:	000b2583          	lw	a1,0(s6)
 cbc:	8556                	mv	a0,s5
 cbe:	00000097          	auipc	ra,0x0
 cc2:	e8e080e7          	jalr	-370(ra) # b4c <printint>
 cc6:	8b4a                	mv	s6,s2
      state = 0;
 cc8:	4981                	li	s3,0
 cca:	b771                	j	c56 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ccc:	008b0913          	addi	s2,s6,8
 cd0:	4681                	li	a3,0
 cd2:	4629                	li	a2,10
 cd4:	000b2583          	lw	a1,0(s6)
 cd8:	8556                	mv	a0,s5
 cda:	00000097          	auipc	ra,0x0
 cde:	e72080e7          	jalr	-398(ra) # b4c <printint>
 ce2:	8b4a                	mv	s6,s2
      state = 0;
 ce4:	4981                	li	s3,0
 ce6:	bf85                	j	c56 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 ce8:	008b0913          	addi	s2,s6,8
 cec:	4681                	li	a3,0
 cee:	4641                	li	a2,16
 cf0:	000b2583          	lw	a1,0(s6)
 cf4:	8556                	mv	a0,s5
 cf6:	00000097          	auipc	ra,0x0
 cfa:	e56080e7          	jalr	-426(ra) # b4c <printint>
 cfe:	8b4a                	mv	s6,s2
      state = 0;
 d00:	4981                	li	s3,0
 d02:	bf91                	j	c56 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 d04:	008b0793          	addi	a5,s6,8
 d08:	f8f43423          	sd	a5,-120(s0)
 d0c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 d10:	03000593          	li	a1,48
 d14:	8556                	mv	a0,s5
 d16:	00000097          	auipc	ra,0x0
 d1a:	e14080e7          	jalr	-492(ra) # b2a <putc>
  putc(fd, 'x');
 d1e:	85ea                	mv	a1,s10
 d20:	8556                	mv	a0,s5
 d22:	00000097          	auipc	ra,0x0
 d26:	e08080e7          	jalr	-504(ra) # b2a <putc>
 d2a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d2c:	03c9d793          	srli	a5,s3,0x3c
 d30:	97de                	add	a5,a5,s7
 d32:	0007c583          	lbu	a1,0(a5)
 d36:	8556                	mv	a0,s5
 d38:	00000097          	auipc	ra,0x0
 d3c:	df2080e7          	jalr	-526(ra) # b2a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d40:	0992                	slli	s3,s3,0x4
 d42:	397d                	addiw	s2,s2,-1
 d44:	fe0914e3          	bnez	s2,d2c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d48:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d4c:	4981                	li	s3,0
 d4e:	b721                	j	c56 <vprintf+0x60>
        s = va_arg(ap, char*);
 d50:	008b0993          	addi	s3,s6,8
 d54:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d58:	02090163          	beqz	s2,d7a <vprintf+0x184>
        while(*s != 0){
 d5c:	00094583          	lbu	a1,0(s2)
 d60:	c9a1                	beqz	a1,db0 <vprintf+0x1ba>
          putc(fd, *s);
 d62:	8556                	mv	a0,s5
 d64:	00000097          	auipc	ra,0x0
 d68:	dc6080e7          	jalr	-570(ra) # b2a <putc>
          s++;
 d6c:	0905                	addi	s2,s2,1
        while(*s != 0){
 d6e:	00094583          	lbu	a1,0(s2)
 d72:	f9e5                	bnez	a1,d62 <vprintf+0x16c>
        s = va_arg(ap, char*);
 d74:	8b4e                	mv	s6,s3
      state = 0;
 d76:	4981                	li	s3,0
 d78:	bdf9                	j	c56 <vprintf+0x60>
          s = "(null)";
 d7a:	00000917          	auipc	s2,0x0
 d7e:	60e90913          	addi	s2,s2,1550 # 1388 <malloc+0x4c8>
        while(*s != 0){
 d82:	02800593          	li	a1,40
 d86:	bff1                	j	d62 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d88:	008b0913          	addi	s2,s6,8
 d8c:	000b4583          	lbu	a1,0(s6)
 d90:	8556                	mv	a0,s5
 d92:	00000097          	auipc	ra,0x0
 d96:	d98080e7          	jalr	-616(ra) # b2a <putc>
 d9a:	8b4a                	mv	s6,s2
      state = 0;
 d9c:	4981                	li	s3,0
 d9e:	bd65                	j	c56 <vprintf+0x60>
        putc(fd, c);
 da0:	85d2                	mv	a1,s4
 da2:	8556                	mv	a0,s5
 da4:	00000097          	auipc	ra,0x0
 da8:	d86080e7          	jalr	-634(ra) # b2a <putc>
      state = 0;
 dac:	4981                	li	s3,0
 dae:	b565                	j	c56 <vprintf+0x60>
        s = va_arg(ap, char*);
 db0:	8b4e                	mv	s6,s3
      state = 0;
 db2:	4981                	li	s3,0
 db4:	b54d                	j	c56 <vprintf+0x60>
    }
  }
}
 db6:	70e6                	ld	ra,120(sp)
 db8:	7446                	ld	s0,112(sp)
 dba:	74a6                	ld	s1,104(sp)
 dbc:	7906                	ld	s2,96(sp)
 dbe:	69e6                	ld	s3,88(sp)
 dc0:	6a46                	ld	s4,80(sp)
 dc2:	6aa6                	ld	s5,72(sp)
 dc4:	6b06                	ld	s6,64(sp)
 dc6:	7be2                	ld	s7,56(sp)
 dc8:	7c42                	ld	s8,48(sp)
 dca:	7ca2                	ld	s9,40(sp)
 dcc:	7d02                	ld	s10,32(sp)
 dce:	6de2                	ld	s11,24(sp)
 dd0:	6109                	addi	sp,sp,128
 dd2:	8082                	ret

0000000000000dd4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 dd4:	715d                	addi	sp,sp,-80
 dd6:	ec06                	sd	ra,24(sp)
 dd8:	e822                	sd	s0,16(sp)
 dda:	1000                	addi	s0,sp,32
 ddc:	e010                	sd	a2,0(s0)
 dde:	e414                	sd	a3,8(s0)
 de0:	e818                	sd	a4,16(s0)
 de2:	ec1c                	sd	a5,24(s0)
 de4:	03043023          	sd	a6,32(s0)
 de8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 dec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 df0:	8622                	mv	a2,s0
 df2:	00000097          	auipc	ra,0x0
 df6:	e04080e7          	jalr	-508(ra) # bf6 <vprintf>
}
 dfa:	60e2                	ld	ra,24(sp)
 dfc:	6442                	ld	s0,16(sp)
 dfe:	6161                	addi	sp,sp,80
 e00:	8082                	ret

0000000000000e02 <printf>:

void
printf(const char *fmt, ...)
{
 e02:	711d                	addi	sp,sp,-96
 e04:	ec06                	sd	ra,24(sp)
 e06:	e822                	sd	s0,16(sp)
 e08:	1000                	addi	s0,sp,32
 e0a:	e40c                	sd	a1,8(s0)
 e0c:	e810                	sd	a2,16(s0)
 e0e:	ec14                	sd	a3,24(s0)
 e10:	f018                	sd	a4,32(s0)
 e12:	f41c                	sd	a5,40(s0)
 e14:	03043823          	sd	a6,48(s0)
 e18:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e1c:	00840613          	addi	a2,s0,8
 e20:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e24:	85aa                	mv	a1,a0
 e26:	4505                	li	a0,1
 e28:	00000097          	auipc	ra,0x0
 e2c:	dce080e7          	jalr	-562(ra) # bf6 <vprintf>
}
 e30:	60e2                	ld	ra,24(sp)
 e32:	6442                	ld	s0,16(sp)
 e34:	6125                	addi	sp,sp,96
 e36:	8082                	ret

0000000000000e38 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e38:	1141                	addi	sp,sp,-16
 e3a:	e422                	sd	s0,8(sp)
 e3c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e3e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e42:	00000797          	auipc	a5,0x0
 e46:	56e7b783          	ld	a5,1390(a5) # 13b0 <freep>
 e4a:	a805                	j	e7a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e4c:	4618                	lw	a4,8(a2)
 e4e:	9db9                	addw	a1,a1,a4
 e50:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e54:	6398                	ld	a4,0(a5)
 e56:	6318                	ld	a4,0(a4)
 e58:	fee53823          	sd	a4,-16(a0)
 e5c:	a091                	j	ea0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e5e:	ff852703          	lw	a4,-8(a0)
 e62:	9e39                	addw	a2,a2,a4
 e64:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e66:	ff053703          	ld	a4,-16(a0)
 e6a:	e398                	sd	a4,0(a5)
 e6c:	a099                	j	eb2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e6e:	6398                	ld	a4,0(a5)
 e70:	00e7e463          	bltu	a5,a4,e78 <free+0x40>
 e74:	00e6ea63          	bltu	a3,a4,e88 <free+0x50>
{
 e78:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e7a:	fed7fae3          	bgeu	a5,a3,e6e <free+0x36>
 e7e:	6398                	ld	a4,0(a5)
 e80:	00e6e463          	bltu	a3,a4,e88 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e84:	fee7eae3          	bltu	a5,a4,e78 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e88:	ff852583          	lw	a1,-8(a0)
 e8c:	6390                	ld	a2,0(a5)
 e8e:	02059713          	slli	a4,a1,0x20
 e92:	9301                	srli	a4,a4,0x20
 e94:	0712                	slli	a4,a4,0x4
 e96:	9736                	add	a4,a4,a3
 e98:	fae60ae3          	beq	a2,a4,e4c <free+0x14>
    bp->s.ptr = p->s.ptr;
 e9c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ea0:	4790                	lw	a2,8(a5)
 ea2:	02061713          	slli	a4,a2,0x20
 ea6:	9301                	srli	a4,a4,0x20
 ea8:	0712                	slli	a4,a4,0x4
 eaa:	973e                	add	a4,a4,a5
 eac:	fae689e3          	beq	a3,a4,e5e <free+0x26>
  } else
    p->s.ptr = bp;
 eb0:	e394                	sd	a3,0(a5)
  freep = p;
 eb2:	00000717          	auipc	a4,0x0
 eb6:	4ef73f23          	sd	a5,1278(a4) # 13b0 <freep>
}
 eba:	6422                	ld	s0,8(sp)
 ebc:	0141                	addi	sp,sp,16
 ebe:	8082                	ret

0000000000000ec0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ec0:	7139                	addi	sp,sp,-64
 ec2:	fc06                	sd	ra,56(sp)
 ec4:	f822                	sd	s0,48(sp)
 ec6:	f426                	sd	s1,40(sp)
 ec8:	f04a                	sd	s2,32(sp)
 eca:	ec4e                	sd	s3,24(sp)
 ecc:	e852                	sd	s4,16(sp)
 ece:	e456                	sd	s5,8(sp)
 ed0:	e05a                	sd	s6,0(sp)
 ed2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ed4:	02051493          	slli	s1,a0,0x20
 ed8:	9081                	srli	s1,s1,0x20
 eda:	04bd                	addi	s1,s1,15
 edc:	8091                	srli	s1,s1,0x4
 ede:	0014899b          	addiw	s3,s1,1
 ee2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ee4:	00000517          	auipc	a0,0x0
 ee8:	4cc53503          	ld	a0,1228(a0) # 13b0 <freep>
 eec:	c515                	beqz	a0,f18 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 eee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ef0:	4798                	lw	a4,8(a5)
 ef2:	02977f63          	bgeu	a4,s1,f30 <malloc+0x70>
 ef6:	8a4e                	mv	s4,s3
 ef8:	0009871b          	sext.w	a4,s3
 efc:	6685                	lui	a3,0x1
 efe:	00d77363          	bgeu	a4,a3,f04 <malloc+0x44>
 f02:	6a05                	lui	s4,0x1
 f04:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f08:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f0c:	00000917          	auipc	s2,0x0
 f10:	4a490913          	addi	s2,s2,1188 # 13b0 <freep>
  if(p == (char*)-1)
 f14:	5afd                	li	s5,-1
 f16:	a88d                	j	f88 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 f18:	00000797          	auipc	a5,0x0
 f1c:	4b878793          	addi	a5,a5,1208 # 13d0 <base>
 f20:	00000717          	auipc	a4,0x0
 f24:	48f73823          	sd	a5,1168(a4) # 13b0 <freep>
 f28:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f2a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f2e:	b7e1                	j	ef6 <malloc+0x36>
      if(p->s.size == nunits)
 f30:	02e48b63          	beq	s1,a4,f66 <malloc+0xa6>
        p->s.size -= nunits;
 f34:	4137073b          	subw	a4,a4,s3
 f38:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f3a:	1702                	slli	a4,a4,0x20
 f3c:	9301                	srli	a4,a4,0x20
 f3e:	0712                	slli	a4,a4,0x4
 f40:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f42:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f46:	00000717          	auipc	a4,0x0
 f4a:	46a73523          	sd	a0,1130(a4) # 13b0 <freep>
      return (void*)(p + 1);
 f4e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f52:	70e2                	ld	ra,56(sp)
 f54:	7442                	ld	s0,48(sp)
 f56:	74a2                	ld	s1,40(sp)
 f58:	7902                	ld	s2,32(sp)
 f5a:	69e2                	ld	s3,24(sp)
 f5c:	6a42                	ld	s4,16(sp)
 f5e:	6aa2                	ld	s5,8(sp)
 f60:	6b02                	ld	s6,0(sp)
 f62:	6121                	addi	sp,sp,64
 f64:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f66:	6398                	ld	a4,0(a5)
 f68:	e118                	sd	a4,0(a0)
 f6a:	bff1                	j	f46 <malloc+0x86>
  hp->s.size = nu;
 f6c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f70:	0541                	addi	a0,a0,16
 f72:	00000097          	auipc	ra,0x0
 f76:	ec6080e7          	jalr	-314(ra) # e38 <free>
  return freep;
 f7a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f7e:	d971                	beqz	a0,f52 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f80:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f82:	4798                	lw	a4,8(a5)
 f84:	fa9776e3          	bgeu	a4,s1,f30 <malloc+0x70>
    if(p == freep)
 f88:	00093703          	ld	a4,0(s2)
 f8c:	853e                	mv	a0,a5
 f8e:	fef719e3          	bne	a4,a5,f80 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 f92:	8552                	mv	a0,s4
 f94:	00000097          	auipc	ra,0x0
 f98:	b6e080e7          	jalr	-1170(ra) # b02 <sbrk>
  if(p == (char*)-1)
 f9c:	fd5518e3          	bne	a0,s5,f6c <malloc+0xac>
        return 0;
 fa0:	4501                	li	a0,0
 fa2:	bf45                	j	f52 <malloc+0x92>


user/_simplefifotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:
#include "kernel/stat.h"
#include "user/user.h"

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
   c:	00000097          	auipc	ra,0x0
  10:	234080e7          	jalr	564(ra) # 240 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	46a080e7          	jalr	1130(ra) # 486 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <do_work>:

// Simple work function to ensure processes run long enough to be scheduled
void
do_work()
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec22                	sd	s0,24(sp)
  32:	1000                	addi	s0,sp,32
  volatile int sum = 0;
  34:	fe042623          	sw	zero,-20(s0)
  for(int i = 0; i < 50000; i++) {
  38:	4781                	li	a5,0
  3a:	66b1                	lui	a3,0xc
  3c:	35068693          	addi	a3,a3,848 # c350 <__global_pointer$+0xafa7>
    sum += i;
  40:	fec42703          	lw	a4,-20(s0)
  44:	9f3d                	addw	a4,a4,a5
  46:	fee42623          	sw	a4,-20(s0)
  for(int i = 0; i < 50000; i++) {
  4a:	2785                	addiw	a5,a5,1
  4c:	fed79ae3          	bne	a5,a3,40 <do_work+0x12>
  }
}
  50:	6462                	ld	s0,24(sp)
  52:	6105                	addi	sp,sp,32
  54:	8082                	ret

0000000000000056 <main>:

int
main(void)
{
  56:	7179                	addi	sp,sp,-48
  58:	f406                	sd	ra,40(sp)
  5a:	f022                	sd	s0,32(sp)
  5c:	ec26                	sd	s1,24(sp)
  5e:	e84a                	sd	s2,16(sp)
  60:	1800                	addi	s0,sp,48
  print("=== Simple FIFO Test ===\n");
  62:	00001517          	auipc	a0,0x1
  66:	92e50513          	addi	a0,a0,-1746 # 990 <malloc+0xe4>
  6a:	00000097          	auipc	ra,0x0
  6e:	f96080e7          	jalr	-106(ra) # 0 <print>
  print("Creating processes sequentially - they should run in FIFO order\n\n");
  72:	00001517          	auipc	a0,0x1
  76:	93e50513          	addi	a0,a0,-1730 # 9b0 <malloc+0x104>
  7a:	00000097          	auipc	ra,0x0
  7e:	f86080e7          	jalr	-122(ra) # 0 <print>
  
  int sync_pipe[2];
  if(pipe(sync_pipe) < 0) {
  82:	fd840513          	addi	a0,s0,-40
  86:	00000097          	auipc	ra,0x0
  8a:	3f0080e7          	jalr	1008(ra) # 476 <pipe>
    print("ERROR: pipe creation failed\n");
    exit(1);
  }
  
  // Create 3 child processes with slight delays between creation
  for(int i = 0; i < 3; i++) {
  8e:	4481                	li	s1,0
  90:	490d                	li	s2,3
  if(pipe(sync_pipe) < 0) {
  92:	0c054d63          	bltz	a0,16c <main+0x116>
    
    // Small delay to ensure different arrival times
    do_work();
  96:	00000097          	auipc	ra,0x0
  9a:	f98080e7          	jalr	-104(ra) # 2e <do_work>
    
    int pid = fork();
  9e:	00000097          	auipc	ra,0x0
  a2:	3c0080e7          	jalr	960(ra) # 45e <fork>
    if(pid < 0) {
  a6:	0e054063          	bltz	a0,186 <main+0x130>
      print("ERROR: fork failed\n");
      exit(1);
    }
    
    if(pid == 0) {
  aa:	c97d                	beqz	a0,1a0 <main+0x14a>
  for(int i = 0; i < 3; i++) {
  ac:	2485                	addiw	s1,s1,1
  ae:	ff2494e3          	bne	s1,s2,96 <main+0x40>
      exit(i);
    }
  }
  
  // Parent: signal all children to start at the same time
  close(sync_pipe[0]); // Close read end
  b2:	fd842503          	lw	a0,-40(s0)
  b6:	00000097          	auipc	ra,0x0
  ba:	3d8080e7          	jalr	984(ra) # 48e <close>
  print("All processes created. Starting them simultaneously...\n");
  be:	00001517          	auipc	a0,0x1
  c2:	99250513          	addi	a0,a0,-1646 # a50 <malloc+0x1a4>
  c6:	00000097          	auipc	ra,0x0
  ca:	f3a080e7          	jalr	-198(ra) # 0 <print>
  ce:	448d                	li	s1,3
  
  for(int i = 0; i < 3; i++) {
    char signal = 1;
  d0:	4905                	li	s2,1
  d2:	fd240a23          	sb	s2,-44(s0)
    write(sync_pipe[1], &signal, 1);
  d6:	864a                	mv	a2,s2
  d8:	fd440593          	addi	a1,s0,-44
  dc:	fdc42503          	lw	a0,-36(s0)
  e0:	00000097          	auipc	ra,0x0
  e4:	3a6080e7          	jalr	934(ra) # 486 <write>
  for(int i = 0; i < 3; i++) {
  e8:	34fd                	addiw	s1,s1,-1
  ea:	f4e5                	bnez	s1,d2 <main+0x7c>
  }
  close(sync_pipe[1]);
  ec:	fdc42503          	lw	a0,-36(s0)
  f0:	00000097          	auipc	ra,0x0
  f4:	39e080e7          	jalr	926(ra) # 48e <close>
  
  // Wait for children and collect results
  print("\nProcess execution order:\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	99050513          	addi	a0,a0,-1648 # a88 <malloc+0x1dc>
 100:	00000097          	auipc	ra,0x0
 104:	f00080e7          	jalr	-256(ra) # 0 <print>
 108:	448d                	li	s1,3
  for(int i = 0; i < 3; i++) {
    int status;
    int pid = wait(&status);
    printf("Process finished: exit code %d, PID %d\n", status, pid);
 10a:	00001917          	auipc	s2,0x1
 10e:	99e90913          	addi	s2,s2,-1634 # aa8 <malloc+0x1fc>
    int pid = wait(&status);
 112:	fd440513          	addi	a0,s0,-44
 116:	00000097          	auipc	ra,0x0
 11a:	358080e7          	jalr	856(ra) # 46e <wait>
 11e:	862a                	mv	a2,a0
    printf("Process finished: exit code %d, PID %d\n", status, pid);
 120:	fd442583          	lw	a1,-44(s0)
 124:	854a                	mv	a0,s2
 126:	00000097          	auipc	ra,0x0
 12a:	6c8080e7          	jalr	1736(ra) # 7ee <printf>
  for(int i = 0; i < 3; i++) {
 12e:	34fd                	addiw	s1,s1,-1
 130:	f0ed                	bnez	s1,112 <main+0xbc>
  }
  
  print("\nExpected FIFO behavior: Processes should run in creation order (0, 1, 2)\n");
 132:	00001517          	auipc	a0,0x1
 136:	99e50513          	addi	a0,a0,-1634 # ad0 <malloc+0x224>
 13a:	00000097          	auipc	ra,0x0
 13e:	ec6080e7          	jalr	-314(ra) # 0 <print>
  print("If FIFO is working correctly, you should see processes execute in sequence.\n");
 142:	00001517          	auipc	a0,0x1
 146:	9de50513          	addi	a0,a0,-1570 # b20 <malloc+0x274>
 14a:	00000097          	auipc	ra,0x0
 14e:	eb6080e7          	jalr	-330(ra) # 0 <print>
  print("\nSimple FIFO test completed.\n");
 152:	00001517          	auipc	a0,0x1
 156:	a1e50513          	addi	a0,a0,-1506 # b70 <malloc+0x2c4>
 15a:	00000097          	auipc	ra,0x0
 15e:	ea6080e7          	jalr	-346(ra) # 0 <print>
  
  exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	302080e7          	jalr	770(ra) # 466 <exit>
    print("ERROR: pipe creation failed\n");
 16c:	00001517          	auipc	a0,0x1
 170:	88c50513          	addi	a0,a0,-1908 # 9f8 <malloc+0x14c>
 174:	00000097          	auipc	ra,0x0
 178:	e8c080e7          	jalr	-372(ra) # 0 <print>
    exit(1);
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	2e8080e7          	jalr	744(ra) # 466 <exit>
      print("ERROR: fork failed\n");
 186:	00001517          	auipc	a0,0x1
 18a:	89250513          	addi	a0,a0,-1902 # a18 <malloc+0x16c>
 18e:	00000097          	auipc	ra,0x0
 192:	e72080e7          	jalr	-398(ra) # 0 <print>
      exit(1);
 196:	4505                	li	a0,1
 198:	00000097          	auipc	ra,0x0
 19c:	2ce080e7          	jalr	718(ra) # 466 <exit>
      close(sync_pipe[1]); // Close write end
 1a0:	fdc42503          	lw	a0,-36(s0)
 1a4:	00000097          	auipc	ra,0x0
 1a8:	2ea080e7          	jalr	746(ra) # 48e <close>
      read(sync_pipe[0], &signal, 1);
 1ac:	4605                	li	a2,1
 1ae:	fd440593          	addi	a1,s0,-44
 1b2:	fd842503          	lw	a0,-40(s0)
 1b6:	00000097          	auipc	ra,0x0
 1ba:	2c8080e7          	jalr	712(ra) # 47e <read>
      close(sync_pipe[0]);
 1be:	fd842503          	lw	a0,-40(s0)
 1c2:	00000097          	auipc	ra,0x0
 1c6:	2cc080e7          	jalr	716(ra) # 48e <close>
      do_work();
 1ca:	00000097          	auipc	ra,0x0
 1ce:	e64080e7          	jalr	-412(ra) # 2e <do_work>
      printf("Process %d (PID %d) is running\n", i, getpid());
 1d2:	00000097          	auipc	ra,0x0
 1d6:	314080e7          	jalr	788(ra) # 4e6 <getpid>
 1da:	862a                	mv	a2,a0
 1dc:	85a6                	mv	a1,s1
 1de:	00001517          	auipc	a0,0x1
 1e2:	85250513          	addi	a0,a0,-1966 # a30 <malloc+0x184>
 1e6:	00000097          	auipc	ra,0x0
 1ea:	608080e7          	jalr	1544(ra) # 7ee <printf>
      exit(i);
 1ee:	8526                	mv	a0,s1
 1f0:	00000097          	auipc	ra,0x0
 1f4:	276080e7          	jalr	630(ra) # 466 <exit>

00000000000001f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1fe:	87aa                	mv	a5,a0
 200:	0585                	addi	a1,a1,1
 202:	0785                	addi	a5,a5,1
 204:	fff5c703          	lbu	a4,-1(a1)
 208:	fee78fa3          	sb	a4,-1(a5)
 20c:	fb75                	bnez	a4,200 <strcpy+0x8>
    ;
  return os;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb91                	beqz	a5,232 <strcmp+0x1e>
 220:	0005c703          	lbu	a4,0(a1)
 224:	00f71763          	bne	a4,a5,232 <strcmp+0x1e>
    p++, q++;
 228:	0505                	addi	a0,a0,1
 22a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	fbe5                	bnez	a5,220 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 232:	0005c503          	lbu	a0,0(a1)
}
 236:	40a7853b          	subw	a0,a5,a0
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <strlen>:

uint
strlen(const char *s)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 246:	00054783          	lbu	a5,0(a0)
 24a:	cf91                	beqz	a5,266 <strlen+0x26>
 24c:	0505                	addi	a0,a0,1
 24e:	87aa                	mv	a5,a0
 250:	4685                	li	a3,1
 252:	9e89                	subw	a3,a3,a0
 254:	00f6853b          	addw	a0,a3,a5
 258:	0785                	addi	a5,a5,1
 25a:	fff7c703          	lbu	a4,-1(a5)
 25e:	fb7d                	bnez	a4,254 <strlen+0x14>
    ;
  return n;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  for(n = 0; s[n]; n++)
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <strlen+0x20>

000000000000026a <memset>:

void*
memset(void *dst, int c, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 270:	ca19                	beqz	a2,286 <memset+0x1c>
 272:	87aa                	mv	a5,a0
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 280:	0785                	addi	a5,a5,1
 282:	fee79de3          	bne	a5,a4,27c <memset+0x12>
  }
  return dst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strchr>:

char*
strchr(const char *s, char c)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  for(; *s; s++)
 292:	00054783          	lbu	a5,0(a0)
 296:	cb99                	beqz	a5,2ac <strchr+0x20>
    if(*s == c)
 298:	00f58763          	beq	a1,a5,2a6 <strchr+0x1a>
  for(; *s; s++)
 29c:	0505                	addi	a0,a0,1
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbfd                	bnez	a5,298 <strchr+0xc>
      return (char*)s;
  return 0;
 2a4:	4501                	li	a0,0
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strchr+0x1a>

00000000000002b0 <gets>:

char*
gets(char *buf, int max)
{
 2b0:	711d                	addi	sp,sp,-96
 2b2:	ec86                	sd	ra,88(sp)
 2b4:	e8a2                	sd	s0,80(sp)
 2b6:	e4a6                	sd	s1,72(sp)
 2b8:	e0ca                	sd	s2,64(sp)
 2ba:	fc4e                	sd	s3,56(sp)
 2bc:	f852                	sd	s4,48(sp)
 2be:	f456                	sd	s5,40(sp)
 2c0:	f05a                	sd	s6,32(sp)
 2c2:	ec5e                	sd	s7,24(sp)
 2c4:	1080                	addi	s0,sp,96
 2c6:	8baa                	mv	s7,a0
 2c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ca:	892a                	mv	s2,a0
 2cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ce:	4aa9                	li	s5,10
 2d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d2:	89a6                	mv	s3,s1
 2d4:	2485                	addiw	s1,s1,1
 2d6:	0344d863          	bge	s1,s4,306 <gets+0x56>
    cc = read(0, &c, 1);
 2da:	4605                	li	a2,1
 2dc:	faf40593          	addi	a1,s0,-81
 2e0:	4501                	li	a0,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	19c080e7          	jalr	412(ra) # 47e <read>
    if(cc < 1)
 2ea:	00a05e63          	blez	a0,306 <gets+0x56>
    buf[i++] = c;
 2ee:	faf44783          	lbu	a5,-81(s0)
 2f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f6:	01578763          	beq	a5,s5,304 <gets+0x54>
 2fa:	0905                	addi	s2,s2,1
 2fc:	fd679be3          	bne	a5,s6,2d2 <gets+0x22>
  for(i=0; i+1 < max; ){
 300:	89a6                	mv	s3,s1
 302:	a011                	j	306 <gets+0x56>
 304:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 306:	99de                	add	s3,s3,s7
 308:	00098023          	sb	zero,0(s3)
  return buf;
}
 30c:	855e                	mv	a0,s7
 30e:	60e6                	ld	ra,88(sp)
 310:	6446                	ld	s0,80(sp)
 312:	64a6                	ld	s1,72(sp)
 314:	6906                	ld	s2,64(sp)
 316:	79e2                	ld	s3,56(sp)
 318:	7a42                	ld	s4,48(sp)
 31a:	7aa2                	ld	s5,40(sp)
 31c:	7b02                	ld	s6,32(sp)
 31e:	6be2                	ld	s7,24(sp)
 320:	6125                	addi	sp,sp,96
 322:	8082                	ret

0000000000000324 <stat>:

int
stat(const char *n, struct stat *st)
{
 324:	1101                	addi	sp,sp,-32
 326:	ec06                	sd	ra,24(sp)
 328:	e822                	sd	s0,16(sp)
 32a:	e426                	sd	s1,8(sp)
 32c:	e04a                	sd	s2,0(sp)
 32e:	1000                	addi	s0,sp,32
 330:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 332:	4581                	li	a1,0
 334:	00000097          	auipc	ra,0x0
 338:	172080e7          	jalr	370(ra) # 4a6 <open>
  if(fd < 0)
 33c:	02054563          	bltz	a0,366 <stat+0x42>
 340:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 342:	85ca                	mv	a1,s2
 344:	00000097          	auipc	ra,0x0
 348:	17a080e7          	jalr	378(ra) # 4be <fstat>
 34c:	892a                	mv	s2,a0
  close(fd);
 34e:	8526                	mv	a0,s1
 350:	00000097          	auipc	ra,0x0
 354:	13e080e7          	jalr	318(ra) # 48e <close>
  return r;
}
 358:	854a                	mv	a0,s2
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	64a2                	ld	s1,8(sp)
 360:	6902                	ld	s2,0(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret
    return -1;
 366:	597d                	li	s2,-1
 368:	bfc5                	j	358 <stat+0x34>

000000000000036a <atoi>:

int
atoi(const char *s)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 370:	00054603          	lbu	a2,0(a0)
 374:	fd06079b          	addiw	a5,a2,-48
 378:	0ff7f793          	andi	a5,a5,255
 37c:	4725                	li	a4,9
 37e:	02f76963          	bltu	a4,a5,3b0 <atoi+0x46>
 382:	86aa                	mv	a3,a0
  n = 0;
 384:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 386:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 388:	0685                	addi	a3,a3,1
 38a:	0025179b          	slliw	a5,a0,0x2
 38e:	9fa9                	addw	a5,a5,a0
 390:	0017979b          	slliw	a5,a5,0x1
 394:	9fb1                	addw	a5,a5,a2
 396:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 39a:	0006c603          	lbu	a2,0(a3)
 39e:	fd06071b          	addiw	a4,a2,-48
 3a2:	0ff77713          	andi	a4,a4,255
 3a6:	fee5f1e3          	bgeu	a1,a4,388 <atoi+0x1e>
  return n;
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  n = 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <atoi+0x40>

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57463          	bgeu	a0,a1,3e2 <memmove+0x2e>
    while(n-- > 0)
 3be:	00c05f63          	blez	a2,3dc <memmove+0x28>
 3c2:	1602                	slli	a2,a2,0x20
 3c4:	9201                	srli	a2,a2,0x20
 3c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 3cc:	0585                	addi	a1,a1,1
 3ce:	0705                	addi	a4,a4,1
 3d0:	fff5c683          	lbu	a3,-1(a1)
 3d4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d8:	fee79ae3          	bne	a5,a4,3cc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
    dst += n;
 3e2:	00c50733          	add	a4,a0,a2
    src += n;
 3e6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e8:	fec05ae3          	blez	a2,3dc <memmove+0x28>
 3ec:	fff6079b          	addiw	a5,a2,-1
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	fff7c793          	not	a5,a5
 3f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fa:	15fd                	addi	a1,a1,-1
 3fc:	177d                	addi	a4,a4,-1
 3fe:	0005c683          	lbu	a3,0(a1)
 402:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 406:	fee79ae3          	bne	a5,a4,3fa <memmove+0x46>
 40a:	bfc9                	j	3dc <memmove+0x28>

000000000000040c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 412:	ca05                	beqz	a2,442 <memcmp+0x36>
 414:	fff6069b          	addiw	a3,a2,-1
 418:	1682                	slli	a3,a3,0x20
 41a:	9281                	srli	a3,a3,0x20
 41c:	0685                	addi	a3,a3,1
 41e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 420:	00054783          	lbu	a5,0(a0)
 424:	0005c703          	lbu	a4,0(a1)
 428:	00e79863          	bne	a5,a4,438 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42c:	0505                	addi	a0,a0,1
    p2++;
 42e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 430:	fed518e3          	bne	a0,a3,420 <memcmp+0x14>
  }
  return 0;
 434:	4501                	li	a0,0
 436:	a019                	j	43c <memcmp+0x30>
      return *p1 - *p2;
 438:	40e7853b          	subw	a0,a5,a4
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  return 0;
 442:	4501                	li	a0,0
 444:	bfe5                	j	43c <memcmp+0x30>

0000000000000446 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e406                	sd	ra,8(sp)
 44a:	e022                	sd	s0,0(sp)
 44c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44e:	00000097          	auipc	ra,0x0
 452:	f66080e7          	jalr	-154(ra) # 3b4 <memmove>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45e:	4885                	li	a7,1
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exit>:
.global exit
exit:
 li a7, SYS_exit
 466:	4889                	li	a7,2
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <wait>:
.global wait
wait:
 li a7, SYS_wait
 46e:	488d                	li	a7,3
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 476:	4891                	li	a7,4
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <read>:
.global read
read:
 li a7, SYS_read
 47e:	4895                	li	a7,5
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <write>:
.global write
write:
 li a7, SYS_write
 486:	48c1                	li	a7,16
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <close>:
.global close
close:
 li a7, SYS_close
 48e:	48d5                	li	a7,21
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <kill>:
.global kill
kill:
 li a7, SYS_kill
 496:	4899                	li	a7,6
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exec>:
.global exec
exec:
 li a7, SYS_exec
 49e:	489d                	li	a7,7
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <open>:
.global open
open:
 li a7, SYS_open
 4a6:	48bd                	li	a7,15
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ae:	48c5                	li	a7,17
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b6:	48c9                	li	a7,18
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4be:	48a1                	li	a7,8
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <link>:
.global link
link:
 li a7, SYS_link
 4c6:	48cd                	li	a7,19
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ce:	48d1                	li	a7,20
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d6:	48a5                	li	a7,9
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <dup>:
.global dup
dup:
 li a7, SYS_dup
 4de:	48a9                	li	a7,10
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e6:	48ad                	li	a7,11
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ee:	48b1                	li	a7,12
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f6:	48b5                	li	a7,13
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fe:	48b9                	li	a7,14
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 506:	48d9                	li	a7,22
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 50e:	48dd                	li	a7,23
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 516:	1101                	addi	sp,sp,-32
 518:	ec06                	sd	ra,24(sp)
 51a:	e822                	sd	s0,16(sp)
 51c:	1000                	addi	s0,sp,32
 51e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 522:	4605                	li	a2,1
 524:	fef40593          	addi	a1,s0,-17
 528:	00000097          	auipc	ra,0x0
 52c:	f5e080e7          	jalr	-162(ra) # 486 <write>
}
 530:	60e2                	ld	ra,24(sp)
 532:	6442                	ld	s0,16(sp)
 534:	6105                	addi	sp,sp,32
 536:	8082                	ret

0000000000000538 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 538:	7139                	addi	sp,sp,-64
 53a:	fc06                	sd	ra,56(sp)
 53c:	f822                	sd	s0,48(sp)
 53e:	f426                	sd	s1,40(sp)
 540:	f04a                	sd	s2,32(sp)
 542:	ec4e                	sd	s3,24(sp)
 544:	0080                	addi	s0,sp,64
 546:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 548:	c299                	beqz	a3,54e <printint+0x16>
 54a:	0805c863          	bltz	a1,5da <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 54e:	2581                	sext.w	a1,a1
  neg = 0;
 550:	4881                	li	a7,0
 552:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 556:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 558:	2601                	sext.w	a2,a2
 55a:	00000517          	auipc	a0,0x0
 55e:	63e50513          	addi	a0,a0,1598 # b98 <digits>
 562:	883a                	mv	a6,a4
 564:	2705                	addiw	a4,a4,1
 566:	02c5f7bb          	remuw	a5,a1,a2
 56a:	1782                	slli	a5,a5,0x20
 56c:	9381                	srli	a5,a5,0x20
 56e:	97aa                	add	a5,a5,a0
 570:	0007c783          	lbu	a5,0(a5)
 574:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 578:	0005879b          	sext.w	a5,a1
 57c:	02c5d5bb          	divuw	a1,a1,a2
 580:	0685                	addi	a3,a3,1
 582:	fec7f0e3          	bgeu	a5,a2,562 <printint+0x2a>
  if(neg)
 586:	00088b63          	beqz	a7,59c <printint+0x64>
    buf[i++] = '-';
 58a:	fd040793          	addi	a5,s0,-48
 58e:	973e                	add	a4,a4,a5
 590:	02d00793          	li	a5,45
 594:	fef70823          	sb	a5,-16(a4)
 598:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 59c:	02e05863          	blez	a4,5cc <printint+0x94>
 5a0:	fc040793          	addi	a5,s0,-64
 5a4:	00e78933          	add	s2,a5,a4
 5a8:	fff78993          	addi	s3,a5,-1
 5ac:	99ba                	add	s3,s3,a4
 5ae:	377d                	addiw	a4,a4,-1
 5b0:	1702                	slli	a4,a4,0x20
 5b2:	9301                	srli	a4,a4,0x20
 5b4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b8:	fff94583          	lbu	a1,-1(s2)
 5bc:	8526                	mv	a0,s1
 5be:	00000097          	auipc	ra,0x0
 5c2:	f58080e7          	jalr	-168(ra) # 516 <putc>
  while(--i >= 0)
 5c6:	197d                	addi	s2,s2,-1
 5c8:	ff3918e3          	bne	s2,s3,5b8 <printint+0x80>
}
 5cc:	70e2                	ld	ra,56(sp)
 5ce:	7442                	ld	s0,48(sp)
 5d0:	74a2                	ld	s1,40(sp)
 5d2:	7902                	ld	s2,32(sp)
 5d4:	69e2                	ld	s3,24(sp)
 5d6:	6121                	addi	sp,sp,64
 5d8:	8082                	ret
    x = -xx;
 5da:	40b005bb          	negw	a1,a1
    neg = 1;
 5de:	4885                	li	a7,1
    x = -xx;
 5e0:	bf8d                	j	552 <printint+0x1a>

00000000000005e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e2:	7119                	addi	sp,sp,-128
 5e4:	fc86                	sd	ra,120(sp)
 5e6:	f8a2                	sd	s0,112(sp)
 5e8:	f4a6                	sd	s1,104(sp)
 5ea:	f0ca                	sd	s2,96(sp)
 5ec:	ecce                	sd	s3,88(sp)
 5ee:	e8d2                	sd	s4,80(sp)
 5f0:	e4d6                	sd	s5,72(sp)
 5f2:	e0da                	sd	s6,64(sp)
 5f4:	fc5e                	sd	s7,56(sp)
 5f6:	f862                	sd	s8,48(sp)
 5f8:	f466                	sd	s9,40(sp)
 5fa:	f06a                	sd	s10,32(sp)
 5fc:	ec6e                	sd	s11,24(sp)
 5fe:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 600:	0005c903          	lbu	s2,0(a1)
 604:	18090f63          	beqz	s2,7a2 <vprintf+0x1c0>
 608:	8aaa                	mv	s5,a0
 60a:	8b32                	mv	s6,a2
 60c:	00158493          	addi	s1,a1,1
  state = 0;
 610:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 612:	02500a13          	li	s4,37
      if(c == 'd'){
 616:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 61a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 61e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 622:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 626:	00000b97          	auipc	s7,0x0
 62a:	572b8b93          	addi	s7,s7,1394 # b98 <digits>
 62e:	a839                	j	64c <vprintf+0x6a>
        putc(fd, c);
 630:	85ca                	mv	a1,s2
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	ee2080e7          	jalr	-286(ra) # 516 <putc>
 63c:	a019                	j	642 <vprintf+0x60>
    } else if(state == '%'){
 63e:	01498f63          	beq	s3,s4,65c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 642:	0485                	addi	s1,s1,1
 644:	fff4c903          	lbu	s2,-1(s1)
 648:	14090d63          	beqz	s2,7a2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 64c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 650:	fe0997e3          	bnez	s3,63e <vprintf+0x5c>
      if(c == '%'){
 654:	fd479ee3          	bne	a5,s4,630 <vprintf+0x4e>
        state = '%';
 658:	89be                	mv	s3,a5
 65a:	b7e5                	j	642 <vprintf+0x60>
      if(c == 'd'){
 65c:	05878063          	beq	a5,s8,69c <vprintf+0xba>
      } else if(c == 'l') {
 660:	05978c63          	beq	a5,s9,6b8 <vprintf+0xd6>
      } else if(c == 'x') {
 664:	07a78863          	beq	a5,s10,6d4 <vprintf+0xf2>
      } else if(c == 'p') {
 668:	09b78463          	beq	a5,s11,6f0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 66c:	07300713          	li	a4,115
 670:	0ce78663          	beq	a5,a4,73c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 674:	06300713          	li	a4,99
 678:	0ee78e63          	beq	a5,a4,774 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 67c:	11478863          	beq	a5,s4,78c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 680:	85d2                	mv	a1,s4
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	e92080e7          	jalr	-366(ra) # 516 <putc>
        putc(fd, c);
 68c:	85ca                	mv	a1,s2
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e86080e7          	jalr	-378(ra) # 516 <putc>
      }
      state = 0;
 698:	4981                	li	s3,0
 69a:	b765                	j	642 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 69c:	008b0913          	addi	s2,s6,8
 6a0:	4685                	li	a3,1
 6a2:	4629                	li	a2,10
 6a4:	000b2583          	lw	a1,0(s6)
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e8e080e7          	jalr	-370(ra) # 538 <printint>
 6b2:	8b4a                	mv	s6,s2
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b771                	j	642 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b8:	008b0913          	addi	s2,s6,8
 6bc:	4681                	li	a3,0
 6be:	4629                	li	a2,10
 6c0:	000b2583          	lw	a1,0(s6)
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	e72080e7          	jalr	-398(ra) # 538 <printint>
 6ce:	8b4a                	mv	s6,s2
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bf85                	j	642 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6d4:	008b0913          	addi	s2,s6,8
 6d8:	4681                	li	a3,0
 6da:	4641                	li	a2,16
 6dc:	000b2583          	lw	a1,0(s6)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e56080e7          	jalr	-426(ra) # 538 <printint>
 6ea:	8b4a                	mv	s6,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bf91                	j	642 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6f0:	008b0793          	addi	a5,s6,8
 6f4:	f8f43423          	sd	a5,-120(s0)
 6f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6fc:	03000593          	li	a1,48
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	e14080e7          	jalr	-492(ra) # 516 <putc>
  putc(fd, 'x');
 70a:	85ea                	mv	a1,s10
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e08080e7          	jalr	-504(ra) # 516 <putc>
 716:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 718:	03c9d793          	srli	a5,s3,0x3c
 71c:	97de                	add	a5,a5,s7
 71e:	0007c583          	lbu	a1,0(a5)
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	df2080e7          	jalr	-526(ra) # 516 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72c:	0992                	slli	s3,s3,0x4
 72e:	397d                	addiw	s2,s2,-1
 730:	fe0914e3          	bnez	s2,718 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 734:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 738:	4981                	li	s3,0
 73a:	b721                	j	642 <vprintf+0x60>
        s = va_arg(ap, char*);
 73c:	008b0993          	addi	s3,s6,8
 740:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 744:	02090163          	beqz	s2,766 <vprintf+0x184>
        while(*s != 0){
 748:	00094583          	lbu	a1,0(s2)
 74c:	c9a1                	beqz	a1,79c <vprintf+0x1ba>
          putc(fd, *s);
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	dc6080e7          	jalr	-570(ra) # 516 <putc>
          s++;
 758:	0905                	addi	s2,s2,1
        while(*s != 0){
 75a:	00094583          	lbu	a1,0(s2)
 75e:	f9e5                	bnez	a1,74e <vprintf+0x16c>
        s = va_arg(ap, char*);
 760:	8b4e                	mv	s6,s3
      state = 0;
 762:	4981                	li	s3,0
 764:	bdf9                	j	642 <vprintf+0x60>
          s = "(null)";
 766:	00000917          	auipc	s2,0x0
 76a:	42a90913          	addi	s2,s2,1066 # b90 <malloc+0x2e4>
        while(*s != 0){
 76e:	02800593          	li	a1,40
 772:	bff1                	j	74e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 774:	008b0913          	addi	s2,s6,8
 778:	000b4583          	lbu	a1,0(s6)
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	d98080e7          	jalr	-616(ra) # 516 <putc>
 786:	8b4a                	mv	s6,s2
      state = 0;
 788:	4981                	li	s3,0
 78a:	bd65                	j	642 <vprintf+0x60>
        putc(fd, c);
 78c:	85d2                	mv	a1,s4
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	d86080e7          	jalr	-634(ra) # 516 <putc>
      state = 0;
 798:	4981                	li	s3,0
 79a:	b565                	j	642 <vprintf+0x60>
        s = va_arg(ap, char*);
 79c:	8b4e                	mv	s6,s3
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b54d                	j	642 <vprintf+0x60>
    }
  }
}
 7a2:	70e6                	ld	ra,120(sp)
 7a4:	7446                	ld	s0,112(sp)
 7a6:	74a6                	ld	s1,104(sp)
 7a8:	7906                	ld	s2,96(sp)
 7aa:	69e6                	ld	s3,88(sp)
 7ac:	6a46                	ld	s4,80(sp)
 7ae:	6aa6                	ld	s5,72(sp)
 7b0:	6b06                	ld	s6,64(sp)
 7b2:	7be2                	ld	s7,56(sp)
 7b4:	7c42                	ld	s8,48(sp)
 7b6:	7ca2                	ld	s9,40(sp)
 7b8:	7d02                	ld	s10,32(sp)
 7ba:	6de2                	ld	s11,24(sp)
 7bc:	6109                	addi	sp,sp,128
 7be:	8082                	ret

00000000000007c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c0:	715d                	addi	sp,sp,-80
 7c2:	ec06                	sd	ra,24(sp)
 7c4:	e822                	sd	s0,16(sp)
 7c6:	1000                	addi	s0,sp,32
 7c8:	e010                	sd	a2,0(s0)
 7ca:	e414                	sd	a3,8(s0)
 7cc:	e818                	sd	a4,16(s0)
 7ce:	ec1c                	sd	a5,24(s0)
 7d0:	03043023          	sd	a6,32(s0)
 7d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7dc:	8622                	mv	a2,s0
 7de:	00000097          	auipc	ra,0x0
 7e2:	e04080e7          	jalr	-508(ra) # 5e2 <vprintf>
}
 7e6:	60e2                	ld	ra,24(sp)
 7e8:	6442                	ld	s0,16(sp)
 7ea:	6161                	addi	sp,sp,80
 7ec:	8082                	ret

00000000000007ee <printf>:

void
printf(const char *fmt, ...)
{
 7ee:	711d                	addi	sp,sp,-96
 7f0:	ec06                	sd	ra,24(sp)
 7f2:	e822                	sd	s0,16(sp)
 7f4:	1000                	addi	s0,sp,32
 7f6:	e40c                	sd	a1,8(s0)
 7f8:	e810                	sd	a2,16(s0)
 7fa:	ec14                	sd	a3,24(s0)
 7fc:	f018                	sd	a4,32(s0)
 7fe:	f41c                	sd	a5,40(s0)
 800:	03043823          	sd	a6,48(s0)
 804:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 808:	00840613          	addi	a2,s0,8
 80c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 810:	85aa                	mv	a1,a0
 812:	4505                	li	a0,1
 814:	00000097          	auipc	ra,0x0
 818:	dce080e7          	jalr	-562(ra) # 5e2 <vprintf>
}
 81c:	60e2                	ld	ra,24(sp)
 81e:	6442                	ld	s0,16(sp)
 820:	6125                	addi	sp,sp,96
 822:	8082                	ret

0000000000000824 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 824:	1141                	addi	sp,sp,-16
 826:	e422                	sd	s0,8(sp)
 828:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82e:	00000797          	auipc	a5,0x0
 832:	3827b783          	ld	a5,898(a5) # bb0 <freep>
 836:	a805                	j	866 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 838:	4618                	lw	a4,8(a2)
 83a:	9db9                	addw	a1,a1,a4
 83c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 840:	6398                	ld	a4,0(a5)
 842:	6318                	ld	a4,0(a4)
 844:	fee53823          	sd	a4,-16(a0)
 848:	a091                	j	88c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84a:	ff852703          	lw	a4,-8(a0)
 84e:	9e39                	addw	a2,a2,a4
 850:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 852:	ff053703          	ld	a4,-16(a0)
 856:	e398                	sd	a4,0(a5)
 858:	a099                	j	89e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	6398                	ld	a4,0(a5)
 85c:	00e7e463          	bltu	a5,a4,864 <free+0x40>
 860:	00e6ea63          	bltu	a3,a4,874 <free+0x50>
{
 864:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 866:	fed7fae3          	bgeu	a5,a3,85a <free+0x36>
 86a:	6398                	ld	a4,0(a5)
 86c:	00e6e463          	bltu	a3,a4,874 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 870:	fee7eae3          	bltu	a5,a4,864 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 874:	ff852583          	lw	a1,-8(a0)
 878:	6390                	ld	a2,0(a5)
 87a:	02059713          	slli	a4,a1,0x20
 87e:	9301                	srli	a4,a4,0x20
 880:	0712                	slli	a4,a4,0x4
 882:	9736                	add	a4,a4,a3
 884:	fae60ae3          	beq	a2,a4,838 <free+0x14>
    bp->s.ptr = p->s.ptr;
 888:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88c:	4790                	lw	a2,8(a5)
 88e:	02061713          	slli	a4,a2,0x20
 892:	9301                	srli	a4,a4,0x20
 894:	0712                	slli	a4,a4,0x4
 896:	973e                	add	a4,a4,a5
 898:	fae689e3          	beq	a3,a4,84a <free+0x26>
  } else
    p->s.ptr = bp;
 89c:	e394                	sd	a3,0(a5)
  freep = p;
 89e:	00000717          	auipc	a4,0x0
 8a2:	30f73923          	sd	a5,786(a4) # bb0 <freep>
}
 8a6:	6422                	ld	s0,8(sp)
 8a8:	0141                	addi	sp,sp,16
 8aa:	8082                	ret

00000000000008ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ac:	7139                	addi	sp,sp,-64
 8ae:	fc06                	sd	ra,56(sp)
 8b0:	f822                	sd	s0,48(sp)
 8b2:	f426                	sd	s1,40(sp)
 8b4:	f04a                	sd	s2,32(sp)
 8b6:	ec4e                	sd	s3,24(sp)
 8b8:	e852                	sd	s4,16(sp)
 8ba:	e456                	sd	s5,8(sp)
 8bc:	e05a                	sd	s6,0(sp)
 8be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c0:	02051493          	slli	s1,a0,0x20
 8c4:	9081                	srli	s1,s1,0x20
 8c6:	04bd                	addi	s1,s1,15
 8c8:	8091                	srli	s1,s1,0x4
 8ca:	0014899b          	addiw	s3,s1,1
 8ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d0:	00000517          	auipc	a0,0x0
 8d4:	2e053503          	ld	a0,736(a0) # bb0 <freep>
 8d8:	c515                	beqz	a0,904 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	02977f63          	bgeu	a4,s1,91c <malloc+0x70>
 8e2:	8a4e                	mv	s4,s3
 8e4:	0009871b          	sext.w	a4,s3
 8e8:	6685                	lui	a3,0x1
 8ea:	00d77363          	bgeu	a4,a3,8f0 <malloc+0x44>
 8ee:	6a05                	lui	s4,0x1
 8f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f8:	00000917          	auipc	s2,0x0
 8fc:	2b890913          	addi	s2,s2,696 # bb0 <freep>
  if(p == (char*)-1)
 900:	5afd                	li	s5,-1
 902:	a88d                	j	974 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 904:	00000797          	auipc	a5,0x0
 908:	2b478793          	addi	a5,a5,692 # bb8 <base>
 90c:	00000717          	auipc	a4,0x0
 910:	2af73223          	sd	a5,676(a4) # bb0 <freep>
 914:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 916:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91a:	b7e1                	j	8e2 <malloc+0x36>
      if(p->s.size == nunits)
 91c:	02e48b63          	beq	s1,a4,952 <malloc+0xa6>
        p->s.size -= nunits;
 920:	4137073b          	subw	a4,a4,s3
 924:	c798                	sw	a4,8(a5)
        p += p->s.size;
 926:	1702                	slli	a4,a4,0x20
 928:	9301                	srli	a4,a4,0x20
 92a:	0712                	slli	a4,a4,0x4
 92c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 92e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 932:	00000717          	auipc	a4,0x0
 936:	26a73f23          	sd	a0,638(a4) # bb0 <freep>
      return (void*)(p + 1);
 93a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 93e:	70e2                	ld	ra,56(sp)
 940:	7442                	ld	s0,48(sp)
 942:	74a2                	ld	s1,40(sp)
 944:	7902                	ld	s2,32(sp)
 946:	69e2                	ld	s3,24(sp)
 948:	6a42                	ld	s4,16(sp)
 94a:	6aa2                	ld	s5,8(sp)
 94c:	6b02                	ld	s6,0(sp)
 94e:	6121                	addi	sp,sp,64
 950:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 952:	6398                	ld	a4,0(a5)
 954:	e118                	sd	a4,0(a0)
 956:	bff1                	j	932 <malloc+0x86>
  hp->s.size = nu;
 958:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 95c:	0541                	addi	a0,a0,16
 95e:	00000097          	auipc	ra,0x0
 962:	ec6080e7          	jalr	-314(ra) # 824 <free>
  return freep;
 966:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 96a:	d971                	beqz	a0,93e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96e:	4798                	lw	a4,8(a5)
 970:	fa9776e3          	bgeu	a4,s1,91c <malloc+0x70>
    if(p == freep)
 974:	00093703          	ld	a4,0(s2)
 978:	853e                	mv	a0,a5
 97a:	fef719e3          	bne	a4,a5,96c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 97e:	8552                	mv	a0,s4
 980:	00000097          	auipc	ra,0x0
 984:	b6e080e7          	jalr	-1170(ra) # 4ee <sbrk>
  if(p == (char*)-1)
 988:	fd5518e3          	bne	a0,s5,958 <malloc+0xac>
        return 0;
 98c:	4501                	li	a0,0
 98e:	bf45                	j	93e <malloc+0x92>

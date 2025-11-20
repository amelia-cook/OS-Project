
user/_alloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
#include "user/user.h"

enum { NCHILD = 50, NFD = 10};

void
test0() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
  int i, j;
  int fd;

  printf("filetest: start\n");
   c:	00001517          	auipc	a0,0x1
  10:	9cc50513          	addi	a0,a0,-1588 # 9d8 <malloc+0xe6>
  14:	00001097          	auipc	ra,0x1
  18:	820080e7          	jalr	-2016(ra) # 834 <printf>
  1c:	03200493          	li	s1,50
    printf("test setup is wrong\n");
    exit(1);
  }

  for (i = 0; i < NCHILD; i++) {
    int pid = fork();
  20:	00000097          	auipc	ra,0x0
  24:	484080e7          	jalr	1156(ra) # 4a4 <fork>
    if(pid < 0){
  28:	04054263          	bltz	a0,6c <test0+0x6c>
      printf("fork failed\n");
      exit(-1);
    }
    if(pid == 0){
  2c:	cd29                	beqz	a0,86 <test0+0x86>
  for (i = 0; i < NCHILD; i++) {
  2e:	34fd                	addiw	s1,s1,-1
  30:	f8e5                	bnez	s1,20 <test0+0x20>
  32:	03200493          	li	s1,50
  }

  for(int i = 0; i < NCHILD; i++){
    int xstatus;
    wait(&xstatus);
    if(xstatus == -1) {
  36:	597d                	li	s2,-1
    wait(&xstatus);
  38:	fdc40513          	addi	a0,s0,-36
  3c:	00000097          	auipc	ra,0x0
  40:	478080e7          	jalr	1144(ra) # 4b4 <wait>
    if(xstatus == -1) {
  44:	fdc42783          	lw	a5,-36(s0)
  48:	09278563          	beq	a5,s2,d2 <test0+0xd2>
  for(int i = 0; i < NCHILD; i++){
  4c:	34fd                	addiw	s1,s1,-1
  4e:	f4ed                	bnez	s1,38 <test0+0x38>
       printf("filetest: FAILED\n");
       exit(-1);
    }
  }

  printf("filetest: OK\n");
  50:	00001517          	auipc	a0,0x1
  54:	9e050513          	addi	a0,a0,-1568 # a30 <malloc+0x13e>
  58:	00000097          	auipc	ra,0x0
  5c:	7dc080e7          	jalr	2012(ra) # 834 <printf>
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	6145                	addi	sp,sp,48
  6a:	8082                	ret
      printf("fork failed\n");
  6c:	00001517          	auipc	a0,0x1
  70:	98450513          	addi	a0,a0,-1660 # 9f0 <malloc+0xfe>
  74:	00000097          	auipc	ra,0x0
  78:	7c0080e7          	jalr	1984(ra) # 834 <printf>
      exit(-1);
  7c:	557d                	li	a0,-1
  7e:	00000097          	auipc	ra,0x0
  82:	42e080e7          	jalr	1070(ra) # 4ac <exit>
  86:	44a9                	li	s1,10
        if ((fd = open("README", O_RDONLY)) < 0) {
  88:	00001917          	auipc	s2,0x1
  8c:	97890913          	addi	s2,s2,-1672 # a00 <malloc+0x10e>
  90:	4581                	li	a1,0
  92:	854a                	mv	a0,s2
  94:	00000097          	auipc	ra,0x0
  98:	458080e7          	jalr	1112(ra) # 4ec <open>
  9c:	00054e63          	bltz	a0,b8 <test0+0xb8>
      for(j = 0; j < NFD; j++) {
  a0:	34fd                	addiw	s1,s1,-1
  a2:	f4fd                	bnez	s1,90 <test0+0x90>
      sleep(10);
  a4:	4529                	li	a0,10
  a6:	00000097          	auipc	ra,0x0
  aa:	496080e7          	jalr	1174(ra) # 53c <sleep>
      exit(0);  // no errors; exit with 0.
  ae:	4501                	li	a0,0
  b0:	00000097          	auipc	ra,0x0
  b4:	3fc080e7          	jalr	1020(ra) # 4ac <exit>
          printf("open failed\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	95050513          	addi	a0,a0,-1712 # a08 <malloc+0x116>
  c0:	00000097          	auipc	ra,0x0
  c4:	774080e7          	jalr	1908(ra) # 834 <printf>
          exit(-1);
  c8:	557d                	li	a0,-1
  ca:	00000097          	auipc	ra,0x0
  ce:	3e2080e7          	jalr	994(ra) # 4ac <exit>
       printf("filetest: FAILED\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	94650513          	addi	a0,a0,-1722 # a18 <malloc+0x126>
  da:	00000097          	auipc	ra,0x0
  de:	75a080e7          	jalr	1882(ra) # 834 <printf>
       exit(-1);
  e2:	557d                	li	a0,-1
  e4:	00000097          	auipc	ra,0x0
  e8:	3c8080e7          	jalr	968(ra) # 4ac <exit>

00000000000000ec <test1>:

void test1()
{
  ec:	7139                	addi	sp,sp,-64
  ee:	fc06                	sd	ra,56(sp)
  f0:	f822                	sd	s0,48(sp)
  f2:	f426                	sd	s1,40(sp)
  f4:	f04a                	sd	s2,32(sp)
  f6:	ec4e                	sd	s3,24(sp)
  f8:	0080                	addi	s0,sp,64
  int pid, xstatus, n0, n;

  printf("memtest: start\n");
  fa:	00001517          	auipc	a0,0x1
  fe:	94650513          	addi	a0,a0,-1722 # a40 <malloc+0x14e>
 102:	00000097          	auipc	ra,0x0
 106:	732080e7          	jalr	1842(ra) # 834 <printf>

  n0 = nfree();
 10a:	00000097          	auipc	ra,0x0
 10e:	44a080e7          	jalr	1098(ra) # 554 <nfree>
 112:	84aa                	mv	s1,a0

  pid = fork();
 114:	00000097          	auipc	ra,0x0
 118:	390080e7          	jalr	912(ra) # 4a4 <fork>
  if(pid < 0){
 11c:	04054f63          	bltz	a0,17a <test1+0x8e>
    printf("fork failed");
    exit(1);
  }

  if(pid == 0){
 120:	ed41                	bnez	a0,1b8 <test1+0xcc>
    int i, fd;

    n0 = nfree();
 122:	00000097          	auipc	ra,0x0
 126:	432080e7          	jalr	1074(ra) # 554 <nfree>
 12a:	89aa                	mv	s3,a0
 12c:	44a9                	li	s1,10
    for(i = 0; i < NFD; i++) {
      if ((fd = open("README", O_RDONLY)) < 0) {
 12e:	00001917          	auipc	s2,0x1
 132:	8d290913          	addi	s2,s2,-1838 # a00 <malloc+0x10e>
 136:	4581                	li	a1,0
 138:	854a                	mv	a0,s2
 13a:	00000097          	auipc	ra,0x0
 13e:	3b2080e7          	jalr	946(ra) # 4ec <open>
 142:	04054963          	bltz	a0,194 <test1+0xa8>
    for(i = 0; i < NFD; i++) {
 146:	34fd                	addiw	s1,s1,-1
 148:	f4fd                	bnez	s1,136 <test1+0x4a>
        // the open() failed; exit with -1
        printf("open failed\n");
        exit(-1);
      }
    }
    n = n0 - nfree();
 14a:	00000097          	auipc	ra,0x0
 14e:	40a080e7          	jalr	1034(ra) # 554 <nfree>
 152:	40a9853b          	subw	a0,s3,a0
 156:	0005059b          	sext.w	a1,a0
    // n should be 0 but we're okay with 1
    if(n != 0 && n != 1){
 15a:	4785                	li	a5,1
 15c:	04b7f963          	bgeu	a5,a1,1ae <test1+0xc2>
      printf("expected to allocate at most one page, got %d\n", n);
 160:	00001517          	auipc	a0,0x1
 164:	90050513          	addi	a0,a0,-1792 # a60 <malloc+0x16e>
 168:	00000097          	auipc	ra,0x0
 16c:	6cc080e7          	jalr	1740(ra) # 834 <printf>
      exit(-1);
 170:	557d                	li	a0,-1
 172:	00000097          	auipc	ra,0x0
 176:	33a080e7          	jalr	826(ra) # 4ac <exit>
    printf("fork failed");
 17a:	00001517          	auipc	a0,0x1
 17e:	8d650513          	addi	a0,a0,-1834 # a50 <malloc+0x15e>
 182:	00000097          	auipc	ra,0x0
 186:	6b2080e7          	jalr	1714(ra) # 834 <printf>
    exit(1);
 18a:	4505                	li	a0,1
 18c:	00000097          	auipc	ra,0x0
 190:	320080e7          	jalr	800(ra) # 4ac <exit>
        printf("open failed\n");
 194:	00001517          	auipc	a0,0x1
 198:	87450513          	addi	a0,a0,-1932 # a08 <malloc+0x116>
 19c:	00000097          	auipc	ra,0x0
 1a0:	698080e7          	jalr	1688(ra) # 834 <printf>
        exit(-1);
 1a4:	557d                	li	a0,-1
 1a6:	00000097          	auipc	ra,0x0
 1aa:	306080e7          	jalr	774(ra) # 4ac <exit>
    }
    exit(0);
 1ae:	4501                	li	a0,0
 1b0:	00000097          	auipc	ra,0x0
 1b4:	2fc080e7          	jalr	764(ra) # 4ac <exit>
  }

  wait(&xstatus);
 1b8:	fcc40513          	addi	a0,s0,-52
 1bc:	00000097          	auipc	ra,0x0
 1c0:	2f8080e7          	jalr	760(ra) # 4b4 <wait>
  if(xstatus == -1)
 1c4:	fcc42703          	lw	a4,-52(s0)
 1c8:	57fd                	li	a5,-1
 1ca:	02f70a63          	beq	a4,a5,1fe <test1+0x112>
    goto failed;

  n = n0 - nfree();
 1ce:	00000097          	auipc	ra,0x0
 1d2:	386080e7          	jalr	902(ra) # 554 <nfree>
 1d6:	40a485bb          	subw	a1,s1,a0
  if(n){
 1da:	e991                	bnez	a1,1ee <test1+0x102>
    printf("expected to free all the pages, got %d\n", n);
    goto failed;
  }
  printf("memtest: OK\n");
 1dc:	00001517          	auipc	a0,0x1
 1e0:	8dc50513          	addi	a0,a0,-1828 # ab8 <malloc+0x1c6>
 1e4:	00000097          	auipc	ra,0x0
 1e8:	650080e7          	jalr	1616(ra) # 834 <printf>
  return;
 1ec:	a00d                	j	20e <test1+0x122>
    printf("expected to free all the pages, got %d\n", n);
 1ee:	00001517          	auipc	a0,0x1
 1f2:	8a250513          	addi	a0,a0,-1886 # a90 <malloc+0x19e>
 1f6:	00000097          	auipc	ra,0x0
 1fa:	63e080e7          	jalr	1598(ra) # 834 <printf>

failed:
  printf("memtest: FAILED\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	8ca50513          	addi	a0,a0,-1846 # ac8 <malloc+0x1d6>
 206:	00000097          	auipc	ra,0x0
 20a:	62e080e7          	jalr	1582(ra) # 834 <printf>
}
 20e:	70e2                	ld	ra,56(sp)
 210:	7442                	ld	s0,48(sp)
 212:	74a2                	ld	s1,40(sp)
 214:	7902                	ld	s2,32(sp)
 216:	69e2                	ld	s3,24(sp)
 218:	6121                	addi	sp,sp,64
 21a:	8082                	ret

000000000000021c <main>:

int
main(int argc, char *argv[])
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e406                	sd	ra,8(sp)
 220:	e022                	sd	s0,0(sp)
 222:	0800                	addi	s0,sp,16
  test0();
 224:	00000097          	auipc	ra,0x0
 228:	ddc080e7          	jalr	-548(ra) # 0 <test0>
  test1();
 22c:	00000097          	auipc	ra,0x0
 230:	ec0080e7          	jalr	-320(ra) # ec <test1>
  exit(0);
 234:	4501                	li	a0,0
 236:	00000097          	auipc	ra,0x0
 23a:	276080e7          	jalr	630(ra) # 4ac <exit>

000000000000023e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 244:	87aa                	mv	a5,a0
 246:	0585                	addi	a1,a1,1
 248:	0785                	addi	a5,a5,1
 24a:	fff5c703          	lbu	a4,-1(a1)
 24e:	fee78fa3          	sb	a4,-1(a5)
 252:	fb75                	bnez	a4,246 <strcpy+0x8>
    ;
  return os;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 260:	00054783          	lbu	a5,0(a0)
 264:	cb91                	beqz	a5,278 <strcmp+0x1e>
 266:	0005c703          	lbu	a4,0(a1)
 26a:	00f71763          	bne	a4,a5,278 <strcmp+0x1e>
    p++, q++;
 26e:	0505                	addi	a0,a0,1
 270:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 272:	00054783          	lbu	a5,0(a0)
 276:	fbe5                	bnez	a5,266 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 278:	0005c503          	lbu	a0,0(a1)
}
 27c:	40a7853b          	subw	a0,a5,a0
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strlen>:

uint
strlen(const char *s)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cf91                	beqz	a5,2ac <strlen+0x26>
 292:	0505                	addi	a0,a0,1
 294:	87aa                	mv	a5,a0
 296:	4685                	li	a3,1
 298:	9e89                	subw	a3,a3,a0
 29a:	00f6853b          	addw	a0,a3,a5
 29e:	0785                	addi	a5,a5,1
 2a0:	fff7c703          	lbu	a4,-1(a5)
 2a4:	fb7d                	bnez	a4,29a <strlen+0x14>
    ;
  return n;
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  for(n = 0; s[n]; n++)
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strlen+0x20>

00000000000002b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e422                	sd	s0,8(sp)
 2b4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2b6:	ca19                	beqz	a2,2cc <memset+0x1c>
 2b8:	87aa                	mv	a5,a0
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2c6:	0785                	addi	a5,a5,1
 2c8:	fee79de3          	bne	a5,a4,2c2 <memset+0x12>
  }
  return dst;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret

00000000000002d2 <strchr>:

char*
strchr(const char *s, char c)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	cb99                	beqz	a5,2f2 <strchr+0x20>
    if(*s == c)
 2de:	00f58763          	beq	a1,a5,2ec <strchr+0x1a>
  for(; *s; s++)
 2e2:	0505                	addi	a0,a0,1
 2e4:	00054783          	lbu	a5,0(a0)
 2e8:	fbfd                	bnez	a5,2de <strchr+0xc>
      return (char*)s;
  return 0;
 2ea:	4501                	li	a0,0
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <strchr+0x1a>

00000000000002f6 <gets>:

char*
gets(char *buf, int max)
{
 2f6:	711d                	addi	sp,sp,-96
 2f8:	ec86                	sd	ra,88(sp)
 2fa:	e8a2                	sd	s0,80(sp)
 2fc:	e4a6                	sd	s1,72(sp)
 2fe:	e0ca                	sd	s2,64(sp)
 300:	fc4e                	sd	s3,56(sp)
 302:	f852                	sd	s4,48(sp)
 304:	f456                	sd	s5,40(sp)
 306:	f05a                	sd	s6,32(sp)
 308:	ec5e                	sd	s7,24(sp)
 30a:	1080                	addi	s0,sp,96
 30c:	8baa                	mv	s7,a0
 30e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 310:	892a                	mv	s2,a0
 312:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 314:	4aa9                	li	s5,10
 316:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 318:	89a6                	mv	s3,s1
 31a:	2485                	addiw	s1,s1,1
 31c:	0344d863          	bge	s1,s4,34c <gets+0x56>
    cc = read(0, &c, 1);
 320:	4605                	li	a2,1
 322:	faf40593          	addi	a1,s0,-81
 326:	4501                	li	a0,0
 328:	00000097          	auipc	ra,0x0
 32c:	19c080e7          	jalr	412(ra) # 4c4 <read>
    if(cc < 1)
 330:	00a05e63          	blez	a0,34c <gets+0x56>
    buf[i++] = c;
 334:	faf44783          	lbu	a5,-81(s0)
 338:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 33c:	01578763          	beq	a5,s5,34a <gets+0x54>
 340:	0905                	addi	s2,s2,1
 342:	fd679be3          	bne	a5,s6,318 <gets+0x22>
  for(i=0; i+1 < max; ){
 346:	89a6                	mv	s3,s1
 348:	a011                	j	34c <gets+0x56>
 34a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 34c:	99de                	add	s3,s3,s7
 34e:	00098023          	sb	zero,0(s3)
  return buf;
}
 352:	855e                	mv	a0,s7
 354:	60e6                	ld	ra,88(sp)
 356:	6446                	ld	s0,80(sp)
 358:	64a6                	ld	s1,72(sp)
 35a:	6906                	ld	s2,64(sp)
 35c:	79e2                	ld	s3,56(sp)
 35e:	7a42                	ld	s4,48(sp)
 360:	7aa2                	ld	s5,40(sp)
 362:	7b02                	ld	s6,32(sp)
 364:	6be2                	ld	s7,24(sp)
 366:	6125                	addi	sp,sp,96
 368:	8082                	ret

000000000000036a <stat>:

int
stat(const char *n, struct stat *st)
{
 36a:	1101                	addi	sp,sp,-32
 36c:	ec06                	sd	ra,24(sp)
 36e:	e822                	sd	s0,16(sp)
 370:	e426                	sd	s1,8(sp)
 372:	e04a                	sd	s2,0(sp)
 374:	1000                	addi	s0,sp,32
 376:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 378:	4581                	li	a1,0
 37a:	00000097          	auipc	ra,0x0
 37e:	172080e7          	jalr	370(ra) # 4ec <open>
  if(fd < 0)
 382:	02054563          	bltz	a0,3ac <stat+0x42>
 386:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 388:	85ca                	mv	a1,s2
 38a:	00000097          	auipc	ra,0x0
 38e:	17a080e7          	jalr	378(ra) # 504 <fstat>
 392:	892a                	mv	s2,a0
  close(fd);
 394:	8526                	mv	a0,s1
 396:	00000097          	auipc	ra,0x0
 39a:	13e080e7          	jalr	318(ra) # 4d4 <close>
  return r;
}
 39e:	854a                	mv	a0,s2
 3a0:	60e2                	ld	ra,24(sp)
 3a2:	6442                	ld	s0,16(sp)
 3a4:	64a2                	ld	s1,8(sp)
 3a6:	6902                	ld	s2,0(sp)
 3a8:	6105                	addi	sp,sp,32
 3aa:	8082                	ret
    return -1;
 3ac:	597d                	li	s2,-1
 3ae:	bfc5                	j	39e <stat+0x34>

00000000000003b0 <atoi>:

int
atoi(const char *s)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3b6:	00054603          	lbu	a2,0(a0)
 3ba:	fd06079b          	addiw	a5,a2,-48
 3be:	0ff7f793          	andi	a5,a5,255
 3c2:	4725                	li	a4,9
 3c4:	02f76963          	bltu	a4,a5,3f6 <atoi+0x46>
 3c8:	86aa                	mv	a3,a0
  n = 0;
 3ca:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3cc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3ce:	0685                	addi	a3,a3,1
 3d0:	0025179b          	slliw	a5,a0,0x2
 3d4:	9fa9                	addw	a5,a5,a0
 3d6:	0017979b          	slliw	a5,a5,0x1
 3da:	9fb1                	addw	a5,a5,a2
 3dc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3e0:	0006c603          	lbu	a2,0(a3)
 3e4:	fd06071b          	addiw	a4,a2,-48
 3e8:	0ff77713          	andi	a4,a4,255
 3ec:	fee5f1e3          	bgeu	a1,a4,3ce <atoi+0x1e>
  return n;
}
 3f0:	6422                	ld	s0,8(sp)
 3f2:	0141                	addi	sp,sp,16
 3f4:	8082                	ret
  n = 0;
 3f6:	4501                	li	a0,0
 3f8:	bfe5                	j	3f0 <atoi+0x40>

00000000000003fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 400:	02b57463          	bgeu	a0,a1,428 <memmove+0x2e>
    while(n-- > 0)
 404:	00c05f63          	blez	a2,422 <memmove+0x28>
 408:	1602                	slli	a2,a2,0x20
 40a:	9201                	srli	a2,a2,0x20
 40c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 410:	872a                	mv	a4,a0
      *dst++ = *src++;
 412:	0585                	addi	a1,a1,1
 414:	0705                	addi	a4,a4,1
 416:	fff5c683          	lbu	a3,-1(a1)
 41a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 41e:	fee79ae3          	bne	a5,a4,412 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
    dst += n;
 428:	00c50733          	add	a4,a0,a2
    src += n;
 42c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 42e:	fec05ae3          	blez	a2,422 <memmove+0x28>
 432:	fff6079b          	addiw	a5,a2,-1
 436:	1782                	slli	a5,a5,0x20
 438:	9381                	srli	a5,a5,0x20
 43a:	fff7c793          	not	a5,a5
 43e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 440:	15fd                	addi	a1,a1,-1
 442:	177d                	addi	a4,a4,-1
 444:	0005c683          	lbu	a3,0(a1)
 448:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 44c:	fee79ae3          	bne	a5,a4,440 <memmove+0x46>
 450:	bfc9                	j	422 <memmove+0x28>

0000000000000452 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 458:	ca05                	beqz	a2,488 <memcmp+0x36>
 45a:	fff6069b          	addiw	a3,a2,-1
 45e:	1682                	slli	a3,a3,0x20
 460:	9281                	srli	a3,a3,0x20
 462:	0685                	addi	a3,a3,1
 464:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 466:	00054783          	lbu	a5,0(a0)
 46a:	0005c703          	lbu	a4,0(a1)
 46e:	00e79863          	bne	a5,a4,47e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 472:	0505                	addi	a0,a0,1
    p2++;
 474:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 476:	fed518e3          	bne	a0,a3,466 <memcmp+0x14>
  }
  return 0;
 47a:	4501                	li	a0,0
 47c:	a019                	j	482 <memcmp+0x30>
      return *p1 - *p2;
 47e:	40e7853b          	subw	a0,a5,a4
}
 482:	6422                	ld	s0,8(sp)
 484:	0141                	addi	sp,sp,16
 486:	8082                	ret
  return 0;
 488:	4501                	li	a0,0
 48a:	bfe5                	j	482 <memcmp+0x30>

000000000000048c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 48c:	1141                	addi	sp,sp,-16
 48e:	e406                	sd	ra,8(sp)
 490:	e022                	sd	s0,0(sp)
 492:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 494:	00000097          	auipc	ra,0x0
 498:	f66080e7          	jalr	-154(ra) # 3fa <memmove>
}
 49c:	60a2                	ld	ra,8(sp)
 49e:	6402                	ld	s0,0(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret

00000000000004a4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a4:	4885                	li	a7,1
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ac:	4889                	li	a7,2
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b4:	488d                	li	a7,3
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4bc:	4891                	li	a7,4
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <read>:
.global read
read:
 li a7, SYS_read
 4c4:	4895                	li	a7,5
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <write>:
.global write
write:
 li a7, SYS_write
 4cc:	48c1                	li	a7,16
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <close>:
.global close
close:
 li a7, SYS_close
 4d4:	48d5                	li	a7,21
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <kill>:
.global kill
kill:
 li a7, SYS_kill
 4dc:	4899                	li	a7,6
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e4:	489d                	li	a7,7
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <open>:
.global open
open:
 li a7, SYS_open
 4ec:	48bd                	li	a7,15
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f4:	48c5                	li	a7,17
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4fc:	48c9                	li	a7,18
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 504:	48a1                	li	a7,8
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <link>:
.global link
link:
 li a7, SYS_link
 50c:	48cd                	li	a7,19
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 514:	48d1                	li	a7,20
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 51c:	48a5                	li	a7,9
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <dup>:
.global dup
dup:
 li a7, SYS_dup
 524:	48a9                	li	a7,10
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 52c:	48ad                	li	a7,11
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 534:	48b1                	li	a7,12
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 53c:	48b5                	li	a7,13
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 544:	48b9                	li	a7,14
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 54c:	48d9                	li	a7,22
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 554:	48dd                	li	a7,23
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 55c:	1101                	addi	sp,sp,-32
 55e:	ec06                	sd	ra,24(sp)
 560:	e822                	sd	s0,16(sp)
 562:	1000                	addi	s0,sp,32
 564:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 568:	4605                	li	a2,1
 56a:	fef40593          	addi	a1,s0,-17
 56e:	00000097          	auipc	ra,0x0
 572:	f5e080e7          	jalr	-162(ra) # 4cc <write>
}
 576:	60e2                	ld	ra,24(sp)
 578:	6442                	ld	s0,16(sp)
 57a:	6105                	addi	sp,sp,32
 57c:	8082                	ret

000000000000057e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 57e:	7139                	addi	sp,sp,-64
 580:	fc06                	sd	ra,56(sp)
 582:	f822                	sd	s0,48(sp)
 584:	f426                	sd	s1,40(sp)
 586:	f04a                	sd	s2,32(sp)
 588:	ec4e                	sd	s3,24(sp)
 58a:	0080                	addi	s0,sp,64
 58c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 58e:	c299                	beqz	a3,594 <printint+0x16>
 590:	0805c863          	bltz	a1,620 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 594:	2581                	sext.w	a1,a1
  neg = 0;
 596:	4881                	li	a7,0
 598:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 59c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 59e:	2601                	sext.w	a2,a2
 5a0:	00000517          	auipc	a0,0x0
 5a4:	54850513          	addi	a0,a0,1352 # ae8 <digits>
 5a8:	883a                	mv	a6,a4
 5aa:	2705                	addiw	a4,a4,1
 5ac:	02c5f7bb          	remuw	a5,a1,a2
 5b0:	1782                	slli	a5,a5,0x20
 5b2:	9381                	srli	a5,a5,0x20
 5b4:	97aa                	add	a5,a5,a0
 5b6:	0007c783          	lbu	a5,0(a5)
 5ba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5be:	0005879b          	sext.w	a5,a1
 5c2:	02c5d5bb          	divuw	a1,a1,a2
 5c6:	0685                	addi	a3,a3,1
 5c8:	fec7f0e3          	bgeu	a5,a2,5a8 <printint+0x2a>
  if(neg)
 5cc:	00088b63          	beqz	a7,5e2 <printint+0x64>
    buf[i++] = '-';
 5d0:	fd040793          	addi	a5,s0,-48
 5d4:	973e                	add	a4,a4,a5
 5d6:	02d00793          	li	a5,45
 5da:	fef70823          	sb	a5,-16(a4)
 5de:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5e2:	02e05863          	blez	a4,612 <printint+0x94>
 5e6:	fc040793          	addi	a5,s0,-64
 5ea:	00e78933          	add	s2,a5,a4
 5ee:	fff78993          	addi	s3,a5,-1
 5f2:	99ba                	add	s3,s3,a4
 5f4:	377d                	addiw	a4,a4,-1
 5f6:	1702                	slli	a4,a4,0x20
 5f8:	9301                	srli	a4,a4,0x20
 5fa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5fe:	fff94583          	lbu	a1,-1(s2)
 602:	8526                	mv	a0,s1
 604:	00000097          	auipc	ra,0x0
 608:	f58080e7          	jalr	-168(ra) # 55c <putc>
  while(--i >= 0)
 60c:	197d                	addi	s2,s2,-1
 60e:	ff3918e3          	bne	s2,s3,5fe <printint+0x80>
}
 612:	70e2                	ld	ra,56(sp)
 614:	7442                	ld	s0,48(sp)
 616:	74a2                	ld	s1,40(sp)
 618:	7902                	ld	s2,32(sp)
 61a:	69e2                	ld	s3,24(sp)
 61c:	6121                	addi	sp,sp,64
 61e:	8082                	ret
    x = -xx;
 620:	40b005bb          	negw	a1,a1
    neg = 1;
 624:	4885                	li	a7,1
    x = -xx;
 626:	bf8d                	j	598 <printint+0x1a>

0000000000000628 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 628:	7119                	addi	sp,sp,-128
 62a:	fc86                	sd	ra,120(sp)
 62c:	f8a2                	sd	s0,112(sp)
 62e:	f4a6                	sd	s1,104(sp)
 630:	f0ca                	sd	s2,96(sp)
 632:	ecce                	sd	s3,88(sp)
 634:	e8d2                	sd	s4,80(sp)
 636:	e4d6                	sd	s5,72(sp)
 638:	e0da                	sd	s6,64(sp)
 63a:	fc5e                	sd	s7,56(sp)
 63c:	f862                	sd	s8,48(sp)
 63e:	f466                	sd	s9,40(sp)
 640:	f06a                	sd	s10,32(sp)
 642:	ec6e                	sd	s11,24(sp)
 644:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 646:	0005c903          	lbu	s2,0(a1)
 64a:	18090f63          	beqz	s2,7e8 <vprintf+0x1c0>
 64e:	8aaa                	mv	s5,a0
 650:	8b32                	mv	s6,a2
 652:	00158493          	addi	s1,a1,1
  state = 0;
 656:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 658:	02500a13          	li	s4,37
      if(c == 'd'){
 65c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 660:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 664:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 668:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66c:	00000b97          	auipc	s7,0x0
 670:	47cb8b93          	addi	s7,s7,1148 # ae8 <digits>
 674:	a839                	j	692 <vprintf+0x6a>
        putc(fd, c);
 676:	85ca                	mv	a1,s2
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	ee2080e7          	jalr	-286(ra) # 55c <putc>
 682:	a019                	j	688 <vprintf+0x60>
    } else if(state == '%'){
 684:	01498f63          	beq	s3,s4,6a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 688:	0485                	addi	s1,s1,1
 68a:	fff4c903          	lbu	s2,-1(s1)
 68e:	14090d63          	beqz	s2,7e8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 692:	0009079b          	sext.w	a5,s2
    if(state == 0){
 696:	fe0997e3          	bnez	s3,684 <vprintf+0x5c>
      if(c == '%'){
 69a:	fd479ee3          	bne	a5,s4,676 <vprintf+0x4e>
        state = '%';
 69e:	89be                	mv	s3,a5
 6a0:	b7e5                	j	688 <vprintf+0x60>
      if(c == 'd'){
 6a2:	05878063          	beq	a5,s8,6e2 <vprintf+0xba>
      } else if(c == 'l') {
 6a6:	05978c63          	beq	a5,s9,6fe <vprintf+0xd6>
      } else if(c == 'x') {
 6aa:	07a78863          	beq	a5,s10,71a <vprintf+0xf2>
      } else if(c == 'p') {
 6ae:	09b78463          	beq	a5,s11,736 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6b2:	07300713          	li	a4,115
 6b6:	0ce78663          	beq	a5,a4,782 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ba:	06300713          	li	a4,99
 6be:	0ee78e63          	beq	a5,a4,7ba <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6c2:	11478863          	beq	a5,s4,7d2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6c6:	85d2                	mv	a1,s4
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e92080e7          	jalr	-366(ra) # 55c <putc>
        putc(fd, c);
 6d2:	85ca                	mv	a1,s2
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e86080e7          	jalr	-378(ra) # 55c <putc>
      }
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b765                	j	688 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6e2:	008b0913          	addi	s2,s6,8
 6e6:	4685                	li	a3,1
 6e8:	4629                	li	a2,10
 6ea:	000b2583          	lw	a1,0(s6)
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e8e080e7          	jalr	-370(ra) # 57e <printint>
 6f8:	8b4a                	mv	s6,s2
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b771                	j	688 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fe:	008b0913          	addi	s2,s6,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000b2583          	lw	a1,0(s6)
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	e72080e7          	jalr	-398(ra) # 57e <printint>
 714:	8b4a                	mv	s6,s2
      state = 0;
 716:	4981                	li	s3,0
 718:	bf85                	j	688 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 71a:	008b0913          	addi	s2,s6,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000b2583          	lw	a1,0(s6)
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	e56080e7          	jalr	-426(ra) # 57e <printint>
 730:	8b4a                	mv	s6,s2
      state = 0;
 732:	4981                	li	s3,0
 734:	bf91                	j	688 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 736:	008b0793          	addi	a5,s6,8
 73a:	f8f43423          	sd	a5,-120(s0)
 73e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 742:	03000593          	li	a1,48
 746:	8556                	mv	a0,s5
 748:	00000097          	auipc	ra,0x0
 74c:	e14080e7          	jalr	-492(ra) # 55c <putc>
  putc(fd, 'x');
 750:	85ea                	mv	a1,s10
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	e08080e7          	jalr	-504(ra) # 55c <putc>
 75c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75e:	03c9d793          	srli	a5,s3,0x3c
 762:	97de                	add	a5,a5,s7
 764:	0007c583          	lbu	a1,0(a5)
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	df2080e7          	jalr	-526(ra) # 55c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 772:	0992                	slli	s3,s3,0x4
 774:	397d                	addiw	s2,s2,-1
 776:	fe0914e3          	bnez	s2,75e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 77a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 77e:	4981                	li	s3,0
 780:	b721                	j	688 <vprintf+0x60>
        s = va_arg(ap, char*);
 782:	008b0993          	addi	s3,s6,8
 786:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 78a:	02090163          	beqz	s2,7ac <vprintf+0x184>
        while(*s != 0){
 78e:	00094583          	lbu	a1,0(s2)
 792:	c9a1                	beqz	a1,7e2 <vprintf+0x1ba>
          putc(fd, *s);
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	dc6080e7          	jalr	-570(ra) # 55c <putc>
          s++;
 79e:	0905                	addi	s2,s2,1
        while(*s != 0){
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	f9e5                	bnez	a1,794 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7a6:	8b4e                	mv	s6,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bdf9                	j	688 <vprintf+0x60>
          s = "(null)";
 7ac:	00000917          	auipc	s2,0x0
 7b0:	33490913          	addi	s2,s2,820 # ae0 <malloc+0x1ee>
        while(*s != 0){
 7b4:	02800593          	li	a1,40
 7b8:	bff1                	j	794 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ba:	008b0913          	addi	s2,s6,8
 7be:	000b4583          	lbu	a1,0(s6)
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	d98080e7          	jalr	-616(ra) # 55c <putc>
 7cc:	8b4a                	mv	s6,s2
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	bd65                	j	688 <vprintf+0x60>
        putc(fd, c);
 7d2:	85d2                	mv	a1,s4
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	d86080e7          	jalr	-634(ra) # 55c <putc>
      state = 0;
 7de:	4981                	li	s3,0
 7e0:	b565                	j	688 <vprintf+0x60>
        s = va_arg(ap, char*);
 7e2:	8b4e                	mv	s6,s3
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	b54d                	j	688 <vprintf+0x60>
    }
  }
}
 7e8:	70e6                	ld	ra,120(sp)
 7ea:	7446                	ld	s0,112(sp)
 7ec:	74a6                	ld	s1,104(sp)
 7ee:	7906                	ld	s2,96(sp)
 7f0:	69e6                	ld	s3,88(sp)
 7f2:	6a46                	ld	s4,80(sp)
 7f4:	6aa6                	ld	s5,72(sp)
 7f6:	6b06                	ld	s6,64(sp)
 7f8:	7be2                	ld	s7,56(sp)
 7fa:	7c42                	ld	s8,48(sp)
 7fc:	7ca2                	ld	s9,40(sp)
 7fe:	7d02                	ld	s10,32(sp)
 800:	6de2                	ld	s11,24(sp)
 802:	6109                	addi	sp,sp,128
 804:	8082                	ret

0000000000000806 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 806:	715d                	addi	sp,sp,-80
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e010                	sd	a2,0(s0)
 810:	e414                	sd	a3,8(s0)
 812:	e818                	sd	a4,16(s0)
 814:	ec1c                	sd	a5,24(s0)
 816:	03043023          	sd	a6,32(s0)
 81a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 822:	8622                	mv	a2,s0
 824:	00000097          	auipc	ra,0x0
 828:	e04080e7          	jalr	-508(ra) # 628 <vprintf>
}
 82c:	60e2                	ld	ra,24(sp)
 82e:	6442                	ld	s0,16(sp)
 830:	6161                	addi	sp,sp,80
 832:	8082                	ret

0000000000000834 <printf>:

void
printf(const char *fmt, ...)
{
 834:	711d                	addi	sp,sp,-96
 836:	ec06                	sd	ra,24(sp)
 838:	e822                	sd	s0,16(sp)
 83a:	1000                	addi	s0,sp,32
 83c:	e40c                	sd	a1,8(s0)
 83e:	e810                	sd	a2,16(s0)
 840:	ec14                	sd	a3,24(s0)
 842:	f018                	sd	a4,32(s0)
 844:	f41c                	sd	a5,40(s0)
 846:	03043823          	sd	a6,48(s0)
 84a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84e:	00840613          	addi	a2,s0,8
 852:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 856:	85aa                	mv	a1,a0
 858:	4505                	li	a0,1
 85a:	00000097          	auipc	ra,0x0
 85e:	dce080e7          	jalr	-562(ra) # 628 <vprintf>
}
 862:	60e2                	ld	ra,24(sp)
 864:	6442                	ld	s0,16(sp)
 866:	6125                	addi	sp,sp,96
 868:	8082                	ret

000000000000086a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 86a:	1141                	addi	sp,sp,-16
 86c:	e422                	sd	s0,8(sp)
 86e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 870:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 874:	00000797          	auipc	a5,0x0
 878:	28c7b783          	ld	a5,652(a5) # b00 <freep>
 87c:	a805                	j	8ac <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 87e:	4618                	lw	a4,8(a2)
 880:	9db9                	addw	a1,a1,a4
 882:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 886:	6398                	ld	a4,0(a5)
 888:	6318                	ld	a4,0(a4)
 88a:	fee53823          	sd	a4,-16(a0)
 88e:	a091                	j	8d2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 890:	ff852703          	lw	a4,-8(a0)
 894:	9e39                	addw	a2,a2,a4
 896:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 898:	ff053703          	ld	a4,-16(a0)
 89c:	e398                	sd	a4,0(a5)
 89e:	a099                	j	8e4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	6398                	ld	a4,0(a5)
 8a2:	00e7e463          	bltu	a5,a4,8aa <free+0x40>
 8a6:	00e6ea63          	bltu	a3,a4,8ba <free+0x50>
{
 8aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	fed7fae3          	bgeu	a5,a3,8a0 <free+0x36>
 8b0:	6398                	ld	a4,0(a5)
 8b2:	00e6e463          	bltu	a3,a4,8ba <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b6:	fee7eae3          	bltu	a5,a4,8aa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ba:	ff852583          	lw	a1,-8(a0)
 8be:	6390                	ld	a2,0(a5)
 8c0:	02059713          	slli	a4,a1,0x20
 8c4:	9301                	srli	a4,a4,0x20
 8c6:	0712                	slli	a4,a4,0x4
 8c8:	9736                	add	a4,a4,a3
 8ca:	fae60ae3          	beq	a2,a4,87e <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d2:	4790                	lw	a2,8(a5)
 8d4:	02061713          	slli	a4,a2,0x20
 8d8:	9301                	srli	a4,a4,0x20
 8da:	0712                	slli	a4,a4,0x4
 8dc:	973e                	add	a4,a4,a5
 8de:	fae689e3          	beq	a3,a4,890 <free+0x26>
  } else
    p->s.ptr = bp;
 8e2:	e394                	sd	a3,0(a5)
  freep = p;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	20f73e23          	sd	a5,540(a4) # b00 <freep>
}
 8ec:	6422                	ld	s0,8(sp)
 8ee:	0141                	addi	sp,sp,16
 8f0:	8082                	ret

00000000000008f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f2:	7139                	addi	sp,sp,-64
 8f4:	fc06                	sd	ra,56(sp)
 8f6:	f822                	sd	s0,48(sp)
 8f8:	f426                	sd	s1,40(sp)
 8fa:	f04a                	sd	s2,32(sp)
 8fc:	ec4e                	sd	s3,24(sp)
 8fe:	e852                	sd	s4,16(sp)
 900:	e456                	sd	s5,8(sp)
 902:	e05a                	sd	s6,0(sp)
 904:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 906:	02051493          	slli	s1,a0,0x20
 90a:	9081                	srli	s1,s1,0x20
 90c:	04bd                	addi	s1,s1,15
 90e:	8091                	srli	s1,s1,0x4
 910:	0014899b          	addiw	s3,s1,1
 914:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 916:	00000517          	auipc	a0,0x0
 91a:	1ea53503          	ld	a0,490(a0) # b00 <freep>
 91e:	c515                	beqz	a0,94a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	02977f63          	bgeu	a4,s1,962 <malloc+0x70>
 928:	8a4e                	mv	s4,s3
 92a:	0009871b          	sext.w	a4,s3
 92e:	6685                	lui	a3,0x1
 930:	00d77363          	bgeu	a4,a3,936 <malloc+0x44>
 934:	6a05                	lui	s4,0x1
 936:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 93e:	00000917          	auipc	s2,0x0
 942:	1c290913          	addi	s2,s2,450 # b00 <freep>
  if(p == (char*)-1)
 946:	5afd                	li	s5,-1
 948:	a88d                	j	9ba <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 94a:	00000797          	auipc	a5,0x0
 94e:	1be78793          	addi	a5,a5,446 # b08 <base>
 952:	00000717          	auipc	a4,0x0
 956:	1af73723          	sd	a5,430(a4) # b00 <freep>
 95a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 95c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 960:	b7e1                	j	928 <malloc+0x36>
      if(p->s.size == nunits)
 962:	02e48b63          	beq	s1,a4,998 <malloc+0xa6>
        p->s.size -= nunits;
 966:	4137073b          	subw	a4,a4,s3
 96a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 96c:	1702                	slli	a4,a4,0x20
 96e:	9301                	srli	a4,a4,0x20
 970:	0712                	slli	a4,a4,0x4
 972:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 974:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 978:	00000717          	auipc	a4,0x0
 97c:	18a73423          	sd	a0,392(a4) # b00 <freep>
      return (void*)(p + 1);
 980:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 984:	70e2                	ld	ra,56(sp)
 986:	7442                	ld	s0,48(sp)
 988:	74a2                	ld	s1,40(sp)
 98a:	7902                	ld	s2,32(sp)
 98c:	69e2                	ld	s3,24(sp)
 98e:	6a42                	ld	s4,16(sp)
 990:	6aa2                	ld	s5,8(sp)
 992:	6b02                	ld	s6,0(sp)
 994:	6121                	addi	sp,sp,64
 996:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 998:	6398                	ld	a4,0(a5)
 99a:	e118                	sd	a4,0(a0)
 99c:	bff1                	j	978 <malloc+0x86>
  hp->s.size = nu;
 99e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a2:	0541                	addi	a0,a0,16
 9a4:	00000097          	auipc	ra,0x0
 9a8:	ec6080e7          	jalr	-314(ra) # 86a <free>
  return freep;
 9ac:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b0:	d971                	beqz	a0,984 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b4:	4798                	lw	a4,8(a5)
 9b6:	fa9776e3          	bgeu	a4,s1,962 <malloc+0x70>
    if(p == freep)
 9ba:	00093703          	ld	a4,0(s2)
 9be:	853e                	mv	a0,a5
 9c0:	fef719e3          	bne	a4,a5,9b2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9c4:	8552                	mv	a0,s4
 9c6:	00000097          	auipc	ra,0x0
 9ca:	b6e080e7          	jalr	-1170(ra) # 534 <sbrk>
  if(p == (char*)-1)
 9ce:	fd5518e3          	bne	a0,s5,99e <malloc+0xac>
        return 0;
 9d2:	4501                	li	a0,0
 9d4:	bf45                	j	984 <malloc+0x92>

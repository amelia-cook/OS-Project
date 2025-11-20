
user/_specialtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testnull>:
  exit(failed);
}

void
testnull(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  int fd, r;
  static char buf[32] = { 'a', 'b', 'c', 0 };

  printf("\nSTART: test /dev/null\n");
   a:	00001517          	auipc	a0,0x1
   e:	e3e50513          	addi	a0,a0,-450 # e48 <malloc+0xea>
  12:	00001097          	auipc	ra,0x1
  16:	c8e080e7          	jalr	-882(ra) # ca0 <printf>

  fd = open("/dev/null", O_RDWR);
  1a:	4589                	li	a1,2
  1c:	00001517          	auipc	a0,0x1
  20:	e4450513          	addi	a0,a0,-444 # e60 <malloc+0x102>
  24:	00001097          	auipc	ra,0x1
  28:	934080e7          	jalr	-1740(ra) # 958 <open>
  2c:	84aa                	mv	s1,a0
  if (fd < 0)
  2e:	06054b63          	bltz	a0,a4 <testnull+0xa4>
    fail("could not open /dev/null\n");

  printf("reading from /dev/null..\n");
  32:	00001517          	auipc	a0,0x1
  36:	e6650513          	addi	a0,a0,-410 # e98 <malloc+0x13a>
  3a:	00001097          	auipc	ra,0x1
  3e:	c66080e7          	jalr	-922(ra) # ca0 <printf>
  r = read(fd, buf, sizeof(buf));
  42:	02000613          	li	a2,32
  46:	00001597          	auipc	a1,0x1
  4a:	36258593          	addi	a1,a1,866 # 13a8 <buf.0>
  4e:	8526                	mv	a0,s1
  50:	00001097          	auipc	ra,0x1
  54:	8e0080e7          	jalr	-1824(ra) # 930 <read>
  if (r != 0)
  58:	ed2d                	bnez	a0,d2 <testnull+0xd2>
    fail("read /dev/null did not return EOF\n");

  printf("writing to /dev/null..\n");
  5a:	00001517          	auipc	a0,0x1
  5e:	e8e50513          	addi	a0,a0,-370 # ee8 <malloc+0x18a>
  62:	00001097          	auipc	ra,0x1
  66:	c3e080e7          	jalr	-962(ra) # ca0 <printf>
  r = write(fd, buf, sizeof(buf));
  6a:	02000613          	li	a2,32
  6e:	00001597          	auipc	a1,0x1
  72:	33a58593          	addi	a1,a1,826 # 13a8 <buf.0>
  76:	8526                	mv	a0,s1
  78:	00001097          	auipc	ra,0x1
  7c:	8c0080e7          	jalr	-1856(ra) # 938 <write>
  if (r != sizeof(buf))
  80:	02000793          	li	a5,32
  84:	06f50563          	beq	a0,a5,ee <testnull+0xee>
    fail("could not write to /dev/null\n");
  88:	00001517          	auipc	a0,0x1
  8c:	e7850513          	addi	a0,a0,-392 # f00 <malloc+0x1a2>
  90:	00001097          	auipc	ra,0x1
  94:	c10080e7          	jalr	-1008(ra) # ca0 <printf>
  98:	4785                	li	a5,1
  9a:	00001717          	auipc	a4,0x1
  9e:	32f72723          	sw	a5,814(a4) # 13c8 <failed>
  a2:	a831                	j	be <testnull+0xbe>
    fail("could not open /dev/null\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	dcc50513          	addi	a0,a0,-564 # e70 <malloc+0x112>
  ac:	00001097          	auipc	ra,0x1
  b0:	bf4080e7          	jalr	-1036(ra) # ca0 <printf>
  b4:	4785                	li	a5,1
  b6:	00001717          	auipc	a4,0x1
  ba:	30f72923          	sw	a5,786(a4) # 13c8 <failed>
  if (buf[0] != 'a')
    fail("/dev/null read non-zero amount of bytes\n");

  printf("SUCCESS: test /dev/null\n");
done:
  close(fd);
  be:	8526                	mv	a0,s1
  c0:	00001097          	auipc	ra,0x1
  c4:	880080e7          	jalr	-1920(ra) # 940 <close>
}
  c8:	60e2                	ld	ra,24(sp)
  ca:	6442                	ld	s0,16(sp)
  cc:	64a2                	ld	s1,8(sp)
  ce:	6105                	addi	sp,sp,32
  d0:	8082                	ret
    fail("read /dev/null did not return EOF\n");
  d2:	00001517          	auipc	a0,0x1
  d6:	de650513          	addi	a0,a0,-538 # eb8 <malloc+0x15a>
  da:	00001097          	auipc	ra,0x1
  de:	bc6080e7          	jalr	-1082(ra) # ca0 <printf>
  e2:	4785                	li	a5,1
  e4:	00001717          	auipc	a4,0x1
  e8:	2ef72223          	sw	a5,740(a4) # 13c8 <failed>
  ec:	bfc9                	j	be <testnull+0xbe>
  printf("reading from /dev/null again..\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	e3a50513          	addi	a0,a0,-454 # f28 <malloc+0x1ca>
  f6:	00001097          	auipc	ra,0x1
  fa:	baa080e7          	jalr	-1110(ra) # ca0 <printf>
  r = read(fd, buf, sizeof(buf));
  fe:	02000613          	li	a2,32
 102:	00001597          	auipc	a1,0x1
 106:	2a658593          	addi	a1,a1,678 # 13a8 <buf.0>
 10a:	8526                	mv	a0,s1
 10c:	00001097          	auipc	ra,0x1
 110:	824080e7          	jalr	-2012(ra) # 930 <read>
  if (r != 0)
 114:	e51d                	bnez	a0,142 <testnull+0x142>
  if (buf[0] != 'a')
 116:	00001717          	auipc	a4,0x1
 11a:	29274703          	lbu	a4,658(a4) # 13a8 <buf.0>
 11e:	06100793          	li	a5,97
 122:	02f70e63          	beq	a4,a5,15e <testnull+0x15e>
    fail("/dev/null read non-zero amount of bytes\n");
 126:	00001517          	auipc	a0,0x1
 12a:	e5a50513          	addi	a0,a0,-422 # f80 <malloc+0x222>
 12e:	00001097          	auipc	ra,0x1
 132:	b72080e7          	jalr	-1166(ra) # ca0 <printf>
 136:	4785                	li	a5,1
 138:	00001717          	auipc	a4,0x1
 13c:	28f72823          	sw	a5,656(a4) # 13c8 <failed>
 140:	bfbd                	j	be <testnull+0xbe>
    fail("read /dev/null did not return EOF after write");
 142:	00001517          	auipc	a0,0x1
 146:	e0650513          	addi	a0,a0,-506 # f48 <malloc+0x1ea>
 14a:	00001097          	auipc	ra,0x1
 14e:	b56080e7          	jalr	-1194(ra) # ca0 <printf>
 152:	4785                	li	a5,1
 154:	00001717          	auipc	a4,0x1
 158:	26f72a23          	sw	a5,628(a4) # 13c8 <failed>
 15c:	b78d                	j	be <testnull+0xbe>
  printf("SUCCESS: test /dev/null\n");
 15e:	00001517          	auipc	a0,0x1
 162:	e5a50513          	addi	a0,a0,-422 # fb8 <malloc+0x25a>
 166:	00001097          	auipc	ra,0x1
 16a:	b3a080e7          	jalr	-1222(ra) # ca0 <printf>
 16e:	bf81                	j	be <testnull+0xbe>

0000000000000170 <testzero>:

void
testzero(void)
{
 170:	7179                	addi	sp,sp,-48
 172:	f406                	sd	ra,40(sp)
 174:	f022                	sd	s0,32(sp)
 176:	ec26                	sd	s1,24(sp)
 178:	1800                	addi	s0,sp,48
  int fd, r;
  char buf[8] = {'a','b','c','d','e','f','g','h'};
 17a:	00001797          	auipc	a5,0x1
 17e:	f8e7b783          	ld	a5,-114(a5) # 1108 <malloc+0x3aa>
 182:	fcf43c23          	sd	a5,-40(s0)

  printf("\nSTART: test /dev/zero\n");
 186:	00001517          	auipc	a0,0x1
 18a:	e5250513          	addi	a0,a0,-430 # fd8 <malloc+0x27a>
 18e:	00001097          	auipc	ra,0x1
 192:	b12080e7          	jalr	-1262(ra) # ca0 <printf>

  fd = open("/dev/zero", O_RDWR);
 196:	4589                	li	a1,2
 198:	00001517          	auipc	a0,0x1
 19c:	e5850513          	addi	a0,a0,-424 # ff0 <malloc+0x292>
 1a0:	00000097          	auipc	ra,0x0
 1a4:	7b8080e7          	jalr	1976(ra) # 958 <open>
 1a8:	84aa                	mv	s1,a0
  if (fd < 0)
 1aa:	04054c63          	bltz	a0,202 <testzero+0x92>
    fail("could not open /dev/zero");

  printf("writing to /dev/zero..\n");
 1ae:	00001517          	auipc	a0,0x1
 1b2:	e7a50513          	addi	a0,a0,-390 # 1028 <malloc+0x2ca>
 1b6:	00001097          	auipc	ra,0x1
 1ba:	aea080e7          	jalr	-1302(ra) # ca0 <printf>
  r = write(fd, buf, sizeof(buf));
 1be:	4621                	li	a2,8
 1c0:	fd840593          	addi	a1,s0,-40
 1c4:	8526                	mv	a0,s1
 1c6:	00000097          	auipc	ra,0x0
 1ca:	772080e7          	jalr	1906(ra) # 938 <write>
  if (r != sizeof(buf))
 1ce:	47a1                	li	a5,8
 1d0:	04f50763          	beq	a0,a5,21e <testzero+0xae>
    fail("could not write to /dev/zero");
 1d4:	00001517          	auipc	a0,0x1
 1d8:	e6c50513          	addi	a0,a0,-404 # 1040 <malloc+0x2e2>
 1dc:	00001097          	auipc	ra,0x1
 1e0:	ac4080e7          	jalr	-1340(ra) # ca0 <printf>
 1e4:	4785                	li	a5,1
 1e6:	00001717          	auipc	a4,0x1
 1ea:	1ef72123          	sw	a5,482(a4) # 13c8 <failed>
      fail("reading from /dev/zero produced non-zero bytes");
  }

  printf("SUCCESS: test /dev/zero\n");
done:
  close(fd);
 1ee:	8526                	mv	a0,s1
 1f0:	00000097          	auipc	ra,0x0
 1f4:	750080e7          	jalr	1872(ra) # 940 <close>
}
 1f8:	70a2                	ld	ra,40(sp)
 1fa:	7402                	ld	s0,32(sp)
 1fc:	64e2                	ld	s1,24(sp)
 1fe:	6145                	addi	sp,sp,48
 200:	8082                	ret
    fail("could not open /dev/zero");
 202:	00001517          	auipc	a0,0x1
 206:	dfe50513          	addi	a0,a0,-514 # 1000 <malloc+0x2a2>
 20a:	00001097          	auipc	ra,0x1
 20e:	a96080e7          	jalr	-1386(ra) # ca0 <printf>
 212:	4785                	li	a5,1
 214:	00001717          	auipc	a4,0x1
 218:	1af72a23          	sw	a5,436(a4) # 13c8 <failed>
 21c:	bfc9                	j	1ee <testzero+0x7e>
  printf("reading from /dev/zero..\n");
 21e:	00001517          	auipc	a0,0x1
 222:	e4a50513          	addi	a0,a0,-438 # 1068 <malloc+0x30a>
 226:	00001097          	auipc	ra,0x1
 22a:	a7a080e7          	jalr	-1414(ra) # ca0 <printf>
  r = read(fd, buf, sizeof(buf));
 22e:	4621                	li	a2,8
 230:	fd840593          	addi	a1,s0,-40
 234:	8526                	mv	a0,s1
 236:	00000097          	auipc	ra,0x0
 23a:	6fa080e7          	jalr	1786(ra) # 930 <read>
  if (r != 8)
 23e:	4721                	li	a4,8
 240:	fd840793          	addi	a5,s0,-40
 244:	fe040693          	addi	a3,s0,-32
 248:	02e51163          	bne	a0,a4,26a <testzero+0xfa>
    if (buf[i])
 24c:	0007c703          	lbu	a4,0(a5)
 250:	eb1d                	bnez	a4,286 <testzero+0x116>
  for(int i = 0; i < sizeof(buf); i++) {
 252:	0785                	addi	a5,a5,1
 254:	fed79ce3          	bne	a5,a3,24c <testzero+0xdc>
  printf("SUCCESS: test /dev/zero\n");
 258:	00001517          	auipc	a0,0x1
 25c:	e9050513          	addi	a0,a0,-368 # 10e8 <malloc+0x38a>
 260:	00001097          	auipc	ra,0x1
 264:	a40080e7          	jalr	-1472(ra) # ca0 <printf>
 268:	b759                	j	1ee <testzero+0x7e>
    fail("could not read from /dev/zero");
 26a:	00001517          	auipc	a0,0x1
 26e:	e1e50513          	addi	a0,a0,-482 # 1088 <malloc+0x32a>
 272:	00001097          	auipc	ra,0x1
 276:	a2e080e7          	jalr	-1490(ra) # ca0 <printf>
 27a:	4785                	li	a5,1
 27c:	00001717          	auipc	a4,0x1
 280:	14f72623          	sw	a5,332(a4) # 13c8 <failed>
 284:	b7ad                	j	1ee <testzero+0x7e>
      fail("reading from /dev/zero produced non-zero bytes");
 286:	00001517          	auipc	a0,0x1
 28a:	e2a50513          	addi	a0,a0,-470 # 10b0 <malloc+0x352>
 28e:	00001097          	auipc	ra,0x1
 292:	a12080e7          	jalr	-1518(ra) # ca0 <printf>
 296:	4785                	li	a5,1
 298:	00001717          	auipc	a4,0x1
 29c:	12f72823          	sw	a5,304(a4) # 13c8 <failed>
 2a0:	b7b9                	j	1ee <testzero+0x7e>

00000000000002a2 <testuptime>:

void
testuptime(void)
{
 2a2:	7139                	addi	sp,sp,-64
 2a4:	fc06                	sd	ra,56(sp)
 2a6:	f822                	sd	s0,48(sp)
 2a8:	f426                	sd	s1,40(sp)
 2aa:	f04a                	sd	s2,32(sp)
 2ac:	ec4e                	sd	s3,24(sp)
 2ae:	0080                	addi	s0,sp,64
  int fd, r, first, second;
  char buf[16] = { 0 };
 2b0:	fc043023          	sd	zero,-64(s0)
 2b4:	fc043423          	sd	zero,-56(s0)

  printf("\nSTART: test /dev/uptime\n");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	e6050513          	addi	a0,a0,-416 # 1118 <malloc+0x3ba>
 2c0:	00001097          	auipc	ra,0x1
 2c4:	9e0080e7          	jalr	-1568(ra) # ca0 <printf>

  fd = open("/dev/uptime", O_RDONLY);
 2c8:	4581                	li	a1,0
 2ca:	00001517          	auipc	a0,0x1
 2ce:	e6e50513          	addi	a0,a0,-402 # 1138 <malloc+0x3da>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	686080e7          	jalr	1670(ra) # 958 <open>
 2da:	84aa                	mv	s1,a0
  if (fd < 0)
 2dc:	0e054f63          	bltz	a0,3da <testuptime+0x138>
    fail("could not open /dev/uptime");

  printf("Reading from /dev/uptime..\n");
 2e0:	00001517          	auipc	a0,0x1
 2e4:	e9050513          	addi	a0,a0,-368 # 1170 <malloc+0x412>
 2e8:	00001097          	auipc	ra,0x1
 2ec:	9b8080e7          	jalr	-1608(ra) # ca0 <printf>
  r = read(fd, buf, sizeof(buf));
 2f0:	4641                	li	a2,16
 2f2:	fc040593          	addi	a1,s0,-64
 2f6:	8526                	mv	a0,s1
 2f8:	00000097          	auipc	ra,0x0
 2fc:	638080e7          	jalr	1592(ra) # 930 <read>
  if (r <= 0)
 300:	0ea05b63          	blez	a0,3f6 <testuptime+0x154>
    fail("could not read /dev/uptime");
  first = atoi(buf);
 304:	fc040513          	addi	a0,s0,-64
 308:	00000097          	auipc	ra,0x0
 30c:	514080e7          	jalr	1300(ra) # 81c <atoi>
 310:	892a                	mv	s2,a0
  memset(buf, 0, sizeof(buf));
 312:	4641                	li	a2,16
 314:	4581                	li	a1,0
 316:	fc040513          	addi	a0,s0,-64
 31a:	00000097          	auipc	ra,0x0
 31e:	402080e7          	jalr	1026(ra) # 71c <memset>

  sleep(2);
 322:	4509                	li	a0,2
 324:	00000097          	auipc	ra,0x0
 328:	684080e7          	jalr	1668(ra) # 9a8 <sleep>

  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	00000097          	auipc	ra,0x0
 332:	612080e7          	jalr	1554(ra) # 940 <close>
  fd = open("/dev/uptime", O_RDONLY);
 336:	4581                	li	a1,0
 338:	00001517          	auipc	a0,0x1
 33c:	e0050513          	addi	a0,a0,-512 # 1138 <malloc+0x3da>
 340:	00000097          	auipc	ra,0x0
 344:	618080e7          	jalr	1560(ra) # 958 <open>
 348:	84aa                	mv	s1,a0
  printf("Reading from /dev/uptime again..\n");
 34a:	00001517          	auipc	a0,0x1
 34e:	e6e50513          	addi	a0,a0,-402 # 11b8 <malloc+0x45a>
 352:	00001097          	auipc	ra,0x1
 356:	94e080e7          	jalr	-1714(ra) # ca0 <printf>
  r = read(fd, buf, sizeof(buf));
 35a:	4641                	li	a2,16
 35c:	fc040593          	addi	a1,s0,-64
 360:	8526                	mv	a0,s1
 362:	00000097          	auipc	ra,0x0
 366:	5ce080e7          	jalr	1486(ra) # 930 <read>
  if (r <= 0)
 36a:	0aa05463          	blez	a0,412 <testuptime+0x170>
    fail("could not read /dev/uptime");
  second = atoi(buf);
 36e:	fc040513          	addi	a0,s0,-64
 372:	00000097          	auipc	ra,0x0
 376:	4aa080e7          	jalr	1194(ra) # 81c <atoi>
 37a:	89aa                	mv	s3,a0

  if(first <= 0 || second <= 0 || second <= first || second - first > 50) {
 37c:	01205c63          	blez	s2,394 <testuptime+0xf2>
 380:	00a05a63          	blez	a0,394 <testuptime+0xf2>
 384:	00a95863          	bge	s2,a0,394 <testuptime+0xf2>
 388:	412507bb          	subw	a5,a0,s2
 38c:	03200713          	li	a4,50
 390:	08f75f63          	bge	a4,a5,42e <testuptime+0x18c>
    printf("expected two positive, monotonically increasing integers near each other\n");
 394:	00001517          	auipc	a0,0x1
 398:	e4c50513          	addi	a0,a0,-436 # 11e0 <malloc+0x482>
 39c:	00001097          	auipc	ra,0x1
 3a0:	904080e7          	jalr	-1788(ra) # ca0 <printf>
    printf("         got: %d %d\n", first, second);
 3a4:	864e                	mv	a2,s3
 3a6:	85ca                	mv	a1,s2
 3a8:	00001517          	auipc	a0,0x1
 3ac:	e8850513          	addi	a0,a0,-376 # 1230 <malloc+0x4d2>
 3b0:	00001097          	auipc	ra,0x1
 3b4:	8f0080e7          	jalr	-1808(ra) # ca0 <printf>
    failed = 1;
 3b8:	4785                	li	a5,1
 3ba:	00001717          	auipc	a4,0x1
 3be:	00f72723          	sw	a5,14(a4) # 13c8 <failed>
    goto done;
  }

  printf("SUCCESS: test /dev/uptime\n");
done:
  close(fd);
 3c2:	8526                	mv	a0,s1
 3c4:	00000097          	auipc	ra,0x0
 3c8:	57c080e7          	jalr	1404(ra) # 940 <close>
}
 3cc:	70e2                	ld	ra,56(sp)
 3ce:	7442                	ld	s0,48(sp)
 3d0:	74a2                	ld	s1,40(sp)
 3d2:	7902                	ld	s2,32(sp)
 3d4:	69e2                	ld	s3,24(sp)
 3d6:	6121                	addi	sp,sp,64
 3d8:	8082                	ret
    fail("could not open /dev/uptime");
 3da:	00001517          	auipc	a0,0x1
 3de:	d6e50513          	addi	a0,a0,-658 # 1148 <malloc+0x3ea>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	8be080e7          	jalr	-1858(ra) # ca0 <printf>
 3ea:	4785                	li	a5,1
 3ec:	00001717          	auipc	a4,0x1
 3f0:	fcf72e23          	sw	a5,-36(a4) # 13c8 <failed>
 3f4:	b7f9                	j	3c2 <testuptime+0x120>
    fail("could not read /dev/uptime");
 3f6:	00001517          	auipc	a0,0x1
 3fa:	d9a50513          	addi	a0,a0,-614 # 1190 <malloc+0x432>
 3fe:	00001097          	auipc	ra,0x1
 402:	8a2080e7          	jalr	-1886(ra) # ca0 <printf>
 406:	4785                	li	a5,1
 408:	00001717          	auipc	a4,0x1
 40c:	fcf72023          	sw	a5,-64(a4) # 13c8 <failed>
 410:	bf4d                	j	3c2 <testuptime+0x120>
    fail("could not read /dev/uptime");
 412:	00001517          	auipc	a0,0x1
 416:	d7e50513          	addi	a0,a0,-642 # 1190 <malloc+0x432>
 41a:	00001097          	auipc	ra,0x1
 41e:	886080e7          	jalr	-1914(ra) # ca0 <printf>
 422:	4785                	li	a5,1
 424:	00001717          	auipc	a4,0x1
 428:	faf72223          	sw	a5,-92(a4) # 13c8 <failed>
 42c:	bf59                	j	3c2 <testuptime+0x120>
  printf("SUCCESS: test /dev/uptime\n");
 42e:	00001517          	auipc	a0,0x1
 432:	e1a50513          	addi	a0,a0,-486 # 1248 <malloc+0x4ea>
 436:	00001097          	auipc	ra,0x1
 43a:	86a080e7          	jalr	-1942(ra) # ca0 <printf>
 43e:	b751                	j	3c2 <testuptime+0x120>

0000000000000440 <testrandom>:

void
testrandom(void)
{
 440:	7139                	addi	sp,sp,-64
 442:	fc06                	sd	ra,56(sp)
 444:	f822                	sd	s0,48(sp)
 446:	f426                	sd	s1,40(sp)
 448:	f04a                	sd	s2,32(sp)
 44a:	0080                	addi	s0,sp,64
  int r = 0, fd1 = -1, fd2 = -1;
  char buf1[8], buf2[8], buf3[8], buf4[8];

  printf("\nSTART: test /dev/random\n");
 44c:	00001517          	auipc	a0,0x1
 450:	e1c50513          	addi	a0,a0,-484 # 1268 <malloc+0x50a>
 454:	00001097          	auipc	ra,0x1
 458:	84c080e7          	jalr	-1972(ra) # ca0 <printf>

  printf("Opening /dev/random..\n");
 45c:	00001517          	auipc	a0,0x1
 460:	e2c50513          	addi	a0,a0,-468 # 1288 <malloc+0x52a>
 464:	00001097          	auipc	ra,0x1
 468:	83c080e7          	jalr	-1988(ra) # ca0 <printf>
  fd1 = open("/dev/random", O_RDONLY);
 46c:	4581                	li	a1,0
 46e:	00001517          	auipc	a0,0x1
 472:	e3250513          	addi	a0,a0,-462 # 12a0 <malloc+0x542>
 476:	00000097          	auipc	ra,0x0
 47a:	4e2080e7          	jalr	1250(ra) # 958 <open>
 47e:	84aa                	mv	s1,a0
  if(fd1 < 0)
 480:	06054e63          	bltz	a0,4fc <testrandom+0xbc>
    fail("Failed to open /dev/random");
  fd2 = open("/dev/random", O_RDONLY);
 484:	4581                	li	a1,0
 486:	00001517          	auipc	a0,0x1
 48a:	e1a50513          	addi	a0,a0,-486 # 12a0 <malloc+0x542>
 48e:	00000097          	auipc	ra,0x0
 492:	4ca080e7          	jalr	1226(ra) # 958 <open>
 496:	892a                	mv	s2,a0
  if (fd2 < 0)
 498:	08054163          	bltz	a0,51a <testrandom+0xda>
    fail("Failed to open /dev/random");


  printf("reading from /dev/random four times..\n");
 49c:	00001517          	auipc	a0,0x1
 4a0:	e3c50513          	addi	a0,a0,-452 # 12d8 <malloc+0x57a>
 4a4:	00000097          	auipc	ra,0x0
 4a8:	7fc080e7          	jalr	2044(ra) # ca0 <printf>
  r = read(fd1, buf1, sizeof(buf1));
 4ac:	4621                	li	a2,8
 4ae:	fd840593          	addi	a1,s0,-40
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	47c080e7          	jalr	1148(ra) # 930 <read>
  if (r != sizeof(buf1)) fail("Failed to read /dev/random");
 4bc:	47a1                	li	a5,8
 4be:	06f50c63          	beq	a0,a5,536 <testrandom+0xf6>
 4c2:	00001517          	auipc	a0,0x1
 4c6:	e3e50513          	addi	a0,a0,-450 # 1300 <malloc+0x5a2>
 4ca:	00000097          	auipc	ra,0x0
 4ce:	7d6080e7          	jalr	2006(ra) # ca0 <printf>
 4d2:	4785                	li	a5,1
 4d4:	00001717          	auipc	a4,0x1
 4d8:	eef72a23          	sw	a5,-268(a4) # 13c8 <failed>
  if(!r)
    fail("Reads of /dev/random should return random bytes..");

  printf("SUCCESS: test /dev/random\n");
done:
  close(fd1);
 4dc:	8526                	mv	a0,s1
 4de:	00000097          	auipc	ra,0x0
 4e2:	462080e7          	jalr	1122(ra) # 940 <close>
  close(fd2);
 4e6:	854a                	mv	a0,s2
 4e8:	00000097          	auipc	ra,0x0
 4ec:	458080e7          	jalr	1112(ra) # 940 <close>
 4f0:	70e2                	ld	ra,56(sp)
 4f2:	7442                	ld	s0,48(sp)
 4f4:	74a2                	ld	s1,40(sp)
 4f6:	7902                	ld	s2,32(sp)
 4f8:	6121                	addi	sp,sp,64
 4fa:	8082                	ret
    fail("Failed to open /dev/random");
 4fc:	00001517          	auipc	a0,0x1
 500:	db450513          	addi	a0,a0,-588 # 12b0 <malloc+0x552>
 504:	00000097          	auipc	ra,0x0
 508:	79c080e7          	jalr	1948(ra) # ca0 <printf>
 50c:	4785                	li	a5,1
 50e:	00001717          	auipc	a4,0x1
 512:	eaf72d23          	sw	a5,-326(a4) # 13c8 <failed>
  int r = 0, fd1 = -1, fd2 = -1;
 516:	597d                	li	s2,-1
    fail("Failed to open /dev/random");
 518:	b7d1                	j	4dc <testrandom+0x9c>
    fail("Failed to open /dev/random");
 51a:	00001517          	auipc	a0,0x1
 51e:	d9650513          	addi	a0,a0,-618 # 12b0 <malloc+0x552>
 522:	00000097          	auipc	ra,0x0
 526:	77e080e7          	jalr	1918(ra) # ca0 <printf>
 52a:	4785                	li	a5,1
 52c:	00001717          	auipc	a4,0x1
 530:	e8f72e23          	sw	a5,-356(a4) # 13c8 <failed>
 534:	b765                	j	4dc <testrandom+0x9c>
  r = read(fd1, buf2, sizeof(buf2));
 536:	4621                	li	a2,8
 538:	fd040593          	addi	a1,s0,-48
 53c:	8526                	mv	a0,s1
 53e:	00000097          	auipc	ra,0x0
 542:	3f2080e7          	jalr	1010(ra) # 930 <read>
  if (r != sizeof(buf2)) fail("Failed to read /dev/random");
 546:	47a1                	li	a5,8
 548:	02f50063          	beq	a0,a5,568 <testrandom+0x128>
 54c:	00001517          	auipc	a0,0x1
 550:	db450513          	addi	a0,a0,-588 # 1300 <malloc+0x5a2>
 554:	00000097          	auipc	ra,0x0
 558:	74c080e7          	jalr	1868(ra) # ca0 <printf>
 55c:	4785                	li	a5,1
 55e:	00001717          	auipc	a4,0x1
 562:	e6f72523          	sw	a5,-406(a4) # 13c8 <failed>
 566:	bf9d                	j	4dc <testrandom+0x9c>
  r = read(fd2, buf3, sizeof(buf3));
 568:	4621                	li	a2,8
 56a:	fc840593          	addi	a1,s0,-56
 56e:	854a                	mv	a0,s2
 570:	00000097          	auipc	ra,0x0
 574:	3c0080e7          	jalr	960(ra) # 930 <read>
  if (r != sizeof(buf3)) fail("Failed to read /dev/random");
 578:	47a1                	li	a5,8
 57a:	02f50063          	beq	a0,a5,59a <testrandom+0x15a>
 57e:	00001517          	auipc	a0,0x1
 582:	d8250513          	addi	a0,a0,-638 # 1300 <malloc+0x5a2>
 586:	00000097          	auipc	ra,0x0
 58a:	71a080e7          	jalr	1818(ra) # ca0 <printf>
 58e:	4785                	li	a5,1
 590:	00001717          	auipc	a4,0x1
 594:	e2f72c23          	sw	a5,-456(a4) # 13c8 <failed>
 598:	b791                	j	4dc <testrandom+0x9c>
  r = read(fd2, buf4, sizeof(buf4));
 59a:	4621                	li	a2,8
 59c:	fc040593          	addi	a1,s0,-64
 5a0:	854a                	mv	a0,s2
 5a2:	00000097          	auipc	ra,0x0
 5a6:	38e080e7          	jalr	910(ra) # 930 <read>
  if (r != sizeof(buf4)) fail("Failed to read /dev/random");
 5aa:	47a1                	li	a5,8
 5ac:	02f50063          	beq	a0,a5,5cc <testrandom+0x18c>
 5b0:	00001517          	auipc	a0,0x1
 5b4:	d5050513          	addi	a0,a0,-688 # 1300 <malloc+0x5a2>
 5b8:	00000097          	auipc	ra,0x0
 5bc:	6e8080e7          	jalr	1768(ra) # ca0 <printf>
 5c0:	4785                	li	a5,1
 5c2:	00001717          	auipc	a4,0x1
 5c6:	e0f72323          	sw	a5,-506(a4) # 13c8 <failed>
 5ca:	bf09                	j	4dc <testrandom+0x9c>
  r = memcmp(buf1, buf2, 8) &&
 5cc:	4621                	li	a2,8
 5ce:	fd040593          	addi	a1,s0,-48
 5d2:	fd840513          	addi	a0,s0,-40
 5d6:	00000097          	auipc	ra,0x0
 5da:	2e8080e7          	jalr	744(ra) # 8be <memcmp>
      memcmp(buf2, buf4, 8) &&
 5de:	c919                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf1, buf3, 8) &&
 5e0:	4621                	li	a2,8
 5e2:	fc840593          	addi	a1,s0,-56
 5e6:	fd840513          	addi	a0,s0,-40
 5ea:	00000097          	auipc	ra,0x0
 5ee:	2d4080e7          	jalr	724(ra) # 8be <memcmp>
  r = memcmp(buf1, buf2, 8) &&
 5f2:	ed19                	bnez	a0,610 <testrandom+0x1d0>
    fail("Reads of /dev/random should return random bytes..");
 5f4:	00001517          	auipc	a0,0x1
 5f8:	d5450513          	addi	a0,a0,-684 # 1348 <malloc+0x5ea>
 5fc:	00000097          	auipc	ra,0x0
 600:	6a4080e7          	jalr	1700(ra) # ca0 <printf>
 604:	4785                	li	a5,1
 606:	00001717          	auipc	a4,0x1
 60a:	dcf72123          	sw	a5,-574(a4) # 13c8 <failed>
 60e:	b5f9                	j	4dc <testrandom+0x9c>
      memcmp(buf1, buf4, 8) &&
 610:	4621                	li	a2,8
 612:	fc040593          	addi	a1,s0,-64
 616:	fd840513          	addi	a0,s0,-40
 61a:	00000097          	auipc	ra,0x0
 61e:	2a4080e7          	jalr	676(ra) # 8be <memcmp>
      memcmp(buf1, buf3, 8) &&
 622:	d969                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf2, buf3, 8) &&
 624:	4621                	li	a2,8
 626:	fc840593          	addi	a1,s0,-56
 62a:	fd040513          	addi	a0,s0,-48
 62e:	00000097          	auipc	ra,0x0
 632:	290080e7          	jalr	656(ra) # 8be <memcmp>
      memcmp(buf1, buf4, 8) &&
 636:	dd5d                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf2, buf4, 8) &&
 638:	4621                	li	a2,8
 63a:	fc040593          	addi	a1,s0,-64
 63e:	fd040513          	addi	a0,s0,-48
 642:	00000097          	auipc	ra,0x0
 646:	27c080e7          	jalr	636(ra) # 8be <memcmp>
      memcmp(buf2, buf3, 8) &&
 64a:	d54d                	beqz	a0,5f4 <testrandom+0x1b4>
      memcmp(buf3, buf4, 8);
 64c:	4621                	li	a2,8
 64e:	fc040593          	addi	a1,s0,-64
 652:	fc840513          	addi	a0,s0,-56
 656:	00000097          	auipc	ra,0x0
 65a:	268080e7          	jalr	616(ra) # 8be <memcmp>
      memcmp(buf2, buf4, 8) &&
 65e:	d959                	beqz	a0,5f4 <testrandom+0x1b4>
  printf("SUCCESS: test /dev/random\n");
 660:	00001517          	auipc	a0,0x1
 664:	cc850513          	addi	a0,a0,-824 # 1328 <malloc+0x5ca>
 668:	00000097          	auipc	ra,0x0
 66c:	638080e7          	jalr	1592(ra) # ca0 <printf>
 670:	b5b5                	j	4dc <testrandom+0x9c>

0000000000000672 <main>:
{
 672:	1141                	addi	sp,sp,-16
 674:	e406                	sd	ra,8(sp)
 676:	e022                	sd	s0,0(sp)
 678:	0800                	addi	s0,sp,16
  testnull();
 67a:	00000097          	auipc	ra,0x0
 67e:	986080e7          	jalr	-1658(ra) # 0 <testnull>
  testzero();
 682:	00000097          	auipc	ra,0x0
 686:	aee080e7          	jalr	-1298(ra) # 170 <testzero>
  testuptime();
 68a:	00000097          	auipc	ra,0x0
 68e:	c18080e7          	jalr	-1000(ra) # 2a2 <testuptime>
  testrandom();
 692:	00000097          	auipc	ra,0x0
 696:	dae080e7          	jalr	-594(ra) # 440 <testrandom>
  exit(failed);
 69a:	00001517          	auipc	a0,0x1
 69e:	d2e52503          	lw	a0,-722(a0) # 13c8 <failed>
 6a2:	00000097          	auipc	ra,0x0
 6a6:	276080e7          	jalr	630(ra) # 918 <exit>

00000000000006aa <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 6aa:	1141                	addi	sp,sp,-16
 6ac:	e422                	sd	s0,8(sp)
 6ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 6b0:	87aa                	mv	a5,a0
 6b2:	0585                	addi	a1,a1,1
 6b4:	0785                	addi	a5,a5,1
 6b6:	fff5c703          	lbu	a4,-1(a1)
 6ba:	fee78fa3          	sb	a4,-1(a5)
 6be:	fb75                	bnez	a4,6b2 <strcpy+0x8>
    ;
  return os;
}
 6c0:	6422                	ld	s0,8(sp)
 6c2:	0141                	addi	sp,sp,16
 6c4:	8082                	ret

00000000000006c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e422                	sd	s0,8(sp)
 6ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 6cc:	00054783          	lbu	a5,0(a0)
 6d0:	cb91                	beqz	a5,6e4 <strcmp+0x1e>
 6d2:	0005c703          	lbu	a4,0(a1)
 6d6:	00f71763          	bne	a4,a5,6e4 <strcmp+0x1e>
    p++, q++;
 6da:	0505                	addi	a0,a0,1
 6dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6de:	00054783          	lbu	a5,0(a0)
 6e2:	fbe5                	bnez	a5,6d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6e4:	0005c503          	lbu	a0,0(a1)
}
 6e8:	40a7853b          	subw	a0,a5,a0
 6ec:	6422                	ld	s0,8(sp)
 6ee:	0141                	addi	sp,sp,16
 6f0:	8082                	ret

00000000000006f2 <strlen>:

uint
strlen(const char *s)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6f8:	00054783          	lbu	a5,0(a0)
 6fc:	cf91                	beqz	a5,718 <strlen+0x26>
 6fe:	0505                	addi	a0,a0,1
 700:	87aa                	mv	a5,a0
 702:	4685                	li	a3,1
 704:	9e89                	subw	a3,a3,a0
 706:	00f6853b          	addw	a0,a3,a5
 70a:	0785                	addi	a5,a5,1
 70c:	fff7c703          	lbu	a4,-1(a5)
 710:	fb7d                	bnez	a4,706 <strlen+0x14>
    ;
  return n;
}
 712:	6422                	ld	s0,8(sp)
 714:	0141                	addi	sp,sp,16
 716:	8082                	ret
  for(n = 0; s[n]; n++)
 718:	4501                	li	a0,0
 71a:	bfe5                	j	712 <strlen+0x20>

000000000000071c <memset>:

void*
memset(void *dst, int c, uint n)
{
 71c:	1141                	addi	sp,sp,-16
 71e:	e422                	sd	s0,8(sp)
 720:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 722:	ca19                	beqz	a2,738 <memset+0x1c>
 724:	87aa                	mv	a5,a0
 726:	1602                	slli	a2,a2,0x20
 728:	9201                	srli	a2,a2,0x20
 72a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 72e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 732:	0785                	addi	a5,a5,1
 734:	fee79de3          	bne	a5,a4,72e <memset+0x12>
  }
  return dst;
}
 738:	6422                	ld	s0,8(sp)
 73a:	0141                	addi	sp,sp,16
 73c:	8082                	ret

000000000000073e <strchr>:

char*
strchr(const char *s, char c)
{
 73e:	1141                	addi	sp,sp,-16
 740:	e422                	sd	s0,8(sp)
 742:	0800                	addi	s0,sp,16
  for(; *s; s++)
 744:	00054783          	lbu	a5,0(a0)
 748:	cb99                	beqz	a5,75e <strchr+0x20>
    if(*s == c)
 74a:	00f58763          	beq	a1,a5,758 <strchr+0x1a>
  for(; *s; s++)
 74e:	0505                	addi	a0,a0,1
 750:	00054783          	lbu	a5,0(a0)
 754:	fbfd                	bnez	a5,74a <strchr+0xc>
      return (char*)s;
  return 0;
 756:	4501                	li	a0,0
}
 758:	6422                	ld	s0,8(sp)
 75a:	0141                	addi	sp,sp,16
 75c:	8082                	ret
  return 0;
 75e:	4501                	li	a0,0
 760:	bfe5                	j	758 <strchr+0x1a>

0000000000000762 <gets>:

char*
gets(char *buf, int max)
{
 762:	711d                	addi	sp,sp,-96
 764:	ec86                	sd	ra,88(sp)
 766:	e8a2                	sd	s0,80(sp)
 768:	e4a6                	sd	s1,72(sp)
 76a:	e0ca                	sd	s2,64(sp)
 76c:	fc4e                	sd	s3,56(sp)
 76e:	f852                	sd	s4,48(sp)
 770:	f456                	sd	s5,40(sp)
 772:	f05a                	sd	s6,32(sp)
 774:	ec5e                	sd	s7,24(sp)
 776:	1080                	addi	s0,sp,96
 778:	8baa                	mv	s7,a0
 77a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 77c:	892a                	mv	s2,a0
 77e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 780:	4aa9                	li	s5,10
 782:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 784:	89a6                	mv	s3,s1
 786:	2485                	addiw	s1,s1,1
 788:	0344d863          	bge	s1,s4,7b8 <gets+0x56>
    cc = read(0, &c, 1);
 78c:	4605                	li	a2,1
 78e:	faf40593          	addi	a1,s0,-81
 792:	4501                	li	a0,0
 794:	00000097          	auipc	ra,0x0
 798:	19c080e7          	jalr	412(ra) # 930 <read>
    if(cc < 1)
 79c:	00a05e63          	blez	a0,7b8 <gets+0x56>
    buf[i++] = c;
 7a0:	faf44783          	lbu	a5,-81(s0)
 7a4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 7a8:	01578763          	beq	a5,s5,7b6 <gets+0x54>
 7ac:	0905                	addi	s2,s2,1
 7ae:	fd679be3          	bne	a5,s6,784 <gets+0x22>
  for(i=0; i+1 < max; ){
 7b2:	89a6                	mv	s3,s1
 7b4:	a011                	j	7b8 <gets+0x56>
 7b6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 7b8:	99de                	add	s3,s3,s7
 7ba:	00098023          	sb	zero,0(s3)
  return buf;
}
 7be:	855e                	mv	a0,s7
 7c0:	60e6                	ld	ra,88(sp)
 7c2:	6446                	ld	s0,80(sp)
 7c4:	64a6                	ld	s1,72(sp)
 7c6:	6906                	ld	s2,64(sp)
 7c8:	79e2                	ld	s3,56(sp)
 7ca:	7a42                	ld	s4,48(sp)
 7cc:	7aa2                	ld	s5,40(sp)
 7ce:	7b02                	ld	s6,32(sp)
 7d0:	6be2                	ld	s7,24(sp)
 7d2:	6125                	addi	sp,sp,96
 7d4:	8082                	ret

00000000000007d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 7d6:	1101                	addi	sp,sp,-32
 7d8:	ec06                	sd	ra,24(sp)
 7da:	e822                	sd	s0,16(sp)
 7dc:	e426                	sd	s1,8(sp)
 7de:	e04a                	sd	s2,0(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7e4:	4581                	li	a1,0
 7e6:	00000097          	auipc	ra,0x0
 7ea:	172080e7          	jalr	370(ra) # 958 <open>
  if(fd < 0)
 7ee:	02054563          	bltz	a0,818 <stat+0x42>
 7f2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7f4:	85ca                	mv	a1,s2
 7f6:	00000097          	auipc	ra,0x0
 7fa:	17a080e7          	jalr	378(ra) # 970 <fstat>
 7fe:	892a                	mv	s2,a0
  close(fd);
 800:	8526                	mv	a0,s1
 802:	00000097          	auipc	ra,0x0
 806:	13e080e7          	jalr	318(ra) # 940 <close>
  return r;
}
 80a:	854a                	mv	a0,s2
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	64a2                	ld	s1,8(sp)
 812:	6902                	ld	s2,0(sp)
 814:	6105                	addi	sp,sp,32
 816:	8082                	ret
    return -1;
 818:	597d                	li	s2,-1
 81a:	bfc5                	j	80a <stat+0x34>

000000000000081c <atoi>:

int
atoi(const char *s)
{
 81c:	1141                	addi	sp,sp,-16
 81e:	e422                	sd	s0,8(sp)
 820:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 822:	00054603          	lbu	a2,0(a0)
 826:	fd06079b          	addiw	a5,a2,-48
 82a:	0ff7f793          	andi	a5,a5,255
 82e:	4725                	li	a4,9
 830:	02f76963          	bltu	a4,a5,862 <atoi+0x46>
 834:	86aa                	mv	a3,a0
  n = 0;
 836:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 838:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 83a:	0685                	addi	a3,a3,1
 83c:	0025179b          	slliw	a5,a0,0x2
 840:	9fa9                	addw	a5,a5,a0
 842:	0017979b          	slliw	a5,a5,0x1
 846:	9fb1                	addw	a5,a5,a2
 848:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 84c:	0006c603          	lbu	a2,0(a3)
 850:	fd06071b          	addiw	a4,a2,-48
 854:	0ff77713          	andi	a4,a4,255
 858:	fee5f1e3          	bgeu	a1,a4,83a <atoi+0x1e>
  return n;
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret
  n = 0;
 862:	4501                	li	a0,0
 864:	bfe5                	j	85c <atoi+0x40>

0000000000000866 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 866:	1141                	addi	sp,sp,-16
 868:	e422                	sd	s0,8(sp)
 86a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 86c:	02b57463          	bgeu	a0,a1,894 <memmove+0x2e>
    while(n-- > 0)
 870:	00c05f63          	blez	a2,88e <memmove+0x28>
 874:	1602                	slli	a2,a2,0x20
 876:	9201                	srli	a2,a2,0x20
 878:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 87c:	872a                	mv	a4,a0
      *dst++ = *src++;
 87e:	0585                	addi	a1,a1,1
 880:	0705                	addi	a4,a4,1
 882:	fff5c683          	lbu	a3,-1(a1)
 886:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 88a:	fee79ae3          	bne	a5,a4,87e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 88e:	6422                	ld	s0,8(sp)
 890:	0141                	addi	sp,sp,16
 892:	8082                	ret
    dst += n;
 894:	00c50733          	add	a4,a0,a2
    src += n;
 898:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 89a:	fec05ae3          	blez	a2,88e <memmove+0x28>
 89e:	fff6079b          	addiw	a5,a2,-1
 8a2:	1782                	slli	a5,a5,0x20
 8a4:	9381                	srli	a5,a5,0x20
 8a6:	fff7c793          	not	a5,a5
 8aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 8ac:	15fd                	addi	a1,a1,-1
 8ae:	177d                	addi	a4,a4,-1
 8b0:	0005c683          	lbu	a3,0(a1)
 8b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 8b8:	fee79ae3          	bne	a5,a4,8ac <memmove+0x46>
 8bc:	bfc9                	j	88e <memmove+0x28>

00000000000008be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 8be:	1141                	addi	sp,sp,-16
 8c0:	e422                	sd	s0,8(sp)
 8c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 8c4:	ca05                	beqz	a2,8f4 <memcmp+0x36>
 8c6:	fff6069b          	addiw	a3,a2,-1
 8ca:	1682                	slli	a3,a3,0x20
 8cc:	9281                	srli	a3,a3,0x20
 8ce:	0685                	addi	a3,a3,1
 8d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8d2:	00054783          	lbu	a5,0(a0)
 8d6:	0005c703          	lbu	a4,0(a1)
 8da:	00e79863          	bne	a5,a4,8ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8de:	0505                	addi	a0,a0,1
    p2++;
 8e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8e2:	fed518e3          	bne	a0,a3,8d2 <memcmp+0x14>
  }
  return 0;
 8e6:	4501                	li	a0,0
 8e8:	a019                	j	8ee <memcmp+0x30>
      return *p1 - *p2;
 8ea:	40e7853b          	subw	a0,a5,a4
}
 8ee:	6422                	ld	s0,8(sp)
 8f0:	0141                	addi	sp,sp,16
 8f2:	8082                	ret
  return 0;
 8f4:	4501                	li	a0,0
 8f6:	bfe5                	j	8ee <memcmp+0x30>

00000000000008f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8f8:	1141                	addi	sp,sp,-16
 8fa:	e406                	sd	ra,8(sp)
 8fc:	e022                	sd	s0,0(sp)
 8fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 900:	00000097          	auipc	ra,0x0
 904:	f66080e7          	jalr	-154(ra) # 866 <memmove>
}
 908:	60a2                	ld	ra,8(sp)
 90a:	6402                	ld	s0,0(sp)
 90c:	0141                	addi	sp,sp,16
 90e:	8082                	ret

0000000000000910 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 910:	4885                	li	a7,1
 ecall
 912:	00000073          	ecall
 ret
 916:	8082                	ret

0000000000000918 <exit>:
.global exit
exit:
 li a7, SYS_exit
 918:	4889                	li	a7,2
 ecall
 91a:	00000073          	ecall
 ret
 91e:	8082                	ret

0000000000000920 <wait>:
.global wait
wait:
 li a7, SYS_wait
 920:	488d                	li	a7,3
 ecall
 922:	00000073          	ecall
 ret
 926:	8082                	ret

0000000000000928 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 928:	4891                	li	a7,4
 ecall
 92a:	00000073          	ecall
 ret
 92e:	8082                	ret

0000000000000930 <read>:
.global read
read:
 li a7, SYS_read
 930:	4895                	li	a7,5
 ecall
 932:	00000073          	ecall
 ret
 936:	8082                	ret

0000000000000938 <write>:
.global write
write:
 li a7, SYS_write
 938:	48c1                	li	a7,16
 ecall
 93a:	00000073          	ecall
 ret
 93e:	8082                	ret

0000000000000940 <close>:
.global close
close:
 li a7, SYS_close
 940:	48d5                	li	a7,21
 ecall
 942:	00000073          	ecall
 ret
 946:	8082                	ret

0000000000000948 <kill>:
.global kill
kill:
 li a7, SYS_kill
 948:	4899                	li	a7,6
 ecall
 94a:	00000073          	ecall
 ret
 94e:	8082                	ret

0000000000000950 <exec>:
.global exec
exec:
 li a7, SYS_exec
 950:	489d                	li	a7,7
 ecall
 952:	00000073          	ecall
 ret
 956:	8082                	ret

0000000000000958 <open>:
.global open
open:
 li a7, SYS_open
 958:	48bd                	li	a7,15
 ecall
 95a:	00000073          	ecall
 ret
 95e:	8082                	ret

0000000000000960 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 960:	48c5                	li	a7,17
 ecall
 962:	00000073          	ecall
 ret
 966:	8082                	ret

0000000000000968 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 968:	48c9                	li	a7,18
 ecall
 96a:	00000073          	ecall
 ret
 96e:	8082                	ret

0000000000000970 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 970:	48a1                	li	a7,8
 ecall
 972:	00000073          	ecall
 ret
 976:	8082                	ret

0000000000000978 <link>:
.global link
link:
 li a7, SYS_link
 978:	48cd                	li	a7,19
 ecall
 97a:	00000073          	ecall
 ret
 97e:	8082                	ret

0000000000000980 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 980:	48d1                	li	a7,20
 ecall
 982:	00000073          	ecall
 ret
 986:	8082                	ret

0000000000000988 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 988:	48a5                	li	a7,9
 ecall
 98a:	00000073          	ecall
 ret
 98e:	8082                	ret

0000000000000990 <dup>:
.global dup
dup:
 li a7, SYS_dup
 990:	48a9                	li	a7,10
 ecall
 992:	00000073          	ecall
 ret
 996:	8082                	ret

0000000000000998 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 998:	48ad                	li	a7,11
 ecall
 99a:	00000073          	ecall
 ret
 99e:	8082                	ret

00000000000009a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 9a0:	48b1                	li	a7,12
 ecall
 9a2:	00000073          	ecall
 ret
 9a6:	8082                	ret

00000000000009a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 9a8:	48b5                	li	a7,13
 ecall
 9aa:	00000073          	ecall
 ret
 9ae:	8082                	ret

00000000000009b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 9b0:	48b9                	li	a7,14
 ecall
 9b2:	00000073          	ecall
 ret
 9b6:	8082                	ret

00000000000009b8 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 9b8:	48d9                	li	a7,22
 ecall
 9ba:	00000073          	ecall
 ret
 9be:	8082                	ret

00000000000009c0 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 9c0:	48dd                	li	a7,23
 ecall
 9c2:	00000073          	ecall
 ret
 9c6:	8082                	ret

00000000000009c8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9c8:	1101                	addi	sp,sp,-32
 9ca:	ec06                	sd	ra,24(sp)
 9cc:	e822                	sd	s0,16(sp)
 9ce:	1000                	addi	s0,sp,32
 9d0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9d4:	4605                	li	a2,1
 9d6:	fef40593          	addi	a1,s0,-17
 9da:	00000097          	auipc	ra,0x0
 9de:	f5e080e7          	jalr	-162(ra) # 938 <write>
}
 9e2:	60e2                	ld	ra,24(sp)
 9e4:	6442                	ld	s0,16(sp)
 9e6:	6105                	addi	sp,sp,32
 9e8:	8082                	ret

00000000000009ea <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9ea:	7139                	addi	sp,sp,-64
 9ec:	fc06                	sd	ra,56(sp)
 9ee:	f822                	sd	s0,48(sp)
 9f0:	f426                	sd	s1,40(sp)
 9f2:	f04a                	sd	s2,32(sp)
 9f4:	ec4e                	sd	s3,24(sp)
 9f6:	0080                	addi	s0,sp,64
 9f8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9fa:	c299                	beqz	a3,a00 <printint+0x16>
 9fc:	0805c863          	bltz	a1,a8c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 a00:	2581                	sext.w	a1,a1
  neg = 0;
 a02:	4881                	li	a7,0
 a04:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 a08:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 a0a:	2601                	sext.w	a2,a2
 a0c:	00001517          	auipc	a0,0x1
 a10:	98450513          	addi	a0,a0,-1660 # 1390 <digits>
 a14:	883a                	mv	a6,a4
 a16:	2705                	addiw	a4,a4,1
 a18:	02c5f7bb          	remuw	a5,a1,a2
 a1c:	1782                	slli	a5,a5,0x20
 a1e:	9381                	srli	a5,a5,0x20
 a20:	97aa                	add	a5,a5,a0
 a22:	0007c783          	lbu	a5,0(a5)
 a26:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a2a:	0005879b          	sext.w	a5,a1
 a2e:	02c5d5bb          	divuw	a1,a1,a2
 a32:	0685                	addi	a3,a3,1
 a34:	fec7f0e3          	bgeu	a5,a2,a14 <printint+0x2a>
  if(neg)
 a38:	00088b63          	beqz	a7,a4e <printint+0x64>
    buf[i++] = '-';
 a3c:	fd040793          	addi	a5,s0,-48
 a40:	973e                	add	a4,a4,a5
 a42:	02d00793          	li	a5,45
 a46:	fef70823          	sb	a5,-16(a4)
 a4a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a4e:	02e05863          	blez	a4,a7e <printint+0x94>
 a52:	fc040793          	addi	a5,s0,-64
 a56:	00e78933          	add	s2,a5,a4
 a5a:	fff78993          	addi	s3,a5,-1
 a5e:	99ba                	add	s3,s3,a4
 a60:	377d                	addiw	a4,a4,-1
 a62:	1702                	slli	a4,a4,0x20
 a64:	9301                	srli	a4,a4,0x20
 a66:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a6a:	fff94583          	lbu	a1,-1(s2)
 a6e:	8526                	mv	a0,s1
 a70:	00000097          	auipc	ra,0x0
 a74:	f58080e7          	jalr	-168(ra) # 9c8 <putc>
  while(--i >= 0)
 a78:	197d                	addi	s2,s2,-1
 a7a:	ff3918e3          	bne	s2,s3,a6a <printint+0x80>
}
 a7e:	70e2                	ld	ra,56(sp)
 a80:	7442                	ld	s0,48(sp)
 a82:	74a2                	ld	s1,40(sp)
 a84:	7902                	ld	s2,32(sp)
 a86:	69e2                	ld	s3,24(sp)
 a88:	6121                	addi	sp,sp,64
 a8a:	8082                	ret
    x = -xx;
 a8c:	40b005bb          	negw	a1,a1
    neg = 1;
 a90:	4885                	li	a7,1
    x = -xx;
 a92:	bf8d                	j	a04 <printint+0x1a>

0000000000000a94 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a94:	7119                	addi	sp,sp,-128
 a96:	fc86                	sd	ra,120(sp)
 a98:	f8a2                	sd	s0,112(sp)
 a9a:	f4a6                	sd	s1,104(sp)
 a9c:	f0ca                	sd	s2,96(sp)
 a9e:	ecce                	sd	s3,88(sp)
 aa0:	e8d2                	sd	s4,80(sp)
 aa2:	e4d6                	sd	s5,72(sp)
 aa4:	e0da                	sd	s6,64(sp)
 aa6:	fc5e                	sd	s7,56(sp)
 aa8:	f862                	sd	s8,48(sp)
 aaa:	f466                	sd	s9,40(sp)
 aac:	f06a                	sd	s10,32(sp)
 aae:	ec6e                	sd	s11,24(sp)
 ab0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 ab2:	0005c903          	lbu	s2,0(a1)
 ab6:	18090f63          	beqz	s2,c54 <vprintf+0x1c0>
 aba:	8aaa                	mv	s5,a0
 abc:	8b32                	mv	s6,a2
 abe:	00158493          	addi	s1,a1,1
  state = 0;
 ac2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ac4:	02500a13          	li	s4,37
      if(c == 'd'){
 ac8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 acc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 ad0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 ad4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ad8:	00001b97          	auipc	s7,0x1
 adc:	8b8b8b93          	addi	s7,s7,-1864 # 1390 <digits>
 ae0:	a839                	j	afe <vprintf+0x6a>
        putc(fd, c);
 ae2:	85ca                	mv	a1,s2
 ae4:	8556                	mv	a0,s5
 ae6:	00000097          	auipc	ra,0x0
 aea:	ee2080e7          	jalr	-286(ra) # 9c8 <putc>
 aee:	a019                	j	af4 <vprintf+0x60>
    } else if(state == '%'){
 af0:	01498f63          	beq	s3,s4,b0e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 af4:	0485                	addi	s1,s1,1
 af6:	fff4c903          	lbu	s2,-1(s1)
 afa:	14090d63          	beqz	s2,c54 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 afe:	0009079b          	sext.w	a5,s2
    if(state == 0){
 b02:	fe0997e3          	bnez	s3,af0 <vprintf+0x5c>
      if(c == '%'){
 b06:	fd479ee3          	bne	a5,s4,ae2 <vprintf+0x4e>
        state = '%';
 b0a:	89be                	mv	s3,a5
 b0c:	b7e5                	j	af4 <vprintf+0x60>
      if(c == 'd'){
 b0e:	05878063          	beq	a5,s8,b4e <vprintf+0xba>
      } else if(c == 'l') {
 b12:	05978c63          	beq	a5,s9,b6a <vprintf+0xd6>
      } else if(c == 'x') {
 b16:	07a78863          	beq	a5,s10,b86 <vprintf+0xf2>
      } else if(c == 'p') {
 b1a:	09b78463          	beq	a5,s11,ba2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 b1e:	07300713          	li	a4,115
 b22:	0ce78663          	beq	a5,a4,bee <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b26:	06300713          	li	a4,99
 b2a:	0ee78e63          	beq	a5,a4,c26 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 b2e:	11478863          	beq	a5,s4,c3e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b32:	85d2                	mv	a1,s4
 b34:	8556                	mv	a0,s5
 b36:	00000097          	auipc	ra,0x0
 b3a:	e92080e7          	jalr	-366(ra) # 9c8 <putc>
        putc(fd, c);
 b3e:	85ca                	mv	a1,s2
 b40:	8556                	mv	a0,s5
 b42:	00000097          	auipc	ra,0x0
 b46:	e86080e7          	jalr	-378(ra) # 9c8 <putc>
      }
      state = 0;
 b4a:	4981                	li	s3,0
 b4c:	b765                	j	af4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 b4e:	008b0913          	addi	s2,s6,8
 b52:	4685                	li	a3,1
 b54:	4629                	li	a2,10
 b56:	000b2583          	lw	a1,0(s6)
 b5a:	8556                	mv	a0,s5
 b5c:	00000097          	auipc	ra,0x0
 b60:	e8e080e7          	jalr	-370(ra) # 9ea <printint>
 b64:	8b4a                	mv	s6,s2
      state = 0;
 b66:	4981                	li	s3,0
 b68:	b771                	j	af4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b6a:	008b0913          	addi	s2,s6,8
 b6e:	4681                	li	a3,0
 b70:	4629                	li	a2,10
 b72:	000b2583          	lw	a1,0(s6)
 b76:	8556                	mv	a0,s5
 b78:	00000097          	auipc	ra,0x0
 b7c:	e72080e7          	jalr	-398(ra) # 9ea <printint>
 b80:	8b4a                	mv	s6,s2
      state = 0;
 b82:	4981                	li	s3,0
 b84:	bf85                	j	af4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b86:	008b0913          	addi	s2,s6,8
 b8a:	4681                	li	a3,0
 b8c:	4641                	li	a2,16
 b8e:	000b2583          	lw	a1,0(s6)
 b92:	8556                	mv	a0,s5
 b94:	00000097          	auipc	ra,0x0
 b98:	e56080e7          	jalr	-426(ra) # 9ea <printint>
 b9c:	8b4a                	mv	s6,s2
      state = 0;
 b9e:	4981                	li	s3,0
 ba0:	bf91                	j	af4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 ba2:	008b0793          	addi	a5,s6,8
 ba6:	f8f43423          	sd	a5,-120(s0)
 baa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 bae:	03000593          	li	a1,48
 bb2:	8556                	mv	a0,s5
 bb4:	00000097          	auipc	ra,0x0
 bb8:	e14080e7          	jalr	-492(ra) # 9c8 <putc>
  putc(fd, 'x');
 bbc:	85ea                	mv	a1,s10
 bbe:	8556                	mv	a0,s5
 bc0:	00000097          	auipc	ra,0x0
 bc4:	e08080e7          	jalr	-504(ra) # 9c8 <putc>
 bc8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bca:	03c9d793          	srli	a5,s3,0x3c
 bce:	97de                	add	a5,a5,s7
 bd0:	0007c583          	lbu	a1,0(a5)
 bd4:	8556                	mv	a0,s5
 bd6:	00000097          	auipc	ra,0x0
 bda:	df2080e7          	jalr	-526(ra) # 9c8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bde:	0992                	slli	s3,s3,0x4
 be0:	397d                	addiw	s2,s2,-1
 be2:	fe0914e3          	bnez	s2,bca <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 be6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bea:	4981                	li	s3,0
 bec:	b721                	j	af4 <vprintf+0x60>
        s = va_arg(ap, char*);
 bee:	008b0993          	addi	s3,s6,8
 bf2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 bf6:	02090163          	beqz	s2,c18 <vprintf+0x184>
        while(*s != 0){
 bfa:	00094583          	lbu	a1,0(s2)
 bfe:	c9a1                	beqz	a1,c4e <vprintf+0x1ba>
          putc(fd, *s);
 c00:	8556                	mv	a0,s5
 c02:	00000097          	auipc	ra,0x0
 c06:	dc6080e7          	jalr	-570(ra) # 9c8 <putc>
          s++;
 c0a:	0905                	addi	s2,s2,1
        while(*s != 0){
 c0c:	00094583          	lbu	a1,0(s2)
 c10:	f9e5                	bnez	a1,c00 <vprintf+0x16c>
        s = va_arg(ap, char*);
 c12:	8b4e                	mv	s6,s3
      state = 0;
 c14:	4981                	li	s3,0
 c16:	bdf9                	j	af4 <vprintf+0x60>
          s = "(null)";
 c18:	00000917          	auipc	s2,0x0
 c1c:	77090913          	addi	s2,s2,1904 # 1388 <malloc+0x62a>
        while(*s != 0){
 c20:	02800593          	li	a1,40
 c24:	bff1                	j	c00 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 c26:	008b0913          	addi	s2,s6,8
 c2a:	000b4583          	lbu	a1,0(s6)
 c2e:	8556                	mv	a0,s5
 c30:	00000097          	auipc	ra,0x0
 c34:	d98080e7          	jalr	-616(ra) # 9c8 <putc>
 c38:	8b4a                	mv	s6,s2
      state = 0;
 c3a:	4981                	li	s3,0
 c3c:	bd65                	j	af4 <vprintf+0x60>
        putc(fd, c);
 c3e:	85d2                	mv	a1,s4
 c40:	8556                	mv	a0,s5
 c42:	00000097          	auipc	ra,0x0
 c46:	d86080e7          	jalr	-634(ra) # 9c8 <putc>
      state = 0;
 c4a:	4981                	li	s3,0
 c4c:	b565                	j	af4 <vprintf+0x60>
        s = va_arg(ap, char*);
 c4e:	8b4e                	mv	s6,s3
      state = 0;
 c50:	4981                	li	s3,0
 c52:	b54d                	j	af4 <vprintf+0x60>
    }
  }
}
 c54:	70e6                	ld	ra,120(sp)
 c56:	7446                	ld	s0,112(sp)
 c58:	74a6                	ld	s1,104(sp)
 c5a:	7906                	ld	s2,96(sp)
 c5c:	69e6                	ld	s3,88(sp)
 c5e:	6a46                	ld	s4,80(sp)
 c60:	6aa6                	ld	s5,72(sp)
 c62:	6b06                	ld	s6,64(sp)
 c64:	7be2                	ld	s7,56(sp)
 c66:	7c42                	ld	s8,48(sp)
 c68:	7ca2                	ld	s9,40(sp)
 c6a:	7d02                	ld	s10,32(sp)
 c6c:	6de2                	ld	s11,24(sp)
 c6e:	6109                	addi	sp,sp,128
 c70:	8082                	ret

0000000000000c72 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c72:	715d                	addi	sp,sp,-80
 c74:	ec06                	sd	ra,24(sp)
 c76:	e822                	sd	s0,16(sp)
 c78:	1000                	addi	s0,sp,32
 c7a:	e010                	sd	a2,0(s0)
 c7c:	e414                	sd	a3,8(s0)
 c7e:	e818                	sd	a4,16(s0)
 c80:	ec1c                	sd	a5,24(s0)
 c82:	03043023          	sd	a6,32(s0)
 c86:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c8a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c8e:	8622                	mv	a2,s0
 c90:	00000097          	auipc	ra,0x0
 c94:	e04080e7          	jalr	-508(ra) # a94 <vprintf>
}
 c98:	60e2                	ld	ra,24(sp)
 c9a:	6442                	ld	s0,16(sp)
 c9c:	6161                	addi	sp,sp,80
 c9e:	8082                	ret

0000000000000ca0 <printf>:

void
printf(const char *fmt, ...)
{
 ca0:	711d                	addi	sp,sp,-96
 ca2:	ec06                	sd	ra,24(sp)
 ca4:	e822                	sd	s0,16(sp)
 ca6:	1000                	addi	s0,sp,32
 ca8:	e40c                	sd	a1,8(s0)
 caa:	e810                	sd	a2,16(s0)
 cac:	ec14                	sd	a3,24(s0)
 cae:	f018                	sd	a4,32(s0)
 cb0:	f41c                	sd	a5,40(s0)
 cb2:	03043823          	sd	a6,48(s0)
 cb6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 cba:	00840613          	addi	a2,s0,8
 cbe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cc2:	85aa                	mv	a1,a0
 cc4:	4505                	li	a0,1
 cc6:	00000097          	auipc	ra,0x0
 cca:	dce080e7          	jalr	-562(ra) # a94 <vprintf>
}
 cce:	60e2                	ld	ra,24(sp)
 cd0:	6442                	ld	s0,16(sp)
 cd2:	6125                	addi	sp,sp,96
 cd4:	8082                	ret

0000000000000cd6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cd6:	1141                	addi	sp,sp,-16
 cd8:	e422                	sd	s0,8(sp)
 cda:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cdc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ce0:	00000797          	auipc	a5,0x0
 ce4:	6f07b783          	ld	a5,1776(a5) # 13d0 <freep>
 ce8:	a805                	j	d18 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cea:	4618                	lw	a4,8(a2)
 cec:	9db9                	addw	a1,a1,a4
 cee:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 cf2:	6398                	ld	a4,0(a5)
 cf4:	6318                	ld	a4,0(a4)
 cf6:	fee53823          	sd	a4,-16(a0)
 cfa:	a091                	j	d3e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 cfc:	ff852703          	lw	a4,-8(a0)
 d00:	9e39                	addw	a2,a2,a4
 d02:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 d04:	ff053703          	ld	a4,-16(a0)
 d08:	e398                	sd	a4,0(a5)
 d0a:	a099                	j	d50 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d0c:	6398                	ld	a4,0(a5)
 d0e:	00e7e463          	bltu	a5,a4,d16 <free+0x40>
 d12:	00e6ea63          	bltu	a3,a4,d26 <free+0x50>
{
 d16:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d18:	fed7fae3          	bgeu	a5,a3,d0c <free+0x36>
 d1c:	6398                	ld	a4,0(a5)
 d1e:	00e6e463          	bltu	a3,a4,d26 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d22:	fee7eae3          	bltu	a5,a4,d16 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 d26:	ff852583          	lw	a1,-8(a0)
 d2a:	6390                	ld	a2,0(a5)
 d2c:	02059713          	slli	a4,a1,0x20
 d30:	9301                	srli	a4,a4,0x20
 d32:	0712                	slli	a4,a4,0x4
 d34:	9736                	add	a4,a4,a3
 d36:	fae60ae3          	beq	a2,a4,cea <free+0x14>
    bp->s.ptr = p->s.ptr;
 d3a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d3e:	4790                	lw	a2,8(a5)
 d40:	02061713          	slli	a4,a2,0x20
 d44:	9301                	srli	a4,a4,0x20
 d46:	0712                	slli	a4,a4,0x4
 d48:	973e                	add	a4,a4,a5
 d4a:	fae689e3          	beq	a3,a4,cfc <free+0x26>
  } else
    p->s.ptr = bp;
 d4e:	e394                	sd	a3,0(a5)
  freep = p;
 d50:	00000717          	auipc	a4,0x0
 d54:	68f73023          	sd	a5,1664(a4) # 13d0 <freep>
}
 d58:	6422                	ld	s0,8(sp)
 d5a:	0141                	addi	sp,sp,16
 d5c:	8082                	ret

0000000000000d5e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d5e:	7139                	addi	sp,sp,-64
 d60:	fc06                	sd	ra,56(sp)
 d62:	f822                	sd	s0,48(sp)
 d64:	f426                	sd	s1,40(sp)
 d66:	f04a                	sd	s2,32(sp)
 d68:	ec4e                	sd	s3,24(sp)
 d6a:	e852                	sd	s4,16(sp)
 d6c:	e456                	sd	s5,8(sp)
 d6e:	e05a                	sd	s6,0(sp)
 d70:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d72:	02051493          	slli	s1,a0,0x20
 d76:	9081                	srli	s1,s1,0x20
 d78:	04bd                	addi	s1,s1,15
 d7a:	8091                	srli	s1,s1,0x4
 d7c:	0014899b          	addiw	s3,s1,1
 d80:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d82:	00000517          	auipc	a0,0x0
 d86:	64e53503          	ld	a0,1614(a0) # 13d0 <freep>
 d8a:	c515                	beqz	a0,db6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d8c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d8e:	4798                	lw	a4,8(a5)
 d90:	02977f63          	bgeu	a4,s1,dce <malloc+0x70>
 d94:	8a4e                	mv	s4,s3
 d96:	0009871b          	sext.w	a4,s3
 d9a:	6685                	lui	a3,0x1
 d9c:	00d77363          	bgeu	a4,a3,da2 <malloc+0x44>
 da0:	6a05                	lui	s4,0x1
 da2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 da6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 daa:	00000917          	auipc	s2,0x0
 dae:	62690913          	addi	s2,s2,1574 # 13d0 <freep>
  if(p == (char*)-1)
 db2:	5afd                	li	s5,-1
 db4:	a88d                	j	e26 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 db6:	00000797          	auipc	a5,0x0
 dba:	62278793          	addi	a5,a5,1570 # 13d8 <base>
 dbe:	00000717          	auipc	a4,0x0
 dc2:	60f73923          	sd	a5,1554(a4) # 13d0 <freep>
 dc6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 dc8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 dcc:	b7e1                	j	d94 <malloc+0x36>
      if(p->s.size == nunits)
 dce:	02e48b63          	beq	s1,a4,e04 <malloc+0xa6>
        p->s.size -= nunits;
 dd2:	4137073b          	subw	a4,a4,s3
 dd6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dd8:	1702                	slli	a4,a4,0x20
 dda:	9301                	srli	a4,a4,0x20
 ddc:	0712                	slli	a4,a4,0x4
 dde:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 de0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 de4:	00000717          	auipc	a4,0x0
 de8:	5ea73623          	sd	a0,1516(a4) # 13d0 <freep>
      return (void*)(p + 1);
 dec:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 df0:	70e2                	ld	ra,56(sp)
 df2:	7442                	ld	s0,48(sp)
 df4:	74a2                	ld	s1,40(sp)
 df6:	7902                	ld	s2,32(sp)
 df8:	69e2                	ld	s3,24(sp)
 dfa:	6a42                	ld	s4,16(sp)
 dfc:	6aa2                	ld	s5,8(sp)
 dfe:	6b02                	ld	s6,0(sp)
 e00:	6121                	addi	sp,sp,64
 e02:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 e04:	6398                	ld	a4,0(a5)
 e06:	e118                	sd	a4,0(a0)
 e08:	bff1                	j	de4 <malloc+0x86>
  hp->s.size = nu;
 e0a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 e0e:	0541                	addi	a0,a0,16
 e10:	00000097          	auipc	ra,0x0
 e14:	ec6080e7          	jalr	-314(ra) # cd6 <free>
  return freep;
 e18:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e1c:	d971                	beqz	a0,df0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e1e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e20:	4798                	lw	a4,8(a5)
 e22:	fa9776e3          	bgeu	a4,s1,dce <malloc+0x70>
    if(p == freep)
 e26:	00093703          	ld	a4,0(s2)
 e2a:	853e                	mv	a0,a5
 e2c:	fef719e3          	bne	a4,a5,e1e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 e30:	8552                	mv	a0,s4
 e32:	00000097          	auipc	ra,0x0
 e36:	b6e080e7          	jalr	-1170(ra) # 9a0 <sbrk>
  if(p == (char*)-1)
 e3a:	fd5518e3          	bne	a0,s5,e0a <malloc+0xac>
        return 0;
 e3e:	4501                	li	a0,0
 e40:	bf45                	j	df0 <malloc+0x92>

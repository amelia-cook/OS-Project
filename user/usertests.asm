
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <createtest>:
}

// many creates, followed by unlink test
void
createtest(char *s)
{
       0:	7179                	addi	sp,sp,-48
       2:	f406                	sd	ra,40(sp)
       4:	f022                	sd	s0,32(sp)
       6:	ec26                	sd	s1,24(sp)
       8:	e84a                	sd	s2,16(sp)
       a:	e44e                	sd	s3,8(sp)
       c:	1800                	addi	s0,sp,48
  int i, fd;
  enum { N=52 };

  name[0] = 'a';
       e:	00007797          	auipc	a5,0x7
      12:	ff278793          	addi	a5,a5,-14 # 7000 <name>
      16:	06100713          	li	a4,97
      1a:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
      1e:	00078123          	sb	zero,2(a5)
      22:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
      26:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
      28:	06400993          	li	s3,100
    name[1] = '0' + i;
      2c:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
      30:	20200593          	li	a1,514
      34:	854a                	mv	a0,s2
      36:	00005097          	auipc	ra,0x5
      3a:	8ba080e7          	jalr	-1862(ra) # 48f0 <open>
    close(fd);
      3e:	00005097          	auipc	ra,0x5
      42:	89a080e7          	jalr	-1894(ra) # 48d8 <close>
  for(i = 0; i < N; i++){
      46:	2485                	addiw	s1,s1,1
      48:	0ff4f493          	andi	s1,s1,255
      4c:	ff3490e3          	bne	s1,s3,2c <createtest+0x2c>
  }
  name[0] = 'a';
      50:	00007797          	auipc	a5,0x7
      54:	fb078793          	addi	a5,a5,-80 # 7000 <name>
      58:	06100713          	li	a4,97
      5c:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
      60:	00078123          	sb	zero,2(a5)
      64:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    name[1] = '0' + i;
      68:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
      6a:	06400993          	li	s3,100
    name[1] = '0' + i;
      6e:	009900a3          	sb	s1,1(s2)
    unlink(name);
      72:	854a                	mv	a0,s2
      74:	00005097          	auipc	ra,0x5
      78:	88c080e7          	jalr	-1908(ra) # 4900 <unlink>
  for(i = 0; i < N; i++){
      7c:	2485                	addiw	s1,s1,1
      7e:	0ff4f493          	andi	s1,s1,255
      82:	ff3496e3          	bne	s1,s3,6e <createtest+0x6e>
  }
}
      86:	70a2                	ld	ra,40(sp)
      88:	7402                	ld	s0,32(sp)
      8a:	64e2                	ld	s1,24(sp)
      8c:	6942                	ld	s2,16(sp)
      8e:	69a2                	ld	s3,8(sp)
      90:	6145                	addi	sp,sp,48
      92:	8082                	ret

0000000000000094 <truncate1>:
{
      94:	711d                	addi	sp,sp,-96
      96:	ec86                	sd	ra,88(sp)
      98:	e8a2                	sd	s0,80(sp)
      9a:	e4a6                	sd	s1,72(sp)
      9c:	e0ca                	sd	s2,64(sp)
      9e:	fc4e                	sd	s3,56(sp)
      a0:	f852                	sd	s4,48(sp)
      a2:	f456                	sd	s5,40(sp)
      a4:	1080                	addi	s0,sp,96
      a6:	8aaa                	mv	s5,a0
  unlink("truncfile");
      a8:	00005517          	auipc	a0,0x5
      ac:	fd850513          	addi	a0,a0,-40 # 5080 <malloc+0x38a>
      b0:	00005097          	auipc	ra,0x5
      b4:	850080e7          	jalr	-1968(ra) # 4900 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
      b8:	60100593          	li	a1,1537
      bc:	00005517          	auipc	a0,0x5
      c0:	fc450513          	addi	a0,a0,-60 # 5080 <malloc+0x38a>
      c4:	00005097          	auipc	ra,0x5
      c8:	82c080e7          	jalr	-2004(ra) # 48f0 <open>
      cc:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
      ce:	4611                	li	a2,4
      d0:	00005597          	auipc	a1,0x5
      d4:	fc058593          	addi	a1,a1,-64 # 5090 <malloc+0x39a>
      d8:	00004097          	auipc	ra,0x4
      dc:	7f8080e7          	jalr	2040(ra) # 48d0 <write>
  close(fd1);
      e0:	8526                	mv	a0,s1
      e2:	00004097          	auipc	ra,0x4
      e6:	7f6080e7          	jalr	2038(ra) # 48d8 <close>
  int fd2 = open("truncfile", O_RDONLY);
      ea:	4581                	li	a1,0
      ec:	00005517          	auipc	a0,0x5
      f0:	f9450513          	addi	a0,a0,-108 # 5080 <malloc+0x38a>
      f4:	00004097          	auipc	ra,0x4
      f8:	7fc080e7          	jalr	2044(ra) # 48f0 <open>
      fc:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
      fe:	02000613          	li	a2,32
     102:	fa040593          	addi	a1,s0,-96
     106:	00004097          	auipc	ra,0x4
     10a:	7c2080e7          	jalr	1986(ra) # 48c8 <read>
  if(n != 4){
     10e:	4791                	li	a5,4
     110:	0cf51e63          	bne	a0,a5,1ec <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     114:	40100593          	li	a1,1025
     118:	00005517          	auipc	a0,0x5
     11c:	f6850513          	addi	a0,a0,-152 # 5080 <malloc+0x38a>
     120:	00004097          	auipc	ra,0x4
     124:	7d0080e7          	jalr	2000(ra) # 48f0 <open>
     128:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     12a:	4581                	li	a1,0
     12c:	00005517          	auipc	a0,0x5
     130:	f5450513          	addi	a0,a0,-172 # 5080 <malloc+0x38a>
     134:	00004097          	auipc	ra,0x4
     138:	7bc080e7          	jalr	1980(ra) # 48f0 <open>
     13c:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     13e:	02000613          	li	a2,32
     142:	fa040593          	addi	a1,s0,-96
     146:	00004097          	auipc	ra,0x4
     14a:	782080e7          	jalr	1922(ra) # 48c8 <read>
     14e:	8a2a                	mv	s4,a0
  if(n != 0){
     150:	ed4d                	bnez	a0,20a <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     152:	02000613          	li	a2,32
     156:	fa040593          	addi	a1,s0,-96
     15a:	8526                	mv	a0,s1
     15c:	00004097          	auipc	ra,0x4
     160:	76c080e7          	jalr	1900(ra) # 48c8 <read>
     164:	8a2a                	mv	s4,a0
  if(n != 0){
     166:	e971                	bnez	a0,23a <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     168:	4619                	li	a2,6
     16a:	00005597          	auipc	a1,0x5
     16e:	f8e58593          	addi	a1,a1,-114 # 50f8 <malloc+0x402>
     172:	854e                	mv	a0,s3
     174:	00004097          	auipc	ra,0x4
     178:	75c080e7          	jalr	1884(ra) # 48d0 <write>
  n = read(fd3, buf, sizeof(buf));
     17c:	02000613          	li	a2,32
     180:	fa040593          	addi	a1,s0,-96
     184:	854a                	mv	a0,s2
     186:	00004097          	auipc	ra,0x4
     18a:	742080e7          	jalr	1858(ra) # 48c8 <read>
  if(n != 6){
     18e:	4799                	li	a5,6
     190:	0cf51d63          	bne	a0,a5,26a <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     194:	02000613          	li	a2,32
     198:	fa040593          	addi	a1,s0,-96
     19c:	8526                	mv	a0,s1
     19e:	00004097          	auipc	ra,0x4
     1a2:	72a080e7          	jalr	1834(ra) # 48c8 <read>
  if(n != 2){
     1a6:	4789                	li	a5,2
     1a8:	0ef51063          	bne	a0,a5,288 <truncate1+0x1f4>
  unlink("truncfile");
     1ac:	00005517          	auipc	a0,0x5
     1b0:	ed450513          	addi	a0,a0,-300 # 5080 <malloc+0x38a>
     1b4:	00004097          	auipc	ra,0x4
     1b8:	74c080e7          	jalr	1868(ra) # 4900 <unlink>
  close(fd1);
     1bc:	854e                	mv	a0,s3
     1be:	00004097          	auipc	ra,0x4
     1c2:	71a080e7          	jalr	1818(ra) # 48d8 <close>
  close(fd2);
     1c6:	8526                	mv	a0,s1
     1c8:	00004097          	auipc	ra,0x4
     1cc:	710080e7          	jalr	1808(ra) # 48d8 <close>
  close(fd3);
     1d0:	854a                	mv	a0,s2
     1d2:	00004097          	auipc	ra,0x4
     1d6:	706080e7          	jalr	1798(ra) # 48d8 <close>
}
     1da:	60e6                	ld	ra,88(sp)
     1dc:	6446                	ld	s0,80(sp)
     1de:	64a6                	ld	s1,72(sp)
     1e0:	6906                	ld	s2,64(sp)
     1e2:	79e2                	ld	s3,56(sp)
     1e4:	7a42                	ld	s4,48(sp)
     1e6:	7aa2                	ld	s5,40(sp)
     1e8:	6125                	addi	sp,sp,96
     1ea:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     1ec:	862a                	mv	a2,a0
     1ee:	85d6                	mv	a1,s5
     1f0:	00005517          	auipc	a0,0x5
     1f4:	ea850513          	addi	a0,a0,-344 # 5098 <malloc+0x3a2>
     1f8:	00005097          	auipc	ra,0x5
     1fc:	a40080e7          	jalr	-1472(ra) # 4c38 <printf>
    exit(1);
     200:	4505                	li	a0,1
     202:	00004097          	auipc	ra,0x4
     206:	6ae080e7          	jalr	1710(ra) # 48b0 <exit>
    printf("aaa fd3=%d\n", fd3);
     20a:	85ca                	mv	a1,s2
     20c:	00005517          	auipc	a0,0x5
     210:	eac50513          	addi	a0,a0,-340 # 50b8 <malloc+0x3c2>
     214:	00005097          	auipc	ra,0x5
     218:	a24080e7          	jalr	-1500(ra) # 4c38 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     21c:	8652                	mv	a2,s4
     21e:	85d6                	mv	a1,s5
     220:	00005517          	auipc	a0,0x5
     224:	ea850513          	addi	a0,a0,-344 # 50c8 <malloc+0x3d2>
     228:	00005097          	auipc	ra,0x5
     22c:	a10080e7          	jalr	-1520(ra) # 4c38 <printf>
    exit(1);
     230:	4505                	li	a0,1
     232:	00004097          	auipc	ra,0x4
     236:	67e080e7          	jalr	1662(ra) # 48b0 <exit>
    printf("bbb fd2=%d\n", fd2);
     23a:	85a6                	mv	a1,s1
     23c:	00005517          	auipc	a0,0x5
     240:	eac50513          	addi	a0,a0,-340 # 50e8 <malloc+0x3f2>
     244:	00005097          	auipc	ra,0x5
     248:	9f4080e7          	jalr	-1548(ra) # 4c38 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     24c:	8652                	mv	a2,s4
     24e:	85d6                	mv	a1,s5
     250:	00005517          	auipc	a0,0x5
     254:	e7850513          	addi	a0,a0,-392 # 50c8 <malloc+0x3d2>
     258:	00005097          	auipc	ra,0x5
     25c:	9e0080e7          	jalr	-1568(ra) # 4c38 <printf>
    exit(1);
     260:	4505                	li	a0,1
     262:	00004097          	auipc	ra,0x4
     266:	64e080e7          	jalr	1614(ra) # 48b0 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     26a:	862a                	mv	a2,a0
     26c:	85d6                	mv	a1,s5
     26e:	00005517          	auipc	a0,0x5
     272:	e9250513          	addi	a0,a0,-366 # 5100 <malloc+0x40a>
     276:	00005097          	auipc	ra,0x5
     27a:	9c2080e7          	jalr	-1598(ra) # 4c38 <printf>
    exit(1);
     27e:	4505                	li	a0,1
     280:	00004097          	auipc	ra,0x4
     284:	630080e7          	jalr	1584(ra) # 48b0 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     288:	862a                	mv	a2,a0
     28a:	85d6                	mv	a1,s5
     28c:	00005517          	auipc	a0,0x5
     290:	e9450513          	addi	a0,a0,-364 # 5120 <malloc+0x42a>
     294:	00005097          	auipc	ra,0x5
     298:	9a4080e7          	jalr	-1628(ra) # 4c38 <printf>
    exit(1);
     29c:	4505                	li	a0,1
     29e:	00004097          	auipc	ra,0x4
     2a2:	612080e7          	jalr	1554(ra) # 48b0 <exit>

00000000000002a6 <truncate2>:
{
     2a6:	7179                	addi	sp,sp,-48
     2a8:	f406                	sd	ra,40(sp)
     2aa:	f022                	sd	s0,32(sp)
     2ac:	ec26                	sd	s1,24(sp)
     2ae:	e84a                	sd	s2,16(sp)
     2b0:	e44e                	sd	s3,8(sp)
     2b2:	1800                	addi	s0,sp,48
     2b4:	89aa                	mv	s3,a0
  unlink("truncfile");
     2b6:	00005517          	auipc	a0,0x5
     2ba:	dca50513          	addi	a0,a0,-566 # 5080 <malloc+0x38a>
     2be:	00004097          	auipc	ra,0x4
     2c2:	642080e7          	jalr	1602(ra) # 4900 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     2c6:	60100593          	li	a1,1537
     2ca:	00005517          	auipc	a0,0x5
     2ce:	db650513          	addi	a0,a0,-586 # 5080 <malloc+0x38a>
     2d2:	00004097          	auipc	ra,0x4
     2d6:	61e080e7          	jalr	1566(ra) # 48f0 <open>
     2da:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     2dc:	4611                	li	a2,4
     2de:	00005597          	auipc	a1,0x5
     2e2:	db258593          	addi	a1,a1,-590 # 5090 <malloc+0x39a>
     2e6:	00004097          	auipc	ra,0x4
     2ea:	5ea080e7          	jalr	1514(ra) # 48d0 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     2ee:	40100593          	li	a1,1025
     2f2:	00005517          	auipc	a0,0x5
     2f6:	d8e50513          	addi	a0,a0,-626 # 5080 <malloc+0x38a>
     2fa:	00004097          	auipc	ra,0x4
     2fe:	5f6080e7          	jalr	1526(ra) # 48f0 <open>
     302:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     304:	4605                	li	a2,1
     306:	00005597          	auipc	a1,0x5
     30a:	e3a58593          	addi	a1,a1,-454 # 5140 <malloc+0x44a>
     30e:	8526                	mv	a0,s1
     310:	00004097          	auipc	ra,0x4
     314:	5c0080e7          	jalr	1472(ra) # 48d0 <write>
  if(n != -1){
     318:	57fd                	li	a5,-1
     31a:	02f51b63          	bne	a0,a5,350 <truncate2+0xaa>
  unlink("truncfile");
     31e:	00005517          	auipc	a0,0x5
     322:	d6250513          	addi	a0,a0,-670 # 5080 <malloc+0x38a>
     326:	00004097          	auipc	ra,0x4
     32a:	5da080e7          	jalr	1498(ra) # 4900 <unlink>
  close(fd1);
     32e:	8526                	mv	a0,s1
     330:	00004097          	auipc	ra,0x4
     334:	5a8080e7          	jalr	1448(ra) # 48d8 <close>
  close(fd2);
     338:	854a                	mv	a0,s2
     33a:	00004097          	auipc	ra,0x4
     33e:	59e080e7          	jalr	1438(ra) # 48d8 <close>
}
     342:	70a2                	ld	ra,40(sp)
     344:	7402                	ld	s0,32(sp)
     346:	64e2                	ld	s1,24(sp)
     348:	6942                	ld	s2,16(sp)
     34a:	69a2                	ld	s3,8(sp)
     34c:	6145                	addi	sp,sp,48
     34e:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     350:	862a                	mv	a2,a0
     352:	85ce                	mv	a1,s3
     354:	00005517          	auipc	a0,0x5
     358:	df450513          	addi	a0,a0,-524 # 5148 <malloc+0x452>
     35c:	00005097          	auipc	ra,0x5
     360:	8dc080e7          	jalr	-1828(ra) # 4c38 <printf>
    exit(1);
     364:	4505                	li	a0,1
     366:	00004097          	auipc	ra,0x4
     36a:	54a080e7          	jalr	1354(ra) # 48b0 <exit>

000000000000036e <opentest>:
{
     36e:	1101                	addi	sp,sp,-32
     370:	ec06                	sd	ra,24(sp)
     372:	e822                	sd	s0,16(sp)
     374:	e426                	sd	s1,8(sp)
     376:	1000                	addi	s0,sp,32
     378:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     37a:	4581                	li	a1,0
     37c:	00005517          	auipc	a0,0x5
     380:	df450513          	addi	a0,a0,-524 # 5170 <malloc+0x47a>
     384:	00004097          	auipc	ra,0x4
     388:	56c080e7          	jalr	1388(ra) # 48f0 <open>
  if(fd < 0){
     38c:	02054663          	bltz	a0,3b8 <opentest+0x4a>
  close(fd);
     390:	00004097          	auipc	ra,0x4
     394:	548080e7          	jalr	1352(ra) # 48d8 <close>
  fd = open("doesnotexist", 0);
     398:	4581                	li	a1,0
     39a:	00005517          	auipc	a0,0x5
     39e:	df650513          	addi	a0,a0,-522 # 5190 <malloc+0x49a>
     3a2:	00004097          	auipc	ra,0x4
     3a6:	54e080e7          	jalr	1358(ra) # 48f0 <open>
  if(fd >= 0){
     3aa:	02055563          	bgez	a0,3d4 <opentest+0x66>
}
     3ae:	60e2                	ld	ra,24(sp)
     3b0:	6442                	ld	s0,16(sp)
     3b2:	64a2                	ld	s1,8(sp)
     3b4:	6105                	addi	sp,sp,32
     3b6:	8082                	ret
    printf("%s: open echo failed!\n", s);
     3b8:	85a6                	mv	a1,s1
     3ba:	00005517          	auipc	a0,0x5
     3be:	dbe50513          	addi	a0,a0,-578 # 5178 <malloc+0x482>
     3c2:	00005097          	auipc	ra,0x5
     3c6:	876080e7          	jalr	-1930(ra) # 4c38 <printf>
    exit(1);
     3ca:	4505                	li	a0,1
     3cc:	00004097          	auipc	ra,0x4
     3d0:	4e4080e7          	jalr	1252(ra) # 48b0 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     3d4:	85a6                	mv	a1,s1
     3d6:	00005517          	auipc	a0,0x5
     3da:	dca50513          	addi	a0,a0,-566 # 51a0 <malloc+0x4aa>
     3de:	00005097          	auipc	ra,0x5
     3e2:	85a080e7          	jalr	-1958(ra) # 4c38 <printf>
    exit(1);
     3e6:	4505                	li	a0,1
     3e8:	00004097          	auipc	ra,0x4
     3ec:	4c8080e7          	jalr	1224(ra) # 48b0 <exit>

00000000000003f0 <writetest>:
{
     3f0:	7139                	addi	sp,sp,-64
     3f2:	fc06                	sd	ra,56(sp)
     3f4:	f822                	sd	s0,48(sp)
     3f6:	f426                	sd	s1,40(sp)
     3f8:	f04a                	sd	s2,32(sp)
     3fa:	ec4e                	sd	s3,24(sp)
     3fc:	e852                	sd	s4,16(sp)
     3fe:	e456                	sd	s5,8(sp)
     400:	e05a                	sd	s6,0(sp)
     402:	0080                	addi	s0,sp,64
     404:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     406:	20200593          	li	a1,514
     40a:	00005517          	auipc	a0,0x5
     40e:	dbe50513          	addi	a0,a0,-578 # 51c8 <malloc+0x4d2>
     412:	00004097          	auipc	ra,0x4
     416:	4de080e7          	jalr	1246(ra) # 48f0 <open>
  if(fd < 0){
     41a:	0a054d63          	bltz	a0,4d4 <writetest+0xe4>
     41e:	892a                	mv	s2,a0
     420:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     422:	00005997          	auipc	s3,0x5
     426:	dce98993          	addi	s3,s3,-562 # 51f0 <malloc+0x4fa>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     42a:	00005a97          	auipc	s5,0x5
     42e:	dfea8a93          	addi	s5,s5,-514 # 5228 <malloc+0x532>
  for(i = 0; i < N; i++){
     432:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     436:	4629                	li	a2,10
     438:	85ce                	mv	a1,s3
     43a:	854a                	mv	a0,s2
     43c:	00004097          	auipc	ra,0x4
     440:	494080e7          	jalr	1172(ra) # 48d0 <write>
     444:	47a9                	li	a5,10
     446:	0af51563          	bne	a0,a5,4f0 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     44a:	4629                	li	a2,10
     44c:	85d6                	mv	a1,s5
     44e:	854a                	mv	a0,s2
     450:	00004097          	auipc	ra,0x4
     454:	480080e7          	jalr	1152(ra) # 48d0 <write>
     458:	47a9                	li	a5,10
     45a:	0af51963          	bne	a0,a5,50c <writetest+0x11c>
  for(i = 0; i < N; i++){
     45e:	2485                	addiw	s1,s1,1
     460:	fd449be3          	bne	s1,s4,436 <writetest+0x46>
  close(fd);
     464:	854a                	mv	a0,s2
     466:	00004097          	auipc	ra,0x4
     46a:	472080e7          	jalr	1138(ra) # 48d8 <close>
  fd = open("small", O_RDONLY);
     46e:	4581                	li	a1,0
     470:	00005517          	auipc	a0,0x5
     474:	d5850513          	addi	a0,a0,-680 # 51c8 <malloc+0x4d2>
     478:	00004097          	auipc	ra,0x4
     47c:	478080e7          	jalr	1144(ra) # 48f0 <open>
     480:	84aa                	mv	s1,a0
  if(fd < 0){
     482:	0a054363          	bltz	a0,528 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     486:	7d000613          	li	a2,2000
     48a:	00009597          	auipc	a1,0x9
     48e:	39658593          	addi	a1,a1,918 # 9820 <buf>
     492:	00004097          	auipc	ra,0x4
     496:	436080e7          	jalr	1078(ra) # 48c8 <read>
  if(i != N*SZ*2){
     49a:	7d000793          	li	a5,2000
     49e:	0af51363          	bne	a0,a5,544 <writetest+0x154>
  close(fd);
     4a2:	8526                	mv	a0,s1
     4a4:	00004097          	auipc	ra,0x4
     4a8:	434080e7          	jalr	1076(ra) # 48d8 <close>
  if(unlink("small") < 0){
     4ac:	00005517          	auipc	a0,0x5
     4b0:	d1c50513          	addi	a0,a0,-740 # 51c8 <malloc+0x4d2>
     4b4:	00004097          	auipc	ra,0x4
     4b8:	44c080e7          	jalr	1100(ra) # 4900 <unlink>
     4bc:	0a054263          	bltz	a0,560 <writetest+0x170>
}
     4c0:	70e2                	ld	ra,56(sp)
     4c2:	7442                	ld	s0,48(sp)
     4c4:	74a2                	ld	s1,40(sp)
     4c6:	7902                	ld	s2,32(sp)
     4c8:	69e2                	ld	s3,24(sp)
     4ca:	6a42                	ld	s4,16(sp)
     4cc:	6aa2                	ld	s5,8(sp)
     4ce:	6b02                	ld	s6,0(sp)
     4d0:	6121                	addi	sp,sp,64
     4d2:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     4d4:	85da                	mv	a1,s6
     4d6:	00005517          	auipc	a0,0x5
     4da:	cfa50513          	addi	a0,a0,-774 # 51d0 <malloc+0x4da>
     4de:	00004097          	auipc	ra,0x4
     4e2:	75a080e7          	jalr	1882(ra) # 4c38 <printf>
    exit(1);
     4e6:	4505                	li	a0,1
     4e8:	00004097          	auipc	ra,0x4
     4ec:	3c8080e7          	jalr	968(ra) # 48b0 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     4f0:	85a6                	mv	a1,s1
     4f2:	00005517          	auipc	a0,0x5
     4f6:	d0e50513          	addi	a0,a0,-754 # 5200 <malloc+0x50a>
     4fa:	00004097          	auipc	ra,0x4
     4fe:	73e080e7          	jalr	1854(ra) # 4c38 <printf>
      exit(1);
     502:	4505                	li	a0,1
     504:	00004097          	auipc	ra,0x4
     508:	3ac080e7          	jalr	940(ra) # 48b0 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     50c:	85a6                	mv	a1,s1
     50e:	00005517          	auipc	a0,0x5
     512:	d2a50513          	addi	a0,a0,-726 # 5238 <malloc+0x542>
     516:	00004097          	auipc	ra,0x4
     51a:	722080e7          	jalr	1826(ra) # 4c38 <printf>
      exit(1);
     51e:	4505                	li	a0,1
     520:	00004097          	auipc	ra,0x4
     524:	390080e7          	jalr	912(ra) # 48b0 <exit>
    printf("%s: error: open small failed!\n", s);
     528:	85da                	mv	a1,s6
     52a:	00005517          	auipc	a0,0x5
     52e:	d3650513          	addi	a0,a0,-714 # 5260 <malloc+0x56a>
     532:	00004097          	auipc	ra,0x4
     536:	706080e7          	jalr	1798(ra) # 4c38 <printf>
    exit(1);
     53a:	4505                	li	a0,1
     53c:	00004097          	auipc	ra,0x4
     540:	374080e7          	jalr	884(ra) # 48b0 <exit>
    printf("%s: read failed\n", s);
     544:	85da                	mv	a1,s6
     546:	00005517          	auipc	a0,0x5
     54a:	d3a50513          	addi	a0,a0,-710 # 5280 <malloc+0x58a>
     54e:	00004097          	auipc	ra,0x4
     552:	6ea080e7          	jalr	1770(ra) # 4c38 <printf>
    exit(1);
     556:	4505                	li	a0,1
     558:	00004097          	auipc	ra,0x4
     55c:	358080e7          	jalr	856(ra) # 48b0 <exit>
    printf("%s: unlink small failed\n", s);
     560:	85da                	mv	a1,s6
     562:	00005517          	auipc	a0,0x5
     566:	d3650513          	addi	a0,a0,-714 # 5298 <malloc+0x5a2>
     56a:	00004097          	auipc	ra,0x4
     56e:	6ce080e7          	jalr	1742(ra) # 4c38 <printf>
    exit(1);
     572:	4505                	li	a0,1
     574:	00004097          	auipc	ra,0x4
     578:	33c080e7          	jalr	828(ra) # 48b0 <exit>

000000000000057c <writebig>:
{
     57c:	7139                	addi	sp,sp,-64
     57e:	fc06                	sd	ra,56(sp)
     580:	f822                	sd	s0,48(sp)
     582:	f426                	sd	s1,40(sp)
     584:	f04a                	sd	s2,32(sp)
     586:	ec4e                	sd	s3,24(sp)
     588:	e852                	sd	s4,16(sp)
     58a:	e456                	sd	s5,8(sp)
     58c:	0080                	addi	s0,sp,64
     58e:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     590:	20200593          	li	a1,514
     594:	00005517          	auipc	a0,0x5
     598:	d2450513          	addi	a0,a0,-732 # 52b8 <malloc+0x5c2>
     59c:	00004097          	auipc	ra,0x4
     5a0:	354080e7          	jalr	852(ra) # 48f0 <open>
     5a4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     5a6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     5a8:	00009917          	auipc	s2,0x9
     5ac:	27890913          	addi	s2,s2,632 # 9820 <buf>
  for(i = 0; i < MAXFILE; i++){
     5b0:	10c00a13          	li	s4,268
  if(fd < 0){
     5b4:	06054c63          	bltz	a0,62c <writebig+0xb0>
    ((int*)buf)[0] = i;
     5b8:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     5bc:	40000613          	li	a2,1024
     5c0:	85ca                	mv	a1,s2
     5c2:	854e                	mv	a0,s3
     5c4:	00004097          	auipc	ra,0x4
     5c8:	30c080e7          	jalr	780(ra) # 48d0 <write>
     5cc:	40000793          	li	a5,1024
     5d0:	06f51c63          	bne	a0,a5,648 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     5d4:	2485                	addiw	s1,s1,1
     5d6:	ff4491e3          	bne	s1,s4,5b8 <writebig+0x3c>
  close(fd);
     5da:	854e                	mv	a0,s3
     5dc:	00004097          	auipc	ra,0x4
     5e0:	2fc080e7          	jalr	764(ra) # 48d8 <close>
  fd = open("big", O_RDONLY);
     5e4:	4581                	li	a1,0
     5e6:	00005517          	auipc	a0,0x5
     5ea:	cd250513          	addi	a0,a0,-814 # 52b8 <malloc+0x5c2>
     5ee:	00004097          	auipc	ra,0x4
     5f2:	302080e7          	jalr	770(ra) # 48f0 <open>
     5f6:	89aa                	mv	s3,a0
  n = 0;
     5f8:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     5fa:	00009917          	auipc	s2,0x9
     5fe:	22690913          	addi	s2,s2,550 # 9820 <buf>
  if(fd < 0){
     602:	06054163          	bltz	a0,664 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     606:	40000613          	li	a2,1024
     60a:	85ca                	mv	a1,s2
     60c:	854e                	mv	a0,s3
     60e:	00004097          	auipc	ra,0x4
     612:	2ba080e7          	jalr	698(ra) # 48c8 <read>
    if(i == 0){
     616:	c52d                	beqz	a0,680 <writebig+0x104>
    } else if(i != BSIZE){
     618:	40000793          	li	a5,1024
     61c:	0af51d63          	bne	a0,a5,6d6 <writebig+0x15a>
    if(((int*)buf)[0] != n){
     620:	00092603          	lw	a2,0(s2)
     624:	0c961763          	bne	a2,s1,6f2 <writebig+0x176>
    n++;
     628:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     62a:	bff1                	j	606 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     62c:	85d6                	mv	a1,s5
     62e:	00005517          	auipc	a0,0x5
     632:	c9250513          	addi	a0,a0,-878 # 52c0 <malloc+0x5ca>
     636:	00004097          	auipc	ra,0x4
     63a:	602080e7          	jalr	1538(ra) # 4c38 <printf>
    exit(1);
     63e:	4505                	li	a0,1
     640:	00004097          	auipc	ra,0x4
     644:	270080e7          	jalr	624(ra) # 48b0 <exit>
      printf("%s: error: write big file failed\n", i);
     648:	85a6                	mv	a1,s1
     64a:	00005517          	auipc	a0,0x5
     64e:	c9650513          	addi	a0,a0,-874 # 52e0 <malloc+0x5ea>
     652:	00004097          	auipc	ra,0x4
     656:	5e6080e7          	jalr	1510(ra) # 4c38 <printf>
      exit(1);
     65a:	4505                	li	a0,1
     65c:	00004097          	auipc	ra,0x4
     660:	254080e7          	jalr	596(ra) # 48b0 <exit>
    printf("%s: error: open big failed!\n", s);
     664:	85d6                	mv	a1,s5
     666:	00005517          	auipc	a0,0x5
     66a:	ca250513          	addi	a0,a0,-862 # 5308 <malloc+0x612>
     66e:	00004097          	auipc	ra,0x4
     672:	5ca080e7          	jalr	1482(ra) # 4c38 <printf>
    exit(1);
     676:	4505                	li	a0,1
     678:	00004097          	auipc	ra,0x4
     67c:	238080e7          	jalr	568(ra) # 48b0 <exit>
      if(n == MAXFILE - 1){
     680:	10b00793          	li	a5,267
     684:	02f48a63          	beq	s1,a5,6b8 <writebig+0x13c>
  close(fd);
     688:	854e                	mv	a0,s3
     68a:	00004097          	auipc	ra,0x4
     68e:	24e080e7          	jalr	590(ra) # 48d8 <close>
  if(unlink("big") < 0){
     692:	00005517          	auipc	a0,0x5
     696:	c2650513          	addi	a0,a0,-986 # 52b8 <malloc+0x5c2>
     69a:	00004097          	auipc	ra,0x4
     69e:	266080e7          	jalr	614(ra) # 4900 <unlink>
     6a2:	06054663          	bltz	a0,70e <writebig+0x192>
}
     6a6:	70e2                	ld	ra,56(sp)
     6a8:	7442                	ld	s0,48(sp)
     6aa:	74a2                	ld	s1,40(sp)
     6ac:	7902                	ld	s2,32(sp)
     6ae:	69e2                	ld	s3,24(sp)
     6b0:	6a42                	ld	s4,16(sp)
     6b2:	6aa2                	ld	s5,8(sp)
     6b4:	6121                	addi	sp,sp,64
     6b6:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     6b8:	10b00593          	li	a1,267
     6bc:	00005517          	auipc	a0,0x5
     6c0:	c6c50513          	addi	a0,a0,-916 # 5328 <malloc+0x632>
     6c4:	00004097          	auipc	ra,0x4
     6c8:	574080e7          	jalr	1396(ra) # 4c38 <printf>
        exit(1);
     6cc:	4505                	li	a0,1
     6ce:	00004097          	auipc	ra,0x4
     6d2:	1e2080e7          	jalr	482(ra) # 48b0 <exit>
      printf("%s: read failed %d\n", i);
     6d6:	85aa                	mv	a1,a0
     6d8:	00005517          	auipc	a0,0x5
     6dc:	c7850513          	addi	a0,a0,-904 # 5350 <malloc+0x65a>
     6e0:	00004097          	auipc	ra,0x4
     6e4:	558080e7          	jalr	1368(ra) # 4c38 <printf>
      exit(1);
     6e8:	4505                	li	a0,1
     6ea:	00004097          	auipc	ra,0x4
     6ee:	1c6080e7          	jalr	454(ra) # 48b0 <exit>
      printf("%s: read content of block %d is %d\n",
     6f2:	85a6                	mv	a1,s1
     6f4:	00005517          	auipc	a0,0x5
     6f8:	c7450513          	addi	a0,a0,-908 # 5368 <malloc+0x672>
     6fc:	00004097          	auipc	ra,0x4
     700:	53c080e7          	jalr	1340(ra) # 4c38 <printf>
      exit(1);
     704:	4505                	li	a0,1
     706:	00004097          	auipc	ra,0x4
     70a:	1aa080e7          	jalr	426(ra) # 48b0 <exit>
    printf("%s: unlink big failed\n", s);
     70e:	85d6                	mv	a1,s5
     710:	00005517          	auipc	a0,0x5
     714:	c8050513          	addi	a0,a0,-896 # 5390 <malloc+0x69a>
     718:	00004097          	auipc	ra,0x4
     71c:	520080e7          	jalr	1312(ra) # 4c38 <printf>
    exit(1);
     720:	4505                	li	a0,1
     722:	00004097          	auipc	ra,0x4
     726:	18e080e7          	jalr	398(ra) # 48b0 <exit>

000000000000072a <unlinkread>:
}

// can I unlink a file and still read it?
void
unlinkread(char *s)
{
     72a:	7179                	addi	sp,sp,-48
     72c:	f406                	sd	ra,40(sp)
     72e:	f022                	sd	s0,32(sp)
     730:	ec26                	sd	s1,24(sp)
     732:	e84a                	sd	s2,16(sp)
     734:	e44e                	sd	s3,8(sp)
     736:	1800                	addi	s0,sp,48
     738:	89aa                	mv	s3,a0
  enum { SZ = 5 };
  int fd, fd1;

  fd = open("unlinkread", O_CREATE | O_RDWR);
     73a:	20200593          	li	a1,514
     73e:	00004517          	auipc	a0,0x4
     742:	7a250513          	addi	a0,a0,1954 # 4ee0 <malloc+0x1ea>
     746:	00004097          	auipc	ra,0x4
     74a:	1aa080e7          	jalr	426(ra) # 48f0 <open>
  if(fd < 0){
     74e:	0e054563          	bltz	a0,838 <unlinkread+0x10e>
     752:	84aa                	mv	s1,a0
    printf("%s: create unlinkread failed\n", s);
    exit(1);
  }
  write(fd, "hello", SZ);
     754:	4615                	li	a2,5
     756:	00005597          	auipc	a1,0x5
     75a:	c7258593          	addi	a1,a1,-910 # 53c8 <malloc+0x6d2>
     75e:	00004097          	auipc	ra,0x4
     762:	172080e7          	jalr	370(ra) # 48d0 <write>
  close(fd);
     766:	8526                	mv	a0,s1
     768:	00004097          	auipc	ra,0x4
     76c:	170080e7          	jalr	368(ra) # 48d8 <close>

  fd = open("unlinkread", O_RDWR);
     770:	4589                	li	a1,2
     772:	00004517          	auipc	a0,0x4
     776:	76e50513          	addi	a0,a0,1902 # 4ee0 <malloc+0x1ea>
     77a:	00004097          	auipc	ra,0x4
     77e:	176080e7          	jalr	374(ra) # 48f0 <open>
     782:	84aa                	mv	s1,a0
  if(fd < 0){
     784:	0c054863          	bltz	a0,854 <unlinkread+0x12a>
    printf("%s: open unlinkread failed\n", s);
    exit(1);
  }
  if(unlink("unlinkread") != 0){
     788:	00004517          	auipc	a0,0x4
     78c:	75850513          	addi	a0,a0,1880 # 4ee0 <malloc+0x1ea>
     790:	00004097          	auipc	ra,0x4
     794:	170080e7          	jalr	368(ra) # 4900 <unlink>
     798:	ed61                	bnez	a0,870 <unlinkread+0x146>
    printf("%s: unlink unlinkread failed\n", s);
    exit(1);
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     79a:	20200593          	li	a1,514
     79e:	00004517          	auipc	a0,0x4
     7a2:	74250513          	addi	a0,a0,1858 # 4ee0 <malloc+0x1ea>
     7a6:	00004097          	auipc	ra,0x4
     7aa:	14a080e7          	jalr	330(ra) # 48f0 <open>
     7ae:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     7b0:	460d                	li	a2,3
     7b2:	00005597          	auipc	a1,0x5
     7b6:	c5e58593          	addi	a1,a1,-930 # 5410 <malloc+0x71a>
     7ba:	00004097          	auipc	ra,0x4
     7be:	116080e7          	jalr	278(ra) # 48d0 <write>
  close(fd1);
     7c2:	854a                	mv	a0,s2
     7c4:	00004097          	auipc	ra,0x4
     7c8:	114080e7          	jalr	276(ra) # 48d8 <close>

  if(read(fd, buf, sizeof(buf)) != SZ){
     7cc:	660d                	lui	a2,0x3
     7ce:	00009597          	auipc	a1,0x9
     7d2:	05258593          	addi	a1,a1,82 # 9820 <buf>
     7d6:	8526                	mv	a0,s1
     7d8:	00004097          	auipc	ra,0x4
     7dc:	0f0080e7          	jalr	240(ra) # 48c8 <read>
     7e0:	4795                	li	a5,5
     7e2:	0af51563          	bne	a0,a5,88c <unlinkread+0x162>
    printf("%s: unlinkread read failed", s);
    exit(1);
  }
  if(buf[0] != 'h'){
     7e6:	00009717          	auipc	a4,0x9
     7ea:	03a74703          	lbu	a4,58(a4) # 9820 <buf>
     7ee:	06800793          	li	a5,104
     7f2:	0af71b63          	bne	a4,a5,8a8 <unlinkread+0x17e>
    printf("%s: unlinkread wrong data\n", s);
    exit(1);
  }
  if(write(fd, buf, 10) != 10){
     7f6:	4629                	li	a2,10
     7f8:	00009597          	auipc	a1,0x9
     7fc:	02858593          	addi	a1,a1,40 # 9820 <buf>
     800:	8526                	mv	a0,s1
     802:	00004097          	auipc	ra,0x4
     806:	0ce080e7          	jalr	206(ra) # 48d0 <write>
     80a:	47a9                	li	a5,10
     80c:	0af51c63          	bne	a0,a5,8c4 <unlinkread+0x19a>
    printf("%s: unlinkread write failed\n", s);
    exit(1);
  }
  close(fd);
     810:	8526                	mv	a0,s1
     812:	00004097          	auipc	ra,0x4
     816:	0c6080e7          	jalr	198(ra) # 48d8 <close>
  unlink("unlinkread");
     81a:	00004517          	auipc	a0,0x4
     81e:	6c650513          	addi	a0,a0,1734 # 4ee0 <malloc+0x1ea>
     822:	00004097          	auipc	ra,0x4
     826:	0de080e7          	jalr	222(ra) # 4900 <unlink>
}
     82a:	70a2                	ld	ra,40(sp)
     82c:	7402                	ld	s0,32(sp)
     82e:	64e2                	ld	s1,24(sp)
     830:	6942                	ld	s2,16(sp)
     832:	69a2                	ld	s3,8(sp)
     834:	6145                	addi	sp,sp,48
     836:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     838:	85ce                	mv	a1,s3
     83a:	00005517          	auipc	a0,0x5
     83e:	b6e50513          	addi	a0,a0,-1170 # 53a8 <malloc+0x6b2>
     842:	00004097          	auipc	ra,0x4
     846:	3f6080e7          	jalr	1014(ra) # 4c38 <printf>
    exit(1);
     84a:	4505                	li	a0,1
     84c:	00004097          	auipc	ra,0x4
     850:	064080e7          	jalr	100(ra) # 48b0 <exit>
    printf("%s: open unlinkread failed\n", s);
     854:	85ce                	mv	a1,s3
     856:	00005517          	auipc	a0,0x5
     85a:	b7a50513          	addi	a0,a0,-1158 # 53d0 <malloc+0x6da>
     85e:	00004097          	auipc	ra,0x4
     862:	3da080e7          	jalr	986(ra) # 4c38 <printf>
    exit(1);
     866:	4505                	li	a0,1
     868:	00004097          	auipc	ra,0x4
     86c:	048080e7          	jalr	72(ra) # 48b0 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     870:	85ce                	mv	a1,s3
     872:	00005517          	auipc	a0,0x5
     876:	b7e50513          	addi	a0,a0,-1154 # 53f0 <malloc+0x6fa>
     87a:	00004097          	auipc	ra,0x4
     87e:	3be080e7          	jalr	958(ra) # 4c38 <printf>
    exit(1);
     882:	4505                	li	a0,1
     884:	00004097          	auipc	ra,0x4
     888:	02c080e7          	jalr	44(ra) # 48b0 <exit>
    printf("%s: unlinkread read failed", s);
     88c:	85ce                	mv	a1,s3
     88e:	00005517          	auipc	a0,0x5
     892:	b8a50513          	addi	a0,a0,-1142 # 5418 <malloc+0x722>
     896:	00004097          	auipc	ra,0x4
     89a:	3a2080e7          	jalr	930(ra) # 4c38 <printf>
    exit(1);
     89e:	4505                	li	a0,1
     8a0:	00004097          	auipc	ra,0x4
     8a4:	010080e7          	jalr	16(ra) # 48b0 <exit>
    printf("%s: unlinkread wrong data\n", s);
     8a8:	85ce                	mv	a1,s3
     8aa:	00005517          	auipc	a0,0x5
     8ae:	b8e50513          	addi	a0,a0,-1138 # 5438 <malloc+0x742>
     8b2:	00004097          	auipc	ra,0x4
     8b6:	386080e7          	jalr	902(ra) # 4c38 <printf>
    exit(1);
     8ba:	4505                	li	a0,1
     8bc:	00004097          	auipc	ra,0x4
     8c0:	ff4080e7          	jalr	-12(ra) # 48b0 <exit>
    printf("%s: unlinkread write failed\n", s);
     8c4:	85ce                	mv	a1,s3
     8c6:	00005517          	auipc	a0,0x5
     8ca:	b9250513          	addi	a0,a0,-1134 # 5458 <malloc+0x762>
     8ce:	00004097          	auipc	ra,0x4
     8d2:	36a080e7          	jalr	874(ra) # 4c38 <printf>
    exit(1);
     8d6:	4505                	li	a0,1
     8d8:	00004097          	auipc	ra,0x4
     8dc:	fd8080e7          	jalr	-40(ra) # 48b0 <exit>

00000000000008e0 <bigwrite>:
}

// test writes that are larger than the log.
void
bigwrite(char *s)
{
     8e0:	715d                	addi	sp,sp,-80
     8e2:	e486                	sd	ra,72(sp)
     8e4:	e0a2                	sd	s0,64(sp)
     8e6:	fc26                	sd	s1,56(sp)
     8e8:	f84a                	sd	s2,48(sp)
     8ea:	f44e                	sd	s3,40(sp)
     8ec:	f052                	sd	s4,32(sp)
     8ee:	ec56                	sd	s5,24(sp)
     8f0:	e85a                	sd	s6,16(sp)
     8f2:	e45e                	sd	s7,8(sp)
     8f4:	0880                	addi	s0,sp,80
     8f6:	8baa                	mv	s7,a0
  int fd, sz;

  unlink("bigwrite");
     8f8:	00004517          	auipc	a0,0x4
     8fc:	65050513          	addi	a0,a0,1616 # 4f48 <malloc+0x252>
     900:	00004097          	auipc	ra,0x4
     904:	000080e7          	jalr	ra # 4900 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     908:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     90c:	00004a97          	auipc	s5,0x4
     910:	63ca8a93          	addi	s5,s5,1596 # 4f48 <malloc+0x252>
      printf("%s: cannot create bigwrite\n", s);
      exit(1);
    }
    int i;
    for(i = 0; i < 2; i++){
      int cc = write(fd, buf, sz);
     914:	00009a17          	auipc	s4,0x9
     918:	f0ca0a13          	addi	s4,s4,-244 # 9820 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     91c:	6b0d                	lui	s6,0x3
     91e:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x3ed>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     922:	20200593          	li	a1,514
     926:	8556                	mv	a0,s5
     928:	00004097          	auipc	ra,0x4
     92c:	fc8080e7          	jalr	-56(ra) # 48f0 <open>
     930:	892a                	mv	s2,a0
    if(fd < 0){
     932:	04054d63          	bltz	a0,98c <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     936:	8626                	mv	a2,s1
     938:	85d2                	mv	a1,s4
     93a:	00004097          	auipc	ra,0x4
     93e:	f96080e7          	jalr	-106(ra) # 48d0 <write>
     942:	89aa                	mv	s3,a0
      if(cc != sz){
     944:	06a49463          	bne	s1,a0,9ac <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     948:	8626                	mv	a2,s1
     94a:	85d2                	mv	a1,s4
     94c:	854a                	mv	a0,s2
     94e:	00004097          	auipc	ra,0x4
     952:	f82080e7          	jalr	-126(ra) # 48d0 <write>
      if(cc != sz){
     956:	04951963          	bne	a0,s1,9a8 <bigwrite+0xc8>
        printf("%s: write(%d) ret %d\n", s, sz, cc);
        exit(1);
      }
    }
    close(fd);
     95a:	854a                	mv	a0,s2
     95c:	00004097          	auipc	ra,0x4
     960:	f7c080e7          	jalr	-132(ra) # 48d8 <close>
    unlink("bigwrite");
     964:	8556                	mv	a0,s5
     966:	00004097          	auipc	ra,0x4
     96a:	f9a080e7          	jalr	-102(ra) # 4900 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     96e:	1d74849b          	addiw	s1,s1,471
     972:	fb6498e3          	bne	s1,s6,922 <bigwrite+0x42>
  }
}
     976:	60a6                	ld	ra,72(sp)
     978:	6406                	ld	s0,64(sp)
     97a:	74e2                	ld	s1,56(sp)
     97c:	7942                	ld	s2,48(sp)
     97e:	79a2                	ld	s3,40(sp)
     980:	7a02                	ld	s4,32(sp)
     982:	6ae2                	ld	s5,24(sp)
     984:	6b42                	ld	s6,16(sp)
     986:	6ba2                	ld	s7,8(sp)
     988:	6161                	addi	sp,sp,80
     98a:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     98c:	85de                	mv	a1,s7
     98e:	00005517          	auipc	a0,0x5
     992:	aea50513          	addi	a0,a0,-1302 # 5478 <malloc+0x782>
     996:	00004097          	auipc	ra,0x4
     99a:	2a2080e7          	jalr	674(ra) # 4c38 <printf>
      exit(1);
     99e:	4505                	li	a0,1
     9a0:	00004097          	auipc	ra,0x4
     9a4:	f10080e7          	jalr	-240(ra) # 48b0 <exit>
     9a8:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     9aa:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     9ac:	86ce                	mv	a3,s3
     9ae:	8626                	mv	a2,s1
     9b0:	85de                	mv	a1,s7
     9b2:	00005517          	auipc	a0,0x5
     9b6:	ae650513          	addi	a0,a0,-1306 # 5498 <malloc+0x7a2>
     9ba:	00004097          	auipc	ra,0x4
     9be:	27e080e7          	jalr	638(ra) # 4c38 <printf>
        exit(1);
     9c2:	4505                	li	a0,1
     9c4:	00004097          	auipc	ra,0x4
     9c8:	eec080e7          	jalr	-276(ra) # 48b0 <exit>

00000000000009cc <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
     9cc:	00006797          	auipc	a5,0x6
     9d0:	74478793          	addi	a5,a5,1860 # 7110 <uninit>
     9d4:	00009697          	auipc	a3,0x9
     9d8:	e4c68693          	addi	a3,a3,-436 # 9820 <buf>
    if(uninit[i] != '\0'){
     9dc:	0007c703          	lbu	a4,0(a5)
     9e0:	e709                	bnez	a4,9ea <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
     9e2:	0785                	addi	a5,a5,1
     9e4:	fed79ce3          	bne	a5,a3,9dc <bsstest+0x10>
     9e8:	8082                	ret
{
     9ea:	1141                	addi	sp,sp,-16
     9ec:	e406                	sd	ra,8(sp)
     9ee:	e022                	sd	s0,0(sp)
     9f0:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
     9f2:	85aa                	mv	a1,a0
     9f4:	00005517          	auipc	a0,0x5
     9f8:	abc50513          	addi	a0,a0,-1348 # 54b0 <malloc+0x7ba>
     9fc:	00004097          	auipc	ra,0x4
     a00:	23c080e7          	jalr	572(ra) # 4c38 <printf>
      exit(1);
     a04:	4505                	li	a0,1
     a06:	00004097          	auipc	ra,0x4
     a0a:	eaa080e7          	jalr	-342(ra) # 48b0 <exit>

0000000000000a0e <truncate3>:
{
     a0e:	7159                	addi	sp,sp,-112
     a10:	f486                	sd	ra,104(sp)
     a12:	f0a2                	sd	s0,96(sp)
     a14:	eca6                	sd	s1,88(sp)
     a16:	e8ca                	sd	s2,80(sp)
     a18:	e4ce                	sd	s3,72(sp)
     a1a:	e0d2                	sd	s4,64(sp)
     a1c:	fc56                	sd	s5,56(sp)
     a1e:	1880                	addi	s0,sp,112
     a20:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
     a22:	60100593          	li	a1,1537
     a26:	00004517          	auipc	a0,0x4
     a2a:	65a50513          	addi	a0,a0,1626 # 5080 <malloc+0x38a>
     a2e:	00004097          	auipc	ra,0x4
     a32:	ec2080e7          	jalr	-318(ra) # 48f0 <open>
     a36:	00004097          	auipc	ra,0x4
     a3a:	ea2080e7          	jalr	-350(ra) # 48d8 <close>
  pid = fork();
     a3e:	00004097          	auipc	ra,0x4
     a42:	e6a080e7          	jalr	-406(ra) # 48a8 <fork>
  if(pid < 0){
     a46:	08054063          	bltz	a0,ac6 <truncate3+0xb8>
  if(pid == 0){
     a4a:	e969                	bnez	a0,b1c <truncate3+0x10e>
     a4c:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
     a50:	00004a17          	auipc	s4,0x4
     a54:	630a0a13          	addi	s4,s4,1584 # 5080 <malloc+0x38a>
      int n = write(fd, "1234567890", 10);
     a58:	00005a97          	auipc	s5,0x5
     a5c:	aa0a8a93          	addi	s5,s5,-1376 # 54f8 <malloc+0x802>
      int fd = open("truncfile", O_WRONLY);
     a60:	4585                	li	a1,1
     a62:	8552                	mv	a0,s4
     a64:	00004097          	auipc	ra,0x4
     a68:	e8c080e7          	jalr	-372(ra) # 48f0 <open>
     a6c:	84aa                	mv	s1,a0
      if(fd < 0){
     a6e:	06054a63          	bltz	a0,ae2 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
     a72:	4629                	li	a2,10
     a74:	85d6                	mv	a1,s5
     a76:	00004097          	auipc	ra,0x4
     a7a:	e5a080e7          	jalr	-422(ra) # 48d0 <write>
      if(n != 10){
     a7e:	47a9                	li	a5,10
     a80:	06f51f63          	bne	a0,a5,afe <truncate3+0xf0>
      close(fd);
     a84:	8526                	mv	a0,s1
     a86:	00004097          	auipc	ra,0x4
     a8a:	e52080e7          	jalr	-430(ra) # 48d8 <close>
      fd = open("truncfile", O_RDONLY);
     a8e:	4581                	li	a1,0
     a90:	8552                	mv	a0,s4
     a92:	00004097          	auipc	ra,0x4
     a96:	e5e080e7          	jalr	-418(ra) # 48f0 <open>
     a9a:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
     a9c:	02000613          	li	a2,32
     aa0:	f9840593          	addi	a1,s0,-104
     aa4:	00004097          	auipc	ra,0x4
     aa8:	e24080e7          	jalr	-476(ra) # 48c8 <read>
      close(fd);
     aac:	8526                	mv	a0,s1
     aae:	00004097          	auipc	ra,0x4
     ab2:	e2a080e7          	jalr	-470(ra) # 48d8 <close>
    for(int i = 0; i < 100; i++){
     ab6:	39fd                	addiw	s3,s3,-1
     ab8:	fa0994e3          	bnez	s3,a60 <truncate3+0x52>
    exit(0);
     abc:	4501                	li	a0,0
     abe:	00004097          	auipc	ra,0x4
     ac2:	df2080e7          	jalr	-526(ra) # 48b0 <exit>
    printf("%s: fork failed\n", s);
     ac6:	85ca                	mv	a1,s2
     ac8:	00005517          	auipc	a0,0x5
     acc:	a0050513          	addi	a0,a0,-1536 # 54c8 <malloc+0x7d2>
     ad0:	00004097          	auipc	ra,0x4
     ad4:	168080e7          	jalr	360(ra) # 4c38 <printf>
    exit(1);
     ad8:	4505                	li	a0,1
     ada:	00004097          	auipc	ra,0x4
     ade:	dd6080e7          	jalr	-554(ra) # 48b0 <exit>
        printf("%s: open failed\n", s);
     ae2:	85ca                	mv	a1,s2
     ae4:	00005517          	auipc	a0,0x5
     ae8:	9fc50513          	addi	a0,a0,-1540 # 54e0 <malloc+0x7ea>
     aec:	00004097          	auipc	ra,0x4
     af0:	14c080e7          	jalr	332(ra) # 4c38 <printf>
        exit(1);
     af4:	4505                	li	a0,1
     af6:	00004097          	auipc	ra,0x4
     afa:	dba080e7          	jalr	-582(ra) # 48b0 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
     afe:	862a                	mv	a2,a0
     b00:	85ca                	mv	a1,s2
     b02:	00005517          	auipc	a0,0x5
     b06:	a0650513          	addi	a0,a0,-1530 # 5508 <malloc+0x812>
     b0a:	00004097          	auipc	ra,0x4
     b0e:	12e080e7          	jalr	302(ra) # 4c38 <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00004097          	auipc	ra,0x4
     b18:	d9c080e7          	jalr	-612(ra) # 48b0 <exit>
     b1c:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     b20:	00004a17          	auipc	s4,0x4
     b24:	560a0a13          	addi	s4,s4,1376 # 5080 <malloc+0x38a>
    int n = write(fd, "xxx", 3);
     b28:	00005a97          	auipc	s5,0x5
     b2c:	a00a8a93          	addi	s5,s5,-1536 # 5528 <malloc+0x832>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     b30:	60100593          	li	a1,1537
     b34:	8552                	mv	a0,s4
     b36:	00004097          	auipc	ra,0x4
     b3a:	dba080e7          	jalr	-582(ra) # 48f0 <open>
     b3e:	84aa                	mv	s1,a0
    if(fd < 0){
     b40:	04054763          	bltz	a0,b8e <truncate3+0x180>
    int n = write(fd, "xxx", 3);
     b44:	460d                	li	a2,3
     b46:	85d6                	mv	a1,s5
     b48:	00004097          	auipc	ra,0x4
     b4c:	d88080e7          	jalr	-632(ra) # 48d0 <write>
    if(n != 3){
     b50:	478d                	li	a5,3
     b52:	04f51c63          	bne	a0,a5,baa <truncate3+0x19c>
    close(fd);
     b56:	8526                	mv	a0,s1
     b58:	00004097          	auipc	ra,0x4
     b5c:	d80080e7          	jalr	-640(ra) # 48d8 <close>
  for(int i = 0; i < 150; i++){
     b60:	39fd                	addiw	s3,s3,-1
     b62:	fc0997e3          	bnez	s3,b30 <truncate3+0x122>
  wait(&xstatus);
     b66:	fbc40513          	addi	a0,s0,-68
     b6a:	00004097          	auipc	ra,0x4
     b6e:	d4e080e7          	jalr	-690(ra) # 48b8 <wait>
  unlink("truncfile");
     b72:	00004517          	auipc	a0,0x4
     b76:	50e50513          	addi	a0,a0,1294 # 5080 <malloc+0x38a>
     b7a:	00004097          	auipc	ra,0x4
     b7e:	d86080e7          	jalr	-634(ra) # 4900 <unlink>
  exit(xstatus);
     b82:	fbc42503          	lw	a0,-68(s0)
     b86:	00004097          	auipc	ra,0x4
     b8a:	d2a080e7          	jalr	-726(ra) # 48b0 <exit>
      printf("%s: open failed\n", s);
     b8e:	85ca                	mv	a1,s2
     b90:	00005517          	auipc	a0,0x5
     b94:	95050513          	addi	a0,a0,-1712 # 54e0 <malloc+0x7ea>
     b98:	00004097          	auipc	ra,0x4
     b9c:	0a0080e7          	jalr	160(ra) # 4c38 <printf>
      exit(1);
     ba0:	4505                	li	a0,1
     ba2:	00004097          	auipc	ra,0x4
     ba6:	d0e080e7          	jalr	-754(ra) # 48b0 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
     baa:	862a                	mv	a2,a0
     bac:	85ca                	mv	a1,s2
     bae:	00005517          	auipc	a0,0x5
     bb2:	98250513          	addi	a0,a0,-1662 # 5530 <malloc+0x83a>
     bb6:	00004097          	auipc	ra,0x4
     bba:	082080e7          	jalr	130(ra) # 4c38 <printf>
      exit(1);
     bbe:	4505                	li	a0,1
     bc0:	00004097          	auipc	ra,0x4
     bc4:	cf0080e7          	jalr	-784(ra) # 48b0 <exit>

0000000000000bc8 <exitwait>:
{
     bc8:	7139                	addi	sp,sp,-64
     bca:	fc06                	sd	ra,56(sp)
     bcc:	f822                	sd	s0,48(sp)
     bce:	f426                	sd	s1,40(sp)
     bd0:	f04a                	sd	s2,32(sp)
     bd2:	ec4e                	sd	s3,24(sp)
     bd4:	e852                	sd	s4,16(sp)
     bd6:	0080                	addi	s0,sp,64
     bd8:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
     bda:	4901                	li	s2,0
     bdc:	06400993          	li	s3,100
    pid = fork();
     be0:	00004097          	auipc	ra,0x4
     be4:	cc8080e7          	jalr	-824(ra) # 48a8 <fork>
     be8:	84aa                	mv	s1,a0
    if(pid < 0){
     bea:	02054a63          	bltz	a0,c1e <exitwait+0x56>
    if(pid){
     bee:	c151                	beqz	a0,c72 <exitwait+0xaa>
      if(wait(&xstate) != pid){
     bf0:	fcc40513          	addi	a0,s0,-52
     bf4:	00004097          	auipc	ra,0x4
     bf8:	cc4080e7          	jalr	-828(ra) # 48b8 <wait>
     bfc:	02951f63          	bne	a0,s1,c3a <exitwait+0x72>
      if(i != xstate) {
     c00:	fcc42783          	lw	a5,-52(s0)
     c04:	05279963          	bne	a5,s2,c56 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
     c08:	2905                	addiw	s2,s2,1
     c0a:	fd391be3          	bne	s2,s3,be0 <exitwait+0x18>
}
     c0e:	70e2                	ld	ra,56(sp)
     c10:	7442                	ld	s0,48(sp)
     c12:	74a2                	ld	s1,40(sp)
     c14:	7902                	ld	s2,32(sp)
     c16:	69e2                	ld	s3,24(sp)
     c18:	6a42                	ld	s4,16(sp)
     c1a:	6121                	addi	sp,sp,64
     c1c:	8082                	ret
      printf("%s: fork failed\n", s);
     c1e:	85d2                	mv	a1,s4
     c20:	00005517          	auipc	a0,0x5
     c24:	8a850513          	addi	a0,a0,-1880 # 54c8 <malloc+0x7d2>
     c28:	00004097          	auipc	ra,0x4
     c2c:	010080e7          	jalr	16(ra) # 4c38 <printf>
      exit(1);
     c30:	4505                	li	a0,1
     c32:	00004097          	auipc	ra,0x4
     c36:	c7e080e7          	jalr	-898(ra) # 48b0 <exit>
        printf("%s: wait wrong pid\n", s);
     c3a:	85d2                	mv	a1,s4
     c3c:	00005517          	auipc	a0,0x5
     c40:	91450513          	addi	a0,a0,-1772 # 5550 <malloc+0x85a>
     c44:	00004097          	auipc	ra,0x4
     c48:	ff4080e7          	jalr	-12(ra) # 4c38 <printf>
        exit(1);
     c4c:	4505                	li	a0,1
     c4e:	00004097          	auipc	ra,0x4
     c52:	c62080e7          	jalr	-926(ra) # 48b0 <exit>
        printf("%s: wait wrong exit status\n", s);
     c56:	85d2                	mv	a1,s4
     c58:	00005517          	auipc	a0,0x5
     c5c:	91050513          	addi	a0,a0,-1776 # 5568 <malloc+0x872>
     c60:	00004097          	auipc	ra,0x4
     c64:	fd8080e7          	jalr	-40(ra) # 4c38 <printf>
        exit(1);
     c68:	4505                	li	a0,1
     c6a:	00004097          	auipc	ra,0x4
     c6e:	c46080e7          	jalr	-954(ra) # 48b0 <exit>
      exit(i);
     c72:	854a                	mv	a0,s2
     c74:	00004097          	auipc	ra,0x4
     c78:	c3c080e7          	jalr	-964(ra) # 48b0 <exit>

0000000000000c7c <twochildren>:
{
     c7c:	1101                	addi	sp,sp,-32
     c7e:	ec06                	sd	ra,24(sp)
     c80:	e822                	sd	s0,16(sp)
     c82:	e426                	sd	s1,8(sp)
     c84:	e04a                	sd	s2,0(sp)
     c86:	1000                	addi	s0,sp,32
     c88:	892a                	mv	s2,a0
     c8a:	3e800493          	li	s1,1000
    int pid1 = fork();
     c8e:	00004097          	auipc	ra,0x4
     c92:	c1a080e7          	jalr	-998(ra) # 48a8 <fork>
    if(pid1 < 0){
     c96:	02054c63          	bltz	a0,cce <twochildren+0x52>
    if(pid1 == 0){
     c9a:	c921                	beqz	a0,cea <twochildren+0x6e>
      int pid2 = fork();
     c9c:	00004097          	auipc	ra,0x4
     ca0:	c0c080e7          	jalr	-1012(ra) # 48a8 <fork>
      if(pid2 < 0){
     ca4:	04054763          	bltz	a0,cf2 <twochildren+0x76>
      if(pid2 == 0){
     ca8:	c13d                	beqz	a0,d0e <twochildren+0x92>
        wait(0);
     caa:	4501                	li	a0,0
     cac:	00004097          	auipc	ra,0x4
     cb0:	c0c080e7          	jalr	-1012(ra) # 48b8 <wait>
        wait(0);
     cb4:	4501                	li	a0,0
     cb6:	00004097          	auipc	ra,0x4
     cba:	c02080e7          	jalr	-1022(ra) # 48b8 <wait>
  for(int i = 0; i < 1000; i++){
     cbe:	34fd                	addiw	s1,s1,-1
     cc0:	f4f9                	bnez	s1,c8e <twochildren+0x12>
}
     cc2:	60e2                	ld	ra,24(sp)
     cc4:	6442                	ld	s0,16(sp)
     cc6:	64a2                	ld	s1,8(sp)
     cc8:	6902                	ld	s2,0(sp)
     cca:	6105                	addi	sp,sp,32
     ccc:	8082                	ret
      printf("%s: fork failed\n", s);
     cce:	85ca                	mv	a1,s2
     cd0:	00004517          	auipc	a0,0x4
     cd4:	7f850513          	addi	a0,a0,2040 # 54c8 <malloc+0x7d2>
     cd8:	00004097          	auipc	ra,0x4
     cdc:	f60080e7          	jalr	-160(ra) # 4c38 <printf>
      exit(1);
     ce0:	4505                	li	a0,1
     ce2:	00004097          	auipc	ra,0x4
     ce6:	bce080e7          	jalr	-1074(ra) # 48b0 <exit>
      exit(0);
     cea:	00004097          	auipc	ra,0x4
     cee:	bc6080e7          	jalr	-1082(ra) # 48b0 <exit>
        printf("%s: fork failed\n", s);
     cf2:	85ca                	mv	a1,s2
     cf4:	00004517          	auipc	a0,0x4
     cf8:	7d450513          	addi	a0,a0,2004 # 54c8 <malloc+0x7d2>
     cfc:	00004097          	auipc	ra,0x4
     d00:	f3c080e7          	jalr	-196(ra) # 4c38 <printf>
        exit(1);
     d04:	4505                	li	a0,1
     d06:	00004097          	auipc	ra,0x4
     d0a:	baa080e7          	jalr	-1110(ra) # 48b0 <exit>
        exit(0);
     d0e:	00004097          	auipc	ra,0x4
     d12:	ba2080e7          	jalr	-1118(ra) # 48b0 <exit>

0000000000000d16 <forkfork>:
{
     d16:	7179                	addi	sp,sp,-48
     d18:	f406                	sd	ra,40(sp)
     d1a:	f022                	sd	s0,32(sp)
     d1c:	ec26                	sd	s1,24(sp)
     d1e:	1800                	addi	s0,sp,48
     d20:	84aa                	mv	s1,a0
    int pid = fork();
     d22:	00004097          	auipc	ra,0x4
     d26:	b86080e7          	jalr	-1146(ra) # 48a8 <fork>
    if(pid < 0){
     d2a:	04054163          	bltz	a0,d6c <forkfork+0x56>
    if(pid == 0){
     d2e:	cd29                	beqz	a0,d88 <forkfork+0x72>
    int pid = fork();
     d30:	00004097          	auipc	ra,0x4
     d34:	b78080e7          	jalr	-1160(ra) # 48a8 <fork>
    if(pid < 0){
     d38:	02054a63          	bltz	a0,d6c <forkfork+0x56>
    if(pid == 0){
     d3c:	c531                	beqz	a0,d88 <forkfork+0x72>
    wait(&xstatus);
     d3e:	fdc40513          	addi	a0,s0,-36
     d42:	00004097          	auipc	ra,0x4
     d46:	b76080e7          	jalr	-1162(ra) # 48b8 <wait>
    if(xstatus != 0) {
     d4a:	fdc42783          	lw	a5,-36(s0)
     d4e:	ebbd                	bnez	a5,dc4 <forkfork+0xae>
    wait(&xstatus);
     d50:	fdc40513          	addi	a0,s0,-36
     d54:	00004097          	auipc	ra,0x4
     d58:	b64080e7          	jalr	-1180(ra) # 48b8 <wait>
    if(xstatus != 0) {
     d5c:	fdc42783          	lw	a5,-36(s0)
     d60:	e3b5                	bnez	a5,dc4 <forkfork+0xae>
}
     d62:	70a2                	ld	ra,40(sp)
     d64:	7402                	ld	s0,32(sp)
     d66:	64e2                	ld	s1,24(sp)
     d68:	6145                	addi	sp,sp,48
     d6a:	8082                	ret
      printf("%s: fork failed", s);
     d6c:	85a6                	mv	a1,s1
     d6e:	00005517          	auipc	a0,0x5
     d72:	81a50513          	addi	a0,a0,-2022 # 5588 <malloc+0x892>
     d76:	00004097          	auipc	ra,0x4
     d7a:	ec2080e7          	jalr	-318(ra) # 4c38 <printf>
      exit(1);
     d7e:	4505                	li	a0,1
     d80:	00004097          	auipc	ra,0x4
     d84:	b30080e7          	jalr	-1232(ra) # 48b0 <exit>
{
     d88:	0c800493          	li	s1,200
        int pid1 = fork();
     d8c:	00004097          	auipc	ra,0x4
     d90:	b1c080e7          	jalr	-1252(ra) # 48a8 <fork>
        if(pid1 < 0){
     d94:	00054f63          	bltz	a0,db2 <forkfork+0x9c>
        if(pid1 == 0){
     d98:	c115                	beqz	a0,dbc <forkfork+0xa6>
        wait(0);
     d9a:	4501                	li	a0,0
     d9c:	00004097          	auipc	ra,0x4
     da0:	b1c080e7          	jalr	-1252(ra) # 48b8 <wait>
      for(int j = 0; j < 200; j++){
     da4:	34fd                	addiw	s1,s1,-1
     da6:	f0fd                	bnez	s1,d8c <forkfork+0x76>
      exit(0);
     da8:	4501                	li	a0,0
     daa:	00004097          	auipc	ra,0x4
     dae:	b06080e7          	jalr	-1274(ra) # 48b0 <exit>
          exit(1);
     db2:	4505                	li	a0,1
     db4:	00004097          	auipc	ra,0x4
     db8:	afc080e7          	jalr	-1284(ra) # 48b0 <exit>
          exit(0);
     dbc:	00004097          	auipc	ra,0x4
     dc0:	af4080e7          	jalr	-1292(ra) # 48b0 <exit>
      printf("%s: fork in child failed", s);
     dc4:	85a6                	mv	a1,s1
     dc6:	00004517          	auipc	a0,0x4
     dca:	7d250513          	addi	a0,a0,2002 # 5598 <malloc+0x8a2>
     dce:	00004097          	auipc	ra,0x4
     dd2:	e6a080e7          	jalr	-406(ra) # 4c38 <printf>
      exit(1);
     dd6:	4505                	li	a0,1
     dd8:	00004097          	auipc	ra,0x4
     ddc:	ad8080e7          	jalr	-1320(ra) # 48b0 <exit>

0000000000000de0 <reparent2>:
{
     de0:	1101                	addi	sp,sp,-32
     de2:	ec06                	sd	ra,24(sp)
     de4:	e822                	sd	s0,16(sp)
     de6:	e426                	sd	s1,8(sp)
     de8:	1000                	addi	s0,sp,32
     dea:	32000493          	li	s1,800
    int pid1 = fork();
     dee:	00004097          	auipc	ra,0x4
     df2:	aba080e7          	jalr	-1350(ra) # 48a8 <fork>
    if(pid1 < 0){
     df6:	00054f63          	bltz	a0,e14 <reparent2+0x34>
    if(pid1 == 0){
     dfa:	c915                	beqz	a0,e2e <reparent2+0x4e>
    wait(0);
     dfc:	4501                	li	a0,0
     dfe:	00004097          	auipc	ra,0x4
     e02:	aba080e7          	jalr	-1350(ra) # 48b8 <wait>
  for(int i = 0; i < 800; i++){
     e06:	34fd                	addiw	s1,s1,-1
     e08:	f0fd                	bnez	s1,dee <reparent2+0xe>
  exit(0);
     e0a:	4501                	li	a0,0
     e0c:	00004097          	auipc	ra,0x4
     e10:	aa4080e7          	jalr	-1372(ra) # 48b0 <exit>
      printf("fork failed\n");
     e14:	00005517          	auipc	a0,0x5
     e18:	e4450513          	addi	a0,a0,-444 # 5c58 <malloc+0xf62>
     e1c:	00004097          	auipc	ra,0x4
     e20:	e1c080e7          	jalr	-484(ra) # 4c38 <printf>
      exit(1);
     e24:	4505                	li	a0,1
     e26:	00004097          	auipc	ra,0x4
     e2a:	a8a080e7          	jalr	-1398(ra) # 48b0 <exit>
      fork();
     e2e:	00004097          	auipc	ra,0x4
     e32:	a7a080e7          	jalr	-1414(ra) # 48a8 <fork>
      fork();
     e36:	00004097          	auipc	ra,0x4
     e3a:	a72080e7          	jalr	-1422(ra) # 48a8 <fork>
      exit(0);
     e3e:	4501                	li	a0,0
     e40:	00004097          	auipc	ra,0x4
     e44:	a70080e7          	jalr	-1424(ra) # 48b0 <exit>

0000000000000e48 <createdelete>:
{
     e48:	7175                	addi	sp,sp,-144
     e4a:	e506                	sd	ra,136(sp)
     e4c:	e122                	sd	s0,128(sp)
     e4e:	fca6                	sd	s1,120(sp)
     e50:	f8ca                	sd	s2,112(sp)
     e52:	f4ce                	sd	s3,104(sp)
     e54:	f0d2                	sd	s4,96(sp)
     e56:	ecd6                	sd	s5,88(sp)
     e58:	e8da                	sd	s6,80(sp)
     e5a:	e4de                	sd	s7,72(sp)
     e5c:	e0e2                	sd	s8,64(sp)
     e5e:	fc66                	sd	s9,56(sp)
     e60:	0900                	addi	s0,sp,144
     e62:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
     e64:	4901                	li	s2,0
     e66:	4991                	li	s3,4
    pid = fork();
     e68:	00004097          	auipc	ra,0x4
     e6c:	a40080e7          	jalr	-1472(ra) # 48a8 <fork>
     e70:	84aa                	mv	s1,a0
    if(pid < 0){
     e72:	02054f63          	bltz	a0,eb0 <createdelete+0x68>
    if(pid == 0){
     e76:	c939                	beqz	a0,ecc <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
     e78:	2905                	addiw	s2,s2,1
     e7a:	ff3917e3          	bne	s2,s3,e68 <createdelete+0x20>
     e7e:	4491                	li	s1,4
    wait(&xstatus);
     e80:	f7c40513          	addi	a0,s0,-132
     e84:	00004097          	auipc	ra,0x4
     e88:	a34080e7          	jalr	-1484(ra) # 48b8 <wait>
    if(xstatus != 0)
     e8c:	f7c42903          	lw	s2,-132(s0)
     e90:	0e091263          	bnez	s2,f74 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
     e94:	34fd                	addiw	s1,s1,-1
     e96:	f4ed                	bnez	s1,e80 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
     e98:	f8040123          	sb	zero,-126(s0)
     e9c:	03000993          	li	s3,48
     ea0:	5a7d                	li	s4,-1
     ea2:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
     ea6:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
     ea8:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
     eaa:	07400a93          	li	s5,116
     eae:	a29d                	j	1014 <createdelete+0x1cc>
      printf("fork failed\n", s);
     eb0:	85e6                	mv	a1,s9
     eb2:	00005517          	auipc	a0,0x5
     eb6:	da650513          	addi	a0,a0,-602 # 5c58 <malloc+0xf62>
     eba:	00004097          	auipc	ra,0x4
     ebe:	d7e080e7          	jalr	-642(ra) # 4c38 <printf>
      exit(1);
     ec2:	4505                	li	a0,1
     ec4:	00004097          	auipc	ra,0x4
     ec8:	9ec080e7          	jalr	-1556(ra) # 48b0 <exit>
      name[0] = 'p' + pi;
     ecc:	0709091b          	addiw	s2,s2,112
     ed0:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
     ed4:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
     ed8:	4951                	li	s2,20
     eda:	a015                	j	efe <createdelete+0xb6>
          printf("%s: create failed\n", s);
     edc:	85e6                	mv	a1,s9
     ede:	00004517          	auipc	a0,0x4
     ee2:	6da50513          	addi	a0,a0,1754 # 55b8 <malloc+0x8c2>
     ee6:	00004097          	auipc	ra,0x4
     eea:	d52080e7          	jalr	-686(ra) # 4c38 <printf>
          exit(1);
     eee:	4505                	li	a0,1
     ef0:	00004097          	auipc	ra,0x4
     ef4:	9c0080e7          	jalr	-1600(ra) # 48b0 <exit>
      for(i = 0; i < N; i++){
     ef8:	2485                	addiw	s1,s1,1
     efa:	07248863          	beq	s1,s2,f6a <createdelete+0x122>
        name[1] = '0' + i;
     efe:	0304879b          	addiw	a5,s1,48
     f02:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
     f06:	20200593          	li	a1,514
     f0a:	f8040513          	addi	a0,s0,-128
     f0e:	00004097          	auipc	ra,0x4
     f12:	9e2080e7          	jalr	-1566(ra) # 48f0 <open>
        if(fd < 0){
     f16:	fc0543e3          	bltz	a0,edc <createdelete+0x94>
        close(fd);
     f1a:	00004097          	auipc	ra,0x4
     f1e:	9be080e7          	jalr	-1602(ra) # 48d8 <close>
        if(i > 0 && (i % 2 ) == 0){
     f22:	fc905be3          	blez	s1,ef8 <createdelete+0xb0>
     f26:	0014f793          	andi	a5,s1,1
     f2a:	f7f9                	bnez	a5,ef8 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
     f2c:	01f4d79b          	srliw	a5,s1,0x1f
     f30:	9fa5                	addw	a5,a5,s1
     f32:	4017d79b          	sraiw	a5,a5,0x1
     f36:	0307879b          	addiw	a5,a5,48
     f3a:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
     f3e:	f8040513          	addi	a0,s0,-128
     f42:	00004097          	auipc	ra,0x4
     f46:	9be080e7          	jalr	-1602(ra) # 4900 <unlink>
     f4a:	fa0557e3          	bgez	a0,ef8 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
     f4e:	85e6                	mv	a1,s9
     f50:	00004517          	auipc	a0,0x4
     f54:	68050513          	addi	a0,a0,1664 # 55d0 <malloc+0x8da>
     f58:	00004097          	auipc	ra,0x4
     f5c:	ce0080e7          	jalr	-800(ra) # 4c38 <printf>
            exit(1);
     f60:	4505                	li	a0,1
     f62:	00004097          	auipc	ra,0x4
     f66:	94e080e7          	jalr	-1714(ra) # 48b0 <exit>
      exit(0);
     f6a:	4501                	li	a0,0
     f6c:	00004097          	auipc	ra,0x4
     f70:	944080e7          	jalr	-1724(ra) # 48b0 <exit>
      exit(1);
     f74:	4505                	li	a0,1
     f76:	00004097          	auipc	ra,0x4
     f7a:	93a080e7          	jalr	-1734(ra) # 48b0 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
     f7e:	f8040613          	addi	a2,s0,-128
     f82:	85e6                	mv	a1,s9
     f84:	00004517          	auipc	a0,0x4
     f88:	66450513          	addi	a0,a0,1636 # 55e8 <malloc+0x8f2>
     f8c:	00004097          	auipc	ra,0x4
     f90:	cac080e7          	jalr	-852(ra) # 4c38 <printf>
        exit(1);
     f94:	4505                	li	a0,1
     f96:	00004097          	auipc	ra,0x4
     f9a:	91a080e7          	jalr	-1766(ra) # 48b0 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     f9e:	054b7163          	bgeu	s6,s4,fe0 <createdelete+0x198>
      if(fd >= 0)
     fa2:	02055a63          	bgez	a0,fd6 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
     fa6:	2485                	addiw	s1,s1,1
     fa8:	0ff4f493          	andi	s1,s1,255
     fac:	05548c63          	beq	s1,s5,1004 <createdelete+0x1bc>
      name[0] = 'p' + pi;
     fb0:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
     fb4:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
     fb8:	4581                	li	a1,0
     fba:	f8040513          	addi	a0,s0,-128
     fbe:	00004097          	auipc	ra,0x4
     fc2:	932080e7          	jalr	-1742(ra) # 48f0 <open>
      if((i == 0 || i >= N/2) && fd < 0){
     fc6:	00090463          	beqz	s2,fce <createdelete+0x186>
     fca:	fd2bdae3          	bge	s7,s2,f9e <createdelete+0x156>
     fce:	fa0548e3          	bltz	a0,f7e <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     fd2:	014b7963          	bgeu	s6,s4,fe4 <createdelete+0x19c>
        close(fd);
     fd6:	00004097          	auipc	ra,0x4
     fda:	902080e7          	jalr	-1790(ra) # 48d8 <close>
     fde:	b7e1                	j	fa6 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
     fe0:	fc0543e3          	bltz	a0,fa6 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
     fe4:	f8040613          	addi	a2,s0,-128
     fe8:	85e6                	mv	a1,s9
     fea:	00004517          	auipc	a0,0x4
     fee:	62650513          	addi	a0,a0,1574 # 5610 <malloc+0x91a>
     ff2:	00004097          	auipc	ra,0x4
     ff6:	c46080e7          	jalr	-954(ra) # 4c38 <printf>
        exit(1);
     ffa:	4505                	li	a0,1
     ffc:	00004097          	auipc	ra,0x4
    1000:	8b4080e7          	jalr	-1868(ra) # 48b0 <exit>
  for(i = 0; i < N; i++){
    1004:	2905                	addiw	s2,s2,1
    1006:	2a05                	addiw	s4,s4,1
    1008:	2985                	addiw	s3,s3,1
    100a:	0ff9f993          	andi	s3,s3,255
    100e:	47d1                	li	a5,20
    1010:	02f90a63          	beq	s2,a5,1044 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1014:	84e2                	mv	s1,s8
    1016:	bf69                	j	fb0 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1018:	2905                	addiw	s2,s2,1
    101a:	0ff97913          	andi	s2,s2,255
    101e:	2985                	addiw	s3,s3,1
    1020:	0ff9f993          	andi	s3,s3,255
    1024:	03490863          	beq	s2,s4,1054 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1028:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    102a:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    102e:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1032:	f8040513          	addi	a0,s0,-128
    1036:	00004097          	auipc	ra,0x4
    103a:	8ca080e7          	jalr	-1846(ra) # 4900 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    103e:	34fd                	addiw	s1,s1,-1
    1040:	f4ed                	bnez	s1,102a <createdelete+0x1e2>
    1042:	bfd9                	j	1018 <createdelete+0x1d0>
    1044:	03000993          	li	s3,48
    1048:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    104c:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    104e:	08400a13          	li	s4,132
    1052:	bfd9                	j	1028 <createdelete+0x1e0>
}
    1054:	60aa                	ld	ra,136(sp)
    1056:	640a                	ld	s0,128(sp)
    1058:	74e6                	ld	s1,120(sp)
    105a:	7946                	ld	s2,112(sp)
    105c:	79a6                	ld	s3,104(sp)
    105e:	7a06                	ld	s4,96(sp)
    1060:	6ae6                	ld	s5,88(sp)
    1062:	6b46                	ld	s6,80(sp)
    1064:	6ba6                	ld	s7,72(sp)
    1066:	6c06                	ld	s8,64(sp)
    1068:	7ce2                	ld	s9,56(sp)
    106a:	6149                	addi	sp,sp,144
    106c:	8082                	ret

000000000000106e <forktest>:
{
    106e:	7179                	addi	sp,sp,-48
    1070:	f406                	sd	ra,40(sp)
    1072:	f022                	sd	s0,32(sp)
    1074:	ec26                	sd	s1,24(sp)
    1076:	e84a                	sd	s2,16(sp)
    1078:	e44e                	sd	s3,8(sp)
    107a:	1800                	addi	s0,sp,48
    107c:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    107e:	4481                	li	s1,0
    1080:	3e800913          	li	s2,1000
    pid = fork();
    1084:	00004097          	auipc	ra,0x4
    1088:	824080e7          	jalr	-2012(ra) # 48a8 <fork>
    if(pid < 0)
    108c:	02054863          	bltz	a0,10bc <forktest+0x4e>
    if(pid == 0)
    1090:	c115                	beqz	a0,10b4 <forktest+0x46>
  for(n=0; n<N; n++){
    1092:	2485                	addiw	s1,s1,1
    1094:	ff2498e3          	bne	s1,s2,1084 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1098:	85ce                	mv	a1,s3
    109a:	00004517          	auipc	a0,0x4
    109e:	5b650513          	addi	a0,a0,1462 # 5650 <malloc+0x95a>
    10a2:	00004097          	auipc	ra,0x4
    10a6:	b96080e7          	jalr	-1130(ra) # 4c38 <printf>
    exit(1);
    10aa:	4505                	li	a0,1
    10ac:	00004097          	auipc	ra,0x4
    10b0:	804080e7          	jalr	-2044(ra) # 48b0 <exit>
      exit(0);
    10b4:	00003097          	auipc	ra,0x3
    10b8:	7fc080e7          	jalr	2044(ra) # 48b0 <exit>
  if (n == 0) {
    10bc:	cc9d                	beqz	s1,10fa <forktest+0x8c>
  if(n == N){
    10be:	3e800793          	li	a5,1000
    10c2:	fcf48be3          	beq	s1,a5,1098 <forktest+0x2a>
  for(; n > 0; n--){
    10c6:	00905b63          	blez	s1,10dc <forktest+0x6e>
    if(wait(0) < 0){
    10ca:	4501                	li	a0,0
    10cc:	00003097          	auipc	ra,0x3
    10d0:	7ec080e7          	jalr	2028(ra) # 48b8 <wait>
    10d4:	04054163          	bltz	a0,1116 <forktest+0xa8>
  for(; n > 0; n--){
    10d8:	34fd                	addiw	s1,s1,-1
    10da:	f8e5                	bnez	s1,10ca <forktest+0x5c>
  if(wait(0) != -1){
    10dc:	4501                	li	a0,0
    10de:	00003097          	auipc	ra,0x3
    10e2:	7da080e7          	jalr	2010(ra) # 48b8 <wait>
    10e6:	57fd                	li	a5,-1
    10e8:	04f51563          	bne	a0,a5,1132 <forktest+0xc4>
}
    10ec:	70a2                	ld	ra,40(sp)
    10ee:	7402                	ld	s0,32(sp)
    10f0:	64e2                	ld	s1,24(sp)
    10f2:	6942                	ld	s2,16(sp)
    10f4:	69a2                	ld	s3,8(sp)
    10f6:	6145                	addi	sp,sp,48
    10f8:	8082                	ret
    printf("%s: no fork at all!\n", s);
    10fa:	85ce                	mv	a1,s3
    10fc:	00004517          	auipc	a0,0x4
    1100:	53c50513          	addi	a0,a0,1340 # 5638 <malloc+0x942>
    1104:	00004097          	auipc	ra,0x4
    1108:	b34080e7          	jalr	-1228(ra) # 4c38 <printf>
    exit(1);
    110c:	4505                	li	a0,1
    110e:	00003097          	auipc	ra,0x3
    1112:	7a2080e7          	jalr	1954(ra) # 48b0 <exit>
      printf("%s: wait stopped early\n", s);
    1116:	85ce                	mv	a1,s3
    1118:	00004517          	auipc	a0,0x4
    111c:	56050513          	addi	a0,a0,1376 # 5678 <malloc+0x982>
    1120:	00004097          	auipc	ra,0x4
    1124:	b18080e7          	jalr	-1256(ra) # 4c38 <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	00003097          	auipc	ra,0x3
    112e:	786080e7          	jalr	1926(ra) # 48b0 <exit>
    printf("%s: wait got too many\n", s);
    1132:	85ce                	mv	a1,s3
    1134:	00004517          	auipc	a0,0x4
    1138:	55c50513          	addi	a0,a0,1372 # 5690 <malloc+0x99a>
    113c:	00004097          	auipc	ra,0x4
    1140:	afc080e7          	jalr	-1284(ra) # 4c38 <printf>
    exit(1);
    1144:	4505                	li	a0,1
    1146:	00003097          	auipc	ra,0x3
    114a:	76a080e7          	jalr	1898(ra) # 48b0 <exit>

000000000000114e <kernmem>:
{
    114e:	715d                	addi	sp,sp,-80
    1150:	e486                	sd	ra,72(sp)
    1152:	e0a2                	sd	s0,64(sp)
    1154:	fc26                	sd	s1,56(sp)
    1156:	f84a                	sd	s2,48(sp)
    1158:	f44e                	sd	s3,40(sp)
    115a:	f052                	sd	s4,32(sp)
    115c:	ec56                	sd	s5,24(sp)
    115e:	0880                	addi	s0,sp,80
    1160:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1162:	4485                	li	s1,1
    1164:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1166:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1168:	69b1                	lui	s3,0xc
    116a:	35098993          	addi	s3,s3,848 # c350 <buf+0x2b30>
    116e:	1003d937          	lui	s2,0x1003d
    1172:	090e                	slli	s2,s2,0x3
    1174:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x10030c50>
    pid = fork();
    1178:	00003097          	auipc	ra,0x3
    117c:	730080e7          	jalr	1840(ra) # 48a8 <fork>
    if(pid < 0){
    1180:	02054963          	bltz	a0,11b2 <kernmem+0x64>
    if(pid == 0){
    1184:	c529                	beqz	a0,11ce <kernmem+0x80>
    wait(&xstatus);
    1186:	fbc40513          	addi	a0,s0,-68
    118a:	00003097          	auipc	ra,0x3
    118e:	72e080e7          	jalr	1838(ra) # 48b8 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1192:	fbc42783          	lw	a5,-68(s0)
    1196:	05579c63          	bne	a5,s5,11ee <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    119a:	94ce                	add	s1,s1,s3
    119c:	fd249ee3          	bne	s1,s2,1178 <kernmem+0x2a>
}
    11a0:	60a6                	ld	ra,72(sp)
    11a2:	6406                	ld	s0,64(sp)
    11a4:	74e2                	ld	s1,56(sp)
    11a6:	7942                	ld	s2,48(sp)
    11a8:	79a2                	ld	s3,40(sp)
    11aa:	7a02                	ld	s4,32(sp)
    11ac:	6ae2                	ld	s5,24(sp)
    11ae:	6161                	addi	sp,sp,80
    11b0:	8082                	ret
      printf("%s: fork failed\n", s);
    11b2:	85d2                	mv	a1,s4
    11b4:	00004517          	auipc	a0,0x4
    11b8:	31450513          	addi	a0,a0,788 # 54c8 <malloc+0x7d2>
    11bc:	00004097          	auipc	ra,0x4
    11c0:	a7c080e7          	jalr	-1412(ra) # 4c38 <printf>
      exit(1);
    11c4:	4505                	li	a0,1
    11c6:	00003097          	auipc	ra,0x3
    11ca:	6ea080e7          	jalr	1770(ra) # 48b0 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    11ce:	0004c603          	lbu	a2,0(s1)
    11d2:	85a6                	mv	a1,s1
    11d4:	00004517          	auipc	a0,0x4
    11d8:	4d450513          	addi	a0,a0,1236 # 56a8 <malloc+0x9b2>
    11dc:	00004097          	auipc	ra,0x4
    11e0:	a5c080e7          	jalr	-1444(ra) # 4c38 <printf>
      exit(1);
    11e4:	4505                	li	a0,1
    11e6:	00003097          	auipc	ra,0x3
    11ea:	6ca080e7          	jalr	1738(ra) # 48b0 <exit>
      exit(1);
    11ee:	4505                	li	a0,1
    11f0:	00003097          	auipc	ra,0x3
    11f4:	6c0080e7          	jalr	1728(ra) # 48b0 <exit>

00000000000011f8 <stacktest>:

// check that there's an invalid page beneath
// the user stack, to catch stack overflow.
void
stacktest(char *s)
{
    11f8:	7179                	addi	sp,sp,-48
    11fa:	f406                	sd	ra,40(sp)
    11fc:	f022                	sd	s0,32(sp)
    11fe:	ec26                	sd	s1,24(sp)
    1200:	1800                	addi	s0,sp,48
    1202:	84aa                	mv	s1,a0
  int pid;
  int xstatus;
  
  pid = fork();
    1204:	00003097          	auipc	ra,0x3
    1208:	6a4080e7          	jalr	1700(ra) # 48a8 <fork>
  if(pid == 0) {
    120c:	c115                	beqz	a0,1230 <stacktest+0x38>
    char *sp = (char *) r_sp();
    sp -= PGSIZE;
    // the *sp should cause a trap.
    printf("%s: stacktest: read below stack %p\n", *sp);
    exit(1);
  } else if(pid < 0){
    120e:	04054363          	bltz	a0,1254 <stacktest+0x5c>
    printf("%s: fork failed\n", s);
    exit(1);
  }
  wait(&xstatus);
    1212:	fdc40513          	addi	a0,s0,-36
    1216:	00003097          	auipc	ra,0x3
    121a:	6a2080e7          	jalr	1698(ra) # 48b8 <wait>
  if(xstatus == -1)  // kernel killed child?
    121e:	fdc42503          	lw	a0,-36(s0)
    1222:	57fd                	li	a5,-1
    1224:	04f50663          	beq	a0,a5,1270 <stacktest+0x78>
    exit(0);
  else
    exit(xstatus);
    1228:	00003097          	auipc	ra,0x3
    122c:	688080e7          	jalr	1672(ra) # 48b0 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1230:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    1232:	77fd                	lui	a5,0xfffff
    1234:	97ba                	add	a5,a5,a4
    1236:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff27d0>
    123a:	00004517          	auipc	a0,0x4
    123e:	48e50513          	addi	a0,a0,1166 # 56c8 <malloc+0x9d2>
    1242:	00004097          	auipc	ra,0x4
    1246:	9f6080e7          	jalr	-1546(ra) # 4c38 <printf>
    exit(1);
    124a:	4505                	li	a0,1
    124c:	00003097          	auipc	ra,0x3
    1250:	664080e7          	jalr	1636(ra) # 48b0 <exit>
    printf("%s: fork failed\n", s);
    1254:	85a6                	mv	a1,s1
    1256:	00004517          	auipc	a0,0x4
    125a:	27250513          	addi	a0,a0,626 # 54c8 <malloc+0x7d2>
    125e:	00004097          	auipc	ra,0x4
    1262:	9da080e7          	jalr	-1574(ra) # 4c38 <printf>
    exit(1);
    1266:	4505                	li	a0,1
    1268:	00003097          	auipc	ra,0x3
    126c:	648080e7          	jalr	1608(ra) # 48b0 <exit>
    exit(0);
    1270:	4501                	li	a0,0
    1272:	00003097          	auipc	ra,0x3
    1276:	63e080e7          	jalr	1598(ra) # 48b0 <exit>

000000000000127a <fourteen>:
{
    127a:	1101                	addi	sp,sp,-32
    127c:	ec06                	sd	ra,24(sp)
    127e:	e822                	sd	s0,16(sp)
    1280:	e426                	sd	s1,8(sp)
    1282:	1000                	addi	s0,sp,32
    1284:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    1286:	00004517          	auipc	a0,0x4
    128a:	63a50513          	addi	a0,a0,1594 # 58c0 <malloc+0xbca>
    128e:	00003097          	auipc	ra,0x3
    1292:	68a080e7          	jalr	1674(ra) # 4918 <mkdir>
    1296:	e141                	bnez	a0,1316 <fourteen+0x9c>
  if(mkdir("12345678901234/123456789012345") != 0){
    1298:	00004517          	auipc	a0,0x4
    129c:	48050513          	addi	a0,a0,1152 # 5718 <malloc+0xa22>
    12a0:	00003097          	auipc	ra,0x3
    12a4:	678080e7          	jalr	1656(ra) # 4918 <mkdir>
    12a8:	e549                	bnez	a0,1332 <fourteen+0xb8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    12aa:	20000593          	li	a1,512
    12ae:	00004517          	auipc	a0,0x4
    12b2:	4c250513          	addi	a0,a0,1218 # 5770 <malloc+0xa7a>
    12b6:	00003097          	auipc	ra,0x3
    12ba:	63a080e7          	jalr	1594(ra) # 48f0 <open>
  if(fd < 0){
    12be:	08054863          	bltz	a0,134e <fourteen+0xd4>
  close(fd);
    12c2:	00003097          	auipc	ra,0x3
    12c6:	616080e7          	jalr	1558(ra) # 48d8 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    12ca:	4581                	li	a1,0
    12cc:	00004517          	auipc	a0,0x4
    12d0:	51c50513          	addi	a0,a0,1308 # 57e8 <malloc+0xaf2>
    12d4:	00003097          	auipc	ra,0x3
    12d8:	61c080e7          	jalr	1564(ra) # 48f0 <open>
  if(fd < 0){
    12dc:	08054763          	bltz	a0,136a <fourteen+0xf0>
  close(fd);
    12e0:	00003097          	auipc	ra,0x3
    12e4:	5f8080e7          	jalr	1528(ra) # 48d8 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    12e8:	00004517          	auipc	a0,0x4
    12ec:	57050513          	addi	a0,a0,1392 # 5858 <malloc+0xb62>
    12f0:	00003097          	auipc	ra,0x3
    12f4:	628080e7          	jalr	1576(ra) # 4918 <mkdir>
    12f8:	c559                	beqz	a0,1386 <fourteen+0x10c>
  if(mkdir("123456789012345/12345678901234") == 0){
    12fa:	00004517          	auipc	a0,0x4
    12fe:	5b650513          	addi	a0,a0,1462 # 58b0 <malloc+0xbba>
    1302:	00003097          	auipc	ra,0x3
    1306:	616080e7          	jalr	1558(ra) # 4918 <mkdir>
    130a:	cd41                	beqz	a0,13a2 <fourteen+0x128>
}
    130c:	60e2                	ld	ra,24(sp)
    130e:	6442                	ld	s0,16(sp)
    1310:	64a2                	ld	s1,8(sp)
    1312:	6105                	addi	sp,sp,32
    1314:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    1316:	85a6                	mv	a1,s1
    1318:	00004517          	auipc	a0,0x4
    131c:	3d850513          	addi	a0,a0,984 # 56f0 <malloc+0x9fa>
    1320:	00004097          	auipc	ra,0x4
    1324:	918080e7          	jalr	-1768(ra) # 4c38 <printf>
    exit(1);
    1328:	4505                	li	a0,1
    132a:	00003097          	auipc	ra,0x3
    132e:	586080e7          	jalr	1414(ra) # 48b0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    1332:	85a6                	mv	a1,s1
    1334:	00004517          	auipc	a0,0x4
    1338:	40450513          	addi	a0,a0,1028 # 5738 <malloc+0xa42>
    133c:	00004097          	auipc	ra,0x4
    1340:	8fc080e7          	jalr	-1796(ra) # 4c38 <printf>
    exit(1);
    1344:	4505                	li	a0,1
    1346:	00003097          	auipc	ra,0x3
    134a:	56a080e7          	jalr	1386(ra) # 48b0 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    134e:	85a6                	mv	a1,s1
    1350:	00004517          	auipc	a0,0x4
    1354:	45050513          	addi	a0,a0,1104 # 57a0 <malloc+0xaaa>
    1358:	00004097          	auipc	ra,0x4
    135c:	8e0080e7          	jalr	-1824(ra) # 4c38 <printf>
    exit(1);
    1360:	4505                	li	a0,1
    1362:	00003097          	auipc	ra,0x3
    1366:	54e080e7          	jalr	1358(ra) # 48b0 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    136a:	85a6                	mv	a1,s1
    136c:	00004517          	auipc	a0,0x4
    1370:	4ac50513          	addi	a0,a0,1196 # 5818 <malloc+0xb22>
    1374:	00004097          	auipc	ra,0x4
    1378:	8c4080e7          	jalr	-1852(ra) # 4c38 <printf>
    exit(1);
    137c:	4505                	li	a0,1
    137e:	00003097          	auipc	ra,0x3
    1382:	532080e7          	jalr	1330(ra) # 48b0 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    1386:	85a6                	mv	a1,s1
    1388:	00004517          	auipc	a0,0x4
    138c:	4f050513          	addi	a0,a0,1264 # 5878 <malloc+0xb82>
    1390:	00004097          	auipc	ra,0x4
    1394:	8a8080e7          	jalr	-1880(ra) # 4c38 <printf>
    exit(1);
    1398:	4505                	li	a0,1
    139a:	00003097          	auipc	ra,0x3
    139e:	516080e7          	jalr	1302(ra) # 48b0 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    13a2:	85a6                	mv	a1,s1
    13a4:	00004517          	auipc	a0,0x4
    13a8:	52c50513          	addi	a0,a0,1324 # 58d0 <malloc+0xbda>
    13ac:	00004097          	auipc	ra,0x4
    13b0:	88c080e7          	jalr	-1908(ra) # 4c38 <printf>
    exit(1);
    13b4:	4505                	li	a0,1
    13b6:	00003097          	auipc	ra,0x3
    13ba:	4fa080e7          	jalr	1274(ra) # 48b0 <exit>

00000000000013be <iputtest>:
{
    13be:	1101                	addi	sp,sp,-32
    13c0:	ec06                	sd	ra,24(sp)
    13c2:	e822                	sd	s0,16(sp)
    13c4:	e426                	sd	s1,8(sp)
    13c6:	1000                	addi	s0,sp,32
    13c8:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    13ca:	00004517          	auipc	a0,0x4
    13ce:	53e50513          	addi	a0,a0,1342 # 5908 <malloc+0xc12>
    13d2:	00003097          	auipc	ra,0x3
    13d6:	546080e7          	jalr	1350(ra) # 4918 <mkdir>
    13da:	04054563          	bltz	a0,1424 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    13de:	00004517          	auipc	a0,0x4
    13e2:	52a50513          	addi	a0,a0,1322 # 5908 <malloc+0xc12>
    13e6:	00003097          	auipc	ra,0x3
    13ea:	53a080e7          	jalr	1338(ra) # 4920 <chdir>
    13ee:	04054963          	bltz	a0,1440 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    13f2:	00004517          	auipc	a0,0x4
    13f6:	55650513          	addi	a0,a0,1366 # 5948 <malloc+0xc52>
    13fa:	00003097          	auipc	ra,0x3
    13fe:	506080e7          	jalr	1286(ra) # 4900 <unlink>
    1402:	04054d63          	bltz	a0,145c <iputtest+0x9e>
  if(chdir("/") < 0){
    1406:	00004517          	auipc	a0,0x4
    140a:	57250513          	addi	a0,a0,1394 # 5978 <malloc+0xc82>
    140e:	00003097          	auipc	ra,0x3
    1412:	512080e7          	jalr	1298(ra) # 4920 <chdir>
    1416:	06054163          	bltz	a0,1478 <iputtest+0xba>
}
    141a:	60e2                	ld	ra,24(sp)
    141c:	6442                	ld	s0,16(sp)
    141e:	64a2                	ld	s1,8(sp)
    1420:	6105                	addi	sp,sp,32
    1422:	8082                	ret
    printf("%s: mkdir failed\n", s);
    1424:	85a6                	mv	a1,s1
    1426:	00004517          	auipc	a0,0x4
    142a:	4ea50513          	addi	a0,a0,1258 # 5910 <malloc+0xc1a>
    142e:	00004097          	auipc	ra,0x4
    1432:	80a080e7          	jalr	-2038(ra) # 4c38 <printf>
    exit(1);
    1436:	4505                	li	a0,1
    1438:	00003097          	auipc	ra,0x3
    143c:	478080e7          	jalr	1144(ra) # 48b0 <exit>
    printf("%s: chdir iputdir failed\n", s);
    1440:	85a6                	mv	a1,s1
    1442:	00004517          	auipc	a0,0x4
    1446:	4e650513          	addi	a0,a0,1254 # 5928 <malloc+0xc32>
    144a:	00003097          	auipc	ra,0x3
    144e:	7ee080e7          	jalr	2030(ra) # 4c38 <printf>
    exit(1);
    1452:	4505                	li	a0,1
    1454:	00003097          	auipc	ra,0x3
    1458:	45c080e7          	jalr	1116(ra) # 48b0 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    145c:	85a6                	mv	a1,s1
    145e:	00004517          	auipc	a0,0x4
    1462:	4fa50513          	addi	a0,a0,1274 # 5958 <malloc+0xc62>
    1466:	00003097          	auipc	ra,0x3
    146a:	7d2080e7          	jalr	2002(ra) # 4c38 <printf>
    exit(1);
    146e:	4505                	li	a0,1
    1470:	00003097          	auipc	ra,0x3
    1474:	440080e7          	jalr	1088(ra) # 48b0 <exit>
    printf("%s: chdir / failed\n", s);
    1478:	85a6                	mv	a1,s1
    147a:	00004517          	auipc	a0,0x4
    147e:	50650513          	addi	a0,a0,1286 # 5980 <malloc+0xc8a>
    1482:	00003097          	auipc	ra,0x3
    1486:	7b6080e7          	jalr	1974(ra) # 4c38 <printf>
    exit(1);
    148a:	4505                	li	a0,1
    148c:	00003097          	auipc	ra,0x3
    1490:	424080e7          	jalr	1060(ra) # 48b0 <exit>

0000000000001494 <exitiputtest>:
{
    1494:	7179                	addi	sp,sp,-48
    1496:	f406                	sd	ra,40(sp)
    1498:	f022                	sd	s0,32(sp)
    149a:	ec26                	sd	s1,24(sp)
    149c:	1800                	addi	s0,sp,48
    149e:	84aa                	mv	s1,a0
  pid = fork();
    14a0:	00003097          	auipc	ra,0x3
    14a4:	408080e7          	jalr	1032(ra) # 48a8 <fork>
  if(pid < 0){
    14a8:	04054663          	bltz	a0,14f4 <exitiputtest+0x60>
  if(pid == 0){
    14ac:	ed45                	bnez	a0,1564 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    14ae:	00004517          	auipc	a0,0x4
    14b2:	45a50513          	addi	a0,a0,1114 # 5908 <malloc+0xc12>
    14b6:	00003097          	auipc	ra,0x3
    14ba:	462080e7          	jalr	1122(ra) # 4918 <mkdir>
    14be:	04054963          	bltz	a0,1510 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    14c2:	00004517          	auipc	a0,0x4
    14c6:	44650513          	addi	a0,a0,1094 # 5908 <malloc+0xc12>
    14ca:	00003097          	auipc	ra,0x3
    14ce:	456080e7          	jalr	1110(ra) # 4920 <chdir>
    14d2:	04054d63          	bltz	a0,152c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    14d6:	00004517          	auipc	a0,0x4
    14da:	47250513          	addi	a0,a0,1138 # 5948 <malloc+0xc52>
    14de:	00003097          	auipc	ra,0x3
    14e2:	422080e7          	jalr	1058(ra) # 4900 <unlink>
    14e6:	06054163          	bltz	a0,1548 <exitiputtest+0xb4>
    exit(0);
    14ea:	4501                	li	a0,0
    14ec:	00003097          	auipc	ra,0x3
    14f0:	3c4080e7          	jalr	964(ra) # 48b0 <exit>
    printf("%s: fork failed\n", s);
    14f4:	85a6                	mv	a1,s1
    14f6:	00004517          	auipc	a0,0x4
    14fa:	fd250513          	addi	a0,a0,-46 # 54c8 <malloc+0x7d2>
    14fe:	00003097          	auipc	ra,0x3
    1502:	73a080e7          	jalr	1850(ra) # 4c38 <printf>
    exit(1);
    1506:	4505                	li	a0,1
    1508:	00003097          	auipc	ra,0x3
    150c:	3a8080e7          	jalr	936(ra) # 48b0 <exit>
      printf("%s: mkdir failed\n", s);
    1510:	85a6                	mv	a1,s1
    1512:	00004517          	auipc	a0,0x4
    1516:	3fe50513          	addi	a0,a0,1022 # 5910 <malloc+0xc1a>
    151a:	00003097          	auipc	ra,0x3
    151e:	71e080e7          	jalr	1822(ra) # 4c38 <printf>
      exit(1);
    1522:	4505                	li	a0,1
    1524:	00003097          	auipc	ra,0x3
    1528:	38c080e7          	jalr	908(ra) # 48b0 <exit>
      printf("%s: child chdir failed\n", s);
    152c:	85a6                	mv	a1,s1
    152e:	00004517          	auipc	a0,0x4
    1532:	46a50513          	addi	a0,a0,1130 # 5998 <malloc+0xca2>
    1536:	00003097          	auipc	ra,0x3
    153a:	702080e7          	jalr	1794(ra) # 4c38 <printf>
      exit(1);
    153e:	4505                	li	a0,1
    1540:	00003097          	auipc	ra,0x3
    1544:	370080e7          	jalr	880(ra) # 48b0 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    1548:	85a6                	mv	a1,s1
    154a:	00004517          	auipc	a0,0x4
    154e:	40e50513          	addi	a0,a0,1038 # 5958 <malloc+0xc62>
    1552:	00003097          	auipc	ra,0x3
    1556:	6e6080e7          	jalr	1766(ra) # 4c38 <printf>
      exit(1);
    155a:	4505                	li	a0,1
    155c:	00003097          	auipc	ra,0x3
    1560:	354080e7          	jalr	852(ra) # 48b0 <exit>
  wait(&xstatus);
    1564:	fdc40513          	addi	a0,s0,-36
    1568:	00003097          	auipc	ra,0x3
    156c:	350080e7          	jalr	848(ra) # 48b8 <wait>
  exit(xstatus);
    1570:	fdc42503          	lw	a0,-36(s0)
    1574:	00003097          	auipc	ra,0x3
    1578:	33c080e7          	jalr	828(ra) # 48b0 <exit>

000000000000157c <rmdot>:
{
    157c:	1101                	addi	sp,sp,-32
    157e:	ec06                	sd	ra,24(sp)
    1580:	e822                	sd	s0,16(sp)
    1582:	e426                	sd	s1,8(sp)
    1584:	1000                	addi	s0,sp,32
    1586:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    1588:	00004517          	auipc	a0,0x4
    158c:	42850513          	addi	a0,a0,1064 # 59b0 <malloc+0xcba>
    1590:	00003097          	auipc	ra,0x3
    1594:	388080e7          	jalr	904(ra) # 4918 <mkdir>
    1598:	e549                	bnez	a0,1622 <rmdot+0xa6>
  if(chdir("dots") != 0){
    159a:	00004517          	auipc	a0,0x4
    159e:	41650513          	addi	a0,a0,1046 # 59b0 <malloc+0xcba>
    15a2:	00003097          	auipc	ra,0x3
    15a6:	37e080e7          	jalr	894(ra) # 4920 <chdir>
    15aa:	e951                	bnez	a0,163e <rmdot+0xc2>
  if(unlink(".") == 0){
    15ac:	00004517          	auipc	a0,0x4
    15b0:	43c50513          	addi	a0,a0,1084 # 59e8 <malloc+0xcf2>
    15b4:	00003097          	auipc	ra,0x3
    15b8:	34c080e7          	jalr	844(ra) # 4900 <unlink>
    15bc:	cd59                	beqz	a0,165a <rmdot+0xde>
  if(unlink("..") == 0){
    15be:	00004517          	auipc	a0,0x4
    15c2:	44a50513          	addi	a0,a0,1098 # 5a08 <malloc+0xd12>
    15c6:	00003097          	auipc	ra,0x3
    15ca:	33a080e7          	jalr	826(ra) # 4900 <unlink>
    15ce:	c545                	beqz	a0,1676 <rmdot+0xfa>
  if(chdir("/") != 0){
    15d0:	00004517          	auipc	a0,0x4
    15d4:	3a850513          	addi	a0,a0,936 # 5978 <malloc+0xc82>
    15d8:	00003097          	auipc	ra,0x3
    15dc:	348080e7          	jalr	840(ra) # 4920 <chdir>
    15e0:	e94d                	bnez	a0,1692 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    15e2:	00004517          	auipc	a0,0x4
    15e6:	44650513          	addi	a0,a0,1094 # 5a28 <malloc+0xd32>
    15ea:	00003097          	auipc	ra,0x3
    15ee:	316080e7          	jalr	790(ra) # 4900 <unlink>
    15f2:	cd55                	beqz	a0,16ae <rmdot+0x132>
  if(unlink("dots/..") == 0){
    15f4:	00004517          	auipc	a0,0x4
    15f8:	45c50513          	addi	a0,a0,1116 # 5a50 <malloc+0xd5a>
    15fc:	00003097          	auipc	ra,0x3
    1600:	304080e7          	jalr	772(ra) # 4900 <unlink>
    1604:	c179                	beqz	a0,16ca <rmdot+0x14e>
  if(unlink("dots") != 0){
    1606:	00004517          	auipc	a0,0x4
    160a:	3aa50513          	addi	a0,a0,938 # 59b0 <malloc+0xcba>
    160e:	00003097          	auipc	ra,0x3
    1612:	2f2080e7          	jalr	754(ra) # 4900 <unlink>
    1616:	e961                	bnez	a0,16e6 <rmdot+0x16a>
}
    1618:	60e2                	ld	ra,24(sp)
    161a:	6442                	ld	s0,16(sp)
    161c:	64a2                	ld	s1,8(sp)
    161e:	6105                	addi	sp,sp,32
    1620:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    1622:	85a6                	mv	a1,s1
    1624:	00004517          	auipc	a0,0x4
    1628:	39450513          	addi	a0,a0,916 # 59b8 <malloc+0xcc2>
    162c:	00003097          	auipc	ra,0x3
    1630:	60c080e7          	jalr	1548(ra) # 4c38 <printf>
    exit(1);
    1634:	4505                	li	a0,1
    1636:	00003097          	auipc	ra,0x3
    163a:	27a080e7          	jalr	634(ra) # 48b0 <exit>
    printf("%s: chdir dots failed\n", s);
    163e:	85a6                	mv	a1,s1
    1640:	00004517          	auipc	a0,0x4
    1644:	39050513          	addi	a0,a0,912 # 59d0 <malloc+0xcda>
    1648:	00003097          	auipc	ra,0x3
    164c:	5f0080e7          	jalr	1520(ra) # 4c38 <printf>
    exit(1);
    1650:	4505                	li	a0,1
    1652:	00003097          	auipc	ra,0x3
    1656:	25e080e7          	jalr	606(ra) # 48b0 <exit>
    printf("%s: rm . worked!\n", s);
    165a:	85a6                	mv	a1,s1
    165c:	00004517          	auipc	a0,0x4
    1660:	39450513          	addi	a0,a0,916 # 59f0 <malloc+0xcfa>
    1664:	00003097          	auipc	ra,0x3
    1668:	5d4080e7          	jalr	1492(ra) # 4c38 <printf>
    exit(1);
    166c:	4505                	li	a0,1
    166e:	00003097          	auipc	ra,0x3
    1672:	242080e7          	jalr	578(ra) # 48b0 <exit>
    printf("%s: rm .. worked!\n", s);
    1676:	85a6                	mv	a1,s1
    1678:	00004517          	auipc	a0,0x4
    167c:	39850513          	addi	a0,a0,920 # 5a10 <malloc+0xd1a>
    1680:	00003097          	auipc	ra,0x3
    1684:	5b8080e7          	jalr	1464(ra) # 4c38 <printf>
    exit(1);
    1688:	4505                	li	a0,1
    168a:	00003097          	auipc	ra,0x3
    168e:	226080e7          	jalr	550(ra) # 48b0 <exit>
    printf("%s: chdir / failed\n", s);
    1692:	85a6                	mv	a1,s1
    1694:	00004517          	auipc	a0,0x4
    1698:	2ec50513          	addi	a0,a0,748 # 5980 <malloc+0xc8a>
    169c:	00003097          	auipc	ra,0x3
    16a0:	59c080e7          	jalr	1436(ra) # 4c38 <printf>
    exit(1);
    16a4:	4505                	li	a0,1
    16a6:	00003097          	auipc	ra,0x3
    16aa:	20a080e7          	jalr	522(ra) # 48b0 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    16ae:	85a6                	mv	a1,s1
    16b0:	00004517          	auipc	a0,0x4
    16b4:	38050513          	addi	a0,a0,896 # 5a30 <malloc+0xd3a>
    16b8:	00003097          	auipc	ra,0x3
    16bc:	580080e7          	jalr	1408(ra) # 4c38 <printf>
    exit(1);
    16c0:	4505                	li	a0,1
    16c2:	00003097          	auipc	ra,0x3
    16c6:	1ee080e7          	jalr	494(ra) # 48b0 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    16ca:	85a6                	mv	a1,s1
    16cc:	00004517          	auipc	a0,0x4
    16d0:	38c50513          	addi	a0,a0,908 # 5a58 <malloc+0xd62>
    16d4:	00003097          	auipc	ra,0x3
    16d8:	564080e7          	jalr	1380(ra) # 4c38 <printf>
    exit(1);
    16dc:	4505                	li	a0,1
    16de:	00003097          	auipc	ra,0x3
    16e2:	1d2080e7          	jalr	466(ra) # 48b0 <exit>
    printf("%s: unlink dots failed!\n", s);
    16e6:	85a6                	mv	a1,s1
    16e8:	00004517          	auipc	a0,0x4
    16ec:	39050513          	addi	a0,a0,912 # 5a78 <malloc+0xd82>
    16f0:	00003097          	auipc	ra,0x3
    16f4:	548080e7          	jalr	1352(ra) # 4c38 <printf>
    exit(1);
    16f8:	4505                	li	a0,1
    16fa:	00003097          	auipc	ra,0x3
    16fe:	1b6080e7          	jalr	438(ra) # 48b0 <exit>

0000000000001702 <openiputtest>:
{
    1702:	7179                	addi	sp,sp,-48
    1704:	f406                	sd	ra,40(sp)
    1706:	f022                	sd	s0,32(sp)
    1708:	ec26                	sd	s1,24(sp)
    170a:	1800                	addi	s0,sp,48
    170c:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    170e:	00004517          	auipc	a0,0x4
    1712:	38a50513          	addi	a0,a0,906 # 5a98 <malloc+0xda2>
    1716:	00003097          	auipc	ra,0x3
    171a:	202080e7          	jalr	514(ra) # 4918 <mkdir>
    171e:	04054263          	bltz	a0,1762 <openiputtest+0x60>
  pid = fork();
    1722:	00003097          	auipc	ra,0x3
    1726:	186080e7          	jalr	390(ra) # 48a8 <fork>
  if(pid < 0){
    172a:	04054a63          	bltz	a0,177e <openiputtest+0x7c>
  if(pid == 0){
    172e:	e93d                	bnez	a0,17a4 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    1730:	4589                	li	a1,2
    1732:	00004517          	auipc	a0,0x4
    1736:	36650513          	addi	a0,a0,870 # 5a98 <malloc+0xda2>
    173a:	00003097          	auipc	ra,0x3
    173e:	1b6080e7          	jalr	438(ra) # 48f0 <open>
    if(fd >= 0){
    1742:	04054c63          	bltz	a0,179a <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    1746:	85a6                	mv	a1,s1
    1748:	00004517          	auipc	a0,0x4
    174c:	37050513          	addi	a0,a0,880 # 5ab8 <malloc+0xdc2>
    1750:	00003097          	auipc	ra,0x3
    1754:	4e8080e7          	jalr	1256(ra) # 4c38 <printf>
      exit(1);
    1758:	4505                	li	a0,1
    175a:	00003097          	auipc	ra,0x3
    175e:	156080e7          	jalr	342(ra) # 48b0 <exit>
    printf("%s: mkdir oidir failed\n", s);
    1762:	85a6                	mv	a1,s1
    1764:	00004517          	auipc	a0,0x4
    1768:	33c50513          	addi	a0,a0,828 # 5aa0 <malloc+0xdaa>
    176c:	00003097          	auipc	ra,0x3
    1770:	4cc080e7          	jalr	1228(ra) # 4c38 <printf>
    exit(1);
    1774:	4505                	li	a0,1
    1776:	00003097          	auipc	ra,0x3
    177a:	13a080e7          	jalr	314(ra) # 48b0 <exit>
    printf("%s: fork failed\n", s);
    177e:	85a6                	mv	a1,s1
    1780:	00004517          	auipc	a0,0x4
    1784:	d4850513          	addi	a0,a0,-696 # 54c8 <malloc+0x7d2>
    1788:	00003097          	auipc	ra,0x3
    178c:	4b0080e7          	jalr	1200(ra) # 4c38 <printf>
    exit(1);
    1790:	4505                	li	a0,1
    1792:	00003097          	auipc	ra,0x3
    1796:	11e080e7          	jalr	286(ra) # 48b0 <exit>
    exit(0);
    179a:	4501                	li	a0,0
    179c:	00003097          	auipc	ra,0x3
    17a0:	114080e7          	jalr	276(ra) # 48b0 <exit>
  sleep(1);
    17a4:	4505                	li	a0,1
    17a6:	00003097          	auipc	ra,0x3
    17aa:	19a080e7          	jalr	410(ra) # 4940 <sleep>
  if(unlink("oidir") != 0){
    17ae:	00004517          	auipc	a0,0x4
    17b2:	2ea50513          	addi	a0,a0,746 # 5a98 <malloc+0xda2>
    17b6:	00003097          	auipc	ra,0x3
    17ba:	14a080e7          	jalr	330(ra) # 4900 <unlink>
    17be:	cd19                	beqz	a0,17dc <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    17c0:	85a6                	mv	a1,s1
    17c2:	00004517          	auipc	a0,0x4
    17c6:	e0e50513          	addi	a0,a0,-498 # 55d0 <malloc+0x8da>
    17ca:	00003097          	auipc	ra,0x3
    17ce:	46e080e7          	jalr	1134(ra) # 4c38 <printf>
    exit(1);
    17d2:	4505                	li	a0,1
    17d4:	00003097          	auipc	ra,0x3
    17d8:	0dc080e7          	jalr	220(ra) # 48b0 <exit>
  wait(&xstatus);
    17dc:	fdc40513          	addi	a0,s0,-36
    17e0:	00003097          	auipc	ra,0x3
    17e4:	0d8080e7          	jalr	216(ra) # 48b8 <wait>
  exit(xstatus);
    17e8:	fdc42503          	lw	a0,-36(s0)
    17ec:	00003097          	auipc	ra,0x3
    17f0:	0c4080e7          	jalr	196(ra) # 48b0 <exit>

00000000000017f4 <forkforkfork>:
{
    17f4:	1101                	addi	sp,sp,-32
    17f6:	ec06                	sd	ra,24(sp)
    17f8:	e822                	sd	s0,16(sp)
    17fa:	e426                	sd	s1,8(sp)
    17fc:	1000                	addi	s0,sp,32
    17fe:	84aa                	mv	s1,a0
  unlink("stopforking");
    1800:	00004517          	auipc	a0,0x4
    1804:	2e050513          	addi	a0,a0,736 # 5ae0 <malloc+0xdea>
    1808:	00003097          	auipc	ra,0x3
    180c:	0f8080e7          	jalr	248(ra) # 4900 <unlink>
  int pid = fork();
    1810:	00003097          	auipc	ra,0x3
    1814:	098080e7          	jalr	152(ra) # 48a8 <fork>
  if(pid < 0){
    1818:	04054563          	bltz	a0,1862 <forkforkfork+0x6e>
  if(pid == 0){
    181c:	c12d                	beqz	a0,187e <forkforkfork+0x8a>
  sleep(20); // two seconds
    181e:	4551                	li	a0,20
    1820:	00003097          	auipc	ra,0x3
    1824:	120080e7          	jalr	288(ra) # 4940 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    1828:	20200593          	li	a1,514
    182c:	00004517          	auipc	a0,0x4
    1830:	2b450513          	addi	a0,a0,692 # 5ae0 <malloc+0xdea>
    1834:	00003097          	auipc	ra,0x3
    1838:	0bc080e7          	jalr	188(ra) # 48f0 <open>
    183c:	00003097          	auipc	ra,0x3
    1840:	09c080e7          	jalr	156(ra) # 48d8 <close>
  wait(0);
    1844:	4501                	li	a0,0
    1846:	00003097          	auipc	ra,0x3
    184a:	072080e7          	jalr	114(ra) # 48b8 <wait>
  sleep(10); // one second
    184e:	4529                	li	a0,10
    1850:	00003097          	auipc	ra,0x3
    1854:	0f0080e7          	jalr	240(ra) # 4940 <sleep>
}
    1858:	60e2                	ld	ra,24(sp)
    185a:	6442                	ld	s0,16(sp)
    185c:	64a2                	ld	s1,8(sp)
    185e:	6105                	addi	sp,sp,32
    1860:	8082                	ret
    printf("%s: fork failed", s);
    1862:	85a6                	mv	a1,s1
    1864:	00004517          	auipc	a0,0x4
    1868:	d2450513          	addi	a0,a0,-732 # 5588 <malloc+0x892>
    186c:	00003097          	auipc	ra,0x3
    1870:	3cc080e7          	jalr	972(ra) # 4c38 <printf>
    exit(1);
    1874:	4505                	li	a0,1
    1876:	00003097          	auipc	ra,0x3
    187a:	03a080e7          	jalr	58(ra) # 48b0 <exit>
      int fd = open("stopforking", 0);
    187e:	00004497          	auipc	s1,0x4
    1882:	26248493          	addi	s1,s1,610 # 5ae0 <malloc+0xdea>
    1886:	4581                	li	a1,0
    1888:	8526                	mv	a0,s1
    188a:	00003097          	auipc	ra,0x3
    188e:	066080e7          	jalr	102(ra) # 48f0 <open>
      if(fd >= 0){
    1892:	02055463          	bgez	a0,18ba <forkforkfork+0xc6>
      if(fork() < 0){
    1896:	00003097          	auipc	ra,0x3
    189a:	012080e7          	jalr	18(ra) # 48a8 <fork>
    189e:	fe0554e3          	bgez	a0,1886 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    18a2:	20200593          	li	a1,514
    18a6:	8526                	mv	a0,s1
    18a8:	00003097          	auipc	ra,0x3
    18ac:	048080e7          	jalr	72(ra) # 48f0 <open>
    18b0:	00003097          	auipc	ra,0x3
    18b4:	028080e7          	jalr	40(ra) # 48d8 <close>
    18b8:	b7f9                	j	1886 <forkforkfork+0x92>
        exit(0);
    18ba:	4501                	li	a0,0
    18bc:	00003097          	auipc	ra,0x3
    18c0:	ff4080e7          	jalr	-12(ra) # 48b0 <exit>

00000000000018c4 <exectest>:
{
    18c4:	715d                	addi	sp,sp,-80
    18c6:	e486                	sd	ra,72(sp)
    18c8:	e0a2                	sd	s0,64(sp)
    18ca:	fc26                	sd	s1,56(sp)
    18cc:	f84a                	sd	s2,48(sp)
    18ce:	0880                	addi	s0,sp,80
    18d0:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    18d2:	00004797          	auipc	a5,0x4
    18d6:	89e78793          	addi	a5,a5,-1890 # 5170 <malloc+0x47a>
    18da:	fcf43023          	sd	a5,-64(s0)
    18de:	00004797          	auipc	a5,0x4
    18e2:	21278793          	addi	a5,a5,530 # 5af0 <malloc+0xdfa>
    18e6:	fcf43423          	sd	a5,-56(s0)
    18ea:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    18ee:	00004517          	auipc	a0,0x4
    18f2:	20a50513          	addi	a0,a0,522 # 5af8 <malloc+0xe02>
    18f6:	00003097          	auipc	ra,0x3
    18fa:	00a080e7          	jalr	10(ra) # 4900 <unlink>
  pid = fork();
    18fe:	00003097          	auipc	ra,0x3
    1902:	faa080e7          	jalr	-86(ra) # 48a8 <fork>
  if(pid < 0) {
    1906:	04054663          	bltz	a0,1952 <exectest+0x8e>
    190a:	84aa                	mv	s1,a0
  if(pid == 0) {
    190c:	e959                	bnez	a0,19a2 <exectest+0xde>
    close(1);
    190e:	4505                	li	a0,1
    1910:	00003097          	auipc	ra,0x3
    1914:	fc8080e7          	jalr	-56(ra) # 48d8 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1918:	20100593          	li	a1,513
    191c:	00004517          	auipc	a0,0x4
    1920:	1dc50513          	addi	a0,a0,476 # 5af8 <malloc+0xe02>
    1924:	00003097          	auipc	ra,0x3
    1928:	fcc080e7          	jalr	-52(ra) # 48f0 <open>
    if(fd < 0) {
    192c:	04054163          	bltz	a0,196e <exectest+0xaa>
    if(fd != 1) {
    1930:	4785                	li	a5,1
    1932:	04f50c63          	beq	a0,a5,198a <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    1936:	85ca                	mv	a1,s2
    1938:	00004517          	auipc	a0,0x4
    193c:	1c850513          	addi	a0,a0,456 # 5b00 <malloc+0xe0a>
    1940:	00003097          	auipc	ra,0x3
    1944:	2f8080e7          	jalr	760(ra) # 4c38 <printf>
      exit(1);
    1948:	4505                	li	a0,1
    194a:	00003097          	auipc	ra,0x3
    194e:	f66080e7          	jalr	-154(ra) # 48b0 <exit>
     printf("%s: fork failed\n", s);
    1952:	85ca                	mv	a1,s2
    1954:	00004517          	auipc	a0,0x4
    1958:	b7450513          	addi	a0,a0,-1164 # 54c8 <malloc+0x7d2>
    195c:	00003097          	auipc	ra,0x3
    1960:	2dc080e7          	jalr	732(ra) # 4c38 <printf>
     exit(1);
    1964:	4505                	li	a0,1
    1966:	00003097          	auipc	ra,0x3
    196a:	f4a080e7          	jalr	-182(ra) # 48b0 <exit>
      printf("%s: create failed\n", s);
    196e:	85ca                	mv	a1,s2
    1970:	00004517          	auipc	a0,0x4
    1974:	c4850513          	addi	a0,a0,-952 # 55b8 <malloc+0x8c2>
    1978:	00003097          	auipc	ra,0x3
    197c:	2c0080e7          	jalr	704(ra) # 4c38 <printf>
      exit(1);
    1980:	4505                	li	a0,1
    1982:	00003097          	auipc	ra,0x3
    1986:	f2e080e7          	jalr	-210(ra) # 48b0 <exit>
    if(exec("echo", echoargv) < 0){
    198a:	fc040593          	addi	a1,s0,-64
    198e:	00003517          	auipc	a0,0x3
    1992:	7e250513          	addi	a0,a0,2018 # 5170 <malloc+0x47a>
    1996:	00003097          	auipc	ra,0x3
    199a:	f52080e7          	jalr	-174(ra) # 48e8 <exec>
    199e:	02054163          	bltz	a0,19c0 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    19a2:	fdc40513          	addi	a0,s0,-36
    19a6:	00003097          	auipc	ra,0x3
    19aa:	f12080e7          	jalr	-238(ra) # 48b8 <wait>
    19ae:	02951763          	bne	a0,s1,19dc <exectest+0x118>
  if(xstatus != 0)
    19b2:	fdc42503          	lw	a0,-36(s0)
    19b6:	cd0d                	beqz	a0,19f0 <exectest+0x12c>
    exit(xstatus);
    19b8:	00003097          	auipc	ra,0x3
    19bc:	ef8080e7          	jalr	-264(ra) # 48b0 <exit>
      printf("%s: exec echo failed\n", s);
    19c0:	85ca                	mv	a1,s2
    19c2:	00004517          	auipc	a0,0x4
    19c6:	14e50513          	addi	a0,a0,334 # 5b10 <malloc+0xe1a>
    19ca:	00003097          	auipc	ra,0x3
    19ce:	26e080e7          	jalr	622(ra) # 4c38 <printf>
      exit(1);
    19d2:	4505                	li	a0,1
    19d4:	00003097          	auipc	ra,0x3
    19d8:	edc080e7          	jalr	-292(ra) # 48b0 <exit>
    printf("%s: wait failed!\n", s);
    19dc:	85ca                	mv	a1,s2
    19de:	00004517          	auipc	a0,0x4
    19e2:	14a50513          	addi	a0,a0,330 # 5b28 <malloc+0xe32>
    19e6:	00003097          	auipc	ra,0x3
    19ea:	252080e7          	jalr	594(ra) # 4c38 <printf>
    19ee:	b7d1                	j	19b2 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    19f0:	4581                	li	a1,0
    19f2:	00004517          	auipc	a0,0x4
    19f6:	10650513          	addi	a0,a0,262 # 5af8 <malloc+0xe02>
    19fa:	00003097          	auipc	ra,0x3
    19fe:	ef6080e7          	jalr	-266(ra) # 48f0 <open>
  if(fd < 0) {
    1a02:	02054a63          	bltz	a0,1a36 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1a06:	4609                	li	a2,2
    1a08:	fb840593          	addi	a1,s0,-72
    1a0c:	00003097          	auipc	ra,0x3
    1a10:	ebc080e7          	jalr	-324(ra) # 48c8 <read>
    1a14:	4789                	li	a5,2
    1a16:	02f50e63          	beq	a0,a5,1a52 <exectest+0x18e>
    printf("%s: read failed\n", s);
    1a1a:	85ca                	mv	a1,s2
    1a1c:	00004517          	auipc	a0,0x4
    1a20:	86450513          	addi	a0,a0,-1948 # 5280 <malloc+0x58a>
    1a24:	00003097          	auipc	ra,0x3
    1a28:	214080e7          	jalr	532(ra) # 4c38 <printf>
    exit(1);
    1a2c:	4505                	li	a0,1
    1a2e:	00003097          	auipc	ra,0x3
    1a32:	e82080e7          	jalr	-382(ra) # 48b0 <exit>
    printf("%s: open failed\n", s);
    1a36:	85ca                	mv	a1,s2
    1a38:	00004517          	auipc	a0,0x4
    1a3c:	aa850513          	addi	a0,a0,-1368 # 54e0 <malloc+0x7ea>
    1a40:	00003097          	auipc	ra,0x3
    1a44:	1f8080e7          	jalr	504(ra) # 4c38 <printf>
    exit(1);
    1a48:	4505                	li	a0,1
    1a4a:	00003097          	auipc	ra,0x3
    1a4e:	e66080e7          	jalr	-410(ra) # 48b0 <exit>
  unlink("echo-ok");
    1a52:	00004517          	auipc	a0,0x4
    1a56:	0a650513          	addi	a0,a0,166 # 5af8 <malloc+0xe02>
    1a5a:	00003097          	auipc	ra,0x3
    1a5e:	ea6080e7          	jalr	-346(ra) # 4900 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1a62:	fb844703          	lbu	a4,-72(s0)
    1a66:	04f00793          	li	a5,79
    1a6a:	00f71863          	bne	a4,a5,1a7a <exectest+0x1b6>
    1a6e:	fb944703          	lbu	a4,-71(s0)
    1a72:	04b00793          	li	a5,75
    1a76:	02f70063          	beq	a4,a5,1a96 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1a7a:	85ca                	mv	a1,s2
    1a7c:	00004517          	auipc	a0,0x4
    1a80:	0c450513          	addi	a0,a0,196 # 5b40 <malloc+0xe4a>
    1a84:	00003097          	auipc	ra,0x3
    1a88:	1b4080e7          	jalr	436(ra) # 4c38 <printf>
    exit(1);
    1a8c:	4505                	li	a0,1
    1a8e:	00003097          	auipc	ra,0x3
    1a92:	e22080e7          	jalr	-478(ra) # 48b0 <exit>
    exit(0);
    1a96:	4501                	li	a0,0
    1a98:	00003097          	auipc	ra,0x3
    1a9c:	e18080e7          	jalr	-488(ra) # 48b0 <exit>

0000000000001aa0 <bigargtest>:
{
    1aa0:	7179                	addi	sp,sp,-48
    1aa2:	f406                	sd	ra,40(sp)
    1aa4:	f022                	sd	s0,32(sp)
    1aa6:	ec26                	sd	s1,24(sp)
    1aa8:	1800                	addi	s0,sp,48
    1aaa:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    1aac:	00004517          	auipc	a0,0x4
    1ab0:	0ac50513          	addi	a0,a0,172 # 5b58 <malloc+0xe62>
    1ab4:	00003097          	auipc	ra,0x3
    1ab8:	e4c080e7          	jalr	-436(ra) # 4900 <unlink>
  pid = fork();
    1abc:	00003097          	auipc	ra,0x3
    1ac0:	dec080e7          	jalr	-532(ra) # 48a8 <fork>
  if(pid == 0){
    1ac4:	c121                	beqz	a0,1b04 <bigargtest+0x64>
  } else if(pid < 0){
    1ac6:	0a054063          	bltz	a0,1b66 <bigargtest+0xc6>
  wait(&xstatus);
    1aca:	fdc40513          	addi	a0,s0,-36
    1ace:	00003097          	auipc	ra,0x3
    1ad2:	dea080e7          	jalr	-534(ra) # 48b8 <wait>
  if(xstatus != 0)
    1ad6:	fdc42503          	lw	a0,-36(s0)
    1ada:	e545                	bnez	a0,1b82 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    1adc:	4581                	li	a1,0
    1ade:	00004517          	auipc	a0,0x4
    1ae2:	07a50513          	addi	a0,a0,122 # 5b58 <malloc+0xe62>
    1ae6:	00003097          	auipc	ra,0x3
    1aea:	e0a080e7          	jalr	-502(ra) # 48f0 <open>
  if(fd < 0){
    1aee:	08054e63          	bltz	a0,1b8a <bigargtest+0xea>
  close(fd);
    1af2:	00003097          	auipc	ra,0x3
    1af6:	de6080e7          	jalr	-538(ra) # 48d8 <close>
}
    1afa:	70a2                	ld	ra,40(sp)
    1afc:	7402                	ld	s0,32(sp)
    1afe:	64e2                	ld	s1,24(sp)
    1b00:	6145                	addi	sp,sp,48
    1b02:	8082                	ret
    1b04:	00005797          	auipc	a5,0x5
    1b08:	50c78793          	addi	a5,a5,1292 # 7010 <args.0>
    1b0c:	00005697          	auipc	a3,0x5
    1b10:	5fc68693          	addi	a3,a3,1532 # 7108 <args.0+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1b14:	00004717          	auipc	a4,0x4
    1b18:	05470713          	addi	a4,a4,84 # 5b68 <malloc+0xe72>
    1b1c:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1b1e:	07a1                	addi	a5,a5,8
    1b20:	fed79ee3          	bne	a5,a3,1b1c <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1b24:	00005597          	auipc	a1,0x5
    1b28:	4ec58593          	addi	a1,a1,1260 # 7010 <args.0>
    1b2c:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    1b30:	00003517          	auipc	a0,0x3
    1b34:	64050513          	addi	a0,a0,1600 # 5170 <malloc+0x47a>
    1b38:	00003097          	auipc	ra,0x3
    1b3c:	db0080e7          	jalr	-592(ra) # 48e8 <exec>
    fd = open("bigarg-ok", O_CREATE);
    1b40:	20000593          	li	a1,512
    1b44:	00004517          	auipc	a0,0x4
    1b48:	01450513          	addi	a0,a0,20 # 5b58 <malloc+0xe62>
    1b4c:	00003097          	auipc	ra,0x3
    1b50:	da4080e7          	jalr	-604(ra) # 48f0 <open>
    close(fd);
    1b54:	00003097          	auipc	ra,0x3
    1b58:	d84080e7          	jalr	-636(ra) # 48d8 <close>
    exit(0);
    1b5c:	4501                	li	a0,0
    1b5e:	00003097          	auipc	ra,0x3
    1b62:	d52080e7          	jalr	-686(ra) # 48b0 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    1b66:	85a6                	mv	a1,s1
    1b68:	00004517          	auipc	a0,0x4
    1b6c:	0e050513          	addi	a0,a0,224 # 5c48 <malloc+0xf52>
    1b70:	00003097          	auipc	ra,0x3
    1b74:	0c8080e7          	jalr	200(ra) # 4c38 <printf>
    exit(1);
    1b78:	4505                	li	a0,1
    1b7a:	00003097          	auipc	ra,0x3
    1b7e:	d36080e7          	jalr	-714(ra) # 48b0 <exit>
    exit(xstatus);
    1b82:	00003097          	auipc	ra,0x3
    1b86:	d2e080e7          	jalr	-722(ra) # 48b0 <exit>
    printf("%s: bigarg test failed!\n", s);
    1b8a:	85a6                	mv	a1,s1
    1b8c:	00004517          	auipc	a0,0x4
    1b90:	0dc50513          	addi	a0,a0,220 # 5c68 <malloc+0xf72>
    1b94:	00003097          	auipc	ra,0x3
    1b98:	0a4080e7          	jalr	164(ra) # 4c38 <printf>
    exit(1);
    1b9c:	4505                	li	a0,1
    1b9e:	00003097          	auipc	ra,0x3
    1ba2:	d12080e7          	jalr	-750(ra) # 48b0 <exit>

0000000000001ba6 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1ba6:	7139                	addi	sp,sp,-64
    1ba8:	fc06                	sd	ra,56(sp)
    1baa:	f822                	sd	s0,48(sp)
    1bac:	f426                	sd	s1,40(sp)
    1bae:	f04a                	sd	s2,32(sp)
    1bb0:	ec4e                	sd	s3,24(sp)
    1bb2:	0080                	addi	s0,sp,64
    1bb4:	64b1                	lui	s1,0xc
    1bb6:	35048493          	addi	s1,s1,848 # c350 <buf+0x2b30>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1bba:	597d                	li	s2,-1
    1bbc:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1bc0:	00003997          	auipc	s3,0x3
    1bc4:	5b098993          	addi	s3,s3,1456 # 5170 <malloc+0x47a>
    argv[0] = (char*)0xffffffff;
    1bc8:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1bcc:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1bd0:	fc040593          	addi	a1,s0,-64
    1bd4:	854e                	mv	a0,s3
    1bd6:	00003097          	auipc	ra,0x3
    1bda:	d12080e7          	jalr	-750(ra) # 48e8 <exec>
  for(int i = 0; i < 50000; i++){
    1bde:	34fd                	addiw	s1,s1,-1
    1be0:	f4e5                	bnez	s1,1bc8 <badarg+0x22>
  }
  
  exit(0);
    1be2:	4501                	li	a0,0
    1be4:	00003097          	auipc	ra,0x3
    1be8:	ccc080e7          	jalr	-820(ra) # 48b0 <exit>

0000000000001bec <pipe1>:
{
    1bec:	711d                	addi	sp,sp,-96
    1bee:	ec86                	sd	ra,88(sp)
    1bf0:	e8a2                	sd	s0,80(sp)
    1bf2:	e4a6                	sd	s1,72(sp)
    1bf4:	e0ca                	sd	s2,64(sp)
    1bf6:	fc4e                	sd	s3,56(sp)
    1bf8:	f852                	sd	s4,48(sp)
    1bfa:	f456                	sd	s5,40(sp)
    1bfc:	f05a                	sd	s6,32(sp)
    1bfe:	ec5e                	sd	s7,24(sp)
    1c00:	1080                	addi	s0,sp,96
    1c02:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1c04:	fa840513          	addi	a0,s0,-88
    1c08:	00003097          	auipc	ra,0x3
    1c0c:	cb8080e7          	jalr	-840(ra) # 48c0 <pipe>
    1c10:	ed25                	bnez	a0,1c88 <pipe1+0x9c>
    1c12:	84aa                	mv	s1,a0
  pid = fork();
    1c14:	00003097          	auipc	ra,0x3
    1c18:	c94080e7          	jalr	-876(ra) # 48a8 <fork>
    1c1c:	8a2a                	mv	s4,a0
  if(pid == 0){
    1c1e:	c159                	beqz	a0,1ca4 <pipe1+0xb8>
  } else if(pid > 0){
    1c20:	16a05e63          	blez	a0,1d9c <pipe1+0x1b0>
    close(fds[1]);
    1c24:	fac42503          	lw	a0,-84(s0)
    1c28:	00003097          	auipc	ra,0x3
    1c2c:	cb0080e7          	jalr	-848(ra) # 48d8 <close>
    total = 0;
    1c30:	8a26                	mv	s4,s1
    cc = 1;
    1c32:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1c34:	00008a97          	auipc	s5,0x8
    1c38:	beca8a93          	addi	s5,s5,-1044 # 9820 <buf>
      if(cc > sizeof(buf))
    1c3c:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1c3e:	864e                	mv	a2,s3
    1c40:	85d6                	mv	a1,s5
    1c42:	fa842503          	lw	a0,-88(s0)
    1c46:	00003097          	auipc	ra,0x3
    1c4a:	c82080e7          	jalr	-894(ra) # 48c8 <read>
    1c4e:	10a05263          	blez	a0,1d52 <pipe1+0x166>
      for(i = 0; i < n; i++){
    1c52:	00008717          	auipc	a4,0x8
    1c56:	bce70713          	addi	a4,a4,-1074 # 9820 <buf>
    1c5a:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c5e:	00074683          	lbu	a3,0(a4)
    1c62:	0ff4f793          	andi	a5,s1,255
    1c66:	2485                	addiw	s1,s1,1
    1c68:	0cf69163          	bne	a3,a5,1d2a <pipe1+0x13e>
      for(i = 0; i < n; i++){
    1c6c:	0705                	addi	a4,a4,1
    1c6e:	fec498e3          	bne	s1,a2,1c5e <pipe1+0x72>
      total += n;
    1c72:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1c76:	0019979b          	slliw	a5,s3,0x1
    1c7a:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    1c7e:	013b7363          	bgeu	s6,s3,1c84 <pipe1+0x98>
        cc = sizeof(buf);
    1c82:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1c84:	84b2                	mv	s1,a2
    1c86:	bf65                	j	1c3e <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    1c88:	85ca                	mv	a1,s2
    1c8a:	00004517          	auipc	a0,0x4
    1c8e:	ffe50513          	addi	a0,a0,-2 # 5c88 <malloc+0xf92>
    1c92:	00003097          	auipc	ra,0x3
    1c96:	fa6080e7          	jalr	-90(ra) # 4c38 <printf>
    exit(1);
    1c9a:	4505                	li	a0,1
    1c9c:	00003097          	auipc	ra,0x3
    1ca0:	c14080e7          	jalr	-1004(ra) # 48b0 <exit>
    close(fds[0]);
    1ca4:	fa842503          	lw	a0,-88(s0)
    1ca8:	00003097          	auipc	ra,0x3
    1cac:	c30080e7          	jalr	-976(ra) # 48d8 <close>
    for(n = 0; n < N; n++){
    1cb0:	00008b17          	auipc	s6,0x8
    1cb4:	b70b0b13          	addi	s6,s6,-1168 # 9820 <buf>
    1cb8:	416004bb          	negw	s1,s6
    1cbc:	0ff4f493          	andi	s1,s1,255
    1cc0:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1cc4:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1cc6:	6a85                	lui	s5,0x1
    1cc8:	42da8a93          	addi	s5,s5,1069 # 142d <iputtest+0x6f>
{
    1ccc:	87da                	mv	a5,s6
        buf[i] = seq++;
    1cce:	0097873b          	addw	a4,a5,s1
    1cd2:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1cd6:	0785                	addi	a5,a5,1
    1cd8:	fef99be3          	bne	s3,a5,1cce <pipe1+0xe2>
        buf[i] = seq++;
    1cdc:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1ce0:	40900613          	li	a2,1033
    1ce4:	85de                	mv	a1,s7
    1ce6:	fac42503          	lw	a0,-84(s0)
    1cea:	00003097          	auipc	ra,0x3
    1cee:	be6080e7          	jalr	-1050(ra) # 48d0 <write>
    1cf2:	40900793          	li	a5,1033
    1cf6:	00f51c63          	bne	a0,a5,1d0e <pipe1+0x122>
    for(n = 0; n < N; n++){
    1cfa:	24a5                	addiw	s1,s1,9
    1cfc:	0ff4f493          	andi	s1,s1,255
    1d00:	fd5a16e3          	bne	s4,s5,1ccc <pipe1+0xe0>
    exit(0);
    1d04:	4501                	li	a0,0
    1d06:	00003097          	auipc	ra,0x3
    1d0a:	baa080e7          	jalr	-1110(ra) # 48b0 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1d0e:	85ca                	mv	a1,s2
    1d10:	00004517          	auipc	a0,0x4
    1d14:	f9050513          	addi	a0,a0,-112 # 5ca0 <malloc+0xfaa>
    1d18:	00003097          	auipc	ra,0x3
    1d1c:	f20080e7          	jalr	-224(ra) # 4c38 <printf>
        exit(1);
    1d20:	4505                	li	a0,1
    1d22:	00003097          	auipc	ra,0x3
    1d26:	b8e080e7          	jalr	-1138(ra) # 48b0 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1d2a:	85ca                	mv	a1,s2
    1d2c:	00004517          	auipc	a0,0x4
    1d30:	f8c50513          	addi	a0,a0,-116 # 5cb8 <malloc+0xfc2>
    1d34:	00003097          	auipc	ra,0x3
    1d38:	f04080e7          	jalr	-252(ra) # 4c38 <printf>
}
    1d3c:	60e6                	ld	ra,88(sp)
    1d3e:	6446                	ld	s0,80(sp)
    1d40:	64a6                	ld	s1,72(sp)
    1d42:	6906                	ld	s2,64(sp)
    1d44:	79e2                	ld	s3,56(sp)
    1d46:	7a42                	ld	s4,48(sp)
    1d48:	7aa2                	ld	s5,40(sp)
    1d4a:	7b02                	ld	s6,32(sp)
    1d4c:	6be2                	ld	s7,24(sp)
    1d4e:	6125                	addi	sp,sp,96
    1d50:	8082                	ret
    if(total != N * SZ){
    1d52:	6785                	lui	a5,0x1
    1d54:	42d78793          	addi	a5,a5,1069 # 142d <iputtest+0x6f>
    1d58:	02fa0063          	beq	s4,a5,1d78 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    1d5c:	85d2                	mv	a1,s4
    1d5e:	00004517          	auipc	a0,0x4
    1d62:	f7250513          	addi	a0,a0,-142 # 5cd0 <malloc+0xfda>
    1d66:	00003097          	auipc	ra,0x3
    1d6a:	ed2080e7          	jalr	-302(ra) # 4c38 <printf>
      exit(1);
    1d6e:	4505                	li	a0,1
    1d70:	00003097          	auipc	ra,0x3
    1d74:	b40080e7          	jalr	-1216(ra) # 48b0 <exit>
    close(fds[0]);
    1d78:	fa842503          	lw	a0,-88(s0)
    1d7c:	00003097          	auipc	ra,0x3
    1d80:	b5c080e7          	jalr	-1188(ra) # 48d8 <close>
    wait(&xstatus);
    1d84:	fa440513          	addi	a0,s0,-92
    1d88:	00003097          	auipc	ra,0x3
    1d8c:	b30080e7          	jalr	-1232(ra) # 48b8 <wait>
    exit(xstatus);
    1d90:	fa442503          	lw	a0,-92(s0)
    1d94:	00003097          	auipc	ra,0x3
    1d98:	b1c080e7          	jalr	-1252(ra) # 48b0 <exit>
    printf("%s: fork() failed\n", s);
    1d9c:	85ca                	mv	a1,s2
    1d9e:	00004517          	auipc	a0,0x4
    1da2:	f5250513          	addi	a0,a0,-174 # 5cf0 <malloc+0xffa>
    1da6:	00003097          	auipc	ra,0x3
    1daa:	e92080e7          	jalr	-366(ra) # 4c38 <printf>
    exit(1);
    1dae:	4505                	li	a0,1
    1db0:	00003097          	auipc	ra,0x3
    1db4:	b00080e7          	jalr	-1280(ra) # 48b0 <exit>

0000000000001db8 <pgbug>:
{
    1db8:	7179                	addi	sp,sp,-48
    1dba:	f406                	sd	ra,40(sp)
    1dbc:	f022                	sd	s0,32(sp)
    1dbe:	ec26                	sd	s1,24(sp)
    1dc0:	1800                	addi	s0,sp,48
  argv[0] = 0;
    1dc2:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1dc6:	00005497          	auipc	s1,0x5
    1dca:	22a4b483          	ld	s1,554(s1) # 6ff0 <__SDATA_BEGIN__>
    1dce:	fd840593          	addi	a1,s0,-40
    1dd2:	8526                	mv	a0,s1
    1dd4:	00003097          	auipc	ra,0x3
    1dd8:	b14080e7          	jalr	-1260(ra) # 48e8 <exec>
  pipe((int*)0xeaeb0b5b00002f5e);
    1ddc:	8526                	mv	a0,s1
    1dde:	00003097          	auipc	ra,0x3
    1de2:	ae2080e7          	jalr	-1310(ra) # 48c0 <pipe>
  exit(0);
    1de6:	4501                	li	a0,0
    1de8:	00003097          	auipc	ra,0x3
    1dec:	ac8080e7          	jalr	-1336(ra) # 48b0 <exit>

0000000000001df0 <preempt>:
{
    1df0:	7139                	addi	sp,sp,-64
    1df2:	fc06                	sd	ra,56(sp)
    1df4:	f822                	sd	s0,48(sp)
    1df6:	f426                	sd	s1,40(sp)
    1df8:	f04a                	sd	s2,32(sp)
    1dfa:	ec4e                	sd	s3,24(sp)
    1dfc:	e852                	sd	s4,16(sp)
    1dfe:	0080                	addi	s0,sp,64
    1e00:	892a                	mv	s2,a0
  pid1 = fork();
    1e02:	00003097          	auipc	ra,0x3
    1e06:	aa6080e7          	jalr	-1370(ra) # 48a8 <fork>
  if(pid1 < 0) {
    1e0a:	00054563          	bltz	a0,1e14 <preempt+0x24>
    1e0e:	84aa                	mv	s1,a0
  if(pid1 == 0)
    1e10:	ed19                	bnez	a0,1e2e <preempt+0x3e>
    for(;;)
    1e12:	a001                	j	1e12 <preempt+0x22>
    printf("%s: fork failed");
    1e14:	00003517          	auipc	a0,0x3
    1e18:	77450513          	addi	a0,a0,1908 # 5588 <malloc+0x892>
    1e1c:	00003097          	auipc	ra,0x3
    1e20:	e1c080e7          	jalr	-484(ra) # 4c38 <printf>
    exit(1);
    1e24:	4505                	li	a0,1
    1e26:	00003097          	auipc	ra,0x3
    1e2a:	a8a080e7          	jalr	-1398(ra) # 48b0 <exit>
  pid2 = fork();
    1e2e:	00003097          	auipc	ra,0x3
    1e32:	a7a080e7          	jalr	-1414(ra) # 48a8 <fork>
    1e36:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    1e38:	00054463          	bltz	a0,1e40 <preempt+0x50>
  if(pid2 == 0)
    1e3c:	e105                	bnez	a0,1e5c <preempt+0x6c>
    for(;;)
    1e3e:	a001                	j	1e3e <preempt+0x4e>
    printf("%s: fork failed\n", s);
    1e40:	85ca                	mv	a1,s2
    1e42:	00003517          	auipc	a0,0x3
    1e46:	68650513          	addi	a0,a0,1670 # 54c8 <malloc+0x7d2>
    1e4a:	00003097          	auipc	ra,0x3
    1e4e:	dee080e7          	jalr	-530(ra) # 4c38 <printf>
    exit(1);
    1e52:	4505                	li	a0,1
    1e54:	00003097          	auipc	ra,0x3
    1e58:	a5c080e7          	jalr	-1444(ra) # 48b0 <exit>
  pipe(pfds);
    1e5c:	fc840513          	addi	a0,s0,-56
    1e60:	00003097          	auipc	ra,0x3
    1e64:	a60080e7          	jalr	-1440(ra) # 48c0 <pipe>
  pid3 = fork();
    1e68:	00003097          	auipc	ra,0x3
    1e6c:	a40080e7          	jalr	-1472(ra) # 48a8 <fork>
    1e70:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    1e72:	02054e63          	bltz	a0,1eae <preempt+0xbe>
  if(pid3 == 0){
    1e76:	e13d                	bnez	a0,1edc <preempt+0xec>
    close(pfds[0]);
    1e78:	fc842503          	lw	a0,-56(s0)
    1e7c:	00003097          	auipc	ra,0x3
    1e80:	a5c080e7          	jalr	-1444(ra) # 48d8 <close>
    if(write(pfds[1], "x", 1) != 1)
    1e84:	4605                	li	a2,1
    1e86:	00003597          	auipc	a1,0x3
    1e8a:	2ba58593          	addi	a1,a1,698 # 5140 <malloc+0x44a>
    1e8e:	fcc42503          	lw	a0,-52(s0)
    1e92:	00003097          	auipc	ra,0x3
    1e96:	a3e080e7          	jalr	-1474(ra) # 48d0 <write>
    1e9a:	4785                	li	a5,1
    1e9c:	02f51763          	bne	a0,a5,1eca <preempt+0xda>
    close(pfds[1]);
    1ea0:	fcc42503          	lw	a0,-52(s0)
    1ea4:	00003097          	auipc	ra,0x3
    1ea8:	a34080e7          	jalr	-1484(ra) # 48d8 <close>
    for(;;)
    1eac:	a001                	j	1eac <preempt+0xbc>
     printf("%s: fork failed\n", s);
    1eae:	85ca                	mv	a1,s2
    1eb0:	00003517          	auipc	a0,0x3
    1eb4:	61850513          	addi	a0,a0,1560 # 54c8 <malloc+0x7d2>
    1eb8:	00003097          	auipc	ra,0x3
    1ebc:	d80080e7          	jalr	-640(ra) # 4c38 <printf>
     exit(1);
    1ec0:	4505                	li	a0,1
    1ec2:	00003097          	auipc	ra,0x3
    1ec6:	9ee080e7          	jalr	-1554(ra) # 48b0 <exit>
      printf("%s: preempt write error");
    1eca:	00004517          	auipc	a0,0x4
    1ece:	e3e50513          	addi	a0,a0,-450 # 5d08 <malloc+0x1012>
    1ed2:	00003097          	auipc	ra,0x3
    1ed6:	d66080e7          	jalr	-666(ra) # 4c38 <printf>
    1eda:	b7d9                	j	1ea0 <preempt+0xb0>
  close(pfds[1]);
    1edc:	fcc42503          	lw	a0,-52(s0)
    1ee0:	00003097          	auipc	ra,0x3
    1ee4:	9f8080e7          	jalr	-1544(ra) # 48d8 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    1ee8:	660d                	lui	a2,0x3
    1eea:	00008597          	auipc	a1,0x8
    1eee:	93658593          	addi	a1,a1,-1738 # 9820 <buf>
    1ef2:	fc842503          	lw	a0,-56(s0)
    1ef6:	00003097          	auipc	ra,0x3
    1efa:	9d2080e7          	jalr	-1582(ra) # 48c8 <read>
    1efe:	4785                	li	a5,1
    1f00:	02f50263          	beq	a0,a5,1f24 <preempt+0x134>
    printf("%s: preempt read error");
    1f04:	00004517          	auipc	a0,0x4
    1f08:	e1c50513          	addi	a0,a0,-484 # 5d20 <malloc+0x102a>
    1f0c:	00003097          	auipc	ra,0x3
    1f10:	d2c080e7          	jalr	-724(ra) # 4c38 <printf>
}
    1f14:	70e2                	ld	ra,56(sp)
    1f16:	7442                	ld	s0,48(sp)
    1f18:	74a2                	ld	s1,40(sp)
    1f1a:	7902                	ld	s2,32(sp)
    1f1c:	69e2                	ld	s3,24(sp)
    1f1e:	6a42                	ld	s4,16(sp)
    1f20:	6121                	addi	sp,sp,64
    1f22:	8082                	ret
  close(pfds[0]);
    1f24:	fc842503          	lw	a0,-56(s0)
    1f28:	00003097          	auipc	ra,0x3
    1f2c:	9b0080e7          	jalr	-1616(ra) # 48d8 <close>
  printf("kill... ");
    1f30:	00004517          	auipc	a0,0x4
    1f34:	e0850513          	addi	a0,a0,-504 # 5d38 <malloc+0x1042>
    1f38:	00003097          	auipc	ra,0x3
    1f3c:	d00080e7          	jalr	-768(ra) # 4c38 <printf>
  kill(pid1);
    1f40:	8526                	mv	a0,s1
    1f42:	00003097          	auipc	ra,0x3
    1f46:	99e080e7          	jalr	-1634(ra) # 48e0 <kill>
  kill(pid2);
    1f4a:	854e                	mv	a0,s3
    1f4c:	00003097          	auipc	ra,0x3
    1f50:	994080e7          	jalr	-1644(ra) # 48e0 <kill>
  kill(pid3);
    1f54:	8552                	mv	a0,s4
    1f56:	00003097          	auipc	ra,0x3
    1f5a:	98a080e7          	jalr	-1654(ra) # 48e0 <kill>
  printf("wait... ");
    1f5e:	00004517          	auipc	a0,0x4
    1f62:	dea50513          	addi	a0,a0,-534 # 5d48 <malloc+0x1052>
    1f66:	00003097          	auipc	ra,0x3
    1f6a:	cd2080e7          	jalr	-814(ra) # 4c38 <printf>
  wait(0);
    1f6e:	4501                	li	a0,0
    1f70:	00003097          	auipc	ra,0x3
    1f74:	948080e7          	jalr	-1720(ra) # 48b8 <wait>
  wait(0);
    1f78:	4501                	li	a0,0
    1f7a:	00003097          	auipc	ra,0x3
    1f7e:	93e080e7          	jalr	-1730(ra) # 48b8 <wait>
  wait(0);
    1f82:	4501                	li	a0,0
    1f84:	00003097          	auipc	ra,0x3
    1f88:	934080e7          	jalr	-1740(ra) # 48b8 <wait>
    1f8c:	b761                	j	1f14 <preempt+0x124>

0000000000001f8e <reparent>:
{
    1f8e:	7179                	addi	sp,sp,-48
    1f90:	f406                	sd	ra,40(sp)
    1f92:	f022                	sd	s0,32(sp)
    1f94:	ec26                	sd	s1,24(sp)
    1f96:	e84a                	sd	s2,16(sp)
    1f98:	e44e                	sd	s3,8(sp)
    1f9a:	e052                	sd	s4,0(sp)
    1f9c:	1800                	addi	s0,sp,48
    1f9e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    1fa0:	00003097          	auipc	ra,0x3
    1fa4:	990080e7          	jalr	-1648(ra) # 4930 <getpid>
    1fa8:	8a2a                	mv	s4,a0
    1faa:	0c800913          	li	s2,200
    int pid = fork();
    1fae:	00003097          	auipc	ra,0x3
    1fb2:	8fa080e7          	jalr	-1798(ra) # 48a8 <fork>
    1fb6:	84aa                	mv	s1,a0
    if(pid < 0){
    1fb8:	02054263          	bltz	a0,1fdc <reparent+0x4e>
    if(pid){
    1fbc:	cd21                	beqz	a0,2014 <reparent+0x86>
      if(wait(0) != pid){
    1fbe:	4501                	li	a0,0
    1fc0:	00003097          	auipc	ra,0x3
    1fc4:	8f8080e7          	jalr	-1800(ra) # 48b8 <wait>
    1fc8:	02951863          	bne	a0,s1,1ff8 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    1fcc:	397d                	addiw	s2,s2,-1
    1fce:	fe0910e3          	bnez	s2,1fae <reparent+0x20>
  exit(0);
    1fd2:	4501                	li	a0,0
    1fd4:	00003097          	auipc	ra,0x3
    1fd8:	8dc080e7          	jalr	-1828(ra) # 48b0 <exit>
      printf("%s: fork failed\n", s);
    1fdc:	85ce                	mv	a1,s3
    1fde:	00003517          	auipc	a0,0x3
    1fe2:	4ea50513          	addi	a0,a0,1258 # 54c8 <malloc+0x7d2>
    1fe6:	00003097          	auipc	ra,0x3
    1fea:	c52080e7          	jalr	-942(ra) # 4c38 <printf>
      exit(1);
    1fee:	4505                	li	a0,1
    1ff0:	00003097          	auipc	ra,0x3
    1ff4:	8c0080e7          	jalr	-1856(ra) # 48b0 <exit>
        printf("%s: wait wrong pid\n", s);
    1ff8:	85ce                	mv	a1,s3
    1ffa:	00003517          	auipc	a0,0x3
    1ffe:	55650513          	addi	a0,a0,1366 # 5550 <malloc+0x85a>
    2002:	00003097          	auipc	ra,0x3
    2006:	c36080e7          	jalr	-970(ra) # 4c38 <printf>
        exit(1);
    200a:	4505                	li	a0,1
    200c:	00003097          	auipc	ra,0x3
    2010:	8a4080e7          	jalr	-1884(ra) # 48b0 <exit>
      int pid2 = fork();
    2014:	00003097          	auipc	ra,0x3
    2018:	894080e7          	jalr	-1900(ra) # 48a8 <fork>
      if(pid2 < 0){
    201c:	00054763          	bltz	a0,202a <reparent+0x9c>
      exit(0);
    2020:	4501                	li	a0,0
    2022:	00003097          	auipc	ra,0x3
    2026:	88e080e7          	jalr	-1906(ra) # 48b0 <exit>
        kill(master_pid);
    202a:	8552                	mv	a0,s4
    202c:	00003097          	auipc	ra,0x3
    2030:	8b4080e7          	jalr	-1868(ra) # 48e0 <kill>
        exit(1);
    2034:	4505                	li	a0,1
    2036:	00003097          	auipc	ra,0x3
    203a:	87a080e7          	jalr	-1926(ra) # 48b0 <exit>

000000000000203e <sharedfd>:
{
    203e:	7159                	addi	sp,sp,-112
    2040:	f486                	sd	ra,104(sp)
    2042:	f0a2                	sd	s0,96(sp)
    2044:	eca6                	sd	s1,88(sp)
    2046:	e8ca                	sd	s2,80(sp)
    2048:	e4ce                	sd	s3,72(sp)
    204a:	e0d2                	sd	s4,64(sp)
    204c:	fc56                	sd	s5,56(sp)
    204e:	f85a                	sd	s6,48(sp)
    2050:	f45e                	sd	s7,40(sp)
    2052:	1880                	addi	s0,sp,112
    2054:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    2056:	00003517          	auipc	a0,0x3
    205a:	ec250513          	addi	a0,a0,-318 # 4f18 <malloc+0x222>
    205e:	00003097          	auipc	ra,0x3
    2062:	8a2080e7          	jalr	-1886(ra) # 4900 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    2066:	20200593          	li	a1,514
    206a:	00003517          	auipc	a0,0x3
    206e:	eae50513          	addi	a0,a0,-338 # 4f18 <malloc+0x222>
    2072:	00003097          	auipc	ra,0x3
    2076:	87e080e7          	jalr	-1922(ra) # 48f0 <open>
  if(fd < 0){
    207a:	04054a63          	bltz	a0,20ce <sharedfd+0x90>
    207e:	892a                	mv	s2,a0
  pid = fork();
    2080:	00003097          	auipc	ra,0x3
    2084:	828080e7          	jalr	-2008(ra) # 48a8 <fork>
    2088:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    208a:	06300593          	li	a1,99
    208e:	c119                	beqz	a0,2094 <sharedfd+0x56>
    2090:	07000593          	li	a1,112
    2094:	4629                	li	a2,10
    2096:	fa040513          	addi	a0,s0,-96
    209a:	00002097          	auipc	ra,0x2
    209e:	61a080e7          	jalr	1562(ra) # 46b4 <memset>
    20a2:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    20a6:	4629                	li	a2,10
    20a8:	fa040593          	addi	a1,s0,-96
    20ac:	854a                	mv	a0,s2
    20ae:	00003097          	auipc	ra,0x3
    20b2:	822080e7          	jalr	-2014(ra) # 48d0 <write>
    20b6:	47a9                	li	a5,10
    20b8:	02f51963          	bne	a0,a5,20ea <sharedfd+0xac>
  for(i = 0; i < N; i++){
    20bc:	34fd                	addiw	s1,s1,-1
    20be:	f4e5                	bnez	s1,20a6 <sharedfd+0x68>
  if(pid == 0) {
    20c0:	04099363          	bnez	s3,2106 <sharedfd+0xc8>
    exit(0);
    20c4:	4501                	li	a0,0
    20c6:	00002097          	auipc	ra,0x2
    20ca:	7ea080e7          	jalr	2026(ra) # 48b0 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    20ce:	85d2                	mv	a1,s4
    20d0:	00004517          	auipc	a0,0x4
    20d4:	c8850513          	addi	a0,a0,-888 # 5d58 <malloc+0x1062>
    20d8:	00003097          	auipc	ra,0x3
    20dc:	b60080e7          	jalr	-1184(ra) # 4c38 <printf>
    exit(1);
    20e0:	4505                	li	a0,1
    20e2:	00002097          	auipc	ra,0x2
    20e6:	7ce080e7          	jalr	1998(ra) # 48b0 <exit>
      printf("%s: write sharedfd failed\n", s);
    20ea:	85d2                	mv	a1,s4
    20ec:	00004517          	auipc	a0,0x4
    20f0:	c9450513          	addi	a0,a0,-876 # 5d80 <malloc+0x108a>
    20f4:	00003097          	auipc	ra,0x3
    20f8:	b44080e7          	jalr	-1212(ra) # 4c38 <printf>
      exit(1);
    20fc:	4505                	li	a0,1
    20fe:	00002097          	auipc	ra,0x2
    2102:	7b2080e7          	jalr	1970(ra) # 48b0 <exit>
    wait(&xstatus);
    2106:	f9c40513          	addi	a0,s0,-100
    210a:	00002097          	auipc	ra,0x2
    210e:	7ae080e7          	jalr	1966(ra) # 48b8 <wait>
    if(xstatus != 0)
    2112:	f9c42983          	lw	s3,-100(s0)
    2116:	00098763          	beqz	s3,2124 <sharedfd+0xe6>
      exit(xstatus);
    211a:	854e                	mv	a0,s3
    211c:	00002097          	auipc	ra,0x2
    2120:	794080e7          	jalr	1940(ra) # 48b0 <exit>
  close(fd);
    2124:	854a                	mv	a0,s2
    2126:	00002097          	auipc	ra,0x2
    212a:	7b2080e7          	jalr	1970(ra) # 48d8 <close>
  fd = open("sharedfd", 0);
    212e:	4581                	li	a1,0
    2130:	00003517          	auipc	a0,0x3
    2134:	de850513          	addi	a0,a0,-536 # 4f18 <malloc+0x222>
    2138:	00002097          	auipc	ra,0x2
    213c:	7b8080e7          	jalr	1976(ra) # 48f0 <open>
    2140:	8baa                	mv	s7,a0
  nc = np = 0;
    2142:	8ace                	mv	s5,s3
  if(fd < 0){
    2144:	02054563          	bltz	a0,216e <sharedfd+0x130>
    2148:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    214c:	06300493          	li	s1,99
      if(buf[i] == 'p')
    2150:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    2154:	4629                	li	a2,10
    2156:	fa040593          	addi	a1,s0,-96
    215a:	855e                	mv	a0,s7
    215c:	00002097          	auipc	ra,0x2
    2160:	76c080e7          	jalr	1900(ra) # 48c8 <read>
    2164:	02a05f63          	blez	a0,21a2 <sharedfd+0x164>
    2168:	fa040793          	addi	a5,s0,-96
    216c:	a01d                	j	2192 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    216e:	85d2                	mv	a1,s4
    2170:	00004517          	auipc	a0,0x4
    2174:	c3050513          	addi	a0,a0,-976 # 5da0 <malloc+0x10aa>
    2178:	00003097          	auipc	ra,0x3
    217c:	ac0080e7          	jalr	-1344(ra) # 4c38 <printf>
    exit(1);
    2180:	4505                	li	a0,1
    2182:	00002097          	auipc	ra,0x2
    2186:	72e080e7          	jalr	1838(ra) # 48b0 <exit>
        nc++;
    218a:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    218c:	0785                	addi	a5,a5,1
    218e:	fd2783e3          	beq	a5,s2,2154 <sharedfd+0x116>
      if(buf[i] == 'c')
    2192:	0007c703          	lbu	a4,0(a5)
    2196:	fe970ae3          	beq	a4,s1,218a <sharedfd+0x14c>
      if(buf[i] == 'p')
    219a:	ff6719e3          	bne	a4,s6,218c <sharedfd+0x14e>
        np++;
    219e:	2a85                	addiw	s5,s5,1
    21a0:	b7f5                	j	218c <sharedfd+0x14e>
  close(fd);
    21a2:	855e                	mv	a0,s7
    21a4:	00002097          	auipc	ra,0x2
    21a8:	734080e7          	jalr	1844(ra) # 48d8 <close>
  unlink("sharedfd");
    21ac:	00003517          	auipc	a0,0x3
    21b0:	d6c50513          	addi	a0,a0,-660 # 4f18 <malloc+0x222>
    21b4:	00002097          	auipc	ra,0x2
    21b8:	74c080e7          	jalr	1868(ra) # 4900 <unlink>
  if(nc == N*SZ && np == N*SZ){
    21bc:	6789                	lui	a5,0x2
    21be:	71078793          	addi	a5,a5,1808 # 2710 <linktest+0xf8>
    21c2:	00f99763          	bne	s3,a5,21d0 <sharedfd+0x192>
    21c6:	6789                	lui	a5,0x2
    21c8:	71078793          	addi	a5,a5,1808 # 2710 <linktest+0xf8>
    21cc:	02fa8063          	beq	s5,a5,21ec <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    21d0:	85d2                	mv	a1,s4
    21d2:	00004517          	auipc	a0,0x4
    21d6:	bf650513          	addi	a0,a0,-1034 # 5dc8 <malloc+0x10d2>
    21da:	00003097          	auipc	ra,0x3
    21de:	a5e080e7          	jalr	-1442(ra) # 4c38 <printf>
    exit(1);
    21e2:	4505                	li	a0,1
    21e4:	00002097          	auipc	ra,0x2
    21e8:	6cc080e7          	jalr	1740(ra) # 48b0 <exit>
    exit(0);
    21ec:	4501                	li	a0,0
    21ee:	00002097          	auipc	ra,0x2
    21f2:	6c2080e7          	jalr	1730(ra) # 48b0 <exit>

00000000000021f6 <fourfiles>:
{
    21f6:	7171                	addi	sp,sp,-176
    21f8:	f506                	sd	ra,168(sp)
    21fa:	f122                	sd	s0,160(sp)
    21fc:	ed26                	sd	s1,152(sp)
    21fe:	e94a                	sd	s2,144(sp)
    2200:	e54e                	sd	s3,136(sp)
    2202:	e152                	sd	s4,128(sp)
    2204:	fcd6                	sd	s5,120(sp)
    2206:	f8da                	sd	s6,112(sp)
    2208:	f4de                	sd	s7,104(sp)
    220a:	f0e2                	sd	s8,96(sp)
    220c:	ece6                	sd	s9,88(sp)
    220e:	e8ea                	sd	s10,80(sp)
    2210:	e4ee                	sd	s11,72(sp)
    2212:	1900                	addi	s0,sp,176
    2214:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    2218:	00003797          	auipc	a5,0x3
    221c:	bc878793          	addi	a5,a5,-1080 # 4de0 <malloc+0xea>
    2220:	f6f43823          	sd	a5,-144(s0)
    2224:	00003797          	auipc	a5,0x3
    2228:	bc478793          	addi	a5,a5,-1084 # 4de8 <malloc+0xf2>
    222c:	f6f43c23          	sd	a5,-136(s0)
    2230:	00003797          	auipc	a5,0x3
    2234:	bc078793          	addi	a5,a5,-1088 # 4df0 <malloc+0xfa>
    2238:	f8f43023          	sd	a5,-128(s0)
    223c:	00003797          	auipc	a5,0x3
    2240:	bbc78793          	addi	a5,a5,-1092 # 4df8 <malloc+0x102>
    2244:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2248:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    224c:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    224e:	4481                	li	s1,0
    2250:	4a11                	li	s4,4
    fname = names[pi];
    2252:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2256:	854e                	mv	a0,s3
    2258:	00002097          	auipc	ra,0x2
    225c:	6a8080e7          	jalr	1704(ra) # 4900 <unlink>
    pid = fork();
    2260:	00002097          	auipc	ra,0x2
    2264:	648080e7          	jalr	1608(ra) # 48a8 <fork>
    if(pid < 0){
    2268:	04054463          	bltz	a0,22b0 <fourfiles+0xba>
    if(pid == 0){
    226c:	c12d                	beqz	a0,22ce <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    226e:	2485                	addiw	s1,s1,1
    2270:	0921                	addi	s2,s2,8
    2272:	ff4490e3          	bne	s1,s4,2252 <fourfiles+0x5c>
    2276:	4491                	li	s1,4
    wait(&xstatus);
    2278:	f6c40513          	addi	a0,s0,-148
    227c:	00002097          	auipc	ra,0x2
    2280:	63c080e7          	jalr	1596(ra) # 48b8 <wait>
    if(xstatus != 0)
    2284:	f6c42b03          	lw	s6,-148(s0)
    2288:	0c0b1e63          	bnez	s6,2364 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    228c:	34fd                	addiw	s1,s1,-1
    228e:	f4ed                	bnez	s1,2278 <fourfiles+0x82>
    2290:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2294:	00007a17          	auipc	s4,0x7
    2298:	58ca0a13          	addi	s4,s4,1420 # 9820 <buf>
    229c:	00007a97          	auipc	s5,0x7
    22a0:	585a8a93          	addi	s5,s5,1413 # 9821 <buf+0x1>
    if(total != N*SZ){
    22a4:	6d85                	lui	s11,0x1
    22a6:	770d8d93          	addi	s11,s11,1904 # 1770 <openiputtest+0x6e>
  for(i = 0; i < NCHILD; i++){
    22aa:	03400d13          	li	s10,52
    22ae:	aa1d                	j	23e4 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    22b0:	f5843583          	ld	a1,-168(s0)
    22b4:	00004517          	auipc	a0,0x4
    22b8:	9a450513          	addi	a0,a0,-1628 # 5c58 <malloc+0xf62>
    22bc:	00003097          	auipc	ra,0x3
    22c0:	97c080e7          	jalr	-1668(ra) # 4c38 <printf>
      exit(1);
    22c4:	4505                	li	a0,1
    22c6:	00002097          	auipc	ra,0x2
    22ca:	5ea080e7          	jalr	1514(ra) # 48b0 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    22ce:	20200593          	li	a1,514
    22d2:	854e                	mv	a0,s3
    22d4:	00002097          	auipc	ra,0x2
    22d8:	61c080e7          	jalr	1564(ra) # 48f0 <open>
    22dc:	892a                	mv	s2,a0
      if(fd < 0){
    22de:	04054763          	bltz	a0,232c <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    22e2:	1f400613          	li	a2,500
    22e6:	0304859b          	addiw	a1,s1,48
    22ea:	00007517          	auipc	a0,0x7
    22ee:	53650513          	addi	a0,a0,1334 # 9820 <buf>
    22f2:	00002097          	auipc	ra,0x2
    22f6:	3c2080e7          	jalr	962(ra) # 46b4 <memset>
    22fa:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    22fc:	00007997          	auipc	s3,0x7
    2300:	52498993          	addi	s3,s3,1316 # 9820 <buf>
    2304:	1f400613          	li	a2,500
    2308:	85ce                	mv	a1,s3
    230a:	854a                	mv	a0,s2
    230c:	00002097          	auipc	ra,0x2
    2310:	5c4080e7          	jalr	1476(ra) # 48d0 <write>
    2314:	85aa                	mv	a1,a0
    2316:	1f400793          	li	a5,500
    231a:	02f51863          	bne	a0,a5,234a <fourfiles+0x154>
      for(i = 0; i < N; i++){
    231e:	34fd                	addiw	s1,s1,-1
    2320:	f0f5                	bnez	s1,2304 <fourfiles+0x10e>
      exit(0);
    2322:	4501                	li	a0,0
    2324:	00002097          	auipc	ra,0x2
    2328:	58c080e7          	jalr	1420(ra) # 48b0 <exit>
        printf("create failed\n", s);
    232c:	f5843583          	ld	a1,-168(s0)
    2330:	00004517          	auipc	a0,0x4
    2334:	ab050513          	addi	a0,a0,-1360 # 5de0 <malloc+0x10ea>
    2338:	00003097          	auipc	ra,0x3
    233c:	900080e7          	jalr	-1792(ra) # 4c38 <printf>
        exit(1);
    2340:	4505                	li	a0,1
    2342:	00002097          	auipc	ra,0x2
    2346:	56e080e7          	jalr	1390(ra) # 48b0 <exit>
          printf("write failed %d\n", n);
    234a:	00004517          	auipc	a0,0x4
    234e:	aa650513          	addi	a0,a0,-1370 # 5df0 <malloc+0x10fa>
    2352:	00003097          	auipc	ra,0x3
    2356:	8e6080e7          	jalr	-1818(ra) # 4c38 <printf>
          exit(1);
    235a:	4505                	li	a0,1
    235c:	00002097          	auipc	ra,0x2
    2360:	554080e7          	jalr	1364(ra) # 48b0 <exit>
      exit(xstatus);
    2364:	855a                	mv	a0,s6
    2366:	00002097          	auipc	ra,0x2
    236a:	54a080e7          	jalr	1354(ra) # 48b0 <exit>
          printf("wrong char\n", s);
    236e:	f5843583          	ld	a1,-168(s0)
    2372:	00004517          	auipc	a0,0x4
    2376:	a9650513          	addi	a0,a0,-1386 # 5e08 <malloc+0x1112>
    237a:	00003097          	auipc	ra,0x3
    237e:	8be080e7          	jalr	-1858(ra) # 4c38 <printf>
          exit(1);
    2382:	4505                	li	a0,1
    2384:	00002097          	auipc	ra,0x2
    2388:	52c080e7          	jalr	1324(ra) # 48b0 <exit>
      total += n;
    238c:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2390:	660d                	lui	a2,0x3
    2392:	85d2                	mv	a1,s4
    2394:	854e                	mv	a0,s3
    2396:	00002097          	auipc	ra,0x2
    239a:	532080e7          	jalr	1330(ra) # 48c8 <read>
    239e:	02a05363          	blez	a0,23c4 <fourfiles+0x1ce>
    23a2:	00007797          	auipc	a5,0x7
    23a6:	47e78793          	addi	a5,a5,1150 # 9820 <buf>
    23aa:	fff5069b          	addiw	a3,a0,-1
    23ae:	1682                	slli	a3,a3,0x20
    23b0:	9281                	srli	a3,a3,0x20
    23b2:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    23b4:	0007c703          	lbu	a4,0(a5)
    23b8:	fa971be3          	bne	a4,s1,236e <fourfiles+0x178>
      for(j = 0; j < n; j++){
    23bc:	0785                	addi	a5,a5,1
    23be:	fed79be3          	bne	a5,a3,23b4 <fourfiles+0x1be>
    23c2:	b7e9                	j	238c <fourfiles+0x196>
    close(fd);
    23c4:	854e                	mv	a0,s3
    23c6:	00002097          	auipc	ra,0x2
    23ca:	512080e7          	jalr	1298(ra) # 48d8 <close>
    if(total != N*SZ){
    23ce:	03b91863          	bne	s2,s11,23fe <fourfiles+0x208>
    unlink(fname);
    23d2:	8566                	mv	a0,s9
    23d4:	00002097          	auipc	ra,0x2
    23d8:	52c080e7          	jalr	1324(ra) # 4900 <unlink>
  for(i = 0; i < NCHILD; i++){
    23dc:	0c21                	addi	s8,s8,8
    23de:	2b85                	addiw	s7,s7,1
    23e0:	03ab8d63          	beq	s7,s10,241a <fourfiles+0x224>
    fname = names[i];
    23e4:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    23e8:	4581                	li	a1,0
    23ea:	8566                	mv	a0,s9
    23ec:	00002097          	auipc	ra,0x2
    23f0:	504080e7          	jalr	1284(ra) # 48f0 <open>
    23f4:	89aa                	mv	s3,a0
    total = 0;
    23f6:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    23f8:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    23fc:	bf51                	j	2390 <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    23fe:	85ca                	mv	a1,s2
    2400:	00004517          	auipc	a0,0x4
    2404:	a1850513          	addi	a0,a0,-1512 # 5e18 <malloc+0x1122>
    2408:	00003097          	auipc	ra,0x3
    240c:	830080e7          	jalr	-2000(ra) # 4c38 <printf>
      exit(1);
    2410:	4505                	li	a0,1
    2412:	00002097          	auipc	ra,0x2
    2416:	49e080e7          	jalr	1182(ra) # 48b0 <exit>
}
    241a:	70aa                	ld	ra,168(sp)
    241c:	740a                	ld	s0,160(sp)
    241e:	64ea                	ld	s1,152(sp)
    2420:	694a                	ld	s2,144(sp)
    2422:	69aa                	ld	s3,136(sp)
    2424:	6a0a                	ld	s4,128(sp)
    2426:	7ae6                	ld	s5,120(sp)
    2428:	7b46                	ld	s6,112(sp)
    242a:	7ba6                	ld	s7,104(sp)
    242c:	7c06                	ld	s8,96(sp)
    242e:	6ce6                	ld	s9,88(sp)
    2430:	6d46                	ld	s10,80(sp)
    2432:	6da6                	ld	s11,72(sp)
    2434:	614d                	addi	sp,sp,176
    2436:	8082                	ret

0000000000002438 <bigfile>:
{
    2438:	7139                	addi	sp,sp,-64
    243a:	fc06                	sd	ra,56(sp)
    243c:	f822                	sd	s0,48(sp)
    243e:	f426                	sd	s1,40(sp)
    2440:	f04a                	sd	s2,32(sp)
    2442:	ec4e                	sd	s3,24(sp)
    2444:	e852                	sd	s4,16(sp)
    2446:	e456                	sd	s5,8(sp)
    2448:	0080                	addi	s0,sp,64
    244a:	8aaa                	mv	s5,a0
  unlink("bigfile");
    244c:	00003517          	auipc	a0,0x3
    2450:	c0450513          	addi	a0,a0,-1020 # 5050 <malloc+0x35a>
    2454:	00002097          	auipc	ra,0x2
    2458:	4ac080e7          	jalr	1196(ra) # 4900 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    245c:	20200593          	li	a1,514
    2460:	00003517          	auipc	a0,0x3
    2464:	bf050513          	addi	a0,a0,-1040 # 5050 <malloc+0x35a>
    2468:	00002097          	auipc	ra,0x2
    246c:	488080e7          	jalr	1160(ra) # 48f0 <open>
    2470:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    2472:	4481                	li	s1,0
    memset(buf, i, SZ);
    2474:	00007917          	auipc	s2,0x7
    2478:	3ac90913          	addi	s2,s2,940 # 9820 <buf>
  for(i = 0; i < N; i++){
    247c:	4a51                	li	s4,20
  if(fd < 0){
    247e:	0a054063          	bltz	a0,251e <bigfile+0xe6>
    memset(buf, i, SZ);
    2482:	25800613          	li	a2,600
    2486:	85a6                	mv	a1,s1
    2488:	854a                	mv	a0,s2
    248a:	00002097          	auipc	ra,0x2
    248e:	22a080e7          	jalr	554(ra) # 46b4 <memset>
    if(write(fd, buf, SZ) != SZ){
    2492:	25800613          	li	a2,600
    2496:	85ca                	mv	a1,s2
    2498:	854e                	mv	a0,s3
    249a:	00002097          	auipc	ra,0x2
    249e:	436080e7          	jalr	1078(ra) # 48d0 <write>
    24a2:	25800793          	li	a5,600
    24a6:	08f51a63          	bne	a0,a5,253a <bigfile+0x102>
  for(i = 0; i < N; i++){
    24aa:	2485                	addiw	s1,s1,1
    24ac:	fd449be3          	bne	s1,s4,2482 <bigfile+0x4a>
  close(fd);
    24b0:	854e                	mv	a0,s3
    24b2:	00002097          	auipc	ra,0x2
    24b6:	426080e7          	jalr	1062(ra) # 48d8 <close>
  fd = open("bigfile", 0);
    24ba:	4581                	li	a1,0
    24bc:	00003517          	auipc	a0,0x3
    24c0:	b9450513          	addi	a0,a0,-1132 # 5050 <malloc+0x35a>
    24c4:	00002097          	auipc	ra,0x2
    24c8:	42c080e7          	jalr	1068(ra) # 48f0 <open>
    24cc:	8a2a                	mv	s4,a0
  total = 0;
    24ce:	4981                	li	s3,0
  for(i = 0; ; i++){
    24d0:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    24d2:	00007917          	auipc	s2,0x7
    24d6:	34e90913          	addi	s2,s2,846 # 9820 <buf>
  if(fd < 0){
    24da:	06054e63          	bltz	a0,2556 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    24de:	12c00613          	li	a2,300
    24e2:	85ca                	mv	a1,s2
    24e4:	8552                	mv	a0,s4
    24e6:	00002097          	auipc	ra,0x2
    24ea:	3e2080e7          	jalr	994(ra) # 48c8 <read>
    if(cc < 0){
    24ee:	08054263          	bltz	a0,2572 <bigfile+0x13a>
    if(cc == 0)
    24f2:	c971                	beqz	a0,25c6 <bigfile+0x18e>
    if(cc != SZ/2){
    24f4:	12c00793          	li	a5,300
    24f8:	08f51b63          	bne	a0,a5,258e <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    24fc:	01f4d79b          	srliw	a5,s1,0x1f
    2500:	9fa5                	addw	a5,a5,s1
    2502:	4017d79b          	sraiw	a5,a5,0x1
    2506:	00094703          	lbu	a4,0(s2)
    250a:	0af71063          	bne	a4,a5,25aa <bigfile+0x172>
    250e:	12b94703          	lbu	a4,299(s2)
    2512:	08f71c63          	bne	a4,a5,25aa <bigfile+0x172>
    total += cc;
    2516:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    251a:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    251c:	b7c9                	j	24de <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    251e:	85d6                	mv	a1,s5
    2520:	00004517          	auipc	a0,0x4
    2524:	91050513          	addi	a0,a0,-1776 # 5e30 <malloc+0x113a>
    2528:	00002097          	auipc	ra,0x2
    252c:	710080e7          	jalr	1808(ra) # 4c38 <printf>
    exit(1);
    2530:	4505                	li	a0,1
    2532:	00002097          	auipc	ra,0x2
    2536:	37e080e7          	jalr	894(ra) # 48b0 <exit>
      printf("%s: write bigfile failed\n", s);
    253a:	85d6                	mv	a1,s5
    253c:	00004517          	auipc	a0,0x4
    2540:	91450513          	addi	a0,a0,-1772 # 5e50 <malloc+0x115a>
    2544:	00002097          	auipc	ra,0x2
    2548:	6f4080e7          	jalr	1780(ra) # 4c38 <printf>
      exit(1);
    254c:	4505                	li	a0,1
    254e:	00002097          	auipc	ra,0x2
    2552:	362080e7          	jalr	866(ra) # 48b0 <exit>
    printf("%s: cannot open bigfile\n", s);
    2556:	85d6                	mv	a1,s5
    2558:	00004517          	auipc	a0,0x4
    255c:	91850513          	addi	a0,a0,-1768 # 5e70 <malloc+0x117a>
    2560:	00002097          	auipc	ra,0x2
    2564:	6d8080e7          	jalr	1752(ra) # 4c38 <printf>
    exit(1);
    2568:	4505                	li	a0,1
    256a:	00002097          	auipc	ra,0x2
    256e:	346080e7          	jalr	838(ra) # 48b0 <exit>
      printf("%s: read bigfile failed\n", s);
    2572:	85d6                	mv	a1,s5
    2574:	00004517          	auipc	a0,0x4
    2578:	91c50513          	addi	a0,a0,-1764 # 5e90 <malloc+0x119a>
    257c:	00002097          	auipc	ra,0x2
    2580:	6bc080e7          	jalr	1724(ra) # 4c38 <printf>
      exit(1);
    2584:	4505                	li	a0,1
    2586:	00002097          	auipc	ra,0x2
    258a:	32a080e7          	jalr	810(ra) # 48b0 <exit>
      printf("%s: short read bigfile\n", s);
    258e:	85d6                	mv	a1,s5
    2590:	00004517          	auipc	a0,0x4
    2594:	92050513          	addi	a0,a0,-1760 # 5eb0 <malloc+0x11ba>
    2598:	00002097          	auipc	ra,0x2
    259c:	6a0080e7          	jalr	1696(ra) # 4c38 <printf>
      exit(1);
    25a0:	4505                	li	a0,1
    25a2:	00002097          	auipc	ra,0x2
    25a6:	30e080e7          	jalr	782(ra) # 48b0 <exit>
      printf("%s: read bigfile wrong data\n", s);
    25aa:	85d6                	mv	a1,s5
    25ac:	00004517          	auipc	a0,0x4
    25b0:	91c50513          	addi	a0,a0,-1764 # 5ec8 <malloc+0x11d2>
    25b4:	00002097          	auipc	ra,0x2
    25b8:	684080e7          	jalr	1668(ra) # 4c38 <printf>
      exit(1);
    25bc:	4505                	li	a0,1
    25be:	00002097          	auipc	ra,0x2
    25c2:	2f2080e7          	jalr	754(ra) # 48b0 <exit>
  close(fd);
    25c6:	8552                	mv	a0,s4
    25c8:	00002097          	auipc	ra,0x2
    25cc:	310080e7          	jalr	784(ra) # 48d8 <close>
  if(total != N*SZ){
    25d0:	678d                	lui	a5,0x3
    25d2:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x104>
    25d6:	02f99363          	bne	s3,a5,25fc <bigfile+0x1c4>
  unlink("bigfile");
    25da:	00003517          	auipc	a0,0x3
    25de:	a7650513          	addi	a0,a0,-1418 # 5050 <malloc+0x35a>
    25e2:	00002097          	auipc	ra,0x2
    25e6:	31e080e7          	jalr	798(ra) # 4900 <unlink>
}
    25ea:	70e2                	ld	ra,56(sp)
    25ec:	7442                	ld	s0,48(sp)
    25ee:	74a2                	ld	s1,40(sp)
    25f0:	7902                	ld	s2,32(sp)
    25f2:	69e2                	ld	s3,24(sp)
    25f4:	6a42                	ld	s4,16(sp)
    25f6:	6aa2                	ld	s5,8(sp)
    25f8:	6121                	addi	sp,sp,64
    25fa:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    25fc:	85d6                	mv	a1,s5
    25fe:	00004517          	auipc	a0,0x4
    2602:	8ea50513          	addi	a0,a0,-1814 # 5ee8 <malloc+0x11f2>
    2606:	00002097          	auipc	ra,0x2
    260a:	632080e7          	jalr	1586(ra) # 4c38 <printf>
    exit(1);
    260e:	4505                	li	a0,1
    2610:	00002097          	auipc	ra,0x2
    2614:	2a0080e7          	jalr	672(ra) # 48b0 <exit>

0000000000002618 <linktest>:
{
    2618:	1101                	addi	sp,sp,-32
    261a:	ec06                	sd	ra,24(sp)
    261c:	e822                	sd	s0,16(sp)
    261e:	e426                	sd	s1,8(sp)
    2620:	e04a                	sd	s2,0(sp)
    2622:	1000                	addi	s0,sp,32
    2624:	892a                	mv	s2,a0
  unlink("lf1");
    2626:	00004517          	auipc	a0,0x4
    262a:	8e250513          	addi	a0,a0,-1822 # 5f08 <malloc+0x1212>
    262e:	00002097          	auipc	ra,0x2
    2632:	2d2080e7          	jalr	722(ra) # 4900 <unlink>
  unlink("lf2");
    2636:	00004517          	auipc	a0,0x4
    263a:	8da50513          	addi	a0,a0,-1830 # 5f10 <malloc+0x121a>
    263e:	00002097          	auipc	ra,0x2
    2642:	2c2080e7          	jalr	706(ra) # 4900 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    2646:	20200593          	li	a1,514
    264a:	00004517          	auipc	a0,0x4
    264e:	8be50513          	addi	a0,a0,-1858 # 5f08 <malloc+0x1212>
    2652:	00002097          	auipc	ra,0x2
    2656:	29e080e7          	jalr	670(ra) # 48f0 <open>
  if(fd < 0){
    265a:	10054763          	bltz	a0,2768 <linktest+0x150>
    265e:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    2660:	4615                	li	a2,5
    2662:	00003597          	auipc	a1,0x3
    2666:	d6658593          	addi	a1,a1,-666 # 53c8 <malloc+0x6d2>
    266a:	00002097          	auipc	ra,0x2
    266e:	266080e7          	jalr	614(ra) # 48d0 <write>
    2672:	4795                	li	a5,5
    2674:	10f51863          	bne	a0,a5,2784 <linktest+0x16c>
  close(fd);
    2678:	8526                	mv	a0,s1
    267a:	00002097          	auipc	ra,0x2
    267e:	25e080e7          	jalr	606(ra) # 48d8 <close>
  if(link("lf1", "lf2") < 0){
    2682:	00004597          	auipc	a1,0x4
    2686:	88e58593          	addi	a1,a1,-1906 # 5f10 <malloc+0x121a>
    268a:	00004517          	auipc	a0,0x4
    268e:	87e50513          	addi	a0,a0,-1922 # 5f08 <malloc+0x1212>
    2692:	00002097          	auipc	ra,0x2
    2696:	27e080e7          	jalr	638(ra) # 4910 <link>
    269a:	10054363          	bltz	a0,27a0 <linktest+0x188>
  unlink("lf1");
    269e:	00004517          	auipc	a0,0x4
    26a2:	86a50513          	addi	a0,a0,-1942 # 5f08 <malloc+0x1212>
    26a6:	00002097          	auipc	ra,0x2
    26aa:	25a080e7          	jalr	602(ra) # 4900 <unlink>
  if(open("lf1", 0) >= 0){
    26ae:	4581                	li	a1,0
    26b0:	00004517          	auipc	a0,0x4
    26b4:	85850513          	addi	a0,a0,-1960 # 5f08 <malloc+0x1212>
    26b8:	00002097          	auipc	ra,0x2
    26bc:	238080e7          	jalr	568(ra) # 48f0 <open>
    26c0:	0e055e63          	bgez	a0,27bc <linktest+0x1a4>
  fd = open("lf2", 0);
    26c4:	4581                	li	a1,0
    26c6:	00004517          	auipc	a0,0x4
    26ca:	84a50513          	addi	a0,a0,-1974 # 5f10 <malloc+0x121a>
    26ce:	00002097          	auipc	ra,0x2
    26d2:	222080e7          	jalr	546(ra) # 48f0 <open>
    26d6:	84aa                	mv	s1,a0
  if(fd < 0){
    26d8:	10054063          	bltz	a0,27d8 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    26dc:	660d                	lui	a2,0x3
    26de:	00007597          	auipc	a1,0x7
    26e2:	14258593          	addi	a1,a1,322 # 9820 <buf>
    26e6:	00002097          	auipc	ra,0x2
    26ea:	1e2080e7          	jalr	482(ra) # 48c8 <read>
    26ee:	4795                	li	a5,5
    26f0:	10f51263          	bne	a0,a5,27f4 <linktest+0x1dc>
  close(fd);
    26f4:	8526                	mv	a0,s1
    26f6:	00002097          	auipc	ra,0x2
    26fa:	1e2080e7          	jalr	482(ra) # 48d8 <close>
  if(link("lf2", "lf2") >= 0){
    26fe:	00004597          	auipc	a1,0x4
    2702:	81258593          	addi	a1,a1,-2030 # 5f10 <malloc+0x121a>
    2706:	852e                	mv	a0,a1
    2708:	00002097          	auipc	ra,0x2
    270c:	208080e7          	jalr	520(ra) # 4910 <link>
    2710:	10055063          	bgez	a0,2810 <linktest+0x1f8>
  unlink("lf2");
    2714:	00003517          	auipc	a0,0x3
    2718:	7fc50513          	addi	a0,a0,2044 # 5f10 <malloc+0x121a>
    271c:	00002097          	auipc	ra,0x2
    2720:	1e4080e7          	jalr	484(ra) # 4900 <unlink>
  if(link("lf2", "lf1") >= 0){
    2724:	00003597          	auipc	a1,0x3
    2728:	7e458593          	addi	a1,a1,2020 # 5f08 <malloc+0x1212>
    272c:	00003517          	auipc	a0,0x3
    2730:	7e450513          	addi	a0,a0,2020 # 5f10 <malloc+0x121a>
    2734:	00002097          	auipc	ra,0x2
    2738:	1dc080e7          	jalr	476(ra) # 4910 <link>
    273c:	0e055863          	bgez	a0,282c <linktest+0x214>
  if(link(".", "lf1") >= 0){
    2740:	00003597          	auipc	a1,0x3
    2744:	7c858593          	addi	a1,a1,1992 # 5f08 <malloc+0x1212>
    2748:	00003517          	auipc	a0,0x3
    274c:	2a050513          	addi	a0,a0,672 # 59e8 <malloc+0xcf2>
    2750:	00002097          	auipc	ra,0x2
    2754:	1c0080e7          	jalr	448(ra) # 4910 <link>
    2758:	0e055863          	bgez	a0,2848 <linktest+0x230>
}
    275c:	60e2                	ld	ra,24(sp)
    275e:	6442                	ld	s0,16(sp)
    2760:	64a2                	ld	s1,8(sp)
    2762:	6902                	ld	s2,0(sp)
    2764:	6105                	addi	sp,sp,32
    2766:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    2768:	85ca                	mv	a1,s2
    276a:	00003517          	auipc	a0,0x3
    276e:	7ae50513          	addi	a0,a0,1966 # 5f18 <malloc+0x1222>
    2772:	00002097          	auipc	ra,0x2
    2776:	4c6080e7          	jalr	1222(ra) # 4c38 <printf>
    exit(1);
    277a:	4505                	li	a0,1
    277c:	00002097          	auipc	ra,0x2
    2780:	134080e7          	jalr	308(ra) # 48b0 <exit>
    printf("%s: write lf1 failed\n", s);
    2784:	85ca                	mv	a1,s2
    2786:	00003517          	auipc	a0,0x3
    278a:	7aa50513          	addi	a0,a0,1962 # 5f30 <malloc+0x123a>
    278e:	00002097          	auipc	ra,0x2
    2792:	4aa080e7          	jalr	1194(ra) # 4c38 <printf>
    exit(1);
    2796:	4505                	li	a0,1
    2798:	00002097          	auipc	ra,0x2
    279c:	118080e7          	jalr	280(ra) # 48b0 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    27a0:	85ca                	mv	a1,s2
    27a2:	00003517          	auipc	a0,0x3
    27a6:	7a650513          	addi	a0,a0,1958 # 5f48 <malloc+0x1252>
    27aa:	00002097          	auipc	ra,0x2
    27ae:	48e080e7          	jalr	1166(ra) # 4c38 <printf>
    exit(1);
    27b2:	4505                	li	a0,1
    27b4:	00002097          	auipc	ra,0x2
    27b8:	0fc080e7          	jalr	252(ra) # 48b0 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    27bc:	85ca                	mv	a1,s2
    27be:	00003517          	auipc	a0,0x3
    27c2:	7aa50513          	addi	a0,a0,1962 # 5f68 <malloc+0x1272>
    27c6:	00002097          	auipc	ra,0x2
    27ca:	472080e7          	jalr	1138(ra) # 4c38 <printf>
    exit(1);
    27ce:	4505                	li	a0,1
    27d0:	00002097          	auipc	ra,0x2
    27d4:	0e0080e7          	jalr	224(ra) # 48b0 <exit>
    printf("%s: open lf2 failed\n", s);
    27d8:	85ca                	mv	a1,s2
    27da:	00003517          	auipc	a0,0x3
    27de:	7be50513          	addi	a0,a0,1982 # 5f98 <malloc+0x12a2>
    27e2:	00002097          	auipc	ra,0x2
    27e6:	456080e7          	jalr	1110(ra) # 4c38 <printf>
    exit(1);
    27ea:	4505                	li	a0,1
    27ec:	00002097          	auipc	ra,0x2
    27f0:	0c4080e7          	jalr	196(ra) # 48b0 <exit>
    printf("%s: read lf2 failed\n", s);
    27f4:	85ca                	mv	a1,s2
    27f6:	00003517          	auipc	a0,0x3
    27fa:	7ba50513          	addi	a0,a0,1978 # 5fb0 <malloc+0x12ba>
    27fe:	00002097          	auipc	ra,0x2
    2802:	43a080e7          	jalr	1082(ra) # 4c38 <printf>
    exit(1);
    2806:	4505                	li	a0,1
    2808:	00002097          	auipc	ra,0x2
    280c:	0a8080e7          	jalr	168(ra) # 48b0 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    2810:	85ca                	mv	a1,s2
    2812:	00003517          	auipc	a0,0x3
    2816:	7b650513          	addi	a0,a0,1974 # 5fc8 <malloc+0x12d2>
    281a:	00002097          	auipc	ra,0x2
    281e:	41e080e7          	jalr	1054(ra) # 4c38 <printf>
    exit(1);
    2822:	4505                	li	a0,1
    2824:	00002097          	auipc	ra,0x2
    2828:	08c080e7          	jalr	140(ra) # 48b0 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
    282c:	85ca                	mv	a1,s2
    282e:	00003517          	auipc	a0,0x3
    2832:	7c250513          	addi	a0,a0,1986 # 5ff0 <malloc+0x12fa>
    2836:	00002097          	auipc	ra,0x2
    283a:	402080e7          	jalr	1026(ra) # 4c38 <printf>
    exit(1);
    283e:	4505                	li	a0,1
    2840:	00002097          	auipc	ra,0x2
    2844:	070080e7          	jalr	112(ra) # 48b0 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    2848:	85ca                	mv	a1,s2
    284a:	00003517          	auipc	a0,0x3
    284e:	7ce50513          	addi	a0,a0,1998 # 6018 <malloc+0x1322>
    2852:	00002097          	auipc	ra,0x2
    2856:	3e6080e7          	jalr	998(ra) # 4c38 <printf>
    exit(1);
    285a:	4505                	li	a0,1
    285c:	00002097          	auipc	ra,0x2
    2860:	054080e7          	jalr	84(ra) # 48b0 <exit>

0000000000002864 <concreate>:
{
    2864:	7135                	addi	sp,sp,-160
    2866:	ed06                	sd	ra,152(sp)
    2868:	e922                	sd	s0,144(sp)
    286a:	e526                	sd	s1,136(sp)
    286c:	e14a                	sd	s2,128(sp)
    286e:	fcce                	sd	s3,120(sp)
    2870:	f8d2                	sd	s4,112(sp)
    2872:	f4d6                	sd	s5,104(sp)
    2874:	f0da                	sd	s6,96(sp)
    2876:	ecde                	sd	s7,88(sp)
    2878:	1100                	addi	s0,sp,160
    287a:	89aa                	mv	s3,a0
  file[0] = 'C';
    287c:	04300793          	li	a5,67
    2880:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    2884:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    2888:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    288a:	4b0d                	li	s6,3
    288c:	4a85                	li	s5,1
      link("C0", file);
    288e:	00003b97          	auipc	s7,0x3
    2892:	7aab8b93          	addi	s7,s7,1962 # 6038 <malloc+0x1342>
  for(i = 0; i < N; i++){
    2896:	02800a13          	li	s4,40
    289a:	a471                	j	2b26 <concreate+0x2c2>
      link("C0", file);
    289c:	fa840593          	addi	a1,s0,-88
    28a0:	855e                	mv	a0,s7
    28a2:	00002097          	auipc	ra,0x2
    28a6:	06e080e7          	jalr	110(ra) # 4910 <link>
    if(pid == 0) {
    28aa:	a48d                	j	2b0c <concreate+0x2a8>
    } else if(pid == 0 && (i % 5) == 1){
    28ac:	4795                	li	a5,5
    28ae:	02f9693b          	remw	s2,s2,a5
    28b2:	4785                	li	a5,1
    28b4:	02f90b63          	beq	s2,a5,28ea <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    28b8:	20200593          	li	a1,514
    28bc:	fa840513          	addi	a0,s0,-88
    28c0:	00002097          	auipc	ra,0x2
    28c4:	030080e7          	jalr	48(ra) # 48f0 <open>
      if(fd < 0){
    28c8:	22055963          	bgez	a0,2afa <concreate+0x296>
        printf("concreate create %s failed\n", file);
    28cc:	fa840593          	addi	a1,s0,-88
    28d0:	00003517          	auipc	a0,0x3
    28d4:	77050513          	addi	a0,a0,1904 # 6040 <malloc+0x134a>
    28d8:	00002097          	auipc	ra,0x2
    28dc:	360080e7          	jalr	864(ra) # 4c38 <printf>
        exit(1);
    28e0:	4505                	li	a0,1
    28e2:	00002097          	auipc	ra,0x2
    28e6:	fce080e7          	jalr	-50(ra) # 48b0 <exit>
      link("C0", file);
    28ea:	fa840593          	addi	a1,s0,-88
    28ee:	00003517          	auipc	a0,0x3
    28f2:	74a50513          	addi	a0,a0,1866 # 6038 <malloc+0x1342>
    28f6:	00002097          	auipc	ra,0x2
    28fa:	01a080e7          	jalr	26(ra) # 4910 <link>
      exit(0);
    28fe:	4501                	li	a0,0
    2900:	00002097          	auipc	ra,0x2
    2904:	fb0080e7          	jalr	-80(ra) # 48b0 <exit>
        exit(1);
    2908:	4505                	li	a0,1
    290a:	00002097          	auipc	ra,0x2
    290e:	fa6080e7          	jalr	-90(ra) # 48b0 <exit>
  memset(fa, 0, sizeof(fa));
    2912:	02800613          	li	a2,40
    2916:	4581                	li	a1,0
    2918:	f8040513          	addi	a0,s0,-128
    291c:	00002097          	auipc	ra,0x2
    2920:	d98080e7          	jalr	-616(ra) # 46b4 <memset>
  fd = open(".", 0);
    2924:	4581                	li	a1,0
    2926:	00003517          	auipc	a0,0x3
    292a:	0c250513          	addi	a0,a0,194 # 59e8 <malloc+0xcf2>
    292e:	00002097          	auipc	ra,0x2
    2932:	fc2080e7          	jalr	-62(ra) # 48f0 <open>
    2936:	892a                	mv	s2,a0
  n = 0;
    2938:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    293a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    293e:	02700b13          	li	s6,39
      fa[i] = 1;
    2942:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    2944:	4641                	li	a2,16
    2946:	f7040593          	addi	a1,s0,-144
    294a:	854a                	mv	a0,s2
    294c:	00002097          	auipc	ra,0x2
    2950:	f7c080e7          	jalr	-132(ra) # 48c8 <read>
    2954:	08a05163          	blez	a0,29d6 <concreate+0x172>
    if(de.inum == 0)
    2958:	f7045783          	lhu	a5,-144(s0)
    295c:	d7e5                	beqz	a5,2944 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    295e:	f7244783          	lbu	a5,-142(s0)
    2962:	ff4791e3          	bne	a5,s4,2944 <concreate+0xe0>
    2966:	f7444783          	lbu	a5,-140(s0)
    296a:	ffe9                	bnez	a5,2944 <concreate+0xe0>
      i = de.name[1] - '0';
    296c:	f7344783          	lbu	a5,-141(s0)
    2970:	fd07879b          	addiw	a5,a5,-48
    2974:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    2978:	00eb6f63          	bltu	s6,a4,2996 <concreate+0x132>
      if(fa[i]){
    297c:	fb040793          	addi	a5,s0,-80
    2980:	97ba                	add	a5,a5,a4
    2982:	fd07c783          	lbu	a5,-48(a5)
    2986:	eb85                	bnez	a5,29b6 <concreate+0x152>
      fa[i] = 1;
    2988:	fb040793          	addi	a5,s0,-80
    298c:	973e                	add	a4,a4,a5
    298e:	fd770823          	sb	s7,-48(a4)
      n++;
    2992:	2a85                	addiw	s5,s5,1
    2994:	bf45                	j	2944 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    2996:	f7240613          	addi	a2,s0,-142
    299a:	85ce                	mv	a1,s3
    299c:	00003517          	auipc	a0,0x3
    29a0:	6c450513          	addi	a0,a0,1732 # 6060 <malloc+0x136a>
    29a4:	00002097          	auipc	ra,0x2
    29a8:	294080e7          	jalr	660(ra) # 4c38 <printf>
        exit(1);
    29ac:	4505                	li	a0,1
    29ae:	00002097          	auipc	ra,0x2
    29b2:	f02080e7          	jalr	-254(ra) # 48b0 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    29b6:	f7240613          	addi	a2,s0,-142
    29ba:	85ce                	mv	a1,s3
    29bc:	00003517          	auipc	a0,0x3
    29c0:	6c450513          	addi	a0,a0,1732 # 6080 <malloc+0x138a>
    29c4:	00002097          	auipc	ra,0x2
    29c8:	274080e7          	jalr	628(ra) # 4c38 <printf>
        exit(1);
    29cc:	4505                	li	a0,1
    29ce:	00002097          	auipc	ra,0x2
    29d2:	ee2080e7          	jalr	-286(ra) # 48b0 <exit>
  close(fd);
    29d6:	854a                	mv	a0,s2
    29d8:	00002097          	auipc	ra,0x2
    29dc:	f00080e7          	jalr	-256(ra) # 48d8 <close>
  if(n != N){
    29e0:	02800793          	li	a5,40
    29e4:	00fa9763          	bne	s5,a5,29f2 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    29e8:	4a8d                	li	s5,3
    29ea:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    29ec:	02800a13          	li	s4,40
    29f0:	a05d                	j	2a96 <concreate+0x232>
    printf("%s: concreate not enough files in directory listing\n", s);
    29f2:	85ce                	mv	a1,s3
    29f4:	00003517          	auipc	a0,0x3
    29f8:	6b450513          	addi	a0,a0,1716 # 60a8 <malloc+0x13b2>
    29fc:	00002097          	auipc	ra,0x2
    2a00:	23c080e7          	jalr	572(ra) # 4c38 <printf>
    exit(1);
    2a04:	4505                	li	a0,1
    2a06:	00002097          	auipc	ra,0x2
    2a0a:	eaa080e7          	jalr	-342(ra) # 48b0 <exit>
      printf("%s: fork failed\n", s);
    2a0e:	85ce                	mv	a1,s3
    2a10:	00003517          	auipc	a0,0x3
    2a14:	ab850513          	addi	a0,a0,-1352 # 54c8 <malloc+0x7d2>
    2a18:	00002097          	auipc	ra,0x2
    2a1c:	220080e7          	jalr	544(ra) # 4c38 <printf>
      exit(1);
    2a20:	4505                	li	a0,1
    2a22:	00002097          	auipc	ra,0x2
    2a26:	e8e080e7          	jalr	-370(ra) # 48b0 <exit>
      close(open(file, 0));
    2a2a:	4581                	li	a1,0
    2a2c:	fa840513          	addi	a0,s0,-88
    2a30:	00002097          	auipc	ra,0x2
    2a34:	ec0080e7          	jalr	-320(ra) # 48f0 <open>
    2a38:	00002097          	auipc	ra,0x2
    2a3c:	ea0080e7          	jalr	-352(ra) # 48d8 <close>
      close(open(file, 0));
    2a40:	4581                	li	a1,0
    2a42:	fa840513          	addi	a0,s0,-88
    2a46:	00002097          	auipc	ra,0x2
    2a4a:	eaa080e7          	jalr	-342(ra) # 48f0 <open>
    2a4e:	00002097          	auipc	ra,0x2
    2a52:	e8a080e7          	jalr	-374(ra) # 48d8 <close>
      close(open(file, 0));
    2a56:	4581                	li	a1,0
    2a58:	fa840513          	addi	a0,s0,-88
    2a5c:	00002097          	auipc	ra,0x2
    2a60:	e94080e7          	jalr	-364(ra) # 48f0 <open>
    2a64:	00002097          	auipc	ra,0x2
    2a68:	e74080e7          	jalr	-396(ra) # 48d8 <close>
      close(open(file, 0));
    2a6c:	4581                	li	a1,0
    2a6e:	fa840513          	addi	a0,s0,-88
    2a72:	00002097          	auipc	ra,0x2
    2a76:	e7e080e7          	jalr	-386(ra) # 48f0 <open>
    2a7a:	00002097          	auipc	ra,0x2
    2a7e:	e5e080e7          	jalr	-418(ra) # 48d8 <close>
    if(pid == 0)
    2a82:	06090763          	beqz	s2,2af0 <concreate+0x28c>
      wait(0);
    2a86:	4501                	li	a0,0
    2a88:	00002097          	auipc	ra,0x2
    2a8c:	e30080e7          	jalr	-464(ra) # 48b8 <wait>
  for(i = 0; i < N; i++){
    2a90:	2485                	addiw	s1,s1,1
    2a92:	0d448963          	beq	s1,s4,2b64 <concreate+0x300>
    file[1] = '0' + i;
    2a96:	0304879b          	addiw	a5,s1,48
    2a9a:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    2a9e:	00002097          	auipc	ra,0x2
    2aa2:	e0a080e7          	jalr	-502(ra) # 48a8 <fork>
    2aa6:	892a                	mv	s2,a0
    if(pid < 0){
    2aa8:	f60543e3          	bltz	a0,2a0e <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    2aac:	0354e73b          	remw	a4,s1,s5
    2ab0:	00a767b3          	or	a5,a4,a0
    2ab4:	2781                	sext.w	a5,a5
    2ab6:	dbb5                	beqz	a5,2a2a <concreate+0x1c6>
    2ab8:	01671363          	bne	a4,s6,2abe <concreate+0x25a>
       ((i % 3) == 1 && pid != 0)){
    2abc:	f53d                	bnez	a0,2a2a <concreate+0x1c6>
      unlink(file);
    2abe:	fa840513          	addi	a0,s0,-88
    2ac2:	00002097          	auipc	ra,0x2
    2ac6:	e3e080e7          	jalr	-450(ra) # 4900 <unlink>
      unlink(file);
    2aca:	fa840513          	addi	a0,s0,-88
    2ace:	00002097          	auipc	ra,0x2
    2ad2:	e32080e7          	jalr	-462(ra) # 4900 <unlink>
      unlink(file);
    2ad6:	fa840513          	addi	a0,s0,-88
    2ada:	00002097          	auipc	ra,0x2
    2ade:	e26080e7          	jalr	-474(ra) # 4900 <unlink>
      unlink(file);
    2ae2:	fa840513          	addi	a0,s0,-88
    2ae6:	00002097          	auipc	ra,0x2
    2aea:	e1a080e7          	jalr	-486(ra) # 4900 <unlink>
    2aee:	bf51                	j	2a82 <concreate+0x21e>
      exit(0);
    2af0:	4501                	li	a0,0
    2af2:	00002097          	auipc	ra,0x2
    2af6:	dbe080e7          	jalr	-578(ra) # 48b0 <exit>
      close(fd);
    2afa:	00002097          	auipc	ra,0x2
    2afe:	dde080e7          	jalr	-546(ra) # 48d8 <close>
    if(pid == 0) {
    2b02:	bbf5                	j	28fe <concreate+0x9a>
      close(fd);
    2b04:	00002097          	auipc	ra,0x2
    2b08:	dd4080e7          	jalr	-556(ra) # 48d8 <close>
      wait(&xstatus);
    2b0c:	f6c40513          	addi	a0,s0,-148
    2b10:	00002097          	auipc	ra,0x2
    2b14:	da8080e7          	jalr	-600(ra) # 48b8 <wait>
      if(xstatus != 0)
    2b18:	f6c42483          	lw	s1,-148(s0)
    2b1c:	de0496e3          	bnez	s1,2908 <concreate+0xa4>
  for(i = 0; i < N; i++){
    2b20:	2905                	addiw	s2,s2,1
    2b22:	df4908e3          	beq	s2,s4,2912 <concreate+0xae>
    file[1] = '0' + i;
    2b26:	0309079b          	addiw	a5,s2,48
    2b2a:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    2b2e:	fa840513          	addi	a0,s0,-88
    2b32:	00002097          	auipc	ra,0x2
    2b36:	dce080e7          	jalr	-562(ra) # 4900 <unlink>
    pid = fork();
    2b3a:	00002097          	auipc	ra,0x2
    2b3e:	d6e080e7          	jalr	-658(ra) # 48a8 <fork>
    if(pid && (i % 3) == 1){
    2b42:	d60505e3          	beqz	a0,28ac <concreate+0x48>
    2b46:	036967bb          	remw	a5,s2,s6
    2b4a:	d55789e3          	beq	a5,s5,289c <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    2b4e:	20200593          	li	a1,514
    2b52:	fa840513          	addi	a0,s0,-88
    2b56:	00002097          	auipc	ra,0x2
    2b5a:	d9a080e7          	jalr	-614(ra) # 48f0 <open>
      if(fd < 0){
    2b5e:	fa0553e3          	bgez	a0,2b04 <concreate+0x2a0>
    2b62:	b3ad                	j	28cc <concreate+0x68>
}
    2b64:	60ea                	ld	ra,152(sp)
    2b66:	644a                	ld	s0,144(sp)
    2b68:	64aa                	ld	s1,136(sp)
    2b6a:	690a                	ld	s2,128(sp)
    2b6c:	79e6                	ld	s3,120(sp)
    2b6e:	7a46                	ld	s4,112(sp)
    2b70:	7aa6                	ld	s5,104(sp)
    2b72:	7b06                	ld	s6,96(sp)
    2b74:	6be6                	ld	s7,88(sp)
    2b76:	610d                	addi	sp,sp,160
    2b78:	8082                	ret

0000000000002b7a <linkunlink>:
{
    2b7a:	711d                	addi	sp,sp,-96
    2b7c:	ec86                	sd	ra,88(sp)
    2b7e:	e8a2                	sd	s0,80(sp)
    2b80:	e4a6                	sd	s1,72(sp)
    2b82:	e0ca                	sd	s2,64(sp)
    2b84:	fc4e                	sd	s3,56(sp)
    2b86:	f852                	sd	s4,48(sp)
    2b88:	f456                	sd	s5,40(sp)
    2b8a:	f05a                	sd	s6,32(sp)
    2b8c:	ec5e                	sd	s7,24(sp)
    2b8e:	e862                	sd	s8,16(sp)
    2b90:	e466                	sd	s9,8(sp)
    2b92:	1080                	addi	s0,sp,96
    2b94:	84aa                	mv	s1,a0
  unlink("x");
    2b96:	00002517          	auipc	a0,0x2
    2b9a:	5aa50513          	addi	a0,a0,1450 # 5140 <malloc+0x44a>
    2b9e:	00002097          	auipc	ra,0x2
    2ba2:	d62080e7          	jalr	-670(ra) # 4900 <unlink>
  pid = fork();
    2ba6:	00002097          	auipc	ra,0x2
    2baa:	d02080e7          	jalr	-766(ra) # 48a8 <fork>
  if(pid < 0){
    2bae:	02054b63          	bltz	a0,2be4 <linkunlink+0x6a>
    2bb2:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    2bb4:	4c85                	li	s9,1
    2bb6:	e119                	bnez	a0,2bbc <linkunlink+0x42>
    2bb8:	06100c93          	li	s9,97
    2bbc:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    2bc0:	41c659b7          	lui	s3,0x41c65
    2bc4:	e6d9899b          	addiw	s3,s3,-403
    2bc8:	690d                	lui	s2,0x3
    2bca:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    2bce:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    2bd0:	4b05                	li	s6,1
      unlink("x");
    2bd2:	00002a97          	auipc	s5,0x2
    2bd6:	56ea8a93          	addi	s5,s5,1390 # 5140 <malloc+0x44a>
      link("cat", "x");
    2bda:	00003b97          	auipc	s7,0x3
    2bde:	506b8b93          	addi	s7,s7,1286 # 60e0 <malloc+0x13ea>
    2be2:	a825                	j	2c1a <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    2be4:	85a6                	mv	a1,s1
    2be6:	00003517          	auipc	a0,0x3
    2bea:	8e250513          	addi	a0,a0,-1822 # 54c8 <malloc+0x7d2>
    2bee:	00002097          	auipc	ra,0x2
    2bf2:	04a080e7          	jalr	74(ra) # 4c38 <printf>
    exit(1);
    2bf6:	4505                	li	a0,1
    2bf8:	00002097          	auipc	ra,0x2
    2bfc:	cb8080e7          	jalr	-840(ra) # 48b0 <exit>
      close(open("x", O_RDWR | O_CREATE));
    2c00:	20200593          	li	a1,514
    2c04:	8556                	mv	a0,s5
    2c06:	00002097          	auipc	ra,0x2
    2c0a:	cea080e7          	jalr	-790(ra) # 48f0 <open>
    2c0e:	00002097          	auipc	ra,0x2
    2c12:	cca080e7          	jalr	-822(ra) # 48d8 <close>
  for(i = 0; i < 100; i++){
    2c16:	34fd                	addiw	s1,s1,-1
    2c18:	c88d                	beqz	s1,2c4a <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    2c1a:	033c87bb          	mulw	a5,s9,s3
    2c1e:	012787bb          	addw	a5,a5,s2
    2c22:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    2c26:	0347f7bb          	remuw	a5,a5,s4
    2c2a:	dbf9                	beqz	a5,2c00 <linkunlink+0x86>
    } else if((x % 3) == 1){
    2c2c:	01678863          	beq	a5,s6,2c3c <linkunlink+0xc2>
      unlink("x");
    2c30:	8556                	mv	a0,s5
    2c32:	00002097          	auipc	ra,0x2
    2c36:	cce080e7          	jalr	-818(ra) # 4900 <unlink>
    2c3a:	bff1                	j	2c16 <linkunlink+0x9c>
      link("cat", "x");
    2c3c:	85d6                	mv	a1,s5
    2c3e:	855e                	mv	a0,s7
    2c40:	00002097          	auipc	ra,0x2
    2c44:	cd0080e7          	jalr	-816(ra) # 4910 <link>
    2c48:	b7f9                	j	2c16 <linkunlink+0x9c>
  if(pid)
    2c4a:	020c0463          	beqz	s8,2c72 <linkunlink+0xf8>
    wait(0);
    2c4e:	4501                	li	a0,0
    2c50:	00002097          	auipc	ra,0x2
    2c54:	c68080e7          	jalr	-920(ra) # 48b8 <wait>
}
    2c58:	60e6                	ld	ra,88(sp)
    2c5a:	6446                	ld	s0,80(sp)
    2c5c:	64a6                	ld	s1,72(sp)
    2c5e:	6906                	ld	s2,64(sp)
    2c60:	79e2                	ld	s3,56(sp)
    2c62:	7a42                	ld	s4,48(sp)
    2c64:	7aa2                	ld	s5,40(sp)
    2c66:	7b02                	ld	s6,32(sp)
    2c68:	6be2                	ld	s7,24(sp)
    2c6a:	6c42                	ld	s8,16(sp)
    2c6c:	6ca2                	ld	s9,8(sp)
    2c6e:	6125                	addi	sp,sp,96
    2c70:	8082                	ret
    exit(0);
    2c72:	4501                	li	a0,0
    2c74:	00002097          	auipc	ra,0x2
    2c78:	c3c080e7          	jalr	-964(ra) # 48b0 <exit>

0000000000002c7c <bigdir>:
{
    2c7c:	715d                	addi	sp,sp,-80
    2c7e:	e486                	sd	ra,72(sp)
    2c80:	e0a2                	sd	s0,64(sp)
    2c82:	fc26                	sd	s1,56(sp)
    2c84:	f84a                	sd	s2,48(sp)
    2c86:	f44e                	sd	s3,40(sp)
    2c88:	f052                	sd	s4,32(sp)
    2c8a:	ec56                	sd	s5,24(sp)
    2c8c:	e85a                	sd	s6,16(sp)
    2c8e:	0880                	addi	s0,sp,80
    2c90:	89aa                	mv	s3,a0
  unlink("bd");
    2c92:	00003517          	auipc	a0,0x3
    2c96:	45650513          	addi	a0,a0,1110 # 60e8 <malloc+0x13f2>
    2c9a:	00002097          	auipc	ra,0x2
    2c9e:	c66080e7          	jalr	-922(ra) # 4900 <unlink>
  fd = open("bd", O_CREATE);
    2ca2:	20000593          	li	a1,512
    2ca6:	00003517          	auipc	a0,0x3
    2caa:	44250513          	addi	a0,a0,1090 # 60e8 <malloc+0x13f2>
    2cae:	00002097          	auipc	ra,0x2
    2cb2:	c42080e7          	jalr	-958(ra) # 48f0 <open>
  if(fd < 0){
    2cb6:	0c054963          	bltz	a0,2d88 <bigdir+0x10c>
  close(fd);
    2cba:	00002097          	auipc	ra,0x2
    2cbe:	c1e080e7          	jalr	-994(ra) # 48d8 <close>
  for(i = 0; i < N; i++){
    2cc2:	4901                	li	s2,0
    name[0] = 'x';
    2cc4:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    2cc8:	00003a17          	auipc	s4,0x3
    2ccc:	420a0a13          	addi	s4,s4,1056 # 60e8 <malloc+0x13f2>
  for(i = 0; i < N; i++){
    2cd0:	1f400b13          	li	s6,500
    name[0] = 'x';
    2cd4:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    2cd8:	41f9579b          	sraiw	a5,s2,0x1f
    2cdc:	01a7d71b          	srliw	a4,a5,0x1a
    2ce0:	012707bb          	addw	a5,a4,s2
    2ce4:	4067d69b          	sraiw	a3,a5,0x6
    2ce8:	0306869b          	addiw	a3,a3,48
    2cec:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2cf0:	03f7f793          	andi	a5,a5,63
    2cf4:	9f99                	subw	a5,a5,a4
    2cf6:	0307879b          	addiw	a5,a5,48
    2cfa:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2cfe:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    2d02:	fb040593          	addi	a1,s0,-80
    2d06:	8552                	mv	a0,s4
    2d08:	00002097          	auipc	ra,0x2
    2d0c:	c08080e7          	jalr	-1016(ra) # 4910 <link>
    2d10:	84aa                	mv	s1,a0
    2d12:	e949                	bnez	a0,2da4 <bigdir+0x128>
  for(i = 0; i < N; i++){
    2d14:	2905                	addiw	s2,s2,1
    2d16:	fb691fe3          	bne	s2,s6,2cd4 <bigdir+0x58>
  unlink("bd");
    2d1a:	00003517          	auipc	a0,0x3
    2d1e:	3ce50513          	addi	a0,a0,974 # 60e8 <malloc+0x13f2>
    2d22:	00002097          	auipc	ra,0x2
    2d26:	bde080e7          	jalr	-1058(ra) # 4900 <unlink>
    name[0] = 'x';
    2d2a:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    2d2e:	1f400a13          	li	s4,500
    name[0] = 'x';
    2d32:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    2d36:	41f4d79b          	sraiw	a5,s1,0x1f
    2d3a:	01a7d71b          	srliw	a4,a5,0x1a
    2d3e:	009707bb          	addw	a5,a4,s1
    2d42:	4067d69b          	sraiw	a3,a5,0x6
    2d46:	0306869b          	addiw	a3,a3,48
    2d4a:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    2d4e:	03f7f793          	andi	a5,a5,63
    2d52:	9f99                	subw	a5,a5,a4
    2d54:	0307879b          	addiw	a5,a5,48
    2d58:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    2d5c:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    2d60:	fb040513          	addi	a0,s0,-80
    2d64:	00002097          	auipc	ra,0x2
    2d68:	b9c080e7          	jalr	-1124(ra) # 4900 <unlink>
    2d6c:	e931                	bnez	a0,2dc0 <bigdir+0x144>
  for(i = 0; i < N; i++){
    2d6e:	2485                	addiw	s1,s1,1
    2d70:	fd4491e3          	bne	s1,s4,2d32 <bigdir+0xb6>
}
    2d74:	60a6                	ld	ra,72(sp)
    2d76:	6406                	ld	s0,64(sp)
    2d78:	74e2                	ld	s1,56(sp)
    2d7a:	7942                	ld	s2,48(sp)
    2d7c:	79a2                	ld	s3,40(sp)
    2d7e:	7a02                	ld	s4,32(sp)
    2d80:	6ae2                	ld	s5,24(sp)
    2d82:	6b42                	ld	s6,16(sp)
    2d84:	6161                	addi	sp,sp,80
    2d86:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    2d88:	85ce                	mv	a1,s3
    2d8a:	00003517          	auipc	a0,0x3
    2d8e:	36650513          	addi	a0,a0,870 # 60f0 <malloc+0x13fa>
    2d92:	00002097          	auipc	ra,0x2
    2d96:	ea6080e7          	jalr	-346(ra) # 4c38 <printf>
    exit(1);
    2d9a:	4505                	li	a0,1
    2d9c:	00002097          	auipc	ra,0x2
    2da0:	b14080e7          	jalr	-1260(ra) # 48b0 <exit>
      printf("%s: bigdir link failed\n", s);
    2da4:	85ce                	mv	a1,s3
    2da6:	00003517          	auipc	a0,0x3
    2daa:	36a50513          	addi	a0,a0,874 # 6110 <malloc+0x141a>
    2dae:	00002097          	auipc	ra,0x2
    2db2:	e8a080e7          	jalr	-374(ra) # 4c38 <printf>
      exit(1);
    2db6:	4505                	li	a0,1
    2db8:	00002097          	auipc	ra,0x2
    2dbc:	af8080e7          	jalr	-1288(ra) # 48b0 <exit>
      printf("%s: bigdir unlink failed", s);
    2dc0:	85ce                	mv	a1,s3
    2dc2:	00003517          	auipc	a0,0x3
    2dc6:	36650513          	addi	a0,a0,870 # 6128 <malloc+0x1432>
    2dca:	00002097          	auipc	ra,0x2
    2dce:	e6e080e7          	jalr	-402(ra) # 4c38 <printf>
      exit(1);
    2dd2:	4505                	li	a0,1
    2dd4:	00002097          	auipc	ra,0x2
    2dd8:	adc080e7          	jalr	-1316(ra) # 48b0 <exit>

0000000000002ddc <subdir>:
{
    2ddc:	1101                	addi	sp,sp,-32
    2dde:	ec06                	sd	ra,24(sp)
    2de0:	e822                	sd	s0,16(sp)
    2de2:	e426                	sd	s1,8(sp)
    2de4:	e04a                	sd	s2,0(sp)
    2de6:	1000                	addi	s0,sp,32
    2de8:	892a                	mv	s2,a0
  unlink("ff");
    2dea:	00003517          	auipc	a0,0x3
    2dee:	48e50513          	addi	a0,a0,1166 # 6278 <malloc+0x1582>
    2df2:	00002097          	auipc	ra,0x2
    2df6:	b0e080e7          	jalr	-1266(ra) # 4900 <unlink>
  if(mkdir("dd") != 0){
    2dfa:	00003517          	auipc	a0,0x3
    2dfe:	34e50513          	addi	a0,a0,846 # 6148 <malloc+0x1452>
    2e02:	00002097          	auipc	ra,0x2
    2e06:	b16080e7          	jalr	-1258(ra) # 4918 <mkdir>
    2e0a:	38051663          	bnez	a0,3196 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2e0e:	20200593          	li	a1,514
    2e12:	00003517          	auipc	a0,0x3
    2e16:	35650513          	addi	a0,a0,854 # 6168 <malloc+0x1472>
    2e1a:	00002097          	auipc	ra,0x2
    2e1e:	ad6080e7          	jalr	-1322(ra) # 48f0 <open>
    2e22:	84aa                	mv	s1,a0
  if(fd < 0){
    2e24:	38054763          	bltz	a0,31b2 <subdir+0x3d6>
  write(fd, "ff", 2);
    2e28:	4609                	li	a2,2
    2e2a:	00003597          	auipc	a1,0x3
    2e2e:	44e58593          	addi	a1,a1,1102 # 6278 <malloc+0x1582>
    2e32:	00002097          	auipc	ra,0x2
    2e36:	a9e080e7          	jalr	-1378(ra) # 48d0 <write>
  close(fd);
    2e3a:	8526                	mv	a0,s1
    2e3c:	00002097          	auipc	ra,0x2
    2e40:	a9c080e7          	jalr	-1380(ra) # 48d8 <close>
  if(unlink("dd") >= 0){
    2e44:	00003517          	auipc	a0,0x3
    2e48:	30450513          	addi	a0,a0,772 # 6148 <malloc+0x1452>
    2e4c:	00002097          	auipc	ra,0x2
    2e50:	ab4080e7          	jalr	-1356(ra) # 4900 <unlink>
    2e54:	36055d63          	bgez	a0,31ce <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2e58:	00003517          	auipc	a0,0x3
    2e5c:	36850513          	addi	a0,a0,872 # 61c0 <malloc+0x14ca>
    2e60:	00002097          	auipc	ra,0x2
    2e64:	ab8080e7          	jalr	-1352(ra) # 4918 <mkdir>
    2e68:	38051163          	bnez	a0,31ea <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2e6c:	20200593          	li	a1,514
    2e70:	00003517          	auipc	a0,0x3
    2e74:	37850513          	addi	a0,a0,888 # 61e8 <malloc+0x14f2>
    2e78:	00002097          	auipc	ra,0x2
    2e7c:	a78080e7          	jalr	-1416(ra) # 48f0 <open>
    2e80:	84aa                	mv	s1,a0
  if(fd < 0){
    2e82:	38054263          	bltz	a0,3206 <subdir+0x42a>
  write(fd, "FF", 2);
    2e86:	4609                	li	a2,2
    2e88:	00003597          	auipc	a1,0x3
    2e8c:	39058593          	addi	a1,a1,912 # 6218 <malloc+0x1522>
    2e90:	00002097          	auipc	ra,0x2
    2e94:	a40080e7          	jalr	-1472(ra) # 48d0 <write>
  close(fd);
    2e98:	8526                	mv	a0,s1
    2e9a:	00002097          	auipc	ra,0x2
    2e9e:	a3e080e7          	jalr	-1474(ra) # 48d8 <close>
  fd = open("dd/dd/../ff", 0);
    2ea2:	4581                	li	a1,0
    2ea4:	00003517          	auipc	a0,0x3
    2ea8:	37c50513          	addi	a0,a0,892 # 6220 <malloc+0x152a>
    2eac:	00002097          	auipc	ra,0x2
    2eb0:	a44080e7          	jalr	-1468(ra) # 48f0 <open>
    2eb4:	84aa                	mv	s1,a0
  if(fd < 0){
    2eb6:	36054663          	bltz	a0,3222 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2eba:	660d                	lui	a2,0x3
    2ebc:	00007597          	auipc	a1,0x7
    2ec0:	96458593          	addi	a1,a1,-1692 # 9820 <buf>
    2ec4:	00002097          	auipc	ra,0x2
    2ec8:	a04080e7          	jalr	-1532(ra) # 48c8 <read>
  if(cc != 2 || buf[0] != 'f'){
    2ecc:	4789                	li	a5,2
    2ece:	36f51863          	bne	a0,a5,323e <subdir+0x462>
    2ed2:	00007717          	auipc	a4,0x7
    2ed6:	94e74703          	lbu	a4,-1714(a4) # 9820 <buf>
    2eda:	06600793          	li	a5,102
    2ede:	36f71063          	bne	a4,a5,323e <subdir+0x462>
  close(fd);
    2ee2:	8526                	mv	a0,s1
    2ee4:	00002097          	auipc	ra,0x2
    2ee8:	9f4080e7          	jalr	-1548(ra) # 48d8 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2eec:	00003597          	auipc	a1,0x3
    2ef0:	38458593          	addi	a1,a1,900 # 6270 <malloc+0x157a>
    2ef4:	00003517          	auipc	a0,0x3
    2ef8:	2f450513          	addi	a0,a0,756 # 61e8 <malloc+0x14f2>
    2efc:	00002097          	auipc	ra,0x2
    2f00:	a14080e7          	jalr	-1516(ra) # 4910 <link>
    2f04:	34051b63          	bnez	a0,325a <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2f08:	00003517          	auipc	a0,0x3
    2f0c:	2e050513          	addi	a0,a0,736 # 61e8 <malloc+0x14f2>
    2f10:	00002097          	auipc	ra,0x2
    2f14:	9f0080e7          	jalr	-1552(ra) # 4900 <unlink>
    2f18:	34051f63          	bnez	a0,3276 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2f1c:	4581                	li	a1,0
    2f1e:	00003517          	auipc	a0,0x3
    2f22:	2ca50513          	addi	a0,a0,714 # 61e8 <malloc+0x14f2>
    2f26:	00002097          	auipc	ra,0x2
    2f2a:	9ca080e7          	jalr	-1590(ra) # 48f0 <open>
    2f2e:	36055263          	bgez	a0,3292 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2f32:	00003517          	auipc	a0,0x3
    2f36:	21650513          	addi	a0,a0,534 # 6148 <malloc+0x1452>
    2f3a:	00002097          	auipc	ra,0x2
    2f3e:	9e6080e7          	jalr	-1562(ra) # 4920 <chdir>
    2f42:	36051663          	bnez	a0,32ae <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2f46:	00003517          	auipc	a0,0x3
    2f4a:	3c250513          	addi	a0,a0,962 # 6308 <malloc+0x1612>
    2f4e:	00002097          	auipc	ra,0x2
    2f52:	9d2080e7          	jalr	-1582(ra) # 4920 <chdir>
    2f56:	36051a63          	bnez	a0,32ca <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2f5a:	00003517          	auipc	a0,0x3
    2f5e:	3de50513          	addi	a0,a0,990 # 6338 <malloc+0x1642>
    2f62:	00002097          	auipc	ra,0x2
    2f66:	9be080e7          	jalr	-1602(ra) # 4920 <chdir>
    2f6a:	36051e63          	bnez	a0,32e6 <subdir+0x50a>
  if(chdir("./..") != 0){
    2f6e:	00003517          	auipc	a0,0x3
    2f72:	3fa50513          	addi	a0,a0,1018 # 6368 <malloc+0x1672>
    2f76:	00002097          	auipc	ra,0x2
    2f7a:	9aa080e7          	jalr	-1622(ra) # 4920 <chdir>
    2f7e:	38051263          	bnez	a0,3302 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2f82:	4581                	li	a1,0
    2f84:	00003517          	auipc	a0,0x3
    2f88:	2ec50513          	addi	a0,a0,748 # 6270 <malloc+0x157a>
    2f8c:	00002097          	auipc	ra,0x2
    2f90:	964080e7          	jalr	-1692(ra) # 48f0 <open>
    2f94:	84aa                	mv	s1,a0
  if(fd < 0){
    2f96:	38054463          	bltz	a0,331e <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2f9a:	660d                	lui	a2,0x3
    2f9c:	00007597          	auipc	a1,0x7
    2fa0:	88458593          	addi	a1,a1,-1916 # 9820 <buf>
    2fa4:	00002097          	auipc	ra,0x2
    2fa8:	924080e7          	jalr	-1756(ra) # 48c8 <read>
    2fac:	4789                	li	a5,2
    2fae:	38f51663          	bne	a0,a5,333a <subdir+0x55e>
  close(fd);
    2fb2:	8526                	mv	a0,s1
    2fb4:	00002097          	auipc	ra,0x2
    2fb8:	924080e7          	jalr	-1756(ra) # 48d8 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2fbc:	4581                	li	a1,0
    2fbe:	00003517          	auipc	a0,0x3
    2fc2:	22a50513          	addi	a0,a0,554 # 61e8 <malloc+0x14f2>
    2fc6:	00002097          	auipc	ra,0x2
    2fca:	92a080e7          	jalr	-1750(ra) # 48f0 <open>
    2fce:	38055463          	bgez	a0,3356 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2fd2:	20200593          	li	a1,514
    2fd6:	00003517          	auipc	a0,0x3
    2fda:	42250513          	addi	a0,a0,1058 # 63f8 <malloc+0x1702>
    2fde:	00002097          	auipc	ra,0x2
    2fe2:	912080e7          	jalr	-1774(ra) # 48f0 <open>
    2fe6:	38055663          	bgez	a0,3372 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2fea:	20200593          	li	a1,514
    2fee:	00003517          	auipc	a0,0x3
    2ff2:	43a50513          	addi	a0,a0,1082 # 6428 <malloc+0x1732>
    2ff6:	00002097          	auipc	ra,0x2
    2ffa:	8fa080e7          	jalr	-1798(ra) # 48f0 <open>
    2ffe:	38055863          	bgez	a0,338e <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3002:	20000593          	li	a1,512
    3006:	00003517          	auipc	a0,0x3
    300a:	14250513          	addi	a0,a0,322 # 6148 <malloc+0x1452>
    300e:	00002097          	auipc	ra,0x2
    3012:	8e2080e7          	jalr	-1822(ra) # 48f0 <open>
    3016:	38055a63          	bgez	a0,33aa <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    301a:	4589                	li	a1,2
    301c:	00003517          	auipc	a0,0x3
    3020:	12c50513          	addi	a0,a0,300 # 6148 <malloc+0x1452>
    3024:	00002097          	auipc	ra,0x2
    3028:	8cc080e7          	jalr	-1844(ra) # 48f0 <open>
    302c:	38055d63          	bgez	a0,33c6 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    3030:	4585                	li	a1,1
    3032:	00003517          	auipc	a0,0x3
    3036:	11650513          	addi	a0,a0,278 # 6148 <malloc+0x1452>
    303a:	00002097          	auipc	ra,0x2
    303e:	8b6080e7          	jalr	-1866(ra) # 48f0 <open>
    3042:	3a055063          	bgez	a0,33e2 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    3046:	00003597          	auipc	a1,0x3
    304a:	47258593          	addi	a1,a1,1138 # 64b8 <malloc+0x17c2>
    304e:	00003517          	auipc	a0,0x3
    3052:	3aa50513          	addi	a0,a0,938 # 63f8 <malloc+0x1702>
    3056:	00002097          	auipc	ra,0x2
    305a:	8ba080e7          	jalr	-1862(ra) # 4910 <link>
    305e:	3a050063          	beqz	a0,33fe <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    3062:	00003597          	auipc	a1,0x3
    3066:	45658593          	addi	a1,a1,1110 # 64b8 <malloc+0x17c2>
    306a:	00003517          	auipc	a0,0x3
    306e:	3be50513          	addi	a0,a0,958 # 6428 <malloc+0x1732>
    3072:	00002097          	auipc	ra,0x2
    3076:	89e080e7          	jalr	-1890(ra) # 4910 <link>
    307a:	3a050063          	beqz	a0,341a <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    307e:	00003597          	auipc	a1,0x3
    3082:	1f258593          	addi	a1,a1,498 # 6270 <malloc+0x157a>
    3086:	00003517          	auipc	a0,0x3
    308a:	0e250513          	addi	a0,a0,226 # 6168 <malloc+0x1472>
    308e:	00002097          	auipc	ra,0x2
    3092:	882080e7          	jalr	-1918(ra) # 4910 <link>
    3096:	3a050063          	beqz	a0,3436 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    309a:	00003517          	auipc	a0,0x3
    309e:	35e50513          	addi	a0,a0,862 # 63f8 <malloc+0x1702>
    30a2:	00002097          	auipc	ra,0x2
    30a6:	876080e7          	jalr	-1930(ra) # 4918 <mkdir>
    30aa:	3a050463          	beqz	a0,3452 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    30ae:	00003517          	auipc	a0,0x3
    30b2:	37a50513          	addi	a0,a0,890 # 6428 <malloc+0x1732>
    30b6:	00002097          	auipc	ra,0x2
    30ba:	862080e7          	jalr	-1950(ra) # 4918 <mkdir>
    30be:	3a050863          	beqz	a0,346e <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    30c2:	00003517          	auipc	a0,0x3
    30c6:	1ae50513          	addi	a0,a0,430 # 6270 <malloc+0x157a>
    30ca:	00002097          	auipc	ra,0x2
    30ce:	84e080e7          	jalr	-1970(ra) # 4918 <mkdir>
    30d2:	3a050c63          	beqz	a0,348a <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    30d6:	00003517          	auipc	a0,0x3
    30da:	35250513          	addi	a0,a0,850 # 6428 <malloc+0x1732>
    30de:	00002097          	auipc	ra,0x2
    30e2:	822080e7          	jalr	-2014(ra) # 4900 <unlink>
    30e6:	3c050063          	beqz	a0,34a6 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    30ea:	00003517          	auipc	a0,0x3
    30ee:	30e50513          	addi	a0,a0,782 # 63f8 <malloc+0x1702>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	80e080e7          	jalr	-2034(ra) # 4900 <unlink>
    30fa:	3c050463          	beqz	a0,34c2 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    30fe:	00003517          	auipc	a0,0x3
    3102:	06a50513          	addi	a0,a0,106 # 6168 <malloc+0x1472>
    3106:	00002097          	auipc	ra,0x2
    310a:	81a080e7          	jalr	-2022(ra) # 4920 <chdir>
    310e:	3c050863          	beqz	a0,34de <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3112:	00003517          	auipc	a0,0x3
    3116:	4f650513          	addi	a0,a0,1270 # 6608 <malloc+0x1912>
    311a:	00002097          	auipc	ra,0x2
    311e:	806080e7          	jalr	-2042(ra) # 4920 <chdir>
    3122:	3c050c63          	beqz	a0,34fa <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3126:	00003517          	auipc	a0,0x3
    312a:	14a50513          	addi	a0,a0,330 # 6270 <malloc+0x157a>
    312e:	00001097          	auipc	ra,0x1
    3132:	7d2080e7          	jalr	2002(ra) # 4900 <unlink>
    3136:	3e051063          	bnez	a0,3516 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    313a:	00003517          	auipc	a0,0x3
    313e:	02e50513          	addi	a0,a0,46 # 6168 <malloc+0x1472>
    3142:	00001097          	auipc	ra,0x1
    3146:	7be080e7          	jalr	1982(ra) # 4900 <unlink>
    314a:	3e051463          	bnez	a0,3532 <subdir+0x756>
  if(unlink("dd") == 0){
    314e:	00003517          	auipc	a0,0x3
    3152:	ffa50513          	addi	a0,a0,-6 # 6148 <malloc+0x1452>
    3156:	00001097          	auipc	ra,0x1
    315a:	7aa080e7          	jalr	1962(ra) # 4900 <unlink>
    315e:	3e050863          	beqz	a0,354e <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3162:	00003517          	auipc	a0,0x3
    3166:	51650513          	addi	a0,a0,1302 # 6678 <malloc+0x1982>
    316a:	00001097          	auipc	ra,0x1
    316e:	796080e7          	jalr	1942(ra) # 4900 <unlink>
    3172:	3e054c63          	bltz	a0,356a <subdir+0x78e>
  if(unlink("dd") < 0){
    3176:	00003517          	auipc	a0,0x3
    317a:	fd250513          	addi	a0,a0,-46 # 6148 <malloc+0x1452>
    317e:	00001097          	auipc	ra,0x1
    3182:	782080e7          	jalr	1922(ra) # 4900 <unlink>
    3186:	40054063          	bltz	a0,3586 <subdir+0x7aa>
}
    318a:	60e2                	ld	ra,24(sp)
    318c:	6442                	ld	s0,16(sp)
    318e:	64a2                	ld	s1,8(sp)
    3190:	6902                	ld	s2,0(sp)
    3192:	6105                	addi	sp,sp,32
    3194:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3196:	85ca                	mv	a1,s2
    3198:	00003517          	auipc	a0,0x3
    319c:	fb850513          	addi	a0,a0,-72 # 6150 <malloc+0x145a>
    31a0:	00002097          	auipc	ra,0x2
    31a4:	a98080e7          	jalr	-1384(ra) # 4c38 <printf>
    exit(1);
    31a8:	4505                	li	a0,1
    31aa:	00001097          	auipc	ra,0x1
    31ae:	706080e7          	jalr	1798(ra) # 48b0 <exit>
    printf("%s: create dd/ff failed\n", s);
    31b2:	85ca                	mv	a1,s2
    31b4:	00003517          	auipc	a0,0x3
    31b8:	fbc50513          	addi	a0,a0,-68 # 6170 <malloc+0x147a>
    31bc:	00002097          	auipc	ra,0x2
    31c0:	a7c080e7          	jalr	-1412(ra) # 4c38 <printf>
    exit(1);
    31c4:	4505                	li	a0,1
    31c6:	00001097          	auipc	ra,0x1
    31ca:	6ea080e7          	jalr	1770(ra) # 48b0 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    31ce:	85ca                	mv	a1,s2
    31d0:	00003517          	auipc	a0,0x3
    31d4:	fc050513          	addi	a0,a0,-64 # 6190 <malloc+0x149a>
    31d8:	00002097          	auipc	ra,0x2
    31dc:	a60080e7          	jalr	-1440(ra) # 4c38 <printf>
    exit(1);
    31e0:	4505                	li	a0,1
    31e2:	00001097          	auipc	ra,0x1
    31e6:	6ce080e7          	jalr	1742(ra) # 48b0 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    31ea:	85ca                	mv	a1,s2
    31ec:	00003517          	auipc	a0,0x3
    31f0:	fdc50513          	addi	a0,a0,-36 # 61c8 <malloc+0x14d2>
    31f4:	00002097          	auipc	ra,0x2
    31f8:	a44080e7          	jalr	-1468(ra) # 4c38 <printf>
    exit(1);
    31fc:	4505                	li	a0,1
    31fe:	00001097          	auipc	ra,0x1
    3202:	6b2080e7          	jalr	1714(ra) # 48b0 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3206:	85ca                	mv	a1,s2
    3208:	00003517          	auipc	a0,0x3
    320c:	ff050513          	addi	a0,a0,-16 # 61f8 <malloc+0x1502>
    3210:	00002097          	auipc	ra,0x2
    3214:	a28080e7          	jalr	-1496(ra) # 4c38 <printf>
    exit(1);
    3218:	4505                	li	a0,1
    321a:	00001097          	auipc	ra,0x1
    321e:	696080e7          	jalr	1686(ra) # 48b0 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3222:	85ca                	mv	a1,s2
    3224:	00003517          	auipc	a0,0x3
    3228:	00c50513          	addi	a0,a0,12 # 6230 <malloc+0x153a>
    322c:	00002097          	auipc	ra,0x2
    3230:	a0c080e7          	jalr	-1524(ra) # 4c38 <printf>
    exit(1);
    3234:	4505                	li	a0,1
    3236:	00001097          	auipc	ra,0x1
    323a:	67a080e7          	jalr	1658(ra) # 48b0 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    323e:	85ca                	mv	a1,s2
    3240:	00003517          	auipc	a0,0x3
    3244:	01050513          	addi	a0,a0,16 # 6250 <malloc+0x155a>
    3248:	00002097          	auipc	ra,0x2
    324c:	9f0080e7          	jalr	-1552(ra) # 4c38 <printf>
    exit(1);
    3250:	4505                	li	a0,1
    3252:	00001097          	auipc	ra,0x1
    3256:	65e080e7          	jalr	1630(ra) # 48b0 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    325a:	85ca                	mv	a1,s2
    325c:	00003517          	auipc	a0,0x3
    3260:	02450513          	addi	a0,a0,36 # 6280 <malloc+0x158a>
    3264:	00002097          	auipc	ra,0x2
    3268:	9d4080e7          	jalr	-1580(ra) # 4c38 <printf>
    exit(1);
    326c:	4505                	li	a0,1
    326e:	00001097          	auipc	ra,0x1
    3272:	642080e7          	jalr	1602(ra) # 48b0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3276:	85ca                	mv	a1,s2
    3278:	00003517          	auipc	a0,0x3
    327c:	03050513          	addi	a0,a0,48 # 62a8 <malloc+0x15b2>
    3280:	00002097          	auipc	ra,0x2
    3284:	9b8080e7          	jalr	-1608(ra) # 4c38 <printf>
    exit(1);
    3288:	4505                	li	a0,1
    328a:	00001097          	auipc	ra,0x1
    328e:	626080e7          	jalr	1574(ra) # 48b0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3292:	85ca                	mv	a1,s2
    3294:	00003517          	auipc	a0,0x3
    3298:	03450513          	addi	a0,a0,52 # 62c8 <malloc+0x15d2>
    329c:	00002097          	auipc	ra,0x2
    32a0:	99c080e7          	jalr	-1636(ra) # 4c38 <printf>
    exit(1);
    32a4:	4505                	li	a0,1
    32a6:	00001097          	auipc	ra,0x1
    32aa:	60a080e7          	jalr	1546(ra) # 48b0 <exit>
    printf("%s: chdir dd failed\n", s);
    32ae:	85ca                	mv	a1,s2
    32b0:	00003517          	auipc	a0,0x3
    32b4:	04050513          	addi	a0,a0,64 # 62f0 <malloc+0x15fa>
    32b8:	00002097          	auipc	ra,0x2
    32bc:	980080e7          	jalr	-1664(ra) # 4c38 <printf>
    exit(1);
    32c0:	4505                	li	a0,1
    32c2:	00001097          	auipc	ra,0x1
    32c6:	5ee080e7          	jalr	1518(ra) # 48b0 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    32ca:	85ca                	mv	a1,s2
    32cc:	00003517          	auipc	a0,0x3
    32d0:	04c50513          	addi	a0,a0,76 # 6318 <malloc+0x1622>
    32d4:	00002097          	auipc	ra,0x2
    32d8:	964080e7          	jalr	-1692(ra) # 4c38 <printf>
    exit(1);
    32dc:	4505                	li	a0,1
    32de:	00001097          	auipc	ra,0x1
    32e2:	5d2080e7          	jalr	1490(ra) # 48b0 <exit>
    printf("chdir dd/../../dd failed\n", s);
    32e6:	85ca                	mv	a1,s2
    32e8:	00003517          	auipc	a0,0x3
    32ec:	06050513          	addi	a0,a0,96 # 6348 <malloc+0x1652>
    32f0:	00002097          	auipc	ra,0x2
    32f4:	948080e7          	jalr	-1720(ra) # 4c38 <printf>
    exit(1);
    32f8:	4505                	li	a0,1
    32fa:	00001097          	auipc	ra,0x1
    32fe:	5b6080e7          	jalr	1462(ra) # 48b0 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3302:	85ca                	mv	a1,s2
    3304:	00003517          	auipc	a0,0x3
    3308:	06c50513          	addi	a0,a0,108 # 6370 <malloc+0x167a>
    330c:	00002097          	auipc	ra,0x2
    3310:	92c080e7          	jalr	-1748(ra) # 4c38 <printf>
    exit(1);
    3314:	4505                	li	a0,1
    3316:	00001097          	auipc	ra,0x1
    331a:	59a080e7          	jalr	1434(ra) # 48b0 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    331e:	85ca                	mv	a1,s2
    3320:	00003517          	auipc	a0,0x3
    3324:	06850513          	addi	a0,a0,104 # 6388 <malloc+0x1692>
    3328:	00002097          	auipc	ra,0x2
    332c:	910080e7          	jalr	-1776(ra) # 4c38 <printf>
    exit(1);
    3330:	4505                	li	a0,1
    3332:	00001097          	auipc	ra,0x1
    3336:	57e080e7          	jalr	1406(ra) # 48b0 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    333a:	85ca                	mv	a1,s2
    333c:	00003517          	auipc	a0,0x3
    3340:	06c50513          	addi	a0,a0,108 # 63a8 <malloc+0x16b2>
    3344:	00002097          	auipc	ra,0x2
    3348:	8f4080e7          	jalr	-1804(ra) # 4c38 <printf>
    exit(1);
    334c:	4505                	li	a0,1
    334e:	00001097          	auipc	ra,0x1
    3352:	562080e7          	jalr	1378(ra) # 48b0 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3356:	85ca                	mv	a1,s2
    3358:	00003517          	auipc	a0,0x3
    335c:	07050513          	addi	a0,a0,112 # 63c8 <malloc+0x16d2>
    3360:	00002097          	auipc	ra,0x2
    3364:	8d8080e7          	jalr	-1832(ra) # 4c38 <printf>
    exit(1);
    3368:	4505                	li	a0,1
    336a:	00001097          	auipc	ra,0x1
    336e:	546080e7          	jalr	1350(ra) # 48b0 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3372:	85ca                	mv	a1,s2
    3374:	00003517          	auipc	a0,0x3
    3378:	09450513          	addi	a0,a0,148 # 6408 <malloc+0x1712>
    337c:	00002097          	auipc	ra,0x2
    3380:	8bc080e7          	jalr	-1860(ra) # 4c38 <printf>
    exit(1);
    3384:	4505                	li	a0,1
    3386:	00001097          	auipc	ra,0x1
    338a:	52a080e7          	jalr	1322(ra) # 48b0 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    338e:	85ca                	mv	a1,s2
    3390:	00003517          	auipc	a0,0x3
    3394:	0a850513          	addi	a0,a0,168 # 6438 <malloc+0x1742>
    3398:	00002097          	auipc	ra,0x2
    339c:	8a0080e7          	jalr	-1888(ra) # 4c38 <printf>
    exit(1);
    33a0:	4505                	li	a0,1
    33a2:	00001097          	auipc	ra,0x1
    33a6:	50e080e7          	jalr	1294(ra) # 48b0 <exit>
    printf("%s: create dd succeeded!\n", s);
    33aa:	85ca                	mv	a1,s2
    33ac:	00003517          	auipc	a0,0x3
    33b0:	0ac50513          	addi	a0,a0,172 # 6458 <malloc+0x1762>
    33b4:	00002097          	auipc	ra,0x2
    33b8:	884080e7          	jalr	-1916(ra) # 4c38 <printf>
    exit(1);
    33bc:	4505                	li	a0,1
    33be:	00001097          	auipc	ra,0x1
    33c2:	4f2080e7          	jalr	1266(ra) # 48b0 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    33c6:	85ca                	mv	a1,s2
    33c8:	00003517          	auipc	a0,0x3
    33cc:	0b050513          	addi	a0,a0,176 # 6478 <malloc+0x1782>
    33d0:	00002097          	auipc	ra,0x2
    33d4:	868080e7          	jalr	-1944(ra) # 4c38 <printf>
    exit(1);
    33d8:	4505                	li	a0,1
    33da:	00001097          	auipc	ra,0x1
    33de:	4d6080e7          	jalr	1238(ra) # 48b0 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    33e2:	85ca                	mv	a1,s2
    33e4:	00003517          	auipc	a0,0x3
    33e8:	0b450513          	addi	a0,a0,180 # 6498 <malloc+0x17a2>
    33ec:	00002097          	auipc	ra,0x2
    33f0:	84c080e7          	jalr	-1972(ra) # 4c38 <printf>
    exit(1);
    33f4:	4505                	li	a0,1
    33f6:	00001097          	auipc	ra,0x1
    33fa:	4ba080e7          	jalr	1210(ra) # 48b0 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    33fe:	85ca                	mv	a1,s2
    3400:	00003517          	auipc	a0,0x3
    3404:	0c850513          	addi	a0,a0,200 # 64c8 <malloc+0x17d2>
    3408:	00002097          	auipc	ra,0x2
    340c:	830080e7          	jalr	-2000(ra) # 4c38 <printf>
    exit(1);
    3410:	4505                	li	a0,1
    3412:	00001097          	auipc	ra,0x1
    3416:	49e080e7          	jalr	1182(ra) # 48b0 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    341a:	85ca                	mv	a1,s2
    341c:	00003517          	auipc	a0,0x3
    3420:	0d450513          	addi	a0,a0,212 # 64f0 <malloc+0x17fa>
    3424:	00002097          	auipc	ra,0x2
    3428:	814080e7          	jalr	-2028(ra) # 4c38 <printf>
    exit(1);
    342c:	4505                	li	a0,1
    342e:	00001097          	auipc	ra,0x1
    3432:	482080e7          	jalr	1154(ra) # 48b0 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3436:	85ca                	mv	a1,s2
    3438:	00003517          	auipc	a0,0x3
    343c:	0e050513          	addi	a0,a0,224 # 6518 <malloc+0x1822>
    3440:	00001097          	auipc	ra,0x1
    3444:	7f8080e7          	jalr	2040(ra) # 4c38 <printf>
    exit(1);
    3448:	4505                	li	a0,1
    344a:	00001097          	auipc	ra,0x1
    344e:	466080e7          	jalr	1126(ra) # 48b0 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3452:	85ca                	mv	a1,s2
    3454:	00003517          	auipc	a0,0x3
    3458:	0ec50513          	addi	a0,a0,236 # 6540 <malloc+0x184a>
    345c:	00001097          	auipc	ra,0x1
    3460:	7dc080e7          	jalr	2012(ra) # 4c38 <printf>
    exit(1);
    3464:	4505                	li	a0,1
    3466:	00001097          	auipc	ra,0x1
    346a:	44a080e7          	jalr	1098(ra) # 48b0 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    346e:	85ca                	mv	a1,s2
    3470:	00003517          	auipc	a0,0x3
    3474:	0f050513          	addi	a0,a0,240 # 6560 <malloc+0x186a>
    3478:	00001097          	auipc	ra,0x1
    347c:	7c0080e7          	jalr	1984(ra) # 4c38 <printf>
    exit(1);
    3480:	4505                	li	a0,1
    3482:	00001097          	auipc	ra,0x1
    3486:	42e080e7          	jalr	1070(ra) # 48b0 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    348a:	85ca                	mv	a1,s2
    348c:	00003517          	auipc	a0,0x3
    3490:	0f450513          	addi	a0,a0,244 # 6580 <malloc+0x188a>
    3494:	00001097          	auipc	ra,0x1
    3498:	7a4080e7          	jalr	1956(ra) # 4c38 <printf>
    exit(1);
    349c:	4505                	li	a0,1
    349e:	00001097          	auipc	ra,0x1
    34a2:	412080e7          	jalr	1042(ra) # 48b0 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    34a6:	85ca                	mv	a1,s2
    34a8:	00003517          	auipc	a0,0x3
    34ac:	10050513          	addi	a0,a0,256 # 65a8 <malloc+0x18b2>
    34b0:	00001097          	auipc	ra,0x1
    34b4:	788080e7          	jalr	1928(ra) # 4c38 <printf>
    exit(1);
    34b8:	4505                	li	a0,1
    34ba:	00001097          	auipc	ra,0x1
    34be:	3f6080e7          	jalr	1014(ra) # 48b0 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    34c2:	85ca                	mv	a1,s2
    34c4:	00003517          	auipc	a0,0x3
    34c8:	10450513          	addi	a0,a0,260 # 65c8 <malloc+0x18d2>
    34cc:	00001097          	auipc	ra,0x1
    34d0:	76c080e7          	jalr	1900(ra) # 4c38 <printf>
    exit(1);
    34d4:	4505                	li	a0,1
    34d6:	00001097          	auipc	ra,0x1
    34da:	3da080e7          	jalr	986(ra) # 48b0 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    34de:	85ca                	mv	a1,s2
    34e0:	00003517          	auipc	a0,0x3
    34e4:	10850513          	addi	a0,a0,264 # 65e8 <malloc+0x18f2>
    34e8:	00001097          	auipc	ra,0x1
    34ec:	750080e7          	jalr	1872(ra) # 4c38 <printf>
    exit(1);
    34f0:	4505                	li	a0,1
    34f2:	00001097          	auipc	ra,0x1
    34f6:	3be080e7          	jalr	958(ra) # 48b0 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    34fa:	85ca                	mv	a1,s2
    34fc:	00003517          	auipc	a0,0x3
    3500:	11450513          	addi	a0,a0,276 # 6610 <malloc+0x191a>
    3504:	00001097          	auipc	ra,0x1
    3508:	734080e7          	jalr	1844(ra) # 4c38 <printf>
    exit(1);
    350c:	4505                	li	a0,1
    350e:	00001097          	auipc	ra,0x1
    3512:	3a2080e7          	jalr	930(ra) # 48b0 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3516:	85ca                	mv	a1,s2
    3518:	00003517          	auipc	a0,0x3
    351c:	d9050513          	addi	a0,a0,-624 # 62a8 <malloc+0x15b2>
    3520:	00001097          	auipc	ra,0x1
    3524:	718080e7          	jalr	1816(ra) # 4c38 <printf>
    exit(1);
    3528:	4505                	li	a0,1
    352a:	00001097          	auipc	ra,0x1
    352e:	386080e7          	jalr	902(ra) # 48b0 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3532:	85ca                	mv	a1,s2
    3534:	00003517          	auipc	a0,0x3
    3538:	0fc50513          	addi	a0,a0,252 # 6630 <malloc+0x193a>
    353c:	00001097          	auipc	ra,0x1
    3540:	6fc080e7          	jalr	1788(ra) # 4c38 <printf>
    exit(1);
    3544:	4505                	li	a0,1
    3546:	00001097          	auipc	ra,0x1
    354a:	36a080e7          	jalr	874(ra) # 48b0 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    354e:	85ca                	mv	a1,s2
    3550:	00003517          	auipc	a0,0x3
    3554:	10050513          	addi	a0,a0,256 # 6650 <malloc+0x195a>
    3558:	00001097          	auipc	ra,0x1
    355c:	6e0080e7          	jalr	1760(ra) # 4c38 <printf>
    exit(1);
    3560:	4505                	li	a0,1
    3562:	00001097          	auipc	ra,0x1
    3566:	34e080e7          	jalr	846(ra) # 48b0 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    356a:	85ca                	mv	a1,s2
    356c:	00003517          	auipc	a0,0x3
    3570:	11450513          	addi	a0,a0,276 # 6680 <malloc+0x198a>
    3574:	00001097          	auipc	ra,0x1
    3578:	6c4080e7          	jalr	1732(ra) # 4c38 <printf>
    exit(1);
    357c:	4505                	li	a0,1
    357e:	00001097          	auipc	ra,0x1
    3582:	332080e7          	jalr	818(ra) # 48b0 <exit>
    printf("%s: unlink dd failed\n", s);
    3586:	85ca                	mv	a1,s2
    3588:	00003517          	auipc	a0,0x3
    358c:	11850513          	addi	a0,a0,280 # 66a0 <malloc+0x19aa>
    3590:	00001097          	auipc	ra,0x1
    3594:	6a8080e7          	jalr	1704(ra) # 4c38 <printf>
    exit(1);
    3598:	4505                	li	a0,1
    359a:	00001097          	auipc	ra,0x1
    359e:	316080e7          	jalr	790(ra) # 48b0 <exit>

00000000000035a2 <dirfile>:
{
    35a2:	1101                	addi	sp,sp,-32
    35a4:	ec06                	sd	ra,24(sp)
    35a6:	e822                	sd	s0,16(sp)
    35a8:	e426                	sd	s1,8(sp)
    35aa:	e04a                	sd	s2,0(sp)
    35ac:	1000                	addi	s0,sp,32
    35ae:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    35b0:	20000593          	li	a1,512
    35b4:	00002517          	auipc	a0,0x2
    35b8:	aa450513          	addi	a0,a0,-1372 # 5058 <malloc+0x362>
    35bc:	00001097          	auipc	ra,0x1
    35c0:	334080e7          	jalr	820(ra) # 48f0 <open>
  if(fd < 0){
    35c4:	0e054d63          	bltz	a0,36be <dirfile+0x11c>
  close(fd);
    35c8:	00001097          	auipc	ra,0x1
    35cc:	310080e7          	jalr	784(ra) # 48d8 <close>
  if(chdir("dirfile") == 0){
    35d0:	00002517          	auipc	a0,0x2
    35d4:	a8850513          	addi	a0,a0,-1400 # 5058 <malloc+0x362>
    35d8:	00001097          	auipc	ra,0x1
    35dc:	348080e7          	jalr	840(ra) # 4920 <chdir>
    35e0:	cd6d                	beqz	a0,36da <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    35e2:	4581                	li	a1,0
    35e4:	00003517          	auipc	a0,0x3
    35e8:	11450513          	addi	a0,a0,276 # 66f8 <malloc+0x1a02>
    35ec:	00001097          	auipc	ra,0x1
    35f0:	304080e7          	jalr	772(ra) # 48f0 <open>
  if(fd >= 0){
    35f4:	10055163          	bgez	a0,36f6 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    35f8:	20000593          	li	a1,512
    35fc:	00003517          	auipc	a0,0x3
    3600:	0fc50513          	addi	a0,a0,252 # 66f8 <malloc+0x1a02>
    3604:	00001097          	auipc	ra,0x1
    3608:	2ec080e7          	jalr	748(ra) # 48f0 <open>
  if(fd >= 0){
    360c:	10055363          	bgez	a0,3712 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3610:	00003517          	auipc	a0,0x3
    3614:	0e850513          	addi	a0,a0,232 # 66f8 <malloc+0x1a02>
    3618:	00001097          	auipc	ra,0x1
    361c:	300080e7          	jalr	768(ra) # 4918 <mkdir>
    3620:	10050763          	beqz	a0,372e <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3624:	00003517          	auipc	a0,0x3
    3628:	0d450513          	addi	a0,a0,212 # 66f8 <malloc+0x1a02>
    362c:	00001097          	auipc	ra,0x1
    3630:	2d4080e7          	jalr	724(ra) # 4900 <unlink>
    3634:	10050b63          	beqz	a0,374a <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3638:	00003597          	auipc	a1,0x3
    363c:	0c058593          	addi	a1,a1,192 # 66f8 <malloc+0x1a02>
    3640:	00003517          	auipc	a0,0x3
    3644:	14050513          	addi	a0,a0,320 # 6780 <malloc+0x1a8a>
    3648:	00001097          	auipc	ra,0x1
    364c:	2c8080e7          	jalr	712(ra) # 4910 <link>
    3650:	10050b63          	beqz	a0,3766 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3654:	00002517          	auipc	a0,0x2
    3658:	a0450513          	addi	a0,a0,-1532 # 5058 <malloc+0x362>
    365c:	00001097          	auipc	ra,0x1
    3660:	2a4080e7          	jalr	676(ra) # 4900 <unlink>
    3664:	10051f63          	bnez	a0,3782 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3668:	4589                	li	a1,2
    366a:	00002517          	auipc	a0,0x2
    366e:	37e50513          	addi	a0,a0,894 # 59e8 <malloc+0xcf2>
    3672:	00001097          	auipc	ra,0x1
    3676:	27e080e7          	jalr	638(ra) # 48f0 <open>
  if(fd >= 0){
    367a:	12055263          	bgez	a0,379e <dirfile+0x1fc>
  fd = open(".", 0);
    367e:	4581                	li	a1,0
    3680:	00002517          	auipc	a0,0x2
    3684:	36850513          	addi	a0,a0,872 # 59e8 <malloc+0xcf2>
    3688:	00001097          	auipc	ra,0x1
    368c:	268080e7          	jalr	616(ra) # 48f0 <open>
    3690:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3692:	4605                	li	a2,1
    3694:	00002597          	auipc	a1,0x2
    3698:	aac58593          	addi	a1,a1,-1364 # 5140 <malloc+0x44a>
    369c:	00001097          	auipc	ra,0x1
    36a0:	234080e7          	jalr	564(ra) # 48d0 <write>
    36a4:	10a04b63          	bgtz	a0,37ba <dirfile+0x218>
  close(fd);
    36a8:	8526                	mv	a0,s1
    36aa:	00001097          	auipc	ra,0x1
    36ae:	22e080e7          	jalr	558(ra) # 48d8 <close>
}
    36b2:	60e2                	ld	ra,24(sp)
    36b4:	6442                	ld	s0,16(sp)
    36b6:	64a2                	ld	s1,8(sp)
    36b8:	6902                	ld	s2,0(sp)
    36ba:	6105                	addi	sp,sp,32
    36bc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    36be:	85ca                	mv	a1,s2
    36c0:	00003517          	auipc	a0,0x3
    36c4:	ff850513          	addi	a0,a0,-8 # 66b8 <malloc+0x19c2>
    36c8:	00001097          	auipc	ra,0x1
    36cc:	570080e7          	jalr	1392(ra) # 4c38 <printf>
    exit(1);
    36d0:	4505                	li	a0,1
    36d2:	00001097          	auipc	ra,0x1
    36d6:	1de080e7          	jalr	478(ra) # 48b0 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    36da:	85ca                	mv	a1,s2
    36dc:	00003517          	auipc	a0,0x3
    36e0:	ffc50513          	addi	a0,a0,-4 # 66d8 <malloc+0x19e2>
    36e4:	00001097          	auipc	ra,0x1
    36e8:	554080e7          	jalr	1364(ra) # 4c38 <printf>
    exit(1);
    36ec:	4505                	li	a0,1
    36ee:	00001097          	auipc	ra,0x1
    36f2:	1c2080e7          	jalr	450(ra) # 48b0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    36f6:	85ca                	mv	a1,s2
    36f8:	00003517          	auipc	a0,0x3
    36fc:	01050513          	addi	a0,a0,16 # 6708 <malloc+0x1a12>
    3700:	00001097          	auipc	ra,0x1
    3704:	538080e7          	jalr	1336(ra) # 4c38 <printf>
    exit(1);
    3708:	4505                	li	a0,1
    370a:	00001097          	auipc	ra,0x1
    370e:	1a6080e7          	jalr	422(ra) # 48b0 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3712:	85ca                	mv	a1,s2
    3714:	00003517          	auipc	a0,0x3
    3718:	ff450513          	addi	a0,a0,-12 # 6708 <malloc+0x1a12>
    371c:	00001097          	auipc	ra,0x1
    3720:	51c080e7          	jalr	1308(ra) # 4c38 <printf>
    exit(1);
    3724:	4505                	li	a0,1
    3726:	00001097          	auipc	ra,0x1
    372a:	18a080e7          	jalr	394(ra) # 48b0 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    372e:	85ca                	mv	a1,s2
    3730:	00003517          	auipc	a0,0x3
    3734:	00050513          	mv	a0,a0
    3738:	00001097          	auipc	ra,0x1
    373c:	500080e7          	jalr	1280(ra) # 4c38 <printf>
    exit(1);
    3740:	4505                	li	a0,1
    3742:	00001097          	auipc	ra,0x1
    3746:	16e080e7          	jalr	366(ra) # 48b0 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    374a:	85ca                	mv	a1,s2
    374c:	00003517          	auipc	a0,0x3
    3750:	00c50513          	addi	a0,a0,12 # 6758 <malloc+0x1a62>
    3754:	00001097          	auipc	ra,0x1
    3758:	4e4080e7          	jalr	1252(ra) # 4c38 <printf>
    exit(1);
    375c:	4505                	li	a0,1
    375e:	00001097          	auipc	ra,0x1
    3762:	152080e7          	jalr	338(ra) # 48b0 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3766:	85ca                	mv	a1,s2
    3768:	00003517          	auipc	a0,0x3
    376c:	02050513          	addi	a0,a0,32 # 6788 <malloc+0x1a92>
    3770:	00001097          	auipc	ra,0x1
    3774:	4c8080e7          	jalr	1224(ra) # 4c38 <printf>
    exit(1);
    3778:	4505                	li	a0,1
    377a:	00001097          	auipc	ra,0x1
    377e:	136080e7          	jalr	310(ra) # 48b0 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3782:	85ca                	mv	a1,s2
    3784:	00003517          	auipc	a0,0x3
    3788:	02c50513          	addi	a0,a0,44 # 67b0 <malloc+0x1aba>
    378c:	00001097          	auipc	ra,0x1
    3790:	4ac080e7          	jalr	1196(ra) # 4c38 <printf>
    exit(1);
    3794:	4505                	li	a0,1
    3796:	00001097          	auipc	ra,0x1
    379a:	11a080e7          	jalr	282(ra) # 48b0 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    379e:	85ca                	mv	a1,s2
    37a0:	00003517          	auipc	a0,0x3
    37a4:	03050513          	addi	a0,a0,48 # 67d0 <malloc+0x1ada>
    37a8:	00001097          	auipc	ra,0x1
    37ac:	490080e7          	jalr	1168(ra) # 4c38 <printf>
    exit(1);
    37b0:	4505                	li	a0,1
    37b2:	00001097          	auipc	ra,0x1
    37b6:	0fe080e7          	jalr	254(ra) # 48b0 <exit>
    printf("%s: write . succeeded!\n", s);
    37ba:	85ca                	mv	a1,s2
    37bc:	00003517          	auipc	a0,0x3
    37c0:	03c50513          	addi	a0,a0,60 # 67f8 <malloc+0x1b02>
    37c4:	00001097          	auipc	ra,0x1
    37c8:	474080e7          	jalr	1140(ra) # 4c38 <printf>
    exit(1);
    37cc:	4505                	li	a0,1
    37ce:	00001097          	auipc	ra,0x1
    37d2:	0e2080e7          	jalr	226(ra) # 48b0 <exit>

00000000000037d6 <iref>:
{
    37d6:	7139                	addi	sp,sp,-64
    37d8:	fc06                	sd	ra,56(sp)
    37da:	f822                	sd	s0,48(sp)
    37dc:	f426                	sd	s1,40(sp)
    37de:	f04a                	sd	s2,32(sp)
    37e0:	ec4e                	sd	s3,24(sp)
    37e2:	e852                	sd	s4,16(sp)
    37e4:	e456                	sd	s5,8(sp)
    37e6:	e05a                	sd	s6,0(sp)
    37e8:	0080                	addi	s0,sp,64
    37ea:	8b2a                	mv	s6,a0
    37ec:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    37f0:	00003a17          	auipc	s4,0x3
    37f4:	020a0a13          	addi	s4,s4,32 # 6810 <malloc+0x1b1a>
    mkdir("");
    37f8:	00003497          	auipc	s1,0x3
    37fc:	bf848493          	addi	s1,s1,-1032 # 63f0 <malloc+0x16fa>
    link("README", "");
    3800:	00003a97          	auipc	s5,0x3
    3804:	f80a8a93          	addi	s5,s5,-128 # 6780 <malloc+0x1a8a>
    fd = open("xx", O_CREATE);
    3808:	00003997          	auipc	s3,0x3
    380c:	ef898993          	addi	s3,s3,-264 # 6700 <malloc+0x1a0a>
    3810:	a891                	j	3864 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3812:	85da                	mv	a1,s6
    3814:	00003517          	auipc	a0,0x3
    3818:	00450513          	addi	a0,a0,4 # 6818 <malloc+0x1b22>
    381c:	00001097          	auipc	ra,0x1
    3820:	41c080e7          	jalr	1052(ra) # 4c38 <printf>
      exit(1);
    3824:	4505                	li	a0,1
    3826:	00001097          	auipc	ra,0x1
    382a:	08a080e7          	jalr	138(ra) # 48b0 <exit>
      printf("%s: chdir irefd failed\n", s);
    382e:	85da                	mv	a1,s6
    3830:	00003517          	auipc	a0,0x3
    3834:	00050513          	mv	a0,a0
    3838:	00001097          	auipc	ra,0x1
    383c:	400080e7          	jalr	1024(ra) # 4c38 <printf>
      exit(1);
    3840:	4505                	li	a0,1
    3842:	00001097          	auipc	ra,0x1
    3846:	06e080e7          	jalr	110(ra) # 48b0 <exit>
      close(fd);
    384a:	00001097          	auipc	ra,0x1
    384e:	08e080e7          	jalr	142(ra) # 48d8 <close>
    3852:	a889                	j	38a4 <iref+0xce>
    unlink("xx");
    3854:	854e                	mv	a0,s3
    3856:	00001097          	auipc	ra,0x1
    385a:	0aa080e7          	jalr	170(ra) # 4900 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    385e:	397d                	addiw	s2,s2,-1
    3860:	06090063          	beqz	s2,38c0 <iref+0xea>
    if(mkdir("irefd") != 0){
    3864:	8552                	mv	a0,s4
    3866:	00001097          	auipc	ra,0x1
    386a:	0b2080e7          	jalr	178(ra) # 4918 <mkdir>
    386e:	f155                	bnez	a0,3812 <iref+0x3c>
    if(chdir("irefd") != 0){
    3870:	8552                	mv	a0,s4
    3872:	00001097          	auipc	ra,0x1
    3876:	0ae080e7          	jalr	174(ra) # 4920 <chdir>
    387a:	f955                	bnez	a0,382e <iref+0x58>
    mkdir("");
    387c:	8526                	mv	a0,s1
    387e:	00001097          	auipc	ra,0x1
    3882:	09a080e7          	jalr	154(ra) # 4918 <mkdir>
    link("README", "");
    3886:	85a6                	mv	a1,s1
    3888:	8556                	mv	a0,s5
    388a:	00001097          	auipc	ra,0x1
    388e:	086080e7          	jalr	134(ra) # 4910 <link>
    fd = open("", O_CREATE);
    3892:	20000593          	li	a1,512
    3896:	8526                	mv	a0,s1
    3898:	00001097          	auipc	ra,0x1
    389c:	058080e7          	jalr	88(ra) # 48f0 <open>
    if(fd >= 0)
    38a0:	fa0555e3          	bgez	a0,384a <iref+0x74>
    fd = open("xx", O_CREATE);
    38a4:	20000593          	li	a1,512
    38a8:	854e                	mv	a0,s3
    38aa:	00001097          	auipc	ra,0x1
    38ae:	046080e7          	jalr	70(ra) # 48f0 <open>
    if(fd >= 0)
    38b2:	fa0541e3          	bltz	a0,3854 <iref+0x7e>
      close(fd);
    38b6:	00001097          	auipc	ra,0x1
    38ba:	022080e7          	jalr	34(ra) # 48d8 <close>
    38be:	bf59                	j	3854 <iref+0x7e>
  chdir("/");
    38c0:	00002517          	auipc	a0,0x2
    38c4:	0b850513          	addi	a0,a0,184 # 5978 <malloc+0xc82>
    38c8:	00001097          	auipc	ra,0x1
    38cc:	058080e7          	jalr	88(ra) # 4920 <chdir>
}
    38d0:	70e2                	ld	ra,56(sp)
    38d2:	7442                	ld	s0,48(sp)
    38d4:	74a2                	ld	s1,40(sp)
    38d6:	7902                	ld	s2,32(sp)
    38d8:	69e2                	ld	s3,24(sp)
    38da:	6a42                	ld	s4,16(sp)
    38dc:	6aa2                	ld	s5,8(sp)
    38de:	6b02                	ld	s6,0(sp)
    38e0:	6121                	addi	sp,sp,64
    38e2:	8082                	ret

00000000000038e4 <validatetest>:
{
    38e4:	7139                	addi	sp,sp,-64
    38e6:	fc06                	sd	ra,56(sp)
    38e8:	f822                	sd	s0,48(sp)
    38ea:	f426                	sd	s1,40(sp)
    38ec:	f04a                	sd	s2,32(sp)
    38ee:	ec4e                	sd	s3,24(sp)
    38f0:	e852                	sd	s4,16(sp)
    38f2:	e456                	sd	s5,8(sp)
    38f4:	e05a                	sd	s6,0(sp)
    38f6:	0080                	addi	s0,sp,64
    38f8:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    38fa:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    38fc:	00003997          	auipc	s3,0x3
    3900:	f4c98993          	addi	s3,s3,-180 # 6848 <malloc+0x1b52>
    3904:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    3906:	6a85                	lui	s5,0x1
    3908:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    390c:	85a6                	mv	a1,s1
    390e:	854e                	mv	a0,s3
    3910:	00001097          	auipc	ra,0x1
    3914:	000080e7          	jalr	ra # 4910 <link>
    3918:	01251f63          	bne	a0,s2,3936 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    391c:	94d6                	add	s1,s1,s5
    391e:	ff4497e3          	bne	s1,s4,390c <validatetest+0x28>
}
    3922:	70e2                	ld	ra,56(sp)
    3924:	7442                	ld	s0,48(sp)
    3926:	74a2                	ld	s1,40(sp)
    3928:	7902                	ld	s2,32(sp)
    392a:	69e2                	ld	s3,24(sp)
    392c:	6a42                	ld	s4,16(sp)
    392e:	6aa2                	ld	s5,8(sp)
    3930:	6b02                	ld	s6,0(sp)
    3932:	6121                	addi	sp,sp,64
    3934:	8082                	ret
      printf("%s: link should not succeed\n", s);
    3936:	85da                	mv	a1,s6
    3938:	00003517          	auipc	a0,0x3
    393c:	f2050513          	addi	a0,a0,-224 # 6858 <malloc+0x1b62>
    3940:	00001097          	auipc	ra,0x1
    3944:	2f8080e7          	jalr	760(ra) # 4c38 <printf>
      exit(1);
    3948:	4505                	li	a0,1
    394a:	00001097          	auipc	ra,0x1
    394e:	f66080e7          	jalr	-154(ra) # 48b0 <exit>

0000000000003952 <sbrkmuch>:
{
    3952:	7179                	addi	sp,sp,-48
    3954:	f406                	sd	ra,40(sp)
    3956:	f022                	sd	s0,32(sp)
    3958:	ec26                	sd	s1,24(sp)
    395a:	e84a                	sd	s2,16(sp)
    395c:	e44e                	sd	s3,8(sp)
    395e:	e052                	sd	s4,0(sp)
    3960:	1800                	addi	s0,sp,48
    3962:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    3964:	4501                	li	a0,0
    3966:	00001097          	auipc	ra,0x1
    396a:	fd2080e7          	jalr	-46(ra) # 4938 <sbrk>
    396e:	892a                	mv	s2,a0
  a = sbrk(0);
    3970:	4501                	li	a0,0
    3972:	00001097          	auipc	ra,0x1
    3976:	fc6080e7          	jalr	-58(ra) # 4938 <sbrk>
    397a:	84aa                	mv	s1,a0
  p = sbrk(amt);
    397c:	06400537          	lui	a0,0x6400
    3980:	9d05                	subw	a0,a0,s1
    3982:	00001097          	auipc	ra,0x1
    3986:	fb6080e7          	jalr	-74(ra) # 4938 <sbrk>
  if (p != a) {
    398a:	0aa49963          	bne	s1,a0,3a3c <sbrkmuch+0xea>
  *lastaddr = 99;
    398e:	064007b7          	lui	a5,0x6400
    3992:	06300713          	li	a4,99
    3996:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f37cf>
  a = sbrk(0);
    399a:	4501                	li	a0,0
    399c:	00001097          	auipc	ra,0x1
    39a0:	f9c080e7          	jalr	-100(ra) # 4938 <sbrk>
    39a4:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    39a6:	757d                	lui	a0,0xfffff
    39a8:	00001097          	auipc	ra,0x1
    39ac:	f90080e7          	jalr	-112(ra) # 4938 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    39b0:	57fd                	li	a5,-1
    39b2:	0af50363          	beq	a0,a5,3a58 <sbrkmuch+0x106>
  c = sbrk(0);
    39b6:	4501                	li	a0,0
    39b8:	00001097          	auipc	ra,0x1
    39bc:	f80080e7          	jalr	-128(ra) # 4938 <sbrk>
  if(c != a - PGSIZE){
    39c0:	77fd                	lui	a5,0xfffff
    39c2:	97a6                	add	a5,a5,s1
    39c4:	0af51863          	bne	a0,a5,3a74 <sbrkmuch+0x122>
  a = sbrk(0);
    39c8:	4501                	li	a0,0
    39ca:	00001097          	auipc	ra,0x1
    39ce:	f6e080e7          	jalr	-146(ra) # 4938 <sbrk>
    39d2:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    39d4:	6505                	lui	a0,0x1
    39d6:	00001097          	auipc	ra,0x1
    39da:	f62080e7          	jalr	-158(ra) # 4938 <sbrk>
    39de:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    39e0:	0aa49963          	bne	s1,a0,3a92 <sbrkmuch+0x140>
    39e4:	4501                	li	a0,0
    39e6:	00001097          	auipc	ra,0x1
    39ea:	f52080e7          	jalr	-174(ra) # 4938 <sbrk>
    39ee:	6785                	lui	a5,0x1
    39f0:	97a6                	add	a5,a5,s1
    39f2:	0af51063          	bne	a0,a5,3a92 <sbrkmuch+0x140>
  if(*lastaddr == 99){
    39f6:	064007b7          	lui	a5,0x6400
    39fa:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f37cf>
    39fe:	06300793          	li	a5,99
    3a02:	0af70763          	beq	a4,a5,3ab0 <sbrkmuch+0x15e>
  a = sbrk(0);
    3a06:	4501                	li	a0,0
    3a08:	00001097          	auipc	ra,0x1
    3a0c:	f30080e7          	jalr	-208(ra) # 4938 <sbrk>
    3a10:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    3a12:	4501                	li	a0,0
    3a14:	00001097          	auipc	ra,0x1
    3a18:	f24080e7          	jalr	-220(ra) # 4938 <sbrk>
    3a1c:	40a9053b          	subw	a0,s2,a0
    3a20:	00001097          	auipc	ra,0x1
    3a24:	f18080e7          	jalr	-232(ra) # 4938 <sbrk>
  if(c != a){
    3a28:	0aa49263          	bne	s1,a0,3acc <sbrkmuch+0x17a>
}
    3a2c:	70a2                	ld	ra,40(sp)
    3a2e:	7402                	ld	s0,32(sp)
    3a30:	64e2                	ld	s1,24(sp)
    3a32:	6942                	ld	s2,16(sp)
    3a34:	69a2                	ld	s3,8(sp)
    3a36:	6a02                	ld	s4,0(sp)
    3a38:	6145                	addi	sp,sp,48
    3a3a:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    3a3c:	85ce                	mv	a1,s3
    3a3e:	00003517          	auipc	a0,0x3
    3a42:	e3a50513          	addi	a0,a0,-454 # 6878 <malloc+0x1b82>
    3a46:	00001097          	auipc	ra,0x1
    3a4a:	1f2080e7          	jalr	498(ra) # 4c38 <printf>
    exit(1);
    3a4e:	4505                	li	a0,1
    3a50:	00001097          	auipc	ra,0x1
    3a54:	e60080e7          	jalr	-416(ra) # 48b0 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    3a58:	85ce                	mv	a1,s3
    3a5a:	00003517          	auipc	a0,0x3
    3a5e:	e6650513          	addi	a0,a0,-410 # 68c0 <malloc+0x1bca>
    3a62:	00001097          	auipc	ra,0x1
    3a66:	1d6080e7          	jalr	470(ra) # 4c38 <printf>
    exit(1);
    3a6a:	4505                	li	a0,1
    3a6c:	00001097          	auipc	ra,0x1
    3a70:	e44080e7          	jalr	-444(ra) # 48b0 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    3a74:	862a                	mv	a2,a0
    3a76:	85a6                	mv	a1,s1
    3a78:	00003517          	auipc	a0,0x3
    3a7c:	e6850513          	addi	a0,a0,-408 # 68e0 <malloc+0x1bea>
    3a80:	00001097          	auipc	ra,0x1
    3a84:	1b8080e7          	jalr	440(ra) # 4c38 <printf>
    exit(1);
    3a88:	4505                	li	a0,1
    3a8a:	00001097          	auipc	ra,0x1
    3a8e:	e26080e7          	jalr	-474(ra) # 48b0 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    3a92:	8652                	mv	a2,s4
    3a94:	85a6                	mv	a1,s1
    3a96:	00003517          	auipc	a0,0x3
    3a9a:	e8a50513          	addi	a0,a0,-374 # 6920 <malloc+0x1c2a>
    3a9e:	00001097          	auipc	ra,0x1
    3aa2:	19a080e7          	jalr	410(ra) # 4c38 <printf>
    exit(1);
    3aa6:	4505                	li	a0,1
    3aa8:	00001097          	auipc	ra,0x1
    3aac:	e08080e7          	jalr	-504(ra) # 48b0 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    3ab0:	85ce                	mv	a1,s3
    3ab2:	00003517          	auipc	a0,0x3
    3ab6:	e9e50513          	addi	a0,a0,-354 # 6950 <malloc+0x1c5a>
    3aba:	00001097          	auipc	ra,0x1
    3abe:	17e080e7          	jalr	382(ra) # 4c38 <printf>
    exit(1);
    3ac2:	4505                	li	a0,1
    3ac4:	00001097          	auipc	ra,0x1
    3ac8:	dec080e7          	jalr	-532(ra) # 48b0 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    3acc:	862a                	mv	a2,a0
    3ace:	85a6                	mv	a1,s1
    3ad0:	00003517          	auipc	a0,0x3
    3ad4:	eb850513          	addi	a0,a0,-328 # 6988 <malloc+0x1c92>
    3ad8:	00001097          	auipc	ra,0x1
    3adc:	160080e7          	jalr	352(ra) # 4c38 <printf>
    exit(1);
    3ae0:	4505                	li	a0,1
    3ae2:	00001097          	auipc	ra,0x1
    3ae6:	dce080e7          	jalr	-562(ra) # 48b0 <exit>

0000000000003aea <sbrkfail>:
{
    3aea:	7119                	addi	sp,sp,-128
    3aec:	fc86                	sd	ra,120(sp)
    3aee:	f8a2                	sd	s0,112(sp)
    3af0:	f4a6                	sd	s1,104(sp)
    3af2:	f0ca                	sd	s2,96(sp)
    3af4:	ecce                	sd	s3,88(sp)
    3af6:	e8d2                	sd	s4,80(sp)
    3af8:	e4d6                	sd	s5,72(sp)
    3afa:	0100                	addi	s0,sp,128
    3afc:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3afe:	fb040513          	addi	a0,s0,-80
    3b02:	00001097          	auipc	ra,0x1
    3b06:	dbe080e7          	jalr	-578(ra) # 48c0 <pipe>
    3b0a:	e901                	bnez	a0,3b1a <sbrkfail+0x30>
    3b0c:	f8040493          	addi	s1,s0,-128
    3b10:	fa840993          	addi	s3,s0,-88
    3b14:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3b16:	5a7d                	li	s4,-1
    3b18:	a085                	j	3b78 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3b1a:	85d6                	mv	a1,s5
    3b1c:	00002517          	auipc	a0,0x2
    3b20:	16c50513          	addi	a0,a0,364 # 5c88 <malloc+0xf92>
    3b24:	00001097          	auipc	ra,0x1
    3b28:	114080e7          	jalr	276(ra) # 4c38 <printf>
    exit(1);
    3b2c:	4505                	li	a0,1
    3b2e:	00001097          	auipc	ra,0x1
    3b32:	d82080e7          	jalr	-638(ra) # 48b0 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3b36:	00001097          	auipc	ra,0x1
    3b3a:	e02080e7          	jalr	-510(ra) # 4938 <sbrk>
    3b3e:	064007b7          	lui	a5,0x6400
    3b42:	40a7853b          	subw	a0,a5,a0
    3b46:	00001097          	auipc	ra,0x1
    3b4a:	df2080e7          	jalr	-526(ra) # 4938 <sbrk>
      write(fds[1], "x", 1);
    3b4e:	4605                	li	a2,1
    3b50:	00001597          	auipc	a1,0x1
    3b54:	5f058593          	addi	a1,a1,1520 # 5140 <malloc+0x44a>
    3b58:	fb442503          	lw	a0,-76(s0)
    3b5c:	00001097          	auipc	ra,0x1
    3b60:	d74080e7          	jalr	-652(ra) # 48d0 <write>
      for(;;) sleep(1000);
    3b64:	3e800513          	li	a0,1000
    3b68:	00001097          	auipc	ra,0x1
    3b6c:	dd8080e7          	jalr	-552(ra) # 4940 <sleep>
    3b70:	bfd5                	j	3b64 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3b72:	0911                	addi	s2,s2,4
    3b74:	03390563          	beq	s2,s3,3b9e <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3b78:	00001097          	auipc	ra,0x1
    3b7c:	d30080e7          	jalr	-720(ra) # 48a8 <fork>
    3b80:	00a92023          	sw	a0,0(s2) # 3000 <subdir+0x224>
    3b84:	d94d                	beqz	a0,3b36 <sbrkfail+0x4c>
    if(pids[i] != -1)
    3b86:	ff4506e3          	beq	a0,s4,3b72 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    3b8a:	4605                	li	a2,1
    3b8c:	faf40593          	addi	a1,s0,-81
    3b90:	fb042503          	lw	a0,-80(s0)
    3b94:	00001097          	auipc	ra,0x1
    3b98:	d34080e7          	jalr	-716(ra) # 48c8 <read>
    3b9c:	bfd9                	j	3b72 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    3b9e:	6505                	lui	a0,0x1
    3ba0:	00001097          	auipc	ra,0x1
    3ba4:	d98080e7          	jalr	-616(ra) # 4938 <sbrk>
    3ba8:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    3baa:	597d                	li	s2,-1
    3bac:	a021                	j	3bb4 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3bae:	0491                	addi	s1,s1,4
    3bb0:	01348f63          	beq	s1,s3,3bce <sbrkfail+0xe4>
    if(pids[i] == -1)
    3bb4:	4088                	lw	a0,0(s1)
    3bb6:	ff250ce3          	beq	a0,s2,3bae <sbrkfail+0xc4>
    kill(pids[i]);
    3bba:	00001097          	auipc	ra,0x1
    3bbe:	d26080e7          	jalr	-730(ra) # 48e0 <kill>
    wait(0);
    3bc2:	4501                	li	a0,0
    3bc4:	00001097          	auipc	ra,0x1
    3bc8:	cf4080e7          	jalr	-780(ra) # 48b8 <wait>
    3bcc:	b7cd                	j	3bae <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    3bce:	57fd                	li	a5,-1
    3bd0:	02fa0e63          	beq	s4,a5,3c0c <sbrkfail+0x122>
  pid = fork();
    3bd4:	00001097          	auipc	ra,0x1
    3bd8:	cd4080e7          	jalr	-812(ra) # 48a8 <fork>
    3bdc:	84aa                	mv	s1,a0
  if(pid < 0){
    3bde:	04054563          	bltz	a0,3c28 <sbrkfail+0x13e>
  if(pid == 0){
    3be2:	c12d                	beqz	a0,3c44 <sbrkfail+0x15a>
  wait(&xstatus);
    3be4:	fbc40513          	addi	a0,s0,-68
    3be8:	00001097          	auipc	ra,0x1
    3bec:	cd0080e7          	jalr	-816(ra) # 48b8 <wait>
  if(xstatus != -1)
    3bf0:	fbc42703          	lw	a4,-68(s0)
    3bf4:	57fd                	li	a5,-1
    3bf6:	08f71c63          	bne	a4,a5,3c8e <sbrkfail+0x1a4>
}
    3bfa:	70e6                	ld	ra,120(sp)
    3bfc:	7446                	ld	s0,112(sp)
    3bfe:	74a6                	ld	s1,104(sp)
    3c00:	7906                	ld	s2,96(sp)
    3c02:	69e6                	ld	s3,88(sp)
    3c04:	6a46                	ld	s4,80(sp)
    3c06:	6aa6                	ld	s5,72(sp)
    3c08:	6109                	addi	sp,sp,128
    3c0a:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3c0c:	85d6                	mv	a1,s5
    3c0e:	00003517          	auipc	a0,0x3
    3c12:	da250513          	addi	a0,a0,-606 # 69b0 <malloc+0x1cba>
    3c16:	00001097          	auipc	ra,0x1
    3c1a:	022080e7          	jalr	34(ra) # 4c38 <printf>
    exit(1);
    3c1e:	4505                	li	a0,1
    3c20:	00001097          	auipc	ra,0x1
    3c24:	c90080e7          	jalr	-880(ra) # 48b0 <exit>
    printf("%s: fork failed\n", s);
    3c28:	85d6                	mv	a1,s5
    3c2a:	00002517          	auipc	a0,0x2
    3c2e:	89e50513          	addi	a0,a0,-1890 # 54c8 <malloc+0x7d2>
    3c32:	00001097          	auipc	ra,0x1
    3c36:	006080e7          	jalr	6(ra) # 4c38 <printf>
    exit(1);
    3c3a:	4505                	li	a0,1
    3c3c:	00001097          	auipc	ra,0x1
    3c40:	c74080e7          	jalr	-908(ra) # 48b0 <exit>
    a = sbrk(0);
    3c44:	4501                	li	a0,0
    3c46:	00001097          	auipc	ra,0x1
    3c4a:	cf2080e7          	jalr	-782(ra) # 4938 <sbrk>
    3c4e:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3c50:	3e800537          	lui	a0,0x3e800
    3c54:	00001097          	auipc	ra,0x1
    3c58:	ce4080e7          	jalr	-796(ra) # 4938 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c5c:	87ca                	mv	a5,s2
    3c5e:	3e800737          	lui	a4,0x3e800
    3c62:	993a                	add	s2,s2,a4
    3c64:	6705                	lui	a4,0x1
      n += *(a+i);
    3c66:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f37d0>
    3c6a:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3c6c:	97ba                	add	a5,a5,a4
    3c6e:	ff279ce3          	bne	a5,s2,3c66 <sbrkfail+0x17c>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3c72:	85a6                	mv	a1,s1
    3c74:	00003517          	auipc	a0,0x3
    3c78:	d5c50513          	addi	a0,a0,-676 # 69d0 <malloc+0x1cda>
    3c7c:	00001097          	auipc	ra,0x1
    3c80:	fbc080e7          	jalr	-68(ra) # 4c38 <printf>
    exit(1);
    3c84:	4505                	li	a0,1
    3c86:	00001097          	auipc	ra,0x1
    3c8a:	c2a080e7          	jalr	-982(ra) # 48b0 <exit>
    exit(1);
    3c8e:	4505                	li	a0,1
    3c90:	00001097          	auipc	ra,0x1
    3c94:	c20080e7          	jalr	-992(ra) # 48b0 <exit>

0000000000003c98 <sbrkarg>:
{
    3c98:	7179                	addi	sp,sp,-48
    3c9a:	f406                	sd	ra,40(sp)
    3c9c:	f022                	sd	s0,32(sp)
    3c9e:	ec26                	sd	s1,24(sp)
    3ca0:	e84a                	sd	s2,16(sp)
    3ca2:	e44e                	sd	s3,8(sp)
    3ca4:	1800                	addi	s0,sp,48
    3ca6:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    3ca8:	6505                	lui	a0,0x1
    3caa:	00001097          	auipc	ra,0x1
    3cae:	c8e080e7          	jalr	-882(ra) # 4938 <sbrk>
    3cb2:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    3cb4:	20100593          	li	a1,513
    3cb8:	00003517          	auipc	a0,0x3
    3cbc:	d4850513          	addi	a0,a0,-696 # 6a00 <malloc+0x1d0a>
    3cc0:	00001097          	auipc	ra,0x1
    3cc4:	c30080e7          	jalr	-976(ra) # 48f0 <open>
    3cc8:	84aa                	mv	s1,a0
  unlink("sbrk");
    3cca:	00003517          	auipc	a0,0x3
    3cce:	d3650513          	addi	a0,a0,-714 # 6a00 <malloc+0x1d0a>
    3cd2:	00001097          	auipc	ra,0x1
    3cd6:	c2e080e7          	jalr	-978(ra) # 4900 <unlink>
  if(fd < 0)  {
    3cda:	0404c163          	bltz	s1,3d1c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    3cde:	6605                	lui	a2,0x1
    3ce0:	85ca                	mv	a1,s2
    3ce2:	8526                	mv	a0,s1
    3ce4:	00001097          	auipc	ra,0x1
    3ce8:	bec080e7          	jalr	-1044(ra) # 48d0 <write>
    3cec:	04054663          	bltz	a0,3d38 <sbrkarg+0xa0>
  close(fd);
    3cf0:	8526                	mv	a0,s1
    3cf2:	00001097          	auipc	ra,0x1
    3cf6:	be6080e7          	jalr	-1050(ra) # 48d8 <close>
  a = sbrk(PGSIZE);
    3cfa:	6505                	lui	a0,0x1
    3cfc:	00001097          	auipc	ra,0x1
    3d00:	c3c080e7          	jalr	-964(ra) # 4938 <sbrk>
  if(pipe((int *) a) != 0){
    3d04:	00001097          	auipc	ra,0x1
    3d08:	bbc080e7          	jalr	-1092(ra) # 48c0 <pipe>
    3d0c:	e521                	bnez	a0,3d54 <sbrkarg+0xbc>
}
    3d0e:	70a2                	ld	ra,40(sp)
    3d10:	7402                	ld	s0,32(sp)
    3d12:	64e2                	ld	s1,24(sp)
    3d14:	6942                	ld	s2,16(sp)
    3d16:	69a2                	ld	s3,8(sp)
    3d18:	6145                	addi	sp,sp,48
    3d1a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    3d1c:	85ce                	mv	a1,s3
    3d1e:	00003517          	auipc	a0,0x3
    3d22:	cea50513          	addi	a0,a0,-790 # 6a08 <malloc+0x1d12>
    3d26:	00001097          	auipc	ra,0x1
    3d2a:	f12080e7          	jalr	-238(ra) # 4c38 <printf>
    exit(1);
    3d2e:	4505                	li	a0,1
    3d30:	00001097          	auipc	ra,0x1
    3d34:	b80080e7          	jalr	-1152(ra) # 48b0 <exit>
    printf("%s: write sbrk failed\n", s);
    3d38:	85ce                	mv	a1,s3
    3d3a:	00003517          	auipc	a0,0x3
    3d3e:	ce650513          	addi	a0,a0,-794 # 6a20 <malloc+0x1d2a>
    3d42:	00001097          	auipc	ra,0x1
    3d46:	ef6080e7          	jalr	-266(ra) # 4c38 <printf>
    exit(1);
    3d4a:	4505                	li	a0,1
    3d4c:	00001097          	auipc	ra,0x1
    3d50:	b64080e7          	jalr	-1180(ra) # 48b0 <exit>
    printf("%s: pipe() failed\n", s);
    3d54:	85ce                	mv	a1,s3
    3d56:	00002517          	auipc	a0,0x2
    3d5a:	f3250513          	addi	a0,a0,-206 # 5c88 <malloc+0xf92>
    3d5e:	00001097          	auipc	ra,0x1
    3d62:	eda080e7          	jalr	-294(ra) # 4c38 <printf>
    exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00001097          	auipc	ra,0x1
    3d6c:	b48080e7          	jalr	-1208(ra) # 48b0 <exit>

0000000000003d70 <argptest>:
{
    3d70:	1101                	addi	sp,sp,-32
    3d72:	ec06                	sd	ra,24(sp)
    3d74:	e822                	sd	s0,16(sp)
    3d76:	e426                	sd	s1,8(sp)
    3d78:	e04a                	sd	s2,0(sp)
    3d7a:	1000                	addi	s0,sp,32
    3d7c:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    3d7e:	4581                	li	a1,0
    3d80:	00003517          	auipc	a0,0x3
    3d84:	cb850513          	addi	a0,a0,-840 # 6a38 <malloc+0x1d42>
    3d88:	00001097          	auipc	ra,0x1
    3d8c:	b68080e7          	jalr	-1176(ra) # 48f0 <open>
  if (fd < 0) {
    3d90:	02054b63          	bltz	a0,3dc6 <argptest+0x56>
    3d94:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    3d96:	4501                	li	a0,0
    3d98:	00001097          	auipc	ra,0x1
    3d9c:	ba0080e7          	jalr	-1120(ra) # 4938 <sbrk>
    3da0:	567d                	li	a2,-1
    3da2:	fff50593          	addi	a1,a0,-1
    3da6:	8526                	mv	a0,s1
    3da8:	00001097          	auipc	ra,0x1
    3dac:	b20080e7          	jalr	-1248(ra) # 48c8 <read>
  close(fd);
    3db0:	8526                	mv	a0,s1
    3db2:	00001097          	auipc	ra,0x1
    3db6:	b26080e7          	jalr	-1242(ra) # 48d8 <close>
}
    3dba:	60e2                	ld	ra,24(sp)
    3dbc:	6442                	ld	s0,16(sp)
    3dbe:	64a2                	ld	s1,8(sp)
    3dc0:	6902                	ld	s2,0(sp)
    3dc2:	6105                	addi	sp,sp,32
    3dc4:	8082                	ret
    printf("%s: open failed\n", s);
    3dc6:	85ca                	mv	a1,s2
    3dc8:	00001517          	auipc	a0,0x1
    3dcc:	71850513          	addi	a0,a0,1816 # 54e0 <malloc+0x7ea>
    3dd0:	00001097          	auipc	ra,0x1
    3dd4:	e68080e7          	jalr	-408(ra) # 4c38 <printf>
    exit(1);
    3dd8:	4505                	li	a0,1
    3dda:	00001097          	auipc	ra,0x1
    3dde:	ad6080e7          	jalr	-1322(ra) # 48b0 <exit>

0000000000003de2 <sbrkbugs>:
{
    3de2:	1141                	addi	sp,sp,-16
    3de4:	e406                	sd	ra,8(sp)
    3de6:	e022                	sd	s0,0(sp)
    3de8:	0800                	addi	s0,sp,16
  int pid = fork();
    3dea:	00001097          	auipc	ra,0x1
    3dee:	abe080e7          	jalr	-1346(ra) # 48a8 <fork>
  if(pid < 0){
    3df2:	02054263          	bltz	a0,3e16 <sbrkbugs+0x34>
  if(pid == 0){
    3df6:	ed0d                	bnez	a0,3e30 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    3df8:	00001097          	auipc	ra,0x1
    3dfc:	b40080e7          	jalr	-1216(ra) # 4938 <sbrk>
    sbrk(-sz);
    3e00:	40a0053b          	negw	a0,a0
    3e04:	00001097          	auipc	ra,0x1
    3e08:	b34080e7          	jalr	-1228(ra) # 4938 <sbrk>
    exit(0);
    3e0c:	4501                	li	a0,0
    3e0e:	00001097          	auipc	ra,0x1
    3e12:	aa2080e7          	jalr	-1374(ra) # 48b0 <exit>
    printf("fork failed\n");
    3e16:	00002517          	auipc	a0,0x2
    3e1a:	e4250513          	addi	a0,a0,-446 # 5c58 <malloc+0xf62>
    3e1e:	00001097          	auipc	ra,0x1
    3e22:	e1a080e7          	jalr	-486(ra) # 4c38 <printf>
    exit(1);
    3e26:	4505                	li	a0,1
    3e28:	00001097          	auipc	ra,0x1
    3e2c:	a88080e7          	jalr	-1400(ra) # 48b0 <exit>
  wait(0);
    3e30:	4501                	li	a0,0
    3e32:	00001097          	auipc	ra,0x1
    3e36:	a86080e7          	jalr	-1402(ra) # 48b8 <wait>
  pid = fork();
    3e3a:	00001097          	auipc	ra,0x1
    3e3e:	a6e080e7          	jalr	-1426(ra) # 48a8 <fork>
  if(pid < 0){
    3e42:	02054563          	bltz	a0,3e6c <sbrkbugs+0x8a>
  if(pid == 0){
    3e46:	e121                	bnez	a0,3e86 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    3e48:	00001097          	auipc	ra,0x1
    3e4c:	af0080e7          	jalr	-1296(ra) # 4938 <sbrk>
    sbrk(-(sz - 3500));
    3e50:	6785                	lui	a5,0x1
    3e52:	dac7879b          	addiw	a5,a5,-596
    3e56:	40a7853b          	subw	a0,a5,a0
    3e5a:	00001097          	auipc	ra,0x1
    3e5e:	ade080e7          	jalr	-1314(ra) # 4938 <sbrk>
    exit(0);
    3e62:	4501                	li	a0,0
    3e64:	00001097          	auipc	ra,0x1
    3e68:	a4c080e7          	jalr	-1460(ra) # 48b0 <exit>
    printf("fork failed\n");
    3e6c:	00002517          	auipc	a0,0x2
    3e70:	dec50513          	addi	a0,a0,-532 # 5c58 <malloc+0xf62>
    3e74:	00001097          	auipc	ra,0x1
    3e78:	dc4080e7          	jalr	-572(ra) # 4c38 <printf>
    exit(1);
    3e7c:	4505                	li	a0,1
    3e7e:	00001097          	auipc	ra,0x1
    3e82:	a32080e7          	jalr	-1486(ra) # 48b0 <exit>
  wait(0);
    3e86:	4501                	li	a0,0
    3e88:	00001097          	auipc	ra,0x1
    3e8c:	a30080e7          	jalr	-1488(ra) # 48b8 <wait>
  pid = fork();
    3e90:	00001097          	auipc	ra,0x1
    3e94:	a18080e7          	jalr	-1512(ra) # 48a8 <fork>
  if(pid < 0){
    3e98:	02054a63          	bltz	a0,3ecc <sbrkbugs+0xea>
  if(pid == 0){
    3e9c:	e529                	bnez	a0,3ee6 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    3e9e:	00001097          	auipc	ra,0x1
    3ea2:	a9a080e7          	jalr	-1382(ra) # 4938 <sbrk>
    3ea6:	67ad                	lui	a5,0xb
    3ea8:	8007879b          	addiw	a5,a5,-2048
    3eac:	40a7853b          	subw	a0,a5,a0
    3eb0:	00001097          	auipc	ra,0x1
    3eb4:	a88080e7          	jalr	-1400(ra) # 4938 <sbrk>
    sbrk(-10);
    3eb8:	5559                	li	a0,-10
    3eba:	00001097          	auipc	ra,0x1
    3ebe:	a7e080e7          	jalr	-1410(ra) # 4938 <sbrk>
    exit(0);
    3ec2:	4501                	li	a0,0
    3ec4:	00001097          	auipc	ra,0x1
    3ec8:	9ec080e7          	jalr	-1556(ra) # 48b0 <exit>
    printf("fork failed\n");
    3ecc:	00002517          	auipc	a0,0x2
    3ed0:	d8c50513          	addi	a0,a0,-628 # 5c58 <malloc+0xf62>
    3ed4:	00001097          	auipc	ra,0x1
    3ed8:	d64080e7          	jalr	-668(ra) # 4c38 <printf>
    exit(1);
    3edc:	4505                	li	a0,1
    3ede:	00001097          	auipc	ra,0x1
    3ee2:	9d2080e7          	jalr	-1582(ra) # 48b0 <exit>
  wait(0);
    3ee6:	4501                	li	a0,0
    3ee8:	00001097          	auipc	ra,0x1
    3eec:	9d0080e7          	jalr	-1584(ra) # 48b8 <wait>
  exit(0);
    3ef0:	4501                	li	a0,0
    3ef2:	00001097          	auipc	ra,0x1
    3ef6:	9be080e7          	jalr	-1602(ra) # 48b0 <exit>

0000000000003efa <dirtest>:
{
    3efa:	1101                	addi	sp,sp,-32
    3efc:	ec06                	sd	ra,24(sp)
    3efe:	e822                	sd	s0,16(sp)
    3f00:	e426                	sd	s1,8(sp)
    3f02:	1000                	addi	s0,sp,32
    3f04:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    3f06:	00003517          	auipc	a0,0x3
    3f0a:	b3a50513          	addi	a0,a0,-1222 # 6a40 <malloc+0x1d4a>
    3f0e:	00001097          	auipc	ra,0x1
    3f12:	d2a080e7          	jalr	-726(ra) # 4c38 <printf>
  if(mkdir("dir0") < 0){
    3f16:	00003517          	auipc	a0,0x3
    3f1a:	b3a50513          	addi	a0,a0,-1222 # 6a50 <malloc+0x1d5a>
    3f1e:	00001097          	auipc	ra,0x1
    3f22:	9fa080e7          	jalr	-1542(ra) # 4918 <mkdir>
    3f26:	04054d63          	bltz	a0,3f80 <dirtest+0x86>
  if(chdir("dir0") < 0){
    3f2a:	00003517          	auipc	a0,0x3
    3f2e:	b2650513          	addi	a0,a0,-1242 # 6a50 <malloc+0x1d5a>
    3f32:	00001097          	auipc	ra,0x1
    3f36:	9ee080e7          	jalr	-1554(ra) # 4920 <chdir>
    3f3a:	06054163          	bltz	a0,3f9c <dirtest+0xa2>
  if(chdir("..") < 0){
    3f3e:	00002517          	auipc	a0,0x2
    3f42:	aca50513          	addi	a0,a0,-1334 # 5a08 <malloc+0xd12>
    3f46:	00001097          	auipc	ra,0x1
    3f4a:	9da080e7          	jalr	-1574(ra) # 4920 <chdir>
    3f4e:	06054563          	bltz	a0,3fb8 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    3f52:	00003517          	auipc	a0,0x3
    3f56:	afe50513          	addi	a0,a0,-1282 # 6a50 <malloc+0x1d5a>
    3f5a:	00001097          	auipc	ra,0x1
    3f5e:	9a6080e7          	jalr	-1626(ra) # 4900 <unlink>
    3f62:	06054963          	bltz	a0,3fd4 <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    3f66:	00003517          	auipc	a0,0x3
    3f6a:	b3a50513          	addi	a0,a0,-1222 # 6aa0 <malloc+0x1daa>
    3f6e:	00001097          	auipc	ra,0x1
    3f72:	cca080e7          	jalr	-822(ra) # 4c38 <printf>
}
    3f76:	60e2                	ld	ra,24(sp)
    3f78:	6442                	ld	s0,16(sp)
    3f7a:	64a2                	ld	s1,8(sp)
    3f7c:	6105                	addi	sp,sp,32
    3f7e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3f80:	85a6                	mv	a1,s1
    3f82:	00002517          	auipc	a0,0x2
    3f86:	98e50513          	addi	a0,a0,-1650 # 5910 <malloc+0xc1a>
    3f8a:	00001097          	auipc	ra,0x1
    3f8e:	cae080e7          	jalr	-850(ra) # 4c38 <printf>
    exit(1);
    3f92:	4505                	li	a0,1
    3f94:	00001097          	auipc	ra,0x1
    3f98:	91c080e7          	jalr	-1764(ra) # 48b0 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3f9c:	85a6                	mv	a1,s1
    3f9e:	00003517          	auipc	a0,0x3
    3fa2:	aba50513          	addi	a0,a0,-1350 # 6a58 <malloc+0x1d62>
    3fa6:	00001097          	auipc	ra,0x1
    3faa:	c92080e7          	jalr	-878(ra) # 4c38 <printf>
    exit(1);
    3fae:	4505                	li	a0,1
    3fb0:	00001097          	auipc	ra,0x1
    3fb4:	900080e7          	jalr	-1792(ra) # 48b0 <exit>
    printf("%s: chdir .. failed\n", s);
    3fb8:	85a6                	mv	a1,s1
    3fba:	00003517          	auipc	a0,0x3
    3fbe:	ab650513          	addi	a0,a0,-1354 # 6a70 <malloc+0x1d7a>
    3fc2:	00001097          	auipc	ra,0x1
    3fc6:	c76080e7          	jalr	-906(ra) # 4c38 <printf>
    exit(1);
    3fca:	4505                	li	a0,1
    3fcc:	00001097          	auipc	ra,0x1
    3fd0:	8e4080e7          	jalr	-1820(ra) # 48b0 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3fd4:	85a6                	mv	a1,s1
    3fd6:	00003517          	auipc	a0,0x3
    3fda:	ab250513          	addi	a0,a0,-1358 # 6a88 <malloc+0x1d92>
    3fde:	00001097          	auipc	ra,0x1
    3fe2:	c5a080e7          	jalr	-934(ra) # 4c38 <printf>
    exit(1);
    3fe6:	4505                	li	a0,1
    3fe8:	00001097          	auipc	ra,0x1
    3fec:	8c8080e7          	jalr	-1848(ra) # 48b0 <exit>

0000000000003ff0 <mem>:
{
    3ff0:	7139                	addi	sp,sp,-64
    3ff2:	fc06                	sd	ra,56(sp)
    3ff4:	f822                	sd	s0,48(sp)
    3ff6:	f426                	sd	s1,40(sp)
    3ff8:	f04a                	sd	s2,32(sp)
    3ffa:	ec4e                	sd	s3,24(sp)
    3ffc:	0080                	addi	s0,sp,64
    3ffe:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4000:	00001097          	auipc	ra,0x1
    4004:	8a8080e7          	jalr	-1880(ra) # 48a8 <fork>
    m1 = 0;
    4008:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    400a:	6909                	lui	s2,0x2
    400c:	71190913          	addi	s2,s2,1809 # 2711 <linktest+0xf9>
  if((pid = fork()) == 0){
    4010:	cd19                	beqz	a0,402e <mem+0x3e>
    wait(&xstatus);
    4012:	fcc40513          	addi	a0,s0,-52
    4016:	00001097          	auipc	ra,0x1
    401a:	8a2080e7          	jalr	-1886(ra) # 48b8 <wait>
    exit(xstatus);
    401e:	fcc42503          	lw	a0,-52(s0)
    4022:	00001097          	auipc	ra,0x1
    4026:	88e080e7          	jalr	-1906(ra) # 48b0 <exit>
      *(char**)m2 = m1;
    402a:	e104                	sd	s1,0(a0)
      m1 = m2;
    402c:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    402e:	854a                	mv	a0,s2
    4030:	00001097          	auipc	ra,0x1
    4034:	cc6080e7          	jalr	-826(ra) # 4cf6 <malloc>
    4038:	f96d                	bnez	a0,402a <mem+0x3a>
    while(m1){
    403a:	c881                	beqz	s1,404a <mem+0x5a>
      m2 = *(char**)m1;
    403c:	8526                	mv	a0,s1
    403e:	6084                	ld	s1,0(s1)
      free(m1);
    4040:	00001097          	auipc	ra,0x1
    4044:	c2e080e7          	jalr	-978(ra) # 4c6e <free>
    while(m1){
    4048:	f8f5                	bnez	s1,403c <mem+0x4c>
    m1 = malloc(1024*20);
    404a:	6515                	lui	a0,0x5
    404c:	00001097          	auipc	ra,0x1
    4050:	caa080e7          	jalr	-854(ra) # 4cf6 <malloc>
    if(m1 == 0){
    4054:	c911                	beqz	a0,4068 <mem+0x78>
    free(m1);
    4056:	00001097          	auipc	ra,0x1
    405a:	c18080e7          	jalr	-1000(ra) # 4c6e <free>
    exit(0);
    405e:	4501                	li	a0,0
    4060:	00001097          	auipc	ra,0x1
    4064:	850080e7          	jalr	-1968(ra) # 48b0 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4068:	85ce                	mv	a1,s3
    406a:	00003517          	auipc	a0,0x3
    406e:	a4e50513          	addi	a0,a0,-1458 # 6ab8 <malloc+0x1dc2>
    4072:	00001097          	auipc	ra,0x1
    4076:	bc6080e7          	jalr	-1082(ra) # 4c38 <printf>
      exit(1);
    407a:	4505                	li	a0,1
    407c:	00001097          	auipc	ra,0x1
    4080:	834080e7          	jalr	-1996(ra) # 48b0 <exit>

0000000000004084 <sbrkbasic>:
{
    4084:	7139                	addi	sp,sp,-64
    4086:	fc06                	sd	ra,56(sp)
    4088:	f822                	sd	s0,48(sp)
    408a:	f426                	sd	s1,40(sp)
    408c:	f04a                	sd	s2,32(sp)
    408e:	ec4e                	sd	s3,24(sp)
    4090:	e852                	sd	s4,16(sp)
    4092:	0080                	addi	s0,sp,64
    4094:	8a2a                	mv	s4,a0
  a = sbrk(TOOMUCH);
    4096:	40000537          	lui	a0,0x40000
    409a:	00001097          	auipc	ra,0x1
    409e:	89e080e7          	jalr	-1890(ra) # 4938 <sbrk>
  if(a != (char*)0xffffffffffffffffL){
    40a2:	57fd                	li	a5,-1
    40a4:	02f50063          	beq	a0,a5,40c4 <sbrkbasic+0x40>
    40a8:	85aa                	mv	a1,a0
    printf("%s: sbrk(<toomuch>) returned %p\n", a);
    40aa:	00003517          	auipc	a0,0x3
    40ae:	a2e50513          	addi	a0,a0,-1490 # 6ad8 <malloc+0x1de2>
    40b2:	00001097          	auipc	ra,0x1
    40b6:	b86080e7          	jalr	-1146(ra) # 4c38 <printf>
    exit(1);
    40ba:	4505                	li	a0,1
    40bc:	00000097          	auipc	ra,0x0
    40c0:	7f4080e7          	jalr	2036(ra) # 48b0 <exit>
  a = sbrk(0);
    40c4:	4501                	li	a0,0
    40c6:	00001097          	auipc	ra,0x1
    40ca:	872080e7          	jalr	-1934(ra) # 4938 <sbrk>
    40ce:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    40d0:	4901                	li	s2,0
    40d2:	6985                	lui	s3,0x1
    40d4:	38898993          	addi	s3,s3,904 # 1388 <fourteen+0x10e>
    40d8:	a011                	j	40dc <sbrkbasic+0x58>
    a = b + 1;
    40da:	84be                	mv	s1,a5
    b = sbrk(1);
    40dc:	4505                	li	a0,1
    40de:	00001097          	auipc	ra,0x1
    40e2:	85a080e7          	jalr	-1958(ra) # 4938 <sbrk>
    if(b != a){
    40e6:	04951c63          	bne	a0,s1,413e <sbrkbasic+0xba>
    *b = 1;
    40ea:	4785                	li	a5,1
    40ec:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    40f0:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    40f4:	2905                	addiw	s2,s2,1
    40f6:	ff3912e3          	bne	s2,s3,40da <sbrkbasic+0x56>
  pid = fork();
    40fa:	00000097          	auipc	ra,0x0
    40fe:	7ae080e7          	jalr	1966(ra) # 48a8 <fork>
    4102:	892a                	mv	s2,a0
  if(pid < 0){
    4104:	04054e63          	bltz	a0,4160 <sbrkbasic+0xdc>
  c = sbrk(1);
    4108:	4505                	li	a0,1
    410a:	00001097          	auipc	ra,0x1
    410e:	82e080e7          	jalr	-2002(ra) # 4938 <sbrk>
  c = sbrk(1);
    4112:	4505                	li	a0,1
    4114:	00001097          	auipc	ra,0x1
    4118:	824080e7          	jalr	-2012(ra) # 4938 <sbrk>
  if(c != a + 1){
    411c:	0489                	addi	s1,s1,2
    411e:	04a48f63          	beq	s1,a0,417c <sbrkbasic+0xf8>
    printf("%s: sbrk test failed post-fork\n", s);
    4122:	85d2                	mv	a1,s4
    4124:	00003517          	auipc	a0,0x3
    4128:	a1c50513          	addi	a0,a0,-1508 # 6b40 <malloc+0x1e4a>
    412c:	00001097          	auipc	ra,0x1
    4130:	b0c080e7          	jalr	-1268(ra) # 4c38 <printf>
    exit(1);
    4134:	4505                	li	a0,1
    4136:	00000097          	auipc	ra,0x0
    413a:	77a080e7          	jalr	1914(ra) # 48b0 <exit>
      printf("%s: sbrk test failed %d %x %x\n", s, i, a, b);
    413e:	872a                	mv	a4,a0
    4140:	86a6                	mv	a3,s1
    4142:	864a                	mv	a2,s2
    4144:	85d2                	mv	a1,s4
    4146:	00003517          	auipc	a0,0x3
    414a:	9ba50513          	addi	a0,a0,-1606 # 6b00 <malloc+0x1e0a>
    414e:	00001097          	auipc	ra,0x1
    4152:	aea080e7          	jalr	-1302(ra) # 4c38 <printf>
      exit(1);
    4156:	4505                	li	a0,1
    4158:	00000097          	auipc	ra,0x0
    415c:	758080e7          	jalr	1880(ra) # 48b0 <exit>
    printf("%s: sbrk test fork failed\n", s);
    4160:	85d2                	mv	a1,s4
    4162:	00003517          	auipc	a0,0x3
    4166:	9be50513          	addi	a0,a0,-1602 # 6b20 <malloc+0x1e2a>
    416a:	00001097          	auipc	ra,0x1
    416e:	ace080e7          	jalr	-1330(ra) # 4c38 <printf>
    exit(1);
    4172:	4505                	li	a0,1
    4174:	00000097          	auipc	ra,0x0
    4178:	73c080e7          	jalr	1852(ra) # 48b0 <exit>
  if(pid == 0)
    417c:	00091763          	bnez	s2,418a <sbrkbasic+0x106>
    exit(0);
    4180:	4501                	li	a0,0
    4182:	00000097          	auipc	ra,0x0
    4186:	72e080e7          	jalr	1838(ra) # 48b0 <exit>
  wait(&xstatus);
    418a:	fcc40513          	addi	a0,s0,-52
    418e:	00000097          	auipc	ra,0x0
    4192:	72a080e7          	jalr	1834(ra) # 48b8 <wait>
  exit(xstatus);
    4196:	fcc42503          	lw	a0,-52(s0)
    419a:	00000097          	auipc	ra,0x0
    419e:	716080e7          	jalr	1814(ra) # 48b0 <exit>

00000000000041a2 <fsfull>:
{
    41a2:	7171                	addi	sp,sp,-176
    41a4:	f506                	sd	ra,168(sp)
    41a6:	f122                	sd	s0,160(sp)
    41a8:	ed26                	sd	s1,152(sp)
    41aa:	e94a                	sd	s2,144(sp)
    41ac:	e54e                	sd	s3,136(sp)
    41ae:	e152                	sd	s4,128(sp)
    41b0:	fcd6                	sd	s5,120(sp)
    41b2:	f8da                	sd	s6,112(sp)
    41b4:	f4de                	sd	s7,104(sp)
    41b6:	f0e2                	sd	s8,96(sp)
    41b8:	ece6                	sd	s9,88(sp)
    41ba:	e8ea                	sd	s10,80(sp)
    41bc:	e4ee                	sd	s11,72(sp)
    41be:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    41c0:	00003517          	auipc	a0,0x3
    41c4:	9a050513          	addi	a0,a0,-1632 # 6b60 <malloc+0x1e6a>
    41c8:	00001097          	auipc	ra,0x1
    41cc:	a70080e7          	jalr	-1424(ra) # 4c38 <printf>
  for(nfiles = 0; ; nfiles++){
    41d0:	4481                	li	s1,0
    name[0] = 'f';
    41d2:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    41d6:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    41da:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    41de:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    41e0:	00003c97          	auipc	s9,0x3
    41e4:	990c8c93          	addi	s9,s9,-1648 # 6b70 <malloc+0x1e7a>
    int total = 0;
    41e8:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    41ea:	00005a17          	auipc	s4,0x5
    41ee:	636a0a13          	addi	s4,s4,1590 # 9820 <buf>
    name[0] = 'f';
    41f2:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    41f6:	0384c7bb          	divw	a5,s1,s8
    41fa:	0307879b          	addiw	a5,a5,48
    41fe:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4202:	0384e7bb          	remw	a5,s1,s8
    4206:	0377c7bb          	divw	a5,a5,s7
    420a:	0307879b          	addiw	a5,a5,48
    420e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4212:	0374e7bb          	remw	a5,s1,s7
    4216:	0367c7bb          	divw	a5,a5,s6
    421a:	0307879b          	addiw	a5,a5,48
    421e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4222:	0364e7bb          	remw	a5,s1,s6
    4226:	0307879b          	addiw	a5,a5,48
    422a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    422e:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    4232:	f5040593          	addi	a1,s0,-176
    4236:	8566                	mv	a0,s9
    4238:	00001097          	auipc	ra,0x1
    423c:	a00080e7          	jalr	-1536(ra) # 4c38 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4240:	20200593          	li	a1,514
    4244:	f5040513          	addi	a0,s0,-176
    4248:	00000097          	auipc	ra,0x0
    424c:	6a8080e7          	jalr	1704(ra) # 48f0 <open>
    4250:	892a                	mv	s2,a0
    if(fd < 0){
    4252:	0a055663          	bgez	a0,42fe <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    4256:	f5040593          	addi	a1,s0,-176
    425a:	00003517          	auipc	a0,0x3
    425e:	92650513          	addi	a0,a0,-1754 # 6b80 <malloc+0x1e8a>
    4262:	00001097          	auipc	ra,0x1
    4266:	9d6080e7          	jalr	-1578(ra) # 4c38 <printf>
  while(nfiles >= 0){
    426a:	0604c363          	bltz	s1,42d0 <fsfull+0x12e>
    name[0] = 'f';
    426e:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4272:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4276:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    427a:	4929                	li	s2,10
  while(nfiles >= 0){
    427c:	5afd                	li	s5,-1
    name[0] = 'f';
    427e:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4282:	0344c7bb          	divw	a5,s1,s4
    4286:	0307879b          	addiw	a5,a5,48
    428a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    428e:	0344e7bb          	remw	a5,s1,s4
    4292:	0337c7bb          	divw	a5,a5,s3
    4296:	0307879b          	addiw	a5,a5,48
    429a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    429e:	0334e7bb          	remw	a5,s1,s3
    42a2:	0327c7bb          	divw	a5,a5,s2
    42a6:	0307879b          	addiw	a5,a5,48
    42aa:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    42ae:	0324e7bb          	remw	a5,s1,s2
    42b2:	0307879b          	addiw	a5,a5,48
    42b6:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    42ba:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    42be:	f5040513          	addi	a0,s0,-176
    42c2:	00000097          	auipc	ra,0x0
    42c6:	63e080e7          	jalr	1598(ra) # 4900 <unlink>
    nfiles--;
    42ca:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    42cc:	fb5499e3          	bne	s1,s5,427e <fsfull+0xdc>
  printf("fsfull test finished\n");
    42d0:	00003517          	auipc	a0,0x3
    42d4:	8e050513          	addi	a0,a0,-1824 # 6bb0 <malloc+0x1eba>
    42d8:	00001097          	auipc	ra,0x1
    42dc:	960080e7          	jalr	-1696(ra) # 4c38 <printf>
}
    42e0:	70aa                	ld	ra,168(sp)
    42e2:	740a                	ld	s0,160(sp)
    42e4:	64ea                	ld	s1,152(sp)
    42e6:	694a                	ld	s2,144(sp)
    42e8:	69aa                	ld	s3,136(sp)
    42ea:	6a0a                	ld	s4,128(sp)
    42ec:	7ae6                	ld	s5,120(sp)
    42ee:	7b46                	ld	s6,112(sp)
    42f0:	7ba6                	ld	s7,104(sp)
    42f2:	7c06                	ld	s8,96(sp)
    42f4:	6ce6                	ld	s9,88(sp)
    42f6:	6d46                	ld	s10,80(sp)
    42f8:	6da6                	ld	s11,72(sp)
    42fa:	614d                	addi	sp,sp,176
    42fc:	8082                	ret
    int total = 0;
    42fe:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4300:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4304:	40000613          	li	a2,1024
    4308:	85d2                	mv	a1,s4
    430a:	854a                	mv	a0,s2
    430c:	00000097          	auipc	ra,0x0
    4310:	5c4080e7          	jalr	1476(ra) # 48d0 <write>
      if(cc < BSIZE)
    4314:	00aad563          	bge	s5,a0,431e <fsfull+0x17c>
      total += cc;
    4318:	00a989bb          	addw	s3,s3,a0
    while(1){
    431c:	b7e5                	j	4304 <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    431e:	85ce                	mv	a1,s3
    4320:	00003517          	auipc	a0,0x3
    4324:	87850513          	addi	a0,a0,-1928 # 6b98 <malloc+0x1ea2>
    4328:	00001097          	auipc	ra,0x1
    432c:	910080e7          	jalr	-1776(ra) # 4c38 <printf>
    close(fd);
    4330:	854a                	mv	a0,s2
    4332:	00000097          	auipc	ra,0x0
    4336:	5a6080e7          	jalr	1446(ra) # 48d8 <close>
    if(total == 0)
    433a:	f20988e3          	beqz	s3,426a <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    433e:	2485                	addiw	s1,s1,1
    4340:	bd4d                	j	41f2 <fsfull+0x50>

0000000000004342 <rand>:
{
    4342:	1141                	addi	sp,sp,-16
    4344:	e422                	sd	s0,8(sp)
    4346:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4348:	00003717          	auipc	a4,0x3
    434c:	cb070713          	addi	a4,a4,-848 # 6ff8 <randstate>
    4350:	6308                	ld	a0,0(a4)
    4352:	001967b7          	lui	a5,0x196
    4356:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x189ddd>
    435a:	02f50533          	mul	a0,a0,a5
    435e:	3c6ef7b7          	lui	a5,0x3c6ef
    4362:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e2b2f>
    4366:	953e                	add	a0,a0,a5
    4368:	e308                	sd	a0,0(a4)
}
    436a:	2501                	sext.w	a0,a0
    436c:	6422                	ld	s0,8(sp)
    436e:	0141                	addi	sp,sp,16
    4370:	8082                	ret

0000000000004372 <badwrite>:
{
    4372:	7179                	addi	sp,sp,-48
    4374:	f406                	sd	ra,40(sp)
    4376:	f022                	sd	s0,32(sp)
    4378:	ec26                	sd	s1,24(sp)
    437a:	e84a                	sd	s2,16(sp)
    437c:	e44e                	sd	s3,8(sp)
    437e:	e052                	sd	s4,0(sp)
    4380:	1800                	addi	s0,sp,48
  unlink("junk");
    4382:	00003517          	auipc	a0,0x3
    4386:	84650513          	addi	a0,a0,-1978 # 6bc8 <malloc+0x1ed2>
    438a:	00000097          	auipc	ra,0x0
    438e:	576080e7          	jalr	1398(ra) # 4900 <unlink>
    4392:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4396:	00003997          	auipc	s3,0x3
    439a:	83298993          	addi	s3,s3,-1998 # 6bc8 <malloc+0x1ed2>
    write(fd, (char*)0xffffffffffL, 1);
    439e:	5a7d                	li	s4,-1
    43a0:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    43a4:	20100593          	li	a1,513
    43a8:	854e                	mv	a0,s3
    43aa:	00000097          	auipc	ra,0x0
    43ae:	546080e7          	jalr	1350(ra) # 48f0 <open>
    43b2:	84aa                	mv	s1,a0
    if(fd < 0){
    43b4:	06054b63          	bltz	a0,442a <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    43b8:	4605                	li	a2,1
    43ba:	85d2                	mv	a1,s4
    43bc:	00000097          	auipc	ra,0x0
    43c0:	514080e7          	jalr	1300(ra) # 48d0 <write>
    close(fd);
    43c4:	8526                	mv	a0,s1
    43c6:	00000097          	auipc	ra,0x0
    43ca:	512080e7          	jalr	1298(ra) # 48d8 <close>
    unlink("junk");
    43ce:	854e                	mv	a0,s3
    43d0:	00000097          	auipc	ra,0x0
    43d4:	530080e7          	jalr	1328(ra) # 4900 <unlink>
  for(int i = 0; i < assumed_free; i++){
    43d8:	397d                	addiw	s2,s2,-1
    43da:	fc0915e3          	bnez	s2,43a4 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    43de:	20100593          	li	a1,513
    43e2:	00002517          	auipc	a0,0x2
    43e6:	7e650513          	addi	a0,a0,2022 # 6bc8 <malloc+0x1ed2>
    43ea:	00000097          	auipc	ra,0x0
    43ee:	506080e7          	jalr	1286(ra) # 48f0 <open>
    43f2:	84aa                	mv	s1,a0
  if(fd < 0){
    43f4:	04054863          	bltz	a0,4444 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    43f8:	4605                	li	a2,1
    43fa:	00001597          	auipc	a1,0x1
    43fe:	d4658593          	addi	a1,a1,-698 # 5140 <malloc+0x44a>
    4402:	00000097          	auipc	ra,0x0
    4406:	4ce080e7          	jalr	1230(ra) # 48d0 <write>
    440a:	4785                	li	a5,1
    440c:	04f50963          	beq	a0,a5,445e <badwrite+0xec>
    printf("write failed\n");
    4410:	00002517          	auipc	a0,0x2
    4414:	7d850513          	addi	a0,a0,2008 # 6be8 <malloc+0x1ef2>
    4418:	00001097          	auipc	ra,0x1
    441c:	820080e7          	jalr	-2016(ra) # 4c38 <printf>
    exit(1);
    4420:	4505                	li	a0,1
    4422:	00000097          	auipc	ra,0x0
    4426:	48e080e7          	jalr	1166(ra) # 48b0 <exit>
      printf("open junk failed\n");
    442a:	00002517          	auipc	a0,0x2
    442e:	7a650513          	addi	a0,a0,1958 # 6bd0 <malloc+0x1eda>
    4432:	00001097          	auipc	ra,0x1
    4436:	806080e7          	jalr	-2042(ra) # 4c38 <printf>
      exit(1);
    443a:	4505                	li	a0,1
    443c:	00000097          	auipc	ra,0x0
    4440:	474080e7          	jalr	1140(ra) # 48b0 <exit>
    printf("open junk failed\n");
    4444:	00002517          	auipc	a0,0x2
    4448:	78c50513          	addi	a0,a0,1932 # 6bd0 <malloc+0x1eda>
    444c:	00000097          	auipc	ra,0x0
    4450:	7ec080e7          	jalr	2028(ra) # 4c38 <printf>
    exit(1);
    4454:	4505                	li	a0,1
    4456:	00000097          	auipc	ra,0x0
    445a:	45a080e7          	jalr	1114(ra) # 48b0 <exit>
  close(fd);
    445e:	8526                	mv	a0,s1
    4460:	00000097          	auipc	ra,0x0
    4464:	478080e7          	jalr	1144(ra) # 48d8 <close>
  unlink("junk");
    4468:	00002517          	auipc	a0,0x2
    446c:	76050513          	addi	a0,a0,1888 # 6bc8 <malloc+0x1ed2>
    4470:	00000097          	auipc	ra,0x0
    4474:	490080e7          	jalr	1168(ra) # 4900 <unlink>
  exit(0);
    4478:	4501                	li	a0,0
    447a:	00000097          	auipc	ra,0x0
    447e:	436080e7          	jalr	1078(ra) # 48b0 <exit>

0000000000004482 <run>:
}

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4482:	7179                	addi	sp,sp,-48
    4484:	f406                	sd	ra,40(sp)
    4486:	f022                	sd	s0,32(sp)
    4488:	ec26                	sd	s1,24(sp)
    448a:	e84a                	sd	s2,16(sp)
    448c:	1800                	addi	s0,sp,48
    448e:	892a                	mv	s2,a0
    4490:	84ae                	mv	s1,a1
  int pid;
  int xstatus;
  
  printf("test %s: ", s);
    4492:	00002517          	auipc	a0,0x2
    4496:	76650513          	addi	a0,a0,1894 # 6bf8 <malloc+0x1f02>
    449a:	00000097          	auipc	ra,0x0
    449e:	79e080e7          	jalr	1950(ra) # 4c38 <printf>
  if((pid = fork()) < 0) {
    44a2:	00000097          	auipc	ra,0x0
    44a6:	406080e7          	jalr	1030(ra) # 48a8 <fork>
    44aa:	02054f63          	bltz	a0,44e8 <run+0x66>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    44ae:	c931                	beqz	a0,4502 <run+0x80>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    44b0:	fdc40513          	addi	a0,s0,-36
    44b4:	00000097          	auipc	ra,0x0
    44b8:	404080e7          	jalr	1028(ra) # 48b8 <wait>
    if(xstatus != 0) 
    44bc:	fdc42783          	lw	a5,-36(s0)
    44c0:	cba1                	beqz	a5,4510 <run+0x8e>
      printf("FAILED\n", s);
    44c2:	85a6                	mv	a1,s1
    44c4:	00002517          	auipc	a0,0x2
    44c8:	75c50513          	addi	a0,a0,1884 # 6c20 <malloc+0x1f2a>
    44cc:	00000097          	auipc	ra,0x0
    44d0:	76c080e7          	jalr	1900(ra) # 4c38 <printf>
    else
      printf("OK\n", s);
    return xstatus == 0;
    44d4:	fdc42503          	lw	a0,-36(s0)
  }
}
    44d8:	00153513          	seqz	a0,a0
    44dc:	70a2                	ld	ra,40(sp)
    44de:	7402                	ld	s0,32(sp)
    44e0:	64e2                	ld	s1,24(sp)
    44e2:	6942                	ld	s2,16(sp)
    44e4:	6145                	addi	sp,sp,48
    44e6:	8082                	ret
    printf("runtest: fork error\n");
    44e8:	00002517          	auipc	a0,0x2
    44ec:	72050513          	addi	a0,a0,1824 # 6c08 <malloc+0x1f12>
    44f0:	00000097          	auipc	ra,0x0
    44f4:	748080e7          	jalr	1864(ra) # 4c38 <printf>
    exit(1);
    44f8:	4505                	li	a0,1
    44fa:	00000097          	auipc	ra,0x0
    44fe:	3b6080e7          	jalr	950(ra) # 48b0 <exit>
    f(s);
    4502:	8526                	mv	a0,s1
    4504:	9902                	jalr	s2
    exit(0);
    4506:	4501                	li	a0,0
    4508:	00000097          	auipc	ra,0x0
    450c:	3a8080e7          	jalr	936(ra) # 48b0 <exit>
      printf("OK\n", s);
    4510:	85a6                	mv	a1,s1
    4512:	00002517          	auipc	a0,0x2
    4516:	71650513          	addi	a0,a0,1814 # 6c28 <malloc+0x1f32>
    451a:	00000097          	auipc	ra,0x0
    451e:	71e080e7          	jalr	1822(ra) # 4c38 <printf>
    4522:	bf4d                	j	44d4 <run+0x52>

0000000000004524 <main>:

int
main(int argc, char *argv[])
{
    4524:	cd010113          	addi	sp,sp,-816
    4528:	32113423          	sd	ra,808(sp)
    452c:	32813023          	sd	s0,800(sp)
    4530:	30913c23          	sd	s1,792(sp)
    4534:	31213823          	sd	s2,784(sp)
    4538:	31313423          	sd	s3,776(sp)
    453c:	31413023          	sd	s4,768(sp)
    4540:	1e00                	addi	s0,sp,816
  char *n = 0;
  if(argc > 1) {
    4542:	4785                	li	a5,1
  char *n = 0;
    4544:	4901                	li	s2,0
  if(argc > 1) {
    4546:	00a7d463          	bge	a5,a0,454e <main+0x2a>
    n = argv[1];
    454a:	0085b903          	ld	s2,8(a1)
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    454e:	00002797          	auipc	a5,0x2
    4552:	78278793          	addi	a5,a5,1922 # 6cd0 <malloc+0x1fda>
    4556:	cd040713          	addi	a4,s0,-816
    455a:	00003817          	auipc	a6,0x3
    455e:	a7680813          	addi	a6,a6,-1418 # 6fd0 <malloc+0x22da>
    4562:	6388                	ld	a0,0(a5)
    4564:	678c                	ld	a1,8(a5)
    4566:	6b90                	ld	a2,16(a5)
    4568:	6f94                	ld	a3,24(a5)
    456a:	e308                	sd	a0,0(a4)
    456c:	e70c                	sd	a1,8(a4)
    456e:	eb10                	sd	a2,16(a4)
    4570:	ef14                	sd	a3,24(a4)
    4572:	02078793          	addi	a5,a5,32
    4576:	02070713          	addi	a4,a4,32
    457a:	ff0794e3          	bne	a5,a6,4562 <main+0x3e>
    {forktest, "forktest"},
    {bigdir, "bigdir"}, // slow
    { 0, 0},
  };
    
  printf("usertests starting\n");
    457e:	00002517          	auipc	a0,0x2
    4582:	6b250513          	addi	a0,a0,1714 # 6c30 <malloc+0x1f3a>
    4586:	00000097          	auipc	ra,0x0
    458a:	6b2080e7          	jalr	1714(ra) # 4c38 <printf>

  if(open("usertests.ran", 0) >= 0){
    458e:	4581                	li	a1,0
    4590:	00002517          	auipc	a0,0x2
    4594:	6b850513          	addi	a0,a0,1720 # 6c48 <malloc+0x1f52>
    4598:	00000097          	auipc	ra,0x0
    459c:	358080e7          	jalr	856(ra) # 48f0 <open>
    45a0:	00054f63          	bltz	a0,45be <main+0x9a>
    printf("already ran user tests -- rebuild fs.img (rm fs.img; make fs.img)\n");
    45a4:	00002517          	auipc	a0,0x2
    45a8:	6b450513          	addi	a0,a0,1716 # 6c58 <malloc+0x1f62>
    45ac:	00000097          	auipc	ra,0x0
    45b0:	68c080e7          	jalr	1676(ra) # 4c38 <printf>
    exit(1);
    45b4:	4505                	li	a0,1
    45b6:	00000097          	auipc	ra,0x0
    45ba:	2fa080e7          	jalr	762(ra) # 48b0 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    45be:	20000593          	li	a1,512
    45c2:	00002517          	auipc	a0,0x2
    45c6:	68650513          	addi	a0,a0,1670 # 6c48 <malloc+0x1f52>
    45ca:	00000097          	auipc	ra,0x0
    45ce:	326080e7          	jalr	806(ra) # 48f0 <open>
    45d2:	00000097          	auipc	ra,0x0
    45d6:	306080e7          	jalr	774(ra) # 48d8 <close>

  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    45da:	cd843503          	ld	a0,-808(s0)
    45de:	c529                	beqz	a0,4628 <main+0x104>
    45e0:	cd040493          	addi	s1,s0,-816
  int fail = 0;
    45e4:	4981                	li	s3,0
    if((n == 0) || strcmp(t->s, n) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    45e6:	4a05                	li	s4,1
    45e8:	a021                	j	45f0 <main+0xcc>
  for (struct test *t = tests; t->s != 0; t++) {
    45ea:	04c1                	addi	s1,s1,16
    45ec:	6488                	ld	a0,8(s1)
    45ee:	c115                	beqz	a0,4612 <main+0xee>
    if((n == 0) || strcmp(t->s, n) == 0) {
    45f0:	00090863          	beqz	s2,4600 <main+0xdc>
    45f4:	85ca                	mv	a1,s2
    45f6:	00000097          	auipc	ra,0x0
    45fa:	068080e7          	jalr	104(ra) # 465e <strcmp>
    45fe:	f575                	bnez	a0,45ea <main+0xc6>
      if(!run(t->f, t->s))
    4600:	648c                	ld	a1,8(s1)
    4602:	6088                	ld	a0,0(s1)
    4604:	00000097          	auipc	ra,0x0
    4608:	e7e080e7          	jalr	-386(ra) # 4482 <run>
    460c:	fd79                	bnez	a0,45ea <main+0xc6>
        fail = 1;
    460e:	89d2                	mv	s3,s4
    4610:	bfe9                	j	45ea <main+0xc6>
    }
  }
  if(!fail)
    4612:	00098b63          	beqz	s3,4628 <main+0x104>
    printf("ALL TESTS PASSED\n");
  else
    printf("SOME TESTS FAILED\n");
    4616:	00002517          	auipc	a0,0x2
    461a:	6a250513          	addi	a0,a0,1698 # 6cb8 <malloc+0x1fc2>
    461e:	00000097          	auipc	ra,0x0
    4622:	61a080e7          	jalr	1562(ra) # 4c38 <printf>
    4626:	a809                	j	4638 <main+0x114>
    printf("ALL TESTS PASSED\n");
    4628:	00002517          	auipc	a0,0x2
    462c:	67850513          	addi	a0,a0,1656 # 6ca0 <malloc+0x1faa>
    4630:	00000097          	auipc	ra,0x0
    4634:	608080e7          	jalr	1544(ra) # 4c38 <printf>
  exit(1);   // not reached.
    4638:	4505                	li	a0,1
    463a:	00000097          	auipc	ra,0x0
    463e:	276080e7          	jalr	630(ra) # 48b0 <exit>

0000000000004642 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    4642:	1141                	addi	sp,sp,-16
    4644:	e422                	sd	s0,8(sp)
    4646:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4648:	87aa                	mv	a5,a0
    464a:	0585                	addi	a1,a1,1
    464c:	0785                	addi	a5,a5,1
    464e:	fff5c703          	lbu	a4,-1(a1)
    4652:	fee78fa3          	sb	a4,-1(a5)
    4656:	fb75                	bnez	a4,464a <strcpy+0x8>
    ;
  return os;
}
    4658:	6422                	ld	s0,8(sp)
    465a:	0141                	addi	sp,sp,16
    465c:	8082                	ret

000000000000465e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    465e:	1141                	addi	sp,sp,-16
    4660:	e422                	sd	s0,8(sp)
    4662:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4664:	00054783          	lbu	a5,0(a0)
    4668:	cb91                	beqz	a5,467c <strcmp+0x1e>
    466a:	0005c703          	lbu	a4,0(a1)
    466e:	00f71763          	bne	a4,a5,467c <strcmp+0x1e>
    p++, q++;
    4672:	0505                	addi	a0,a0,1
    4674:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4676:	00054783          	lbu	a5,0(a0)
    467a:	fbe5                	bnez	a5,466a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    467c:	0005c503          	lbu	a0,0(a1)
}
    4680:	40a7853b          	subw	a0,a5,a0
    4684:	6422                	ld	s0,8(sp)
    4686:	0141                	addi	sp,sp,16
    4688:	8082                	ret

000000000000468a <strlen>:

uint
strlen(const char *s)
{
    468a:	1141                	addi	sp,sp,-16
    468c:	e422                	sd	s0,8(sp)
    468e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4690:	00054783          	lbu	a5,0(a0)
    4694:	cf91                	beqz	a5,46b0 <strlen+0x26>
    4696:	0505                	addi	a0,a0,1
    4698:	87aa                	mv	a5,a0
    469a:	4685                	li	a3,1
    469c:	9e89                	subw	a3,a3,a0
    469e:	00f6853b          	addw	a0,a3,a5
    46a2:	0785                	addi	a5,a5,1
    46a4:	fff7c703          	lbu	a4,-1(a5)
    46a8:	fb7d                	bnez	a4,469e <strlen+0x14>
    ;
  return n;
}
    46aa:	6422                	ld	s0,8(sp)
    46ac:	0141                	addi	sp,sp,16
    46ae:	8082                	ret
  for(n = 0; s[n]; n++)
    46b0:	4501                	li	a0,0
    46b2:	bfe5                	j	46aa <strlen+0x20>

00000000000046b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
    46b4:	1141                	addi	sp,sp,-16
    46b6:	e422                	sd	s0,8(sp)
    46b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    46ba:	ca19                	beqz	a2,46d0 <memset+0x1c>
    46bc:	87aa                	mv	a5,a0
    46be:	1602                	slli	a2,a2,0x20
    46c0:	9201                	srli	a2,a2,0x20
    46c2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    46c6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    46ca:	0785                	addi	a5,a5,1
    46cc:	fee79de3          	bne	a5,a4,46c6 <memset+0x12>
  }
  return dst;
}
    46d0:	6422                	ld	s0,8(sp)
    46d2:	0141                	addi	sp,sp,16
    46d4:	8082                	ret

00000000000046d6 <strchr>:

char*
strchr(const char *s, char c)
{
    46d6:	1141                	addi	sp,sp,-16
    46d8:	e422                	sd	s0,8(sp)
    46da:	0800                	addi	s0,sp,16
  for(; *s; s++)
    46dc:	00054783          	lbu	a5,0(a0)
    46e0:	cb99                	beqz	a5,46f6 <strchr+0x20>
    if(*s == c)
    46e2:	00f58763          	beq	a1,a5,46f0 <strchr+0x1a>
  for(; *s; s++)
    46e6:	0505                	addi	a0,a0,1
    46e8:	00054783          	lbu	a5,0(a0)
    46ec:	fbfd                	bnez	a5,46e2 <strchr+0xc>
      return (char*)s;
  return 0;
    46ee:	4501                	li	a0,0
}
    46f0:	6422                	ld	s0,8(sp)
    46f2:	0141                	addi	sp,sp,16
    46f4:	8082                	ret
  return 0;
    46f6:	4501                	li	a0,0
    46f8:	bfe5                	j	46f0 <strchr+0x1a>

00000000000046fa <gets>:

char*
gets(char *buf, int max)
{
    46fa:	711d                	addi	sp,sp,-96
    46fc:	ec86                	sd	ra,88(sp)
    46fe:	e8a2                	sd	s0,80(sp)
    4700:	e4a6                	sd	s1,72(sp)
    4702:	e0ca                	sd	s2,64(sp)
    4704:	fc4e                	sd	s3,56(sp)
    4706:	f852                	sd	s4,48(sp)
    4708:	f456                	sd	s5,40(sp)
    470a:	f05a                	sd	s6,32(sp)
    470c:	ec5e                	sd	s7,24(sp)
    470e:	1080                	addi	s0,sp,96
    4710:	8baa                	mv	s7,a0
    4712:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4714:	892a                	mv	s2,a0
    4716:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4718:	4aa9                	li	s5,10
    471a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    471c:	89a6                	mv	s3,s1
    471e:	2485                	addiw	s1,s1,1
    4720:	0344d863          	bge	s1,s4,4750 <gets+0x56>
    cc = read(0, &c, 1);
    4724:	4605                	li	a2,1
    4726:	faf40593          	addi	a1,s0,-81
    472a:	4501                	li	a0,0
    472c:	00000097          	auipc	ra,0x0
    4730:	19c080e7          	jalr	412(ra) # 48c8 <read>
    if(cc < 1)
    4734:	00a05e63          	blez	a0,4750 <gets+0x56>
    buf[i++] = c;
    4738:	faf44783          	lbu	a5,-81(s0)
    473c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4740:	01578763          	beq	a5,s5,474e <gets+0x54>
    4744:	0905                	addi	s2,s2,1
    4746:	fd679be3          	bne	a5,s6,471c <gets+0x22>
  for(i=0; i+1 < max; ){
    474a:	89a6                	mv	s3,s1
    474c:	a011                	j	4750 <gets+0x56>
    474e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4750:	99de                	add	s3,s3,s7
    4752:	00098023          	sb	zero,0(s3)
  return buf;
}
    4756:	855e                	mv	a0,s7
    4758:	60e6                	ld	ra,88(sp)
    475a:	6446                	ld	s0,80(sp)
    475c:	64a6                	ld	s1,72(sp)
    475e:	6906                	ld	s2,64(sp)
    4760:	79e2                	ld	s3,56(sp)
    4762:	7a42                	ld	s4,48(sp)
    4764:	7aa2                	ld	s5,40(sp)
    4766:	7b02                	ld	s6,32(sp)
    4768:	6be2                	ld	s7,24(sp)
    476a:	6125                	addi	sp,sp,96
    476c:	8082                	ret

000000000000476e <stat>:

int
stat(const char *n, struct stat *st)
{
    476e:	1101                	addi	sp,sp,-32
    4770:	ec06                	sd	ra,24(sp)
    4772:	e822                	sd	s0,16(sp)
    4774:	e426                	sd	s1,8(sp)
    4776:	e04a                	sd	s2,0(sp)
    4778:	1000                	addi	s0,sp,32
    477a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    477c:	4581                	li	a1,0
    477e:	00000097          	auipc	ra,0x0
    4782:	172080e7          	jalr	370(ra) # 48f0 <open>
  if(fd < 0)
    4786:	02054563          	bltz	a0,47b0 <stat+0x42>
    478a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    478c:	85ca                	mv	a1,s2
    478e:	00000097          	auipc	ra,0x0
    4792:	17a080e7          	jalr	378(ra) # 4908 <fstat>
    4796:	892a                	mv	s2,a0
  close(fd);
    4798:	8526                	mv	a0,s1
    479a:	00000097          	auipc	ra,0x0
    479e:	13e080e7          	jalr	318(ra) # 48d8 <close>
  return r;
}
    47a2:	854a                	mv	a0,s2
    47a4:	60e2                	ld	ra,24(sp)
    47a6:	6442                	ld	s0,16(sp)
    47a8:	64a2                	ld	s1,8(sp)
    47aa:	6902                	ld	s2,0(sp)
    47ac:	6105                	addi	sp,sp,32
    47ae:	8082                	ret
    return -1;
    47b0:	597d                	li	s2,-1
    47b2:	bfc5                	j	47a2 <stat+0x34>

00000000000047b4 <atoi>:

int
atoi(const char *s)
{
    47b4:	1141                	addi	sp,sp,-16
    47b6:	e422                	sd	s0,8(sp)
    47b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    47ba:	00054603          	lbu	a2,0(a0)
    47be:	fd06079b          	addiw	a5,a2,-48
    47c2:	0ff7f793          	andi	a5,a5,255
    47c6:	4725                	li	a4,9
    47c8:	02f76963          	bltu	a4,a5,47fa <atoi+0x46>
    47cc:	86aa                	mv	a3,a0
  n = 0;
    47ce:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    47d0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    47d2:	0685                	addi	a3,a3,1
    47d4:	0025179b          	slliw	a5,a0,0x2
    47d8:	9fa9                	addw	a5,a5,a0
    47da:	0017979b          	slliw	a5,a5,0x1
    47de:	9fb1                	addw	a5,a5,a2
    47e0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    47e4:	0006c603          	lbu	a2,0(a3)
    47e8:	fd06071b          	addiw	a4,a2,-48
    47ec:	0ff77713          	andi	a4,a4,255
    47f0:	fee5f1e3          	bgeu	a1,a4,47d2 <atoi+0x1e>
  return n;
}
    47f4:	6422                	ld	s0,8(sp)
    47f6:	0141                	addi	sp,sp,16
    47f8:	8082                	ret
  n = 0;
    47fa:	4501                	li	a0,0
    47fc:	bfe5                	j	47f4 <atoi+0x40>

00000000000047fe <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    47fe:	1141                	addi	sp,sp,-16
    4800:	e422                	sd	s0,8(sp)
    4802:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4804:	02b57463          	bgeu	a0,a1,482c <memmove+0x2e>
    while(n-- > 0)
    4808:	00c05f63          	blez	a2,4826 <memmove+0x28>
    480c:	1602                	slli	a2,a2,0x20
    480e:	9201                	srli	a2,a2,0x20
    4810:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4814:	872a                	mv	a4,a0
      *dst++ = *src++;
    4816:	0585                	addi	a1,a1,1
    4818:	0705                	addi	a4,a4,1
    481a:	fff5c683          	lbu	a3,-1(a1)
    481e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4822:	fee79ae3          	bne	a5,a4,4816 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4826:	6422                	ld	s0,8(sp)
    4828:	0141                	addi	sp,sp,16
    482a:	8082                	ret
    dst += n;
    482c:	00c50733          	add	a4,a0,a2
    src += n;
    4830:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4832:	fec05ae3          	blez	a2,4826 <memmove+0x28>
    4836:	fff6079b          	addiw	a5,a2,-1
    483a:	1782                	slli	a5,a5,0x20
    483c:	9381                	srli	a5,a5,0x20
    483e:	fff7c793          	not	a5,a5
    4842:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4844:	15fd                	addi	a1,a1,-1
    4846:	177d                	addi	a4,a4,-1
    4848:	0005c683          	lbu	a3,0(a1)
    484c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4850:	fee79ae3          	bne	a5,a4,4844 <memmove+0x46>
    4854:	bfc9                	j	4826 <memmove+0x28>

0000000000004856 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4856:	1141                	addi	sp,sp,-16
    4858:	e422                	sd	s0,8(sp)
    485a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    485c:	ca05                	beqz	a2,488c <memcmp+0x36>
    485e:	fff6069b          	addiw	a3,a2,-1
    4862:	1682                	slli	a3,a3,0x20
    4864:	9281                	srli	a3,a3,0x20
    4866:	0685                	addi	a3,a3,1
    4868:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    486a:	00054783          	lbu	a5,0(a0)
    486e:	0005c703          	lbu	a4,0(a1)
    4872:	00e79863          	bne	a5,a4,4882 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    4876:	0505                	addi	a0,a0,1
    p2++;
    4878:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    487a:	fed518e3          	bne	a0,a3,486a <memcmp+0x14>
  }
  return 0;
    487e:	4501                	li	a0,0
    4880:	a019                	j	4886 <memcmp+0x30>
      return *p1 - *p2;
    4882:	40e7853b          	subw	a0,a5,a4
}
    4886:	6422                	ld	s0,8(sp)
    4888:	0141                	addi	sp,sp,16
    488a:	8082                	ret
  return 0;
    488c:	4501                	li	a0,0
    488e:	bfe5                	j	4886 <memcmp+0x30>

0000000000004890 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4890:	1141                	addi	sp,sp,-16
    4892:	e406                	sd	ra,8(sp)
    4894:	e022                	sd	s0,0(sp)
    4896:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4898:	00000097          	auipc	ra,0x0
    489c:	f66080e7          	jalr	-154(ra) # 47fe <memmove>
}
    48a0:	60a2                	ld	ra,8(sp)
    48a2:	6402                	ld	s0,0(sp)
    48a4:	0141                	addi	sp,sp,16
    48a6:	8082                	ret

00000000000048a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    48a8:	4885                	li	a7,1
 ecall
    48aa:	00000073          	ecall
 ret
    48ae:	8082                	ret

00000000000048b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
    48b0:	4889                	li	a7,2
 ecall
    48b2:	00000073          	ecall
 ret
    48b6:	8082                	ret

00000000000048b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
    48b8:	488d                	li	a7,3
 ecall
    48ba:	00000073          	ecall
 ret
    48be:	8082                	ret

00000000000048c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    48c0:	4891                	li	a7,4
 ecall
    48c2:	00000073          	ecall
 ret
    48c6:	8082                	ret

00000000000048c8 <read>:
.global read
read:
 li a7, SYS_read
    48c8:	4895                	li	a7,5
 ecall
    48ca:	00000073          	ecall
 ret
    48ce:	8082                	ret

00000000000048d0 <write>:
.global write
write:
 li a7, SYS_write
    48d0:	48c1                	li	a7,16
 ecall
    48d2:	00000073          	ecall
 ret
    48d6:	8082                	ret

00000000000048d8 <close>:
.global close
close:
 li a7, SYS_close
    48d8:	48d5                	li	a7,21
 ecall
    48da:	00000073          	ecall
 ret
    48de:	8082                	ret

00000000000048e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
    48e0:	4899                	li	a7,6
 ecall
    48e2:	00000073          	ecall
 ret
    48e6:	8082                	ret

00000000000048e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
    48e8:	489d                	li	a7,7
 ecall
    48ea:	00000073          	ecall
 ret
    48ee:	8082                	ret

00000000000048f0 <open>:
.global open
open:
 li a7, SYS_open
    48f0:	48bd                	li	a7,15
 ecall
    48f2:	00000073          	ecall
 ret
    48f6:	8082                	ret

00000000000048f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    48f8:	48c5                	li	a7,17
 ecall
    48fa:	00000073          	ecall
 ret
    48fe:	8082                	ret

0000000000004900 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4900:	48c9                	li	a7,18
 ecall
    4902:	00000073          	ecall
 ret
    4906:	8082                	ret

0000000000004908 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4908:	48a1                	li	a7,8
 ecall
    490a:	00000073          	ecall
 ret
    490e:	8082                	ret

0000000000004910 <link>:
.global link
link:
 li a7, SYS_link
    4910:	48cd                	li	a7,19
 ecall
    4912:	00000073          	ecall
 ret
    4916:	8082                	ret

0000000000004918 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4918:	48d1                	li	a7,20
 ecall
    491a:	00000073          	ecall
 ret
    491e:	8082                	ret

0000000000004920 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4920:	48a5                	li	a7,9
 ecall
    4922:	00000073          	ecall
 ret
    4926:	8082                	ret

0000000000004928 <dup>:
.global dup
dup:
 li a7, SYS_dup
    4928:	48a9                	li	a7,10
 ecall
    492a:	00000073          	ecall
 ret
    492e:	8082                	ret

0000000000004930 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4930:	48ad                	li	a7,11
 ecall
    4932:	00000073          	ecall
 ret
    4936:	8082                	ret

0000000000004938 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    4938:	48b1                	li	a7,12
 ecall
    493a:	00000073          	ecall
 ret
    493e:	8082                	ret

0000000000004940 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    4940:	48b5                	li	a7,13
 ecall
    4942:	00000073          	ecall
 ret
    4946:	8082                	ret

0000000000004948 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4948:	48b9                	li	a7,14
 ecall
    494a:	00000073          	ecall
 ret
    494e:	8082                	ret

0000000000004950 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
    4950:	48d9                	li	a7,22
 ecall
    4952:	00000073          	ecall
 ret
    4956:	8082                	ret

0000000000004958 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
    4958:	48dd                	li	a7,23
 ecall
    495a:	00000073          	ecall
 ret
    495e:	8082                	ret

0000000000004960 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4960:	1101                	addi	sp,sp,-32
    4962:	ec06                	sd	ra,24(sp)
    4964:	e822                	sd	s0,16(sp)
    4966:	1000                	addi	s0,sp,32
    4968:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    496c:	4605                	li	a2,1
    496e:	fef40593          	addi	a1,s0,-17
    4972:	00000097          	auipc	ra,0x0
    4976:	f5e080e7          	jalr	-162(ra) # 48d0 <write>
}
    497a:	60e2                	ld	ra,24(sp)
    497c:	6442                	ld	s0,16(sp)
    497e:	6105                	addi	sp,sp,32
    4980:	8082                	ret

0000000000004982 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    4982:	7139                	addi	sp,sp,-64
    4984:	fc06                	sd	ra,56(sp)
    4986:	f822                	sd	s0,48(sp)
    4988:	f426                	sd	s1,40(sp)
    498a:	f04a                	sd	s2,32(sp)
    498c:	ec4e                	sd	s3,24(sp)
    498e:	0080                	addi	s0,sp,64
    4990:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    4992:	c299                	beqz	a3,4998 <printint+0x16>
    4994:	0805c863          	bltz	a1,4a24 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    4998:	2581                	sext.w	a1,a1
  neg = 0;
    499a:	4881                	li	a7,0
    499c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    49a0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    49a2:	2601                	sext.w	a2,a2
    49a4:	00002517          	auipc	a0,0x2
    49a8:	63450513          	addi	a0,a0,1588 # 6fd8 <digits>
    49ac:	883a                	mv	a6,a4
    49ae:	2705                	addiw	a4,a4,1
    49b0:	02c5f7bb          	remuw	a5,a1,a2
    49b4:	1782                	slli	a5,a5,0x20
    49b6:	9381                	srli	a5,a5,0x20
    49b8:	97aa                	add	a5,a5,a0
    49ba:	0007c783          	lbu	a5,0(a5)
    49be:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    49c2:	0005879b          	sext.w	a5,a1
    49c6:	02c5d5bb          	divuw	a1,a1,a2
    49ca:	0685                	addi	a3,a3,1
    49cc:	fec7f0e3          	bgeu	a5,a2,49ac <printint+0x2a>
  if(neg)
    49d0:	00088b63          	beqz	a7,49e6 <printint+0x64>
    buf[i++] = '-';
    49d4:	fd040793          	addi	a5,s0,-48
    49d8:	973e                	add	a4,a4,a5
    49da:	02d00793          	li	a5,45
    49de:	fef70823          	sb	a5,-16(a4)
    49e2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    49e6:	02e05863          	blez	a4,4a16 <printint+0x94>
    49ea:	fc040793          	addi	a5,s0,-64
    49ee:	00e78933          	add	s2,a5,a4
    49f2:	fff78993          	addi	s3,a5,-1
    49f6:	99ba                	add	s3,s3,a4
    49f8:	377d                	addiw	a4,a4,-1
    49fa:	1702                	slli	a4,a4,0x20
    49fc:	9301                	srli	a4,a4,0x20
    49fe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    4a02:	fff94583          	lbu	a1,-1(s2)
    4a06:	8526                	mv	a0,s1
    4a08:	00000097          	auipc	ra,0x0
    4a0c:	f58080e7          	jalr	-168(ra) # 4960 <putc>
  while(--i >= 0)
    4a10:	197d                	addi	s2,s2,-1
    4a12:	ff3918e3          	bne	s2,s3,4a02 <printint+0x80>
}
    4a16:	70e2                	ld	ra,56(sp)
    4a18:	7442                	ld	s0,48(sp)
    4a1a:	74a2                	ld	s1,40(sp)
    4a1c:	7902                	ld	s2,32(sp)
    4a1e:	69e2                	ld	s3,24(sp)
    4a20:	6121                	addi	sp,sp,64
    4a22:	8082                	ret
    x = -xx;
    4a24:	40b005bb          	negw	a1,a1
    neg = 1;
    4a28:	4885                	li	a7,1
    x = -xx;
    4a2a:	bf8d                	j	499c <printint+0x1a>

0000000000004a2c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4a2c:	7119                	addi	sp,sp,-128
    4a2e:	fc86                	sd	ra,120(sp)
    4a30:	f8a2                	sd	s0,112(sp)
    4a32:	f4a6                	sd	s1,104(sp)
    4a34:	f0ca                	sd	s2,96(sp)
    4a36:	ecce                	sd	s3,88(sp)
    4a38:	e8d2                	sd	s4,80(sp)
    4a3a:	e4d6                	sd	s5,72(sp)
    4a3c:	e0da                	sd	s6,64(sp)
    4a3e:	fc5e                	sd	s7,56(sp)
    4a40:	f862                	sd	s8,48(sp)
    4a42:	f466                	sd	s9,40(sp)
    4a44:	f06a                	sd	s10,32(sp)
    4a46:	ec6e                	sd	s11,24(sp)
    4a48:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4a4a:	0005c903          	lbu	s2,0(a1)
    4a4e:	18090f63          	beqz	s2,4bec <vprintf+0x1c0>
    4a52:	8aaa                	mv	s5,a0
    4a54:	8b32                	mv	s6,a2
    4a56:	00158493          	addi	s1,a1,1
  state = 0;
    4a5a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    4a5c:	02500a13          	li	s4,37
      if(c == 'd'){
    4a60:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    4a64:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    4a68:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    4a6c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4a70:	00002b97          	auipc	s7,0x2
    4a74:	568b8b93          	addi	s7,s7,1384 # 6fd8 <digits>
    4a78:	a839                	j	4a96 <vprintf+0x6a>
        putc(fd, c);
    4a7a:	85ca                	mv	a1,s2
    4a7c:	8556                	mv	a0,s5
    4a7e:	00000097          	auipc	ra,0x0
    4a82:	ee2080e7          	jalr	-286(ra) # 4960 <putc>
    4a86:	a019                	j	4a8c <vprintf+0x60>
    } else if(state == '%'){
    4a88:	01498f63          	beq	s3,s4,4aa6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    4a8c:	0485                	addi	s1,s1,1
    4a8e:	fff4c903          	lbu	s2,-1(s1)
    4a92:	14090d63          	beqz	s2,4bec <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    4a96:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4a9a:	fe0997e3          	bnez	s3,4a88 <vprintf+0x5c>
      if(c == '%'){
    4a9e:	fd479ee3          	bne	a5,s4,4a7a <vprintf+0x4e>
        state = '%';
    4aa2:	89be                	mv	s3,a5
    4aa4:	b7e5                	j	4a8c <vprintf+0x60>
      if(c == 'd'){
    4aa6:	05878063          	beq	a5,s8,4ae6 <vprintf+0xba>
      } else if(c == 'l') {
    4aaa:	05978c63          	beq	a5,s9,4b02 <vprintf+0xd6>
      } else if(c == 'x') {
    4aae:	07a78863          	beq	a5,s10,4b1e <vprintf+0xf2>
      } else if(c == 'p') {
    4ab2:	09b78463          	beq	a5,s11,4b3a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    4ab6:	07300713          	li	a4,115
    4aba:	0ce78663          	beq	a5,a4,4b86 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    4abe:	06300713          	li	a4,99
    4ac2:	0ee78e63          	beq	a5,a4,4bbe <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    4ac6:	11478863          	beq	a5,s4,4bd6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    4aca:	85d2                	mv	a1,s4
    4acc:	8556                	mv	a0,s5
    4ace:	00000097          	auipc	ra,0x0
    4ad2:	e92080e7          	jalr	-366(ra) # 4960 <putc>
        putc(fd, c);
    4ad6:	85ca                	mv	a1,s2
    4ad8:	8556                	mv	a0,s5
    4ada:	00000097          	auipc	ra,0x0
    4ade:	e86080e7          	jalr	-378(ra) # 4960 <putc>
      }
      state = 0;
    4ae2:	4981                	li	s3,0
    4ae4:	b765                	j	4a8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    4ae6:	008b0913          	addi	s2,s6,8
    4aea:	4685                	li	a3,1
    4aec:	4629                	li	a2,10
    4aee:	000b2583          	lw	a1,0(s6)
    4af2:	8556                	mv	a0,s5
    4af4:	00000097          	auipc	ra,0x0
    4af8:	e8e080e7          	jalr	-370(ra) # 4982 <printint>
    4afc:	8b4a                	mv	s6,s2
      state = 0;
    4afe:	4981                	li	s3,0
    4b00:	b771                	j	4a8c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    4b02:	008b0913          	addi	s2,s6,8
    4b06:	4681                	li	a3,0
    4b08:	4629                	li	a2,10
    4b0a:	000b2583          	lw	a1,0(s6)
    4b0e:	8556                	mv	a0,s5
    4b10:	00000097          	auipc	ra,0x0
    4b14:	e72080e7          	jalr	-398(ra) # 4982 <printint>
    4b18:	8b4a                	mv	s6,s2
      state = 0;
    4b1a:	4981                	li	s3,0
    4b1c:	bf85                	j	4a8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    4b1e:	008b0913          	addi	s2,s6,8
    4b22:	4681                	li	a3,0
    4b24:	4641                	li	a2,16
    4b26:	000b2583          	lw	a1,0(s6)
    4b2a:	8556                	mv	a0,s5
    4b2c:	00000097          	auipc	ra,0x0
    4b30:	e56080e7          	jalr	-426(ra) # 4982 <printint>
    4b34:	8b4a                	mv	s6,s2
      state = 0;
    4b36:	4981                	li	s3,0
    4b38:	bf91                	j	4a8c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    4b3a:	008b0793          	addi	a5,s6,8
    4b3e:	f8f43423          	sd	a5,-120(s0)
    4b42:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    4b46:	03000593          	li	a1,48
    4b4a:	8556                	mv	a0,s5
    4b4c:	00000097          	auipc	ra,0x0
    4b50:	e14080e7          	jalr	-492(ra) # 4960 <putc>
  putc(fd, 'x');
    4b54:	85ea                	mv	a1,s10
    4b56:	8556                	mv	a0,s5
    4b58:	00000097          	auipc	ra,0x0
    4b5c:	e08080e7          	jalr	-504(ra) # 4960 <putc>
    4b60:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    4b62:	03c9d793          	srli	a5,s3,0x3c
    4b66:	97de                	add	a5,a5,s7
    4b68:	0007c583          	lbu	a1,0(a5)
    4b6c:	8556                	mv	a0,s5
    4b6e:	00000097          	auipc	ra,0x0
    4b72:	df2080e7          	jalr	-526(ra) # 4960 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    4b76:	0992                	slli	s3,s3,0x4
    4b78:	397d                	addiw	s2,s2,-1
    4b7a:	fe0914e3          	bnez	s2,4b62 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    4b7e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    4b82:	4981                	li	s3,0
    4b84:	b721                	j	4a8c <vprintf+0x60>
        s = va_arg(ap, char*);
    4b86:	008b0993          	addi	s3,s6,8
    4b8a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    4b8e:	02090163          	beqz	s2,4bb0 <vprintf+0x184>
        while(*s != 0){
    4b92:	00094583          	lbu	a1,0(s2)
    4b96:	c9a1                	beqz	a1,4be6 <vprintf+0x1ba>
          putc(fd, *s);
    4b98:	8556                	mv	a0,s5
    4b9a:	00000097          	auipc	ra,0x0
    4b9e:	dc6080e7          	jalr	-570(ra) # 4960 <putc>
          s++;
    4ba2:	0905                	addi	s2,s2,1
        while(*s != 0){
    4ba4:	00094583          	lbu	a1,0(s2)
    4ba8:	f9e5                	bnez	a1,4b98 <vprintf+0x16c>
        s = va_arg(ap, char*);
    4baa:	8b4e                	mv	s6,s3
      state = 0;
    4bac:	4981                	li	s3,0
    4bae:	bdf9                	j	4a8c <vprintf+0x60>
          s = "(null)";
    4bb0:	00002917          	auipc	s2,0x2
    4bb4:	42090913          	addi	s2,s2,1056 # 6fd0 <malloc+0x22da>
        while(*s != 0){
    4bb8:	02800593          	li	a1,40
    4bbc:	bff1                	j	4b98 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    4bbe:	008b0913          	addi	s2,s6,8
    4bc2:	000b4583          	lbu	a1,0(s6)
    4bc6:	8556                	mv	a0,s5
    4bc8:	00000097          	auipc	ra,0x0
    4bcc:	d98080e7          	jalr	-616(ra) # 4960 <putc>
    4bd0:	8b4a                	mv	s6,s2
      state = 0;
    4bd2:	4981                	li	s3,0
    4bd4:	bd65                	j	4a8c <vprintf+0x60>
        putc(fd, c);
    4bd6:	85d2                	mv	a1,s4
    4bd8:	8556                	mv	a0,s5
    4bda:	00000097          	auipc	ra,0x0
    4bde:	d86080e7          	jalr	-634(ra) # 4960 <putc>
      state = 0;
    4be2:	4981                	li	s3,0
    4be4:	b565                	j	4a8c <vprintf+0x60>
        s = va_arg(ap, char*);
    4be6:	8b4e                	mv	s6,s3
      state = 0;
    4be8:	4981                	li	s3,0
    4bea:	b54d                	j	4a8c <vprintf+0x60>
    }
  }
}
    4bec:	70e6                	ld	ra,120(sp)
    4bee:	7446                	ld	s0,112(sp)
    4bf0:	74a6                	ld	s1,104(sp)
    4bf2:	7906                	ld	s2,96(sp)
    4bf4:	69e6                	ld	s3,88(sp)
    4bf6:	6a46                	ld	s4,80(sp)
    4bf8:	6aa6                	ld	s5,72(sp)
    4bfa:	6b06                	ld	s6,64(sp)
    4bfc:	7be2                	ld	s7,56(sp)
    4bfe:	7c42                	ld	s8,48(sp)
    4c00:	7ca2                	ld	s9,40(sp)
    4c02:	7d02                	ld	s10,32(sp)
    4c04:	6de2                	ld	s11,24(sp)
    4c06:	6109                	addi	sp,sp,128
    4c08:	8082                	ret

0000000000004c0a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    4c0a:	715d                	addi	sp,sp,-80
    4c0c:	ec06                	sd	ra,24(sp)
    4c0e:	e822                	sd	s0,16(sp)
    4c10:	1000                	addi	s0,sp,32
    4c12:	e010                	sd	a2,0(s0)
    4c14:	e414                	sd	a3,8(s0)
    4c16:	e818                	sd	a4,16(s0)
    4c18:	ec1c                	sd	a5,24(s0)
    4c1a:	03043023          	sd	a6,32(s0)
    4c1e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    4c22:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    4c26:	8622                	mv	a2,s0
    4c28:	00000097          	auipc	ra,0x0
    4c2c:	e04080e7          	jalr	-508(ra) # 4a2c <vprintf>
}
    4c30:	60e2                	ld	ra,24(sp)
    4c32:	6442                	ld	s0,16(sp)
    4c34:	6161                	addi	sp,sp,80
    4c36:	8082                	ret

0000000000004c38 <printf>:

void
printf(const char *fmt, ...)
{
    4c38:	711d                	addi	sp,sp,-96
    4c3a:	ec06                	sd	ra,24(sp)
    4c3c:	e822                	sd	s0,16(sp)
    4c3e:	1000                	addi	s0,sp,32
    4c40:	e40c                	sd	a1,8(s0)
    4c42:	e810                	sd	a2,16(s0)
    4c44:	ec14                	sd	a3,24(s0)
    4c46:	f018                	sd	a4,32(s0)
    4c48:	f41c                	sd	a5,40(s0)
    4c4a:	03043823          	sd	a6,48(s0)
    4c4e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    4c52:	00840613          	addi	a2,s0,8
    4c56:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    4c5a:	85aa                	mv	a1,a0
    4c5c:	4505                	li	a0,1
    4c5e:	00000097          	auipc	ra,0x0
    4c62:	dce080e7          	jalr	-562(ra) # 4a2c <vprintf>
}
    4c66:	60e2                	ld	ra,24(sp)
    4c68:	6442                	ld	s0,16(sp)
    4c6a:	6125                	addi	sp,sp,96
    4c6c:	8082                	ret

0000000000004c6e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4c6e:	1141                	addi	sp,sp,-16
    4c70:	e422                	sd	s0,8(sp)
    4c72:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    4c74:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4c78:	00002797          	auipc	a5,0x2
    4c7c:	3907b783          	ld	a5,912(a5) # 7008 <freep>
    4c80:	a805                	j	4cb0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    4c82:	4618                	lw	a4,8(a2)
    4c84:	9db9                	addw	a1,a1,a4
    4c86:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    4c8a:	6398                	ld	a4,0(a5)
    4c8c:	6318                	ld	a4,0(a4)
    4c8e:	fee53823          	sd	a4,-16(a0)
    4c92:	a091                	j	4cd6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    4c94:	ff852703          	lw	a4,-8(a0)
    4c98:	9e39                	addw	a2,a2,a4
    4c9a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    4c9c:	ff053703          	ld	a4,-16(a0)
    4ca0:	e398                	sd	a4,0(a5)
    4ca2:	a099                	j	4ce8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4ca4:	6398                	ld	a4,0(a5)
    4ca6:	00e7e463          	bltu	a5,a4,4cae <free+0x40>
    4caa:	00e6ea63          	bltu	a3,a4,4cbe <free+0x50>
{
    4cae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4cb0:	fed7fae3          	bgeu	a5,a3,4ca4 <free+0x36>
    4cb4:	6398                	ld	a4,0(a5)
    4cb6:	00e6e463          	bltu	a3,a4,4cbe <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    4cba:	fee7eae3          	bltu	a5,a4,4cae <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    4cbe:	ff852583          	lw	a1,-8(a0)
    4cc2:	6390                	ld	a2,0(a5)
    4cc4:	02059713          	slli	a4,a1,0x20
    4cc8:	9301                	srli	a4,a4,0x20
    4cca:	0712                	slli	a4,a4,0x4
    4ccc:	9736                	add	a4,a4,a3
    4cce:	fae60ae3          	beq	a2,a4,4c82 <free+0x14>
    bp->s.ptr = p->s.ptr;
    4cd2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    4cd6:	4790                	lw	a2,8(a5)
    4cd8:	02061713          	slli	a4,a2,0x20
    4cdc:	9301                	srli	a4,a4,0x20
    4cde:	0712                	slli	a4,a4,0x4
    4ce0:	973e                	add	a4,a4,a5
    4ce2:	fae689e3          	beq	a3,a4,4c94 <free+0x26>
  } else
    p->s.ptr = bp;
    4ce6:	e394                	sd	a3,0(a5)
  freep = p;
    4ce8:	00002717          	auipc	a4,0x2
    4cec:	32f73023          	sd	a5,800(a4) # 7008 <freep>
}
    4cf0:	6422                	ld	s0,8(sp)
    4cf2:	0141                	addi	sp,sp,16
    4cf4:	8082                	ret

0000000000004cf6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    4cf6:	7139                	addi	sp,sp,-64
    4cf8:	fc06                	sd	ra,56(sp)
    4cfa:	f822                	sd	s0,48(sp)
    4cfc:	f426                	sd	s1,40(sp)
    4cfe:	f04a                	sd	s2,32(sp)
    4d00:	ec4e                	sd	s3,24(sp)
    4d02:	e852                	sd	s4,16(sp)
    4d04:	e456                	sd	s5,8(sp)
    4d06:	e05a                	sd	s6,0(sp)
    4d08:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4d0a:	02051493          	slli	s1,a0,0x20
    4d0e:	9081                	srli	s1,s1,0x20
    4d10:	04bd                	addi	s1,s1,15
    4d12:	8091                	srli	s1,s1,0x4
    4d14:	0014899b          	addiw	s3,s1,1
    4d18:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    4d1a:	00002517          	auipc	a0,0x2
    4d1e:	2ee53503          	ld	a0,750(a0) # 7008 <freep>
    4d22:	c515                	beqz	a0,4d4e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4d24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4d26:	4798                	lw	a4,8(a5)
    4d28:	02977f63          	bgeu	a4,s1,4d66 <malloc+0x70>
    4d2c:	8a4e                	mv	s4,s3
    4d2e:	0009871b          	sext.w	a4,s3
    4d32:	6685                	lui	a3,0x1
    4d34:	00d77363          	bgeu	a4,a3,4d3a <malloc+0x44>
    4d38:	6a05                	lui	s4,0x1
    4d3a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    4d3e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    4d42:	00002917          	auipc	s2,0x2
    4d46:	2c690913          	addi	s2,s2,710 # 7008 <freep>
  if(p == (char*)-1)
    4d4a:	5afd                	li	s5,-1
    4d4c:	a88d                	j	4dbe <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    4d4e:	00008797          	auipc	a5,0x8
    4d52:	ad278793          	addi	a5,a5,-1326 # c820 <base>
    4d56:	00002717          	auipc	a4,0x2
    4d5a:	2af73923          	sd	a5,690(a4) # 7008 <freep>
    4d5e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    4d60:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    4d64:	b7e1                	j	4d2c <malloc+0x36>
      if(p->s.size == nunits)
    4d66:	02e48b63          	beq	s1,a4,4d9c <malloc+0xa6>
        p->s.size -= nunits;
    4d6a:	4137073b          	subw	a4,a4,s3
    4d6e:	c798                	sw	a4,8(a5)
        p += p->s.size;
    4d70:	1702                	slli	a4,a4,0x20
    4d72:	9301                	srli	a4,a4,0x20
    4d74:	0712                	slli	a4,a4,0x4
    4d76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    4d78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    4d7c:	00002717          	auipc	a4,0x2
    4d80:	28a73623          	sd	a0,652(a4) # 7008 <freep>
      return (void*)(p + 1);
    4d84:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    4d88:	70e2                	ld	ra,56(sp)
    4d8a:	7442                	ld	s0,48(sp)
    4d8c:	74a2                	ld	s1,40(sp)
    4d8e:	7902                	ld	s2,32(sp)
    4d90:	69e2                	ld	s3,24(sp)
    4d92:	6a42                	ld	s4,16(sp)
    4d94:	6aa2                	ld	s5,8(sp)
    4d96:	6b02                	ld	s6,0(sp)
    4d98:	6121                	addi	sp,sp,64
    4d9a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    4d9c:	6398                	ld	a4,0(a5)
    4d9e:	e118                	sd	a4,0(a0)
    4da0:	bff1                	j	4d7c <malloc+0x86>
  hp->s.size = nu;
    4da2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    4da6:	0541                	addi	a0,a0,16
    4da8:	00000097          	auipc	ra,0x0
    4dac:	ec6080e7          	jalr	-314(ra) # 4c6e <free>
  return freep;
    4db0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    4db4:	d971                	beqz	a0,4d88 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4db6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    4db8:	4798                	lw	a4,8(a5)
    4dba:	fa9776e3          	bgeu	a4,s1,4d66 <malloc+0x70>
    if(p == freep)
    4dbe:	00093703          	ld	a4,0(s2)
    4dc2:	853e                	mv	a0,a5
    4dc4:	fef719e3          	bne	a4,a5,4db6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    4dc8:	8552                	mv	a0,s4
    4dca:	00000097          	auipc	ra,0x0
    4dce:	b6e080e7          	jalr	-1170(ra) # 4938 <sbrk>
  if(p == (char*)-1)
    4dd2:	fd5518e3          	bne	a0,s5,4da2 <malloc+0xac>
        return 0;
    4dd6:	4501                	li	a0,0
    4dd8:	bf45                	j	4d88 <malloc+0x92>

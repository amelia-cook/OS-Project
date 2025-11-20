
user/_umalloc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
   6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
   a:	00000797          	auipc	a5,0x0
   e:	7ae7b783          	ld	a5,1966(a5) # 7b8 <freep>
  12:	a805                	j	42 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
  14:	4618                	lw	a4,8(a2)
  16:	9db9                	addw	a1,a1,a4
  18:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
  1c:	6398                	ld	a4,0(a5)
  1e:	6318                	ld	a4,0(a4)
  20:	fee53823          	sd	a4,-16(a0)
  24:	a091                	j	68 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
  26:	ff852703          	lw	a4,-8(a0)
  2a:	9e39                	addw	a2,a2,a4
  2c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
  2e:	ff053703          	ld	a4,-16(a0)
  32:	e398                	sd	a4,0(a5)
  34:	a099                	j	7a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
  36:	6398                	ld	a4,0(a5)
  38:	00e7e463          	bltu	a5,a4,40 <free+0x40>
  3c:	00e6ea63          	bltu	a3,a4,50 <free+0x50>
{
  40:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
  42:	fed7fae3          	bgeu	a5,a3,36 <free+0x36>
  46:	6398                	ld	a4,0(a5)
  48:	00e6e463          	bltu	a3,a4,50 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
  4c:	fee7eae3          	bltu	a5,a4,40 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
  50:	ff852583          	lw	a1,-8(a0)
  54:	6390                	ld	a2,0(a5)
  56:	02059713          	slli	a4,a1,0x20
  5a:	9301                	srli	a4,a4,0x20
  5c:	0712                	slli	a4,a4,0x4
  5e:	9736                	add	a4,a4,a3
  60:	fae60ae3          	beq	a2,a4,14 <free+0x14>
    bp->s.ptr = p->s.ptr;
  64:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
  68:	4790                	lw	a2,8(a5)
  6a:	02061713          	slli	a4,a2,0x20
  6e:	9301                	srli	a4,a4,0x20
  70:	0712                	slli	a4,a4,0x4
  72:	973e                	add	a4,a4,a5
  74:	fae689e3          	beq	a3,a4,26 <free+0x26>
  } else
    p->s.ptr = bp;
  78:	e394                	sd	a3,0(a5)
  freep = p;
  7a:	00000717          	auipc	a4,0x0
  7e:	72f73f23          	sd	a5,1854(a4) # 7b8 <freep>
}
  82:	6422                	ld	s0,8(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
  88:	7139                	addi	sp,sp,-64
  8a:	fc06                	sd	ra,56(sp)
  8c:	f822                	sd	s0,48(sp)
  8e:	f426                	sd	s1,40(sp)
  90:	f04a                	sd	s2,32(sp)
  92:	ec4e                	sd	s3,24(sp)
  94:	e852                	sd	s4,16(sp)
  96:	e456                	sd	s5,8(sp)
  98:	e05a                	sd	s6,0(sp)
  9a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  9c:	02051493          	slli	s1,a0,0x20
  a0:	9081                	srli	s1,s1,0x20
  a2:	04bd                	addi	s1,s1,15
  a4:	8091                	srli	s1,s1,0x4
  a6:	0014899b          	addiw	s3,s1,1
  aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
  ac:	00000517          	auipc	a0,0x0
  b0:	70c53503          	ld	a0,1804(a0) # 7b8 <freep>
  b4:	c515                	beqz	a0,e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
  b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
  b8:	4798                	lw	a4,8(a5)
  ba:	02977f63          	bgeu	a4,s1,f8 <malloc+0x70>
  be:	8a4e                	mv	s4,s3
  c0:	0009871b          	sext.w	a4,s3
  c4:	6685                	lui	a3,0x1
  c6:	00d77363          	bgeu	a4,a3,cc <malloc+0x44>
  ca:	6a05                	lui	s4,0x1
  cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
  d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
  d4:	00000917          	auipc	s2,0x0
  d8:	6e490913          	addi	s2,s2,1764 # 7b8 <freep>
  if(p == (char*)-1)
  dc:	5afd                	li	s5,-1
  de:	a88d                	j	150 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
  e0:	00000797          	auipc	a5,0x0
  e4:	6e078793          	addi	a5,a5,1760 # 7c0 <base>
  e8:	00000717          	auipc	a4,0x0
  ec:	6cf73823          	sd	a5,1744(a4) # 7b8 <freep>
  f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
  f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
  f6:	b7e1                	j	be <malloc+0x36>
      if(p->s.size == nunits)
  f8:	02e48b63          	beq	s1,a4,12e <malloc+0xa6>
        p->s.size -= nunits;
  fc:	4137073b          	subw	a4,a4,s3
 100:	c798                	sw	a4,8(a5)
        p += p->s.size;
 102:	1702                	slli	a4,a4,0x20
 104:	9301                	srli	a4,a4,0x20
 106:	0712                	slli	a4,a4,0x4
 108:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 10a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 10e:	00000717          	auipc	a4,0x0
 112:	6aa73523          	sd	a0,1706(a4) # 7b8 <freep>
      return (void*)(p + 1);
 116:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 11a:	70e2                	ld	ra,56(sp)
 11c:	7442                	ld	s0,48(sp)
 11e:	74a2                	ld	s1,40(sp)
 120:	7902                	ld	s2,32(sp)
 122:	69e2                	ld	s3,24(sp)
 124:	6a42                	ld	s4,16(sp)
 126:	6aa2                	ld	s5,8(sp)
 128:	6b02                	ld	s6,0(sp)
 12a:	6121                	addi	sp,sp,64
 12c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 12e:	6398                	ld	a4,0(a5)
 130:	e118                	sd	a4,0(a0)
 132:	bff1                	j	10e <malloc+0x86>
  hp->s.size = nu;
 134:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 138:	0541                	addi	a0,a0,16
 13a:	00000097          	auipc	ra,0x0
 13e:	ec6080e7          	jalr	-314(ra) # 0 <free>
  return freep;
 142:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 146:	d971                	beqz	a0,11a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 148:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 14a:	4798                	lw	a4,8(a5)
 14c:	fa9776e3          	bgeu	a4,s1,f8 <malloc+0x70>
    if(p == freep)
 150:	00093703          	ld	a4,0(s2)
 154:	853e                	mv	a0,a5
 156:	fef719e3          	bne	a4,a5,148 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 15a:	8552                	mv	a0,s4
 15c:	00000097          	auipc	ra,0x0
 160:	306080e7          	jalr	774(ra) # 462 <sbrk>
  if(p == (char*)-1)
 164:	fd5518e3          	bne	a0,s5,134 <malloc+0xac>
        return 0;
 168:	4501                	li	a0,0
 16a:	bf45                	j	11a <malloc+0x92>

000000000000016c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	addi	a1,a1,1
 176:	0785                	addi	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	addi	a0,a0,1
 19e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	addi	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	4685                	li	a3,1
 1c6:	9e89                	subw	a3,a3,a0
 1c8:	00f6853b          	addw	a0,a3,a5
 1cc:	0785                	addi	a5,a5,1
 1ce:	fff7c703          	lbu	a4,-1(a5)
 1d2:	fb7d                	bnez	a4,1c8 <strlen+0x14>
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	addi	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	slli	a2,a2,0x20
 1ea:	9201                	srli	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	addi	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	addi	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	addi	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	addi	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addiw	s1,s1,1
 24a:	0344d863          	bge	s1,s4,27a <gets+0x56>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	addi	a1,s0,-81
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	19c080e7          	jalr	412(ra) # 3f2 <read>
    if(cc < 1)
 25e:	00a05e63          	blez	a0,27a <gets+0x56>
    buf[i++] = c;
 262:	faf44783          	lbu	a5,-81(s0)
 266:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26a:	01578763          	beq	a5,s5,278 <gets+0x54>
 26e:	0905                	addi	s2,s2,1
 270:	fd679be3          	bne	a5,s6,246 <gets+0x22>
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	a011                	j	27a <gets+0x56>
 278:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27a:	99de                	add	s3,s3,s7
 27c:	00098023          	sb	zero,0(s3)
  return buf;
}
 280:	855e                	mv	a0,s7
 282:	60e6                	ld	ra,88(sp)
 284:	6446                	ld	s0,80(sp)
 286:	64a6                	ld	s1,72(sp)
 288:	6906                	ld	s2,64(sp)
 28a:	79e2                	ld	s3,56(sp)
 28c:	7a42                	ld	s4,48(sp)
 28e:	7aa2                	ld	s5,40(sp)
 290:	7b02                	ld	s6,32(sp)
 292:	6be2                	ld	s7,24(sp)
 294:	6125                	addi	sp,sp,96
 296:	8082                	ret

0000000000000298 <stat>:

int
stat(const char *n, struct stat *st)
{
 298:	1101                	addi	sp,sp,-32
 29a:	ec06                	sd	ra,24(sp)
 29c:	e822                	sd	s0,16(sp)
 29e:	e426                	sd	s1,8(sp)
 2a0:	e04a                	sd	s2,0(sp)
 2a2:	1000                	addi	s0,sp,32
 2a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a6:	4581                	li	a1,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	172080e7          	jalr	370(ra) # 41a <open>
  if(fd < 0)
 2b0:	02054563          	bltz	a0,2da <stat+0x42>
 2b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b6:	85ca                	mv	a1,s2
 2b8:	00000097          	auipc	ra,0x0
 2bc:	17a080e7          	jalr	378(ra) # 432 <fstat>
 2c0:	892a                	mv	s2,a0
  close(fd);
 2c2:	8526                	mv	a0,s1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	13e080e7          	jalr	318(ra) # 402 <close>
  return r;
}
 2cc:	854a                	mv	a0,s2
 2ce:	60e2                	ld	ra,24(sp)
 2d0:	6442                	ld	s0,16(sp)
 2d2:	64a2                	ld	s1,8(sp)
 2d4:	6902                	ld	s2,0(sp)
 2d6:	6105                	addi	sp,sp,32
 2d8:	8082                	ret
    return -1;
 2da:	597d                	li	s2,-1
 2dc:	bfc5                	j	2cc <stat+0x34>

00000000000002de <atoi>:

int
atoi(const char *s)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e4:	00054603          	lbu	a2,0(a0)
 2e8:	fd06079b          	addiw	a5,a2,-48
 2ec:	0ff7f793          	andi	a5,a5,255
 2f0:	4725                	li	a4,9
 2f2:	02f76963          	bltu	a4,a5,324 <atoi+0x46>
 2f6:	86aa                	mv	a3,a0
  n = 0;
 2f8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2fa:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2fc:	0685                	addi	a3,a3,1
 2fe:	0025179b          	slliw	a5,a0,0x2
 302:	9fa9                	addw	a5,a5,a0
 304:	0017979b          	slliw	a5,a5,0x1
 308:	9fb1                	addw	a5,a5,a2
 30a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30e:	0006c603          	lbu	a2,0(a3) # 1000 <__global_pointer$+0x4f>
 312:	fd06071b          	addiw	a4,a2,-48
 316:	0ff77713          	andi	a4,a4,255
 31a:	fee5f1e3          	bgeu	a1,a4,2fc <atoi+0x1e>
  return n;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  n = 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <atoi+0x40>

0000000000000328 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32e:	02b57463          	bgeu	a0,a1,356 <memmove+0x2e>
    while(n-- > 0)
 332:	00c05f63          	blez	a2,350 <memmove+0x28>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33e:	872a                	mv	a4,a0
      *dst++ = *src++;
 340:	0585                	addi	a1,a1,1
 342:	0705                	addi	a4,a4,1
 344:	fff5c683          	lbu	a3,-1(a1)
 348:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
    dst += n;
 356:	00c50733          	add	a4,a0,a2
    src += n;
 35a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35c:	fec05ae3          	blez	a2,350 <memmove+0x28>
 360:	fff6079b          	addiw	a5,a2,-1
 364:	1782                	slli	a5,a5,0x20
 366:	9381                	srli	a5,a5,0x20
 368:	fff7c793          	not	a5,a5
 36c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36e:	15fd                	addi	a1,a1,-1
 370:	177d                	addi	a4,a4,-1
 372:	0005c683          	lbu	a3,0(a1)
 376:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37a:	fee79ae3          	bne	a5,a4,36e <memmove+0x46>
 37e:	bfc9                	j	350 <memmove+0x28>

0000000000000380 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 386:	ca05                	beqz	a2,3b6 <memcmp+0x36>
 388:	fff6069b          	addiw	a3,a2,-1
 38c:	1682                	slli	a3,a3,0x20
 38e:	9281                	srli	a3,a3,0x20
 390:	0685                	addi	a3,a3,1
 392:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 394:	00054783          	lbu	a5,0(a0)
 398:	0005c703          	lbu	a4,0(a1)
 39c:	00e79863          	bne	a5,a4,3ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a0:	0505                	addi	a0,a0,1
    p2++;
 3a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a4:	fed518e3          	bne	a0,a3,394 <memcmp+0x14>
  }
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	a019                	j	3b0 <memcmp+0x30>
      return *p1 - *p2;
 3ac:	40e7853b          	subw	a0,a5,a4
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <memcmp+0x30>

00000000000003ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c2:	00000097          	auipc	ra,0x0
 3c6:	f66080e7          	jalr	-154(ra) # 328 <memmove>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d2:	4885                	li	a7,1
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exit>:
.global exit
exit:
 li a7, SYS_exit
 3da:	4889                	li	a7,2
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e2:	488d                	li	a7,3
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ea:	4891                	li	a7,4
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <read>:
.global read
read:
 li a7, SYS_read
 3f2:	4895                	li	a7,5
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <write>:
.global write
write:
 li a7, SYS_write
 3fa:	48c1                	li	a7,16
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <close>:
.global close
close:
 li a7, SYS_close
 402:	48d5                	li	a7,21
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <kill>:
.global kill
kill:
 li a7, SYS_kill
 40a:	4899                	li	a7,6
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exec>:
.global exec
exec:
 li a7, SYS_exec
 412:	489d                	li	a7,7
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <open>:
.global open
open:
 li a7, SYS_open
 41a:	48bd                	li	a7,15
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 422:	48c5                	li	a7,17
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42a:	48c9                	li	a7,18
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 432:	48a1                	li	a7,8
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <link>:
.global link
link:
 li a7, SYS_link
 43a:	48cd                	li	a7,19
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 442:	48d1                	li	a7,20
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44a:	48a5                	li	a7,9
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <dup>:
.global dup
dup:
 li a7, SYS_dup
 452:	48a9                	li	a7,10
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45a:	48ad                	li	a7,11
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 462:	48b1                	li	a7,12
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46a:	48b5                	li	a7,13
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 472:	48b9                	li	a7,14
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 47a:	48d9                	li	a7,22
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <nfree>:
.global nfree
nfree:
 li a7, SYS_nfree
 482:	48dd                	li	a7,23
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48a:	1101                	addi	sp,sp,-32
 48c:	ec06                	sd	ra,24(sp)
 48e:	e822                	sd	s0,16(sp)
 490:	1000                	addi	s0,sp,32
 492:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 496:	4605                	li	a2,1
 498:	fef40593          	addi	a1,s0,-17
 49c:	00000097          	auipc	ra,0x0
 4a0:	f5e080e7          	jalr	-162(ra) # 3fa <write>
}
 4a4:	60e2                	ld	ra,24(sp)
 4a6:	6442                	ld	s0,16(sp)
 4a8:	6105                	addi	sp,sp,32
 4aa:	8082                	ret

00000000000004ac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ac:	7139                	addi	sp,sp,-64
 4ae:	fc06                	sd	ra,56(sp)
 4b0:	f822                	sd	s0,48(sp)
 4b2:	f426                	sd	s1,40(sp)
 4b4:	f04a                	sd	s2,32(sp)
 4b6:	ec4e                	sd	s3,24(sp)
 4b8:	0080                	addi	s0,sp,64
 4ba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4bc:	c299                	beqz	a3,4c2 <printint+0x16>
 4be:	0805c863          	bltz	a1,54e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c2:	2581                	sext.w	a1,a1
  neg = 0;
 4c4:	4881                	li	a7,0
 4c6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ca:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4cc:	2601                	sext.w	a2,a2
 4ce:	00000517          	auipc	a0,0x0
 4d2:	2d250513          	addi	a0,a0,722 # 7a0 <digits>
 4d6:	883a                	mv	a6,a4
 4d8:	2705                	addiw	a4,a4,1
 4da:	02c5f7bb          	remuw	a5,a1,a2
 4de:	1782                	slli	a5,a5,0x20
 4e0:	9381                	srli	a5,a5,0x20
 4e2:	97aa                	add	a5,a5,a0
 4e4:	0007c783          	lbu	a5,0(a5)
 4e8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ec:	0005879b          	sext.w	a5,a1
 4f0:	02c5d5bb          	divuw	a1,a1,a2
 4f4:	0685                	addi	a3,a3,1
 4f6:	fec7f0e3          	bgeu	a5,a2,4d6 <printint+0x2a>
  if(neg)
 4fa:	00088b63          	beqz	a7,510 <printint+0x64>
    buf[i++] = '-';
 4fe:	fd040793          	addi	a5,s0,-48
 502:	973e                	add	a4,a4,a5
 504:	02d00793          	li	a5,45
 508:	fef70823          	sb	a5,-16(a4)
 50c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 510:	02e05863          	blez	a4,540 <printint+0x94>
 514:	fc040793          	addi	a5,s0,-64
 518:	00e78933          	add	s2,a5,a4
 51c:	fff78993          	addi	s3,a5,-1
 520:	99ba                	add	s3,s3,a4
 522:	377d                	addiw	a4,a4,-1
 524:	1702                	slli	a4,a4,0x20
 526:	9301                	srli	a4,a4,0x20
 528:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 52c:	fff94583          	lbu	a1,-1(s2)
 530:	8526                	mv	a0,s1
 532:	00000097          	auipc	ra,0x0
 536:	f58080e7          	jalr	-168(ra) # 48a <putc>
  while(--i >= 0)
 53a:	197d                	addi	s2,s2,-1
 53c:	ff3918e3          	bne	s2,s3,52c <printint+0x80>
}
 540:	70e2                	ld	ra,56(sp)
 542:	7442                	ld	s0,48(sp)
 544:	74a2                	ld	s1,40(sp)
 546:	7902                	ld	s2,32(sp)
 548:	69e2                	ld	s3,24(sp)
 54a:	6121                	addi	sp,sp,64
 54c:	8082                	ret
    x = -xx;
 54e:	40b005bb          	negw	a1,a1
    neg = 1;
 552:	4885                	li	a7,1
    x = -xx;
 554:	bf8d                	j	4c6 <printint+0x1a>

0000000000000556 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 556:	7119                	addi	sp,sp,-128
 558:	fc86                	sd	ra,120(sp)
 55a:	f8a2                	sd	s0,112(sp)
 55c:	f4a6                	sd	s1,104(sp)
 55e:	f0ca                	sd	s2,96(sp)
 560:	ecce                	sd	s3,88(sp)
 562:	e8d2                	sd	s4,80(sp)
 564:	e4d6                	sd	s5,72(sp)
 566:	e0da                	sd	s6,64(sp)
 568:	fc5e                	sd	s7,56(sp)
 56a:	f862                	sd	s8,48(sp)
 56c:	f466                	sd	s9,40(sp)
 56e:	f06a                	sd	s10,32(sp)
 570:	ec6e                	sd	s11,24(sp)
 572:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 574:	0005c903          	lbu	s2,0(a1)
 578:	18090f63          	beqz	s2,716 <vprintf+0x1c0>
 57c:	8aaa                	mv	s5,a0
 57e:	8b32                	mv	s6,a2
 580:	00158493          	addi	s1,a1,1
  state = 0;
 584:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 586:	02500a13          	li	s4,37
      if(c == 'd'){
 58a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 58e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 592:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 596:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 59a:	00000b97          	auipc	s7,0x0
 59e:	206b8b93          	addi	s7,s7,518 # 7a0 <digits>
 5a2:	a839                	j	5c0 <vprintf+0x6a>
        putc(fd, c);
 5a4:	85ca                	mv	a1,s2
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ee2080e7          	jalr	-286(ra) # 48a <putc>
 5b0:	a019                	j	5b6 <vprintf+0x60>
    } else if(state == '%'){
 5b2:	01498f63          	beq	s3,s4,5d0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5b6:	0485                	addi	s1,s1,1
 5b8:	fff4c903          	lbu	s2,-1(s1)
 5bc:	14090d63          	beqz	s2,716 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5c0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5c4:	fe0997e3          	bnez	s3,5b2 <vprintf+0x5c>
      if(c == '%'){
 5c8:	fd479ee3          	bne	a5,s4,5a4 <vprintf+0x4e>
        state = '%';
 5cc:	89be                	mv	s3,a5
 5ce:	b7e5                	j	5b6 <vprintf+0x60>
      if(c == 'd'){
 5d0:	05878063          	beq	a5,s8,610 <vprintf+0xba>
      } else if(c == 'l') {
 5d4:	05978c63          	beq	a5,s9,62c <vprintf+0xd6>
      } else if(c == 'x') {
 5d8:	07a78863          	beq	a5,s10,648 <vprintf+0xf2>
      } else if(c == 'p') {
 5dc:	09b78463          	beq	a5,s11,664 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5e0:	07300713          	li	a4,115
 5e4:	0ce78663          	beq	a5,a4,6b0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5e8:	06300713          	li	a4,99
 5ec:	0ee78e63          	beq	a5,a4,6e8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5f0:	11478863          	beq	a5,s4,700 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5f4:	85d2                	mv	a1,s4
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e92080e7          	jalr	-366(ra) # 48a <putc>
        putc(fd, c);
 600:	85ca                	mv	a1,s2
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e86080e7          	jalr	-378(ra) # 48a <putc>
      }
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b765                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 610:	008b0913          	addi	s2,s6,8
 614:	4685                	li	a3,1
 616:	4629                	li	a2,10
 618:	000b2583          	lw	a1,0(s6)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e8e080e7          	jalr	-370(ra) # 4ac <printint>
 626:	8b4a                	mv	s6,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b771                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	008b0913          	addi	s2,s6,8
 630:	4681                	li	a3,0
 632:	4629                	li	a2,10
 634:	000b2583          	lw	a1,0(s6)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e72080e7          	jalr	-398(ra) # 4ac <printint>
 642:	8b4a                	mv	s6,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	bf85                	j	5b6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 648:	008b0913          	addi	s2,s6,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000b2583          	lw	a1,0(s6)
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	e56080e7          	jalr	-426(ra) # 4ac <printint>
 65e:	8b4a                	mv	s6,s2
      state = 0;
 660:	4981                	li	s3,0
 662:	bf91                	j	5b6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 664:	008b0793          	addi	a5,s6,8
 668:	f8f43423          	sd	a5,-120(s0)
 66c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 670:	03000593          	li	a1,48
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e14080e7          	jalr	-492(ra) # 48a <putc>
  putc(fd, 'x');
 67e:	85ea                	mv	a1,s10
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e08080e7          	jalr	-504(ra) # 48a <putc>
 68a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68c:	03c9d793          	srli	a5,s3,0x3c
 690:	97de                	add	a5,a5,s7
 692:	0007c583          	lbu	a1,0(a5)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	df2080e7          	jalr	-526(ra) # 48a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a0:	0992                	slli	s3,s3,0x4
 6a2:	397d                	addiw	s2,s2,-1
 6a4:	fe0914e3          	bnez	s2,68c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6a8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b721                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6b0:	008b0993          	addi	s3,s6,8
 6b4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6b8:	02090163          	beqz	s2,6da <vprintf+0x184>
        while(*s != 0){
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	c9a1                	beqz	a1,710 <vprintf+0x1ba>
          putc(fd, *s);
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	dc6080e7          	jalr	-570(ra) # 48a <putc>
          s++;
 6cc:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ce:	00094583          	lbu	a1,0(s2)
 6d2:	f9e5                	bnez	a1,6c2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6d4:	8b4e                	mv	s6,s3
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bdf9                	j	5b6 <vprintf+0x60>
          s = "(null)";
 6da:	00000917          	auipc	s2,0x0
 6de:	0be90913          	addi	s2,s2,190 # 798 <printf+0x36>
        while(*s != 0){
 6e2:	02800593          	li	a1,40
 6e6:	bff1                	j	6c2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6e8:	008b0913          	addi	s2,s6,8
 6ec:	000b4583          	lbu	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d98080e7          	jalr	-616(ra) # 48a <putc>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bd65                	j	5b6 <vprintf+0x60>
        putc(fd, c);
 700:	85d2                	mv	a1,s4
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	d86080e7          	jalr	-634(ra) # 48a <putc>
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b565                	j	5b6 <vprintf+0x60>
        s = va_arg(ap, char*);
 710:	8b4e                	mv	s6,s3
      state = 0;
 712:	4981                	li	s3,0
 714:	b54d                	j	5b6 <vprintf+0x60>
    }
  }
}
 716:	70e6                	ld	ra,120(sp)
 718:	7446                	ld	s0,112(sp)
 71a:	74a6                	ld	s1,104(sp)
 71c:	7906                	ld	s2,96(sp)
 71e:	69e6                	ld	s3,88(sp)
 720:	6a46                	ld	s4,80(sp)
 722:	6aa6                	ld	s5,72(sp)
 724:	6b06                	ld	s6,64(sp)
 726:	7be2                	ld	s7,56(sp)
 728:	7c42                	ld	s8,48(sp)
 72a:	7ca2                	ld	s9,40(sp)
 72c:	7d02                	ld	s10,32(sp)
 72e:	6de2                	ld	s11,24(sp)
 730:	6109                	addi	sp,sp,128
 732:	8082                	ret

0000000000000734 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 734:	715d                	addi	sp,sp,-80
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e010                	sd	a2,0(s0)
 73e:	e414                	sd	a3,8(s0)
 740:	e818                	sd	a4,16(s0)
 742:	ec1c                	sd	a5,24(s0)
 744:	03043023          	sd	a6,32(s0)
 748:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 750:	8622                	mv	a2,s0
 752:	00000097          	auipc	ra,0x0
 756:	e04080e7          	jalr	-508(ra) # 556 <vprintf>
}
 75a:	60e2                	ld	ra,24(sp)
 75c:	6442                	ld	s0,16(sp)
 75e:	6161                	addi	sp,sp,80
 760:	8082                	ret

0000000000000762 <printf>:

void
printf(const char *fmt, ...)
{
 762:	711d                	addi	sp,sp,-96
 764:	ec06                	sd	ra,24(sp)
 766:	e822                	sd	s0,16(sp)
 768:	1000                	addi	s0,sp,32
 76a:	e40c                	sd	a1,8(s0)
 76c:	e810                	sd	a2,16(s0)
 76e:	ec14                	sd	a3,24(s0)
 770:	f018                	sd	a4,32(s0)
 772:	f41c                	sd	a5,40(s0)
 774:	03043823          	sd	a6,48(s0)
 778:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	00840613          	addi	a2,s0,8
 780:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 784:	85aa                	mv	a1,a0
 786:	4505                	li	a0,1
 788:	00000097          	auipc	ra,0x0
 78c:	dce080e7          	jalr	-562(ra) # 556 <vprintf>
}
 790:	60e2                	ld	ra,24(sp)
 792:	6442                	ld	s0,16(sp)
 794:	6125                	addi	sp,sp,96
 796:	8082                	ret

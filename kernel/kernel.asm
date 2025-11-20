
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	09010113          	addi	sp,sp,144 # 80009090 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	efe70713          	addi	a4,a4,-258 # 80008f50 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	cfc78793          	addi	a5,a5,-772 # 80005d60 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc830f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	f9a78793          	addi	a5,a5,-102 # 80001048 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    80000102:	7159                	addi	sp,sp,-112
    80000104:	f486                	sd	ra,104(sp)
    80000106:	f0a2                	sd	s0,96(sp)
    80000108:	eca6                	sd	s1,88(sp)
    8000010a:	e8ca                	sd	s2,80(sp)
    8000010c:	e4ce                	sd	s3,72(sp)
    8000010e:	e0d2                	sd	s4,64(sp)
    80000110:	fc56                	sd	s5,56(sp)
    80000112:	f85a                	sd	s6,48(sp)
    80000114:	f45e                	sd	s7,40(sp)
    80000116:	f062                	sd	s8,32(sp)
    80000118:	ec66                	sd	s9,24(sp)
    8000011a:	e86a                	sd	s10,16(sp)
    8000011c:	1880                	addi	s0,sp,112
    8000011e:	8aae                	mv	s5,a1
    80000120:	8a32                	mv	s4,a2
    80000122:	89b6                	mv	s3,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000124:	00068b1b          	sext.w	s6,a3
  acquire(&cons.lock);
    80000128:	00011517          	auipc	a0,0x11
    8000012c:	f6850513          	addi	a0,a0,-152 # 80011090 <cons>
    80000130:	00001097          	auipc	ra,0x1
    80000134:	a62080e7          	jalr	-1438(ra) # 80000b92 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000138:	00011497          	auipc	s1,0x11
    8000013c:	f5848493          	addi	s1,s1,-168 # 80011090 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000140:	00011917          	auipc	s2,0x11
    80000144:	ff090913          	addi	s2,s2,-16 # 80011130 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000148:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000014a:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000014c:	4ca9                	li	s9,10
  while(n > 0){
    8000014e:	07305863          	blez	s3,800001be <consoleread+0xbc>
    while(cons.r == cons.w){
    80000152:	0a04a783          	lw	a5,160(s1)
    80000156:	0a44a703          	lw	a4,164(s1)
    8000015a:	02f71463          	bne	a4,a5,80000182 <consoleread+0x80>
      if(myproc()->killed){
    8000015e:	00002097          	auipc	ra,0x2
    80000162:	9ea080e7          	jalr	-1558(ra) # 80001b48 <myproc>
    80000166:	5d1c                	lw	a5,56(a0)
    80000168:	e7b5                	bnez	a5,800001d4 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    8000016a:	85a6                	mv	a1,s1
    8000016c:	854a                	mv	a0,s2
    8000016e:	00002097          	auipc	ra,0x2
    80000172:	1ea080e7          	jalr	490(ra) # 80002358 <sleep>
    while(cons.r == cons.w){
    80000176:	0a04a783          	lw	a5,160(s1)
    8000017a:	0a44a703          	lw	a4,164(s1)
    8000017e:	fef700e3          	beq	a4,a5,8000015e <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000182:	0017871b          	addiw	a4,a5,1
    80000186:	0ae4a023          	sw	a4,160(s1)
    8000018a:	07f7f713          	andi	a4,a5,127
    8000018e:	9726                	add	a4,a4,s1
    80000190:	02074703          	lbu	a4,32(a4)
    80000194:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000198:	077d0563          	beq	s10,s7,80000202 <consoleread+0x100>
    cbuf = c;
    8000019c:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a0:	4685                	li	a3,1
    800001a2:	f9f40613          	addi	a2,s0,-97
    800001a6:	85d2                	mv	a1,s4
    800001a8:	8556                	mv	a0,s5
    800001aa:	00002097          	auipc	ra,0x2
    800001ae:	424080e7          	jalr	1060(ra) # 800025ce <either_copyout>
    800001b2:	01850663          	beq	a0,s8,800001be <consoleread+0xbc>
    dst++;
    800001b6:	0a05                	addi	s4,s4,1
    --n;
    800001b8:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800001ba:	f99d1ae3          	bne	s10,s9,8000014e <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001be:	00011517          	auipc	a0,0x11
    800001c2:	ed250513          	addi	a0,a0,-302 # 80011090 <cons>
    800001c6:	00001097          	auipc	ra,0x1
    800001ca:	a9c080e7          	jalr	-1380(ra) # 80000c62 <release>

  return target - n;
    800001ce:	413b053b          	subw	a0,s6,s3
    800001d2:	a811                	j	800001e6 <consoleread+0xe4>
        release(&cons.lock);
    800001d4:	00011517          	auipc	a0,0x11
    800001d8:	ebc50513          	addi	a0,a0,-324 # 80011090 <cons>
    800001dc:	00001097          	auipc	ra,0x1
    800001e0:	a86080e7          	jalr	-1402(ra) # 80000c62 <release>
        return -1;
    800001e4:	557d                	li	a0,-1
}
    800001e6:	70a6                	ld	ra,104(sp)
    800001e8:	7406                	ld	s0,96(sp)
    800001ea:	64e6                	ld	s1,88(sp)
    800001ec:	6946                	ld	s2,80(sp)
    800001ee:	69a6                	ld	s3,72(sp)
    800001f0:	6a06                	ld	s4,64(sp)
    800001f2:	7ae2                	ld	s5,56(sp)
    800001f4:	7b42                	ld	s6,48(sp)
    800001f6:	7ba2                	ld	s7,40(sp)
    800001f8:	7c02                	ld	s8,32(sp)
    800001fa:	6ce2                	ld	s9,24(sp)
    800001fc:	6d42                	ld	s10,16(sp)
    800001fe:	6165                	addi	sp,sp,112
    80000200:	8082                	ret
      if(n < target){
    80000202:	0009871b          	sext.w	a4,s3
    80000206:	fb677ce3          	bgeu	a4,s6,800001be <consoleread+0xbc>
        cons.r--;
    8000020a:	00011717          	auipc	a4,0x11
    8000020e:	f2f72323          	sw	a5,-218(a4) # 80011130 <cons+0xa0>
    80000212:	b775                	j	800001be <consoleread+0xbc>

0000000080000214 <consputc>:
  if(panicked){
    80000214:	00009797          	auipc	a5,0x9
    80000218:	cec7a783          	lw	a5,-788(a5) # 80008f00 <panicked>
    8000021c:	c391                	beqz	a5,80000220 <consputc+0xc>
    for(;;)
    8000021e:	a001                	j	8000021e <consputc+0xa>
{
    80000220:	1141                	addi	sp,sp,-16
    80000222:	e406                	sd	ra,8(sp)
    80000224:	e022                	sd	s0,0(sp)
    80000226:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000228:	10000793          	li	a5,256
    8000022c:	00f50a63          	beq	a0,a5,80000240 <consputc+0x2c>
    uartputc(c);
    80000230:	00000097          	auipc	ra,0x0
    80000234:	692080e7          	jalr	1682(ra) # 800008c2 <uartputc>
}
    80000238:	60a2                	ld	ra,8(sp)
    8000023a:	6402                	ld	s0,0(sp)
    8000023c:	0141                	addi	sp,sp,16
    8000023e:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000240:	4521                	li	a0,8
    80000242:	00000097          	auipc	ra,0x0
    80000246:	680080e7          	jalr	1664(ra) # 800008c2 <uartputc>
    8000024a:	02000513          	li	a0,32
    8000024e:	00000097          	auipc	ra,0x0
    80000252:	674080e7          	jalr	1652(ra) # 800008c2 <uartputc>
    80000256:	4521                	li	a0,8
    80000258:	00000097          	auipc	ra,0x0
    8000025c:	66a080e7          	jalr	1642(ra) # 800008c2 <uartputc>
    80000260:	bfe1                	j	80000238 <consputc+0x24>

0000000080000262 <consolewrite>:
{
    80000262:	715d                	addi	sp,sp,-80
    80000264:	e486                	sd	ra,72(sp)
    80000266:	e0a2                	sd	s0,64(sp)
    80000268:	fc26                	sd	s1,56(sp)
    8000026a:	f84a                	sd	s2,48(sp)
    8000026c:	f44e                	sd	s3,40(sp)
    8000026e:	f052                	sd	s4,32(sp)
    80000270:	ec56                	sd	s5,24(sp)
    80000272:	0880                	addi	s0,sp,80
    80000274:	8a2e                	mv	s4,a1
    80000276:	84b2                	mv	s1,a2
    80000278:	89b6                	mv	s3,a3
  acquire(&cons.lock);
    8000027a:	00011517          	auipc	a0,0x11
    8000027e:	e1650513          	addi	a0,a0,-490 # 80011090 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	910080e7          	jalr	-1776(ra) # 80000b92 <acquire>
  for(i = 0; i < n; i++){
    8000028a:	05305b63          	blez	s3,800002e0 <consolewrite+0x7e>
    8000028e:	4901                	li	s2,0
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000290:	5afd                	li	s5,-1
    80000292:	4685                	li	a3,1
    80000294:	8626                	mv	a2,s1
    80000296:	85d2                	mv	a1,s4
    80000298:	fbf40513          	addi	a0,s0,-65
    8000029c:	00002097          	auipc	ra,0x2
    800002a0:	388080e7          	jalr	904(ra) # 80002624 <either_copyin>
    800002a4:	01550c63          	beq	a0,s5,800002bc <consolewrite+0x5a>
    consputc(c);
    800002a8:	fbf44503          	lbu	a0,-65(s0)
    800002ac:	00000097          	auipc	ra,0x0
    800002b0:	f68080e7          	jalr	-152(ra) # 80000214 <consputc>
  for(i = 0; i < n; i++){
    800002b4:	2905                	addiw	s2,s2,1
    800002b6:	0485                	addi	s1,s1,1
    800002b8:	fd299de3          	bne	s3,s2,80000292 <consolewrite+0x30>
  release(&cons.lock);
    800002bc:	00011517          	auipc	a0,0x11
    800002c0:	dd450513          	addi	a0,a0,-556 # 80011090 <cons>
    800002c4:	00001097          	auipc	ra,0x1
    800002c8:	99e080e7          	jalr	-1634(ra) # 80000c62 <release>
}
    800002cc:	854a                	mv	a0,s2
    800002ce:	60a6                	ld	ra,72(sp)
    800002d0:	6406                	ld	s0,64(sp)
    800002d2:	74e2                	ld	s1,56(sp)
    800002d4:	7942                	ld	s2,48(sp)
    800002d6:	79a2                	ld	s3,40(sp)
    800002d8:	7a02                	ld	s4,32(sp)
    800002da:	6ae2                	ld	s5,24(sp)
    800002dc:	6161                	addi	sp,sp,80
    800002de:	8082                	ret
  for(i = 0; i < n; i++){
    800002e0:	4901                	li	s2,0
    800002e2:	bfe9                	j	800002bc <consolewrite+0x5a>

00000000800002e4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002e4:	1101                	addi	sp,sp,-32
    800002e6:	ec06                	sd	ra,24(sp)
    800002e8:	e822                	sd	s0,16(sp)
    800002ea:	e426                	sd	s1,8(sp)
    800002ec:	e04a                	sd	s2,0(sp)
    800002ee:	1000                	addi	s0,sp,32
    800002f0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002f2:	00011517          	auipc	a0,0x11
    800002f6:	d9e50513          	addi	a0,a0,-610 # 80011090 <cons>
    800002fa:	00001097          	auipc	ra,0x1
    800002fe:	898080e7          	jalr	-1896(ra) # 80000b92 <acquire>

  switch(c){
    80000302:	47d5                	li	a5,21
    80000304:	0af48663          	beq	s1,a5,800003b0 <consoleintr+0xcc>
    80000308:	0297ca63          	blt	a5,s1,8000033c <consoleintr+0x58>
    8000030c:	47a1                	li	a5,8
    8000030e:	0ef48763          	beq	s1,a5,800003fc <consoleintr+0x118>
    80000312:	47c1                	li	a5,16
    80000314:	10f49a63          	bne	s1,a5,80000428 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000318:	00002097          	auipc	ra,0x2
    8000031c:	362080e7          	jalr	866(ra) # 8000267a <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000320:	00011517          	auipc	a0,0x11
    80000324:	d7050513          	addi	a0,a0,-656 # 80011090 <cons>
    80000328:	00001097          	auipc	ra,0x1
    8000032c:	93a080e7          	jalr	-1734(ra) # 80000c62 <release>
}
    80000330:	60e2                	ld	ra,24(sp)
    80000332:	6442                	ld	s0,16(sp)
    80000334:	64a2                	ld	s1,8(sp)
    80000336:	6902                	ld	s2,0(sp)
    80000338:	6105                	addi	sp,sp,32
    8000033a:	8082                	ret
  switch(c){
    8000033c:	07f00793          	li	a5,127
    80000340:	0af48e63          	beq	s1,a5,800003fc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000344:	00011717          	auipc	a4,0x11
    80000348:	d4c70713          	addi	a4,a4,-692 # 80011090 <cons>
    8000034c:	0a872783          	lw	a5,168(a4)
    80000350:	0a072703          	lw	a4,160(a4)
    80000354:	9f99                	subw	a5,a5,a4
    80000356:	07f00713          	li	a4,127
    8000035a:	fcf763e3          	bltu	a4,a5,80000320 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000035e:	47b5                	li	a5,13
    80000360:	0cf48763          	beq	s1,a5,8000042e <consoleintr+0x14a>
      consputc(c);
    80000364:	8526                	mv	a0,s1
    80000366:	00000097          	auipc	ra,0x0
    8000036a:	eae080e7          	jalr	-338(ra) # 80000214 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000036e:	00011797          	auipc	a5,0x11
    80000372:	d2278793          	addi	a5,a5,-734 # 80011090 <cons>
    80000376:	0a87a703          	lw	a4,168(a5)
    8000037a:	0017069b          	addiw	a3,a4,1
    8000037e:	0006861b          	sext.w	a2,a3
    80000382:	0ad7a423          	sw	a3,168(a5)
    80000386:	07f77713          	andi	a4,a4,127
    8000038a:	97ba                	add	a5,a5,a4
    8000038c:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000390:	47a9                	li	a5,10
    80000392:	0cf48563          	beq	s1,a5,8000045c <consoleintr+0x178>
    80000396:	4791                	li	a5,4
    80000398:	0cf48263          	beq	s1,a5,8000045c <consoleintr+0x178>
    8000039c:	00011797          	auipc	a5,0x11
    800003a0:	d947a783          	lw	a5,-620(a5) # 80011130 <cons+0xa0>
    800003a4:	0807879b          	addiw	a5,a5,128
    800003a8:	f6f61ce3          	bne	a2,a5,80000320 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003ac:	863e                	mv	a2,a5
    800003ae:	a07d                	j	8000045c <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b0:	00011717          	auipc	a4,0x11
    800003b4:	ce070713          	addi	a4,a4,-800 # 80011090 <cons>
    800003b8:	0a872783          	lw	a5,168(a4)
    800003bc:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c0:	00011497          	auipc	s1,0x11
    800003c4:	cd048493          	addi	s1,s1,-816 # 80011090 <cons>
    while(cons.e != cons.w &&
    800003c8:	4929                	li	s2,10
    800003ca:	f4f70be3          	beq	a4,a5,80000320 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ce:	37fd                	addiw	a5,a5,-1
    800003d0:	07f7f713          	andi	a4,a5,127
    800003d4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003d6:	02074703          	lbu	a4,32(a4)
    800003da:	f52703e3          	beq	a4,s2,80000320 <consoleintr+0x3c>
      cons.e--;
    800003de:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003e2:	10000513          	li	a0,256
    800003e6:	00000097          	auipc	ra,0x0
    800003ea:	e2e080e7          	jalr	-466(ra) # 80000214 <consputc>
    while(cons.e != cons.w &&
    800003ee:	0a84a783          	lw	a5,168(s1)
    800003f2:	0a44a703          	lw	a4,164(s1)
    800003f6:	fcf71ce3          	bne	a4,a5,800003ce <consoleintr+0xea>
    800003fa:	b71d                	j	80000320 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003fc:	00011717          	auipc	a4,0x11
    80000400:	c9470713          	addi	a4,a4,-876 # 80011090 <cons>
    80000404:	0a872783          	lw	a5,168(a4)
    80000408:	0a472703          	lw	a4,164(a4)
    8000040c:	f0f70ae3          	beq	a4,a5,80000320 <consoleintr+0x3c>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00011717          	auipc	a4,0x11
    80000416:	d2f72323          	sw	a5,-730(a4) # 80011138 <cons+0xa8>
      consputc(BACKSPACE);
    8000041a:	10000513          	li	a0,256
    8000041e:	00000097          	auipc	ra,0x0
    80000422:	df6080e7          	jalr	-522(ra) # 80000214 <consputc>
    80000426:	bded                	j	80000320 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000428:	ee048ce3          	beqz	s1,80000320 <consoleintr+0x3c>
    8000042c:	bf21                	j	80000344 <consoleintr+0x60>
      consputc(c);
    8000042e:	4529                	li	a0,10
    80000430:	00000097          	auipc	ra,0x0
    80000434:	de4080e7          	jalr	-540(ra) # 80000214 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000438:	00011797          	auipc	a5,0x11
    8000043c:	c5878793          	addi	a5,a5,-936 # 80011090 <cons>
    80000440:	0a87a703          	lw	a4,168(a5)
    80000444:	0017069b          	addiw	a3,a4,1
    80000448:	0006861b          	sext.w	a2,a3
    8000044c:	0ad7a423          	sw	a3,168(a5)
    80000450:	07f77713          	andi	a4,a4,127
    80000454:	97ba                	add	a5,a5,a4
    80000456:	4729                	li	a4,10
    80000458:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    8000045c:	00011797          	auipc	a5,0x11
    80000460:	ccc7ac23          	sw	a2,-808(a5) # 80011134 <cons+0xa4>
        wakeup(&cons.r);
    80000464:	00011517          	auipc	a0,0x11
    80000468:	ccc50513          	addi	a0,a0,-820 # 80011130 <cons+0xa0>
    8000046c:	00002097          	auipc	ra,0x2
    80000470:	06c080e7          	jalr	108(ra) # 800024d8 <wakeup>
    80000474:	b575                	j	80000320 <consoleintr+0x3c>

0000000080000476 <consoleinit>:

void
consoleinit(void)
{
    80000476:	1141                	addi	sp,sp,-16
    80000478:	e406                	sd	ra,8(sp)
    8000047a:	e022                	sd	s0,0(sp)
    8000047c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000047e:	00008597          	auipc	a1,0x8
    80000482:	b9258593          	addi	a1,a1,-1134 # 80008010 <etext+0x10>
    80000486:	00011517          	auipc	a0,0x11
    8000048a:	c0a50513          	addi	a0,a0,-1014 # 80011090 <cons>
    8000048e:	00000097          	auipc	ra,0x0
    80000492:	62e080e7          	jalr	1582(ra) # 80000abc <initlock>

  uartinit();
    80000496:	00000097          	auipc	ra,0x0
    8000049a:	3f6080e7          	jalr	1014(ra) # 8000088c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049e:	00035797          	auipc	a5,0x35
    800004a2:	e8a78793          	addi	a5,a5,-374 # 80035328 <devsw>
    800004a6:	00000717          	auipc	a4,0x0
    800004aa:	c5c70713          	addi	a4,a4,-932 # 80000102 <consoleread>
    800004ae:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004b0:	00000717          	auipc	a4,0x0
    800004b4:	db270713          	addi	a4,a4,-590 # 80000262 <consolewrite>
    800004b8:	ef98                	sd	a4,24(a5)
}
    800004ba:	60a2                	ld	ra,8(sp)
    800004bc:	6402                	ld	s0,0(sp)
    800004be:	0141                	addi	sp,sp,16
    800004c0:	8082                	ret

00000000800004c2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004c2:	7179                	addi	sp,sp,-48
    800004c4:	f406                	sd	ra,40(sp)
    800004c6:	f022                	sd	s0,32(sp)
    800004c8:	ec26                	sd	s1,24(sp)
    800004ca:	e84a                	sd	s2,16(sp)
    800004cc:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ce:	c219                	beqz	a2,800004d4 <printint+0x12>
    800004d0:	08054663          	bltz	a0,8000055c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004d4:	2501                	sext.w	a0,a0
    800004d6:	4881                	li	a7,0
    800004d8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004dc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004de:	2581                	sext.w	a1,a1
    800004e0:	00008617          	auipc	a2,0x8
    800004e4:	c9060613          	addi	a2,a2,-880 # 80008170 <digits>
    800004e8:	883a                	mv	a6,a4
    800004ea:	2705                	addiw	a4,a4,1
    800004ec:	02b577bb          	remuw	a5,a0,a1
    800004f0:	1782                	slli	a5,a5,0x20
    800004f2:	9381                	srli	a5,a5,0x20
    800004f4:	97b2                	add	a5,a5,a2
    800004f6:	0007c783          	lbu	a5,0(a5)
    800004fa:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004fe:	0005079b          	sext.w	a5,a0
    80000502:	02b5553b          	divuw	a0,a0,a1
    80000506:	0685                	addi	a3,a3,1
    80000508:	feb7f0e3          	bgeu	a5,a1,800004e8 <printint+0x26>

  if(sign)
    8000050c:	00088b63          	beqz	a7,80000522 <printint+0x60>
    buf[i++] = '-';
    80000510:	fe040793          	addi	a5,s0,-32
    80000514:	973e                	add	a4,a4,a5
    80000516:	02d00793          	li	a5,45
    8000051a:	fef70823          	sb	a5,-16(a4)
    8000051e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000522:	02e05763          	blez	a4,80000550 <printint+0x8e>
    80000526:	fd040793          	addi	a5,s0,-48
    8000052a:	00e784b3          	add	s1,a5,a4
    8000052e:	fff78913          	addi	s2,a5,-1
    80000532:	993a                	add	s2,s2,a4
    80000534:	377d                	addiw	a4,a4,-1
    80000536:	1702                	slli	a4,a4,0x20
    80000538:	9301                	srli	a4,a4,0x20
    8000053a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053e:	fff4c503          	lbu	a0,-1(s1)
    80000542:	00000097          	auipc	ra,0x0
    80000546:	cd2080e7          	jalr	-814(ra) # 80000214 <consputc>
  while(--i >= 0)
    8000054a:	14fd                	addi	s1,s1,-1
    8000054c:	ff2499e3          	bne	s1,s2,8000053e <printint+0x7c>
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	64e2                	ld	s1,24(sp)
    80000556:	6942                	ld	s2,16(sp)
    80000558:	6145                	addi	sp,sp,48
    8000055a:	8082                	ret
    x = -xx;
    8000055c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000560:	4885                	li	a7,1
    x = -xx;
    80000562:	bf9d                	j	800004d8 <printint+0x16>

0000000080000564 <panic>:
  }
}

void
panic(char *s)
{
    80000564:	1101                	addi	sp,sp,-32
    80000566:	ec06                	sd	ra,24(sp)
    80000568:	e822                	sd	s0,16(sp)
    8000056a:	e426                	sd	s1,8(sp)
    8000056c:	1000                	addi	s0,sp,32
    8000056e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000570:	00011797          	auipc	a5,0x11
    80000574:	be07a823          	sw	zero,-1040(a5) # 80011160 <pr+0x20>
  printf("PANIC: ");
    80000578:	00008517          	auipc	a0,0x8
    8000057c:	aa050513          	addi	a0,a0,-1376 # 80008018 <etext+0x18>
    80000580:	00000097          	auipc	ra,0x0
    80000584:	046080e7          	jalr	70(ra) # 800005c6 <printf>
  printf(s);
    80000588:	8526                	mv	a0,s1
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	03c080e7          	jalr	60(ra) # 800005c6 <printf>
  printf("\n");
    80000592:	00008517          	auipc	a0,0x8
    80000596:	c6e50513          	addi	a0,a0,-914 # 80008200 <digits+0x90>
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	02c080e7          	jalr	44(ra) # 800005c6 <printf>
  backtrace();
    800005a2:	00000097          	auipc	ra,0x0
    800005a6:	24e080e7          	jalr	590(ra) # 800007f0 <backtrace>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    800005aa:	00008517          	auipc	a0,0x8
    800005ae:	a7650513          	addi	a0,a0,-1418 # 80008020 <etext+0x20>
    800005b2:	00000097          	auipc	ra,0x0
    800005b6:	014080e7          	jalr	20(ra) # 800005c6 <printf>
  panicked = 1; // freeze other CPUs
    800005ba:	4785                	li	a5,1
    800005bc:	00009717          	auipc	a4,0x9
    800005c0:	94f72223          	sw	a5,-1724(a4) # 80008f00 <panicked>
  for(;;)
    800005c4:	a001                	j	800005c4 <panic+0x60>

00000000800005c6 <printf>:
{
    800005c6:	7131                	addi	sp,sp,-192
    800005c8:	fc86                	sd	ra,120(sp)
    800005ca:	f8a2                	sd	s0,112(sp)
    800005cc:	f4a6                	sd	s1,104(sp)
    800005ce:	f0ca                	sd	s2,96(sp)
    800005d0:	ecce                	sd	s3,88(sp)
    800005d2:	e8d2                	sd	s4,80(sp)
    800005d4:	e4d6                	sd	s5,72(sp)
    800005d6:	e0da                	sd	s6,64(sp)
    800005d8:	fc5e                	sd	s7,56(sp)
    800005da:	f862                	sd	s8,48(sp)
    800005dc:	f466                	sd	s9,40(sp)
    800005de:	f06a                	sd	s10,32(sp)
    800005e0:	ec6e                	sd	s11,24(sp)
    800005e2:	0100                	addi	s0,sp,128
    800005e4:	892a                	mv	s2,a0
    800005e6:	e40c                	sd	a1,8(s0)
    800005e8:	e810                	sd	a2,16(s0)
    800005ea:	ec14                	sd	a3,24(s0)
    800005ec:	f018                	sd	a4,32(s0)
    800005ee:	f41c                	sd	a5,40(s0)
    800005f0:	03043823          	sd	a6,48(s0)
    800005f4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005f8:	00011c17          	auipc	s8,0x11
    800005fc:	b68c2c03          	lw	s8,-1176(s8) # 80011160 <pr+0x20>
  if(locking)
    80000600:	020c1c63          	bnez	s8,80000638 <printf+0x72>
  if (fmt == 0)
    80000604:	04090363          	beqz	s2,8000064a <printf+0x84>
  va_start(ap, fmt);
    80000608:	00840793          	addi	a5,s0,8
    8000060c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000610:	00094503          	lbu	a0,0(s2)
    80000614:	1a050463          	beqz	a0,800007bc <printf+0x1f6>
    80000618:	4481                	li	s1,0
    if(c != '%'){
    8000061a:	02500993          	li	s3,37
    switch(c){
    8000061e:	4ad5                	li	s5,21
    80000620:	00008b17          	auipc	s6,0x8
    80000624:	af8b0b13          	addi	s6,s6,-1288 # 80008118 <etext+0x118>
      for(; *s; s++)
    80000628:	02800d13          	li	s10,40
  consputc('x');
    8000062c:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000062e:	00008a17          	auipc	s4,0x8
    80000632:	b42a0a13          	addi	s4,s4,-1214 # 80008170 <digits>
    80000636:	a82d                	j	80000670 <printf+0xaa>
    acquire(&pr.lock);
    80000638:	00011517          	auipc	a0,0x11
    8000063c:	b0850513          	addi	a0,a0,-1272 # 80011140 <pr>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	552080e7          	jalr	1362(ra) # 80000b92 <acquire>
    80000648:	bf75                	j	80000604 <printf+0x3e>
    panic("null fmt");
    8000064a:	00008517          	auipc	a0,0x8
    8000064e:	aae50513          	addi	a0,a0,-1362 # 800080f8 <etext+0xf8>
    80000652:	00000097          	auipc	ra,0x0
    80000656:	f12080e7          	jalr	-238(ra) # 80000564 <panic>
      consputc(c);
    8000065a:	00000097          	auipc	ra,0x0
    8000065e:	bba080e7          	jalr	-1094(ra) # 80000214 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000662:	2485                	addiw	s1,s1,1
    80000664:	009907b3          	add	a5,s2,s1
    80000668:	0007c503          	lbu	a0,0(a5)
    8000066c:	14050863          	beqz	a0,800007bc <printf+0x1f6>
    if(c != '%'){
    80000670:	ff3515e3          	bne	a0,s3,8000065a <printf+0x94>
    c = fmt[++i] & 0xff;
    80000674:	2485                	addiw	s1,s1,1
    80000676:	009907b3          	add	a5,s2,s1
    8000067a:	0007c783          	lbu	a5,0(a5)
    8000067e:	00078b9b          	sext.w	s7,a5
    if(c == 0)
    80000682:	12078d63          	beqz	a5,800007bc <printf+0x1f6>
    switch(c){
    80000686:	11378a63          	beq	a5,s3,8000079a <printf+0x1d4>
    8000068a:	f9d7871b          	addiw	a4,a5,-99
    8000068e:	0ff77713          	andi	a4,a4,255
    80000692:	10eaea63          	bltu	s5,a4,800007a6 <printf+0x1e0>
    80000696:	f9d7879b          	addiw	a5,a5,-99
    8000069a:	0ff7f713          	andi	a4,a5,255
    8000069e:	10eae463          	bltu	s5,a4,800007a6 <printf+0x1e0>
    800006a2:	00271793          	slli	a5,a4,0x2
    800006a6:	97da                	add	a5,a5,s6
    800006a8:	439c                	lw	a5,0(a5)
    800006aa:	97da                	add	a5,a5,s6
    800006ac:	8782                	jr	a5
      consputc(va_arg(ap, int));
    800006ae:	f8843783          	ld	a5,-120(s0)
    800006b2:	00878713          	addi	a4,a5,8
    800006b6:	f8e43423          	sd	a4,-120(s0)
    800006ba:	4388                	lw	a0,0(a5)
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	b58080e7          	jalr	-1192(ra) # 80000214 <consputc>
      break;
    800006c4:	bf79                	j	80000662 <printf+0x9c>
      printint(va_arg(ap, int), 10, 1);
    800006c6:	f8843783          	ld	a5,-120(s0)
    800006ca:	00878713          	addi	a4,a5,8
    800006ce:	f8e43423          	sd	a4,-120(s0)
    800006d2:	4605                	li	a2,1
    800006d4:	45a9                	li	a1,10
    800006d6:	4388                	lw	a0,0(a5)
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	dea080e7          	jalr	-534(ra) # 800004c2 <printint>
      break;
    800006e0:	b749                	j	80000662 <printf+0x9c>
      printint(va_arg(ap, int), 10, 0);
    800006e2:	f8843783          	ld	a5,-120(s0)
    800006e6:	00878713          	addi	a4,a5,8
    800006ea:	f8e43423          	sd	a4,-120(s0)
    800006ee:	4601                	li	a2,0
    800006f0:	45a9                	li	a1,10
    800006f2:	4388                	lw	a0,0(a5)
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	dce080e7          	jalr	-562(ra) # 800004c2 <printint>
      break;
    800006fc:	b79d                	j	80000662 <printf+0x9c>
      printint(va_arg(ap, int), 16, 1);
    800006fe:	f8843783          	ld	a5,-120(s0)
    80000702:	00878713          	addi	a4,a5,8
    80000706:	f8e43423          	sd	a4,-120(s0)
    8000070a:	4605                	li	a2,1
    8000070c:	85e6                	mv	a1,s9
    8000070e:	4388                	lw	a0,0(a5)
    80000710:	00000097          	auipc	ra,0x0
    80000714:	db2080e7          	jalr	-590(ra) # 800004c2 <printint>
      break;
    80000718:	b7a9                	j	80000662 <printf+0x9c>
      printptr(va_arg(ap, uint64));
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	0007bd83          	ld	s11,0(a5)
  consputc('0');
    8000072a:	03000513          	li	a0,48
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	ae6080e7          	jalr	-1306(ra) # 80000214 <consputc>
  consputc('x');
    80000736:	07800513          	li	a0,120
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	ada080e7          	jalr	-1318(ra) # 80000214 <consputc>
    80000742:	8be6                	mv	s7,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000744:	03cdd793          	srli	a5,s11,0x3c
    80000748:	97d2                	add	a5,a5,s4
    8000074a:	0007c503          	lbu	a0,0(a5)
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	ac6080e7          	jalr	-1338(ra) # 80000214 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000756:	0d92                	slli	s11,s11,0x4
    80000758:	3bfd                	addiw	s7,s7,-1
    8000075a:	fe0b95e3          	bnez	s7,80000744 <printf+0x17e>
    8000075e:	b711                	j	80000662 <printf+0x9c>
      if((s = va_arg(ap, char*)) == 0)
    80000760:	f8843783          	ld	a5,-120(s0)
    80000764:	00878713          	addi	a4,a5,8
    80000768:	f8e43423          	sd	a4,-120(s0)
    8000076c:	0007bb83          	ld	s7,0(a5)
    80000770:	000b8f63          	beqz	s7,8000078e <printf+0x1c8>
      for(; *s; s++)
    80000774:	000bc503          	lbu	a0,0(s7)
    80000778:	ee0505e3          	beqz	a0,80000662 <printf+0x9c>
        consputc(*s);
    8000077c:	00000097          	auipc	ra,0x0
    80000780:	a98080e7          	jalr	-1384(ra) # 80000214 <consputc>
      for(; *s; s++)
    80000784:	0b85                	addi	s7,s7,1
    80000786:	000bc503          	lbu	a0,0(s7)
    8000078a:	f96d                	bnez	a0,8000077c <printf+0x1b6>
    8000078c:	bdd9                	j	80000662 <printf+0x9c>
        s = "(null)";
    8000078e:	00008b97          	auipc	s7,0x8
    80000792:	962b8b93          	addi	s7,s7,-1694 # 800080f0 <etext+0xf0>
      for(; *s; s++)
    80000796:	856a                	mv	a0,s10
    80000798:	b7d5                	j	8000077c <printf+0x1b6>
      consputc('%');
    8000079a:	854e                	mv	a0,s3
    8000079c:	00000097          	auipc	ra,0x0
    800007a0:	a78080e7          	jalr	-1416(ra) # 80000214 <consputc>
      break;
    800007a4:	bd7d                	j	80000662 <printf+0x9c>
      consputc('%');
    800007a6:	854e                	mv	a0,s3
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	a6c080e7          	jalr	-1428(ra) # 80000214 <consputc>
      consputc(c);
    800007b0:	855e                	mv	a0,s7
    800007b2:	00000097          	auipc	ra,0x0
    800007b6:	a62080e7          	jalr	-1438(ra) # 80000214 <consputc>
      break;
    800007ba:	b565                	j	80000662 <printf+0x9c>
  if(locking)
    800007bc:	020c1163          	bnez	s8,800007de <printf+0x218>
}
    800007c0:	70e6                	ld	ra,120(sp)
    800007c2:	7446                	ld	s0,112(sp)
    800007c4:	74a6                	ld	s1,104(sp)
    800007c6:	7906                	ld	s2,96(sp)
    800007c8:	69e6                	ld	s3,88(sp)
    800007ca:	6a46                	ld	s4,80(sp)
    800007cc:	6aa6                	ld	s5,72(sp)
    800007ce:	6b06                	ld	s6,64(sp)
    800007d0:	7be2                	ld	s7,56(sp)
    800007d2:	7c42                	ld	s8,48(sp)
    800007d4:	7ca2                	ld	s9,40(sp)
    800007d6:	7d02                	ld	s10,32(sp)
    800007d8:	6de2                	ld	s11,24(sp)
    800007da:	6129                	addi	sp,sp,192
    800007dc:	8082                	ret
    release(&pr.lock);
    800007de:	00011517          	auipc	a0,0x11
    800007e2:	96250513          	addi	a0,a0,-1694 # 80011140 <pr>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	47c080e7          	jalr	1148(ra) # 80000c62 <release>
}
    800007ee:	bfc9                	j	800007c0 <printf+0x1fa>

00000000800007f0 <backtrace>:
{
    800007f0:	7179                	addi	sp,sp,-48
    800007f2:	f406                	sd	ra,40(sp)
    800007f4:	f022                	sd	s0,32(sp)
    800007f6:	ec26                	sd	s1,24(sp)
    800007f8:	e84a                	sd	s2,16(sp)
    800007fa:	e44e                	sd	s3,8(sp)
    800007fc:	e052                	sd	s4,0(sp)
    800007fe:	1800                	addi	s0,sp,48
  asm volatile("mv %0, fp" : "=r" (x) );
    80000800:	84a2                	mv	s1,s0
  uint64 ra, low = PGROUNDDOWN(fp) + 16, high = PGROUNDUP(fp);
    80000802:	77fd                	lui	a5,0xfffff
    80000804:	00f4f9b3          	and	s3,s1,a5
    80000808:	6905                	lui	s2,0x1
    8000080a:	197d                	addi	s2,s2,-1
    8000080c:	9926                	add	s2,s2,s1
    8000080e:	00f97933          	and	s2,s2,a5
  while(!(fp & 7) && fp >= low && fp < high){
    80000812:	0074f793          	andi	a5,s1,7
    80000816:	eb95                	bnez	a5,8000084a <backtrace+0x5a>
    80000818:	09c1                	addi	s3,s3,16
    8000081a:	0334e863          	bltu	s1,s3,8000084a <backtrace+0x5a>
    8000081e:	0324f663          	bgeu	s1,s2,8000084a <backtrace+0x5a>
    printf("[<%p>]\n", ra);
    80000822:	00008a17          	auipc	s4,0x8
    80000826:	8e6a0a13          	addi	s4,s4,-1818 # 80008108 <etext+0x108>
    8000082a:	ff84b583          	ld	a1,-8(s1)
    8000082e:	8552                	mv	a0,s4
    80000830:	00000097          	auipc	ra,0x0
    80000834:	d96080e7          	jalr	-618(ra) # 800005c6 <printf>
    fp = *(uint64*)(fp - 16);
    80000838:	ff04b483          	ld	s1,-16(s1)
  while(!(fp & 7) && fp >= low && fp < high){
    8000083c:	0074f793          	andi	a5,s1,7
    80000840:	e789                	bnez	a5,8000084a <backtrace+0x5a>
    80000842:	0134e463          	bltu	s1,s3,8000084a <backtrace+0x5a>
    80000846:	ff24e2e3          	bltu	s1,s2,8000082a <backtrace+0x3a>
}
    8000084a:	70a2                	ld	ra,40(sp)
    8000084c:	7402                	ld	s0,32(sp)
    8000084e:	64e2                	ld	s1,24(sp)
    80000850:	6942                	ld	s2,16(sp)
    80000852:	69a2                	ld	s3,8(sp)
    80000854:	6a02                	ld	s4,0(sp)
    80000856:	6145                	addi	sp,sp,48
    80000858:	8082                	ret

000000008000085a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000085a:	1101                	addi	sp,sp,-32
    8000085c:	ec06                	sd	ra,24(sp)
    8000085e:	e822                	sd	s0,16(sp)
    80000860:	e426                	sd	s1,8(sp)
    80000862:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000864:	00011497          	auipc	s1,0x11
    80000868:	8dc48493          	addi	s1,s1,-1828 # 80011140 <pr>
    8000086c:	00008597          	auipc	a1,0x8
    80000870:	8a458593          	addi	a1,a1,-1884 # 80008110 <etext+0x110>
    80000874:	8526                	mv	a0,s1
    80000876:	00000097          	auipc	ra,0x0
    8000087a:	246080e7          	jalr	582(ra) # 80000abc <initlock>
  pr.locking = 1;
    8000087e:	4785                	li	a5,1
    80000880:	d09c                	sw	a5,32(s1)
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret

000000008000088c <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    8000088c:	1141                	addi	sp,sp,-16
    8000088e:	e422                	sd	s0,8(sp)
    80000890:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000892:	100007b7          	lui	a5,0x10000
    80000896:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    8000089a:	f8000713          	li	a4,-128
    8000089e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008a2:	470d                	li	a4,3
    800008a4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008a8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800008ac:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800008b0:	471d                	li	a4,7
    800008b2:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800008b6:	4705                	li	a4,1
    800008b8:	00e780a3          	sb	a4,1(a5)
}
    800008bc:	6422                	ld	s0,8(sp)
    800008be:	0141                	addi	sp,sp,16
    800008c0:	8082                	ret

00000000800008c2 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800008c2:	1141                	addi	sp,sp,-16
    800008c4:	e422                	sd	s0,8(sp)
    800008c6:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800008c8:	10000737          	lui	a4,0x10000
    800008cc:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800008d0:	0207f793          	andi	a5,a5,32
    800008d4:	dfe5                	beqz	a5,800008cc <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800008d6:	0ff57513          	andi	a0,a0,255
    800008da:	100007b7          	lui	a5,0x10000
    800008de:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800008e2:	6422                	ld	s0,8(sp)
    800008e4:	0141                	addi	sp,sp,16
    800008e6:	8082                	ret

00000000800008e8 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800008e8:	1141                	addi	sp,sp,-16
    800008ea:	e422                	sd	s0,8(sp)
    800008ec:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800008ee:	100007b7          	lui	a5,0x10000
    800008f2:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800008f6:	8b85                	andi	a5,a5,1
    800008f8:	cb91                	beqz	a5,8000090c <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800008fa:	100007b7          	lui	a5,0x10000
    800008fe:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000902:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000906:	6422                	ld	s0,8(sp)
    80000908:	0141                	addi	sp,sp,16
    8000090a:	8082                	ret
    return -1;
    8000090c:	557d                	li	a0,-1
    8000090e:	bfe5                	j	80000906 <uartgetc+0x1e>

0000000080000910 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000910:	1101                	addi	sp,sp,-32
    80000912:	ec06                	sd	ra,24(sp)
    80000914:	e822                	sd	s0,16(sp)
    80000916:	e426                	sd	s1,8(sp)
    80000918:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000091a:	54fd                	li	s1,-1
    8000091c:	a029                	j	80000926 <uartintr+0x16>
      break;
    consoleintr(c);
    8000091e:	00000097          	auipc	ra,0x0
    80000922:	9c6080e7          	jalr	-1594(ra) # 800002e4 <consoleintr>
    int c = uartgetc();
    80000926:	00000097          	auipc	ra,0x0
    8000092a:	fc2080e7          	jalr	-62(ra) # 800008e8 <uartgetc>
    if(c == -1)
    8000092e:	fe9518e3          	bne	a0,s1,8000091e <uartintr+0xe>
  }
}
    80000932:	60e2                	ld	ra,24(sp)
    80000934:	6442                	ld	s0,16(sp)
    80000936:	64a2                	ld	s1,8(sp)
    80000938:	6105                	addi	sp,sp,32
    8000093a:	8082                	ret

000000008000093c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000093c:	1101                	addi	sp,sp,-32
    8000093e:	ec06                	sd	ra,24(sp)
    80000940:	e822                	sd	s0,16(sp)
    80000942:	e426                	sd	s1,8(sp)
    80000944:	e04a                	sd	s2,0(sp)
    80000946:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000948:	03451793          	slli	a5,a0,0x34
    8000094c:	e3a5                	bnez	a5,800009ac <kfree+0x70>
    8000094e:	84aa                	mv	s1,a0
    80000950:	00036797          	auipc	a5,0x36
    80000954:	ba078793          	addi	a5,a5,-1120 # 800364f0 <end>
    80000958:	04f56a63          	bltu	a0,a5,800009ac <kfree+0x70>
    8000095c:	47c5                	li	a5,17
    8000095e:	07ee                	slli	a5,a5,0x1b
    80000960:	04f57663          	bgeu	a0,a5,800009ac <kfree+0x70>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000964:	6605                	lui	a2,0x1
    80000966:	4585                	li	a1,1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	50e080e7          	jalr	1294(ra) # 80000e76 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000970:	00010917          	auipc	s2,0x10
    80000974:	7f890913          	addi	s2,s2,2040 # 80011168 <kmem>
    80000978:	854a                	mv	a0,s2
    8000097a:	00000097          	auipc	ra,0x0
    8000097e:	218080e7          	jalr	536(ra) # 80000b92 <acquire>
  r->next = kmem.freelist;
    80000982:	02093783          	ld	a5,32(s2)
    80000986:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000988:	02993023          	sd	s1,32(s2)
  kmem.nfree++;
    8000098c:	02893783          	ld	a5,40(s2)
    80000990:	0785                	addi	a5,a5,1
    80000992:	02f93423          	sd	a5,40(s2)
  release(&kmem.lock);
    80000996:	854a                	mv	a0,s2
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	2ca080e7          	jalr	714(ra) # 80000c62 <release>
}
    800009a0:	60e2                	ld	ra,24(sp)
    800009a2:	6442                	ld	s0,16(sp)
    800009a4:	64a2                	ld	s1,8(sp)
    800009a6:	6902                	ld	s2,0(sp)
    800009a8:	6105                	addi	sp,sp,32
    800009aa:	8082                	ret
    panic("kfree");
    800009ac:	00007517          	auipc	a0,0x7
    800009b0:	7dc50513          	addi	a0,a0,2012 # 80008188 <digits+0x18>
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	bb0080e7          	jalr	-1104(ra) # 80000564 <panic>

00000000800009bc <freerange>:
{
    800009bc:	7179                	addi	sp,sp,-48
    800009be:	f406                	sd	ra,40(sp)
    800009c0:	f022                	sd	s0,32(sp)
    800009c2:	ec26                	sd	s1,24(sp)
    800009c4:	e84a                	sd	s2,16(sp)
    800009c6:	e44e                	sd	s3,8(sp)
    800009c8:	e052                	sd	s4,0(sp)
    800009ca:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800009cc:	6785                	lui	a5,0x1
    800009ce:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800009d2:	94aa                	add	s1,s1,a0
    800009d4:	757d                	lui	a0,0xfffff
    800009d6:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009d8:	94be                	add	s1,s1,a5
    800009da:	0095ee63          	bltu	a1,s1,800009f6 <freerange+0x3a>
    800009de:	892e                	mv	s2,a1
    kfree(p);
    800009e0:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009e2:	6985                	lui	s3,0x1
    kfree(p);
    800009e4:	01448533          	add	a0,s1,s4
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	f54080e7          	jalr	-172(ra) # 8000093c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800009f0:	94ce                	add	s1,s1,s3
    800009f2:	fe9979e3          	bgeu	s2,s1,800009e4 <freerange+0x28>
}
    800009f6:	70a2                	ld	ra,40(sp)
    800009f8:	7402                	ld	s0,32(sp)
    800009fa:	64e2                	ld	s1,24(sp)
    800009fc:	6942                	ld	s2,16(sp)
    800009fe:	69a2                	ld	s3,8(sp)
    80000a00:	6a02                	ld	s4,0(sp)
    80000a02:	6145                	addi	sp,sp,48
    80000a04:	8082                	ret

0000000080000a06 <kinit>:
{
    80000a06:	1141                	addi	sp,sp,-16
    80000a08:	e406                	sd	ra,8(sp)
    80000a0a:	e022                	sd	s0,0(sp)
    80000a0c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a0e:	00007597          	auipc	a1,0x7
    80000a12:	78258593          	addi	a1,a1,1922 # 80008190 <digits+0x20>
    80000a16:	00010517          	auipc	a0,0x10
    80000a1a:	75250513          	addi	a0,a0,1874 # 80011168 <kmem>
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	09e080e7          	jalr	158(ra) # 80000abc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a26:	45c5                	li	a1,17
    80000a28:	05ee                	slli	a1,a1,0x1b
    80000a2a:	00036517          	auipc	a0,0x36
    80000a2e:	ac650513          	addi	a0,a0,-1338 # 800364f0 <end>
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	f8a080e7          	jalr	-118(ra) # 800009bc <freerange>
}
    80000a3a:	60a2                	ld	ra,8(sp)
    80000a3c:	6402                	ld	s0,0(sp)
    80000a3e:	0141                	addi	sp,sp,16
    80000a40:	8082                	ret

0000000080000a42 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000a4c:	00010497          	auipc	s1,0x10
    80000a50:	71c48493          	addi	s1,s1,1820 # 80011168 <kmem>
    80000a54:	8526                	mv	a0,s1
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	13c080e7          	jalr	316(ra) # 80000b92 <acquire>
  r = kmem.freelist;
    80000a5e:	7084                	ld	s1,32(s1)
  if(r){
    80000a60:	c89d                	beqz	s1,80000a96 <kalloc+0x54>
    kmem.freelist = r->next;
    80000a62:	609c                	ld	a5,0(s1)
    80000a64:	00010517          	auipc	a0,0x10
    80000a68:	70450513          	addi	a0,a0,1796 # 80011168 <kmem>
    80000a6c:	f11c                	sd	a5,32(a0)
    kmem.nfree--;
    80000a6e:	751c                	ld	a5,40(a0)
    80000a70:	17fd                	addi	a5,a5,-1
    80000a72:	f51c                	sd	a5,40(a0)
  }
  release(&kmem.lock);
    80000a74:	00000097          	auipc	ra,0x0
    80000a78:	1ee080e7          	jalr	494(ra) # 80000c62 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000a7c:	6605                	lui	a2,0x1
    80000a7e:	4595                	li	a1,5
    80000a80:	8526                	mv	a0,s1
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	3f4080e7          	jalr	1012(ra) # 80000e76 <memset>
  return (void*)r;
}
    80000a8a:	8526                	mv	a0,s1
    80000a8c:	60e2                	ld	ra,24(sp)
    80000a8e:	6442                	ld	s0,16(sp)
    80000a90:	64a2                	ld	s1,8(sp)
    80000a92:	6105                	addi	sp,sp,32
    80000a94:	8082                	ret
  release(&kmem.lock);
    80000a96:	00010517          	auipc	a0,0x10
    80000a9a:	6d250513          	addi	a0,a0,1746 # 80011168 <kmem>
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	1c4080e7          	jalr	452(ra) # 80000c62 <release>
  if(r)
    80000aa6:	b7d5                	j	80000a8a <kalloc+0x48>

0000000080000aa8 <sys_nfree>:

uint64
sys_nfree(void)
{
    80000aa8:	1141                	addi	sp,sp,-16
    80000aaa:	e422                	sd	s0,8(sp)
    80000aac:	0800                	addi	s0,sp,16
  return kmem.nfree;
}
    80000aae:	00010517          	auipc	a0,0x10
    80000ab2:	6e253503          	ld	a0,1762(a0) # 80011190 <kmem+0x28>
    80000ab6:	6422                	ld	s0,8(sp)
    80000ab8:	0141                	addi	sp,sp,16
    80000aba:	8082                	ret

0000000080000abc <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000abc:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000abe:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ac2:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000ac6:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    80000aca:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    80000ace:	00008797          	auipc	a5,0x8
    80000ad2:	4367a783          	lw	a5,1078(a5) # 80008f04 <nlock>
    80000ad6:	6709                	lui	a4,0x2
    80000ad8:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000adc:	02f74063          	blt	a4,a5,80000afc <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000ae0:	00379693          	slli	a3,a5,0x3
    80000ae4:	00010717          	auipc	a4,0x10
    80000ae8:	6b470713          	addi	a4,a4,1716 # 80011198 <locks>
    80000aec:	9736                	add	a4,a4,a3
    80000aee:	e308                	sd	a0,0(a4)
  nlock++;
    80000af0:	2785                	addiw	a5,a5,1
    80000af2:	00008717          	auipc	a4,0x8
    80000af6:	40f72923          	sw	a5,1042(a4) # 80008f04 <nlock>
    80000afa:	8082                	ret
{
    80000afc:	1141                	addi	sp,sp,-16
    80000afe:	e406                	sd	ra,8(sp)
    80000b00:	e022                	sd	s0,0(sp)
    80000b02:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b04:	00007517          	auipc	a0,0x7
    80000b08:	69450513          	addi	a0,a0,1684 # 80008198 <digits+0x28>
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	a58080e7          	jalr	-1448(ra) # 80000564 <panic>

0000000080000b14 <holding>:
// Must be called with interrupts off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b14:	411c                	lw	a5,0(a0)
    80000b16:	e399                	bnez	a5,80000b1c <holding+0x8>
    80000b18:	4501                	li	a0,0
  return r;
}
    80000b1a:	8082                	ret
{
    80000b1c:	1101                	addi	sp,sp,-32
    80000b1e:	ec06                	sd	ra,24(sp)
    80000b20:	e822                	sd	s0,16(sp)
    80000b22:	e426                	sd	s1,8(sp)
    80000b24:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b26:	6904                	ld	s1,16(a0)
    80000b28:	00001097          	auipc	ra,0x1
    80000b2c:	004080e7          	jalr	4(ra) # 80001b2c <mycpu>
    80000b30:	40a48533          	sub	a0,s1,a0
    80000b34:	00153513          	seqz	a0,a0
}
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret

0000000080000b42 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b42:	1101                	addi	sp,sp,-32
    80000b44:	ec06                	sd	ra,24(sp)
    80000b46:	e822                	sd	s0,16(sp)
    80000b48:	e426                	sd	s1,8(sp)
    80000b4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b4c:	100024f3          	csrr	s1,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b50:	8889                	andi	s1,s1,2
  int old = intr_get();
  if(old)
    80000b52:	c491                	beqz	s1,80000b5e <push_off+0x1c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b54:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b58:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b5a:	10079073          	csrw	sstatus,a5
    intr_off();
  if(mycpu()->noff == 0)
    80000b5e:	00001097          	auipc	ra,0x1
    80000b62:	fce080e7          	jalr	-50(ra) # 80001b2c <mycpu>
    80000b66:	5d3c                	lw	a5,120(a0)
    80000b68:	cf89                	beqz	a5,80000b82 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	fc2080e7          	jalr	-62(ra) # 80001b2c <mycpu>
    80000b72:	5d3c                	lw	a5,120(a0)
    80000b74:	2785                	addiw	a5,a5,1
    80000b76:	dd3c                	sw	a5,120(a0)
}
    80000b78:	60e2                	ld	ra,24(sp)
    80000b7a:	6442                	ld	s0,16(sp)
    80000b7c:	64a2                	ld	s1,8(sp)
    80000b7e:	6105                	addi	sp,sp,32
    80000b80:	8082                	ret
    mycpu()->intena = old;
    80000b82:	00001097          	auipc	ra,0x1
    80000b86:	faa080e7          	jalr	-86(ra) # 80001b2c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b8a:	009034b3          	snez	s1,s1
    80000b8e:	dd64                	sw	s1,124(a0)
    80000b90:	bfe9                	j	80000b6a <push_off+0x28>

0000000080000b92 <acquire>:
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
    80000b9c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	fa4080e7          	jalr	-92(ra) # 80000b42 <push_off>
  if(holding(lk))
    80000ba6:	8526                	mv	a0,s1
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	f6c080e7          	jalr	-148(ra) # 80000b14 <holding>
    80000bb0:	e911                	bnez	a0,80000bc4 <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000bb2:	4785                	li	a5,1
    80000bb4:	01848713          	addi	a4,s1,24
    80000bb8:	0f50000f          	fence	iorw,ow
    80000bbc:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000bc0:	4705                	li	a4,1
    80000bc2:	a839                	j	80000be0 <acquire+0x4e>
    panic("acquire");
    80000bc4:	00007517          	auipc	a0,0x7
    80000bc8:	5e450513          	addi	a0,a0,1508 # 800081a8 <digits+0x38>
    80000bcc:	00000097          	auipc	ra,0x0
    80000bd0:	998080e7          	jalr	-1640(ra) # 80000564 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000bd4:	01c48793          	addi	a5,s1,28
    80000bd8:	0f50000f          	fence	iorw,ow
    80000bdc:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000be0:	87ba                	mv	a5,a4
    80000be2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000be6:	2781                	sext.w	a5,a5
    80000be8:	f7f5                	bnez	a5,80000bd4 <acquire+0x42>
  __sync_synchronize();
    80000bea:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bee:	00001097          	auipc	ra,0x1
    80000bf2:	f3e080e7          	jalr	-194(ra) # 80001b2c <mycpu>
    80000bf6:	e888                	sd	a0,16(s1)
}
    80000bf8:	60e2                	ld	ra,24(sp)
    80000bfa:	6442                	ld	s0,16(sp)
    80000bfc:	64a2                	ld	s1,8(sp)
    80000bfe:	6105                	addi	sp,sp,32
    80000c00:	8082                	ret

0000000080000c02 <pop_off>:

void
pop_off(void)
{
    80000c02:	1141                	addi	sp,sp,-16
    80000c04:	e406                	sd	ra,8(sp)
    80000c06:	e022                	sd	s0,0(sp)
    80000c08:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c0a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c0e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c10:	eb8d                	bnez	a5,80000c42 <pop_off+0x40>
    panic("pop_off - interruptible");
  struct cpu *c = mycpu();
    80000c12:	00001097          	auipc	ra,0x1
    80000c16:	f1a080e7          	jalr	-230(ra) # 80001b2c <mycpu>
  if(c->noff < 1)
    80000c1a:	5d3c                	lw	a5,120(a0)
    80000c1c:	02f05b63          	blez	a5,80000c52 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c20:	37fd                	addiw	a5,a5,-1
    80000c22:	0007871b          	sext.w	a4,a5
    80000c26:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c28:	eb09                	bnez	a4,80000c3a <pop_off+0x38>
    80000c2a:	5d7c                	lw	a5,124(a0)
    80000c2c:	c799                	beqz	a5,80000c3a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c2e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c32:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c36:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c3a:	60a2                	ld	ra,8(sp)
    80000c3c:	6402                	ld	s0,0(sp)
    80000c3e:	0141                	addi	sp,sp,16
    80000c40:	8082                	ret
    panic("pop_off - interruptible");
    80000c42:	00007517          	auipc	a0,0x7
    80000c46:	56e50513          	addi	a0,a0,1390 # 800081b0 <digits+0x40>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	91a080e7          	jalr	-1766(ra) # 80000564 <panic>
    panic("pop_off");
    80000c52:	00007517          	auipc	a0,0x7
    80000c56:	57650513          	addi	a0,a0,1398 # 800081c8 <digits+0x58>
    80000c5a:	00000097          	auipc	ra,0x0
    80000c5e:	90a080e7          	jalr	-1782(ra) # 80000564 <panic>

0000000080000c62 <release>:
{
    80000c62:	1101                	addi	sp,sp,-32
    80000c64:	ec06                	sd	ra,24(sp)
    80000c66:	e822                	sd	s0,16(sp)
    80000c68:	e426                	sd	s1,8(sp)
    80000c6a:	1000                	addi	s0,sp,32
    80000c6c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	ea6080e7          	jalr	-346(ra) # 80000b14 <holding>
    80000c76:	c115                	beqz	a0,80000c9a <release+0x38>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c80:	0f50000f          	fence	iorw,ow
    80000c84:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	f7a080e7          	jalr	-134(ra) # 80000c02 <pop_off>
}
    80000c90:	60e2                	ld	ra,24(sp)
    80000c92:	6442                	ld	s0,16(sp)
    80000c94:	64a2                	ld	s1,8(sp)
    80000c96:	6105                	addi	sp,sp,32
    80000c98:	8082                	ret
    panic("release");
    80000c9a:	00007517          	auipc	a0,0x7
    80000c9e:	53650513          	addi	a0,a0,1334 # 800081d0 <digits+0x60>
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	8c2080e7          	jalr	-1854(ra) # 80000564 <panic>

0000000080000caa <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000caa:	4d14                	lw	a3,24(a0)
    80000cac:	e291                	bnez	a3,80000cb0 <print_lock+0x6>
    80000cae:	8082                	ret
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000cb8:	4d50                	lw	a2,28(a0)
    80000cba:	650c                	ld	a1,8(a0)
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	51c50513          	addi	a0,a0,1308 # 800081d8 <digits+0x68>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	902080e7          	jalr	-1790(ra) # 800005c6 <printf>
}
    80000ccc:	60a2                	ld	ra,8(sp)
    80000cce:	6402                	ld	s0,0(sp)
    80000cd0:	0141                	addi	sp,sp,16
    80000cd2:	8082                	ret

0000000080000cd4 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000cd4:	711d                	addi	sp,sp,-96
    80000cd6:	ec86                	sd	ra,88(sp)
    80000cd8:	e8a2                	sd	s0,80(sp)
    80000cda:	e4a6                	sd	s1,72(sp)
    80000cdc:	e0ca                	sd	s2,64(sp)
    80000cde:	fc4e                	sd	s3,56(sp)
    80000ce0:	f852                	sd	s4,48(sp)
    80000ce2:	f456                	sd	s5,40(sp)
    80000ce4:	f05a                	sd	s6,32(sp)
    80000ce6:	ec5e                	sd	s7,24(sp)
    80000ce8:	1080                	addi	s0,sp,96
  int zero = 0;
    80000cea:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000cee:	fac40593          	addi	a1,s0,-84
    80000cf2:	4501                	li	a0,0
    80000cf4:	00002097          	auipc	ra,0x2
    80000cf8:	fac080e7          	jalr	-84(ra) # 80002ca0 <argint>
    80000cfc:	12054463          	bltz	a0,80000e24 <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d00:	fac42783          	lw	a5,-84(s0)
    80000d04:	e39d                	bnez	a5,80000d2a <sys_ntas+0x56>
    80000d06:	00010797          	auipc	a5,0x10
    80000d0a:	49278793          	addi	a5,a5,1170 # 80011198 <locks>
    80000d0e:	00024697          	auipc	a3,0x24
    80000d12:	d0a68693          	addi	a3,a3,-758 # 80024a18 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000d16:	6398                	ld	a4,0(a5)
    80000d18:	10070863          	beqz	a4,80000e28 <sys_ntas+0x154>
        break;
      locks[i]->nts = 0;
    80000d1c:	00072e23          	sw	zero,28(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000d20:	07a1                	addi	a5,a5,8
    80000d22:	fed79ae3          	bne	a5,a3,80000d16 <sys_ntas+0x42>
    }
    return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	a0dd                	j	80000e0e <sys_ntas+0x13a>
  }

  printf("=== lock kmem stats\n");
    80000d2a:	00007517          	auipc	a0,0x7
    80000d2e:	4de50513          	addi	a0,a0,1246 # 80008208 <digits+0x98>
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	894080e7          	jalr	-1900(ra) # 800005c6 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000d3a:	00010b17          	auipc	s6,0x10
    80000d3e:	45eb0b13          	addi	s6,s6,1118 # 80011198 <locks>
    80000d42:	00024b97          	auipc	s7,0x24
    80000d46:	cd6b8b93          	addi	s7,s7,-810 # 80024a18 <pid_lock>
  printf("=== lock kmem stats\n");
    80000d4a:	84da                	mv	s1,s6
  int tot = 0;
    80000d4c:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d4e:	00007917          	auipc	s2,0x7
    80000d52:	44290913          	addi	s2,s2,1090 # 80008190 <digits+0x20>
    80000d56:	a021                	j	80000d5e <sys_ntas+0x8a>
  for(int i = 0; i < NLOCK; i++) {
    80000d58:	04a1                	addi	s1,s1,8
    80000d5a:	03748d63          	beq	s1,s7,80000d94 <sys_ntas+0xc0>
    if(locks[i] == 0)
    80000d5e:	609c                	ld	a5,0(s1)
    80000d60:	cb95                	beqz	a5,80000d94 <sys_ntas+0xc0>
    if(strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d62:	0087ba03          	ld	s4,8(a5)
    80000d66:	854a                	mv	a0,s2
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	2b6080e7          	jalr	694(ra) # 8000101e <strlen>
    80000d70:	0005061b          	sext.w	a2,a0
    80000d74:	85ca                	mv	a1,s2
    80000d76:	8552                	mv	a0,s4
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	1fa080e7          	jalr	506(ra) # 80000f72 <strncmp>
    80000d80:	fd61                	bnez	a0,80000d58 <sys_ntas+0x84>
      tot += locks[i]->nts;
    80000d82:	6088                	ld	a0,0(s1)
    80000d84:	4d5c                	lw	a5,28(a0)
    80000d86:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000d8a:	00000097          	auipc	ra,0x0
    80000d8e:	f20080e7          	jalr	-224(ra) # 80000caa <print_lock>
    80000d92:	b7d9                	j	80000d58 <sys_ntas+0x84>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000d94:	00007517          	auipc	a0,0x7
    80000d98:	48c50513          	addi	a0,a0,1164 # 80008220 <digits+0xb0>
    80000d9c:	00000097          	auipc	ra,0x0
    80000da0:	82a080e7          	jalr	-2006(ra) # 800005c6 <printf>
    80000da4:	4a15                	li	s4,5
  int last = 100000000;
    80000da6:	05f5e537          	lui	a0,0x5f5e
    80000daa:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000dae:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000db0:	00010497          	auipc	s1,0x10
    80000db4:	3e848493          	addi	s1,s1,1000 # 80011198 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000db8:	6909                	lui	s2,0x2
    80000dba:	71090913          	addi	s2,s2,1808 # 2710 <_entry-0x7fffd8f0>
    80000dbe:	a091                	j	80000e02 <sys_ntas+0x12e>
    80000dc0:	2705                	addiw	a4,a4,1
    80000dc2:	06a1                	addi	a3,a3,8
    80000dc4:	03270063          	beq	a4,s2,80000de4 <sys_ntas+0x110>
      if(locks[i] == 0)
    80000dc8:	629c                	ld	a5,0(a3)
    80000dca:	cf89                	beqz	a5,80000de4 <sys_ntas+0x110>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000dcc:	4fd0                	lw	a2,28(a5)
    80000dce:	00359793          	slli	a5,a1,0x3
    80000dd2:	97a6                	add	a5,a5,s1
    80000dd4:	639c                	ld	a5,0(a5)
    80000dd6:	4fdc                	lw	a5,28(a5)
    80000dd8:	fec7f4e3          	bgeu	a5,a2,80000dc0 <sys_ntas+0xec>
    80000ddc:	fea672e3          	bgeu	a2,a0,80000dc0 <sys_ntas+0xec>
    80000de0:	85ba                	mv	a1,a4
    80000de2:	bff9                	j	80000dc0 <sys_ntas+0xec>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000de4:	058e                	slli	a1,a1,0x3
    80000de6:	00b48bb3          	add	s7,s1,a1
    80000dea:	000bb503          	ld	a0,0(s7)
    80000dee:	00000097          	auipc	ra,0x0
    80000df2:	ebc080e7          	jalr	-324(ra) # 80000caa <print_lock>
    last = locks[top]->nts;
    80000df6:	000bb783          	ld	a5,0(s7)
    80000dfa:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000dfc:	3a7d                	addiw	s4,s4,-1
    80000dfe:	000a0763          	beqz	s4,80000e0c <sys_ntas+0x138>
  int tot = 0;
    80000e02:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000e04:	8756                	mv	a4,s5
    int top = 0;
    80000e06:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e08:	2501                	sext.w	a0,a0
    80000e0a:	bf7d                	j	80000dc8 <sys_ntas+0xf4>
  }
  return tot;
    80000e0c:	854e                	mv	a0,s3
}
    80000e0e:	60e6                	ld	ra,88(sp)
    80000e10:	6446                	ld	s0,80(sp)
    80000e12:	64a6                	ld	s1,72(sp)
    80000e14:	6906                	ld	s2,64(sp)
    80000e16:	79e2                	ld	s3,56(sp)
    80000e18:	7a42                	ld	s4,48(sp)
    80000e1a:	7aa2                	ld	s5,40(sp)
    80000e1c:	7b02                	ld	s6,32(sp)
    80000e1e:	6be2                	ld	s7,24(sp)
    80000e20:	6125                	addi	sp,sp,96
    80000e22:	8082                	ret
    return -1;
    80000e24:	557d                	li	a0,-1
    80000e26:	b7e5                	j	80000e0e <sys_ntas+0x13a>
    return 0;
    80000e28:	4501                	li	a0,0
    80000e2a:	b7d5                	j	80000e0e <sys_ntas+0x13a>

0000000080000e2c <atoi>:
#include "types.h"

int
atoi(const char *s)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e422                	sd	s0,8(sp)
    80000e30:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    80000e32:	00054603          	lbu	a2,0(a0)
    80000e36:	fd06079b          	addiw	a5,a2,-48
    80000e3a:	0ff7f793          	andi	a5,a5,255
    80000e3e:	4725                	li	a4,9
    80000e40:	02f76963          	bltu	a4,a5,80000e72 <atoi+0x46>
    80000e44:	86aa                	mv	a3,a0
  n = 0;
    80000e46:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    80000e48:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    80000e4a:	0685                	addi	a3,a3,1
    80000e4c:	0025179b          	slliw	a5,a0,0x2
    80000e50:	9fa9                	addw	a5,a5,a0
    80000e52:	0017979b          	slliw	a5,a5,0x1
    80000e56:	9fb1                	addw	a5,a5,a2
    80000e58:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    80000e5c:	0006c603          	lbu	a2,0(a3)
    80000e60:	fd06071b          	addiw	a4,a2,-48
    80000e64:	0ff77713          	andi	a4,a4,255
    80000e68:	fee5f1e3          	bgeu	a1,a4,80000e4a <atoi+0x1e>
  return n;
}
    80000e6c:	6422                	ld	s0,8(sp)
    80000e6e:	0141                	addi	sp,sp,16
    80000e70:	8082                	ret
  n = 0;
    80000e72:	4501                	li	a0,0
    80000e74:	bfe5                	j	80000e6c <atoi+0x40>

0000000080000e76 <memset>:

void*
memset(void *dst, int c, uint n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e7c:	ca19                	beqz	a2,80000e92 <memset+0x1c>
    80000e7e:	87aa                	mv	a5,a0
    80000e80:	1602                	slli	a2,a2,0x20
    80000e82:	9201                	srli	a2,a2,0x20
    80000e84:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e88:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e8c:	0785                	addi	a5,a5,1
    80000e8e:	fee79de3          	bne	a5,a4,80000e88 <memset+0x12>
  }
  return dst;
}
    80000e92:	6422                	ld	s0,8(sp)
    80000e94:	0141                	addi	sp,sp,16
    80000e96:	8082                	ret

0000000080000e98 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e98:	1141                	addi	sp,sp,-16
    80000e9a:	e422                	sd	s0,8(sp)
    80000e9c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e9e:	ca05                	beqz	a2,80000ece <memcmp+0x36>
    80000ea0:	fff6069b          	addiw	a3,a2,-1
    80000ea4:	1682                	slli	a3,a3,0x20
    80000ea6:	9281                	srli	a3,a3,0x20
    80000ea8:	0685                	addi	a3,a3,1
    80000eaa:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000eac:	00054783          	lbu	a5,0(a0)
    80000eb0:	0005c703          	lbu	a4,0(a1)
    80000eb4:	00e79863          	bne	a5,a4,80000ec4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000eb8:	0505                	addi	a0,a0,1
    80000eba:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ebc:	fed518e3          	bne	a0,a3,80000eac <memcmp+0x14>
  }

  return 0;
    80000ec0:	4501                	li	a0,0
    80000ec2:	a019                	j	80000ec8 <memcmp+0x30>
      return *s1 - *s2;
    80000ec4:	40e7853b          	subw	a0,a5,a4
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  return 0;
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <memcmp+0x30>

0000000080000ed2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e422                	sd	s0,8(sp)
    80000ed6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ed8:	c205                	beqz	a2,80000ef8 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000eda:	02a5e263          	bltu	a1,a0,80000efe <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000ede:	1602                	slli	a2,a2,0x20
    80000ee0:	9201                	srli	a2,a2,0x20
    80000ee2:	00c587b3          	add	a5,a1,a2
{
    80000ee6:	872a                	mv	a4,a0
      *d++ = *s++;
    80000ee8:	0585                	addi	a1,a1,1
    80000eea:	0705                	addi	a4,a4,1
    80000eec:	fff5c683          	lbu	a3,-1(a1)
    80000ef0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000ef4:	fef59ae3          	bne	a1,a5,80000ee8 <memmove+0x16>

  return dst;
}
    80000ef8:	6422                	ld	s0,8(sp)
    80000efa:	0141                	addi	sp,sp,16
    80000efc:	8082                	ret
  if(s < d && s + n > d){
    80000efe:	02061693          	slli	a3,a2,0x20
    80000f02:	9281                	srli	a3,a3,0x20
    80000f04:	00d58733          	add	a4,a1,a3
    80000f08:	fce57be3          	bgeu	a0,a4,80000ede <memmove+0xc>
    d += n;
    80000f0c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f0e:	fff6079b          	addiw	a5,a2,-1
    80000f12:	1782                	slli	a5,a5,0x20
    80000f14:	9381                	srli	a5,a5,0x20
    80000f16:	fff7c793          	not	a5,a5
    80000f1a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f1c:	177d                	addi	a4,a4,-1
    80000f1e:	16fd                	addi	a3,a3,-1
    80000f20:	00074603          	lbu	a2,0(a4)
    80000f24:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f28:	fee79ae3          	bne	a5,a4,80000f1c <memmove+0x4a>
    80000f2c:	b7f1                	j	80000ef8 <memmove+0x26>

0000000080000f2e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f2e:	1141                	addi	sp,sp,-16
    80000f30:	e406                	sd	ra,8(sp)
    80000f32:	e022                	sd	s0,0(sp)
    80000f34:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f36:	00000097          	auipc	ra,0x0
    80000f3a:	f9c080e7          	jalr	-100(ra) # 80000ed2 <memmove>
}
    80000f3e:	60a2                	ld	ra,8(sp)
    80000f40:	6402                	ld	s0,0(sp)
    80000f42:	0141                	addi	sp,sp,16
    80000f44:	8082                	ret

0000000080000f46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    80000f46:	1141                	addi	sp,sp,-16
    80000f48:	e422                	sd	s0,8(sp)
    80000f4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    80000f4c:	00054783          	lbu	a5,0(a0)
    80000f50:	cb91                	beqz	a5,80000f64 <strcmp+0x1e>
    80000f52:	0005c703          	lbu	a4,0(a1)
    80000f56:	00f71763          	bne	a4,a5,80000f64 <strcmp+0x1e>
    p++, q++;
    80000f5a:	0505                	addi	a0,a0,1
    80000f5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    80000f5e:	00054783          	lbu	a5,0(a0)
    80000f62:	fbe5                	bnez	a5,80000f52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    80000f64:	0005c503          	lbu	a0,0(a1)
}
    80000f68:	40a7853b          	subw	a0,a5,a0
    80000f6c:	6422                	ld	s0,8(sp)
    80000f6e:	0141                	addi	sp,sp,16
    80000f70:	8082                	ret

0000000080000f72 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f72:	1141                	addi	sp,sp,-16
    80000f74:	e422                	sd	s0,8(sp)
    80000f76:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f78:	ce11                	beqz	a2,80000f94 <strncmp+0x22>
    80000f7a:	00054783          	lbu	a5,0(a0)
    80000f7e:	cf89                	beqz	a5,80000f98 <strncmp+0x26>
    80000f80:	0005c703          	lbu	a4,0(a1)
    80000f84:	00f71a63          	bne	a4,a5,80000f98 <strncmp+0x26>
    n--, p++, q++;
    80000f88:	367d                	addiw	a2,a2,-1
    80000f8a:	0505                	addi	a0,a0,1
    80000f8c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f8e:	f675                	bnez	a2,80000f7a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f90:	4501                	li	a0,0
    80000f92:	a809                	j	80000fa4 <strncmp+0x32>
    80000f94:	4501                	li	a0,0
    80000f96:	a039                	j	80000fa4 <strncmp+0x32>
  if(n == 0)
    80000f98:	ca09                	beqz	a2,80000faa <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f9a:	00054503          	lbu	a0,0(a0)
    80000f9e:	0005c783          	lbu	a5,0(a1)
    80000fa2:	9d1d                	subw	a0,a0,a5
}
    80000fa4:	6422                	ld	s0,8(sp)
    80000fa6:	0141                	addi	sp,sp,16
    80000fa8:	8082                	ret
    return 0;
    80000faa:	4501                	li	a0,0
    80000fac:	bfe5                	j	80000fa4 <strncmp+0x32>

0000000080000fae <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fae:	1141                	addi	sp,sp,-16
    80000fb0:	e422                	sd	s0,8(sp)
    80000fb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fb4:	872a                	mv	a4,a0
    80000fb6:	8832                	mv	a6,a2
    80000fb8:	367d                	addiw	a2,a2,-1
    80000fba:	01005963          	blez	a6,80000fcc <strncpy+0x1e>
    80000fbe:	0705                	addi	a4,a4,1
    80000fc0:	0005c783          	lbu	a5,0(a1)
    80000fc4:	fef70fa3          	sb	a5,-1(a4)
    80000fc8:	0585                	addi	a1,a1,1
    80000fca:	f7f5                	bnez	a5,80000fb6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fcc:	86ba                	mv	a3,a4
    80000fce:	00c05c63          	blez	a2,80000fe6 <strncpy+0x38>
    *s++ = 0;
    80000fd2:	0685                	addi	a3,a3,1
    80000fd4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fd8:	fff6c793          	not	a5,a3
    80000fdc:	9fb9                	addw	a5,a5,a4
    80000fde:	010787bb          	addw	a5,a5,a6
    80000fe2:	fef048e3          	bgtz	a5,80000fd2 <strncpy+0x24>
  return os;
}
    80000fe6:	6422                	ld	s0,8(sp)
    80000fe8:	0141                	addi	sp,sp,16
    80000fea:	8082                	ret

0000000080000fec <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fec:	1141                	addi	sp,sp,-16
    80000fee:	e422                	sd	s0,8(sp)
    80000ff0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ff2:	02c05363          	blez	a2,80001018 <safestrcpy+0x2c>
    80000ff6:	fff6069b          	addiw	a3,a2,-1
    80000ffa:	1682                	slli	a3,a3,0x20
    80000ffc:	9281                	srli	a3,a3,0x20
    80000ffe:	96ae                	add	a3,a3,a1
    80001000:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001002:	00d58963          	beq	a1,a3,80001014 <safestrcpy+0x28>
    80001006:	0585                	addi	a1,a1,1
    80001008:	0785                	addi	a5,a5,1
    8000100a:	fff5c703          	lbu	a4,-1(a1)
    8000100e:	fee78fa3          	sb	a4,-1(a5)
    80001012:	fb65                	bnez	a4,80001002 <safestrcpy+0x16>
    ;
  *s = 0;
    80001014:	00078023          	sb	zero,0(a5)
  return os;
}
    80001018:	6422                	ld	s0,8(sp)
    8000101a:	0141                	addi	sp,sp,16
    8000101c:	8082                	ret

000000008000101e <strlen>:

int
strlen(const char *s)
{
    8000101e:	1141                	addi	sp,sp,-16
    80001020:	e422                	sd	s0,8(sp)
    80001022:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001024:	00054783          	lbu	a5,0(a0)
    80001028:	cf91                	beqz	a5,80001044 <strlen+0x26>
    8000102a:	0505                	addi	a0,a0,1
    8000102c:	87aa                	mv	a5,a0
    8000102e:	4685                	li	a3,1
    80001030:	9e89                	subw	a3,a3,a0
    80001032:	00f6853b          	addw	a0,a3,a5
    80001036:	0785                	addi	a5,a5,1
    80001038:	fff7c703          	lbu	a4,-1(a5)
    8000103c:	fb7d                	bnez	a4,80001032 <strlen+0x14>
    ;
  return n;
}
    8000103e:	6422                	ld	s0,8(sp)
    80001040:	0141                	addi	sp,sp,16
    80001042:	8082                	ret
  for(n = 0; s[n]; n++)
    80001044:	4501                	li	a0,0
    80001046:	bfe5                	j	8000103e <strlen+0x20>

0000000080001048 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001048:	1141                	addi	sp,sp,-16
    8000104a:	e406                	sd	ra,8(sp)
    8000104c:	e022                	sd	s0,0(sp)
    8000104e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001050:	00001097          	auipc	ra,0x1
    80001054:	acc080e7          	jalr	-1332(ra) # 80001b1c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001058:	00008717          	auipc	a4,0x8
    8000105c:	eb070713          	addi	a4,a4,-336 # 80008f08 <started>
  if(cpuid() == 0){
    80001060:	c139                	beqz	a0,800010a6 <main+0x5e>
    while(started == 0)
    80001062:	431c                	lw	a5,0(a4)
    80001064:	2781                	sext.w	a5,a5
    80001066:	dff5                	beqz	a5,80001062 <main+0x1a>
      ;
    __sync_synchronize();
    80001068:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000106c:	00001097          	auipc	ra,0x1
    80001070:	ab0080e7          	jalr	-1360(ra) # 80001b1c <cpuid>
    80001074:	85aa                	mv	a1,a0
    80001076:	00007517          	auipc	a0,0x7
    8000107a:	1e250513          	addi	a0,a0,482 # 80008258 <digits+0xe8>
    8000107e:	fffff097          	auipc	ra,0xfffff
    80001082:	548080e7          	jalr	1352(ra) # 800005c6 <printf>
    kvminithart();    // turn on paging
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	1e8080e7          	jalr	488(ra) # 8000126e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000108e:	00001097          	auipc	ra,0x1
    80001092:	7c6080e7          	jalr	1990(ra) # 80002854 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001096:	00005097          	auipc	ra,0x5
    8000109a:	d0a080e7          	jalr	-758(ra) # 80005da0 <plicinithart>
  }

  scheduler();        
    8000109e:	00001097          	auipc	ra,0x1
    800010a2:	fbc080e7          	jalr	-68(ra) # 8000205a <scheduler>
    consoleinit();
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	3d0080e7          	jalr	976(ra) # 80000476 <consoleinit>
    printfinit();
    800010ae:	fffff097          	auipc	ra,0xfffff
    800010b2:	7ac080e7          	jalr	1964(ra) # 8000085a <printfinit>
    printf("\n");
    800010b6:	00007517          	auipc	a0,0x7
    800010ba:	14a50513          	addi	a0,a0,330 # 80008200 <digits+0x90>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	508080e7          	jalr	1288(ra) # 800005c6 <printf>
    printf("xv6 kernel is booting\n");
    800010c6:	00007517          	auipc	a0,0x7
    800010ca:	17a50513          	addi	a0,a0,378 # 80008240 <digits+0xd0>
    800010ce:	fffff097          	auipc	ra,0xfffff
    800010d2:	4f8080e7          	jalr	1272(ra) # 800005c6 <printf>
    printf("\n");
    800010d6:	00007517          	auipc	a0,0x7
    800010da:	12a50513          	addi	a0,a0,298 # 80008200 <digits+0x90>
    800010de:	fffff097          	auipc	ra,0xfffff
    800010e2:	4e8080e7          	jalr	1256(ra) # 800005c6 <printf>
    kinit();         // physical page allocator
    800010e6:	00000097          	auipc	ra,0x0
    800010ea:	920080e7          	jalr	-1760(ra) # 80000a06 <kinit>
    kvminit();       // create kernel page table
    800010ee:	00000097          	auipc	ra,0x0
    800010f2:	2be080e7          	jalr	702(ra) # 800013ac <kvminit>
    kvminithart();   // turn on paging
    800010f6:	00000097          	auipc	ra,0x0
    800010fa:	178080e7          	jalr	376(ra) # 8000126e <kvminithart>
    procinit();      // process table
    800010fe:	00001097          	auipc	ra,0x1
    80001102:	94e080e7          	jalr	-1714(ra) # 80001a4c <procinit>
    trapinit();      // trap vectors
    80001106:	00001097          	auipc	ra,0x1
    8000110a:	726080e7          	jalr	1830(ra) # 8000282c <trapinit>
    trapinithart();  // install kernel trap vector
    8000110e:	00001097          	auipc	ra,0x1
    80001112:	746080e7          	jalr	1862(ra) # 80002854 <trapinithart>
    plicinit();      // set up interrupt controller
    80001116:	00005097          	auipc	ra,0x5
    8000111a:	c74080e7          	jalr	-908(ra) # 80005d8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111e:	00005097          	auipc	ra,0x5
    80001122:	c82080e7          	jalr	-894(ra) # 80005da0 <plicinithart>
    binit();         // buffer cache
    80001126:	00002097          	auipc	ra,0x2
    8000112a:	e5a080e7          	jalr	-422(ra) # 80002f80 <binit>
    iinit();         // inode cache
    8000112e:	00002097          	auipc	ra,0x2
    80001132:	4ea080e7          	jalr	1258(ra) # 80003618 <iinit>
    fileinit();      // file table
    80001136:	00003097          	auipc	ra,0x3
    8000113a:	482080e7          	jalr	1154(ra) # 800045b8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000113e:	00005097          	auipc	ra,0x5
    80001142:	d5a080e7          	jalr	-678(ra) # 80005e98 <virtio_disk_init>
    userinit();      // first user process
    80001146:	00001097          	auipc	ra,0x1
    8000114a:	c82080e7          	jalr	-894(ra) # 80001dc8 <userinit>
    __sync_synchronize();
    8000114e:	0ff0000f          	fence
    started = 1;
    80001152:	4785                	li	a5,1
    80001154:	00008717          	auipc	a4,0x8
    80001158:	daf72a23          	sw	a5,-588(a4) # 80008f08 <started>
    8000115c:	b789                	j	8000109e <main+0x56>

000000008000115e <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000115e:	7139                	addi	sp,sp,-64
    80001160:	fc06                	sd	ra,56(sp)
    80001162:	f822                	sd	s0,48(sp)
    80001164:	f426                	sd	s1,40(sp)
    80001166:	f04a                	sd	s2,32(sp)
    80001168:	ec4e                	sd	s3,24(sp)
    8000116a:	e852                	sd	s4,16(sp)
    8000116c:	e456                	sd	s5,8(sp)
    8000116e:	e05a                	sd	s6,0(sp)
    80001170:	0080                	addi	s0,sp,64
    80001172:	84aa                	mv	s1,a0
    80001174:	89ae                	mv	s3,a1
    80001176:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001178:	57fd                	li	a5,-1
    8000117a:	83e9                	srli	a5,a5,0x1a
    8000117c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000117e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001180:	04b7f263          	bgeu	a5,a1,800011c4 <walk+0x66>
    panic("walk");
    80001184:	00007517          	auipc	a0,0x7
    80001188:	0ec50513          	addi	a0,a0,236 # 80008270 <digits+0x100>
    8000118c:	fffff097          	auipc	ra,0xfffff
    80001190:	3d8080e7          	jalr	984(ra) # 80000564 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001194:	060a8663          	beqz	s5,80001200 <walk+0xa2>
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	8aa080e7          	jalr	-1878(ra) # 80000a42 <kalloc>
    800011a0:	84aa                	mv	s1,a0
    800011a2:	c529                	beqz	a0,800011ec <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011a4:	6605                	lui	a2,0x1
    800011a6:	4581                	li	a1,0
    800011a8:	00000097          	auipc	ra,0x0
    800011ac:	cce080e7          	jalr	-818(ra) # 80000e76 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011b0:	00c4d793          	srli	a5,s1,0xc
    800011b4:	07aa                	slli	a5,a5,0xa
    800011b6:	0017e793          	ori	a5,a5,1
    800011ba:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011be:	3a5d                	addiw	s4,s4,-9
    800011c0:	036a0063          	beq	s4,s6,800011e0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011c4:	0149d933          	srl	s2,s3,s4
    800011c8:	1ff97913          	andi	s2,s2,511
    800011cc:	090e                	slli	s2,s2,0x3
    800011ce:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011d0:	00093483          	ld	s1,0(s2)
    800011d4:	0014f793          	andi	a5,s1,1
    800011d8:	dfd5                	beqz	a5,80001194 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011da:	80a9                	srli	s1,s1,0xa
    800011dc:	04b2                	slli	s1,s1,0xc
    800011de:	b7c5                	j	800011be <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011e0:	00c9d513          	srli	a0,s3,0xc
    800011e4:	1ff57513          	andi	a0,a0,511
    800011e8:	050e                	slli	a0,a0,0x3
    800011ea:	9526                	add	a0,a0,s1
}
    800011ec:	70e2                	ld	ra,56(sp)
    800011ee:	7442                	ld	s0,48(sp)
    800011f0:	74a2                	ld	s1,40(sp)
    800011f2:	7902                	ld	s2,32(sp)
    800011f4:	69e2                	ld	s3,24(sp)
    800011f6:	6a42                	ld	s4,16(sp)
    800011f8:	6aa2                	ld	s5,8(sp)
    800011fa:	6b02                	ld	s6,0(sp)
    800011fc:	6121                	addi	sp,sp,64
    800011fe:	8082                	ret
        return 0;
    80001200:	4501                	li	a0,0
    80001202:	b7ed                	j	800011ec <walk+0x8e>

0000000080001204 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80001204:	7179                	addi	sp,sp,-48
    80001206:	f406                	sd	ra,40(sp)
    80001208:	f022                	sd	s0,32(sp)
    8000120a:	ec26                	sd	s1,24(sp)
    8000120c:	e84a                	sd	s2,16(sp)
    8000120e:	e44e                	sd	s3,8(sp)
    80001210:	e052                	sd	s4,0(sp)
    80001212:	1800                	addi	s0,sp,48
    80001214:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001216:	84aa                	mv	s1,a0
    80001218:	6905                	lui	s2,0x1
    8000121a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000121c:	4985                	li	s3,1
    8000121e:	a821                	j	80001236 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001220:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001222:	0532                	slli	a0,a0,0xc
    80001224:	00000097          	auipc	ra,0x0
    80001228:	fe0080e7          	jalr	-32(ra) # 80001204 <freewalk>
      pagetable[i] = 0;
    8000122c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001230:	04a1                	addi	s1,s1,8
    80001232:	03248163          	beq	s1,s2,80001254 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001236:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001238:	00f57793          	andi	a5,a0,15
    8000123c:	ff3782e3          	beq	a5,s3,80001220 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001240:	8905                	andi	a0,a0,1
    80001242:	d57d                	beqz	a0,80001230 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001244:	00007517          	auipc	a0,0x7
    80001248:	03450513          	addi	a0,a0,52 # 80008278 <digits+0x108>
    8000124c:	fffff097          	auipc	ra,0xfffff
    80001250:	318080e7          	jalr	792(ra) # 80000564 <panic>
    }
  }
  kfree((void*)pagetable);
    80001254:	8552                	mv	a0,s4
    80001256:	fffff097          	auipc	ra,0xfffff
    8000125a:	6e6080e7          	jalr	1766(ra) # 8000093c <kfree>
}
    8000125e:	70a2                	ld	ra,40(sp)
    80001260:	7402                	ld	s0,32(sp)
    80001262:	64e2                	ld	s1,24(sp)
    80001264:	6942                	ld	s2,16(sp)
    80001266:	69a2                	ld	s3,8(sp)
    80001268:	6a02                	ld	s4,0(sp)
    8000126a:	6145                	addi	sp,sp,48
    8000126c:	8082                	ret

000000008000126e <kvminithart>:
{
    8000126e:	1141                	addi	sp,sp,-16
    80001270:	e422                	sd	s0,8(sp)
    80001272:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001274:	00008797          	auipc	a5,0x8
    80001278:	c9c7b783          	ld	a5,-868(a5) # 80008f10 <kernel_pagetable>
    8000127c:	83b1                	srli	a5,a5,0xc
    8000127e:	577d                	li	a4,-1
    80001280:	177e                	slli	a4,a4,0x3f
    80001282:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001284:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001288:	12000073          	sfence.vma
}
    8000128c:	6422                	ld	s0,8(sp)
    8000128e:	0141                	addi	sp,sp,16
    80001290:	8082                	ret

0000000080001292 <walkaddr>:
  if(va >= MAXVA)
    80001292:	57fd                	li	a5,-1
    80001294:	83e9                	srli	a5,a5,0x1a
    80001296:	00b7f463          	bgeu	a5,a1,8000129e <walkaddr+0xc>
    return 0;
    8000129a:	4501                	li	a0,0
}
    8000129c:	8082                	ret
{
    8000129e:	1141                	addi	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012a6:	4601                	li	a2,0
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	eb6080e7          	jalr	-330(ra) # 8000115e <walk>
  if(pte == 0)
    800012b0:	c105                	beqz	a0,800012d0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012b2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012b4:	0117f693          	andi	a3,a5,17
    800012b8:	4745                	li	a4,17
    return 0;
    800012ba:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012bc:	00e68663          	beq	a3,a4,800012c8 <walkaddr+0x36>
}
    800012c0:	60a2                	ld	ra,8(sp)
    800012c2:	6402                	ld	s0,0(sp)
    800012c4:	0141                	addi	sp,sp,16
    800012c6:	8082                	ret
  pa = PTE2PA(*pte);
    800012c8:	00a7d513          	srli	a0,a5,0xa
    800012cc:	0532                	slli	a0,a0,0xc
  return pa;
    800012ce:	bfcd                	j	800012c0 <walkaddr+0x2e>
    return 0;
    800012d0:	4501                	li	a0,0
    800012d2:	b7fd                	j	800012c0 <walkaddr+0x2e>

00000000800012d4 <mappages>:
{
    800012d4:	715d                	addi	sp,sp,-80
    800012d6:	e486                	sd	ra,72(sp)
    800012d8:	e0a2                	sd	s0,64(sp)
    800012da:	fc26                	sd	s1,56(sp)
    800012dc:	f84a                	sd	s2,48(sp)
    800012de:	f44e                	sd	s3,40(sp)
    800012e0:	f052                	sd	s4,32(sp)
    800012e2:	ec56                	sd	s5,24(sp)
    800012e4:	e85a                	sd	s6,16(sp)
    800012e6:	e45e                	sd	s7,8(sp)
    800012e8:	0880                	addi	s0,sp,80
  if(size == 0)
    800012ea:	c639                	beqz	a2,80001338 <mappages+0x64>
    800012ec:	8aaa                	mv	s5,a0
    800012ee:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    800012f0:	77fd                	lui	a5,0xfffff
    800012f2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800012f6:	15fd                	addi	a1,a1,-1
    800012f8:	00c589b3          	add	s3,a1,a2
    800012fc:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001300:	8952                	mv	s2,s4
    80001302:	41468a33          	sub	s4,a3,s4
    a += PGSIZE;
    80001306:	6b85                	lui	s7,0x1
    80001308:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000130c:	4605                	li	a2,1
    8000130e:	85ca                	mv	a1,s2
    80001310:	8556                	mv	a0,s5
    80001312:	00000097          	auipc	ra,0x0
    80001316:	e4c080e7          	jalr	-436(ra) # 8000115e <walk>
    8000131a:	cd1d                	beqz	a0,80001358 <mappages+0x84>
    if(*pte & PTE_V)
    8000131c:	611c                	ld	a5,0(a0)
    8000131e:	8b85                	andi	a5,a5,1
    80001320:	e785                	bnez	a5,80001348 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001322:	80b1                	srli	s1,s1,0xc
    80001324:	04aa                	slli	s1,s1,0xa
    80001326:	0164e4b3          	or	s1,s1,s6
    8000132a:	0014e493          	ori	s1,s1,1
    8000132e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001330:	05390063          	beq	s2,s3,80001370 <mappages+0x9c>
    a += PGSIZE;
    80001334:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001336:	bfc9                	j	80001308 <mappages+0x34>
    panic("mappages: size");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	f5050513          	addi	a0,a0,-176 # 80008288 <digits+0x118>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	224080e7          	jalr	548(ra) # 80000564 <panic>
      panic("mappages: remap");
    80001348:	00007517          	auipc	a0,0x7
    8000134c:	f5050513          	addi	a0,a0,-176 # 80008298 <digits+0x128>
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	214080e7          	jalr	532(ra) # 80000564 <panic>
      return -1;
    80001358:	557d                	li	a0,-1
}
    8000135a:	60a6                	ld	ra,72(sp)
    8000135c:	6406                	ld	s0,64(sp)
    8000135e:	74e2                	ld	s1,56(sp)
    80001360:	7942                	ld	s2,48(sp)
    80001362:	79a2                	ld	s3,40(sp)
    80001364:	7a02                	ld	s4,32(sp)
    80001366:	6ae2                	ld	s5,24(sp)
    80001368:	6b42                	ld	s6,16(sp)
    8000136a:	6ba2                	ld	s7,8(sp)
    8000136c:	6161                	addi	sp,sp,80
    8000136e:	8082                	ret
  return 0;
    80001370:	4501                	li	a0,0
    80001372:	b7e5                	j	8000135a <mappages+0x86>

0000000080001374 <kvmmap>:
{
    80001374:	1141                	addi	sp,sp,-16
    80001376:	e406                	sd	ra,8(sp)
    80001378:	e022                	sd	s0,0(sp)
    8000137a:	0800                	addi	s0,sp,16
    8000137c:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000137e:	86ae                	mv	a3,a1
    80001380:	85aa                	mv	a1,a0
    80001382:	00008517          	auipc	a0,0x8
    80001386:	b8e53503          	ld	a0,-1138(a0) # 80008f10 <kernel_pagetable>
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	f4a080e7          	jalr	-182(ra) # 800012d4 <mappages>
    80001392:	e509                	bnez	a0,8000139c <kvmmap+0x28>
}
    80001394:	60a2                	ld	ra,8(sp)
    80001396:	6402                	ld	s0,0(sp)
    80001398:	0141                	addi	sp,sp,16
    8000139a:	8082                	ret
    panic("kvmmap");
    8000139c:	00007517          	auipc	a0,0x7
    800013a0:	f0c50513          	addi	a0,a0,-244 # 800082a8 <digits+0x138>
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	1c0080e7          	jalr	448(ra) # 80000564 <panic>

00000000800013ac <kvminit>:
{
    800013ac:	1101                	addi	sp,sp,-32
    800013ae:	ec06                	sd	ra,24(sp)
    800013b0:	e822                	sd	s0,16(sp)
    800013b2:	e426                	sd	s1,8(sp)
    800013b4:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	68c080e7          	jalr	1676(ra) # 80000a42 <kalloc>
    800013be:	00008797          	auipc	a5,0x8
    800013c2:	b4a7b923          	sd	a0,-1198(a5) # 80008f10 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    800013c6:	6605                	lui	a2,0x1
    800013c8:	4581                	li	a1,0
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	aac080e7          	jalr	-1364(ra) # 80000e76 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013d2:	4699                	li	a3,6
    800013d4:	6605                	lui	a2,0x1
    800013d6:	100005b7          	lui	a1,0x10000
    800013da:	10000537          	lui	a0,0x10000
    800013de:	00000097          	auipc	ra,0x0
    800013e2:	f96080e7          	jalr	-106(ra) # 80001374 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800013e6:	4699                	li	a3,6
    800013e8:	6605                	lui	a2,0x1
    800013ea:	100015b7          	lui	a1,0x10001
    800013ee:	10001537          	lui	a0,0x10001
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	f82080e7          	jalr	-126(ra) # 80001374 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800013fa:	4699                	li	a3,6
    800013fc:	00400637          	lui	a2,0x400
    80001400:	0c0005b7          	lui	a1,0xc000
    80001404:	0c000537          	lui	a0,0xc000
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	f6c080e7          	jalr	-148(ra) # 80001374 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001410:	00007497          	auipc	s1,0x7
    80001414:	bf048493          	addi	s1,s1,-1040 # 80008000 <etext>
    80001418:	46a9                	li	a3,10
    8000141a:	80007617          	auipc	a2,0x80007
    8000141e:	be660613          	addi	a2,a2,-1050 # 8000 <_entry-0x7fff8000>
    80001422:	4585                	li	a1,1
    80001424:	05fe                	slli	a1,a1,0x1f
    80001426:	852e                	mv	a0,a1
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	f4c080e7          	jalr	-180(ra) # 80001374 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001430:	4699                	li	a3,6
    80001432:	4645                	li	a2,17
    80001434:	066e                	slli	a2,a2,0x1b
    80001436:	8e05                	sub	a2,a2,s1
    80001438:	85a6                	mv	a1,s1
    8000143a:	8526                	mv	a0,s1
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	f38080e7          	jalr	-200(ra) # 80001374 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001444:	46a9                	li	a3,10
    80001446:	6605                	lui	a2,0x1
    80001448:	00006597          	auipc	a1,0x6
    8000144c:	bb858593          	addi	a1,a1,-1096 # 80007000 <_trampoline>
    80001450:	04000537          	lui	a0,0x4000
    80001454:	157d                	addi	a0,a0,-1
    80001456:	0532                	slli	a0,a0,0xc
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f1c080e7          	jalr	-228(ra) # 80001374 <kvmmap>
}
    80001460:	60e2                	ld	ra,24(sp)
    80001462:	6442                	ld	s0,16(sp)
    80001464:	64a2                	ld	s1,8(sp)
    80001466:	6105                	addi	sp,sp,32
    80001468:	8082                	ret

000000008000146a <uvmunmap>:
{
    8000146a:	715d                	addi	sp,sp,-80
    8000146c:	e486                	sd	ra,72(sp)
    8000146e:	e0a2                	sd	s0,64(sp)
    80001470:	fc26                	sd	s1,56(sp)
    80001472:	f84a                	sd	s2,48(sp)
    80001474:	f44e                	sd	s3,40(sp)
    80001476:	f052                	sd	s4,32(sp)
    80001478:	ec56                	sd	s5,24(sp)
    8000147a:	e85a                	sd	s6,16(sp)
    8000147c:	e45e                	sd	s7,8(sp)
    8000147e:	0880                	addi	s0,sp,80
    80001480:	8a2a                	mv	s4,a0
    80001482:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    80001484:	77fd                	lui	a5,0xfffff
    80001486:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000148a:	167d                	addi	a2,a2,-1
    8000148c:	00b609b3          	add	s3,a2,a1
    80001490:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    80001494:	4b05                	li	s6,1
    a += PGSIZE;
    80001496:	6b85                	lui	s7,0x1
    80001498:	a0b9                	j	800014e6 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    8000149a:	00007517          	auipc	a0,0x7
    8000149e:	e1650513          	addi	a0,a0,-490 # 800082b0 <digits+0x140>
    800014a2:	fffff097          	auipc	ra,0xfffff
    800014a6:	0c2080e7          	jalr	194(ra) # 80000564 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800014aa:	85ca                	mv	a1,s2
    800014ac:	00007517          	auipc	a0,0x7
    800014b0:	e1450513          	addi	a0,a0,-492 # 800082c0 <digits+0x150>
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	112080e7          	jalr	274(ra) # 800005c6 <printf>
      panic("uvmunmap: not mapped");
    800014bc:	00007517          	auipc	a0,0x7
    800014c0:	e1450513          	addi	a0,a0,-492 # 800082d0 <digits+0x160>
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	0a0080e7          	jalr	160(ra) # 80000564 <panic>
      panic("uvmunmap: not a leaf");
    800014cc:	00007517          	auipc	a0,0x7
    800014d0:	e1c50513          	addi	a0,a0,-484 # 800082e8 <digits+0x178>
    800014d4:	fffff097          	auipc	ra,0xfffff
    800014d8:	090080e7          	jalr	144(ra) # 80000564 <panic>
    *pte = 0;
    800014dc:	0004b023          	sd	zero,0(s1)
    if(a == last)
    800014e0:	03390e63          	beq	s2,s3,8000151c <uvmunmap+0xb2>
    a += PGSIZE;
    800014e4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    800014e6:	4601                	li	a2,0
    800014e8:	85ca                	mv	a1,s2
    800014ea:	8552                	mv	a0,s4
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	c72080e7          	jalr	-910(ra) # 8000115e <walk>
    800014f4:	84aa                	mv	s1,a0
    800014f6:	d155                	beqz	a0,8000149a <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    800014f8:	6110                	ld	a2,0(a0)
    800014fa:	00167793          	andi	a5,a2,1
    800014fe:	d7d5                	beqz	a5,800014aa <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001500:	3ff67793          	andi	a5,a2,1023
    80001504:	fd6784e3          	beq	a5,s6,800014cc <uvmunmap+0x62>
    if(do_free){
    80001508:	fc0a8ae3          	beqz	s5,800014dc <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    8000150c:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    8000150e:	00c61513          	slli	a0,a2,0xc
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	42a080e7          	jalr	1066(ra) # 8000093c <kfree>
    8000151a:	b7c9                	j	800014dc <uvmunmap+0x72>
}
    8000151c:	60a6                	ld	ra,72(sp)
    8000151e:	6406                	ld	s0,64(sp)
    80001520:	74e2                	ld	s1,56(sp)
    80001522:	7942                	ld	s2,48(sp)
    80001524:	79a2                	ld	s3,40(sp)
    80001526:	7a02                	ld	s4,32(sp)
    80001528:	6ae2                	ld	s5,24(sp)
    8000152a:	6b42                	ld	s6,16(sp)
    8000152c:	6ba2                	ld	s7,8(sp)
    8000152e:	6161                	addi	sp,sp,80
    80001530:	8082                	ret

0000000080001532 <uvmcreate>:
{
    80001532:	1101                	addi	sp,sp,-32
    80001534:	ec06                	sd	ra,24(sp)
    80001536:	e822                	sd	s0,16(sp)
    80001538:	e426                	sd	s1,8(sp)
    8000153a:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000153c:	fffff097          	auipc	ra,0xfffff
    80001540:	506080e7          	jalr	1286(ra) # 80000a42 <kalloc>
  if(pagetable == 0)
    80001544:	cd11                	beqz	a0,80001560 <uvmcreate+0x2e>
    80001546:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001548:	6605                	lui	a2,0x1
    8000154a:	4581                	li	a1,0
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	92a080e7          	jalr	-1750(ra) # 80000e76 <memset>
}
    80001554:	8526                	mv	a0,s1
    80001556:	60e2                	ld	ra,24(sp)
    80001558:	6442                	ld	s0,16(sp)
    8000155a:	64a2                	ld	s1,8(sp)
    8000155c:	6105                	addi	sp,sp,32
    8000155e:	8082                	ret
    panic("uvmcreate: out of memory");
    80001560:	00007517          	auipc	a0,0x7
    80001564:	da050513          	addi	a0,a0,-608 # 80008300 <digits+0x190>
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	ffc080e7          	jalr	-4(ra) # 80000564 <panic>

0000000080001570 <uvminit>:
{
    80001570:	7179                	addi	sp,sp,-48
    80001572:	f406                	sd	ra,40(sp)
    80001574:	f022                	sd	s0,32(sp)
    80001576:	ec26                	sd	s1,24(sp)
    80001578:	e84a                	sd	s2,16(sp)
    8000157a:	e44e                	sd	s3,8(sp)
    8000157c:	e052                	sd	s4,0(sp)
    8000157e:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80001580:	6785                	lui	a5,0x1
    80001582:	04f67863          	bgeu	a2,a5,800015d2 <uvminit+0x62>
    80001586:	8a2a                	mv	s4,a0
    80001588:	89ae                	mv	s3,a1
    8000158a:	84b2                	mv	s1,a2
  mem = kalloc();
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4b6080e7          	jalr	1206(ra) # 80000a42 <kalloc>
    80001594:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001596:	6605                	lui	a2,0x1
    80001598:	4581                	li	a1,0
    8000159a:	00000097          	auipc	ra,0x0
    8000159e:	8dc080e7          	jalr	-1828(ra) # 80000e76 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800015a2:	4779                	li	a4,30
    800015a4:	86ca                	mv	a3,s2
    800015a6:	6605                	lui	a2,0x1
    800015a8:	4581                	li	a1,0
    800015aa:	8552                	mv	a0,s4
    800015ac:	00000097          	auipc	ra,0x0
    800015b0:	d28080e7          	jalr	-728(ra) # 800012d4 <mappages>
  memmove(mem, src, sz);
    800015b4:	8626                	mv	a2,s1
    800015b6:	85ce                	mv	a1,s3
    800015b8:	854a                	mv	a0,s2
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	918080e7          	jalr	-1768(ra) # 80000ed2 <memmove>
}
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	64e2                	ld	s1,24(sp)
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	69a2                	ld	s3,8(sp)
    800015cc:	6a02                	ld	s4,0(sp)
    800015ce:	6145                	addi	sp,sp,48
    800015d0:	8082                	ret
    panic("inituvm: more than a page");
    800015d2:	00007517          	auipc	a0,0x7
    800015d6:	d4e50513          	addi	a0,a0,-690 # 80008320 <digits+0x1b0>
    800015da:	fffff097          	auipc	ra,0xfffff
    800015de:	f8a080e7          	jalr	-118(ra) # 80000564 <panic>

00000000800015e2 <uvmdealloc>:
{
    800015e2:	1101                	addi	sp,sp,-32
    800015e4:	ec06                	sd	ra,24(sp)
    800015e6:	e822                	sd	s0,16(sp)
    800015e8:	e426                	sd	s1,8(sp)
    800015ea:	1000                	addi	s0,sp,32
    return oldsz;
    800015ec:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800015ee:	00b67d63          	bgeu	a2,a1,80001608 <uvmdealloc+0x26>
    800015f2:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    800015f4:	6785                	lui	a5,0x1
    800015f6:	17fd                	addi	a5,a5,-1
    800015f8:	00f60733          	add	a4,a2,a5
    800015fc:	76fd                	lui	a3,0xfffff
    800015fe:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001600:	97ae                	add	a5,a5,a1
    80001602:	8ff5                	and	a5,a5,a3
    80001604:	00f76863          	bltu	a4,a5,80001614 <uvmdealloc+0x32>
}
    80001608:	8526                	mv	a0,s1
    8000160a:	60e2                	ld	ra,24(sp)
    8000160c:	6442                	ld	s0,16(sp)
    8000160e:	64a2                	ld	s1,8(sp)
    80001610:	6105                	addi	sp,sp,32
    80001612:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001614:	4685                	li	a3,1
    80001616:	40e58633          	sub	a2,a1,a4
    8000161a:	85ba                	mv	a1,a4
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	e4e080e7          	jalr	-434(ra) # 8000146a <uvmunmap>
    80001624:	b7d5                	j	80001608 <uvmdealloc+0x26>

0000000080001626 <uvmalloc>:
  if(newsz < oldsz)
    80001626:	0ab66163          	bltu	a2,a1,800016c8 <uvmalloc+0xa2>
{
    8000162a:	7139                	addi	sp,sp,-64
    8000162c:	fc06                	sd	ra,56(sp)
    8000162e:	f822                	sd	s0,48(sp)
    80001630:	f426                	sd	s1,40(sp)
    80001632:	f04a                	sd	s2,32(sp)
    80001634:	ec4e                	sd	s3,24(sp)
    80001636:	e852                	sd	s4,16(sp)
    80001638:	e456                	sd	s5,8(sp)
    8000163a:	0080                	addi	s0,sp,64
    8000163c:	8aaa                	mv	s5,a0
    8000163e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001640:	6985                	lui	s3,0x1
    80001642:	19fd                	addi	s3,s3,-1
    80001644:	95ce                	add	a1,a1,s3
    80001646:	79fd                	lui	s3,0xfffff
    80001648:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000164c:	08c9f063          	bgeu	s3,a2,800016cc <uvmalloc+0xa6>
    80001650:	894e                	mv	s2,s3
    mem = kalloc();
    80001652:	fffff097          	auipc	ra,0xfffff
    80001656:	3f0080e7          	jalr	1008(ra) # 80000a42 <kalloc>
    8000165a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000165c:	c51d                	beqz	a0,8000168a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000165e:	6605                	lui	a2,0x1
    80001660:	4581                	li	a1,0
    80001662:	00000097          	auipc	ra,0x0
    80001666:	814080e7          	jalr	-2028(ra) # 80000e76 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000166a:	4779                	li	a4,30
    8000166c:	86a6                	mv	a3,s1
    8000166e:	6605                	lui	a2,0x1
    80001670:	85ca                	mv	a1,s2
    80001672:	8556                	mv	a0,s5
    80001674:	00000097          	auipc	ra,0x0
    80001678:	c60080e7          	jalr	-928(ra) # 800012d4 <mappages>
    8000167c:	e905                	bnez	a0,800016ac <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000167e:	6785                	lui	a5,0x1
    80001680:	993e                	add	s2,s2,a5
    80001682:	fd4968e3          	bltu	s2,s4,80001652 <uvmalloc+0x2c>
  return newsz;
    80001686:	8552                	mv	a0,s4
    80001688:	a809                	j	8000169a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000168a:	864e                	mv	a2,s3
    8000168c:	85ca                	mv	a1,s2
    8000168e:	8556                	mv	a0,s5
    80001690:	00000097          	auipc	ra,0x0
    80001694:	f52080e7          	jalr	-174(ra) # 800015e2 <uvmdealloc>
      return 0;
    80001698:	4501                	li	a0,0
}
    8000169a:	70e2                	ld	ra,56(sp)
    8000169c:	7442                	ld	s0,48(sp)
    8000169e:	74a2                	ld	s1,40(sp)
    800016a0:	7902                	ld	s2,32(sp)
    800016a2:	69e2                	ld	s3,24(sp)
    800016a4:	6a42                	ld	s4,16(sp)
    800016a6:	6aa2                	ld	s5,8(sp)
    800016a8:	6121                	addi	sp,sp,64
    800016aa:	8082                	ret
      kfree(mem);
    800016ac:	8526                	mv	a0,s1
    800016ae:	fffff097          	auipc	ra,0xfffff
    800016b2:	28e080e7          	jalr	654(ra) # 8000093c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800016b6:	864e                	mv	a2,s3
    800016b8:	85ca                	mv	a1,s2
    800016ba:	8556                	mv	a0,s5
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	f26080e7          	jalr	-218(ra) # 800015e2 <uvmdealloc>
      return 0;
    800016c4:	4501                	li	a0,0
    800016c6:	bfd1                	j	8000169a <uvmalloc+0x74>
    return oldsz;
    800016c8:	852e                	mv	a0,a1
}
    800016ca:	8082                	ret
  return newsz;
    800016cc:	8532                	mv	a0,a2
    800016ce:	b7f1                	j	8000169a <uvmalloc+0x74>

00000000800016d0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016d0:	1101                	addi	sp,sp,-32
    800016d2:	ec06                	sd	ra,24(sp)
    800016d4:	e822                	sd	s0,16(sp)
    800016d6:	e426                	sd	s1,8(sp)
    800016d8:	1000                	addi	s0,sp,32
    800016da:	84aa                	mv	s1,a0
    800016dc:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    800016de:	4685                	li	a3,1
    800016e0:	4581                	li	a1,0
    800016e2:	00000097          	auipc	ra,0x0
    800016e6:	d88080e7          	jalr	-632(ra) # 8000146a <uvmunmap>
  freewalk(pagetable);
    800016ea:	8526                	mv	a0,s1
    800016ec:	00000097          	auipc	ra,0x0
    800016f0:	b18080e7          	jalr	-1256(ra) # 80001204 <freewalk>
}
    800016f4:	60e2                	ld	ra,24(sp)
    800016f6:	6442                	ld	s0,16(sp)
    800016f8:	64a2                	ld	s1,8(sp)
    800016fa:	6105                	addi	sp,sp,32
    800016fc:	8082                	ret

00000000800016fe <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016fe:	c671                	beqz	a2,800017ca <uvmcopy+0xcc>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	0880                	addi	s0,sp,80
    80001716:	8b2a                	mv	s6,a0
    80001718:	8aae                	mv	s5,a1
    8000171a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000171c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000171e:	4601                	li	a2,0
    80001720:	85ce                	mv	a1,s3
    80001722:	855a                	mv	a0,s6
    80001724:	00000097          	auipc	ra,0x0
    80001728:	a3a080e7          	jalr	-1478(ra) # 8000115e <walk>
    8000172c:	c531                	beqz	a0,80001778 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000172e:	6118                	ld	a4,0(a0)
    80001730:	00177793          	andi	a5,a4,1
    80001734:	cbb1                	beqz	a5,80001788 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001736:	00a75593          	srli	a1,a4,0xa
    8000173a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000173e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	300080e7          	jalr	768(ra) # 80000a42 <kalloc>
    8000174a:	892a                	mv	s2,a0
    8000174c:	c939                	beqz	a0,800017a2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000174e:	6605                	lui	a2,0x1
    80001750:	85de                	mv	a1,s7
    80001752:	fffff097          	auipc	ra,0xfffff
    80001756:	780080e7          	jalr	1920(ra) # 80000ed2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000175a:	8726                	mv	a4,s1
    8000175c:	86ca                	mv	a3,s2
    8000175e:	6605                	lui	a2,0x1
    80001760:	85ce                	mv	a1,s3
    80001762:	8556                	mv	a0,s5
    80001764:	00000097          	auipc	ra,0x0
    80001768:	b70080e7          	jalr	-1168(ra) # 800012d4 <mappages>
    8000176c:	e515                	bnez	a0,80001798 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000176e:	6785                	lui	a5,0x1
    80001770:	99be                	add	s3,s3,a5
    80001772:	fb49e6e3          	bltu	s3,s4,8000171e <uvmcopy+0x20>
    80001776:	a83d                	j	800017b4 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    80001778:	00007517          	auipc	a0,0x7
    8000177c:	bc850513          	addi	a0,a0,-1080 # 80008340 <digits+0x1d0>
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	de4080e7          	jalr	-540(ra) # 80000564 <panic>
      panic("uvmcopy: page not present");
    80001788:	00007517          	auipc	a0,0x7
    8000178c:	bd850513          	addi	a0,a0,-1064 # 80008360 <digits+0x1f0>
    80001790:	fffff097          	auipc	ra,0xfffff
    80001794:	dd4080e7          	jalr	-556(ra) # 80000564 <panic>
      kfree(mem);
    80001798:	854a                	mv	a0,s2
    8000179a:	fffff097          	auipc	ra,0xfffff
    8000179e:	1a2080e7          	jalr	418(ra) # 8000093c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800017a2:	4685                	li	a3,1
    800017a4:	864e                	mv	a2,s3
    800017a6:	4581                	li	a1,0
    800017a8:	8556                	mv	a0,s5
    800017aa:	00000097          	auipc	ra,0x0
    800017ae:	cc0080e7          	jalr	-832(ra) # 8000146a <uvmunmap>
  return -1;
    800017b2:	557d                	li	a0,-1
}
    800017b4:	60a6                	ld	ra,72(sp)
    800017b6:	6406                	ld	s0,64(sp)
    800017b8:	74e2                	ld	s1,56(sp)
    800017ba:	7942                	ld	s2,48(sp)
    800017bc:	79a2                	ld	s3,40(sp)
    800017be:	7a02                	ld	s4,32(sp)
    800017c0:	6ae2                	ld	s5,24(sp)
    800017c2:	6b42                	ld	s6,16(sp)
    800017c4:	6ba2                	ld	s7,8(sp)
    800017c6:	6161                	addi	sp,sp,80
    800017c8:	8082                	ret
  return 0;
    800017ca:	4501                	li	a0,0
}
    800017cc:	8082                	ret

00000000800017ce <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017ce:	1141                	addi	sp,sp,-16
    800017d0:	e406                	sd	ra,8(sp)
    800017d2:	e022                	sd	s0,0(sp)
    800017d4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017d6:	4601                	li	a2,0
    800017d8:	00000097          	auipc	ra,0x0
    800017dc:	986080e7          	jalr	-1658(ra) # 8000115e <walk>
  if(pte == 0)
    800017e0:	c901                	beqz	a0,800017f0 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017e2:	611c                	ld	a5,0(a0)
    800017e4:	9bbd                	andi	a5,a5,-17
    800017e6:	e11c                	sd	a5,0(a0)
}
    800017e8:	60a2                	ld	ra,8(sp)
    800017ea:	6402                	ld	s0,0(sp)
    800017ec:	0141                	addi	sp,sp,16
    800017ee:	8082                	ret
    panic("uvmclear");
    800017f0:	00007517          	auipc	a0,0x7
    800017f4:	b9050513          	addi	a0,a0,-1136 # 80008380 <digits+0x210>
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	d6c080e7          	jalr	-660(ra) # 80000564 <panic>

0000000080001800 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001800:	c6bd                	beqz	a3,8000186e <copyout+0x6e>
{
    80001802:	715d                	addi	sp,sp,-80
    80001804:	e486                	sd	ra,72(sp)
    80001806:	e0a2                	sd	s0,64(sp)
    80001808:	fc26                	sd	s1,56(sp)
    8000180a:	f84a                	sd	s2,48(sp)
    8000180c:	f44e                	sd	s3,40(sp)
    8000180e:	f052                	sd	s4,32(sp)
    80001810:	ec56                	sd	s5,24(sp)
    80001812:	e85a                	sd	s6,16(sp)
    80001814:	e45e                	sd	s7,8(sp)
    80001816:	e062                	sd	s8,0(sp)
    80001818:	0880                	addi	s0,sp,80
    8000181a:	8b2a                	mv	s6,a0
    8000181c:	8c2e                	mv	s8,a1
    8000181e:	8a32                	mv	s4,a2
    80001820:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001822:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001824:	6a85                	lui	s5,0x1
    80001826:	a015                	j	8000184a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001828:	9562                	add	a0,a0,s8
    8000182a:	0004861b          	sext.w	a2,s1
    8000182e:	85d2                	mv	a1,s4
    80001830:	41250533          	sub	a0,a0,s2
    80001834:	fffff097          	auipc	ra,0xfffff
    80001838:	69e080e7          	jalr	1694(ra) # 80000ed2 <memmove>

    len -= n;
    8000183c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001840:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001842:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001846:	02098263          	beqz	s3,8000186a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000184a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000184e:	85ca                	mv	a1,s2
    80001850:	855a                	mv	a0,s6
    80001852:	00000097          	auipc	ra,0x0
    80001856:	a40080e7          	jalr	-1472(ra) # 80001292 <walkaddr>
    if(pa0 == 0)
    8000185a:	cd01                	beqz	a0,80001872 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000185c:	418904b3          	sub	s1,s2,s8
    80001860:	94d6                	add	s1,s1,s5
    if(n > len)
    80001862:	fc99f3e3          	bgeu	s3,s1,80001828 <copyout+0x28>
    80001866:	84ce                	mv	s1,s3
    80001868:	b7c1                	j	80001828 <copyout+0x28>
  }
  return 0;
    8000186a:	4501                	li	a0,0
    8000186c:	a021                	j	80001874 <copyout+0x74>
    8000186e:	4501                	li	a0,0
}
    80001870:	8082                	ret
      return -1;
    80001872:	557d                	li	a0,-1
}
    80001874:	60a6                	ld	ra,72(sp)
    80001876:	6406                	ld	s0,64(sp)
    80001878:	74e2                	ld	s1,56(sp)
    8000187a:	7942                	ld	s2,48(sp)
    8000187c:	79a2                	ld	s3,40(sp)
    8000187e:	7a02                	ld	s4,32(sp)
    80001880:	6ae2                	ld	s5,24(sp)
    80001882:	6b42                	ld	s6,16(sp)
    80001884:	6ba2                	ld	s7,8(sp)
    80001886:	6c02                	ld	s8,0(sp)
    80001888:	6161                	addi	sp,sp,80
    8000188a:	8082                	ret

000000008000188c <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000188c:	caa5                	beqz	a3,800018fc <copyin+0x70>
{
    8000188e:	715d                	addi	sp,sp,-80
    80001890:	e486                	sd	ra,72(sp)
    80001892:	e0a2                	sd	s0,64(sp)
    80001894:	fc26                	sd	s1,56(sp)
    80001896:	f84a                	sd	s2,48(sp)
    80001898:	f44e                	sd	s3,40(sp)
    8000189a:	f052                	sd	s4,32(sp)
    8000189c:	ec56                	sd	s5,24(sp)
    8000189e:	e85a                	sd	s6,16(sp)
    800018a0:	e45e                	sd	s7,8(sp)
    800018a2:	e062                	sd	s8,0(sp)
    800018a4:	0880                	addi	s0,sp,80
    800018a6:	8b2a                	mv	s6,a0
    800018a8:	8a2e                	mv	s4,a1
    800018aa:	8c32                	mv	s8,a2
    800018ac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800018ae:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018b0:	6a85                	lui	s5,0x1
    800018b2:	a01d                	j	800018d8 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018b4:	018505b3          	add	a1,a0,s8
    800018b8:	0004861b          	sext.w	a2,s1
    800018bc:	412585b3          	sub	a1,a1,s2
    800018c0:	8552                	mv	a0,s4
    800018c2:	fffff097          	auipc	ra,0xfffff
    800018c6:	610080e7          	jalr	1552(ra) # 80000ed2 <memmove>

    len -= n;
    800018ca:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018ce:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018d0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018d4:	02098263          	beqz	s3,800018f8 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018d8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018dc:	85ca                	mv	a1,s2
    800018de:	855a                	mv	a0,s6
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	9b2080e7          	jalr	-1614(ra) # 80001292 <walkaddr>
    if(pa0 == 0)
    800018e8:	cd01                	beqz	a0,80001900 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018ea:	418904b3          	sub	s1,s2,s8
    800018ee:	94d6                	add	s1,s1,s5
    if(n > len)
    800018f0:	fc99f2e3          	bgeu	s3,s1,800018b4 <copyin+0x28>
    800018f4:	84ce                	mv	s1,s3
    800018f6:	bf7d                	j	800018b4 <copyin+0x28>
  }
  return 0;
    800018f8:	4501                	li	a0,0
    800018fa:	a021                	j	80001902 <copyin+0x76>
    800018fc:	4501                	li	a0,0
}
    800018fe:	8082                	ret
      return -1;
    80001900:	557d                	li	a0,-1
}
    80001902:	60a6                	ld	ra,72(sp)
    80001904:	6406                	ld	s0,64(sp)
    80001906:	74e2                	ld	s1,56(sp)
    80001908:	7942                	ld	s2,48(sp)
    8000190a:	79a2                	ld	s3,40(sp)
    8000190c:	7a02                	ld	s4,32(sp)
    8000190e:	6ae2                	ld	s5,24(sp)
    80001910:	6b42                	ld	s6,16(sp)
    80001912:	6ba2                	ld	s7,8(sp)
    80001914:	6c02                	ld	s8,0(sp)
    80001916:	6161                	addi	sp,sp,80
    80001918:	8082                	ret

000000008000191a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000191a:	c6c5                	beqz	a3,800019c2 <copyinstr+0xa8>
{
    8000191c:	715d                	addi	sp,sp,-80
    8000191e:	e486                	sd	ra,72(sp)
    80001920:	e0a2                	sd	s0,64(sp)
    80001922:	fc26                	sd	s1,56(sp)
    80001924:	f84a                	sd	s2,48(sp)
    80001926:	f44e                	sd	s3,40(sp)
    80001928:	f052                	sd	s4,32(sp)
    8000192a:	ec56                	sd	s5,24(sp)
    8000192c:	e85a                	sd	s6,16(sp)
    8000192e:	e45e                	sd	s7,8(sp)
    80001930:	0880                	addi	s0,sp,80
    80001932:	8a2a                	mv	s4,a0
    80001934:	8b2e                	mv	s6,a1
    80001936:	8bb2                	mv	s7,a2
    80001938:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000193a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000193c:	6985                	lui	s3,0x1
    8000193e:	a035                	j	8000196a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001940:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001944:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001946:	0017b793          	seqz	a5,a5
    8000194a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000194e:	60a6                	ld	ra,72(sp)
    80001950:	6406                	ld	s0,64(sp)
    80001952:	74e2                	ld	s1,56(sp)
    80001954:	7942                	ld	s2,48(sp)
    80001956:	79a2                	ld	s3,40(sp)
    80001958:	7a02                	ld	s4,32(sp)
    8000195a:	6ae2                	ld	s5,24(sp)
    8000195c:	6b42                	ld	s6,16(sp)
    8000195e:	6ba2                	ld	s7,8(sp)
    80001960:	6161                	addi	sp,sp,80
    80001962:	8082                	ret
    srcva = va0 + PGSIZE;
    80001964:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001968:	c8a9                	beqz	s1,800019ba <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000196a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000196e:	85ca                	mv	a1,s2
    80001970:	8552                	mv	a0,s4
    80001972:	00000097          	auipc	ra,0x0
    80001976:	920080e7          	jalr	-1760(ra) # 80001292 <walkaddr>
    if(pa0 == 0)
    8000197a:	c131                	beqz	a0,800019be <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000197c:	41790833          	sub	a6,s2,s7
    80001980:	984e                	add	a6,a6,s3
    if(n > max)
    80001982:	0104f363          	bgeu	s1,a6,80001988 <copyinstr+0x6e>
    80001986:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001988:	955e                	add	a0,a0,s7
    8000198a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000198e:	fc080be3          	beqz	a6,80001964 <copyinstr+0x4a>
    80001992:	985a                	add	a6,a6,s6
    80001994:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001996:	41650633          	sub	a2,a0,s6
    8000199a:	14fd                	addi	s1,s1,-1
    8000199c:	9b26                	add	s6,s6,s1
    8000199e:	00f60733          	add	a4,a2,a5
    800019a2:	00074703          	lbu	a4,0(a4)
    800019a6:	df49                	beqz	a4,80001940 <copyinstr+0x26>
        *dst = *p;
    800019a8:	00e78023          	sb	a4,0(a5)
      --max;
    800019ac:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800019b0:	0785                	addi	a5,a5,1
    while(n > 0){
    800019b2:	ff0796e3          	bne	a5,a6,8000199e <copyinstr+0x84>
      dst++;
    800019b6:	8b42                	mv	s6,a6
    800019b8:	b775                	j	80001964 <copyinstr+0x4a>
    800019ba:	4781                	li	a5,0
    800019bc:	b769                	j	80001946 <copyinstr+0x2c>
      return -1;
    800019be:	557d                	li	a0,-1
    800019c0:	b779                	j	8000194e <copyinstr+0x34>
  int got_null = 0;
    800019c2:	4781                	li	a5,0
  if(got_null){
    800019c4:	0017b793          	seqz	a5,a5
    800019c8:	40f00533          	neg	a0,a5
}
    800019cc:	8082                	ret

00000000800019ce <kwalkaddr>:
kwalkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t* pte;
  uint64 pa;

  if(va>= MAXVA)
    800019ce:	57fd                	li	a5,-1
    800019d0:	83e9                	srli	a5,a5,0x1a
    800019d2:	00b7f463          	bgeu	a5,a1,800019da <kwalkaddr+0xc>
    return 0;
    800019d6:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_V) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
    800019d8:	8082                	ret
{
    800019da:	1141                	addi	sp,sp,-16
    800019dc:	e406                	sd	ra,8(sp)
    800019de:	e022                	sd	s0,0(sp)
    800019e0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800019e2:	4601                	li	a2,0
    800019e4:	fffff097          	auipc	ra,0xfffff
    800019e8:	77a080e7          	jalr	1914(ra) # 8000115e <walk>
  if (pte == 0)
    800019ec:	cd01                	beqz	a0,80001a04 <kwalkaddr+0x36>
  if ((*pte & PTE_V) == 0)
    800019ee:	611c                	ld	a5,0(a0)
    800019f0:	0017f513          	andi	a0,a5,1
    800019f4:	c501                	beqz	a0,800019fc <kwalkaddr+0x2e>
  pa = PTE2PA(*pte);
    800019f6:	00a7d513          	srli	a0,a5,0xa
    800019fa:	0532                	slli	a0,a0,0xc
    800019fc:	60a2                	ld	ra,8(sp)
    800019fe:	6402                	ld	s0,0(sp)
    80001a00:	0141                	addi	sp,sp,16
    80001a02:	8082                	ret
    return 0;
    80001a04:	4501                	li	a0,0
    80001a06:	bfdd                	j	800019fc <kwalkaddr+0x2e>

0000000080001a08 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a08:	1101                	addi	sp,sp,-32
    80001a0a:	ec06                	sd	ra,24(sp)
    80001a0c:	e822                	sd	s0,16(sp)
    80001a0e:	e426                	sd	s1,8(sp)
    80001a10:	1000                	addi	s0,sp,32
    80001a12:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	100080e7          	jalr	256(ra) # 80000b14 <holding>
    80001a1c:	c909                	beqz	a0,80001a2e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a1e:	789c                	ld	a5,48(s1)
    80001a20:	00978f63          	beq	a5,s1,80001a3e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a24:	60e2                	ld	ra,24(sp)
    80001a26:	6442                	ld	s0,16(sp)
    80001a28:	64a2                	ld	s1,8(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    panic("wakeup1");
    80001a2e:	00007517          	auipc	a0,0x7
    80001a32:	96250513          	addi	a0,a0,-1694 # 80008390 <digits+0x220>
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	b2e080e7          	jalr	-1234(ra) # 80000564 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a3e:	5098                	lw	a4,32(s1)
    80001a40:	4785                	li	a5,1
    80001a42:	fef711e3          	bne	a4,a5,80001a24 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a46:	4789                	li	a5,2
    80001a48:	d09c                	sw	a5,32(s1)
}
    80001a4a:	bfe9                	j	80001a24 <wakeup1+0x1c>

0000000080001a4c <procinit>:
{
    80001a4c:	715d                	addi	sp,sp,-80
    80001a4e:	e486                	sd	ra,72(sp)
    80001a50:	e0a2                	sd	s0,64(sp)
    80001a52:	fc26                	sd	s1,56(sp)
    80001a54:	f84a                	sd	s2,48(sp)
    80001a56:	f44e                	sd	s3,40(sp)
    80001a58:	f052                	sd	s4,32(sp)
    80001a5a:	ec56                	sd	s5,24(sp)
    80001a5c:	e85a                	sd	s6,16(sp)
    80001a5e:	e45e                	sd	s7,8(sp)
    80001a60:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a62:	00007597          	auipc	a1,0x7
    80001a66:	93658593          	addi	a1,a1,-1738 # 80008398 <digits+0x228>
    80001a6a:	00023517          	auipc	a0,0x23
    80001a6e:	fae50513          	addi	a0,a0,-82 # 80024a18 <pid_lock>
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	04a080e7          	jalr	74(ra) # 80000abc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a7a:	00023917          	auipc	s2,0x23
    80001a7e:	3be90913          	addi	s2,s2,958 # 80024e38 <proc>
      initlock(&p->lock, "proc");
    80001a82:	00007b97          	auipc	s7,0x7
    80001a86:	91eb8b93          	addi	s7,s7,-1762 # 800083a0 <digits+0x230>
      uint64 va = KSTACK((int) (p - proc));
    80001a8a:	8b4a                	mv	s6,s2
    80001a8c:	00006a97          	auipc	s5,0x6
    80001a90:	574a8a93          	addi	s5,s5,1396 # 80008000 <etext>
    80001a94:	040009b7          	lui	s3,0x4000
    80001a98:	19fd                	addi	s3,s3,-1
    80001a9a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a9c:	00029a17          	auipc	s4,0x29
    80001aa0:	39ca0a13          	addi	s4,s4,924 # 8002ae38 <tickslock>
      initlock(&p->lock, "proc");
    80001aa4:	85de                	mv	a1,s7
    80001aa6:	854a                	mv	a0,s2
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	014080e7          	jalr	20(ra) # 80000abc <initlock>
      char *pa = kalloc();
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	f92080e7          	jalr	-110(ra) # 80000a42 <kalloc>
    80001ab8:	85aa                	mv	a1,a0
      if(pa == 0)
    80001aba:	c929                	beqz	a0,80001b0c <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001abc:	416904b3          	sub	s1,s2,s6
    80001ac0:	849d                	srai	s1,s1,0x7
    80001ac2:	000ab783          	ld	a5,0(s5)
    80001ac6:	02f484b3          	mul	s1,s1,a5
    80001aca:	2485                	addiw	s1,s1,1
    80001acc:	00d4949b          	slliw	s1,s1,0xd
    80001ad0:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ad4:	4699                	li	a3,6
    80001ad6:	6605                	lui	a2,0x1
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	89a080e7          	jalr	-1894(ra) # 80001374 <kvmmap>
      p->kstack = va;
    80001ae2:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae6:	18090913          	addi	s2,s2,384
    80001aea:	fb491de3          	bne	s2,s4,80001aa4 <procinit+0x58>
  kvminithart();
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	780080e7          	jalr	1920(ra) # 8000126e <kvminithart>
}
    80001af6:	60a6                	ld	ra,72(sp)
    80001af8:	6406                	ld	s0,64(sp)
    80001afa:	74e2                	ld	s1,56(sp)
    80001afc:	7942                	ld	s2,48(sp)
    80001afe:	79a2                	ld	s3,40(sp)
    80001b00:	7a02                	ld	s4,32(sp)
    80001b02:	6ae2                	ld	s5,24(sp)
    80001b04:	6b42                	ld	s6,16(sp)
    80001b06:	6ba2                	ld	s7,8(sp)
    80001b08:	6161                	addi	sp,sp,80
    80001b0a:	8082                	ret
        panic("kalloc");
    80001b0c:	00007517          	auipc	a0,0x7
    80001b10:	89c50513          	addi	a0,a0,-1892 # 800083a8 <digits+0x238>
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	a50080e7          	jalr	-1456(ra) # 80000564 <panic>

0000000080001b1c <cpuid>:
{
    80001b1c:	1141                	addi	sp,sp,-16
    80001b1e:	e422                	sd	s0,8(sp)
    80001b20:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b22:	8512                	mv	a0,tp
}
    80001b24:	2501                	sext.w	a0,a0
    80001b26:	6422                	ld	s0,8(sp)
    80001b28:	0141                	addi	sp,sp,16
    80001b2a:	8082                	ret

0000000080001b2c <mycpu>:
mycpu(void) {
    80001b2c:	1141                	addi	sp,sp,-16
    80001b2e:	e422                	sd	s0,8(sp)
    80001b30:	0800                	addi	s0,sp,16
    80001b32:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b34:	2781                	sext.w	a5,a5
    80001b36:	079e                	slli	a5,a5,0x7
}
    80001b38:	00023517          	auipc	a0,0x23
    80001b3c:	f0050513          	addi	a0,a0,-256 # 80024a38 <cpus>
    80001b40:	953e                	add	a0,a0,a5
    80001b42:	6422                	ld	s0,8(sp)
    80001b44:	0141                	addi	sp,sp,16
    80001b46:	8082                	ret

0000000080001b48 <myproc>:
myproc(void) {
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  push_off();
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	ff0080e7          	jalr	-16(ra) # 80000b42 <push_off>
    80001b5a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b5c:	2781                	sext.w	a5,a5
    80001b5e:	079e                	slli	a5,a5,0x7
    80001b60:	00023717          	auipc	a4,0x23
    80001b64:	eb870713          	addi	a4,a4,-328 # 80024a18 <pid_lock>
    80001b68:	97ba                	add	a5,a5,a4
    80001b6a:	7384                	ld	s1,32(a5)
  pop_off();
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	096080e7          	jalr	150(ra) # 80000c02 <pop_off>
}
    80001b74:	8526                	mv	a0,s1
    80001b76:	60e2                	ld	ra,24(sp)
    80001b78:	6442                	ld	s0,16(sp)
    80001b7a:	64a2                	ld	s1,8(sp)
    80001b7c:	6105                	addi	sp,sp,32
    80001b7e:	8082                	ret

0000000080001b80 <forkret>:
{
    80001b80:	1141                	addi	sp,sp,-16
    80001b82:	e406                	sd	ra,8(sp)
    80001b84:	e022                	sd	s0,0(sp)
    80001b86:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	fc0080e7          	jalr	-64(ra) # 80001b48 <myproc>
    80001b90:	fffff097          	auipc	ra,0xfffff
    80001b94:	0d2080e7          	jalr	210(ra) # 80000c62 <release>
  if (first) {
    80001b98:	00007797          	auipc	a5,0x7
    80001b9c:	3187a783          	lw	a5,792(a5) # 80008eb0 <first.1>
    80001ba0:	eb89                	bnez	a5,80001bb2 <forkret+0x32>
  usertrapret();
    80001ba2:	00001097          	auipc	ra,0x1
    80001ba6:	cca080e7          	jalr	-822(ra) # 8000286c <usertrapret>
}
    80001baa:	60a2                	ld	ra,8(sp)
    80001bac:	6402                	ld	s0,0(sp)
    80001bae:	0141                	addi	sp,sp,16
    80001bb0:	8082                	ret
    first = 0;
    80001bb2:	00007797          	auipc	a5,0x7
    80001bb6:	2e07af23          	sw	zero,766(a5) # 80008eb0 <first.1>
    fsinit(ROOTDEV);
    80001bba:	4505                	li	a0,1
    80001bbc:	00002097          	auipc	ra,0x2
    80001bc0:	9dc080e7          	jalr	-1572(ra) # 80003598 <fsinit>
    80001bc4:	bff9                	j	80001ba2 <forkret+0x22>

0000000080001bc6 <allocpid>:
allocpid() {
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	e04a                	sd	s2,0(sp)
    80001bd0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bd2:	00023917          	auipc	s2,0x23
    80001bd6:	e4690913          	addi	s2,s2,-442 # 80024a18 <pid_lock>
    80001bda:	854a                	mv	a0,s2
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	fb6080e7          	jalr	-74(ra) # 80000b92 <acquire>
  pid = nextpid;
    80001be4:	00007797          	auipc	a5,0x7
    80001be8:	2d078793          	addi	a5,a5,720 # 80008eb4 <nextpid>
    80001bec:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bee:	0014871b          	addiw	a4,s1,1
    80001bf2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bf4:	854a                	mv	a0,s2
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	06c080e7          	jalr	108(ra) # 80000c62 <release>
}
    80001bfe:	8526                	mv	a0,s1
    80001c00:	60e2                	ld	ra,24(sp)
    80001c02:	6442                	ld	s0,16(sp)
    80001c04:	64a2                	ld	s1,8(sp)
    80001c06:	6902                	ld	s2,0(sp)
    80001c08:	6105                	addi	sp,sp,32
    80001c0a:	8082                	ret

0000000080001c0c <proc_pagetable>:
{
    80001c0c:	1101                	addi	sp,sp,-32
    80001c0e:	ec06                	sd	ra,24(sp)
    80001c10:	e822                	sd	s0,16(sp)
    80001c12:	e426                	sd	s1,8(sp)
    80001c14:	e04a                	sd	s2,0(sp)
    80001c16:	1000                	addi	s0,sp,32
    80001c18:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c1a:	00000097          	auipc	ra,0x0
    80001c1e:	918080e7          	jalr	-1768(ra) # 80001532 <uvmcreate>
    80001c22:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c24:	4729                	li	a4,10
    80001c26:	00005697          	auipc	a3,0x5
    80001c2a:	3da68693          	addi	a3,a3,986 # 80007000 <_trampoline>
    80001c2e:	6605                	lui	a2,0x1
    80001c30:	040005b7          	lui	a1,0x4000
    80001c34:	15fd                	addi	a1,a1,-1
    80001c36:	05b2                	slli	a1,a1,0xc
    80001c38:	fffff097          	auipc	ra,0xfffff
    80001c3c:	69c080e7          	jalr	1692(ra) # 800012d4 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c40:	4719                	li	a4,6
    80001c42:	06093683          	ld	a3,96(s2)
    80001c46:	6605                	lui	a2,0x1
    80001c48:	020005b7          	lui	a1,0x2000
    80001c4c:	15fd                	addi	a1,a1,-1
    80001c4e:	05b6                	slli	a1,a1,0xd
    80001c50:	8526                	mv	a0,s1
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	682080e7          	jalr	1666(ra) # 800012d4 <mappages>
}
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6902                	ld	s2,0(sp)
    80001c64:	6105                	addi	sp,sp,32
    80001c66:	8082                	ret

0000000080001c68 <allocproc>:
{
    80001c68:	1101                	addi	sp,sp,-32
    80001c6a:	ec06                	sd	ra,24(sp)
    80001c6c:	e822                	sd	s0,16(sp)
    80001c6e:	e426                	sd	s1,8(sp)
    80001c70:	e04a                	sd	s2,0(sp)
    80001c72:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c74:	00023497          	auipc	s1,0x23
    80001c78:	1c448493          	addi	s1,s1,452 # 80024e38 <proc>
    80001c7c:	00029917          	auipc	s2,0x29
    80001c80:	1bc90913          	addi	s2,s2,444 # 8002ae38 <tickslock>
    acquire(&p->lock);
    80001c84:	8526                	mv	a0,s1
    80001c86:	fffff097          	auipc	ra,0xfffff
    80001c8a:	f0c080e7          	jalr	-244(ra) # 80000b92 <acquire>
    if(p->state == UNUSED) {
    80001c8e:	509c                	lw	a5,32(s1)
    80001c90:	cf81                	beqz	a5,80001ca8 <allocproc+0x40>
      release(&p->lock);
    80001c92:	8526                	mv	a0,s1
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	fce080e7          	jalr	-50(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9c:	18048493          	addi	s1,s1,384
    80001ca0:	ff2492e3          	bne	s1,s2,80001c84 <allocproc+0x1c>
  return 0;
    80001ca4:	4481                	li	s1,0
    80001ca6:	a899                	j	80001cfc <allocproc+0x94>
  p->pid = allocpid();
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	f1e080e7          	jalr	-226(ra) # 80001bc6 <allocpid>
    80001cb0:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	d90080e7          	jalr	-624(ra) # 80000a42 <kalloc>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	f0a8                	sd	a0,96(s1)
    80001cbe:	c531                	beqz	a0,80001d0a <allocproc+0xa2>
  p->pagetable = proc_pagetable(p);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	f4a080e7          	jalr	-182(ra) # 80001c0c <proc_pagetable>
    80001cca:	eca8                	sd	a0,88(s1)
  p->trap_va = TRAPFRAME;
    80001ccc:	020007b7          	lui	a5,0x2000
    80001cd0:	17fd                	addi	a5,a5,-1
    80001cd2:	07b6                	slli	a5,a5,0xd
    80001cd4:	16f4b823          	sd	a5,368(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001cd8:	07000613          	li	a2,112
    80001cdc:	4581                	li	a1,0
    80001cde:	06848513          	addi	a0,s1,104
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	194080e7          	jalr	404(ra) # 80000e76 <memset>
  p->context.ra = (uint64)forkret;
    80001cea:	00000797          	auipc	a5,0x0
    80001cee:	e9678793          	addi	a5,a5,-362 # 80001b80 <forkret>
    80001cf2:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cf4:	64bc                	ld	a5,72(s1)
    80001cf6:	6705                	lui	a4,0x1
    80001cf8:	97ba                	add	a5,a5,a4
    80001cfa:	f8bc                	sd	a5,112(s1)
}
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	60e2                	ld	ra,24(sp)
    80001d00:	6442                	ld	s0,16(sp)
    80001d02:	64a2                	ld	s1,8(sp)
    80001d04:	6902                	ld	s2,0(sp)
    80001d06:	6105                	addi	sp,sp,32
    80001d08:	8082                	ret
    release(&p->lock);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	fffff097          	auipc	ra,0xfffff
    80001d10:	f56080e7          	jalr	-170(ra) # 80000c62 <release>
    return 0;
    80001d14:	84ca                	mv	s1,s2
    80001d16:	b7dd                	j	80001cfc <allocproc+0x94>

0000000080001d18 <proc_freepagetable>:
{
    80001d18:	1101                	addi	sp,sp,-32
    80001d1a:	ec06                	sd	ra,24(sp)
    80001d1c:	e822                	sd	s0,16(sp)
    80001d1e:	e426                	sd	s1,8(sp)
    80001d20:	e04a                	sd	s2,0(sp)
    80001d22:	1000                	addi	s0,sp,32
    80001d24:	84aa                	mv	s1,a0
    80001d26:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d28:	4681                	li	a3,0
    80001d2a:	6605                	lui	a2,0x1
    80001d2c:	040005b7          	lui	a1,0x4000
    80001d30:	15fd                	addi	a1,a1,-1
    80001d32:	05b2                	slli	a1,a1,0xc
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	736080e7          	jalr	1846(ra) # 8000146a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d3c:	4681                	li	a3,0
    80001d3e:	6605                	lui	a2,0x1
    80001d40:	020005b7          	lui	a1,0x2000
    80001d44:	15fd                	addi	a1,a1,-1
    80001d46:	05b6                	slli	a1,a1,0xd
    80001d48:	8526                	mv	a0,s1
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	720080e7          	jalr	1824(ra) # 8000146a <uvmunmap>
  if(sz > 0)
    80001d52:	00091863          	bnez	s2,80001d62 <proc_freepagetable+0x4a>
}
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret
    uvmfree(pagetable, sz);
    80001d62:	85ca                	mv	a1,s2
    80001d64:	8526                	mv	a0,s1
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	96a080e7          	jalr	-1686(ra) # 800016d0 <uvmfree>
}
    80001d6e:	b7e5                	j	80001d56 <proc_freepagetable+0x3e>

0000000080001d70 <freeproc>:
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	1000                	addi	s0,sp,32
    80001d7a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d7c:	7128                	ld	a0,96(a0)
    80001d7e:	c509                	beqz	a0,80001d88 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	bbc080e7          	jalr	-1092(ra) # 8000093c <kfree>
  p->trapframe = 0;
    80001d88:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001d8c:	6ca8                	ld	a0,88(s1)
    80001d8e:	c511                	beqz	a0,80001d9a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001d90:	68ac                	ld	a1,80(s1)
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	f86080e7          	jalr	-122(ra) # 80001d18 <proc_freepagetable>
  p->pagetable = 0;
    80001d9a:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001d9e:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001da2:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001da6:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001daa:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dae:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001db2:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001db6:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001dba:	0204a023          	sw	zero,32(s1)
}
    80001dbe:	60e2                	ld	ra,24(sp)
    80001dc0:	6442                	ld	s0,16(sp)
    80001dc2:	64a2                	ld	s1,8(sp)
    80001dc4:	6105                	addi	sp,sp,32
    80001dc6:	8082                	ret

0000000080001dc8 <userinit>:
{
    80001dc8:	1101                	addi	sp,sp,-32
    80001dca:	ec06                	sd	ra,24(sp)
    80001dcc:	e822                	sd	s0,16(sp)
    80001dce:	e426                	sd	s1,8(sp)
    80001dd0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	e96080e7          	jalr	-362(ra) # 80001c68 <allocproc>
    80001dda:	84aa                	mv	s1,a0
  initproc = p;
    80001ddc:	00007797          	auipc	a5,0x7
    80001de0:	14a7b223          	sd	a0,324(a5) # 80008f20 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001de4:	03400613          	li	a2,52
    80001de8:	00007597          	auipc	a1,0x7
    80001dec:	0d858593          	addi	a1,a1,216 # 80008ec0 <initcode>
    80001df0:	6d28                	ld	a0,88(a0)
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	77e080e7          	jalr	1918(ra) # 80001570 <uvminit>
  p->sz = PGSIZE;
    80001dfa:	6785                	lui	a5,0x1
    80001dfc:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001dfe:	70b8                	ld	a4,96(s1)
    80001e00:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e04:	70b8                	ld	a4,96(s1)
    80001e06:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e08:	4641                	li	a2,16
    80001e0a:	00006597          	auipc	a1,0x6
    80001e0e:	5a658593          	addi	a1,a1,1446 # 800083b0 <digits+0x240>
    80001e12:	16048513          	addi	a0,s1,352
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	1d6080e7          	jalr	470(ra) # 80000fec <safestrcpy>
  p->cwd = namei("/");
    80001e1e:	00006517          	auipc	a0,0x6
    80001e22:	5a250513          	addi	a0,a0,1442 # 800083c0 <digits+0x250>
    80001e26:	00002097          	auipc	ra,0x2
    80001e2a:	1a0080e7          	jalr	416(ra) # 80003fc6 <namei>
    80001e2e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e32:	4789                	li	a5,2
    80001e34:	d09c                	sw	a5,32(s1)
  p->arrival = arrival_counter++;  // record join order
    80001e36:	00007717          	auipc	a4,0x7
    80001e3a:	0e270713          	addi	a4,a4,226 # 80008f18 <arrival_counter>
    80001e3e:	631c                	ld	a5,0(a4)
    80001e40:	00178693          	addi	a3,a5,1 # 1001 <_entry-0x7fffefff>
    80001e44:	e314                	sd	a3,0(a4)
    80001e46:	16f4bc23          	sd	a5,376(s1)
  release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	e16080e7          	jalr	-490(ra) # 80000c62 <release>
}
    80001e54:	60e2                	ld	ra,24(sp)
    80001e56:	6442                	ld	s0,16(sp)
    80001e58:	64a2                	ld	s1,8(sp)
    80001e5a:	6105                	addi	sp,sp,32
    80001e5c:	8082                	ret

0000000080001e5e <growproc>:
{
    80001e5e:	1101                	addi	sp,sp,-32
    80001e60:	ec06                	sd	ra,24(sp)
    80001e62:	e822                	sd	s0,16(sp)
    80001e64:	e426                	sd	s1,8(sp)
    80001e66:	e04a                	sd	s2,0(sp)
    80001e68:	1000                	addi	s0,sp,32
    80001e6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	cdc080e7          	jalr	-804(ra) # 80001b48 <myproc>
    80001e74:	892a                	mv	s2,a0
  sz = p->sz;
    80001e76:	692c                	ld	a1,80(a0)
    80001e78:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e7c:	00904f63          	bgtz	s1,80001e9a <growproc+0x3c>
  } else if(n < 0){
    80001e80:	0204cc63          	bltz	s1,80001eb8 <growproc+0x5a>
  p->sz = sz;
    80001e84:	1602                	slli	a2,a2,0x20
    80001e86:	9201                	srli	a2,a2,0x20
    80001e88:	04c93823          	sd	a2,80(s2)
  return 0;
    80001e8c:	4501                	li	a0,0
}
    80001e8e:	60e2                	ld	ra,24(sp)
    80001e90:	6442                	ld	s0,16(sp)
    80001e92:	64a2                	ld	s1,8(sp)
    80001e94:	6902                	ld	s2,0(sp)
    80001e96:	6105                	addi	sp,sp,32
    80001e98:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e9a:	9e25                	addw	a2,a2,s1
    80001e9c:	1602                	slli	a2,a2,0x20
    80001e9e:	9201                	srli	a2,a2,0x20
    80001ea0:	1582                	slli	a1,a1,0x20
    80001ea2:	9181                	srli	a1,a1,0x20
    80001ea4:	6d28                	ld	a0,88(a0)
    80001ea6:	fffff097          	auipc	ra,0xfffff
    80001eaa:	780080e7          	jalr	1920(ra) # 80001626 <uvmalloc>
    80001eae:	0005061b          	sext.w	a2,a0
    80001eb2:	fa69                	bnez	a2,80001e84 <growproc+0x26>
      return -1;
    80001eb4:	557d                	li	a0,-1
    80001eb6:	bfe1                	j	80001e8e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eb8:	9e25                	addw	a2,a2,s1
    80001eba:	1602                	slli	a2,a2,0x20
    80001ebc:	9201                	srli	a2,a2,0x20
    80001ebe:	1582                	slli	a1,a1,0x20
    80001ec0:	9181                	srli	a1,a1,0x20
    80001ec2:	6d28                	ld	a0,88(a0)
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	71e080e7          	jalr	1822(ra) # 800015e2 <uvmdealloc>
    80001ecc:	0005061b          	sext.w	a2,a0
    80001ed0:	bf55                	j	80001e84 <growproc+0x26>

0000000080001ed2 <fork>:
{
    80001ed2:	7139                	addi	sp,sp,-64
    80001ed4:	fc06                	sd	ra,56(sp)
    80001ed6:	f822                	sd	s0,48(sp)
    80001ed8:	f426                	sd	s1,40(sp)
    80001eda:	f04a                	sd	s2,32(sp)
    80001edc:	ec4e                	sd	s3,24(sp)
    80001ede:	e852                	sd	s4,16(sp)
    80001ee0:	e456                	sd	s5,8(sp)
    80001ee2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ee4:	00000097          	auipc	ra,0x0
    80001ee8:	c64080e7          	jalr	-924(ra) # 80001b48 <myproc>
    80001eec:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001eee:	00000097          	auipc	ra,0x0
    80001ef2:	d7a080e7          	jalr	-646(ra) # 80001c68 <allocproc>
    80001ef6:	cd6d                	beqz	a0,80001ff0 <fork+0x11e>
    80001ef8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001efa:	050ab603          	ld	a2,80(s5)
    80001efe:	6d2c                	ld	a1,88(a0)
    80001f00:	058ab503          	ld	a0,88(s5)
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	7fa080e7          	jalr	2042(ra) # 800016fe <uvmcopy>
    80001f0c:	04054a63          	bltz	a0,80001f60 <fork+0x8e>
  np->sz = p->sz;
    80001f10:	050ab783          	ld	a5,80(s5)
    80001f14:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001f18:	035a3423          	sd	s5,40(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f1c:	060ab683          	ld	a3,96(s5)
    80001f20:	87b6                	mv	a5,a3
    80001f22:	060a3703          	ld	a4,96(s4)
    80001f26:	12068693          	addi	a3,a3,288
    80001f2a:	0007b803          	ld	a6,0(a5)
    80001f2e:	6788                	ld	a0,8(a5)
    80001f30:	6b8c                	ld	a1,16(a5)
    80001f32:	6f90                	ld	a2,24(a5)
    80001f34:	01073023          	sd	a6,0(a4)
    80001f38:	e708                	sd	a0,8(a4)
    80001f3a:	eb0c                	sd	a1,16(a4)
    80001f3c:	ef10                	sd	a2,24(a4)
    80001f3e:	02078793          	addi	a5,a5,32
    80001f42:	02070713          	addi	a4,a4,32
    80001f46:	fed792e3          	bne	a5,a3,80001f2a <fork+0x58>
  np->trapframe->a0 = 0;
    80001f4a:	060a3783          	ld	a5,96(s4)
    80001f4e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f52:	0d8a8493          	addi	s1,s5,216
    80001f56:	0d8a0913          	addi	s2,s4,216
    80001f5a:	158a8993          	addi	s3,s5,344
    80001f5e:	a00d                	j	80001f80 <fork+0xae>
    freeproc(np);
    80001f60:	8552                	mv	a0,s4
    80001f62:	00000097          	auipc	ra,0x0
    80001f66:	e0e080e7          	jalr	-498(ra) # 80001d70 <freeproc>
    release(&np->lock);
    80001f6a:	8552                	mv	a0,s4
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	cf6080e7          	jalr	-778(ra) # 80000c62 <release>
    return -1;
    80001f74:	54fd                	li	s1,-1
    80001f76:	a09d                	j	80001fdc <fork+0x10a>
  for(i = 0; i < NOFILE; i++)
    80001f78:	04a1                	addi	s1,s1,8
    80001f7a:	0921                	addi	s2,s2,8
    80001f7c:	01348b63          	beq	s1,s3,80001f92 <fork+0xc0>
    if(p->ofile[i])
    80001f80:	6088                	ld	a0,0(s1)
    80001f82:	d97d                	beqz	a0,80001f78 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f84:	00002097          	auipc	ra,0x2
    80001f88:	6c6080e7          	jalr	1734(ra) # 8000464a <filedup>
    80001f8c:	00a93023          	sd	a0,0(s2)
    80001f90:	b7e5                	j	80001f78 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f92:	158ab503          	ld	a0,344(s5)
    80001f96:	00002097          	auipc	ra,0x2
    80001f9a:	83c080e7          	jalr	-1988(ra) # 800037d2 <idup>
    80001f9e:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fa2:	4641                	li	a2,16
    80001fa4:	160a8593          	addi	a1,s5,352
    80001fa8:	160a0513          	addi	a0,s4,352
    80001fac:	fffff097          	auipc	ra,0xfffff
    80001fb0:	040080e7          	jalr	64(ra) # 80000fec <safestrcpy>
  pid = np->pid;
    80001fb4:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001fb8:	4789                	li	a5,2
    80001fba:	02fa2023          	sw	a5,32(s4)
  np->arrival = arrival_counter++;  // record join order
    80001fbe:	00007717          	auipc	a4,0x7
    80001fc2:	f5a70713          	addi	a4,a4,-166 # 80008f18 <arrival_counter>
    80001fc6:	631c                	ld	a5,0(a4)
    80001fc8:	00178693          	addi	a3,a5,1
    80001fcc:	e314                	sd	a3,0(a4)
    80001fce:	16fa3c23          	sd	a5,376(s4)
  release(&np->lock);
    80001fd2:	8552                	mv	a0,s4
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	c8e080e7          	jalr	-882(ra) # 80000c62 <release>
}
    80001fdc:	8526                	mv	a0,s1
    80001fde:	70e2                	ld	ra,56(sp)
    80001fe0:	7442                	ld	s0,48(sp)
    80001fe2:	74a2                	ld	s1,40(sp)
    80001fe4:	7902                	ld	s2,32(sp)
    80001fe6:	69e2                	ld	s3,24(sp)
    80001fe8:	6a42                	ld	s4,16(sp)
    80001fea:	6aa2                	ld	s5,8(sp)
    80001fec:	6121                	addi	sp,sp,64
    80001fee:	8082                	ret
    return -1;
    80001ff0:	54fd                	li	s1,-1
    80001ff2:	b7ed                	j	80001fdc <fork+0x10a>

0000000080001ff4 <reparent>:
{
    80001ff4:	7179                	addi	sp,sp,-48
    80001ff6:	f406                	sd	ra,40(sp)
    80001ff8:	f022                	sd	s0,32(sp)
    80001ffa:	ec26                	sd	s1,24(sp)
    80001ffc:	e84a                	sd	s2,16(sp)
    80001ffe:	e44e                	sd	s3,8(sp)
    80002000:	e052                	sd	s4,0(sp)
    80002002:	1800                	addi	s0,sp,48
    80002004:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002006:	00023497          	auipc	s1,0x23
    8000200a:	e3248493          	addi	s1,s1,-462 # 80024e38 <proc>
      pp->parent = initproc;
    8000200e:	00007a17          	auipc	s4,0x7
    80002012:	f12a0a13          	addi	s4,s4,-238 # 80008f20 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002016:	00029997          	auipc	s3,0x29
    8000201a:	e2298993          	addi	s3,s3,-478 # 8002ae38 <tickslock>
    8000201e:	a029                	j	80002028 <reparent+0x34>
    80002020:	18048493          	addi	s1,s1,384
    80002024:	03348363          	beq	s1,s3,8000204a <reparent+0x56>
    if(pp->parent == p){
    80002028:	749c                	ld	a5,40(s1)
    8000202a:	ff279be3          	bne	a5,s2,80002020 <reparent+0x2c>
      acquire(&pp->lock);
    8000202e:	8526                	mv	a0,s1
    80002030:	fffff097          	auipc	ra,0xfffff
    80002034:	b62080e7          	jalr	-1182(ra) # 80000b92 <acquire>
      pp->parent = initproc;
    80002038:	000a3783          	ld	a5,0(s4)
    8000203c:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    8000203e:	8526                	mv	a0,s1
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	c22080e7          	jalr	-990(ra) # 80000c62 <release>
    80002048:	bfe1                	j	80002020 <reparent+0x2c>
}
    8000204a:	70a2                	ld	ra,40(sp)
    8000204c:	7402                	ld	s0,32(sp)
    8000204e:	64e2                	ld	s1,24(sp)
    80002050:	6942                	ld	s2,16(sp)
    80002052:	69a2                	ld	s3,8(sp)
    80002054:	6a02                	ld	s4,0(sp)
    80002056:	6145                	addi	sp,sp,48
    80002058:	8082                	ret

000000008000205a <scheduler>:
{
    8000205a:	715d                	addi	sp,sp,-80
    8000205c:	e486                	sd	ra,72(sp)
    8000205e:	e0a2                	sd	s0,64(sp)
    80002060:	fc26                	sd	s1,56(sp)
    80002062:	f84a                	sd	s2,48(sp)
    80002064:	f44e                	sd	s3,40(sp)
    80002066:	f052                	sd	s4,32(sp)
    80002068:	ec56                	sd	s5,24(sp)
    8000206a:	e85a                	sd	s6,16(sp)
    8000206c:	e45e                	sd	s7,8(sp)
    8000206e:	0880                	addi	s0,sp,80
    80002070:	8792                	mv	a5,tp
  int id = r_tp();
    80002072:	2781                	sext.w	a5,a5
        swtch(&c->scheduler, &chosen->context);
    80002074:	00779693          	slli	a3,a5,0x7
    80002078:	00023717          	auipc	a4,0x23
    8000207c:	9c870713          	addi	a4,a4,-1592 # 80024a40 <cpus+0x8>
    80002080:	00e68b33          	add	s6,a3,a4
    chosen = 0;
    80002084:	4a01                	li	s4,0
    for(p = proc; p < &proc[NPROC]; p++){
    80002086:	00029917          	auipc	s2,0x29
    8000208a:	db290913          	addi	s2,s2,-590 # 8002ae38 <tickslock>
        c->proc = chosen;
    8000208e:	00023a97          	auipc	s5,0x23
    80002092:	98aa8a93          	addi	s5,s5,-1654 # 80024a18 <pid_lock>
    80002096:	9ab6                	add	s5,s5,a3
    80002098:	a8bd                	j	80002116 <scheduler+0xbc>
        if(chosen == 0 || p->arrival < chosen->arrival)
    8000209a:	08098f63          	beqz	s3,80002138 <scheduler+0xde>
    8000209e:	ff87b583          	ld	a1,-8(a5)
    800020a2:	1789b683          	ld	a3,376(s3)
    800020a6:	00d5f363          	bgeu	a1,a3,800020ac <scheduler+0x52>
    800020aa:	89b2                	mv	s3,a2
    for(p = proc; p < &proc[NPROC]; p++){
    800020ac:	05277063          	bgeu	a4,s2,800020ec <scheduler+0x92>
    800020b0:	18078793          	addi	a5,a5,384
    800020b4:	e8078613          	addi	a2,a5,-384
      if(p->state == RUNNABLE){
    800020b8:	873e                	mv	a4,a5
    800020ba:	ea07a683          	lw	a3,-352(a5)
    800020be:	fc968ee3          	beq	a3,s1,8000209a <scheduler+0x40>
    for(p = proc; p < &proc[NPROC]; p++){
    800020c2:	ff27e7e3          	bltu	a5,s2,800020b0 <scheduler+0x56>
    if(chosen){
    800020c6:	02099363          	bnez	s3,800020ec <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020d2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800020da:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020dc:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++){
    800020e0:	00023797          	auipc	a5,0x23
    800020e4:	ed878793          	addi	a5,a5,-296 # 80024fb8 <proc+0x180>
    chosen = 0;
    800020e8:	89d2                	mv	s3,s4
    800020ea:	b7e9                	j	800020b4 <scheduler+0x5a>
      acquire(&chosen->lock);
    800020ec:	8bce                	mv	s7,s3
    800020ee:	854e                	mv	a0,s3
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	aa2080e7          	jalr	-1374(ra) # 80000b92 <acquire>
      if(chosen->state == RUNNABLE) {
    800020f8:	0209a783          	lw	a5,32(s3)
    800020fc:	00978f63          	beq	a5,s1,8000211a <scheduler+0xc0>
      if(holding(&chosen->lock))
    80002100:	855e                	mv	a0,s7
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	a12080e7          	jalr	-1518(ra) # 80000b14 <holding>
    8000210a:	d161                	beqz	a0,800020ca <scheduler+0x70>
        release(&chosen->lock);
    8000210c:	855e                	mv	a0,s7
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	b54080e7          	jalr	-1196(ra) # 80000c62 <release>
      if(p->state == RUNNABLE){
    80002116:	4489                	li	s1,2
    80002118:	bf4d                	j	800020ca <scheduler+0x70>
        chosen->state = RUNNING;
    8000211a:	478d                	li	a5,3
    8000211c:	02f9a023          	sw	a5,32(s3)
        c->proc = chosen;
    80002120:	033ab023          	sd	s3,32(s5)
        swtch(&c->scheduler, &chosen->context);
    80002124:	06898593          	addi	a1,s3,104
    80002128:	855a                	mv	a0,s6
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	5fe080e7          	jalr	1534(ra) # 80002728 <swtch>
        c->proc = 0;
    80002132:	020ab023          	sd	zero,32(s5)
    80002136:	b7e9                	j	80002100 <scheduler+0xa6>
    80002138:	89b2                	mv	s3,a2
    8000213a:	bf8d                	j	800020ac <scheduler+0x52>

000000008000213c <sched>:
{
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	9fe080e7          	jalr	-1538(ra) # 80001b48 <myproc>
    80002152:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	9c0080e7          	jalr	-1600(ra) # 80000b14 <holding>
    8000215c:	c93d                	beqz	a0,800021d2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000215e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002160:	2781                	sext.w	a5,a5
    80002162:	079e                	slli	a5,a5,0x7
    80002164:	00023717          	auipc	a4,0x23
    80002168:	8b470713          	addi	a4,a4,-1868 # 80024a18 <pid_lock>
    8000216c:	97ba                	add	a5,a5,a4
    8000216e:	0987a703          	lw	a4,152(a5)
    80002172:	4785                	li	a5,1
    80002174:	06f71763          	bne	a4,a5,800021e2 <sched+0xa6>
  if(p->state == RUNNING)
    80002178:	5098                	lw	a4,32(s1)
    8000217a:	478d                	li	a5,3
    8000217c:	06f70b63          	beq	a4,a5,800021f2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002180:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002184:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002186:	efb5                	bnez	a5,80002202 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002188:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000218a:	00023917          	auipc	s2,0x23
    8000218e:	88e90913          	addi	s2,s2,-1906 # 80024a18 <pid_lock>
    80002192:	2781                	sext.w	a5,a5
    80002194:	079e                	slli	a5,a5,0x7
    80002196:	97ca                	add	a5,a5,s2
    80002198:	09c7a983          	lw	s3,156(a5)
    8000219c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    8000219e:	2781                	sext.w	a5,a5
    800021a0:	079e                	slli	a5,a5,0x7
    800021a2:	00023597          	auipc	a1,0x23
    800021a6:	89e58593          	addi	a1,a1,-1890 # 80024a40 <cpus+0x8>
    800021aa:	95be                	add	a1,a1,a5
    800021ac:	06848513          	addi	a0,s1,104
    800021b0:	00000097          	auipc	ra,0x0
    800021b4:	578080e7          	jalr	1400(ra) # 80002728 <swtch>
    800021b8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ba:	2781                	sext.w	a5,a5
    800021bc:	079e                	slli	a5,a5,0x7
    800021be:	97ca                	add	a5,a5,s2
    800021c0:	0937ae23          	sw	s3,156(a5)
}
    800021c4:	70a2                	ld	ra,40(sp)
    800021c6:	7402                	ld	s0,32(sp)
    800021c8:	64e2                	ld	s1,24(sp)
    800021ca:	6942                	ld	s2,16(sp)
    800021cc:	69a2                	ld	s3,8(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret
    panic("sched p->lock");
    800021d2:	00006517          	auipc	a0,0x6
    800021d6:	1f650513          	addi	a0,a0,502 # 800083c8 <digits+0x258>
    800021da:	ffffe097          	auipc	ra,0xffffe
    800021de:	38a080e7          	jalr	906(ra) # 80000564 <panic>
    panic("sched locks");
    800021e2:	00006517          	auipc	a0,0x6
    800021e6:	1f650513          	addi	a0,a0,502 # 800083d8 <digits+0x268>
    800021ea:	ffffe097          	auipc	ra,0xffffe
    800021ee:	37a080e7          	jalr	890(ra) # 80000564 <panic>
    panic("sched running");
    800021f2:	00006517          	auipc	a0,0x6
    800021f6:	1f650513          	addi	a0,a0,502 # 800083e8 <digits+0x278>
    800021fa:	ffffe097          	auipc	ra,0xffffe
    800021fe:	36a080e7          	jalr	874(ra) # 80000564 <panic>
    panic("sched interruptible");
    80002202:	00006517          	auipc	a0,0x6
    80002206:	1f650513          	addi	a0,a0,502 # 800083f8 <digits+0x288>
    8000220a:	ffffe097          	auipc	ra,0xffffe
    8000220e:	35a080e7          	jalr	858(ra) # 80000564 <panic>

0000000080002212 <exit>:
{
    80002212:	7179                	addi	sp,sp,-48
    80002214:	f406                	sd	ra,40(sp)
    80002216:	f022                	sd	s0,32(sp)
    80002218:	ec26                	sd	s1,24(sp)
    8000221a:	e84a                	sd	s2,16(sp)
    8000221c:	e44e                	sd	s3,8(sp)
    8000221e:	e052                	sd	s4,0(sp)
    80002220:	1800                	addi	s0,sp,48
    80002222:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002224:	00000097          	auipc	ra,0x0
    80002228:	924080e7          	jalr	-1756(ra) # 80001b48 <myproc>
    8000222c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000222e:	00007797          	auipc	a5,0x7
    80002232:	cf27b783          	ld	a5,-782(a5) # 80008f20 <initproc>
    80002236:	0d850493          	addi	s1,a0,216
    8000223a:	15850913          	addi	s2,a0,344
    8000223e:	02a79363          	bne	a5,a0,80002264 <exit+0x52>
    panic("init exiting");
    80002242:	00006517          	auipc	a0,0x6
    80002246:	1ce50513          	addi	a0,a0,462 # 80008410 <digits+0x2a0>
    8000224a:	ffffe097          	auipc	ra,0xffffe
    8000224e:	31a080e7          	jalr	794(ra) # 80000564 <panic>
      fileclose(f);
    80002252:	00002097          	auipc	ra,0x2
    80002256:	44a080e7          	jalr	1098(ra) # 8000469c <fileclose>
      p->ofile[fd] = 0;
    8000225a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000225e:	04a1                	addi	s1,s1,8
    80002260:	01248563          	beq	s1,s2,8000226a <exit+0x58>
    if(p->ofile[fd]){
    80002264:	6088                	ld	a0,0(s1)
    80002266:	f575                	bnez	a0,80002252 <exit+0x40>
    80002268:	bfdd                	j	8000225e <exit+0x4c>
  begin_op();
    8000226a:	00002097          	auipc	ra,0x2
    8000226e:	f68080e7          	jalr	-152(ra) # 800041d2 <begin_op>
  iput(p->cwd);
    80002272:	1589b503          	ld	a0,344(s3)
    80002276:	00001097          	auipc	ra,0x1
    8000227a:	754080e7          	jalr	1876(ra) # 800039ca <iput>
  end_op();
    8000227e:	00002097          	auipc	ra,0x2
    80002282:	fd4080e7          	jalr	-44(ra) # 80004252 <end_op>
  p->cwd = 0;
    80002286:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    8000228a:	00007497          	auipc	s1,0x7
    8000228e:	c9648493          	addi	s1,s1,-874 # 80008f20 <initproc>
    80002292:	6088                	ld	a0,0(s1)
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	8fe080e7          	jalr	-1794(ra) # 80000b92 <acquire>
  wakeup1(initproc);
    8000229c:	6088                	ld	a0,0(s1)
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	76a080e7          	jalr	1898(ra) # 80001a08 <wakeup1>
  release(&initproc->lock);
    800022a6:	6088                	ld	a0,0(s1)
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	9ba080e7          	jalr	-1606(ra) # 80000c62 <release>
  acquire(&p->lock);
    800022b0:	854e                	mv	a0,s3
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	8e0080e7          	jalr	-1824(ra) # 80000b92 <acquire>
  struct proc *original_parent = p->parent;
    800022ba:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800022be:	854e                	mv	a0,s3
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	9a2080e7          	jalr	-1630(ra) # 80000c62 <release>
  acquire(&original_parent->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	8c8080e7          	jalr	-1848(ra) # 80000b92 <acquire>
  acquire(&p->lock);
    800022d2:	854e                	mv	a0,s3
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	8be080e7          	jalr	-1858(ra) # 80000b92 <acquire>
  reparent(p);
    800022dc:	854e                	mv	a0,s3
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	d16080e7          	jalr	-746(ra) # 80001ff4 <reparent>
  wakeup1(original_parent);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	720080e7          	jalr	1824(ra) # 80001a08 <wakeup1>
  p->xstate = status;
    800022f0:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800022f4:	4791                	li	a5,4
    800022f6:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	966080e7          	jalr	-1690(ra) # 80000c62 <release>
  sched();
    80002304:	00000097          	auipc	ra,0x0
    80002308:	e38080e7          	jalr	-456(ra) # 8000213c <sched>
  panic("zombie exit");
    8000230c:	00006517          	auipc	a0,0x6
    80002310:	11450513          	addi	a0,a0,276 # 80008420 <digits+0x2b0>
    80002314:	ffffe097          	auipc	ra,0xffffe
    80002318:	250080e7          	jalr	592(ra) # 80000564 <panic>

000000008000231c <yield>:
{
    8000231c:	1101                	addi	sp,sp,-32
    8000231e:	ec06                	sd	ra,24(sp)
    80002320:	e822                	sd	s0,16(sp)
    80002322:	e426                	sd	s1,8(sp)
    80002324:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002326:	00000097          	auipc	ra,0x0
    8000232a:	822080e7          	jalr	-2014(ra) # 80001b48 <myproc>
    8000232e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	862080e7          	jalr	-1950(ra) # 80000b92 <acquire>
  p->state = RUNNABLE;
    80002338:	4789                	li	a5,2
    8000233a:	d09c                	sw	a5,32(s1)
  sched();
    8000233c:	00000097          	auipc	ra,0x0
    80002340:	e00080e7          	jalr	-512(ra) # 8000213c <sched>
  release(&p->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	91c080e7          	jalr	-1764(ra) # 80000c62 <release>
}
    8000234e:	60e2                	ld	ra,24(sp)
    80002350:	6442                	ld	s0,16(sp)
    80002352:	64a2                	ld	s1,8(sp)
    80002354:	6105                	addi	sp,sp,32
    80002356:	8082                	ret

0000000080002358 <sleep>:
{
    80002358:	7179                	addi	sp,sp,-48
    8000235a:	f406                	sd	ra,40(sp)
    8000235c:	f022                	sd	s0,32(sp)
    8000235e:	ec26                	sd	s1,24(sp)
    80002360:	e84a                	sd	s2,16(sp)
    80002362:	e44e                	sd	s3,8(sp)
    80002364:	1800                	addi	s0,sp,48
    80002366:	89aa                	mv	s3,a0
    80002368:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000236a:	fffff097          	auipc	ra,0xfffff
    8000236e:	7de080e7          	jalr	2014(ra) # 80001b48 <myproc>
    80002372:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002374:	05250663          	beq	a0,s2,800023c0 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	81a080e7          	jalr	-2022(ra) # 80000b92 <acquire>
    release(lk);
    80002380:	854a                	mv	a0,s2
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	8e0080e7          	jalr	-1824(ra) # 80000c62 <release>
  p->chan = chan;
    8000238a:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000238e:	4785                	li	a5,1
    80002390:	d09c                	sw	a5,32(s1)
  sched();
    80002392:	00000097          	auipc	ra,0x0
    80002396:	daa080e7          	jalr	-598(ra) # 8000213c <sched>
  p->chan = 0;
    8000239a:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	8c2080e7          	jalr	-1854(ra) # 80000c62 <release>
    acquire(lk);
    800023a8:	854a                	mv	a0,s2
    800023aa:	ffffe097          	auipc	ra,0xffffe
    800023ae:	7e8080e7          	jalr	2024(ra) # 80000b92 <acquire>
}
    800023b2:	70a2                	ld	ra,40(sp)
    800023b4:	7402                	ld	s0,32(sp)
    800023b6:	64e2                	ld	s1,24(sp)
    800023b8:	6942                	ld	s2,16(sp)
    800023ba:	69a2                	ld	s3,8(sp)
    800023bc:	6145                	addi	sp,sp,48
    800023be:	8082                	ret
  p->chan = chan;
    800023c0:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023c4:	4785                	li	a5,1
    800023c6:	d11c                	sw	a5,32(a0)
  sched();
    800023c8:	00000097          	auipc	ra,0x0
    800023cc:	d74080e7          	jalr	-652(ra) # 8000213c <sched>
  p->chan = 0;
    800023d0:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800023d4:	bff9                	j	800023b2 <sleep+0x5a>

00000000800023d6 <wait>:
{
    800023d6:	715d                	addi	sp,sp,-80
    800023d8:	e486                	sd	ra,72(sp)
    800023da:	e0a2                	sd	s0,64(sp)
    800023dc:	fc26                	sd	s1,56(sp)
    800023de:	f84a                	sd	s2,48(sp)
    800023e0:	f44e                	sd	s3,40(sp)
    800023e2:	f052                	sd	s4,32(sp)
    800023e4:	ec56                	sd	s5,24(sp)
    800023e6:	e85a                	sd	s6,16(sp)
    800023e8:	e45e                	sd	s7,8(sp)
    800023ea:	0880                	addi	s0,sp,80
    800023ec:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	75a080e7          	jalr	1882(ra) # 80001b48 <myproc>
    800023f6:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	79a080e7          	jalr	1946(ra) # 80000b92 <acquire>
    havekids = 0;
    80002400:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002402:	4a11                	li	s4,4
        havekids = 1;
    80002404:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002406:	00029997          	auipc	s3,0x29
    8000240a:	a3298993          	addi	s3,s3,-1486 # 8002ae38 <tickslock>
    havekids = 0;
    8000240e:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002410:	00023497          	auipc	s1,0x23
    80002414:	a2848493          	addi	s1,s1,-1496 # 80024e38 <proc>
    80002418:	a08d                	j	8000247a <wait+0xa4>
          pid = np->pid;
    8000241a:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000241e:	000b0e63          	beqz	s6,8000243a <wait+0x64>
    80002422:	4691                	li	a3,4
    80002424:	03c48613          	addi	a2,s1,60
    80002428:	85da                	mv	a1,s6
    8000242a:	05893503          	ld	a0,88(s2)
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	3d2080e7          	jalr	978(ra) # 80001800 <copyout>
    80002436:	02054263          	bltz	a0,8000245a <wait+0x84>
          freeproc(np);
    8000243a:	8526                	mv	a0,s1
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	934080e7          	jalr	-1740(ra) # 80001d70 <freeproc>
          release(&np->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	81c080e7          	jalr	-2020(ra) # 80000c62 <release>
          release(&p->lock);
    8000244e:	854a                	mv	a0,s2
    80002450:	fffff097          	auipc	ra,0xfffff
    80002454:	812080e7          	jalr	-2030(ra) # 80000c62 <release>
          return pid;
    80002458:	a8a9                	j	800024b2 <wait+0xdc>
            release(&np->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	806080e7          	jalr	-2042(ra) # 80000c62 <release>
            release(&p->lock);
    80002464:	854a                	mv	a0,s2
    80002466:	ffffe097          	auipc	ra,0xffffe
    8000246a:	7fc080e7          	jalr	2044(ra) # 80000c62 <release>
            return -1;
    8000246e:	59fd                	li	s3,-1
    80002470:	a089                	j	800024b2 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002472:	18048493          	addi	s1,s1,384
    80002476:	03348463          	beq	s1,s3,8000249e <wait+0xc8>
      if(np->parent == p){
    8000247a:	749c                	ld	a5,40(s1)
    8000247c:	ff279be3          	bne	a5,s2,80002472 <wait+0x9c>
        acquire(&np->lock);
    80002480:	8526                	mv	a0,s1
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	710080e7          	jalr	1808(ra) # 80000b92 <acquire>
        if(np->state == ZOMBIE){
    8000248a:	509c                	lw	a5,32(s1)
    8000248c:	f94787e3          	beq	a5,s4,8000241a <wait+0x44>
        release(&np->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	7d0080e7          	jalr	2000(ra) # 80000c62 <release>
        havekids = 1;
    8000249a:	8756                	mv	a4,s5
    8000249c:	bfd9                	j	80002472 <wait+0x9c>
    if(!havekids || p->killed){
    8000249e:	c701                	beqz	a4,800024a6 <wait+0xd0>
    800024a0:	03892783          	lw	a5,56(s2)
    800024a4:	c39d                	beqz	a5,800024ca <wait+0xf4>
      release(&p->lock);
    800024a6:	854a                	mv	a0,s2
    800024a8:	ffffe097          	auipc	ra,0xffffe
    800024ac:	7ba080e7          	jalr	1978(ra) # 80000c62 <release>
      return -1;
    800024b0:	59fd                	li	s3,-1
}
    800024b2:	854e                	mv	a0,s3
    800024b4:	60a6                	ld	ra,72(sp)
    800024b6:	6406                	ld	s0,64(sp)
    800024b8:	74e2                	ld	s1,56(sp)
    800024ba:	7942                	ld	s2,48(sp)
    800024bc:	79a2                	ld	s3,40(sp)
    800024be:	7a02                	ld	s4,32(sp)
    800024c0:	6ae2                	ld	s5,24(sp)
    800024c2:	6b42                	ld	s6,16(sp)
    800024c4:	6ba2                	ld	s7,8(sp)
    800024c6:	6161                	addi	sp,sp,80
    800024c8:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800024ca:	85ca                	mv	a1,s2
    800024cc:	854a                	mv	a0,s2
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	e8a080e7          	jalr	-374(ra) # 80002358 <sleep>
    havekids = 0;
    800024d6:	bf25                	j	8000240e <wait+0x38>

00000000800024d8 <wakeup>:
{
    800024d8:	7139                	addi	sp,sp,-64
    800024da:	fc06                	sd	ra,56(sp)
    800024dc:	f822                	sd	s0,48(sp)
    800024de:	f426                	sd	s1,40(sp)
    800024e0:	f04a                	sd	s2,32(sp)
    800024e2:	ec4e                	sd	s3,24(sp)
    800024e4:	e852                	sd	s4,16(sp)
    800024e6:	e456                	sd	s5,8(sp)
    800024e8:	e05a                	sd	s6,0(sp)
    800024ea:	0080                	addi	s0,sp,64
    800024ec:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ee:	00023497          	auipc	s1,0x23
    800024f2:	94a48493          	addi	s1,s1,-1718 # 80024e38 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024f6:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024f8:	4b09                	li	s6,2
      p->arrival = arrival_counter++;  // record join order
    800024fa:	00007a97          	auipc	s5,0x7
    800024fe:	a1ea8a93          	addi	s5,s5,-1506 # 80008f18 <arrival_counter>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002502:	00029917          	auipc	s2,0x29
    80002506:	93690913          	addi	s2,s2,-1738 # 8002ae38 <tickslock>
    8000250a:	a811                	j	8000251e <wakeup+0x46>
    release(&p->lock);
    8000250c:	8526                	mv	a0,s1
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	754080e7          	jalr	1876(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002516:	18048493          	addi	s1,s1,384
    8000251a:	03248863          	beq	s1,s2,8000254a <wakeup+0x72>
    acquire(&p->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	672080e7          	jalr	1650(ra) # 80000b92 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002528:	509c                	lw	a5,32(s1)
    8000252a:	ff3791e3          	bne	a5,s3,8000250c <wakeup+0x34>
    8000252e:	789c                	ld	a5,48(s1)
    80002530:	fd479ee3          	bne	a5,s4,8000250c <wakeup+0x34>
      p->state = RUNNABLE;
    80002534:	0364a023          	sw	s6,32(s1)
      p->arrival = arrival_counter++;  // record join order
    80002538:	000ab783          	ld	a5,0(s5)
    8000253c:	00178713          	addi	a4,a5,1
    80002540:	00eab023          	sd	a4,0(s5)
    80002544:	16f4bc23          	sd	a5,376(s1)
    80002548:	b7d1                	j	8000250c <wakeup+0x34>
}
    8000254a:	70e2                	ld	ra,56(sp)
    8000254c:	7442                	ld	s0,48(sp)
    8000254e:	74a2                	ld	s1,40(sp)
    80002550:	7902                	ld	s2,32(sp)
    80002552:	69e2                	ld	s3,24(sp)
    80002554:	6a42                	ld	s4,16(sp)
    80002556:	6aa2                	ld	s5,8(sp)
    80002558:	6b02                	ld	s6,0(sp)
    8000255a:	6121                	addi	sp,sp,64
    8000255c:	8082                	ret

000000008000255e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000255e:	7179                	addi	sp,sp,-48
    80002560:	f406                	sd	ra,40(sp)
    80002562:	f022                	sd	s0,32(sp)
    80002564:	ec26                	sd	s1,24(sp)
    80002566:	e84a                	sd	s2,16(sp)
    80002568:	e44e                	sd	s3,8(sp)
    8000256a:	1800                	addi	s0,sp,48
    8000256c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000256e:	00023497          	auipc	s1,0x23
    80002572:	8ca48493          	addi	s1,s1,-1846 # 80024e38 <proc>
    80002576:	00029997          	auipc	s3,0x29
    8000257a:	8c298993          	addi	s3,s3,-1854 # 8002ae38 <tickslock>
    acquire(&p->lock);
    8000257e:	8526                	mv	a0,s1
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	612080e7          	jalr	1554(ra) # 80000b92 <acquire>
    if(p->pid == pid){
    80002588:	40bc                	lw	a5,64(s1)
    8000258a:	01278d63          	beq	a5,s2,800025a4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	6d2080e7          	jalr	1746(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002598:	18048493          	addi	s1,s1,384
    8000259c:	ff3491e3          	bne	s1,s3,8000257e <kill+0x20>
  }
  return -1;
    800025a0:	557d                	li	a0,-1
    800025a2:	a821                	j	800025ba <kill+0x5c>
      p->killed = 1;
    800025a4:	4785                	li	a5,1
    800025a6:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800025a8:	5098                	lw	a4,32(s1)
    800025aa:	00f70f63          	beq	a4,a5,800025c8 <kill+0x6a>
      release(&p->lock);
    800025ae:	8526                	mv	a0,s1
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	6b2080e7          	jalr	1714(ra) # 80000c62 <release>
      return 0;
    800025b8:	4501                	li	a0,0
}
    800025ba:	70a2                	ld	ra,40(sp)
    800025bc:	7402                	ld	s0,32(sp)
    800025be:	64e2                	ld	s1,24(sp)
    800025c0:	6942                	ld	s2,16(sp)
    800025c2:	69a2                	ld	s3,8(sp)
    800025c4:	6145                	addi	sp,sp,48
    800025c6:	8082                	ret
        p->state = RUNNABLE;
    800025c8:	4789                	li	a5,2
    800025ca:	d09c                	sw	a5,32(s1)
    800025cc:	b7cd                	j	800025ae <kill+0x50>

00000000800025ce <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025ce:	7179                	addi	sp,sp,-48
    800025d0:	f406                	sd	ra,40(sp)
    800025d2:	f022                	sd	s0,32(sp)
    800025d4:	ec26                	sd	s1,24(sp)
    800025d6:	e84a                	sd	s2,16(sp)
    800025d8:	e44e                	sd	s3,8(sp)
    800025da:	e052                	sd	s4,0(sp)
    800025dc:	1800                	addi	s0,sp,48
    800025de:	84aa                	mv	s1,a0
    800025e0:	892e                	mv	s2,a1
    800025e2:	89b2                	mv	s3,a2
    800025e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025e6:	fffff097          	auipc	ra,0xfffff
    800025ea:	562080e7          	jalr	1378(ra) # 80001b48 <myproc>
  if(user_dst){
    800025ee:	c08d                	beqz	s1,80002610 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025f0:	86d2                	mv	a3,s4
    800025f2:	864e                	mv	a2,s3
    800025f4:	85ca                	mv	a1,s2
    800025f6:	6d28                	ld	a0,88(a0)
    800025f8:	fffff097          	auipc	ra,0xfffff
    800025fc:	208080e7          	jalr	520(ra) # 80001800 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002600:	70a2                	ld	ra,40(sp)
    80002602:	7402                	ld	s0,32(sp)
    80002604:	64e2                	ld	s1,24(sp)
    80002606:	6942                	ld	s2,16(sp)
    80002608:	69a2                	ld	s3,8(sp)
    8000260a:	6a02                	ld	s4,0(sp)
    8000260c:	6145                	addi	sp,sp,48
    8000260e:	8082                	ret
    memmove((char *)dst, src, len);
    80002610:	000a061b          	sext.w	a2,s4
    80002614:	85ce                	mv	a1,s3
    80002616:	854a                	mv	a0,s2
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	8ba080e7          	jalr	-1862(ra) # 80000ed2 <memmove>
    return 0;
    80002620:	8526                	mv	a0,s1
    80002622:	bff9                	j	80002600 <either_copyout+0x32>

0000000080002624 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002624:	7179                	addi	sp,sp,-48
    80002626:	f406                	sd	ra,40(sp)
    80002628:	f022                	sd	s0,32(sp)
    8000262a:	ec26                	sd	s1,24(sp)
    8000262c:	e84a                	sd	s2,16(sp)
    8000262e:	e44e                	sd	s3,8(sp)
    80002630:	e052                	sd	s4,0(sp)
    80002632:	1800                	addi	s0,sp,48
    80002634:	892a                	mv	s2,a0
    80002636:	84ae                	mv	s1,a1
    80002638:	89b2                	mv	s3,a2
    8000263a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000263c:	fffff097          	auipc	ra,0xfffff
    80002640:	50c080e7          	jalr	1292(ra) # 80001b48 <myproc>
  if(user_src){
    80002644:	c08d                	beqz	s1,80002666 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002646:	86d2                	mv	a3,s4
    80002648:	864e                	mv	a2,s3
    8000264a:	85ca                	mv	a1,s2
    8000264c:	6d28                	ld	a0,88(a0)
    8000264e:	fffff097          	auipc	ra,0xfffff
    80002652:	23e080e7          	jalr	574(ra) # 8000188c <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6a02                	ld	s4,0(sp)
    80002662:	6145                	addi	sp,sp,48
    80002664:	8082                	ret
    memmove(dst, (char*)src, len);
    80002666:	000a061b          	sext.w	a2,s4
    8000266a:	85ce                	mv	a1,s3
    8000266c:	854a                	mv	a0,s2
    8000266e:	fffff097          	auipc	ra,0xfffff
    80002672:	864080e7          	jalr	-1948(ra) # 80000ed2 <memmove>
    return 0;
    80002676:	8526                	mv	a0,s1
    80002678:	bff9                	j	80002656 <either_copyin+0x32>

000000008000267a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000267a:	715d                	addi	sp,sp,-80
    8000267c:	e486                	sd	ra,72(sp)
    8000267e:	e0a2                	sd	s0,64(sp)
    80002680:	fc26                	sd	s1,56(sp)
    80002682:	f84a                	sd	s2,48(sp)
    80002684:	f44e                	sd	s3,40(sp)
    80002686:	f052                	sd	s4,32(sp)
    80002688:	ec56                	sd	s5,24(sp)
    8000268a:	e85a                	sd	s6,16(sp)
    8000268c:	e45e                	sd	s7,8(sp)
    8000268e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002690:	00006517          	auipc	a0,0x6
    80002694:	b7050513          	addi	a0,a0,-1168 # 80008200 <digits+0x90>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	f2e080e7          	jalr	-210(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026a0:	00023497          	auipc	s1,0x23
    800026a4:	8f848493          	addi	s1,s1,-1800 # 80024f98 <proc+0x160>
    800026a8:	00029917          	auipc	s2,0x29
    800026ac:	8f090913          	addi	s2,s2,-1808 # 8002af98 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b0:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800026b2:	00006997          	auipc	s3,0x6
    800026b6:	d7e98993          	addi	s3,s3,-642 # 80008430 <digits+0x2c0>
    printf("%d %s %s", p->pid, state, p->name);
    800026ba:	00006a97          	auipc	s5,0x6
    800026be:	d7ea8a93          	addi	s5,s5,-642 # 80008438 <digits+0x2c8>
    printf("\n");
    800026c2:	00006a17          	auipc	s4,0x6
    800026c6:	b3ea0a13          	addi	s4,s4,-1218 # 80008200 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ca:	00006b97          	auipc	s7,0x6
    800026ce:	da6b8b93          	addi	s7,s7,-602 # 80008470 <states.0>
    800026d2:	a00d                	j	800026f4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026d4:	ee06a583          	lw	a1,-288(a3)
    800026d8:	8556                	mv	a0,s5
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	eec080e7          	jalr	-276(ra) # 800005c6 <printf>
    printf("\n");
    800026e2:	8552                	mv	a0,s4
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	ee2080e7          	jalr	-286(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ec:	18048493          	addi	s1,s1,384
    800026f0:	03248163          	beq	s1,s2,80002712 <procdump+0x98>
    if(p->state == UNUSED)
    800026f4:	86a6                	mv	a3,s1
    800026f6:	ec04a783          	lw	a5,-320(s1)
    800026fa:	dbed                	beqz	a5,800026ec <procdump+0x72>
      state = "???";
    800026fc:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026fe:	fcfb6be3          	bltu	s6,a5,800026d4 <procdump+0x5a>
    80002702:	1782                	slli	a5,a5,0x20
    80002704:	9381                	srli	a5,a5,0x20
    80002706:	078e                	slli	a5,a5,0x3
    80002708:	97de                	add	a5,a5,s7
    8000270a:	6390                	ld	a2,0(a5)
    8000270c:	f661                	bnez	a2,800026d4 <procdump+0x5a>
      state = "???";
    8000270e:	864e                	mv	a2,s3
    80002710:	b7d1                	j	800026d4 <procdump+0x5a>
  }
}
    80002712:	60a6                	ld	ra,72(sp)
    80002714:	6406                	ld	s0,64(sp)
    80002716:	74e2                	ld	s1,56(sp)
    80002718:	7942                	ld	s2,48(sp)
    8000271a:	79a2                	ld	s3,40(sp)
    8000271c:	7a02                	ld	s4,32(sp)
    8000271e:	6ae2                	ld	s5,24(sp)
    80002720:	6b42                	ld	s6,16(sp)
    80002722:	6ba2                	ld	s7,8(sp)
    80002724:	6161                	addi	sp,sp,80
    80002726:	8082                	ret

0000000080002728 <swtch>:
    80002728:	00153023          	sd	ra,0(a0)
    8000272c:	00253423          	sd	sp,8(a0)
    80002730:	e900                	sd	s0,16(a0)
    80002732:	ed04                	sd	s1,24(a0)
    80002734:	03253023          	sd	s2,32(a0)
    80002738:	03353423          	sd	s3,40(a0)
    8000273c:	03453823          	sd	s4,48(a0)
    80002740:	03553c23          	sd	s5,56(a0)
    80002744:	05653023          	sd	s6,64(a0)
    80002748:	05753423          	sd	s7,72(a0)
    8000274c:	05853823          	sd	s8,80(a0)
    80002750:	05953c23          	sd	s9,88(a0)
    80002754:	07a53023          	sd	s10,96(a0)
    80002758:	07b53423          	sd	s11,104(a0)
    8000275c:	0005b083          	ld	ra,0(a1)
    80002760:	0085b103          	ld	sp,8(a1)
    80002764:	6980                	ld	s0,16(a1)
    80002766:	6d84                	ld	s1,24(a1)
    80002768:	0205b903          	ld	s2,32(a1)
    8000276c:	0285b983          	ld	s3,40(a1)
    80002770:	0305ba03          	ld	s4,48(a1)
    80002774:	0385ba83          	ld	s5,56(a1)
    80002778:	0405bb03          	ld	s6,64(a1)
    8000277c:	0485bb83          	ld	s7,72(a1)
    80002780:	0505bc03          	ld	s8,80(a1)
    80002784:	0585bc83          	ld	s9,88(a1)
    80002788:	0605bd03          	ld	s10,96(a1)
    8000278c:	0685bd83          	ld	s11,104(a1)
    80002790:	8082                	ret

0000000080002792 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002792:	1141                	addi	sp,sp,-16
    80002794:	e422                	sd	s0,8(sp)
    80002796:	0800                	addi	s0,sp,16
    80002798:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000279a:	00151713          	slli	a4,a0,0x1
    8000279e:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    800027a0:	04054c63          	bltz	a0,800027f8 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    800027a4:	5685                	li	a3,-31
    800027a6:	8285                	srli	a3,a3,0x1
    800027a8:	8ee9                	and	a3,a3,a0
    800027aa:	caad                	beqz	a3,8000281c <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    800027ac:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    800027ae:	00006517          	auipc	a0,0x6
    800027b2:	cea50513          	addi	a0,a0,-790 # 80008498 <states.0+0x28>
    } else if (code <= 23) {
    800027b6:	06e6f063          	bgeu	a3,a4,80002816 <scause_desc+0x84>
    } else if (code <= 31) {
    800027ba:	fc100693          	li	a3,-63
    800027be:	8285                	srli	a3,a3,0x1
    800027c0:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    800027c2:	00006517          	auipc	a0,0x6
    800027c6:	cfe50513          	addi	a0,a0,-770 # 800084c0 <states.0+0x50>
    } else if (code <= 31) {
    800027ca:	c6b1                	beqz	a3,80002816 <scause_desc+0x84>
    } else if (code <= 47) {
    800027cc:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    800027d0:	00006517          	auipc	a0,0x6
    800027d4:	cc850513          	addi	a0,a0,-824 # 80008498 <states.0+0x28>
    } else if (code <= 47) {
    800027d8:	02e6ff63          	bgeu	a3,a4,80002816 <scause_desc+0x84>
    } else if (code <= 63) {
    800027dc:	f8100513          	li	a0,-127
    800027e0:	8105                	srli	a0,a0,0x1
    800027e2:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800027e4:	00006517          	auipc	a0,0x6
    800027e8:	cdc50513          	addi	a0,a0,-804 # 800084c0 <states.0+0x50>
    } else if (code <= 63) {
    800027ec:	c78d                	beqz	a5,80002816 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800027ee:	00006517          	auipc	a0,0x6
    800027f2:	caa50513          	addi	a0,a0,-854 # 80008498 <states.0+0x28>
    800027f6:	a005                	j	80002816 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800027f8:	5505                	li	a0,-31
    800027fa:	8105                	srli	a0,a0,0x1
    800027fc:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800027fe:	00006517          	auipc	a0,0x6
    80002802:	ce250513          	addi	a0,a0,-798 # 800084e0 <states.0+0x70>
    if (code < NELEM(intr_desc)) {
    80002806:	eb81                	bnez	a5,80002816 <scause_desc+0x84>
      return intr_desc[code];
    80002808:	070e                	slli	a4,a4,0x3
    8000280a:	00006797          	auipc	a5,0x6
    8000280e:	fe678793          	addi	a5,a5,-26 # 800087f0 <intr_desc.1>
    80002812:	973e                	add	a4,a4,a5
    80002814:	6308                	ld	a0,0(a4)
    }
  }
}
    80002816:	6422                	ld	s0,8(sp)
    80002818:	0141                	addi	sp,sp,16
    8000281a:	8082                	ret
      return nointr_desc[code];
    8000281c:	070e                	slli	a4,a4,0x3
    8000281e:	00006797          	auipc	a5,0x6
    80002822:	fd278793          	addi	a5,a5,-46 # 800087f0 <intr_desc.1>
    80002826:	973e                	add	a4,a4,a5
    80002828:	6348                	ld	a0,128(a4)
    8000282a:	b7f5                	j	80002816 <scause_desc+0x84>

000000008000282c <trapinit>:
{
    8000282c:	1141                	addi	sp,sp,-16
    8000282e:	e406                	sd	ra,8(sp)
    80002830:	e022                	sd	s0,0(sp)
    80002832:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002834:	00006597          	auipc	a1,0x6
    80002838:	ccc58593          	addi	a1,a1,-820 # 80008500 <states.0+0x90>
    8000283c:	00028517          	auipc	a0,0x28
    80002840:	5fc50513          	addi	a0,a0,1532 # 8002ae38 <tickslock>
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	278080e7          	jalr	632(ra) # 80000abc <initlock>
}
    8000284c:	60a2                	ld	ra,8(sp)
    8000284e:	6402                	ld	s0,0(sp)
    80002850:	0141                	addi	sp,sp,16
    80002852:	8082                	ret

0000000080002854 <trapinithart>:
{
    80002854:	1141                	addi	sp,sp,-16
    80002856:	e422                	sd	s0,8(sp)
    80002858:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285a:	00003797          	auipc	a5,0x3
    8000285e:	47678793          	addi	a5,a5,1142 # 80005cd0 <kernelvec>
    80002862:	10579073          	csrw	stvec,a5
}
    80002866:	6422                	ld	s0,8(sp)
    80002868:	0141                	addi	sp,sp,16
    8000286a:	8082                	ret

000000008000286c <usertrapret>:
{
    8000286c:	1141                	addi	sp,sp,-16
    8000286e:	e406                	sd	ra,8(sp)
    80002870:	e022                	sd	s0,0(sp)
    80002872:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002874:	fffff097          	auipc	ra,0xfffff
    80002878:	2d4080e7          	jalr	724(ra) # 80001b48 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002880:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002882:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002886:	00004617          	auipc	a2,0x4
    8000288a:	77a60613          	addi	a2,a2,1914 # 80007000 <_trampoline>
    8000288e:	00004697          	auipc	a3,0x4
    80002892:	77268693          	addi	a3,a3,1906 # 80007000 <_trampoline>
    80002896:	8e91                	sub	a3,a3,a2
    80002898:	040007b7          	lui	a5,0x4000
    8000289c:	17fd                	addi	a5,a5,-1
    8000289e:	07b2                	slli	a5,a5,0xc
    800028a0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a2:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028a6:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028a8:	180026f3          	csrr	a3,satp
    800028ac:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028ae:	7138                	ld	a4,96(a0)
    800028b0:	6534                	ld	a3,72(a0)
    800028b2:	6585                	lui	a1,0x1
    800028b4:	96ae                	add	a3,a3,a1
    800028b6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028b8:	7138                	ld	a4,96(a0)
    800028ba:	00000697          	auipc	a3,0x0
    800028be:	12268693          	addi	a3,a3,290 # 800029dc <usertrap>
    800028c2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028c4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028c6:	8692                	mv	a3,tp
    800028c8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ca:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028ce:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028d2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d6:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    800028da:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028dc:	6f18                	ld	a4,24(a4)
    800028de:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    800028e2:	6d2c                	ld	a1,88(a0)
    800028e4:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800028e6:	00004717          	auipc	a4,0x4
    800028ea:	7aa70713          	addi	a4,a4,1962 # 80007090 <userret>
    800028ee:	8f11                	sub	a4,a4,a2
    800028f0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    800028f2:	577d                	li	a4,-1
    800028f4:	177e                	slli	a4,a4,0x3f
    800028f6:	8dd9                	or	a1,a1,a4
    800028f8:	17053503          	ld	a0,368(a0)
    800028fc:	9782                	jalr	a5
}
    800028fe:	60a2                	ld	ra,8(sp)
    80002900:	6402                	ld	s0,0(sp)
    80002902:	0141                	addi	sp,sp,16
    80002904:	8082                	ret

0000000080002906 <clockintr>:
{
    80002906:	1101                	addi	sp,sp,-32
    80002908:	ec06                	sd	ra,24(sp)
    8000290a:	e822                	sd	s0,16(sp)
    8000290c:	e426                	sd	s1,8(sp)
    8000290e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002910:	00028497          	auipc	s1,0x28
    80002914:	52848493          	addi	s1,s1,1320 # 8002ae38 <tickslock>
    80002918:	8526                	mv	a0,s1
    8000291a:	ffffe097          	auipc	ra,0xffffe
    8000291e:	278080e7          	jalr	632(ra) # 80000b92 <acquire>
  ticks++;
    80002922:	00006517          	auipc	a0,0x6
    80002926:	60650513          	addi	a0,a0,1542 # 80008f28 <ticks>
    8000292a:	411c                	lw	a5,0(a0)
    8000292c:	2785                	addiw	a5,a5,1
    8000292e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002930:	00000097          	auipc	ra,0x0
    80002934:	ba8080e7          	jalr	-1112(ra) # 800024d8 <wakeup>
  release(&tickslock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	328080e7          	jalr	808(ra) # 80000c62 <release>
}
    80002942:	60e2                	ld	ra,24(sp)
    80002944:	6442                	ld	s0,16(sp)
    80002946:	64a2                	ld	s1,8(sp)
    80002948:	6105                	addi	sp,sp,32
    8000294a:	8082                	ret

000000008000294c <devintr>:
{
    8000294c:	1101                	addi	sp,sp,-32
    8000294e:	ec06                	sd	ra,24(sp)
    80002950:	e822                	sd	s0,16(sp)
    80002952:	e426                	sd	s1,8(sp)
    80002954:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002956:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    8000295a:	00074d63          	bltz	a4,80002974 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    8000295e:	57fd                	li	a5,-1
    80002960:	17fe                	slli	a5,a5,0x3f
    80002962:	0785                	addi	a5,a5,1
    return 0;
    80002964:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002966:	04f70a63          	beq	a4,a5,800029ba <devintr+0x6e>
}
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	64a2                	ld	s1,8(sp)
    80002970:	6105                	addi	sp,sp,32
    80002972:	8082                	ret
     (scause & 0xff) == 9){
    80002974:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002978:	46a5                	li	a3,9
    8000297a:	fed792e3          	bne	a5,a3,8000295e <devintr+0x12>
    int irq = plic_claim();
    8000297e:	00003097          	auipc	ra,0x3
    80002982:	45a080e7          	jalr	1114(ra) # 80005dd8 <plic_claim>
    80002986:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002988:	47a9                	li	a5,10
    8000298a:	00f50863          	beq	a0,a5,8000299a <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    8000298e:	4785                	li	a5,1
    80002990:	02f50063          	beq	a0,a5,800029b0 <devintr+0x64>
    return 1;
    80002994:	4505                	li	a0,1
    if(irq)
    80002996:	d8f1                	beqz	s1,8000296a <devintr+0x1e>
    80002998:	a029                	j	800029a2 <devintr+0x56>
      uartintr();
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	f76080e7          	jalr	-138(ra) # 80000910 <uartintr>
      plic_complete(irq);
    800029a2:	8526                	mv	a0,s1
    800029a4:	00003097          	auipc	ra,0x3
    800029a8:	458080e7          	jalr	1112(ra) # 80005dfc <plic_complete>
    return 1;
    800029ac:	4505                	li	a0,1
    800029ae:	bf75                	j	8000296a <devintr+0x1e>
      virtio_disk_intr();
    800029b0:	00004097          	auipc	ra,0x4
    800029b4:	904080e7          	jalr	-1788(ra) # 800062b4 <virtio_disk_intr>
    800029b8:	b7ed                	j	800029a2 <devintr+0x56>
    if(cpuid() == 0){
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	162080e7          	jalr	354(ra) # 80001b1c <cpuid>
    800029c2:	c901                	beqz	a0,800029d2 <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800029c4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800029c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029ca:	14479073          	csrw	sip,a5
    return 2;
    800029ce:	4509                	li	a0,2
    800029d0:	bf69                	j	8000296a <devintr+0x1e>
      clockintr();
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	f34080e7          	jalr	-204(ra) # 80002906 <clockintr>
    800029da:	b7ed                	j	800029c4 <devintr+0x78>

00000000800029dc <usertrap>:
{
    800029dc:	1101                	addi	sp,sp,-32
    800029de:	ec06                	sd	ra,24(sp)
    800029e0:	e822                	sd	s0,16(sp)
    800029e2:	e426                	sd	s1,8(sp)
    800029e4:	e04a                	sd	s2,0(sp)
    800029e6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800029ec:	1007f793          	andi	a5,a5,256
    800029f0:	e3ad                	bnez	a5,80002a52 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f2:	00003797          	auipc	a5,0x3
    800029f6:	2de78793          	addi	a5,a5,734 # 80005cd0 <kernelvec>
    800029fa:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029fe:	fffff097          	auipc	ra,0xfffff
    80002a02:	14a080e7          	jalr	330(ra) # 80001b48 <myproc>
    80002a06:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a08:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a0a:	14102773          	csrr	a4,sepc
    80002a0e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a10:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a14:	47a1                	li	a5,8
    80002a16:	04f71c63          	bne	a4,a5,80002a6e <usertrap+0x92>
    if(p->killed)
    80002a1a:	5d1c                	lw	a5,56(a0)
    80002a1c:	e3b9                	bnez	a5,80002a62 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002a1e:	70b8                	ld	a4,96(s1)
    80002a20:	6f1c                	ld	a5,24(a4)
    80002a22:	0791                	addi	a5,a5,4
    80002a24:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a2a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	2e2080e7          	jalr	738(ra) # 80002d14 <syscall>
  if(p->killed)
    80002a3a:	5c9c                	lw	a5,56(s1)
    80002a3c:	efbd                	bnez	a5,80002aba <usertrap+0xde>
  usertrapret();
    80002a3e:	00000097          	auipc	ra,0x0
    80002a42:	e2e080e7          	jalr	-466(ra) # 8000286c <usertrapret>
}
    80002a46:	60e2                	ld	ra,24(sp)
    80002a48:	6442                	ld	s0,16(sp)
    80002a4a:	64a2                	ld	s1,8(sp)
    80002a4c:	6902                	ld	s2,0(sp)
    80002a4e:	6105                	addi	sp,sp,32
    80002a50:	8082                	ret
    panic("usertrap: not from user mode");
    80002a52:	00006517          	auipc	a0,0x6
    80002a56:	ab650513          	addi	a0,a0,-1354 # 80008508 <states.0+0x98>
    80002a5a:	ffffe097          	auipc	ra,0xffffe
    80002a5e:	b0a080e7          	jalr	-1270(ra) # 80000564 <panic>
      exit(-1);
    80002a62:	557d                	li	a0,-1
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	7ae080e7          	jalr	1966(ra) # 80002212 <exit>
    80002a6c:	bf4d                	j	80002a1e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002a6e:	00000097          	auipc	ra,0x0
    80002a72:	ede080e7          	jalr	-290(ra) # 8000294c <devintr>
    80002a76:	f171                	bnez	a0,80002a3a <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a78:	14202973          	csrr	s2,scause
    80002a7c:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002a80:	00000097          	auipc	ra,0x0
    80002a84:	d12080e7          	jalr	-750(ra) # 80002792 <scause_desc>
    80002a88:	862a                	mv	a2,a0
    80002a8a:	40b4                	lw	a3,64(s1)
    80002a8c:	85ca                	mv	a1,s2
    80002a8e:	00006517          	auipc	a0,0x6
    80002a92:	a9a50513          	addi	a0,a0,-1382 # 80008528 <states.0+0xb8>
    80002a96:	ffffe097          	auipc	ra,0xffffe
    80002a9a:	b30080e7          	jalr	-1232(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aa2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002aa6:	00006517          	auipc	a0,0x6
    80002aaa:	ab250513          	addi	a0,a0,-1358 # 80008558 <states.0+0xe8>
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	b18080e7          	jalr	-1256(ra) # 800005c6 <printf>
    p->killed = 1;
    80002ab6:	4785                	li	a5,1
    80002ab8:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002aba:	557d                	li	a0,-1
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	756080e7          	jalr	1878(ra) # 80002212 <exit>
    80002ac4:	bfad                	j	80002a3e <usertrap+0x62>

0000000080002ac6 <kerneltrap>:
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	e84a                	sd	s2,16(sp)
    80002ad0:	e44e                	sd	s3,8(sp)
    80002ad2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002adc:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ae0:	1004f793          	andi	a5,s1,256
    80002ae4:	cb85                	beqz	a5,80002b14 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aea:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002aec:	ef85                	bnez	a5,80002b24 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	e5e080e7          	jalr	-418(ra) # 8000294c <devintr>
    80002af6:	cd1d                	beqz	a0,80002b34 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af8:	4789                	li	a5,2
    80002afa:	08f50063          	beq	a0,a5,80002b7a <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002afe:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b02:	10049073          	csrw	sstatus,s1
}
    80002b06:	70a2                	ld	ra,40(sp)
    80002b08:	7402                	ld	s0,32(sp)
    80002b0a:	64e2                	ld	s1,24(sp)
    80002b0c:	6942                	ld	s2,16(sp)
    80002b0e:	69a2                	ld	s3,8(sp)
    80002b10:	6145                	addi	sp,sp,48
    80002b12:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b14:	00006517          	auipc	a0,0x6
    80002b18:	a6450513          	addi	a0,a0,-1436 # 80008578 <states.0+0x108>
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a48080e7          	jalr	-1464(ra) # 80000564 <panic>
    panic("kerneltrap: interrupts enabled");
    80002b24:	00006517          	auipc	a0,0x6
    80002b28:	a7c50513          	addi	a0,a0,-1412 # 800085a0 <states.0+0x130>
    80002b2c:	ffffe097          	auipc	ra,0xffffe
    80002b30:	a38080e7          	jalr	-1480(ra) # 80000564 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002b34:	854e                	mv	a0,s3
    80002b36:	00000097          	auipc	ra,0x0
    80002b3a:	c5c080e7          	jalr	-932(ra) # 80002792 <scause_desc>
    80002b3e:	862a                	mv	a2,a0
    80002b40:	85ce                	mv	a1,s3
    80002b42:	00006517          	auipc	a0,0x6
    80002b46:	a7e50513          	addi	a0,a0,-1410 # 800085c0 <states.0+0x150>
    80002b4a:	ffffe097          	auipc	ra,0xffffe
    80002b4e:	a7c080e7          	jalr	-1412(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b52:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b56:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	a7650513          	addi	a0,a0,-1418 # 800085d0 <states.0+0x160>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	a64080e7          	jalr	-1436(ra) # 800005c6 <printf>
    panic("kerneltrap");
    80002b6a:	00006517          	auipc	a0,0x6
    80002b6e:	a7e50513          	addi	a0,a0,-1410 # 800085e8 <states.0+0x178>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	9f2080e7          	jalr	-1550(ra) # 80000564 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b7a:	fffff097          	auipc	ra,0xfffff
    80002b7e:	fce080e7          	jalr	-50(ra) # 80001b48 <myproc>
    80002b82:	dd35                	beqz	a0,80002afe <kerneltrap+0x38>
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	fc4080e7          	jalr	-60(ra) # 80001b48 <myproc>
    80002b8c:	5118                	lw	a4,32(a0)
    80002b8e:	478d                	li	a5,3
    80002b90:	f6f717e3          	bne	a4,a5,80002afe <kerneltrap+0x38>
    yield();
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	788080e7          	jalr	1928(ra) # 8000231c <yield>
    80002b9c:	b78d                	j	80002afe <kerneltrap+0x38>

0000000080002b9e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b9e:	1101                	addi	sp,sp,-32
    80002ba0:	ec06                	sd	ra,24(sp)
    80002ba2:	e822                	sd	s0,16(sp)
    80002ba4:	e426                	sd	s1,8(sp)
    80002ba6:	1000                	addi	s0,sp,32
    80002ba8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	f9e080e7          	jalr	-98(ra) # 80001b48 <myproc>
  switch (n) {
    80002bb2:	4795                	li	a5,5
    80002bb4:	0497e163          	bltu	a5,s1,80002bf6 <argraw+0x58>
    80002bb8:	048a                	slli	s1,s1,0x2
    80002bba:	00006717          	auipc	a4,0x6
    80002bbe:	d5e70713          	addi	a4,a4,-674 # 80008918 <nointr_desc.0+0xa8>
    80002bc2:	94ba                	add	s1,s1,a4
    80002bc4:	409c                	lw	a5,0(s1)
    80002bc6:	97ba                	add	a5,a5,a4
    80002bc8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002bca:	713c                	ld	a5,96(a0)
    80002bcc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bce:	60e2                	ld	ra,24(sp)
    80002bd0:	6442                	ld	s0,16(sp)
    80002bd2:	64a2                	ld	s1,8(sp)
    80002bd4:	6105                	addi	sp,sp,32
    80002bd6:	8082                	ret
    return p->trapframe->a1;
    80002bd8:	713c                	ld	a5,96(a0)
    80002bda:	7fa8                	ld	a0,120(a5)
    80002bdc:	bfcd                	j	80002bce <argraw+0x30>
    return p->trapframe->a2;
    80002bde:	713c                	ld	a5,96(a0)
    80002be0:	63c8                	ld	a0,128(a5)
    80002be2:	b7f5                	j	80002bce <argraw+0x30>
    return p->trapframe->a3;
    80002be4:	713c                	ld	a5,96(a0)
    80002be6:	67c8                	ld	a0,136(a5)
    80002be8:	b7dd                	j	80002bce <argraw+0x30>
    return p->trapframe->a4;
    80002bea:	713c                	ld	a5,96(a0)
    80002bec:	6bc8                	ld	a0,144(a5)
    80002bee:	b7c5                	j	80002bce <argraw+0x30>
    return p->trapframe->a5;
    80002bf0:	713c                	ld	a5,96(a0)
    80002bf2:	6fc8                	ld	a0,152(a5)
    80002bf4:	bfe9                	j	80002bce <argraw+0x30>
  panic("argraw");
    80002bf6:	00006517          	auipc	a0,0x6
    80002bfa:	cfa50513          	addi	a0,a0,-774 # 800088f0 <nointr_desc.0+0x80>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	966080e7          	jalr	-1690(ra) # 80000564 <panic>

0000000080002c06 <fetchaddr>:
{
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	e04a                	sd	s2,0(sp)
    80002c10:	1000                	addi	s0,sp,32
    80002c12:	84aa                	mv	s1,a0
    80002c14:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	f32080e7          	jalr	-206(ra) # 80001b48 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c1e:	693c                	ld	a5,80(a0)
    80002c20:	02f4f863          	bgeu	s1,a5,80002c50 <fetchaddr+0x4a>
    80002c24:	00848713          	addi	a4,s1,8
    80002c28:	02e7e663          	bltu	a5,a4,80002c54 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c2c:	46a1                	li	a3,8
    80002c2e:	8626                	mv	a2,s1
    80002c30:	85ca                	mv	a1,s2
    80002c32:	6d28                	ld	a0,88(a0)
    80002c34:	fffff097          	auipc	ra,0xfffff
    80002c38:	c58080e7          	jalr	-936(ra) # 8000188c <copyin>
    80002c3c:	00a03533          	snez	a0,a0
    80002c40:	40a00533          	neg	a0,a0
}
    80002c44:	60e2                	ld	ra,24(sp)
    80002c46:	6442                	ld	s0,16(sp)
    80002c48:	64a2                	ld	s1,8(sp)
    80002c4a:	6902                	ld	s2,0(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret
    return -1;
    80002c50:	557d                	li	a0,-1
    80002c52:	bfcd                	j	80002c44 <fetchaddr+0x3e>
    80002c54:	557d                	li	a0,-1
    80002c56:	b7fd                	j	80002c44 <fetchaddr+0x3e>

0000000080002c58 <fetchstr>:
{
    80002c58:	7179                	addi	sp,sp,-48
    80002c5a:	f406                	sd	ra,40(sp)
    80002c5c:	f022                	sd	s0,32(sp)
    80002c5e:	ec26                	sd	s1,24(sp)
    80002c60:	e84a                	sd	s2,16(sp)
    80002c62:	e44e                	sd	s3,8(sp)
    80002c64:	1800                	addi	s0,sp,48
    80002c66:	892a                	mv	s2,a0
    80002c68:	84ae                	mv	s1,a1
    80002c6a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	edc080e7          	jalr	-292(ra) # 80001b48 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002c74:	86ce                	mv	a3,s3
    80002c76:	864a                	mv	a2,s2
    80002c78:	85a6                	mv	a1,s1
    80002c7a:	6d28                	ld	a0,88(a0)
    80002c7c:	fffff097          	auipc	ra,0xfffff
    80002c80:	c9e080e7          	jalr	-866(ra) # 8000191a <copyinstr>
  if(err < 0)
    80002c84:	00054763          	bltz	a0,80002c92 <fetchstr+0x3a>
  return strlen(buf);
    80002c88:	8526                	mv	a0,s1
    80002c8a:	ffffe097          	auipc	ra,0xffffe
    80002c8e:	394080e7          	jalr	916(ra) # 8000101e <strlen>
}
    80002c92:	70a2                	ld	ra,40(sp)
    80002c94:	7402                	ld	s0,32(sp)
    80002c96:	64e2                	ld	s1,24(sp)
    80002c98:	6942                	ld	s2,16(sp)
    80002c9a:	69a2                	ld	s3,8(sp)
    80002c9c:	6145                	addi	sp,sp,48
    80002c9e:	8082                	ret

0000000080002ca0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002ca0:	1101                	addi	sp,sp,-32
    80002ca2:	ec06                	sd	ra,24(sp)
    80002ca4:	e822                	sd	s0,16(sp)
    80002ca6:	e426                	sd	s1,8(sp)
    80002ca8:	1000                	addi	s0,sp,32
    80002caa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	ef2080e7          	jalr	-270(ra) # 80002b9e <argraw>
    80002cb4:	c088                	sw	a0,0(s1)
  return 0;
}
    80002cb6:	4501                	li	a0,0
    80002cb8:	60e2                	ld	ra,24(sp)
    80002cba:	6442                	ld	s0,16(sp)
    80002cbc:	64a2                	ld	s1,8(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	ed0080e7          	jalr	-304(ra) # 80002b9e <argraw>
    80002cd6:	e088                	sd	a0,0(s1)
  return 0;
}
    80002cd8:	4501                	li	a0,0
    80002cda:	60e2                	ld	ra,24(sp)
    80002cdc:	6442                	ld	s0,16(sp)
    80002cde:	64a2                	ld	s1,8(sp)
    80002ce0:	6105                	addi	sp,sp,32
    80002ce2:	8082                	ret

0000000080002ce4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ce4:	1101                	addi	sp,sp,-32
    80002ce6:	ec06                	sd	ra,24(sp)
    80002ce8:	e822                	sd	s0,16(sp)
    80002cea:	e426                	sd	s1,8(sp)
    80002cec:	e04a                	sd	s2,0(sp)
    80002cee:	1000                	addi	s0,sp,32
    80002cf0:	84ae                	mv	s1,a1
    80002cf2:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	eaa080e7          	jalr	-342(ra) # 80002b9e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002cfc:	864a                	mv	a2,s2
    80002cfe:	85a6                	mv	a1,s1
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	f58080e7          	jalr	-168(ra) # 80002c58 <fetchstr>
}
    80002d08:	60e2                	ld	ra,24(sp)
    80002d0a:	6442                	ld	s0,16(sp)
    80002d0c:	64a2                	ld	s1,8(sp)
    80002d0e:	6902                	ld	s2,0(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret

0000000080002d14 <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	e04a                	sd	s2,0(sp)
    80002d1e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	e28080e7          	jalr	-472(ra) # 80001b48 <myproc>
    80002d28:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d2a:	06053903          	ld	s2,96(a0)
    80002d2e:	0a893783          	ld	a5,168(s2)
    80002d32:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d36:	37fd                	addiw	a5,a5,-1
    80002d38:	4759                	li	a4,22
    80002d3a:	00f76f63          	bltu	a4,a5,80002d58 <syscall+0x44>
    80002d3e:	00369713          	slli	a4,a3,0x3
    80002d42:	00006797          	auipc	a5,0x6
    80002d46:	bee78793          	addi	a5,a5,-1042 # 80008930 <syscalls>
    80002d4a:	97ba                	add	a5,a5,a4
    80002d4c:	639c                	ld	a5,0(a5)
    80002d4e:	c789                	beqz	a5,80002d58 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002d50:	9782                	jalr	a5
    80002d52:	06a93823          	sd	a0,112(s2)
    80002d56:	a839                	j	80002d74 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d58:	16048613          	addi	a2,s1,352
    80002d5c:	40ac                	lw	a1,64(s1)
    80002d5e:	00006517          	auipc	a0,0x6
    80002d62:	b9a50513          	addi	a0,a0,-1126 # 800088f8 <nointr_desc.0+0x88>
    80002d66:	ffffe097          	auipc	ra,0xffffe
    80002d6a:	860080e7          	jalr	-1952(ra) # 800005c6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d6e:	70bc                	ld	a5,96(s1)
    80002d70:	577d                	li	a4,-1
    80002d72:	fbb8                	sd	a4,112(a5)
  }
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6902                	ld	s2,0(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret

0000000080002d80 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d80:	1101                	addi	sp,sp,-32
    80002d82:	ec06                	sd	ra,24(sp)
    80002d84:	e822                	sd	s0,16(sp)
    80002d86:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002d88:	fec40593          	addi	a1,s0,-20
    80002d8c:	4501                	li	a0,0
    80002d8e:	00000097          	auipc	ra,0x0
    80002d92:	f12080e7          	jalr	-238(ra) # 80002ca0 <argint>
    return -1;
    80002d96:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d98:	00054963          	bltz	a0,80002daa <sys_exit+0x2a>
  exit(n);
    80002d9c:	fec42503          	lw	a0,-20(s0)
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	472080e7          	jalr	1138(ra) # 80002212 <exit>
  return 0;  // not reached
    80002da8:	4781                	li	a5,0
}
    80002daa:	853e                	mv	a0,a5
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret

0000000080002db4 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002db4:	1141                	addi	sp,sp,-16
    80002db6:	e406                	sd	ra,8(sp)
    80002db8:	e022                	sd	s0,0(sp)
    80002dba:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002dbc:	fffff097          	auipc	ra,0xfffff
    80002dc0:	d8c080e7          	jalr	-628(ra) # 80001b48 <myproc>
}
    80002dc4:	4128                	lw	a0,64(a0)
    80002dc6:	60a2                	ld	ra,8(sp)
    80002dc8:	6402                	ld	s0,0(sp)
    80002dca:	0141                	addi	sp,sp,16
    80002dcc:	8082                	ret

0000000080002dce <sys_fork>:

uint64
sys_fork(void)
{
    80002dce:	1141                	addi	sp,sp,-16
    80002dd0:	e406                	sd	ra,8(sp)
    80002dd2:	e022                	sd	s0,0(sp)
    80002dd4:	0800                	addi	s0,sp,16
  return fork();
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	0fc080e7          	jalr	252(ra) # 80001ed2 <fork>
}
    80002dde:	60a2                	ld	ra,8(sp)
    80002de0:	6402                	ld	s0,0(sp)
    80002de2:	0141                	addi	sp,sp,16
    80002de4:	8082                	ret

0000000080002de6 <sys_wait>:

uint64
sys_wait(void)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002dee:	fe840593          	addi	a1,s0,-24
    80002df2:	4501                	li	a0,0
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	ece080e7          	jalr	-306(ra) # 80002cc2 <argaddr>
    80002dfc:	87aa                	mv	a5,a0
    return -1;
    80002dfe:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e00:	0007c863          	bltz	a5,80002e10 <sys_wait+0x2a>
  return wait(p);
    80002e04:	fe843503          	ld	a0,-24(s0)
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	5ce080e7          	jalr	1486(ra) # 800023d6 <wait>
}
    80002e10:	60e2                	ld	ra,24(sp)
    80002e12:	6442                	ld	s0,16(sp)
    80002e14:	6105                	addi	sp,sp,32
    80002e16:	8082                	ret

0000000080002e18 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e18:	7179                	addi	sp,sp,-48
    80002e1a:	f406                	sd	ra,40(sp)
    80002e1c:	f022                	sd	s0,32(sp)
    80002e1e:	ec26                	sd	s1,24(sp)
    80002e20:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e22:	fdc40593          	addi	a1,s0,-36
    80002e26:	4501                	li	a0,0
    80002e28:	00000097          	auipc	ra,0x0
    80002e2c:	e78080e7          	jalr	-392(ra) # 80002ca0 <argint>
    return -1;
    80002e30:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002e32:	00054f63          	bltz	a0,80002e50 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002e36:	fffff097          	auipc	ra,0xfffff
    80002e3a:	d12080e7          	jalr	-750(ra) # 80001b48 <myproc>
    80002e3e:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002e40:	fdc42503          	lw	a0,-36(s0)
    80002e44:	fffff097          	auipc	ra,0xfffff
    80002e48:	01a080e7          	jalr	26(ra) # 80001e5e <growproc>
    80002e4c:	00054863          	bltz	a0,80002e5c <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002e50:	8526                	mv	a0,s1
    80002e52:	70a2                	ld	ra,40(sp)
    80002e54:	7402                	ld	s0,32(sp)
    80002e56:	64e2                	ld	s1,24(sp)
    80002e58:	6145                	addi	sp,sp,48
    80002e5a:	8082                	ret
    return -1;
    80002e5c:	54fd                	li	s1,-1
    80002e5e:	bfcd                	j	80002e50 <sys_sbrk+0x38>

0000000080002e60 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e60:	7139                	addi	sp,sp,-64
    80002e62:	fc06                	sd	ra,56(sp)
    80002e64:	f822                	sd	s0,48(sp)
    80002e66:	f426                	sd	s1,40(sp)
    80002e68:	f04a                	sd	s2,32(sp)
    80002e6a:	ec4e                	sd	s3,24(sp)
    80002e6c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e6e:	fcc40593          	addi	a1,s0,-52
    80002e72:	4501                	li	a0,0
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	e2c080e7          	jalr	-468(ra) # 80002ca0 <argint>
    return -1;
    80002e7c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e7e:	06054563          	bltz	a0,80002ee8 <sys_sleep+0x88>
  acquire(&tickslock);
    80002e82:	00028517          	auipc	a0,0x28
    80002e86:	fb650513          	addi	a0,a0,-74 # 8002ae38 <tickslock>
    80002e8a:	ffffe097          	auipc	ra,0xffffe
    80002e8e:	d08080e7          	jalr	-760(ra) # 80000b92 <acquire>
  ticks0 = ticks;
    80002e92:	00006917          	auipc	s2,0x6
    80002e96:	09692903          	lw	s2,150(s2) # 80008f28 <ticks>
  while(ticks - ticks0 < n){
    80002e9a:	fcc42783          	lw	a5,-52(s0)
    80002e9e:	cf85                	beqz	a5,80002ed6 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ea0:	00028997          	auipc	s3,0x28
    80002ea4:	f9898993          	addi	s3,s3,-104 # 8002ae38 <tickslock>
    80002ea8:	00006497          	auipc	s1,0x6
    80002eac:	08048493          	addi	s1,s1,128 # 80008f28 <ticks>
    if(myproc()->killed){
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	c98080e7          	jalr	-872(ra) # 80001b48 <myproc>
    80002eb8:	5d1c                	lw	a5,56(a0)
    80002eba:	ef9d                	bnez	a5,80002ef8 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002ebc:	85ce                	mv	a1,s3
    80002ebe:	8526                	mv	a0,s1
    80002ec0:	fffff097          	auipc	ra,0xfffff
    80002ec4:	498080e7          	jalr	1176(ra) # 80002358 <sleep>
  while(ticks - ticks0 < n){
    80002ec8:	409c                	lw	a5,0(s1)
    80002eca:	412787bb          	subw	a5,a5,s2
    80002ece:	fcc42703          	lw	a4,-52(s0)
    80002ed2:	fce7efe3          	bltu	a5,a4,80002eb0 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002ed6:	00028517          	auipc	a0,0x28
    80002eda:	f6250513          	addi	a0,a0,-158 # 8002ae38 <tickslock>
    80002ede:	ffffe097          	auipc	ra,0xffffe
    80002ee2:	d84080e7          	jalr	-636(ra) # 80000c62 <release>
  return 0;
    80002ee6:	4781                	li	a5,0
}
    80002ee8:	853e                	mv	a0,a5
    80002eea:	70e2                	ld	ra,56(sp)
    80002eec:	7442                	ld	s0,48(sp)
    80002eee:	74a2                	ld	s1,40(sp)
    80002ef0:	7902                	ld	s2,32(sp)
    80002ef2:	69e2                	ld	s3,24(sp)
    80002ef4:	6121                	addi	sp,sp,64
    80002ef6:	8082                	ret
      release(&tickslock);
    80002ef8:	00028517          	auipc	a0,0x28
    80002efc:	f4050513          	addi	a0,a0,-192 # 8002ae38 <tickslock>
    80002f00:	ffffe097          	auipc	ra,0xffffe
    80002f04:	d62080e7          	jalr	-670(ra) # 80000c62 <release>
      return -1;
    80002f08:	57fd                	li	a5,-1
    80002f0a:	bff9                	j	80002ee8 <sys_sleep+0x88>

0000000080002f0c <sys_kill>:

uint64
sys_kill(void)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f14:	fec40593          	addi	a1,s0,-20
    80002f18:	4501                	li	a0,0
    80002f1a:	00000097          	auipc	ra,0x0
    80002f1e:	d86080e7          	jalr	-634(ra) # 80002ca0 <argint>
    80002f22:	87aa                	mv	a5,a0
    return -1;
    80002f24:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f26:	0007c863          	bltz	a5,80002f36 <sys_kill+0x2a>
  return kill(pid);
    80002f2a:	fec42503          	lw	a0,-20(s0)
    80002f2e:	fffff097          	auipc	ra,0xfffff
    80002f32:	630080e7          	jalr	1584(ra) # 8000255e <kill>
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	6105                	addi	sp,sp,32
    80002f3c:	8082                	ret

0000000080002f3e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f3e:	1101                	addi	sp,sp,-32
    80002f40:	ec06                	sd	ra,24(sp)
    80002f42:	e822                	sd	s0,16(sp)
    80002f44:	e426                	sd	s1,8(sp)
    80002f46:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f48:	00028517          	auipc	a0,0x28
    80002f4c:	ef050513          	addi	a0,a0,-272 # 8002ae38 <tickslock>
    80002f50:	ffffe097          	auipc	ra,0xffffe
    80002f54:	c42080e7          	jalr	-958(ra) # 80000b92 <acquire>
  xticks = ticks;
    80002f58:	00006497          	auipc	s1,0x6
    80002f5c:	fd04a483          	lw	s1,-48(s1) # 80008f28 <ticks>
  release(&tickslock);
    80002f60:	00028517          	auipc	a0,0x28
    80002f64:	ed850513          	addi	a0,a0,-296 # 8002ae38 <tickslock>
    80002f68:	ffffe097          	auipc	ra,0xffffe
    80002f6c:	cfa080e7          	jalr	-774(ra) # 80000c62 <release>
  return xticks;
}
    80002f70:	02049513          	slli	a0,s1,0x20
    80002f74:	9101                	srli	a0,a0,0x20
    80002f76:	60e2                	ld	ra,24(sp)
    80002f78:	6442                	ld	s0,16(sp)
    80002f7a:	64a2                	ld	s1,8(sp)
    80002f7c:	6105                	addi	sp,sp,32
    80002f7e:	8082                	ret

0000000080002f80 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f80:	7179                	addi	sp,sp,-48
    80002f82:	f406                	sd	ra,40(sp)
    80002f84:	f022                	sd	s0,32(sp)
    80002f86:	ec26                	sd	s1,24(sp)
    80002f88:	e84a                	sd	s2,16(sp)
    80002f8a:	e44e                	sd	s3,8(sp)
    80002f8c:	e052                	sd	s4,0(sp)
    80002f8e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f90:	00006597          	auipc	a1,0x6
    80002f94:	a6058593          	addi	a1,a1,-1440 # 800089f0 <syscalls+0xc0>
    80002f98:	00028517          	auipc	a0,0x28
    80002f9c:	ec050513          	addi	a0,a0,-320 # 8002ae58 <bcache>
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	b1c080e7          	jalr	-1252(ra) # 80000abc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002fa8:	00030797          	auipc	a5,0x30
    80002fac:	eb078793          	addi	a5,a5,-336 # 80032e58 <bcache+0x8000>
    80002fb0:	00030717          	auipc	a4,0x30
    80002fb4:	20870713          	addi	a4,a4,520 # 800331b8 <bcache+0x8360>
    80002fb8:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    80002fbc:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fc0:	00028497          	auipc	s1,0x28
    80002fc4:	eb848493          	addi	s1,s1,-328 # 8002ae78 <bcache+0x20>
    b->next = bcache.head.next;
    80002fc8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002fca:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fcc:	00006a17          	auipc	s4,0x6
    80002fd0:	a2ca0a13          	addi	s4,s4,-1492 # 800089f8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002fd4:	3b893783          	ld	a5,952(s2)
    80002fd8:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80002fda:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80002fde:	85d2                	mv	a1,s4
    80002fe0:	01048513          	addi	a0,s1,16
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	4aa080e7          	jalr	1194(ra) # 8000448e <initsleeplock>
    bcache.head.next->prev = b;
    80002fec:	3b893783          	ld	a5,952(s2)
    80002ff0:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80002ff2:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ff6:	46048493          	addi	s1,s1,1120
    80002ffa:	fd349de3          	bne	s1,s3,80002fd4 <binit+0x54>
  }
}
    80002ffe:	70a2                	ld	ra,40(sp)
    80003000:	7402                	ld	s0,32(sp)
    80003002:	64e2                	ld	s1,24(sp)
    80003004:	6942                	ld	s2,16(sp)
    80003006:	69a2                	ld	s3,8(sp)
    80003008:	6a02                	ld	s4,0(sp)
    8000300a:	6145                	addi	sp,sp,48
    8000300c:	8082                	ret

000000008000300e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000300e:	7179                	addi	sp,sp,-48
    80003010:	f406                	sd	ra,40(sp)
    80003012:	f022                	sd	s0,32(sp)
    80003014:	ec26                	sd	s1,24(sp)
    80003016:	e84a                	sd	s2,16(sp)
    80003018:	e44e                	sd	s3,8(sp)
    8000301a:	1800                	addi	s0,sp,48
    8000301c:	892a                	mv	s2,a0
    8000301e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003020:	00028517          	auipc	a0,0x28
    80003024:	e3850513          	addi	a0,a0,-456 # 8002ae58 <bcache>
    80003028:	ffffe097          	auipc	ra,0xffffe
    8000302c:	b6a080e7          	jalr	-1174(ra) # 80000b92 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003030:	00030497          	auipc	s1,0x30
    80003034:	1e04b483          	ld	s1,480(s1) # 80033210 <bcache+0x83b8>
    80003038:	00030797          	auipc	a5,0x30
    8000303c:	18078793          	addi	a5,a5,384 # 800331b8 <bcache+0x8360>
    80003040:	02f48f63          	beq	s1,a5,8000307e <bread+0x70>
    80003044:	873e                	mv	a4,a5
    80003046:	a021                	j	8000304e <bread+0x40>
    80003048:	6ca4                	ld	s1,88(s1)
    8000304a:	02e48a63          	beq	s1,a4,8000307e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000304e:	449c                	lw	a5,8(s1)
    80003050:	ff279ce3          	bne	a5,s2,80003048 <bread+0x3a>
    80003054:	44dc                	lw	a5,12(s1)
    80003056:	ff3799e3          	bne	a5,s3,80003048 <bread+0x3a>
      b->refcnt++;
    8000305a:	44bc                	lw	a5,72(s1)
    8000305c:	2785                	addiw	a5,a5,1
    8000305e:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003060:	00028517          	auipc	a0,0x28
    80003064:	df850513          	addi	a0,a0,-520 # 8002ae58 <bcache>
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	bfa080e7          	jalr	-1030(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    80003070:	01048513          	addi	a0,s1,16
    80003074:	00001097          	auipc	ra,0x1
    80003078:	454080e7          	jalr	1108(ra) # 800044c8 <acquiresleep>
      return b;
    8000307c:	a8b9                	j	800030da <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000307e:	00030497          	auipc	s1,0x30
    80003082:	18a4b483          	ld	s1,394(s1) # 80033208 <bcache+0x83b0>
    80003086:	00030797          	auipc	a5,0x30
    8000308a:	13278793          	addi	a5,a5,306 # 800331b8 <bcache+0x8360>
    8000308e:	00f48863          	beq	s1,a5,8000309e <bread+0x90>
    80003092:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003094:	44bc                	lw	a5,72(s1)
    80003096:	cf81                	beqz	a5,800030ae <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003098:	68a4                	ld	s1,80(s1)
    8000309a:	fee49de3          	bne	s1,a4,80003094 <bread+0x86>
  panic("bget: no buffers");
    8000309e:	00006517          	auipc	a0,0x6
    800030a2:	96250513          	addi	a0,a0,-1694 # 80008a00 <syscalls+0xd0>
    800030a6:	ffffd097          	auipc	ra,0xffffd
    800030aa:	4be080e7          	jalr	1214(ra) # 80000564 <panic>
      b->dev = dev;
    800030ae:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800030b2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800030b6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800030ba:	4785                	li	a5,1
    800030bc:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800030be:	00028517          	auipc	a0,0x28
    800030c2:	d9a50513          	addi	a0,a0,-614 # 8002ae58 <bcache>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	b9c080e7          	jalr	-1124(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    800030ce:	01048513          	addi	a0,s1,16
    800030d2:	00001097          	auipc	ra,0x1
    800030d6:	3f6080e7          	jalr	1014(ra) # 800044c8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030da:	409c                	lw	a5,0(s1)
    800030dc:	cb89                	beqz	a5,800030ee <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030de:	8526                	mv	a0,s1
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6942                	ld	s2,16(sp)
    800030e8:	69a2                	ld	s3,8(sp)
    800030ea:	6145                	addi	sp,sp,48
    800030ec:	8082                	ret
    virtio_disk_rw(b, 0);
    800030ee:	4581                	li	a1,0
    800030f0:	8526                	mv	a0,s1
    800030f2:	00003097          	auipc	ra,0x3
    800030f6:	f94080e7          	jalr	-108(ra) # 80006086 <virtio_disk_rw>
    b->valid = 1;
    800030fa:	4785                	li	a5,1
    800030fc:	c09c                	sw	a5,0(s1)
  return b;
    800030fe:	b7c5                	j	800030de <bread+0xd0>

0000000080003100 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003100:	1101                	addi	sp,sp,-32
    80003102:	ec06                	sd	ra,24(sp)
    80003104:	e822                	sd	s0,16(sp)
    80003106:	e426                	sd	s1,8(sp)
    80003108:	1000                	addi	s0,sp,32
    8000310a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000310c:	0541                	addi	a0,a0,16
    8000310e:	00001097          	auipc	ra,0x1
    80003112:	454080e7          	jalr	1108(ra) # 80004562 <holdingsleep>
    80003116:	cd01                	beqz	a0,8000312e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003118:	4585                	li	a1,1
    8000311a:	8526                	mv	a0,s1
    8000311c:	00003097          	auipc	ra,0x3
    80003120:	f6a080e7          	jalr	-150(ra) # 80006086 <virtio_disk_rw>
}
    80003124:	60e2                	ld	ra,24(sp)
    80003126:	6442                	ld	s0,16(sp)
    80003128:	64a2                	ld	s1,8(sp)
    8000312a:	6105                	addi	sp,sp,32
    8000312c:	8082                	ret
    panic("bwrite");
    8000312e:	00006517          	auipc	a0,0x6
    80003132:	8ea50513          	addi	a0,a0,-1814 # 80008a18 <syscalls+0xe8>
    80003136:	ffffd097          	auipc	ra,0xffffd
    8000313a:	42e080e7          	jalr	1070(ra) # 80000564 <panic>

000000008000313e <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    8000313e:	1101                	addi	sp,sp,-32
    80003140:	ec06                	sd	ra,24(sp)
    80003142:	e822                	sd	s0,16(sp)
    80003144:	e426                	sd	s1,8(sp)
    80003146:	e04a                	sd	s2,0(sp)
    80003148:	1000                	addi	s0,sp,32
    8000314a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000314c:	01050913          	addi	s2,a0,16
    80003150:	854a                	mv	a0,s2
    80003152:	00001097          	auipc	ra,0x1
    80003156:	410080e7          	jalr	1040(ra) # 80004562 <holdingsleep>
    8000315a:	c92d                	beqz	a0,800031cc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000315c:	854a                	mv	a0,s2
    8000315e:	00001097          	auipc	ra,0x1
    80003162:	3c0080e7          	jalr	960(ra) # 8000451e <releasesleep>

  acquire(&bcache.lock);
    80003166:	00028517          	auipc	a0,0x28
    8000316a:	cf250513          	addi	a0,a0,-782 # 8002ae58 <bcache>
    8000316e:	ffffe097          	auipc	ra,0xffffe
    80003172:	a24080e7          	jalr	-1500(ra) # 80000b92 <acquire>
  b->refcnt--;
    80003176:	44bc                	lw	a5,72(s1)
    80003178:	37fd                	addiw	a5,a5,-1
    8000317a:	0007871b          	sext.w	a4,a5
    8000317e:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003180:	eb05                	bnez	a4,800031b0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003182:	6cbc                	ld	a5,88(s1)
    80003184:	68b8                	ld	a4,80(s1)
    80003186:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003188:	68bc                	ld	a5,80(s1)
    8000318a:	6cb8                	ld	a4,88(s1)
    8000318c:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    8000318e:	00030797          	auipc	a5,0x30
    80003192:	cca78793          	addi	a5,a5,-822 # 80032e58 <bcache+0x8000>
    80003196:	3b87b703          	ld	a4,952(a5)
    8000319a:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000319c:	00030717          	auipc	a4,0x30
    800031a0:	01c70713          	addi	a4,a4,28 # 800331b8 <bcache+0x8360>
    800031a4:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    800031a6:	3b87b703          	ld	a4,952(a5)
    800031aa:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    800031ac:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    800031b0:	00028517          	auipc	a0,0x28
    800031b4:	ca850513          	addi	a0,a0,-856 # 8002ae58 <bcache>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	aaa080e7          	jalr	-1366(ra) # 80000c62 <release>
}
    800031c0:	60e2                	ld	ra,24(sp)
    800031c2:	6442                	ld	s0,16(sp)
    800031c4:	64a2                	ld	s1,8(sp)
    800031c6:	6902                	ld	s2,0(sp)
    800031c8:	6105                	addi	sp,sp,32
    800031ca:	8082                	ret
    panic("brelse");
    800031cc:	00006517          	auipc	a0,0x6
    800031d0:	85450513          	addi	a0,a0,-1964 # 80008a20 <syscalls+0xf0>
    800031d4:	ffffd097          	auipc	ra,0xffffd
    800031d8:	390080e7          	jalr	912(ra) # 80000564 <panic>

00000000800031dc <bpin>:

void
bpin(struct buf *b) {
    800031dc:	1101                	addi	sp,sp,-32
    800031de:	ec06                	sd	ra,24(sp)
    800031e0:	e822                	sd	s0,16(sp)
    800031e2:	e426                	sd	s1,8(sp)
    800031e4:	1000                	addi	s0,sp,32
    800031e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031e8:	00028517          	auipc	a0,0x28
    800031ec:	c7050513          	addi	a0,a0,-912 # 8002ae58 <bcache>
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	9a2080e7          	jalr	-1630(ra) # 80000b92 <acquire>
  b->refcnt++;
    800031f8:	44bc                	lw	a5,72(s1)
    800031fa:	2785                	addiw	a5,a5,1
    800031fc:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800031fe:	00028517          	auipc	a0,0x28
    80003202:	c5a50513          	addi	a0,a0,-934 # 8002ae58 <bcache>
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	a5c080e7          	jalr	-1444(ra) # 80000c62 <release>
}
    8000320e:	60e2                	ld	ra,24(sp)
    80003210:	6442                	ld	s0,16(sp)
    80003212:	64a2                	ld	s1,8(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret

0000000080003218 <bunpin>:

void
bunpin(struct buf *b) {
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	1000                	addi	s0,sp,32
    80003222:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003224:	00028517          	auipc	a0,0x28
    80003228:	c3450513          	addi	a0,a0,-972 # 8002ae58 <bcache>
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	966080e7          	jalr	-1690(ra) # 80000b92 <acquire>
  b->refcnt--;
    80003234:	44bc                	lw	a5,72(s1)
    80003236:	37fd                	addiw	a5,a5,-1
    80003238:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000323a:	00028517          	auipc	a0,0x28
    8000323e:	c1e50513          	addi	a0,a0,-994 # 8002ae58 <bcache>
    80003242:	ffffe097          	auipc	ra,0xffffe
    80003246:	a20080e7          	jalr	-1504(ra) # 80000c62 <release>
}
    8000324a:	60e2                	ld	ra,24(sp)
    8000324c:	6442                	ld	s0,16(sp)
    8000324e:	64a2                	ld	s1,8(sp)
    80003250:	6105                	addi	sp,sp,32
    80003252:	8082                	ret

0000000080003254 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	e04a                	sd	s2,0(sp)
    8000325e:	1000                	addi	s0,sp,32
    80003260:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003262:	00d5d59b          	srliw	a1,a1,0xd
    80003266:	00030797          	auipc	a5,0x30
    8000326a:	3ce7a783          	lw	a5,974(a5) # 80033634 <sb+0x1c>
    8000326e:	9dbd                	addw	a1,a1,a5
    80003270:	00000097          	auipc	ra,0x0
    80003274:	d9e080e7          	jalr	-610(ra) # 8000300e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003278:	0074f713          	andi	a4,s1,7
    8000327c:	4785                	li	a5,1
    8000327e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003282:	14ce                	slli	s1,s1,0x33
    80003284:	90d9                	srli	s1,s1,0x36
    80003286:	00950733          	add	a4,a0,s1
    8000328a:	06074703          	lbu	a4,96(a4)
    8000328e:	00e7f6b3          	and	a3,a5,a4
    80003292:	c69d                	beqz	a3,800032c0 <bfree+0x6c>
    80003294:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003296:	94aa                	add	s1,s1,a0
    80003298:	fff7c793          	not	a5,a5
    8000329c:	8ff9                	and	a5,a5,a4
    8000329e:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    800032a2:	00001097          	auipc	ra,0x1
    800032a6:	106080e7          	jalr	262(ra) # 800043a8 <log_write>
  brelse(bp);
    800032aa:	854a                	mv	a0,s2
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	e92080e7          	jalr	-366(ra) # 8000313e <brelse>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6902                	ld	s2,0(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret
    panic("freeing free block");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	76850513          	addi	a0,a0,1896 # 80008a28 <syscalls+0xf8>
    800032c8:	ffffd097          	auipc	ra,0xffffd
    800032cc:	29c080e7          	jalr	668(ra) # 80000564 <panic>

00000000800032d0 <balloc>:
{
    800032d0:	711d                	addi	sp,sp,-96
    800032d2:	ec86                	sd	ra,88(sp)
    800032d4:	e8a2                	sd	s0,80(sp)
    800032d6:	e4a6                	sd	s1,72(sp)
    800032d8:	e0ca                	sd	s2,64(sp)
    800032da:	fc4e                	sd	s3,56(sp)
    800032dc:	f852                	sd	s4,48(sp)
    800032de:	f456                	sd	s5,40(sp)
    800032e0:	f05a                	sd	s6,32(sp)
    800032e2:	ec5e                	sd	s7,24(sp)
    800032e4:	e862                	sd	s8,16(sp)
    800032e6:	e466                	sd	s9,8(sp)
    800032e8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032ea:	00030797          	auipc	a5,0x30
    800032ee:	3327a783          	lw	a5,818(a5) # 8003361c <sb+0x4>
    800032f2:	cbd1                	beqz	a5,80003386 <balloc+0xb6>
    800032f4:	8baa                	mv	s7,a0
    800032f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032f8:	00030b17          	auipc	s6,0x30
    800032fc:	320b0b13          	addi	s6,s6,800 # 80033618 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003300:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003302:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003304:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003306:	6c89                	lui	s9,0x2
    80003308:	a831                	j	80003324 <balloc+0x54>
    brelse(bp);
    8000330a:	854a                	mv	a0,s2
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	e32080e7          	jalr	-462(ra) # 8000313e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003314:	015c87bb          	addw	a5,s9,s5
    80003318:	00078a9b          	sext.w	s5,a5
    8000331c:	004b2703          	lw	a4,4(s6)
    80003320:	06eaf363          	bgeu	s5,a4,80003386 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003324:	41fad79b          	sraiw	a5,s5,0x1f
    80003328:	0137d79b          	srliw	a5,a5,0x13
    8000332c:	015787bb          	addw	a5,a5,s5
    80003330:	40d7d79b          	sraiw	a5,a5,0xd
    80003334:	01cb2583          	lw	a1,28(s6)
    80003338:	9dbd                	addw	a1,a1,a5
    8000333a:	855e                	mv	a0,s7
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	cd2080e7          	jalr	-814(ra) # 8000300e <bread>
    80003344:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003346:	004b2503          	lw	a0,4(s6)
    8000334a:	000a849b          	sext.w	s1,s5
    8000334e:	8662                	mv	a2,s8
    80003350:	faa4fde3          	bgeu	s1,a0,8000330a <balloc+0x3a>
      m = 1 << (bi % 8);
    80003354:	41f6579b          	sraiw	a5,a2,0x1f
    80003358:	01d7d69b          	srliw	a3,a5,0x1d
    8000335c:	00c6873b          	addw	a4,a3,a2
    80003360:	00777793          	andi	a5,a4,7
    80003364:	9f95                	subw	a5,a5,a3
    80003366:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000336a:	4037571b          	sraiw	a4,a4,0x3
    8000336e:	00e906b3          	add	a3,s2,a4
    80003372:	0606c683          	lbu	a3,96(a3)
    80003376:	00d7f5b3          	and	a1,a5,a3
    8000337a:	cd91                	beqz	a1,80003396 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000337c:	2605                	addiw	a2,a2,1
    8000337e:	2485                	addiw	s1,s1,1
    80003380:	fd4618e3          	bne	a2,s4,80003350 <balloc+0x80>
    80003384:	b759                	j	8000330a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003386:	00005517          	auipc	a0,0x5
    8000338a:	6ba50513          	addi	a0,a0,1722 # 80008a40 <syscalls+0x110>
    8000338e:	ffffd097          	auipc	ra,0xffffd
    80003392:	1d6080e7          	jalr	470(ra) # 80000564 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003396:	974a                	add	a4,a4,s2
    80003398:	8fd5                	or	a5,a5,a3
    8000339a:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000339e:	854a                	mv	a0,s2
    800033a0:	00001097          	auipc	ra,0x1
    800033a4:	008080e7          	jalr	8(ra) # 800043a8 <log_write>
        brelse(bp);
    800033a8:	854a                	mv	a0,s2
    800033aa:	00000097          	auipc	ra,0x0
    800033ae:	d94080e7          	jalr	-620(ra) # 8000313e <brelse>
  bp = bread(dev, bno);
    800033b2:	85a6                	mv	a1,s1
    800033b4:	855e                	mv	a0,s7
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	c58080e7          	jalr	-936(ra) # 8000300e <bread>
    800033be:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033c0:	40000613          	li	a2,1024
    800033c4:	4581                	li	a1,0
    800033c6:	06050513          	addi	a0,a0,96
    800033ca:	ffffe097          	auipc	ra,0xffffe
    800033ce:	aac080e7          	jalr	-1364(ra) # 80000e76 <memset>
  log_write(bp);
    800033d2:	854a                	mv	a0,s2
    800033d4:	00001097          	auipc	ra,0x1
    800033d8:	fd4080e7          	jalr	-44(ra) # 800043a8 <log_write>
  brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	d60080e7          	jalr	-672(ra) # 8000313e <brelse>
}
    800033e6:	8526                	mv	a0,s1
    800033e8:	60e6                	ld	ra,88(sp)
    800033ea:	6446                	ld	s0,80(sp)
    800033ec:	64a6                	ld	s1,72(sp)
    800033ee:	6906                	ld	s2,64(sp)
    800033f0:	79e2                	ld	s3,56(sp)
    800033f2:	7a42                	ld	s4,48(sp)
    800033f4:	7aa2                	ld	s5,40(sp)
    800033f6:	7b02                	ld	s6,32(sp)
    800033f8:	6be2                	ld	s7,24(sp)
    800033fa:	6c42                	ld	s8,16(sp)
    800033fc:	6ca2                	ld	s9,8(sp)
    800033fe:	6125                	addi	sp,sp,96
    80003400:	8082                	ret

0000000080003402 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003402:	7179                	addi	sp,sp,-48
    80003404:	f406                	sd	ra,40(sp)
    80003406:	f022                	sd	s0,32(sp)
    80003408:	ec26                	sd	s1,24(sp)
    8000340a:	e84a                	sd	s2,16(sp)
    8000340c:	e44e                	sd	s3,8(sp)
    8000340e:	e052                	sd	s4,0(sp)
    80003410:	1800                	addi	s0,sp,48
    80003412:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003414:	47ad                	li	a5,11
    80003416:	04b7fe63          	bgeu	a5,a1,80003472 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000341a:	ff45849b          	addiw	s1,a1,-12
    8000341e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003422:	0ff00793          	li	a5,255
    80003426:	0ae7e363          	bltu	a5,a4,800034cc <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000342a:	08852583          	lw	a1,136(a0)
    8000342e:	c5ad                	beqz	a1,80003498 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003430:	00092503          	lw	a0,0(s2)
    80003434:	00000097          	auipc	ra,0x0
    80003438:	bda080e7          	jalr	-1062(ra) # 8000300e <bread>
    8000343c:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000343e:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003442:	02049593          	slli	a1,s1,0x20
    80003446:	9181                	srli	a1,a1,0x20
    80003448:	058a                	slli	a1,a1,0x2
    8000344a:	00b784b3          	add	s1,a5,a1
    8000344e:	0004a983          	lw	s3,0(s1)
    80003452:	04098d63          	beqz	s3,800034ac <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003456:	8552                	mv	a0,s4
    80003458:	00000097          	auipc	ra,0x0
    8000345c:	ce6080e7          	jalr	-794(ra) # 8000313e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003460:	854e                	mv	a0,s3
    80003462:	70a2                	ld	ra,40(sp)
    80003464:	7402                	ld	s0,32(sp)
    80003466:	64e2                	ld	s1,24(sp)
    80003468:	6942                	ld	s2,16(sp)
    8000346a:	69a2                	ld	s3,8(sp)
    8000346c:	6a02                	ld	s4,0(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003472:	02059493          	slli	s1,a1,0x20
    80003476:	9081                	srli	s1,s1,0x20
    80003478:	048a                	slli	s1,s1,0x2
    8000347a:	94aa                	add	s1,s1,a0
    8000347c:	0584a983          	lw	s3,88(s1)
    80003480:	fe0990e3          	bnez	s3,80003460 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003484:	4108                	lw	a0,0(a0)
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	e4a080e7          	jalr	-438(ra) # 800032d0 <balloc>
    8000348e:	0005099b          	sext.w	s3,a0
    80003492:	0534ac23          	sw	s3,88(s1)
    80003496:	b7e9                	j	80003460 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003498:	4108                	lw	a0,0(a0)
    8000349a:	00000097          	auipc	ra,0x0
    8000349e:	e36080e7          	jalr	-458(ra) # 800032d0 <balloc>
    800034a2:	0005059b          	sext.w	a1,a0
    800034a6:	08b92423          	sw	a1,136(s2)
    800034aa:	b759                	j	80003430 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800034ac:	00092503          	lw	a0,0(s2)
    800034b0:	00000097          	auipc	ra,0x0
    800034b4:	e20080e7          	jalr	-480(ra) # 800032d0 <balloc>
    800034b8:	0005099b          	sext.w	s3,a0
    800034bc:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800034c0:	8552                	mv	a0,s4
    800034c2:	00001097          	auipc	ra,0x1
    800034c6:	ee6080e7          	jalr	-282(ra) # 800043a8 <log_write>
    800034ca:	b771                	j	80003456 <bmap+0x54>
  panic("bmap: out of range");
    800034cc:	00005517          	auipc	a0,0x5
    800034d0:	58c50513          	addi	a0,a0,1420 # 80008a58 <syscalls+0x128>
    800034d4:	ffffd097          	auipc	ra,0xffffd
    800034d8:	090080e7          	jalr	144(ra) # 80000564 <panic>

00000000800034dc <iget>:
{
    800034dc:	7179                	addi	sp,sp,-48
    800034de:	f406                	sd	ra,40(sp)
    800034e0:	f022                	sd	s0,32(sp)
    800034e2:	ec26                	sd	s1,24(sp)
    800034e4:	e84a                	sd	s2,16(sp)
    800034e6:	e44e                	sd	s3,8(sp)
    800034e8:	e052                	sd	s4,0(sp)
    800034ea:	1800                	addi	s0,sp,48
    800034ec:	89aa                	mv	s3,a0
    800034ee:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800034f0:	00030517          	auipc	a0,0x30
    800034f4:	14850513          	addi	a0,a0,328 # 80033638 <icache>
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	69a080e7          	jalr	1690(ra) # 80000b92 <acquire>
  empty = 0;
    80003500:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003502:	00030497          	auipc	s1,0x30
    80003506:	15648493          	addi	s1,s1,342 # 80033658 <icache+0x20>
    8000350a:	00032697          	auipc	a3,0x32
    8000350e:	d6e68693          	addi	a3,a3,-658 # 80035278 <log>
    80003512:	a039                	j	80003520 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003514:	02090b63          	beqz	s2,8000354a <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003518:	09048493          	addi	s1,s1,144
    8000351c:	02d48a63          	beq	s1,a3,80003550 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003520:	449c                	lw	a5,8(s1)
    80003522:	fef059e3          	blez	a5,80003514 <iget+0x38>
    80003526:	4098                	lw	a4,0(s1)
    80003528:	ff3716e3          	bne	a4,s3,80003514 <iget+0x38>
    8000352c:	40d8                	lw	a4,4(s1)
    8000352e:	ff4713e3          	bne	a4,s4,80003514 <iget+0x38>
      ip->ref++;
    80003532:	2785                	addiw	a5,a5,1
    80003534:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003536:	00030517          	auipc	a0,0x30
    8000353a:	10250513          	addi	a0,a0,258 # 80033638 <icache>
    8000353e:	ffffd097          	auipc	ra,0xffffd
    80003542:	724080e7          	jalr	1828(ra) # 80000c62 <release>
      return ip;
    80003546:	8926                	mv	s2,s1
    80003548:	a03d                	j	80003576 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000354a:	f7f9                	bnez	a5,80003518 <iget+0x3c>
    8000354c:	8926                	mv	s2,s1
    8000354e:	b7e9                	j	80003518 <iget+0x3c>
  if(empty == 0)
    80003550:	02090c63          	beqz	s2,80003588 <iget+0xac>
  ip->dev = dev;
    80003554:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003558:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000355c:	4785                	li	a5,1
    8000355e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003562:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    80003566:	00030517          	auipc	a0,0x30
    8000356a:	0d250513          	addi	a0,a0,210 # 80033638 <icache>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	6f4080e7          	jalr	1780(ra) # 80000c62 <release>
}
    80003576:	854a                	mv	a0,s2
    80003578:	70a2                	ld	ra,40(sp)
    8000357a:	7402                	ld	s0,32(sp)
    8000357c:	64e2                	ld	s1,24(sp)
    8000357e:	6942                	ld	s2,16(sp)
    80003580:	69a2                	ld	s3,8(sp)
    80003582:	6a02                	ld	s4,0(sp)
    80003584:	6145                	addi	sp,sp,48
    80003586:	8082                	ret
    panic("iget: no inodes");
    80003588:	00005517          	auipc	a0,0x5
    8000358c:	4e850513          	addi	a0,a0,1256 # 80008a70 <syscalls+0x140>
    80003590:	ffffd097          	auipc	ra,0xffffd
    80003594:	fd4080e7          	jalr	-44(ra) # 80000564 <panic>

0000000080003598 <fsinit>:
fsinit(int dev) {
    80003598:	7179                	addi	sp,sp,-48
    8000359a:	f406                	sd	ra,40(sp)
    8000359c:	f022                	sd	s0,32(sp)
    8000359e:	ec26                	sd	s1,24(sp)
    800035a0:	e84a                	sd	s2,16(sp)
    800035a2:	e44e                	sd	s3,8(sp)
    800035a4:	1800                	addi	s0,sp,48
    800035a6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035a8:	4585                	li	a1,1
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	a64080e7          	jalr	-1436(ra) # 8000300e <bread>
    800035b2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035b4:	00030997          	auipc	s3,0x30
    800035b8:	06498993          	addi	s3,s3,100 # 80033618 <sb>
    800035bc:	02000613          	li	a2,32
    800035c0:	06050593          	addi	a1,a0,96
    800035c4:	854e                	mv	a0,s3
    800035c6:	ffffe097          	auipc	ra,0xffffe
    800035ca:	90c080e7          	jalr	-1780(ra) # 80000ed2 <memmove>
  brelse(bp);
    800035ce:	8526                	mv	a0,s1
    800035d0:	00000097          	auipc	ra,0x0
    800035d4:	b6e080e7          	jalr	-1170(ra) # 8000313e <brelse>
  if(sb.magic != FSMAGIC)
    800035d8:	0009a703          	lw	a4,0(s3)
    800035dc:	102037b7          	lui	a5,0x10203
    800035e0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035e4:	02f71263          	bne	a4,a5,80003608 <fsinit+0x70>
  initlog(dev, &sb);
    800035e8:	00030597          	auipc	a1,0x30
    800035ec:	03058593          	addi	a1,a1,48 # 80033618 <sb>
    800035f0:	854a                	mv	a0,s2
    800035f2:	00001097          	auipc	ra,0x1
    800035f6:	b3e080e7          	jalr	-1218(ra) # 80004130 <initlog>
}
    800035fa:	70a2                	ld	ra,40(sp)
    800035fc:	7402                	ld	s0,32(sp)
    800035fe:	64e2                	ld	s1,24(sp)
    80003600:	6942                	ld	s2,16(sp)
    80003602:	69a2                	ld	s3,8(sp)
    80003604:	6145                	addi	sp,sp,48
    80003606:	8082                	ret
    panic("invalid file system");
    80003608:	00005517          	auipc	a0,0x5
    8000360c:	47850513          	addi	a0,a0,1144 # 80008a80 <syscalls+0x150>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	f54080e7          	jalr	-172(ra) # 80000564 <panic>

0000000080003618 <iinit>:
{
    80003618:	7179                	addi	sp,sp,-48
    8000361a:	f406                	sd	ra,40(sp)
    8000361c:	f022                	sd	s0,32(sp)
    8000361e:	ec26                	sd	s1,24(sp)
    80003620:	e84a                	sd	s2,16(sp)
    80003622:	e44e                	sd	s3,8(sp)
    80003624:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003626:	00005597          	auipc	a1,0x5
    8000362a:	47258593          	addi	a1,a1,1138 # 80008a98 <syscalls+0x168>
    8000362e:	00030517          	auipc	a0,0x30
    80003632:	00a50513          	addi	a0,a0,10 # 80033638 <icache>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	486080e7          	jalr	1158(ra) # 80000abc <initlock>
  for(i = 0; i < NINODE; i++) {
    8000363e:	00030497          	auipc	s1,0x30
    80003642:	02a48493          	addi	s1,s1,42 # 80033668 <icache+0x30>
    80003646:	00032997          	auipc	s3,0x32
    8000364a:	c4298993          	addi	s3,s3,-958 # 80035288 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000364e:	00005917          	auipc	s2,0x5
    80003652:	45290913          	addi	s2,s2,1106 # 80008aa0 <syscalls+0x170>
    80003656:	85ca                	mv	a1,s2
    80003658:	8526                	mv	a0,s1
    8000365a:	00001097          	auipc	ra,0x1
    8000365e:	e34080e7          	jalr	-460(ra) # 8000448e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003662:	09048493          	addi	s1,s1,144
    80003666:	ff3498e3          	bne	s1,s3,80003656 <iinit+0x3e>
}
    8000366a:	70a2                	ld	ra,40(sp)
    8000366c:	7402                	ld	s0,32(sp)
    8000366e:	64e2                	ld	s1,24(sp)
    80003670:	6942                	ld	s2,16(sp)
    80003672:	69a2                	ld	s3,8(sp)
    80003674:	6145                	addi	sp,sp,48
    80003676:	8082                	ret

0000000080003678 <ialloc>:
{
    80003678:	715d                	addi	sp,sp,-80
    8000367a:	e486                	sd	ra,72(sp)
    8000367c:	e0a2                	sd	s0,64(sp)
    8000367e:	fc26                	sd	s1,56(sp)
    80003680:	f84a                	sd	s2,48(sp)
    80003682:	f44e                	sd	s3,40(sp)
    80003684:	f052                	sd	s4,32(sp)
    80003686:	ec56                	sd	s5,24(sp)
    80003688:	e85a                	sd	s6,16(sp)
    8000368a:	e45e                	sd	s7,8(sp)
    8000368c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000368e:	00030717          	auipc	a4,0x30
    80003692:	f9672703          	lw	a4,-106(a4) # 80033624 <sb+0xc>
    80003696:	4785                	li	a5,1
    80003698:	04e7fa63          	bgeu	a5,a4,800036ec <ialloc+0x74>
    8000369c:	8aaa                	mv	s5,a0
    8000369e:	8bae                	mv	s7,a1
    800036a0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800036a2:	00030a17          	auipc	s4,0x30
    800036a6:	f76a0a13          	addi	s4,s4,-138 # 80033618 <sb>
    800036aa:	00048b1b          	sext.w	s6,s1
    800036ae:	0044d793          	srli	a5,s1,0x4
    800036b2:	018a2583          	lw	a1,24(s4)
    800036b6:	9dbd                	addw	a1,a1,a5
    800036b8:	8556                	mv	a0,s5
    800036ba:	00000097          	auipc	ra,0x0
    800036be:	954080e7          	jalr	-1708(ra) # 8000300e <bread>
    800036c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036c4:	06050993          	addi	s3,a0,96
    800036c8:	00f4f793          	andi	a5,s1,15
    800036cc:	079a                	slli	a5,a5,0x6
    800036ce:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036d0:	00099783          	lh	a5,0(s3)
    800036d4:	c785                	beqz	a5,800036fc <ialloc+0x84>
    brelse(bp);
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	a68080e7          	jalr	-1432(ra) # 8000313e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036de:	0485                	addi	s1,s1,1
    800036e0:	00ca2703          	lw	a4,12(s4)
    800036e4:	0004879b          	sext.w	a5,s1
    800036e8:	fce7e1e3          	bltu	a5,a4,800036aa <ialloc+0x32>
  panic("ialloc: no inodes");
    800036ec:	00005517          	auipc	a0,0x5
    800036f0:	3bc50513          	addi	a0,a0,956 # 80008aa8 <syscalls+0x178>
    800036f4:	ffffd097          	auipc	ra,0xffffd
    800036f8:	e70080e7          	jalr	-400(ra) # 80000564 <panic>
      memset(dip, 0, sizeof(*dip));
    800036fc:	04000613          	li	a2,64
    80003700:	4581                	li	a1,0
    80003702:	854e                	mv	a0,s3
    80003704:	ffffd097          	auipc	ra,0xffffd
    80003708:	772080e7          	jalr	1906(ra) # 80000e76 <memset>
      dip->type = type;
    8000370c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003710:	854a                	mv	a0,s2
    80003712:	00001097          	auipc	ra,0x1
    80003716:	c96080e7          	jalr	-874(ra) # 800043a8 <log_write>
      brelse(bp);
    8000371a:	854a                	mv	a0,s2
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	a22080e7          	jalr	-1502(ra) # 8000313e <brelse>
      return iget(dev, inum);
    80003724:	85da                	mv	a1,s6
    80003726:	8556                	mv	a0,s5
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	db4080e7          	jalr	-588(ra) # 800034dc <iget>
}
    80003730:	60a6                	ld	ra,72(sp)
    80003732:	6406                	ld	s0,64(sp)
    80003734:	74e2                	ld	s1,56(sp)
    80003736:	7942                	ld	s2,48(sp)
    80003738:	79a2                	ld	s3,40(sp)
    8000373a:	7a02                	ld	s4,32(sp)
    8000373c:	6ae2                	ld	s5,24(sp)
    8000373e:	6b42                	ld	s6,16(sp)
    80003740:	6ba2                	ld	s7,8(sp)
    80003742:	6161                	addi	sp,sp,80
    80003744:	8082                	ret

0000000080003746 <iupdate>:
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	e04a                	sd	s2,0(sp)
    80003750:	1000                	addi	s0,sp,32
    80003752:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003754:	415c                	lw	a5,4(a0)
    80003756:	0047d79b          	srliw	a5,a5,0x4
    8000375a:	00030597          	auipc	a1,0x30
    8000375e:	ed65a583          	lw	a1,-298(a1) # 80033630 <sb+0x18>
    80003762:	9dbd                	addw	a1,a1,a5
    80003764:	4108                	lw	a0,0(a0)
    80003766:	00000097          	auipc	ra,0x0
    8000376a:	8a8080e7          	jalr	-1880(ra) # 8000300e <bread>
    8000376e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003770:	06050793          	addi	a5,a0,96
    80003774:	40c8                	lw	a0,4(s1)
    80003776:	893d                	andi	a0,a0,15
    80003778:	051a                	slli	a0,a0,0x6
    8000377a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000377c:	04c49703          	lh	a4,76(s1)
    80003780:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003784:	04e49703          	lh	a4,78(s1)
    80003788:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000378c:	05049703          	lh	a4,80(s1)
    80003790:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003794:	05249703          	lh	a4,82(s1)
    80003798:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000379c:	48f8                	lw	a4,84(s1)
    8000379e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037a0:	03400613          	li	a2,52
    800037a4:	05848593          	addi	a1,s1,88
    800037a8:	0531                	addi	a0,a0,12
    800037aa:	ffffd097          	auipc	ra,0xffffd
    800037ae:	728080e7          	jalr	1832(ra) # 80000ed2 <memmove>
  log_write(bp);
    800037b2:	854a                	mv	a0,s2
    800037b4:	00001097          	auipc	ra,0x1
    800037b8:	bf4080e7          	jalr	-1036(ra) # 800043a8 <log_write>
  brelse(bp);
    800037bc:	854a                	mv	a0,s2
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	980080e7          	jalr	-1664(ra) # 8000313e <brelse>
}
    800037c6:	60e2                	ld	ra,24(sp)
    800037c8:	6442                	ld	s0,16(sp)
    800037ca:	64a2                	ld	s1,8(sp)
    800037cc:	6902                	ld	s2,0(sp)
    800037ce:	6105                	addi	sp,sp,32
    800037d0:	8082                	ret

00000000800037d2 <idup>:
{
    800037d2:	1101                	addi	sp,sp,-32
    800037d4:	ec06                	sd	ra,24(sp)
    800037d6:	e822                	sd	s0,16(sp)
    800037d8:	e426                	sd	s1,8(sp)
    800037da:	1000                	addi	s0,sp,32
    800037dc:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037de:	00030517          	auipc	a0,0x30
    800037e2:	e5a50513          	addi	a0,a0,-422 # 80033638 <icache>
    800037e6:	ffffd097          	auipc	ra,0xffffd
    800037ea:	3ac080e7          	jalr	940(ra) # 80000b92 <acquire>
  ip->ref++;
    800037ee:	449c                	lw	a5,8(s1)
    800037f0:	2785                	addiw	a5,a5,1
    800037f2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037f4:	00030517          	auipc	a0,0x30
    800037f8:	e4450513          	addi	a0,a0,-444 # 80033638 <icache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	466080e7          	jalr	1126(ra) # 80000c62 <release>
}
    80003804:	8526                	mv	a0,s1
    80003806:	60e2                	ld	ra,24(sp)
    80003808:	6442                	ld	s0,16(sp)
    8000380a:	64a2                	ld	s1,8(sp)
    8000380c:	6105                	addi	sp,sp,32
    8000380e:	8082                	ret

0000000080003810 <ilock>:
{
    80003810:	1101                	addi	sp,sp,-32
    80003812:	ec06                	sd	ra,24(sp)
    80003814:	e822                	sd	s0,16(sp)
    80003816:	e426                	sd	s1,8(sp)
    80003818:	e04a                	sd	s2,0(sp)
    8000381a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000381c:	c115                	beqz	a0,80003840 <ilock+0x30>
    8000381e:	84aa                	mv	s1,a0
    80003820:	451c                	lw	a5,8(a0)
    80003822:	00f05f63          	blez	a5,80003840 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003826:	0541                	addi	a0,a0,16
    80003828:	00001097          	auipc	ra,0x1
    8000382c:	ca0080e7          	jalr	-864(ra) # 800044c8 <acquiresleep>
  if(ip->valid == 0){
    80003830:	44bc                	lw	a5,72(s1)
    80003832:	cf99                	beqz	a5,80003850 <ilock+0x40>
}
    80003834:	60e2                	ld	ra,24(sp)
    80003836:	6442                	ld	s0,16(sp)
    80003838:	64a2                	ld	s1,8(sp)
    8000383a:	6902                	ld	s2,0(sp)
    8000383c:	6105                	addi	sp,sp,32
    8000383e:	8082                	ret
    panic("ilock");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	28050513          	addi	a0,a0,640 # 80008ac0 <syscalls+0x190>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	d1c080e7          	jalr	-740(ra) # 80000564 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003850:	40dc                	lw	a5,4(s1)
    80003852:	0047d79b          	srliw	a5,a5,0x4
    80003856:	00030597          	auipc	a1,0x30
    8000385a:	dda5a583          	lw	a1,-550(a1) # 80033630 <sb+0x18>
    8000385e:	9dbd                	addw	a1,a1,a5
    80003860:	4088                	lw	a0,0(s1)
    80003862:	fffff097          	auipc	ra,0xfffff
    80003866:	7ac080e7          	jalr	1964(ra) # 8000300e <bread>
    8000386a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000386c:	06050593          	addi	a1,a0,96
    80003870:	40dc                	lw	a5,4(s1)
    80003872:	8bbd                	andi	a5,a5,15
    80003874:	079a                	slli	a5,a5,0x6
    80003876:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003878:	00059783          	lh	a5,0(a1)
    8000387c:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003880:	00259783          	lh	a5,2(a1)
    80003884:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003888:	00459783          	lh	a5,4(a1)
    8000388c:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003890:	00659783          	lh	a5,6(a1)
    80003894:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003898:	459c                	lw	a5,8(a1)
    8000389a:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000389c:	03400613          	li	a2,52
    800038a0:	05b1                	addi	a1,a1,12
    800038a2:	05848513          	addi	a0,s1,88
    800038a6:	ffffd097          	auipc	ra,0xffffd
    800038aa:	62c080e7          	jalr	1580(ra) # 80000ed2 <memmove>
    brelse(bp);
    800038ae:	854a                	mv	a0,s2
    800038b0:	00000097          	auipc	ra,0x0
    800038b4:	88e080e7          	jalr	-1906(ra) # 8000313e <brelse>
    ip->valid = 1;
    800038b8:	4785                	li	a5,1
    800038ba:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    800038bc:	04c49783          	lh	a5,76(s1)
    800038c0:	fbb5                	bnez	a5,80003834 <ilock+0x24>
      panic("ilock: no type");
    800038c2:	00005517          	auipc	a0,0x5
    800038c6:	20650513          	addi	a0,a0,518 # 80008ac8 <syscalls+0x198>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	c9a080e7          	jalr	-870(ra) # 80000564 <panic>

00000000800038d2 <iunlock>:
{
    800038d2:	1101                	addi	sp,sp,-32
    800038d4:	ec06                	sd	ra,24(sp)
    800038d6:	e822                	sd	s0,16(sp)
    800038d8:	e426                	sd	s1,8(sp)
    800038da:	e04a                	sd	s2,0(sp)
    800038dc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038de:	c905                	beqz	a0,8000390e <iunlock+0x3c>
    800038e0:	84aa                	mv	s1,a0
    800038e2:	01050913          	addi	s2,a0,16
    800038e6:	854a                	mv	a0,s2
    800038e8:	00001097          	auipc	ra,0x1
    800038ec:	c7a080e7          	jalr	-902(ra) # 80004562 <holdingsleep>
    800038f0:	cd19                	beqz	a0,8000390e <iunlock+0x3c>
    800038f2:	449c                	lw	a5,8(s1)
    800038f4:	00f05d63          	blez	a5,8000390e <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038f8:	854a                	mv	a0,s2
    800038fa:	00001097          	auipc	ra,0x1
    800038fe:	c24080e7          	jalr	-988(ra) # 8000451e <releasesleep>
}
    80003902:	60e2                	ld	ra,24(sp)
    80003904:	6442                	ld	s0,16(sp)
    80003906:	64a2                	ld	s1,8(sp)
    80003908:	6902                	ld	s2,0(sp)
    8000390a:	6105                	addi	sp,sp,32
    8000390c:	8082                	ret
    panic("iunlock");
    8000390e:	00005517          	auipc	a0,0x5
    80003912:	1ca50513          	addi	a0,a0,458 # 80008ad8 <syscalls+0x1a8>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	c4e080e7          	jalr	-946(ra) # 80000564 <panic>

000000008000391e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000391e:	7179                	addi	sp,sp,-48
    80003920:	f406                	sd	ra,40(sp)
    80003922:	f022                	sd	s0,32(sp)
    80003924:	ec26                	sd	s1,24(sp)
    80003926:	e84a                	sd	s2,16(sp)
    80003928:	e44e                	sd	s3,8(sp)
    8000392a:	e052                	sd	s4,0(sp)
    8000392c:	1800                	addi	s0,sp,48
    8000392e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003930:	05850493          	addi	s1,a0,88
    80003934:	08850913          	addi	s2,a0,136
    80003938:	a021                	j	80003940 <itrunc+0x22>
    8000393a:	0491                	addi	s1,s1,4
    8000393c:	01248d63          	beq	s1,s2,80003956 <itrunc+0x38>
    if(ip->addrs[i]){
    80003940:	408c                	lw	a1,0(s1)
    80003942:	dde5                	beqz	a1,8000393a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003944:	0009a503          	lw	a0,0(s3)
    80003948:	00000097          	auipc	ra,0x0
    8000394c:	90c080e7          	jalr	-1780(ra) # 80003254 <bfree>
      ip->addrs[i] = 0;
    80003950:	0004a023          	sw	zero,0(s1)
    80003954:	b7dd                	j	8000393a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003956:	0889a583          	lw	a1,136(s3)
    8000395a:	e185                	bnez	a1,8000397a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000395c:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003960:	854e                	mv	a0,s3
    80003962:	00000097          	auipc	ra,0x0
    80003966:	de4080e7          	jalr	-540(ra) # 80003746 <iupdate>
}
    8000396a:	70a2                	ld	ra,40(sp)
    8000396c:	7402                	ld	s0,32(sp)
    8000396e:	64e2                	ld	s1,24(sp)
    80003970:	6942                	ld	s2,16(sp)
    80003972:	69a2                	ld	s3,8(sp)
    80003974:	6a02                	ld	s4,0(sp)
    80003976:	6145                	addi	sp,sp,48
    80003978:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000397a:	0009a503          	lw	a0,0(s3)
    8000397e:	fffff097          	auipc	ra,0xfffff
    80003982:	690080e7          	jalr	1680(ra) # 8000300e <bread>
    80003986:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003988:	06050493          	addi	s1,a0,96
    8000398c:	46050913          	addi	s2,a0,1120
    80003990:	a021                	j	80003998 <itrunc+0x7a>
    80003992:	0491                	addi	s1,s1,4
    80003994:	01248b63          	beq	s1,s2,800039aa <itrunc+0x8c>
      if(a[j])
    80003998:	408c                	lw	a1,0(s1)
    8000399a:	dde5                	beqz	a1,80003992 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000399c:	0009a503          	lw	a0,0(s3)
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	8b4080e7          	jalr	-1868(ra) # 80003254 <bfree>
    800039a8:	b7ed                	j	80003992 <itrunc+0x74>
    brelse(bp);
    800039aa:	8552                	mv	a0,s4
    800039ac:	fffff097          	auipc	ra,0xfffff
    800039b0:	792080e7          	jalr	1938(ra) # 8000313e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039b4:	0889a583          	lw	a1,136(s3)
    800039b8:	0009a503          	lw	a0,0(s3)
    800039bc:	00000097          	auipc	ra,0x0
    800039c0:	898080e7          	jalr	-1896(ra) # 80003254 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039c4:	0809a423          	sw	zero,136(s3)
    800039c8:	bf51                	j	8000395c <itrunc+0x3e>

00000000800039ca <iput>:
{
    800039ca:	1101                	addi	sp,sp,-32
    800039cc:	ec06                	sd	ra,24(sp)
    800039ce:	e822                	sd	s0,16(sp)
    800039d0:	e426                	sd	s1,8(sp)
    800039d2:	e04a                	sd	s2,0(sp)
    800039d4:	1000                	addi	s0,sp,32
    800039d6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039d8:	00030517          	auipc	a0,0x30
    800039dc:	c6050513          	addi	a0,a0,-928 # 80033638 <icache>
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	1b2080e7          	jalr	434(ra) # 80000b92 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039e8:	4498                	lw	a4,8(s1)
    800039ea:	4785                	li	a5,1
    800039ec:	02f70363          	beq	a4,a5,80003a12 <iput+0x48>
  ip->ref--;
    800039f0:	449c                	lw	a5,8(s1)
    800039f2:	37fd                	addiw	a5,a5,-1
    800039f4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039f6:	00030517          	auipc	a0,0x30
    800039fa:	c4250513          	addi	a0,a0,-958 # 80033638 <icache>
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	264080e7          	jalr	612(ra) # 80000c62 <release>
}
    80003a06:	60e2                	ld	ra,24(sp)
    80003a08:	6442                	ld	s0,16(sp)
    80003a0a:	64a2                	ld	s1,8(sp)
    80003a0c:	6902                	ld	s2,0(sp)
    80003a0e:	6105                	addi	sp,sp,32
    80003a10:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a12:	44bc                	lw	a5,72(s1)
    80003a14:	dff1                	beqz	a5,800039f0 <iput+0x26>
    80003a16:	05249783          	lh	a5,82(s1)
    80003a1a:	fbf9                	bnez	a5,800039f0 <iput+0x26>
    acquiresleep(&ip->lock);
    80003a1c:	01048913          	addi	s2,s1,16
    80003a20:	854a                	mv	a0,s2
    80003a22:	00001097          	auipc	ra,0x1
    80003a26:	aa6080e7          	jalr	-1370(ra) # 800044c8 <acquiresleep>
    release(&icache.lock);
    80003a2a:	00030517          	auipc	a0,0x30
    80003a2e:	c0e50513          	addi	a0,a0,-1010 # 80033638 <icache>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	230080e7          	jalr	560(ra) # 80000c62 <release>
    itrunc(ip);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	ee2080e7          	jalr	-286(ra) # 8000391e <itrunc>
    ip->type = 0;
    80003a44:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003a48:	8526                	mv	a0,s1
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	cfc080e7          	jalr	-772(ra) # 80003746 <iupdate>
    ip->valid = 0;
    80003a52:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003a56:	854a                	mv	a0,s2
    80003a58:	00001097          	auipc	ra,0x1
    80003a5c:	ac6080e7          	jalr	-1338(ra) # 8000451e <releasesleep>
    acquire(&icache.lock);
    80003a60:	00030517          	auipc	a0,0x30
    80003a64:	bd850513          	addi	a0,a0,-1064 # 80033638 <icache>
    80003a68:	ffffd097          	auipc	ra,0xffffd
    80003a6c:	12a080e7          	jalr	298(ra) # 80000b92 <acquire>
    80003a70:	b741                	j	800039f0 <iput+0x26>

0000000080003a72 <iunlockput>:
{
    80003a72:	1101                	addi	sp,sp,-32
    80003a74:	ec06                	sd	ra,24(sp)
    80003a76:	e822                	sd	s0,16(sp)
    80003a78:	e426                	sd	s1,8(sp)
    80003a7a:	1000                	addi	s0,sp,32
    80003a7c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a7e:	00000097          	auipc	ra,0x0
    80003a82:	e54080e7          	jalr	-428(ra) # 800038d2 <iunlock>
  iput(ip);
    80003a86:	8526                	mv	a0,s1
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	f42080e7          	jalr	-190(ra) # 800039ca <iput>
}
    80003a90:	60e2                	ld	ra,24(sp)
    80003a92:	6442                	ld	s0,16(sp)
    80003a94:	64a2                	ld	s1,8(sp)
    80003a96:	6105                	addi	sp,sp,32
    80003a98:	8082                	ret

0000000080003a9a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a9a:	1141                	addi	sp,sp,-16
    80003a9c:	e422                	sd	s0,8(sp)
    80003a9e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003aa0:	411c                	lw	a5,0(a0)
    80003aa2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003aa4:	415c                	lw	a5,4(a0)
    80003aa6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003aa8:	04c51783          	lh	a5,76(a0)
    80003aac:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ab0:	05251783          	lh	a5,82(a0)
    80003ab4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ab8:	05456783          	lwu	a5,84(a0)
    80003abc:	e99c                	sd	a5,16(a1)
}
    80003abe:	6422                	ld	s0,8(sp)
    80003ac0:	0141                	addi	sp,sp,16
    80003ac2:	8082                	ret

0000000080003ac4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ac4:	497c                	lw	a5,84(a0)
    80003ac6:	0ed7e963          	bltu	a5,a3,80003bb8 <readi+0xf4>
{
    80003aca:	7159                	addi	sp,sp,-112
    80003acc:	f486                	sd	ra,104(sp)
    80003ace:	f0a2                	sd	s0,96(sp)
    80003ad0:	eca6                	sd	s1,88(sp)
    80003ad2:	e8ca                	sd	s2,80(sp)
    80003ad4:	e4ce                	sd	s3,72(sp)
    80003ad6:	e0d2                	sd	s4,64(sp)
    80003ad8:	fc56                	sd	s5,56(sp)
    80003ada:	f85a                	sd	s6,48(sp)
    80003adc:	f45e                	sd	s7,40(sp)
    80003ade:	f062                	sd	s8,32(sp)
    80003ae0:	ec66                	sd	s9,24(sp)
    80003ae2:	e86a                	sd	s10,16(sp)
    80003ae4:	e46e                	sd	s11,8(sp)
    80003ae6:	1880                	addi	s0,sp,112
    80003ae8:	8baa                	mv	s7,a0
    80003aea:	8c2e                	mv	s8,a1
    80003aec:	8ab2                	mv	s5,a2
    80003aee:	84b6                	mv	s1,a3
    80003af0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003af2:	9f35                	addw	a4,a4,a3
    return 0;
    80003af4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003af6:	0ad76063          	bltu	a4,a3,80003b96 <readi+0xd2>
  if(off + n > ip->size)
    80003afa:	00e7f463          	bgeu	a5,a4,80003b02 <readi+0x3e>
    n = ip->size - off;
    80003afe:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b02:	0a0b0963          	beqz	s6,80003bb4 <readi+0xf0>
    80003b06:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b08:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b0c:	5cfd                	li	s9,-1
    80003b0e:	a82d                	j	80003b48 <readi+0x84>
    80003b10:	020a1d93          	slli	s11,s4,0x20
    80003b14:	020ddd93          	srli	s11,s11,0x20
    80003b18:	06090793          	addi	a5,s2,96
    80003b1c:	86ee                	mv	a3,s11
    80003b1e:	963e                	add	a2,a2,a5
    80003b20:	85d6                	mv	a1,s5
    80003b22:	8562                	mv	a0,s8
    80003b24:	fffff097          	auipc	ra,0xfffff
    80003b28:	aaa080e7          	jalr	-1366(ra) # 800025ce <either_copyout>
    80003b2c:	05950d63          	beq	a0,s9,80003b86 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b30:	854a                	mv	a0,s2
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	60c080e7          	jalr	1548(ra) # 8000313e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b3a:	013a09bb          	addw	s3,s4,s3
    80003b3e:	009a04bb          	addw	s1,s4,s1
    80003b42:	9aee                	add	s5,s5,s11
    80003b44:	0569f763          	bgeu	s3,s6,80003b92 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b48:	000ba903          	lw	s2,0(s7)
    80003b4c:	00a4d59b          	srliw	a1,s1,0xa
    80003b50:	855e                	mv	a0,s7
    80003b52:	00000097          	auipc	ra,0x0
    80003b56:	8b0080e7          	jalr	-1872(ra) # 80003402 <bmap>
    80003b5a:	0005059b          	sext.w	a1,a0
    80003b5e:	854a                	mv	a0,s2
    80003b60:	fffff097          	auipc	ra,0xfffff
    80003b64:	4ae080e7          	jalr	1198(ra) # 8000300e <bread>
    80003b68:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6a:	3ff4f613          	andi	a2,s1,1023
    80003b6e:	40cd07bb          	subw	a5,s10,a2
    80003b72:	413b073b          	subw	a4,s6,s3
    80003b76:	8a3e                	mv	s4,a5
    80003b78:	2781                	sext.w	a5,a5
    80003b7a:	0007069b          	sext.w	a3,a4
    80003b7e:	f8f6f9e3          	bgeu	a3,a5,80003b10 <readi+0x4c>
    80003b82:	8a3a                	mv	s4,a4
    80003b84:	b771                	j	80003b10 <readi+0x4c>
      brelse(bp);
    80003b86:	854a                	mv	a0,s2
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	5b6080e7          	jalr	1462(ra) # 8000313e <brelse>
      tot = -1;
    80003b90:	59fd                	li	s3,-1
  }
  return tot;
    80003b92:	0009851b          	sext.w	a0,s3
}
    80003b96:	70a6                	ld	ra,104(sp)
    80003b98:	7406                	ld	s0,96(sp)
    80003b9a:	64e6                	ld	s1,88(sp)
    80003b9c:	6946                	ld	s2,80(sp)
    80003b9e:	69a6                	ld	s3,72(sp)
    80003ba0:	6a06                	ld	s4,64(sp)
    80003ba2:	7ae2                	ld	s5,56(sp)
    80003ba4:	7b42                	ld	s6,48(sp)
    80003ba6:	7ba2                	ld	s7,40(sp)
    80003ba8:	7c02                	ld	s8,32(sp)
    80003baa:	6ce2                	ld	s9,24(sp)
    80003bac:	6d42                	ld	s10,16(sp)
    80003bae:	6da2                	ld	s11,8(sp)
    80003bb0:	6165                	addi	sp,sp,112
    80003bb2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bb4:	89da                	mv	s3,s6
    80003bb6:	bff1                	j	80003b92 <readi+0xce>
    return 0;
    80003bb8:	4501                	li	a0,0
}
    80003bba:	8082                	ret

0000000080003bbc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bbc:	497c                	lw	a5,84(a0)
    80003bbe:	10d7e863          	bltu	a5,a3,80003cce <writei+0x112>
{
    80003bc2:	7159                	addi	sp,sp,-112
    80003bc4:	f486                	sd	ra,104(sp)
    80003bc6:	f0a2                	sd	s0,96(sp)
    80003bc8:	eca6                	sd	s1,88(sp)
    80003bca:	e8ca                	sd	s2,80(sp)
    80003bcc:	e4ce                	sd	s3,72(sp)
    80003bce:	e0d2                	sd	s4,64(sp)
    80003bd0:	fc56                	sd	s5,56(sp)
    80003bd2:	f85a                	sd	s6,48(sp)
    80003bd4:	f45e                	sd	s7,40(sp)
    80003bd6:	f062                	sd	s8,32(sp)
    80003bd8:	ec66                	sd	s9,24(sp)
    80003bda:	e86a                	sd	s10,16(sp)
    80003bdc:	e46e                	sd	s11,8(sp)
    80003bde:	1880                	addi	s0,sp,112
    80003be0:	8b2a                	mv	s6,a0
    80003be2:	8c2e                	mv	s8,a1
    80003be4:	8ab2                	mv	s5,a2
    80003be6:	8936                	mv	s2,a3
    80003be8:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003bea:	00e687bb          	addw	a5,a3,a4
    80003bee:	0ed7e263          	bltu	a5,a3,80003cd2 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bf2:	00043737          	lui	a4,0x43
    80003bf6:	0ef76063          	bltu	a4,a5,80003cd6 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bfa:	0c0b8863          	beqz	s7,80003cca <writei+0x10e>
    80003bfe:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c00:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c04:	5cfd                	li	s9,-1
    80003c06:	a091                	j	80003c4a <writei+0x8e>
    80003c08:	02099d93          	slli	s11,s3,0x20
    80003c0c:	020ddd93          	srli	s11,s11,0x20
    80003c10:	06048793          	addi	a5,s1,96
    80003c14:	86ee                	mv	a3,s11
    80003c16:	8656                	mv	a2,s5
    80003c18:	85e2                	mv	a1,s8
    80003c1a:	953e                	add	a0,a0,a5
    80003c1c:	fffff097          	auipc	ra,0xfffff
    80003c20:	a08080e7          	jalr	-1528(ra) # 80002624 <either_copyin>
    80003c24:	07950263          	beq	a0,s9,80003c88 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c28:	8526                	mv	a0,s1
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	77e080e7          	jalr	1918(ra) # 800043a8 <log_write>
    brelse(bp);
    80003c32:	8526                	mv	a0,s1
    80003c34:	fffff097          	auipc	ra,0xfffff
    80003c38:	50a080e7          	jalr	1290(ra) # 8000313e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c3c:	01498a3b          	addw	s4,s3,s4
    80003c40:	0129893b          	addw	s2,s3,s2
    80003c44:	9aee                	add	s5,s5,s11
    80003c46:	057a7663          	bgeu	s4,s7,80003c92 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c4a:	000b2483          	lw	s1,0(s6)
    80003c4e:	00a9559b          	srliw	a1,s2,0xa
    80003c52:	855a                	mv	a0,s6
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	7ae080e7          	jalr	1966(ra) # 80003402 <bmap>
    80003c5c:	0005059b          	sext.w	a1,a0
    80003c60:	8526                	mv	a0,s1
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	3ac080e7          	jalr	940(ra) # 8000300e <bread>
    80003c6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c6c:	3ff97513          	andi	a0,s2,1023
    80003c70:	40ad07bb          	subw	a5,s10,a0
    80003c74:	414b873b          	subw	a4,s7,s4
    80003c78:	89be                	mv	s3,a5
    80003c7a:	2781                	sext.w	a5,a5
    80003c7c:	0007069b          	sext.w	a3,a4
    80003c80:	f8f6f4e3          	bgeu	a3,a5,80003c08 <writei+0x4c>
    80003c84:	89ba                	mv	s3,a4
    80003c86:	b749                	j	80003c08 <writei+0x4c>
      brelse(bp);
    80003c88:	8526                	mv	a0,s1
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	4b4080e7          	jalr	1204(ra) # 8000313e <brelse>
  }

  if(off > ip->size)
    80003c92:	054b2783          	lw	a5,84(s6)
    80003c96:	0127f463          	bgeu	a5,s2,80003c9e <writei+0xe2>
    ip->size = off;
    80003c9a:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c9e:	855a                	mv	a0,s6
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	aa6080e7          	jalr	-1370(ra) # 80003746 <iupdate>

  return tot;
    80003ca8:	000a051b          	sext.w	a0,s4
}
    80003cac:	70a6                	ld	ra,104(sp)
    80003cae:	7406                	ld	s0,96(sp)
    80003cb0:	64e6                	ld	s1,88(sp)
    80003cb2:	6946                	ld	s2,80(sp)
    80003cb4:	69a6                	ld	s3,72(sp)
    80003cb6:	6a06                	ld	s4,64(sp)
    80003cb8:	7ae2                	ld	s5,56(sp)
    80003cba:	7b42                	ld	s6,48(sp)
    80003cbc:	7ba2                	ld	s7,40(sp)
    80003cbe:	7c02                	ld	s8,32(sp)
    80003cc0:	6ce2                	ld	s9,24(sp)
    80003cc2:	6d42                	ld	s10,16(sp)
    80003cc4:	6da2                	ld	s11,8(sp)
    80003cc6:	6165                	addi	sp,sp,112
    80003cc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cca:	8a5e                	mv	s4,s7
    80003ccc:	bfc9                	j	80003c9e <writei+0xe2>
    return -1;
    80003cce:	557d                	li	a0,-1
}
    80003cd0:	8082                	ret
    return -1;
    80003cd2:	557d                	li	a0,-1
    80003cd4:	bfe1                	j	80003cac <writei+0xf0>
    return -1;
    80003cd6:	557d                	li	a0,-1
    80003cd8:	bfd1                	j	80003cac <writei+0xf0>

0000000080003cda <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cda:	1141                	addi	sp,sp,-16
    80003cdc:	e406                	sd	ra,8(sp)
    80003cde:	e022                	sd	s0,0(sp)
    80003ce0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ce2:	4639                	li	a2,14
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	28e080e7          	jalr	654(ra) # 80000f72 <strncmp>
}
    80003cec:	60a2                	ld	ra,8(sp)
    80003cee:	6402                	ld	s0,0(sp)
    80003cf0:	0141                	addi	sp,sp,16
    80003cf2:	8082                	ret

0000000080003cf4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cf4:	7139                	addi	sp,sp,-64
    80003cf6:	fc06                	sd	ra,56(sp)
    80003cf8:	f822                	sd	s0,48(sp)
    80003cfa:	f426                	sd	s1,40(sp)
    80003cfc:	f04a                	sd	s2,32(sp)
    80003cfe:	ec4e                	sd	s3,24(sp)
    80003d00:	e852                	sd	s4,16(sp)
    80003d02:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d04:	04c51703          	lh	a4,76(a0)
    80003d08:	4785                	li	a5,1
    80003d0a:	00f71a63          	bne	a4,a5,80003d1e <dirlookup+0x2a>
    80003d0e:	892a                	mv	s2,a0
    80003d10:	89ae                	mv	s3,a1
    80003d12:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d14:	497c                	lw	a5,84(a0)
    80003d16:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d18:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d1a:	e79d                	bnez	a5,80003d48 <dirlookup+0x54>
    80003d1c:	a8a5                	j	80003d94 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d1e:	00005517          	auipc	a0,0x5
    80003d22:	dc250513          	addi	a0,a0,-574 # 80008ae0 <syscalls+0x1b0>
    80003d26:	ffffd097          	auipc	ra,0xffffd
    80003d2a:	83e080e7          	jalr	-1986(ra) # 80000564 <panic>
      panic("dirlookup read");
    80003d2e:	00005517          	auipc	a0,0x5
    80003d32:	dca50513          	addi	a0,a0,-566 # 80008af8 <syscalls+0x1c8>
    80003d36:	ffffd097          	auipc	ra,0xffffd
    80003d3a:	82e080e7          	jalr	-2002(ra) # 80000564 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d3e:	24c1                	addiw	s1,s1,16
    80003d40:	05492783          	lw	a5,84(s2)
    80003d44:	04f4f763          	bgeu	s1,a5,80003d92 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d48:	4741                	li	a4,16
    80003d4a:	86a6                	mv	a3,s1
    80003d4c:	fc040613          	addi	a2,s0,-64
    80003d50:	4581                	li	a1,0
    80003d52:	854a                	mv	a0,s2
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	d70080e7          	jalr	-656(ra) # 80003ac4 <readi>
    80003d5c:	47c1                	li	a5,16
    80003d5e:	fcf518e3          	bne	a0,a5,80003d2e <dirlookup+0x3a>
    if(de.inum == 0)
    80003d62:	fc045783          	lhu	a5,-64(s0)
    80003d66:	dfe1                	beqz	a5,80003d3e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d68:	fc240593          	addi	a1,s0,-62
    80003d6c:	854e                	mv	a0,s3
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	f6c080e7          	jalr	-148(ra) # 80003cda <namecmp>
    80003d76:	f561                	bnez	a0,80003d3e <dirlookup+0x4a>
      if(poff)
    80003d78:	000a0463          	beqz	s4,80003d80 <dirlookup+0x8c>
        *poff = off;
    80003d7c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d80:	fc045583          	lhu	a1,-64(s0)
    80003d84:	00092503          	lw	a0,0(s2)
    80003d88:	fffff097          	auipc	ra,0xfffff
    80003d8c:	754080e7          	jalr	1876(ra) # 800034dc <iget>
    80003d90:	a011                	j	80003d94 <dirlookup+0xa0>
  return 0;
    80003d92:	4501                	li	a0,0
}
    80003d94:	70e2                	ld	ra,56(sp)
    80003d96:	7442                	ld	s0,48(sp)
    80003d98:	74a2                	ld	s1,40(sp)
    80003d9a:	7902                	ld	s2,32(sp)
    80003d9c:	69e2                	ld	s3,24(sp)
    80003d9e:	6a42                	ld	s4,16(sp)
    80003da0:	6121                	addi	sp,sp,64
    80003da2:	8082                	ret

0000000080003da4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003da4:	711d                	addi	sp,sp,-96
    80003da6:	ec86                	sd	ra,88(sp)
    80003da8:	e8a2                	sd	s0,80(sp)
    80003daa:	e4a6                	sd	s1,72(sp)
    80003dac:	e0ca                	sd	s2,64(sp)
    80003dae:	fc4e                	sd	s3,56(sp)
    80003db0:	f852                	sd	s4,48(sp)
    80003db2:	f456                	sd	s5,40(sp)
    80003db4:	f05a                	sd	s6,32(sp)
    80003db6:	ec5e                	sd	s7,24(sp)
    80003db8:	e862                	sd	s8,16(sp)
    80003dba:	e466                	sd	s9,8(sp)
    80003dbc:	1080                	addi	s0,sp,96
    80003dbe:	84aa                	mv	s1,a0
    80003dc0:	8aae                	mv	s5,a1
    80003dc2:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003dc4:	00054703          	lbu	a4,0(a0)
    80003dc8:	02f00793          	li	a5,47
    80003dcc:	02f70363          	beq	a4,a5,80003df2 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003dd0:	ffffe097          	auipc	ra,0xffffe
    80003dd4:	d78080e7          	jalr	-648(ra) # 80001b48 <myproc>
    80003dd8:	15853503          	ld	a0,344(a0)
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	9f6080e7          	jalr	-1546(ra) # 800037d2 <idup>
    80003de4:	89aa                	mv	s3,a0
  while(*path == '/')
    80003de6:	02f00913          	li	s2,47
  len = path - s;
    80003dea:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003dec:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dee:	4b85                	li	s7,1
    80003df0:	a865                	j	80003ea8 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003df2:	4585                	li	a1,1
    80003df4:	4505                	li	a0,1
    80003df6:	fffff097          	auipc	ra,0xfffff
    80003dfa:	6e6080e7          	jalr	1766(ra) # 800034dc <iget>
    80003dfe:	89aa                	mv	s3,a0
    80003e00:	b7dd                	j	80003de6 <namex+0x42>
      iunlockput(ip);
    80003e02:	854e                	mv	a0,s3
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	c6e080e7          	jalr	-914(ra) # 80003a72 <iunlockput>
      return 0;
    80003e0c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e0e:	854e                	mv	a0,s3
    80003e10:	60e6                	ld	ra,88(sp)
    80003e12:	6446                	ld	s0,80(sp)
    80003e14:	64a6                	ld	s1,72(sp)
    80003e16:	6906                	ld	s2,64(sp)
    80003e18:	79e2                	ld	s3,56(sp)
    80003e1a:	7a42                	ld	s4,48(sp)
    80003e1c:	7aa2                	ld	s5,40(sp)
    80003e1e:	7b02                	ld	s6,32(sp)
    80003e20:	6be2                	ld	s7,24(sp)
    80003e22:	6c42                	ld	s8,16(sp)
    80003e24:	6ca2                	ld	s9,8(sp)
    80003e26:	6125                	addi	sp,sp,96
    80003e28:	8082                	ret
      iunlock(ip);
    80003e2a:	854e                	mv	a0,s3
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	aa6080e7          	jalr	-1370(ra) # 800038d2 <iunlock>
      return ip;
    80003e34:	bfe9                	j	80003e0e <namex+0x6a>
      iunlockput(ip);
    80003e36:	854e                	mv	a0,s3
    80003e38:	00000097          	auipc	ra,0x0
    80003e3c:	c3a080e7          	jalr	-966(ra) # 80003a72 <iunlockput>
      return 0;
    80003e40:	89e6                	mv	s3,s9
    80003e42:	b7f1                	j	80003e0e <namex+0x6a>
  len = path - s;
    80003e44:	40b48633          	sub	a2,s1,a1
    80003e48:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003e4c:	099c5463          	bge	s8,s9,80003ed4 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003e50:	4639                	li	a2,14
    80003e52:	8552                	mv	a0,s4
    80003e54:	ffffd097          	auipc	ra,0xffffd
    80003e58:	07e080e7          	jalr	126(ra) # 80000ed2 <memmove>
  while(*path == '/')
    80003e5c:	0004c783          	lbu	a5,0(s1)
    80003e60:	01279763          	bne	a5,s2,80003e6e <namex+0xca>
    path++;
    80003e64:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e66:	0004c783          	lbu	a5,0(s1)
    80003e6a:	ff278de3          	beq	a5,s2,80003e64 <namex+0xc0>
    ilock(ip);
    80003e6e:	854e                	mv	a0,s3
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	9a0080e7          	jalr	-1632(ra) # 80003810 <ilock>
    if(ip->type != T_DIR){
    80003e78:	04c99783          	lh	a5,76(s3)
    80003e7c:	f97793e3          	bne	a5,s7,80003e02 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003e80:	000a8563          	beqz	s5,80003e8a <namex+0xe6>
    80003e84:	0004c783          	lbu	a5,0(s1)
    80003e88:	d3cd                	beqz	a5,80003e2a <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e8a:	865a                	mv	a2,s6
    80003e8c:	85d2                	mv	a1,s4
    80003e8e:	854e                	mv	a0,s3
    80003e90:	00000097          	auipc	ra,0x0
    80003e94:	e64080e7          	jalr	-412(ra) # 80003cf4 <dirlookup>
    80003e98:	8caa                	mv	s9,a0
    80003e9a:	dd51                	beqz	a0,80003e36 <namex+0x92>
    iunlockput(ip);
    80003e9c:	854e                	mv	a0,s3
    80003e9e:	00000097          	auipc	ra,0x0
    80003ea2:	bd4080e7          	jalr	-1068(ra) # 80003a72 <iunlockput>
    ip = next;
    80003ea6:	89e6                	mv	s3,s9
  while(*path == '/')
    80003ea8:	0004c783          	lbu	a5,0(s1)
    80003eac:	05279763          	bne	a5,s2,80003efa <namex+0x156>
    path++;
    80003eb0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003eb2:	0004c783          	lbu	a5,0(s1)
    80003eb6:	ff278de3          	beq	a5,s2,80003eb0 <namex+0x10c>
  if(*path == 0)
    80003eba:	c79d                	beqz	a5,80003ee8 <namex+0x144>
    path++;
    80003ebc:	85a6                	mv	a1,s1
  len = path - s;
    80003ebe:	8cda                	mv	s9,s6
    80003ec0:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003ec2:	01278963          	beq	a5,s2,80003ed4 <namex+0x130>
    80003ec6:	dfbd                	beqz	a5,80003e44 <namex+0xa0>
    path++;
    80003ec8:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003eca:	0004c783          	lbu	a5,0(s1)
    80003ece:	ff279ce3          	bne	a5,s2,80003ec6 <namex+0x122>
    80003ed2:	bf8d                	j	80003e44 <namex+0xa0>
    memmove(name, s, len);
    80003ed4:	2601                	sext.w	a2,a2
    80003ed6:	8552                	mv	a0,s4
    80003ed8:	ffffd097          	auipc	ra,0xffffd
    80003edc:	ffa080e7          	jalr	-6(ra) # 80000ed2 <memmove>
    name[len] = 0;
    80003ee0:	9cd2                	add	s9,s9,s4
    80003ee2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ee6:	bf9d                	j	80003e5c <namex+0xb8>
  if(nameiparent){
    80003ee8:	f20a83e3          	beqz	s5,80003e0e <namex+0x6a>
    iput(ip);
    80003eec:	854e                	mv	a0,s3
    80003eee:	00000097          	auipc	ra,0x0
    80003ef2:	adc080e7          	jalr	-1316(ra) # 800039ca <iput>
    return 0;
    80003ef6:	4981                	li	s3,0
    80003ef8:	bf19                	j	80003e0e <namex+0x6a>
  if(*path == 0)
    80003efa:	d7fd                	beqz	a5,80003ee8 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003efc:	0004c783          	lbu	a5,0(s1)
    80003f00:	85a6                	mv	a1,s1
    80003f02:	b7d1                	j	80003ec6 <namex+0x122>

0000000080003f04 <dirlink>:
{
    80003f04:	7139                	addi	sp,sp,-64
    80003f06:	fc06                	sd	ra,56(sp)
    80003f08:	f822                	sd	s0,48(sp)
    80003f0a:	f426                	sd	s1,40(sp)
    80003f0c:	f04a                	sd	s2,32(sp)
    80003f0e:	ec4e                	sd	s3,24(sp)
    80003f10:	e852                	sd	s4,16(sp)
    80003f12:	0080                	addi	s0,sp,64
    80003f14:	892a                	mv	s2,a0
    80003f16:	8a2e                	mv	s4,a1
    80003f18:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f1a:	4601                	li	a2,0
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	dd8080e7          	jalr	-552(ra) # 80003cf4 <dirlookup>
    80003f24:	e93d                	bnez	a0,80003f9a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f26:	05492483          	lw	s1,84(s2)
    80003f2a:	c49d                	beqz	s1,80003f58 <dirlink+0x54>
    80003f2c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f2e:	4741                	li	a4,16
    80003f30:	86a6                	mv	a3,s1
    80003f32:	fc040613          	addi	a2,s0,-64
    80003f36:	4581                	li	a1,0
    80003f38:	854a                	mv	a0,s2
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	b8a080e7          	jalr	-1142(ra) # 80003ac4 <readi>
    80003f42:	47c1                	li	a5,16
    80003f44:	06f51163          	bne	a0,a5,80003fa6 <dirlink+0xa2>
    if(de.inum == 0)
    80003f48:	fc045783          	lhu	a5,-64(s0)
    80003f4c:	c791                	beqz	a5,80003f58 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f4e:	24c1                	addiw	s1,s1,16
    80003f50:	05492783          	lw	a5,84(s2)
    80003f54:	fcf4ede3          	bltu	s1,a5,80003f2e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f58:	4639                	li	a2,14
    80003f5a:	85d2                	mv	a1,s4
    80003f5c:	fc240513          	addi	a0,s0,-62
    80003f60:	ffffd097          	auipc	ra,0xffffd
    80003f64:	04e080e7          	jalr	78(ra) # 80000fae <strncpy>
  de.inum = inum;
    80003f68:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f6c:	4741                	li	a4,16
    80003f6e:	86a6                	mv	a3,s1
    80003f70:	fc040613          	addi	a2,s0,-64
    80003f74:	4581                	li	a1,0
    80003f76:	854a                	mv	a0,s2
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	c44080e7          	jalr	-956(ra) # 80003bbc <writei>
    80003f80:	872a                	mv	a4,a0
    80003f82:	47c1                	li	a5,16
  return 0;
    80003f84:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f86:	02f71863          	bne	a4,a5,80003fb6 <dirlink+0xb2>
}
    80003f8a:	70e2                	ld	ra,56(sp)
    80003f8c:	7442                	ld	s0,48(sp)
    80003f8e:	74a2                	ld	s1,40(sp)
    80003f90:	7902                	ld	s2,32(sp)
    80003f92:	69e2                	ld	s3,24(sp)
    80003f94:	6a42                	ld	s4,16(sp)
    80003f96:	6121                	addi	sp,sp,64
    80003f98:	8082                	ret
    iput(ip);
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	a30080e7          	jalr	-1488(ra) # 800039ca <iput>
    return -1;
    80003fa2:	557d                	li	a0,-1
    80003fa4:	b7dd                	j	80003f8a <dirlink+0x86>
      panic("dirlink read");
    80003fa6:	00005517          	auipc	a0,0x5
    80003faa:	b6250513          	addi	a0,a0,-1182 # 80008b08 <syscalls+0x1d8>
    80003fae:	ffffc097          	auipc	ra,0xffffc
    80003fb2:	5b6080e7          	jalr	1462(ra) # 80000564 <panic>
    panic("dirlink");
    80003fb6:	00005517          	auipc	a0,0x5
    80003fba:	c6250513          	addi	a0,a0,-926 # 80008c18 <syscalls+0x2e8>
    80003fbe:	ffffc097          	auipc	ra,0xffffc
    80003fc2:	5a6080e7          	jalr	1446(ra) # 80000564 <panic>

0000000080003fc6 <namei>:

struct inode*
namei(char *path)
{
    80003fc6:	1101                	addi	sp,sp,-32
    80003fc8:	ec06                	sd	ra,24(sp)
    80003fca:	e822                	sd	s0,16(sp)
    80003fcc:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fce:	fe040613          	addi	a2,s0,-32
    80003fd2:	4581                	li	a1,0
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	dd0080e7          	jalr	-560(ra) # 80003da4 <namex>
}
    80003fdc:	60e2                	ld	ra,24(sp)
    80003fde:	6442                	ld	s0,16(sp)
    80003fe0:	6105                	addi	sp,sp,32
    80003fe2:	8082                	ret

0000000080003fe4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fe4:	1141                	addi	sp,sp,-16
    80003fe6:	e406                	sd	ra,8(sp)
    80003fe8:	e022                	sd	s0,0(sp)
    80003fea:	0800                	addi	s0,sp,16
    80003fec:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fee:	4585                	li	a1,1
    80003ff0:	00000097          	auipc	ra,0x0
    80003ff4:	db4080e7          	jalr	-588(ra) # 80003da4 <namex>
}
    80003ff8:	60a2                	ld	ra,8(sp)
    80003ffa:	6402                	ld	s0,0(sp)
    80003ffc:	0141                	addi	sp,sp,16
    80003ffe:	8082                	ret

0000000080004000 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004000:	1101                	addi	sp,sp,-32
    80004002:	ec06                	sd	ra,24(sp)
    80004004:	e822                	sd	s0,16(sp)
    80004006:	e426                	sd	s1,8(sp)
    80004008:	e04a                	sd	s2,0(sp)
    8000400a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000400c:	00031917          	auipc	s2,0x31
    80004010:	26c90913          	addi	s2,s2,620 # 80035278 <log>
    80004014:	02092583          	lw	a1,32(s2)
    80004018:	03092503          	lw	a0,48(s2)
    8000401c:	fffff097          	auipc	ra,0xfffff
    80004020:	ff2080e7          	jalr	-14(ra) # 8000300e <bread>
    80004024:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004026:	03492683          	lw	a3,52(s2)
    8000402a:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000402c:	02d05763          	blez	a3,8000405a <write_head+0x5a>
    80004030:	00031797          	auipc	a5,0x31
    80004034:	28078793          	addi	a5,a5,640 # 800352b0 <log+0x38>
    80004038:	06450713          	addi	a4,a0,100
    8000403c:	36fd                	addiw	a3,a3,-1
    8000403e:	1682                	slli	a3,a3,0x20
    80004040:	9281                	srli	a3,a3,0x20
    80004042:	068a                	slli	a3,a3,0x2
    80004044:	00031617          	auipc	a2,0x31
    80004048:	27060613          	addi	a2,a2,624 # 800352b4 <log+0x3c>
    8000404c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000404e:	4390                	lw	a2,0(a5)
    80004050:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004052:	0791                	addi	a5,a5,4
    80004054:	0711                	addi	a4,a4,4
    80004056:	fed79ce3          	bne	a5,a3,8000404e <write_head+0x4e>
  }
  bwrite(buf);
    8000405a:	8526                	mv	a0,s1
    8000405c:	fffff097          	auipc	ra,0xfffff
    80004060:	0a4080e7          	jalr	164(ra) # 80003100 <bwrite>
  brelse(buf);
    80004064:	8526                	mv	a0,s1
    80004066:	fffff097          	auipc	ra,0xfffff
    8000406a:	0d8080e7          	jalr	216(ra) # 8000313e <brelse>
}
    8000406e:	60e2                	ld	ra,24(sp)
    80004070:	6442                	ld	s0,16(sp)
    80004072:	64a2                	ld	s1,8(sp)
    80004074:	6902                	ld	s2,0(sp)
    80004076:	6105                	addi	sp,sp,32
    80004078:	8082                	ret

000000008000407a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000407a:	00031797          	auipc	a5,0x31
    8000407e:	2327a783          	lw	a5,562(a5) # 800352ac <log+0x34>
    80004082:	0af05663          	blez	a5,8000412e <install_trans+0xb4>
{
    80004086:	7139                	addi	sp,sp,-64
    80004088:	fc06                	sd	ra,56(sp)
    8000408a:	f822                	sd	s0,48(sp)
    8000408c:	f426                	sd	s1,40(sp)
    8000408e:	f04a                	sd	s2,32(sp)
    80004090:	ec4e                	sd	s3,24(sp)
    80004092:	e852                	sd	s4,16(sp)
    80004094:	e456                	sd	s5,8(sp)
    80004096:	0080                	addi	s0,sp,64
    80004098:	00031a97          	auipc	s5,0x31
    8000409c:	218a8a93          	addi	s5,s5,536 # 800352b0 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040a0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040a2:	00031997          	auipc	s3,0x31
    800040a6:	1d698993          	addi	s3,s3,470 # 80035278 <log>
    800040aa:	0209a583          	lw	a1,32(s3)
    800040ae:	014585bb          	addw	a1,a1,s4
    800040b2:	2585                	addiw	a1,a1,1
    800040b4:	0309a503          	lw	a0,48(s3)
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	f56080e7          	jalr	-170(ra) # 8000300e <bread>
    800040c0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040c2:	000aa583          	lw	a1,0(s5)
    800040c6:	0309a503          	lw	a0,48(s3)
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	f44080e7          	jalr	-188(ra) # 8000300e <bread>
    800040d2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040d4:	40000613          	li	a2,1024
    800040d8:	06090593          	addi	a1,s2,96
    800040dc:	06050513          	addi	a0,a0,96
    800040e0:	ffffd097          	auipc	ra,0xffffd
    800040e4:	df2080e7          	jalr	-526(ra) # 80000ed2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040e8:	8526                	mv	a0,s1
    800040ea:	fffff097          	auipc	ra,0xfffff
    800040ee:	016080e7          	jalr	22(ra) # 80003100 <bwrite>
    bunpin(dbuf);
    800040f2:	8526                	mv	a0,s1
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	124080e7          	jalr	292(ra) # 80003218 <bunpin>
    brelse(lbuf);
    800040fc:	854a                	mv	a0,s2
    800040fe:	fffff097          	auipc	ra,0xfffff
    80004102:	040080e7          	jalr	64(ra) # 8000313e <brelse>
    brelse(dbuf);
    80004106:	8526                	mv	a0,s1
    80004108:	fffff097          	auipc	ra,0xfffff
    8000410c:	036080e7          	jalr	54(ra) # 8000313e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004110:	2a05                	addiw	s4,s4,1
    80004112:	0a91                	addi	s5,s5,4
    80004114:	0349a783          	lw	a5,52(s3)
    80004118:	f8fa49e3          	blt	s4,a5,800040aa <install_trans+0x30>
}
    8000411c:	70e2                	ld	ra,56(sp)
    8000411e:	7442                	ld	s0,48(sp)
    80004120:	74a2                	ld	s1,40(sp)
    80004122:	7902                	ld	s2,32(sp)
    80004124:	69e2                	ld	s3,24(sp)
    80004126:	6a42                	ld	s4,16(sp)
    80004128:	6aa2                	ld	s5,8(sp)
    8000412a:	6121                	addi	sp,sp,64
    8000412c:	8082                	ret
    8000412e:	8082                	ret

0000000080004130 <initlog>:
{
    80004130:	7179                	addi	sp,sp,-48
    80004132:	f406                	sd	ra,40(sp)
    80004134:	f022                	sd	s0,32(sp)
    80004136:	ec26                	sd	s1,24(sp)
    80004138:	e84a                	sd	s2,16(sp)
    8000413a:	e44e                	sd	s3,8(sp)
    8000413c:	1800                	addi	s0,sp,48
    8000413e:	892a                	mv	s2,a0
    80004140:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004142:	00031497          	auipc	s1,0x31
    80004146:	13648493          	addi	s1,s1,310 # 80035278 <log>
    8000414a:	00005597          	auipc	a1,0x5
    8000414e:	9ce58593          	addi	a1,a1,-1586 # 80008b18 <syscalls+0x1e8>
    80004152:	8526                	mv	a0,s1
    80004154:	ffffd097          	auipc	ra,0xffffd
    80004158:	968080e7          	jalr	-1688(ra) # 80000abc <initlock>
  log.start = sb->logstart;
    8000415c:	0149a583          	lw	a1,20(s3)
    80004160:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    80004162:	0109a783          	lw	a5,16(s3)
    80004166:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80004168:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000416c:	854a                	mv	a0,s2
    8000416e:	fffff097          	auipc	ra,0xfffff
    80004172:	ea0080e7          	jalr	-352(ra) # 8000300e <bread>
  log.lh.n = lh->n;
    80004176:	5134                	lw	a3,96(a0)
    80004178:	d8d4                	sw	a3,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000417a:	02d05563          	blez	a3,800041a4 <initlog+0x74>
    8000417e:	06450793          	addi	a5,a0,100
    80004182:	00031717          	auipc	a4,0x31
    80004186:	12e70713          	addi	a4,a4,302 # 800352b0 <log+0x38>
    8000418a:	36fd                	addiw	a3,a3,-1
    8000418c:	1682                	slli	a3,a3,0x20
    8000418e:	9281                	srli	a3,a3,0x20
    80004190:	068a                	slli	a3,a3,0x2
    80004192:	06850613          	addi	a2,a0,104
    80004196:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004198:	4390                	lw	a2,0(a5)
    8000419a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000419c:	0791                	addi	a5,a5,4
    8000419e:	0711                	addi	a4,a4,4
    800041a0:	fed79ce3          	bne	a5,a3,80004198 <initlog+0x68>
  brelse(buf);
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	f9a080e7          	jalr	-102(ra) # 8000313e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	ece080e7          	jalr	-306(ra) # 8000407a <install_trans>
  log.lh.n = 0;
    800041b4:	00031797          	auipc	a5,0x31
    800041b8:	0e07ac23          	sw	zero,248(a5) # 800352ac <log+0x34>
  write_head(); // clear the log
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	e44080e7          	jalr	-444(ra) # 80004000 <write_head>
}
    800041c4:	70a2                	ld	ra,40(sp)
    800041c6:	7402                	ld	s0,32(sp)
    800041c8:	64e2                	ld	s1,24(sp)
    800041ca:	6942                	ld	s2,16(sp)
    800041cc:	69a2                	ld	s3,8(sp)
    800041ce:	6145                	addi	sp,sp,48
    800041d0:	8082                	ret

00000000800041d2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041d2:	1101                	addi	sp,sp,-32
    800041d4:	ec06                	sd	ra,24(sp)
    800041d6:	e822                	sd	s0,16(sp)
    800041d8:	e426                	sd	s1,8(sp)
    800041da:	e04a                	sd	s2,0(sp)
    800041dc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041de:	00031517          	auipc	a0,0x31
    800041e2:	09a50513          	addi	a0,a0,154 # 80035278 <log>
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	9ac080e7          	jalr	-1620(ra) # 80000b92 <acquire>
  while(1){
    if(log.committing){
    800041ee:	00031497          	auipc	s1,0x31
    800041f2:	08a48493          	addi	s1,s1,138 # 80035278 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041f6:	4979                	li	s2,30
    800041f8:	a039                	j	80004206 <begin_op+0x34>
      sleep(&log, &log.lock);
    800041fa:	85a6                	mv	a1,s1
    800041fc:	8526                	mv	a0,s1
    800041fe:	ffffe097          	auipc	ra,0xffffe
    80004202:	15a080e7          	jalr	346(ra) # 80002358 <sleep>
    if(log.committing){
    80004206:	54dc                	lw	a5,44(s1)
    80004208:	fbed                	bnez	a5,800041fa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000420a:	549c                	lw	a5,40(s1)
    8000420c:	0017871b          	addiw	a4,a5,1
    80004210:	0007069b          	sext.w	a3,a4
    80004214:	0027179b          	slliw	a5,a4,0x2
    80004218:	9fb9                	addw	a5,a5,a4
    8000421a:	0017979b          	slliw	a5,a5,0x1
    8000421e:	58d8                	lw	a4,52(s1)
    80004220:	9fb9                	addw	a5,a5,a4
    80004222:	00f95963          	bge	s2,a5,80004234 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004226:	85a6                	mv	a1,s1
    80004228:	8526                	mv	a0,s1
    8000422a:	ffffe097          	auipc	ra,0xffffe
    8000422e:	12e080e7          	jalr	302(ra) # 80002358 <sleep>
    80004232:	bfd1                	j	80004206 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004234:	00031517          	auipc	a0,0x31
    80004238:	04450513          	addi	a0,a0,68 # 80035278 <log>
    8000423c:	d514                	sw	a3,40(a0)
      release(&log.lock);
    8000423e:	ffffd097          	auipc	ra,0xffffd
    80004242:	a24080e7          	jalr	-1500(ra) # 80000c62 <release>
      break;
    }
  }
}
    80004246:	60e2                	ld	ra,24(sp)
    80004248:	6442                	ld	s0,16(sp)
    8000424a:	64a2                	ld	s1,8(sp)
    8000424c:	6902                	ld	s2,0(sp)
    8000424e:	6105                	addi	sp,sp,32
    80004250:	8082                	ret

0000000080004252 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004252:	7139                	addi	sp,sp,-64
    80004254:	fc06                	sd	ra,56(sp)
    80004256:	f822                	sd	s0,48(sp)
    80004258:	f426                	sd	s1,40(sp)
    8000425a:	f04a                	sd	s2,32(sp)
    8000425c:	ec4e                	sd	s3,24(sp)
    8000425e:	e852                	sd	s4,16(sp)
    80004260:	e456                	sd	s5,8(sp)
    80004262:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004264:	00031497          	auipc	s1,0x31
    80004268:	01448493          	addi	s1,s1,20 # 80035278 <log>
    8000426c:	8526                	mv	a0,s1
    8000426e:	ffffd097          	auipc	ra,0xffffd
    80004272:	924080e7          	jalr	-1756(ra) # 80000b92 <acquire>
  log.outstanding -= 1;
    80004276:	549c                	lw	a5,40(s1)
    80004278:	37fd                	addiw	a5,a5,-1
    8000427a:	0007891b          	sext.w	s2,a5
    8000427e:	d49c                	sw	a5,40(s1)
  if(log.committing)
    80004280:	54dc                	lw	a5,44(s1)
    80004282:	e7b9                	bnez	a5,800042d0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004284:	04091e63          	bnez	s2,800042e0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004288:	00031497          	auipc	s1,0x31
    8000428c:	ff048493          	addi	s1,s1,-16 # 80035278 <log>
    80004290:	4785                	li	a5,1
    80004292:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004294:	8526                	mv	a0,s1
    80004296:	ffffd097          	auipc	ra,0xffffd
    8000429a:	9cc080e7          	jalr	-1588(ra) # 80000c62 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    8000429e:	58dc                	lw	a5,52(s1)
    800042a0:	06f04763          	bgtz	a5,8000430e <end_op+0xbc>
    acquire(&log.lock);
    800042a4:	00031497          	auipc	s1,0x31
    800042a8:	fd448493          	addi	s1,s1,-44 # 80035278 <log>
    800042ac:	8526                	mv	a0,s1
    800042ae:	ffffd097          	auipc	ra,0xffffd
    800042b2:	8e4080e7          	jalr	-1820(ra) # 80000b92 <acquire>
    log.committing = 0;
    800042b6:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    800042ba:	8526                	mv	a0,s1
    800042bc:	ffffe097          	auipc	ra,0xffffe
    800042c0:	21c080e7          	jalr	540(ra) # 800024d8 <wakeup>
    release(&log.lock);
    800042c4:	8526                	mv	a0,s1
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	99c080e7          	jalr	-1636(ra) # 80000c62 <release>
}
    800042ce:	a03d                	j	800042fc <end_op+0xaa>
    panic("log.committing");
    800042d0:	00005517          	auipc	a0,0x5
    800042d4:	85050513          	addi	a0,a0,-1968 # 80008b20 <syscalls+0x1f0>
    800042d8:	ffffc097          	auipc	ra,0xffffc
    800042dc:	28c080e7          	jalr	652(ra) # 80000564 <panic>
    wakeup(&log);
    800042e0:	00031497          	auipc	s1,0x31
    800042e4:	f9848493          	addi	s1,s1,-104 # 80035278 <log>
    800042e8:	8526                	mv	a0,s1
    800042ea:	ffffe097          	auipc	ra,0xffffe
    800042ee:	1ee080e7          	jalr	494(ra) # 800024d8 <wakeup>
  release(&log.lock);
    800042f2:	8526                	mv	a0,s1
    800042f4:	ffffd097          	auipc	ra,0xffffd
    800042f8:	96e080e7          	jalr	-1682(ra) # 80000c62 <release>
}
    800042fc:	70e2                	ld	ra,56(sp)
    800042fe:	7442                	ld	s0,48(sp)
    80004300:	74a2                	ld	s1,40(sp)
    80004302:	7902                	ld	s2,32(sp)
    80004304:	69e2                	ld	s3,24(sp)
    80004306:	6a42                	ld	s4,16(sp)
    80004308:	6aa2                	ld	s5,8(sp)
    8000430a:	6121                	addi	sp,sp,64
    8000430c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000430e:	00031a97          	auipc	s5,0x31
    80004312:	fa2a8a93          	addi	s5,s5,-94 # 800352b0 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004316:	00031a17          	auipc	s4,0x31
    8000431a:	f62a0a13          	addi	s4,s4,-158 # 80035278 <log>
    8000431e:	020a2583          	lw	a1,32(s4)
    80004322:	012585bb          	addw	a1,a1,s2
    80004326:	2585                	addiw	a1,a1,1
    80004328:	030a2503          	lw	a0,48(s4)
    8000432c:	fffff097          	auipc	ra,0xfffff
    80004330:	ce2080e7          	jalr	-798(ra) # 8000300e <bread>
    80004334:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004336:	000aa583          	lw	a1,0(s5)
    8000433a:	030a2503          	lw	a0,48(s4)
    8000433e:	fffff097          	auipc	ra,0xfffff
    80004342:	cd0080e7          	jalr	-816(ra) # 8000300e <bread>
    80004346:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004348:	40000613          	li	a2,1024
    8000434c:	06050593          	addi	a1,a0,96
    80004350:	06048513          	addi	a0,s1,96
    80004354:	ffffd097          	auipc	ra,0xffffd
    80004358:	b7e080e7          	jalr	-1154(ra) # 80000ed2 <memmove>
    bwrite(to);  // write the log
    8000435c:	8526                	mv	a0,s1
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	da2080e7          	jalr	-606(ra) # 80003100 <bwrite>
    brelse(from);
    80004366:	854e                	mv	a0,s3
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	dd6080e7          	jalr	-554(ra) # 8000313e <brelse>
    brelse(to);
    80004370:	8526                	mv	a0,s1
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	dcc080e7          	jalr	-564(ra) # 8000313e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000437a:	2905                	addiw	s2,s2,1
    8000437c:	0a91                	addi	s5,s5,4
    8000437e:	034a2783          	lw	a5,52(s4)
    80004382:	f8f94ee3          	blt	s2,a5,8000431e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004386:	00000097          	auipc	ra,0x0
    8000438a:	c7a080e7          	jalr	-902(ra) # 80004000 <write_head>
    install_trans(); // Now install writes to home locations
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	cec080e7          	jalr	-788(ra) # 8000407a <install_trans>
    log.lh.n = 0;
    80004396:	00031797          	auipc	a5,0x31
    8000439a:	f007ab23          	sw	zero,-234(a5) # 800352ac <log+0x34>
    write_head();    // Erase the transaction from the log
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	c62080e7          	jalr	-926(ra) # 80004000 <write_head>
    800043a6:	bdfd                	j	800042a4 <end_op+0x52>

00000000800043a8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043a8:	1101                	addi	sp,sp,-32
    800043aa:	ec06                	sd	ra,24(sp)
    800043ac:	e822                	sd	s0,16(sp)
    800043ae:	e426                	sd	s1,8(sp)
    800043b0:	e04a                	sd	s2,0(sp)
    800043b2:	1000                	addi	s0,sp,32
    800043b4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043b6:	00031917          	auipc	s2,0x31
    800043ba:	ec290913          	addi	s2,s2,-318 # 80035278 <log>
    800043be:	854a                	mv	a0,s2
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	7d2080e7          	jalr	2002(ra) # 80000b92 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800043c8:	03492603          	lw	a2,52(s2)
    800043cc:	47f5                	li	a5,29
    800043ce:	06c7c563          	blt	a5,a2,80004438 <log_write+0x90>
    800043d2:	00031797          	auipc	a5,0x31
    800043d6:	eca7a783          	lw	a5,-310(a5) # 8003529c <log+0x24>
    800043da:	37fd                	addiw	a5,a5,-1
    800043dc:	04f65e63          	bge	a2,a5,80004438 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043e0:	00031797          	auipc	a5,0x31
    800043e4:	ec07a783          	lw	a5,-320(a5) # 800352a0 <log+0x28>
    800043e8:	06f05063          	blez	a5,80004448 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043ec:	4781                	li	a5,0
    800043ee:	06c05563          	blez	a2,80004458 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043f2:	44cc                	lw	a1,12(s1)
    800043f4:	00031717          	auipc	a4,0x31
    800043f8:	ebc70713          	addi	a4,a4,-324 # 800352b0 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    800043fc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043fe:	4314                	lw	a3,0(a4)
    80004400:	04b68c63          	beq	a3,a1,80004458 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004404:	2785                	addiw	a5,a5,1
    80004406:	0711                	addi	a4,a4,4
    80004408:	fef61be3          	bne	a2,a5,800043fe <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000440c:	0631                	addi	a2,a2,12
    8000440e:	060a                	slli	a2,a2,0x2
    80004410:	00031797          	auipc	a5,0x31
    80004414:	e6878793          	addi	a5,a5,-408 # 80035278 <log>
    80004418:	963e                	add	a2,a2,a5
    8000441a:	44dc                	lw	a5,12(s1)
    8000441c:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000441e:	8526                	mv	a0,s1
    80004420:	fffff097          	auipc	ra,0xfffff
    80004424:	dbc080e7          	jalr	-580(ra) # 800031dc <bpin>
    log.lh.n++;
    80004428:	00031717          	auipc	a4,0x31
    8000442c:	e5070713          	addi	a4,a4,-432 # 80035278 <log>
    80004430:	5b5c                	lw	a5,52(a4)
    80004432:	2785                	addiw	a5,a5,1
    80004434:	db5c                	sw	a5,52(a4)
    80004436:	a835                	j	80004472 <log_write+0xca>
    panic("too big a transaction");
    80004438:	00004517          	auipc	a0,0x4
    8000443c:	6f850513          	addi	a0,a0,1784 # 80008b30 <syscalls+0x200>
    80004440:	ffffc097          	auipc	ra,0xffffc
    80004444:	124080e7          	jalr	292(ra) # 80000564 <panic>
    panic("log_write outside of trans");
    80004448:	00004517          	auipc	a0,0x4
    8000444c:	70050513          	addi	a0,a0,1792 # 80008b48 <syscalls+0x218>
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	114080e7          	jalr	276(ra) # 80000564 <panic>
  log.lh.block[i] = b->blockno;
    80004458:	00c78713          	addi	a4,a5,12
    8000445c:	00271693          	slli	a3,a4,0x2
    80004460:	00031717          	auipc	a4,0x31
    80004464:	e1870713          	addi	a4,a4,-488 # 80035278 <log>
    80004468:	9736                	add	a4,a4,a3
    8000446a:	44d4                	lw	a3,12(s1)
    8000446c:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000446e:	faf608e3          	beq	a2,a5,8000441e <log_write+0x76>
  }
  release(&log.lock);
    80004472:	00031517          	auipc	a0,0x31
    80004476:	e0650513          	addi	a0,a0,-506 # 80035278 <log>
    8000447a:	ffffc097          	auipc	ra,0xffffc
    8000447e:	7e8080e7          	jalr	2024(ra) # 80000c62 <release>
}
    80004482:	60e2                	ld	ra,24(sp)
    80004484:	6442                	ld	s0,16(sp)
    80004486:	64a2                	ld	s1,8(sp)
    80004488:	6902                	ld	s2,0(sp)
    8000448a:	6105                	addi	sp,sp,32
    8000448c:	8082                	ret

000000008000448e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	e426                	sd	s1,8(sp)
    80004496:	e04a                	sd	s2,0(sp)
    80004498:	1000                	addi	s0,sp,32
    8000449a:	84aa                	mv	s1,a0
    8000449c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000449e:	00004597          	auipc	a1,0x4
    800044a2:	6ca58593          	addi	a1,a1,1738 # 80008b68 <syscalls+0x238>
    800044a6:	0521                	addi	a0,a0,8
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	614080e7          	jalr	1556(ra) # 80000abc <initlock>
  lk->name = name;
    800044b0:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    800044b4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044b8:	0204a823          	sw	zero,48(s1)
}
    800044bc:	60e2                	ld	ra,24(sp)
    800044be:	6442                	ld	s0,16(sp)
    800044c0:	64a2                	ld	s1,8(sp)
    800044c2:	6902                	ld	s2,0(sp)
    800044c4:	6105                	addi	sp,sp,32
    800044c6:	8082                	ret

00000000800044c8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044c8:	1101                	addi	sp,sp,-32
    800044ca:	ec06                	sd	ra,24(sp)
    800044cc:	e822                	sd	s0,16(sp)
    800044ce:	e426                	sd	s1,8(sp)
    800044d0:	e04a                	sd	s2,0(sp)
    800044d2:	1000                	addi	s0,sp,32
    800044d4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044d6:	00850913          	addi	s2,a0,8
    800044da:	854a                	mv	a0,s2
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	6b6080e7          	jalr	1718(ra) # 80000b92 <acquire>
  while (lk->locked) {
    800044e4:	409c                	lw	a5,0(s1)
    800044e6:	cb89                	beqz	a5,800044f8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044e8:	85ca                	mv	a1,s2
    800044ea:	8526                	mv	a0,s1
    800044ec:	ffffe097          	auipc	ra,0xffffe
    800044f0:	e6c080e7          	jalr	-404(ra) # 80002358 <sleep>
  while (lk->locked) {
    800044f4:	409c                	lw	a5,0(s1)
    800044f6:	fbed                	bnez	a5,800044e8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044f8:	4785                	li	a5,1
    800044fa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	64c080e7          	jalr	1612(ra) # 80001b48 <myproc>
    80004504:	413c                	lw	a5,64(a0)
    80004506:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004508:	854a                	mv	a0,s2
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	758080e7          	jalr	1880(ra) # 80000c62 <release>
}
    80004512:	60e2                	ld	ra,24(sp)
    80004514:	6442                	ld	s0,16(sp)
    80004516:	64a2                	ld	s1,8(sp)
    80004518:	6902                	ld	s2,0(sp)
    8000451a:	6105                	addi	sp,sp,32
    8000451c:	8082                	ret

000000008000451e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	e426                	sd	s1,8(sp)
    80004526:	e04a                	sd	s2,0(sp)
    80004528:	1000                	addi	s0,sp,32
    8000452a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000452c:	00850913          	addi	s2,a0,8
    80004530:	854a                	mv	a0,s2
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	660080e7          	jalr	1632(ra) # 80000b92 <acquire>
  lk->locked = 0;
    8000453a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000453e:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    80004542:	8526                	mv	a0,s1
    80004544:	ffffe097          	auipc	ra,0xffffe
    80004548:	f94080e7          	jalr	-108(ra) # 800024d8 <wakeup>
  release(&lk->lk);
    8000454c:	854a                	mv	a0,s2
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	714080e7          	jalr	1812(ra) # 80000c62 <release>
}
    80004556:	60e2                	ld	ra,24(sp)
    80004558:	6442                	ld	s0,16(sp)
    8000455a:	64a2                	ld	s1,8(sp)
    8000455c:	6902                	ld	s2,0(sp)
    8000455e:	6105                	addi	sp,sp,32
    80004560:	8082                	ret

0000000080004562 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004562:	7179                	addi	sp,sp,-48
    80004564:	f406                	sd	ra,40(sp)
    80004566:	f022                	sd	s0,32(sp)
    80004568:	ec26                	sd	s1,24(sp)
    8000456a:	e84a                	sd	s2,16(sp)
    8000456c:	e44e                	sd	s3,8(sp)
    8000456e:	1800                	addi	s0,sp,48
    80004570:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004572:	00850913          	addi	s2,a0,8
    80004576:	854a                	mv	a0,s2
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	61a080e7          	jalr	1562(ra) # 80000b92 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004580:	409c                	lw	a5,0(s1)
    80004582:	ef99                	bnez	a5,800045a0 <holdingsleep+0x3e>
    80004584:	4481                	li	s1,0
  release(&lk->lk);
    80004586:	854a                	mv	a0,s2
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	6da080e7          	jalr	1754(ra) # 80000c62 <release>
  return r;
}
    80004590:	8526                	mv	a0,s1
    80004592:	70a2                	ld	ra,40(sp)
    80004594:	7402                	ld	s0,32(sp)
    80004596:	64e2                	ld	s1,24(sp)
    80004598:	6942                	ld	s2,16(sp)
    8000459a:	69a2                	ld	s3,8(sp)
    8000459c:	6145                	addi	sp,sp,48
    8000459e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045a0:	0304a983          	lw	s3,48(s1)
    800045a4:	ffffd097          	auipc	ra,0xffffd
    800045a8:	5a4080e7          	jalr	1444(ra) # 80001b48 <myproc>
    800045ac:	4124                	lw	s1,64(a0)
    800045ae:	413484b3          	sub	s1,s1,s3
    800045b2:	0014b493          	seqz	s1,s1
    800045b6:	bfc1                	j	80004586 <holdingsleep+0x24>

00000000800045b8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045b8:	1141                	addi	sp,sp,-16
    800045ba:	e406                	sd	ra,8(sp)
    800045bc:	e022                	sd	s0,0(sp)
    800045be:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045c0:	00004597          	auipc	a1,0x4
    800045c4:	5b858593          	addi	a1,a1,1464 # 80008b78 <syscalls+0x248>
    800045c8:	00031517          	auipc	a0,0x31
    800045cc:	e0050513          	addi	a0,a0,-512 # 800353c8 <ftable>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	4ec080e7          	jalr	1260(ra) # 80000abc <initlock>
}
    800045d8:	60a2                	ld	ra,8(sp)
    800045da:	6402                	ld	s0,0(sp)
    800045dc:	0141                	addi	sp,sp,16
    800045de:	8082                	ret

00000000800045e0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045e0:	1101                	addi	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	e426                	sd	s1,8(sp)
    800045e8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045ea:	00031517          	auipc	a0,0x31
    800045ee:	dde50513          	addi	a0,a0,-546 # 800353c8 <ftable>
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	5a0080e7          	jalr	1440(ra) # 80000b92 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045fa:	00031497          	auipc	s1,0x31
    800045fe:	dee48493          	addi	s1,s1,-530 # 800353e8 <ftable+0x20>
    80004602:	00032717          	auipc	a4,0x32
    80004606:	d8670713          	addi	a4,a4,-634 # 80036388 <disk>
    if(f->ref == 0){
    8000460a:	40dc                	lw	a5,4(s1)
    8000460c:	cf99                	beqz	a5,8000462a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000460e:	02848493          	addi	s1,s1,40
    80004612:	fee49ce3          	bne	s1,a4,8000460a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004616:	00031517          	auipc	a0,0x31
    8000461a:	db250513          	addi	a0,a0,-590 # 800353c8 <ftable>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	644080e7          	jalr	1604(ra) # 80000c62 <release>
  return 0;
    80004626:	4481                	li	s1,0
    80004628:	a819                	j	8000463e <filealloc+0x5e>
      f->ref = 1;
    8000462a:	4785                	li	a5,1
    8000462c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000462e:	00031517          	auipc	a0,0x31
    80004632:	d9a50513          	addi	a0,a0,-614 # 800353c8 <ftable>
    80004636:	ffffc097          	auipc	ra,0xffffc
    8000463a:	62c080e7          	jalr	1580(ra) # 80000c62 <release>
}
    8000463e:	8526                	mv	a0,s1
    80004640:	60e2                	ld	ra,24(sp)
    80004642:	6442                	ld	s0,16(sp)
    80004644:	64a2                	ld	s1,8(sp)
    80004646:	6105                	addi	sp,sp,32
    80004648:	8082                	ret

000000008000464a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000464a:	1101                	addi	sp,sp,-32
    8000464c:	ec06                	sd	ra,24(sp)
    8000464e:	e822                	sd	s0,16(sp)
    80004650:	e426                	sd	s1,8(sp)
    80004652:	1000                	addi	s0,sp,32
    80004654:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004656:	00031517          	auipc	a0,0x31
    8000465a:	d7250513          	addi	a0,a0,-654 # 800353c8 <ftable>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	534080e7          	jalr	1332(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    80004666:	40dc                	lw	a5,4(s1)
    80004668:	02f05263          	blez	a5,8000468c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000466c:	2785                	addiw	a5,a5,1
    8000466e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004670:	00031517          	auipc	a0,0x31
    80004674:	d5850513          	addi	a0,a0,-680 # 800353c8 <ftable>
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	5ea080e7          	jalr	1514(ra) # 80000c62 <release>
  return f;
}
    80004680:	8526                	mv	a0,s1
    80004682:	60e2                	ld	ra,24(sp)
    80004684:	6442                	ld	s0,16(sp)
    80004686:	64a2                	ld	s1,8(sp)
    80004688:	6105                	addi	sp,sp,32
    8000468a:	8082                	ret
    panic("filedup");
    8000468c:	00004517          	auipc	a0,0x4
    80004690:	4f450513          	addi	a0,a0,1268 # 80008b80 <syscalls+0x250>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	ed0080e7          	jalr	-304(ra) # 80000564 <panic>

000000008000469c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000469c:	7139                	addi	sp,sp,-64
    8000469e:	fc06                	sd	ra,56(sp)
    800046a0:	f822                	sd	s0,48(sp)
    800046a2:	f426                	sd	s1,40(sp)
    800046a4:	f04a                	sd	s2,32(sp)
    800046a6:	ec4e                	sd	s3,24(sp)
    800046a8:	e852                	sd	s4,16(sp)
    800046aa:	e456                	sd	s5,8(sp)
    800046ac:	0080                	addi	s0,sp,64
    800046ae:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046b0:	00031517          	auipc	a0,0x31
    800046b4:	d1850513          	addi	a0,a0,-744 # 800353c8 <ftable>
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	4da080e7          	jalr	1242(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    800046c0:	40dc                	lw	a5,4(s1)
    800046c2:	06f05163          	blez	a5,80004724 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046c6:	37fd                	addiw	a5,a5,-1
    800046c8:	0007871b          	sext.w	a4,a5
    800046cc:	c0dc                	sw	a5,4(s1)
    800046ce:	06e04363          	bgtz	a4,80004734 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046d2:	0004a903          	lw	s2,0(s1)
    800046d6:	0094ca83          	lbu	s5,9(s1)
    800046da:	0104ba03          	ld	s4,16(s1)
    800046de:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046e2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046e6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046ea:	00031517          	auipc	a0,0x31
    800046ee:	cde50513          	addi	a0,a0,-802 # 800353c8 <ftable>
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	570080e7          	jalr	1392(ra) # 80000c62 <release>

  if(ff.type == FD_PIPE){
    800046fa:	4785                	li	a5,1
    800046fc:	04f90d63          	beq	s2,a5,80004756 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004700:	3979                	addiw	s2,s2,-2
    80004702:	4785                	li	a5,1
    80004704:	0527e063          	bltu	a5,s2,80004744 <fileclose+0xa8>
    begin_op();
    80004708:	00000097          	auipc	ra,0x0
    8000470c:	aca080e7          	jalr	-1334(ra) # 800041d2 <begin_op>
    iput(ff.ip);
    80004710:	854e                	mv	a0,s3
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	2b8080e7          	jalr	696(ra) # 800039ca <iput>
    end_op();
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	b38080e7          	jalr	-1224(ra) # 80004252 <end_op>
    80004722:	a00d                	j	80004744 <fileclose+0xa8>
    panic("fileclose");
    80004724:	00004517          	auipc	a0,0x4
    80004728:	46450513          	addi	a0,a0,1124 # 80008b88 <syscalls+0x258>
    8000472c:	ffffc097          	auipc	ra,0xffffc
    80004730:	e38080e7          	jalr	-456(ra) # 80000564 <panic>
    release(&ftable.lock);
    80004734:	00031517          	auipc	a0,0x31
    80004738:	c9450513          	addi	a0,a0,-876 # 800353c8 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	526080e7          	jalr	1318(ra) # 80000c62 <release>
  }
}
    80004744:	70e2                	ld	ra,56(sp)
    80004746:	7442                	ld	s0,48(sp)
    80004748:	74a2                	ld	s1,40(sp)
    8000474a:	7902                	ld	s2,32(sp)
    8000474c:	69e2                	ld	s3,24(sp)
    8000474e:	6a42                	ld	s4,16(sp)
    80004750:	6aa2                	ld	s5,8(sp)
    80004752:	6121                	addi	sp,sp,64
    80004754:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004756:	85d6                	mv	a1,s5
    80004758:	8552                	mv	a0,s4
    8000475a:	00000097          	auipc	ra,0x0
    8000475e:	354080e7          	jalr	852(ra) # 80004aae <pipeclose>
    80004762:	b7cd                	j	80004744 <fileclose+0xa8>

0000000080004764 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004764:	715d                	addi	sp,sp,-80
    80004766:	e486                	sd	ra,72(sp)
    80004768:	e0a2                	sd	s0,64(sp)
    8000476a:	fc26                	sd	s1,56(sp)
    8000476c:	f84a                	sd	s2,48(sp)
    8000476e:	f44e                	sd	s3,40(sp)
    80004770:	0880                	addi	s0,sp,80
    80004772:	84aa                	mv	s1,a0
    80004774:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004776:	ffffd097          	auipc	ra,0xffffd
    8000477a:	3d2080e7          	jalr	978(ra) # 80001b48 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000477e:	409c                	lw	a5,0(s1)
    80004780:	37f9                	addiw	a5,a5,-2
    80004782:	4705                	li	a4,1
    80004784:	04f76763          	bltu	a4,a5,800047d2 <filestat+0x6e>
    80004788:	892a                	mv	s2,a0
    ilock(f->ip);
    8000478a:	6c88                	ld	a0,24(s1)
    8000478c:	fffff097          	auipc	ra,0xfffff
    80004790:	084080e7          	jalr	132(ra) # 80003810 <ilock>
    stati(f->ip, &st);
    80004794:	fb840593          	addi	a1,s0,-72
    80004798:	6c88                	ld	a0,24(s1)
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	300080e7          	jalr	768(ra) # 80003a9a <stati>
    iunlock(f->ip);
    800047a2:	6c88                	ld	a0,24(s1)
    800047a4:	fffff097          	auipc	ra,0xfffff
    800047a8:	12e080e7          	jalr	302(ra) # 800038d2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047ac:	46e1                	li	a3,24
    800047ae:	fb840613          	addi	a2,s0,-72
    800047b2:	85ce                	mv	a1,s3
    800047b4:	05893503          	ld	a0,88(s2)
    800047b8:	ffffd097          	auipc	ra,0xffffd
    800047bc:	048080e7          	jalr	72(ra) # 80001800 <copyout>
    800047c0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047c4:	60a6                	ld	ra,72(sp)
    800047c6:	6406                	ld	s0,64(sp)
    800047c8:	74e2                	ld	s1,56(sp)
    800047ca:	7942                	ld	s2,48(sp)
    800047cc:	79a2                	ld	s3,40(sp)
    800047ce:	6161                	addi	sp,sp,80
    800047d0:	8082                	ret
  return -1;
    800047d2:	557d                	li	a0,-1
    800047d4:	bfc5                	j	800047c4 <filestat+0x60>

00000000800047d6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047d6:	7179                	addi	sp,sp,-48
    800047d8:	f406                	sd	ra,40(sp)
    800047da:	f022                	sd	s0,32(sp)
    800047dc:	ec26                	sd	s1,24(sp)
    800047de:	e84a                	sd	s2,16(sp)
    800047e0:	e44e                	sd	s3,8(sp)
    800047e2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047e4:	00854783          	lbu	a5,8(a0)
    800047e8:	c7c5                	beqz	a5,80004890 <fileread+0xba>
    800047ea:	84aa                	mv	s1,a0
    800047ec:	89ae                	mv	s3,a1
    800047ee:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047f0:	411c                	lw	a5,0(a0)
    800047f2:	4705                	li	a4,1
    800047f4:	04e78963          	beq	a5,a4,80004846 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047f8:	470d                	li	a4,3
    800047fa:	04e78d63          	beq	a5,a4,80004854 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800047fe:	4709                	li	a4,2
    80004800:	08e79063          	bne	a5,a4,80004880 <fileread+0xaa>
    ilock(f->ip);
    80004804:	6d08                	ld	a0,24(a0)
    80004806:	fffff097          	auipc	ra,0xfffff
    8000480a:	00a080e7          	jalr	10(ra) # 80003810 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000480e:	874a                	mv	a4,s2
    80004810:	5094                	lw	a3,32(s1)
    80004812:	864e                	mv	a2,s3
    80004814:	4585                	li	a1,1
    80004816:	6c88                	ld	a0,24(s1)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	2ac080e7          	jalr	684(ra) # 80003ac4 <readi>
    80004820:	892a                	mv	s2,a0
    80004822:	00a05563          	blez	a0,8000482c <fileread+0x56>
      f->off += r;
    80004826:	509c                	lw	a5,32(s1)
    80004828:	9fa9                	addw	a5,a5,a0
    8000482a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000482c:	6c88                	ld	a0,24(s1)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	0a4080e7          	jalr	164(ra) # 800038d2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004836:	854a                	mv	a0,s2
    80004838:	70a2                	ld	ra,40(sp)
    8000483a:	7402                	ld	s0,32(sp)
    8000483c:	64e2                	ld	s1,24(sp)
    8000483e:	6942                	ld	s2,16(sp)
    80004840:	69a2                	ld	s3,8(sp)
    80004842:	6145                	addi	sp,sp,48
    80004844:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004846:	6908                	ld	a0,16(a0)
    80004848:	00000097          	auipc	ra,0x0
    8000484c:	3c8080e7          	jalr	968(ra) # 80004c10 <piperead>
    80004850:	892a                	mv	s2,a0
    80004852:	b7d5                	j	80004836 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004854:	02451783          	lh	a5,36(a0)
    80004858:	03079693          	slli	a3,a5,0x30
    8000485c:	92c1                	srli	a3,a3,0x30
    8000485e:	4725                	li	a4,9
    80004860:	02d76a63          	bltu	a4,a3,80004894 <fileread+0xbe>
    80004864:	0792                	slli	a5,a5,0x4
    80004866:	00031717          	auipc	a4,0x31
    8000486a:	ac270713          	addi	a4,a4,-1342 # 80035328 <devsw>
    8000486e:	97ba                	add	a5,a5,a4
    80004870:	639c                	ld	a5,0(a5)
    80004872:	c39d                	beqz	a5,80004898 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004874:	86b2                	mv	a3,a2
    80004876:	862e                	mv	a2,a1
    80004878:	4585                	li	a1,1
    8000487a:	9782                	jalr	a5
    8000487c:	892a                	mv	s2,a0
    8000487e:	bf65                	j	80004836 <fileread+0x60>
    panic("fileread");
    80004880:	00004517          	auipc	a0,0x4
    80004884:	31850513          	addi	a0,a0,792 # 80008b98 <syscalls+0x268>
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	cdc080e7          	jalr	-804(ra) # 80000564 <panic>
    return -1;
    80004890:	597d                	li	s2,-1
    80004892:	b755                	j	80004836 <fileread+0x60>
      return -1;
    80004894:	597d                	li	s2,-1
    80004896:	b745                	j	80004836 <fileread+0x60>
    80004898:	597d                	li	s2,-1
    8000489a:	bf71                	j	80004836 <fileread+0x60>

000000008000489c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000489c:	715d                	addi	sp,sp,-80
    8000489e:	e486                	sd	ra,72(sp)
    800048a0:	e0a2                	sd	s0,64(sp)
    800048a2:	fc26                	sd	s1,56(sp)
    800048a4:	f84a                	sd	s2,48(sp)
    800048a6:	f44e                	sd	s3,40(sp)
    800048a8:	f052                	sd	s4,32(sp)
    800048aa:	ec56                	sd	s5,24(sp)
    800048ac:	e85a                	sd	s6,16(sp)
    800048ae:	e45e                	sd	s7,8(sp)
    800048b0:	e062                	sd	s8,0(sp)
    800048b2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800048b4:	00954783          	lbu	a5,9(a0)
    800048b8:	10078863          	beqz	a5,800049c8 <filewrite+0x12c>
    800048bc:	892a                	mv	s2,a0
    800048be:	8aae                	mv	s5,a1
    800048c0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048c2:	411c                	lw	a5,0(a0)
    800048c4:	4705                	li	a4,1
    800048c6:	02e78263          	beq	a5,a4,800048ea <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048ca:	470d                	li	a4,3
    800048cc:	02e78663          	beq	a5,a4,800048f8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800048d0:	4709                	li	a4,2
    800048d2:	0ee79363          	bne	a5,a4,800049b8 <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048d6:	0ac05f63          	blez	a2,80004994 <filewrite+0xf8>
    int i = 0;
    800048da:	4981                	li	s3,0
    800048dc:	6b05                	lui	s6,0x1
    800048de:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048e2:	6b85                	lui	s7,0x1
    800048e4:	c00b8b9b          	addiw	s7,s7,-1024
    800048e8:	a871                	j	80004984 <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    800048ea:	6908                	ld	a0,16(a0)
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	232080e7          	jalr	562(ra) # 80004b1e <pipewrite>
    800048f4:	8a2a                	mv	s4,a0
    800048f6:	a055                	j	8000499a <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048f8:	02451783          	lh	a5,36(a0)
    800048fc:	03079693          	slli	a3,a5,0x30
    80004900:	92c1                	srli	a3,a3,0x30
    80004902:	4725                	li	a4,9
    80004904:	0cd76463          	bltu	a4,a3,800049cc <filewrite+0x130>
    80004908:	0792                	slli	a5,a5,0x4
    8000490a:	00031717          	auipc	a4,0x31
    8000490e:	a1e70713          	addi	a4,a4,-1506 # 80035328 <devsw>
    80004912:	97ba                	add	a5,a5,a4
    80004914:	679c                	ld	a5,8(a5)
    80004916:	cfcd                	beqz	a5,800049d0 <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004918:	86b2                	mv	a3,a2
    8000491a:	862e                	mv	a2,a1
    8000491c:	4585                	li	a1,1
    8000491e:	9782                	jalr	a5
    80004920:	8a2a                	mv	s4,a0
    80004922:	a8a5                	j	8000499a <filewrite+0xfe>
    80004924:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004928:	00000097          	auipc	ra,0x0
    8000492c:	8aa080e7          	jalr	-1878(ra) # 800041d2 <begin_op>
      ilock(f->ip);
    80004930:	01893503          	ld	a0,24(s2)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	edc080e7          	jalr	-292(ra) # 80003810 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000493c:	8762                	mv	a4,s8
    8000493e:	02092683          	lw	a3,32(s2)
    80004942:	01598633          	add	a2,s3,s5
    80004946:	4585                	li	a1,1
    80004948:	01893503          	ld	a0,24(s2)
    8000494c:	fffff097          	auipc	ra,0xfffff
    80004950:	270080e7          	jalr	624(ra) # 80003bbc <writei>
    80004954:	84aa                	mv	s1,a0
    80004956:	00a05763          	blez	a0,80004964 <filewrite+0xc8>
        f->off += r;
    8000495a:	02092783          	lw	a5,32(s2)
    8000495e:	9fa9                	addw	a5,a5,a0
    80004960:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004964:	01893503          	ld	a0,24(s2)
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	f6a080e7          	jalr	-150(ra) # 800038d2 <iunlock>
      end_op();
    80004970:	00000097          	auipc	ra,0x0
    80004974:	8e2080e7          	jalr	-1822(ra) # 80004252 <end_op>

      if(r != n1){
    80004978:	009c1f63          	bne	s8,s1,80004996 <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    8000497c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004980:	0149db63          	bge	s3,s4,80004996 <filewrite+0xfa>
      int n1 = n - i;
    80004984:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004988:	84be                	mv	s1,a5
    8000498a:	2781                	sext.w	a5,a5
    8000498c:	f8fb5ce3          	bge	s6,a5,80004924 <filewrite+0x88>
    80004990:	84de                	mv	s1,s7
    80004992:	bf49                	j	80004924 <filewrite+0x88>
    int i = 0;
    80004994:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004996:	013a1f63          	bne	s4,s3,800049b4 <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000499a:	8552                	mv	a0,s4
    8000499c:	60a6                	ld	ra,72(sp)
    8000499e:	6406                	ld	s0,64(sp)
    800049a0:	74e2                	ld	s1,56(sp)
    800049a2:	7942                	ld	s2,48(sp)
    800049a4:	79a2                	ld	s3,40(sp)
    800049a6:	7a02                	ld	s4,32(sp)
    800049a8:	6ae2                	ld	s5,24(sp)
    800049aa:	6b42                	ld	s6,16(sp)
    800049ac:	6ba2                	ld	s7,8(sp)
    800049ae:	6c02                	ld	s8,0(sp)
    800049b0:	6161                	addi	sp,sp,80
    800049b2:	8082                	ret
    ret = (i == n ? n : -1);
    800049b4:	5a7d                	li	s4,-1
    800049b6:	b7d5                	j	8000499a <filewrite+0xfe>
    panic("filewrite");
    800049b8:	00004517          	auipc	a0,0x4
    800049bc:	1f050513          	addi	a0,a0,496 # 80008ba8 <syscalls+0x278>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	ba4080e7          	jalr	-1116(ra) # 80000564 <panic>
    return -1;
    800049c8:	5a7d                	li	s4,-1
    800049ca:	bfc1                	j	8000499a <filewrite+0xfe>
      return -1;
    800049cc:	5a7d                	li	s4,-1
    800049ce:	b7f1                	j	8000499a <filewrite+0xfe>
    800049d0:	5a7d                	li	s4,-1
    800049d2:	b7e1                	j	8000499a <filewrite+0xfe>

00000000800049d4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049d4:	7179                	addi	sp,sp,-48
    800049d6:	f406                	sd	ra,40(sp)
    800049d8:	f022                	sd	s0,32(sp)
    800049da:	ec26                	sd	s1,24(sp)
    800049dc:	e84a                	sd	s2,16(sp)
    800049de:	e44e                	sd	s3,8(sp)
    800049e0:	e052                	sd	s4,0(sp)
    800049e2:	1800                	addi	s0,sp,48
    800049e4:	84aa                	mv	s1,a0
    800049e6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049e8:	0005b023          	sd	zero,0(a1)
    800049ec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049f0:	00000097          	auipc	ra,0x0
    800049f4:	bf0080e7          	jalr	-1040(ra) # 800045e0 <filealloc>
    800049f8:	e088                	sd	a0,0(s1)
    800049fa:	c551                	beqz	a0,80004a86 <pipealloc+0xb2>
    800049fc:	00000097          	auipc	ra,0x0
    80004a00:	be4080e7          	jalr	-1052(ra) # 800045e0 <filealloc>
    80004a04:	00aa3023          	sd	a0,0(s4)
    80004a08:	c92d                	beqz	a0,80004a7a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	038080e7          	jalr	56(ra) # 80000a42 <kalloc>
    80004a12:	892a                	mv	s2,a0
    80004a14:	c125                	beqz	a0,80004a74 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a16:	4985                	li	s3,1
    80004a18:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004a1c:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004a20:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004a24:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004a28:	00004597          	auipc	a1,0x4
    80004a2c:	19058593          	addi	a1,a1,400 # 80008bb8 <syscalls+0x288>
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	08c080e7          	jalr	140(ra) # 80000abc <initlock>
  (*f0)->type = FD_PIPE;
    80004a38:	609c                	ld	a5,0(s1)
    80004a3a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a3e:	609c                	ld	a5,0(s1)
    80004a40:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a44:	609c                	ld	a5,0(s1)
    80004a46:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a4a:	609c                	ld	a5,0(s1)
    80004a4c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a50:	000a3783          	ld	a5,0(s4)
    80004a54:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a58:	000a3783          	ld	a5,0(s4)
    80004a5c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a60:	000a3783          	ld	a5,0(s4)
    80004a64:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a68:	000a3783          	ld	a5,0(s4)
    80004a6c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a70:	4501                	li	a0,0
    80004a72:	a025                	j	80004a9a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a74:	6088                	ld	a0,0(s1)
    80004a76:	e501                	bnez	a0,80004a7e <pipealloc+0xaa>
    80004a78:	a039                	j	80004a86 <pipealloc+0xb2>
    80004a7a:	6088                	ld	a0,0(s1)
    80004a7c:	c51d                	beqz	a0,80004aaa <pipealloc+0xd6>
    fileclose(*f0);
    80004a7e:	00000097          	auipc	ra,0x0
    80004a82:	c1e080e7          	jalr	-994(ra) # 8000469c <fileclose>
  if(*f1)
    80004a86:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a8a:	557d                	li	a0,-1
  if(*f1)
    80004a8c:	c799                	beqz	a5,80004a9a <pipealloc+0xc6>
    fileclose(*f1);
    80004a8e:	853e                	mv	a0,a5
    80004a90:	00000097          	auipc	ra,0x0
    80004a94:	c0c080e7          	jalr	-1012(ra) # 8000469c <fileclose>
  return -1;
    80004a98:	557d                	li	a0,-1
}
    80004a9a:	70a2                	ld	ra,40(sp)
    80004a9c:	7402                	ld	s0,32(sp)
    80004a9e:	64e2                	ld	s1,24(sp)
    80004aa0:	6942                	ld	s2,16(sp)
    80004aa2:	69a2                	ld	s3,8(sp)
    80004aa4:	6a02                	ld	s4,0(sp)
    80004aa6:	6145                	addi	sp,sp,48
    80004aa8:	8082                	ret
  return -1;
    80004aaa:	557d                	li	a0,-1
    80004aac:	b7fd                	j	80004a9a <pipealloc+0xc6>

0000000080004aae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004aae:	1101                	addi	sp,sp,-32
    80004ab0:	ec06                	sd	ra,24(sp)
    80004ab2:	e822                	sd	s0,16(sp)
    80004ab4:	e426                	sd	s1,8(sp)
    80004ab6:	e04a                	sd	s2,0(sp)
    80004ab8:	1000                	addi	s0,sp,32
    80004aba:	84aa                	mv	s1,a0
    80004abc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	0d4080e7          	jalr	212(ra) # 80000b92 <acquire>
  if(writable){
    80004ac6:	02090d63          	beqz	s2,80004b00 <pipeclose+0x52>
    pi->writeopen = 0;
    80004aca:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004ace:	22048513          	addi	a0,s1,544
    80004ad2:	ffffe097          	auipc	ra,0xffffe
    80004ad6:	a06080e7          	jalr	-1530(ra) # 800024d8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ada:	2284b783          	ld	a5,552(s1)
    80004ade:	eb95                	bnez	a5,80004b12 <pipeclose+0x64>
    release(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	180080e7          	jalr	384(ra) # 80000c62 <release>
    kfree((char*)pi);
    80004aea:	8526                	mv	a0,s1
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	e50080e7          	jalr	-432(ra) # 8000093c <kfree>
  } else
    release(&pi->lock);
}
    80004af4:	60e2                	ld	ra,24(sp)
    80004af6:	6442                	ld	s0,16(sp)
    80004af8:	64a2                	ld	s1,8(sp)
    80004afa:	6902                	ld	s2,0(sp)
    80004afc:	6105                	addi	sp,sp,32
    80004afe:	8082                	ret
    pi->readopen = 0;
    80004b00:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004b04:	22448513          	addi	a0,s1,548
    80004b08:	ffffe097          	auipc	ra,0xffffe
    80004b0c:	9d0080e7          	jalr	-1584(ra) # 800024d8 <wakeup>
    80004b10:	b7e9                	j	80004ada <pipeclose+0x2c>
    release(&pi->lock);
    80004b12:	8526                	mv	a0,s1
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	14e080e7          	jalr	334(ra) # 80000c62 <release>
}
    80004b1c:	bfe1                	j	80004af4 <pipeclose+0x46>

0000000080004b1e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b1e:	711d                	addi	sp,sp,-96
    80004b20:	ec86                	sd	ra,88(sp)
    80004b22:	e8a2                	sd	s0,80(sp)
    80004b24:	e4a6                	sd	s1,72(sp)
    80004b26:	e0ca                	sd	s2,64(sp)
    80004b28:	fc4e                	sd	s3,56(sp)
    80004b2a:	f852                	sd	s4,48(sp)
    80004b2c:	f456                	sd	s5,40(sp)
    80004b2e:	f05a                	sd	s6,32(sp)
    80004b30:	ec5e                	sd	s7,24(sp)
    80004b32:	e862                	sd	s8,16(sp)
    80004b34:	1080                	addi	s0,sp,96
    80004b36:	84aa                	mv	s1,a0
    80004b38:	8aae                	mv	s5,a1
    80004b3a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004b3c:	ffffd097          	auipc	ra,0xffffd
    80004b40:	00c080e7          	jalr	12(ra) # 80001b48 <myproc>
    80004b44:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004b46:	8526                	mv	a0,s1
    80004b48:	ffffc097          	auipc	ra,0xffffc
    80004b4c:	04a080e7          	jalr	74(ra) # 80000b92 <acquire>
  while(i < n){
    80004b50:	0b405363          	blez	s4,80004bf6 <pipewrite+0xd8>
  int i = 0;
    80004b54:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b56:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b58:	22048c13          	addi	s8,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004b5c:	22448b93          	addi	s7,s1,548
    80004b60:	a089                	j	80004ba2 <pipewrite+0x84>
      release(&pi->lock);
    80004b62:	8526                	mv	a0,s1
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	0fe080e7          	jalr	254(ra) # 80000c62 <release>
      return -1;
    80004b6c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b6e:	854a                	mv	a0,s2
    80004b70:	60e6                	ld	ra,88(sp)
    80004b72:	6446                	ld	s0,80(sp)
    80004b74:	64a6                	ld	s1,72(sp)
    80004b76:	6906                	ld	s2,64(sp)
    80004b78:	79e2                	ld	s3,56(sp)
    80004b7a:	7a42                	ld	s4,48(sp)
    80004b7c:	7aa2                	ld	s5,40(sp)
    80004b7e:	7b02                	ld	s6,32(sp)
    80004b80:	6be2                	ld	s7,24(sp)
    80004b82:	6c42                	ld	s8,16(sp)
    80004b84:	6125                	addi	sp,sp,96
    80004b86:	8082                	ret
      wakeup(&pi->nread);
    80004b88:	8562                	mv	a0,s8
    80004b8a:	ffffe097          	auipc	ra,0xffffe
    80004b8e:	94e080e7          	jalr	-1714(ra) # 800024d8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b92:	85a6                	mv	a1,s1
    80004b94:	855e                	mv	a0,s7
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	7c2080e7          	jalr	1986(ra) # 80002358 <sleep>
  while(i < n){
    80004b9e:	05495d63          	bge	s2,s4,80004bf8 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004ba2:	2284a783          	lw	a5,552(s1)
    80004ba6:	dfd5                	beqz	a5,80004b62 <pipewrite+0x44>
    80004ba8:	0389a783          	lw	a5,56(s3)
    80004bac:	fbdd                	bnez	a5,80004b62 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004bae:	2204a783          	lw	a5,544(s1)
    80004bb2:	2244a703          	lw	a4,548(s1)
    80004bb6:	2007879b          	addiw	a5,a5,512
    80004bba:	fcf707e3          	beq	a4,a5,80004b88 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004bbe:	4685                	li	a3,1
    80004bc0:	01590633          	add	a2,s2,s5
    80004bc4:	faf40593          	addi	a1,s0,-81
    80004bc8:	0589b503          	ld	a0,88(s3)
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	cc0080e7          	jalr	-832(ra) # 8000188c <copyin>
    80004bd4:	03650263          	beq	a0,s6,80004bf8 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bd8:	2244a783          	lw	a5,548(s1)
    80004bdc:	0017871b          	addiw	a4,a5,1
    80004be0:	22e4a223          	sw	a4,548(s1)
    80004be4:	1ff7f793          	andi	a5,a5,511
    80004be8:	97a6                	add	a5,a5,s1
    80004bea:	faf44703          	lbu	a4,-81(s0)
    80004bee:	02e78023          	sb	a4,32(a5)
      i++;
    80004bf2:	2905                	addiw	s2,s2,1
    80004bf4:	b76d                	j	80004b9e <pipewrite+0x80>
  int i = 0;
    80004bf6:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004bf8:	22048513          	addi	a0,s1,544
    80004bfc:	ffffe097          	auipc	ra,0xffffe
    80004c00:	8dc080e7          	jalr	-1828(ra) # 800024d8 <wakeup>
  release(&pi->lock);
    80004c04:	8526                	mv	a0,s1
    80004c06:	ffffc097          	auipc	ra,0xffffc
    80004c0a:	05c080e7          	jalr	92(ra) # 80000c62 <release>
  return i;
    80004c0e:	b785                	j	80004b6e <pipewrite+0x50>

0000000080004c10 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c10:	715d                	addi	sp,sp,-80
    80004c12:	e486                	sd	ra,72(sp)
    80004c14:	e0a2                	sd	s0,64(sp)
    80004c16:	fc26                	sd	s1,56(sp)
    80004c18:	f84a                	sd	s2,48(sp)
    80004c1a:	f44e                	sd	s3,40(sp)
    80004c1c:	f052                	sd	s4,32(sp)
    80004c1e:	ec56                	sd	s5,24(sp)
    80004c20:	e85a                	sd	s6,16(sp)
    80004c22:	0880                	addi	s0,sp,80
    80004c24:	84aa                	mv	s1,a0
    80004c26:	892e                	mv	s2,a1
    80004c28:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c2a:	ffffd097          	auipc	ra,0xffffd
    80004c2e:	f1e080e7          	jalr	-226(ra) # 80001b48 <myproc>
    80004c32:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c34:	8526                	mv	a0,s1
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	f5c080e7          	jalr	-164(ra) # 80000b92 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c3e:	2204a703          	lw	a4,544(s1)
    80004c42:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c46:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c4a:	02f71463          	bne	a4,a5,80004c72 <piperead+0x62>
    80004c4e:	22c4a783          	lw	a5,556(s1)
    80004c52:	c385                	beqz	a5,80004c72 <piperead+0x62>
    if(pr->killed){
    80004c54:	038a2783          	lw	a5,56(s4)
    80004c58:	ebc1                	bnez	a5,80004ce8 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c5a:	85a6                	mv	a1,s1
    80004c5c:	854e                	mv	a0,s3
    80004c5e:	ffffd097          	auipc	ra,0xffffd
    80004c62:	6fa080e7          	jalr	1786(ra) # 80002358 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c66:	2204a703          	lw	a4,544(s1)
    80004c6a:	2244a783          	lw	a5,548(s1)
    80004c6e:	fef700e3          	beq	a4,a5,80004c4e <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c72:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c74:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c76:	05505363          	blez	s5,80004cbc <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004c7a:	2204a783          	lw	a5,544(s1)
    80004c7e:	2244a703          	lw	a4,548(s1)
    80004c82:	02f70d63          	beq	a4,a5,80004cbc <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c86:	0017871b          	addiw	a4,a5,1
    80004c8a:	22e4a023          	sw	a4,544(s1)
    80004c8e:	1ff7f793          	andi	a5,a5,511
    80004c92:	97a6                	add	a5,a5,s1
    80004c94:	0207c783          	lbu	a5,32(a5)
    80004c98:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c9c:	4685                	li	a3,1
    80004c9e:	fbf40613          	addi	a2,s0,-65
    80004ca2:	85ca                	mv	a1,s2
    80004ca4:	058a3503          	ld	a0,88(s4)
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	b58080e7          	jalr	-1192(ra) # 80001800 <copyout>
    80004cb0:	01650663          	beq	a0,s6,80004cbc <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cb4:	2985                	addiw	s3,s3,1
    80004cb6:	0905                	addi	s2,s2,1
    80004cb8:	fd3a91e3          	bne	s5,s3,80004c7a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cbc:	22448513          	addi	a0,s1,548
    80004cc0:	ffffe097          	auipc	ra,0xffffe
    80004cc4:	818080e7          	jalr	-2024(ra) # 800024d8 <wakeup>
  release(&pi->lock);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	f98080e7          	jalr	-104(ra) # 80000c62 <release>
  return i;
}
    80004cd2:	854e                	mv	a0,s3
    80004cd4:	60a6                	ld	ra,72(sp)
    80004cd6:	6406                	ld	s0,64(sp)
    80004cd8:	74e2                	ld	s1,56(sp)
    80004cda:	7942                	ld	s2,48(sp)
    80004cdc:	79a2                	ld	s3,40(sp)
    80004cde:	7a02                	ld	s4,32(sp)
    80004ce0:	6ae2                	ld	s5,24(sp)
    80004ce2:	6b42                	ld	s6,16(sp)
    80004ce4:	6161                	addi	sp,sp,80
    80004ce6:	8082                	ret
      release(&pi->lock);
    80004ce8:	8526                	mv	a0,s1
    80004cea:	ffffc097          	auipc	ra,0xffffc
    80004cee:	f78080e7          	jalr	-136(ra) # 80000c62 <release>
      return -1;
    80004cf2:	59fd                	li	s3,-1
    80004cf4:	bff9                	j	80004cd2 <piperead+0xc2>

0000000080004cf6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cf6:	de010113          	addi	sp,sp,-544
    80004cfa:	20113c23          	sd	ra,536(sp)
    80004cfe:	20813823          	sd	s0,528(sp)
    80004d02:	20913423          	sd	s1,520(sp)
    80004d06:	21213023          	sd	s2,512(sp)
    80004d0a:	ffce                	sd	s3,504(sp)
    80004d0c:	fbd2                	sd	s4,496(sp)
    80004d0e:	f7d6                	sd	s5,488(sp)
    80004d10:	f3da                	sd	s6,480(sp)
    80004d12:	efde                	sd	s7,472(sp)
    80004d14:	ebe2                	sd	s8,464(sp)
    80004d16:	e7e6                	sd	s9,456(sp)
    80004d18:	e3ea                	sd	s10,448(sp)
    80004d1a:	ff6e                	sd	s11,440(sp)
    80004d1c:	1400                	addi	s0,sp,544
    80004d1e:	892a                	mv	s2,a0
    80004d20:	dea43423          	sd	a0,-536(s0)
    80004d24:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d28:	ffffd097          	auipc	ra,0xffffd
    80004d2c:	e20080e7          	jalr	-480(ra) # 80001b48 <myproc>
    80004d30:	84aa                	mv	s1,a0

  begin_op();
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	4a0080e7          	jalr	1184(ra) # 800041d2 <begin_op>

  if((ip = namei(path)) == 0){
    80004d3a:	854a                	mv	a0,s2
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	28a080e7          	jalr	650(ra) # 80003fc6 <namei>
    80004d44:	c93d                	beqz	a0,80004dba <exec+0xc4>
    80004d46:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	ac8080e7          	jalr	-1336(ra) # 80003810 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d50:	04000713          	li	a4,64
    80004d54:	4681                	li	a3,0
    80004d56:	e5040613          	addi	a2,s0,-432
    80004d5a:	4581                	li	a1,0
    80004d5c:	8556                	mv	a0,s5
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	d66080e7          	jalr	-666(ra) # 80003ac4 <readi>
    80004d66:	04000793          	li	a5,64
    80004d6a:	00f51a63          	bne	a0,a5,80004d7e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d6e:	e5042703          	lw	a4,-432(s0)
    80004d72:	464c47b7          	lui	a5,0x464c4
    80004d76:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d7a:	04f70663          	beq	a4,a5,80004dc6 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d7e:	8556                	mv	a0,s5
    80004d80:	fffff097          	auipc	ra,0xfffff
    80004d84:	cf2080e7          	jalr	-782(ra) # 80003a72 <iunlockput>
    end_op();
    80004d88:	fffff097          	auipc	ra,0xfffff
    80004d8c:	4ca080e7          	jalr	1226(ra) # 80004252 <end_op>
  }
  return -1;
    80004d90:	557d                	li	a0,-1
}
    80004d92:	21813083          	ld	ra,536(sp)
    80004d96:	21013403          	ld	s0,528(sp)
    80004d9a:	20813483          	ld	s1,520(sp)
    80004d9e:	20013903          	ld	s2,512(sp)
    80004da2:	79fe                	ld	s3,504(sp)
    80004da4:	7a5e                	ld	s4,496(sp)
    80004da6:	7abe                	ld	s5,488(sp)
    80004da8:	7b1e                	ld	s6,480(sp)
    80004daa:	6bfe                	ld	s7,472(sp)
    80004dac:	6c5e                	ld	s8,464(sp)
    80004dae:	6cbe                	ld	s9,456(sp)
    80004db0:	6d1e                	ld	s10,448(sp)
    80004db2:	7dfa                	ld	s11,440(sp)
    80004db4:	22010113          	addi	sp,sp,544
    80004db8:	8082                	ret
    end_op();
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	498080e7          	jalr	1176(ra) # 80004252 <end_op>
    return -1;
    80004dc2:	557d                	li	a0,-1
    80004dc4:	b7f9                	j	80004d92 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	ffffd097          	auipc	ra,0xffffd
    80004dcc:	e44080e7          	jalr	-444(ra) # 80001c0c <proc_pagetable>
    80004dd0:	8b2a                	mv	s6,a0
    80004dd2:	d555                	beqz	a0,80004d7e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd4:	e7042783          	lw	a5,-400(s0)
    80004dd8:	e8845703          	lhu	a4,-376(s0)
    80004ddc:	c735                	beqz	a4,80004e48 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dde:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004de0:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004de4:	6a05                	lui	s4,0x1
    80004de6:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004dea:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004dee:	6d85                	lui	s11,0x1
    80004df0:	7d7d                	lui	s10,0xfffff
    80004df2:	ac1d                	j	80005028 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004df4:	00004517          	auipc	a0,0x4
    80004df8:	dcc50513          	addi	a0,a0,-564 # 80008bc0 <syscalls+0x290>
    80004dfc:	ffffb097          	auipc	ra,0xffffb
    80004e00:	768080e7          	jalr	1896(ra) # 80000564 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e04:	874a                	mv	a4,s2
    80004e06:	009c86bb          	addw	a3,s9,s1
    80004e0a:	4581                	li	a1,0
    80004e0c:	8556                	mv	a0,s5
    80004e0e:	fffff097          	auipc	ra,0xfffff
    80004e12:	cb6080e7          	jalr	-842(ra) # 80003ac4 <readi>
    80004e16:	2501                	sext.w	a0,a0
    80004e18:	1aa91863          	bne	s2,a0,80004fc8 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004e1c:	009d84bb          	addw	s1,s11,s1
    80004e20:	013d09bb          	addw	s3,s10,s3
    80004e24:	1f74f263          	bgeu	s1,s7,80005008 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004e28:	02049593          	slli	a1,s1,0x20
    80004e2c:	9181                	srli	a1,a1,0x20
    80004e2e:	95e2                	add	a1,a1,s8
    80004e30:	855a                	mv	a0,s6
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	460080e7          	jalr	1120(ra) # 80001292 <walkaddr>
    80004e3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004e3c:	dd45                	beqz	a0,80004df4 <exec+0xfe>
      n = PGSIZE;
    80004e3e:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e40:	fd49f2e3          	bgeu	s3,s4,80004e04 <exec+0x10e>
      n = sz - i;
    80004e44:	894e                	mv	s2,s3
    80004e46:	bf7d                	j	80004e04 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e48:	4481                	li	s1,0
  iunlockput(ip);
    80004e4a:	8556                	mv	a0,s5
    80004e4c:	fffff097          	auipc	ra,0xfffff
    80004e50:	c26080e7          	jalr	-986(ra) # 80003a72 <iunlockput>
  end_op();
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	3fe080e7          	jalr	1022(ra) # 80004252 <end_op>
  p = myproc();
    80004e5c:	ffffd097          	auipc	ra,0xffffd
    80004e60:	cec080e7          	jalr	-788(ra) # 80001b48 <myproc>
    80004e64:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004e66:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004e6a:	6785                	lui	a5,0x1
    80004e6c:	17fd                	addi	a5,a5,-1
    80004e6e:	94be                	add	s1,s1,a5
    80004e70:	77fd                	lui	a5,0xfffff
    80004e72:	8fe5                	and	a5,a5,s1
    80004e74:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e78:	6609                	lui	a2,0x2
    80004e7a:	963e                	add	a2,a2,a5
    80004e7c:	85be                	mv	a1,a5
    80004e7e:	855a                	mv	a0,s6
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	7a6080e7          	jalr	1958(ra) # 80001626 <uvmalloc>
    80004e88:	8c2a                	mv	s8,a0
  ip = 0;
    80004e8a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e8c:	12050e63          	beqz	a0,80004fc8 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e90:	75f9                	lui	a1,0xffffe
    80004e92:	95aa                	add	a1,a1,a0
    80004e94:	855a                	mv	a0,s6
    80004e96:	ffffd097          	auipc	ra,0xffffd
    80004e9a:	938080e7          	jalr	-1736(ra) # 800017ce <uvmclear>
  stackbase = sp - PGSIZE;
    80004e9e:	7afd                	lui	s5,0xfffff
    80004ea0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ea2:	df043783          	ld	a5,-528(s0)
    80004ea6:	6388                	ld	a0,0(a5)
    80004ea8:	c925                	beqz	a0,80004f18 <exec+0x222>
    80004eaa:	e9040993          	addi	s3,s0,-368
    80004eae:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004eb2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004eb4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	168080e7          	jalr	360(ra) # 8000101e <strlen>
    80004ebe:	0015079b          	addiw	a5,a0,1
    80004ec2:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ec6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004eca:	13596363          	bltu	s2,s5,80004ff0 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ece:	df043d83          	ld	s11,-528(s0)
    80004ed2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004ed6:	8552                	mv	a0,s4
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	146080e7          	jalr	326(ra) # 8000101e <strlen>
    80004ee0:	0015069b          	addiw	a3,a0,1
    80004ee4:	8652                	mv	a2,s4
    80004ee6:	85ca                	mv	a1,s2
    80004ee8:	855a                	mv	a0,s6
    80004eea:	ffffd097          	auipc	ra,0xffffd
    80004eee:	916080e7          	jalr	-1770(ra) # 80001800 <copyout>
    80004ef2:	10054363          	bltz	a0,80004ff8 <exec+0x302>
    ustack[argc] = sp;
    80004ef6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004efa:	0485                	addi	s1,s1,1
    80004efc:	008d8793          	addi	a5,s11,8
    80004f00:	def43823          	sd	a5,-528(s0)
    80004f04:	008db503          	ld	a0,8(s11)
    80004f08:	c911                	beqz	a0,80004f1c <exec+0x226>
    if(argc >= MAXARG)
    80004f0a:	09a1                	addi	s3,s3,8
    80004f0c:	fb3c95e3          	bne	s9,s3,80004eb6 <exec+0x1c0>
  sz = sz1;
    80004f10:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f14:	4a81                	li	s5,0
    80004f16:	a84d                	j	80004fc8 <exec+0x2d2>
  sp = sz;
    80004f18:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f1a:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f1c:	00349793          	slli	a5,s1,0x3
    80004f20:	f9040713          	addi	a4,s0,-112
    80004f24:	97ba                	add	a5,a5,a4
    80004f26:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffc8a10>
  sp -= (argc+1) * sizeof(uint64);
    80004f2a:	00148693          	addi	a3,s1,1
    80004f2e:	068e                	slli	a3,a3,0x3
    80004f30:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f34:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f38:	01597663          	bgeu	s2,s5,80004f44 <exec+0x24e>
  sz = sz1;
    80004f3c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f40:	4a81                	li	s5,0
    80004f42:	a059                	j	80004fc8 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f44:	e9040613          	addi	a2,s0,-368
    80004f48:	85ca                	mv	a1,s2
    80004f4a:	855a                	mv	a0,s6
    80004f4c:	ffffd097          	auipc	ra,0xffffd
    80004f50:	8b4080e7          	jalr	-1868(ra) # 80001800 <copyout>
    80004f54:	0a054663          	bltz	a0,80005000 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004f58:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    80004f5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f60:	de843783          	ld	a5,-536(s0)
    80004f64:	0007c703          	lbu	a4,0(a5)
    80004f68:	cf11                	beqz	a4,80004f84 <exec+0x28e>
    80004f6a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f6c:	02f00693          	li	a3,47
    80004f70:	a039                	j	80004f7e <exec+0x288>
      last = s+1;
    80004f72:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004f76:	0785                	addi	a5,a5,1
    80004f78:	fff7c703          	lbu	a4,-1(a5)
    80004f7c:	c701                	beqz	a4,80004f84 <exec+0x28e>
    if(*s == '/')
    80004f7e:	fed71ce3          	bne	a4,a3,80004f76 <exec+0x280>
    80004f82:	bfc5                	j	80004f72 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f84:	4641                	li	a2,16
    80004f86:	de843583          	ld	a1,-536(s0)
    80004f8a:	160b8513          	addi	a0,s7,352
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	05e080e7          	jalr	94(ra) # 80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    80004f96:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80004f9a:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80004f9e:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fa2:	060bb783          	ld	a5,96(s7)
    80004fa6:	e6843703          	ld	a4,-408(s0)
    80004faa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fac:	060bb783          	ld	a5,96(s7)
    80004fb0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fb4:	85ea                	mv	a1,s10
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	d62080e7          	jalr	-670(ra) # 80001d18 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fbe:	0004851b          	sext.w	a0,s1
    80004fc2:	bbc1                	j	80004d92 <exec+0x9c>
    80004fc4:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004fc8:	df843583          	ld	a1,-520(s0)
    80004fcc:	855a                	mv	a0,s6
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	d4a080e7          	jalr	-694(ra) # 80001d18 <proc_freepagetable>
  if(ip){
    80004fd6:	da0a94e3          	bnez	s5,80004d7e <exec+0x88>
  return -1;
    80004fda:	557d                	li	a0,-1
    80004fdc:	bb5d                	j	80004d92 <exec+0x9c>
    80004fde:	de943c23          	sd	s1,-520(s0)
    80004fe2:	b7dd                	j	80004fc8 <exec+0x2d2>
    80004fe4:	de943c23          	sd	s1,-520(s0)
    80004fe8:	b7c5                	j	80004fc8 <exec+0x2d2>
    80004fea:	de943c23          	sd	s1,-520(s0)
    80004fee:	bfe9                	j	80004fc8 <exec+0x2d2>
  sz = sz1;
    80004ff0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ff4:	4a81                	li	s5,0
    80004ff6:	bfc9                	j	80004fc8 <exec+0x2d2>
  sz = sz1;
    80004ff8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ffc:	4a81                	li	s5,0
    80004ffe:	b7e9                	j	80004fc8 <exec+0x2d2>
  sz = sz1;
    80005000:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005004:	4a81                	li	s5,0
    80005006:	b7c9                	j	80004fc8 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005008:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000500c:	e0843783          	ld	a5,-504(s0)
    80005010:	0017869b          	addiw	a3,a5,1
    80005014:	e0d43423          	sd	a3,-504(s0)
    80005018:	e0043783          	ld	a5,-512(s0)
    8000501c:	0387879b          	addiw	a5,a5,56
    80005020:	e8845703          	lhu	a4,-376(s0)
    80005024:	e2e6d3e3          	bge	a3,a4,80004e4a <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005028:	2781                	sext.w	a5,a5
    8000502a:	e0f43023          	sd	a5,-512(s0)
    8000502e:	03800713          	li	a4,56
    80005032:	86be                	mv	a3,a5
    80005034:	e1840613          	addi	a2,s0,-488
    80005038:	4581                	li	a1,0
    8000503a:	8556                	mv	a0,s5
    8000503c:	fffff097          	auipc	ra,0xfffff
    80005040:	a88080e7          	jalr	-1400(ra) # 80003ac4 <readi>
    80005044:	03800793          	li	a5,56
    80005048:	f6f51ee3          	bne	a0,a5,80004fc4 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    8000504c:	e1842783          	lw	a5,-488(s0)
    80005050:	4705                	li	a4,1
    80005052:	fae79de3          	bne	a5,a4,8000500c <exec+0x316>
    if(ph.memsz < ph.filesz)
    80005056:	e4043603          	ld	a2,-448(s0)
    8000505a:	e3843783          	ld	a5,-456(s0)
    8000505e:	f8f660e3          	bltu	a2,a5,80004fde <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005062:	e2843783          	ld	a5,-472(s0)
    80005066:	963e                	add	a2,a2,a5
    80005068:	f6f66ee3          	bltu	a2,a5,80004fe4 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000506c:	85a6                	mv	a1,s1
    8000506e:	855a                	mv	a0,s6
    80005070:	ffffc097          	auipc	ra,0xffffc
    80005074:	5b6080e7          	jalr	1462(ra) # 80001626 <uvmalloc>
    80005078:	dea43c23          	sd	a0,-520(s0)
    8000507c:	d53d                	beqz	a0,80004fea <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    8000507e:	e2843c03          	ld	s8,-472(s0)
    80005082:	de043783          	ld	a5,-544(s0)
    80005086:	00fc77b3          	and	a5,s8,a5
    8000508a:	ff9d                	bnez	a5,80004fc8 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000508c:	e2042c83          	lw	s9,-480(s0)
    80005090:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005094:	f60b8ae3          	beqz	s7,80005008 <exec+0x312>
    80005098:	89de                	mv	s3,s7
    8000509a:	4481                	li	s1,0
    8000509c:	b371                	j	80004e28 <exec+0x132>

000000008000509e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000509e:	7179                	addi	sp,sp,-48
    800050a0:	f406                	sd	ra,40(sp)
    800050a2:	f022                	sd	s0,32(sp)
    800050a4:	ec26                	sd	s1,24(sp)
    800050a6:	e84a                	sd	s2,16(sp)
    800050a8:	1800                	addi	s0,sp,48
    800050aa:	892e                	mv	s2,a1
    800050ac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050ae:	fdc40593          	addi	a1,s0,-36
    800050b2:	ffffe097          	auipc	ra,0xffffe
    800050b6:	bee080e7          	jalr	-1042(ra) # 80002ca0 <argint>
    800050ba:	04054063          	bltz	a0,800050fa <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050be:	fdc42703          	lw	a4,-36(s0)
    800050c2:	47bd                	li	a5,15
    800050c4:	02e7ed63          	bltu	a5,a4,800050fe <argfd+0x60>
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	a80080e7          	jalr	-1408(ra) # 80001b48 <myproc>
    800050d0:	fdc42703          	lw	a4,-36(s0)
    800050d4:	01a70793          	addi	a5,a4,26
    800050d8:	078e                	slli	a5,a5,0x3
    800050da:	953e                	add	a0,a0,a5
    800050dc:	651c                	ld	a5,8(a0)
    800050de:	c395                	beqz	a5,80005102 <argfd+0x64>
    return -1;
  if(pfd)
    800050e0:	00090463          	beqz	s2,800050e8 <argfd+0x4a>
    *pfd = fd;
    800050e4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800050e8:	4501                	li	a0,0
  if(pf)
    800050ea:	c091                	beqz	s1,800050ee <argfd+0x50>
    *pf = f;
    800050ec:	e09c                	sd	a5,0(s1)
}
    800050ee:	70a2                	ld	ra,40(sp)
    800050f0:	7402                	ld	s0,32(sp)
    800050f2:	64e2                	ld	s1,24(sp)
    800050f4:	6942                	ld	s2,16(sp)
    800050f6:	6145                	addi	sp,sp,48
    800050f8:	8082                	ret
    return -1;
    800050fa:	557d                	li	a0,-1
    800050fc:	bfcd                	j	800050ee <argfd+0x50>
    return -1;
    800050fe:	557d                	li	a0,-1
    80005100:	b7fd                	j	800050ee <argfd+0x50>
    80005102:	557d                	li	a0,-1
    80005104:	b7ed                	j	800050ee <argfd+0x50>

0000000080005106 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005106:	1101                	addi	sp,sp,-32
    80005108:	ec06                	sd	ra,24(sp)
    8000510a:	e822                	sd	s0,16(sp)
    8000510c:	e426                	sd	s1,8(sp)
    8000510e:	1000                	addi	s0,sp,32
    80005110:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005112:	ffffd097          	auipc	ra,0xffffd
    80005116:	a36080e7          	jalr	-1482(ra) # 80001b48 <myproc>
    8000511a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000511c:	0d850793          	addi	a5,a0,216
    80005120:	4501                	li	a0,0
    80005122:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005124:	6398                	ld	a4,0(a5)
    80005126:	cb19                	beqz	a4,8000513c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005128:	2505                	addiw	a0,a0,1
    8000512a:	07a1                	addi	a5,a5,8
    8000512c:	fed51ce3          	bne	a0,a3,80005124 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005130:	557d                	li	a0,-1
}
    80005132:	60e2                	ld	ra,24(sp)
    80005134:	6442                	ld	s0,16(sp)
    80005136:	64a2                	ld	s1,8(sp)
    80005138:	6105                	addi	sp,sp,32
    8000513a:	8082                	ret
      p->ofile[fd] = f;
    8000513c:	01a50793          	addi	a5,a0,26
    80005140:	078e                	slli	a5,a5,0x3
    80005142:	963e                	add	a2,a2,a5
    80005144:	e604                	sd	s1,8(a2)
      return fd;
    80005146:	b7f5                	j	80005132 <fdalloc+0x2c>

0000000080005148 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005148:	715d                	addi	sp,sp,-80
    8000514a:	e486                	sd	ra,72(sp)
    8000514c:	e0a2                	sd	s0,64(sp)
    8000514e:	fc26                	sd	s1,56(sp)
    80005150:	f84a                	sd	s2,48(sp)
    80005152:	f44e                	sd	s3,40(sp)
    80005154:	f052                	sd	s4,32(sp)
    80005156:	ec56                	sd	s5,24(sp)
    80005158:	0880                	addi	s0,sp,80
    8000515a:	89ae                	mv	s3,a1
    8000515c:	8ab2                	mv	s5,a2
    8000515e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005160:	fb040593          	addi	a1,s0,-80
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	e80080e7          	jalr	-384(ra) # 80003fe4 <nameiparent>
    8000516c:	892a                	mv	s2,a0
    8000516e:	12050e63          	beqz	a0,800052aa <create+0x162>
    return 0;

  ilock(dp);
    80005172:	ffffe097          	auipc	ra,0xffffe
    80005176:	69e080e7          	jalr	1694(ra) # 80003810 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000517a:	4601                	li	a2,0
    8000517c:	fb040593          	addi	a1,s0,-80
    80005180:	854a                	mv	a0,s2
    80005182:	fffff097          	auipc	ra,0xfffff
    80005186:	b72080e7          	jalr	-1166(ra) # 80003cf4 <dirlookup>
    8000518a:	84aa                	mv	s1,a0
    8000518c:	c921                	beqz	a0,800051dc <create+0x94>
    iunlockput(dp);
    8000518e:	854a                	mv	a0,s2
    80005190:	fffff097          	auipc	ra,0xfffff
    80005194:	8e2080e7          	jalr	-1822(ra) # 80003a72 <iunlockput>
    ilock(ip);
    80005198:	8526                	mv	a0,s1
    8000519a:	ffffe097          	auipc	ra,0xffffe
    8000519e:	676080e7          	jalr	1654(ra) # 80003810 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051a2:	2981                	sext.w	s3,s3
    800051a4:	4789                	li	a5,2
    800051a6:	02f99463          	bne	s3,a5,800051ce <create+0x86>
    800051aa:	04c4d783          	lhu	a5,76(s1)
    800051ae:	37f9                	addiw	a5,a5,-2
    800051b0:	17c2                	slli	a5,a5,0x30
    800051b2:	93c1                	srli	a5,a5,0x30
    800051b4:	4705                	li	a4,1
    800051b6:	00f76c63          	bltu	a4,a5,800051ce <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051ba:	8526                	mv	a0,s1
    800051bc:	60a6                	ld	ra,72(sp)
    800051be:	6406                	ld	s0,64(sp)
    800051c0:	74e2                	ld	s1,56(sp)
    800051c2:	7942                	ld	s2,48(sp)
    800051c4:	79a2                	ld	s3,40(sp)
    800051c6:	7a02                	ld	s4,32(sp)
    800051c8:	6ae2                	ld	s5,24(sp)
    800051ca:	6161                	addi	sp,sp,80
    800051cc:	8082                	ret
    iunlockput(ip);
    800051ce:	8526                	mv	a0,s1
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	8a2080e7          	jalr	-1886(ra) # 80003a72 <iunlockput>
    return 0;
    800051d8:	4481                	li	s1,0
    800051da:	b7c5                	j	800051ba <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051dc:	85ce                	mv	a1,s3
    800051de:	00092503          	lw	a0,0(s2)
    800051e2:	ffffe097          	auipc	ra,0xffffe
    800051e6:	496080e7          	jalr	1174(ra) # 80003678 <ialloc>
    800051ea:	84aa                	mv	s1,a0
    800051ec:	c521                	beqz	a0,80005234 <create+0xec>
  ilock(ip);
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	622080e7          	jalr	1570(ra) # 80003810 <ilock>
  ip->major = major;
    800051f6:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800051fa:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800051fe:	4a05                	li	s4,1
    80005200:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005204:	8526                	mv	a0,s1
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	540080e7          	jalr	1344(ra) # 80003746 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000520e:	2981                	sext.w	s3,s3
    80005210:	03498a63          	beq	s3,s4,80005244 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005214:	40d0                	lw	a2,4(s1)
    80005216:	fb040593          	addi	a1,s0,-80
    8000521a:	854a                	mv	a0,s2
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	ce8080e7          	jalr	-792(ra) # 80003f04 <dirlink>
    80005224:	06054b63          	bltz	a0,8000529a <create+0x152>
  iunlockput(dp);
    80005228:	854a                	mv	a0,s2
    8000522a:	fffff097          	auipc	ra,0xfffff
    8000522e:	848080e7          	jalr	-1976(ra) # 80003a72 <iunlockput>
  return ip;
    80005232:	b761                	j	800051ba <create+0x72>
    panic("create: ialloc");
    80005234:	00004517          	auipc	a0,0x4
    80005238:	9ac50513          	addi	a0,a0,-1620 # 80008be0 <syscalls+0x2b0>
    8000523c:	ffffb097          	auipc	ra,0xffffb
    80005240:	328080e7          	jalr	808(ra) # 80000564 <panic>
    dp->nlink++;  // for ".."
    80005244:	05295783          	lhu	a5,82(s2)
    80005248:	2785                	addiw	a5,a5,1
    8000524a:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    8000524e:	854a                	mv	a0,s2
    80005250:	ffffe097          	auipc	ra,0xffffe
    80005254:	4f6080e7          	jalr	1270(ra) # 80003746 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005258:	40d0                	lw	a2,4(s1)
    8000525a:	00004597          	auipc	a1,0x4
    8000525e:	99658593          	addi	a1,a1,-1642 # 80008bf0 <syscalls+0x2c0>
    80005262:	8526                	mv	a0,s1
    80005264:	fffff097          	auipc	ra,0xfffff
    80005268:	ca0080e7          	jalr	-864(ra) # 80003f04 <dirlink>
    8000526c:	00054f63          	bltz	a0,8000528a <create+0x142>
    80005270:	00492603          	lw	a2,4(s2)
    80005274:	00004597          	auipc	a1,0x4
    80005278:	98458593          	addi	a1,a1,-1660 # 80008bf8 <syscalls+0x2c8>
    8000527c:	8526                	mv	a0,s1
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	c86080e7          	jalr	-890(ra) # 80003f04 <dirlink>
    80005286:	f80557e3          	bgez	a0,80005214 <create+0xcc>
      panic("create dots");
    8000528a:	00004517          	auipc	a0,0x4
    8000528e:	97650513          	addi	a0,a0,-1674 # 80008c00 <syscalls+0x2d0>
    80005292:	ffffb097          	auipc	ra,0xffffb
    80005296:	2d2080e7          	jalr	722(ra) # 80000564 <panic>
    panic("create: dirlink");
    8000529a:	00004517          	auipc	a0,0x4
    8000529e:	97650513          	addi	a0,a0,-1674 # 80008c10 <syscalls+0x2e0>
    800052a2:	ffffb097          	auipc	ra,0xffffb
    800052a6:	2c2080e7          	jalr	706(ra) # 80000564 <panic>
    return 0;
    800052aa:	84aa                	mv	s1,a0
    800052ac:	b739                	j	800051ba <create+0x72>

00000000800052ae <sys_dup>:
{
    800052ae:	7179                	addi	sp,sp,-48
    800052b0:	f406                	sd	ra,40(sp)
    800052b2:	f022                	sd	s0,32(sp)
    800052b4:	ec26                	sd	s1,24(sp)
    800052b6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052b8:	fd840613          	addi	a2,s0,-40
    800052bc:	4581                	li	a1,0
    800052be:	4501                	li	a0,0
    800052c0:	00000097          	auipc	ra,0x0
    800052c4:	dde080e7          	jalr	-546(ra) # 8000509e <argfd>
    return -1;
    800052c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052ca:	02054363          	bltz	a0,800052f0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800052ce:	fd843503          	ld	a0,-40(s0)
    800052d2:	00000097          	auipc	ra,0x0
    800052d6:	e34080e7          	jalr	-460(ra) # 80005106 <fdalloc>
    800052da:	84aa                	mv	s1,a0
    return -1;
    800052dc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052de:	00054963          	bltz	a0,800052f0 <sys_dup+0x42>
  filedup(f);
    800052e2:	fd843503          	ld	a0,-40(s0)
    800052e6:	fffff097          	auipc	ra,0xfffff
    800052ea:	364080e7          	jalr	868(ra) # 8000464a <filedup>
  return fd;
    800052ee:	87a6                	mv	a5,s1
}
    800052f0:	853e                	mv	a0,a5
    800052f2:	70a2                	ld	ra,40(sp)
    800052f4:	7402                	ld	s0,32(sp)
    800052f6:	64e2                	ld	s1,24(sp)
    800052f8:	6145                	addi	sp,sp,48
    800052fa:	8082                	ret

00000000800052fc <sys_read>:
{
    800052fc:	7179                	addi	sp,sp,-48
    800052fe:	f406                	sd	ra,40(sp)
    80005300:	f022                	sd	s0,32(sp)
    80005302:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005304:	fe840613          	addi	a2,s0,-24
    80005308:	4581                	li	a1,0
    8000530a:	4501                	li	a0,0
    8000530c:	00000097          	auipc	ra,0x0
    80005310:	d92080e7          	jalr	-622(ra) # 8000509e <argfd>
    return -1;
    80005314:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005316:	04054163          	bltz	a0,80005358 <sys_read+0x5c>
    8000531a:	fe440593          	addi	a1,s0,-28
    8000531e:	4509                	li	a0,2
    80005320:	ffffe097          	auipc	ra,0xffffe
    80005324:	980080e7          	jalr	-1664(ra) # 80002ca0 <argint>
    return -1;
    80005328:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000532a:	02054763          	bltz	a0,80005358 <sys_read+0x5c>
    8000532e:	fd840593          	addi	a1,s0,-40
    80005332:	4505                	li	a0,1
    80005334:	ffffe097          	auipc	ra,0xffffe
    80005338:	98e080e7          	jalr	-1650(ra) # 80002cc2 <argaddr>
    return -1;
    8000533c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000533e:	00054d63          	bltz	a0,80005358 <sys_read+0x5c>
  return fileread(f, p, n);
    80005342:	fe442603          	lw	a2,-28(s0)
    80005346:	fd843583          	ld	a1,-40(s0)
    8000534a:	fe843503          	ld	a0,-24(s0)
    8000534e:	fffff097          	auipc	ra,0xfffff
    80005352:	488080e7          	jalr	1160(ra) # 800047d6 <fileread>
    80005356:	87aa                	mv	a5,a0
}
    80005358:	853e                	mv	a0,a5
    8000535a:	70a2                	ld	ra,40(sp)
    8000535c:	7402                	ld	s0,32(sp)
    8000535e:	6145                	addi	sp,sp,48
    80005360:	8082                	ret

0000000080005362 <sys_write>:
{
    80005362:	7179                	addi	sp,sp,-48
    80005364:	f406                	sd	ra,40(sp)
    80005366:	f022                	sd	s0,32(sp)
    80005368:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000536a:	fe840613          	addi	a2,s0,-24
    8000536e:	4581                	li	a1,0
    80005370:	4501                	li	a0,0
    80005372:	00000097          	auipc	ra,0x0
    80005376:	d2c080e7          	jalr	-724(ra) # 8000509e <argfd>
    return -1;
    8000537a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000537c:	04054163          	bltz	a0,800053be <sys_write+0x5c>
    80005380:	fe440593          	addi	a1,s0,-28
    80005384:	4509                	li	a0,2
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	91a080e7          	jalr	-1766(ra) # 80002ca0 <argint>
    return -1;
    8000538e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005390:	02054763          	bltz	a0,800053be <sys_write+0x5c>
    80005394:	fd840593          	addi	a1,s0,-40
    80005398:	4505                	li	a0,1
    8000539a:	ffffe097          	auipc	ra,0xffffe
    8000539e:	928080e7          	jalr	-1752(ra) # 80002cc2 <argaddr>
    return -1;
    800053a2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053a4:	00054d63          	bltz	a0,800053be <sys_write+0x5c>
  return filewrite(f, p, n);
    800053a8:	fe442603          	lw	a2,-28(s0)
    800053ac:	fd843583          	ld	a1,-40(s0)
    800053b0:	fe843503          	ld	a0,-24(s0)
    800053b4:	fffff097          	auipc	ra,0xfffff
    800053b8:	4e8080e7          	jalr	1256(ra) # 8000489c <filewrite>
    800053bc:	87aa                	mv	a5,a0
}
    800053be:	853e                	mv	a0,a5
    800053c0:	70a2                	ld	ra,40(sp)
    800053c2:	7402                	ld	s0,32(sp)
    800053c4:	6145                	addi	sp,sp,48
    800053c6:	8082                	ret

00000000800053c8 <sys_close>:
{
    800053c8:	1101                	addi	sp,sp,-32
    800053ca:	ec06                	sd	ra,24(sp)
    800053cc:	e822                	sd	s0,16(sp)
    800053ce:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053d0:	fe040613          	addi	a2,s0,-32
    800053d4:	fec40593          	addi	a1,s0,-20
    800053d8:	4501                	li	a0,0
    800053da:	00000097          	auipc	ra,0x0
    800053de:	cc4080e7          	jalr	-828(ra) # 8000509e <argfd>
    return -1;
    800053e2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800053e4:	02054463          	bltz	a0,8000540c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800053e8:	ffffc097          	auipc	ra,0xffffc
    800053ec:	760080e7          	jalr	1888(ra) # 80001b48 <myproc>
    800053f0:	fec42783          	lw	a5,-20(s0)
    800053f4:	07e9                	addi	a5,a5,26
    800053f6:	078e                	slli	a5,a5,0x3
    800053f8:	97aa                	add	a5,a5,a0
    800053fa:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800053fe:	fe043503          	ld	a0,-32(s0)
    80005402:	fffff097          	auipc	ra,0xfffff
    80005406:	29a080e7          	jalr	666(ra) # 8000469c <fileclose>
  return 0;
    8000540a:	4781                	li	a5,0
}
    8000540c:	853e                	mv	a0,a5
    8000540e:	60e2                	ld	ra,24(sp)
    80005410:	6442                	ld	s0,16(sp)
    80005412:	6105                	addi	sp,sp,32
    80005414:	8082                	ret

0000000080005416 <sys_fstat>:
{
    80005416:	1101                	addi	sp,sp,-32
    80005418:	ec06                	sd	ra,24(sp)
    8000541a:	e822                	sd	s0,16(sp)
    8000541c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000541e:	fe840613          	addi	a2,s0,-24
    80005422:	4581                	li	a1,0
    80005424:	4501                	li	a0,0
    80005426:	00000097          	auipc	ra,0x0
    8000542a:	c78080e7          	jalr	-904(ra) # 8000509e <argfd>
    return -1;
    8000542e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005430:	02054563          	bltz	a0,8000545a <sys_fstat+0x44>
    80005434:	fe040593          	addi	a1,s0,-32
    80005438:	4505                	li	a0,1
    8000543a:	ffffe097          	auipc	ra,0xffffe
    8000543e:	888080e7          	jalr	-1912(ra) # 80002cc2 <argaddr>
    return -1;
    80005442:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005444:	00054b63          	bltz	a0,8000545a <sys_fstat+0x44>
  return filestat(f, st);
    80005448:	fe043583          	ld	a1,-32(s0)
    8000544c:	fe843503          	ld	a0,-24(s0)
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	314080e7          	jalr	788(ra) # 80004764 <filestat>
    80005458:	87aa                	mv	a5,a0
}
    8000545a:	853e                	mv	a0,a5
    8000545c:	60e2                	ld	ra,24(sp)
    8000545e:	6442                	ld	s0,16(sp)
    80005460:	6105                	addi	sp,sp,32
    80005462:	8082                	ret

0000000080005464 <sys_link>:
{
    80005464:	7169                	addi	sp,sp,-304
    80005466:	f606                	sd	ra,296(sp)
    80005468:	f222                	sd	s0,288(sp)
    8000546a:	ee26                	sd	s1,280(sp)
    8000546c:	ea4a                	sd	s2,272(sp)
    8000546e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005470:	08000613          	li	a2,128
    80005474:	ed040593          	addi	a1,s0,-304
    80005478:	4501                	li	a0,0
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	86a080e7          	jalr	-1942(ra) # 80002ce4 <argstr>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005484:	10054e63          	bltz	a0,800055a0 <sys_link+0x13c>
    80005488:	08000613          	li	a2,128
    8000548c:	f5040593          	addi	a1,s0,-176
    80005490:	4505                	li	a0,1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	852080e7          	jalr	-1966(ra) # 80002ce4 <argstr>
    return -1;
    8000549a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000549c:	10054263          	bltz	a0,800055a0 <sys_link+0x13c>
  begin_op();
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	d32080e7          	jalr	-718(ra) # 800041d2 <begin_op>
  if((ip = namei(old)) == 0){
    800054a8:	ed040513          	addi	a0,s0,-304
    800054ac:	fffff097          	auipc	ra,0xfffff
    800054b0:	b1a080e7          	jalr	-1254(ra) # 80003fc6 <namei>
    800054b4:	84aa                	mv	s1,a0
    800054b6:	c551                	beqz	a0,80005542 <sys_link+0xde>
  ilock(ip);
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	358080e7          	jalr	856(ra) # 80003810 <ilock>
  if(ip->type == T_DIR){
    800054c0:	04c49703          	lh	a4,76(s1)
    800054c4:	4785                	li	a5,1
    800054c6:	08f70463          	beq	a4,a5,8000554e <sys_link+0xea>
  ip->nlink++;
    800054ca:	0524d783          	lhu	a5,82(s1)
    800054ce:	2785                	addiw	a5,a5,1
    800054d0:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	270080e7          	jalr	624(ra) # 80003746 <iupdate>
  iunlock(ip);
    800054de:	8526                	mv	a0,s1
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	3f2080e7          	jalr	1010(ra) # 800038d2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800054e8:	fd040593          	addi	a1,s0,-48
    800054ec:	f5040513          	addi	a0,s0,-176
    800054f0:	fffff097          	auipc	ra,0xfffff
    800054f4:	af4080e7          	jalr	-1292(ra) # 80003fe4 <nameiparent>
    800054f8:	892a                	mv	s2,a0
    800054fa:	c935                	beqz	a0,8000556e <sys_link+0x10a>
  ilock(dp);
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	314080e7          	jalr	788(ra) # 80003810 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005504:	00092703          	lw	a4,0(s2)
    80005508:	409c                	lw	a5,0(s1)
    8000550a:	04f71d63          	bne	a4,a5,80005564 <sys_link+0x100>
    8000550e:	40d0                	lw	a2,4(s1)
    80005510:	fd040593          	addi	a1,s0,-48
    80005514:	854a                	mv	a0,s2
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	9ee080e7          	jalr	-1554(ra) # 80003f04 <dirlink>
    8000551e:	04054363          	bltz	a0,80005564 <sys_link+0x100>
  iunlockput(dp);
    80005522:	854a                	mv	a0,s2
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	54e080e7          	jalr	1358(ra) # 80003a72 <iunlockput>
  iput(ip);
    8000552c:	8526                	mv	a0,s1
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	49c080e7          	jalr	1180(ra) # 800039ca <iput>
  end_op();
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	d1c080e7          	jalr	-740(ra) # 80004252 <end_op>
  return 0;
    8000553e:	4781                	li	a5,0
    80005540:	a085                	j	800055a0 <sys_link+0x13c>
    end_op();
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	d10080e7          	jalr	-752(ra) # 80004252 <end_op>
    return -1;
    8000554a:	57fd                	li	a5,-1
    8000554c:	a891                	j	800055a0 <sys_link+0x13c>
    iunlockput(ip);
    8000554e:	8526                	mv	a0,s1
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	522080e7          	jalr	1314(ra) # 80003a72 <iunlockput>
    end_op();
    80005558:	fffff097          	auipc	ra,0xfffff
    8000555c:	cfa080e7          	jalr	-774(ra) # 80004252 <end_op>
    return -1;
    80005560:	57fd                	li	a5,-1
    80005562:	a83d                	j	800055a0 <sys_link+0x13c>
    iunlockput(dp);
    80005564:	854a                	mv	a0,s2
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	50c080e7          	jalr	1292(ra) # 80003a72 <iunlockput>
  ilock(ip);
    8000556e:	8526                	mv	a0,s1
    80005570:	ffffe097          	auipc	ra,0xffffe
    80005574:	2a0080e7          	jalr	672(ra) # 80003810 <ilock>
  ip->nlink--;
    80005578:	0524d783          	lhu	a5,82(s1)
    8000557c:	37fd                	addiw	a5,a5,-1
    8000557e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005582:	8526                	mv	a0,s1
    80005584:	ffffe097          	auipc	ra,0xffffe
    80005588:	1c2080e7          	jalr	450(ra) # 80003746 <iupdate>
  iunlockput(ip);
    8000558c:	8526                	mv	a0,s1
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	4e4080e7          	jalr	1252(ra) # 80003a72 <iunlockput>
  end_op();
    80005596:	fffff097          	auipc	ra,0xfffff
    8000559a:	cbc080e7          	jalr	-836(ra) # 80004252 <end_op>
  return -1;
    8000559e:	57fd                	li	a5,-1
}
    800055a0:	853e                	mv	a0,a5
    800055a2:	70b2                	ld	ra,296(sp)
    800055a4:	7412                	ld	s0,288(sp)
    800055a6:	64f2                	ld	s1,280(sp)
    800055a8:	6952                	ld	s2,272(sp)
    800055aa:	6155                	addi	sp,sp,304
    800055ac:	8082                	ret

00000000800055ae <sys_unlink>:
{
    800055ae:	7151                	addi	sp,sp,-240
    800055b0:	f586                	sd	ra,232(sp)
    800055b2:	f1a2                	sd	s0,224(sp)
    800055b4:	eda6                	sd	s1,216(sp)
    800055b6:	e9ca                	sd	s2,208(sp)
    800055b8:	e5ce                	sd	s3,200(sp)
    800055ba:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055bc:	08000613          	li	a2,128
    800055c0:	f3040593          	addi	a1,s0,-208
    800055c4:	4501                	li	a0,0
    800055c6:	ffffd097          	auipc	ra,0xffffd
    800055ca:	71e080e7          	jalr	1822(ra) # 80002ce4 <argstr>
    800055ce:	18054163          	bltz	a0,80005750 <sys_unlink+0x1a2>
  begin_op();
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	c00080e7          	jalr	-1024(ra) # 800041d2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055da:	fb040593          	addi	a1,s0,-80
    800055de:	f3040513          	addi	a0,s0,-208
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	a02080e7          	jalr	-1534(ra) # 80003fe4 <nameiparent>
    800055ea:	84aa                	mv	s1,a0
    800055ec:	c979                	beqz	a0,800056c2 <sys_unlink+0x114>
  ilock(dp);
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	222080e7          	jalr	546(ra) # 80003810 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055f6:	00003597          	auipc	a1,0x3
    800055fa:	5fa58593          	addi	a1,a1,1530 # 80008bf0 <syscalls+0x2c0>
    800055fe:	fb040513          	addi	a0,s0,-80
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	6d8080e7          	jalr	1752(ra) # 80003cda <namecmp>
    8000560a:	14050a63          	beqz	a0,8000575e <sys_unlink+0x1b0>
    8000560e:	00003597          	auipc	a1,0x3
    80005612:	5ea58593          	addi	a1,a1,1514 # 80008bf8 <syscalls+0x2c8>
    80005616:	fb040513          	addi	a0,s0,-80
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	6c0080e7          	jalr	1728(ra) # 80003cda <namecmp>
    80005622:	12050e63          	beqz	a0,8000575e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005626:	f2c40613          	addi	a2,s0,-212
    8000562a:	fb040593          	addi	a1,s0,-80
    8000562e:	8526                	mv	a0,s1
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	6c4080e7          	jalr	1732(ra) # 80003cf4 <dirlookup>
    80005638:	892a                	mv	s2,a0
    8000563a:	12050263          	beqz	a0,8000575e <sys_unlink+0x1b0>
  ilock(ip);
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	1d2080e7          	jalr	466(ra) # 80003810 <ilock>
  if(ip->nlink < 1)
    80005646:	05291783          	lh	a5,82(s2)
    8000564a:	08f05263          	blez	a5,800056ce <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000564e:	04c91703          	lh	a4,76(s2)
    80005652:	4785                	li	a5,1
    80005654:	08f70563          	beq	a4,a5,800056de <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005658:	4641                	li	a2,16
    8000565a:	4581                	li	a1,0
    8000565c:	fc040513          	addi	a0,s0,-64
    80005660:	ffffc097          	auipc	ra,0xffffc
    80005664:	816080e7          	jalr	-2026(ra) # 80000e76 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005668:	4741                	li	a4,16
    8000566a:	f2c42683          	lw	a3,-212(s0)
    8000566e:	fc040613          	addi	a2,s0,-64
    80005672:	4581                	li	a1,0
    80005674:	8526                	mv	a0,s1
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	546080e7          	jalr	1350(ra) # 80003bbc <writei>
    8000567e:	47c1                	li	a5,16
    80005680:	0af51563          	bne	a0,a5,8000572a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005684:	04c91703          	lh	a4,76(s2)
    80005688:	4785                	li	a5,1
    8000568a:	0af70863          	beq	a4,a5,8000573a <sys_unlink+0x18c>
  iunlockput(dp);
    8000568e:	8526                	mv	a0,s1
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	3e2080e7          	jalr	994(ra) # 80003a72 <iunlockput>
  ip->nlink--;
    80005698:	05295783          	lhu	a5,82(s2)
    8000569c:	37fd                	addiw	a5,a5,-1
    8000569e:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    800056a2:	854a                	mv	a0,s2
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	0a2080e7          	jalr	162(ra) # 80003746 <iupdate>
  iunlockput(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	3c4080e7          	jalr	964(ra) # 80003a72 <iunlockput>
  end_op();
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	b9c080e7          	jalr	-1124(ra) # 80004252 <end_op>
  return 0;
    800056be:	4501                	li	a0,0
    800056c0:	a84d                	j	80005772 <sys_unlink+0x1c4>
    end_op();
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	b90080e7          	jalr	-1136(ra) # 80004252 <end_op>
    return -1;
    800056ca:	557d                	li	a0,-1
    800056cc:	a05d                	j	80005772 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056ce:	00003517          	auipc	a0,0x3
    800056d2:	55250513          	addi	a0,a0,1362 # 80008c20 <syscalls+0x2f0>
    800056d6:	ffffb097          	auipc	ra,0xffffb
    800056da:	e8e080e7          	jalr	-370(ra) # 80000564 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056de:	05492703          	lw	a4,84(s2)
    800056e2:	02000793          	li	a5,32
    800056e6:	f6e7f9e3          	bgeu	a5,a4,80005658 <sys_unlink+0xaa>
    800056ea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ee:	4741                	li	a4,16
    800056f0:	86ce                	mv	a3,s3
    800056f2:	f1840613          	addi	a2,s0,-232
    800056f6:	4581                	li	a1,0
    800056f8:	854a                	mv	a0,s2
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	3ca080e7          	jalr	970(ra) # 80003ac4 <readi>
    80005702:	47c1                	li	a5,16
    80005704:	00f51b63          	bne	a0,a5,8000571a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005708:	f1845783          	lhu	a5,-232(s0)
    8000570c:	e7a1                	bnez	a5,80005754 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000570e:	29c1                	addiw	s3,s3,16
    80005710:	05492783          	lw	a5,84(s2)
    80005714:	fcf9ede3          	bltu	s3,a5,800056ee <sys_unlink+0x140>
    80005718:	b781                	j	80005658 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000571a:	00003517          	auipc	a0,0x3
    8000571e:	51e50513          	addi	a0,a0,1310 # 80008c38 <syscalls+0x308>
    80005722:	ffffb097          	auipc	ra,0xffffb
    80005726:	e42080e7          	jalr	-446(ra) # 80000564 <panic>
    panic("unlink: writei");
    8000572a:	00003517          	auipc	a0,0x3
    8000572e:	52650513          	addi	a0,a0,1318 # 80008c50 <syscalls+0x320>
    80005732:	ffffb097          	auipc	ra,0xffffb
    80005736:	e32080e7          	jalr	-462(ra) # 80000564 <panic>
    dp->nlink--;
    8000573a:	0524d783          	lhu	a5,82(s1)
    8000573e:	37fd                	addiw	a5,a5,-1
    80005740:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005744:	8526                	mv	a0,s1
    80005746:	ffffe097          	auipc	ra,0xffffe
    8000574a:	000080e7          	jalr	ra # 80003746 <iupdate>
    8000574e:	b781                	j	8000568e <sys_unlink+0xe0>
    return -1;
    80005750:	557d                	li	a0,-1
    80005752:	a005                	j	80005772 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005754:	854a                	mv	a0,s2
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	31c080e7          	jalr	796(ra) # 80003a72 <iunlockput>
  iunlockput(dp);
    8000575e:	8526                	mv	a0,s1
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	312080e7          	jalr	786(ra) # 80003a72 <iunlockput>
  end_op();
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	aea080e7          	jalr	-1302(ra) # 80004252 <end_op>
  return -1;
    80005770:	557d                	li	a0,-1
}
    80005772:	70ae                	ld	ra,232(sp)
    80005774:	740e                	ld	s0,224(sp)
    80005776:	64ee                	ld	s1,216(sp)
    80005778:	694e                	ld	s2,208(sp)
    8000577a:	69ae                	ld	s3,200(sp)
    8000577c:	616d                	addi	sp,sp,240
    8000577e:	8082                	ret

0000000080005780 <sys_open>:

uint64
sys_open(void)
{
    80005780:	7131                	addi	sp,sp,-192
    80005782:	fd06                	sd	ra,184(sp)
    80005784:	f922                	sd	s0,176(sp)
    80005786:	f526                	sd	s1,168(sp)
    80005788:	f14a                	sd	s2,160(sp)
    8000578a:	ed4e                	sd	s3,152(sp)
    8000578c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000578e:	08000613          	li	a2,128
    80005792:	f5040593          	addi	a1,s0,-176
    80005796:	4501                	li	a0,0
    80005798:	ffffd097          	auipc	ra,0xffffd
    8000579c:	54c080e7          	jalr	1356(ra) # 80002ce4 <argstr>
    return -1;
    800057a0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057a2:	0c054163          	bltz	a0,80005864 <sys_open+0xe4>
    800057a6:	f4c40593          	addi	a1,s0,-180
    800057aa:	4505                	li	a0,1
    800057ac:	ffffd097          	auipc	ra,0xffffd
    800057b0:	4f4080e7          	jalr	1268(ra) # 80002ca0 <argint>
    800057b4:	0a054863          	bltz	a0,80005864 <sys_open+0xe4>

  begin_op();
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	a1a080e7          	jalr	-1510(ra) # 800041d2 <begin_op>

  if(omode & O_CREATE){
    800057c0:	f4c42783          	lw	a5,-180(s0)
    800057c4:	2007f793          	andi	a5,a5,512
    800057c8:	cbdd                	beqz	a5,8000587e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800057ca:	4681                	li	a3,0
    800057cc:	4601                	li	a2,0
    800057ce:	4589                	li	a1,2
    800057d0:	f5040513          	addi	a0,s0,-176
    800057d4:	00000097          	auipc	ra,0x0
    800057d8:	974080e7          	jalr	-1676(ra) # 80005148 <create>
    800057dc:	892a                	mv	s2,a0
    if(ip == 0){
    800057de:	c959                	beqz	a0,80005874 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057e0:	04c91703          	lh	a4,76(s2)
    800057e4:	478d                	li	a5,3
    800057e6:	00f71763          	bne	a4,a5,800057f4 <sys_open+0x74>
    800057ea:	04e95703          	lhu	a4,78(s2)
    800057ee:	47a5                	li	a5,9
    800057f0:	0ce7ec63          	bltu	a5,a4,800058c8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	dec080e7          	jalr	-532(ra) # 800045e0 <filealloc>
    800057fc:	89aa                	mv	s3,a0
    800057fe:	10050663          	beqz	a0,8000590a <sys_open+0x18a>
    80005802:	00000097          	auipc	ra,0x0
    80005806:	904080e7          	jalr	-1788(ra) # 80005106 <fdalloc>
    8000580a:	84aa                	mv	s1,a0
    8000580c:	0e054a63          	bltz	a0,80005900 <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005810:	04c91703          	lh	a4,76(s2)
    80005814:	478d                	li	a5,3
    80005816:	0cf70463          	beq	a4,a5,800058de <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    8000581a:	4789                	li	a5,2
    8000581c:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005820:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005824:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005828:	f4c42783          	lw	a5,-180(s0)
    8000582c:	0017c713          	xori	a4,a5,1
    80005830:	8b05                	andi	a4,a4,1
    80005832:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005836:	0037f713          	andi	a4,a5,3
    8000583a:	00e03733          	snez	a4,a4
    8000583e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005842:	4007f793          	andi	a5,a5,1024
    80005846:	c791                	beqz	a5,80005852 <sys_open+0xd2>
    80005848:	04c91703          	lh	a4,76(s2)
    8000584c:	4789                	li	a5,2
    8000584e:	0af70363          	beq	a4,a5,800058f4 <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    80005852:	854a                	mv	a0,s2
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	07e080e7          	jalr	126(ra) # 800038d2 <iunlock>
  end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	9f6080e7          	jalr	-1546(ra) # 80004252 <end_op>

  return fd;
}
    80005864:	8526                	mv	a0,s1
    80005866:	70ea                	ld	ra,184(sp)
    80005868:	744a                	ld	s0,176(sp)
    8000586a:	74aa                	ld	s1,168(sp)
    8000586c:	790a                	ld	s2,160(sp)
    8000586e:	69ea                	ld	s3,152(sp)
    80005870:	6129                	addi	sp,sp,192
    80005872:	8082                	ret
      end_op();
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	9de080e7          	jalr	-1570(ra) # 80004252 <end_op>
      return -1;
    8000587c:	b7e5                	j	80005864 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000587e:	f5040513          	addi	a0,s0,-176
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	744080e7          	jalr	1860(ra) # 80003fc6 <namei>
    8000588a:	892a                	mv	s2,a0
    8000588c:	c905                	beqz	a0,800058bc <sys_open+0x13c>
    ilock(ip);
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	f82080e7          	jalr	-126(ra) # 80003810 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005896:	04c91703          	lh	a4,76(s2)
    8000589a:	4785                	li	a5,1
    8000589c:	f4f712e3          	bne	a4,a5,800057e0 <sys_open+0x60>
    800058a0:	f4c42783          	lw	a5,-180(s0)
    800058a4:	dba1                	beqz	a5,800057f4 <sys_open+0x74>
      iunlockput(ip);
    800058a6:	854a                	mv	a0,s2
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	1ca080e7          	jalr	458(ra) # 80003a72 <iunlockput>
      end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	9a2080e7          	jalr	-1630(ra) # 80004252 <end_op>
      return -1;
    800058b8:	54fd                	li	s1,-1
    800058ba:	b76d                	j	80005864 <sys_open+0xe4>
      end_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	996080e7          	jalr	-1642(ra) # 80004252 <end_op>
      return -1;
    800058c4:	54fd                	li	s1,-1
    800058c6:	bf79                	j	80005864 <sys_open+0xe4>
    iunlockput(ip);
    800058c8:	854a                	mv	a0,s2
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	1a8080e7          	jalr	424(ra) # 80003a72 <iunlockput>
    end_op();
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	980080e7          	jalr	-1664(ra) # 80004252 <end_op>
    return -1;
    800058da:	54fd                	li	s1,-1
    800058dc:	b761                	j	80005864 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058de:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058e2:	04e91783          	lh	a5,78(s2)
    800058e6:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    800058ea:	05091783          	lh	a5,80(s2)
    800058ee:	02f99323          	sh	a5,38(s3)
    800058f2:	b73d                	j	80005820 <sys_open+0xa0>
    itrunc(ip);
    800058f4:	854a                	mv	a0,s2
    800058f6:	ffffe097          	auipc	ra,0xffffe
    800058fa:	028080e7          	jalr	40(ra) # 8000391e <itrunc>
    800058fe:	bf91                	j	80005852 <sys_open+0xd2>
      fileclose(f);
    80005900:	854e                	mv	a0,s3
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	d9a080e7          	jalr	-614(ra) # 8000469c <fileclose>
    iunlockput(ip);
    8000590a:	854a                	mv	a0,s2
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	166080e7          	jalr	358(ra) # 80003a72 <iunlockput>
    end_op();
    80005914:	fffff097          	auipc	ra,0xfffff
    80005918:	93e080e7          	jalr	-1730(ra) # 80004252 <end_op>
    return -1;
    8000591c:	54fd                	li	s1,-1
    8000591e:	b799                	j	80005864 <sys_open+0xe4>

0000000080005920 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005920:	7175                	addi	sp,sp,-144
    80005922:	e506                	sd	ra,136(sp)
    80005924:	e122                	sd	s0,128(sp)
    80005926:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	8aa080e7          	jalr	-1878(ra) # 800041d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005930:	08000613          	li	a2,128
    80005934:	f7040593          	addi	a1,s0,-144
    80005938:	4501                	li	a0,0
    8000593a:	ffffd097          	auipc	ra,0xffffd
    8000593e:	3aa080e7          	jalr	938(ra) # 80002ce4 <argstr>
    80005942:	02054963          	bltz	a0,80005974 <sys_mkdir+0x54>
    80005946:	4681                	li	a3,0
    80005948:	4601                	li	a2,0
    8000594a:	4585                	li	a1,1
    8000594c:	f7040513          	addi	a0,s0,-144
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	7f8080e7          	jalr	2040(ra) # 80005148 <create>
    80005958:	cd11                	beqz	a0,80005974 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	118080e7          	jalr	280(ra) # 80003a72 <iunlockput>
  end_op();
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	8f0080e7          	jalr	-1808(ra) # 80004252 <end_op>
  return 0;
    8000596a:	4501                	li	a0,0
}
    8000596c:	60aa                	ld	ra,136(sp)
    8000596e:	640a                	ld	s0,128(sp)
    80005970:	6149                	addi	sp,sp,144
    80005972:	8082                	ret
    end_op();
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	8de080e7          	jalr	-1826(ra) # 80004252 <end_op>
    return -1;
    8000597c:	557d                	li	a0,-1
    8000597e:	b7fd                	j	8000596c <sys_mkdir+0x4c>

0000000080005980 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005980:	7135                	addi	sp,sp,-160
    80005982:	ed06                	sd	ra,152(sp)
    80005984:	e922                	sd	s0,144(sp)
    80005986:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	84a080e7          	jalr	-1974(ra) # 800041d2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005990:	08000613          	li	a2,128
    80005994:	f7040593          	addi	a1,s0,-144
    80005998:	4501                	li	a0,0
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	34a080e7          	jalr	842(ra) # 80002ce4 <argstr>
    800059a2:	04054a63          	bltz	a0,800059f6 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800059a6:	f6c40593          	addi	a1,s0,-148
    800059aa:	4505                	li	a0,1
    800059ac:	ffffd097          	auipc	ra,0xffffd
    800059b0:	2f4080e7          	jalr	756(ra) # 80002ca0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059b4:	04054163          	bltz	a0,800059f6 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800059b8:	f6840593          	addi	a1,s0,-152
    800059bc:	4509                	li	a0,2
    800059be:	ffffd097          	auipc	ra,0xffffd
    800059c2:	2e2080e7          	jalr	738(ra) # 80002ca0 <argint>
     argint(1, &major) < 0 ||
    800059c6:	02054863          	bltz	a0,800059f6 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059ca:	f6841683          	lh	a3,-152(s0)
    800059ce:	f6c41603          	lh	a2,-148(s0)
    800059d2:	458d                	li	a1,3
    800059d4:	f7040513          	addi	a0,s0,-144
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	770080e7          	jalr	1904(ra) # 80005148 <create>
     argint(2, &minor) < 0 ||
    800059e0:	c919                	beqz	a0,800059f6 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	090080e7          	jalr	144(ra) # 80003a72 <iunlockput>
  end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	868080e7          	jalr	-1944(ra) # 80004252 <end_op>
  return 0;
    800059f2:	4501                	li	a0,0
    800059f4:	a031                	j	80005a00 <sys_mknod+0x80>
    end_op();
    800059f6:	fffff097          	auipc	ra,0xfffff
    800059fa:	85c080e7          	jalr	-1956(ra) # 80004252 <end_op>
    return -1;
    800059fe:	557d                	li	a0,-1
}
    80005a00:	60ea                	ld	ra,152(sp)
    80005a02:	644a                	ld	s0,144(sp)
    80005a04:	610d                	addi	sp,sp,160
    80005a06:	8082                	ret

0000000080005a08 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a08:	7135                	addi	sp,sp,-160
    80005a0a:	ed06                	sd	ra,152(sp)
    80005a0c:	e922                	sd	s0,144(sp)
    80005a0e:	e526                	sd	s1,136(sp)
    80005a10:	e14a                	sd	s2,128(sp)
    80005a12:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	134080e7          	jalr	308(ra) # 80001b48 <myproc>
    80005a1c:	892a                	mv	s2,a0
  
  begin_op();
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	7b4080e7          	jalr	1972(ra) # 800041d2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a26:	08000613          	li	a2,128
    80005a2a:	f6040593          	addi	a1,s0,-160
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	2b4080e7          	jalr	692(ra) # 80002ce4 <argstr>
    80005a38:	04054b63          	bltz	a0,80005a8e <sys_chdir+0x86>
    80005a3c:	f6040513          	addi	a0,s0,-160
    80005a40:	ffffe097          	auipc	ra,0xffffe
    80005a44:	586080e7          	jalr	1414(ra) # 80003fc6 <namei>
    80005a48:	84aa                	mv	s1,a0
    80005a4a:	c131                	beqz	a0,80005a8e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	dc4080e7          	jalr	-572(ra) # 80003810 <ilock>
  if(ip->type != T_DIR){
    80005a54:	04c49703          	lh	a4,76(s1)
    80005a58:	4785                	li	a5,1
    80005a5a:	04f71063          	bne	a4,a5,80005a9a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a5e:	8526                	mv	a0,s1
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	e72080e7          	jalr	-398(ra) # 800038d2 <iunlock>
  iput(p->cwd);
    80005a68:	15893503          	ld	a0,344(s2)
    80005a6c:	ffffe097          	auipc	ra,0xffffe
    80005a70:	f5e080e7          	jalr	-162(ra) # 800039ca <iput>
  end_op();
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	7de080e7          	jalr	2014(ra) # 80004252 <end_op>
  p->cwd = ip;
    80005a7c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005a80:	4501                	li	a0,0
}
    80005a82:	60ea                	ld	ra,152(sp)
    80005a84:	644a                	ld	s0,144(sp)
    80005a86:	64aa                	ld	s1,136(sp)
    80005a88:	690a                	ld	s2,128(sp)
    80005a8a:	610d                	addi	sp,sp,160
    80005a8c:	8082                	ret
    end_op();
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	7c4080e7          	jalr	1988(ra) # 80004252 <end_op>
    return -1;
    80005a96:	557d                	li	a0,-1
    80005a98:	b7ed                	j	80005a82 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	fd6080e7          	jalr	-42(ra) # 80003a72 <iunlockput>
    end_op();
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	7ae080e7          	jalr	1966(ra) # 80004252 <end_op>
    return -1;
    80005aac:	557d                	li	a0,-1
    80005aae:	bfd1                	j	80005a82 <sys_chdir+0x7a>

0000000080005ab0 <sys_exec>:

uint64
sys_exec(void)
{
    80005ab0:	7145                	addi	sp,sp,-464
    80005ab2:	e786                	sd	ra,456(sp)
    80005ab4:	e3a2                	sd	s0,448(sp)
    80005ab6:	ff26                	sd	s1,440(sp)
    80005ab8:	fb4a                	sd	s2,432(sp)
    80005aba:	f74e                	sd	s3,424(sp)
    80005abc:	f352                	sd	s4,416(sp)
    80005abe:	ef56                	sd	s5,408(sp)
    80005ac0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ac2:	08000613          	li	a2,128
    80005ac6:	f4040593          	addi	a1,s0,-192
    80005aca:	4501                	li	a0,0
    80005acc:	ffffd097          	auipc	ra,0xffffd
    80005ad0:	218080e7          	jalr	536(ra) # 80002ce4 <argstr>
    return -1;
    80005ad4:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ad6:	0c054a63          	bltz	a0,80005baa <sys_exec+0xfa>
    80005ada:	e3840593          	addi	a1,s0,-456
    80005ade:	4505                	li	a0,1
    80005ae0:	ffffd097          	auipc	ra,0xffffd
    80005ae4:	1e2080e7          	jalr	482(ra) # 80002cc2 <argaddr>
    80005ae8:	0c054163          	bltz	a0,80005baa <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005aec:	10000613          	li	a2,256
    80005af0:	4581                	li	a1,0
    80005af2:	e4040513          	addi	a0,s0,-448
    80005af6:	ffffb097          	auipc	ra,0xffffb
    80005afa:	380080e7          	jalr	896(ra) # 80000e76 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005afe:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b02:	89a6                	mv	s3,s1
    80005b04:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b06:	02000a13          	li	s4,32
    80005b0a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b0e:	00391793          	slli	a5,s2,0x3
    80005b12:	e3040593          	addi	a1,s0,-464
    80005b16:	e3843503          	ld	a0,-456(s0)
    80005b1a:	953e                	add	a0,a0,a5
    80005b1c:	ffffd097          	auipc	ra,0xffffd
    80005b20:	0ea080e7          	jalr	234(ra) # 80002c06 <fetchaddr>
    80005b24:	02054a63          	bltz	a0,80005b58 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b28:	e3043783          	ld	a5,-464(s0)
    80005b2c:	c3b9                	beqz	a5,80005b72 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b2e:	ffffb097          	auipc	ra,0xffffb
    80005b32:	f14080e7          	jalr	-236(ra) # 80000a42 <kalloc>
    80005b36:	85aa                	mv	a1,a0
    80005b38:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b3c:	cd11                	beqz	a0,80005b58 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b3e:	6605                	lui	a2,0x1
    80005b40:	e3043503          	ld	a0,-464(s0)
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	114080e7          	jalr	276(ra) # 80002c58 <fetchstr>
    80005b4c:	00054663          	bltz	a0,80005b58 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b50:	0905                	addi	s2,s2,1
    80005b52:	09a1                	addi	s3,s3,8
    80005b54:	fb491be3          	bne	s2,s4,80005b0a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b58:	10048913          	addi	s2,s1,256
    80005b5c:	6088                	ld	a0,0(s1)
    80005b5e:	c529                	beqz	a0,80005ba8 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b60:	ffffb097          	auipc	ra,0xffffb
    80005b64:	ddc080e7          	jalr	-548(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b68:	04a1                	addi	s1,s1,8
    80005b6a:	ff2499e3          	bne	s1,s2,80005b5c <sys_exec+0xac>
  return -1;
    80005b6e:	597d                	li	s2,-1
    80005b70:	a82d                	j	80005baa <sys_exec+0xfa>
      argv[i] = 0;
    80005b72:	0a8e                	slli	s5,s5,0x3
    80005b74:	fc040793          	addi	a5,s0,-64
    80005b78:	9abe                	add	s5,s5,a5
    80005b7a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc8990>
  int ret = exec(path, argv);
    80005b7e:	e4040593          	addi	a1,s0,-448
    80005b82:	f4040513          	addi	a0,s0,-192
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	170080e7          	jalr	368(ra) # 80004cf6 <exec>
    80005b8e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b90:	10048993          	addi	s3,s1,256
    80005b94:	6088                	ld	a0,0(s1)
    80005b96:	c911                	beqz	a0,80005baa <sys_exec+0xfa>
    kfree(argv[i]);
    80005b98:	ffffb097          	auipc	ra,0xffffb
    80005b9c:	da4080e7          	jalr	-604(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba0:	04a1                	addi	s1,s1,8
    80005ba2:	ff3499e3          	bne	s1,s3,80005b94 <sys_exec+0xe4>
    80005ba6:	a011                	j	80005baa <sys_exec+0xfa>
  return -1;
    80005ba8:	597d                	li	s2,-1
}
    80005baa:	854a                	mv	a0,s2
    80005bac:	60be                	ld	ra,456(sp)
    80005bae:	641e                	ld	s0,448(sp)
    80005bb0:	74fa                	ld	s1,440(sp)
    80005bb2:	795a                	ld	s2,432(sp)
    80005bb4:	79ba                	ld	s3,424(sp)
    80005bb6:	7a1a                	ld	s4,416(sp)
    80005bb8:	6afa                	ld	s5,408(sp)
    80005bba:	6179                	addi	sp,sp,464
    80005bbc:	8082                	ret

0000000080005bbe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bbe:	7139                	addi	sp,sp,-64
    80005bc0:	fc06                	sd	ra,56(sp)
    80005bc2:	f822                	sd	s0,48(sp)
    80005bc4:	f426                	sd	s1,40(sp)
    80005bc6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bc8:	ffffc097          	auipc	ra,0xffffc
    80005bcc:	f80080e7          	jalr	-128(ra) # 80001b48 <myproc>
    80005bd0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005bd2:	fd840593          	addi	a1,s0,-40
    80005bd6:	4501                	li	a0,0
    80005bd8:	ffffd097          	auipc	ra,0xffffd
    80005bdc:	0ea080e7          	jalr	234(ra) # 80002cc2 <argaddr>
    return -1;
    80005be0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005be2:	0e054063          	bltz	a0,80005cc2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005be6:	fc840593          	addi	a1,s0,-56
    80005bea:	fd040513          	addi	a0,s0,-48
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	de6080e7          	jalr	-538(ra) # 800049d4 <pipealloc>
    return -1;
    80005bf6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bf8:	0c054563          	bltz	a0,80005cc2 <sys_pipe+0x104>
  fd0 = -1;
    80005bfc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c00:	fd043503          	ld	a0,-48(s0)
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	502080e7          	jalr	1282(ra) # 80005106 <fdalloc>
    80005c0c:	fca42223          	sw	a0,-60(s0)
    80005c10:	08054c63          	bltz	a0,80005ca8 <sys_pipe+0xea>
    80005c14:	fc843503          	ld	a0,-56(s0)
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	4ee080e7          	jalr	1262(ra) # 80005106 <fdalloc>
    80005c20:	fca42023          	sw	a0,-64(s0)
    80005c24:	06054863          	bltz	a0,80005c94 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c28:	4691                	li	a3,4
    80005c2a:	fc440613          	addi	a2,s0,-60
    80005c2e:	fd843583          	ld	a1,-40(s0)
    80005c32:	6ca8                	ld	a0,88(s1)
    80005c34:	ffffc097          	auipc	ra,0xffffc
    80005c38:	bcc080e7          	jalr	-1076(ra) # 80001800 <copyout>
    80005c3c:	02054063          	bltz	a0,80005c5c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c40:	4691                	li	a3,4
    80005c42:	fc040613          	addi	a2,s0,-64
    80005c46:	fd843583          	ld	a1,-40(s0)
    80005c4a:	0591                	addi	a1,a1,4
    80005c4c:	6ca8                	ld	a0,88(s1)
    80005c4e:	ffffc097          	auipc	ra,0xffffc
    80005c52:	bb2080e7          	jalr	-1102(ra) # 80001800 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c56:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c58:	06055563          	bgez	a0,80005cc2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c5c:	fc442783          	lw	a5,-60(s0)
    80005c60:	07e9                	addi	a5,a5,26
    80005c62:	078e                	slli	a5,a5,0x3
    80005c64:	97a6                	add	a5,a5,s1
    80005c66:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005c6a:	fc042503          	lw	a0,-64(s0)
    80005c6e:	0569                	addi	a0,a0,26
    80005c70:	050e                	slli	a0,a0,0x3
    80005c72:	9526                	add	a0,a0,s1
    80005c74:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005c78:	fd043503          	ld	a0,-48(s0)
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	a20080e7          	jalr	-1504(ra) # 8000469c <fileclose>
    fileclose(wf);
    80005c84:	fc843503          	ld	a0,-56(s0)
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	a14080e7          	jalr	-1516(ra) # 8000469c <fileclose>
    return -1;
    80005c90:	57fd                	li	a5,-1
    80005c92:	a805                	j	80005cc2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c94:	fc442783          	lw	a5,-60(s0)
    80005c98:	0007c863          	bltz	a5,80005ca8 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c9c:	01a78513          	addi	a0,a5,26
    80005ca0:	050e                	slli	a0,a0,0x3
    80005ca2:	9526                	add	a0,a0,s1
    80005ca4:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005ca8:	fd043503          	ld	a0,-48(s0)
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	9f0080e7          	jalr	-1552(ra) # 8000469c <fileclose>
    fileclose(wf);
    80005cb4:	fc843503          	ld	a0,-56(s0)
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	9e4080e7          	jalr	-1564(ra) # 8000469c <fileclose>
    return -1;
    80005cc0:	57fd                	li	a5,-1
}
    80005cc2:	853e                	mv	a0,a5
    80005cc4:	70e2                	ld	ra,56(sp)
    80005cc6:	7442                	ld	s0,48(sp)
    80005cc8:	74a2                	ld	s1,40(sp)
    80005cca:	6121                	addi	sp,sp,64
    80005ccc:	8082                	ret
	...

0000000080005cd0 <kernelvec>:
    80005cd0:	7111                	addi	sp,sp,-256
    80005cd2:	e006                	sd	ra,0(sp)
    80005cd4:	e40a                	sd	sp,8(sp)
    80005cd6:	e80e                	sd	gp,16(sp)
    80005cd8:	ec12                	sd	tp,24(sp)
    80005cda:	f016                	sd	t0,32(sp)
    80005cdc:	f41a                	sd	t1,40(sp)
    80005cde:	f81e                	sd	t2,48(sp)
    80005ce0:	fc22                	sd	s0,56(sp)
    80005ce2:	e0a6                	sd	s1,64(sp)
    80005ce4:	e4aa                	sd	a0,72(sp)
    80005ce6:	e8ae                	sd	a1,80(sp)
    80005ce8:	ecb2                	sd	a2,88(sp)
    80005cea:	f0b6                	sd	a3,96(sp)
    80005cec:	f4ba                	sd	a4,104(sp)
    80005cee:	f8be                	sd	a5,112(sp)
    80005cf0:	fcc2                	sd	a6,120(sp)
    80005cf2:	e146                	sd	a7,128(sp)
    80005cf4:	e54a                	sd	s2,136(sp)
    80005cf6:	e94e                	sd	s3,144(sp)
    80005cf8:	ed52                	sd	s4,152(sp)
    80005cfa:	f156                	sd	s5,160(sp)
    80005cfc:	f55a                	sd	s6,168(sp)
    80005cfe:	f95e                	sd	s7,176(sp)
    80005d00:	fd62                	sd	s8,184(sp)
    80005d02:	e1e6                	sd	s9,192(sp)
    80005d04:	e5ea                	sd	s10,200(sp)
    80005d06:	e9ee                	sd	s11,208(sp)
    80005d08:	edf2                	sd	t3,216(sp)
    80005d0a:	f1f6                	sd	t4,224(sp)
    80005d0c:	f5fa                	sd	t5,232(sp)
    80005d0e:	f9fe                	sd	t6,240(sp)
    80005d10:	db7fc0ef          	jal	ra,80002ac6 <kerneltrap>
    80005d14:	6082                	ld	ra,0(sp)
    80005d16:	6122                	ld	sp,8(sp)
    80005d18:	61c2                	ld	gp,16(sp)
    80005d1a:	7282                	ld	t0,32(sp)
    80005d1c:	7322                	ld	t1,40(sp)
    80005d1e:	73c2                	ld	t2,48(sp)
    80005d20:	7462                	ld	s0,56(sp)
    80005d22:	6486                	ld	s1,64(sp)
    80005d24:	6526                	ld	a0,72(sp)
    80005d26:	65c6                	ld	a1,80(sp)
    80005d28:	6666                	ld	a2,88(sp)
    80005d2a:	7686                	ld	a3,96(sp)
    80005d2c:	7726                	ld	a4,104(sp)
    80005d2e:	77c6                	ld	a5,112(sp)
    80005d30:	7866                	ld	a6,120(sp)
    80005d32:	688a                	ld	a7,128(sp)
    80005d34:	692a                	ld	s2,136(sp)
    80005d36:	69ca                	ld	s3,144(sp)
    80005d38:	6a6a                	ld	s4,152(sp)
    80005d3a:	7a8a                	ld	s5,160(sp)
    80005d3c:	7b2a                	ld	s6,168(sp)
    80005d3e:	7bca                	ld	s7,176(sp)
    80005d40:	7c6a                	ld	s8,184(sp)
    80005d42:	6c8e                	ld	s9,192(sp)
    80005d44:	6d2e                	ld	s10,200(sp)
    80005d46:	6dce                	ld	s11,208(sp)
    80005d48:	6e6e                	ld	t3,216(sp)
    80005d4a:	7e8e                	ld	t4,224(sp)
    80005d4c:	7f2e                	ld	t5,232(sp)
    80005d4e:	7fce                	ld	t6,240(sp)
    80005d50:	6111                	addi	sp,sp,256
    80005d52:	10200073          	sret
    80005d56:	00000013          	nop
    80005d5a:	00000013          	nop
    80005d5e:	0001                	nop

0000000080005d60 <timervec>:
    80005d60:	34051573          	csrrw	a0,mscratch,a0
    80005d64:	e10c                	sd	a1,0(a0)
    80005d66:	e510                	sd	a2,8(a0)
    80005d68:	e914                	sd	a3,16(a0)
    80005d6a:	6d0c                	ld	a1,24(a0)
    80005d6c:	7110                	ld	a2,32(a0)
    80005d6e:	6194                	ld	a3,0(a1)
    80005d70:	96b2                	add	a3,a3,a2
    80005d72:	e194                	sd	a3,0(a1)
    80005d74:	4589                	li	a1,2
    80005d76:	14459073          	csrw	sip,a1
    80005d7a:	6914                	ld	a3,16(a0)
    80005d7c:	6510                	ld	a2,8(a0)
    80005d7e:	610c                	ld	a1,0(a0)
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	30200073          	mret
	...

0000000080005d8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d8a:	1141                	addi	sp,sp,-16
    80005d8c:	e422                	sd	s0,8(sp)
    80005d8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d90:	0c0007b7          	lui	a5,0xc000
    80005d94:	4705                	li	a4,1
    80005d96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d98:	c3d8                	sw	a4,4(a5)
}
    80005d9a:	6422                	ld	s0,8(sp)
    80005d9c:	0141                	addi	sp,sp,16
    80005d9e:	8082                	ret

0000000080005da0 <plicinithart>:

void
plicinithart(void)
{
    80005da0:	1141                	addi	sp,sp,-16
    80005da2:	e406                	sd	ra,8(sp)
    80005da4:	e022                	sd	s0,0(sp)
    80005da6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	d74080e7          	jalr	-652(ra) # 80001b1c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005db0:	0085171b          	slliw	a4,a0,0x8
    80005db4:	0c0027b7          	lui	a5,0xc002
    80005db8:	97ba                	add	a5,a5,a4
    80005dba:	40200713          	li	a4,1026
    80005dbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005dc2:	00d5151b          	slliw	a0,a0,0xd
    80005dc6:	0c2017b7          	lui	a5,0xc201
    80005dca:	953e                	add	a0,a0,a5
    80005dcc:	00052023          	sw	zero,0(a0)
}
    80005dd0:	60a2                	ld	ra,8(sp)
    80005dd2:	6402                	ld	s0,0(sp)
    80005dd4:	0141                	addi	sp,sp,16
    80005dd6:	8082                	ret

0000000080005dd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005dd8:	1141                	addi	sp,sp,-16
    80005dda:	e406                	sd	ra,8(sp)
    80005ddc:	e022                	sd	s0,0(sp)
    80005dde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005de0:	ffffc097          	auipc	ra,0xffffc
    80005de4:	d3c080e7          	jalr	-708(ra) # 80001b1c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005de8:	00d5179b          	slliw	a5,a0,0xd
    80005dec:	0c201537          	lui	a0,0xc201
    80005df0:	953e                	add	a0,a0,a5
  return irq;
}
    80005df2:	4148                	lw	a0,4(a0)
    80005df4:	60a2                	ld	ra,8(sp)
    80005df6:	6402                	ld	s0,0(sp)
    80005df8:	0141                	addi	sp,sp,16
    80005dfa:	8082                	ret

0000000080005dfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dfc:	1101                	addi	sp,sp,-32
    80005dfe:	ec06                	sd	ra,24(sp)
    80005e00:	e822                	sd	s0,16(sp)
    80005e02:	e426                	sd	s1,8(sp)
    80005e04:	1000                	addi	s0,sp,32
    80005e06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	d14080e7          	jalr	-748(ra) # 80001b1c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e10:	00d5151b          	slliw	a0,a0,0xd
    80005e14:	0c2017b7          	lui	a5,0xc201
    80005e18:	97aa                	add	a5,a5,a0
    80005e1a:	c3c4                	sw	s1,4(a5)
}
    80005e1c:	60e2                	ld	ra,24(sp)
    80005e1e:	6442                	ld	s0,16(sp)
    80005e20:	64a2                	ld	s1,8(sp)
    80005e22:	6105                	addi	sp,sp,32
    80005e24:	8082                	ret

0000000080005e26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e26:	1141                	addi	sp,sp,-16
    80005e28:	e406                	sd	ra,8(sp)
    80005e2a:	e022                	sd	s0,0(sp)
    80005e2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e2e:	479d                	li	a5,7
    80005e30:	04a7c463          	blt	a5,a0,80005e78 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005e34:	00030797          	auipc	a5,0x30
    80005e38:	55478793          	addi	a5,a5,1364 # 80036388 <disk>
    80005e3c:	97aa                	add	a5,a5,a0
    80005e3e:	0187c783          	lbu	a5,24(a5)
    80005e42:	e3b9                	bnez	a5,80005e88 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e44:	00030797          	auipc	a5,0x30
    80005e48:	54478793          	addi	a5,a5,1348 # 80036388 <disk>
    80005e4c:	6398                	ld	a4,0(a5)
    80005e4e:	00451693          	slli	a3,a0,0x4
    80005e52:	9736                	add	a4,a4,a3
    80005e54:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005e58:	953e                	add	a0,a0,a5
    80005e5a:	4785                	li	a5,1
    80005e5c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005e60:	00030517          	auipc	a0,0x30
    80005e64:	54050513          	addi	a0,a0,1344 # 800363a0 <disk+0x18>
    80005e68:	ffffc097          	auipc	ra,0xffffc
    80005e6c:	670080e7          	jalr	1648(ra) # 800024d8 <wakeup>
}
    80005e70:	60a2                	ld	ra,8(sp)
    80005e72:	6402                	ld	s0,0(sp)
    80005e74:	0141                	addi	sp,sp,16
    80005e76:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e78:	00003517          	auipc	a0,0x3
    80005e7c:	de850513          	addi	a0,a0,-536 # 80008c60 <syscalls+0x330>
    80005e80:	ffffa097          	auipc	ra,0xffffa
    80005e84:	6e4080e7          	jalr	1764(ra) # 80000564 <panic>
    panic("virtio_disk_intr 2");
    80005e88:	00003517          	auipc	a0,0x3
    80005e8c:	df050513          	addi	a0,a0,-528 # 80008c78 <syscalls+0x348>
    80005e90:	ffffa097          	auipc	ra,0xffffa
    80005e94:	6d4080e7          	jalr	1748(ra) # 80000564 <panic>

0000000080005e98 <virtio_disk_init>:
{
    80005e98:	1101                	addi	sp,sp,-32
    80005e9a:	ec06                	sd	ra,24(sp)
    80005e9c:	e822                	sd	s0,16(sp)
    80005e9e:	e426                	sd	s1,8(sp)
    80005ea0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ea2:	00030497          	auipc	s1,0x30
    80005ea6:	4e648493          	addi	s1,s1,1254 # 80036388 <disk>
    80005eaa:	00003597          	auipc	a1,0x3
    80005eae:	de658593          	addi	a1,a1,-538 # 80008c90 <syscalls+0x360>
    80005eb2:	00030517          	auipc	a0,0x30
    80005eb6:	5fe50513          	addi	a0,a0,1534 # 800364b0 <disk+0x128>
    80005eba:	ffffb097          	auipc	ra,0xffffb
    80005ebe:	c02080e7          	jalr	-1022(ra) # 80000abc <initlock>
  disk.desc = kalloc();
    80005ec2:	ffffb097          	auipc	ra,0xffffb
    80005ec6:	b80080e7          	jalr	-1152(ra) # 80000a42 <kalloc>
    80005eca:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ecc:	ffffb097          	auipc	ra,0xffffb
    80005ed0:	b76080e7          	jalr	-1162(ra) # 80000a42 <kalloc>
    80005ed4:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005ed6:	ffffb097          	auipc	ra,0xffffb
    80005eda:	b6c080e7          	jalr	-1172(ra) # 80000a42 <kalloc>
    80005ede:	87aa                	mv	a5,a0
    80005ee0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005ee2:	6088                	ld	a0,0(s1)
    80005ee4:	14050163          	beqz	a0,80006026 <virtio_disk_init+0x18e>
    80005ee8:	00030717          	auipc	a4,0x30
    80005eec:	4a873703          	ld	a4,1192(a4) # 80036390 <disk+0x8>
    80005ef0:	12070b63          	beqz	a4,80006026 <virtio_disk_init+0x18e>
    80005ef4:	12078963          	beqz	a5,80006026 <virtio_disk_init+0x18e>
  memset(disk.desc, 0, PGSIZE);
    80005ef8:	6605                	lui	a2,0x1
    80005efa:	4581                	li	a1,0
    80005efc:	ffffb097          	auipc	ra,0xffffb
    80005f00:	f7a080e7          	jalr	-134(ra) # 80000e76 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f04:	00030497          	auipc	s1,0x30
    80005f08:	48448493          	addi	s1,s1,1156 # 80036388 <disk>
    80005f0c:	6605                	lui	a2,0x1
    80005f0e:	4581                	li	a1,0
    80005f10:	6488                	ld	a0,8(s1)
    80005f12:	ffffb097          	auipc	ra,0xffffb
    80005f16:	f64080e7          	jalr	-156(ra) # 80000e76 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f1a:	6605                	lui	a2,0x1
    80005f1c:	4581                	li	a1,0
    80005f1e:	6888                	ld	a0,16(s1)
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	f56080e7          	jalr	-170(ra) # 80000e76 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f28:	100017b7          	lui	a5,0x10001
    80005f2c:	4398                	lw	a4,0(a5)
    80005f2e:	2701                	sext.w	a4,a4
    80005f30:	747277b7          	lui	a5,0x74727
    80005f34:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005f38:	0ef71f63          	bne	a4,a5,80006036 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f3c:	100017b7          	lui	a5,0x10001
    80005f40:	43dc                	lw	a5,4(a5)
    80005f42:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f44:	4709                	li	a4,2
    80005f46:	0ee79863          	bne	a5,a4,80006036 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f4a:	100017b7          	lui	a5,0x10001
    80005f4e:	479c                	lw	a5,8(a5)
    80005f50:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f52:	0ee79263          	bne	a5,a4,80006036 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f56:	100017b7          	lui	a5,0x10001
    80005f5a:	47d8                	lw	a4,12(a5)
    80005f5c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f5e:	554d47b7          	lui	a5,0x554d4
    80005f62:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f66:	0cf71863          	bne	a4,a5,80006036 <virtio_disk_init+0x19e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f6a:	100017b7          	lui	a5,0x10001
    80005f6e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f72:	4705                	li	a4,1
    80005f74:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f76:	470d                	li	a4,3
    80005f78:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f7a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005f7c:	c7ffe737          	lui	a4,0xc7ffe
    80005f80:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc826f>
    80005f84:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f86:	2701                	sext.w	a4,a4
    80005f88:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f8a:	472d                	li	a4,11
    80005f8c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f8e:	5bbc                	lw	a5,112(a5)
    80005f90:	0007861b          	sext.w	a2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f94:	8ba1                	andi	a5,a5,8
    80005f96:	cbc5                	beqz	a5,80006046 <virtio_disk_init+0x1ae>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f98:	100017b7          	lui	a5,0x10001
    80005f9c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005fa0:	43fc                	lw	a5,68(a5)
    80005fa2:	2781                	sext.w	a5,a5
    80005fa4:	ebcd                	bnez	a5,80006056 <virtio_disk_init+0x1be>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005fa6:	100017b7          	lui	a5,0x10001
    80005faa:	5bdc                	lw	a5,52(a5)
    80005fac:	2781                	sext.w	a5,a5
  if(max == 0)
    80005fae:	cfc5                	beqz	a5,80006066 <virtio_disk_init+0x1ce>
  if(max < NUM)
    80005fb0:	471d                	li	a4,7
    80005fb2:	0cf77263          	bgeu	a4,a5,80006076 <virtio_disk_init+0x1de>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005fb6:	10001737          	lui	a4,0x10001
    80005fba:	47a1                	li	a5,8
    80005fbc:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    80005fbe:	00030797          	auipc	a5,0x30
    80005fc2:	3ca78793          	addi	a5,a5,970 # 80036388 <disk>
    80005fc6:	4394                	lw	a3,0(a5)
    80005fc8:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    80005fcc:	43d4                	lw	a3,4(a5)
    80005fce:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    80005fd2:	6794                	ld	a3,8(a5)
    80005fd4:	0006859b          	sext.w	a1,a3
    80005fd8:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005fdc:	9681                	srai	a3,a3,0x20
    80005fde:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    80005fe2:	6b94                	ld	a3,16(a5)
    80005fe4:	0006859b          	sext.w	a1,a3
    80005fe8:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005fec:	9681                	srai	a3,a3,0x20
    80005fee:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005ff2:	4685                	li	a3,1
    80005ff4:	c374                	sw	a3,68(a4)
    disk.free[i] = 1;
    80005ff6:	00d78c23          	sb	a3,24(a5)
    80005ffa:	00d78ca3          	sb	a3,25(a5)
    80005ffe:	00d78d23          	sb	a3,26(a5)
    80006002:	00d78da3          	sb	a3,27(a5)
    80006006:	00d78e23          	sb	a3,28(a5)
    8000600a:	00d78ea3          	sb	a3,29(a5)
    8000600e:	00d78f23          	sb	a3,30(a5)
    80006012:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006016:	00466793          	ori	a5,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601a:	db3c                	sw	a5,112(a4)
}
    8000601c:	60e2                	ld	ra,24(sp)
    8000601e:	6442                	ld	s0,16(sp)
    80006020:	64a2                	ld	s1,8(sp)
    80006022:	6105                	addi	sp,sp,32
    80006024:	8082                	ret
    panic("virtio disk kalloc");
    80006026:	00003517          	auipc	a0,0x3
    8000602a:	c7a50513          	addi	a0,a0,-902 # 80008ca0 <syscalls+0x370>
    8000602e:	ffffa097          	auipc	ra,0xffffa
    80006032:	536080e7          	jalr	1334(ra) # 80000564 <panic>
    panic("could not find virtio disk");
    80006036:	00003517          	auipc	a0,0x3
    8000603a:	c8250513          	addi	a0,a0,-894 # 80008cb8 <syscalls+0x388>
    8000603e:	ffffa097          	auipc	ra,0xffffa
    80006042:	526080e7          	jalr	1318(ra) # 80000564 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006046:	00003517          	auipc	a0,0x3
    8000604a:	c9250513          	addi	a0,a0,-878 # 80008cd8 <syscalls+0x3a8>
    8000604e:	ffffa097          	auipc	ra,0xffffa
    80006052:	516080e7          	jalr	1302(ra) # 80000564 <panic>
    panic("virtio disk ready not zero");
    80006056:	00003517          	auipc	a0,0x3
    8000605a:	ca250513          	addi	a0,a0,-862 # 80008cf8 <syscalls+0x3c8>
    8000605e:	ffffa097          	auipc	ra,0xffffa
    80006062:	506080e7          	jalr	1286(ra) # 80000564 <panic>
    panic("virtio disk has no queue 0");
    80006066:	00003517          	auipc	a0,0x3
    8000606a:	cb250513          	addi	a0,a0,-846 # 80008d18 <syscalls+0x3e8>
    8000606e:	ffffa097          	auipc	ra,0xffffa
    80006072:	4f6080e7          	jalr	1270(ra) # 80000564 <panic>
    panic("virtio disk max queue too short");
    80006076:	00003517          	auipc	a0,0x3
    8000607a:	cc250513          	addi	a0,a0,-830 # 80008d38 <syscalls+0x408>
    8000607e:	ffffa097          	auipc	ra,0xffffa
    80006082:	4e6080e7          	jalr	1254(ra) # 80000564 <panic>

0000000080006086 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006086:	7119                	addi	sp,sp,-128
    80006088:	fc86                	sd	ra,120(sp)
    8000608a:	f8a2                	sd	s0,112(sp)
    8000608c:	f4a6                	sd	s1,104(sp)
    8000608e:	f0ca                	sd	s2,96(sp)
    80006090:	ecce                	sd	s3,88(sp)
    80006092:	e8d2                	sd	s4,80(sp)
    80006094:	e4d6                	sd	s5,72(sp)
    80006096:	e0da                	sd	s6,64(sp)
    80006098:	fc5e                	sd	s7,56(sp)
    8000609a:	f862                	sd	s8,48(sp)
    8000609c:	f466                	sd	s9,40(sp)
    8000609e:	f06a                	sd	s10,32(sp)
    800060a0:	ec6e                	sd	s11,24(sp)
    800060a2:	0100                	addi	s0,sp,128
    800060a4:	8aaa                	mv	s5,a0
    800060a6:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060a8:	00c52d03          	lw	s10,12(a0)
    800060ac:	001d1d1b          	slliw	s10,s10,0x1
    800060b0:	1d02                	slli	s10,s10,0x20
    800060b2:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800060b6:	00030517          	auipc	a0,0x30
    800060ba:	3fa50513          	addi	a0,a0,1018 # 800364b0 <disk+0x128>
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	ad4080e7          	jalr	-1324(ra) # 80000b92 <acquire>
  for(int i = 0; i < 3; i++){
    800060c6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800060c8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800060ca:	00030b97          	auipc	s7,0x30
    800060ce:	2beb8b93          	addi	s7,s7,702 # 80036388 <disk>
  for(int i = 0; i < 3; i++){
    800060d2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060d4:	00030c97          	auipc	s9,0x30
    800060d8:	3dcc8c93          	addi	s9,s9,988 # 800364b0 <disk+0x128>
    800060dc:	a08d                	j	8000613e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800060de:	00fb8733          	add	a4,s7,a5
    800060e2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800060e6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800060e8:	0207c563          	bltz	a5,80006112 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800060ec:	2905                	addiw	s2,s2,1
    800060ee:	0611                	addi	a2,a2,4
    800060f0:	0b690263          	beq	s2,s6,80006194 <virtio_disk_rw+0x10e>
    idx[i] = alloc_desc();
    800060f4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800060f6:	00030717          	auipc	a4,0x30
    800060fa:	29270713          	addi	a4,a4,658 # 80036388 <disk>
    800060fe:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006100:	01874683          	lbu	a3,24(a4)
    80006104:	fee9                	bnez	a3,800060de <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006106:	2785                	addiw	a5,a5,1
    80006108:	0705                	addi	a4,a4,1
    8000610a:	fe979be3          	bne	a5,s1,80006100 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000610e:	57fd                	li	a5,-1
    80006110:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006112:	01205d63          	blez	s2,8000612c <virtio_disk_rw+0xa6>
    80006116:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006118:	000a2503          	lw	a0,0(s4)
    8000611c:	00000097          	auipc	ra,0x0
    80006120:	d0a080e7          	jalr	-758(ra) # 80005e26 <free_desc>
      for(int j = 0; j < i; j++)
    80006124:	2d85                	addiw	s11,s11,1
    80006126:	0a11                	addi	s4,s4,4
    80006128:	ffb918e3          	bne	s2,s11,80006118 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000612c:	85e6                	mv	a1,s9
    8000612e:	00030517          	auipc	a0,0x30
    80006132:	27250513          	addi	a0,a0,626 # 800363a0 <disk+0x18>
    80006136:	ffffc097          	auipc	ra,0xffffc
    8000613a:	222080e7          	jalr	546(ra) # 80002358 <sleep>
  for(int i = 0; i < 3; i++){
    8000613e:	f8040a13          	addi	s4,s0,-128
{
    80006142:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006144:	894e                	mv	s2,s3
    80006146:	b77d                	j	800060f4 <virtio_disk_rw+0x6e>
      i = disk.desc[i].next;
    80006148:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000614c:	8526                	mv	a0,s1
    8000614e:	00000097          	auipc	ra,0x0
    80006152:	cd8080e7          	jalr	-808(ra) # 80005e26 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    80006156:	0492                	slli	s1,s1,0x4
    80006158:	00093783          	ld	a5,0(s2)
    8000615c:	94be                	add	s1,s1,a5
    8000615e:	00c4d783          	lhu	a5,12(s1)
    80006162:	8b85                	andi	a5,a5,1
    80006164:	f3f5                	bnez	a5,80006148 <virtio_disk_rw+0xc2>
  }

  disk.info[idx[0]].b = 0;
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006166:	00030517          	auipc	a0,0x30
    8000616a:	34a50513          	addi	a0,a0,842 # 800364b0 <disk+0x128>
    8000616e:	ffffb097          	auipc	ra,0xffffb
    80006172:	af4080e7          	jalr	-1292(ra) # 80000c62 <release>
}
    80006176:	70e6                	ld	ra,120(sp)
    80006178:	7446                	ld	s0,112(sp)
    8000617a:	74a6                	ld	s1,104(sp)
    8000617c:	7906                	ld	s2,96(sp)
    8000617e:	69e6                	ld	s3,88(sp)
    80006180:	6a46                	ld	s4,80(sp)
    80006182:	6aa6                	ld	s5,72(sp)
    80006184:	6b06                	ld	s6,64(sp)
    80006186:	7be2                	ld	s7,56(sp)
    80006188:	7c42                	ld	s8,48(sp)
    8000618a:	7ca2                	ld	s9,40(sp)
    8000618c:	7d02                	ld	s10,32(sp)
    8000618e:	6de2                	ld	s11,24(sp)
    80006190:	6109                	addi	sp,sp,128
    80006192:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006194:	f8042583          	lw	a1,-128(s0)
    80006198:	00a58793          	addi	a5,a1,10
    8000619c:	0792                	slli	a5,a5,0x4
  if(write)
    8000619e:	00030617          	auipc	a2,0x30
    800061a2:	1ea60613          	addi	a2,a2,490 # 80036388 <disk>
    800061a6:	00f60733          	add	a4,a2,a5
    800061aa:	018036b3          	snez	a3,s8
    800061ae:	c714                	sw	a3,8(a4)
  buf0->reserved = 0;
    800061b0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800061b4:	01a73823          	sd	s10,16(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061b8:	f6078693          	addi	a3,a5,-160
    800061bc:	6218                	ld	a4,0(a2)
    800061be:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061c0:	00878513          	addi	a0,a5,8
    800061c4:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061c6:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061c8:	6208                	ld	a0,0(a2)
    800061ca:	96aa                	add	a3,a3,a0
    800061cc:	4741                	li	a4,16
    800061ce:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    800061d0:	4705                	li	a4,1
    800061d2:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800061d6:	f8442703          	lw	a4,-124(s0)
    800061da:	00e69723          	sh	a4,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061de:	0712                	slli	a4,a4,0x4
    800061e0:	953a                	add	a0,a0,a4
    800061e2:	060a8693          	addi	a3,s5,96
    800061e6:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800061e8:	6208                	ld	a0,0(a2)
    800061ea:	972a                	add	a4,a4,a0
    800061ec:	40000693          	li	a3,1024
    800061f0:	c714                	sw	a3,8(a4)
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    800061f2:	001c3c13          	seqz	s8,s8
    800061f6:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    800061f8:	001c6c13          	ori	s8,s8,1
    800061fc:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006200:	f8842603          	lw	a2,-120(s0)
    80006204:	00c71723          	sh	a2,14(a4)
  disk.info[idx[0]].status = 0;
    80006208:	00030697          	auipc	a3,0x30
    8000620c:	18068693          	addi	a3,a3,384 # 80036388 <disk>
    80006210:	00258713          	addi	a4,a1,2
    80006214:	0712                	slli	a4,a4,0x4
    80006216:	9736                	add	a4,a4,a3
    80006218:	00070823          	sb	zero,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000621c:	0612                	slli	a2,a2,0x4
    8000621e:	9532                	add	a0,a0,a2
    80006220:	f9078793          	addi	a5,a5,-112
    80006224:	97b6                	add	a5,a5,a3
    80006226:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006228:	629c                	ld	a5,0(a3)
    8000622a:	97b2                	add	a5,a5,a2
    8000622c:	4605                	li	a2,1
    8000622e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    80006230:	4509                	li	a0,2
    80006232:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80006236:	00079723          	sh	zero,14(a5)
  b->disk = 1;
    8000623a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000623e:	01573423          	sd	s5,8(a4)
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006242:	6698                	ld	a4,8(a3)
    80006244:	00275783          	lhu	a5,2(a4)
    80006248:	8b9d                	andi	a5,a5,7
    8000624a:	0786                	slli	a5,a5,0x1
    8000624c:	97ba                	add	a5,a5,a4
    8000624e:	00b79223          	sh	a1,4(a5)
  __sync_synchronize();
    80006252:	0ff0000f          	fence
  disk.avail->idx += 1;
    80006256:	6698                	ld	a4,8(a3)
    80006258:	00275783          	lhu	a5,2(a4)
    8000625c:	2785                	addiw	a5,a5,1
    8000625e:	00f71123          	sh	a5,2(a4)
  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006262:	100017b7          	lui	a5,0x10001
    80006266:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
  while(b->disk == 1) {
    8000626a:	004aa783          	lw	a5,4(s5)
    8000626e:	02c79163          	bne	a5,a2,80006290 <virtio_disk_rw+0x20a>
    sleep(b, &disk.vdisk_lock);
    80006272:	00030917          	auipc	s2,0x30
    80006276:	23e90913          	addi	s2,s2,574 # 800364b0 <disk+0x128>
  while(b->disk == 1) {
    8000627a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000627c:	85ca                	mv	a1,s2
    8000627e:	8556                	mv	a0,s5
    80006280:	ffffc097          	auipc	ra,0xffffc
    80006284:	0d8080e7          	jalr	216(ra) # 80002358 <sleep>
  while(b->disk == 1) {
    80006288:	004aa783          	lw	a5,4(s5)
    8000628c:	fe9788e3          	beq	a5,s1,8000627c <virtio_disk_rw+0x1f6>
  disk.info[idx[0]].b = 0;
    80006290:	f8042483          	lw	s1,-128(s0)
    80006294:	00248793          	addi	a5,s1,2
    80006298:	00479713          	slli	a4,a5,0x4
    8000629c:	00030797          	auipc	a5,0x30
    800062a0:	0ec78793          	addi	a5,a5,236 # 80036388 <disk>
    800062a4:	97ba                	add	a5,a5,a4
    800062a6:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800062aa:	00030917          	auipc	s2,0x30
    800062ae:	0de90913          	addi	s2,s2,222 # 80036388 <disk>
    800062b2:	bd69                	j	8000614c <virtio_disk_rw+0xc6>

00000000800062b4 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    800062b4:	1101                	addi	sp,sp,-32
    800062b6:	ec06                	sd	ra,24(sp)
    800062b8:	e822                	sd	s0,16(sp)
    800062ba:	e426                	sd	s1,8(sp)
    800062bc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062be:	00030497          	auipc	s1,0x30
    800062c2:	0ca48493          	addi	s1,s1,202 # 80036388 <disk>
    800062c6:	00030517          	auipc	a0,0x30
    800062ca:	1ea50513          	addi	a0,a0,490 # 800364b0 <disk+0x128>
    800062ce:	ffffb097          	auipc	ra,0xffffb
    800062d2:	8c4080e7          	jalr	-1852(ra) # 80000b92 <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    800062d6:	0204d783          	lhu	a5,32(s1)
    800062da:	6898                	ld	a4,16(s1)
    800062dc:	00275683          	lhu	a3,2(a4)
    800062e0:	8ebd                	xor	a3,a3,a5
    800062e2:	8a9d                	andi	a3,a3,7
    800062e4:	c2b1                	beqz	a3,80006328 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    800062e6:	078e                	slli	a5,a5,0x3
    800062e8:	97ba                	add	a5,a5,a4
    800062ea:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800062ec:	00278713          	addi	a4,a5,2
    800062f0:	0712                	slli	a4,a4,0x4
    800062f2:	9726                	add	a4,a4,s1
    800062f4:	01074703          	lbu	a4,16(a4)
    800062f8:	eb31                	bnez	a4,8000634c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    800062fa:	0789                	addi	a5,a5,2
    800062fc:	0792                	slli	a5,a5,0x4
    800062fe:	97a6                	add	a5,a5,s1
    80006300:	6798                	ld	a4,8(a5)
    80006302:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006306:	6788                	ld	a0,8(a5)
    80006308:	ffffc097          	auipc	ra,0xffffc
    8000630c:	1d0080e7          	jalr	464(ra) # 800024d8 <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006310:	0204d783          	lhu	a5,32(s1)
    80006314:	2785                	addiw	a5,a5,1
    80006316:	8b9d                	andi	a5,a5,7
    80006318:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    8000631c:	6898                	ld	a4,16(s1)
    8000631e:	00275683          	lhu	a3,2(a4)
    80006322:	8a9d                	andi	a3,a3,7
    80006324:	fcf691e3          	bne	a3,a5,800062e6 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006328:	10001737          	lui	a4,0x10001
    8000632c:	533c                	lw	a5,96(a4)
    8000632e:	8b8d                	andi	a5,a5,3
    80006330:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006332:	00030517          	auipc	a0,0x30
    80006336:	17e50513          	addi	a0,a0,382 # 800364b0 <disk+0x128>
    8000633a:	ffffb097          	auipc	ra,0xffffb
    8000633e:	928080e7          	jalr	-1752(ra) # 80000c62 <release>
}
    80006342:	60e2                	ld	ra,24(sp)
    80006344:	6442                	ld	s0,16(sp)
    80006346:	64a2                	ld	s1,8(sp)
    80006348:	6105                	addi	sp,sp,32
    8000634a:	8082                	ret
      panic("virtio_disk_intr status");
    8000634c:	00003517          	auipc	a0,0x3
    80006350:	a0c50513          	addi	a0,a0,-1524 # 80008d58 <syscalls+0x428>
    80006354:	ffffa097          	auipc	ra,0xffffa
    80006358:	210080e7          	jalr	528(ra) # 80000564 <panic>

000000008000635c <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    8000635c:	1141                	addi	sp,sp,-16
    8000635e:	e422                	sd	s0,8(sp)
    80006360:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006362:	41f5d79b          	sraiw	a5,a1,0x1f
    80006366:	01d7d79b          	srliw	a5,a5,0x1d
    8000636a:	9dbd                	addw	a1,a1,a5
    8000636c:	0075f713          	andi	a4,a1,7
    80006370:	9f1d                	subw	a4,a4,a5
    80006372:	4785                	li	a5,1
    80006374:	00e797bb          	sllw	a5,a5,a4
    80006378:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    8000637c:	4035d59b          	sraiw	a1,a1,0x3
    80006380:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006382:	0005c503          	lbu	a0,0(a1)
    80006386:	8d7d                	and	a0,a0,a5
    80006388:	8d1d                	sub	a0,a0,a5
}
    8000638a:	00153513          	seqz	a0,a0
    8000638e:	6422                	ld	s0,8(sp)
    80006390:	0141                	addi	sp,sp,16
    80006392:	8082                	ret

0000000080006394 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006394:	1141                	addi	sp,sp,-16
    80006396:	e422                	sd	s0,8(sp)
    80006398:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000639a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000639e:	01d7d79b          	srliw	a5,a5,0x1d
    800063a2:	9dbd                	addw	a1,a1,a5
    800063a4:	4035d71b          	sraiw	a4,a1,0x3
    800063a8:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800063aa:	899d                	andi	a1,a1,7
    800063ac:	9d9d                	subw	a1,a1,a5
    800063ae:	4785                	li	a5,1
    800063b0:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800063b4:	00054783          	lbu	a5,0(a0)
    800063b8:	8ddd                	or	a1,a1,a5
    800063ba:	00b50023          	sb	a1,0(a0)
}
    800063be:	6422                	ld	s0,8(sp)
    800063c0:	0141                	addi	sp,sp,16
    800063c2:	8082                	ret

00000000800063c4 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800063c4:	1141                	addi	sp,sp,-16
    800063c6:	e422                	sd	s0,8(sp)
    800063c8:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800063ca:	41f5d79b          	sraiw	a5,a1,0x1f
    800063ce:	01d7d79b          	srliw	a5,a5,0x1d
    800063d2:	9dbd                	addw	a1,a1,a5
    800063d4:	4035d71b          	sraiw	a4,a1,0x3
    800063d8:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800063da:	899d                	andi	a1,a1,7
    800063dc:	9d9d                	subw	a1,a1,a5
    800063de:	4785                	li	a5,1
    800063e0:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    800063e4:	fff5c593          	not	a1,a1
    800063e8:	00054783          	lbu	a5,0(a0)
    800063ec:	8dfd                	and	a1,a1,a5
    800063ee:	00b50023          	sb	a1,0(a0)
}
    800063f2:	6422                	ld	s0,8(sp)
    800063f4:	0141                	addi	sp,sp,16
    800063f6:	8082                	ret

00000000800063f8 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800063f8:	715d                	addi	sp,sp,-80
    800063fa:	e486                	sd	ra,72(sp)
    800063fc:	e0a2                	sd	s0,64(sp)
    800063fe:	fc26                	sd	s1,56(sp)
    80006400:	f84a                	sd	s2,48(sp)
    80006402:	f44e                	sd	s3,40(sp)
    80006404:	f052                	sd	s4,32(sp)
    80006406:	ec56                	sd	s5,24(sp)
    80006408:	e85a                	sd	s6,16(sp)
    8000640a:	e45e                	sd	s7,8(sp)
    8000640c:	0880                	addi	s0,sp,80
    8000640e:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006410:	08b05b63          	blez	a1,800064a6 <bd_print_vector+0xae>
    80006414:	89aa                	mv	s3,a0
    80006416:	4481                	li	s1,0
  lb = 0;
    80006418:	4a81                	li	s5,0
  last = 1;
    8000641a:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000641c:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000641e:	00003b97          	auipc	s7,0x3
    80006422:	952b8b93          	addi	s7,s7,-1710 # 80008d70 <syscalls+0x440>
    80006426:	a821                	j	8000643e <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006428:	85a6                	mv	a1,s1
    8000642a:	854e                	mv	a0,s3
    8000642c:	00000097          	auipc	ra,0x0
    80006430:	f30080e7          	jalr	-208(ra) # 8000635c <bit_isset>
    80006434:	892a                	mv	s2,a0
    80006436:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006438:	2485                	addiw	s1,s1,1
    8000643a:	029a0463          	beq	s4,s1,80006462 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    8000643e:	85a6                	mv	a1,s1
    80006440:	854e                	mv	a0,s3
    80006442:	00000097          	auipc	ra,0x0
    80006446:	f1a080e7          	jalr	-230(ra) # 8000635c <bit_isset>
    8000644a:	ff2507e3          	beq	a0,s2,80006438 <bd_print_vector+0x40>
    if(last == 1)
    8000644e:	fd691de3          	bne	s2,s6,80006428 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    80006452:	8626                	mv	a2,s1
    80006454:	85d6                	mv	a1,s5
    80006456:	855e                	mv	a0,s7
    80006458:	ffffa097          	auipc	ra,0xffffa
    8000645c:	16e080e7          	jalr	366(ra) # 800005c6 <printf>
    80006460:	b7e1                	j	80006428 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006462:	000a8563          	beqz	s5,8000646c <bd_print_vector+0x74>
    80006466:	4785                	li	a5,1
    80006468:	00f91c63          	bne	s2,a5,80006480 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    8000646c:	8652                	mv	a2,s4
    8000646e:	85d6                	mv	a1,s5
    80006470:	00003517          	auipc	a0,0x3
    80006474:	90050513          	addi	a0,a0,-1792 # 80008d70 <syscalls+0x440>
    80006478:	ffffa097          	auipc	ra,0xffffa
    8000647c:	14e080e7          	jalr	334(ra) # 800005c6 <printf>
  }
  printf("\n");
    80006480:	00002517          	auipc	a0,0x2
    80006484:	d8050513          	addi	a0,a0,-640 # 80008200 <digits+0x90>
    80006488:	ffffa097          	auipc	ra,0xffffa
    8000648c:	13e080e7          	jalr	318(ra) # 800005c6 <printf>
}
    80006490:	60a6                	ld	ra,72(sp)
    80006492:	6406                	ld	s0,64(sp)
    80006494:	74e2                	ld	s1,56(sp)
    80006496:	7942                	ld	s2,48(sp)
    80006498:	79a2                	ld	s3,40(sp)
    8000649a:	7a02                	ld	s4,32(sp)
    8000649c:	6ae2                	ld	s5,24(sp)
    8000649e:	6b42                	ld	s6,16(sp)
    800064a0:	6ba2                	ld	s7,8(sp)
    800064a2:	6161                	addi	sp,sp,80
    800064a4:	8082                	ret
  lb = 0;
    800064a6:	4a81                	li	s5,0
    800064a8:	b7d1                	j	8000646c <bd_print_vector+0x74>

00000000800064aa <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800064aa:	00003697          	auipc	a3,0x3
    800064ae:	a966a683          	lw	a3,-1386(a3) # 80008f40 <nsizes>
    800064b2:	10d05063          	blez	a3,800065b2 <bd_print+0x108>
bd_print() {
    800064b6:	711d                	addi	sp,sp,-96
    800064b8:	ec86                	sd	ra,88(sp)
    800064ba:	e8a2                	sd	s0,80(sp)
    800064bc:	e4a6                	sd	s1,72(sp)
    800064be:	e0ca                	sd	s2,64(sp)
    800064c0:	fc4e                	sd	s3,56(sp)
    800064c2:	f852                	sd	s4,48(sp)
    800064c4:	f456                	sd	s5,40(sp)
    800064c6:	f05a                	sd	s6,32(sp)
    800064c8:	ec5e                	sd	s7,24(sp)
    800064ca:	e862                	sd	s8,16(sp)
    800064cc:	e466                	sd	s9,8(sp)
    800064ce:	e06a                	sd	s10,0(sp)
    800064d0:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800064d2:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800064d4:	4a85                	li	s5,1
    800064d6:	4c41                	li	s8,16
    800064d8:	00003b97          	auipc	s7,0x3
    800064dc:	8a8b8b93          	addi	s7,s7,-1880 # 80008d80 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    800064e0:	00003a17          	auipc	s4,0x3
    800064e4:	a58a0a13          	addi	s4,s4,-1448 # 80008f38 <bd_sizes>
    printf("  alloc:");
    800064e8:	00003b17          	auipc	s6,0x3
    800064ec:	8c0b0b13          	addi	s6,s6,-1856 # 80008da8 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800064f0:	00003997          	auipc	s3,0x3
    800064f4:	a5098993          	addi	s3,s3,-1456 # 80008f40 <nsizes>
    if(k > 0) {
      printf("  split:");
    800064f8:	00003c97          	auipc	s9,0x3
    800064fc:	8c0c8c93          	addi	s9,s9,-1856 # 80008db8 <syscalls+0x488>
    80006500:	a801                	j	80006510 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006502:	0009a683          	lw	a3,0(s3)
    80006506:	0485                	addi	s1,s1,1
    80006508:	0004879b          	sext.w	a5,s1
    8000650c:	08d7d563          	bge	a5,a3,80006596 <bd_print+0xec>
    80006510:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006514:	36fd                	addiw	a3,a3,-1
    80006516:	9e85                	subw	a3,a3,s1
    80006518:	00da96bb          	sllw	a3,s5,a3
    8000651c:	009c1633          	sll	a2,s8,s1
    80006520:	85ca                	mv	a1,s2
    80006522:	855e                	mv	a0,s7
    80006524:	ffffa097          	auipc	ra,0xffffa
    80006528:	0a2080e7          	jalr	162(ra) # 800005c6 <printf>
    lst_print(&bd_sizes[k].free);
    8000652c:	00549d13          	slli	s10,s1,0x5
    80006530:	000a3503          	ld	a0,0(s4)
    80006534:	956a                	add	a0,a0,s10
    80006536:	00001097          	auipc	ra,0x1
    8000653a:	a56080e7          	jalr	-1450(ra) # 80006f8c <lst_print>
    printf("  alloc:");
    8000653e:	855a                	mv	a0,s6
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	086080e7          	jalr	134(ra) # 800005c6 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006548:	0009a583          	lw	a1,0(s3)
    8000654c:	35fd                	addiw	a1,a1,-1
    8000654e:	412585bb          	subw	a1,a1,s2
    80006552:	000a3783          	ld	a5,0(s4)
    80006556:	97ea                	add	a5,a5,s10
    80006558:	00ba95bb          	sllw	a1,s5,a1
    8000655c:	6b88                	ld	a0,16(a5)
    8000655e:	00000097          	auipc	ra,0x0
    80006562:	e9a080e7          	jalr	-358(ra) # 800063f8 <bd_print_vector>
    if(k > 0) {
    80006566:	f9205ee3          	blez	s2,80006502 <bd_print+0x58>
      printf("  split:");
    8000656a:	8566                	mv	a0,s9
    8000656c:	ffffa097          	auipc	ra,0xffffa
    80006570:	05a080e7          	jalr	90(ra) # 800005c6 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006574:	0009a583          	lw	a1,0(s3)
    80006578:	35fd                	addiw	a1,a1,-1
    8000657a:	412585bb          	subw	a1,a1,s2
    8000657e:	000a3783          	ld	a5,0(s4)
    80006582:	9d3e                	add	s10,s10,a5
    80006584:	00ba95bb          	sllw	a1,s5,a1
    80006588:	018d3503          	ld	a0,24(s10) # fffffffffffff018 <end+0xffffffff7ffc8b28>
    8000658c:	00000097          	auipc	ra,0x0
    80006590:	e6c080e7          	jalr	-404(ra) # 800063f8 <bd_print_vector>
    80006594:	b7bd                	j	80006502 <bd_print+0x58>
    }
  }
}
    80006596:	60e6                	ld	ra,88(sp)
    80006598:	6446                	ld	s0,80(sp)
    8000659a:	64a6                	ld	s1,72(sp)
    8000659c:	6906                	ld	s2,64(sp)
    8000659e:	79e2                	ld	s3,56(sp)
    800065a0:	7a42                	ld	s4,48(sp)
    800065a2:	7aa2                	ld	s5,40(sp)
    800065a4:	7b02                	ld	s6,32(sp)
    800065a6:	6be2                	ld	s7,24(sp)
    800065a8:	6c42                	ld	s8,16(sp)
    800065aa:	6ca2                	ld	s9,8(sp)
    800065ac:	6d02                	ld	s10,0(sp)
    800065ae:	6125                	addi	sp,sp,96
    800065b0:	8082                	ret
    800065b2:	8082                	ret

00000000800065b4 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800065b4:	1141                	addi	sp,sp,-16
    800065b6:	e422                	sd	s0,8(sp)
    800065b8:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800065ba:	47c1                	li	a5,16
    800065bc:	00a7fb63          	bgeu	a5,a0,800065d2 <firstk+0x1e>
    800065c0:	872a                	mv	a4,a0
  int k = 0;
    800065c2:	4501                	li	a0,0
    k++;
    800065c4:	2505                	addiw	a0,a0,1
    size *= 2;
    800065c6:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800065c8:	fee7eee3          	bltu	a5,a4,800065c4 <firstk+0x10>
  }
  return k;
}
    800065cc:	6422                	ld	s0,8(sp)
    800065ce:	0141                	addi	sp,sp,16
    800065d0:	8082                	ret
  int k = 0;
    800065d2:	4501                	li	a0,0
    800065d4:	bfe5                	j	800065cc <firstk+0x18>

00000000800065d6 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800065d6:	1141                	addi	sp,sp,-16
    800065d8:	e422                	sd	s0,8(sp)
    800065da:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800065dc:	00003797          	auipc	a5,0x3
    800065e0:	9547b783          	ld	a5,-1708(a5) # 80008f30 <bd_base>
    800065e4:	9d9d                	subw	a1,a1,a5
    800065e6:	47c1                	li	a5,16
    800065e8:	00a797b3          	sll	a5,a5,a0
    800065ec:	02f5c5b3          	div	a1,a1,a5
}
    800065f0:	0005851b          	sext.w	a0,a1
    800065f4:	6422                	ld	s0,8(sp)
    800065f6:	0141                	addi	sp,sp,16
    800065f8:	8082                	ret

00000000800065fa <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800065fa:	1141                	addi	sp,sp,-16
    800065fc:	e422                	sd	s0,8(sp)
    800065fe:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006600:	47c1                	li	a5,16
    80006602:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006606:	02b787bb          	mulw	a5,a5,a1
}
    8000660a:	00003517          	auipc	a0,0x3
    8000660e:	92653503          	ld	a0,-1754(a0) # 80008f30 <bd_base>
    80006612:	953e                	add	a0,a0,a5
    80006614:	6422                	ld	s0,8(sp)
    80006616:	0141                	addi	sp,sp,16
    80006618:	8082                	ret

000000008000661a <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    8000661a:	7159                	addi	sp,sp,-112
    8000661c:	f486                	sd	ra,104(sp)
    8000661e:	f0a2                	sd	s0,96(sp)
    80006620:	eca6                	sd	s1,88(sp)
    80006622:	e8ca                	sd	s2,80(sp)
    80006624:	e4ce                	sd	s3,72(sp)
    80006626:	e0d2                	sd	s4,64(sp)
    80006628:	fc56                	sd	s5,56(sp)
    8000662a:	f85a                	sd	s6,48(sp)
    8000662c:	f45e                	sd	s7,40(sp)
    8000662e:	f062                	sd	s8,32(sp)
    80006630:	ec66                	sd	s9,24(sp)
    80006632:	e86a                	sd	s10,16(sp)
    80006634:	e46e                	sd	s11,8(sp)
    80006636:	1880                	addi	s0,sp,112
    80006638:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    8000663a:	00030517          	auipc	a0,0x30
    8000663e:	e9650513          	addi	a0,a0,-362 # 800364d0 <lock>
    80006642:	ffffa097          	auipc	ra,0xffffa
    80006646:	550080e7          	jalr	1360(ra) # 80000b92 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    8000664a:	8526                	mv	a0,s1
    8000664c:	00000097          	auipc	ra,0x0
    80006650:	f68080e7          	jalr	-152(ra) # 800065b4 <firstk>
  for (k = fk; k < nsizes; k++) {
    80006654:	00003797          	auipc	a5,0x3
    80006658:	8ec7a783          	lw	a5,-1812(a5) # 80008f40 <nsizes>
    8000665c:	02f55d63          	bge	a0,a5,80006696 <bd_malloc+0x7c>
    80006660:	8c2a                	mv	s8,a0
    80006662:	00551913          	slli	s2,a0,0x5
    80006666:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006668:	00003997          	auipc	s3,0x3
    8000666c:	8d098993          	addi	s3,s3,-1840 # 80008f38 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006670:	00003a17          	auipc	s4,0x3
    80006674:	8d0a0a13          	addi	s4,s4,-1840 # 80008f40 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006678:	0009b503          	ld	a0,0(s3)
    8000667c:	954a                	add	a0,a0,s2
    8000667e:	00001097          	auipc	ra,0x1
    80006682:	894080e7          	jalr	-1900(ra) # 80006f12 <lst_empty>
    80006686:	c115                	beqz	a0,800066aa <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006688:	2485                	addiw	s1,s1,1
    8000668a:	02090913          	addi	s2,s2,32
    8000668e:	000a2783          	lw	a5,0(s4)
    80006692:	fef4c3e3          	blt	s1,a5,80006678 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006696:	00030517          	auipc	a0,0x30
    8000669a:	e3a50513          	addi	a0,a0,-454 # 800364d0 <lock>
    8000669e:	ffffa097          	auipc	ra,0xffffa
    800066a2:	5c4080e7          	jalr	1476(ra) # 80000c62 <release>
    return 0;
    800066a6:	4b01                	li	s6,0
    800066a8:	a0e1                	j	80006770 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800066aa:	00003797          	auipc	a5,0x3
    800066ae:	8967a783          	lw	a5,-1898(a5) # 80008f40 <nsizes>
    800066b2:	fef4d2e3          	bge	s1,a5,80006696 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800066b6:	00549993          	slli	s3,s1,0x5
    800066ba:	00003917          	auipc	s2,0x3
    800066be:	87e90913          	addi	s2,s2,-1922 # 80008f38 <bd_sizes>
    800066c2:	00093503          	ld	a0,0(s2)
    800066c6:	954e                	add	a0,a0,s3
    800066c8:	00001097          	auipc	ra,0x1
    800066cc:	876080e7          	jalr	-1930(ra) # 80006f3e <lst_pop>
    800066d0:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800066d2:	00003597          	auipc	a1,0x3
    800066d6:	85e5b583          	ld	a1,-1954(a1) # 80008f30 <bd_base>
    800066da:	40b505bb          	subw	a1,a0,a1
    800066de:	47c1                	li	a5,16
    800066e0:	009797b3          	sll	a5,a5,s1
    800066e4:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800066e8:	00093783          	ld	a5,0(s2)
    800066ec:	97ce                	add	a5,a5,s3
    800066ee:	2581                	sext.w	a1,a1
    800066f0:	6b88                	ld	a0,16(a5)
    800066f2:	00000097          	auipc	ra,0x0
    800066f6:	ca2080e7          	jalr	-862(ra) # 80006394 <bit_set>
  for(; k > fk; k--) {
    800066fa:	069c5363          	bge	s8,s1,80006760 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800066fe:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006700:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006702:	00003d17          	auipc	s10,0x3
    80006706:	82ed0d13          	addi	s10,s10,-2002 # 80008f30 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000670a:	85a6                	mv	a1,s1
    8000670c:	34fd                	addiw	s1,s1,-1
    8000670e:	009b9ab3          	sll	s5,s7,s1
    80006712:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006716:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    8000671a:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000671e:	412b093b          	subw	s2,s6,s2
    80006722:	00bb95b3          	sll	a1,s7,a1
    80006726:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000672a:	013a07b3          	add	a5,s4,s3
    8000672e:	2581                	sext.w	a1,a1
    80006730:	6f88                	ld	a0,24(a5)
    80006732:	00000097          	auipc	ra,0x0
    80006736:	c62080e7          	jalr	-926(ra) # 80006394 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000673a:	1981                	addi	s3,s3,-32
    8000673c:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    8000673e:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006742:	2581                	sext.w	a1,a1
    80006744:	010a3503          	ld	a0,16(s4)
    80006748:	00000097          	auipc	ra,0x0
    8000674c:	c4c080e7          	jalr	-948(ra) # 80006394 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006750:	85e6                	mv	a1,s9
    80006752:	8552                	mv	a0,s4
    80006754:	00001097          	auipc	ra,0x1
    80006758:	820080e7          	jalr	-2016(ra) # 80006f74 <lst_push>
  for(; k > fk; k--) {
    8000675c:	fb8497e3          	bne	s1,s8,8000670a <bd_malloc+0xf0>
  }
  release(&lock);
    80006760:	00030517          	auipc	a0,0x30
    80006764:	d7050513          	addi	a0,a0,-656 # 800364d0 <lock>
    80006768:	ffffa097          	auipc	ra,0xffffa
    8000676c:	4fa080e7          	jalr	1274(ra) # 80000c62 <release>

  return p;
}
    80006770:	855a                	mv	a0,s6
    80006772:	70a6                	ld	ra,104(sp)
    80006774:	7406                	ld	s0,96(sp)
    80006776:	64e6                	ld	s1,88(sp)
    80006778:	6946                	ld	s2,80(sp)
    8000677a:	69a6                	ld	s3,72(sp)
    8000677c:	6a06                	ld	s4,64(sp)
    8000677e:	7ae2                	ld	s5,56(sp)
    80006780:	7b42                	ld	s6,48(sp)
    80006782:	7ba2                	ld	s7,40(sp)
    80006784:	7c02                	ld	s8,32(sp)
    80006786:	6ce2                	ld	s9,24(sp)
    80006788:	6d42                	ld	s10,16(sp)
    8000678a:	6da2                	ld	s11,8(sp)
    8000678c:	6165                	addi	sp,sp,112
    8000678e:	8082                	ret

0000000080006790 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006790:	7139                	addi	sp,sp,-64
    80006792:	fc06                	sd	ra,56(sp)
    80006794:	f822                	sd	s0,48(sp)
    80006796:	f426                	sd	s1,40(sp)
    80006798:	f04a                	sd	s2,32(sp)
    8000679a:	ec4e                	sd	s3,24(sp)
    8000679c:	e852                	sd	s4,16(sp)
    8000679e:	e456                	sd	s5,8(sp)
    800067a0:	e05a                	sd	s6,0(sp)
    800067a2:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    800067a4:	00002a97          	auipc	s5,0x2
    800067a8:	79caaa83          	lw	s5,1948(s5) # 80008f40 <nsizes>
  return n / BLK_SIZE(k);
    800067ac:	00002a17          	auipc	s4,0x2
    800067b0:	784a3a03          	ld	s4,1924(s4) # 80008f30 <bd_base>
    800067b4:	41450a3b          	subw	s4,a0,s4
    800067b8:	00002497          	auipc	s1,0x2
    800067bc:	7804b483          	ld	s1,1920(s1) # 80008f38 <bd_sizes>
    800067c0:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    800067c4:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    800067c6:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    800067c8:	03595363          	bge	s2,s5,800067ee <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800067cc:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800067d0:	013b15b3          	sll	a1,s6,s3
    800067d4:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800067d8:	2581                	sext.w	a1,a1
    800067da:	6088                	ld	a0,0(s1)
    800067dc:	00000097          	auipc	ra,0x0
    800067e0:	b80080e7          	jalr	-1152(ra) # 8000635c <bit_isset>
    800067e4:	02048493          	addi	s1,s1,32
    800067e8:	e501                	bnez	a0,800067f0 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800067ea:	894e                	mv	s2,s3
    800067ec:	bff1                	j	800067c8 <size+0x38>
      return k;
    }
  }
  return 0;
    800067ee:	4901                	li	s2,0
}
    800067f0:	854a                	mv	a0,s2
    800067f2:	70e2                	ld	ra,56(sp)
    800067f4:	7442                	ld	s0,48(sp)
    800067f6:	74a2                	ld	s1,40(sp)
    800067f8:	7902                	ld	s2,32(sp)
    800067fa:	69e2                	ld	s3,24(sp)
    800067fc:	6a42                	ld	s4,16(sp)
    800067fe:	6aa2                	ld	s5,8(sp)
    80006800:	6b02                	ld	s6,0(sp)
    80006802:	6121                	addi	sp,sp,64
    80006804:	8082                	ret

0000000080006806 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006806:	7159                	addi	sp,sp,-112
    80006808:	f486                	sd	ra,104(sp)
    8000680a:	f0a2                	sd	s0,96(sp)
    8000680c:	eca6                	sd	s1,88(sp)
    8000680e:	e8ca                	sd	s2,80(sp)
    80006810:	e4ce                	sd	s3,72(sp)
    80006812:	e0d2                	sd	s4,64(sp)
    80006814:	fc56                	sd	s5,56(sp)
    80006816:	f85a                	sd	s6,48(sp)
    80006818:	f45e                	sd	s7,40(sp)
    8000681a:	f062                	sd	s8,32(sp)
    8000681c:	ec66                	sd	s9,24(sp)
    8000681e:	e86a                	sd	s10,16(sp)
    80006820:	e46e                	sd	s11,8(sp)
    80006822:	1880                	addi	s0,sp,112
    80006824:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006826:	00030517          	auipc	a0,0x30
    8000682a:	caa50513          	addi	a0,a0,-854 # 800364d0 <lock>
    8000682e:	ffffa097          	auipc	ra,0xffffa
    80006832:	364080e7          	jalr	868(ra) # 80000b92 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006836:	8556                	mv	a0,s5
    80006838:	00000097          	auipc	ra,0x0
    8000683c:	f58080e7          	jalr	-168(ra) # 80006790 <size>
    80006840:	84aa                	mv	s1,a0
    80006842:	00002797          	auipc	a5,0x2
    80006846:	6fe7a783          	lw	a5,1790(a5) # 80008f40 <nsizes>
    8000684a:	37fd                	addiw	a5,a5,-1
    8000684c:	0cf55063          	bge	a0,a5,8000690c <bd_free+0x106>
    80006850:	00150a13          	addi	s4,a0,1
    80006854:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006856:	00002c17          	auipc	s8,0x2
    8000685a:	6dac0c13          	addi	s8,s8,1754 # 80008f30 <bd_base>
  return n / BLK_SIZE(k);
    8000685e:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006860:	00002b17          	auipc	s6,0x2
    80006864:	6d8b0b13          	addi	s6,s6,1752 # 80008f38 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006868:	00002c97          	auipc	s9,0x2
    8000686c:	6d8c8c93          	addi	s9,s9,1752 # 80008f40 <nsizes>
    80006870:	a82d                	j	800068aa <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006872:	fff58d9b          	addiw	s11,a1,-1
    80006876:	a881                	j	800068c6 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006878:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    8000687a:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    8000687e:	40ba85bb          	subw	a1,s5,a1
    80006882:	009b97b3          	sll	a5,s7,s1
    80006886:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000688a:	000b3783          	ld	a5,0(s6)
    8000688e:	97d2                	add	a5,a5,s4
    80006890:	2581                	sext.w	a1,a1
    80006892:	6f88                	ld	a0,24(a5)
    80006894:	00000097          	auipc	ra,0x0
    80006898:	b30080e7          	jalr	-1232(ra) # 800063c4 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    8000689c:	020a0a13          	addi	s4,s4,32
    800068a0:	000ca783          	lw	a5,0(s9)
    800068a4:	37fd                	addiw	a5,a5,-1
    800068a6:	06f4d363          	bge	s1,a5,8000690c <bd_free+0x106>
  int n = p - (char *) bd_base;
    800068aa:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    800068ae:	009b99b3          	sll	s3,s7,s1
    800068b2:	412a87bb          	subw	a5,s5,s2
    800068b6:	0337c7b3          	div	a5,a5,s3
    800068ba:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800068be:	8b85                	andi	a5,a5,1
    800068c0:	fbcd                	bnez	a5,80006872 <bd_free+0x6c>
    800068c2:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800068c6:	fe0a0d13          	addi	s10,s4,-32
    800068ca:	000b3783          	ld	a5,0(s6)
    800068ce:	9d3e                	add	s10,s10,a5
    800068d0:	010d3503          	ld	a0,16(s10)
    800068d4:	00000097          	auipc	ra,0x0
    800068d8:	af0080e7          	jalr	-1296(ra) # 800063c4 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    800068dc:	85ee                	mv	a1,s11
    800068de:	010d3503          	ld	a0,16(s10)
    800068e2:	00000097          	auipc	ra,0x0
    800068e6:	a7a080e7          	jalr	-1414(ra) # 8000635c <bit_isset>
    800068ea:	e10d                	bnez	a0,8000690c <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    800068ec:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    800068f0:	03b989bb          	mulw	s3,s3,s11
    800068f4:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    800068f6:	854a                	mv	a0,s2
    800068f8:	00000097          	auipc	ra,0x0
    800068fc:	630080e7          	jalr	1584(ra) # 80006f28 <lst_remove>
    if(buddy % 2 == 0) {
    80006900:	001d7d13          	andi	s10,s10,1
    80006904:	f60d1ae3          	bnez	s10,80006878 <bd_free+0x72>
      p = q;
    80006908:	8aca                	mv	s5,s2
    8000690a:	b7bd                	j	80006878 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    8000690c:	0496                	slli	s1,s1,0x5
    8000690e:	85d6                	mv	a1,s5
    80006910:	00002517          	auipc	a0,0x2
    80006914:	62853503          	ld	a0,1576(a0) # 80008f38 <bd_sizes>
    80006918:	9526                	add	a0,a0,s1
    8000691a:	00000097          	auipc	ra,0x0
    8000691e:	65a080e7          	jalr	1626(ra) # 80006f74 <lst_push>
  release(&lock);
    80006922:	00030517          	auipc	a0,0x30
    80006926:	bae50513          	addi	a0,a0,-1106 # 800364d0 <lock>
    8000692a:	ffffa097          	auipc	ra,0xffffa
    8000692e:	338080e7          	jalr	824(ra) # 80000c62 <release>
}
    80006932:	70a6                	ld	ra,104(sp)
    80006934:	7406                	ld	s0,96(sp)
    80006936:	64e6                	ld	s1,88(sp)
    80006938:	6946                	ld	s2,80(sp)
    8000693a:	69a6                	ld	s3,72(sp)
    8000693c:	6a06                	ld	s4,64(sp)
    8000693e:	7ae2                	ld	s5,56(sp)
    80006940:	7b42                	ld	s6,48(sp)
    80006942:	7ba2                	ld	s7,40(sp)
    80006944:	7c02                	ld	s8,32(sp)
    80006946:	6ce2                	ld	s9,24(sp)
    80006948:	6d42                	ld	s10,16(sp)
    8000694a:	6da2                	ld	s11,8(sp)
    8000694c:	6165                	addi	sp,sp,112
    8000694e:	8082                	ret

0000000080006950 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006950:	1141                	addi	sp,sp,-16
    80006952:	e422                	sd	s0,8(sp)
    80006954:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006956:	00002797          	auipc	a5,0x2
    8000695a:	5da7b783          	ld	a5,1498(a5) # 80008f30 <bd_base>
    8000695e:	8d9d                	sub	a1,a1,a5
    80006960:	47c1                	li	a5,16
    80006962:	00a797b3          	sll	a5,a5,a0
    80006966:	02f5c533          	div	a0,a1,a5
    8000696a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    8000696c:	02f5e5b3          	rem	a1,a1,a5
    80006970:	c191                	beqz	a1,80006974 <blk_index_next+0x24>
      n++;
    80006972:	2505                	addiw	a0,a0,1
  return n ;
}
    80006974:	6422                	ld	s0,8(sp)
    80006976:	0141                	addi	sp,sp,16
    80006978:	8082                	ret

000000008000697a <log2>:

int
log2(uint64 n) {
    8000697a:	1141                	addi	sp,sp,-16
    8000697c:	e422                	sd	s0,8(sp)
    8000697e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006980:	4705                	li	a4,1
    80006982:	00a77b63          	bgeu	a4,a0,80006998 <log2+0x1e>
    80006986:	87aa                	mv	a5,a0
  int k = 0;
    80006988:	4501                	li	a0,0
    k++;
    8000698a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    8000698c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    8000698e:	fef76ee3          	bltu	a4,a5,8000698a <log2+0x10>
  }
  return k;
}
    80006992:	6422                	ld	s0,8(sp)
    80006994:	0141                	addi	sp,sp,16
    80006996:	8082                	ret
  int k = 0;
    80006998:	4501                	li	a0,0
    8000699a:	bfe5                	j	80006992 <log2+0x18>

000000008000699c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    8000699c:	711d                	addi	sp,sp,-96
    8000699e:	ec86                	sd	ra,88(sp)
    800069a0:	e8a2                	sd	s0,80(sp)
    800069a2:	e4a6                	sd	s1,72(sp)
    800069a4:	e0ca                	sd	s2,64(sp)
    800069a6:	fc4e                	sd	s3,56(sp)
    800069a8:	f852                	sd	s4,48(sp)
    800069aa:	f456                	sd	s5,40(sp)
    800069ac:	f05a                	sd	s6,32(sp)
    800069ae:	ec5e                	sd	s7,24(sp)
    800069b0:	e862                	sd	s8,16(sp)
    800069b2:	e466                	sd	s9,8(sp)
    800069b4:	e06a                	sd	s10,0(sp)
    800069b6:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    800069b8:	00b56933          	or	s2,a0,a1
    800069bc:	00f97913          	andi	s2,s2,15
    800069c0:	04091263          	bnez	s2,80006a04 <bd_mark+0x68>
    800069c4:	8b2a                	mv	s6,a0
    800069c6:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    800069c8:	00002c17          	auipc	s8,0x2
    800069cc:	578c2c03          	lw	s8,1400(s8) # 80008f40 <nsizes>
    800069d0:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    800069d2:	00002d17          	auipc	s10,0x2
    800069d6:	55ed0d13          	addi	s10,s10,1374 # 80008f30 <bd_base>
  return n / BLK_SIZE(k);
    800069da:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    800069dc:	00002a97          	auipc	s5,0x2
    800069e0:	55ca8a93          	addi	s5,s5,1372 # 80008f38 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    800069e4:	07804563          	bgtz	s8,80006a4e <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    800069e8:	60e6                	ld	ra,88(sp)
    800069ea:	6446                	ld	s0,80(sp)
    800069ec:	64a6                	ld	s1,72(sp)
    800069ee:	6906                	ld	s2,64(sp)
    800069f0:	79e2                	ld	s3,56(sp)
    800069f2:	7a42                	ld	s4,48(sp)
    800069f4:	7aa2                	ld	s5,40(sp)
    800069f6:	7b02                	ld	s6,32(sp)
    800069f8:	6be2                	ld	s7,24(sp)
    800069fa:	6c42                	ld	s8,16(sp)
    800069fc:	6ca2                	ld	s9,8(sp)
    800069fe:	6d02                	ld	s10,0(sp)
    80006a00:	6125                	addi	sp,sp,96
    80006a02:	8082                	ret
    panic("bd_mark");
    80006a04:	00002517          	auipc	a0,0x2
    80006a08:	3c450513          	addi	a0,a0,964 # 80008dc8 <syscalls+0x498>
    80006a0c:	ffffa097          	auipc	ra,0xffffa
    80006a10:	b58080e7          	jalr	-1192(ra) # 80000564 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006a14:	000ab783          	ld	a5,0(s5)
    80006a18:	97ca                	add	a5,a5,s2
    80006a1a:	85a6                	mv	a1,s1
    80006a1c:	6b88                	ld	a0,16(a5)
    80006a1e:	00000097          	auipc	ra,0x0
    80006a22:	976080e7          	jalr	-1674(ra) # 80006394 <bit_set>
    for(; bi < bj; bi++) {
    80006a26:	2485                	addiw	s1,s1,1
    80006a28:	009a0e63          	beq	s4,s1,80006a44 <bd_mark+0xa8>
      if(k > 0) {
    80006a2c:	ff3054e3          	blez	s3,80006a14 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006a30:	000ab783          	ld	a5,0(s5)
    80006a34:	97ca                	add	a5,a5,s2
    80006a36:	85a6                	mv	a1,s1
    80006a38:	6f88                	ld	a0,24(a5)
    80006a3a:	00000097          	auipc	ra,0x0
    80006a3e:	95a080e7          	jalr	-1702(ra) # 80006394 <bit_set>
    80006a42:	bfc9                	j	80006a14 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006a44:	2985                	addiw	s3,s3,1
    80006a46:	02090913          	addi	s2,s2,32
    80006a4a:	f9898fe3          	beq	s3,s8,800069e8 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006a4e:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006a52:	409b04bb          	subw	s1,s6,s1
    80006a56:	013c97b3          	sll	a5,s9,s3
    80006a5a:	02f4c4b3          	div	s1,s1,a5
    80006a5e:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006a60:	85de                	mv	a1,s7
    80006a62:	854e                	mv	a0,s3
    80006a64:	00000097          	auipc	ra,0x0
    80006a68:	eec080e7          	jalr	-276(ra) # 80006950 <blk_index_next>
    80006a6c:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006a6e:	faa4cfe3          	blt	s1,a0,80006a2c <bd_mark+0x90>
    80006a72:	bfc9                	j	80006a44 <bd_mark+0xa8>

0000000080006a74 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006a74:	7139                	addi	sp,sp,-64
    80006a76:	fc06                	sd	ra,56(sp)
    80006a78:	f822                	sd	s0,48(sp)
    80006a7a:	f426                	sd	s1,40(sp)
    80006a7c:	f04a                	sd	s2,32(sp)
    80006a7e:	ec4e                	sd	s3,24(sp)
    80006a80:	e852                	sd	s4,16(sp)
    80006a82:	e456                	sd	s5,8(sp)
    80006a84:	e05a                	sd	s6,0(sp)
    80006a86:	0080                	addi	s0,sp,64
    80006a88:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a8a:	00058a9b          	sext.w	s5,a1
    80006a8e:	0015f793          	andi	a5,a1,1
    80006a92:	ebad                	bnez	a5,80006b04 <bd_initfree_pair+0x90>
    80006a94:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006a98:	00599493          	slli	s1,s3,0x5
    80006a9c:	00002797          	auipc	a5,0x2
    80006aa0:	49c7b783          	ld	a5,1180(a5) # 80008f38 <bd_sizes>
    80006aa4:	94be                	add	s1,s1,a5
    80006aa6:	0104bb03          	ld	s6,16(s1)
    80006aaa:	855a                	mv	a0,s6
    80006aac:	00000097          	auipc	ra,0x0
    80006ab0:	8b0080e7          	jalr	-1872(ra) # 8000635c <bit_isset>
    80006ab4:	892a                	mv	s2,a0
    80006ab6:	85d2                	mv	a1,s4
    80006ab8:	855a                	mv	a0,s6
    80006aba:	00000097          	auipc	ra,0x0
    80006abe:	8a2080e7          	jalr	-1886(ra) # 8000635c <bit_isset>
  int free = 0;
    80006ac2:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006ac4:	02a90563          	beq	s2,a0,80006aee <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006ac8:	45c1                	li	a1,16
    80006aca:	013599b3          	sll	s3,a1,s3
    80006ace:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006ad2:	02090c63          	beqz	s2,80006b0a <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006ad6:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006ada:	00002597          	auipc	a1,0x2
    80006ade:	4565b583          	ld	a1,1110(a1) # 80008f30 <bd_base>
    80006ae2:	95ce                	add	a1,a1,s3
    80006ae4:	8526                	mv	a0,s1
    80006ae6:	00000097          	auipc	ra,0x0
    80006aea:	48e080e7          	jalr	1166(ra) # 80006f74 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006aee:	855a                	mv	a0,s6
    80006af0:	70e2                	ld	ra,56(sp)
    80006af2:	7442                	ld	s0,48(sp)
    80006af4:	74a2                	ld	s1,40(sp)
    80006af6:	7902                	ld	s2,32(sp)
    80006af8:	69e2                	ld	s3,24(sp)
    80006afa:	6a42                	ld	s4,16(sp)
    80006afc:	6aa2                	ld	s5,8(sp)
    80006afe:	6b02                	ld	s6,0(sp)
    80006b00:	6121                	addi	sp,sp,64
    80006b02:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006b04:	fff58a1b          	addiw	s4,a1,-1
    80006b08:	bf41                	j	80006a98 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006b0a:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006b0e:	00002597          	auipc	a1,0x2
    80006b12:	4225b583          	ld	a1,1058(a1) # 80008f30 <bd_base>
    80006b16:	95ce                	add	a1,a1,s3
    80006b18:	8526                	mv	a0,s1
    80006b1a:	00000097          	auipc	ra,0x0
    80006b1e:	45a080e7          	jalr	1114(ra) # 80006f74 <lst_push>
    80006b22:	b7f1                	j	80006aee <bd_initfree_pair+0x7a>

0000000080006b24 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006b24:	711d                	addi	sp,sp,-96
    80006b26:	ec86                	sd	ra,88(sp)
    80006b28:	e8a2                	sd	s0,80(sp)
    80006b2a:	e4a6                	sd	s1,72(sp)
    80006b2c:	e0ca                	sd	s2,64(sp)
    80006b2e:	fc4e                	sd	s3,56(sp)
    80006b30:	f852                	sd	s4,48(sp)
    80006b32:	f456                	sd	s5,40(sp)
    80006b34:	f05a                	sd	s6,32(sp)
    80006b36:	ec5e                	sd	s7,24(sp)
    80006b38:	e862                	sd	s8,16(sp)
    80006b3a:	e466                	sd	s9,8(sp)
    80006b3c:	e06a                	sd	s10,0(sp)
    80006b3e:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006b40:	00002717          	auipc	a4,0x2
    80006b44:	40072703          	lw	a4,1024(a4) # 80008f40 <nsizes>
    80006b48:	4785                	li	a5,1
    80006b4a:	06e7db63          	bge	a5,a4,80006bc0 <bd_initfree+0x9c>
    80006b4e:	8aaa                	mv	s5,a0
    80006b50:	8b2e                	mv	s6,a1
    80006b52:	4901                	li	s2,0
  int free = 0;
    80006b54:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006b56:	00002c97          	auipc	s9,0x2
    80006b5a:	3dac8c93          	addi	s9,s9,986 # 80008f30 <bd_base>
  return n / BLK_SIZE(k);
    80006b5e:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006b60:	00002b97          	auipc	s7,0x2
    80006b64:	3e0b8b93          	addi	s7,s7,992 # 80008f40 <nsizes>
    80006b68:	a039                	j	80006b76 <bd_initfree+0x52>
    80006b6a:	2905                	addiw	s2,s2,1
    80006b6c:	000ba783          	lw	a5,0(s7)
    80006b70:	37fd                	addiw	a5,a5,-1
    80006b72:	04f95863          	bge	s2,a5,80006bc2 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006b76:	85d6                	mv	a1,s5
    80006b78:	854a                	mv	a0,s2
    80006b7a:	00000097          	auipc	ra,0x0
    80006b7e:	dd6080e7          	jalr	-554(ra) # 80006950 <blk_index_next>
    80006b82:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006b84:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006b88:	409b04bb          	subw	s1,s6,s1
    80006b8c:	012c17b3          	sll	a5,s8,s2
    80006b90:	02f4c4b3          	div	s1,s1,a5
    80006b94:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006b96:	85aa                	mv	a1,a0
    80006b98:	854a                	mv	a0,s2
    80006b9a:	00000097          	auipc	ra,0x0
    80006b9e:	eda080e7          	jalr	-294(ra) # 80006a74 <bd_initfree_pair>
    80006ba2:	01450d3b          	addw	s10,a0,s4
    80006ba6:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006baa:	fc99d0e3          	bge	s3,s1,80006b6a <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006bae:	85a6                	mv	a1,s1
    80006bb0:	854a                	mv	a0,s2
    80006bb2:	00000097          	auipc	ra,0x0
    80006bb6:	ec2080e7          	jalr	-318(ra) # 80006a74 <bd_initfree_pair>
    80006bba:	00ad0a3b          	addw	s4,s10,a0
    80006bbe:	b775                	j	80006b6a <bd_initfree+0x46>
  int free = 0;
    80006bc0:	4a01                	li	s4,0
  }
  return free;
}
    80006bc2:	8552                	mv	a0,s4
    80006bc4:	60e6                	ld	ra,88(sp)
    80006bc6:	6446                	ld	s0,80(sp)
    80006bc8:	64a6                	ld	s1,72(sp)
    80006bca:	6906                	ld	s2,64(sp)
    80006bcc:	79e2                	ld	s3,56(sp)
    80006bce:	7a42                	ld	s4,48(sp)
    80006bd0:	7aa2                	ld	s5,40(sp)
    80006bd2:	7b02                	ld	s6,32(sp)
    80006bd4:	6be2                	ld	s7,24(sp)
    80006bd6:	6c42                	ld	s8,16(sp)
    80006bd8:	6ca2                	ld	s9,8(sp)
    80006bda:	6d02                	ld	s10,0(sp)
    80006bdc:	6125                	addi	sp,sp,96
    80006bde:	8082                	ret

0000000080006be0 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006be0:	7179                	addi	sp,sp,-48
    80006be2:	f406                	sd	ra,40(sp)
    80006be4:	f022                	sd	s0,32(sp)
    80006be6:	ec26                	sd	s1,24(sp)
    80006be8:	e84a                	sd	s2,16(sp)
    80006bea:	e44e                	sd	s3,8(sp)
    80006bec:	1800                	addi	s0,sp,48
    80006bee:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006bf0:	00002997          	auipc	s3,0x2
    80006bf4:	34098993          	addi	s3,s3,832 # 80008f30 <bd_base>
    80006bf8:	0009b483          	ld	s1,0(s3)
    80006bfc:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006c00:	00002797          	auipc	a5,0x2
    80006c04:	3407a783          	lw	a5,832(a5) # 80008f40 <nsizes>
    80006c08:	37fd                	addiw	a5,a5,-1
    80006c0a:	4641                	li	a2,16
    80006c0c:	00f61633          	sll	a2,a2,a5
    80006c10:	85a6                	mv	a1,s1
    80006c12:	00002517          	auipc	a0,0x2
    80006c16:	1be50513          	addi	a0,a0,446 # 80008dd0 <syscalls+0x4a0>
    80006c1a:	ffffa097          	auipc	ra,0xffffa
    80006c1e:	9ac080e7          	jalr	-1620(ra) # 800005c6 <printf>
  bd_mark(bd_base, p);
    80006c22:	85ca                	mv	a1,s2
    80006c24:	0009b503          	ld	a0,0(s3)
    80006c28:	00000097          	auipc	ra,0x0
    80006c2c:	d74080e7          	jalr	-652(ra) # 8000699c <bd_mark>
  return meta;
}
    80006c30:	8526                	mv	a0,s1
    80006c32:	70a2                	ld	ra,40(sp)
    80006c34:	7402                	ld	s0,32(sp)
    80006c36:	64e2                	ld	s1,24(sp)
    80006c38:	6942                	ld	s2,16(sp)
    80006c3a:	69a2                	ld	s3,8(sp)
    80006c3c:	6145                	addi	sp,sp,48
    80006c3e:	8082                	ret

0000000080006c40 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006c40:	1101                	addi	sp,sp,-32
    80006c42:	ec06                	sd	ra,24(sp)
    80006c44:	e822                	sd	s0,16(sp)
    80006c46:	e426                	sd	s1,8(sp)
    80006c48:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006c4a:	00002497          	auipc	s1,0x2
    80006c4e:	2f64a483          	lw	s1,758(s1) # 80008f40 <nsizes>
    80006c52:	fff4879b          	addiw	a5,s1,-1
    80006c56:	44c1                	li	s1,16
    80006c58:	00f494b3          	sll	s1,s1,a5
    80006c5c:	00002797          	auipc	a5,0x2
    80006c60:	2d47b783          	ld	a5,724(a5) # 80008f30 <bd_base>
    80006c64:	8d1d                	sub	a0,a0,a5
    80006c66:	40a4853b          	subw	a0,s1,a0
    80006c6a:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006c6e:	00905a63          	blez	s1,80006c82 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006c72:	357d                	addiw	a0,a0,-1
    80006c74:	41f5549b          	sraiw	s1,a0,0x1f
    80006c78:	01c4d49b          	srliw	s1,s1,0x1c
    80006c7c:	9ca9                	addw	s1,s1,a0
    80006c7e:	98c1                	andi	s1,s1,-16
    80006c80:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006c82:	85a6                	mv	a1,s1
    80006c84:	00002517          	auipc	a0,0x2
    80006c88:	18450513          	addi	a0,a0,388 # 80008e08 <syscalls+0x4d8>
    80006c8c:	ffffa097          	auipc	ra,0xffffa
    80006c90:	93a080e7          	jalr	-1734(ra) # 800005c6 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006c94:	00002717          	auipc	a4,0x2
    80006c98:	29c73703          	ld	a4,668(a4) # 80008f30 <bd_base>
    80006c9c:	00002597          	auipc	a1,0x2
    80006ca0:	2a45a583          	lw	a1,676(a1) # 80008f40 <nsizes>
    80006ca4:	fff5879b          	addiw	a5,a1,-1
    80006ca8:	45c1                	li	a1,16
    80006caa:	00f595b3          	sll	a1,a1,a5
    80006cae:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006cb2:	95ba                	add	a1,a1,a4
    80006cb4:	953a                	add	a0,a0,a4
    80006cb6:	00000097          	auipc	ra,0x0
    80006cba:	ce6080e7          	jalr	-794(ra) # 8000699c <bd_mark>
  return unavailable;
}
    80006cbe:	8526                	mv	a0,s1
    80006cc0:	60e2                	ld	ra,24(sp)
    80006cc2:	6442                	ld	s0,16(sp)
    80006cc4:	64a2                	ld	s1,8(sp)
    80006cc6:	6105                	addi	sp,sp,32
    80006cc8:	8082                	ret

0000000080006cca <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006cca:	715d                	addi	sp,sp,-80
    80006ccc:	e486                	sd	ra,72(sp)
    80006cce:	e0a2                	sd	s0,64(sp)
    80006cd0:	fc26                	sd	s1,56(sp)
    80006cd2:	f84a                	sd	s2,48(sp)
    80006cd4:	f44e                	sd	s3,40(sp)
    80006cd6:	f052                	sd	s4,32(sp)
    80006cd8:	ec56                	sd	s5,24(sp)
    80006cda:	e85a                	sd	s6,16(sp)
    80006cdc:	e45e                	sd	s7,8(sp)
    80006cde:	e062                	sd	s8,0(sp)
    80006ce0:	0880                	addi	s0,sp,80
    80006ce2:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006ce4:	fff50493          	addi	s1,a0,-1
    80006ce8:	98c1                	andi	s1,s1,-16
    80006cea:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006cec:	00002597          	auipc	a1,0x2
    80006cf0:	13c58593          	addi	a1,a1,316 # 80008e28 <syscalls+0x4f8>
    80006cf4:	0002f517          	auipc	a0,0x2f
    80006cf8:	7dc50513          	addi	a0,a0,2012 # 800364d0 <lock>
    80006cfc:	ffffa097          	auipc	ra,0xffffa
    80006d00:	dc0080e7          	jalr	-576(ra) # 80000abc <initlock>
  bd_base = (void *) p;
    80006d04:	00002797          	auipc	a5,0x2
    80006d08:	2297b623          	sd	s1,556(a5) # 80008f30 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006d0c:	409c0933          	sub	s2,s8,s1
    80006d10:	43f95513          	srai	a0,s2,0x3f
    80006d14:	893d                	andi	a0,a0,15
    80006d16:	954a                	add	a0,a0,s2
    80006d18:	8511                	srai	a0,a0,0x4
    80006d1a:	00000097          	auipc	ra,0x0
    80006d1e:	c60080e7          	jalr	-928(ra) # 8000697a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006d22:	47c1                	li	a5,16
    80006d24:	00a797b3          	sll	a5,a5,a0
    80006d28:	1b27c663          	blt	a5,s2,80006ed4 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006d2c:	2505                	addiw	a0,a0,1
    80006d2e:	00002797          	auipc	a5,0x2
    80006d32:	20a7a923          	sw	a0,530(a5) # 80008f40 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006d36:	00002997          	auipc	s3,0x2
    80006d3a:	20a98993          	addi	s3,s3,522 # 80008f40 <nsizes>
    80006d3e:	0009a603          	lw	a2,0(s3)
    80006d42:	85ca                	mv	a1,s2
    80006d44:	00002517          	auipc	a0,0x2
    80006d48:	0ec50513          	addi	a0,a0,236 # 80008e30 <syscalls+0x500>
    80006d4c:	ffffa097          	auipc	ra,0xffffa
    80006d50:	87a080e7          	jalr	-1926(ra) # 800005c6 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006d54:	00002797          	auipc	a5,0x2
    80006d58:	1e97b223          	sd	s1,484(a5) # 80008f38 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006d5c:	0009a603          	lw	a2,0(s3)
    80006d60:	00561913          	slli	s2,a2,0x5
    80006d64:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006d66:	0056161b          	slliw	a2,a2,0x5
    80006d6a:	4581                	li	a1,0
    80006d6c:	8526                	mv	a0,s1
    80006d6e:	ffffa097          	auipc	ra,0xffffa
    80006d72:	108080e7          	jalr	264(ra) # 80000e76 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006d76:	0009a783          	lw	a5,0(s3)
    80006d7a:	06f05a63          	blez	a5,80006dee <bd_init+0x124>
    80006d7e:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006d80:	00002a97          	auipc	s5,0x2
    80006d84:	1b8a8a93          	addi	s5,s5,440 # 80008f38 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006d88:	00002a17          	auipc	s4,0x2
    80006d8c:	1b8a0a13          	addi	s4,s4,440 # 80008f40 <nsizes>
    80006d90:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006d92:	00599b93          	slli	s7,s3,0x5
    80006d96:	000ab503          	ld	a0,0(s5)
    80006d9a:	955e                	add	a0,a0,s7
    80006d9c:	00000097          	auipc	ra,0x0
    80006da0:	166080e7          	jalr	358(ra) # 80006f02 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006da4:	000a2483          	lw	s1,0(s4)
    80006da8:	34fd                	addiw	s1,s1,-1
    80006daa:	413484bb          	subw	s1,s1,s3
    80006dae:	009b14bb          	sllw	s1,s6,s1
    80006db2:	fff4879b          	addiw	a5,s1,-1
    80006db6:	41f7d49b          	sraiw	s1,a5,0x1f
    80006dba:	01d4d49b          	srliw	s1,s1,0x1d
    80006dbe:	9cbd                	addw	s1,s1,a5
    80006dc0:	98e1                	andi	s1,s1,-8
    80006dc2:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006dc4:	000ab783          	ld	a5,0(s5)
    80006dc8:	9bbe                	add	s7,s7,a5
    80006dca:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006dce:	848d                	srai	s1,s1,0x3
    80006dd0:	8626                	mv	a2,s1
    80006dd2:	4581                	li	a1,0
    80006dd4:	854a                	mv	a0,s2
    80006dd6:	ffffa097          	auipc	ra,0xffffa
    80006dda:	0a0080e7          	jalr	160(ra) # 80000e76 <memset>
    p += sz;
    80006dde:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006de0:	0985                	addi	s3,s3,1
    80006de2:	000a2703          	lw	a4,0(s4)
    80006de6:	0009879b          	sext.w	a5,s3
    80006dea:	fae7c4e3          	blt	a5,a4,80006d92 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006dee:	00002797          	auipc	a5,0x2
    80006df2:	1527a783          	lw	a5,338(a5) # 80008f40 <nsizes>
    80006df6:	4705                	li	a4,1
    80006df8:	06f75163          	bge	a4,a5,80006e5a <bd_init+0x190>
    80006dfc:	02000a13          	li	s4,32
    80006e00:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006e02:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006e04:	00002b17          	auipc	s6,0x2
    80006e08:	134b0b13          	addi	s6,s6,308 # 80008f38 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006e0c:	00002a97          	auipc	s5,0x2
    80006e10:	134a8a93          	addi	s5,s5,308 # 80008f40 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006e14:	37fd                	addiw	a5,a5,-1
    80006e16:	413787bb          	subw	a5,a5,s3
    80006e1a:	00fb94bb          	sllw	s1,s7,a5
    80006e1e:	fff4879b          	addiw	a5,s1,-1
    80006e22:	41f7d49b          	sraiw	s1,a5,0x1f
    80006e26:	01d4d49b          	srliw	s1,s1,0x1d
    80006e2a:	9cbd                	addw	s1,s1,a5
    80006e2c:	98e1                	andi	s1,s1,-8
    80006e2e:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006e30:	000b3783          	ld	a5,0(s6)
    80006e34:	97d2                	add	a5,a5,s4
    80006e36:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006e3a:	848d                	srai	s1,s1,0x3
    80006e3c:	8626                	mv	a2,s1
    80006e3e:	4581                	li	a1,0
    80006e40:	854a                	mv	a0,s2
    80006e42:	ffffa097          	auipc	ra,0xffffa
    80006e46:	034080e7          	jalr	52(ra) # 80000e76 <memset>
    p += sz;
    80006e4a:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006e4c:	2985                	addiw	s3,s3,1
    80006e4e:	000aa783          	lw	a5,0(s5)
    80006e52:	020a0a13          	addi	s4,s4,32
    80006e56:	faf9cfe3          	blt	s3,a5,80006e14 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006e5a:	197d                	addi	s2,s2,-1
    80006e5c:	ff097913          	andi	s2,s2,-16
    80006e60:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006e62:	854a                	mv	a0,s2
    80006e64:	00000097          	auipc	ra,0x0
    80006e68:	d7c080e7          	jalr	-644(ra) # 80006be0 <bd_mark_data_structures>
    80006e6c:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006e6e:	85ca                	mv	a1,s2
    80006e70:	8562                	mv	a0,s8
    80006e72:	00000097          	auipc	ra,0x0
    80006e76:	dce080e7          	jalr	-562(ra) # 80006c40 <bd_mark_unavailable>
    80006e7a:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006e7c:	00002a97          	auipc	s5,0x2
    80006e80:	0c4a8a93          	addi	s5,s5,196 # 80008f40 <nsizes>
    80006e84:	000aa783          	lw	a5,0(s5)
    80006e88:	37fd                	addiw	a5,a5,-1
    80006e8a:	44c1                	li	s1,16
    80006e8c:	00f497b3          	sll	a5,s1,a5
    80006e90:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80006e92:	00002597          	auipc	a1,0x2
    80006e96:	09e5b583          	ld	a1,158(a1) # 80008f30 <bd_base>
    80006e9a:	95be                	add	a1,a1,a5
    80006e9c:	854a                	mv	a0,s2
    80006e9e:	00000097          	auipc	ra,0x0
    80006ea2:	c86080e7          	jalr	-890(ra) # 80006b24 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80006ea6:	000aa603          	lw	a2,0(s5)
    80006eaa:	367d                	addiw	a2,a2,-1
    80006eac:	00c49633          	sll	a2,s1,a2
    80006eb0:	41460633          	sub	a2,a2,s4
    80006eb4:	41360633          	sub	a2,a2,s3
    80006eb8:	02c51463          	bne	a0,a2,80006ee0 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    80006ebc:	60a6                	ld	ra,72(sp)
    80006ebe:	6406                	ld	s0,64(sp)
    80006ec0:	74e2                	ld	s1,56(sp)
    80006ec2:	7942                	ld	s2,48(sp)
    80006ec4:	79a2                	ld	s3,40(sp)
    80006ec6:	7a02                	ld	s4,32(sp)
    80006ec8:	6ae2                	ld	s5,24(sp)
    80006eca:	6b42                	ld	s6,16(sp)
    80006ecc:	6ba2                	ld	s7,8(sp)
    80006ece:	6c02                	ld	s8,0(sp)
    80006ed0:	6161                	addi	sp,sp,80
    80006ed2:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80006ed4:	2509                	addiw	a0,a0,2
    80006ed6:	00002797          	auipc	a5,0x2
    80006eda:	06a7a523          	sw	a0,106(a5) # 80008f40 <nsizes>
    80006ede:	bda1                	j	80006d36 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80006ee0:	85aa                	mv	a1,a0
    80006ee2:	00002517          	auipc	a0,0x2
    80006ee6:	f8e50513          	addi	a0,a0,-114 # 80008e70 <syscalls+0x540>
    80006eea:	ffff9097          	auipc	ra,0xffff9
    80006eee:	6dc080e7          	jalr	1756(ra) # 800005c6 <printf>
    panic("bd_init: free mem");
    80006ef2:	00002517          	auipc	a0,0x2
    80006ef6:	f8e50513          	addi	a0,a0,-114 # 80008e80 <syscalls+0x550>
    80006efa:	ffff9097          	auipc	ra,0xffff9
    80006efe:	66a080e7          	jalr	1642(ra) # 80000564 <panic>

0000000080006f02 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80006f02:	1141                	addi	sp,sp,-16
    80006f04:	e422                	sd	s0,8(sp)
    80006f06:	0800                	addi	s0,sp,16
  lst->next = lst;
    80006f08:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80006f0a:	e508                	sd	a0,8(a0)
}
    80006f0c:	6422                	ld	s0,8(sp)
    80006f0e:	0141                	addi	sp,sp,16
    80006f10:	8082                	ret

0000000080006f12 <lst_empty>:

int
lst_empty(struct list *lst) {
    80006f12:	1141                	addi	sp,sp,-16
    80006f14:	e422                	sd	s0,8(sp)
    80006f16:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80006f18:	611c                	ld	a5,0(a0)
    80006f1a:	40a78533          	sub	a0,a5,a0
}
    80006f1e:	00153513          	seqz	a0,a0
    80006f22:	6422                	ld	s0,8(sp)
    80006f24:	0141                	addi	sp,sp,16
    80006f26:	8082                	ret

0000000080006f28 <lst_remove>:

void
lst_remove(struct list *e) {
    80006f28:	1141                	addi	sp,sp,-16
    80006f2a:	e422                	sd	s0,8(sp)
    80006f2c:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80006f2e:	6518                	ld	a4,8(a0)
    80006f30:	611c                	ld	a5,0(a0)
    80006f32:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80006f34:	6518                	ld	a4,8(a0)
    80006f36:	e798                	sd	a4,8(a5)
}
    80006f38:	6422                	ld	s0,8(sp)
    80006f3a:	0141                	addi	sp,sp,16
    80006f3c:	8082                	ret

0000000080006f3e <lst_pop>:

void*
lst_pop(struct list *lst) {
    80006f3e:	1101                	addi	sp,sp,-32
    80006f40:	ec06                	sd	ra,24(sp)
    80006f42:	e822                	sd	s0,16(sp)
    80006f44:	e426                	sd	s1,8(sp)
    80006f46:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80006f48:	6104                	ld	s1,0(a0)
    80006f4a:	00a48d63          	beq	s1,a0,80006f64 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80006f4e:	8526                	mv	a0,s1
    80006f50:	00000097          	auipc	ra,0x0
    80006f54:	fd8080e7          	jalr	-40(ra) # 80006f28 <lst_remove>
  return (void *)p;
}
    80006f58:	8526                	mv	a0,s1
    80006f5a:	60e2                	ld	ra,24(sp)
    80006f5c:	6442                	ld	s0,16(sp)
    80006f5e:	64a2                	ld	s1,8(sp)
    80006f60:	6105                	addi	sp,sp,32
    80006f62:	8082                	ret
    panic("lst_pop");
    80006f64:	00002517          	auipc	a0,0x2
    80006f68:	f3450513          	addi	a0,a0,-204 # 80008e98 <syscalls+0x568>
    80006f6c:	ffff9097          	auipc	ra,0xffff9
    80006f70:	5f8080e7          	jalr	1528(ra) # 80000564 <panic>

0000000080006f74 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80006f74:	1141                	addi	sp,sp,-16
    80006f76:	e422                	sd	s0,8(sp)
    80006f78:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80006f7a:	611c                	ld	a5,0(a0)
    80006f7c:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80006f7e:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80006f80:	611c                	ld	a5,0(a0)
    80006f82:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80006f84:	e10c                	sd	a1,0(a0)
}
    80006f86:	6422                	ld	s0,8(sp)
    80006f88:	0141                	addi	sp,sp,16
    80006f8a:	8082                	ret

0000000080006f8c <lst_print>:

void
lst_print(struct list *lst)
{
    80006f8c:	7179                	addi	sp,sp,-48
    80006f8e:	f406                	sd	ra,40(sp)
    80006f90:	f022                	sd	s0,32(sp)
    80006f92:	ec26                	sd	s1,24(sp)
    80006f94:	e84a                	sd	s2,16(sp)
    80006f96:	e44e                	sd	s3,8(sp)
    80006f98:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80006f9a:	6104                	ld	s1,0(a0)
    80006f9c:	02950063          	beq	a0,s1,80006fbc <lst_print+0x30>
    80006fa0:	892a                	mv	s2,a0
    printf(" %p", p);
    80006fa2:	00002997          	auipc	s3,0x2
    80006fa6:	efe98993          	addi	s3,s3,-258 # 80008ea0 <syscalls+0x570>
    80006faa:	85a6                	mv	a1,s1
    80006fac:	854e                	mv	a0,s3
    80006fae:	ffff9097          	auipc	ra,0xffff9
    80006fb2:	618080e7          	jalr	1560(ra) # 800005c6 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80006fb6:	6084                	ld	s1,0(s1)
    80006fb8:	fe9919e3          	bne	s2,s1,80006faa <lst_print+0x1e>
  }
  printf("\n");
    80006fbc:	00001517          	auipc	a0,0x1
    80006fc0:	24450513          	addi	a0,a0,580 # 80008200 <digits+0x90>
    80006fc4:	ffff9097          	auipc	ra,0xffff9
    80006fc8:	602080e7          	jalr	1538(ra) # 800005c6 <printf>
}
    80006fcc:	70a2                	ld	ra,40(sp)
    80006fce:	7402                	ld	s0,32(sp)
    80006fd0:	64e2                	ld	s1,24(sp)
    80006fd2:	6942                	ld	s2,16(sp)
    80006fd4:	69a2                	ld	s3,8(sp)
    80006fd6:	6145                	addi	sp,sp,48
    80006fd8:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...

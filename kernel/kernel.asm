
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	16010113          	addi	sp,sp,352 # 8000a160 <stack0>
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
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fce70713          	addi	a4,a4,-50 # 8000a020 <timer_scratch>
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
    80000068:	e8c78793          	addi	a5,a5,-372 # 80005ef0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc643f>
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
    80000128:	00012517          	auipc	a0,0x12
    8000012c:	03850513          	addi	a0,a0,56 # 80012160 <cons>
    80000130:	00001097          	auipc	ra,0x1
    80000134:	a62080e7          	jalr	-1438(ra) # 80000b92 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000138:	00012497          	auipc	s1,0x12
    8000013c:	02848493          	addi	s1,s1,40 # 80012160 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000140:	00012917          	auipc	s2,0x12
    80000144:	0c090913          	addi	s2,s2,192 # 80012200 <cons+0xa0>
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
    80000162:	9f2080e7          	jalr	-1550(ra) # 80001b50 <myproc>
    80000166:	5d1c                	lw	a5,56(a0)
    80000168:	e7b5                	bnez	a5,800001d4 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    8000016a:	85a6                	mv	a1,s1
    8000016c:	854a                	mv	a0,s2
    8000016e:	00002097          	auipc	ra,0x2
    80000172:	350080e7          	jalr	848(ra) # 800024be <sleep>
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
    800001ae:	576080e7          	jalr	1398(ra) # 80002720 <either_copyout>
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
    800001be:	00012517          	auipc	a0,0x12
    800001c2:	fa250513          	addi	a0,a0,-94 # 80012160 <cons>
    800001c6:	00001097          	auipc	ra,0x1
    800001ca:	a9c080e7          	jalr	-1380(ra) # 80000c62 <release>

  return target - n;
    800001ce:	413b053b          	subw	a0,s6,s3
    800001d2:	a811                	j	800001e6 <consoleread+0xe4>
        release(&cons.lock);
    800001d4:	00012517          	auipc	a0,0x12
    800001d8:	f8c50513          	addi	a0,a0,-116 # 80012160 <cons>
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
    8000020a:	00012717          	auipc	a4,0x12
    8000020e:	fef72b23          	sw	a5,-10(a4) # 80012200 <cons+0xa0>
    80000212:	b775                	j	800001be <consoleread+0xbc>

0000000080000214 <consputc>:
  if(panicked){
    80000214:	0000a797          	auipc	a5,0xa
    80000218:	dcc7a783          	lw	a5,-564(a5) # 80009fe0 <panicked>
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
    8000027a:	00012517          	auipc	a0,0x12
    8000027e:	ee650513          	addi	a0,a0,-282 # 80012160 <cons>
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
    800002a0:	4da080e7          	jalr	1242(ra) # 80002776 <either_copyin>
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
    800002bc:	00012517          	auipc	a0,0x12
    800002c0:	ea450513          	addi	a0,a0,-348 # 80012160 <cons>
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
    800002f2:	00012517          	auipc	a0,0x12
    800002f6:	e6e50513          	addi	a0,a0,-402 # 80012160 <cons>
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
    8000031c:	4b4080e7          	jalr	1204(ra) # 800027cc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000320:	00012517          	auipc	a0,0x12
    80000324:	e4050513          	addi	a0,a0,-448 # 80012160 <cons>
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
    80000344:	00012717          	auipc	a4,0x12
    80000348:	e1c70713          	addi	a4,a4,-484 # 80012160 <cons>
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
    8000036e:	00012797          	auipc	a5,0x12
    80000372:	df278793          	addi	a5,a5,-526 # 80012160 <cons>
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
    8000039c:	00012797          	auipc	a5,0x12
    800003a0:	e647a783          	lw	a5,-412(a5) # 80012200 <cons+0xa0>
    800003a4:	0807879b          	addiw	a5,a5,128
    800003a8:	f6f61ce3          	bne	a2,a5,80000320 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003ac:	863e                	mv	a2,a5
    800003ae:	a07d                	j	8000045c <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b0:	00012717          	auipc	a4,0x12
    800003b4:	db070713          	addi	a4,a4,-592 # 80012160 <cons>
    800003b8:	0a872783          	lw	a5,168(a4)
    800003bc:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c0:	00012497          	auipc	s1,0x12
    800003c4:	da048493          	addi	s1,s1,-608 # 80012160 <cons>
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
    800003fc:	00012717          	auipc	a4,0x12
    80000400:	d6470713          	addi	a4,a4,-668 # 80012160 <cons>
    80000404:	0a872783          	lw	a5,168(a4)
    80000408:	0a472703          	lw	a4,164(a4)
    8000040c:	f0f70ae3          	beq	a4,a5,80000320 <consoleintr+0x3c>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00012717          	auipc	a4,0x12
    80000416:	def72b23          	sw	a5,-522(a4) # 80012208 <cons+0xa8>
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
    80000438:	00012797          	auipc	a5,0x12
    8000043c:	d2878793          	addi	a5,a5,-728 # 80012160 <cons>
    80000440:	0a87a703          	lw	a4,168(a5)
    80000444:	0017069b          	addiw	a3,a4,1
    80000448:	0006861b          	sext.w	a2,a3
    8000044c:	0ad7a423          	sw	a3,168(a5)
    80000450:	07f77713          	andi	a4,a4,127
    80000454:	97ba                	add	a5,a5,a4
    80000456:	4729                	li	a4,10
    80000458:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    8000045c:	00012797          	auipc	a5,0x12
    80000460:	dac7a423          	sw	a2,-600(a5) # 80012204 <cons+0xa4>
        wakeup(&cons.r);
    80000464:	00012517          	auipc	a0,0x12
    80000468:	d9c50513          	addi	a0,a0,-612 # 80012200 <cons+0xa0>
    8000046c:	00002097          	auipc	ra,0x2
    80000470:	1d2080e7          	jalr	466(ra) # 8000263e <wakeup>
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
    8000047e:	00009597          	auipc	a1,0x9
    80000482:	b9258593          	addi	a1,a1,-1134 # 80009010 <etext+0x10>
    80000486:	00012517          	auipc	a0,0x12
    8000048a:	cda50513          	addi	a0,a0,-806 # 80012160 <cons>
    8000048e:	00000097          	auipc	ra,0x0
    80000492:	62e080e7          	jalr	1582(ra) # 80000abc <initlock>

  uartinit();
    80000496:	00000097          	auipc	ra,0x0
    8000049a:	3f6080e7          	jalr	1014(ra) # 8000088c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049e:	00037797          	auipc	a5,0x37
    800004a2:	d5a78793          	addi	a5,a5,-678 # 800371f8 <devsw>
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
    800004e0:	00009617          	auipc	a2,0x9
    800004e4:	c9060613          	addi	a2,a2,-880 # 80009170 <digits>
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
    80000570:	00012797          	auipc	a5,0x12
    80000574:	cc07a023          	sw	zero,-832(a5) # 80012230 <pr+0x20>
  printf("PANIC: ");
    80000578:	00009517          	auipc	a0,0x9
    8000057c:	aa050513          	addi	a0,a0,-1376 # 80009018 <etext+0x18>
    80000580:	00000097          	auipc	ra,0x0
    80000584:	046080e7          	jalr	70(ra) # 800005c6 <printf>
  printf(s);
    80000588:	8526                	mv	a0,s1
    8000058a:	00000097          	auipc	ra,0x0
    8000058e:	03c080e7          	jalr	60(ra) # 800005c6 <printf>
  printf("\n");
    80000592:	00009517          	auipc	a0,0x9
    80000596:	c6e50513          	addi	a0,a0,-914 # 80009200 <digits+0x90>
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	02c080e7          	jalr	44(ra) # 800005c6 <printf>
  backtrace();
    800005a2:	00000097          	auipc	ra,0x0
    800005a6:	24e080e7          	jalr	590(ra) # 800007f0 <backtrace>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    800005aa:	00009517          	auipc	a0,0x9
    800005ae:	a7650513          	addi	a0,a0,-1418 # 80009020 <etext+0x20>
    800005b2:	00000097          	auipc	ra,0x0
    800005b6:	014080e7          	jalr	20(ra) # 800005c6 <printf>
  panicked = 1; // freeze other CPUs
    800005ba:	4785                	li	a5,1
    800005bc:	0000a717          	auipc	a4,0xa
    800005c0:	a2f72223          	sw	a5,-1500(a4) # 80009fe0 <panicked>
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
    800005f8:	00012c17          	auipc	s8,0x12
    800005fc:	c38c2c03          	lw	s8,-968(s8) # 80012230 <pr+0x20>
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
    80000620:	00009b17          	auipc	s6,0x9
    80000624:	af8b0b13          	addi	s6,s6,-1288 # 80009118 <etext+0x118>
      for(; *s; s++)
    80000628:	02800d13          	li	s10,40
  consputc('x');
    8000062c:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000062e:	00009a17          	auipc	s4,0x9
    80000632:	b42a0a13          	addi	s4,s4,-1214 # 80009170 <digits>
    80000636:	a82d                	j	80000670 <printf+0xaa>
    acquire(&pr.lock);
    80000638:	00012517          	auipc	a0,0x12
    8000063c:	bd850513          	addi	a0,a0,-1064 # 80012210 <pr>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	552080e7          	jalr	1362(ra) # 80000b92 <acquire>
    80000648:	bf75                	j	80000604 <printf+0x3e>
    panic("null fmt");
    8000064a:	00009517          	auipc	a0,0x9
    8000064e:	aae50513          	addi	a0,a0,-1362 # 800090f8 <etext+0xf8>
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
    8000078e:	00009b97          	auipc	s7,0x9
    80000792:	962b8b93          	addi	s7,s7,-1694 # 800090f0 <etext+0xf0>
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
    800007de:	00012517          	auipc	a0,0x12
    800007e2:	a3250513          	addi	a0,a0,-1486 # 80012210 <pr>
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
    80000822:	00009a17          	auipc	s4,0x9
    80000826:	8e6a0a13          	addi	s4,s4,-1818 # 80009108 <etext+0x108>
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
    80000864:	00012497          	auipc	s1,0x12
    80000868:	9ac48493          	addi	s1,s1,-1620 # 80012210 <pr>
    8000086c:	00009597          	auipc	a1,0x9
    80000870:	8a458593          	addi	a1,a1,-1884 # 80009110 <etext+0x110>
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
    80000950:	00038797          	auipc	a5,0x38
    80000954:	a7078793          	addi	a5,a5,-1424 # 800383c0 <end>
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
    80000970:	00012917          	auipc	s2,0x12
    80000974:	8c890913          	addi	s2,s2,-1848 # 80012238 <kmem>
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
    800009ac:	00008517          	auipc	a0,0x8
    800009b0:	7dc50513          	addi	a0,a0,2012 # 80009188 <digits+0x18>
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
    80000a0e:	00008597          	auipc	a1,0x8
    80000a12:	78258593          	addi	a1,a1,1922 # 80009190 <digits+0x20>
    80000a16:	00012517          	auipc	a0,0x12
    80000a1a:	82250513          	addi	a0,a0,-2014 # 80012238 <kmem>
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	09e080e7          	jalr	158(ra) # 80000abc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a26:	45c5                	li	a1,17
    80000a28:	05ee                	slli	a1,a1,0x1b
    80000a2a:	00038517          	auipc	a0,0x38
    80000a2e:	99650513          	addi	a0,a0,-1642 # 800383c0 <end>
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
    80000a4c:	00011497          	auipc	s1,0x11
    80000a50:	7ec48493          	addi	s1,s1,2028 # 80012238 <kmem>
    80000a54:	8526                	mv	a0,s1
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	13c080e7          	jalr	316(ra) # 80000b92 <acquire>
  r = kmem.freelist;
    80000a5e:	7084                	ld	s1,32(s1)
  if(r){
    80000a60:	c89d                	beqz	s1,80000a96 <kalloc+0x54>
    kmem.freelist = r->next;
    80000a62:	609c                	ld	a5,0(s1)
    80000a64:	00011517          	auipc	a0,0x11
    80000a68:	7d450513          	addi	a0,a0,2004 # 80012238 <kmem>
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
    80000a96:	00011517          	auipc	a0,0x11
    80000a9a:	7a250513          	addi	a0,a0,1954 # 80012238 <kmem>
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
    80000aae:	00011517          	auipc	a0,0x11
    80000ab2:	7b253503          	ld	a0,1970(a0) # 80012260 <kmem+0x28>
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
    80000ace:	00009797          	auipc	a5,0x9
    80000ad2:	5167a783          	lw	a5,1302(a5) # 80009fe4 <nlock>
    80000ad6:	6709                	lui	a4,0x2
    80000ad8:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000adc:	02f74063          	blt	a4,a5,80000afc <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000ae0:	00379693          	slli	a3,a5,0x3
    80000ae4:	00011717          	auipc	a4,0x11
    80000ae8:	78470713          	addi	a4,a4,1924 # 80012268 <locks>
    80000aec:	9736                	add	a4,a4,a3
    80000aee:	e308                	sd	a0,0(a4)
  nlock++;
    80000af0:	2785                	addiw	a5,a5,1
    80000af2:	00009717          	auipc	a4,0x9
    80000af6:	4ef72923          	sw	a5,1266(a4) # 80009fe4 <nlock>
    80000afa:	8082                	ret
{
    80000afc:	1141                	addi	sp,sp,-16
    80000afe:	e406                	sd	ra,8(sp)
    80000b00:	e022                	sd	s0,0(sp)
    80000b02:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b04:	00008517          	auipc	a0,0x8
    80000b08:	69450513          	addi	a0,a0,1684 # 80009198 <digits+0x28>
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
    80000b2c:	00c080e7          	jalr	12(ra) # 80001b34 <mycpu>
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
    80000b62:	fd6080e7          	jalr	-42(ra) # 80001b34 <mycpu>
    80000b66:	5d3c                	lw	a5,120(a0)
    80000b68:	cf89                	beqz	a5,80000b82 <push_off+0x40>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	fca080e7          	jalr	-54(ra) # 80001b34 <mycpu>
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
    80000b86:	fb2080e7          	jalr	-78(ra) # 80001b34 <mycpu>
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
    80000bc4:	00008517          	auipc	a0,0x8
    80000bc8:	5e450513          	addi	a0,a0,1508 # 800091a8 <digits+0x38>
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
    80000bf2:	f46080e7          	jalr	-186(ra) # 80001b34 <mycpu>
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
    80000c16:	f22080e7          	jalr	-222(ra) # 80001b34 <mycpu>
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
    80000c42:	00008517          	auipc	a0,0x8
    80000c46:	56e50513          	addi	a0,a0,1390 # 800091b0 <digits+0x40>
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	91a080e7          	jalr	-1766(ra) # 80000564 <panic>
    panic("pop_off");
    80000c52:	00008517          	auipc	a0,0x8
    80000c56:	57650513          	addi	a0,a0,1398 # 800091c8 <digits+0x58>
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
    80000c9a:	00008517          	auipc	a0,0x8
    80000c9e:	53650513          	addi	a0,a0,1334 # 800091d0 <digits+0x60>
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
    80000cbc:	00008517          	auipc	a0,0x8
    80000cc0:	51c50513          	addi	a0,a0,1308 # 800091d8 <digits+0x68>
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
    80000cf8:	13c080e7          	jalr	316(ra) # 80002e30 <argint>
    80000cfc:	12054463          	bltz	a0,80000e24 <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d00:	fac42783          	lw	a5,-84(s0)
    80000d04:	e39d                	bnez	a5,80000d2a <sys_ntas+0x56>
    80000d06:	00011797          	auipc	a5,0x11
    80000d0a:	56278793          	addi	a5,a5,1378 # 80012268 <locks>
    80000d0e:	00025697          	auipc	a3,0x25
    80000d12:	dda68693          	addi	a3,a3,-550 # 80025ae8 <pid_lock>
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
    80000d2a:	00008517          	auipc	a0,0x8
    80000d2e:	4de50513          	addi	a0,a0,1246 # 80009208 <digits+0x98>
    80000d32:	00000097          	auipc	ra,0x0
    80000d36:	894080e7          	jalr	-1900(ra) # 800005c6 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000d3a:	00011b17          	auipc	s6,0x11
    80000d3e:	52eb0b13          	addi	s6,s6,1326 # 80012268 <locks>
    80000d42:	00025b97          	auipc	s7,0x25
    80000d46:	da6b8b93          	addi	s7,s7,-602 # 80025ae8 <pid_lock>
  printf("=== lock kmem stats\n");
    80000d4a:	84da                	mv	s1,s6
  int tot = 0;
    80000d4c:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d4e:	00008917          	auipc	s2,0x8
    80000d52:	44290913          	addi	s2,s2,1090 # 80009190 <digits+0x20>
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
    80000d94:	00008517          	auipc	a0,0x8
    80000d98:	48c50513          	addi	a0,a0,1164 # 80009220 <digits+0xb0>
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
    80000db0:	00011497          	auipc	s1,0x11
    80000db4:	4b848493          	addi	s1,s1,1208 # 80012268 <locks>
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
    80001054:	ad4080e7          	jalr	-1324(ra) # 80001b24 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001058:	00009717          	auipc	a4,0x9
    8000105c:	f9070713          	addi	a4,a4,-112 # 80009fe8 <started>
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
    80001070:	ab8080e7          	jalr	-1352(ra) # 80001b24 <cpuid>
    80001074:	85aa                	mv	a1,a0
    80001076:	00008517          	auipc	a0,0x8
    8000107a:	1e250513          	addi	a0,a0,482 # 80009258 <digits+0xe8>
    8000107e:	fffff097          	auipc	ra,0xfffff
    80001082:	548080e7          	jalr	1352(ra) # 800005c6 <printf>
    kvminithart();    // turn on paging
    80001086:	00000097          	auipc	ra,0x0
    8000108a:	1e8080e7          	jalr	488(ra) # 8000126e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000108e:	00002097          	auipc	ra,0x2
    80001092:	938080e7          	jalr	-1736(ra) # 800029c6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001096:	00005097          	auipc	ra,0x5
    8000109a:	e9a080e7          	jalr	-358(ra) # 80005f30 <plicinithart>
  }

  scheduler();        
    8000109e:	00001097          	auipc	ra,0x1
    800010a2:	fd4080e7          	jalr	-44(ra) # 80002072 <scheduler>
    consoleinit();
    800010a6:	fffff097          	auipc	ra,0xfffff
    800010aa:	3d0080e7          	jalr	976(ra) # 80000476 <consoleinit>
    printfinit();
    800010ae:	fffff097          	auipc	ra,0xfffff
    800010b2:	7ac080e7          	jalr	1964(ra) # 8000085a <printfinit>
    printf("\n");
    800010b6:	00008517          	auipc	a0,0x8
    800010ba:	14a50513          	addi	a0,a0,330 # 80009200 <digits+0x90>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	508080e7          	jalr	1288(ra) # 800005c6 <printf>
    printf("xv6 kernel is booting\n");
    800010c6:	00008517          	auipc	a0,0x8
    800010ca:	17a50513          	addi	a0,a0,378 # 80009240 <digits+0xd0>
    800010ce:	fffff097          	auipc	ra,0xfffff
    800010d2:	4f8080e7          	jalr	1272(ra) # 800005c6 <printf>
    printf("\n");
    800010d6:	00008517          	auipc	a0,0x8
    800010da:	12a50513          	addi	a0,a0,298 # 80009200 <digits+0x90>
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
    80001102:	956080e7          	jalr	-1706(ra) # 80001a54 <procinit>
    trapinit();      // trap vectors
    80001106:	00002097          	auipc	ra,0x2
    8000110a:	898080e7          	jalr	-1896(ra) # 8000299e <trapinit>
    trapinithart();  // install kernel trap vector
    8000110e:	00002097          	auipc	ra,0x2
    80001112:	8b8080e7          	jalr	-1864(ra) # 800029c6 <trapinithart>
    plicinit();      // set up interrupt controller
    80001116:	00005097          	auipc	ra,0x5
    8000111a:	e04080e7          	jalr	-508(ra) # 80005f1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111e:	00005097          	auipc	ra,0x5
    80001122:	e12080e7          	jalr	-494(ra) # 80005f30 <plicinithart>
    binit();         // buffer cache
    80001126:	00002097          	auipc	ra,0x2
    8000112a:	fea080e7          	jalr	-22(ra) # 80003110 <binit>
    iinit();         // inode cache
    8000112e:	00002097          	auipc	ra,0x2
    80001132:	67a080e7          	jalr	1658(ra) # 800037a8 <iinit>
    fileinit();      // file table
    80001136:	00003097          	auipc	ra,0x3
    8000113a:	612080e7          	jalr	1554(ra) # 80004748 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000113e:	00005097          	auipc	ra,0x5
    80001142:	eea080e7          	jalr	-278(ra) # 80006028 <virtio_disk_init>
    userinit();      // first user process
    80001146:	00001097          	auipc	ra,0x1
    8000114a:	cb2080e7          	jalr	-846(ra) # 80001df8 <userinit>
    __sync_synchronize();
    8000114e:	0ff0000f          	fence
    started = 1;
    80001152:	4785                	li	a5,1
    80001154:	00009717          	auipc	a4,0x9
    80001158:	e8f72a23          	sw	a5,-364(a4) # 80009fe8 <started>
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
    80001184:	00008517          	auipc	a0,0x8
    80001188:	0ec50513          	addi	a0,a0,236 # 80009270 <digits+0x100>
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
    80001244:	00008517          	auipc	a0,0x8
    80001248:	03450513          	addi	a0,a0,52 # 80009278 <digits+0x108>
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
    80001274:	00009797          	auipc	a5,0x9
    80001278:	d7c7b783          	ld	a5,-644(a5) # 80009ff0 <kernel_pagetable>
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
    80001338:	00008517          	auipc	a0,0x8
    8000133c:	f5050513          	addi	a0,a0,-176 # 80009288 <digits+0x118>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	224080e7          	jalr	548(ra) # 80000564 <panic>
      panic("mappages: remap");
    80001348:	00008517          	auipc	a0,0x8
    8000134c:	f5050513          	addi	a0,a0,-176 # 80009298 <digits+0x128>
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
    80001382:	00009517          	auipc	a0,0x9
    80001386:	c6e53503          	ld	a0,-914(a0) # 80009ff0 <kernel_pagetable>
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	f4a080e7          	jalr	-182(ra) # 800012d4 <mappages>
    80001392:	e509                	bnez	a0,8000139c <kvmmap+0x28>
}
    80001394:	60a2                	ld	ra,8(sp)
    80001396:	6402                	ld	s0,0(sp)
    80001398:	0141                	addi	sp,sp,16
    8000139a:	8082                	ret
    panic("kvmmap");
    8000139c:	00008517          	auipc	a0,0x8
    800013a0:	f0c50513          	addi	a0,a0,-244 # 800092a8 <digits+0x138>
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
    800013be:	00009797          	auipc	a5,0x9
    800013c2:	c2a7b923          	sd	a0,-974(a5) # 80009ff0 <kernel_pagetable>
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
    80001410:	00008497          	auipc	s1,0x8
    80001414:	bf048493          	addi	s1,s1,-1040 # 80009000 <etext>
    80001418:	46a9                	li	a3,10
    8000141a:	80008617          	auipc	a2,0x80008
    8000141e:	be660613          	addi	a2,a2,-1050 # 9000 <_entry-0x7fff7000>
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
    80001448:	00007597          	auipc	a1,0x7
    8000144c:	bb858593          	addi	a1,a1,-1096 # 80008000 <_trampoline>
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
    8000149a:	00008517          	auipc	a0,0x8
    8000149e:	e1650513          	addi	a0,a0,-490 # 800092b0 <digits+0x140>
    800014a2:	fffff097          	auipc	ra,0xfffff
    800014a6:	0c2080e7          	jalr	194(ra) # 80000564 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800014aa:	85ca                	mv	a1,s2
    800014ac:	00008517          	auipc	a0,0x8
    800014b0:	e1450513          	addi	a0,a0,-492 # 800092c0 <digits+0x150>
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	112080e7          	jalr	274(ra) # 800005c6 <printf>
      panic("uvmunmap: not mapped");
    800014bc:	00008517          	auipc	a0,0x8
    800014c0:	e1450513          	addi	a0,a0,-492 # 800092d0 <digits+0x160>
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	0a0080e7          	jalr	160(ra) # 80000564 <panic>
      panic("uvmunmap: not a leaf");
    800014cc:	00008517          	auipc	a0,0x8
    800014d0:	e1c50513          	addi	a0,a0,-484 # 800092e8 <digits+0x178>
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
    80001560:	00008517          	auipc	a0,0x8
    80001564:	da050513          	addi	a0,a0,-608 # 80009300 <digits+0x190>
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
    800015d2:	00008517          	auipc	a0,0x8
    800015d6:	d4e50513          	addi	a0,a0,-690 # 80009320 <digits+0x1b0>
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
    80001778:	00008517          	auipc	a0,0x8
    8000177c:	bc850513          	addi	a0,a0,-1080 # 80009340 <digits+0x1d0>
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	de4080e7          	jalr	-540(ra) # 80000564 <panic>
      panic("uvmcopy: page not present");
    80001788:	00008517          	auipc	a0,0x8
    8000178c:	bd850513          	addi	a0,a0,-1064 # 80009360 <digits+0x1f0>
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
    800017f0:	00008517          	auipc	a0,0x8
    800017f4:	b9050513          	addi	a0,a0,-1136 # 80009380 <digits+0x210>
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

    // TIMING DATA - wait timing data
    p->wait_start = getTime();
  }
}
    80001a24:	60e2                	ld	ra,24(sp)
    80001a26:	6442                	ld	s0,16(sp)
    80001a28:	64a2                	ld	s1,8(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    panic("wakeup1");
    80001a2e:	00008517          	auipc	a0,0x8
    80001a32:	96250513          	addi	a0,a0,-1694 # 80009390 <digits+0x220>
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	b2e080e7          	jalr	-1234(ra) # 80000564 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a3e:	5098                	lw	a4,32(s1)
    80001a40:	4785                	li	a5,1
    80001a42:	fef711e3          	bne	a4,a5,80001a24 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a46:	4789                	li	a5,2
    80001a48:	d09c                	sw	a5,32(s1)


// TIMING DATA - timing functions
unsigned long getTime() { 
  unsigned long time; 
  asm volatile ("rdtime %0" : "=r" (time)); 
    80001a4a:	c01027f3          	rdtime	a5
    p->wait_start = getTime();
    80001a4e:	1af4b423          	sd	a5,424(s1)
}
    80001a52:	bfc9                	j	80001a24 <wakeup1+0x1c>

0000000080001a54 <procinit>:
{
    80001a54:	715d                	addi	sp,sp,-80
    80001a56:	e486                	sd	ra,72(sp)
    80001a58:	e0a2                	sd	s0,64(sp)
    80001a5a:	fc26                	sd	s1,56(sp)
    80001a5c:	f84a                	sd	s2,48(sp)
    80001a5e:	f44e                	sd	s3,40(sp)
    80001a60:	f052                	sd	s4,32(sp)
    80001a62:	ec56                	sd	s5,24(sp)
    80001a64:	e85a                	sd	s6,16(sp)
    80001a66:	e45e                	sd	s7,8(sp)
    80001a68:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a6a:	00008597          	auipc	a1,0x8
    80001a6e:	92e58593          	addi	a1,a1,-1746 # 80009398 <digits+0x228>
    80001a72:	00024517          	auipc	a0,0x24
    80001a76:	07650513          	addi	a0,a0,118 # 80025ae8 <pid_lock>
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	042080e7          	jalr	66(ra) # 80000abc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a82:	00024917          	auipc	s2,0x24
    80001a86:	48690913          	addi	s2,s2,1158 # 80025f08 <proc>
      initlock(&p->lock, "proc");
    80001a8a:	00008b97          	auipc	s7,0x8
    80001a8e:	916b8b93          	addi	s7,s7,-1770 # 800093a0 <digits+0x230>
      uint64 va = KSTACK((int) (p - proc));
    80001a92:	8b4a                	mv	s6,s2
    80001a94:	00007a97          	auipc	s5,0x7
    80001a98:	56ca8a93          	addi	s5,s5,1388 # 80009000 <etext>
    80001a9c:	040009b7          	lui	s3,0x4000
    80001aa0:	19fd                	addi	s3,s3,-1
    80001aa2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aa4:	0002ba17          	auipc	s4,0x2b
    80001aa8:	264a0a13          	addi	s4,s4,612 # 8002cd08 <tickslock>
      initlock(&p->lock, "proc");
    80001aac:	85de                	mv	a1,s7
    80001aae:	854a                	mv	a0,s2
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	00c080e7          	jalr	12(ra) # 80000abc <initlock>
      char *pa = kalloc();
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	f8a080e7          	jalr	-118(ra) # 80000a42 <kalloc>
    80001ac0:	85aa                	mv	a1,a0
      if(pa == 0)
    80001ac2:	c929                	beqz	a0,80001b14 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001ac4:	416904b3          	sub	s1,s2,s6
    80001ac8:	848d                	srai	s1,s1,0x3
    80001aca:	000ab783          	ld	a5,0(s5)
    80001ace:	02f484b3          	mul	s1,s1,a5
    80001ad2:	2485                	addiw	s1,s1,1
    80001ad4:	00d4949b          	slliw	s1,s1,0xd
    80001ad8:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001adc:	4699                	li	a3,6
    80001ade:	6605                	lui	a2,0x1
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	00000097          	auipc	ra,0x0
    80001ae6:	892080e7          	jalr	-1902(ra) # 80001374 <kvmmap>
      p->kstack = va;
    80001aea:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aee:	1b890913          	addi	s2,s2,440
    80001af2:	fb491de3          	bne	s2,s4,80001aac <procinit+0x58>
  kvminithart();
    80001af6:	fffff097          	auipc	ra,0xfffff
    80001afa:	778080e7          	jalr	1912(ra) # 8000126e <kvminithart>
}
    80001afe:	60a6                	ld	ra,72(sp)
    80001b00:	6406                	ld	s0,64(sp)
    80001b02:	74e2                	ld	s1,56(sp)
    80001b04:	7942                	ld	s2,48(sp)
    80001b06:	79a2                	ld	s3,40(sp)
    80001b08:	7a02                	ld	s4,32(sp)
    80001b0a:	6ae2                	ld	s5,24(sp)
    80001b0c:	6b42                	ld	s6,16(sp)
    80001b0e:	6ba2                	ld	s7,8(sp)
    80001b10:	6161                	addi	sp,sp,80
    80001b12:	8082                	ret
        panic("kalloc");
    80001b14:	00008517          	auipc	a0,0x8
    80001b18:	89450513          	addi	a0,a0,-1900 # 800093a8 <digits+0x238>
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	a48080e7          	jalr	-1464(ra) # 80000564 <panic>

0000000080001b24 <cpuid>:
{
    80001b24:	1141                	addi	sp,sp,-16
    80001b26:	e422                	sd	s0,8(sp)
    80001b28:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b2a:	8512                	mv	a0,tp
}
    80001b2c:	2501                	sext.w	a0,a0
    80001b2e:	6422                	ld	s0,8(sp)
    80001b30:	0141                	addi	sp,sp,16
    80001b32:	8082                	ret

0000000080001b34 <mycpu>:
mycpu(void) {
    80001b34:	1141                	addi	sp,sp,-16
    80001b36:	e422                	sd	s0,8(sp)
    80001b38:	0800                	addi	s0,sp,16
    80001b3a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b3c:	2781                	sext.w	a5,a5
    80001b3e:	079e                	slli	a5,a5,0x7
}
    80001b40:	00024517          	auipc	a0,0x24
    80001b44:	fc850513          	addi	a0,a0,-56 # 80025b08 <cpus>
    80001b48:	953e                	add	a0,a0,a5
    80001b4a:	6422                	ld	s0,8(sp)
    80001b4c:	0141                	addi	sp,sp,16
    80001b4e:	8082                	ret

0000000080001b50 <myproc>:
myproc(void) {
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
  push_off();
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	fe8080e7          	jalr	-24(ra) # 80000b42 <push_off>
    80001b62:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b64:	2781                	sext.w	a5,a5
    80001b66:	079e                	slli	a5,a5,0x7
    80001b68:	00024717          	auipc	a4,0x24
    80001b6c:	f8070713          	addi	a4,a4,-128 # 80025ae8 <pid_lock>
    80001b70:	97ba                	add	a5,a5,a4
    80001b72:	7384                	ld	s1,32(a5)
  pop_off();
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	08e080e7          	jalr	142(ra) # 80000c02 <pop_off>
}
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <forkret>:
{
    80001b88:	1141                	addi	sp,sp,-16
    80001b8a:	e406                	sd	ra,8(sp)
    80001b8c:	e022                	sd	s0,0(sp)
    80001b8e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	fc0080e7          	jalr	-64(ra) # 80001b50 <myproc>
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	0ca080e7          	jalr	202(ra) # 80000c62 <release>
  if (first) {
    80001ba0:	00008797          	auipc	a5,0x8
    80001ba4:	3f07a783          	lw	a5,1008(a5) # 80009f90 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
  usertrapret();
    80001baa:	00001097          	auipc	ra,0x1
    80001bae:	e34080e7          	jalr	-460(ra) # 800029de <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00008797          	auipc	a5,0x8
    80001bbe:	3c07ab23          	sw	zero,982(a5) # 80009f90 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00002097          	auipc	ra,0x2
    80001bc8:	b64080e7          	jalr	-1180(ra) # 80003728 <fsinit>
    80001bcc:	bff9                	j	80001baa <forkret+0x22>

0000000080001bce <allocpid>:
allocpid() {
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	e04a                	sd	s2,0(sp)
    80001bd8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001bda:	00024917          	auipc	s2,0x24
    80001bde:	f0e90913          	addi	s2,s2,-242 # 80025ae8 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	fae080e7          	jalr	-82(ra) # 80000b92 <acquire>
  pid = nextpid;
    80001bec:	00008797          	auipc	a5,0x8
    80001bf0:	3a878793          	addi	a5,a5,936 # 80009f94 <nextpid>
    80001bf4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bf6:	0014871b          	addiw	a4,s1,1
    80001bfa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bfc:	854a                	mv	a0,s2
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	064080e7          	jalr	100(ra) # 80000c62 <release>
}
    80001c06:	8526                	mv	a0,s1
    80001c08:	60e2                	ld	ra,24(sp)
    80001c0a:	6442                	ld	s0,16(sp)
    80001c0c:	64a2                	ld	s1,8(sp)
    80001c0e:	6902                	ld	s2,0(sp)
    80001c10:	6105                	addi	sp,sp,32
    80001c12:	8082                	ret

0000000080001c14 <proc_pagetable>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	e04a                	sd	s2,0(sp)
    80001c1e:	1000                	addi	s0,sp,32
    80001c20:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	910080e7          	jalr	-1776(ra) # 80001532 <uvmcreate>
    80001c2a:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c2c:	4729                	li	a4,10
    80001c2e:	00006697          	auipc	a3,0x6
    80001c32:	3d268693          	addi	a3,a3,978 # 80008000 <_trampoline>
    80001c36:	6605                	lui	a2,0x1
    80001c38:	040005b7          	lui	a1,0x4000
    80001c3c:	15fd                	addi	a1,a1,-1
    80001c3e:	05b2                	slli	a1,a1,0xc
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	694080e7          	jalr	1684(ra) # 800012d4 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c48:	4719                	li	a4,6
    80001c4a:	06093683          	ld	a3,96(s2)
    80001c4e:	6605                	lui	a2,0x1
    80001c50:	020005b7          	lui	a1,0x2000
    80001c54:	15fd                	addi	a1,a1,-1
    80001c56:	05b6                	slli	a1,a1,0xd
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	67a080e7          	jalr	1658(ra) # 800012d4 <mappages>
}
    80001c62:	8526                	mv	a0,s1
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6902                	ld	s2,0(sp)
    80001c6c:	6105                	addi	sp,sp,32
    80001c6e:	8082                	ret

0000000080001c70 <allocproc>:
{
    80001c70:	1101                	addi	sp,sp,-32
    80001c72:	ec06                	sd	ra,24(sp)
    80001c74:	e822                	sd	s0,16(sp)
    80001c76:	e426                	sd	s1,8(sp)
    80001c78:	e04a                	sd	s2,0(sp)
    80001c7a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c7c:	00024497          	auipc	s1,0x24
    80001c80:	28c48493          	addi	s1,s1,652 # 80025f08 <proc>
    80001c84:	0002b917          	auipc	s2,0x2b
    80001c88:	08490913          	addi	s2,s2,132 # 8002cd08 <tickslock>
    acquire(&p->lock);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	f04080e7          	jalr	-252(ra) # 80000b92 <acquire>
    if(p->state == UNUSED) {
    80001c96:	509c                	lw	a5,32(s1)
    80001c98:	cf81                	beqz	a5,80001cb0 <allocproc+0x40>
      release(&p->lock);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	fc6080e7          	jalr	-58(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ca4:	1b848493          	addi	s1,s1,440
    80001ca8:	ff2492e3          	bne	s1,s2,80001c8c <allocproc+0x1c>
  return 0;
    80001cac:	4481                	li	s1,0
    80001cae:	a8bd                	j	80001d2c <allocproc+0xbc>
  p->pid = allocpid();
    80001cb0:	00000097          	auipc	ra,0x0
    80001cb4:	f1e080e7          	jalr	-226(ra) # 80001bce <allocpid>
    80001cb8:	c0a8                	sw	a0,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	d88080e7          	jalr	-632(ra) # 80000a42 <kalloc>
    80001cc2:	892a                	mv	s2,a0
    80001cc4:	f0a8                	sd	a0,96(s1)
    80001cc6:	c935                	beqz	a0,80001d3a <allocproc+0xca>
  p->pagetable = proc_pagetable(p);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	00000097          	auipc	ra,0x0
    80001cce:	f4a080e7          	jalr	-182(ra) # 80001c14 <proc_pagetable>
    80001cd2:	eca8                	sd	a0,88(s1)
  p->trap_va = TRAPFRAME;
    80001cd4:	020007b7          	lui	a5,0x2000
    80001cd8:	17fd                	addi	a5,a5,-1
    80001cda:	07b6                	slli	a5,a5,0xd
    80001cdc:	16f4b823          	sd	a5,368(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001ce0:	07000613          	li	a2,112
    80001ce4:	4581                	li	a1,0
    80001ce6:	06848513          	addi	a0,s1,104
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	18c080e7          	jalr	396(ra) # 80000e76 <memset>
  p->context.ra = (uint64)forkret;
    80001cf2:	00000797          	auipc	a5,0x0
    80001cf6:	e9678793          	addi	a5,a5,-362 # 80001b88 <forkret>
    80001cfa:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cfc:	64bc                	ld	a5,72(s1)
    80001cfe:	6705                	lui	a4,0x1
    80001d00:	97ba                	add	a5,a5,a4
    80001d02:	f8bc                	sd	a5,112(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    80001d04:	c01027f3          	rdtime	a5
  p->creation_time = getTime();
    80001d08:	16f4bc23          	sd	a5,376(s1)
  p->first_run_time = 0;
    80001d0c:	1804b023          	sd	zero,384(s1)
  p->total_run_time = 0;
    80001d10:	1804b423          	sd	zero,392(s1)
  p->last_scheduled = 0;
    80001d14:	1804b823          	sd	zero,400(s1)
  p->total_wait_time = 0;
    80001d18:	1804bc23          	sd	zero,408(s1)
  p->completion_time = 0;
    80001d1c:	1a04b023          	sd	zero,416(s1)
  p->wait_start = 0;
    80001d20:	1a04b423          	sd	zero,424(s1)
  p->context_switches = 0;
    80001d24:	1a04a823          	sw	zero,432(s1)
  p->first_run = 0;
    80001d28:	1a04aa23          	sw	zero,436(s1)
}
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret
    release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f26080e7          	jalr	-218(ra) # 80000c62 <release>
    return 0;
    80001d44:	84ca                	mv	s1,s2
    80001d46:	b7dd                	j	80001d2c <allocproc+0xbc>

0000000080001d48 <proc_freepagetable>:
{
    80001d48:	1101                	addi	sp,sp,-32
    80001d4a:	ec06                	sd	ra,24(sp)
    80001d4c:	e822                	sd	s0,16(sp)
    80001d4e:	e426                	sd	s1,8(sp)
    80001d50:	e04a                	sd	s2,0(sp)
    80001d52:	1000                	addi	s0,sp,32
    80001d54:	84aa                	mv	s1,a0
    80001d56:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d58:	4681                	li	a3,0
    80001d5a:	6605                	lui	a2,0x1
    80001d5c:	040005b7          	lui	a1,0x4000
    80001d60:	15fd                	addi	a1,a1,-1
    80001d62:	05b2                	slli	a1,a1,0xc
    80001d64:	fffff097          	auipc	ra,0xfffff
    80001d68:	706080e7          	jalr	1798(ra) # 8000146a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d6c:	4681                	li	a3,0
    80001d6e:	6605                	lui	a2,0x1
    80001d70:	020005b7          	lui	a1,0x2000
    80001d74:	15fd                	addi	a1,a1,-1
    80001d76:	05b6                	slli	a1,a1,0xd
    80001d78:	8526                	mv	a0,s1
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	6f0080e7          	jalr	1776(ra) # 8000146a <uvmunmap>
  if(sz > 0)
    80001d82:	00091863          	bnez	s2,80001d92 <proc_freepagetable+0x4a>
}
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6902                	ld	s2,0(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret
    uvmfree(pagetable, sz);
    80001d92:	85ca                	mv	a1,s2
    80001d94:	8526                	mv	a0,s1
    80001d96:	00000097          	auipc	ra,0x0
    80001d9a:	93a080e7          	jalr	-1734(ra) # 800016d0 <uvmfree>
}
    80001d9e:	b7e5                	j	80001d86 <proc_freepagetable+0x3e>

0000000080001da0 <freeproc>:
{
    80001da0:	1101                	addi	sp,sp,-32
    80001da2:	ec06                	sd	ra,24(sp)
    80001da4:	e822                	sd	s0,16(sp)
    80001da6:	e426                	sd	s1,8(sp)
    80001da8:	1000                	addi	s0,sp,32
    80001daa:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001dac:	7128                	ld	a0,96(a0)
    80001dae:	c509                	beqz	a0,80001db8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	b8c080e7          	jalr	-1140(ra) # 8000093c <kfree>
  p->trapframe = 0;
    80001db8:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001dbc:	6ca8                	ld	a0,88(s1)
    80001dbe:	c511                	beqz	a0,80001dca <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001dc0:	68ac                	ld	a1,80(s1)
    80001dc2:	00000097          	auipc	ra,0x0
    80001dc6:	f86080e7          	jalr	-122(ra) # 80001d48 <proc_freepagetable>
  p->pagetable = 0;
    80001dca:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001dce:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001dd2:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001dd6:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001dda:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dde:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001de2:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001de6:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001dea:	0204a023          	sw	zero,32(s1)
}
    80001dee:	60e2                	ld	ra,24(sp)
    80001df0:	6442                	ld	s0,16(sp)
    80001df2:	64a2                	ld	s1,8(sp)
    80001df4:	6105                	addi	sp,sp,32
    80001df6:	8082                	ret

0000000080001df8 <userinit>:
{
    80001df8:	1101                	addi	sp,sp,-32
    80001dfa:	ec06                	sd	ra,24(sp)
    80001dfc:	e822                	sd	s0,16(sp)
    80001dfe:	e426                	sd	s1,8(sp)
    80001e00:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	e6e080e7          	jalr	-402(ra) # 80001c70 <allocproc>
    80001e0a:	84aa                	mv	s1,a0
  initproc = p;
    80001e0c:	00008797          	auipc	a5,0x8
    80001e10:	1ea7b623          	sd	a0,492(a5) # 80009ff8 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e14:	03400613          	li	a2,52
    80001e18:	00008597          	auipc	a1,0x8
    80001e1c:	18858593          	addi	a1,a1,392 # 80009fa0 <initcode>
    80001e20:	6d28                	ld	a0,88(a0)
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	74e080e7          	jalr	1870(ra) # 80001570 <uvminit>
  p->sz = PGSIZE;
    80001e2a:	6785                	lui	a5,0x1
    80001e2c:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e2e:	70b8                	ld	a4,96(s1)
    80001e30:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e34:	70b8                	ld	a4,96(s1)
    80001e36:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e38:	4641                	li	a2,16
    80001e3a:	00007597          	auipc	a1,0x7
    80001e3e:	57658593          	addi	a1,a1,1398 # 800093b0 <digits+0x240>
    80001e42:	16048513          	addi	a0,s1,352
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	1a6080e7          	jalr	422(ra) # 80000fec <safestrcpy>
  p->cwd = namei("/");
    80001e4e:	00007517          	auipc	a0,0x7
    80001e52:	57250513          	addi	a0,a0,1394 # 800093c0 <digits+0x250>
    80001e56:	00002097          	auipc	ra,0x2
    80001e5a:	300080e7          	jalr	768(ra) # 80004156 <namei>
    80001e5e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e62:	4789                	li	a5,2
    80001e64:	d09c                	sw	a5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    80001e66:	c01027f3          	rdtime	a5
  p->wait_start = getTime();
    80001e6a:	1af4b423          	sd	a5,424(s1)
  release(&p->lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	df2080e7          	jalr	-526(ra) # 80000c62 <release>
}
    80001e78:	60e2                	ld	ra,24(sp)
    80001e7a:	6442                	ld	s0,16(sp)
    80001e7c:	64a2                	ld	s1,8(sp)
    80001e7e:	6105                	addi	sp,sp,32
    80001e80:	8082                	ret

0000000080001e82 <growproc>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	e04a                	sd	s2,0(sp)
    80001e8c:	1000                	addi	s0,sp,32
    80001e8e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	cc0080e7          	jalr	-832(ra) # 80001b50 <myproc>
    80001e98:	892a                	mv	s2,a0
  sz = p->sz;
    80001e9a:	692c                	ld	a1,80(a0)
    80001e9c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001ea0:	00904f63          	bgtz	s1,80001ebe <growproc+0x3c>
  } else if(n < 0){
    80001ea4:	0204cc63          	bltz	s1,80001edc <growproc+0x5a>
  p->sz = sz;
    80001ea8:	1602                	slli	a2,a2,0x20
    80001eaa:	9201                	srli	a2,a2,0x20
    80001eac:	04c93823          	sd	a2,80(s2)
  return 0;
    80001eb0:	4501                	li	a0,0
}
    80001eb2:	60e2                	ld	ra,24(sp)
    80001eb4:	6442                	ld	s0,16(sp)
    80001eb6:	64a2                	ld	s1,8(sp)
    80001eb8:	6902                	ld	s2,0(sp)
    80001eba:	6105                	addi	sp,sp,32
    80001ebc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ebe:	9e25                	addw	a2,a2,s1
    80001ec0:	1602                	slli	a2,a2,0x20
    80001ec2:	9201                	srli	a2,a2,0x20
    80001ec4:	1582                	slli	a1,a1,0x20
    80001ec6:	9181                	srli	a1,a1,0x20
    80001ec8:	6d28                	ld	a0,88(a0)
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	75c080e7          	jalr	1884(ra) # 80001626 <uvmalloc>
    80001ed2:	0005061b          	sext.w	a2,a0
    80001ed6:	fa69                	bnez	a2,80001ea8 <growproc+0x26>
      return -1;
    80001ed8:	557d                	li	a0,-1
    80001eda:	bfe1                	j	80001eb2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001edc:	9e25                	addw	a2,a2,s1
    80001ede:	1602                	slli	a2,a2,0x20
    80001ee0:	9201                	srli	a2,a2,0x20
    80001ee2:	1582                	slli	a1,a1,0x20
    80001ee4:	9181                	srli	a1,a1,0x20
    80001ee6:	6d28                	ld	a0,88(a0)
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	6fa080e7          	jalr	1786(ra) # 800015e2 <uvmdealloc>
    80001ef0:	0005061b          	sext.w	a2,a0
    80001ef4:	bf55                	j	80001ea8 <growproc+0x26>

0000000080001ef6 <fork>:
{
    80001ef6:	7139                	addi	sp,sp,-64
    80001ef8:	fc06                	sd	ra,56(sp)
    80001efa:	f822                	sd	s0,48(sp)
    80001efc:	f426                	sd	s1,40(sp)
    80001efe:	f04a                	sd	s2,32(sp)
    80001f00:	ec4e                	sd	s3,24(sp)
    80001f02:	e852                	sd	s4,16(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001f08:	00000097          	auipc	ra,0x0
    80001f0c:	c48080e7          	jalr	-952(ra) # 80001b50 <myproc>
    80001f10:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f12:	00000097          	auipc	ra,0x0
    80001f16:	d5e080e7          	jalr	-674(ra) # 80001c70 <allocproc>
    80001f1a:	c57d                	beqz	a0,80002008 <fork+0x112>
    80001f1c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f1e:	050ab603          	ld	a2,80(s5)
    80001f22:	6d2c                	ld	a1,88(a0)
    80001f24:	058ab503          	ld	a0,88(s5)
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	7d6080e7          	jalr	2006(ra) # 800016fe <uvmcopy>
    80001f30:	04054a63          	bltz	a0,80001f84 <fork+0x8e>
  np->sz = p->sz;
    80001f34:	050ab783          	ld	a5,80(s5)
    80001f38:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001f3c:	035a3423          	sd	s5,40(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f40:	060ab683          	ld	a3,96(s5)
    80001f44:	87b6                	mv	a5,a3
    80001f46:	060a3703          	ld	a4,96(s4)
    80001f4a:	12068693          	addi	a3,a3,288
    80001f4e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f52:	6788                	ld	a0,8(a5)
    80001f54:	6b8c                	ld	a1,16(a5)
    80001f56:	6f90                	ld	a2,24(a5)
    80001f58:	01073023          	sd	a6,0(a4)
    80001f5c:	e708                	sd	a0,8(a4)
    80001f5e:	eb0c                	sd	a1,16(a4)
    80001f60:	ef10                	sd	a2,24(a4)
    80001f62:	02078793          	addi	a5,a5,32
    80001f66:	02070713          	addi	a4,a4,32
    80001f6a:	fed792e3          	bne	a5,a3,80001f4e <fork+0x58>
  np->trapframe->a0 = 0;
    80001f6e:	060a3783          	ld	a5,96(s4)
    80001f72:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f76:	0d8a8493          	addi	s1,s5,216
    80001f7a:	0d8a0913          	addi	s2,s4,216
    80001f7e:	158a8993          	addi	s3,s5,344
    80001f82:	a00d                	j	80001fa4 <fork+0xae>
    freeproc(np);
    80001f84:	8552                	mv	a0,s4
    80001f86:	00000097          	auipc	ra,0x0
    80001f8a:	e1a080e7          	jalr	-486(ra) # 80001da0 <freeproc>
    release(&np->lock);
    80001f8e:	8552                	mv	a0,s4
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	cd2080e7          	jalr	-814(ra) # 80000c62 <release>
    return -1;
    80001f98:	54fd                	li	s1,-1
    80001f9a:	a8a9                	j	80001ff4 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
    80001f9c:	04a1                	addi	s1,s1,8
    80001f9e:	0921                	addi	s2,s2,8
    80001fa0:	01348b63          	beq	s1,s3,80001fb6 <fork+0xc0>
    if(p->ofile[i])
    80001fa4:	6088                	ld	a0,0(s1)
    80001fa6:	d97d                	beqz	a0,80001f9c <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fa8:	00003097          	auipc	ra,0x3
    80001fac:	832080e7          	jalr	-1998(ra) # 800047da <filedup>
    80001fb0:	00a93023          	sd	a0,0(s2)
    80001fb4:	b7e5                	j	80001f9c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001fb6:	158ab503          	ld	a0,344(s5)
    80001fba:	00002097          	auipc	ra,0x2
    80001fbe:	9a8080e7          	jalr	-1624(ra) # 80003962 <idup>
    80001fc2:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fc6:	4641                	li	a2,16
    80001fc8:	160a8593          	addi	a1,s5,352
    80001fcc:	160a0513          	addi	a0,s4,352
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	01c080e7          	jalr	28(ra) # 80000fec <safestrcpy>
  pid = np->pid;
    80001fd8:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001fdc:	4789                	li	a5,2
    80001fde:	02fa2023          	sw	a5,32(s4)
  asm volatile ("rdtime %0" : "=r" (time)); 
    80001fe2:	c01027f3          	rdtime	a5
  np->wait_start = getTime();
    80001fe6:	1afa3423          	sd	a5,424(s4)
  release(&np->lock);
    80001fea:	8552                	mv	a0,s4
    80001fec:	fffff097          	auipc	ra,0xfffff
    80001ff0:	c76080e7          	jalr	-906(ra) # 80000c62 <release>
}
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	70e2                	ld	ra,56(sp)
    80001ff8:	7442                	ld	s0,48(sp)
    80001ffa:	74a2                	ld	s1,40(sp)
    80001ffc:	7902                	ld	s2,32(sp)
    80001ffe:	69e2                	ld	s3,24(sp)
    80002000:	6a42                	ld	s4,16(sp)
    80002002:	6aa2                	ld	s5,8(sp)
    80002004:	6121                	addi	sp,sp,64
    80002006:	8082                	ret
    return -1;
    80002008:	54fd                	li	s1,-1
    8000200a:	b7ed                	j	80001ff4 <fork+0xfe>

000000008000200c <reparent>:
{
    8000200c:	7179                	addi	sp,sp,-48
    8000200e:	f406                	sd	ra,40(sp)
    80002010:	f022                	sd	s0,32(sp)
    80002012:	ec26                	sd	s1,24(sp)
    80002014:	e84a                	sd	s2,16(sp)
    80002016:	e44e                	sd	s3,8(sp)
    80002018:	e052                	sd	s4,0(sp)
    8000201a:	1800                	addi	s0,sp,48
    8000201c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000201e:	00024497          	auipc	s1,0x24
    80002022:	eea48493          	addi	s1,s1,-278 # 80025f08 <proc>
      pp->parent = initproc;
    80002026:	00008a17          	auipc	s4,0x8
    8000202a:	fd2a0a13          	addi	s4,s4,-46 # 80009ff8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000202e:	0002b997          	auipc	s3,0x2b
    80002032:	cda98993          	addi	s3,s3,-806 # 8002cd08 <tickslock>
    80002036:	a029                	j	80002040 <reparent+0x34>
    80002038:	1b848493          	addi	s1,s1,440
    8000203c:	03348363          	beq	s1,s3,80002062 <reparent+0x56>
    if(pp->parent == p){
    80002040:	749c                	ld	a5,40(s1)
    80002042:	ff279be3          	bne	a5,s2,80002038 <reparent+0x2c>
      acquire(&pp->lock);
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	b4a080e7          	jalr	-1206(ra) # 80000b92 <acquire>
      pp->parent = initproc;
    80002050:	000a3783          	ld	a5,0(s4)
    80002054:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002056:	8526                	mv	a0,s1
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	c0a080e7          	jalr	-1014(ra) # 80000c62 <release>
    80002060:	bfe1                	j	80002038 <reparent+0x2c>
}
    80002062:	70a2                	ld	ra,40(sp)
    80002064:	7402                	ld	s0,32(sp)
    80002066:	64e2                	ld	s1,24(sp)
    80002068:	6942                	ld	s2,16(sp)
    8000206a:	69a2                	ld	s3,8(sp)
    8000206c:	6a02                	ld	s4,0(sp)
    8000206e:	6145                	addi	sp,sp,48
    80002070:	8082                	ret

0000000080002072 <scheduler>:
{
    80002072:	711d                	addi	sp,sp,-96
    80002074:	ec86                	sd	ra,88(sp)
    80002076:	e8a2                	sd	s0,80(sp)
    80002078:	e4a6                	sd	s1,72(sp)
    8000207a:	e0ca                	sd	s2,64(sp)
    8000207c:	fc4e                	sd	s3,56(sp)
    8000207e:	f852                	sd	s4,48(sp)
    80002080:	f456                	sd	s5,40(sp)
    80002082:	f05a                	sd	s6,32(sp)
    80002084:	ec5e                	sd	s7,24(sp)
    80002086:	e862                	sd	s8,16(sp)
    80002088:	e466                	sd	s9,8(sp)
    8000208a:	1080                	addi	s0,sp,96
    8000208c:	8792                	mv	a5,tp
  int id = r_tp();
    8000208e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002090:	00779b93          	slli	s7,a5,0x7
    80002094:	00024717          	auipc	a4,0x24
    80002098:	a5470713          	addi	a4,a4,-1452 # 80025ae8 <pid_lock>
    8000209c:	975e                	add	a4,a4,s7
    8000209e:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    800020a2:	00024717          	auipc	a4,0x24
    800020a6:	a6e70713          	addi	a4,a4,-1426 # 80025b10 <cpus+0x8>
    800020aa:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    800020ac:	4c0d                	li	s8,3
        c->proc = p;
    800020ae:	079e                	slli	a5,a5,0x7
    800020b0:	00024917          	auipc	s2,0x24
    800020b4:	a3890913          	addi	s2,s2,-1480 # 80025ae8 <pid_lock>
    800020b8:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ba:	0002ba97          	auipc	s5,0x2b
    800020be:	c4ea8a93          	addi	s5,s5,-946 # 8002cd08 <tickslock>
    800020c2:	a849                	j	80002154 <scheduler+0xe2>
  asm volatile ("rdtime %0" : "=r" (time)); 
    800020c4:	c01026f3          	rdtime	a3
          p->total_wait_time += getTime() - p->wait_start;
    800020c8:	1984b703          	ld	a4,408(s1)
    800020cc:	40f707b3          	sub	a5,a4,a5
    800020d0:	97b6                	add	a5,a5,a3
    800020d2:	18f4bc23          	sd	a5,408(s1)
          p->wait_start = 0;
    800020d6:	1a04b423          	sd	zero,424(s1)
    800020da:	a8b9                	j	80002138 <scheduler+0xc6>
        p->state = RUNNING;
    800020dc:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800020e0:	02993023          	sd	s1,32(s2)
  asm volatile ("rdtime %0" : "=r" (time)); 
    800020e4:	c01027f3          	rdtime	a5
        p->last_scheduled = getTime();
    800020e8:	18f4b823          	sd	a5,400(s1)
        p->context_switches++;
    800020ec:	1b04a783          	lw	a5,432(s1)
    800020f0:	2785                	addiw	a5,a5,1
    800020f2:	1af4a823          	sw	a5,432(s1)
        swtch(&c->scheduler, &p->context);
    800020f6:	06898593          	addi	a1,s3,104
    800020fa:	855e                	mv	a0,s7
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	79e080e7          	jalr	1950(ra) # 8000289a <swtch>
        c->proc = 0;
    80002104:	02093023          	sd	zero,32(s2)
        found = 1;
    80002108:	8cda                	mv	s9,s6
      c->intena = 0;
    8000210a:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    8000210e:	8526                	mv	a0,s1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b52080e7          	jalr	-1198(ra) # 80000c62 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002118:	1b848493          	addi	s1,s1,440
    8000211c:	03548863          	beq	s1,s5,8000214c <scheduler+0xda>
      acquire(&p->lock);
    80002120:	89a6                	mv	s3,s1
    80002122:	8526                	mv	a0,s1
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	a6e080e7          	jalr	-1426(ra) # 80000b92 <acquire>
      if(p->state == RUNNABLE) {
    8000212c:	509c                	lw	a5,32(s1)
    8000212e:	fd479ee3          	bne	a5,s4,8000210a <scheduler+0x98>
        if(p->wait_start != 0){
    80002132:	1a84b783          	ld	a5,424(s1)
    80002136:	f7d9                	bnez	a5,800020c4 <scheduler+0x52>
        if(p->first_run == 0) {
    80002138:	1b44a783          	lw	a5,436(s1)
    8000213c:	f3c5                	bnez	a5,800020dc <scheduler+0x6a>
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000213e:	c01027f3          	rdtime	a5
          p->first_run_time = getTime();
    80002142:	18f4b023          	sd	a5,384(s1)
          p->first_run = 1;
    80002146:	1b64aa23          	sw	s6,436(s1)
    8000214a:	bf49                	j	800020dc <scheduler+0x6a>
    if(found == 0){
    8000214c:	000c9463          	bnez	s9,80002154 <scheduler+0xe2>
      asm volatile("wfi");
    80002150:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002154:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002158:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000215c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002160:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002164:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002166:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000216a:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000216c:	00024497          	auipc	s1,0x24
    80002170:	d9c48493          	addi	s1,s1,-612 # 80025f08 <proc>
      if(p->state == RUNNABLE) {
    80002174:	4a09                	li	s4,2
        found = 1;
    80002176:	4b05                	li	s6,1
    80002178:	b765                	j	80002120 <scheduler+0xae>

000000008000217a <sched>:
{
    8000217a:	7179                	addi	sp,sp,-48
    8000217c:	f406                	sd	ra,40(sp)
    8000217e:	f022                	sd	s0,32(sp)
    80002180:	ec26                	sd	s1,24(sp)
    80002182:	e84a                	sd	s2,16(sp)
    80002184:	e44e                	sd	s3,8(sp)
    80002186:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002188:	00000097          	auipc	ra,0x0
    8000218c:	9c8080e7          	jalr	-1592(ra) # 80001b50 <myproc>
    80002190:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002192:	fffff097          	auipc	ra,0xfffff
    80002196:	982080e7          	jalr	-1662(ra) # 80000b14 <holding>
    8000219a:	cd35                	beqz	a0,80002216 <sched+0x9c>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000219c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000219e:	2781                	sext.w	a5,a5
    800021a0:	079e                	slli	a5,a5,0x7
    800021a2:	00024717          	auipc	a4,0x24
    800021a6:	94670713          	addi	a4,a4,-1722 # 80025ae8 <pid_lock>
    800021aa:	97ba                	add	a5,a5,a4
    800021ac:	0987a703          	lw	a4,152(a5)
    800021b0:	4785                	li	a5,1
    800021b2:	06f71a63          	bne	a4,a5,80002226 <sched+0xac>
  if(p->state == RUNNING)
    800021b6:	5098                	lw	a4,32(s1)
    800021b8:	478d                	li	a5,3
    800021ba:	06f70e63          	beq	a4,a5,80002236 <sched+0xbc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021be:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021c2:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021c4:	e3c9                	bnez	a5,80002246 <sched+0xcc>
  if(p->last_scheduled != 0) {
    800021c6:	1904b783          	ld	a5,400(s1)
    800021ca:	e7d1                	bnez	a5,80002256 <sched+0xdc>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021cc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021ce:	00024917          	auipc	s2,0x24
    800021d2:	91a90913          	addi	s2,s2,-1766 # 80025ae8 <pid_lock>
    800021d6:	2781                	sext.w	a5,a5
    800021d8:	079e                	slli	a5,a5,0x7
    800021da:	97ca                	add	a5,a5,s2
    800021dc:	09c7a983          	lw	s3,156(a5)
    800021e0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800021e2:	2781                	sext.w	a5,a5
    800021e4:	079e                	slli	a5,a5,0x7
    800021e6:	00024597          	auipc	a1,0x24
    800021ea:	92a58593          	addi	a1,a1,-1750 # 80025b10 <cpus+0x8>
    800021ee:	95be                	add	a1,a1,a5
    800021f0:	06848513          	addi	a0,s1,104
    800021f4:	00000097          	auipc	ra,0x0
    800021f8:	6a6080e7          	jalr	1702(ra) # 8000289a <swtch>
    800021fc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021fe:	2781                	sext.w	a5,a5
    80002200:	079e                	slli	a5,a5,0x7
    80002202:	97ca                	add	a5,a5,s2
    80002204:	0937ae23          	sw	s3,156(a5)
}
    80002208:	70a2                	ld	ra,40(sp)
    8000220a:	7402                	ld	s0,32(sp)
    8000220c:	64e2                	ld	s1,24(sp)
    8000220e:	6942                	ld	s2,16(sp)
    80002210:	69a2                	ld	s3,8(sp)
    80002212:	6145                	addi	sp,sp,48
    80002214:	8082                	ret
    panic("sched p->lock");
    80002216:	00007517          	auipc	a0,0x7
    8000221a:	1b250513          	addi	a0,a0,434 # 800093c8 <digits+0x258>
    8000221e:	ffffe097          	auipc	ra,0xffffe
    80002222:	346080e7          	jalr	838(ra) # 80000564 <panic>
    panic("sched locks");
    80002226:	00007517          	auipc	a0,0x7
    8000222a:	1b250513          	addi	a0,a0,434 # 800093d8 <digits+0x268>
    8000222e:	ffffe097          	auipc	ra,0xffffe
    80002232:	336080e7          	jalr	822(ra) # 80000564 <panic>
    panic("sched running");
    80002236:	00007517          	auipc	a0,0x7
    8000223a:	1b250513          	addi	a0,a0,434 # 800093e8 <digits+0x278>
    8000223e:	ffffe097          	auipc	ra,0xffffe
    80002242:	326080e7          	jalr	806(ra) # 80000564 <panic>
    panic("sched interruptible");
    80002246:	00007517          	auipc	a0,0x7
    8000224a:	1b250513          	addi	a0,a0,434 # 800093f8 <digits+0x288>
    8000224e:	ffffe097          	auipc	ra,0xffffe
    80002252:	316080e7          	jalr	790(ra) # 80000564 <panic>
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002256:	c01026f3          	rdtime	a3
    p->total_run_time += getTime() - p->last_scheduled;
    8000225a:	1884b703          	ld	a4,392(s1)
    8000225e:	40f707b3          	sub	a5,a4,a5
    80002262:	97b6                	add	a5,a5,a3
    80002264:	18f4b423          	sd	a5,392(s1)
    80002268:	b795                	j	800021cc <sched+0x52>

000000008000226a <exit>:
{
    8000226a:	7139                	addi	sp,sp,-64
    8000226c:	fc06                	sd	ra,56(sp)
    8000226e:	f822                	sd	s0,48(sp)
    80002270:	f426                	sd	s1,40(sp)
    80002272:	f04a                	sd	s2,32(sp)
    80002274:	ec4e                	sd	s3,24(sp)
    80002276:	e852                	sd	s4,16(sp)
    80002278:	e456                	sd	s5,8(sp)
    8000227a:	0080                	addi	s0,sp,64
    8000227c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	8d2080e7          	jalr	-1838(ra) # 80001b50 <myproc>
  if(p == initproc)
    80002286:	00008797          	auipc	a5,0x8
    8000228a:	d727b783          	ld	a5,-654(a5) # 80009ff8 <initproc>
    8000228e:	0ea78a63          	beq	a5,a0,80002382 <exit+0x118>
    80002292:	892a                	mv	s2,a0
  if(p->last_scheduled != 0) {
    80002294:	19053783          	ld	a5,400(a0)
    80002298:	efed                	bnez	a5,80002392 <exit+0x128>
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000229a:	c01024f3          	rdtime	s1
  p->completion_time = getTime();
    8000229e:	1a993023          	sd	s1,416(s2)
  uint64 turnaround = p->completion_time - p->creation_time;
    800022a2:	17893783          	ld	a5,376(s2)
    800022a6:	8c9d                	sub	s1,s1,a5
  uint64 response = (p->first_run == 1) ? (p->first_run_time - p->creation_time) : 0;
    800022a8:	1b492683          	lw	a3,436(s2)
    800022ac:	4705                	li	a4,1
    800022ae:	4a81                	li	s5,0
    800022b0:	0ee68b63          	beq	a3,a4,800023a6 <exit+0x13c>
  uint64 cpu_percent = turnaround > 0 ? (p->total_run_time * 100) / turnaround : 0;
    800022b4:	89a6                	mv	s3,s1
    800022b6:	c889                	beqz	s1,800022c8 <exit+0x5e>
    800022b8:	18893783          	ld	a5,392(s2)
    800022bc:	06400993          	li	s3,100
    800022c0:	02f989b3          	mul	s3,s3,a5
    800022c4:	0299d9b3          	divu	s3,s3,s1
  printf("\n ***Process Exit Metrics***\n");
    800022c8:	00007517          	auipc	a0,0x7
    800022cc:	15850513          	addi	a0,a0,344 # 80009420 <digits+0x2b0>
    800022d0:	ffffe097          	auipc	ra,0xffffe
    800022d4:	2f6080e7          	jalr	758(ra) # 800005c6 <printf>
  printf("PID: %d\n", p->pid);
    800022d8:	04092583          	lw	a1,64(s2)
    800022dc:	00007517          	auipc	a0,0x7
    800022e0:	16450513          	addi	a0,a0,356 # 80009440 <digits+0x2d0>
    800022e4:	ffffe097          	auipc	ra,0xffffe
    800022e8:	2e2080e7          	jalr	738(ra) # 800005c6 <printf>
  printf("Name: %s\n", p->name);
    800022ec:	16090593          	addi	a1,s2,352
    800022f0:	00007517          	auipc	a0,0x7
    800022f4:	16050513          	addi	a0,a0,352 # 80009450 <digits+0x2e0>
    800022f8:	ffffe097          	auipc	ra,0xffffe
    800022fc:	2ce080e7          	jalr	718(ra) # 800005c6 <printf>
  printf("Turnaround Time: %d ticks\n", (int)turnaround);
    80002300:	0004859b          	sext.w	a1,s1
    80002304:	00007517          	auipc	a0,0x7
    80002308:	15c50513          	addi	a0,a0,348 # 80009460 <digits+0x2f0>
    8000230c:	ffffe097          	auipc	ra,0xffffe
    80002310:	2ba080e7          	jalr	698(ra) # 800005c6 <printf>
  printf("Waiting Time: %d ticks\n", (int)p->total_wait_time);
    80002314:	19892583          	lw	a1,408(s2)
    80002318:	00007517          	auipc	a0,0x7
    8000231c:	16850513          	addi	a0,a0,360 # 80009480 <digits+0x310>
    80002320:	ffffe097          	auipc	ra,0xffffe
    80002324:	2a6080e7          	jalr	678(ra) # 800005c6 <printf>
  printf("Response Time: %d ticks\n", (int)response);
    80002328:	000a859b          	sext.w	a1,s5
    8000232c:	00007517          	auipc	a0,0x7
    80002330:	16c50513          	addi	a0,a0,364 # 80009498 <digits+0x328>
    80002334:	ffffe097          	auipc	ra,0xffffe
    80002338:	292080e7          	jalr	658(ra) # 800005c6 <printf>
  printf("Total Run Time: %d ticks\n", (int)p->total_run_time); 
    8000233c:	18892583          	lw	a1,392(s2)
    80002340:	00007517          	auipc	a0,0x7
    80002344:	17850513          	addi	a0,a0,376 # 800094b8 <digits+0x348>
    80002348:	ffffe097          	auipc	ra,0xffffe
    8000234c:	27e080e7          	jalr	638(ra) # 800005c6 <printf>
  printf("Context Switches: %d\n", p->context_switches);
    80002350:	1b092583          	lw	a1,432(s2)
    80002354:	00007517          	auipc	a0,0x7
    80002358:	18450513          	addi	a0,a0,388 # 800094d8 <digits+0x368>
    8000235c:	ffffe097          	auipc	ra,0xffffe
    80002360:	26a080e7          	jalr	618(ra) # 800005c6 <printf>
  printf("CPU Share: %d%%\n", (int)cpu_percent);
    80002364:	0009859b          	sext.w	a1,s3
    80002368:	00007517          	auipc	a0,0x7
    8000236c:	18850513          	addi	a0,a0,392 # 800094f0 <digits+0x380>
    80002370:	ffffe097          	auipc	ra,0xffffe
    80002374:	256080e7          	jalr	598(ra) # 800005c6 <printf>
  for(int fd = 0; fd < NOFILE; fd++){
    80002378:	0d890493          	addi	s1,s2,216
    8000237c:	15890993          	addi	s3,s2,344
    80002380:	a81d                	j	800023b6 <exit+0x14c>
    panic("init exiting");
    80002382:	00007517          	auipc	a0,0x7
    80002386:	08e50513          	addi	a0,a0,142 # 80009410 <digits+0x2a0>
    8000238a:	ffffe097          	auipc	ra,0xffffe
    8000238e:	1da080e7          	jalr	474(ra) # 80000564 <panic>
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002392:	c01026f3          	rdtime	a3
    p->total_run_time += getTime() - p->last_scheduled;
    80002396:	18853703          	ld	a4,392(a0)
    8000239a:	40f707b3          	sub	a5,a4,a5
    8000239e:	97b6                	add	a5,a5,a3
    800023a0:	18f53423          	sd	a5,392(a0)
    800023a4:	bddd                	j	8000229a <exit+0x30>
  uint64 response = (p->first_run == 1) ? (p->first_run_time - p->creation_time) : 0;
    800023a6:	18093a83          	ld	s5,384(s2)
    800023aa:	40fa8ab3          	sub	s5,s5,a5
    800023ae:	b719                	j	800022b4 <exit+0x4a>
  for(int fd = 0; fd < NOFILE; fd++){
    800023b0:	04a1                	addi	s1,s1,8
    800023b2:	01348b63          	beq	s1,s3,800023c8 <exit+0x15e>
    if(p->ofile[fd]){
    800023b6:	6088                	ld	a0,0(s1)
    800023b8:	dd65                	beqz	a0,800023b0 <exit+0x146>
      fileclose(f);
    800023ba:	00002097          	auipc	ra,0x2
    800023be:	472080e7          	jalr	1138(ra) # 8000482c <fileclose>
      p->ofile[fd] = 0;
    800023c2:	0004b023          	sd	zero,0(s1)
    800023c6:	b7ed                	j	800023b0 <exit+0x146>
  begin_op();
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	f9a080e7          	jalr	-102(ra) # 80004362 <begin_op>
  iput(p->cwd);
    800023d0:	15893503          	ld	a0,344(s2)
    800023d4:	00001097          	auipc	ra,0x1
    800023d8:	786080e7          	jalr	1926(ra) # 80003b5a <iput>
  end_op();
    800023dc:	00002097          	auipc	ra,0x2
    800023e0:	006080e7          	jalr	6(ra) # 800043e2 <end_op>
  p->cwd = 0;
    800023e4:	14093c23          	sd	zero,344(s2)
  acquire(&initproc->lock);
    800023e8:	00008497          	auipc	s1,0x8
    800023ec:	c1048493          	addi	s1,s1,-1008 # 80009ff8 <initproc>
    800023f0:	6088                	ld	a0,0(s1)
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7a0080e7          	jalr	1952(ra) # 80000b92 <acquire>
  wakeup1(initproc);
    800023fa:	6088                	ld	a0,0(s1)
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	60c080e7          	jalr	1548(ra) # 80001a08 <wakeup1>
  release(&initproc->lock);
    80002404:	6088                	ld	a0,0(s1)
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	85c080e7          	jalr	-1956(ra) # 80000c62 <release>
  acquire(&p->lock);
    8000240e:	854a                	mv	a0,s2
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	782080e7          	jalr	1922(ra) # 80000b92 <acquire>
  struct proc *original_parent = p->parent;
    80002418:	02893483          	ld	s1,40(s2)
  release(&p->lock);
    8000241c:	854a                	mv	a0,s2
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	844080e7          	jalr	-1980(ra) # 80000c62 <release>
  acquire(&original_parent->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	ffffe097          	auipc	ra,0xffffe
    8000242c:	76a080e7          	jalr	1898(ra) # 80000b92 <acquire>
  acquire(&p->lock);
    80002430:	854a                	mv	a0,s2
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	760080e7          	jalr	1888(ra) # 80000b92 <acquire>
  reparent(p);
    8000243a:	854a                	mv	a0,s2
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	bd0080e7          	jalr	-1072(ra) # 8000200c <reparent>
  wakeup1(original_parent);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	5c2080e7          	jalr	1474(ra) # 80001a08 <wakeup1>
  p->xstate = status;
    8000244e:	03492e23          	sw	s4,60(s2)
  p->state = ZOMBIE;
    80002452:	4791                	li	a5,4
    80002454:	02f92023          	sw	a5,32(s2)
  release(&original_parent->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	808080e7          	jalr	-2040(ra) # 80000c62 <release>
  sched();
    80002462:	00000097          	auipc	ra,0x0
    80002466:	d18080e7          	jalr	-744(ra) # 8000217a <sched>
  panic("zombie exit");
    8000246a:	00007517          	auipc	a0,0x7
    8000246e:	09e50513          	addi	a0,a0,158 # 80009508 <digits+0x398>
    80002472:	ffffe097          	auipc	ra,0xffffe
    80002476:	0f2080e7          	jalr	242(ra) # 80000564 <panic>

000000008000247a <yield>:
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	e426                	sd	s1,8(sp)
    80002482:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	6cc080e7          	jalr	1740(ra) # 80001b50 <myproc>
    8000248c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000248e:	ffffe097          	auipc	ra,0xffffe
    80002492:	704080e7          	jalr	1796(ra) # 80000b92 <acquire>
  p->state = RUNNABLE;
    80002496:	4789                	li	a5,2
    80002498:	d09c                	sw	a5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000249a:	c01027f3          	rdtime	a5
  p->wait_start = getTime();
    8000249e:	1af4b423          	sd	a5,424(s1)
  sched();
    800024a2:	00000097          	auipc	ra,0x0
    800024a6:	cd8080e7          	jalr	-808(ra) # 8000217a <sched>
  release(&p->lock);
    800024aa:	8526                	mv	a0,s1
    800024ac:	ffffe097          	auipc	ra,0xffffe
    800024b0:	7b6080e7          	jalr	1974(ra) # 80000c62 <release>
}
    800024b4:	60e2                	ld	ra,24(sp)
    800024b6:	6442                	ld	s0,16(sp)
    800024b8:	64a2                	ld	s1,8(sp)
    800024ba:	6105                	addi	sp,sp,32
    800024bc:	8082                	ret

00000000800024be <sleep>:
{
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	89aa                	mv	s3,a0
    800024ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	680080e7          	jalr	1664(ra) # 80001b50 <myproc>
    800024d8:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024da:	05250663          	beq	a0,s2,80002526 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024de:	ffffe097          	auipc	ra,0xffffe
    800024e2:	6b4080e7          	jalr	1716(ra) # 80000b92 <acquire>
    release(lk);
    800024e6:	854a                	mv	a0,s2
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	77a080e7          	jalr	1914(ra) # 80000c62 <release>
  p->chan = chan;
    800024f0:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    800024f4:	4785                	li	a5,1
    800024f6:	d09c                	sw	a5,32(s1)
  sched();
    800024f8:	00000097          	auipc	ra,0x0
    800024fc:	c82080e7          	jalr	-894(ra) # 8000217a <sched>
  p->chan = 0;
    80002500:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	75c080e7          	jalr	1884(ra) # 80000c62 <release>
    acquire(lk);
    8000250e:	854a                	mv	a0,s2
    80002510:	ffffe097          	auipc	ra,0xffffe
    80002514:	682080e7          	jalr	1666(ra) # 80000b92 <acquire>
}
    80002518:	70a2                	ld	ra,40(sp)
    8000251a:	7402                	ld	s0,32(sp)
    8000251c:	64e2                	ld	s1,24(sp)
    8000251e:	6942                	ld	s2,16(sp)
    80002520:	69a2                	ld	s3,8(sp)
    80002522:	6145                	addi	sp,sp,48
    80002524:	8082                	ret
  p->chan = chan;
    80002526:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    8000252a:	4785                	li	a5,1
    8000252c:	d11c                	sw	a5,32(a0)
  sched();
    8000252e:	00000097          	auipc	ra,0x0
    80002532:	c4c080e7          	jalr	-948(ra) # 8000217a <sched>
  p->chan = 0;
    80002536:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    8000253a:	bff9                	j	80002518 <sleep+0x5a>

000000008000253c <wait>:
{
    8000253c:	715d                	addi	sp,sp,-80
    8000253e:	e486                	sd	ra,72(sp)
    80002540:	e0a2                	sd	s0,64(sp)
    80002542:	fc26                	sd	s1,56(sp)
    80002544:	f84a                	sd	s2,48(sp)
    80002546:	f44e                	sd	s3,40(sp)
    80002548:	f052                	sd	s4,32(sp)
    8000254a:	ec56                	sd	s5,24(sp)
    8000254c:	e85a                	sd	s6,16(sp)
    8000254e:	e45e                	sd	s7,8(sp)
    80002550:	0880                	addi	s0,sp,80
    80002552:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	5fc080e7          	jalr	1532(ra) # 80001b50 <myproc>
    8000255c:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	634080e7          	jalr	1588(ra) # 80000b92 <acquire>
    havekids = 0;
    80002566:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002568:	4a11                	li	s4,4
        havekids = 1;
    8000256a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000256c:	0002a997          	auipc	s3,0x2a
    80002570:	79c98993          	addi	s3,s3,1948 # 8002cd08 <tickslock>
    havekids = 0;
    80002574:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002576:	00024497          	auipc	s1,0x24
    8000257a:	99248493          	addi	s1,s1,-1646 # 80025f08 <proc>
    8000257e:	a08d                	j	800025e0 <wait+0xa4>
          pid = np->pid;
    80002580:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002584:	000b0e63          	beqz	s6,800025a0 <wait+0x64>
    80002588:	4691                	li	a3,4
    8000258a:	03c48613          	addi	a2,s1,60
    8000258e:	85da                	mv	a1,s6
    80002590:	05893503          	ld	a0,88(s2)
    80002594:	fffff097          	auipc	ra,0xfffff
    80002598:	26c080e7          	jalr	620(ra) # 80001800 <copyout>
    8000259c:	02054263          	bltz	a0,800025c0 <wait+0x84>
          freeproc(np);
    800025a0:	8526                	mv	a0,s1
    800025a2:	fffff097          	auipc	ra,0xfffff
    800025a6:	7fe080e7          	jalr	2046(ra) # 80001da0 <freeproc>
          release(&np->lock);
    800025aa:	8526                	mv	a0,s1
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	6b6080e7          	jalr	1718(ra) # 80000c62 <release>
          release(&p->lock);
    800025b4:	854a                	mv	a0,s2
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	6ac080e7          	jalr	1708(ra) # 80000c62 <release>
          return pid;
    800025be:	a8a9                	j	80002618 <wait+0xdc>
            release(&np->lock);
    800025c0:	8526                	mv	a0,s1
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	6a0080e7          	jalr	1696(ra) # 80000c62 <release>
            release(&p->lock);
    800025ca:	854a                	mv	a0,s2
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	696080e7          	jalr	1686(ra) # 80000c62 <release>
            return -1;
    800025d4:	59fd                	li	s3,-1
    800025d6:	a089                	j	80002618 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800025d8:	1b848493          	addi	s1,s1,440
    800025dc:	03348463          	beq	s1,s3,80002604 <wait+0xc8>
      if(np->parent == p){
    800025e0:	749c                	ld	a5,40(s1)
    800025e2:	ff279be3          	bne	a5,s2,800025d8 <wait+0x9c>
        acquire(&np->lock);
    800025e6:	8526                	mv	a0,s1
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	5aa080e7          	jalr	1450(ra) # 80000b92 <acquire>
        if(np->state == ZOMBIE){
    800025f0:	509c                	lw	a5,32(s1)
    800025f2:	f94787e3          	beq	a5,s4,80002580 <wait+0x44>
        release(&np->lock);
    800025f6:	8526                	mv	a0,s1
    800025f8:	ffffe097          	auipc	ra,0xffffe
    800025fc:	66a080e7          	jalr	1642(ra) # 80000c62 <release>
        havekids = 1;
    80002600:	8756                	mv	a4,s5
    80002602:	bfd9                	j	800025d8 <wait+0x9c>
    if(!havekids || p->killed){
    80002604:	c701                	beqz	a4,8000260c <wait+0xd0>
    80002606:	03892783          	lw	a5,56(s2)
    8000260a:	c39d                	beqz	a5,80002630 <wait+0xf4>
      release(&p->lock);
    8000260c:	854a                	mv	a0,s2
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	654080e7          	jalr	1620(ra) # 80000c62 <release>
      return -1;
    80002616:	59fd                	li	s3,-1
}
    80002618:	854e                	mv	a0,s3
    8000261a:	60a6                	ld	ra,72(sp)
    8000261c:	6406                	ld	s0,64(sp)
    8000261e:	74e2                	ld	s1,56(sp)
    80002620:	7942                	ld	s2,48(sp)
    80002622:	79a2                	ld	s3,40(sp)
    80002624:	7a02                	ld	s4,32(sp)
    80002626:	6ae2                	ld	s5,24(sp)
    80002628:	6b42                	ld	s6,16(sp)
    8000262a:	6ba2                	ld	s7,8(sp)
    8000262c:	6161                	addi	sp,sp,80
    8000262e:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002630:	85ca                	mv	a1,s2
    80002632:	854a                	mv	a0,s2
    80002634:	00000097          	auipc	ra,0x0
    80002638:	e8a080e7          	jalr	-374(ra) # 800024be <sleep>
    havekids = 0;
    8000263c:	bf25                	j	80002574 <wait+0x38>

000000008000263e <wakeup>:
{
    8000263e:	7139                	addi	sp,sp,-64
    80002640:	fc06                	sd	ra,56(sp)
    80002642:	f822                	sd	s0,48(sp)
    80002644:	f426                	sd	s1,40(sp)
    80002646:	f04a                	sd	s2,32(sp)
    80002648:	ec4e                	sd	s3,24(sp)
    8000264a:	e852                	sd	s4,16(sp)
    8000264c:	e456                	sd	s5,8(sp)
    8000264e:	0080                	addi	s0,sp,64
    80002650:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002652:	00024497          	auipc	s1,0x24
    80002656:	8b648493          	addi	s1,s1,-1866 # 80025f08 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000265a:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000265c:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000265e:	0002a917          	auipc	s2,0x2a
    80002662:	6aa90913          	addi	s2,s2,1706 # 8002cd08 <tickslock>
    80002666:	a811                	j	8000267a <wakeup+0x3c>
    release(&p->lock);
    80002668:	8526                	mv	a0,s1
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	5f8080e7          	jalr	1528(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002672:	1b848493          	addi	s1,s1,440
    80002676:	03248463          	beq	s1,s2,8000269e <wakeup+0x60>
    acquire(&p->lock);
    8000267a:	8526                	mv	a0,s1
    8000267c:	ffffe097          	auipc	ra,0xffffe
    80002680:	516080e7          	jalr	1302(ra) # 80000b92 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002684:	509c                	lw	a5,32(s1)
    80002686:	ff3791e3          	bne	a5,s3,80002668 <wakeup+0x2a>
    8000268a:	789c                	ld	a5,48(s1)
    8000268c:	fd479ee3          	bne	a5,s4,80002668 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002690:	0354a023          	sw	s5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002694:	c01027f3          	rdtime	a5
      p->wait_start = getTime();
    80002698:	1af4b423          	sd	a5,424(s1)
    8000269c:	b7f1                	j	80002668 <wakeup+0x2a>
}
    8000269e:	70e2                	ld	ra,56(sp)
    800026a0:	7442                	ld	s0,48(sp)
    800026a2:	74a2                	ld	s1,40(sp)
    800026a4:	7902                	ld	s2,32(sp)
    800026a6:	69e2                	ld	s3,24(sp)
    800026a8:	6a42                	ld	s4,16(sp)
    800026aa:	6aa2                	ld	s5,8(sp)
    800026ac:	6121                	addi	sp,sp,64
    800026ae:	8082                	ret

00000000800026b0 <kill>:
{
    800026b0:	7179                	addi	sp,sp,-48
    800026b2:	f406                	sd	ra,40(sp)
    800026b4:	f022                	sd	s0,32(sp)
    800026b6:	ec26                	sd	s1,24(sp)
    800026b8:	e84a                	sd	s2,16(sp)
    800026ba:	e44e                	sd	s3,8(sp)
    800026bc:	1800                	addi	s0,sp,48
    800026be:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    800026c0:	00024497          	auipc	s1,0x24
    800026c4:	84848493          	addi	s1,s1,-1976 # 80025f08 <proc>
    800026c8:	0002a997          	auipc	s3,0x2a
    800026cc:	64098993          	addi	s3,s3,1600 # 8002cd08 <tickslock>
    acquire(&p->lock);
    800026d0:	8526                	mv	a0,s1
    800026d2:	ffffe097          	auipc	ra,0xffffe
    800026d6:	4c0080e7          	jalr	1216(ra) # 80000b92 <acquire>
    if(p->pid == pid){
    800026da:	40bc                	lw	a5,64(s1)
    800026dc:	01278d63          	beq	a5,s2,800026f6 <kill+0x46>
    release(&p->lock);
    800026e0:	8526                	mv	a0,s1
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	580080e7          	jalr	1408(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ea:	1b848493          	addi	s1,s1,440
    800026ee:	ff3491e3          	bne	s1,s3,800026d0 <kill+0x20>
  return -1;
    800026f2:	557d                	li	a0,-1
    800026f4:	a821                	j	8000270c <kill+0x5c>
      p->killed = 1;
    800026f6:	4785                	li	a5,1
    800026f8:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800026fa:	5098                	lw	a4,32(s1)
    800026fc:	00f70f63          	beq	a4,a5,8000271a <kill+0x6a>
      release(&p->lock);
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	560080e7          	jalr	1376(ra) # 80000c62 <release>
      return 0;
    8000270a:	4501                	li	a0,0
}
    8000270c:	70a2                	ld	ra,40(sp)
    8000270e:	7402                	ld	s0,32(sp)
    80002710:	64e2                	ld	s1,24(sp)
    80002712:	6942                	ld	s2,16(sp)
    80002714:	69a2                	ld	s3,8(sp)
    80002716:	6145                	addi	sp,sp,48
    80002718:	8082                	ret
        p->state = RUNNABLE;
    8000271a:	4789                	li	a5,2
    8000271c:	d09c                	sw	a5,32(s1)
    8000271e:	b7cd                	j	80002700 <kill+0x50>

0000000080002720 <either_copyout>:
{
    80002720:	7179                	addi	sp,sp,-48
    80002722:	f406                	sd	ra,40(sp)
    80002724:	f022                	sd	s0,32(sp)
    80002726:	ec26                	sd	s1,24(sp)
    80002728:	e84a                	sd	s2,16(sp)
    8000272a:	e44e                	sd	s3,8(sp)
    8000272c:	e052                	sd	s4,0(sp)
    8000272e:	1800                	addi	s0,sp,48
    80002730:	84aa                	mv	s1,a0
    80002732:	892e                	mv	s2,a1
    80002734:	89b2                	mv	s3,a2
    80002736:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002738:	fffff097          	auipc	ra,0xfffff
    8000273c:	418080e7          	jalr	1048(ra) # 80001b50 <myproc>
  if(user_dst){
    80002740:	c08d                	beqz	s1,80002762 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002742:	86d2                	mv	a3,s4
    80002744:	864e                	mv	a2,s3
    80002746:	85ca                	mv	a1,s2
    80002748:	6d28                	ld	a0,88(a0)
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	0b6080e7          	jalr	182(ra) # 80001800 <copyout>
}
    80002752:	70a2                	ld	ra,40(sp)
    80002754:	7402                	ld	s0,32(sp)
    80002756:	64e2                	ld	s1,24(sp)
    80002758:	6942                	ld	s2,16(sp)
    8000275a:	69a2                	ld	s3,8(sp)
    8000275c:	6a02                	ld	s4,0(sp)
    8000275e:	6145                	addi	sp,sp,48
    80002760:	8082                	ret
    memmove((char *)dst, src, len);
    80002762:	000a061b          	sext.w	a2,s4
    80002766:	85ce                	mv	a1,s3
    80002768:	854a                	mv	a0,s2
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	768080e7          	jalr	1896(ra) # 80000ed2 <memmove>
    return 0;
    80002772:	8526                	mv	a0,s1
    80002774:	bff9                	j	80002752 <either_copyout+0x32>

0000000080002776 <either_copyin>:
{
    80002776:	7179                	addi	sp,sp,-48
    80002778:	f406                	sd	ra,40(sp)
    8000277a:	f022                	sd	s0,32(sp)
    8000277c:	ec26                	sd	s1,24(sp)
    8000277e:	e84a                	sd	s2,16(sp)
    80002780:	e44e                	sd	s3,8(sp)
    80002782:	e052                	sd	s4,0(sp)
    80002784:	1800                	addi	s0,sp,48
    80002786:	892a                	mv	s2,a0
    80002788:	84ae                	mv	s1,a1
    8000278a:	89b2                	mv	s3,a2
    8000278c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000278e:	fffff097          	auipc	ra,0xfffff
    80002792:	3c2080e7          	jalr	962(ra) # 80001b50 <myproc>
  if(user_src){
    80002796:	c08d                	beqz	s1,800027b8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002798:	86d2                	mv	a3,s4
    8000279a:	864e                	mv	a2,s3
    8000279c:	85ca                	mv	a1,s2
    8000279e:	6d28                	ld	a0,88(a0)
    800027a0:	fffff097          	auipc	ra,0xfffff
    800027a4:	0ec080e7          	jalr	236(ra) # 8000188c <copyin>
}
    800027a8:	70a2                	ld	ra,40(sp)
    800027aa:	7402                	ld	s0,32(sp)
    800027ac:	64e2                	ld	s1,24(sp)
    800027ae:	6942                	ld	s2,16(sp)
    800027b0:	69a2                	ld	s3,8(sp)
    800027b2:	6a02                	ld	s4,0(sp)
    800027b4:	6145                	addi	sp,sp,48
    800027b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800027b8:	000a061b          	sext.w	a2,s4
    800027bc:	85ce                	mv	a1,s3
    800027be:	854a                	mv	a0,s2
    800027c0:	ffffe097          	auipc	ra,0xffffe
    800027c4:	712080e7          	jalr	1810(ra) # 80000ed2 <memmove>
    return 0;
    800027c8:	8526                	mv	a0,s1
    800027ca:	bff9                	j	800027a8 <either_copyin+0x32>

00000000800027cc <procdump>:
{
    800027cc:	715d                	addi	sp,sp,-80
    800027ce:	e486                	sd	ra,72(sp)
    800027d0:	e0a2                	sd	s0,64(sp)
    800027d2:	fc26                	sd	s1,56(sp)
    800027d4:	f84a                	sd	s2,48(sp)
    800027d6:	f44e                	sd	s3,40(sp)
    800027d8:	f052                	sd	s4,32(sp)
    800027da:	ec56                	sd	s5,24(sp)
    800027dc:	e85a                	sd	s6,16(sp)
    800027de:	e45e                	sd	s7,8(sp)
    800027e0:	0880                	addi	s0,sp,80
  printf("\n");
    800027e2:	00007517          	auipc	a0,0x7
    800027e6:	a1e50513          	addi	a0,a0,-1506 # 80009200 <digits+0x90>
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	ddc080e7          	jalr	-548(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027f2:	00024497          	auipc	s1,0x24
    800027f6:	87648493          	addi	s1,s1,-1930 # 80026068 <proc+0x160>
    800027fa:	0002a917          	auipc	s2,0x2a
    800027fe:	66e90913          	addi	s2,s2,1646 # 8002ce68 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002802:	4b11                	li	s6,4
      state = "???";
    80002804:	00007997          	auipc	s3,0x7
    80002808:	d1498993          	addi	s3,s3,-748 # 80009518 <digits+0x3a8>
    printf("%d %s %s", p->pid, state, p->name);
    8000280c:	00007a97          	auipc	s5,0x7
    80002810:	d14a8a93          	addi	s5,s5,-748 # 80009520 <digits+0x3b0>
    printf("\n");
    80002814:	00007a17          	auipc	s4,0x7
    80002818:	9eca0a13          	addi	s4,s4,-1556 # 80009200 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000281c:	00007b97          	auipc	s7,0x7
    80002820:	d3cb8b93          	addi	s7,s7,-708 # 80009558 <states.0>
    80002824:	a00d                	j	80002846 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002826:	ee06a583          	lw	a1,-288(a3)
    8000282a:	8556                	mv	a0,s5
    8000282c:	ffffe097          	auipc	ra,0xffffe
    80002830:	d9a080e7          	jalr	-614(ra) # 800005c6 <printf>
    printf("\n");
    80002834:	8552                	mv	a0,s4
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	d90080e7          	jalr	-624(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000283e:	1b848493          	addi	s1,s1,440
    80002842:	03248163          	beq	s1,s2,80002864 <procdump+0x98>
    if(p->state == UNUSED)
    80002846:	86a6                	mv	a3,s1
    80002848:	ec04a783          	lw	a5,-320(s1)
    8000284c:	dbed                	beqz	a5,8000283e <procdump+0x72>
      state = "???";
    8000284e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002850:	fcfb6be3          	bltu	s6,a5,80002826 <procdump+0x5a>
    80002854:	1782                	slli	a5,a5,0x20
    80002856:	9381                	srli	a5,a5,0x20
    80002858:	078e                	slli	a5,a5,0x3
    8000285a:	97de                	add	a5,a5,s7
    8000285c:	6390                	ld	a2,0(a5)
    8000285e:	f661                	bnez	a2,80002826 <procdump+0x5a>
      state = "???";
    80002860:	864e                	mv	a2,s3
    80002862:	b7d1                	j	80002826 <procdump+0x5a>
}
    80002864:	60a6                	ld	ra,72(sp)
    80002866:	6406                	ld	s0,64(sp)
    80002868:	74e2                	ld	s1,56(sp)
    8000286a:	7942                	ld	s2,48(sp)
    8000286c:	79a2                	ld	s3,40(sp)
    8000286e:	7a02                	ld	s4,32(sp)
    80002870:	6ae2                	ld	s5,24(sp)
    80002872:	6b42                	ld	s6,16(sp)
    80002874:	6ba2                	ld	s7,8(sp)
    80002876:	6161                	addi	sp,sp,80
    80002878:	8082                	ret

000000008000287a <getTime>:
unsigned long getTime() { 
    8000287a:	1141                	addi	sp,sp,-16
    8000287c:	e422                	sd	s0,8(sp)
    8000287e:	0800                	addi	s0,sp,16
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002880:	c0102573          	rdtime	a0
  return time; 
}
    80002884:	6422                	ld	s0,8(sp)
    80002886:	0141                	addi	sp,sp,16
    80002888:	8082                	ret

000000008000288a <getCycles>:

unsigned long getCycles() { 
    8000288a:	1141                	addi	sp,sp,-16
    8000288c:	e422                	sd	s0,8(sp)
    8000288e:	0800                	addi	s0,sp,16
  unsigned long cycles; 
  asm volatile ("rdcycle %0" : "=r" (cycles)); 
    80002890:	c0002573          	rdcycle	a0
  return cycles; 
    80002894:	6422                	ld	s0,8(sp)
    80002896:	0141                	addi	sp,sp,16
    80002898:	8082                	ret

000000008000289a <swtch>:
    8000289a:	00153023          	sd	ra,0(a0)
    8000289e:	00253423          	sd	sp,8(a0)
    800028a2:	e900                	sd	s0,16(a0)
    800028a4:	ed04                	sd	s1,24(a0)
    800028a6:	03253023          	sd	s2,32(a0)
    800028aa:	03353423          	sd	s3,40(a0)
    800028ae:	03453823          	sd	s4,48(a0)
    800028b2:	03553c23          	sd	s5,56(a0)
    800028b6:	05653023          	sd	s6,64(a0)
    800028ba:	05753423          	sd	s7,72(a0)
    800028be:	05853823          	sd	s8,80(a0)
    800028c2:	05953c23          	sd	s9,88(a0)
    800028c6:	07a53023          	sd	s10,96(a0)
    800028ca:	07b53423          	sd	s11,104(a0)
    800028ce:	0005b083          	ld	ra,0(a1)
    800028d2:	0085b103          	ld	sp,8(a1)
    800028d6:	6980                	ld	s0,16(a1)
    800028d8:	6d84                	ld	s1,24(a1)
    800028da:	0205b903          	ld	s2,32(a1)
    800028de:	0285b983          	ld	s3,40(a1)
    800028e2:	0305ba03          	ld	s4,48(a1)
    800028e6:	0385ba83          	ld	s5,56(a1)
    800028ea:	0405bb03          	ld	s6,64(a1)
    800028ee:	0485bb83          	ld	s7,72(a1)
    800028f2:	0505bc03          	ld	s8,80(a1)
    800028f6:	0585bc83          	ld	s9,88(a1)
    800028fa:	0605bd03          	ld	s10,96(a1)
    800028fe:	0685bd83          	ld	s11,104(a1)
    80002902:	8082                	ret

0000000080002904 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    80002904:	1141                	addi	sp,sp,-16
    80002906:	e422                	sd	s0,8(sp)
    80002908:	0800                	addi	s0,sp,16
    8000290a:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    8000290c:	00151713          	slli	a4,a0,0x1
    80002910:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    80002912:	04054c63          	bltz	a0,8000296a <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    80002916:	5685                	li	a3,-31
    80002918:	8285                	srli	a3,a3,0x1
    8000291a:	8ee9                	and	a3,a3,a0
    8000291c:	caad                	beqz	a3,8000298e <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    8000291e:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002920:	00007517          	auipc	a0,0x7
    80002924:	c6050513          	addi	a0,a0,-928 # 80009580 <states.0+0x28>
    } else if (code <= 23) {
    80002928:	06e6f063          	bgeu	a3,a4,80002988 <scause_desc+0x84>
    } else if (code <= 31) {
    8000292c:	fc100693          	li	a3,-63
    80002930:	8285                	srli	a3,a3,0x1
    80002932:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002934:	00007517          	auipc	a0,0x7
    80002938:	c7450513          	addi	a0,a0,-908 # 800095a8 <states.0+0x50>
    } else if (code <= 31) {
    8000293c:	c6b1                	beqz	a3,80002988 <scause_desc+0x84>
    } else if (code <= 47) {
    8000293e:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002942:	00007517          	auipc	a0,0x7
    80002946:	c3e50513          	addi	a0,a0,-962 # 80009580 <states.0+0x28>
    } else if (code <= 47) {
    8000294a:	02e6ff63          	bgeu	a3,a4,80002988 <scause_desc+0x84>
    } else if (code <= 63) {
    8000294e:	f8100513          	li	a0,-127
    80002952:	8105                	srli	a0,a0,0x1
    80002954:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002956:	00007517          	auipc	a0,0x7
    8000295a:	c5250513          	addi	a0,a0,-942 # 800095a8 <states.0+0x50>
    } else if (code <= 63) {
    8000295e:	c78d                	beqz	a5,80002988 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002960:	00007517          	auipc	a0,0x7
    80002964:	c2050513          	addi	a0,a0,-992 # 80009580 <states.0+0x28>
    80002968:	a005                	j	80002988 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    8000296a:	5505                	li	a0,-31
    8000296c:	8105                	srli	a0,a0,0x1
    8000296e:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    80002970:	00007517          	auipc	a0,0x7
    80002974:	c5850513          	addi	a0,a0,-936 # 800095c8 <states.0+0x70>
    if (code < NELEM(intr_desc)) {
    80002978:	eb81                	bnez	a5,80002988 <scause_desc+0x84>
      return intr_desc[code];
    8000297a:	070e                	slli	a4,a4,0x3
    8000297c:	00007797          	auipc	a5,0x7
    80002980:	f5c78793          	addi	a5,a5,-164 # 800098d8 <intr_desc.1>
    80002984:	973e                	add	a4,a4,a5
    80002986:	6308                	ld	a0,0(a4)
    }
  }
}
    80002988:	6422                	ld	s0,8(sp)
    8000298a:	0141                	addi	sp,sp,16
    8000298c:	8082                	ret
      return nointr_desc[code];
    8000298e:	070e                	slli	a4,a4,0x3
    80002990:	00007797          	auipc	a5,0x7
    80002994:	f4878793          	addi	a5,a5,-184 # 800098d8 <intr_desc.1>
    80002998:	973e                	add	a4,a4,a5
    8000299a:	6348                	ld	a0,128(a4)
    8000299c:	b7f5                	j	80002988 <scause_desc+0x84>

000000008000299e <trapinit>:
{
    8000299e:	1141                	addi	sp,sp,-16
    800029a0:	e406                	sd	ra,8(sp)
    800029a2:	e022                	sd	s0,0(sp)
    800029a4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029a6:	00007597          	auipc	a1,0x7
    800029aa:	c4258593          	addi	a1,a1,-958 # 800095e8 <states.0+0x90>
    800029ae:	0002a517          	auipc	a0,0x2a
    800029b2:	35a50513          	addi	a0,a0,858 # 8002cd08 <tickslock>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	106080e7          	jalr	262(ra) # 80000abc <initlock>
}
    800029be:	60a2                	ld	ra,8(sp)
    800029c0:	6402                	ld	s0,0(sp)
    800029c2:	0141                	addi	sp,sp,16
    800029c4:	8082                	ret

00000000800029c6 <trapinithart>:
{
    800029c6:	1141                	addi	sp,sp,-16
    800029c8:	e422                	sd	s0,8(sp)
    800029ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029cc:	00003797          	auipc	a5,0x3
    800029d0:	49478793          	addi	a5,a5,1172 # 80005e60 <kernelvec>
    800029d4:	10579073          	csrw	stvec,a5
}
    800029d8:	6422                	ld	s0,8(sp)
    800029da:	0141                	addi	sp,sp,16
    800029dc:	8082                	ret

00000000800029de <usertrapret>:
{
    800029de:	1141                	addi	sp,sp,-16
    800029e0:	e406                	sd	ra,8(sp)
    800029e2:	e022                	sd	s0,0(sp)
    800029e4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029e6:	fffff097          	auipc	ra,0xfffff
    800029ea:	16a080e7          	jalr	362(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f4:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029f8:	00005617          	auipc	a2,0x5
    800029fc:	60860613          	addi	a2,a2,1544 # 80008000 <_trampoline>
    80002a00:	00005697          	auipc	a3,0x5
    80002a04:	60068693          	addi	a3,a3,1536 # 80008000 <_trampoline>
    80002a08:	8e91                	sub	a3,a3,a2
    80002a0a:	040007b7          	lui	a5,0x4000
    80002a0e:	17fd                	addi	a5,a5,-1
    80002a10:	07b2                	slli	a5,a5,0xc
    80002a12:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a14:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a18:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a1a:	180026f3          	csrr	a3,satp
    80002a1e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a20:	7138                	ld	a4,96(a0)
    80002a22:	6534                	ld	a3,72(a0)
    80002a24:	6585                	lui	a1,0x1
    80002a26:	96ae                	add	a3,a3,a1
    80002a28:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a2a:	7138                	ld	a4,96(a0)
    80002a2c:	00000697          	auipc	a3,0x0
    80002a30:	12268693          	addi	a3,a3,290 # 80002b4e <usertrap>
    80002a34:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a36:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a38:	8692                	mv	a3,tp
    80002a3a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3c:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a40:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a44:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a48:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    80002a4c:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a4e:	6f18                	ld	a4,24(a4)
    80002a50:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a54:	6d2c                	ld	a1,88(a0)
    80002a56:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a58:	00005717          	auipc	a4,0x5
    80002a5c:	63870713          	addi	a4,a4,1592 # 80008090 <userret>
    80002a60:	8f11                	sub	a4,a4,a2
    80002a62:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    80002a64:	577d                	li	a4,-1
    80002a66:	177e                	slli	a4,a4,0x3f
    80002a68:	8dd9                	or	a1,a1,a4
    80002a6a:	17053503          	ld	a0,368(a0)
    80002a6e:	9782                	jalr	a5
}
    80002a70:	60a2                	ld	ra,8(sp)
    80002a72:	6402                	ld	s0,0(sp)
    80002a74:	0141                	addi	sp,sp,16
    80002a76:	8082                	ret

0000000080002a78 <clockintr>:
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	e426                	sd	s1,8(sp)
    80002a80:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a82:	0002a497          	auipc	s1,0x2a
    80002a86:	28648493          	addi	s1,s1,646 # 8002cd08 <tickslock>
    80002a8a:	8526                	mv	a0,s1
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	106080e7          	jalr	262(ra) # 80000b92 <acquire>
  ticks++;
    80002a94:	00007517          	auipc	a0,0x7
    80002a98:	56c50513          	addi	a0,a0,1388 # 8000a000 <ticks>
    80002a9c:	411c                	lw	a5,0(a0)
    80002a9e:	2785                	addiw	a5,a5,1
    80002aa0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002aa2:	00000097          	auipc	ra,0x0
    80002aa6:	b9c080e7          	jalr	-1124(ra) # 8000263e <wakeup>
  release(&tickslock);
    80002aaa:	8526                	mv	a0,s1
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	1b6080e7          	jalr	438(ra) # 80000c62 <release>
}
    80002ab4:	60e2                	ld	ra,24(sp)
    80002ab6:	6442                	ld	s0,16(sp)
    80002ab8:	64a2                	ld	s1,8(sp)
    80002aba:	6105                	addi	sp,sp,32
    80002abc:	8082                	ret

0000000080002abe <devintr>:
{
    80002abe:	1101                	addi	sp,sp,-32
    80002ac0:	ec06                	sd	ra,24(sp)
    80002ac2:	e822                	sd	s0,16(sp)
    80002ac4:	e426                	sd	s1,8(sp)
    80002ac6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ac8:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002acc:	00074d63          	bltz	a4,80002ae6 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002ad0:	57fd                	li	a5,-1
    80002ad2:	17fe                	slli	a5,a5,0x3f
    80002ad4:	0785                	addi	a5,a5,1
    return 0;
    80002ad6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ad8:	04f70a63          	beq	a4,a5,80002b2c <devintr+0x6e>
}
    80002adc:	60e2                	ld	ra,24(sp)
    80002ade:	6442                	ld	s0,16(sp)
    80002ae0:	64a2                	ld	s1,8(sp)
    80002ae2:	6105                	addi	sp,sp,32
    80002ae4:	8082                	ret
     (scause & 0xff) == 9){
    80002ae6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002aea:	46a5                	li	a3,9
    80002aec:	fed792e3          	bne	a5,a3,80002ad0 <devintr+0x12>
    int irq = plic_claim();
    80002af0:	00003097          	auipc	ra,0x3
    80002af4:	478080e7          	jalr	1144(ra) # 80005f68 <plic_claim>
    80002af8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002afa:	47a9                	li	a5,10
    80002afc:	00f50863          	beq	a0,a5,80002b0c <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002b00:	4785                	li	a5,1
    80002b02:	02f50063          	beq	a0,a5,80002b22 <devintr+0x64>
    return 1;
    80002b06:	4505                	li	a0,1
    if(irq)
    80002b08:	d8f1                	beqz	s1,80002adc <devintr+0x1e>
    80002b0a:	a029                	j	80002b14 <devintr+0x56>
      uartintr();
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	e04080e7          	jalr	-508(ra) # 80000910 <uartintr>
      plic_complete(irq);
    80002b14:	8526                	mv	a0,s1
    80002b16:	00003097          	auipc	ra,0x3
    80002b1a:	476080e7          	jalr	1142(ra) # 80005f8c <plic_complete>
    return 1;
    80002b1e:	4505                	li	a0,1
    80002b20:	bf75                	j	80002adc <devintr+0x1e>
      virtio_disk_intr();
    80002b22:	00004097          	auipc	ra,0x4
    80002b26:	922080e7          	jalr	-1758(ra) # 80006444 <virtio_disk_intr>
    80002b2a:	b7ed                	j	80002b14 <devintr+0x56>
    if(cpuid() == 0){
    80002b2c:	fffff097          	auipc	ra,0xfffff
    80002b30:	ff8080e7          	jalr	-8(ra) # 80001b24 <cpuid>
    80002b34:	c901                	beqz	a0,80002b44 <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b36:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b3a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b3c:	14479073          	csrw	sip,a5
    return 2;
    80002b40:	4509                	li	a0,2
    80002b42:	bf69                	j	80002adc <devintr+0x1e>
      clockintr();
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	f34080e7          	jalr	-204(ra) # 80002a78 <clockintr>
    80002b4c:	b7ed                	j	80002b36 <devintr+0x78>

0000000080002b4e <usertrap>:
{
    80002b4e:	7179                	addi	sp,sp,-48
    80002b50:	f406                	sd	ra,40(sp)
    80002b52:	f022                	sd	s0,32(sp)
    80002b54:	ec26                	sd	s1,24(sp)
    80002b56:	e84a                	sd	s2,16(sp)
    80002b58:	e44e                	sd	s3,8(sp)
    80002b5a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b5c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b60:	1007f793          	andi	a5,a5,256
    80002b64:	e3b5                	bnez	a5,80002bc8 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b66:	00003797          	auipc	a5,0x3
    80002b6a:	2fa78793          	addi	a5,a5,762 # 80005e60 <kernelvec>
    80002b6e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b72:	fffff097          	auipc	ra,0xfffff
    80002b76:	fde080e7          	jalr	-34(ra) # 80001b50 <myproc>
    80002b7a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b7c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7e:	14102773          	csrr	a4,sepc
    80002b82:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b84:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b88:	47a1                	li	a5,8
    80002b8a:	04f71d63          	bne	a4,a5,80002be4 <usertrap+0x96>
    if(p->killed)
    80002b8e:	5d1c                	lw	a5,56(a0)
    80002b90:	e7a1                	bnez	a5,80002bd8 <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002b92:	70b8                	ld	a4,96(s1)
    80002b94:	6f1c                	ld	a5,24(a4)
    80002b96:	0791                	addi	a5,a5,4
    80002b98:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b9e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba2:	10079073          	csrw	sstatus,a5
    syscall();
    80002ba6:	00000097          	auipc	ra,0x0
    80002baa:	2fe080e7          	jalr	766(ra) # 80002ea4 <syscall>
  if(p->killed)
    80002bae:	5c9c                	lw	a5,56(s1)
    80002bb0:	e3cd                	bnez	a5,80002c52 <usertrap+0x104>
  usertrapret();
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	e2c080e7          	jalr	-468(ra) # 800029de <usertrapret>
}
    80002bba:	70a2                	ld	ra,40(sp)
    80002bbc:	7402                	ld	s0,32(sp)
    80002bbe:	64e2                	ld	s1,24(sp)
    80002bc0:	6942                	ld	s2,16(sp)
    80002bc2:	69a2                	ld	s3,8(sp)
    80002bc4:	6145                	addi	sp,sp,48
    80002bc6:	8082                	ret
    panic("usertrap: not from user mode");
    80002bc8:	00007517          	auipc	a0,0x7
    80002bcc:	a2850513          	addi	a0,a0,-1496 # 800095f0 <states.0+0x98>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	994080e7          	jalr	-1644(ra) # 80000564 <panic>
      exit(-1);
    80002bd8:	557d                	li	a0,-1
    80002bda:	fffff097          	auipc	ra,0xfffff
    80002bde:	690080e7          	jalr	1680(ra) # 8000226a <exit>
    80002be2:	bf45                	j	80002b92 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002be4:	00000097          	auipc	ra,0x0
    80002be8:	eda080e7          	jalr	-294(ra) # 80002abe <devintr>
    80002bec:	892a                	mv	s2,a0
    80002bee:	c501                	beqz	a0,80002bf6 <usertrap+0xa8>
  if(p->killed)
    80002bf0:	5c9c                	lw	a5,56(s1)
    80002bf2:	cba1                	beqz	a5,80002c42 <usertrap+0xf4>
    80002bf4:	a091                	j	80002c38 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf6:	142029f3          	csrr	s3,scause
    80002bfa:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	d06080e7          	jalr	-762(ra) # 80002904 <scause_desc>
    80002c06:	862a                	mv	a2,a0
    80002c08:	40b4                	lw	a3,64(s1)
    80002c0a:	85ce                	mv	a1,s3
    80002c0c:	00007517          	auipc	a0,0x7
    80002c10:	a0450513          	addi	a0,a0,-1532 # 80009610 <states.0+0xb8>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	9b2080e7          	jalr	-1614(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c20:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c24:	00007517          	auipc	a0,0x7
    80002c28:	a1c50513          	addi	a0,a0,-1508 # 80009640 <states.0+0xe8>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	99a080e7          	jalr	-1638(ra) # 800005c6 <printf>
    p->killed = 1;
    80002c34:	4785                	li	a5,1
    80002c36:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c38:	557d                	li	a0,-1
    80002c3a:	fffff097          	auipc	ra,0xfffff
    80002c3e:	630080e7          	jalr	1584(ra) # 8000226a <exit>
  if(which_dev == 2)
    80002c42:	4789                	li	a5,2
    80002c44:	f6f917e3          	bne	s2,a5,80002bb2 <usertrap+0x64>
    yield();
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	832080e7          	jalr	-1998(ra) # 8000247a <yield>
    80002c50:	b78d                	j	80002bb2 <usertrap+0x64>
  int which_dev = 0;
    80002c52:	4901                	li	s2,0
    80002c54:	b7d5                	j	80002c38 <usertrap+0xea>

0000000080002c56 <kerneltrap>:
{
    80002c56:	7179                	addi	sp,sp,-48
    80002c58:	f406                	sd	ra,40(sp)
    80002c5a:	f022                	sd	s0,32(sp)
    80002c5c:	ec26                	sd	s1,24(sp)
    80002c5e:	e84a                	sd	s2,16(sp)
    80002c60:	e44e                	sd	s3,8(sp)
    80002c62:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c64:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c68:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c6c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c70:	1004f793          	andi	a5,s1,256
    80002c74:	cb85                	beqz	a5,80002ca4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c76:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c7a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c7c:	ef85                	bnez	a5,80002cb4 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	e40080e7          	jalr	-448(ra) # 80002abe <devintr>
    80002c86:	cd1d                	beqz	a0,80002cc4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c88:	4789                	li	a5,2
    80002c8a:	08f50063          	beq	a0,a5,80002d0a <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c8e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c92:	10049073          	csrw	sstatus,s1
}
    80002c96:	70a2                	ld	ra,40(sp)
    80002c98:	7402                	ld	s0,32(sp)
    80002c9a:	64e2                	ld	s1,24(sp)
    80002c9c:	6942                	ld	s2,16(sp)
    80002c9e:	69a2                	ld	s3,8(sp)
    80002ca0:	6145                	addi	sp,sp,48
    80002ca2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ca4:	00007517          	auipc	a0,0x7
    80002ca8:	9bc50513          	addi	a0,a0,-1604 # 80009660 <states.0+0x108>
    80002cac:	ffffe097          	auipc	ra,0xffffe
    80002cb0:	8b8080e7          	jalr	-1864(ra) # 80000564 <panic>
    panic("kerneltrap: interrupts enabled");
    80002cb4:	00007517          	auipc	a0,0x7
    80002cb8:	9d450513          	addi	a0,a0,-1580 # 80009688 <states.0+0x130>
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	8a8080e7          	jalr	-1880(ra) # 80000564 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002cc4:	854e                	mv	a0,s3
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	c3e080e7          	jalr	-962(ra) # 80002904 <scause_desc>
    80002cce:	862a                	mv	a2,a0
    80002cd0:	85ce                	mv	a1,s3
    80002cd2:	00007517          	auipc	a0,0x7
    80002cd6:	9d650513          	addi	a0,a0,-1578 # 800096a8 <states.0+0x150>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	8ec080e7          	jalr	-1812(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ce6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cea:	00007517          	auipc	a0,0x7
    80002cee:	9ce50513          	addi	a0,a0,-1586 # 800096b8 <states.0+0x160>
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	8d4080e7          	jalr	-1836(ra) # 800005c6 <printf>
    panic("kerneltrap");
    80002cfa:	00007517          	auipc	a0,0x7
    80002cfe:	9d650513          	addi	a0,a0,-1578 # 800096d0 <states.0+0x178>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	862080e7          	jalr	-1950(ra) # 80000564 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	e46080e7          	jalr	-442(ra) # 80001b50 <myproc>
    80002d12:	dd35                	beqz	a0,80002c8e <kerneltrap+0x38>
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	e3c080e7          	jalr	-452(ra) # 80001b50 <myproc>
    80002d1c:	5118                	lw	a4,32(a0)
    80002d1e:	478d                	li	a5,3
    80002d20:	f6f717e3          	bne	a4,a5,80002c8e <kerneltrap+0x38>
    yield();
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	756080e7          	jalr	1878(ra) # 8000247a <yield>
    80002d2c:	b78d                	j	80002c8e <kerneltrap+0x38>

0000000080002d2e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d2e:	1101                	addi	sp,sp,-32
    80002d30:	ec06                	sd	ra,24(sp)
    80002d32:	e822                	sd	s0,16(sp)
    80002d34:	e426                	sd	s1,8(sp)
    80002d36:	1000                	addi	s0,sp,32
    80002d38:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	e16080e7          	jalr	-490(ra) # 80001b50 <myproc>
  switch (n) {
    80002d42:	4795                	li	a5,5
    80002d44:	0497e163          	bltu	a5,s1,80002d86 <argraw+0x58>
    80002d48:	048a                	slli	s1,s1,0x2
    80002d4a:	00007717          	auipc	a4,0x7
    80002d4e:	cb670713          	addi	a4,a4,-842 # 80009a00 <nointr_desc.0+0xa8>
    80002d52:	94ba                	add	s1,s1,a4
    80002d54:	409c                	lw	a5,0(s1)
    80002d56:	97ba                	add	a5,a5,a4
    80002d58:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d5a:	713c                	ld	a5,96(a0)
    80002d5c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	64a2                	ld	s1,8(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret
    return p->trapframe->a1;
    80002d68:	713c                	ld	a5,96(a0)
    80002d6a:	7fa8                	ld	a0,120(a5)
    80002d6c:	bfcd                	j	80002d5e <argraw+0x30>
    return p->trapframe->a2;
    80002d6e:	713c                	ld	a5,96(a0)
    80002d70:	63c8                	ld	a0,128(a5)
    80002d72:	b7f5                	j	80002d5e <argraw+0x30>
    return p->trapframe->a3;
    80002d74:	713c                	ld	a5,96(a0)
    80002d76:	67c8                	ld	a0,136(a5)
    80002d78:	b7dd                	j	80002d5e <argraw+0x30>
    return p->trapframe->a4;
    80002d7a:	713c                	ld	a5,96(a0)
    80002d7c:	6bc8                	ld	a0,144(a5)
    80002d7e:	b7c5                	j	80002d5e <argraw+0x30>
    return p->trapframe->a5;
    80002d80:	713c                	ld	a5,96(a0)
    80002d82:	6fc8                	ld	a0,152(a5)
    80002d84:	bfe9                	j	80002d5e <argraw+0x30>
  panic("argraw");
    80002d86:	00007517          	auipc	a0,0x7
    80002d8a:	c5250513          	addi	a0,a0,-942 # 800099d8 <nointr_desc.0+0x80>
    80002d8e:	ffffd097          	auipc	ra,0xffffd
    80002d92:	7d6080e7          	jalr	2006(ra) # 80000564 <panic>

0000000080002d96 <fetchaddr>:
{
    80002d96:	1101                	addi	sp,sp,-32
    80002d98:	ec06                	sd	ra,24(sp)
    80002d9a:	e822                	sd	s0,16(sp)
    80002d9c:	e426                	sd	s1,8(sp)
    80002d9e:	e04a                	sd	s2,0(sp)
    80002da0:	1000                	addi	s0,sp,32
    80002da2:	84aa                	mv	s1,a0
    80002da4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002da6:	fffff097          	auipc	ra,0xfffff
    80002daa:	daa080e7          	jalr	-598(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002dae:	693c                	ld	a5,80(a0)
    80002db0:	02f4f863          	bgeu	s1,a5,80002de0 <fetchaddr+0x4a>
    80002db4:	00848713          	addi	a4,s1,8
    80002db8:	02e7e663          	bltu	a5,a4,80002de4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dbc:	46a1                	li	a3,8
    80002dbe:	8626                	mv	a2,s1
    80002dc0:	85ca                	mv	a1,s2
    80002dc2:	6d28                	ld	a0,88(a0)
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	ac8080e7          	jalr	-1336(ra) # 8000188c <copyin>
    80002dcc:	00a03533          	snez	a0,a0
    80002dd0:	40a00533          	neg	a0,a0
}
    80002dd4:	60e2                	ld	ra,24(sp)
    80002dd6:	6442                	ld	s0,16(sp)
    80002dd8:	64a2                	ld	s1,8(sp)
    80002dda:	6902                	ld	s2,0(sp)
    80002ddc:	6105                	addi	sp,sp,32
    80002dde:	8082                	ret
    return -1;
    80002de0:	557d                	li	a0,-1
    80002de2:	bfcd                	j	80002dd4 <fetchaddr+0x3e>
    80002de4:	557d                	li	a0,-1
    80002de6:	b7fd                	j	80002dd4 <fetchaddr+0x3e>

0000000080002de8 <fetchstr>:
{
    80002de8:	7179                	addi	sp,sp,-48
    80002dea:	f406                	sd	ra,40(sp)
    80002dec:	f022                	sd	s0,32(sp)
    80002dee:	ec26                	sd	s1,24(sp)
    80002df0:	e84a                	sd	s2,16(sp)
    80002df2:	e44e                	sd	s3,8(sp)
    80002df4:	1800                	addi	s0,sp,48
    80002df6:	892a                	mv	s2,a0
    80002df8:	84ae                	mv	s1,a1
    80002dfa:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dfc:	fffff097          	auipc	ra,0xfffff
    80002e00:	d54080e7          	jalr	-684(ra) # 80001b50 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e04:	86ce                	mv	a3,s3
    80002e06:	864a                	mv	a2,s2
    80002e08:	85a6                	mv	a1,s1
    80002e0a:	6d28                	ld	a0,88(a0)
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	b0e080e7          	jalr	-1266(ra) # 8000191a <copyinstr>
  if(err < 0)
    80002e14:	00054763          	bltz	a0,80002e22 <fetchstr+0x3a>
  return strlen(buf);
    80002e18:	8526                	mv	a0,s1
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	204080e7          	jalr	516(ra) # 8000101e <strlen>
}
    80002e22:	70a2                	ld	ra,40(sp)
    80002e24:	7402                	ld	s0,32(sp)
    80002e26:	64e2                	ld	s1,24(sp)
    80002e28:	6942                	ld	s2,16(sp)
    80002e2a:	69a2                	ld	s3,8(sp)
    80002e2c:	6145                	addi	sp,sp,48
    80002e2e:	8082                	ret

0000000080002e30 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e30:	1101                	addi	sp,sp,-32
    80002e32:	ec06                	sd	ra,24(sp)
    80002e34:	e822                	sd	s0,16(sp)
    80002e36:	e426                	sd	s1,8(sp)
    80002e38:	1000                	addi	s0,sp,32
    80002e3a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e3c:	00000097          	auipc	ra,0x0
    80002e40:	ef2080e7          	jalr	-270(ra) # 80002d2e <argraw>
    80002e44:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e46:	4501                	li	a0,0
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	64a2                	ld	s1,8(sp)
    80002e4e:	6105                	addi	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e52:	1101                	addi	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	e426                	sd	s1,8(sp)
    80002e5a:	1000                	addi	s0,sp,32
    80002e5c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e5e:	00000097          	auipc	ra,0x0
    80002e62:	ed0080e7          	jalr	-304(ra) # 80002d2e <argraw>
    80002e66:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e68:	4501                	li	a0,0
    80002e6a:	60e2                	ld	ra,24(sp)
    80002e6c:	6442                	ld	s0,16(sp)
    80002e6e:	64a2                	ld	s1,8(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret

0000000080002e74 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	e04a                	sd	s2,0(sp)
    80002e7e:	1000                	addi	s0,sp,32
    80002e80:	84ae                	mv	s1,a1
    80002e82:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	eaa080e7          	jalr	-342(ra) # 80002d2e <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e8c:	864a                	mv	a2,s2
    80002e8e:	85a6                	mv	a1,s1
    80002e90:	00000097          	auipc	ra,0x0
    80002e94:	f58080e7          	jalr	-168(ra) # 80002de8 <fetchstr>
}
    80002e98:	60e2                	ld	ra,24(sp)
    80002e9a:	6442                	ld	s0,16(sp)
    80002e9c:	64a2                	ld	s1,8(sp)
    80002e9e:	6902                	ld	s2,0(sp)
    80002ea0:	6105                	addi	sp,sp,32
    80002ea2:	8082                	ret

0000000080002ea4 <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002ea4:	1101                	addi	sp,sp,-32
    80002ea6:	ec06                	sd	ra,24(sp)
    80002ea8:	e822                	sd	s0,16(sp)
    80002eaa:	e426                	sd	s1,8(sp)
    80002eac:	e04a                	sd	s2,0(sp)
    80002eae:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	ca0080e7          	jalr	-864(ra) # 80001b50 <myproc>
    80002eb8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002eba:	06053903          	ld	s2,96(a0)
    80002ebe:	0a893783          	ld	a5,168(s2)
    80002ec2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ec6:	37fd                	addiw	a5,a5,-1
    80002ec8:	4759                	li	a4,22
    80002eca:	00f76f63          	bltu	a4,a5,80002ee8 <syscall+0x44>
    80002ece:	00369713          	slli	a4,a3,0x3
    80002ed2:	00007797          	auipc	a5,0x7
    80002ed6:	b4678793          	addi	a5,a5,-1210 # 80009a18 <syscalls>
    80002eda:	97ba                	add	a5,a5,a4
    80002edc:	639c                	ld	a5,0(a5)
    80002ede:	c789                	beqz	a5,80002ee8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ee0:	9782                	jalr	a5
    80002ee2:	06a93823          	sd	a0,112(s2)
    80002ee6:	a839                	j	80002f04 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ee8:	16048613          	addi	a2,s1,352
    80002eec:	40ac                	lw	a1,64(s1)
    80002eee:	00007517          	auipc	a0,0x7
    80002ef2:	af250513          	addi	a0,a0,-1294 # 800099e0 <nointr_desc.0+0x88>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	6d0080e7          	jalr	1744(ra) # 800005c6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002efe:	70bc                	ld	a5,96(s1)
    80002f00:	577d                	li	a4,-1
    80002f02:	fbb8                	sd	a4,112(a5)
  }
}
    80002f04:	60e2                	ld	ra,24(sp)
    80002f06:	6442                	ld	s0,16(sp)
    80002f08:	64a2                	ld	s1,8(sp)
    80002f0a:	6902                	ld	s2,0(sp)
    80002f0c:	6105                	addi	sp,sp,32
    80002f0e:	8082                	ret

0000000080002f10 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f10:	1101                	addi	sp,sp,-32
    80002f12:	ec06                	sd	ra,24(sp)
    80002f14:	e822                	sd	s0,16(sp)
    80002f16:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f18:	fec40593          	addi	a1,s0,-20
    80002f1c:	4501                	li	a0,0
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	f12080e7          	jalr	-238(ra) # 80002e30 <argint>
    return -1;
    80002f26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f28:	00054963          	bltz	a0,80002f3a <sys_exit+0x2a>
  exit(n);
    80002f2c:	fec42503          	lw	a0,-20(s0)
    80002f30:	fffff097          	auipc	ra,0xfffff
    80002f34:	33a080e7          	jalr	826(ra) # 8000226a <exit>
  return 0;  // not reached
    80002f38:	4781                	li	a5,0
}
    80002f3a:	853e                	mv	a0,a5
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f44:	1141                	addi	sp,sp,-16
    80002f46:	e406                	sd	ra,8(sp)
    80002f48:	e022                	sd	s0,0(sp)
    80002f4a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	c04080e7          	jalr	-1020(ra) # 80001b50 <myproc>
}
    80002f54:	4128                	lw	a0,64(a0)
    80002f56:	60a2                	ld	ra,8(sp)
    80002f58:	6402                	ld	s0,0(sp)
    80002f5a:	0141                	addi	sp,sp,16
    80002f5c:	8082                	ret

0000000080002f5e <sys_fork>:

uint64
sys_fork(void)
{
    80002f5e:	1141                	addi	sp,sp,-16
    80002f60:	e406                	sd	ra,8(sp)
    80002f62:	e022                	sd	s0,0(sp)
    80002f64:	0800                	addi	s0,sp,16
  return fork();
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	f90080e7          	jalr	-112(ra) # 80001ef6 <fork>
}
    80002f6e:	60a2                	ld	ra,8(sp)
    80002f70:	6402                	ld	s0,0(sp)
    80002f72:	0141                	addi	sp,sp,16
    80002f74:	8082                	ret

0000000080002f76 <sys_wait>:

uint64
sys_wait(void)
{
    80002f76:	1101                	addi	sp,sp,-32
    80002f78:	ec06                	sd	ra,24(sp)
    80002f7a:	e822                	sd	s0,16(sp)
    80002f7c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f7e:	fe840593          	addi	a1,s0,-24
    80002f82:	4501                	li	a0,0
    80002f84:	00000097          	auipc	ra,0x0
    80002f88:	ece080e7          	jalr	-306(ra) # 80002e52 <argaddr>
    80002f8c:	87aa                	mv	a5,a0
    return -1;
    80002f8e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f90:	0007c863          	bltz	a5,80002fa0 <sys_wait+0x2a>
  return wait(p);
    80002f94:	fe843503          	ld	a0,-24(s0)
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	5a4080e7          	jalr	1444(ra) # 8000253c <wait>
}
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	6105                	addi	sp,sp,32
    80002fa6:	8082                	ret

0000000080002fa8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fa8:	7179                	addi	sp,sp,-48
    80002faa:	f406                	sd	ra,40(sp)
    80002fac:	f022                	sd	s0,32(sp)
    80002fae:	ec26                	sd	s1,24(sp)
    80002fb0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002fb2:	fdc40593          	addi	a1,s0,-36
    80002fb6:	4501                	li	a0,0
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	e78080e7          	jalr	-392(ra) # 80002e30 <argint>
    return -1;
    80002fc0:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002fc2:	00054f63          	bltz	a0,80002fe0 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002fc6:	fffff097          	auipc	ra,0xfffff
    80002fca:	b8a080e7          	jalr	-1142(ra) # 80001b50 <myproc>
    80002fce:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002fd0:	fdc42503          	lw	a0,-36(s0)
    80002fd4:	fffff097          	auipc	ra,0xfffff
    80002fd8:	eae080e7          	jalr	-338(ra) # 80001e82 <growproc>
    80002fdc:	00054863          	bltz	a0,80002fec <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fe0:	8526                	mv	a0,s1
    80002fe2:	70a2                	ld	ra,40(sp)
    80002fe4:	7402                	ld	s0,32(sp)
    80002fe6:	64e2                	ld	s1,24(sp)
    80002fe8:	6145                	addi	sp,sp,48
    80002fea:	8082                	ret
    return -1;
    80002fec:	54fd                	li	s1,-1
    80002fee:	bfcd                	j	80002fe0 <sys_sbrk+0x38>

0000000080002ff0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ff0:	7139                	addi	sp,sp,-64
    80002ff2:	fc06                	sd	ra,56(sp)
    80002ff4:	f822                	sd	s0,48(sp)
    80002ff6:	f426                	sd	s1,40(sp)
    80002ff8:	f04a                	sd	s2,32(sp)
    80002ffa:	ec4e                	sd	s3,24(sp)
    80002ffc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ffe:	fcc40593          	addi	a1,s0,-52
    80003002:	4501                	li	a0,0
    80003004:	00000097          	auipc	ra,0x0
    80003008:	e2c080e7          	jalr	-468(ra) # 80002e30 <argint>
    return -1;
    8000300c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000300e:	06054563          	bltz	a0,80003078 <sys_sleep+0x88>
  acquire(&tickslock);
    80003012:	0002a517          	auipc	a0,0x2a
    80003016:	cf650513          	addi	a0,a0,-778 # 8002cd08 <tickslock>
    8000301a:	ffffe097          	auipc	ra,0xffffe
    8000301e:	b78080e7          	jalr	-1160(ra) # 80000b92 <acquire>
  ticks0 = ticks;
    80003022:	00007917          	auipc	s2,0x7
    80003026:	fde92903          	lw	s2,-34(s2) # 8000a000 <ticks>
  while(ticks - ticks0 < n){
    8000302a:	fcc42783          	lw	a5,-52(s0)
    8000302e:	cf85                	beqz	a5,80003066 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003030:	0002a997          	auipc	s3,0x2a
    80003034:	cd898993          	addi	s3,s3,-808 # 8002cd08 <tickslock>
    80003038:	00007497          	auipc	s1,0x7
    8000303c:	fc848493          	addi	s1,s1,-56 # 8000a000 <ticks>
    if(myproc()->killed){
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	b10080e7          	jalr	-1264(ra) # 80001b50 <myproc>
    80003048:	5d1c                	lw	a5,56(a0)
    8000304a:	ef9d                	bnez	a5,80003088 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000304c:	85ce                	mv	a1,s3
    8000304e:	8526                	mv	a0,s1
    80003050:	fffff097          	auipc	ra,0xfffff
    80003054:	46e080e7          	jalr	1134(ra) # 800024be <sleep>
  while(ticks - ticks0 < n){
    80003058:	409c                	lw	a5,0(s1)
    8000305a:	412787bb          	subw	a5,a5,s2
    8000305e:	fcc42703          	lw	a4,-52(s0)
    80003062:	fce7efe3          	bltu	a5,a4,80003040 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003066:	0002a517          	auipc	a0,0x2a
    8000306a:	ca250513          	addi	a0,a0,-862 # 8002cd08 <tickslock>
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	bf4080e7          	jalr	-1036(ra) # 80000c62 <release>
  return 0;
    80003076:	4781                	li	a5,0
}
    80003078:	853e                	mv	a0,a5
    8000307a:	70e2                	ld	ra,56(sp)
    8000307c:	7442                	ld	s0,48(sp)
    8000307e:	74a2                	ld	s1,40(sp)
    80003080:	7902                	ld	s2,32(sp)
    80003082:	69e2                	ld	s3,24(sp)
    80003084:	6121                	addi	sp,sp,64
    80003086:	8082                	ret
      release(&tickslock);
    80003088:	0002a517          	auipc	a0,0x2a
    8000308c:	c8050513          	addi	a0,a0,-896 # 8002cd08 <tickslock>
    80003090:	ffffe097          	auipc	ra,0xffffe
    80003094:	bd2080e7          	jalr	-1070(ra) # 80000c62 <release>
      return -1;
    80003098:	57fd                	li	a5,-1
    8000309a:	bff9                	j	80003078 <sys_sleep+0x88>

000000008000309c <sys_kill>:

uint64
sys_kill(void)
{
    8000309c:	1101                	addi	sp,sp,-32
    8000309e:	ec06                	sd	ra,24(sp)
    800030a0:	e822                	sd	s0,16(sp)
    800030a2:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030a4:	fec40593          	addi	a1,s0,-20
    800030a8:	4501                	li	a0,0
    800030aa:	00000097          	auipc	ra,0x0
    800030ae:	d86080e7          	jalr	-634(ra) # 80002e30 <argint>
    800030b2:	87aa                	mv	a5,a0
    return -1;
    800030b4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030b6:	0007c863          	bltz	a5,800030c6 <sys_kill+0x2a>
  return kill(pid);
    800030ba:	fec42503          	lw	a0,-20(s0)
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	5f2080e7          	jalr	1522(ra) # 800026b0 <kill>
}
    800030c6:	60e2                	ld	ra,24(sp)
    800030c8:	6442                	ld	s0,16(sp)
    800030ca:	6105                	addi	sp,sp,32
    800030cc:	8082                	ret

00000000800030ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030ce:	1101                	addi	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	e426                	sd	s1,8(sp)
    800030d6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030d8:	0002a517          	auipc	a0,0x2a
    800030dc:	c3050513          	addi	a0,a0,-976 # 8002cd08 <tickslock>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	ab2080e7          	jalr	-1358(ra) # 80000b92 <acquire>
  xticks = ticks;
    800030e8:	00007497          	auipc	s1,0x7
    800030ec:	f184a483          	lw	s1,-232(s1) # 8000a000 <ticks>
  release(&tickslock);
    800030f0:	0002a517          	auipc	a0,0x2a
    800030f4:	c1850513          	addi	a0,a0,-1000 # 8002cd08 <tickslock>
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	b6a080e7          	jalr	-1174(ra) # 80000c62 <release>
  return xticks;
    80003100:	02049513          	slli	a0,s1,0x20
    80003104:	9101                	srli	a0,a0,0x20
    80003106:	60e2                	ld	ra,24(sp)
    80003108:	6442                	ld	s0,16(sp)
    8000310a:	64a2                	ld	s1,8(sp)
    8000310c:	6105                	addi	sp,sp,32
    8000310e:	8082                	ret

0000000080003110 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003110:	7179                	addi	sp,sp,-48
    80003112:	f406                	sd	ra,40(sp)
    80003114:	f022                	sd	s0,32(sp)
    80003116:	ec26                	sd	s1,24(sp)
    80003118:	e84a                	sd	s2,16(sp)
    8000311a:	e44e                	sd	s3,8(sp)
    8000311c:	e052                	sd	s4,0(sp)
    8000311e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003120:	00007597          	auipc	a1,0x7
    80003124:	9b858593          	addi	a1,a1,-1608 # 80009ad8 <syscalls+0xc0>
    80003128:	0002a517          	auipc	a0,0x2a
    8000312c:	c0050513          	addi	a0,a0,-1024 # 8002cd28 <bcache>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	98c080e7          	jalr	-1652(ra) # 80000abc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003138:	00032797          	auipc	a5,0x32
    8000313c:	bf078793          	addi	a5,a5,-1040 # 80034d28 <bcache+0x8000>
    80003140:	00032717          	auipc	a4,0x32
    80003144:	f4870713          	addi	a4,a4,-184 # 80035088 <bcache+0x8360>
    80003148:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    8000314c:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003150:	0002a497          	auipc	s1,0x2a
    80003154:	bf848493          	addi	s1,s1,-1032 # 8002cd48 <bcache+0x20>
    b->next = bcache.head.next;
    80003158:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000315a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000315c:	00007a17          	auipc	s4,0x7
    80003160:	984a0a13          	addi	s4,s4,-1660 # 80009ae0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003164:	3b893783          	ld	a5,952(s2)
    80003168:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    8000316a:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    8000316e:	85d2                	mv	a1,s4
    80003170:	01048513          	addi	a0,s1,16
    80003174:	00001097          	auipc	ra,0x1
    80003178:	4aa080e7          	jalr	1194(ra) # 8000461e <initsleeplock>
    bcache.head.next->prev = b;
    8000317c:	3b893783          	ld	a5,952(s2)
    80003180:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80003182:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003186:	46048493          	addi	s1,s1,1120
    8000318a:	fd349de3          	bne	s1,s3,80003164 <binit+0x54>
  }
}
    8000318e:	70a2                	ld	ra,40(sp)
    80003190:	7402                	ld	s0,32(sp)
    80003192:	64e2                	ld	s1,24(sp)
    80003194:	6942                	ld	s2,16(sp)
    80003196:	69a2                	ld	s3,8(sp)
    80003198:	6a02                	ld	s4,0(sp)
    8000319a:	6145                	addi	sp,sp,48
    8000319c:	8082                	ret

000000008000319e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000319e:	7179                	addi	sp,sp,-48
    800031a0:	f406                	sd	ra,40(sp)
    800031a2:	f022                	sd	s0,32(sp)
    800031a4:	ec26                	sd	s1,24(sp)
    800031a6:	e84a                	sd	s2,16(sp)
    800031a8:	e44e                	sd	s3,8(sp)
    800031aa:	1800                	addi	s0,sp,48
    800031ac:	892a                	mv	s2,a0
    800031ae:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031b0:	0002a517          	auipc	a0,0x2a
    800031b4:	b7850513          	addi	a0,a0,-1160 # 8002cd28 <bcache>
    800031b8:	ffffe097          	auipc	ra,0xffffe
    800031bc:	9da080e7          	jalr	-1574(ra) # 80000b92 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031c0:	00032497          	auipc	s1,0x32
    800031c4:	f204b483          	ld	s1,-224(s1) # 800350e0 <bcache+0x83b8>
    800031c8:	00032797          	auipc	a5,0x32
    800031cc:	ec078793          	addi	a5,a5,-320 # 80035088 <bcache+0x8360>
    800031d0:	02f48f63          	beq	s1,a5,8000320e <bread+0x70>
    800031d4:	873e                	mv	a4,a5
    800031d6:	a021                	j	800031de <bread+0x40>
    800031d8:	6ca4                	ld	s1,88(s1)
    800031da:	02e48a63          	beq	s1,a4,8000320e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031de:	449c                	lw	a5,8(s1)
    800031e0:	ff279ce3          	bne	a5,s2,800031d8 <bread+0x3a>
    800031e4:	44dc                	lw	a5,12(s1)
    800031e6:	ff3799e3          	bne	a5,s3,800031d8 <bread+0x3a>
      b->refcnt++;
    800031ea:	44bc                	lw	a5,72(s1)
    800031ec:	2785                	addiw	a5,a5,1
    800031ee:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800031f0:	0002a517          	auipc	a0,0x2a
    800031f4:	b3850513          	addi	a0,a0,-1224 # 8002cd28 <bcache>
    800031f8:	ffffe097          	auipc	ra,0xffffe
    800031fc:	a6a080e7          	jalr	-1430(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    80003200:	01048513          	addi	a0,s1,16
    80003204:	00001097          	auipc	ra,0x1
    80003208:	454080e7          	jalr	1108(ra) # 80004658 <acquiresleep>
      return b;
    8000320c:	a8b9                	j	8000326a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000320e:	00032497          	auipc	s1,0x32
    80003212:	eca4b483          	ld	s1,-310(s1) # 800350d8 <bcache+0x83b0>
    80003216:	00032797          	auipc	a5,0x32
    8000321a:	e7278793          	addi	a5,a5,-398 # 80035088 <bcache+0x8360>
    8000321e:	00f48863          	beq	s1,a5,8000322e <bread+0x90>
    80003222:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003224:	44bc                	lw	a5,72(s1)
    80003226:	cf81                	beqz	a5,8000323e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003228:	68a4                	ld	s1,80(s1)
    8000322a:	fee49de3          	bne	s1,a4,80003224 <bread+0x86>
  panic("bget: no buffers");
    8000322e:	00007517          	auipc	a0,0x7
    80003232:	8ba50513          	addi	a0,a0,-1862 # 80009ae8 <syscalls+0xd0>
    80003236:	ffffd097          	auipc	ra,0xffffd
    8000323a:	32e080e7          	jalr	814(ra) # 80000564 <panic>
      b->dev = dev;
    8000323e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003242:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003246:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000324a:	4785                	li	a5,1
    8000324c:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000324e:	0002a517          	auipc	a0,0x2a
    80003252:	ada50513          	addi	a0,a0,-1318 # 8002cd28 <bcache>
    80003256:	ffffe097          	auipc	ra,0xffffe
    8000325a:	a0c080e7          	jalr	-1524(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    8000325e:	01048513          	addi	a0,s1,16
    80003262:	00001097          	auipc	ra,0x1
    80003266:	3f6080e7          	jalr	1014(ra) # 80004658 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000326a:	409c                	lw	a5,0(s1)
    8000326c:	cb89                	beqz	a5,8000327e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000326e:	8526                	mv	a0,s1
    80003270:	70a2                	ld	ra,40(sp)
    80003272:	7402                	ld	s0,32(sp)
    80003274:	64e2                	ld	s1,24(sp)
    80003276:	6942                	ld	s2,16(sp)
    80003278:	69a2                	ld	s3,8(sp)
    8000327a:	6145                	addi	sp,sp,48
    8000327c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000327e:	4581                	li	a1,0
    80003280:	8526                	mv	a0,s1
    80003282:	00003097          	auipc	ra,0x3
    80003286:	f94080e7          	jalr	-108(ra) # 80006216 <virtio_disk_rw>
    b->valid = 1;
    8000328a:	4785                	li	a5,1
    8000328c:	c09c                	sw	a5,0(s1)
  return b;
    8000328e:	b7c5                	j	8000326e <bread+0xd0>

0000000080003290 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	1000                	addi	s0,sp,32
    8000329a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000329c:	0541                	addi	a0,a0,16
    8000329e:	00001097          	auipc	ra,0x1
    800032a2:	454080e7          	jalr	1108(ra) # 800046f2 <holdingsleep>
    800032a6:	cd01                	beqz	a0,800032be <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032a8:	4585                	li	a1,1
    800032aa:	8526                	mv	a0,s1
    800032ac:	00003097          	auipc	ra,0x3
    800032b0:	f6a080e7          	jalr	-150(ra) # 80006216 <virtio_disk_rw>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6105                	addi	sp,sp,32
    800032bc:	8082                	ret
    panic("bwrite");
    800032be:	00007517          	auipc	a0,0x7
    800032c2:	84250513          	addi	a0,a0,-1982 # 80009b00 <syscalls+0xe8>
    800032c6:	ffffd097          	auipc	ra,0xffffd
    800032ca:	29e080e7          	jalr	670(ra) # 80000564 <panic>

00000000800032ce <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    800032ce:	1101                	addi	sp,sp,-32
    800032d0:	ec06                	sd	ra,24(sp)
    800032d2:	e822                	sd	s0,16(sp)
    800032d4:	e426                	sd	s1,8(sp)
    800032d6:	e04a                	sd	s2,0(sp)
    800032d8:	1000                	addi	s0,sp,32
    800032da:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032dc:	01050913          	addi	s2,a0,16
    800032e0:	854a                	mv	a0,s2
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	410080e7          	jalr	1040(ra) # 800046f2 <holdingsleep>
    800032ea:	c92d                	beqz	a0,8000335c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032ec:	854a                	mv	a0,s2
    800032ee:	00001097          	auipc	ra,0x1
    800032f2:	3c0080e7          	jalr	960(ra) # 800046ae <releasesleep>

  acquire(&bcache.lock);
    800032f6:	0002a517          	auipc	a0,0x2a
    800032fa:	a3250513          	addi	a0,a0,-1486 # 8002cd28 <bcache>
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	894080e7          	jalr	-1900(ra) # 80000b92 <acquire>
  b->refcnt--;
    80003306:	44bc                	lw	a5,72(s1)
    80003308:	37fd                	addiw	a5,a5,-1
    8000330a:	0007871b          	sext.w	a4,a5
    8000330e:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003310:	eb05                	bnez	a4,80003340 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003312:	6cbc                	ld	a5,88(s1)
    80003314:	68b8                	ld	a4,80(s1)
    80003316:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003318:	68bc                	ld	a5,80(s1)
    8000331a:	6cb8                	ld	a4,88(s1)
    8000331c:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    8000331e:	00032797          	auipc	a5,0x32
    80003322:	a0a78793          	addi	a5,a5,-1526 # 80034d28 <bcache+0x8000>
    80003326:	3b87b703          	ld	a4,952(a5)
    8000332a:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000332c:	00032717          	auipc	a4,0x32
    80003330:	d5c70713          	addi	a4,a4,-676 # 80035088 <bcache+0x8360>
    80003334:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003336:	3b87b703          	ld	a4,952(a5)
    8000333a:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    8000333c:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003340:	0002a517          	auipc	a0,0x2a
    80003344:	9e850513          	addi	a0,a0,-1560 # 8002cd28 <bcache>
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	91a080e7          	jalr	-1766(ra) # 80000c62 <release>
}
    80003350:	60e2                	ld	ra,24(sp)
    80003352:	6442                	ld	s0,16(sp)
    80003354:	64a2                	ld	s1,8(sp)
    80003356:	6902                	ld	s2,0(sp)
    80003358:	6105                	addi	sp,sp,32
    8000335a:	8082                	ret
    panic("brelse");
    8000335c:	00006517          	auipc	a0,0x6
    80003360:	7ac50513          	addi	a0,a0,1964 # 80009b08 <syscalls+0xf0>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	200080e7          	jalr	512(ra) # 80000564 <panic>

000000008000336c <bpin>:

void
bpin(struct buf *b) {
    8000336c:	1101                	addi	sp,sp,-32
    8000336e:	ec06                	sd	ra,24(sp)
    80003370:	e822                	sd	s0,16(sp)
    80003372:	e426                	sd	s1,8(sp)
    80003374:	1000                	addi	s0,sp,32
    80003376:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003378:	0002a517          	auipc	a0,0x2a
    8000337c:	9b050513          	addi	a0,a0,-1616 # 8002cd28 <bcache>
    80003380:	ffffe097          	auipc	ra,0xffffe
    80003384:	812080e7          	jalr	-2030(ra) # 80000b92 <acquire>
  b->refcnt++;
    80003388:	44bc                	lw	a5,72(s1)
    8000338a:	2785                	addiw	a5,a5,1
    8000338c:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    8000338e:	0002a517          	auipc	a0,0x2a
    80003392:	99a50513          	addi	a0,a0,-1638 # 8002cd28 <bcache>
    80003396:	ffffe097          	auipc	ra,0xffffe
    8000339a:	8cc080e7          	jalr	-1844(ra) # 80000c62 <release>
}
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret

00000000800033a8 <bunpin>:

void
bunpin(struct buf *b) {
    800033a8:	1101                	addi	sp,sp,-32
    800033aa:	ec06                	sd	ra,24(sp)
    800033ac:	e822                	sd	s0,16(sp)
    800033ae:	e426                	sd	s1,8(sp)
    800033b0:	1000                	addi	s0,sp,32
    800033b2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033b4:	0002a517          	auipc	a0,0x2a
    800033b8:	97450513          	addi	a0,a0,-1676 # 8002cd28 <bcache>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	7d6080e7          	jalr	2006(ra) # 80000b92 <acquire>
  b->refcnt--;
    800033c4:	44bc                	lw	a5,72(s1)
    800033c6:	37fd                	addiw	a5,a5,-1
    800033c8:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800033ca:	0002a517          	auipc	a0,0x2a
    800033ce:	95e50513          	addi	a0,a0,-1698 # 8002cd28 <bcache>
    800033d2:	ffffe097          	auipc	ra,0xffffe
    800033d6:	890080e7          	jalr	-1904(ra) # 80000c62 <release>
}
    800033da:	60e2                	ld	ra,24(sp)
    800033dc:	6442                	ld	s0,16(sp)
    800033de:	64a2                	ld	s1,8(sp)
    800033e0:	6105                	addi	sp,sp,32
    800033e2:	8082                	ret

00000000800033e4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033e4:	1101                	addi	sp,sp,-32
    800033e6:	ec06                	sd	ra,24(sp)
    800033e8:	e822                	sd	s0,16(sp)
    800033ea:	e426                	sd	s1,8(sp)
    800033ec:	e04a                	sd	s2,0(sp)
    800033ee:	1000                	addi	s0,sp,32
    800033f0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033f2:	00d5d59b          	srliw	a1,a1,0xd
    800033f6:	00032797          	auipc	a5,0x32
    800033fa:	10e7a783          	lw	a5,270(a5) # 80035504 <sb+0x1c>
    800033fe:	9dbd                	addw	a1,a1,a5
    80003400:	00000097          	auipc	ra,0x0
    80003404:	d9e080e7          	jalr	-610(ra) # 8000319e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003408:	0074f713          	andi	a4,s1,7
    8000340c:	4785                	li	a5,1
    8000340e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003412:	14ce                	slli	s1,s1,0x33
    80003414:	90d9                	srli	s1,s1,0x36
    80003416:	00950733          	add	a4,a0,s1
    8000341a:	06074703          	lbu	a4,96(a4)
    8000341e:	00e7f6b3          	and	a3,a5,a4
    80003422:	c69d                	beqz	a3,80003450 <bfree+0x6c>
    80003424:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003426:	94aa                	add	s1,s1,a0
    80003428:	fff7c793          	not	a5,a5
    8000342c:	8ff9                	and	a5,a5,a4
    8000342e:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003432:	00001097          	auipc	ra,0x1
    80003436:	106080e7          	jalr	262(ra) # 80004538 <log_write>
  brelse(bp);
    8000343a:	854a                	mv	a0,s2
    8000343c:	00000097          	auipc	ra,0x0
    80003440:	e92080e7          	jalr	-366(ra) # 800032ce <brelse>
}
    80003444:	60e2                	ld	ra,24(sp)
    80003446:	6442                	ld	s0,16(sp)
    80003448:	64a2                	ld	s1,8(sp)
    8000344a:	6902                	ld	s2,0(sp)
    8000344c:	6105                	addi	sp,sp,32
    8000344e:	8082                	ret
    panic("freeing free block");
    80003450:	00006517          	auipc	a0,0x6
    80003454:	6c050513          	addi	a0,a0,1728 # 80009b10 <syscalls+0xf8>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	10c080e7          	jalr	268(ra) # 80000564 <panic>

0000000080003460 <balloc>:
{
    80003460:	711d                	addi	sp,sp,-96
    80003462:	ec86                	sd	ra,88(sp)
    80003464:	e8a2                	sd	s0,80(sp)
    80003466:	e4a6                	sd	s1,72(sp)
    80003468:	e0ca                	sd	s2,64(sp)
    8000346a:	fc4e                	sd	s3,56(sp)
    8000346c:	f852                	sd	s4,48(sp)
    8000346e:	f456                	sd	s5,40(sp)
    80003470:	f05a                	sd	s6,32(sp)
    80003472:	ec5e                	sd	s7,24(sp)
    80003474:	e862                	sd	s8,16(sp)
    80003476:	e466                	sd	s9,8(sp)
    80003478:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000347a:	00032797          	auipc	a5,0x32
    8000347e:	0727a783          	lw	a5,114(a5) # 800354ec <sb+0x4>
    80003482:	cbd1                	beqz	a5,80003516 <balloc+0xb6>
    80003484:	8baa                	mv	s7,a0
    80003486:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003488:	00032b17          	auipc	s6,0x32
    8000348c:	060b0b13          	addi	s6,s6,96 # 800354e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003490:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003492:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003494:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003496:	6c89                	lui	s9,0x2
    80003498:	a831                	j	800034b4 <balloc+0x54>
    brelse(bp);
    8000349a:	854a                	mv	a0,s2
    8000349c:	00000097          	auipc	ra,0x0
    800034a0:	e32080e7          	jalr	-462(ra) # 800032ce <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034a4:	015c87bb          	addw	a5,s9,s5
    800034a8:	00078a9b          	sext.w	s5,a5
    800034ac:	004b2703          	lw	a4,4(s6)
    800034b0:	06eaf363          	bgeu	s5,a4,80003516 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800034b4:	41fad79b          	sraiw	a5,s5,0x1f
    800034b8:	0137d79b          	srliw	a5,a5,0x13
    800034bc:	015787bb          	addw	a5,a5,s5
    800034c0:	40d7d79b          	sraiw	a5,a5,0xd
    800034c4:	01cb2583          	lw	a1,28(s6)
    800034c8:	9dbd                	addw	a1,a1,a5
    800034ca:	855e                	mv	a0,s7
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	cd2080e7          	jalr	-814(ra) # 8000319e <bread>
    800034d4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d6:	004b2503          	lw	a0,4(s6)
    800034da:	000a849b          	sext.w	s1,s5
    800034de:	8662                	mv	a2,s8
    800034e0:	faa4fde3          	bgeu	s1,a0,8000349a <balloc+0x3a>
      m = 1 << (bi % 8);
    800034e4:	41f6579b          	sraiw	a5,a2,0x1f
    800034e8:	01d7d69b          	srliw	a3,a5,0x1d
    800034ec:	00c6873b          	addw	a4,a3,a2
    800034f0:	00777793          	andi	a5,a4,7
    800034f4:	9f95                	subw	a5,a5,a3
    800034f6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034fa:	4037571b          	sraiw	a4,a4,0x3
    800034fe:	00e906b3          	add	a3,s2,a4
    80003502:	0606c683          	lbu	a3,96(a3)
    80003506:	00d7f5b3          	and	a1,a5,a3
    8000350a:	cd91                	beqz	a1,80003526 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000350c:	2605                	addiw	a2,a2,1
    8000350e:	2485                	addiw	s1,s1,1
    80003510:	fd4618e3          	bne	a2,s4,800034e0 <balloc+0x80>
    80003514:	b759                	j	8000349a <balloc+0x3a>
  panic("balloc: out of blocks");
    80003516:	00006517          	auipc	a0,0x6
    8000351a:	61250513          	addi	a0,a0,1554 # 80009b28 <syscalls+0x110>
    8000351e:	ffffd097          	auipc	ra,0xffffd
    80003522:	046080e7          	jalr	70(ra) # 80000564 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003526:	974a                	add	a4,a4,s2
    80003528:	8fd5                	or	a5,a5,a3
    8000352a:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000352e:	854a                	mv	a0,s2
    80003530:	00001097          	auipc	ra,0x1
    80003534:	008080e7          	jalr	8(ra) # 80004538 <log_write>
        brelse(bp);
    80003538:	854a                	mv	a0,s2
    8000353a:	00000097          	auipc	ra,0x0
    8000353e:	d94080e7          	jalr	-620(ra) # 800032ce <brelse>
  bp = bread(dev, bno);
    80003542:	85a6                	mv	a1,s1
    80003544:	855e                	mv	a0,s7
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	c58080e7          	jalr	-936(ra) # 8000319e <bread>
    8000354e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003550:	40000613          	li	a2,1024
    80003554:	4581                	li	a1,0
    80003556:	06050513          	addi	a0,a0,96
    8000355a:	ffffe097          	auipc	ra,0xffffe
    8000355e:	91c080e7          	jalr	-1764(ra) # 80000e76 <memset>
  log_write(bp);
    80003562:	854a                	mv	a0,s2
    80003564:	00001097          	auipc	ra,0x1
    80003568:	fd4080e7          	jalr	-44(ra) # 80004538 <log_write>
  brelse(bp);
    8000356c:	854a                	mv	a0,s2
    8000356e:	00000097          	auipc	ra,0x0
    80003572:	d60080e7          	jalr	-672(ra) # 800032ce <brelse>
}
    80003576:	8526                	mv	a0,s1
    80003578:	60e6                	ld	ra,88(sp)
    8000357a:	6446                	ld	s0,80(sp)
    8000357c:	64a6                	ld	s1,72(sp)
    8000357e:	6906                	ld	s2,64(sp)
    80003580:	79e2                	ld	s3,56(sp)
    80003582:	7a42                	ld	s4,48(sp)
    80003584:	7aa2                	ld	s5,40(sp)
    80003586:	7b02                	ld	s6,32(sp)
    80003588:	6be2                	ld	s7,24(sp)
    8000358a:	6c42                	ld	s8,16(sp)
    8000358c:	6ca2                	ld	s9,8(sp)
    8000358e:	6125                	addi	sp,sp,96
    80003590:	8082                	ret

0000000080003592 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003592:	7179                	addi	sp,sp,-48
    80003594:	f406                	sd	ra,40(sp)
    80003596:	f022                	sd	s0,32(sp)
    80003598:	ec26                	sd	s1,24(sp)
    8000359a:	e84a                	sd	s2,16(sp)
    8000359c:	e44e                	sd	s3,8(sp)
    8000359e:	e052                	sd	s4,0(sp)
    800035a0:	1800                	addi	s0,sp,48
    800035a2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035a4:	47ad                	li	a5,11
    800035a6:	04b7fe63          	bgeu	a5,a1,80003602 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800035aa:	ff45849b          	addiw	s1,a1,-12
    800035ae:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800035b2:	0ff00793          	li	a5,255
    800035b6:	0ae7e363          	bltu	a5,a4,8000365c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800035ba:	08852583          	lw	a1,136(a0)
    800035be:	c5ad                	beqz	a1,80003628 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035c0:	00092503          	lw	a0,0(s2)
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	bda080e7          	jalr	-1062(ra) # 8000319e <bread>
    800035cc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035ce:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800035d2:	02049593          	slli	a1,s1,0x20
    800035d6:	9181                	srli	a1,a1,0x20
    800035d8:	058a                	slli	a1,a1,0x2
    800035da:	00b784b3          	add	s1,a5,a1
    800035de:	0004a983          	lw	s3,0(s1)
    800035e2:	04098d63          	beqz	s3,8000363c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800035e6:	8552                	mv	a0,s4
    800035e8:	00000097          	auipc	ra,0x0
    800035ec:	ce6080e7          	jalr	-794(ra) # 800032ce <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035f0:	854e                	mv	a0,s3
    800035f2:	70a2                	ld	ra,40(sp)
    800035f4:	7402                	ld	s0,32(sp)
    800035f6:	64e2                	ld	s1,24(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	6a02                	ld	s4,0(sp)
    800035fe:	6145                	addi	sp,sp,48
    80003600:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003602:	02059493          	slli	s1,a1,0x20
    80003606:	9081                	srli	s1,s1,0x20
    80003608:	048a                	slli	s1,s1,0x2
    8000360a:	94aa                	add	s1,s1,a0
    8000360c:	0584a983          	lw	s3,88(s1)
    80003610:	fe0990e3          	bnez	s3,800035f0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003614:	4108                	lw	a0,0(a0)
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	e4a080e7          	jalr	-438(ra) # 80003460 <balloc>
    8000361e:	0005099b          	sext.w	s3,a0
    80003622:	0534ac23          	sw	s3,88(s1)
    80003626:	b7e9                	j	800035f0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003628:	4108                	lw	a0,0(a0)
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	e36080e7          	jalr	-458(ra) # 80003460 <balloc>
    80003632:	0005059b          	sext.w	a1,a0
    80003636:	08b92423          	sw	a1,136(s2)
    8000363a:	b759                	j	800035c0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000363c:	00092503          	lw	a0,0(s2)
    80003640:	00000097          	auipc	ra,0x0
    80003644:	e20080e7          	jalr	-480(ra) # 80003460 <balloc>
    80003648:	0005099b          	sext.w	s3,a0
    8000364c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003650:	8552                	mv	a0,s4
    80003652:	00001097          	auipc	ra,0x1
    80003656:	ee6080e7          	jalr	-282(ra) # 80004538 <log_write>
    8000365a:	b771                	j	800035e6 <bmap+0x54>
  panic("bmap: out of range");
    8000365c:	00006517          	auipc	a0,0x6
    80003660:	4e450513          	addi	a0,a0,1252 # 80009b40 <syscalls+0x128>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	f00080e7          	jalr	-256(ra) # 80000564 <panic>

000000008000366c <iget>:
{
    8000366c:	7179                	addi	sp,sp,-48
    8000366e:	f406                	sd	ra,40(sp)
    80003670:	f022                	sd	s0,32(sp)
    80003672:	ec26                	sd	s1,24(sp)
    80003674:	e84a                	sd	s2,16(sp)
    80003676:	e44e                	sd	s3,8(sp)
    80003678:	e052                	sd	s4,0(sp)
    8000367a:	1800                	addi	s0,sp,48
    8000367c:	89aa                	mv	s3,a0
    8000367e:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003680:	00032517          	auipc	a0,0x32
    80003684:	e8850513          	addi	a0,a0,-376 # 80035508 <icache>
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	50a080e7          	jalr	1290(ra) # 80000b92 <acquire>
  empty = 0;
    80003690:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003692:	00032497          	auipc	s1,0x32
    80003696:	e9648493          	addi	s1,s1,-362 # 80035528 <icache+0x20>
    8000369a:	00034697          	auipc	a3,0x34
    8000369e:	aae68693          	addi	a3,a3,-1362 # 80037148 <log>
    800036a2:	a039                	j	800036b0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036a4:	02090b63          	beqz	s2,800036da <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036a8:	09048493          	addi	s1,s1,144
    800036ac:	02d48a63          	beq	s1,a3,800036e0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800036b0:	449c                	lw	a5,8(s1)
    800036b2:	fef059e3          	blez	a5,800036a4 <iget+0x38>
    800036b6:	4098                	lw	a4,0(s1)
    800036b8:	ff3716e3          	bne	a4,s3,800036a4 <iget+0x38>
    800036bc:	40d8                	lw	a4,4(s1)
    800036be:	ff4713e3          	bne	a4,s4,800036a4 <iget+0x38>
      ip->ref++;
    800036c2:	2785                	addiw	a5,a5,1
    800036c4:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800036c6:	00032517          	auipc	a0,0x32
    800036ca:	e4250513          	addi	a0,a0,-446 # 80035508 <icache>
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	594080e7          	jalr	1428(ra) # 80000c62 <release>
      return ip;
    800036d6:	8926                	mv	s2,s1
    800036d8:	a03d                	j	80003706 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036da:	f7f9                	bnez	a5,800036a8 <iget+0x3c>
    800036dc:	8926                	mv	s2,s1
    800036de:	b7e9                	j	800036a8 <iget+0x3c>
  if(empty == 0)
    800036e0:	02090c63          	beqz	s2,80003718 <iget+0xac>
  ip->dev = dev;
    800036e4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036e8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036ec:	4785                	li	a5,1
    800036ee:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036f2:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800036f6:	00032517          	auipc	a0,0x32
    800036fa:	e1250513          	addi	a0,a0,-494 # 80035508 <icache>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	564080e7          	jalr	1380(ra) # 80000c62 <release>
}
    80003706:	854a                	mv	a0,s2
    80003708:	70a2                	ld	ra,40(sp)
    8000370a:	7402                	ld	s0,32(sp)
    8000370c:	64e2                	ld	s1,24(sp)
    8000370e:	6942                	ld	s2,16(sp)
    80003710:	69a2                	ld	s3,8(sp)
    80003712:	6a02                	ld	s4,0(sp)
    80003714:	6145                	addi	sp,sp,48
    80003716:	8082                	ret
    panic("iget: no inodes");
    80003718:	00006517          	auipc	a0,0x6
    8000371c:	44050513          	addi	a0,a0,1088 # 80009b58 <syscalls+0x140>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	e44080e7          	jalr	-444(ra) # 80000564 <panic>

0000000080003728 <fsinit>:
fsinit(int dev) {
    80003728:	7179                	addi	sp,sp,-48
    8000372a:	f406                	sd	ra,40(sp)
    8000372c:	f022                	sd	s0,32(sp)
    8000372e:	ec26                	sd	s1,24(sp)
    80003730:	e84a                	sd	s2,16(sp)
    80003732:	e44e                	sd	s3,8(sp)
    80003734:	1800                	addi	s0,sp,48
    80003736:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003738:	4585                	li	a1,1
    8000373a:	00000097          	auipc	ra,0x0
    8000373e:	a64080e7          	jalr	-1436(ra) # 8000319e <bread>
    80003742:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003744:	00032997          	auipc	s3,0x32
    80003748:	da498993          	addi	s3,s3,-604 # 800354e8 <sb>
    8000374c:	02000613          	li	a2,32
    80003750:	06050593          	addi	a1,a0,96
    80003754:	854e                	mv	a0,s3
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	77c080e7          	jalr	1916(ra) # 80000ed2 <memmove>
  brelse(bp);
    8000375e:	8526                	mv	a0,s1
    80003760:	00000097          	auipc	ra,0x0
    80003764:	b6e080e7          	jalr	-1170(ra) # 800032ce <brelse>
  if(sb.magic != FSMAGIC)
    80003768:	0009a703          	lw	a4,0(s3)
    8000376c:	102037b7          	lui	a5,0x10203
    80003770:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003774:	02f71263          	bne	a4,a5,80003798 <fsinit+0x70>
  initlog(dev, &sb);
    80003778:	00032597          	auipc	a1,0x32
    8000377c:	d7058593          	addi	a1,a1,-656 # 800354e8 <sb>
    80003780:	854a                	mv	a0,s2
    80003782:	00001097          	auipc	ra,0x1
    80003786:	b3e080e7          	jalr	-1218(ra) # 800042c0 <initlog>
}
    8000378a:	70a2                	ld	ra,40(sp)
    8000378c:	7402                	ld	s0,32(sp)
    8000378e:	64e2                	ld	s1,24(sp)
    80003790:	6942                	ld	s2,16(sp)
    80003792:	69a2                	ld	s3,8(sp)
    80003794:	6145                	addi	sp,sp,48
    80003796:	8082                	ret
    panic("invalid file system");
    80003798:	00006517          	auipc	a0,0x6
    8000379c:	3d050513          	addi	a0,a0,976 # 80009b68 <syscalls+0x150>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	dc4080e7          	jalr	-572(ra) # 80000564 <panic>

00000000800037a8 <iinit>:
{
    800037a8:	7179                	addi	sp,sp,-48
    800037aa:	f406                	sd	ra,40(sp)
    800037ac:	f022                	sd	s0,32(sp)
    800037ae:	ec26                	sd	s1,24(sp)
    800037b0:	e84a                	sd	s2,16(sp)
    800037b2:	e44e                	sd	s3,8(sp)
    800037b4:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800037b6:	00006597          	auipc	a1,0x6
    800037ba:	3ca58593          	addi	a1,a1,970 # 80009b80 <syscalls+0x168>
    800037be:	00032517          	auipc	a0,0x32
    800037c2:	d4a50513          	addi	a0,a0,-694 # 80035508 <icache>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	2f6080e7          	jalr	758(ra) # 80000abc <initlock>
  for(i = 0; i < NINODE; i++) {
    800037ce:	00032497          	auipc	s1,0x32
    800037d2:	d6a48493          	addi	s1,s1,-662 # 80035538 <icache+0x30>
    800037d6:	00034997          	auipc	s3,0x34
    800037da:	98298993          	addi	s3,s3,-1662 # 80037158 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800037de:	00006917          	auipc	s2,0x6
    800037e2:	3aa90913          	addi	s2,s2,938 # 80009b88 <syscalls+0x170>
    800037e6:	85ca                	mv	a1,s2
    800037e8:	8526                	mv	a0,s1
    800037ea:	00001097          	auipc	ra,0x1
    800037ee:	e34080e7          	jalr	-460(ra) # 8000461e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037f2:	09048493          	addi	s1,s1,144
    800037f6:	ff3498e3          	bne	s1,s3,800037e6 <iinit+0x3e>
}
    800037fa:	70a2                	ld	ra,40(sp)
    800037fc:	7402                	ld	s0,32(sp)
    800037fe:	64e2                	ld	s1,24(sp)
    80003800:	6942                	ld	s2,16(sp)
    80003802:	69a2                	ld	s3,8(sp)
    80003804:	6145                	addi	sp,sp,48
    80003806:	8082                	ret

0000000080003808 <ialloc>:
{
    80003808:	715d                	addi	sp,sp,-80
    8000380a:	e486                	sd	ra,72(sp)
    8000380c:	e0a2                	sd	s0,64(sp)
    8000380e:	fc26                	sd	s1,56(sp)
    80003810:	f84a                	sd	s2,48(sp)
    80003812:	f44e                	sd	s3,40(sp)
    80003814:	f052                	sd	s4,32(sp)
    80003816:	ec56                	sd	s5,24(sp)
    80003818:	e85a                	sd	s6,16(sp)
    8000381a:	e45e                	sd	s7,8(sp)
    8000381c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000381e:	00032717          	auipc	a4,0x32
    80003822:	cd672703          	lw	a4,-810(a4) # 800354f4 <sb+0xc>
    80003826:	4785                	li	a5,1
    80003828:	04e7fa63          	bgeu	a5,a4,8000387c <ialloc+0x74>
    8000382c:	8aaa                	mv	s5,a0
    8000382e:	8bae                	mv	s7,a1
    80003830:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003832:	00032a17          	auipc	s4,0x32
    80003836:	cb6a0a13          	addi	s4,s4,-842 # 800354e8 <sb>
    8000383a:	00048b1b          	sext.w	s6,s1
    8000383e:	0044d793          	srli	a5,s1,0x4
    80003842:	018a2583          	lw	a1,24(s4)
    80003846:	9dbd                	addw	a1,a1,a5
    80003848:	8556                	mv	a0,s5
    8000384a:	00000097          	auipc	ra,0x0
    8000384e:	954080e7          	jalr	-1708(ra) # 8000319e <bread>
    80003852:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003854:	06050993          	addi	s3,a0,96
    80003858:	00f4f793          	andi	a5,s1,15
    8000385c:	079a                	slli	a5,a5,0x6
    8000385e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003860:	00099783          	lh	a5,0(s3)
    80003864:	c785                	beqz	a5,8000388c <ialloc+0x84>
    brelse(bp);
    80003866:	00000097          	auipc	ra,0x0
    8000386a:	a68080e7          	jalr	-1432(ra) # 800032ce <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000386e:	0485                	addi	s1,s1,1
    80003870:	00ca2703          	lw	a4,12(s4)
    80003874:	0004879b          	sext.w	a5,s1
    80003878:	fce7e1e3          	bltu	a5,a4,8000383a <ialloc+0x32>
  panic("ialloc: no inodes");
    8000387c:	00006517          	auipc	a0,0x6
    80003880:	31450513          	addi	a0,a0,788 # 80009b90 <syscalls+0x178>
    80003884:	ffffd097          	auipc	ra,0xffffd
    80003888:	ce0080e7          	jalr	-800(ra) # 80000564 <panic>
      memset(dip, 0, sizeof(*dip));
    8000388c:	04000613          	li	a2,64
    80003890:	4581                	li	a1,0
    80003892:	854e                	mv	a0,s3
    80003894:	ffffd097          	auipc	ra,0xffffd
    80003898:	5e2080e7          	jalr	1506(ra) # 80000e76 <memset>
      dip->type = type;
    8000389c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038a0:	854a                	mv	a0,s2
    800038a2:	00001097          	auipc	ra,0x1
    800038a6:	c96080e7          	jalr	-874(ra) # 80004538 <log_write>
      brelse(bp);
    800038aa:	854a                	mv	a0,s2
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	a22080e7          	jalr	-1502(ra) # 800032ce <brelse>
      return iget(dev, inum);
    800038b4:	85da                	mv	a1,s6
    800038b6:	8556                	mv	a0,s5
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	db4080e7          	jalr	-588(ra) # 8000366c <iget>
}
    800038c0:	60a6                	ld	ra,72(sp)
    800038c2:	6406                	ld	s0,64(sp)
    800038c4:	74e2                	ld	s1,56(sp)
    800038c6:	7942                	ld	s2,48(sp)
    800038c8:	79a2                	ld	s3,40(sp)
    800038ca:	7a02                	ld	s4,32(sp)
    800038cc:	6ae2                	ld	s5,24(sp)
    800038ce:	6b42                	ld	s6,16(sp)
    800038d0:	6ba2                	ld	s7,8(sp)
    800038d2:	6161                	addi	sp,sp,80
    800038d4:	8082                	ret

00000000800038d6 <iupdate>:
{
    800038d6:	1101                	addi	sp,sp,-32
    800038d8:	ec06                	sd	ra,24(sp)
    800038da:	e822                	sd	s0,16(sp)
    800038dc:	e426                	sd	s1,8(sp)
    800038de:	e04a                	sd	s2,0(sp)
    800038e0:	1000                	addi	s0,sp,32
    800038e2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038e4:	415c                	lw	a5,4(a0)
    800038e6:	0047d79b          	srliw	a5,a5,0x4
    800038ea:	00032597          	auipc	a1,0x32
    800038ee:	c165a583          	lw	a1,-1002(a1) # 80035500 <sb+0x18>
    800038f2:	9dbd                	addw	a1,a1,a5
    800038f4:	4108                	lw	a0,0(a0)
    800038f6:	00000097          	auipc	ra,0x0
    800038fa:	8a8080e7          	jalr	-1880(ra) # 8000319e <bread>
    800038fe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003900:	06050793          	addi	a5,a0,96
    80003904:	40c8                	lw	a0,4(s1)
    80003906:	893d                	andi	a0,a0,15
    80003908:	051a                	slli	a0,a0,0x6
    8000390a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000390c:	04c49703          	lh	a4,76(s1)
    80003910:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003914:	04e49703          	lh	a4,78(s1)
    80003918:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000391c:	05049703          	lh	a4,80(s1)
    80003920:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003924:	05249703          	lh	a4,82(s1)
    80003928:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000392c:	48f8                	lw	a4,84(s1)
    8000392e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003930:	03400613          	li	a2,52
    80003934:	05848593          	addi	a1,s1,88
    80003938:	0531                	addi	a0,a0,12
    8000393a:	ffffd097          	auipc	ra,0xffffd
    8000393e:	598080e7          	jalr	1432(ra) # 80000ed2 <memmove>
  log_write(bp);
    80003942:	854a                	mv	a0,s2
    80003944:	00001097          	auipc	ra,0x1
    80003948:	bf4080e7          	jalr	-1036(ra) # 80004538 <log_write>
  brelse(bp);
    8000394c:	854a                	mv	a0,s2
    8000394e:	00000097          	auipc	ra,0x0
    80003952:	980080e7          	jalr	-1664(ra) # 800032ce <brelse>
}
    80003956:	60e2                	ld	ra,24(sp)
    80003958:	6442                	ld	s0,16(sp)
    8000395a:	64a2                	ld	s1,8(sp)
    8000395c:	6902                	ld	s2,0(sp)
    8000395e:	6105                	addi	sp,sp,32
    80003960:	8082                	ret

0000000080003962 <idup>:
{
    80003962:	1101                	addi	sp,sp,-32
    80003964:	ec06                	sd	ra,24(sp)
    80003966:	e822                	sd	s0,16(sp)
    80003968:	e426                	sd	s1,8(sp)
    8000396a:	1000                	addi	s0,sp,32
    8000396c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000396e:	00032517          	auipc	a0,0x32
    80003972:	b9a50513          	addi	a0,a0,-1126 # 80035508 <icache>
    80003976:	ffffd097          	auipc	ra,0xffffd
    8000397a:	21c080e7          	jalr	540(ra) # 80000b92 <acquire>
  ip->ref++;
    8000397e:	449c                	lw	a5,8(s1)
    80003980:	2785                	addiw	a5,a5,1
    80003982:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003984:	00032517          	auipc	a0,0x32
    80003988:	b8450513          	addi	a0,a0,-1148 # 80035508 <icache>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	2d6080e7          	jalr	726(ra) # 80000c62 <release>
}
    80003994:	8526                	mv	a0,s1
    80003996:	60e2                	ld	ra,24(sp)
    80003998:	6442                	ld	s0,16(sp)
    8000399a:	64a2                	ld	s1,8(sp)
    8000399c:	6105                	addi	sp,sp,32
    8000399e:	8082                	ret

00000000800039a0 <ilock>:
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	e04a                	sd	s2,0(sp)
    800039aa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800039ac:	c115                	beqz	a0,800039d0 <ilock+0x30>
    800039ae:	84aa                	mv	s1,a0
    800039b0:	451c                	lw	a5,8(a0)
    800039b2:	00f05f63          	blez	a5,800039d0 <ilock+0x30>
  acquiresleep(&ip->lock);
    800039b6:	0541                	addi	a0,a0,16
    800039b8:	00001097          	auipc	ra,0x1
    800039bc:	ca0080e7          	jalr	-864(ra) # 80004658 <acquiresleep>
  if(ip->valid == 0){
    800039c0:	44bc                	lw	a5,72(s1)
    800039c2:	cf99                	beqz	a5,800039e0 <ilock+0x40>
}
    800039c4:	60e2                	ld	ra,24(sp)
    800039c6:	6442                	ld	s0,16(sp)
    800039c8:	64a2                	ld	s1,8(sp)
    800039ca:	6902                	ld	s2,0(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret
    panic("ilock");
    800039d0:	00006517          	auipc	a0,0x6
    800039d4:	1d850513          	addi	a0,a0,472 # 80009ba8 <syscalls+0x190>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	b8c080e7          	jalr	-1140(ra) # 80000564 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039e0:	40dc                	lw	a5,4(s1)
    800039e2:	0047d79b          	srliw	a5,a5,0x4
    800039e6:	00032597          	auipc	a1,0x32
    800039ea:	b1a5a583          	lw	a1,-1254(a1) # 80035500 <sb+0x18>
    800039ee:	9dbd                	addw	a1,a1,a5
    800039f0:	4088                	lw	a0,0(s1)
    800039f2:	fffff097          	auipc	ra,0xfffff
    800039f6:	7ac080e7          	jalr	1964(ra) # 8000319e <bread>
    800039fa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039fc:	06050593          	addi	a1,a0,96
    80003a00:	40dc                	lw	a5,4(s1)
    80003a02:	8bbd                	andi	a5,a5,15
    80003a04:	079a                	slli	a5,a5,0x6
    80003a06:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a08:	00059783          	lh	a5,0(a1)
    80003a0c:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003a10:	00259783          	lh	a5,2(a1)
    80003a14:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003a18:	00459783          	lh	a5,4(a1)
    80003a1c:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a20:	00659783          	lh	a5,6(a1)
    80003a24:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a28:	459c                	lw	a5,8(a1)
    80003a2a:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a2c:	03400613          	li	a2,52
    80003a30:	05b1                	addi	a1,a1,12
    80003a32:	05848513          	addi	a0,s1,88
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	49c080e7          	jalr	1180(ra) # 80000ed2 <memmove>
    brelse(bp);
    80003a3e:	854a                	mv	a0,s2
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	88e080e7          	jalr	-1906(ra) # 800032ce <brelse>
    ip->valid = 1;
    80003a48:	4785                	li	a5,1
    80003a4a:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003a4c:	04c49783          	lh	a5,76(s1)
    80003a50:	fbb5                	bnez	a5,800039c4 <ilock+0x24>
      panic("ilock: no type");
    80003a52:	00006517          	auipc	a0,0x6
    80003a56:	15e50513          	addi	a0,a0,350 # 80009bb0 <syscalls+0x198>
    80003a5a:	ffffd097          	auipc	ra,0xffffd
    80003a5e:	b0a080e7          	jalr	-1270(ra) # 80000564 <panic>

0000000080003a62 <iunlock>:
{
    80003a62:	1101                	addi	sp,sp,-32
    80003a64:	ec06                	sd	ra,24(sp)
    80003a66:	e822                	sd	s0,16(sp)
    80003a68:	e426                	sd	s1,8(sp)
    80003a6a:	e04a                	sd	s2,0(sp)
    80003a6c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a6e:	c905                	beqz	a0,80003a9e <iunlock+0x3c>
    80003a70:	84aa                	mv	s1,a0
    80003a72:	01050913          	addi	s2,a0,16
    80003a76:	854a                	mv	a0,s2
    80003a78:	00001097          	auipc	ra,0x1
    80003a7c:	c7a080e7          	jalr	-902(ra) # 800046f2 <holdingsleep>
    80003a80:	cd19                	beqz	a0,80003a9e <iunlock+0x3c>
    80003a82:	449c                	lw	a5,8(s1)
    80003a84:	00f05d63          	blez	a5,80003a9e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a88:	854a                	mv	a0,s2
    80003a8a:	00001097          	auipc	ra,0x1
    80003a8e:	c24080e7          	jalr	-988(ra) # 800046ae <releasesleep>
}
    80003a92:	60e2                	ld	ra,24(sp)
    80003a94:	6442                	ld	s0,16(sp)
    80003a96:	64a2                	ld	s1,8(sp)
    80003a98:	6902                	ld	s2,0(sp)
    80003a9a:	6105                	addi	sp,sp,32
    80003a9c:	8082                	ret
    panic("iunlock");
    80003a9e:	00006517          	auipc	a0,0x6
    80003aa2:	12250513          	addi	a0,a0,290 # 80009bc0 <syscalls+0x1a8>
    80003aa6:	ffffd097          	auipc	ra,0xffffd
    80003aaa:	abe080e7          	jalr	-1346(ra) # 80000564 <panic>

0000000080003aae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003aae:	7179                	addi	sp,sp,-48
    80003ab0:	f406                	sd	ra,40(sp)
    80003ab2:	f022                	sd	s0,32(sp)
    80003ab4:	ec26                	sd	s1,24(sp)
    80003ab6:	e84a                	sd	s2,16(sp)
    80003ab8:	e44e                	sd	s3,8(sp)
    80003aba:	e052                	sd	s4,0(sp)
    80003abc:	1800                	addi	s0,sp,48
    80003abe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ac0:	05850493          	addi	s1,a0,88
    80003ac4:	08850913          	addi	s2,a0,136
    80003ac8:	a021                	j	80003ad0 <itrunc+0x22>
    80003aca:	0491                	addi	s1,s1,4
    80003acc:	01248d63          	beq	s1,s2,80003ae6 <itrunc+0x38>
    if(ip->addrs[i]){
    80003ad0:	408c                	lw	a1,0(s1)
    80003ad2:	dde5                	beqz	a1,80003aca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ad4:	0009a503          	lw	a0,0(s3)
    80003ad8:	00000097          	auipc	ra,0x0
    80003adc:	90c080e7          	jalr	-1780(ra) # 800033e4 <bfree>
      ip->addrs[i] = 0;
    80003ae0:	0004a023          	sw	zero,0(s1)
    80003ae4:	b7dd                	j	80003aca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ae6:	0889a583          	lw	a1,136(s3)
    80003aea:	e185                	bnez	a1,80003b0a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003aec:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003af0:	854e                	mv	a0,s3
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	de4080e7          	jalr	-540(ra) # 800038d6 <iupdate>
}
    80003afa:	70a2                	ld	ra,40(sp)
    80003afc:	7402                	ld	s0,32(sp)
    80003afe:	64e2                	ld	s1,24(sp)
    80003b00:	6942                	ld	s2,16(sp)
    80003b02:	69a2                	ld	s3,8(sp)
    80003b04:	6a02                	ld	s4,0(sp)
    80003b06:	6145                	addi	sp,sp,48
    80003b08:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b0a:	0009a503          	lw	a0,0(s3)
    80003b0e:	fffff097          	auipc	ra,0xfffff
    80003b12:	690080e7          	jalr	1680(ra) # 8000319e <bread>
    80003b16:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b18:	06050493          	addi	s1,a0,96
    80003b1c:	46050913          	addi	s2,a0,1120
    80003b20:	a021                	j	80003b28 <itrunc+0x7a>
    80003b22:	0491                	addi	s1,s1,4
    80003b24:	01248b63          	beq	s1,s2,80003b3a <itrunc+0x8c>
      if(a[j])
    80003b28:	408c                	lw	a1,0(s1)
    80003b2a:	dde5                	beqz	a1,80003b22 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b2c:	0009a503          	lw	a0,0(s3)
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	8b4080e7          	jalr	-1868(ra) # 800033e4 <bfree>
    80003b38:	b7ed                	j	80003b22 <itrunc+0x74>
    brelse(bp);
    80003b3a:	8552                	mv	a0,s4
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	792080e7          	jalr	1938(ra) # 800032ce <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b44:	0889a583          	lw	a1,136(s3)
    80003b48:	0009a503          	lw	a0,0(s3)
    80003b4c:	00000097          	auipc	ra,0x0
    80003b50:	898080e7          	jalr	-1896(ra) # 800033e4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b54:	0809a423          	sw	zero,136(s3)
    80003b58:	bf51                	j	80003aec <itrunc+0x3e>

0000000080003b5a <iput>:
{
    80003b5a:	1101                	addi	sp,sp,-32
    80003b5c:	ec06                	sd	ra,24(sp)
    80003b5e:	e822                	sd	s0,16(sp)
    80003b60:	e426                	sd	s1,8(sp)
    80003b62:	e04a                	sd	s2,0(sp)
    80003b64:	1000                	addi	s0,sp,32
    80003b66:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b68:	00032517          	auipc	a0,0x32
    80003b6c:	9a050513          	addi	a0,a0,-1632 # 80035508 <icache>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	022080e7          	jalr	34(ra) # 80000b92 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b78:	4498                	lw	a4,8(s1)
    80003b7a:	4785                	li	a5,1
    80003b7c:	02f70363          	beq	a4,a5,80003ba2 <iput+0x48>
  ip->ref--;
    80003b80:	449c                	lw	a5,8(s1)
    80003b82:	37fd                	addiw	a5,a5,-1
    80003b84:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b86:	00032517          	auipc	a0,0x32
    80003b8a:	98250513          	addi	a0,a0,-1662 # 80035508 <icache>
    80003b8e:	ffffd097          	auipc	ra,0xffffd
    80003b92:	0d4080e7          	jalr	212(ra) # 80000c62 <release>
}
    80003b96:	60e2                	ld	ra,24(sp)
    80003b98:	6442                	ld	s0,16(sp)
    80003b9a:	64a2                	ld	s1,8(sp)
    80003b9c:	6902                	ld	s2,0(sp)
    80003b9e:	6105                	addi	sp,sp,32
    80003ba0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ba2:	44bc                	lw	a5,72(s1)
    80003ba4:	dff1                	beqz	a5,80003b80 <iput+0x26>
    80003ba6:	05249783          	lh	a5,82(s1)
    80003baa:	fbf9                	bnez	a5,80003b80 <iput+0x26>
    acquiresleep(&ip->lock);
    80003bac:	01048913          	addi	s2,s1,16
    80003bb0:	854a                	mv	a0,s2
    80003bb2:	00001097          	auipc	ra,0x1
    80003bb6:	aa6080e7          	jalr	-1370(ra) # 80004658 <acquiresleep>
    release(&icache.lock);
    80003bba:	00032517          	auipc	a0,0x32
    80003bbe:	94e50513          	addi	a0,a0,-1714 # 80035508 <icache>
    80003bc2:	ffffd097          	auipc	ra,0xffffd
    80003bc6:	0a0080e7          	jalr	160(ra) # 80000c62 <release>
    itrunc(ip);
    80003bca:	8526                	mv	a0,s1
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	ee2080e7          	jalr	-286(ra) # 80003aae <itrunc>
    ip->type = 0;
    80003bd4:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003bd8:	8526                	mv	a0,s1
    80003bda:	00000097          	auipc	ra,0x0
    80003bde:	cfc080e7          	jalr	-772(ra) # 800038d6 <iupdate>
    ip->valid = 0;
    80003be2:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003be6:	854a                	mv	a0,s2
    80003be8:	00001097          	auipc	ra,0x1
    80003bec:	ac6080e7          	jalr	-1338(ra) # 800046ae <releasesleep>
    acquire(&icache.lock);
    80003bf0:	00032517          	auipc	a0,0x32
    80003bf4:	91850513          	addi	a0,a0,-1768 # 80035508 <icache>
    80003bf8:	ffffd097          	auipc	ra,0xffffd
    80003bfc:	f9a080e7          	jalr	-102(ra) # 80000b92 <acquire>
    80003c00:	b741                	j	80003b80 <iput+0x26>

0000000080003c02 <iunlockput>:
{
    80003c02:	1101                	addi	sp,sp,-32
    80003c04:	ec06                	sd	ra,24(sp)
    80003c06:	e822                	sd	s0,16(sp)
    80003c08:	e426                	sd	s1,8(sp)
    80003c0a:	1000                	addi	s0,sp,32
    80003c0c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c0e:	00000097          	auipc	ra,0x0
    80003c12:	e54080e7          	jalr	-428(ra) # 80003a62 <iunlock>
  iput(ip);
    80003c16:	8526                	mv	a0,s1
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	f42080e7          	jalr	-190(ra) # 80003b5a <iput>
}
    80003c20:	60e2                	ld	ra,24(sp)
    80003c22:	6442                	ld	s0,16(sp)
    80003c24:	64a2                	ld	s1,8(sp)
    80003c26:	6105                	addi	sp,sp,32
    80003c28:	8082                	ret

0000000080003c2a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c2a:	1141                	addi	sp,sp,-16
    80003c2c:	e422                	sd	s0,8(sp)
    80003c2e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c30:	411c                	lw	a5,0(a0)
    80003c32:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c34:	415c                	lw	a5,4(a0)
    80003c36:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c38:	04c51783          	lh	a5,76(a0)
    80003c3c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c40:	05251783          	lh	a5,82(a0)
    80003c44:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c48:	05456783          	lwu	a5,84(a0)
    80003c4c:	e99c                	sd	a5,16(a1)
}
    80003c4e:	6422                	ld	s0,8(sp)
    80003c50:	0141                	addi	sp,sp,16
    80003c52:	8082                	ret

0000000080003c54 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c54:	497c                	lw	a5,84(a0)
    80003c56:	0ed7e963          	bltu	a5,a3,80003d48 <readi+0xf4>
{
    80003c5a:	7159                	addi	sp,sp,-112
    80003c5c:	f486                	sd	ra,104(sp)
    80003c5e:	f0a2                	sd	s0,96(sp)
    80003c60:	eca6                	sd	s1,88(sp)
    80003c62:	e8ca                	sd	s2,80(sp)
    80003c64:	e4ce                	sd	s3,72(sp)
    80003c66:	e0d2                	sd	s4,64(sp)
    80003c68:	fc56                	sd	s5,56(sp)
    80003c6a:	f85a                	sd	s6,48(sp)
    80003c6c:	f45e                	sd	s7,40(sp)
    80003c6e:	f062                	sd	s8,32(sp)
    80003c70:	ec66                	sd	s9,24(sp)
    80003c72:	e86a                	sd	s10,16(sp)
    80003c74:	e46e                	sd	s11,8(sp)
    80003c76:	1880                	addi	s0,sp,112
    80003c78:	8baa                	mv	s7,a0
    80003c7a:	8c2e                	mv	s8,a1
    80003c7c:	8ab2                	mv	s5,a2
    80003c7e:	84b6                	mv	s1,a3
    80003c80:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c82:	9f35                	addw	a4,a4,a3
    return 0;
    80003c84:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c86:	0ad76063          	bltu	a4,a3,80003d26 <readi+0xd2>
  if(off + n > ip->size)
    80003c8a:	00e7f463          	bgeu	a5,a4,80003c92 <readi+0x3e>
    n = ip->size - off;
    80003c8e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c92:	0a0b0963          	beqz	s6,80003d44 <readi+0xf0>
    80003c96:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c98:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c9c:	5cfd                	li	s9,-1
    80003c9e:	a82d                	j	80003cd8 <readi+0x84>
    80003ca0:	020a1d93          	slli	s11,s4,0x20
    80003ca4:	020ddd93          	srli	s11,s11,0x20
    80003ca8:	06090793          	addi	a5,s2,96
    80003cac:	86ee                	mv	a3,s11
    80003cae:	963e                	add	a2,a2,a5
    80003cb0:	85d6                	mv	a1,s5
    80003cb2:	8562                	mv	a0,s8
    80003cb4:	fffff097          	auipc	ra,0xfffff
    80003cb8:	a6c080e7          	jalr	-1428(ra) # 80002720 <either_copyout>
    80003cbc:	05950d63          	beq	a0,s9,80003d16 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	fffff097          	auipc	ra,0xfffff
    80003cc6:	60c080e7          	jalr	1548(ra) # 800032ce <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cca:	013a09bb          	addw	s3,s4,s3
    80003cce:	009a04bb          	addw	s1,s4,s1
    80003cd2:	9aee                	add	s5,s5,s11
    80003cd4:	0569f763          	bgeu	s3,s6,80003d22 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cd8:	000ba903          	lw	s2,0(s7)
    80003cdc:	00a4d59b          	srliw	a1,s1,0xa
    80003ce0:	855e                	mv	a0,s7
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	8b0080e7          	jalr	-1872(ra) # 80003592 <bmap>
    80003cea:	0005059b          	sext.w	a1,a0
    80003cee:	854a                	mv	a0,s2
    80003cf0:	fffff097          	auipc	ra,0xfffff
    80003cf4:	4ae080e7          	jalr	1198(ra) # 8000319e <bread>
    80003cf8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cfa:	3ff4f613          	andi	a2,s1,1023
    80003cfe:	40cd07bb          	subw	a5,s10,a2
    80003d02:	413b073b          	subw	a4,s6,s3
    80003d06:	8a3e                	mv	s4,a5
    80003d08:	2781                	sext.w	a5,a5
    80003d0a:	0007069b          	sext.w	a3,a4
    80003d0e:	f8f6f9e3          	bgeu	a3,a5,80003ca0 <readi+0x4c>
    80003d12:	8a3a                	mv	s4,a4
    80003d14:	b771                	j	80003ca0 <readi+0x4c>
      brelse(bp);
    80003d16:	854a                	mv	a0,s2
    80003d18:	fffff097          	auipc	ra,0xfffff
    80003d1c:	5b6080e7          	jalr	1462(ra) # 800032ce <brelse>
      tot = -1;
    80003d20:	59fd                	li	s3,-1
  }
  return tot;
    80003d22:	0009851b          	sext.w	a0,s3
}
    80003d26:	70a6                	ld	ra,104(sp)
    80003d28:	7406                	ld	s0,96(sp)
    80003d2a:	64e6                	ld	s1,88(sp)
    80003d2c:	6946                	ld	s2,80(sp)
    80003d2e:	69a6                	ld	s3,72(sp)
    80003d30:	6a06                	ld	s4,64(sp)
    80003d32:	7ae2                	ld	s5,56(sp)
    80003d34:	7b42                	ld	s6,48(sp)
    80003d36:	7ba2                	ld	s7,40(sp)
    80003d38:	7c02                	ld	s8,32(sp)
    80003d3a:	6ce2                	ld	s9,24(sp)
    80003d3c:	6d42                	ld	s10,16(sp)
    80003d3e:	6da2                	ld	s11,8(sp)
    80003d40:	6165                	addi	sp,sp,112
    80003d42:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d44:	89da                	mv	s3,s6
    80003d46:	bff1                	j	80003d22 <readi+0xce>
    return 0;
    80003d48:	4501                	li	a0,0
}
    80003d4a:	8082                	ret

0000000080003d4c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d4c:	497c                	lw	a5,84(a0)
    80003d4e:	10d7e863          	bltu	a5,a3,80003e5e <writei+0x112>
{
    80003d52:	7159                	addi	sp,sp,-112
    80003d54:	f486                	sd	ra,104(sp)
    80003d56:	f0a2                	sd	s0,96(sp)
    80003d58:	eca6                	sd	s1,88(sp)
    80003d5a:	e8ca                	sd	s2,80(sp)
    80003d5c:	e4ce                	sd	s3,72(sp)
    80003d5e:	e0d2                	sd	s4,64(sp)
    80003d60:	fc56                	sd	s5,56(sp)
    80003d62:	f85a                	sd	s6,48(sp)
    80003d64:	f45e                	sd	s7,40(sp)
    80003d66:	f062                	sd	s8,32(sp)
    80003d68:	ec66                	sd	s9,24(sp)
    80003d6a:	e86a                	sd	s10,16(sp)
    80003d6c:	e46e                	sd	s11,8(sp)
    80003d6e:	1880                	addi	s0,sp,112
    80003d70:	8b2a                	mv	s6,a0
    80003d72:	8c2e                	mv	s8,a1
    80003d74:	8ab2                	mv	s5,a2
    80003d76:	8936                	mv	s2,a3
    80003d78:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003d7a:	00e687bb          	addw	a5,a3,a4
    80003d7e:	0ed7e263          	bltu	a5,a3,80003e62 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d82:	00043737          	lui	a4,0x43
    80003d86:	0ef76063          	bltu	a4,a5,80003e66 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d8a:	0c0b8863          	beqz	s7,80003e5a <writei+0x10e>
    80003d8e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d90:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d94:	5cfd                	li	s9,-1
    80003d96:	a091                	j	80003dda <writei+0x8e>
    80003d98:	02099d93          	slli	s11,s3,0x20
    80003d9c:	020ddd93          	srli	s11,s11,0x20
    80003da0:	06048793          	addi	a5,s1,96
    80003da4:	86ee                	mv	a3,s11
    80003da6:	8656                	mv	a2,s5
    80003da8:	85e2                	mv	a1,s8
    80003daa:	953e                	add	a0,a0,a5
    80003dac:	fffff097          	auipc	ra,0xfffff
    80003db0:	9ca080e7          	jalr	-1590(ra) # 80002776 <either_copyin>
    80003db4:	07950263          	beq	a0,s9,80003e18 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003db8:	8526                	mv	a0,s1
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	77e080e7          	jalr	1918(ra) # 80004538 <log_write>
    brelse(bp);
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	fffff097          	auipc	ra,0xfffff
    80003dc8:	50a080e7          	jalr	1290(ra) # 800032ce <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dcc:	01498a3b          	addw	s4,s3,s4
    80003dd0:	0129893b          	addw	s2,s3,s2
    80003dd4:	9aee                	add	s5,s5,s11
    80003dd6:	057a7663          	bgeu	s4,s7,80003e22 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003dda:	000b2483          	lw	s1,0(s6)
    80003dde:	00a9559b          	srliw	a1,s2,0xa
    80003de2:	855a                	mv	a0,s6
    80003de4:	fffff097          	auipc	ra,0xfffff
    80003de8:	7ae080e7          	jalr	1966(ra) # 80003592 <bmap>
    80003dec:	0005059b          	sext.w	a1,a0
    80003df0:	8526                	mv	a0,s1
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	3ac080e7          	jalr	940(ra) # 8000319e <bread>
    80003dfa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dfc:	3ff97513          	andi	a0,s2,1023
    80003e00:	40ad07bb          	subw	a5,s10,a0
    80003e04:	414b873b          	subw	a4,s7,s4
    80003e08:	89be                	mv	s3,a5
    80003e0a:	2781                	sext.w	a5,a5
    80003e0c:	0007069b          	sext.w	a3,a4
    80003e10:	f8f6f4e3          	bgeu	a3,a5,80003d98 <writei+0x4c>
    80003e14:	89ba                	mv	s3,a4
    80003e16:	b749                	j	80003d98 <writei+0x4c>
      brelse(bp);
    80003e18:	8526                	mv	a0,s1
    80003e1a:	fffff097          	auipc	ra,0xfffff
    80003e1e:	4b4080e7          	jalr	1204(ra) # 800032ce <brelse>
  }

  if(off > ip->size)
    80003e22:	054b2783          	lw	a5,84(s6)
    80003e26:	0127f463          	bgeu	a5,s2,80003e2e <writei+0xe2>
    ip->size = off;
    80003e2a:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e2e:	855a                	mv	a0,s6
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	aa6080e7          	jalr	-1370(ra) # 800038d6 <iupdate>

  return tot;
    80003e38:	000a051b          	sext.w	a0,s4
}
    80003e3c:	70a6                	ld	ra,104(sp)
    80003e3e:	7406                	ld	s0,96(sp)
    80003e40:	64e6                	ld	s1,88(sp)
    80003e42:	6946                	ld	s2,80(sp)
    80003e44:	69a6                	ld	s3,72(sp)
    80003e46:	6a06                	ld	s4,64(sp)
    80003e48:	7ae2                	ld	s5,56(sp)
    80003e4a:	7b42                	ld	s6,48(sp)
    80003e4c:	7ba2                	ld	s7,40(sp)
    80003e4e:	7c02                	ld	s8,32(sp)
    80003e50:	6ce2                	ld	s9,24(sp)
    80003e52:	6d42                	ld	s10,16(sp)
    80003e54:	6da2                	ld	s11,8(sp)
    80003e56:	6165                	addi	sp,sp,112
    80003e58:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e5a:	8a5e                	mv	s4,s7
    80003e5c:	bfc9                	j	80003e2e <writei+0xe2>
    return -1;
    80003e5e:	557d                	li	a0,-1
}
    80003e60:	8082                	ret
    return -1;
    80003e62:	557d                	li	a0,-1
    80003e64:	bfe1                	j	80003e3c <writei+0xf0>
    return -1;
    80003e66:	557d                	li	a0,-1
    80003e68:	bfd1                	j	80003e3c <writei+0xf0>

0000000080003e6a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e6a:	1141                	addi	sp,sp,-16
    80003e6c:	e406                	sd	ra,8(sp)
    80003e6e:	e022                	sd	s0,0(sp)
    80003e70:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e72:	4639                	li	a2,14
    80003e74:	ffffd097          	auipc	ra,0xffffd
    80003e78:	0fe080e7          	jalr	254(ra) # 80000f72 <strncmp>
}
    80003e7c:	60a2                	ld	ra,8(sp)
    80003e7e:	6402                	ld	s0,0(sp)
    80003e80:	0141                	addi	sp,sp,16
    80003e82:	8082                	ret

0000000080003e84 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e84:	7139                	addi	sp,sp,-64
    80003e86:	fc06                	sd	ra,56(sp)
    80003e88:	f822                	sd	s0,48(sp)
    80003e8a:	f426                	sd	s1,40(sp)
    80003e8c:	f04a                	sd	s2,32(sp)
    80003e8e:	ec4e                	sd	s3,24(sp)
    80003e90:	e852                	sd	s4,16(sp)
    80003e92:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e94:	04c51703          	lh	a4,76(a0)
    80003e98:	4785                	li	a5,1
    80003e9a:	00f71a63          	bne	a4,a5,80003eae <dirlookup+0x2a>
    80003e9e:	892a                	mv	s2,a0
    80003ea0:	89ae                	mv	s3,a1
    80003ea2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea4:	497c                	lw	a5,84(a0)
    80003ea6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ea8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eaa:	e79d                	bnez	a5,80003ed8 <dirlookup+0x54>
    80003eac:	a8a5                	j	80003f24 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003eae:	00006517          	auipc	a0,0x6
    80003eb2:	d1a50513          	addi	a0,a0,-742 # 80009bc8 <syscalls+0x1b0>
    80003eb6:	ffffc097          	auipc	ra,0xffffc
    80003eba:	6ae080e7          	jalr	1710(ra) # 80000564 <panic>
      panic("dirlookup read");
    80003ebe:	00006517          	auipc	a0,0x6
    80003ec2:	d2250513          	addi	a0,a0,-734 # 80009be0 <syscalls+0x1c8>
    80003ec6:	ffffc097          	auipc	ra,0xffffc
    80003eca:	69e080e7          	jalr	1694(ra) # 80000564 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ece:	24c1                	addiw	s1,s1,16
    80003ed0:	05492783          	lw	a5,84(s2)
    80003ed4:	04f4f763          	bgeu	s1,a5,80003f22 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed8:	4741                	li	a4,16
    80003eda:	86a6                	mv	a3,s1
    80003edc:	fc040613          	addi	a2,s0,-64
    80003ee0:	4581                	li	a1,0
    80003ee2:	854a                	mv	a0,s2
    80003ee4:	00000097          	auipc	ra,0x0
    80003ee8:	d70080e7          	jalr	-656(ra) # 80003c54 <readi>
    80003eec:	47c1                	li	a5,16
    80003eee:	fcf518e3          	bne	a0,a5,80003ebe <dirlookup+0x3a>
    if(de.inum == 0)
    80003ef2:	fc045783          	lhu	a5,-64(s0)
    80003ef6:	dfe1                	beqz	a5,80003ece <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ef8:	fc240593          	addi	a1,s0,-62
    80003efc:	854e                	mv	a0,s3
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	f6c080e7          	jalr	-148(ra) # 80003e6a <namecmp>
    80003f06:	f561                	bnez	a0,80003ece <dirlookup+0x4a>
      if(poff)
    80003f08:	000a0463          	beqz	s4,80003f10 <dirlookup+0x8c>
        *poff = off;
    80003f0c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f10:	fc045583          	lhu	a1,-64(s0)
    80003f14:	00092503          	lw	a0,0(s2)
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	754080e7          	jalr	1876(ra) # 8000366c <iget>
    80003f20:	a011                	j	80003f24 <dirlookup+0xa0>
  return 0;
    80003f22:	4501                	li	a0,0
}
    80003f24:	70e2                	ld	ra,56(sp)
    80003f26:	7442                	ld	s0,48(sp)
    80003f28:	74a2                	ld	s1,40(sp)
    80003f2a:	7902                	ld	s2,32(sp)
    80003f2c:	69e2                	ld	s3,24(sp)
    80003f2e:	6a42                	ld	s4,16(sp)
    80003f30:	6121                	addi	sp,sp,64
    80003f32:	8082                	ret

0000000080003f34 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f34:	711d                	addi	sp,sp,-96
    80003f36:	ec86                	sd	ra,88(sp)
    80003f38:	e8a2                	sd	s0,80(sp)
    80003f3a:	e4a6                	sd	s1,72(sp)
    80003f3c:	e0ca                	sd	s2,64(sp)
    80003f3e:	fc4e                	sd	s3,56(sp)
    80003f40:	f852                	sd	s4,48(sp)
    80003f42:	f456                	sd	s5,40(sp)
    80003f44:	f05a                	sd	s6,32(sp)
    80003f46:	ec5e                	sd	s7,24(sp)
    80003f48:	e862                	sd	s8,16(sp)
    80003f4a:	e466                	sd	s9,8(sp)
    80003f4c:	1080                	addi	s0,sp,96
    80003f4e:	84aa                	mv	s1,a0
    80003f50:	8aae                	mv	s5,a1
    80003f52:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f54:	00054703          	lbu	a4,0(a0)
    80003f58:	02f00793          	li	a5,47
    80003f5c:	02f70363          	beq	a4,a5,80003f82 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f60:	ffffe097          	auipc	ra,0xffffe
    80003f64:	bf0080e7          	jalr	-1040(ra) # 80001b50 <myproc>
    80003f68:	15853503          	ld	a0,344(a0)
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	9f6080e7          	jalr	-1546(ra) # 80003962 <idup>
    80003f74:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f76:	02f00913          	li	s2,47
  len = path - s;
    80003f7a:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f7c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f7e:	4b85                	li	s7,1
    80003f80:	a865                	j	80004038 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f82:	4585                	li	a1,1
    80003f84:	4505                	li	a0,1
    80003f86:	fffff097          	auipc	ra,0xfffff
    80003f8a:	6e6080e7          	jalr	1766(ra) # 8000366c <iget>
    80003f8e:	89aa                	mv	s3,a0
    80003f90:	b7dd                	j	80003f76 <namex+0x42>
      iunlockput(ip);
    80003f92:	854e                	mv	a0,s3
    80003f94:	00000097          	auipc	ra,0x0
    80003f98:	c6e080e7          	jalr	-914(ra) # 80003c02 <iunlockput>
      return 0;
    80003f9c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f9e:	854e                	mv	a0,s3
    80003fa0:	60e6                	ld	ra,88(sp)
    80003fa2:	6446                	ld	s0,80(sp)
    80003fa4:	64a6                	ld	s1,72(sp)
    80003fa6:	6906                	ld	s2,64(sp)
    80003fa8:	79e2                	ld	s3,56(sp)
    80003faa:	7a42                	ld	s4,48(sp)
    80003fac:	7aa2                	ld	s5,40(sp)
    80003fae:	7b02                	ld	s6,32(sp)
    80003fb0:	6be2                	ld	s7,24(sp)
    80003fb2:	6c42                	ld	s8,16(sp)
    80003fb4:	6ca2                	ld	s9,8(sp)
    80003fb6:	6125                	addi	sp,sp,96
    80003fb8:	8082                	ret
      iunlock(ip);
    80003fba:	854e                	mv	a0,s3
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	aa6080e7          	jalr	-1370(ra) # 80003a62 <iunlock>
      return ip;
    80003fc4:	bfe9                	j	80003f9e <namex+0x6a>
      iunlockput(ip);
    80003fc6:	854e                	mv	a0,s3
    80003fc8:	00000097          	auipc	ra,0x0
    80003fcc:	c3a080e7          	jalr	-966(ra) # 80003c02 <iunlockput>
      return 0;
    80003fd0:	89e6                	mv	s3,s9
    80003fd2:	b7f1                	j	80003f9e <namex+0x6a>
  len = path - s;
    80003fd4:	40b48633          	sub	a2,s1,a1
    80003fd8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fdc:	099c5463          	bge	s8,s9,80004064 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fe0:	4639                	li	a2,14
    80003fe2:	8552                	mv	a0,s4
    80003fe4:	ffffd097          	auipc	ra,0xffffd
    80003fe8:	eee080e7          	jalr	-274(ra) # 80000ed2 <memmove>
  while(*path == '/')
    80003fec:	0004c783          	lbu	a5,0(s1)
    80003ff0:	01279763          	bne	a5,s2,80003ffe <namex+0xca>
    path++;
    80003ff4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ff6:	0004c783          	lbu	a5,0(s1)
    80003ffa:	ff278de3          	beq	a5,s2,80003ff4 <namex+0xc0>
    ilock(ip);
    80003ffe:	854e                	mv	a0,s3
    80004000:	00000097          	auipc	ra,0x0
    80004004:	9a0080e7          	jalr	-1632(ra) # 800039a0 <ilock>
    if(ip->type != T_DIR){
    80004008:	04c99783          	lh	a5,76(s3)
    8000400c:	f97793e3          	bne	a5,s7,80003f92 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004010:	000a8563          	beqz	s5,8000401a <namex+0xe6>
    80004014:	0004c783          	lbu	a5,0(s1)
    80004018:	d3cd                	beqz	a5,80003fba <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000401a:	865a                	mv	a2,s6
    8000401c:	85d2                	mv	a1,s4
    8000401e:	854e                	mv	a0,s3
    80004020:	00000097          	auipc	ra,0x0
    80004024:	e64080e7          	jalr	-412(ra) # 80003e84 <dirlookup>
    80004028:	8caa                	mv	s9,a0
    8000402a:	dd51                	beqz	a0,80003fc6 <namex+0x92>
    iunlockput(ip);
    8000402c:	854e                	mv	a0,s3
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	bd4080e7          	jalr	-1068(ra) # 80003c02 <iunlockput>
    ip = next;
    80004036:	89e6                	mv	s3,s9
  while(*path == '/')
    80004038:	0004c783          	lbu	a5,0(s1)
    8000403c:	05279763          	bne	a5,s2,8000408a <namex+0x156>
    path++;
    80004040:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004042:	0004c783          	lbu	a5,0(s1)
    80004046:	ff278de3          	beq	a5,s2,80004040 <namex+0x10c>
  if(*path == 0)
    8000404a:	c79d                	beqz	a5,80004078 <namex+0x144>
    path++;
    8000404c:	85a6                	mv	a1,s1
  len = path - s;
    8000404e:	8cda                	mv	s9,s6
    80004050:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004052:	01278963          	beq	a5,s2,80004064 <namex+0x130>
    80004056:	dfbd                	beqz	a5,80003fd4 <namex+0xa0>
    path++;
    80004058:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000405a:	0004c783          	lbu	a5,0(s1)
    8000405e:	ff279ce3          	bne	a5,s2,80004056 <namex+0x122>
    80004062:	bf8d                	j	80003fd4 <namex+0xa0>
    memmove(name, s, len);
    80004064:	2601                	sext.w	a2,a2
    80004066:	8552                	mv	a0,s4
    80004068:	ffffd097          	auipc	ra,0xffffd
    8000406c:	e6a080e7          	jalr	-406(ra) # 80000ed2 <memmove>
    name[len] = 0;
    80004070:	9cd2                	add	s9,s9,s4
    80004072:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004076:	bf9d                	j	80003fec <namex+0xb8>
  if(nameiparent){
    80004078:	f20a83e3          	beqz	s5,80003f9e <namex+0x6a>
    iput(ip);
    8000407c:	854e                	mv	a0,s3
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	adc080e7          	jalr	-1316(ra) # 80003b5a <iput>
    return 0;
    80004086:	4981                	li	s3,0
    80004088:	bf19                	j	80003f9e <namex+0x6a>
  if(*path == 0)
    8000408a:	d7fd                	beqz	a5,80004078 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000408c:	0004c783          	lbu	a5,0(s1)
    80004090:	85a6                	mv	a1,s1
    80004092:	b7d1                	j	80004056 <namex+0x122>

0000000080004094 <dirlink>:
{
    80004094:	7139                	addi	sp,sp,-64
    80004096:	fc06                	sd	ra,56(sp)
    80004098:	f822                	sd	s0,48(sp)
    8000409a:	f426                	sd	s1,40(sp)
    8000409c:	f04a                	sd	s2,32(sp)
    8000409e:	ec4e                	sd	s3,24(sp)
    800040a0:	e852                	sd	s4,16(sp)
    800040a2:	0080                	addi	s0,sp,64
    800040a4:	892a                	mv	s2,a0
    800040a6:	8a2e                	mv	s4,a1
    800040a8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800040aa:	4601                	li	a2,0
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	dd8080e7          	jalr	-552(ra) # 80003e84 <dirlookup>
    800040b4:	e93d                	bnez	a0,8000412a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040b6:	05492483          	lw	s1,84(s2)
    800040ba:	c49d                	beqz	s1,800040e8 <dirlink+0x54>
    800040bc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040be:	4741                	li	a4,16
    800040c0:	86a6                	mv	a3,s1
    800040c2:	fc040613          	addi	a2,s0,-64
    800040c6:	4581                	li	a1,0
    800040c8:	854a                	mv	a0,s2
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	b8a080e7          	jalr	-1142(ra) # 80003c54 <readi>
    800040d2:	47c1                	li	a5,16
    800040d4:	06f51163          	bne	a0,a5,80004136 <dirlink+0xa2>
    if(de.inum == 0)
    800040d8:	fc045783          	lhu	a5,-64(s0)
    800040dc:	c791                	beqz	a5,800040e8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040de:	24c1                	addiw	s1,s1,16
    800040e0:	05492783          	lw	a5,84(s2)
    800040e4:	fcf4ede3          	bltu	s1,a5,800040be <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040e8:	4639                	li	a2,14
    800040ea:	85d2                	mv	a1,s4
    800040ec:	fc240513          	addi	a0,s0,-62
    800040f0:	ffffd097          	auipc	ra,0xffffd
    800040f4:	ebe080e7          	jalr	-322(ra) # 80000fae <strncpy>
  de.inum = inum;
    800040f8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040fc:	4741                	li	a4,16
    800040fe:	86a6                	mv	a3,s1
    80004100:	fc040613          	addi	a2,s0,-64
    80004104:	4581                	li	a1,0
    80004106:	854a                	mv	a0,s2
    80004108:	00000097          	auipc	ra,0x0
    8000410c:	c44080e7          	jalr	-956(ra) # 80003d4c <writei>
    80004110:	872a                	mv	a4,a0
    80004112:	47c1                	li	a5,16
  return 0;
    80004114:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004116:	02f71863          	bne	a4,a5,80004146 <dirlink+0xb2>
}
    8000411a:	70e2                	ld	ra,56(sp)
    8000411c:	7442                	ld	s0,48(sp)
    8000411e:	74a2                	ld	s1,40(sp)
    80004120:	7902                	ld	s2,32(sp)
    80004122:	69e2                	ld	s3,24(sp)
    80004124:	6a42                	ld	s4,16(sp)
    80004126:	6121                	addi	sp,sp,64
    80004128:	8082                	ret
    iput(ip);
    8000412a:	00000097          	auipc	ra,0x0
    8000412e:	a30080e7          	jalr	-1488(ra) # 80003b5a <iput>
    return -1;
    80004132:	557d                	li	a0,-1
    80004134:	b7dd                	j	8000411a <dirlink+0x86>
      panic("dirlink read");
    80004136:	00006517          	auipc	a0,0x6
    8000413a:	aba50513          	addi	a0,a0,-1350 # 80009bf0 <syscalls+0x1d8>
    8000413e:	ffffc097          	auipc	ra,0xffffc
    80004142:	426080e7          	jalr	1062(ra) # 80000564 <panic>
    panic("dirlink");
    80004146:	00006517          	auipc	a0,0x6
    8000414a:	bba50513          	addi	a0,a0,-1094 # 80009d00 <syscalls+0x2e8>
    8000414e:	ffffc097          	auipc	ra,0xffffc
    80004152:	416080e7          	jalr	1046(ra) # 80000564 <panic>

0000000080004156 <namei>:

struct inode*
namei(char *path)
{
    80004156:	1101                	addi	sp,sp,-32
    80004158:	ec06                	sd	ra,24(sp)
    8000415a:	e822                	sd	s0,16(sp)
    8000415c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000415e:	fe040613          	addi	a2,s0,-32
    80004162:	4581                	li	a1,0
    80004164:	00000097          	auipc	ra,0x0
    80004168:	dd0080e7          	jalr	-560(ra) # 80003f34 <namex>
}
    8000416c:	60e2                	ld	ra,24(sp)
    8000416e:	6442                	ld	s0,16(sp)
    80004170:	6105                	addi	sp,sp,32
    80004172:	8082                	ret

0000000080004174 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004174:	1141                	addi	sp,sp,-16
    80004176:	e406                	sd	ra,8(sp)
    80004178:	e022                	sd	s0,0(sp)
    8000417a:	0800                	addi	s0,sp,16
    8000417c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000417e:	4585                	li	a1,1
    80004180:	00000097          	auipc	ra,0x0
    80004184:	db4080e7          	jalr	-588(ra) # 80003f34 <namex>
}
    80004188:	60a2                	ld	ra,8(sp)
    8000418a:	6402                	ld	s0,0(sp)
    8000418c:	0141                	addi	sp,sp,16
    8000418e:	8082                	ret

0000000080004190 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004190:	1101                	addi	sp,sp,-32
    80004192:	ec06                	sd	ra,24(sp)
    80004194:	e822                	sd	s0,16(sp)
    80004196:	e426                	sd	s1,8(sp)
    80004198:	e04a                	sd	s2,0(sp)
    8000419a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000419c:	00033917          	auipc	s2,0x33
    800041a0:	fac90913          	addi	s2,s2,-84 # 80037148 <log>
    800041a4:	02092583          	lw	a1,32(s2)
    800041a8:	03092503          	lw	a0,48(s2)
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	ff2080e7          	jalr	-14(ra) # 8000319e <bread>
    800041b4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800041b6:	03492683          	lw	a3,52(s2)
    800041ba:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    800041bc:	02d05763          	blez	a3,800041ea <write_head+0x5a>
    800041c0:	00033797          	auipc	a5,0x33
    800041c4:	fc078793          	addi	a5,a5,-64 # 80037180 <log+0x38>
    800041c8:	06450713          	addi	a4,a0,100
    800041cc:	36fd                	addiw	a3,a3,-1
    800041ce:	1682                	slli	a3,a3,0x20
    800041d0:	9281                	srli	a3,a3,0x20
    800041d2:	068a                	slli	a3,a3,0x2
    800041d4:	00033617          	auipc	a2,0x33
    800041d8:	fb060613          	addi	a2,a2,-80 # 80037184 <log+0x3c>
    800041dc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041de:	4390                	lw	a2,0(a5)
    800041e0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041e2:	0791                	addi	a5,a5,4
    800041e4:	0711                	addi	a4,a4,4
    800041e6:	fed79ce3          	bne	a5,a3,800041de <write_head+0x4e>
  }
  bwrite(buf);
    800041ea:	8526                	mv	a0,s1
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	0a4080e7          	jalr	164(ra) # 80003290 <bwrite>
  brelse(buf);
    800041f4:	8526                	mv	a0,s1
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	0d8080e7          	jalr	216(ra) # 800032ce <brelse>
}
    800041fe:	60e2                	ld	ra,24(sp)
    80004200:	6442                	ld	s0,16(sp)
    80004202:	64a2                	ld	s1,8(sp)
    80004204:	6902                	ld	s2,0(sp)
    80004206:	6105                	addi	sp,sp,32
    80004208:	8082                	ret

000000008000420a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000420a:	00033797          	auipc	a5,0x33
    8000420e:	f727a783          	lw	a5,-142(a5) # 8003717c <log+0x34>
    80004212:	0af05663          	blez	a5,800042be <install_trans+0xb4>
{
    80004216:	7139                	addi	sp,sp,-64
    80004218:	fc06                	sd	ra,56(sp)
    8000421a:	f822                	sd	s0,48(sp)
    8000421c:	f426                	sd	s1,40(sp)
    8000421e:	f04a                	sd	s2,32(sp)
    80004220:	ec4e                	sd	s3,24(sp)
    80004222:	e852                	sd	s4,16(sp)
    80004224:	e456                	sd	s5,8(sp)
    80004226:	0080                	addi	s0,sp,64
    80004228:	00033a97          	auipc	s5,0x33
    8000422c:	f58a8a93          	addi	s5,s5,-168 # 80037180 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004230:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004232:	00033997          	auipc	s3,0x33
    80004236:	f1698993          	addi	s3,s3,-234 # 80037148 <log>
    8000423a:	0209a583          	lw	a1,32(s3)
    8000423e:	014585bb          	addw	a1,a1,s4
    80004242:	2585                	addiw	a1,a1,1
    80004244:	0309a503          	lw	a0,48(s3)
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	f56080e7          	jalr	-170(ra) # 8000319e <bread>
    80004250:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004252:	000aa583          	lw	a1,0(s5)
    80004256:	0309a503          	lw	a0,48(s3)
    8000425a:	fffff097          	auipc	ra,0xfffff
    8000425e:	f44080e7          	jalr	-188(ra) # 8000319e <bread>
    80004262:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004264:	40000613          	li	a2,1024
    80004268:	06090593          	addi	a1,s2,96
    8000426c:	06050513          	addi	a0,a0,96
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	c62080e7          	jalr	-926(ra) # 80000ed2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004278:	8526                	mv	a0,s1
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	016080e7          	jalr	22(ra) # 80003290 <bwrite>
    bunpin(dbuf);
    80004282:	8526                	mv	a0,s1
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	124080e7          	jalr	292(ra) # 800033a8 <bunpin>
    brelse(lbuf);
    8000428c:	854a                	mv	a0,s2
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	040080e7          	jalr	64(ra) # 800032ce <brelse>
    brelse(dbuf);
    80004296:	8526                	mv	a0,s1
    80004298:	fffff097          	auipc	ra,0xfffff
    8000429c:	036080e7          	jalr	54(ra) # 800032ce <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a0:	2a05                	addiw	s4,s4,1
    800042a2:	0a91                	addi	s5,s5,4
    800042a4:	0349a783          	lw	a5,52(s3)
    800042a8:	f8fa49e3          	blt	s4,a5,8000423a <install_trans+0x30>
}
    800042ac:	70e2                	ld	ra,56(sp)
    800042ae:	7442                	ld	s0,48(sp)
    800042b0:	74a2                	ld	s1,40(sp)
    800042b2:	7902                	ld	s2,32(sp)
    800042b4:	69e2                	ld	s3,24(sp)
    800042b6:	6a42                	ld	s4,16(sp)
    800042b8:	6aa2                	ld	s5,8(sp)
    800042ba:	6121                	addi	sp,sp,64
    800042bc:	8082                	ret
    800042be:	8082                	ret

00000000800042c0 <initlog>:
{
    800042c0:	7179                	addi	sp,sp,-48
    800042c2:	f406                	sd	ra,40(sp)
    800042c4:	f022                	sd	s0,32(sp)
    800042c6:	ec26                	sd	s1,24(sp)
    800042c8:	e84a                	sd	s2,16(sp)
    800042ca:	e44e                	sd	s3,8(sp)
    800042cc:	1800                	addi	s0,sp,48
    800042ce:	892a                	mv	s2,a0
    800042d0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042d2:	00033497          	auipc	s1,0x33
    800042d6:	e7648493          	addi	s1,s1,-394 # 80037148 <log>
    800042da:	00006597          	auipc	a1,0x6
    800042de:	92658593          	addi	a1,a1,-1754 # 80009c00 <syscalls+0x1e8>
    800042e2:	8526                	mv	a0,s1
    800042e4:	ffffc097          	auipc	ra,0xffffc
    800042e8:	7d8080e7          	jalr	2008(ra) # 80000abc <initlock>
  log.start = sb->logstart;
    800042ec:	0149a583          	lw	a1,20(s3)
    800042f0:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800042f2:	0109a783          	lw	a5,16(s3)
    800042f6:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800042f8:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042fc:	854a                	mv	a0,s2
    800042fe:	fffff097          	auipc	ra,0xfffff
    80004302:	ea0080e7          	jalr	-352(ra) # 8000319e <bread>
  log.lh.n = lh->n;
    80004306:	5134                	lw	a3,96(a0)
    80004308:	d8d4                	sw	a3,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000430a:	02d05563          	blez	a3,80004334 <initlog+0x74>
    8000430e:	06450793          	addi	a5,a0,100
    80004312:	00033717          	auipc	a4,0x33
    80004316:	e6e70713          	addi	a4,a4,-402 # 80037180 <log+0x38>
    8000431a:	36fd                	addiw	a3,a3,-1
    8000431c:	1682                	slli	a3,a3,0x20
    8000431e:	9281                	srli	a3,a3,0x20
    80004320:	068a                	slli	a3,a3,0x2
    80004322:	06850613          	addi	a2,a0,104
    80004326:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004328:	4390                	lw	a2,0(a5)
    8000432a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000432c:	0791                	addi	a5,a5,4
    8000432e:	0711                	addi	a4,a4,4
    80004330:	fed79ce3          	bne	a5,a3,80004328 <initlog+0x68>
  brelse(buf);
    80004334:	fffff097          	auipc	ra,0xfffff
    80004338:	f9a080e7          	jalr	-102(ra) # 800032ce <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000433c:	00000097          	auipc	ra,0x0
    80004340:	ece080e7          	jalr	-306(ra) # 8000420a <install_trans>
  log.lh.n = 0;
    80004344:	00033797          	auipc	a5,0x33
    80004348:	e207ac23          	sw	zero,-456(a5) # 8003717c <log+0x34>
  write_head(); // clear the log
    8000434c:	00000097          	auipc	ra,0x0
    80004350:	e44080e7          	jalr	-444(ra) # 80004190 <write_head>
}
    80004354:	70a2                	ld	ra,40(sp)
    80004356:	7402                	ld	s0,32(sp)
    80004358:	64e2                	ld	s1,24(sp)
    8000435a:	6942                	ld	s2,16(sp)
    8000435c:	69a2                	ld	s3,8(sp)
    8000435e:	6145                	addi	sp,sp,48
    80004360:	8082                	ret

0000000080004362 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004362:	1101                	addi	sp,sp,-32
    80004364:	ec06                	sd	ra,24(sp)
    80004366:	e822                	sd	s0,16(sp)
    80004368:	e426                	sd	s1,8(sp)
    8000436a:	e04a                	sd	s2,0(sp)
    8000436c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000436e:	00033517          	auipc	a0,0x33
    80004372:	dda50513          	addi	a0,a0,-550 # 80037148 <log>
    80004376:	ffffd097          	auipc	ra,0xffffd
    8000437a:	81c080e7          	jalr	-2020(ra) # 80000b92 <acquire>
  while(1){
    if(log.committing){
    8000437e:	00033497          	auipc	s1,0x33
    80004382:	dca48493          	addi	s1,s1,-566 # 80037148 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004386:	4979                	li	s2,30
    80004388:	a039                	j	80004396 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000438a:	85a6                	mv	a1,s1
    8000438c:	8526                	mv	a0,s1
    8000438e:	ffffe097          	auipc	ra,0xffffe
    80004392:	130080e7          	jalr	304(ra) # 800024be <sleep>
    if(log.committing){
    80004396:	54dc                	lw	a5,44(s1)
    80004398:	fbed                	bnez	a5,8000438a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000439a:	549c                	lw	a5,40(s1)
    8000439c:	0017871b          	addiw	a4,a5,1
    800043a0:	0007069b          	sext.w	a3,a4
    800043a4:	0027179b          	slliw	a5,a4,0x2
    800043a8:	9fb9                	addw	a5,a5,a4
    800043aa:	0017979b          	slliw	a5,a5,0x1
    800043ae:	58d8                	lw	a4,52(s1)
    800043b0:	9fb9                	addw	a5,a5,a4
    800043b2:	00f95963          	bge	s2,a5,800043c4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800043b6:	85a6                	mv	a1,s1
    800043b8:	8526                	mv	a0,s1
    800043ba:	ffffe097          	auipc	ra,0xffffe
    800043be:	104080e7          	jalr	260(ra) # 800024be <sleep>
    800043c2:	bfd1                	j	80004396 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043c4:	00033517          	auipc	a0,0x33
    800043c8:	d8450513          	addi	a0,a0,-636 # 80037148 <log>
    800043cc:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	894080e7          	jalr	-1900(ra) # 80000c62 <release>
      break;
    }
  }
}
    800043d6:	60e2                	ld	ra,24(sp)
    800043d8:	6442                	ld	s0,16(sp)
    800043da:	64a2                	ld	s1,8(sp)
    800043dc:	6902                	ld	s2,0(sp)
    800043de:	6105                	addi	sp,sp,32
    800043e0:	8082                	ret

00000000800043e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043e2:	7139                	addi	sp,sp,-64
    800043e4:	fc06                	sd	ra,56(sp)
    800043e6:	f822                	sd	s0,48(sp)
    800043e8:	f426                	sd	s1,40(sp)
    800043ea:	f04a                	sd	s2,32(sp)
    800043ec:	ec4e                	sd	s3,24(sp)
    800043ee:	e852                	sd	s4,16(sp)
    800043f0:	e456                	sd	s5,8(sp)
    800043f2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043f4:	00033497          	auipc	s1,0x33
    800043f8:	d5448493          	addi	s1,s1,-684 # 80037148 <log>
    800043fc:	8526                	mv	a0,s1
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	794080e7          	jalr	1940(ra) # 80000b92 <acquire>
  log.outstanding -= 1;
    80004406:	549c                	lw	a5,40(s1)
    80004408:	37fd                	addiw	a5,a5,-1
    8000440a:	0007891b          	sext.w	s2,a5
    8000440e:	d49c                	sw	a5,40(s1)
  if(log.committing)
    80004410:	54dc                	lw	a5,44(s1)
    80004412:	e7b9                	bnez	a5,80004460 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004414:	04091e63          	bnez	s2,80004470 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004418:	00033497          	auipc	s1,0x33
    8000441c:	d3048493          	addi	s1,s1,-720 # 80037148 <log>
    80004420:	4785                	li	a5,1
    80004422:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004424:	8526                	mv	a0,s1
    80004426:	ffffd097          	auipc	ra,0xffffd
    8000442a:	83c080e7          	jalr	-1988(ra) # 80000c62 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    8000442e:	58dc                	lw	a5,52(s1)
    80004430:	06f04763          	bgtz	a5,8000449e <end_op+0xbc>
    acquire(&log.lock);
    80004434:	00033497          	auipc	s1,0x33
    80004438:	d1448493          	addi	s1,s1,-748 # 80037148 <log>
    8000443c:	8526                	mv	a0,s1
    8000443e:	ffffc097          	auipc	ra,0xffffc
    80004442:	754080e7          	jalr	1876(ra) # 80000b92 <acquire>
    log.committing = 0;
    80004446:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    8000444a:	8526                	mv	a0,s1
    8000444c:	ffffe097          	auipc	ra,0xffffe
    80004450:	1f2080e7          	jalr	498(ra) # 8000263e <wakeup>
    release(&log.lock);
    80004454:	8526                	mv	a0,s1
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	80c080e7          	jalr	-2036(ra) # 80000c62 <release>
}
    8000445e:	a03d                	j	8000448c <end_op+0xaa>
    panic("log.committing");
    80004460:	00005517          	auipc	a0,0x5
    80004464:	7a850513          	addi	a0,a0,1960 # 80009c08 <syscalls+0x1f0>
    80004468:	ffffc097          	auipc	ra,0xffffc
    8000446c:	0fc080e7          	jalr	252(ra) # 80000564 <panic>
    wakeup(&log);
    80004470:	00033497          	auipc	s1,0x33
    80004474:	cd848493          	addi	s1,s1,-808 # 80037148 <log>
    80004478:	8526                	mv	a0,s1
    8000447a:	ffffe097          	auipc	ra,0xffffe
    8000447e:	1c4080e7          	jalr	452(ra) # 8000263e <wakeup>
  release(&log.lock);
    80004482:	8526                	mv	a0,s1
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	7de080e7          	jalr	2014(ra) # 80000c62 <release>
}
    8000448c:	70e2                	ld	ra,56(sp)
    8000448e:	7442                	ld	s0,48(sp)
    80004490:	74a2                	ld	s1,40(sp)
    80004492:	7902                	ld	s2,32(sp)
    80004494:	69e2                	ld	s3,24(sp)
    80004496:	6a42                	ld	s4,16(sp)
    80004498:	6aa2                	ld	s5,8(sp)
    8000449a:	6121                	addi	sp,sp,64
    8000449c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449e:	00033a97          	auipc	s5,0x33
    800044a2:	ce2a8a93          	addi	s5,s5,-798 # 80037180 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044a6:	00033a17          	auipc	s4,0x33
    800044aa:	ca2a0a13          	addi	s4,s4,-862 # 80037148 <log>
    800044ae:	020a2583          	lw	a1,32(s4)
    800044b2:	012585bb          	addw	a1,a1,s2
    800044b6:	2585                	addiw	a1,a1,1
    800044b8:	030a2503          	lw	a0,48(s4)
    800044bc:	fffff097          	auipc	ra,0xfffff
    800044c0:	ce2080e7          	jalr	-798(ra) # 8000319e <bread>
    800044c4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044c6:	000aa583          	lw	a1,0(s5)
    800044ca:	030a2503          	lw	a0,48(s4)
    800044ce:	fffff097          	auipc	ra,0xfffff
    800044d2:	cd0080e7          	jalr	-816(ra) # 8000319e <bread>
    800044d6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044d8:	40000613          	li	a2,1024
    800044dc:	06050593          	addi	a1,a0,96
    800044e0:	06048513          	addi	a0,s1,96
    800044e4:	ffffd097          	auipc	ra,0xffffd
    800044e8:	9ee080e7          	jalr	-1554(ra) # 80000ed2 <memmove>
    bwrite(to);  // write the log
    800044ec:	8526                	mv	a0,s1
    800044ee:	fffff097          	auipc	ra,0xfffff
    800044f2:	da2080e7          	jalr	-606(ra) # 80003290 <bwrite>
    brelse(from);
    800044f6:	854e                	mv	a0,s3
    800044f8:	fffff097          	auipc	ra,0xfffff
    800044fc:	dd6080e7          	jalr	-554(ra) # 800032ce <brelse>
    brelse(to);
    80004500:	8526                	mv	a0,s1
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	dcc080e7          	jalr	-564(ra) # 800032ce <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000450a:	2905                	addiw	s2,s2,1
    8000450c:	0a91                	addi	s5,s5,4
    8000450e:	034a2783          	lw	a5,52(s4)
    80004512:	f8f94ee3          	blt	s2,a5,800044ae <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004516:	00000097          	auipc	ra,0x0
    8000451a:	c7a080e7          	jalr	-902(ra) # 80004190 <write_head>
    install_trans(); // Now install writes to home locations
    8000451e:	00000097          	auipc	ra,0x0
    80004522:	cec080e7          	jalr	-788(ra) # 8000420a <install_trans>
    log.lh.n = 0;
    80004526:	00033797          	auipc	a5,0x33
    8000452a:	c407ab23          	sw	zero,-938(a5) # 8003717c <log+0x34>
    write_head();    // Erase the transaction from the log
    8000452e:	00000097          	auipc	ra,0x0
    80004532:	c62080e7          	jalr	-926(ra) # 80004190 <write_head>
    80004536:	bdfd                	j	80004434 <end_op+0x52>

0000000080004538 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	e04a                	sd	s2,0(sp)
    80004542:	1000                	addi	s0,sp,32
    80004544:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004546:	00033917          	auipc	s2,0x33
    8000454a:	c0290913          	addi	s2,s2,-1022 # 80037148 <log>
    8000454e:	854a                	mv	a0,s2
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	642080e7          	jalr	1602(ra) # 80000b92 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004558:	03492603          	lw	a2,52(s2)
    8000455c:	47f5                	li	a5,29
    8000455e:	06c7c563          	blt	a5,a2,800045c8 <log_write+0x90>
    80004562:	00033797          	auipc	a5,0x33
    80004566:	c0a7a783          	lw	a5,-1014(a5) # 8003716c <log+0x24>
    8000456a:	37fd                	addiw	a5,a5,-1
    8000456c:	04f65e63          	bge	a2,a5,800045c8 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004570:	00033797          	auipc	a5,0x33
    80004574:	c007a783          	lw	a5,-1024(a5) # 80037170 <log+0x28>
    80004578:	06f05063          	blez	a5,800045d8 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000457c:	4781                	li	a5,0
    8000457e:	06c05563          	blez	a2,800045e8 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004582:	44cc                	lw	a1,12(s1)
    80004584:	00033717          	auipc	a4,0x33
    80004588:	bfc70713          	addi	a4,a4,-1028 # 80037180 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    8000458c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000458e:	4314                	lw	a3,0(a4)
    80004590:	04b68c63          	beq	a3,a1,800045e8 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004594:	2785                	addiw	a5,a5,1
    80004596:	0711                	addi	a4,a4,4
    80004598:	fef61be3          	bne	a2,a5,8000458e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000459c:	0631                	addi	a2,a2,12
    8000459e:	060a                	slli	a2,a2,0x2
    800045a0:	00033797          	auipc	a5,0x33
    800045a4:	ba878793          	addi	a5,a5,-1112 # 80037148 <log>
    800045a8:	963e                	add	a2,a2,a5
    800045aa:	44dc                	lw	a5,12(s1)
    800045ac:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800045ae:	8526                	mv	a0,s1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	dbc080e7          	jalr	-580(ra) # 8000336c <bpin>
    log.lh.n++;
    800045b8:	00033717          	auipc	a4,0x33
    800045bc:	b9070713          	addi	a4,a4,-1136 # 80037148 <log>
    800045c0:	5b5c                	lw	a5,52(a4)
    800045c2:	2785                	addiw	a5,a5,1
    800045c4:	db5c                	sw	a5,52(a4)
    800045c6:	a835                	j	80004602 <log_write+0xca>
    panic("too big a transaction");
    800045c8:	00005517          	auipc	a0,0x5
    800045cc:	65050513          	addi	a0,a0,1616 # 80009c18 <syscalls+0x200>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	f94080e7          	jalr	-108(ra) # 80000564 <panic>
    panic("log_write outside of trans");
    800045d8:	00005517          	auipc	a0,0x5
    800045dc:	65850513          	addi	a0,a0,1624 # 80009c30 <syscalls+0x218>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	f84080e7          	jalr	-124(ra) # 80000564 <panic>
  log.lh.block[i] = b->blockno;
    800045e8:	00c78713          	addi	a4,a5,12
    800045ec:	00271693          	slli	a3,a4,0x2
    800045f0:	00033717          	auipc	a4,0x33
    800045f4:	b5870713          	addi	a4,a4,-1192 # 80037148 <log>
    800045f8:	9736                	add	a4,a4,a3
    800045fa:	44d4                	lw	a3,12(s1)
    800045fc:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045fe:	faf608e3          	beq	a2,a5,800045ae <log_write+0x76>
  }
  release(&log.lock);
    80004602:	00033517          	auipc	a0,0x33
    80004606:	b4650513          	addi	a0,a0,-1210 # 80037148 <log>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	658080e7          	jalr	1624(ra) # 80000c62 <release>
}
    80004612:	60e2                	ld	ra,24(sp)
    80004614:	6442                	ld	s0,16(sp)
    80004616:	64a2                	ld	s1,8(sp)
    80004618:	6902                	ld	s2,0(sp)
    8000461a:	6105                	addi	sp,sp,32
    8000461c:	8082                	ret

000000008000461e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000461e:	1101                	addi	sp,sp,-32
    80004620:	ec06                	sd	ra,24(sp)
    80004622:	e822                	sd	s0,16(sp)
    80004624:	e426                	sd	s1,8(sp)
    80004626:	e04a                	sd	s2,0(sp)
    80004628:	1000                	addi	s0,sp,32
    8000462a:	84aa                	mv	s1,a0
    8000462c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000462e:	00005597          	auipc	a1,0x5
    80004632:	62258593          	addi	a1,a1,1570 # 80009c50 <syscalls+0x238>
    80004636:	0521                	addi	a0,a0,8
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	484080e7          	jalr	1156(ra) # 80000abc <initlock>
  lk->name = name;
    80004640:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004644:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004648:	0204a823          	sw	zero,48(s1)
}
    8000464c:	60e2                	ld	ra,24(sp)
    8000464e:	6442                	ld	s0,16(sp)
    80004650:	64a2                	ld	s1,8(sp)
    80004652:	6902                	ld	s2,0(sp)
    80004654:	6105                	addi	sp,sp,32
    80004656:	8082                	ret

0000000080004658 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004658:	1101                	addi	sp,sp,-32
    8000465a:	ec06                	sd	ra,24(sp)
    8000465c:	e822                	sd	s0,16(sp)
    8000465e:	e426                	sd	s1,8(sp)
    80004660:	e04a                	sd	s2,0(sp)
    80004662:	1000                	addi	s0,sp,32
    80004664:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004666:	00850913          	addi	s2,a0,8
    8000466a:	854a                	mv	a0,s2
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	526080e7          	jalr	1318(ra) # 80000b92 <acquire>
  while (lk->locked) {
    80004674:	409c                	lw	a5,0(s1)
    80004676:	cb89                	beqz	a5,80004688 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004678:	85ca                	mv	a1,s2
    8000467a:	8526                	mv	a0,s1
    8000467c:	ffffe097          	auipc	ra,0xffffe
    80004680:	e42080e7          	jalr	-446(ra) # 800024be <sleep>
  while (lk->locked) {
    80004684:	409c                	lw	a5,0(s1)
    80004686:	fbed                	bnez	a5,80004678 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004688:	4785                	li	a5,1
    8000468a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000468c:	ffffd097          	auipc	ra,0xffffd
    80004690:	4c4080e7          	jalr	1220(ra) # 80001b50 <myproc>
    80004694:	413c                	lw	a5,64(a0)
    80004696:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    80004698:	854a                	mv	a0,s2
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	5c8080e7          	jalr	1480(ra) # 80000c62 <release>
}
    800046a2:	60e2                	ld	ra,24(sp)
    800046a4:	6442                	ld	s0,16(sp)
    800046a6:	64a2                	ld	s1,8(sp)
    800046a8:	6902                	ld	s2,0(sp)
    800046aa:	6105                	addi	sp,sp,32
    800046ac:	8082                	ret

00000000800046ae <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046ae:	1101                	addi	sp,sp,-32
    800046b0:	ec06                	sd	ra,24(sp)
    800046b2:	e822                	sd	s0,16(sp)
    800046b4:	e426                	sd	s1,8(sp)
    800046b6:	e04a                	sd	s2,0(sp)
    800046b8:	1000                	addi	s0,sp,32
    800046ba:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046bc:	00850913          	addi	s2,a0,8
    800046c0:	854a                	mv	a0,s2
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	4d0080e7          	jalr	1232(ra) # 80000b92 <acquire>
  lk->locked = 0;
    800046ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ce:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	f6a080e7          	jalr	-150(ra) # 8000263e <wakeup>
  release(&lk->lk);
    800046dc:	854a                	mv	a0,s2
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	584080e7          	jalr	1412(ra) # 80000c62 <release>
}
    800046e6:	60e2                	ld	ra,24(sp)
    800046e8:	6442                	ld	s0,16(sp)
    800046ea:	64a2                	ld	s1,8(sp)
    800046ec:	6902                	ld	s2,0(sp)
    800046ee:	6105                	addi	sp,sp,32
    800046f0:	8082                	ret

00000000800046f2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046f2:	7179                	addi	sp,sp,-48
    800046f4:	f406                	sd	ra,40(sp)
    800046f6:	f022                	sd	s0,32(sp)
    800046f8:	ec26                	sd	s1,24(sp)
    800046fa:	e84a                	sd	s2,16(sp)
    800046fc:	e44e                	sd	s3,8(sp)
    800046fe:	1800                	addi	s0,sp,48
    80004700:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004702:	00850913          	addi	s2,a0,8
    80004706:	854a                	mv	a0,s2
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	48a080e7          	jalr	1162(ra) # 80000b92 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004710:	409c                	lw	a5,0(s1)
    80004712:	ef99                	bnez	a5,80004730 <holdingsleep+0x3e>
    80004714:	4481                	li	s1,0
  release(&lk->lk);
    80004716:	854a                	mv	a0,s2
    80004718:	ffffc097          	auipc	ra,0xffffc
    8000471c:	54a080e7          	jalr	1354(ra) # 80000c62 <release>
  return r;
}
    80004720:	8526                	mv	a0,s1
    80004722:	70a2                	ld	ra,40(sp)
    80004724:	7402                	ld	s0,32(sp)
    80004726:	64e2                	ld	s1,24(sp)
    80004728:	6942                	ld	s2,16(sp)
    8000472a:	69a2                	ld	s3,8(sp)
    8000472c:	6145                	addi	sp,sp,48
    8000472e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004730:	0304a983          	lw	s3,48(s1)
    80004734:	ffffd097          	auipc	ra,0xffffd
    80004738:	41c080e7          	jalr	1052(ra) # 80001b50 <myproc>
    8000473c:	4124                	lw	s1,64(a0)
    8000473e:	413484b3          	sub	s1,s1,s3
    80004742:	0014b493          	seqz	s1,s1
    80004746:	bfc1                	j	80004716 <holdingsleep+0x24>

0000000080004748 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004748:	1141                	addi	sp,sp,-16
    8000474a:	e406                	sd	ra,8(sp)
    8000474c:	e022                	sd	s0,0(sp)
    8000474e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004750:	00005597          	auipc	a1,0x5
    80004754:	51058593          	addi	a1,a1,1296 # 80009c60 <syscalls+0x248>
    80004758:	00033517          	auipc	a0,0x33
    8000475c:	b4050513          	addi	a0,a0,-1216 # 80037298 <ftable>
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	35c080e7          	jalr	860(ra) # 80000abc <initlock>
}
    80004768:	60a2                	ld	ra,8(sp)
    8000476a:	6402                	ld	s0,0(sp)
    8000476c:	0141                	addi	sp,sp,16
    8000476e:	8082                	ret

0000000080004770 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004770:	1101                	addi	sp,sp,-32
    80004772:	ec06                	sd	ra,24(sp)
    80004774:	e822                	sd	s0,16(sp)
    80004776:	e426                	sd	s1,8(sp)
    80004778:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000477a:	00033517          	auipc	a0,0x33
    8000477e:	b1e50513          	addi	a0,a0,-1250 # 80037298 <ftable>
    80004782:	ffffc097          	auipc	ra,0xffffc
    80004786:	410080e7          	jalr	1040(ra) # 80000b92 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000478a:	00033497          	auipc	s1,0x33
    8000478e:	b2e48493          	addi	s1,s1,-1234 # 800372b8 <ftable+0x20>
    80004792:	00034717          	auipc	a4,0x34
    80004796:	ac670713          	addi	a4,a4,-1338 # 80038258 <disk>
    if(f->ref == 0){
    8000479a:	40dc                	lw	a5,4(s1)
    8000479c:	cf99                	beqz	a5,800047ba <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000479e:	02848493          	addi	s1,s1,40
    800047a2:	fee49ce3          	bne	s1,a4,8000479a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047a6:	00033517          	auipc	a0,0x33
    800047aa:	af250513          	addi	a0,a0,-1294 # 80037298 <ftable>
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	4b4080e7          	jalr	1204(ra) # 80000c62 <release>
  return 0;
    800047b6:	4481                	li	s1,0
    800047b8:	a819                	j	800047ce <filealloc+0x5e>
      f->ref = 1;
    800047ba:	4785                	li	a5,1
    800047bc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047be:	00033517          	auipc	a0,0x33
    800047c2:	ada50513          	addi	a0,a0,-1318 # 80037298 <ftable>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	49c080e7          	jalr	1180(ra) # 80000c62 <release>
}
    800047ce:	8526                	mv	a0,s1
    800047d0:	60e2                	ld	ra,24(sp)
    800047d2:	6442                	ld	s0,16(sp)
    800047d4:	64a2                	ld	s1,8(sp)
    800047d6:	6105                	addi	sp,sp,32
    800047d8:	8082                	ret

00000000800047da <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047da:	1101                	addi	sp,sp,-32
    800047dc:	ec06                	sd	ra,24(sp)
    800047de:	e822                	sd	s0,16(sp)
    800047e0:	e426                	sd	s1,8(sp)
    800047e2:	1000                	addi	s0,sp,32
    800047e4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047e6:	00033517          	auipc	a0,0x33
    800047ea:	ab250513          	addi	a0,a0,-1358 # 80037298 <ftable>
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	3a4080e7          	jalr	932(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    800047f6:	40dc                	lw	a5,4(s1)
    800047f8:	02f05263          	blez	a5,8000481c <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047fc:	2785                	addiw	a5,a5,1
    800047fe:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004800:	00033517          	auipc	a0,0x33
    80004804:	a9850513          	addi	a0,a0,-1384 # 80037298 <ftable>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	45a080e7          	jalr	1114(ra) # 80000c62 <release>
  return f;
}
    80004810:	8526                	mv	a0,s1
    80004812:	60e2                	ld	ra,24(sp)
    80004814:	6442                	ld	s0,16(sp)
    80004816:	64a2                	ld	s1,8(sp)
    80004818:	6105                	addi	sp,sp,32
    8000481a:	8082                	ret
    panic("filedup");
    8000481c:	00005517          	auipc	a0,0x5
    80004820:	44c50513          	addi	a0,a0,1100 # 80009c68 <syscalls+0x250>
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	d40080e7          	jalr	-704(ra) # 80000564 <panic>

000000008000482c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000482c:	7139                	addi	sp,sp,-64
    8000482e:	fc06                	sd	ra,56(sp)
    80004830:	f822                	sd	s0,48(sp)
    80004832:	f426                	sd	s1,40(sp)
    80004834:	f04a                	sd	s2,32(sp)
    80004836:	ec4e                	sd	s3,24(sp)
    80004838:	e852                	sd	s4,16(sp)
    8000483a:	e456                	sd	s5,8(sp)
    8000483c:	0080                	addi	s0,sp,64
    8000483e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004840:	00033517          	auipc	a0,0x33
    80004844:	a5850513          	addi	a0,a0,-1448 # 80037298 <ftable>
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	34a080e7          	jalr	842(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    80004850:	40dc                	lw	a5,4(s1)
    80004852:	06f05163          	blez	a5,800048b4 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004856:	37fd                	addiw	a5,a5,-1
    80004858:	0007871b          	sext.w	a4,a5
    8000485c:	c0dc                	sw	a5,4(s1)
    8000485e:	06e04363          	bgtz	a4,800048c4 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004862:	0004a903          	lw	s2,0(s1)
    80004866:	0094ca83          	lbu	s5,9(s1)
    8000486a:	0104ba03          	ld	s4,16(s1)
    8000486e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004872:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004876:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000487a:	00033517          	auipc	a0,0x33
    8000487e:	a1e50513          	addi	a0,a0,-1506 # 80037298 <ftable>
    80004882:	ffffc097          	auipc	ra,0xffffc
    80004886:	3e0080e7          	jalr	992(ra) # 80000c62 <release>

  if(ff.type == FD_PIPE){
    8000488a:	4785                	li	a5,1
    8000488c:	04f90d63          	beq	s2,a5,800048e6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004890:	3979                	addiw	s2,s2,-2
    80004892:	4785                	li	a5,1
    80004894:	0527e063          	bltu	a5,s2,800048d4 <fileclose+0xa8>
    begin_op();
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	aca080e7          	jalr	-1334(ra) # 80004362 <begin_op>
    iput(ff.ip);
    800048a0:	854e                	mv	a0,s3
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	2b8080e7          	jalr	696(ra) # 80003b5a <iput>
    end_op();
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	b38080e7          	jalr	-1224(ra) # 800043e2 <end_op>
    800048b2:	a00d                	j	800048d4 <fileclose+0xa8>
    panic("fileclose");
    800048b4:	00005517          	auipc	a0,0x5
    800048b8:	3bc50513          	addi	a0,a0,956 # 80009c70 <syscalls+0x258>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	ca8080e7          	jalr	-856(ra) # 80000564 <panic>
    release(&ftable.lock);
    800048c4:	00033517          	auipc	a0,0x33
    800048c8:	9d450513          	addi	a0,a0,-1580 # 80037298 <ftable>
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	396080e7          	jalr	918(ra) # 80000c62 <release>
  }
}
    800048d4:	70e2                	ld	ra,56(sp)
    800048d6:	7442                	ld	s0,48(sp)
    800048d8:	74a2                	ld	s1,40(sp)
    800048da:	7902                	ld	s2,32(sp)
    800048dc:	69e2                	ld	s3,24(sp)
    800048de:	6a42                	ld	s4,16(sp)
    800048e0:	6aa2                	ld	s5,8(sp)
    800048e2:	6121                	addi	sp,sp,64
    800048e4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048e6:	85d6                	mv	a1,s5
    800048e8:	8552                	mv	a0,s4
    800048ea:	00000097          	auipc	ra,0x0
    800048ee:	354080e7          	jalr	852(ra) # 80004c3e <pipeclose>
    800048f2:	b7cd                	j	800048d4 <fileclose+0xa8>

00000000800048f4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048f4:	715d                	addi	sp,sp,-80
    800048f6:	e486                	sd	ra,72(sp)
    800048f8:	e0a2                	sd	s0,64(sp)
    800048fa:	fc26                	sd	s1,56(sp)
    800048fc:	f84a                	sd	s2,48(sp)
    800048fe:	f44e                	sd	s3,40(sp)
    80004900:	0880                	addi	s0,sp,80
    80004902:	84aa                	mv	s1,a0
    80004904:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004906:	ffffd097          	auipc	ra,0xffffd
    8000490a:	24a080e7          	jalr	586(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000490e:	409c                	lw	a5,0(s1)
    80004910:	37f9                	addiw	a5,a5,-2
    80004912:	4705                	li	a4,1
    80004914:	04f76763          	bltu	a4,a5,80004962 <filestat+0x6e>
    80004918:	892a                	mv	s2,a0
    ilock(f->ip);
    8000491a:	6c88                	ld	a0,24(s1)
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	084080e7          	jalr	132(ra) # 800039a0 <ilock>
    stati(f->ip, &st);
    80004924:	fb840593          	addi	a1,s0,-72
    80004928:	6c88                	ld	a0,24(s1)
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	300080e7          	jalr	768(ra) # 80003c2a <stati>
    iunlock(f->ip);
    80004932:	6c88                	ld	a0,24(s1)
    80004934:	fffff097          	auipc	ra,0xfffff
    80004938:	12e080e7          	jalr	302(ra) # 80003a62 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000493c:	46e1                	li	a3,24
    8000493e:	fb840613          	addi	a2,s0,-72
    80004942:	85ce                	mv	a1,s3
    80004944:	05893503          	ld	a0,88(s2)
    80004948:	ffffd097          	auipc	ra,0xffffd
    8000494c:	eb8080e7          	jalr	-328(ra) # 80001800 <copyout>
    80004950:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004954:	60a6                	ld	ra,72(sp)
    80004956:	6406                	ld	s0,64(sp)
    80004958:	74e2                	ld	s1,56(sp)
    8000495a:	7942                	ld	s2,48(sp)
    8000495c:	79a2                	ld	s3,40(sp)
    8000495e:	6161                	addi	sp,sp,80
    80004960:	8082                	ret
  return -1;
    80004962:	557d                	li	a0,-1
    80004964:	bfc5                	j	80004954 <filestat+0x60>

0000000080004966 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004966:	7179                	addi	sp,sp,-48
    80004968:	f406                	sd	ra,40(sp)
    8000496a:	f022                	sd	s0,32(sp)
    8000496c:	ec26                	sd	s1,24(sp)
    8000496e:	e84a                	sd	s2,16(sp)
    80004970:	e44e                	sd	s3,8(sp)
    80004972:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004974:	00854783          	lbu	a5,8(a0)
    80004978:	c7c5                	beqz	a5,80004a20 <fileread+0xba>
    8000497a:	84aa                	mv	s1,a0
    8000497c:	89ae                	mv	s3,a1
    8000497e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004980:	411c                	lw	a5,0(a0)
    80004982:	4705                	li	a4,1
    80004984:	04e78963          	beq	a5,a4,800049d6 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004988:	470d                	li	a4,3
    8000498a:	04e78d63          	beq	a5,a4,800049e4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    8000498e:	4709                	li	a4,2
    80004990:	08e79063          	bne	a5,a4,80004a10 <fileread+0xaa>
    ilock(f->ip);
    80004994:	6d08                	ld	a0,24(a0)
    80004996:	fffff097          	auipc	ra,0xfffff
    8000499a:	00a080e7          	jalr	10(ra) # 800039a0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000499e:	874a                	mv	a4,s2
    800049a0:	5094                	lw	a3,32(s1)
    800049a2:	864e                	mv	a2,s3
    800049a4:	4585                	li	a1,1
    800049a6:	6c88                	ld	a0,24(s1)
    800049a8:	fffff097          	auipc	ra,0xfffff
    800049ac:	2ac080e7          	jalr	684(ra) # 80003c54 <readi>
    800049b0:	892a                	mv	s2,a0
    800049b2:	00a05563          	blez	a0,800049bc <fileread+0x56>
      f->off += r;
    800049b6:	509c                	lw	a5,32(s1)
    800049b8:	9fa9                	addw	a5,a5,a0
    800049ba:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049bc:	6c88                	ld	a0,24(s1)
    800049be:	fffff097          	auipc	ra,0xfffff
    800049c2:	0a4080e7          	jalr	164(ra) # 80003a62 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049c6:	854a                	mv	a0,s2
    800049c8:	70a2                	ld	ra,40(sp)
    800049ca:	7402                	ld	s0,32(sp)
    800049cc:	64e2                	ld	s1,24(sp)
    800049ce:	6942                	ld	s2,16(sp)
    800049d0:	69a2                	ld	s3,8(sp)
    800049d2:	6145                	addi	sp,sp,48
    800049d4:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049d6:	6908                	ld	a0,16(a0)
    800049d8:	00000097          	auipc	ra,0x0
    800049dc:	3c8080e7          	jalr	968(ra) # 80004da0 <piperead>
    800049e0:	892a                	mv	s2,a0
    800049e2:	b7d5                	j	800049c6 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049e4:	02451783          	lh	a5,36(a0)
    800049e8:	03079693          	slli	a3,a5,0x30
    800049ec:	92c1                	srli	a3,a3,0x30
    800049ee:	4725                	li	a4,9
    800049f0:	02d76a63          	bltu	a4,a3,80004a24 <fileread+0xbe>
    800049f4:	0792                	slli	a5,a5,0x4
    800049f6:	00033717          	auipc	a4,0x33
    800049fa:	80270713          	addi	a4,a4,-2046 # 800371f8 <devsw>
    800049fe:	97ba                	add	a5,a5,a4
    80004a00:	639c                	ld	a5,0(a5)
    80004a02:	c39d                	beqz	a5,80004a28 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004a04:	86b2                	mv	a3,a2
    80004a06:	862e                	mv	a2,a1
    80004a08:	4585                	li	a1,1
    80004a0a:	9782                	jalr	a5
    80004a0c:	892a                	mv	s2,a0
    80004a0e:	bf65                	j	800049c6 <fileread+0x60>
    panic("fileread");
    80004a10:	00005517          	auipc	a0,0x5
    80004a14:	27050513          	addi	a0,a0,624 # 80009c80 <syscalls+0x268>
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	b4c080e7          	jalr	-1204(ra) # 80000564 <panic>
    return -1;
    80004a20:	597d                	li	s2,-1
    80004a22:	b755                	j	800049c6 <fileread+0x60>
      return -1;
    80004a24:	597d                	li	s2,-1
    80004a26:	b745                	j	800049c6 <fileread+0x60>
    80004a28:	597d                	li	s2,-1
    80004a2a:	bf71                	j	800049c6 <fileread+0x60>

0000000080004a2c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a2c:	715d                	addi	sp,sp,-80
    80004a2e:	e486                	sd	ra,72(sp)
    80004a30:	e0a2                	sd	s0,64(sp)
    80004a32:	fc26                	sd	s1,56(sp)
    80004a34:	f84a                	sd	s2,48(sp)
    80004a36:	f44e                	sd	s3,40(sp)
    80004a38:	f052                	sd	s4,32(sp)
    80004a3a:	ec56                	sd	s5,24(sp)
    80004a3c:	e85a                	sd	s6,16(sp)
    80004a3e:	e45e                	sd	s7,8(sp)
    80004a40:	e062                	sd	s8,0(sp)
    80004a42:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a44:	00954783          	lbu	a5,9(a0)
    80004a48:	10078863          	beqz	a5,80004b58 <filewrite+0x12c>
    80004a4c:	892a                	mv	s2,a0
    80004a4e:	8aae                	mv	s5,a1
    80004a50:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a52:	411c                	lw	a5,0(a0)
    80004a54:	4705                	li	a4,1
    80004a56:	02e78263          	beq	a5,a4,80004a7a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a5a:	470d                	li	a4,3
    80004a5c:	02e78663          	beq	a5,a4,80004a88 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004a60:	4709                	li	a4,2
    80004a62:	0ee79363          	bne	a5,a4,80004b48 <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a66:	0ac05f63          	blez	a2,80004b24 <filewrite+0xf8>
    int i = 0;
    80004a6a:	4981                	li	s3,0
    80004a6c:	6b05                	lui	s6,0x1
    80004a6e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a72:	6b85                	lui	s7,0x1
    80004a74:	c00b8b9b          	addiw	s7,s7,-1024
    80004a78:	a871                	j	80004b14 <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    80004a7a:	6908                	ld	a0,16(a0)
    80004a7c:	00000097          	auipc	ra,0x0
    80004a80:	232080e7          	jalr	562(ra) # 80004cae <pipewrite>
    80004a84:	8a2a                	mv	s4,a0
    80004a86:	a055                	j	80004b2a <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a88:	02451783          	lh	a5,36(a0)
    80004a8c:	03079693          	slli	a3,a5,0x30
    80004a90:	92c1                	srli	a3,a3,0x30
    80004a92:	4725                	li	a4,9
    80004a94:	0cd76463          	bltu	a4,a3,80004b5c <filewrite+0x130>
    80004a98:	0792                	slli	a5,a5,0x4
    80004a9a:	00032717          	auipc	a4,0x32
    80004a9e:	75e70713          	addi	a4,a4,1886 # 800371f8 <devsw>
    80004aa2:	97ba                	add	a5,a5,a4
    80004aa4:	679c                	ld	a5,8(a5)
    80004aa6:	cfcd                	beqz	a5,80004b60 <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004aa8:	86b2                	mv	a3,a2
    80004aaa:	862e                	mv	a2,a1
    80004aac:	4585                	li	a1,1
    80004aae:	9782                	jalr	a5
    80004ab0:	8a2a                	mv	s4,a0
    80004ab2:	a8a5                	j	80004b2a <filewrite+0xfe>
    80004ab4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	8aa080e7          	jalr	-1878(ra) # 80004362 <begin_op>
      ilock(f->ip);
    80004ac0:	01893503          	ld	a0,24(s2)
    80004ac4:	fffff097          	auipc	ra,0xfffff
    80004ac8:	edc080e7          	jalr	-292(ra) # 800039a0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004acc:	8762                	mv	a4,s8
    80004ace:	02092683          	lw	a3,32(s2)
    80004ad2:	01598633          	add	a2,s3,s5
    80004ad6:	4585                	li	a1,1
    80004ad8:	01893503          	ld	a0,24(s2)
    80004adc:	fffff097          	auipc	ra,0xfffff
    80004ae0:	270080e7          	jalr	624(ra) # 80003d4c <writei>
    80004ae4:	84aa                	mv	s1,a0
    80004ae6:	00a05763          	blez	a0,80004af4 <filewrite+0xc8>
        f->off += r;
    80004aea:	02092783          	lw	a5,32(s2)
    80004aee:	9fa9                	addw	a5,a5,a0
    80004af0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004af4:	01893503          	ld	a0,24(s2)
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	f6a080e7          	jalr	-150(ra) # 80003a62 <iunlock>
      end_op();
    80004b00:	00000097          	auipc	ra,0x0
    80004b04:	8e2080e7          	jalr	-1822(ra) # 800043e2 <end_op>

      if(r != n1){
    80004b08:	009c1f63          	bne	s8,s1,80004b26 <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    80004b0c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b10:	0149db63          	bge	s3,s4,80004b26 <filewrite+0xfa>
      int n1 = n - i;
    80004b14:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b18:	84be                	mv	s1,a5
    80004b1a:	2781                	sext.w	a5,a5
    80004b1c:	f8fb5ce3          	bge	s6,a5,80004ab4 <filewrite+0x88>
    80004b20:	84de                	mv	s1,s7
    80004b22:	bf49                	j	80004ab4 <filewrite+0x88>
    int i = 0;
    80004b24:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b26:	013a1f63          	bne	s4,s3,80004b44 <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b2a:	8552                	mv	a0,s4
    80004b2c:	60a6                	ld	ra,72(sp)
    80004b2e:	6406                	ld	s0,64(sp)
    80004b30:	74e2                	ld	s1,56(sp)
    80004b32:	7942                	ld	s2,48(sp)
    80004b34:	79a2                	ld	s3,40(sp)
    80004b36:	7a02                	ld	s4,32(sp)
    80004b38:	6ae2                	ld	s5,24(sp)
    80004b3a:	6b42                	ld	s6,16(sp)
    80004b3c:	6ba2                	ld	s7,8(sp)
    80004b3e:	6c02                	ld	s8,0(sp)
    80004b40:	6161                	addi	sp,sp,80
    80004b42:	8082                	ret
    ret = (i == n ? n : -1);
    80004b44:	5a7d                	li	s4,-1
    80004b46:	b7d5                	j	80004b2a <filewrite+0xfe>
    panic("filewrite");
    80004b48:	00005517          	auipc	a0,0x5
    80004b4c:	14850513          	addi	a0,a0,328 # 80009c90 <syscalls+0x278>
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	a14080e7          	jalr	-1516(ra) # 80000564 <panic>
    return -1;
    80004b58:	5a7d                	li	s4,-1
    80004b5a:	bfc1                	j	80004b2a <filewrite+0xfe>
      return -1;
    80004b5c:	5a7d                	li	s4,-1
    80004b5e:	b7f1                	j	80004b2a <filewrite+0xfe>
    80004b60:	5a7d                	li	s4,-1
    80004b62:	b7e1                	j	80004b2a <filewrite+0xfe>

0000000080004b64 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b64:	7179                	addi	sp,sp,-48
    80004b66:	f406                	sd	ra,40(sp)
    80004b68:	f022                	sd	s0,32(sp)
    80004b6a:	ec26                	sd	s1,24(sp)
    80004b6c:	e84a                	sd	s2,16(sp)
    80004b6e:	e44e                	sd	s3,8(sp)
    80004b70:	e052                	sd	s4,0(sp)
    80004b72:	1800                	addi	s0,sp,48
    80004b74:	84aa                	mv	s1,a0
    80004b76:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b78:	0005b023          	sd	zero,0(a1)
    80004b7c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b80:	00000097          	auipc	ra,0x0
    80004b84:	bf0080e7          	jalr	-1040(ra) # 80004770 <filealloc>
    80004b88:	e088                	sd	a0,0(s1)
    80004b8a:	c551                	beqz	a0,80004c16 <pipealloc+0xb2>
    80004b8c:	00000097          	auipc	ra,0x0
    80004b90:	be4080e7          	jalr	-1052(ra) # 80004770 <filealloc>
    80004b94:	00aa3023          	sd	a0,0(s4)
    80004b98:	c92d                	beqz	a0,80004c0a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b9a:	ffffc097          	auipc	ra,0xffffc
    80004b9e:	ea8080e7          	jalr	-344(ra) # 80000a42 <kalloc>
    80004ba2:	892a                	mv	s2,a0
    80004ba4:	c125                	beqz	a0,80004c04 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ba6:	4985                	li	s3,1
    80004ba8:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004bac:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004bb0:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004bb4:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004bb8:	00005597          	auipc	a1,0x5
    80004bbc:	0e858593          	addi	a1,a1,232 # 80009ca0 <syscalls+0x288>
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	efc080e7          	jalr	-260(ra) # 80000abc <initlock>
  (*f0)->type = FD_PIPE;
    80004bc8:	609c                	ld	a5,0(s1)
    80004bca:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bce:	609c                	ld	a5,0(s1)
    80004bd0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bd4:	609c                	ld	a5,0(s1)
    80004bd6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bda:	609c                	ld	a5,0(s1)
    80004bdc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004be0:	000a3783          	ld	a5,0(s4)
    80004be4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004be8:	000a3783          	ld	a5,0(s4)
    80004bec:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bf0:	000a3783          	ld	a5,0(s4)
    80004bf4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bf8:	000a3783          	ld	a5,0(s4)
    80004bfc:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c00:	4501                	li	a0,0
    80004c02:	a025                	j	80004c2a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c04:	6088                	ld	a0,0(s1)
    80004c06:	e501                	bnez	a0,80004c0e <pipealloc+0xaa>
    80004c08:	a039                	j	80004c16 <pipealloc+0xb2>
    80004c0a:	6088                	ld	a0,0(s1)
    80004c0c:	c51d                	beqz	a0,80004c3a <pipealloc+0xd6>
    fileclose(*f0);
    80004c0e:	00000097          	auipc	ra,0x0
    80004c12:	c1e080e7          	jalr	-994(ra) # 8000482c <fileclose>
  if(*f1)
    80004c16:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c1a:	557d                	li	a0,-1
  if(*f1)
    80004c1c:	c799                	beqz	a5,80004c2a <pipealloc+0xc6>
    fileclose(*f1);
    80004c1e:	853e                	mv	a0,a5
    80004c20:	00000097          	auipc	ra,0x0
    80004c24:	c0c080e7          	jalr	-1012(ra) # 8000482c <fileclose>
  return -1;
    80004c28:	557d                	li	a0,-1
}
    80004c2a:	70a2                	ld	ra,40(sp)
    80004c2c:	7402                	ld	s0,32(sp)
    80004c2e:	64e2                	ld	s1,24(sp)
    80004c30:	6942                	ld	s2,16(sp)
    80004c32:	69a2                	ld	s3,8(sp)
    80004c34:	6a02                	ld	s4,0(sp)
    80004c36:	6145                	addi	sp,sp,48
    80004c38:	8082                	ret
  return -1;
    80004c3a:	557d                	li	a0,-1
    80004c3c:	b7fd                	j	80004c2a <pipealloc+0xc6>

0000000080004c3e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c3e:	1101                	addi	sp,sp,-32
    80004c40:	ec06                	sd	ra,24(sp)
    80004c42:	e822                	sd	s0,16(sp)
    80004c44:	e426                	sd	s1,8(sp)
    80004c46:	e04a                	sd	s2,0(sp)
    80004c48:	1000                	addi	s0,sp,32
    80004c4a:	84aa                	mv	s1,a0
    80004c4c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	f44080e7          	jalr	-188(ra) # 80000b92 <acquire>
  if(writable){
    80004c56:	02090d63          	beqz	s2,80004c90 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c5a:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004c5e:	22048513          	addi	a0,s1,544
    80004c62:	ffffe097          	auipc	ra,0xffffe
    80004c66:	9dc080e7          	jalr	-1572(ra) # 8000263e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c6a:	2284b783          	ld	a5,552(s1)
    80004c6e:	eb95                	bnez	a5,80004ca2 <pipeclose+0x64>
    release(&pi->lock);
    80004c70:	8526                	mv	a0,s1
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	ff0080e7          	jalr	-16(ra) # 80000c62 <release>
    kfree((char*)pi);
    80004c7a:	8526                	mv	a0,s1
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	cc0080e7          	jalr	-832(ra) # 8000093c <kfree>
  } else
    release(&pi->lock);
}
    80004c84:	60e2                	ld	ra,24(sp)
    80004c86:	6442                	ld	s0,16(sp)
    80004c88:	64a2                	ld	s1,8(sp)
    80004c8a:	6902                	ld	s2,0(sp)
    80004c8c:	6105                	addi	sp,sp,32
    80004c8e:	8082                	ret
    pi->readopen = 0;
    80004c90:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004c94:	22448513          	addi	a0,s1,548
    80004c98:	ffffe097          	auipc	ra,0xffffe
    80004c9c:	9a6080e7          	jalr	-1626(ra) # 8000263e <wakeup>
    80004ca0:	b7e9                	j	80004c6a <pipeclose+0x2c>
    release(&pi->lock);
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	ffffc097          	auipc	ra,0xffffc
    80004ca8:	fbe080e7          	jalr	-66(ra) # 80000c62 <release>
}
    80004cac:	bfe1                	j	80004c84 <pipeclose+0x46>

0000000080004cae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cae:	711d                	addi	sp,sp,-96
    80004cb0:	ec86                	sd	ra,88(sp)
    80004cb2:	e8a2                	sd	s0,80(sp)
    80004cb4:	e4a6                	sd	s1,72(sp)
    80004cb6:	e0ca                	sd	s2,64(sp)
    80004cb8:	fc4e                	sd	s3,56(sp)
    80004cba:	f852                	sd	s4,48(sp)
    80004cbc:	f456                	sd	s5,40(sp)
    80004cbe:	f05a                	sd	s6,32(sp)
    80004cc0:	ec5e                	sd	s7,24(sp)
    80004cc2:	e862                	sd	s8,16(sp)
    80004cc4:	1080                	addi	s0,sp,96
    80004cc6:	84aa                	mv	s1,a0
    80004cc8:	8aae                	mv	s5,a1
    80004cca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ccc:	ffffd097          	auipc	ra,0xffffd
    80004cd0:	e84080e7          	jalr	-380(ra) # 80001b50 <myproc>
    80004cd4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	eba080e7          	jalr	-326(ra) # 80000b92 <acquire>
  while(i < n){
    80004ce0:	0b405363          	blez	s4,80004d86 <pipewrite+0xd8>
  int i = 0;
    80004ce4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ce6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ce8:	22048c13          	addi	s8,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004cec:	22448b93          	addi	s7,s1,548
    80004cf0:	a089                	j	80004d32 <pipewrite+0x84>
      release(&pi->lock);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	f6e080e7          	jalr	-146(ra) # 80000c62 <release>
      return -1;
    80004cfc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cfe:	854a                	mv	a0,s2
    80004d00:	60e6                	ld	ra,88(sp)
    80004d02:	6446                	ld	s0,80(sp)
    80004d04:	64a6                	ld	s1,72(sp)
    80004d06:	6906                	ld	s2,64(sp)
    80004d08:	79e2                	ld	s3,56(sp)
    80004d0a:	7a42                	ld	s4,48(sp)
    80004d0c:	7aa2                	ld	s5,40(sp)
    80004d0e:	7b02                	ld	s6,32(sp)
    80004d10:	6be2                	ld	s7,24(sp)
    80004d12:	6c42                	ld	s8,16(sp)
    80004d14:	6125                	addi	sp,sp,96
    80004d16:	8082                	ret
      wakeup(&pi->nread);
    80004d18:	8562                	mv	a0,s8
    80004d1a:	ffffe097          	auipc	ra,0xffffe
    80004d1e:	924080e7          	jalr	-1756(ra) # 8000263e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d22:	85a6                	mv	a1,s1
    80004d24:	855e                	mv	a0,s7
    80004d26:	ffffd097          	auipc	ra,0xffffd
    80004d2a:	798080e7          	jalr	1944(ra) # 800024be <sleep>
  while(i < n){
    80004d2e:	05495d63          	bge	s2,s4,80004d88 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004d32:	2284a783          	lw	a5,552(s1)
    80004d36:	dfd5                	beqz	a5,80004cf2 <pipewrite+0x44>
    80004d38:	0389a783          	lw	a5,56(s3)
    80004d3c:	fbdd                	bnez	a5,80004cf2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d3e:	2204a783          	lw	a5,544(s1)
    80004d42:	2244a703          	lw	a4,548(s1)
    80004d46:	2007879b          	addiw	a5,a5,512
    80004d4a:	fcf707e3          	beq	a4,a5,80004d18 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d4e:	4685                	li	a3,1
    80004d50:	01590633          	add	a2,s2,s5
    80004d54:	faf40593          	addi	a1,s0,-81
    80004d58:	0589b503          	ld	a0,88(s3)
    80004d5c:	ffffd097          	auipc	ra,0xffffd
    80004d60:	b30080e7          	jalr	-1232(ra) # 8000188c <copyin>
    80004d64:	03650263          	beq	a0,s6,80004d88 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d68:	2244a783          	lw	a5,548(s1)
    80004d6c:	0017871b          	addiw	a4,a5,1
    80004d70:	22e4a223          	sw	a4,548(s1)
    80004d74:	1ff7f793          	andi	a5,a5,511
    80004d78:	97a6                	add	a5,a5,s1
    80004d7a:	faf44703          	lbu	a4,-81(s0)
    80004d7e:	02e78023          	sb	a4,32(a5)
      i++;
    80004d82:	2905                	addiw	s2,s2,1
    80004d84:	b76d                	j	80004d2e <pipewrite+0x80>
  int i = 0;
    80004d86:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d88:	22048513          	addi	a0,s1,544
    80004d8c:	ffffe097          	auipc	ra,0xffffe
    80004d90:	8b2080e7          	jalr	-1870(ra) # 8000263e <wakeup>
  release(&pi->lock);
    80004d94:	8526                	mv	a0,s1
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	ecc080e7          	jalr	-308(ra) # 80000c62 <release>
  return i;
    80004d9e:	b785                	j	80004cfe <pipewrite+0x50>

0000000080004da0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004da0:	715d                	addi	sp,sp,-80
    80004da2:	e486                	sd	ra,72(sp)
    80004da4:	e0a2                	sd	s0,64(sp)
    80004da6:	fc26                	sd	s1,56(sp)
    80004da8:	f84a                	sd	s2,48(sp)
    80004daa:	f44e                	sd	s3,40(sp)
    80004dac:	f052                	sd	s4,32(sp)
    80004dae:	ec56                	sd	s5,24(sp)
    80004db0:	e85a                	sd	s6,16(sp)
    80004db2:	0880                	addi	s0,sp,80
    80004db4:	84aa                	mv	s1,a0
    80004db6:	892e                	mv	s2,a1
    80004db8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004dba:	ffffd097          	auipc	ra,0xffffd
    80004dbe:	d96080e7          	jalr	-618(ra) # 80001b50 <myproc>
    80004dc2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dc4:	8526                	mv	a0,s1
    80004dc6:	ffffc097          	auipc	ra,0xffffc
    80004dca:	dcc080e7          	jalr	-564(ra) # 80000b92 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dce:	2204a703          	lw	a4,544(s1)
    80004dd2:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dd6:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dda:	02f71463          	bne	a4,a5,80004e02 <piperead+0x62>
    80004dde:	22c4a783          	lw	a5,556(s1)
    80004de2:	c385                	beqz	a5,80004e02 <piperead+0x62>
    if(pr->killed){
    80004de4:	038a2783          	lw	a5,56(s4)
    80004de8:	ebc1                	bnez	a5,80004e78 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dea:	85a6                	mv	a1,s1
    80004dec:	854e                	mv	a0,s3
    80004dee:	ffffd097          	auipc	ra,0xffffd
    80004df2:	6d0080e7          	jalr	1744(ra) # 800024be <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004df6:	2204a703          	lw	a4,544(s1)
    80004dfa:	2244a783          	lw	a5,548(s1)
    80004dfe:	fef700e3          	beq	a4,a5,80004dde <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e02:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e04:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e06:	05505363          	blez	s5,80004e4c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004e0a:	2204a783          	lw	a5,544(s1)
    80004e0e:	2244a703          	lw	a4,548(s1)
    80004e12:	02f70d63          	beq	a4,a5,80004e4c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e16:	0017871b          	addiw	a4,a5,1
    80004e1a:	22e4a023          	sw	a4,544(s1)
    80004e1e:	1ff7f793          	andi	a5,a5,511
    80004e22:	97a6                	add	a5,a5,s1
    80004e24:	0207c783          	lbu	a5,32(a5)
    80004e28:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e2c:	4685                	li	a3,1
    80004e2e:	fbf40613          	addi	a2,s0,-65
    80004e32:	85ca                	mv	a1,s2
    80004e34:	058a3503          	ld	a0,88(s4)
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	9c8080e7          	jalr	-1592(ra) # 80001800 <copyout>
    80004e40:	01650663          	beq	a0,s6,80004e4c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e44:	2985                	addiw	s3,s3,1
    80004e46:	0905                	addi	s2,s2,1
    80004e48:	fd3a91e3          	bne	s5,s3,80004e0a <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e4c:	22448513          	addi	a0,s1,548
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	7ee080e7          	jalr	2030(ra) # 8000263e <wakeup>
  release(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	e08080e7          	jalr	-504(ra) # 80000c62 <release>
  return i;
}
    80004e62:	854e                	mv	a0,s3
    80004e64:	60a6                	ld	ra,72(sp)
    80004e66:	6406                	ld	s0,64(sp)
    80004e68:	74e2                	ld	s1,56(sp)
    80004e6a:	7942                	ld	s2,48(sp)
    80004e6c:	79a2                	ld	s3,40(sp)
    80004e6e:	7a02                	ld	s4,32(sp)
    80004e70:	6ae2                	ld	s5,24(sp)
    80004e72:	6b42                	ld	s6,16(sp)
    80004e74:	6161                	addi	sp,sp,80
    80004e76:	8082                	ret
      release(&pi->lock);
    80004e78:	8526                	mv	a0,s1
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	de8080e7          	jalr	-536(ra) # 80000c62 <release>
      return -1;
    80004e82:	59fd                	li	s3,-1
    80004e84:	bff9                	j	80004e62 <piperead+0xc2>

0000000080004e86 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e86:	de010113          	addi	sp,sp,-544
    80004e8a:	20113c23          	sd	ra,536(sp)
    80004e8e:	20813823          	sd	s0,528(sp)
    80004e92:	20913423          	sd	s1,520(sp)
    80004e96:	21213023          	sd	s2,512(sp)
    80004e9a:	ffce                	sd	s3,504(sp)
    80004e9c:	fbd2                	sd	s4,496(sp)
    80004e9e:	f7d6                	sd	s5,488(sp)
    80004ea0:	f3da                	sd	s6,480(sp)
    80004ea2:	efde                	sd	s7,472(sp)
    80004ea4:	ebe2                	sd	s8,464(sp)
    80004ea6:	e7e6                	sd	s9,456(sp)
    80004ea8:	e3ea                	sd	s10,448(sp)
    80004eaa:	ff6e                	sd	s11,440(sp)
    80004eac:	1400                	addi	s0,sp,544
    80004eae:	892a                	mv	s2,a0
    80004eb0:	dea43423          	sd	a0,-536(s0)
    80004eb4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004eb8:	ffffd097          	auipc	ra,0xffffd
    80004ebc:	c98080e7          	jalr	-872(ra) # 80001b50 <myproc>
    80004ec0:	84aa                	mv	s1,a0

  begin_op();
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	4a0080e7          	jalr	1184(ra) # 80004362 <begin_op>

  if((ip = namei(path)) == 0){
    80004eca:	854a                	mv	a0,s2
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	28a080e7          	jalr	650(ra) # 80004156 <namei>
    80004ed4:	c93d                	beqz	a0,80004f4a <exec+0xc4>
    80004ed6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ed8:	fffff097          	auipc	ra,0xfffff
    80004edc:	ac8080e7          	jalr	-1336(ra) # 800039a0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ee0:	04000713          	li	a4,64
    80004ee4:	4681                	li	a3,0
    80004ee6:	e5040613          	addi	a2,s0,-432
    80004eea:	4581                	li	a1,0
    80004eec:	8556                	mv	a0,s5
    80004eee:	fffff097          	auipc	ra,0xfffff
    80004ef2:	d66080e7          	jalr	-666(ra) # 80003c54 <readi>
    80004ef6:	04000793          	li	a5,64
    80004efa:	00f51a63          	bne	a0,a5,80004f0e <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004efe:	e5042703          	lw	a4,-432(s0)
    80004f02:	464c47b7          	lui	a5,0x464c4
    80004f06:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f0a:	04f70663          	beq	a4,a5,80004f56 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f0e:	8556                	mv	a0,s5
    80004f10:	fffff097          	auipc	ra,0xfffff
    80004f14:	cf2080e7          	jalr	-782(ra) # 80003c02 <iunlockput>
    end_op();
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	4ca080e7          	jalr	1226(ra) # 800043e2 <end_op>
  }
  return -1;
    80004f20:	557d                	li	a0,-1
}
    80004f22:	21813083          	ld	ra,536(sp)
    80004f26:	21013403          	ld	s0,528(sp)
    80004f2a:	20813483          	ld	s1,520(sp)
    80004f2e:	20013903          	ld	s2,512(sp)
    80004f32:	79fe                	ld	s3,504(sp)
    80004f34:	7a5e                	ld	s4,496(sp)
    80004f36:	7abe                	ld	s5,488(sp)
    80004f38:	7b1e                	ld	s6,480(sp)
    80004f3a:	6bfe                	ld	s7,472(sp)
    80004f3c:	6c5e                	ld	s8,464(sp)
    80004f3e:	6cbe                	ld	s9,456(sp)
    80004f40:	6d1e                	ld	s10,448(sp)
    80004f42:	7dfa                	ld	s11,440(sp)
    80004f44:	22010113          	addi	sp,sp,544
    80004f48:	8082                	ret
    end_op();
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	498080e7          	jalr	1176(ra) # 800043e2 <end_op>
    return -1;
    80004f52:	557d                	li	a0,-1
    80004f54:	b7f9                	j	80004f22 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f56:	8526                	mv	a0,s1
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	cbc080e7          	jalr	-836(ra) # 80001c14 <proc_pagetable>
    80004f60:	8b2a                	mv	s6,a0
    80004f62:	d555                	beqz	a0,80004f0e <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f64:	e7042783          	lw	a5,-400(s0)
    80004f68:	e8845703          	lhu	a4,-376(s0)
    80004f6c:	c735                	beqz	a4,80004fd8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f6e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f70:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004f74:	6a05                	lui	s4,0x1
    80004f76:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f7a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f7e:	6d85                	lui	s11,0x1
    80004f80:	7d7d                	lui	s10,0xfffff
    80004f82:	ac1d                	j	800051b8 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f84:	00005517          	auipc	a0,0x5
    80004f88:	d2450513          	addi	a0,a0,-732 # 80009ca8 <syscalls+0x290>
    80004f8c:	ffffb097          	auipc	ra,0xffffb
    80004f90:	5d8080e7          	jalr	1496(ra) # 80000564 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f94:	874a                	mv	a4,s2
    80004f96:	009c86bb          	addw	a3,s9,s1
    80004f9a:	4581                	li	a1,0
    80004f9c:	8556                	mv	a0,s5
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	cb6080e7          	jalr	-842(ra) # 80003c54 <readi>
    80004fa6:	2501                	sext.w	a0,a0
    80004fa8:	1aa91863          	bne	s2,a0,80005158 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004fac:	009d84bb          	addw	s1,s11,s1
    80004fb0:	013d09bb          	addw	s3,s10,s3
    80004fb4:	1f74f263          	bgeu	s1,s7,80005198 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004fb8:	02049593          	slli	a1,s1,0x20
    80004fbc:	9181                	srli	a1,a1,0x20
    80004fbe:	95e2                	add	a1,a1,s8
    80004fc0:	855a                	mv	a0,s6
    80004fc2:	ffffc097          	auipc	ra,0xffffc
    80004fc6:	2d0080e7          	jalr	720(ra) # 80001292 <walkaddr>
    80004fca:	862a                	mv	a2,a0
    if(pa == 0)
    80004fcc:	dd45                	beqz	a0,80004f84 <exec+0xfe>
      n = PGSIZE;
    80004fce:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fd0:	fd49f2e3          	bgeu	s3,s4,80004f94 <exec+0x10e>
      n = sz - i;
    80004fd4:	894e                	mv	s2,s3
    80004fd6:	bf7d                	j	80004f94 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fd8:	4481                	li	s1,0
  iunlockput(ip);
    80004fda:	8556                	mv	a0,s5
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	c26080e7          	jalr	-986(ra) # 80003c02 <iunlockput>
  end_op();
    80004fe4:	fffff097          	auipc	ra,0xfffff
    80004fe8:	3fe080e7          	jalr	1022(ra) # 800043e2 <end_op>
  p = myproc();
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	b64080e7          	jalr	-1180(ra) # 80001b50 <myproc>
    80004ff4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004ff6:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004ffa:	6785                	lui	a5,0x1
    80004ffc:	17fd                	addi	a5,a5,-1
    80004ffe:	94be                	add	s1,s1,a5
    80005000:	77fd                	lui	a5,0xfffff
    80005002:	8fe5                	and	a5,a5,s1
    80005004:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005008:	6609                	lui	a2,0x2
    8000500a:	963e                	add	a2,a2,a5
    8000500c:	85be                	mv	a1,a5
    8000500e:	855a                	mv	a0,s6
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	616080e7          	jalr	1558(ra) # 80001626 <uvmalloc>
    80005018:	8c2a                	mv	s8,a0
  ip = 0;
    8000501a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000501c:	12050e63          	beqz	a0,80005158 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005020:	75f9                	lui	a1,0xffffe
    80005022:	95aa                	add	a1,a1,a0
    80005024:	855a                	mv	a0,s6
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	7a8080e7          	jalr	1960(ra) # 800017ce <uvmclear>
  stackbase = sp - PGSIZE;
    8000502e:	7afd                	lui	s5,0xfffff
    80005030:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005032:	df043783          	ld	a5,-528(s0)
    80005036:	6388                	ld	a0,0(a5)
    80005038:	c925                	beqz	a0,800050a8 <exec+0x222>
    8000503a:	e9040993          	addi	s3,s0,-368
    8000503e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005042:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005044:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005046:	ffffc097          	auipc	ra,0xffffc
    8000504a:	fd8080e7          	jalr	-40(ra) # 8000101e <strlen>
    8000504e:	0015079b          	addiw	a5,a0,1
    80005052:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005056:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000505a:	13596363          	bltu	s2,s5,80005180 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000505e:	df043d83          	ld	s11,-528(s0)
    80005062:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005066:	8552                	mv	a0,s4
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	fb6080e7          	jalr	-74(ra) # 8000101e <strlen>
    80005070:	0015069b          	addiw	a3,a0,1
    80005074:	8652                	mv	a2,s4
    80005076:	85ca                	mv	a1,s2
    80005078:	855a                	mv	a0,s6
    8000507a:	ffffc097          	auipc	ra,0xffffc
    8000507e:	786080e7          	jalr	1926(ra) # 80001800 <copyout>
    80005082:	10054363          	bltz	a0,80005188 <exec+0x302>
    ustack[argc] = sp;
    80005086:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000508a:	0485                	addi	s1,s1,1
    8000508c:	008d8793          	addi	a5,s11,8
    80005090:	def43823          	sd	a5,-528(s0)
    80005094:	008db503          	ld	a0,8(s11)
    80005098:	c911                	beqz	a0,800050ac <exec+0x226>
    if(argc >= MAXARG)
    8000509a:	09a1                	addi	s3,s3,8
    8000509c:	fb3c95e3          	bne	s9,s3,80005046 <exec+0x1c0>
  sz = sz1;
    800050a0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050a4:	4a81                	li	s5,0
    800050a6:	a84d                	j	80005158 <exec+0x2d2>
  sp = sz;
    800050a8:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800050aa:	4481                	li	s1,0
  ustack[argc] = 0;
    800050ac:	00349793          	slli	a5,s1,0x3
    800050b0:	f9040713          	addi	a4,s0,-112
    800050b4:	97ba                	add	a5,a5,a4
    800050b6:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffc6b40>
  sp -= (argc+1) * sizeof(uint64);
    800050ba:	00148693          	addi	a3,s1,1
    800050be:	068e                	slli	a3,a3,0x3
    800050c0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050c4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050c8:	01597663          	bgeu	s2,s5,800050d4 <exec+0x24e>
  sz = sz1;
    800050cc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050d0:	4a81                	li	s5,0
    800050d2:	a059                	j	80005158 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050d4:	e9040613          	addi	a2,s0,-368
    800050d8:	85ca                	mv	a1,s2
    800050da:	855a                	mv	a0,s6
    800050dc:	ffffc097          	auipc	ra,0xffffc
    800050e0:	724080e7          	jalr	1828(ra) # 80001800 <copyout>
    800050e4:	0a054663          	bltz	a0,80005190 <exec+0x30a>
  p->trapframe->a1 = sp;
    800050e8:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800050ec:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050f0:	de843783          	ld	a5,-536(s0)
    800050f4:	0007c703          	lbu	a4,0(a5)
    800050f8:	cf11                	beqz	a4,80005114 <exec+0x28e>
    800050fa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050fc:	02f00693          	li	a3,47
    80005100:	a039                	j	8000510e <exec+0x288>
      last = s+1;
    80005102:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005106:	0785                	addi	a5,a5,1
    80005108:	fff7c703          	lbu	a4,-1(a5)
    8000510c:	c701                	beqz	a4,80005114 <exec+0x28e>
    if(*s == '/')
    8000510e:	fed71ce3          	bne	a4,a3,80005106 <exec+0x280>
    80005112:	bfc5                	j	80005102 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005114:	4641                	li	a2,16
    80005116:	de843583          	ld	a1,-536(s0)
    8000511a:	160b8513          	addi	a0,s7,352
    8000511e:	ffffc097          	auipc	ra,0xffffc
    80005122:	ece080e7          	jalr	-306(ra) # 80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    80005126:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000512a:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000512e:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005132:	060bb783          	ld	a5,96(s7)
    80005136:	e6843703          	ld	a4,-408(s0)
    8000513a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000513c:	060bb783          	ld	a5,96(s7)
    80005140:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005144:	85ea                	mv	a1,s10
    80005146:	ffffd097          	auipc	ra,0xffffd
    8000514a:	c02080e7          	jalr	-1022(ra) # 80001d48 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000514e:	0004851b          	sext.w	a0,s1
    80005152:	bbc1                	j	80004f22 <exec+0x9c>
    80005154:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005158:	df843583          	ld	a1,-520(s0)
    8000515c:	855a                	mv	a0,s6
    8000515e:	ffffd097          	auipc	ra,0xffffd
    80005162:	bea080e7          	jalr	-1046(ra) # 80001d48 <proc_freepagetable>
  if(ip){
    80005166:	da0a94e3          	bnez	s5,80004f0e <exec+0x88>
  return -1;
    8000516a:	557d                	li	a0,-1
    8000516c:	bb5d                	j	80004f22 <exec+0x9c>
    8000516e:	de943c23          	sd	s1,-520(s0)
    80005172:	b7dd                	j	80005158 <exec+0x2d2>
    80005174:	de943c23          	sd	s1,-520(s0)
    80005178:	b7c5                	j	80005158 <exec+0x2d2>
    8000517a:	de943c23          	sd	s1,-520(s0)
    8000517e:	bfe9                	j	80005158 <exec+0x2d2>
  sz = sz1;
    80005180:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005184:	4a81                	li	s5,0
    80005186:	bfc9                	j	80005158 <exec+0x2d2>
  sz = sz1;
    80005188:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000518c:	4a81                	li	s5,0
    8000518e:	b7e9                	j	80005158 <exec+0x2d2>
  sz = sz1;
    80005190:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005194:	4a81                	li	s5,0
    80005196:	b7c9                	j	80005158 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005198:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000519c:	e0843783          	ld	a5,-504(s0)
    800051a0:	0017869b          	addiw	a3,a5,1
    800051a4:	e0d43423          	sd	a3,-504(s0)
    800051a8:	e0043783          	ld	a5,-512(s0)
    800051ac:	0387879b          	addiw	a5,a5,56
    800051b0:	e8845703          	lhu	a4,-376(s0)
    800051b4:	e2e6d3e3          	bge	a3,a4,80004fda <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051b8:	2781                	sext.w	a5,a5
    800051ba:	e0f43023          	sd	a5,-512(s0)
    800051be:	03800713          	li	a4,56
    800051c2:	86be                	mv	a3,a5
    800051c4:	e1840613          	addi	a2,s0,-488
    800051c8:	4581                	li	a1,0
    800051ca:	8556                	mv	a0,s5
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	a88080e7          	jalr	-1400(ra) # 80003c54 <readi>
    800051d4:	03800793          	li	a5,56
    800051d8:	f6f51ee3          	bne	a0,a5,80005154 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800051dc:	e1842783          	lw	a5,-488(s0)
    800051e0:	4705                	li	a4,1
    800051e2:	fae79de3          	bne	a5,a4,8000519c <exec+0x316>
    if(ph.memsz < ph.filesz)
    800051e6:	e4043603          	ld	a2,-448(s0)
    800051ea:	e3843783          	ld	a5,-456(s0)
    800051ee:	f8f660e3          	bltu	a2,a5,8000516e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051f2:	e2843783          	ld	a5,-472(s0)
    800051f6:	963e                	add	a2,a2,a5
    800051f8:	f6f66ee3          	bltu	a2,a5,80005174 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051fc:	85a6                	mv	a1,s1
    800051fe:	855a                	mv	a0,s6
    80005200:	ffffc097          	auipc	ra,0xffffc
    80005204:	426080e7          	jalr	1062(ra) # 80001626 <uvmalloc>
    80005208:	dea43c23          	sd	a0,-520(s0)
    8000520c:	d53d                	beqz	a0,8000517a <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    8000520e:	e2843c03          	ld	s8,-472(s0)
    80005212:	de043783          	ld	a5,-544(s0)
    80005216:	00fc77b3          	and	a5,s8,a5
    8000521a:	ff9d                	bnez	a5,80005158 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000521c:	e2042c83          	lw	s9,-480(s0)
    80005220:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005224:	f60b8ae3          	beqz	s7,80005198 <exec+0x312>
    80005228:	89de                	mv	s3,s7
    8000522a:	4481                	li	s1,0
    8000522c:	b371                	j	80004fb8 <exec+0x132>

000000008000522e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000522e:	7179                	addi	sp,sp,-48
    80005230:	f406                	sd	ra,40(sp)
    80005232:	f022                	sd	s0,32(sp)
    80005234:	ec26                	sd	s1,24(sp)
    80005236:	e84a                	sd	s2,16(sp)
    80005238:	1800                	addi	s0,sp,48
    8000523a:	892e                	mv	s2,a1
    8000523c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000523e:	fdc40593          	addi	a1,s0,-36
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	bee080e7          	jalr	-1042(ra) # 80002e30 <argint>
    8000524a:	04054063          	bltz	a0,8000528a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000524e:	fdc42703          	lw	a4,-36(s0)
    80005252:	47bd                	li	a5,15
    80005254:	02e7ed63          	bltu	a5,a4,8000528e <argfd+0x60>
    80005258:	ffffd097          	auipc	ra,0xffffd
    8000525c:	8f8080e7          	jalr	-1800(ra) # 80001b50 <myproc>
    80005260:	fdc42703          	lw	a4,-36(s0)
    80005264:	01a70793          	addi	a5,a4,26
    80005268:	078e                	slli	a5,a5,0x3
    8000526a:	953e                	add	a0,a0,a5
    8000526c:	651c                	ld	a5,8(a0)
    8000526e:	c395                	beqz	a5,80005292 <argfd+0x64>
    return -1;
  if(pfd)
    80005270:	00090463          	beqz	s2,80005278 <argfd+0x4a>
    *pfd = fd;
    80005274:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005278:	4501                	li	a0,0
  if(pf)
    8000527a:	c091                	beqz	s1,8000527e <argfd+0x50>
    *pf = f;
    8000527c:	e09c                	sd	a5,0(s1)
}
    8000527e:	70a2                	ld	ra,40(sp)
    80005280:	7402                	ld	s0,32(sp)
    80005282:	64e2                	ld	s1,24(sp)
    80005284:	6942                	ld	s2,16(sp)
    80005286:	6145                	addi	sp,sp,48
    80005288:	8082                	ret
    return -1;
    8000528a:	557d                	li	a0,-1
    8000528c:	bfcd                	j	8000527e <argfd+0x50>
    return -1;
    8000528e:	557d                	li	a0,-1
    80005290:	b7fd                	j	8000527e <argfd+0x50>
    80005292:	557d                	li	a0,-1
    80005294:	b7ed                	j	8000527e <argfd+0x50>

0000000080005296 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005296:	1101                	addi	sp,sp,-32
    80005298:	ec06                	sd	ra,24(sp)
    8000529a:	e822                	sd	s0,16(sp)
    8000529c:	e426                	sd	s1,8(sp)
    8000529e:	1000                	addi	s0,sp,32
    800052a0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052a2:	ffffd097          	auipc	ra,0xffffd
    800052a6:	8ae080e7          	jalr	-1874(ra) # 80001b50 <myproc>
    800052aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052ac:	0d850793          	addi	a5,a0,216
    800052b0:	4501                	li	a0,0
    800052b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052b4:	6398                	ld	a4,0(a5)
    800052b6:	cb19                	beqz	a4,800052cc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052b8:	2505                	addiw	a0,a0,1
    800052ba:	07a1                	addi	a5,a5,8
    800052bc:	fed51ce3          	bne	a0,a3,800052b4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052c0:	557d                	li	a0,-1
}
    800052c2:	60e2                	ld	ra,24(sp)
    800052c4:	6442                	ld	s0,16(sp)
    800052c6:	64a2                	ld	s1,8(sp)
    800052c8:	6105                	addi	sp,sp,32
    800052ca:	8082                	ret
      p->ofile[fd] = f;
    800052cc:	01a50793          	addi	a5,a0,26
    800052d0:	078e                	slli	a5,a5,0x3
    800052d2:	963e                	add	a2,a2,a5
    800052d4:	e604                	sd	s1,8(a2)
      return fd;
    800052d6:	b7f5                	j	800052c2 <fdalloc+0x2c>

00000000800052d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052d8:	715d                	addi	sp,sp,-80
    800052da:	e486                	sd	ra,72(sp)
    800052dc:	e0a2                	sd	s0,64(sp)
    800052de:	fc26                	sd	s1,56(sp)
    800052e0:	f84a                	sd	s2,48(sp)
    800052e2:	f44e                	sd	s3,40(sp)
    800052e4:	f052                	sd	s4,32(sp)
    800052e6:	ec56                	sd	s5,24(sp)
    800052e8:	0880                	addi	s0,sp,80
    800052ea:	89ae                	mv	s3,a1
    800052ec:	8ab2                	mv	s5,a2
    800052ee:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052f0:	fb040593          	addi	a1,s0,-80
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	e80080e7          	jalr	-384(ra) # 80004174 <nameiparent>
    800052fc:	892a                	mv	s2,a0
    800052fe:	12050e63          	beqz	a0,8000543a <create+0x162>
    return 0;

  ilock(dp);
    80005302:	ffffe097          	auipc	ra,0xffffe
    80005306:	69e080e7          	jalr	1694(ra) # 800039a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000530a:	4601                	li	a2,0
    8000530c:	fb040593          	addi	a1,s0,-80
    80005310:	854a                	mv	a0,s2
    80005312:	fffff097          	auipc	ra,0xfffff
    80005316:	b72080e7          	jalr	-1166(ra) # 80003e84 <dirlookup>
    8000531a:	84aa                	mv	s1,a0
    8000531c:	c921                	beqz	a0,8000536c <create+0x94>
    iunlockput(dp);
    8000531e:	854a                	mv	a0,s2
    80005320:	fffff097          	auipc	ra,0xfffff
    80005324:	8e2080e7          	jalr	-1822(ra) # 80003c02 <iunlockput>
    ilock(ip);
    80005328:	8526                	mv	a0,s1
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	676080e7          	jalr	1654(ra) # 800039a0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005332:	2981                	sext.w	s3,s3
    80005334:	4789                	li	a5,2
    80005336:	02f99463          	bne	s3,a5,8000535e <create+0x86>
    8000533a:	04c4d783          	lhu	a5,76(s1)
    8000533e:	37f9                	addiw	a5,a5,-2
    80005340:	17c2                	slli	a5,a5,0x30
    80005342:	93c1                	srli	a5,a5,0x30
    80005344:	4705                	li	a4,1
    80005346:	00f76c63          	bltu	a4,a5,8000535e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000534a:	8526                	mv	a0,s1
    8000534c:	60a6                	ld	ra,72(sp)
    8000534e:	6406                	ld	s0,64(sp)
    80005350:	74e2                	ld	s1,56(sp)
    80005352:	7942                	ld	s2,48(sp)
    80005354:	79a2                	ld	s3,40(sp)
    80005356:	7a02                	ld	s4,32(sp)
    80005358:	6ae2                	ld	s5,24(sp)
    8000535a:	6161                	addi	sp,sp,80
    8000535c:	8082                	ret
    iunlockput(ip);
    8000535e:	8526                	mv	a0,s1
    80005360:	fffff097          	auipc	ra,0xfffff
    80005364:	8a2080e7          	jalr	-1886(ra) # 80003c02 <iunlockput>
    return 0;
    80005368:	4481                	li	s1,0
    8000536a:	b7c5                	j	8000534a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000536c:	85ce                	mv	a1,s3
    8000536e:	00092503          	lw	a0,0(s2)
    80005372:	ffffe097          	auipc	ra,0xffffe
    80005376:	496080e7          	jalr	1174(ra) # 80003808 <ialloc>
    8000537a:	84aa                	mv	s1,a0
    8000537c:	c521                	beqz	a0,800053c4 <create+0xec>
  ilock(ip);
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	622080e7          	jalr	1570(ra) # 800039a0 <ilock>
  ip->major = major;
    80005386:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    8000538a:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    8000538e:	4a05                	li	s4,1
    80005390:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	540080e7          	jalr	1344(ra) # 800038d6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000539e:	2981                	sext.w	s3,s3
    800053a0:	03498a63          	beq	s3,s4,800053d4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053a4:	40d0                	lw	a2,4(s1)
    800053a6:	fb040593          	addi	a1,s0,-80
    800053aa:	854a                	mv	a0,s2
    800053ac:	fffff097          	auipc	ra,0xfffff
    800053b0:	ce8080e7          	jalr	-792(ra) # 80004094 <dirlink>
    800053b4:	06054b63          	bltz	a0,8000542a <create+0x152>
  iunlockput(dp);
    800053b8:	854a                	mv	a0,s2
    800053ba:	fffff097          	auipc	ra,0xfffff
    800053be:	848080e7          	jalr	-1976(ra) # 80003c02 <iunlockput>
  return ip;
    800053c2:	b761                	j	8000534a <create+0x72>
    panic("create: ialloc");
    800053c4:	00005517          	auipc	a0,0x5
    800053c8:	90450513          	addi	a0,a0,-1788 # 80009cc8 <syscalls+0x2b0>
    800053cc:	ffffb097          	auipc	ra,0xffffb
    800053d0:	198080e7          	jalr	408(ra) # 80000564 <panic>
    dp->nlink++;  // for ".."
    800053d4:	05295783          	lhu	a5,82(s2)
    800053d8:	2785                	addiw	a5,a5,1
    800053da:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800053de:	854a                	mv	a0,s2
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	4f6080e7          	jalr	1270(ra) # 800038d6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053e8:	40d0                	lw	a2,4(s1)
    800053ea:	00005597          	auipc	a1,0x5
    800053ee:	8ee58593          	addi	a1,a1,-1810 # 80009cd8 <syscalls+0x2c0>
    800053f2:	8526                	mv	a0,s1
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	ca0080e7          	jalr	-864(ra) # 80004094 <dirlink>
    800053fc:	00054f63          	bltz	a0,8000541a <create+0x142>
    80005400:	00492603          	lw	a2,4(s2)
    80005404:	00005597          	auipc	a1,0x5
    80005408:	8dc58593          	addi	a1,a1,-1828 # 80009ce0 <syscalls+0x2c8>
    8000540c:	8526                	mv	a0,s1
    8000540e:	fffff097          	auipc	ra,0xfffff
    80005412:	c86080e7          	jalr	-890(ra) # 80004094 <dirlink>
    80005416:	f80557e3          	bgez	a0,800053a4 <create+0xcc>
      panic("create dots");
    8000541a:	00005517          	auipc	a0,0x5
    8000541e:	8ce50513          	addi	a0,a0,-1842 # 80009ce8 <syscalls+0x2d0>
    80005422:	ffffb097          	auipc	ra,0xffffb
    80005426:	142080e7          	jalr	322(ra) # 80000564 <panic>
    panic("create: dirlink");
    8000542a:	00005517          	auipc	a0,0x5
    8000542e:	8ce50513          	addi	a0,a0,-1842 # 80009cf8 <syscalls+0x2e0>
    80005432:	ffffb097          	auipc	ra,0xffffb
    80005436:	132080e7          	jalr	306(ra) # 80000564 <panic>
    return 0;
    8000543a:	84aa                	mv	s1,a0
    8000543c:	b739                	j	8000534a <create+0x72>

000000008000543e <sys_dup>:
{
    8000543e:	7179                	addi	sp,sp,-48
    80005440:	f406                	sd	ra,40(sp)
    80005442:	f022                	sd	s0,32(sp)
    80005444:	ec26                	sd	s1,24(sp)
    80005446:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005448:	fd840613          	addi	a2,s0,-40
    8000544c:	4581                	li	a1,0
    8000544e:	4501                	li	a0,0
    80005450:	00000097          	auipc	ra,0x0
    80005454:	dde080e7          	jalr	-546(ra) # 8000522e <argfd>
    return -1;
    80005458:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000545a:	02054363          	bltz	a0,80005480 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000545e:	fd843503          	ld	a0,-40(s0)
    80005462:	00000097          	auipc	ra,0x0
    80005466:	e34080e7          	jalr	-460(ra) # 80005296 <fdalloc>
    8000546a:	84aa                	mv	s1,a0
    return -1;
    8000546c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000546e:	00054963          	bltz	a0,80005480 <sys_dup+0x42>
  filedup(f);
    80005472:	fd843503          	ld	a0,-40(s0)
    80005476:	fffff097          	auipc	ra,0xfffff
    8000547a:	364080e7          	jalr	868(ra) # 800047da <filedup>
  return fd;
    8000547e:	87a6                	mv	a5,s1
}
    80005480:	853e                	mv	a0,a5
    80005482:	70a2                	ld	ra,40(sp)
    80005484:	7402                	ld	s0,32(sp)
    80005486:	64e2                	ld	s1,24(sp)
    80005488:	6145                	addi	sp,sp,48
    8000548a:	8082                	ret

000000008000548c <sys_read>:
{
    8000548c:	7179                	addi	sp,sp,-48
    8000548e:	f406                	sd	ra,40(sp)
    80005490:	f022                	sd	s0,32(sp)
    80005492:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005494:	fe840613          	addi	a2,s0,-24
    80005498:	4581                	li	a1,0
    8000549a:	4501                	li	a0,0
    8000549c:	00000097          	auipc	ra,0x0
    800054a0:	d92080e7          	jalr	-622(ra) # 8000522e <argfd>
    return -1;
    800054a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a6:	04054163          	bltz	a0,800054e8 <sys_read+0x5c>
    800054aa:	fe440593          	addi	a1,s0,-28
    800054ae:	4509                	li	a0,2
    800054b0:	ffffe097          	auipc	ra,0xffffe
    800054b4:	980080e7          	jalr	-1664(ra) # 80002e30 <argint>
    return -1;
    800054b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ba:	02054763          	bltz	a0,800054e8 <sys_read+0x5c>
    800054be:	fd840593          	addi	a1,s0,-40
    800054c2:	4505                	li	a0,1
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	98e080e7          	jalr	-1650(ra) # 80002e52 <argaddr>
    return -1;
    800054cc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ce:	00054d63          	bltz	a0,800054e8 <sys_read+0x5c>
  return fileread(f, p, n);
    800054d2:	fe442603          	lw	a2,-28(s0)
    800054d6:	fd843583          	ld	a1,-40(s0)
    800054da:	fe843503          	ld	a0,-24(s0)
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	488080e7          	jalr	1160(ra) # 80004966 <fileread>
    800054e6:	87aa                	mv	a5,a0
}
    800054e8:	853e                	mv	a0,a5
    800054ea:	70a2                	ld	ra,40(sp)
    800054ec:	7402                	ld	s0,32(sp)
    800054ee:	6145                	addi	sp,sp,48
    800054f0:	8082                	ret

00000000800054f2 <sys_write>:
{
    800054f2:	7179                	addi	sp,sp,-48
    800054f4:	f406                	sd	ra,40(sp)
    800054f6:	f022                	sd	s0,32(sp)
    800054f8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054fa:	fe840613          	addi	a2,s0,-24
    800054fe:	4581                	li	a1,0
    80005500:	4501                	li	a0,0
    80005502:	00000097          	auipc	ra,0x0
    80005506:	d2c080e7          	jalr	-724(ra) # 8000522e <argfd>
    return -1;
    8000550a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000550c:	04054163          	bltz	a0,8000554e <sys_write+0x5c>
    80005510:	fe440593          	addi	a1,s0,-28
    80005514:	4509                	li	a0,2
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	91a080e7          	jalr	-1766(ra) # 80002e30 <argint>
    return -1;
    8000551e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005520:	02054763          	bltz	a0,8000554e <sys_write+0x5c>
    80005524:	fd840593          	addi	a1,s0,-40
    80005528:	4505                	li	a0,1
    8000552a:	ffffe097          	auipc	ra,0xffffe
    8000552e:	928080e7          	jalr	-1752(ra) # 80002e52 <argaddr>
    return -1;
    80005532:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005534:	00054d63          	bltz	a0,8000554e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005538:	fe442603          	lw	a2,-28(s0)
    8000553c:	fd843583          	ld	a1,-40(s0)
    80005540:	fe843503          	ld	a0,-24(s0)
    80005544:	fffff097          	auipc	ra,0xfffff
    80005548:	4e8080e7          	jalr	1256(ra) # 80004a2c <filewrite>
    8000554c:	87aa                	mv	a5,a0
}
    8000554e:	853e                	mv	a0,a5
    80005550:	70a2                	ld	ra,40(sp)
    80005552:	7402                	ld	s0,32(sp)
    80005554:	6145                	addi	sp,sp,48
    80005556:	8082                	ret

0000000080005558 <sys_close>:
{
    80005558:	1101                	addi	sp,sp,-32
    8000555a:	ec06                	sd	ra,24(sp)
    8000555c:	e822                	sd	s0,16(sp)
    8000555e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005560:	fe040613          	addi	a2,s0,-32
    80005564:	fec40593          	addi	a1,s0,-20
    80005568:	4501                	li	a0,0
    8000556a:	00000097          	auipc	ra,0x0
    8000556e:	cc4080e7          	jalr	-828(ra) # 8000522e <argfd>
    return -1;
    80005572:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005574:	02054463          	bltz	a0,8000559c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005578:	ffffc097          	auipc	ra,0xffffc
    8000557c:	5d8080e7          	jalr	1496(ra) # 80001b50 <myproc>
    80005580:	fec42783          	lw	a5,-20(s0)
    80005584:	07e9                	addi	a5,a5,26
    80005586:	078e                	slli	a5,a5,0x3
    80005588:	97aa                	add	a5,a5,a0
    8000558a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000558e:	fe043503          	ld	a0,-32(s0)
    80005592:	fffff097          	auipc	ra,0xfffff
    80005596:	29a080e7          	jalr	666(ra) # 8000482c <fileclose>
  return 0;
    8000559a:	4781                	li	a5,0
}
    8000559c:	853e                	mv	a0,a5
    8000559e:	60e2                	ld	ra,24(sp)
    800055a0:	6442                	ld	s0,16(sp)
    800055a2:	6105                	addi	sp,sp,32
    800055a4:	8082                	ret

00000000800055a6 <sys_fstat>:
{
    800055a6:	1101                	addi	sp,sp,-32
    800055a8:	ec06                	sd	ra,24(sp)
    800055aa:	e822                	sd	s0,16(sp)
    800055ac:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055ae:	fe840613          	addi	a2,s0,-24
    800055b2:	4581                	li	a1,0
    800055b4:	4501                	li	a0,0
    800055b6:	00000097          	auipc	ra,0x0
    800055ba:	c78080e7          	jalr	-904(ra) # 8000522e <argfd>
    return -1;
    800055be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055c0:	02054563          	bltz	a0,800055ea <sys_fstat+0x44>
    800055c4:	fe040593          	addi	a1,s0,-32
    800055c8:	4505                	li	a0,1
    800055ca:	ffffe097          	auipc	ra,0xffffe
    800055ce:	888080e7          	jalr	-1912(ra) # 80002e52 <argaddr>
    return -1;
    800055d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055d4:	00054b63          	bltz	a0,800055ea <sys_fstat+0x44>
  return filestat(f, st);
    800055d8:	fe043583          	ld	a1,-32(s0)
    800055dc:	fe843503          	ld	a0,-24(s0)
    800055e0:	fffff097          	auipc	ra,0xfffff
    800055e4:	314080e7          	jalr	788(ra) # 800048f4 <filestat>
    800055e8:	87aa                	mv	a5,a0
}
    800055ea:	853e                	mv	a0,a5
    800055ec:	60e2                	ld	ra,24(sp)
    800055ee:	6442                	ld	s0,16(sp)
    800055f0:	6105                	addi	sp,sp,32
    800055f2:	8082                	ret

00000000800055f4 <sys_link>:
{
    800055f4:	7169                	addi	sp,sp,-304
    800055f6:	f606                	sd	ra,296(sp)
    800055f8:	f222                	sd	s0,288(sp)
    800055fa:	ee26                	sd	s1,280(sp)
    800055fc:	ea4a                	sd	s2,272(sp)
    800055fe:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005600:	08000613          	li	a2,128
    80005604:	ed040593          	addi	a1,s0,-304
    80005608:	4501                	li	a0,0
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	86a080e7          	jalr	-1942(ra) # 80002e74 <argstr>
    return -1;
    80005612:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005614:	10054e63          	bltz	a0,80005730 <sys_link+0x13c>
    80005618:	08000613          	li	a2,128
    8000561c:	f5040593          	addi	a1,s0,-176
    80005620:	4505                	li	a0,1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	852080e7          	jalr	-1966(ra) # 80002e74 <argstr>
    return -1;
    8000562a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000562c:	10054263          	bltz	a0,80005730 <sys_link+0x13c>
  begin_op();
    80005630:	fffff097          	auipc	ra,0xfffff
    80005634:	d32080e7          	jalr	-718(ra) # 80004362 <begin_op>
  if((ip = namei(old)) == 0){
    80005638:	ed040513          	addi	a0,s0,-304
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	b1a080e7          	jalr	-1254(ra) # 80004156 <namei>
    80005644:	84aa                	mv	s1,a0
    80005646:	c551                	beqz	a0,800056d2 <sys_link+0xde>
  ilock(ip);
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	358080e7          	jalr	856(ra) # 800039a0 <ilock>
  if(ip->type == T_DIR){
    80005650:	04c49703          	lh	a4,76(s1)
    80005654:	4785                	li	a5,1
    80005656:	08f70463          	beq	a4,a5,800056de <sys_link+0xea>
  ip->nlink++;
    8000565a:	0524d783          	lhu	a5,82(s1)
    8000565e:	2785                	addiw	a5,a5,1
    80005660:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005664:	8526                	mv	a0,s1
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	270080e7          	jalr	624(ra) # 800038d6 <iupdate>
  iunlock(ip);
    8000566e:	8526                	mv	a0,s1
    80005670:	ffffe097          	auipc	ra,0xffffe
    80005674:	3f2080e7          	jalr	1010(ra) # 80003a62 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005678:	fd040593          	addi	a1,s0,-48
    8000567c:	f5040513          	addi	a0,s0,-176
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	af4080e7          	jalr	-1292(ra) # 80004174 <nameiparent>
    80005688:	892a                	mv	s2,a0
    8000568a:	c935                	beqz	a0,800056fe <sys_link+0x10a>
  ilock(dp);
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	314080e7          	jalr	788(ra) # 800039a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005694:	00092703          	lw	a4,0(s2)
    80005698:	409c                	lw	a5,0(s1)
    8000569a:	04f71d63          	bne	a4,a5,800056f4 <sys_link+0x100>
    8000569e:	40d0                	lw	a2,4(s1)
    800056a0:	fd040593          	addi	a1,s0,-48
    800056a4:	854a                	mv	a0,s2
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	9ee080e7          	jalr	-1554(ra) # 80004094 <dirlink>
    800056ae:	04054363          	bltz	a0,800056f4 <sys_link+0x100>
  iunlockput(dp);
    800056b2:	854a                	mv	a0,s2
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	54e080e7          	jalr	1358(ra) # 80003c02 <iunlockput>
  iput(ip);
    800056bc:	8526                	mv	a0,s1
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	49c080e7          	jalr	1180(ra) # 80003b5a <iput>
  end_op();
    800056c6:	fffff097          	auipc	ra,0xfffff
    800056ca:	d1c080e7          	jalr	-740(ra) # 800043e2 <end_op>
  return 0;
    800056ce:	4781                	li	a5,0
    800056d0:	a085                	j	80005730 <sys_link+0x13c>
    end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	d10080e7          	jalr	-752(ra) # 800043e2 <end_op>
    return -1;
    800056da:	57fd                	li	a5,-1
    800056dc:	a891                	j	80005730 <sys_link+0x13c>
    iunlockput(ip);
    800056de:	8526                	mv	a0,s1
    800056e0:	ffffe097          	auipc	ra,0xffffe
    800056e4:	522080e7          	jalr	1314(ra) # 80003c02 <iunlockput>
    end_op();
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	cfa080e7          	jalr	-774(ra) # 800043e2 <end_op>
    return -1;
    800056f0:	57fd                	li	a5,-1
    800056f2:	a83d                	j	80005730 <sys_link+0x13c>
    iunlockput(dp);
    800056f4:	854a                	mv	a0,s2
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	50c080e7          	jalr	1292(ra) # 80003c02 <iunlockput>
  ilock(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	2a0080e7          	jalr	672(ra) # 800039a0 <ilock>
  ip->nlink--;
    80005708:	0524d783          	lhu	a5,82(s1)
    8000570c:	37fd                	addiw	a5,a5,-1
    8000570e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005712:	8526                	mv	a0,s1
    80005714:	ffffe097          	auipc	ra,0xffffe
    80005718:	1c2080e7          	jalr	450(ra) # 800038d6 <iupdate>
  iunlockput(ip);
    8000571c:	8526                	mv	a0,s1
    8000571e:	ffffe097          	auipc	ra,0xffffe
    80005722:	4e4080e7          	jalr	1252(ra) # 80003c02 <iunlockput>
  end_op();
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	cbc080e7          	jalr	-836(ra) # 800043e2 <end_op>
  return -1;
    8000572e:	57fd                	li	a5,-1
}
    80005730:	853e                	mv	a0,a5
    80005732:	70b2                	ld	ra,296(sp)
    80005734:	7412                	ld	s0,288(sp)
    80005736:	64f2                	ld	s1,280(sp)
    80005738:	6952                	ld	s2,272(sp)
    8000573a:	6155                	addi	sp,sp,304
    8000573c:	8082                	ret

000000008000573e <sys_unlink>:
{
    8000573e:	7151                	addi	sp,sp,-240
    80005740:	f586                	sd	ra,232(sp)
    80005742:	f1a2                	sd	s0,224(sp)
    80005744:	eda6                	sd	s1,216(sp)
    80005746:	e9ca                	sd	s2,208(sp)
    80005748:	e5ce                	sd	s3,200(sp)
    8000574a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000574c:	08000613          	li	a2,128
    80005750:	f3040593          	addi	a1,s0,-208
    80005754:	4501                	li	a0,0
    80005756:	ffffd097          	auipc	ra,0xffffd
    8000575a:	71e080e7          	jalr	1822(ra) # 80002e74 <argstr>
    8000575e:	18054163          	bltz	a0,800058e0 <sys_unlink+0x1a2>
  begin_op();
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	c00080e7          	jalr	-1024(ra) # 80004362 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000576a:	fb040593          	addi	a1,s0,-80
    8000576e:	f3040513          	addi	a0,s0,-208
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	a02080e7          	jalr	-1534(ra) # 80004174 <nameiparent>
    8000577a:	84aa                	mv	s1,a0
    8000577c:	c979                	beqz	a0,80005852 <sys_unlink+0x114>
  ilock(dp);
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	222080e7          	jalr	546(ra) # 800039a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005786:	00004597          	auipc	a1,0x4
    8000578a:	55258593          	addi	a1,a1,1362 # 80009cd8 <syscalls+0x2c0>
    8000578e:	fb040513          	addi	a0,s0,-80
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	6d8080e7          	jalr	1752(ra) # 80003e6a <namecmp>
    8000579a:	14050a63          	beqz	a0,800058ee <sys_unlink+0x1b0>
    8000579e:	00004597          	auipc	a1,0x4
    800057a2:	54258593          	addi	a1,a1,1346 # 80009ce0 <syscalls+0x2c8>
    800057a6:	fb040513          	addi	a0,s0,-80
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	6c0080e7          	jalr	1728(ra) # 80003e6a <namecmp>
    800057b2:	12050e63          	beqz	a0,800058ee <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057b6:	f2c40613          	addi	a2,s0,-212
    800057ba:	fb040593          	addi	a1,s0,-80
    800057be:	8526                	mv	a0,s1
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	6c4080e7          	jalr	1732(ra) # 80003e84 <dirlookup>
    800057c8:	892a                	mv	s2,a0
    800057ca:	12050263          	beqz	a0,800058ee <sys_unlink+0x1b0>
  ilock(ip);
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	1d2080e7          	jalr	466(ra) # 800039a0 <ilock>
  if(ip->nlink < 1)
    800057d6:	05291783          	lh	a5,82(s2)
    800057da:	08f05263          	blez	a5,8000585e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057de:	04c91703          	lh	a4,76(s2)
    800057e2:	4785                	li	a5,1
    800057e4:	08f70563          	beq	a4,a5,8000586e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057e8:	4641                	li	a2,16
    800057ea:	4581                	li	a1,0
    800057ec:	fc040513          	addi	a0,s0,-64
    800057f0:	ffffb097          	auipc	ra,0xffffb
    800057f4:	686080e7          	jalr	1670(ra) # 80000e76 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057f8:	4741                	li	a4,16
    800057fa:	f2c42683          	lw	a3,-212(s0)
    800057fe:	fc040613          	addi	a2,s0,-64
    80005802:	4581                	li	a1,0
    80005804:	8526                	mv	a0,s1
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	546080e7          	jalr	1350(ra) # 80003d4c <writei>
    8000580e:	47c1                	li	a5,16
    80005810:	0af51563          	bne	a0,a5,800058ba <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005814:	04c91703          	lh	a4,76(s2)
    80005818:	4785                	li	a5,1
    8000581a:	0af70863          	beq	a4,a5,800058ca <sys_unlink+0x18c>
  iunlockput(dp);
    8000581e:	8526                	mv	a0,s1
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	3e2080e7          	jalr	994(ra) # 80003c02 <iunlockput>
  ip->nlink--;
    80005828:	05295783          	lhu	a5,82(s2)
    8000582c:	37fd                	addiw	a5,a5,-1
    8000582e:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005832:	854a                	mv	a0,s2
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	0a2080e7          	jalr	162(ra) # 800038d6 <iupdate>
  iunlockput(ip);
    8000583c:	854a                	mv	a0,s2
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	3c4080e7          	jalr	964(ra) # 80003c02 <iunlockput>
  end_op();
    80005846:	fffff097          	auipc	ra,0xfffff
    8000584a:	b9c080e7          	jalr	-1124(ra) # 800043e2 <end_op>
  return 0;
    8000584e:	4501                	li	a0,0
    80005850:	a84d                	j	80005902 <sys_unlink+0x1c4>
    end_op();
    80005852:	fffff097          	auipc	ra,0xfffff
    80005856:	b90080e7          	jalr	-1136(ra) # 800043e2 <end_op>
    return -1;
    8000585a:	557d                	li	a0,-1
    8000585c:	a05d                	j	80005902 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000585e:	00004517          	auipc	a0,0x4
    80005862:	4aa50513          	addi	a0,a0,1194 # 80009d08 <syscalls+0x2f0>
    80005866:	ffffb097          	auipc	ra,0xffffb
    8000586a:	cfe080e7          	jalr	-770(ra) # 80000564 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000586e:	05492703          	lw	a4,84(s2)
    80005872:	02000793          	li	a5,32
    80005876:	f6e7f9e3          	bgeu	a5,a4,800057e8 <sys_unlink+0xaa>
    8000587a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000587e:	4741                	li	a4,16
    80005880:	86ce                	mv	a3,s3
    80005882:	f1840613          	addi	a2,s0,-232
    80005886:	4581                	li	a1,0
    80005888:	854a                	mv	a0,s2
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	3ca080e7          	jalr	970(ra) # 80003c54 <readi>
    80005892:	47c1                	li	a5,16
    80005894:	00f51b63          	bne	a0,a5,800058aa <sys_unlink+0x16c>
    if(de.inum != 0)
    80005898:	f1845783          	lhu	a5,-232(s0)
    8000589c:	e7a1                	bnez	a5,800058e4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000589e:	29c1                	addiw	s3,s3,16
    800058a0:	05492783          	lw	a5,84(s2)
    800058a4:	fcf9ede3          	bltu	s3,a5,8000587e <sys_unlink+0x140>
    800058a8:	b781                	j	800057e8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800058aa:	00004517          	auipc	a0,0x4
    800058ae:	47650513          	addi	a0,a0,1142 # 80009d20 <syscalls+0x308>
    800058b2:	ffffb097          	auipc	ra,0xffffb
    800058b6:	cb2080e7          	jalr	-846(ra) # 80000564 <panic>
    panic("unlink: writei");
    800058ba:	00004517          	auipc	a0,0x4
    800058be:	47e50513          	addi	a0,a0,1150 # 80009d38 <syscalls+0x320>
    800058c2:	ffffb097          	auipc	ra,0xffffb
    800058c6:	ca2080e7          	jalr	-862(ra) # 80000564 <panic>
    dp->nlink--;
    800058ca:	0524d783          	lhu	a5,82(s1)
    800058ce:	37fd                	addiw	a5,a5,-1
    800058d0:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    800058d4:	8526                	mv	a0,s1
    800058d6:	ffffe097          	auipc	ra,0xffffe
    800058da:	000080e7          	jalr	ra # 800038d6 <iupdate>
    800058de:	b781                	j	8000581e <sys_unlink+0xe0>
    return -1;
    800058e0:	557d                	li	a0,-1
    800058e2:	a005                	j	80005902 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058e4:	854a                	mv	a0,s2
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	31c080e7          	jalr	796(ra) # 80003c02 <iunlockput>
  iunlockput(dp);
    800058ee:	8526                	mv	a0,s1
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	312080e7          	jalr	786(ra) # 80003c02 <iunlockput>
  end_op();
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	aea080e7          	jalr	-1302(ra) # 800043e2 <end_op>
  return -1;
    80005900:	557d                	li	a0,-1
}
    80005902:	70ae                	ld	ra,232(sp)
    80005904:	740e                	ld	s0,224(sp)
    80005906:	64ee                	ld	s1,216(sp)
    80005908:	694e                	ld	s2,208(sp)
    8000590a:	69ae                	ld	s3,200(sp)
    8000590c:	616d                	addi	sp,sp,240
    8000590e:	8082                	ret

0000000080005910 <sys_open>:

uint64
sys_open(void)
{
    80005910:	7131                	addi	sp,sp,-192
    80005912:	fd06                	sd	ra,184(sp)
    80005914:	f922                	sd	s0,176(sp)
    80005916:	f526                	sd	s1,168(sp)
    80005918:	f14a                	sd	s2,160(sp)
    8000591a:	ed4e                	sd	s3,152(sp)
    8000591c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000591e:	08000613          	li	a2,128
    80005922:	f5040593          	addi	a1,s0,-176
    80005926:	4501                	li	a0,0
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	54c080e7          	jalr	1356(ra) # 80002e74 <argstr>
    return -1;
    80005930:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005932:	0c054163          	bltz	a0,800059f4 <sys_open+0xe4>
    80005936:	f4c40593          	addi	a1,s0,-180
    8000593a:	4505                	li	a0,1
    8000593c:	ffffd097          	auipc	ra,0xffffd
    80005940:	4f4080e7          	jalr	1268(ra) # 80002e30 <argint>
    80005944:	0a054863          	bltz	a0,800059f4 <sys_open+0xe4>

  begin_op();
    80005948:	fffff097          	auipc	ra,0xfffff
    8000594c:	a1a080e7          	jalr	-1510(ra) # 80004362 <begin_op>

  if(omode & O_CREATE){
    80005950:	f4c42783          	lw	a5,-180(s0)
    80005954:	2007f793          	andi	a5,a5,512
    80005958:	cbdd                	beqz	a5,80005a0e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000595a:	4681                	li	a3,0
    8000595c:	4601                	li	a2,0
    8000595e:	4589                	li	a1,2
    80005960:	f5040513          	addi	a0,s0,-176
    80005964:	00000097          	auipc	ra,0x0
    80005968:	974080e7          	jalr	-1676(ra) # 800052d8 <create>
    8000596c:	892a                	mv	s2,a0
    if(ip == 0){
    8000596e:	c959                	beqz	a0,80005a04 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005970:	04c91703          	lh	a4,76(s2)
    80005974:	478d                	li	a5,3
    80005976:	00f71763          	bne	a4,a5,80005984 <sys_open+0x74>
    8000597a:	04e95703          	lhu	a4,78(s2)
    8000597e:	47a5                	li	a5,9
    80005980:	0ce7ec63          	bltu	a5,a4,80005a58 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005984:	fffff097          	auipc	ra,0xfffff
    80005988:	dec080e7          	jalr	-532(ra) # 80004770 <filealloc>
    8000598c:	89aa                	mv	s3,a0
    8000598e:	10050663          	beqz	a0,80005a9a <sys_open+0x18a>
    80005992:	00000097          	auipc	ra,0x0
    80005996:	904080e7          	jalr	-1788(ra) # 80005296 <fdalloc>
    8000599a:	84aa                	mv	s1,a0
    8000599c:	0e054a63          	bltz	a0,80005a90 <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059a0:	04c91703          	lh	a4,76(s2)
    800059a4:	478d                	li	a5,3
    800059a6:	0cf70463          	beq	a4,a5,80005a6e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    800059aa:	4789                	li	a5,2
    800059ac:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    800059b0:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    800059b4:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    800059b8:	f4c42783          	lw	a5,-180(s0)
    800059bc:	0017c713          	xori	a4,a5,1
    800059c0:	8b05                	andi	a4,a4,1
    800059c2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059c6:	0037f713          	andi	a4,a5,3
    800059ca:	00e03733          	snez	a4,a4
    800059ce:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059d2:	4007f793          	andi	a5,a5,1024
    800059d6:	c791                	beqz	a5,800059e2 <sys_open+0xd2>
    800059d8:	04c91703          	lh	a4,76(s2)
    800059dc:	4789                	li	a5,2
    800059de:	0af70363          	beq	a4,a5,80005a84 <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    800059e2:	854a                	mv	a0,s2
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	07e080e7          	jalr	126(ra) # 80003a62 <iunlock>
  end_op();
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	9f6080e7          	jalr	-1546(ra) # 800043e2 <end_op>

  return fd;
}
    800059f4:	8526                	mv	a0,s1
    800059f6:	70ea                	ld	ra,184(sp)
    800059f8:	744a                	ld	s0,176(sp)
    800059fa:	74aa                	ld	s1,168(sp)
    800059fc:	790a                	ld	s2,160(sp)
    800059fe:	69ea                	ld	s3,152(sp)
    80005a00:	6129                	addi	sp,sp,192
    80005a02:	8082                	ret
      end_op();
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	9de080e7          	jalr	-1570(ra) # 800043e2 <end_op>
      return -1;
    80005a0c:	b7e5                	j	800059f4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a0e:	f5040513          	addi	a0,s0,-176
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	744080e7          	jalr	1860(ra) # 80004156 <namei>
    80005a1a:	892a                	mv	s2,a0
    80005a1c:	c905                	beqz	a0,80005a4c <sys_open+0x13c>
    ilock(ip);
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	f82080e7          	jalr	-126(ra) # 800039a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a26:	04c91703          	lh	a4,76(s2)
    80005a2a:	4785                	li	a5,1
    80005a2c:	f4f712e3          	bne	a4,a5,80005970 <sys_open+0x60>
    80005a30:	f4c42783          	lw	a5,-180(s0)
    80005a34:	dba1                	beqz	a5,80005984 <sys_open+0x74>
      iunlockput(ip);
    80005a36:	854a                	mv	a0,s2
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	1ca080e7          	jalr	458(ra) # 80003c02 <iunlockput>
      end_op();
    80005a40:	fffff097          	auipc	ra,0xfffff
    80005a44:	9a2080e7          	jalr	-1630(ra) # 800043e2 <end_op>
      return -1;
    80005a48:	54fd                	li	s1,-1
    80005a4a:	b76d                	j	800059f4 <sys_open+0xe4>
      end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	996080e7          	jalr	-1642(ra) # 800043e2 <end_op>
      return -1;
    80005a54:	54fd                	li	s1,-1
    80005a56:	bf79                	j	800059f4 <sys_open+0xe4>
    iunlockput(ip);
    80005a58:	854a                	mv	a0,s2
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	1a8080e7          	jalr	424(ra) # 80003c02 <iunlockput>
    end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	980080e7          	jalr	-1664(ra) # 800043e2 <end_op>
    return -1;
    80005a6a:	54fd                	li	s1,-1
    80005a6c:	b761                	j	800059f4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a6e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a72:	04e91783          	lh	a5,78(s2)
    80005a76:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005a7a:	05091783          	lh	a5,80(s2)
    80005a7e:	02f99323          	sh	a5,38(s3)
    80005a82:	b73d                	j	800059b0 <sys_open+0xa0>
    itrunc(ip);
    80005a84:	854a                	mv	a0,s2
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	028080e7          	jalr	40(ra) # 80003aae <itrunc>
    80005a8e:	bf91                	j	800059e2 <sys_open+0xd2>
      fileclose(f);
    80005a90:	854e                	mv	a0,s3
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	d9a080e7          	jalr	-614(ra) # 8000482c <fileclose>
    iunlockput(ip);
    80005a9a:	854a                	mv	a0,s2
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	166080e7          	jalr	358(ra) # 80003c02 <iunlockput>
    end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	93e080e7          	jalr	-1730(ra) # 800043e2 <end_op>
    return -1;
    80005aac:	54fd                	li	s1,-1
    80005aae:	b799                	j	800059f4 <sys_open+0xe4>

0000000080005ab0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ab0:	7175                	addi	sp,sp,-144
    80005ab2:	e506                	sd	ra,136(sp)
    80005ab4:	e122                	sd	s0,128(sp)
    80005ab6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	8aa080e7          	jalr	-1878(ra) # 80004362 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ac0:	08000613          	li	a2,128
    80005ac4:	f7040593          	addi	a1,s0,-144
    80005ac8:	4501                	li	a0,0
    80005aca:	ffffd097          	auipc	ra,0xffffd
    80005ace:	3aa080e7          	jalr	938(ra) # 80002e74 <argstr>
    80005ad2:	02054963          	bltz	a0,80005b04 <sys_mkdir+0x54>
    80005ad6:	4681                	li	a3,0
    80005ad8:	4601                	li	a2,0
    80005ada:	4585                	li	a1,1
    80005adc:	f7040513          	addi	a0,s0,-144
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	7f8080e7          	jalr	2040(ra) # 800052d8 <create>
    80005ae8:	cd11                	beqz	a0,80005b04 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	118080e7          	jalr	280(ra) # 80003c02 <iunlockput>
  end_op();
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	8f0080e7          	jalr	-1808(ra) # 800043e2 <end_op>
  return 0;
    80005afa:	4501                	li	a0,0
}
    80005afc:	60aa                	ld	ra,136(sp)
    80005afe:	640a                	ld	s0,128(sp)
    80005b00:	6149                	addi	sp,sp,144
    80005b02:	8082                	ret
    end_op();
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	8de080e7          	jalr	-1826(ra) # 800043e2 <end_op>
    return -1;
    80005b0c:	557d                	li	a0,-1
    80005b0e:	b7fd                	j	80005afc <sys_mkdir+0x4c>

0000000080005b10 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b10:	7135                	addi	sp,sp,-160
    80005b12:	ed06                	sd	ra,152(sp)
    80005b14:	e922                	sd	s0,144(sp)
    80005b16:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	84a080e7          	jalr	-1974(ra) # 80004362 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b20:	08000613          	li	a2,128
    80005b24:	f7040593          	addi	a1,s0,-144
    80005b28:	4501                	li	a0,0
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	34a080e7          	jalr	842(ra) # 80002e74 <argstr>
    80005b32:	04054a63          	bltz	a0,80005b86 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b36:	f6c40593          	addi	a1,s0,-148
    80005b3a:	4505                	li	a0,1
    80005b3c:	ffffd097          	auipc	ra,0xffffd
    80005b40:	2f4080e7          	jalr	756(ra) # 80002e30 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b44:	04054163          	bltz	a0,80005b86 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b48:	f6840593          	addi	a1,s0,-152
    80005b4c:	4509                	li	a0,2
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	2e2080e7          	jalr	738(ra) # 80002e30 <argint>
     argint(1, &major) < 0 ||
    80005b56:	02054863          	bltz	a0,80005b86 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b5a:	f6841683          	lh	a3,-152(s0)
    80005b5e:	f6c41603          	lh	a2,-148(s0)
    80005b62:	458d                	li	a1,3
    80005b64:	f7040513          	addi	a0,s0,-144
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	770080e7          	jalr	1904(ra) # 800052d8 <create>
     argint(2, &minor) < 0 ||
    80005b70:	c919                	beqz	a0,80005b86 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b72:	ffffe097          	auipc	ra,0xffffe
    80005b76:	090080e7          	jalr	144(ra) # 80003c02 <iunlockput>
  end_op();
    80005b7a:	fffff097          	auipc	ra,0xfffff
    80005b7e:	868080e7          	jalr	-1944(ra) # 800043e2 <end_op>
  return 0;
    80005b82:	4501                	li	a0,0
    80005b84:	a031                	j	80005b90 <sys_mknod+0x80>
    end_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	85c080e7          	jalr	-1956(ra) # 800043e2 <end_op>
    return -1;
    80005b8e:	557d                	li	a0,-1
}
    80005b90:	60ea                	ld	ra,152(sp)
    80005b92:	644a                	ld	s0,144(sp)
    80005b94:	610d                	addi	sp,sp,160
    80005b96:	8082                	ret

0000000080005b98 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b98:	7135                	addi	sp,sp,-160
    80005b9a:	ed06                	sd	ra,152(sp)
    80005b9c:	e922                	sd	s0,144(sp)
    80005b9e:	e526                	sd	s1,136(sp)
    80005ba0:	e14a                	sd	s2,128(sp)
    80005ba2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ba4:	ffffc097          	auipc	ra,0xffffc
    80005ba8:	fac080e7          	jalr	-84(ra) # 80001b50 <myproc>
    80005bac:	892a                	mv	s2,a0
  
  begin_op();
    80005bae:	ffffe097          	auipc	ra,0xffffe
    80005bb2:	7b4080e7          	jalr	1972(ra) # 80004362 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005bb6:	08000613          	li	a2,128
    80005bba:	f6040593          	addi	a1,s0,-160
    80005bbe:	4501                	li	a0,0
    80005bc0:	ffffd097          	auipc	ra,0xffffd
    80005bc4:	2b4080e7          	jalr	692(ra) # 80002e74 <argstr>
    80005bc8:	04054b63          	bltz	a0,80005c1e <sys_chdir+0x86>
    80005bcc:	f6040513          	addi	a0,s0,-160
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	586080e7          	jalr	1414(ra) # 80004156 <namei>
    80005bd8:	84aa                	mv	s1,a0
    80005bda:	c131                	beqz	a0,80005c1e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	dc4080e7          	jalr	-572(ra) # 800039a0 <ilock>
  if(ip->type != T_DIR){
    80005be4:	04c49703          	lh	a4,76(s1)
    80005be8:	4785                	li	a5,1
    80005bea:	04f71063          	bne	a4,a5,80005c2a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bee:	8526                	mv	a0,s1
    80005bf0:	ffffe097          	auipc	ra,0xffffe
    80005bf4:	e72080e7          	jalr	-398(ra) # 80003a62 <iunlock>
  iput(p->cwd);
    80005bf8:	15893503          	ld	a0,344(s2)
    80005bfc:	ffffe097          	auipc	ra,0xffffe
    80005c00:	f5e080e7          	jalr	-162(ra) # 80003b5a <iput>
  end_op();
    80005c04:	ffffe097          	auipc	ra,0xffffe
    80005c08:	7de080e7          	jalr	2014(ra) # 800043e2 <end_op>
  p->cwd = ip;
    80005c0c:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c10:	4501                	li	a0,0
}
    80005c12:	60ea                	ld	ra,152(sp)
    80005c14:	644a                	ld	s0,144(sp)
    80005c16:	64aa                	ld	s1,136(sp)
    80005c18:	690a                	ld	s2,128(sp)
    80005c1a:	610d                	addi	sp,sp,160
    80005c1c:	8082                	ret
    end_op();
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	7c4080e7          	jalr	1988(ra) # 800043e2 <end_op>
    return -1;
    80005c26:	557d                	li	a0,-1
    80005c28:	b7ed                	j	80005c12 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	fd6080e7          	jalr	-42(ra) # 80003c02 <iunlockput>
    end_op();
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	7ae080e7          	jalr	1966(ra) # 800043e2 <end_op>
    return -1;
    80005c3c:	557d                	li	a0,-1
    80005c3e:	bfd1                	j	80005c12 <sys_chdir+0x7a>

0000000080005c40 <sys_exec>:

uint64
sys_exec(void)
{
    80005c40:	7145                	addi	sp,sp,-464
    80005c42:	e786                	sd	ra,456(sp)
    80005c44:	e3a2                	sd	s0,448(sp)
    80005c46:	ff26                	sd	s1,440(sp)
    80005c48:	fb4a                	sd	s2,432(sp)
    80005c4a:	f74e                	sd	s3,424(sp)
    80005c4c:	f352                	sd	s4,416(sp)
    80005c4e:	ef56                	sd	s5,408(sp)
    80005c50:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c52:	08000613          	li	a2,128
    80005c56:	f4040593          	addi	a1,s0,-192
    80005c5a:	4501                	li	a0,0
    80005c5c:	ffffd097          	auipc	ra,0xffffd
    80005c60:	218080e7          	jalr	536(ra) # 80002e74 <argstr>
    return -1;
    80005c64:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c66:	0c054a63          	bltz	a0,80005d3a <sys_exec+0xfa>
    80005c6a:	e3840593          	addi	a1,s0,-456
    80005c6e:	4505                	li	a0,1
    80005c70:	ffffd097          	auipc	ra,0xffffd
    80005c74:	1e2080e7          	jalr	482(ra) # 80002e52 <argaddr>
    80005c78:	0c054163          	bltz	a0,80005d3a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c7c:	10000613          	li	a2,256
    80005c80:	4581                	li	a1,0
    80005c82:	e4040513          	addi	a0,s0,-448
    80005c86:	ffffb097          	auipc	ra,0xffffb
    80005c8a:	1f0080e7          	jalr	496(ra) # 80000e76 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c8e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c92:	89a6                	mv	s3,s1
    80005c94:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c96:	02000a13          	li	s4,32
    80005c9a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c9e:	00391793          	slli	a5,s2,0x3
    80005ca2:	e3040593          	addi	a1,s0,-464
    80005ca6:	e3843503          	ld	a0,-456(s0)
    80005caa:	953e                	add	a0,a0,a5
    80005cac:	ffffd097          	auipc	ra,0xffffd
    80005cb0:	0ea080e7          	jalr	234(ra) # 80002d96 <fetchaddr>
    80005cb4:	02054a63          	bltz	a0,80005ce8 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005cb8:	e3043783          	ld	a5,-464(s0)
    80005cbc:	c3b9                	beqz	a5,80005d02 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cbe:	ffffb097          	auipc	ra,0xffffb
    80005cc2:	d84080e7          	jalr	-636(ra) # 80000a42 <kalloc>
    80005cc6:	85aa                	mv	a1,a0
    80005cc8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ccc:	cd11                	beqz	a0,80005ce8 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cce:	6605                	lui	a2,0x1
    80005cd0:	e3043503          	ld	a0,-464(s0)
    80005cd4:	ffffd097          	auipc	ra,0xffffd
    80005cd8:	114080e7          	jalr	276(ra) # 80002de8 <fetchstr>
    80005cdc:	00054663          	bltz	a0,80005ce8 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ce0:	0905                	addi	s2,s2,1
    80005ce2:	09a1                	addi	s3,s3,8
    80005ce4:	fb491be3          	bne	s2,s4,80005c9a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ce8:	10048913          	addi	s2,s1,256
    80005cec:	6088                	ld	a0,0(s1)
    80005cee:	c529                	beqz	a0,80005d38 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	c4c080e7          	jalr	-948(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cf8:	04a1                	addi	s1,s1,8
    80005cfa:	ff2499e3          	bne	s1,s2,80005cec <sys_exec+0xac>
  return -1;
    80005cfe:	597d                	li	s2,-1
    80005d00:	a82d                	j	80005d3a <sys_exec+0xfa>
      argv[i] = 0;
    80005d02:	0a8e                	slli	s5,s5,0x3
    80005d04:	fc040793          	addi	a5,s0,-64
    80005d08:	9abe                	add	s5,s5,a5
    80005d0a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc6ac0>
  int ret = exec(path, argv);
    80005d0e:	e4040593          	addi	a1,s0,-448
    80005d12:	f4040513          	addi	a0,s0,-192
    80005d16:	fffff097          	auipc	ra,0xfffff
    80005d1a:	170080e7          	jalr	368(ra) # 80004e86 <exec>
    80005d1e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d20:	10048993          	addi	s3,s1,256
    80005d24:	6088                	ld	a0,0(s1)
    80005d26:	c911                	beqz	a0,80005d3a <sys_exec+0xfa>
    kfree(argv[i]);
    80005d28:	ffffb097          	auipc	ra,0xffffb
    80005d2c:	c14080e7          	jalr	-1004(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d30:	04a1                	addi	s1,s1,8
    80005d32:	ff3499e3          	bne	s1,s3,80005d24 <sys_exec+0xe4>
    80005d36:	a011                	j	80005d3a <sys_exec+0xfa>
  return -1;
    80005d38:	597d                	li	s2,-1
}
    80005d3a:	854a                	mv	a0,s2
    80005d3c:	60be                	ld	ra,456(sp)
    80005d3e:	641e                	ld	s0,448(sp)
    80005d40:	74fa                	ld	s1,440(sp)
    80005d42:	795a                	ld	s2,432(sp)
    80005d44:	79ba                	ld	s3,424(sp)
    80005d46:	7a1a                	ld	s4,416(sp)
    80005d48:	6afa                	ld	s5,408(sp)
    80005d4a:	6179                	addi	sp,sp,464
    80005d4c:	8082                	ret

0000000080005d4e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d4e:	7139                	addi	sp,sp,-64
    80005d50:	fc06                	sd	ra,56(sp)
    80005d52:	f822                	sd	s0,48(sp)
    80005d54:	f426                	sd	s1,40(sp)
    80005d56:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d58:	ffffc097          	auipc	ra,0xffffc
    80005d5c:	df8080e7          	jalr	-520(ra) # 80001b50 <myproc>
    80005d60:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d62:	fd840593          	addi	a1,s0,-40
    80005d66:	4501                	li	a0,0
    80005d68:	ffffd097          	auipc	ra,0xffffd
    80005d6c:	0ea080e7          	jalr	234(ra) # 80002e52 <argaddr>
    return -1;
    80005d70:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d72:	0e054063          	bltz	a0,80005e52 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d76:	fc840593          	addi	a1,s0,-56
    80005d7a:	fd040513          	addi	a0,s0,-48
    80005d7e:	fffff097          	auipc	ra,0xfffff
    80005d82:	de6080e7          	jalr	-538(ra) # 80004b64 <pipealloc>
    return -1;
    80005d86:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d88:	0c054563          	bltz	a0,80005e52 <sys_pipe+0x104>
  fd0 = -1;
    80005d8c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d90:	fd043503          	ld	a0,-48(s0)
    80005d94:	fffff097          	auipc	ra,0xfffff
    80005d98:	502080e7          	jalr	1282(ra) # 80005296 <fdalloc>
    80005d9c:	fca42223          	sw	a0,-60(s0)
    80005da0:	08054c63          	bltz	a0,80005e38 <sys_pipe+0xea>
    80005da4:	fc843503          	ld	a0,-56(s0)
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	4ee080e7          	jalr	1262(ra) # 80005296 <fdalloc>
    80005db0:	fca42023          	sw	a0,-64(s0)
    80005db4:	06054863          	bltz	a0,80005e24 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db8:	4691                	li	a3,4
    80005dba:	fc440613          	addi	a2,s0,-60
    80005dbe:	fd843583          	ld	a1,-40(s0)
    80005dc2:	6ca8                	ld	a0,88(s1)
    80005dc4:	ffffc097          	auipc	ra,0xffffc
    80005dc8:	a3c080e7          	jalr	-1476(ra) # 80001800 <copyout>
    80005dcc:	02054063          	bltz	a0,80005dec <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dd0:	4691                	li	a3,4
    80005dd2:	fc040613          	addi	a2,s0,-64
    80005dd6:	fd843583          	ld	a1,-40(s0)
    80005dda:	0591                	addi	a1,a1,4
    80005ddc:	6ca8                	ld	a0,88(s1)
    80005dde:	ffffc097          	auipc	ra,0xffffc
    80005de2:	a22080e7          	jalr	-1502(ra) # 80001800 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005de6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de8:	06055563          	bgez	a0,80005e52 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005dec:	fc442783          	lw	a5,-60(s0)
    80005df0:	07e9                	addi	a5,a5,26
    80005df2:	078e                	slli	a5,a5,0x3
    80005df4:	97a6                	add	a5,a5,s1
    80005df6:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005dfa:	fc042503          	lw	a0,-64(s0)
    80005dfe:	0569                	addi	a0,a0,26
    80005e00:	050e                	slli	a0,a0,0x3
    80005e02:	9526                	add	a0,a0,s1
    80005e04:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e08:	fd043503          	ld	a0,-48(s0)
    80005e0c:	fffff097          	auipc	ra,0xfffff
    80005e10:	a20080e7          	jalr	-1504(ra) # 8000482c <fileclose>
    fileclose(wf);
    80005e14:	fc843503          	ld	a0,-56(s0)
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	a14080e7          	jalr	-1516(ra) # 8000482c <fileclose>
    return -1;
    80005e20:	57fd                	li	a5,-1
    80005e22:	a805                	j	80005e52 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e24:	fc442783          	lw	a5,-60(s0)
    80005e28:	0007c863          	bltz	a5,80005e38 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e2c:	01a78513          	addi	a0,a5,26
    80005e30:	050e                	slli	a0,a0,0x3
    80005e32:	9526                	add	a0,a0,s1
    80005e34:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e38:	fd043503          	ld	a0,-48(s0)
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	9f0080e7          	jalr	-1552(ra) # 8000482c <fileclose>
    fileclose(wf);
    80005e44:	fc843503          	ld	a0,-56(s0)
    80005e48:	fffff097          	auipc	ra,0xfffff
    80005e4c:	9e4080e7          	jalr	-1564(ra) # 8000482c <fileclose>
    return -1;
    80005e50:	57fd                	li	a5,-1
}
    80005e52:	853e                	mv	a0,a5
    80005e54:	70e2                	ld	ra,56(sp)
    80005e56:	7442                	ld	s0,48(sp)
    80005e58:	74a2                	ld	s1,40(sp)
    80005e5a:	6121                	addi	sp,sp,64
    80005e5c:	8082                	ret
	...

0000000080005e60 <kernelvec>:
    80005e60:	7111                	addi	sp,sp,-256
    80005e62:	e006                	sd	ra,0(sp)
    80005e64:	e40a                	sd	sp,8(sp)
    80005e66:	e80e                	sd	gp,16(sp)
    80005e68:	ec12                	sd	tp,24(sp)
    80005e6a:	f016                	sd	t0,32(sp)
    80005e6c:	f41a                	sd	t1,40(sp)
    80005e6e:	f81e                	sd	t2,48(sp)
    80005e70:	fc22                	sd	s0,56(sp)
    80005e72:	e0a6                	sd	s1,64(sp)
    80005e74:	e4aa                	sd	a0,72(sp)
    80005e76:	e8ae                	sd	a1,80(sp)
    80005e78:	ecb2                	sd	a2,88(sp)
    80005e7a:	f0b6                	sd	a3,96(sp)
    80005e7c:	f4ba                	sd	a4,104(sp)
    80005e7e:	f8be                	sd	a5,112(sp)
    80005e80:	fcc2                	sd	a6,120(sp)
    80005e82:	e146                	sd	a7,128(sp)
    80005e84:	e54a                	sd	s2,136(sp)
    80005e86:	e94e                	sd	s3,144(sp)
    80005e88:	ed52                	sd	s4,152(sp)
    80005e8a:	f156                	sd	s5,160(sp)
    80005e8c:	f55a                	sd	s6,168(sp)
    80005e8e:	f95e                	sd	s7,176(sp)
    80005e90:	fd62                	sd	s8,184(sp)
    80005e92:	e1e6                	sd	s9,192(sp)
    80005e94:	e5ea                	sd	s10,200(sp)
    80005e96:	e9ee                	sd	s11,208(sp)
    80005e98:	edf2                	sd	t3,216(sp)
    80005e9a:	f1f6                	sd	t4,224(sp)
    80005e9c:	f5fa                	sd	t5,232(sp)
    80005e9e:	f9fe                	sd	t6,240(sp)
    80005ea0:	db7fc0ef          	jal	ra,80002c56 <kerneltrap>
    80005ea4:	6082                	ld	ra,0(sp)
    80005ea6:	6122                	ld	sp,8(sp)
    80005ea8:	61c2                	ld	gp,16(sp)
    80005eaa:	7282                	ld	t0,32(sp)
    80005eac:	7322                	ld	t1,40(sp)
    80005eae:	73c2                	ld	t2,48(sp)
    80005eb0:	7462                	ld	s0,56(sp)
    80005eb2:	6486                	ld	s1,64(sp)
    80005eb4:	6526                	ld	a0,72(sp)
    80005eb6:	65c6                	ld	a1,80(sp)
    80005eb8:	6666                	ld	a2,88(sp)
    80005eba:	7686                	ld	a3,96(sp)
    80005ebc:	7726                	ld	a4,104(sp)
    80005ebe:	77c6                	ld	a5,112(sp)
    80005ec0:	7866                	ld	a6,120(sp)
    80005ec2:	688a                	ld	a7,128(sp)
    80005ec4:	692a                	ld	s2,136(sp)
    80005ec6:	69ca                	ld	s3,144(sp)
    80005ec8:	6a6a                	ld	s4,152(sp)
    80005eca:	7a8a                	ld	s5,160(sp)
    80005ecc:	7b2a                	ld	s6,168(sp)
    80005ece:	7bca                	ld	s7,176(sp)
    80005ed0:	7c6a                	ld	s8,184(sp)
    80005ed2:	6c8e                	ld	s9,192(sp)
    80005ed4:	6d2e                	ld	s10,200(sp)
    80005ed6:	6dce                	ld	s11,208(sp)
    80005ed8:	6e6e                	ld	t3,216(sp)
    80005eda:	7e8e                	ld	t4,224(sp)
    80005edc:	7f2e                	ld	t5,232(sp)
    80005ede:	7fce                	ld	t6,240(sp)
    80005ee0:	6111                	addi	sp,sp,256
    80005ee2:	10200073          	sret
    80005ee6:	00000013          	nop
    80005eea:	00000013          	nop
    80005eee:	0001                	nop

0000000080005ef0 <timervec>:
    80005ef0:	34051573          	csrrw	a0,mscratch,a0
    80005ef4:	e10c                	sd	a1,0(a0)
    80005ef6:	e510                	sd	a2,8(a0)
    80005ef8:	e914                	sd	a3,16(a0)
    80005efa:	6d0c                	ld	a1,24(a0)
    80005efc:	7110                	ld	a2,32(a0)
    80005efe:	6194                	ld	a3,0(a1)
    80005f00:	96b2                	add	a3,a3,a2
    80005f02:	e194                	sd	a3,0(a1)
    80005f04:	4589                	li	a1,2
    80005f06:	14459073          	csrw	sip,a1
    80005f0a:	6914                	ld	a3,16(a0)
    80005f0c:	6510                	ld	a2,8(a0)
    80005f0e:	610c                	ld	a1,0(a0)
    80005f10:	34051573          	csrrw	a0,mscratch,a0
    80005f14:	30200073          	mret
	...

0000000080005f1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f1a:	1141                	addi	sp,sp,-16
    80005f1c:	e422                	sd	s0,8(sp)
    80005f1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f20:	0c0007b7          	lui	a5,0xc000
    80005f24:	4705                	li	a4,1
    80005f26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f28:	c3d8                	sw	a4,4(a5)
}
    80005f2a:	6422                	ld	s0,8(sp)
    80005f2c:	0141                	addi	sp,sp,16
    80005f2e:	8082                	ret

0000000080005f30 <plicinithart>:

void
plicinithart(void)
{
    80005f30:	1141                	addi	sp,sp,-16
    80005f32:	e406                	sd	ra,8(sp)
    80005f34:	e022                	sd	s0,0(sp)
    80005f36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	bec080e7          	jalr	-1044(ra) # 80001b24 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f40:	0085171b          	slliw	a4,a0,0x8
    80005f44:	0c0027b7          	lui	a5,0xc002
    80005f48:	97ba                	add	a5,a5,a4
    80005f4a:	40200713          	li	a4,1026
    80005f4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f52:	00d5151b          	slliw	a0,a0,0xd
    80005f56:	0c2017b7          	lui	a5,0xc201
    80005f5a:	953e                	add	a0,a0,a5
    80005f5c:	00052023          	sw	zero,0(a0)
}
    80005f60:	60a2                	ld	ra,8(sp)
    80005f62:	6402                	ld	s0,0(sp)
    80005f64:	0141                	addi	sp,sp,16
    80005f66:	8082                	ret

0000000080005f68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f68:	1141                	addi	sp,sp,-16
    80005f6a:	e406                	sd	ra,8(sp)
    80005f6c:	e022                	sd	s0,0(sp)
    80005f6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f70:	ffffc097          	auipc	ra,0xffffc
    80005f74:	bb4080e7          	jalr	-1100(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f78:	00d5179b          	slliw	a5,a0,0xd
    80005f7c:	0c201537          	lui	a0,0xc201
    80005f80:	953e                	add	a0,a0,a5
  return irq;
}
    80005f82:	4148                	lw	a0,4(a0)
    80005f84:	60a2                	ld	ra,8(sp)
    80005f86:	6402                	ld	s0,0(sp)
    80005f88:	0141                	addi	sp,sp,16
    80005f8a:	8082                	ret

0000000080005f8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f8c:	1101                	addi	sp,sp,-32
    80005f8e:	ec06                	sd	ra,24(sp)
    80005f90:	e822                	sd	s0,16(sp)
    80005f92:	e426                	sd	s1,8(sp)
    80005f94:	1000                	addi	s0,sp,32
    80005f96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	b8c080e7          	jalr	-1140(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005fa0:	00d5151b          	slliw	a0,a0,0xd
    80005fa4:	0c2017b7          	lui	a5,0xc201
    80005fa8:	97aa                	add	a5,a5,a0
    80005faa:	c3c4                	sw	s1,4(a5)
}
    80005fac:	60e2                	ld	ra,24(sp)
    80005fae:	6442                	ld	s0,16(sp)
    80005fb0:	64a2                	ld	s1,8(sp)
    80005fb2:	6105                	addi	sp,sp,32
    80005fb4:	8082                	ret

0000000080005fb6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005fb6:	1141                	addi	sp,sp,-16
    80005fb8:	e406                	sd	ra,8(sp)
    80005fba:	e022                	sd	s0,0(sp)
    80005fbc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005fbe:	479d                	li	a5,7
    80005fc0:	04a7c463          	blt	a5,a0,80006008 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005fc4:	00032797          	auipc	a5,0x32
    80005fc8:	29478793          	addi	a5,a5,660 # 80038258 <disk>
    80005fcc:	97aa                	add	a5,a5,a0
    80005fce:	0187c783          	lbu	a5,24(a5)
    80005fd2:	e3b9                	bnez	a5,80006018 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005fd4:	00032797          	auipc	a5,0x32
    80005fd8:	28478793          	addi	a5,a5,644 # 80038258 <disk>
    80005fdc:	6398                	ld	a4,0(a5)
    80005fde:	00451693          	slli	a3,a0,0x4
    80005fe2:	9736                	add	a4,a4,a3
    80005fe4:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005fe8:	953e                	add	a0,a0,a5
    80005fea:	4785                	li	a5,1
    80005fec:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005ff0:	00032517          	auipc	a0,0x32
    80005ff4:	28050513          	addi	a0,a0,640 # 80038270 <disk+0x18>
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	646080e7          	jalr	1606(ra) # 8000263e <wakeup>
}
    80006000:	60a2                	ld	ra,8(sp)
    80006002:	6402                	ld	s0,0(sp)
    80006004:	0141                	addi	sp,sp,16
    80006006:	8082                	ret
    panic("virtio_disk_intr 1");
    80006008:	00004517          	auipc	a0,0x4
    8000600c:	d4050513          	addi	a0,a0,-704 # 80009d48 <syscalls+0x330>
    80006010:	ffffa097          	auipc	ra,0xffffa
    80006014:	554080e7          	jalr	1364(ra) # 80000564 <panic>
    panic("virtio_disk_intr 2");
    80006018:	00004517          	auipc	a0,0x4
    8000601c:	d4850513          	addi	a0,a0,-696 # 80009d60 <syscalls+0x348>
    80006020:	ffffa097          	auipc	ra,0xffffa
    80006024:	544080e7          	jalr	1348(ra) # 80000564 <panic>

0000000080006028 <virtio_disk_init>:
{
    80006028:	1101                	addi	sp,sp,-32
    8000602a:	ec06                	sd	ra,24(sp)
    8000602c:	e822                	sd	s0,16(sp)
    8000602e:	e426                	sd	s1,8(sp)
    80006030:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006032:	00032497          	auipc	s1,0x32
    80006036:	22648493          	addi	s1,s1,550 # 80038258 <disk>
    8000603a:	00004597          	auipc	a1,0x4
    8000603e:	d3e58593          	addi	a1,a1,-706 # 80009d78 <syscalls+0x360>
    80006042:	00032517          	auipc	a0,0x32
    80006046:	33e50513          	addi	a0,a0,830 # 80038380 <disk+0x128>
    8000604a:	ffffb097          	auipc	ra,0xffffb
    8000604e:	a72080e7          	jalr	-1422(ra) # 80000abc <initlock>
  disk.desc = kalloc();
    80006052:	ffffb097          	auipc	ra,0xffffb
    80006056:	9f0080e7          	jalr	-1552(ra) # 80000a42 <kalloc>
    8000605a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000605c:	ffffb097          	auipc	ra,0xffffb
    80006060:	9e6080e7          	jalr	-1562(ra) # 80000a42 <kalloc>
    80006064:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006066:	ffffb097          	auipc	ra,0xffffb
    8000606a:	9dc080e7          	jalr	-1572(ra) # 80000a42 <kalloc>
    8000606e:	87aa                	mv	a5,a0
    80006070:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006072:	6088                	ld	a0,0(s1)
    80006074:	14050163          	beqz	a0,800061b6 <virtio_disk_init+0x18e>
    80006078:	00032717          	auipc	a4,0x32
    8000607c:	1e873703          	ld	a4,488(a4) # 80038260 <disk+0x8>
    80006080:	12070b63          	beqz	a4,800061b6 <virtio_disk_init+0x18e>
    80006084:	12078963          	beqz	a5,800061b6 <virtio_disk_init+0x18e>
  memset(disk.desc, 0, PGSIZE);
    80006088:	6605                	lui	a2,0x1
    8000608a:	4581                	li	a1,0
    8000608c:	ffffb097          	auipc	ra,0xffffb
    80006090:	dea080e7          	jalr	-534(ra) # 80000e76 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006094:	00032497          	auipc	s1,0x32
    80006098:	1c448493          	addi	s1,s1,452 # 80038258 <disk>
    8000609c:	6605                	lui	a2,0x1
    8000609e:	4581                	li	a1,0
    800060a0:	6488                	ld	a0,8(s1)
    800060a2:	ffffb097          	auipc	ra,0xffffb
    800060a6:	dd4080e7          	jalr	-556(ra) # 80000e76 <memset>
  memset(disk.used, 0, PGSIZE);
    800060aa:	6605                	lui	a2,0x1
    800060ac:	4581                	li	a1,0
    800060ae:	6888                	ld	a0,16(s1)
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	dc6080e7          	jalr	-570(ra) # 80000e76 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b8:	100017b7          	lui	a5,0x10001
    800060bc:	4398                	lw	a4,0(a5)
    800060be:	2701                	sext.w	a4,a4
    800060c0:	747277b7          	lui	a5,0x74727
    800060c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060c8:	0ef71f63          	bne	a4,a5,800061c6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060cc:	100017b7          	lui	a5,0x10001
    800060d0:	43dc                	lw	a5,4(a5)
    800060d2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060d4:	4709                	li	a4,2
    800060d6:	0ee79863          	bne	a5,a4,800061c6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060da:	100017b7          	lui	a5,0x10001
    800060de:	479c                	lw	a5,8(a5)
    800060e0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060e2:	0ee79263          	bne	a5,a4,800061c6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060e6:	100017b7          	lui	a5,0x10001
    800060ea:	47d8                	lw	a4,12(a5)
    800060ec:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ee:	554d47b7          	lui	a5,0x554d4
    800060f2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060f6:	0cf71863          	bne	a4,a5,800061c6 <virtio_disk_init+0x19e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060fa:	100017b7          	lui	a5,0x10001
    800060fe:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006102:	4705                	li	a4,1
    80006104:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006106:	470d                	li	a4,3
    80006108:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000610a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000610c:	c7ffe737          	lui	a4,0xc7ffe
    80006110:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc639f>
    80006114:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006116:	2701                	sext.w	a4,a4
    80006118:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611a:	472d                	li	a4,11
    8000611c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000611e:	5bbc                	lw	a5,112(a5)
    80006120:	0007861b          	sext.w	a2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006124:	8ba1                	andi	a5,a5,8
    80006126:	cbc5                	beqz	a5,800061d6 <virtio_disk_init+0x1ae>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006130:	43fc                	lw	a5,68(a5)
    80006132:	2781                	sext.w	a5,a5
    80006134:	ebcd                	bnez	a5,800061e6 <virtio_disk_init+0x1be>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006136:	100017b7          	lui	a5,0x10001
    8000613a:	5bdc                	lw	a5,52(a5)
    8000613c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000613e:	cfc5                	beqz	a5,800061f6 <virtio_disk_init+0x1ce>
  if(max < NUM)
    80006140:	471d                	li	a4,7
    80006142:	0cf77263          	bgeu	a4,a5,80006206 <virtio_disk_init+0x1de>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006146:	10001737          	lui	a4,0x10001
    8000614a:	47a1                	li	a5,8
    8000614c:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    8000614e:	00032797          	auipc	a5,0x32
    80006152:	10a78793          	addi	a5,a5,266 # 80038258 <disk>
    80006156:	4394                	lw	a3,0(a5)
    80006158:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    8000615c:	43d4                	lw	a3,4(a5)
    8000615e:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    80006162:	6794                	ld	a3,8(a5)
    80006164:	0006859b          	sext.w	a1,a3
    80006168:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000616c:	9681                	srai	a3,a3,0x20
    8000616e:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    80006172:	6b94                	ld	a3,16(a5)
    80006174:	0006859b          	sext.w	a1,a3
    80006178:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000617c:	9681                	srai	a3,a3,0x20
    8000617e:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006182:	4685                	li	a3,1
    80006184:	c374                	sw	a3,68(a4)
    disk.free[i] = 1;
    80006186:	00d78c23          	sb	a3,24(a5)
    8000618a:	00d78ca3          	sb	a3,25(a5)
    8000618e:	00d78d23          	sb	a3,26(a5)
    80006192:	00d78da3          	sb	a3,27(a5)
    80006196:	00d78e23          	sb	a3,28(a5)
    8000619a:	00d78ea3          	sb	a3,29(a5)
    8000619e:	00d78f23          	sb	a3,30(a5)
    800061a2:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800061a6:	00466793          	ori	a5,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800061aa:	db3c                	sw	a5,112(a4)
}
    800061ac:	60e2                	ld	ra,24(sp)
    800061ae:	6442                	ld	s0,16(sp)
    800061b0:	64a2                	ld	s1,8(sp)
    800061b2:	6105                	addi	sp,sp,32
    800061b4:	8082                	ret
    panic("virtio disk kalloc");
    800061b6:	00004517          	auipc	a0,0x4
    800061ba:	bd250513          	addi	a0,a0,-1070 # 80009d88 <syscalls+0x370>
    800061be:	ffffa097          	auipc	ra,0xffffa
    800061c2:	3a6080e7          	jalr	934(ra) # 80000564 <panic>
    panic("could not find virtio disk");
    800061c6:	00004517          	auipc	a0,0x4
    800061ca:	bda50513          	addi	a0,a0,-1062 # 80009da0 <syscalls+0x388>
    800061ce:	ffffa097          	auipc	ra,0xffffa
    800061d2:	396080e7          	jalr	918(ra) # 80000564 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061d6:	00004517          	auipc	a0,0x4
    800061da:	bea50513          	addi	a0,a0,-1046 # 80009dc0 <syscalls+0x3a8>
    800061de:	ffffa097          	auipc	ra,0xffffa
    800061e2:	386080e7          	jalr	902(ra) # 80000564 <panic>
    panic("virtio disk ready not zero");
    800061e6:	00004517          	auipc	a0,0x4
    800061ea:	bfa50513          	addi	a0,a0,-1030 # 80009de0 <syscalls+0x3c8>
    800061ee:	ffffa097          	auipc	ra,0xffffa
    800061f2:	376080e7          	jalr	886(ra) # 80000564 <panic>
    panic("virtio disk has no queue 0");
    800061f6:	00004517          	auipc	a0,0x4
    800061fa:	c0a50513          	addi	a0,a0,-1014 # 80009e00 <syscalls+0x3e8>
    800061fe:	ffffa097          	auipc	ra,0xffffa
    80006202:	366080e7          	jalr	870(ra) # 80000564 <panic>
    panic("virtio disk max queue too short");
    80006206:	00004517          	auipc	a0,0x4
    8000620a:	c1a50513          	addi	a0,a0,-998 # 80009e20 <syscalls+0x408>
    8000620e:	ffffa097          	auipc	ra,0xffffa
    80006212:	356080e7          	jalr	854(ra) # 80000564 <panic>

0000000080006216 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006216:	7119                	addi	sp,sp,-128
    80006218:	fc86                	sd	ra,120(sp)
    8000621a:	f8a2                	sd	s0,112(sp)
    8000621c:	f4a6                	sd	s1,104(sp)
    8000621e:	f0ca                	sd	s2,96(sp)
    80006220:	ecce                	sd	s3,88(sp)
    80006222:	e8d2                	sd	s4,80(sp)
    80006224:	e4d6                	sd	s5,72(sp)
    80006226:	e0da                	sd	s6,64(sp)
    80006228:	fc5e                	sd	s7,56(sp)
    8000622a:	f862                	sd	s8,48(sp)
    8000622c:	f466                	sd	s9,40(sp)
    8000622e:	f06a                	sd	s10,32(sp)
    80006230:	ec6e                	sd	s11,24(sp)
    80006232:	0100                	addi	s0,sp,128
    80006234:	8aaa                	mv	s5,a0
    80006236:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006238:	00c52d03          	lw	s10,12(a0)
    8000623c:	001d1d1b          	slliw	s10,s10,0x1
    80006240:	1d02                	slli	s10,s10,0x20
    80006242:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006246:	00032517          	auipc	a0,0x32
    8000624a:	13a50513          	addi	a0,a0,314 # 80038380 <disk+0x128>
    8000624e:	ffffb097          	auipc	ra,0xffffb
    80006252:	944080e7          	jalr	-1724(ra) # 80000b92 <acquire>
  for(int i = 0; i < 3; i++){
    80006256:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006258:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000625a:	00032b97          	auipc	s7,0x32
    8000625e:	ffeb8b93          	addi	s7,s7,-2 # 80038258 <disk>
  for(int i = 0; i < 3; i++){
    80006262:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006264:	00032c97          	auipc	s9,0x32
    80006268:	11cc8c93          	addi	s9,s9,284 # 80038380 <disk+0x128>
    8000626c:	a08d                	j	800062ce <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000626e:	00fb8733          	add	a4,s7,a5
    80006272:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006276:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006278:	0207c563          	bltz	a5,800062a2 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000627c:	2905                	addiw	s2,s2,1
    8000627e:	0611                	addi	a2,a2,4
    80006280:	0b690263          	beq	s2,s6,80006324 <virtio_disk_rw+0x10e>
    idx[i] = alloc_desc();
    80006284:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006286:	00032717          	auipc	a4,0x32
    8000628a:	fd270713          	addi	a4,a4,-46 # 80038258 <disk>
    8000628e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006290:	01874683          	lbu	a3,24(a4)
    80006294:	fee9                	bnez	a3,8000626e <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006296:	2785                	addiw	a5,a5,1
    80006298:	0705                	addi	a4,a4,1
    8000629a:	fe979be3          	bne	a5,s1,80006290 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000629e:	57fd                	li	a5,-1
    800062a0:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800062a2:	01205d63          	blez	s2,800062bc <virtio_disk_rw+0xa6>
    800062a6:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800062a8:	000a2503          	lw	a0,0(s4)
    800062ac:	00000097          	auipc	ra,0x0
    800062b0:	d0a080e7          	jalr	-758(ra) # 80005fb6 <free_desc>
      for(int j = 0; j < i; j++)
    800062b4:	2d85                	addiw	s11,s11,1
    800062b6:	0a11                	addi	s4,s4,4
    800062b8:	ffb918e3          	bne	s2,s11,800062a8 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062bc:	85e6                	mv	a1,s9
    800062be:	00032517          	auipc	a0,0x32
    800062c2:	fb250513          	addi	a0,a0,-78 # 80038270 <disk+0x18>
    800062c6:	ffffc097          	auipc	ra,0xffffc
    800062ca:	1f8080e7          	jalr	504(ra) # 800024be <sleep>
  for(int i = 0; i < 3; i++){
    800062ce:	f8040a13          	addi	s4,s0,-128
{
    800062d2:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062d4:	894e                	mv	s2,s3
    800062d6:	b77d                	j	80006284 <virtio_disk_rw+0x6e>
      i = disk.desc[i].next;
    800062d8:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800062dc:	8526                	mv	a0,s1
    800062de:	00000097          	auipc	ra,0x0
    800062e2:	cd8080e7          	jalr	-808(ra) # 80005fb6 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800062e6:	0492                	slli	s1,s1,0x4
    800062e8:	00093783          	ld	a5,0(s2)
    800062ec:	94be                	add	s1,s1,a5
    800062ee:	00c4d783          	lhu	a5,12(s1)
    800062f2:	8b85                	andi	a5,a5,1
    800062f4:	f3f5                	bnez	a5,800062d8 <virtio_disk_rw+0xc2>
  }

  disk.info[idx[0]].b = 0;
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062f6:	00032517          	auipc	a0,0x32
    800062fa:	08a50513          	addi	a0,a0,138 # 80038380 <disk+0x128>
    800062fe:	ffffb097          	auipc	ra,0xffffb
    80006302:	964080e7          	jalr	-1692(ra) # 80000c62 <release>
}
    80006306:	70e6                	ld	ra,120(sp)
    80006308:	7446                	ld	s0,112(sp)
    8000630a:	74a6                	ld	s1,104(sp)
    8000630c:	7906                	ld	s2,96(sp)
    8000630e:	69e6                	ld	s3,88(sp)
    80006310:	6a46                	ld	s4,80(sp)
    80006312:	6aa6                	ld	s5,72(sp)
    80006314:	6b06                	ld	s6,64(sp)
    80006316:	7be2                	ld	s7,56(sp)
    80006318:	7c42                	ld	s8,48(sp)
    8000631a:	7ca2                	ld	s9,40(sp)
    8000631c:	7d02                	ld	s10,32(sp)
    8000631e:	6de2                	ld	s11,24(sp)
    80006320:	6109                	addi	sp,sp,128
    80006322:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006324:	f8042583          	lw	a1,-128(s0)
    80006328:	00a58793          	addi	a5,a1,10
    8000632c:	0792                	slli	a5,a5,0x4
  if(write)
    8000632e:	00032617          	auipc	a2,0x32
    80006332:	f2a60613          	addi	a2,a2,-214 # 80038258 <disk>
    80006336:	00f60733          	add	a4,a2,a5
    8000633a:	018036b3          	snez	a3,s8
    8000633e:	c714                	sw	a3,8(a4)
  buf0->reserved = 0;
    80006340:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006344:	01a73823          	sd	s10,16(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006348:	f6078693          	addi	a3,a5,-160
    8000634c:	6218                	ld	a4,0(a2)
    8000634e:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006350:	00878513          	addi	a0,a5,8
    80006354:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006356:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006358:	6208                	ld	a0,0(a2)
    8000635a:	96aa                	add	a3,a3,a0
    8000635c:	4741                	li	a4,16
    8000635e:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    80006360:	4705                	li	a4,1
    80006362:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006366:	f8442703          	lw	a4,-124(s0)
    8000636a:	00e69723          	sh	a4,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000636e:	0712                	slli	a4,a4,0x4
    80006370:	953a                	add	a0,a0,a4
    80006372:	060a8693          	addi	a3,s5,96
    80006376:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006378:	6208                	ld	a0,0(a2)
    8000637a:	972a                	add	a4,a4,a0
    8000637c:	40000693          	li	a3,1024
    80006380:	c714                	sw	a3,8(a4)
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    80006382:	001c3c13          	seqz	s8,s8
    80006386:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    80006388:	001c6c13          	ori	s8,s8,1
    8000638c:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006390:	f8842603          	lw	a2,-120(s0)
    80006394:	00c71723          	sh	a2,14(a4)
  disk.info[idx[0]].status = 0;
    80006398:	00032697          	auipc	a3,0x32
    8000639c:	ec068693          	addi	a3,a3,-320 # 80038258 <disk>
    800063a0:	00258713          	addi	a4,a1,2
    800063a4:	0712                	slli	a4,a4,0x4
    800063a6:	9736                	add	a4,a4,a3
    800063a8:	00070823          	sb	zero,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063ac:	0612                	slli	a2,a2,0x4
    800063ae:	9532                	add	a0,a0,a2
    800063b0:	f9078793          	addi	a5,a5,-112
    800063b4:	97b6                	add	a5,a5,a3
    800063b6:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800063b8:	629c                	ld	a5,0(a3)
    800063ba:	97b2                	add	a5,a5,a2
    800063bc:	4605                	li	a2,1
    800063be:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    800063c0:	4509                	li	a0,2
    800063c2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800063c6:	00079723          	sh	zero,14(a5)
  b->disk = 1;
    800063ca:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063ce:	01573423          	sd	s5,8(a4)
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063d2:	6698                	ld	a4,8(a3)
    800063d4:	00275783          	lhu	a5,2(a4)
    800063d8:	8b9d                	andi	a5,a5,7
    800063da:	0786                	slli	a5,a5,0x1
    800063dc:	97ba                	add	a5,a5,a4
    800063de:	00b79223          	sh	a1,4(a5)
  __sync_synchronize();
    800063e2:	0ff0000f          	fence
  disk.avail->idx += 1;
    800063e6:	6698                	ld	a4,8(a3)
    800063e8:	00275783          	lhu	a5,2(a4)
    800063ec:	2785                	addiw	a5,a5,1
    800063ee:	00f71123          	sh	a5,2(a4)
  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063f2:	100017b7          	lui	a5,0x10001
    800063f6:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
  while(b->disk == 1) {
    800063fa:	004aa783          	lw	a5,4(s5)
    800063fe:	02c79163          	bne	a5,a2,80006420 <virtio_disk_rw+0x20a>
    sleep(b, &disk.vdisk_lock);
    80006402:	00032917          	auipc	s2,0x32
    80006406:	f7e90913          	addi	s2,s2,-130 # 80038380 <disk+0x128>
  while(b->disk == 1) {
    8000640a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000640c:	85ca                	mv	a1,s2
    8000640e:	8556                	mv	a0,s5
    80006410:	ffffc097          	auipc	ra,0xffffc
    80006414:	0ae080e7          	jalr	174(ra) # 800024be <sleep>
  while(b->disk == 1) {
    80006418:	004aa783          	lw	a5,4(s5)
    8000641c:	fe9788e3          	beq	a5,s1,8000640c <virtio_disk_rw+0x1f6>
  disk.info[idx[0]].b = 0;
    80006420:	f8042483          	lw	s1,-128(s0)
    80006424:	00248793          	addi	a5,s1,2
    80006428:	00479713          	slli	a4,a5,0x4
    8000642c:	00032797          	auipc	a5,0x32
    80006430:	e2c78793          	addi	a5,a5,-468 # 80038258 <disk>
    80006434:	97ba                	add	a5,a5,a4
    80006436:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    8000643a:	00032917          	auipc	s2,0x32
    8000643e:	e1e90913          	addi	s2,s2,-482 # 80038258 <disk>
    80006442:	bd69                	j	800062dc <virtio_disk_rw+0xc6>

0000000080006444 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    80006444:	1101                	addi	sp,sp,-32
    80006446:	ec06                	sd	ra,24(sp)
    80006448:	e822                	sd	s0,16(sp)
    8000644a:	e426                	sd	s1,8(sp)
    8000644c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000644e:	00032497          	auipc	s1,0x32
    80006452:	e0a48493          	addi	s1,s1,-502 # 80038258 <disk>
    80006456:	00032517          	auipc	a0,0x32
    8000645a:	f2a50513          	addi	a0,a0,-214 # 80038380 <disk+0x128>
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	734080e7          	jalr	1844(ra) # 80000b92 <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006466:	0204d783          	lhu	a5,32(s1)
    8000646a:	6898                	ld	a4,16(s1)
    8000646c:	00275683          	lhu	a3,2(a4)
    80006470:	8ebd                	xor	a3,a3,a5
    80006472:	8a9d                	andi	a3,a3,7
    80006474:	c2b1                	beqz	a3,800064b8 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    80006476:	078e                	slli	a5,a5,0x3
    80006478:	97ba                	add	a5,a5,a4
    8000647a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000647c:	00278713          	addi	a4,a5,2
    80006480:	0712                	slli	a4,a4,0x4
    80006482:	9726                	add	a4,a4,s1
    80006484:	01074703          	lbu	a4,16(a4)
    80006488:	eb31                	bnez	a4,800064dc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000648a:	0789                	addi	a5,a5,2
    8000648c:	0792                	slli	a5,a5,0x4
    8000648e:	97a6                	add	a5,a5,s1
    80006490:	6798                	ld	a4,8(a5)
    80006492:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006496:	6788                	ld	a0,8(a5)
    80006498:	ffffc097          	auipc	ra,0xffffc
    8000649c:	1a6080e7          	jalr	422(ra) # 8000263e <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800064a0:	0204d783          	lhu	a5,32(s1)
    800064a4:	2785                	addiw	a5,a5,1
    800064a6:	8b9d                	andi	a5,a5,7
    800064a8:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    800064ac:	6898                	ld	a4,16(s1)
    800064ae:	00275683          	lhu	a3,2(a4)
    800064b2:	8a9d                	andi	a3,a3,7
    800064b4:	fcf691e3          	bne	a3,a5,80006476 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800064b8:	10001737          	lui	a4,0x10001
    800064bc:	533c                	lw	a5,96(a4)
    800064be:	8b8d                	andi	a5,a5,3
    800064c0:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064c2:	00032517          	auipc	a0,0x32
    800064c6:	ebe50513          	addi	a0,a0,-322 # 80038380 <disk+0x128>
    800064ca:	ffffa097          	auipc	ra,0xffffa
    800064ce:	798080e7          	jalr	1944(ra) # 80000c62 <release>
}
    800064d2:	60e2                	ld	ra,24(sp)
    800064d4:	6442                	ld	s0,16(sp)
    800064d6:	64a2                	ld	s1,8(sp)
    800064d8:	6105                	addi	sp,sp,32
    800064da:	8082                	ret
      panic("virtio_disk_intr status");
    800064dc:	00004517          	auipc	a0,0x4
    800064e0:	96450513          	addi	a0,a0,-1692 # 80009e40 <syscalls+0x428>
    800064e4:	ffffa097          	auipc	ra,0xffffa
    800064e8:	080080e7          	jalr	128(ra) # 80000564 <panic>

00000000800064ec <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800064ec:	1141                	addi	sp,sp,-16
    800064ee:	e422                	sd	s0,8(sp)
    800064f0:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800064f2:	41f5d79b          	sraiw	a5,a1,0x1f
    800064f6:	01d7d79b          	srliw	a5,a5,0x1d
    800064fa:	9dbd                	addw	a1,a1,a5
    800064fc:	0075f713          	andi	a4,a1,7
    80006500:	9f1d                	subw	a4,a4,a5
    80006502:	4785                	li	a5,1
    80006504:	00e797bb          	sllw	a5,a5,a4
    80006508:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    8000650c:	4035d59b          	sraiw	a1,a1,0x3
    80006510:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006512:	0005c503          	lbu	a0,0(a1)
    80006516:	8d7d                	and	a0,a0,a5
    80006518:	8d1d                	sub	a0,a0,a5
}
    8000651a:	00153513          	seqz	a0,a0
    8000651e:	6422                	ld	s0,8(sp)
    80006520:	0141                	addi	sp,sp,16
    80006522:	8082                	ret

0000000080006524 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006524:	1141                	addi	sp,sp,-16
    80006526:	e422                	sd	s0,8(sp)
    80006528:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000652a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000652e:	01d7d79b          	srliw	a5,a5,0x1d
    80006532:	9dbd                	addw	a1,a1,a5
    80006534:	4035d71b          	sraiw	a4,a1,0x3
    80006538:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000653a:	899d                	andi	a1,a1,7
    8000653c:	9d9d                	subw	a1,a1,a5
    8000653e:	4785                	li	a5,1
    80006540:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    80006544:	00054783          	lbu	a5,0(a0)
    80006548:	8ddd                	or	a1,a1,a5
    8000654a:	00b50023          	sb	a1,0(a0)
}
    8000654e:	6422                	ld	s0,8(sp)
    80006550:	0141                	addi	sp,sp,16
    80006552:	8082                	ret

0000000080006554 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006554:	1141                	addi	sp,sp,-16
    80006556:	e422                	sd	s0,8(sp)
    80006558:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000655a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000655e:	01d7d79b          	srliw	a5,a5,0x1d
    80006562:	9dbd                	addw	a1,a1,a5
    80006564:	4035d71b          	sraiw	a4,a1,0x3
    80006568:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000656a:	899d                	andi	a1,a1,7
    8000656c:	9d9d                	subw	a1,a1,a5
    8000656e:	4785                	li	a5,1
    80006570:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    80006574:	fff5c593          	not	a1,a1
    80006578:	00054783          	lbu	a5,0(a0)
    8000657c:	8dfd                	and	a1,a1,a5
    8000657e:	00b50023          	sb	a1,0(a0)
}
    80006582:	6422                	ld	s0,8(sp)
    80006584:	0141                	addi	sp,sp,16
    80006586:	8082                	ret

0000000080006588 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006588:	715d                	addi	sp,sp,-80
    8000658a:	e486                	sd	ra,72(sp)
    8000658c:	e0a2                	sd	s0,64(sp)
    8000658e:	fc26                	sd	s1,56(sp)
    80006590:	f84a                	sd	s2,48(sp)
    80006592:	f44e                	sd	s3,40(sp)
    80006594:	f052                	sd	s4,32(sp)
    80006596:	ec56                	sd	s5,24(sp)
    80006598:	e85a                	sd	s6,16(sp)
    8000659a:	e45e                	sd	s7,8(sp)
    8000659c:	0880                	addi	s0,sp,80
    8000659e:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    800065a0:	08b05b63          	blez	a1,80006636 <bd_print_vector+0xae>
    800065a4:	89aa                	mv	s3,a0
    800065a6:	4481                	li	s1,0
  lb = 0;
    800065a8:	4a81                	li	s5,0
  last = 1;
    800065aa:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    800065ac:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    800065ae:	00004b97          	auipc	s7,0x4
    800065b2:	8aab8b93          	addi	s7,s7,-1878 # 80009e58 <syscalls+0x440>
    800065b6:	a821                	j	800065ce <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    800065b8:	85a6                	mv	a1,s1
    800065ba:	854e                	mv	a0,s3
    800065bc:	00000097          	auipc	ra,0x0
    800065c0:	f30080e7          	jalr	-208(ra) # 800064ec <bit_isset>
    800065c4:	892a                	mv	s2,a0
    800065c6:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    800065c8:	2485                	addiw	s1,s1,1
    800065ca:	029a0463          	beq	s4,s1,800065f2 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    800065ce:	85a6                	mv	a1,s1
    800065d0:	854e                	mv	a0,s3
    800065d2:	00000097          	auipc	ra,0x0
    800065d6:	f1a080e7          	jalr	-230(ra) # 800064ec <bit_isset>
    800065da:	ff2507e3          	beq	a0,s2,800065c8 <bd_print_vector+0x40>
    if(last == 1)
    800065de:	fd691de3          	bne	s2,s6,800065b8 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    800065e2:	8626                	mv	a2,s1
    800065e4:	85d6                	mv	a1,s5
    800065e6:	855e                	mv	a0,s7
    800065e8:	ffffa097          	auipc	ra,0xffffa
    800065ec:	fde080e7          	jalr	-34(ra) # 800005c6 <printf>
    800065f0:	b7e1                	j	800065b8 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800065f2:	000a8563          	beqz	s5,800065fc <bd_print_vector+0x74>
    800065f6:	4785                	li	a5,1
    800065f8:	00f91c63          	bne	s2,a5,80006610 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800065fc:	8652                	mv	a2,s4
    800065fe:	85d6                	mv	a1,s5
    80006600:	00004517          	auipc	a0,0x4
    80006604:	85850513          	addi	a0,a0,-1960 # 80009e58 <syscalls+0x440>
    80006608:	ffffa097          	auipc	ra,0xffffa
    8000660c:	fbe080e7          	jalr	-66(ra) # 800005c6 <printf>
  }
  printf("\n");
    80006610:	00003517          	auipc	a0,0x3
    80006614:	bf050513          	addi	a0,a0,-1040 # 80009200 <digits+0x90>
    80006618:	ffffa097          	auipc	ra,0xffffa
    8000661c:	fae080e7          	jalr	-82(ra) # 800005c6 <printf>
}
    80006620:	60a6                	ld	ra,72(sp)
    80006622:	6406                	ld	s0,64(sp)
    80006624:	74e2                	ld	s1,56(sp)
    80006626:	7942                	ld	s2,48(sp)
    80006628:	79a2                	ld	s3,40(sp)
    8000662a:	7a02                	ld	s4,32(sp)
    8000662c:	6ae2                	ld	s5,24(sp)
    8000662e:	6b42                	ld	s6,16(sp)
    80006630:	6ba2                	ld	s7,8(sp)
    80006632:	6161                	addi	sp,sp,80
    80006634:	8082                	ret
  lb = 0;
    80006636:	4a81                	li	s5,0
    80006638:	b7d1                	j	800065fc <bd_print_vector+0x74>

000000008000663a <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000663a:	00004697          	auipc	a3,0x4
    8000663e:	9de6a683          	lw	a3,-1570(a3) # 8000a018 <nsizes>
    80006642:	10d05063          	blez	a3,80006742 <bd_print+0x108>
bd_print() {
    80006646:	711d                	addi	sp,sp,-96
    80006648:	ec86                	sd	ra,88(sp)
    8000664a:	e8a2                	sd	s0,80(sp)
    8000664c:	e4a6                	sd	s1,72(sp)
    8000664e:	e0ca                	sd	s2,64(sp)
    80006650:	fc4e                	sd	s3,56(sp)
    80006652:	f852                	sd	s4,48(sp)
    80006654:	f456                	sd	s5,40(sp)
    80006656:	f05a                	sd	s6,32(sp)
    80006658:	ec5e                	sd	s7,24(sp)
    8000665a:	e862                	sd	s8,16(sp)
    8000665c:	e466                	sd	s9,8(sp)
    8000665e:	e06a                	sd	s10,0(sp)
    80006660:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006662:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006664:	4a85                	li	s5,1
    80006666:	4c41                	li	s8,16
    80006668:	00004b97          	auipc	s7,0x4
    8000666c:	800b8b93          	addi	s7,s7,-2048 # 80009e68 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    80006670:	00004a17          	auipc	s4,0x4
    80006674:	9a0a0a13          	addi	s4,s4,-1632 # 8000a010 <bd_sizes>
    printf("  alloc:");
    80006678:	00004b17          	auipc	s6,0x4
    8000667c:	818b0b13          	addi	s6,s6,-2024 # 80009e90 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006680:	00004997          	auipc	s3,0x4
    80006684:	99898993          	addi	s3,s3,-1640 # 8000a018 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006688:	00004c97          	auipc	s9,0x4
    8000668c:	818c8c93          	addi	s9,s9,-2024 # 80009ea0 <syscalls+0x488>
    80006690:	a801                	j	800066a0 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006692:	0009a683          	lw	a3,0(s3)
    80006696:	0485                	addi	s1,s1,1
    80006698:	0004879b          	sext.w	a5,s1
    8000669c:	08d7d563          	bge	a5,a3,80006726 <bd_print+0xec>
    800066a0:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800066a4:	36fd                	addiw	a3,a3,-1
    800066a6:	9e85                	subw	a3,a3,s1
    800066a8:	00da96bb          	sllw	a3,s5,a3
    800066ac:	009c1633          	sll	a2,s8,s1
    800066b0:	85ca                	mv	a1,s2
    800066b2:	855e                	mv	a0,s7
    800066b4:	ffffa097          	auipc	ra,0xffffa
    800066b8:	f12080e7          	jalr	-238(ra) # 800005c6 <printf>
    lst_print(&bd_sizes[k].free);
    800066bc:	00549d13          	slli	s10,s1,0x5
    800066c0:	000a3503          	ld	a0,0(s4)
    800066c4:	956a                	add	a0,a0,s10
    800066c6:	00001097          	auipc	ra,0x1
    800066ca:	a56080e7          	jalr	-1450(ra) # 8000711c <lst_print>
    printf("  alloc:");
    800066ce:	855a                	mv	a0,s6
    800066d0:	ffffa097          	auipc	ra,0xffffa
    800066d4:	ef6080e7          	jalr	-266(ra) # 800005c6 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800066d8:	0009a583          	lw	a1,0(s3)
    800066dc:	35fd                	addiw	a1,a1,-1
    800066de:	412585bb          	subw	a1,a1,s2
    800066e2:	000a3783          	ld	a5,0(s4)
    800066e6:	97ea                	add	a5,a5,s10
    800066e8:	00ba95bb          	sllw	a1,s5,a1
    800066ec:	6b88                	ld	a0,16(a5)
    800066ee:	00000097          	auipc	ra,0x0
    800066f2:	e9a080e7          	jalr	-358(ra) # 80006588 <bd_print_vector>
    if(k > 0) {
    800066f6:	f9205ee3          	blez	s2,80006692 <bd_print+0x58>
      printf("  split:");
    800066fa:	8566                	mv	a0,s9
    800066fc:	ffffa097          	auipc	ra,0xffffa
    80006700:	eca080e7          	jalr	-310(ra) # 800005c6 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006704:	0009a583          	lw	a1,0(s3)
    80006708:	35fd                	addiw	a1,a1,-1
    8000670a:	412585bb          	subw	a1,a1,s2
    8000670e:	000a3783          	ld	a5,0(s4)
    80006712:	9d3e                	add	s10,s10,a5
    80006714:	00ba95bb          	sllw	a1,s5,a1
    80006718:	018d3503          	ld	a0,24(s10) # fffffffffffff018 <end+0xffffffff7ffc6c58>
    8000671c:	00000097          	auipc	ra,0x0
    80006720:	e6c080e7          	jalr	-404(ra) # 80006588 <bd_print_vector>
    80006724:	b7bd                	j	80006692 <bd_print+0x58>
    }
  }
}
    80006726:	60e6                	ld	ra,88(sp)
    80006728:	6446                	ld	s0,80(sp)
    8000672a:	64a6                	ld	s1,72(sp)
    8000672c:	6906                	ld	s2,64(sp)
    8000672e:	79e2                	ld	s3,56(sp)
    80006730:	7a42                	ld	s4,48(sp)
    80006732:	7aa2                	ld	s5,40(sp)
    80006734:	7b02                	ld	s6,32(sp)
    80006736:	6be2                	ld	s7,24(sp)
    80006738:	6c42                	ld	s8,16(sp)
    8000673a:	6ca2                	ld	s9,8(sp)
    8000673c:	6d02                	ld	s10,0(sp)
    8000673e:	6125                	addi	sp,sp,96
    80006740:	8082                	ret
    80006742:	8082                	ret

0000000080006744 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006744:	1141                	addi	sp,sp,-16
    80006746:	e422                	sd	s0,8(sp)
    80006748:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    8000674a:	47c1                	li	a5,16
    8000674c:	00a7fb63          	bgeu	a5,a0,80006762 <firstk+0x1e>
    80006750:	872a                	mv	a4,a0
  int k = 0;
    80006752:	4501                	li	a0,0
    k++;
    80006754:	2505                	addiw	a0,a0,1
    size *= 2;
    80006756:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006758:	fee7eee3          	bltu	a5,a4,80006754 <firstk+0x10>
  }
  return k;
}
    8000675c:	6422                	ld	s0,8(sp)
    8000675e:	0141                	addi	sp,sp,16
    80006760:	8082                	ret
  int k = 0;
    80006762:	4501                	li	a0,0
    80006764:	bfe5                	j	8000675c <firstk+0x18>

0000000080006766 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006766:	1141                	addi	sp,sp,-16
    80006768:	e422                	sd	s0,8(sp)
    8000676a:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    8000676c:	00004797          	auipc	a5,0x4
    80006770:	89c7b783          	ld	a5,-1892(a5) # 8000a008 <bd_base>
    80006774:	9d9d                	subw	a1,a1,a5
    80006776:	47c1                	li	a5,16
    80006778:	00a797b3          	sll	a5,a5,a0
    8000677c:	02f5c5b3          	div	a1,a1,a5
}
    80006780:	0005851b          	sext.w	a0,a1
    80006784:	6422                	ld	s0,8(sp)
    80006786:	0141                	addi	sp,sp,16
    80006788:	8082                	ret

000000008000678a <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    8000678a:	1141                	addi	sp,sp,-16
    8000678c:	e422                	sd	s0,8(sp)
    8000678e:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006790:	47c1                	li	a5,16
    80006792:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006796:	02b787bb          	mulw	a5,a5,a1
}
    8000679a:	00004517          	auipc	a0,0x4
    8000679e:	86e53503          	ld	a0,-1938(a0) # 8000a008 <bd_base>
    800067a2:	953e                	add	a0,a0,a5
    800067a4:	6422                	ld	s0,8(sp)
    800067a6:	0141                	addi	sp,sp,16
    800067a8:	8082                	ret

00000000800067aa <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    800067aa:	7159                	addi	sp,sp,-112
    800067ac:	f486                	sd	ra,104(sp)
    800067ae:	f0a2                	sd	s0,96(sp)
    800067b0:	eca6                	sd	s1,88(sp)
    800067b2:	e8ca                	sd	s2,80(sp)
    800067b4:	e4ce                	sd	s3,72(sp)
    800067b6:	e0d2                	sd	s4,64(sp)
    800067b8:	fc56                	sd	s5,56(sp)
    800067ba:	f85a                	sd	s6,48(sp)
    800067bc:	f45e                	sd	s7,40(sp)
    800067be:	f062                	sd	s8,32(sp)
    800067c0:	ec66                	sd	s9,24(sp)
    800067c2:	e86a                	sd	s10,16(sp)
    800067c4:	e46e                	sd	s11,8(sp)
    800067c6:	1880                	addi	s0,sp,112
    800067c8:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800067ca:	00032517          	auipc	a0,0x32
    800067ce:	bd650513          	addi	a0,a0,-1066 # 800383a0 <lock>
    800067d2:	ffffa097          	auipc	ra,0xffffa
    800067d6:	3c0080e7          	jalr	960(ra) # 80000b92 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800067da:	8526                	mv	a0,s1
    800067dc:	00000097          	auipc	ra,0x0
    800067e0:	f68080e7          	jalr	-152(ra) # 80006744 <firstk>
  for (k = fk; k < nsizes; k++) {
    800067e4:	00004797          	auipc	a5,0x4
    800067e8:	8347a783          	lw	a5,-1996(a5) # 8000a018 <nsizes>
    800067ec:	02f55d63          	bge	a0,a5,80006826 <bd_malloc+0x7c>
    800067f0:	8c2a                	mv	s8,a0
    800067f2:	00551913          	slli	s2,a0,0x5
    800067f6:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800067f8:	00004997          	auipc	s3,0x4
    800067fc:	81898993          	addi	s3,s3,-2024 # 8000a010 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006800:	00004a17          	auipc	s4,0x4
    80006804:	818a0a13          	addi	s4,s4,-2024 # 8000a018 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006808:	0009b503          	ld	a0,0(s3)
    8000680c:	954a                	add	a0,a0,s2
    8000680e:	00001097          	auipc	ra,0x1
    80006812:	894080e7          	jalr	-1900(ra) # 800070a2 <lst_empty>
    80006816:	c115                	beqz	a0,8000683a <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006818:	2485                	addiw	s1,s1,1
    8000681a:	02090913          	addi	s2,s2,32
    8000681e:	000a2783          	lw	a5,0(s4)
    80006822:	fef4c3e3          	blt	s1,a5,80006808 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006826:	00032517          	auipc	a0,0x32
    8000682a:	b7a50513          	addi	a0,a0,-1158 # 800383a0 <lock>
    8000682e:	ffffa097          	auipc	ra,0xffffa
    80006832:	434080e7          	jalr	1076(ra) # 80000c62 <release>
    return 0;
    80006836:	4b01                	li	s6,0
    80006838:	a0e1                	j	80006900 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    8000683a:	00003797          	auipc	a5,0x3
    8000683e:	7de7a783          	lw	a5,2014(a5) # 8000a018 <nsizes>
    80006842:	fef4d2e3          	bge	s1,a5,80006826 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006846:	00549993          	slli	s3,s1,0x5
    8000684a:	00003917          	auipc	s2,0x3
    8000684e:	7c690913          	addi	s2,s2,1990 # 8000a010 <bd_sizes>
    80006852:	00093503          	ld	a0,0(s2)
    80006856:	954e                	add	a0,a0,s3
    80006858:	00001097          	auipc	ra,0x1
    8000685c:	876080e7          	jalr	-1930(ra) # 800070ce <lst_pop>
    80006860:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006862:	00003597          	auipc	a1,0x3
    80006866:	7a65b583          	ld	a1,1958(a1) # 8000a008 <bd_base>
    8000686a:	40b505bb          	subw	a1,a0,a1
    8000686e:	47c1                	li	a5,16
    80006870:	009797b3          	sll	a5,a5,s1
    80006874:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006878:	00093783          	ld	a5,0(s2)
    8000687c:	97ce                	add	a5,a5,s3
    8000687e:	2581                	sext.w	a1,a1
    80006880:	6b88                	ld	a0,16(a5)
    80006882:	00000097          	auipc	ra,0x0
    80006886:	ca2080e7          	jalr	-862(ra) # 80006524 <bit_set>
  for(; k > fk; k--) {
    8000688a:	069c5363          	bge	s8,s1,800068f0 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000688e:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006890:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006892:	00003d17          	auipc	s10,0x3
    80006896:	776d0d13          	addi	s10,s10,1910 # 8000a008 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000689a:	85a6                	mv	a1,s1
    8000689c:	34fd                	addiw	s1,s1,-1
    8000689e:	009b9ab3          	sll	s5,s7,s1
    800068a2:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800068a6:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    800068aa:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    800068ae:	412b093b          	subw	s2,s6,s2
    800068b2:	00bb95b3          	sll	a1,s7,a1
    800068b6:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800068ba:	013a07b3          	add	a5,s4,s3
    800068be:	2581                	sext.w	a1,a1
    800068c0:	6f88                	ld	a0,24(a5)
    800068c2:	00000097          	auipc	ra,0x0
    800068c6:	c62080e7          	jalr	-926(ra) # 80006524 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068ca:	1981                	addi	s3,s3,-32
    800068cc:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800068ce:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068d2:	2581                	sext.w	a1,a1
    800068d4:	010a3503          	ld	a0,16(s4)
    800068d8:	00000097          	auipc	ra,0x0
    800068dc:	c4c080e7          	jalr	-948(ra) # 80006524 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    800068e0:	85e6                	mv	a1,s9
    800068e2:	8552                	mv	a0,s4
    800068e4:	00001097          	auipc	ra,0x1
    800068e8:	820080e7          	jalr	-2016(ra) # 80007104 <lst_push>
  for(; k > fk; k--) {
    800068ec:	fb8497e3          	bne	s1,s8,8000689a <bd_malloc+0xf0>
  }
  release(&lock);
    800068f0:	00032517          	auipc	a0,0x32
    800068f4:	ab050513          	addi	a0,a0,-1360 # 800383a0 <lock>
    800068f8:	ffffa097          	auipc	ra,0xffffa
    800068fc:	36a080e7          	jalr	874(ra) # 80000c62 <release>

  return p;
}
    80006900:	855a                	mv	a0,s6
    80006902:	70a6                	ld	ra,104(sp)
    80006904:	7406                	ld	s0,96(sp)
    80006906:	64e6                	ld	s1,88(sp)
    80006908:	6946                	ld	s2,80(sp)
    8000690a:	69a6                	ld	s3,72(sp)
    8000690c:	6a06                	ld	s4,64(sp)
    8000690e:	7ae2                	ld	s5,56(sp)
    80006910:	7b42                	ld	s6,48(sp)
    80006912:	7ba2                	ld	s7,40(sp)
    80006914:	7c02                	ld	s8,32(sp)
    80006916:	6ce2                	ld	s9,24(sp)
    80006918:	6d42                	ld	s10,16(sp)
    8000691a:	6da2                	ld	s11,8(sp)
    8000691c:	6165                	addi	sp,sp,112
    8000691e:	8082                	ret

0000000080006920 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006920:	7139                	addi	sp,sp,-64
    80006922:	fc06                	sd	ra,56(sp)
    80006924:	f822                	sd	s0,48(sp)
    80006926:	f426                	sd	s1,40(sp)
    80006928:	f04a                	sd	s2,32(sp)
    8000692a:	ec4e                	sd	s3,24(sp)
    8000692c:	e852                	sd	s4,16(sp)
    8000692e:	e456                	sd	s5,8(sp)
    80006930:	e05a                	sd	s6,0(sp)
    80006932:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006934:	00003a97          	auipc	s5,0x3
    80006938:	6e4aaa83          	lw	s5,1764(s5) # 8000a018 <nsizes>
  return n / BLK_SIZE(k);
    8000693c:	00003a17          	auipc	s4,0x3
    80006940:	6cca3a03          	ld	s4,1740(s4) # 8000a008 <bd_base>
    80006944:	41450a3b          	subw	s4,a0,s4
    80006948:	00003497          	auipc	s1,0x3
    8000694c:	6c84b483          	ld	s1,1736(s1) # 8000a010 <bd_sizes>
    80006950:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006954:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006956:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006958:	03595363          	bge	s2,s5,8000697e <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000695c:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006960:	013b15b3          	sll	a1,s6,s3
    80006964:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006968:	2581                	sext.w	a1,a1
    8000696a:	6088                	ld	a0,0(s1)
    8000696c:	00000097          	auipc	ra,0x0
    80006970:	b80080e7          	jalr	-1152(ra) # 800064ec <bit_isset>
    80006974:	02048493          	addi	s1,s1,32
    80006978:	e501                	bnez	a0,80006980 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    8000697a:	894e                	mv	s2,s3
    8000697c:	bff1                	j	80006958 <size+0x38>
      return k;
    }
  }
  return 0;
    8000697e:	4901                	li	s2,0
}
    80006980:	854a                	mv	a0,s2
    80006982:	70e2                	ld	ra,56(sp)
    80006984:	7442                	ld	s0,48(sp)
    80006986:	74a2                	ld	s1,40(sp)
    80006988:	7902                	ld	s2,32(sp)
    8000698a:	69e2                	ld	s3,24(sp)
    8000698c:	6a42                	ld	s4,16(sp)
    8000698e:	6aa2                	ld	s5,8(sp)
    80006990:	6b02                	ld	s6,0(sp)
    80006992:	6121                	addi	sp,sp,64
    80006994:	8082                	ret

0000000080006996 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006996:	7159                	addi	sp,sp,-112
    80006998:	f486                	sd	ra,104(sp)
    8000699a:	f0a2                	sd	s0,96(sp)
    8000699c:	eca6                	sd	s1,88(sp)
    8000699e:	e8ca                	sd	s2,80(sp)
    800069a0:	e4ce                	sd	s3,72(sp)
    800069a2:	e0d2                	sd	s4,64(sp)
    800069a4:	fc56                	sd	s5,56(sp)
    800069a6:	f85a                	sd	s6,48(sp)
    800069a8:	f45e                	sd	s7,40(sp)
    800069aa:	f062                	sd	s8,32(sp)
    800069ac:	ec66                	sd	s9,24(sp)
    800069ae:	e86a                	sd	s10,16(sp)
    800069b0:	e46e                	sd	s11,8(sp)
    800069b2:	1880                	addi	s0,sp,112
    800069b4:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    800069b6:	00032517          	auipc	a0,0x32
    800069ba:	9ea50513          	addi	a0,a0,-1558 # 800383a0 <lock>
    800069be:	ffffa097          	auipc	ra,0xffffa
    800069c2:	1d4080e7          	jalr	468(ra) # 80000b92 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800069c6:	8556                	mv	a0,s5
    800069c8:	00000097          	auipc	ra,0x0
    800069cc:	f58080e7          	jalr	-168(ra) # 80006920 <size>
    800069d0:	84aa                	mv	s1,a0
    800069d2:	00003797          	auipc	a5,0x3
    800069d6:	6467a783          	lw	a5,1606(a5) # 8000a018 <nsizes>
    800069da:	37fd                	addiw	a5,a5,-1
    800069dc:	0cf55063          	bge	a0,a5,80006a9c <bd_free+0x106>
    800069e0:	00150a13          	addi	s4,a0,1
    800069e4:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    800069e6:	00003c17          	auipc	s8,0x3
    800069ea:	622c0c13          	addi	s8,s8,1570 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    800069ee:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800069f0:	00003b17          	auipc	s6,0x3
    800069f4:	620b0b13          	addi	s6,s6,1568 # 8000a010 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    800069f8:	00003c97          	auipc	s9,0x3
    800069fc:	620c8c93          	addi	s9,s9,1568 # 8000a018 <nsizes>
    80006a00:	a82d                	j	80006a3a <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a02:	fff58d9b          	addiw	s11,a1,-1
    80006a06:	a881                	j	80006a56 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006a08:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006a0a:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006a0e:	40ba85bb          	subw	a1,s5,a1
    80006a12:	009b97b3          	sll	a5,s7,s1
    80006a16:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006a1a:	000b3783          	ld	a5,0(s6)
    80006a1e:	97d2                	add	a5,a5,s4
    80006a20:	2581                	sext.w	a1,a1
    80006a22:	6f88                	ld	a0,24(a5)
    80006a24:	00000097          	auipc	ra,0x0
    80006a28:	b30080e7          	jalr	-1232(ra) # 80006554 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a2c:	020a0a13          	addi	s4,s4,32
    80006a30:	000ca783          	lw	a5,0(s9)
    80006a34:	37fd                	addiw	a5,a5,-1
    80006a36:	06f4d363          	bge	s1,a5,80006a9c <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006a3a:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006a3e:	009b99b3          	sll	s3,s7,s1
    80006a42:	412a87bb          	subw	a5,s5,s2
    80006a46:	0337c7b3          	div	a5,a5,s3
    80006a4a:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a4e:	8b85                	andi	a5,a5,1
    80006a50:	fbcd                	bnez	a5,80006a02 <bd_free+0x6c>
    80006a52:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006a56:	fe0a0d13          	addi	s10,s4,-32
    80006a5a:	000b3783          	ld	a5,0(s6)
    80006a5e:	9d3e                	add	s10,s10,a5
    80006a60:	010d3503          	ld	a0,16(s10)
    80006a64:	00000097          	auipc	ra,0x0
    80006a68:	af0080e7          	jalr	-1296(ra) # 80006554 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006a6c:	85ee                	mv	a1,s11
    80006a6e:	010d3503          	ld	a0,16(s10)
    80006a72:	00000097          	auipc	ra,0x0
    80006a76:	a7a080e7          	jalr	-1414(ra) # 800064ec <bit_isset>
    80006a7a:	e10d                	bnez	a0,80006a9c <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006a7c:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006a80:	03b989bb          	mulw	s3,s3,s11
    80006a84:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006a86:	854a                	mv	a0,s2
    80006a88:	00000097          	auipc	ra,0x0
    80006a8c:	630080e7          	jalr	1584(ra) # 800070b8 <lst_remove>
    if(buddy % 2 == 0) {
    80006a90:	001d7d13          	andi	s10,s10,1
    80006a94:	f60d1ae3          	bnez	s10,80006a08 <bd_free+0x72>
      p = q;
    80006a98:	8aca                	mv	s5,s2
    80006a9a:	b7bd                	j	80006a08 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006a9c:	0496                	slli	s1,s1,0x5
    80006a9e:	85d6                	mv	a1,s5
    80006aa0:	00003517          	auipc	a0,0x3
    80006aa4:	57053503          	ld	a0,1392(a0) # 8000a010 <bd_sizes>
    80006aa8:	9526                	add	a0,a0,s1
    80006aaa:	00000097          	auipc	ra,0x0
    80006aae:	65a080e7          	jalr	1626(ra) # 80007104 <lst_push>
  release(&lock);
    80006ab2:	00032517          	auipc	a0,0x32
    80006ab6:	8ee50513          	addi	a0,a0,-1810 # 800383a0 <lock>
    80006aba:	ffffa097          	auipc	ra,0xffffa
    80006abe:	1a8080e7          	jalr	424(ra) # 80000c62 <release>
}
    80006ac2:	70a6                	ld	ra,104(sp)
    80006ac4:	7406                	ld	s0,96(sp)
    80006ac6:	64e6                	ld	s1,88(sp)
    80006ac8:	6946                	ld	s2,80(sp)
    80006aca:	69a6                	ld	s3,72(sp)
    80006acc:	6a06                	ld	s4,64(sp)
    80006ace:	7ae2                	ld	s5,56(sp)
    80006ad0:	7b42                	ld	s6,48(sp)
    80006ad2:	7ba2                	ld	s7,40(sp)
    80006ad4:	7c02                	ld	s8,32(sp)
    80006ad6:	6ce2                	ld	s9,24(sp)
    80006ad8:	6d42                	ld	s10,16(sp)
    80006ada:	6da2                	ld	s11,8(sp)
    80006adc:	6165                	addi	sp,sp,112
    80006ade:	8082                	ret

0000000080006ae0 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006ae0:	1141                	addi	sp,sp,-16
    80006ae2:	e422                	sd	s0,8(sp)
    80006ae4:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006ae6:	00003797          	auipc	a5,0x3
    80006aea:	5227b783          	ld	a5,1314(a5) # 8000a008 <bd_base>
    80006aee:	8d9d                	sub	a1,a1,a5
    80006af0:	47c1                	li	a5,16
    80006af2:	00a797b3          	sll	a5,a5,a0
    80006af6:	02f5c533          	div	a0,a1,a5
    80006afa:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006afc:	02f5e5b3          	rem	a1,a1,a5
    80006b00:	c191                	beqz	a1,80006b04 <blk_index_next+0x24>
      n++;
    80006b02:	2505                	addiw	a0,a0,1
  return n ;
}
    80006b04:	6422                	ld	s0,8(sp)
    80006b06:	0141                	addi	sp,sp,16
    80006b08:	8082                	ret

0000000080006b0a <log2>:

int
log2(uint64 n) {
    80006b0a:	1141                	addi	sp,sp,-16
    80006b0c:	e422                	sd	s0,8(sp)
    80006b0e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006b10:	4705                	li	a4,1
    80006b12:	00a77b63          	bgeu	a4,a0,80006b28 <log2+0x1e>
    80006b16:	87aa                	mv	a5,a0
  int k = 0;
    80006b18:	4501                	li	a0,0
    k++;
    80006b1a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006b1c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006b1e:	fef76ee3          	bltu	a4,a5,80006b1a <log2+0x10>
  }
  return k;
}
    80006b22:	6422                	ld	s0,8(sp)
    80006b24:	0141                	addi	sp,sp,16
    80006b26:	8082                	ret
  int k = 0;
    80006b28:	4501                	li	a0,0
    80006b2a:	bfe5                	j	80006b22 <log2+0x18>

0000000080006b2c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006b2c:	711d                	addi	sp,sp,-96
    80006b2e:	ec86                	sd	ra,88(sp)
    80006b30:	e8a2                	sd	s0,80(sp)
    80006b32:	e4a6                	sd	s1,72(sp)
    80006b34:	e0ca                	sd	s2,64(sp)
    80006b36:	fc4e                	sd	s3,56(sp)
    80006b38:	f852                	sd	s4,48(sp)
    80006b3a:	f456                	sd	s5,40(sp)
    80006b3c:	f05a                	sd	s6,32(sp)
    80006b3e:	ec5e                	sd	s7,24(sp)
    80006b40:	e862                	sd	s8,16(sp)
    80006b42:	e466                	sd	s9,8(sp)
    80006b44:	e06a                	sd	s10,0(sp)
    80006b46:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006b48:	00b56933          	or	s2,a0,a1
    80006b4c:	00f97913          	andi	s2,s2,15
    80006b50:	04091263          	bnez	s2,80006b94 <bd_mark+0x68>
    80006b54:	8b2a                	mv	s6,a0
    80006b56:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006b58:	00003c17          	auipc	s8,0x3
    80006b5c:	4c0c2c03          	lw	s8,1216(s8) # 8000a018 <nsizes>
    80006b60:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006b62:	00003d17          	auipc	s10,0x3
    80006b66:	4a6d0d13          	addi	s10,s10,1190 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    80006b6a:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006b6c:	00003a97          	auipc	s5,0x3
    80006b70:	4a4a8a93          	addi	s5,s5,1188 # 8000a010 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006b74:	07804563          	bgtz	s8,80006bde <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006b78:	60e6                	ld	ra,88(sp)
    80006b7a:	6446                	ld	s0,80(sp)
    80006b7c:	64a6                	ld	s1,72(sp)
    80006b7e:	6906                	ld	s2,64(sp)
    80006b80:	79e2                	ld	s3,56(sp)
    80006b82:	7a42                	ld	s4,48(sp)
    80006b84:	7aa2                	ld	s5,40(sp)
    80006b86:	7b02                	ld	s6,32(sp)
    80006b88:	6be2                	ld	s7,24(sp)
    80006b8a:	6c42                	ld	s8,16(sp)
    80006b8c:	6ca2                	ld	s9,8(sp)
    80006b8e:	6d02                	ld	s10,0(sp)
    80006b90:	6125                	addi	sp,sp,96
    80006b92:	8082                	ret
    panic("bd_mark");
    80006b94:	00003517          	auipc	a0,0x3
    80006b98:	31c50513          	addi	a0,a0,796 # 80009eb0 <syscalls+0x498>
    80006b9c:	ffffa097          	auipc	ra,0xffffa
    80006ba0:	9c8080e7          	jalr	-1592(ra) # 80000564 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006ba4:	000ab783          	ld	a5,0(s5)
    80006ba8:	97ca                	add	a5,a5,s2
    80006baa:	85a6                	mv	a1,s1
    80006bac:	6b88                	ld	a0,16(a5)
    80006bae:	00000097          	auipc	ra,0x0
    80006bb2:	976080e7          	jalr	-1674(ra) # 80006524 <bit_set>
    for(; bi < bj; bi++) {
    80006bb6:	2485                	addiw	s1,s1,1
    80006bb8:	009a0e63          	beq	s4,s1,80006bd4 <bd_mark+0xa8>
      if(k > 0) {
    80006bbc:	ff3054e3          	blez	s3,80006ba4 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006bc0:	000ab783          	ld	a5,0(s5)
    80006bc4:	97ca                	add	a5,a5,s2
    80006bc6:	85a6                	mv	a1,s1
    80006bc8:	6f88                	ld	a0,24(a5)
    80006bca:	00000097          	auipc	ra,0x0
    80006bce:	95a080e7          	jalr	-1702(ra) # 80006524 <bit_set>
    80006bd2:	bfc9                	j	80006ba4 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006bd4:	2985                	addiw	s3,s3,1
    80006bd6:	02090913          	addi	s2,s2,32
    80006bda:	f9898fe3          	beq	s3,s8,80006b78 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006bde:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006be2:	409b04bb          	subw	s1,s6,s1
    80006be6:	013c97b3          	sll	a5,s9,s3
    80006bea:	02f4c4b3          	div	s1,s1,a5
    80006bee:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006bf0:	85de                	mv	a1,s7
    80006bf2:	854e                	mv	a0,s3
    80006bf4:	00000097          	auipc	ra,0x0
    80006bf8:	eec080e7          	jalr	-276(ra) # 80006ae0 <blk_index_next>
    80006bfc:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006bfe:	faa4cfe3          	blt	s1,a0,80006bbc <bd_mark+0x90>
    80006c02:	bfc9                	j	80006bd4 <bd_mark+0xa8>

0000000080006c04 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006c04:	7139                	addi	sp,sp,-64
    80006c06:	fc06                	sd	ra,56(sp)
    80006c08:	f822                	sd	s0,48(sp)
    80006c0a:	f426                	sd	s1,40(sp)
    80006c0c:	f04a                	sd	s2,32(sp)
    80006c0e:	ec4e                	sd	s3,24(sp)
    80006c10:	e852                	sd	s4,16(sp)
    80006c12:	e456                	sd	s5,8(sp)
    80006c14:	e05a                	sd	s6,0(sp)
    80006c16:	0080                	addi	s0,sp,64
    80006c18:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c1a:	00058a9b          	sext.w	s5,a1
    80006c1e:	0015f793          	andi	a5,a1,1
    80006c22:	ebad                	bnez	a5,80006c94 <bd_initfree_pair+0x90>
    80006c24:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c28:	00599493          	slli	s1,s3,0x5
    80006c2c:	00003797          	auipc	a5,0x3
    80006c30:	3e47b783          	ld	a5,996(a5) # 8000a010 <bd_sizes>
    80006c34:	94be                	add	s1,s1,a5
    80006c36:	0104bb03          	ld	s6,16(s1)
    80006c3a:	855a                	mv	a0,s6
    80006c3c:	00000097          	auipc	ra,0x0
    80006c40:	8b0080e7          	jalr	-1872(ra) # 800064ec <bit_isset>
    80006c44:	892a                	mv	s2,a0
    80006c46:	85d2                	mv	a1,s4
    80006c48:	855a                	mv	a0,s6
    80006c4a:	00000097          	auipc	ra,0x0
    80006c4e:	8a2080e7          	jalr	-1886(ra) # 800064ec <bit_isset>
  int free = 0;
    80006c52:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c54:	02a90563          	beq	s2,a0,80006c7e <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006c58:	45c1                	li	a1,16
    80006c5a:	013599b3          	sll	s3,a1,s3
    80006c5e:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006c62:	02090c63          	beqz	s2,80006c9a <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006c66:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006c6a:	00003597          	auipc	a1,0x3
    80006c6e:	39e5b583          	ld	a1,926(a1) # 8000a008 <bd_base>
    80006c72:	95ce                	add	a1,a1,s3
    80006c74:	8526                	mv	a0,s1
    80006c76:	00000097          	auipc	ra,0x0
    80006c7a:	48e080e7          	jalr	1166(ra) # 80007104 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006c7e:	855a                	mv	a0,s6
    80006c80:	70e2                	ld	ra,56(sp)
    80006c82:	7442                	ld	s0,48(sp)
    80006c84:	74a2                	ld	s1,40(sp)
    80006c86:	7902                	ld	s2,32(sp)
    80006c88:	69e2                	ld	s3,24(sp)
    80006c8a:	6a42                	ld	s4,16(sp)
    80006c8c:	6aa2                	ld	s5,8(sp)
    80006c8e:	6b02                	ld	s6,0(sp)
    80006c90:	6121                	addi	sp,sp,64
    80006c92:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c94:	fff58a1b          	addiw	s4,a1,-1
    80006c98:	bf41                	j	80006c28 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006c9a:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006c9e:	00003597          	auipc	a1,0x3
    80006ca2:	36a5b583          	ld	a1,874(a1) # 8000a008 <bd_base>
    80006ca6:	95ce                	add	a1,a1,s3
    80006ca8:	8526                	mv	a0,s1
    80006caa:	00000097          	auipc	ra,0x0
    80006cae:	45a080e7          	jalr	1114(ra) # 80007104 <lst_push>
    80006cb2:	b7f1                	j	80006c7e <bd_initfree_pair+0x7a>

0000000080006cb4 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006cb4:	711d                	addi	sp,sp,-96
    80006cb6:	ec86                	sd	ra,88(sp)
    80006cb8:	e8a2                	sd	s0,80(sp)
    80006cba:	e4a6                	sd	s1,72(sp)
    80006cbc:	e0ca                	sd	s2,64(sp)
    80006cbe:	fc4e                	sd	s3,56(sp)
    80006cc0:	f852                	sd	s4,48(sp)
    80006cc2:	f456                	sd	s5,40(sp)
    80006cc4:	f05a                	sd	s6,32(sp)
    80006cc6:	ec5e                	sd	s7,24(sp)
    80006cc8:	e862                	sd	s8,16(sp)
    80006cca:	e466                	sd	s9,8(sp)
    80006ccc:	e06a                	sd	s10,0(sp)
    80006cce:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006cd0:	00003717          	auipc	a4,0x3
    80006cd4:	34872703          	lw	a4,840(a4) # 8000a018 <nsizes>
    80006cd8:	4785                	li	a5,1
    80006cda:	06e7db63          	bge	a5,a4,80006d50 <bd_initfree+0x9c>
    80006cde:	8aaa                	mv	s5,a0
    80006ce0:	8b2e                	mv	s6,a1
    80006ce2:	4901                	li	s2,0
  int free = 0;
    80006ce4:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006ce6:	00003c97          	auipc	s9,0x3
    80006cea:	322c8c93          	addi	s9,s9,802 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    80006cee:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006cf0:	00003b97          	auipc	s7,0x3
    80006cf4:	328b8b93          	addi	s7,s7,808 # 8000a018 <nsizes>
    80006cf8:	a039                	j	80006d06 <bd_initfree+0x52>
    80006cfa:	2905                	addiw	s2,s2,1
    80006cfc:	000ba783          	lw	a5,0(s7)
    80006d00:	37fd                	addiw	a5,a5,-1
    80006d02:	04f95863          	bge	s2,a5,80006d52 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006d06:	85d6                	mv	a1,s5
    80006d08:	854a                	mv	a0,s2
    80006d0a:	00000097          	auipc	ra,0x0
    80006d0e:	dd6080e7          	jalr	-554(ra) # 80006ae0 <blk_index_next>
    80006d12:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006d14:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006d18:	409b04bb          	subw	s1,s6,s1
    80006d1c:	012c17b3          	sll	a5,s8,s2
    80006d20:	02f4c4b3          	div	s1,s1,a5
    80006d24:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006d26:	85aa                	mv	a1,a0
    80006d28:	854a                	mv	a0,s2
    80006d2a:	00000097          	auipc	ra,0x0
    80006d2e:	eda080e7          	jalr	-294(ra) # 80006c04 <bd_initfree_pair>
    80006d32:	01450d3b          	addw	s10,a0,s4
    80006d36:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006d3a:	fc99d0e3          	bge	s3,s1,80006cfa <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006d3e:	85a6                	mv	a1,s1
    80006d40:	854a                	mv	a0,s2
    80006d42:	00000097          	auipc	ra,0x0
    80006d46:	ec2080e7          	jalr	-318(ra) # 80006c04 <bd_initfree_pair>
    80006d4a:	00ad0a3b          	addw	s4,s10,a0
    80006d4e:	b775                	j	80006cfa <bd_initfree+0x46>
  int free = 0;
    80006d50:	4a01                	li	s4,0
  }
  return free;
}
    80006d52:	8552                	mv	a0,s4
    80006d54:	60e6                	ld	ra,88(sp)
    80006d56:	6446                	ld	s0,80(sp)
    80006d58:	64a6                	ld	s1,72(sp)
    80006d5a:	6906                	ld	s2,64(sp)
    80006d5c:	79e2                	ld	s3,56(sp)
    80006d5e:	7a42                	ld	s4,48(sp)
    80006d60:	7aa2                	ld	s5,40(sp)
    80006d62:	7b02                	ld	s6,32(sp)
    80006d64:	6be2                	ld	s7,24(sp)
    80006d66:	6c42                	ld	s8,16(sp)
    80006d68:	6ca2                	ld	s9,8(sp)
    80006d6a:	6d02                	ld	s10,0(sp)
    80006d6c:	6125                	addi	sp,sp,96
    80006d6e:	8082                	ret

0000000080006d70 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006d70:	7179                	addi	sp,sp,-48
    80006d72:	f406                	sd	ra,40(sp)
    80006d74:	f022                	sd	s0,32(sp)
    80006d76:	ec26                	sd	s1,24(sp)
    80006d78:	e84a                	sd	s2,16(sp)
    80006d7a:	e44e                	sd	s3,8(sp)
    80006d7c:	1800                	addi	s0,sp,48
    80006d7e:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006d80:	00003997          	auipc	s3,0x3
    80006d84:	28898993          	addi	s3,s3,648 # 8000a008 <bd_base>
    80006d88:	0009b483          	ld	s1,0(s3)
    80006d8c:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006d90:	00003797          	auipc	a5,0x3
    80006d94:	2887a783          	lw	a5,648(a5) # 8000a018 <nsizes>
    80006d98:	37fd                	addiw	a5,a5,-1
    80006d9a:	4641                	li	a2,16
    80006d9c:	00f61633          	sll	a2,a2,a5
    80006da0:	85a6                	mv	a1,s1
    80006da2:	00003517          	auipc	a0,0x3
    80006da6:	11650513          	addi	a0,a0,278 # 80009eb8 <syscalls+0x4a0>
    80006daa:	ffffa097          	auipc	ra,0xffffa
    80006dae:	81c080e7          	jalr	-2020(ra) # 800005c6 <printf>
  bd_mark(bd_base, p);
    80006db2:	85ca                	mv	a1,s2
    80006db4:	0009b503          	ld	a0,0(s3)
    80006db8:	00000097          	auipc	ra,0x0
    80006dbc:	d74080e7          	jalr	-652(ra) # 80006b2c <bd_mark>
  return meta;
}
    80006dc0:	8526                	mv	a0,s1
    80006dc2:	70a2                	ld	ra,40(sp)
    80006dc4:	7402                	ld	s0,32(sp)
    80006dc6:	64e2                	ld	s1,24(sp)
    80006dc8:	6942                	ld	s2,16(sp)
    80006dca:	69a2                	ld	s3,8(sp)
    80006dcc:	6145                	addi	sp,sp,48
    80006dce:	8082                	ret

0000000080006dd0 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006dd0:	1101                	addi	sp,sp,-32
    80006dd2:	ec06                	sd	ra,24(sp)
    80006dd4:	e822                	sd	s0,16(sp)
    80006dd6:	e426                	sd	s1,8(sp)
    80006dd8:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006dda:	00003497          	auipc	s1,0x3
    80006dde:	23e4a483          	lw	s1,574(s1) # 8000a018 <nsizes>
    80006de2:	fff4879b          	addiw	a5,s1,-1
    80006de6:	44c1                	li	s1,16
    80006de8:	00f494b3          	sll	s1,s1,a5
    80006dec:	00003797          	auipc	a5,0x3
    80006df0:	21c7b783          	ld	a5,540(a5) # 8000a008 <bd_base>
    80006df4:	8d1d                	sub	a0,a0,a5
    80006df6:	40a4853b          	subw	a0,s1,a0
    80006dfa:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006dfe:	00905a63          	blez	s1,80006e12 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006e02:	357d                	addiw	a0,a0,-1
    80006e04:	41f5549b          	sraiw	s1,a0,0x1f
    80006e08:	01c4d49b          	srliw	s1,s1,0x1c
    80006e0c:	9ca9                	addw	s1,s1,a0
    80006e0e:	98c1                	andi	s1,s1,-16
    80006e10:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006e12:	85a6                	mv	a1,s1
    80006e14:	00003517          	auipc	a0,0x3
    80006e18:	0dc50513          	addi	a0,a0,220 # 80009ef0 <syscalls+0x4d8>
    80006e1c:	ffff9097          	auipc	ra,0xffff9
    80006e20:	7aa080e7          	jalr	1962(ra) # 800005c6 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006e24:	00003717          	auipc	a4,0x3
    80006e28:	1e473703          	ld	a4,484(a4) # 8000a008 <bd_base>
    80006e2c:	00003597          	auipc	a1,0x3
    80006e30:	1ec5a583          	lw	a1,492(a1) # 8000a018 <nsizes>
    80006e34:	fff5879b          	addiw	a5,a1,-1
    80006e38:	45c1                	li	a1,16
    80006e3a:	00f595b3          	sll	a1,a1,a5
    80006e3e:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006e42:	95ba                	add	a1,a1,a4
    80006e44:	953a                	add	a0,a0,a4
    80006e46:	00000097          	auipc	ra,0x0
    80006e4a:	ce6080e7          	jalr	-794(ra) # 80006b2c <bd_mark>
  return unavailable;
}
    80006e4e:	8526                	mv	a0,s1
    80006e50:	60e2                	ld	ra,24(sp)
    80006e52:	6442                	ld	s0,16(sp)
    80006e54:	64a2                	ld	s1,8(sp)
    80006e56:	6105                	addi	sp,sp,32
    80006e58:	8082                	ret

0000000080006e5a <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006e5a:	715d                	addi	sp,sp,-80
    80006e5c:	e486                	sd	ra,72(sp)
    80006e5e:	e0a2                	sd	s0,64(sp)
    80006e60:	fc26                	sd	s1,56(sp)
    80006e62:	f84a                	sd	s2,48(sp)
    80006e64:	f44e                	sd	s3,40(sp)
    80006e66:	f052                	sd	s4,32(sp)
    80006e68:	ec56                	sd	s5,24(sp)
    80006e6a:	e85a                	sd	s6,16(sp)
    80006e6c:	e45e                	sd	s7,8(sp)
    80006e6e:	e062                	sd	s8,0(sp)
    80006e70:	0880                	addi	s0,sp,80
    80006e72:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006e74:	fff50493          	addi	s1,a0,-1
    80006e78:	98c1                	andi	s1,s1,-16
    80006e7a:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006e7c:	00003597          	auipc	a1,0x3
    80006e80:	09458593          	addi	a1,a1,148 # 80009f10 <syscalls+0x4f8>
    80006e84:	00031517          	auipc	a0,0x31
    80006e88:	51c50513          	addi	a0,a0,1308 # 800383a0 <lock>
    80006e8c:	ffffa097          	auipc	ra,0xffffa
    80006e90:	c30080e7          	jalr	-976(ra) # 80000abc <initlock>
  bd_base = (void *) p;
    80006e94:	00003797          	auipc	a5,0x3
    80006e98:	1697ba23          	sd	s1,372(a5) # 8000a008 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e9c:	409c0933          	sub	s2,s8,s1
    80006ea0:	43f95513          	srai	a0,s2,0x3f
    80006ea4:	893d                	andi	a0,a0,15
    80006ea6:	954a                	add	a0,a0,s2
    80006ea8:	8511                	srai	a0,a0,0x4
    80006eaa:	00000097          	auipc	ra,0x0
    80006eae:	c60080e7          	jalr	-928(ra) # 80006b0a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006eb2:	47c1                	li	a5,16
    80006eb4:	00a797b3          	sll	a5,a5,a0
    80006eb8:	1b27c663          	blt	a5,s2,80007064 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006ebc:	2505                	addiw	a0,a0,1
    80006ebe:	00003797          	auipc	a5,0x3
    80006ec2:	14a7ad23          	sw	a0,346(a5) # 8000a018 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006ec6:	00003997          	auipc	s3,0x3
    80006eca:	15298993          	addi	s3,s3,338 # 8000a018 <nsizes>
    80006ece:	0009a603          	lw	a2,0(s3)
    80006ed2:	85ca                	mv	a1,s2
    80006ed4:	00003517          	auipc	a0,0x3
    80006ed8:	04450513          	addi	a0,a0,68 # 80009f18 <syscalls+0x500>
    80006edc:	ffff9097          	auipc	ra,0xffff9
    80006ee0:	6ea080e7          	jalr	1770(ra) # 800005c6 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006ee4:	00003797          	auipc	a5,0x3
    80006ee8:	1297b623          	sd	s1,300(a5) # 8000a010 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006eec:	0009a603          	lw	a2,0(s3)
    80006ef0:	00561913          	slli	s2,a2,0x5
    80006ef4:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006ef6:	0056161b          	slliw	a2,a2,0x5
    80006efa:	4581                	li	a1,0
    80006efc:	8526                	mv	a0,s1
    80006efe:	ffffa097          	auipc	ra,0xffffa
    80006f02:	f78080e7          	jalr	-136(ra) # 80000e76 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006f06:	0009a783          	lw	a5,0(s3)
    80006f0a:	06f05a63          	blez	a5,80006f7e <bd_init+0x124>
    80006f0e:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006f10:	00003a97          	auipc	s5,0x3
    80006f14:	100a8a93          	addi	s5,s5,256 # 8000a010 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f18:	00003a17          	auipc	s4,0x3
    80006f1c:	100a0a13          	addi	s4,s4,256 # 8000a018 <nsizes>
    80006f20:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006f22:	00599b93          	slli	s7,s3,0x5
    80006f26:	000ab503          	ld	a0,0(s5)
    80006f2a:	955e                	add	a0,a0,s7
    80006f2c:	00000097          	auipc	ra,0x0
    80006f30:	166080e7          	jalr	358(ra) # 80007092 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f34:	000a2483          	lw	s1,0(s4)
    80006f38:	34fd                	addiw	s1,s1,-1
    80006f3a:	413484bb          	subw	s1,s1,s3
    80006f3e:	009b14bb          	sllw	s1,s6,s1
    80006f42:	fff4879b          	addiw	a5,s1,-1
    80006f46:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f4a:	01d4d49b          	srliw	s1,s1,0x1d
    80006f4e:	9cbd                	addw	s1,s1,a5
    80006f50:	98e1                	andi	s1,s1,-8
    80006f52:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006f54:	000ab783          	ld	a5,0(s5)
    80006f58:	9bbe                	add	s7,s7,a5
    80006f5a:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006f5e:	848d                	srai	s1,s1,0x3
    80006f60:	8626                	mv	a2,s1
    80006f62:	4581                	li	a1,0
    80006f64:	854a                	mv	a0,s2
    80006f66:	ffffa097          	auipc	ra,0xffffa
    80006f6a:	f10080e7          	jalr	-240(ra) # 80000e76 <memset>
    p += sz;
    80006f6e:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006f70:	0985                	addi	s3,s3,1
    80006f72:	000a2703          	lw	a4,0(s4)
    80006f76:	0009879b          	sext.w	a5,s3
    80006f7a:	fae7c4e3          	blt	a5,a4,80006f22 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006f7e:	00003797          	auipc	a5,0x3
    80006f82:	09a7a783          	lw	a5,154(a5) # 8000a018 <nsizes>
    80006f86:	4705                	li	a4,1
    80006f88:	06f75163          	bge	a4,a5,80006fea <bd_init+0x190>
    80006f8c:	02000a13          	li	s4,32
    80006f90:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f92:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006f94:	00003b17          	auipc	s6,0x3
    80006f98:	07cb0b13          	addi	s6,s6,124 # 8000a010 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006f9c:	00003a97          	auipc	s5,0x3
    80006fa0:	07ca8a93          	addi	s5,s5,124 # 8000a018 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006fa4:	37fd                	addiw	a5,a5,-1
    80006fa6:	413787bb          	subw	a5,a5,s3
    80006faa:	00fb94bb          	sllw	s1,s7,a5
    80006fae:	fff4879b          	addiw	a5,s1,-1
    80006fb2:	41f7d49b          	sraiw	s1,a5,0x1f
    80006fb6:	01d4d49b          	srliw	s1,s1,0x1d
    80006fba:	9cbd                	addw	s1,s1,a5
    80006fbc:	98e1                	andi	s1,s1,-8
    80006fbe:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006fc0:	000b3783          	ld	a5,0(s6)
    80006fc4:	97d2                	add	a5,a5,s4
    80006fc6:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006fca:	848d                	srai	s1,s1,0x3
    80006fcc:	8626                	mv	a2,s1
    80006fce:	4581                	li	a1,0
    80006fd0:	854a                	mv	a0,s2
    80006fd2:	ffffa097          	auipc	ra,0xffffa
    80006fd6:	ea4080e7          	jalr	-348(ra) # 80000e76 <memset>
    p += sz;
    80006fda:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006fdc:	2985                	addiw	s3,s3,1
    80006fde:	000aa783          	lw	a5,0(s5)
    80006fe2:	020a0a13          	addi	s4,s4,32
    80006fe6:	faf9cfe3          	blt	s3,a5,80006fa4 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006fea:	197d                	addi	s2,s2,-1
    80006fec:	ff097913          	andi	s2,s2,-16
    80006ff0:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006ff2:	854a                	mv	a0,s2
    80006ff4:	00000097          	auipc	ra,0x0
    80006ff8:	d7c080e7          	jalr	-644(ra) # 80006d70 <bd_mark_data_structures>
    80006ffc:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006ffe:	85ca                	mv	a1,s2
    80007000:	8562                	mv	a0,s8
    80007002:	00000097          	auipc	ra,0x0
    80007006:	dce080e7          	jalr	-562(ra) # 80006dd0 <bd_mark_unavailable>
    8000700a:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000700c:	00003a97          	auipc	s5,0x3
    80007010:	00ca8a93          	addi	s5,s5,12 # 8000a018 <nsizes>
    80007014:	000aa783          	lw	a5,0(s5)
    80007018:	37fd                	addiw	a5,a5,-1
    8000701a:	44c1                	li	s1,16
    8000701c:	00f497b3          	sll	a5,s1,a5
    80007020:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007022:	00003597          	auipc	a1,0x3
    80007026:	fe65b583          	ld	a1,-26(a1) # 8000a008 <bd_base>
    8000702a:	95be                	add	a1,a1,a5
    8000702c:	854a                	mv	a0,s2
    8000702e:	00000097          	auipc	ra,0x0
    80007032:	c86080e7          	jalr	-890(ra) # 80006cb4 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007036:	000aa603          	lw	a2,0(s5)
    8000703a:	367d                	addiw	a2,a2,-1
    8000703c:	00c49633          	sll	a2,s1,a2
    80007040:	41460633          	sub	a2,a2,s4
    80007044:	41360633          	sub	a2,a2,s3
    80007048:	02c51463          	bne	a0,a2,80007070 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    8000704c:	60a6                	ld	ra,72(sp)
    8000704e:	6406                	ld	s0,64(sp)
    80007050:	74e2                	ld	s1,56(sp)
    80007052:	7942                	ld	s2,48(sp)
    80007054:	79a2                	ld	s3,40(sp)
    80007056:	7a02                	ld	s4,32(sp)
    80007058:	6ae2                	ld	s5,24(sp)
    8000705a:	6b42                	ld	s6,16(sp)
    8000705c:	6ba2                	ld	s7,8(sp)
    8000705e:	6c02                	ld	s8,0(sp)
    80007060:	6161                	addi	sp,sp,80
    80007062:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80007064:	2509                	addiw	a0,a0,2
    80007066:	00003797          	auipc	a5,0x3
    8000706a:	faa7a923          	sw	a0,-78(a5) # 8000a018 <nsizes>
    8000706e:	bda1                	j	80006ec6 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007070:	85aa                	mv	a1,a0
    80007072:	00003517          	auipc	a0,0x3
    80007076:	ee650513          	addi	a0,a0,-282 # 80009f58 <syscalls+0x540>
    8000707a:	ffff9097          	auipc	ra,0xffff9
    8000707e:	54c080e7          	jalr	1356(ra) # 800005c6 <printf>
    panic("bd_init: free mem");
    80007082:	00003517          	auipc	a0,0x3
    80007086:	ee650513          	addi	a0,a0,-282 # 80009f68 <syscalls+0x550>
    8000708a:	ffff9097          	auipc	ra,0xffff9
    8000708e:	4da080e7          	jalr	1242(ra) # 80000564 <panic>

0000000080007092 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007092:	1141                	addi	sp,sp,-16
    80007094:	e422                	sd	s0,8(sp)
    80007096:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007098:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000709a:	e508                	sd	a0,8(a0)
}
    8000709c:	6422                	ld	s0,8(sp)
    8000709e:	0141                	addi	sp,sp,16
    800070a0:	8082                	ret

00000000800070a2 <lst_empty>:

int
lst_empty(struct list *lst) {
    800070a2:	1141                	addi	sp,sp,-16
    800070a4:	e422                	sd	s0,8(sp)
    800070a6:	0800                	addi	s0,sp,16
  return lst->next == lst;
    800070a8:	611c                	ld	a5,0(a0)
    800070aa:	40a78533          	sub	a0,a5,a0
}
    800070ae:	00153513          	seqz	a0,a0
    800070b2:	6422                	ld	s0,8(sp)
    800070b4:	0141                	addi	sp,sp,16
    800070b6:	8082                	ret

00000000800070b8 <lst_remove>:

void
lst_remove(struct list *e) {
    800070b8:	1141                	addi	sp,sp,-16
    800070ba:	e422                	sd	s0,8(sp)
    800070bc:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    800070be:	6518                	ld	a4,8(a0)
    800070c0:	611c                	ld	a5,0(a0)
    800070c2:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    800070c4:	6518                	ld	a4,8(a0)
    800070c6:	e798                	sd	a4,8(a5)
}
    800070c8:	6422                	ld	s0,8(sp)
    800070ca:	0141                	addi	sp,sp,16
    800070cc:	8082                	ret

00000000800070ce <lst_pop>:

void*
lst_pop(struct list *lst) {
    800070ce:	1101                	addi	sp,sp,-32
    800070d0:	ec06                	sd	ra,24(sp)
    800070d2:	e822                	sd	s0,16(sp)
    800070d4:	e426                	sd	s1,8(sp)
    800070d6:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800070d8:	6104                	ld	s1,0(a0)
    800070da:	00a48d63          	beq	s1,a0,800070f4 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800070de:	8526                	mv	a0,s1
    800070e0:	00000097          	auipc	ra,0x0
    800070e4:	fd8080e7          	jalr	-40(ra) # 800070b8 <lst_remove>
  return (void *)p;
}
    800070e8:	8526                	mv	a0,s1
    800070ea:	60e2                	ld	ra,24(sp)
    800070ec:	6442                	ld	s0,16(sp)
    800070ee:	64a2                	ld	s1,8(sp)
    800070f0:	6105                	addi	sp,sp,32
    800070f2:	8082                	ret
    panic("lst_pop");
    800070f4:	00003517          	auipc	a0,0x3
    800070f8:	e8c50513          	addi	a0,a0,-372 # 80009f80 <syscalls+0x568>
    800070fc:	ffff9097          	auipc	ra,0xffff9
    80007100:	468080e7          	jalr	1128(ra) # 80000564 <panic>

0000000080007104 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007104:	1141                	addi	sp,sp,-16
    80007106:	e422                	sd	s0,8(sp)
    80007108:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000710a:	611c                	ld	a5,0(a0)
    8000710c:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    8000710e:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007110:	611c                	ld	a5,0(a0)
    80007112:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007114:	e10c                	sd	a1,0(a0)
}
    80007116:	6422                	ld	s0,8(sp)
    80007118:	0141                	addi	sp,sp,16
    8000711a:	8082                	ret

000000008000711c <lst_print>:

void
lst_print(struct list *lst)
{
    8000711c:	7179                	addi	sp,sp,-48
    8000711e:	f406                	sd	ra,40(sp)
    80007120:	f022                	sd	s0,32(sp)
    80007122:	ec26                	sd	s1,24(sp)
    80007124:	e84a                	sd	s2,16(sp)
    80007126:	e44e                	sd	s3,8(sp)
    80007128:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000712a:	6104                	ld	s1,0(a0)
    8000712c:	02950063          	beq	a0,s1,8000714c <lst_print+0x30>
    80007130:	892a                	mv	s2,a0
    printf(" %p", p);
    80007132:	00003997          	auipc	s3,0x3
    80007136:	e5698993          	addi	s3,s3,-426 # 80009f88 <syscalls+0x570>
    8000713a:	85a6                	mv	a1,s1
    8000713c:	854e                	mv	a0,s3
    8000713e:	ffff9097          	auipc	ra,0xffff9
    80007142:	488080e7          	jalr	1160(ra) # 800005c6 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007146:	6084                	ld	s1,0(s1)
    80007148:	fe9919e3          	bne	s2,s1,8000713a <lst_print+0x1e>
  }
  printf("\n");
    8000714c:	00002517          	auipc	a0,0x2
    80007150:	0b450513          	addi	a0,a0,180 # 80009200 <digits+0x90>
    80007154:	ffff9097          	auipc	ra,0xffff9
    80007158:	472080e7          	jalr	1138(ra) # 800005c6 <printf>
}
    8000715c:	70a2                	ld	ra,40(sp)
    8000715e:	7402                	ld	s0,32(sp)
    80007160:	64e2                	ld	s1,24(sp)
    80007162:	6942                	ld	s2,16(sp)
    80007164:	69a2                	ld	s3,8(sp)
    80007166:	6145                	addi	sp,sp,48
    80007168:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...

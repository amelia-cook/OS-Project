
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	17010113          	addi	sp,sp,368 # 8000a170 <stack0>
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
    80000056:	fde70713          	addi	a4,a4,-34 # 8000a030 <timer_scratch>
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
    80000068:	e6c78793          	addi	a5,a5,-404 # 80005ed0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc642f>
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
    8000012c:	04850513          	addi	a0,a0,72 # 80012170 <cons>
    80000130:	00001097          	auipc	ra,0x1
    80000134:	a62080e7          	jalr	-1438(ra) # 80000b92 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000138:	00012497          	auipc	s1,0x12
    8000013c:	03848493          	addi	s1,s1,56 # 80012170 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000140:	00012917          	auipc	s2,0x12
    80000144:	0d090913          	addi	s2,s2,208 # 80012210 <cons+0xa0>
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
    80000172:	332080e7          	jalr	818(ra) # 800024a0 <sleep>
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
    800001ae:	558080e7          	jalr	1368(ra) # 80002702 <either_copyout>
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
    800001c2:	fb250513          	addi	a0,a0,-78 # 80012170 <cons>
    800001c6:	00001097          	auipc	ra,0x1
    800001ca:	a9c080e7          	jalr	-1380(ra) # 80000c62 <release>

  return target - n;
    800001ce:	413b053b          	subw	a0,s6,s3
    800001d2:	a811                	j	800001e6 <consoleread+0xe4>
        release(&cons.lock);
    800001d4:	00012517          	auipc	a0,0x12
    800001d8:	f9c50513          	addi	a0,a0,-100 # 80012170 <cons>
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
    8000020e:	00f72323          	sw	a5,6(a4) # 80012210 <cons+0xa0>
    80000212:	b775                	j	800001be <consoleread+0xbc>

0000000080000214 <consputc>:
  if(panicked){
    80000214:	0000a797          	auipc	a5,0xa
    80000218:	ddc7a783          	lw	a5,-548(a5) # 80009ff0 <panicked>
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
    8000027e:	ef650513          	addi	a0,a0,-266 # 80012170 <cons>
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
    800002a0:	4bc080e7          	jalr	1212(ra) # 80002758 <either_copyin>
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
    800002c0:	eb450513          	addi	a0,a0,-332 # 80012170 <cons>
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
    800002f6:	e7e50513          	addi	a0,a0,-386 # 80012170 <cons>
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
    8000031c:	496080e7          	jalr	1174(ra) # 800027ae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000320:	00012517          	auipc	a0,0x12
    80000324:	e5050513          	addi	a0,a0,-432 # 80012170 <cons>
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
    80000348:	e2c70713          	addi	a4,a4,-468 # 80012170 <cons>
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
    80000372:	e0278793          	addi	a5,a5,-510 # 80012170 <cons>
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
    800003a0:	e747a783          	lw	a5,-396(a5) # 80012210 <cons+0xa0>
    800003a4:	0807879b          	addiw	a5,a5,128
    800003a8:	f6f61ce3          	bne	a2,a5,80000320 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003ac:	863e                	mv	a2,a5
    800003ae:	a07d                	j	8000045c <consoleintr+0x178>
    while(cons.e != cons.w &&
    800003b0:	00012717          	auipc	a4,0x12
    800003b4:	dc070713          	addi	a4,a4,-576 # 80012170 <cons>
    800003b8:	0a872783          	lw	a5,168(a4)
    800003bc:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003c0:	00012497          	auipc	s1,0x12
    800003c4:	db048493          	addi	s1,s1,-592 # 80012170 <cons>
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
    80000400:	d7470713          	addi	a4,a4,-652 # 80012170 <cons>
    80000404:	0a872783          	lw	a5,168(a4)
    80000408:	0a472703          	lw	a4,164(a4)
    8000040c:	f0f70ae3          	beq	a4,a5,80000320 <consoleintr+0x3c>
      cons.e--;
    80000410:	37fd                	addiw	a5,a5,-1
    80000412:	00012717          	auipc	a4,0x12
    80000416:	e0f72323          	sw	a5,-506(a4) # 80012218 <cons+0xa8>
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
    8000043c:	d3878793          	addi	a5,a5,-712 # 80012170 <cons>
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
    80000460:	dac7ac23          	sw	a2,-584(a5) # 80012214 <cons+0xa4>
        wakeup(&cons.r);
    80000464:	00012517          	auipc	a0,0x12
    80000468:	dac50513          	addi	a0,a0,-596 # 80012210 <cons+0xa0>
    8000046c:	00002097          	auipc	ra,0x2
    80000470:	1b4080e7          	jalr	436(ra) # 80002620 <wakeup>
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
    8000048a:	cea50513          	addi	a0,a0,-790 # 80012170 <cons>
    8000048e:	00000097          	auipc	ra,0x0
    80000492:	62e080e7          	jalr	1582(ra) # 80000abc <initlock>

  uartinit();
    80000496:	00000097          	auipc	ra,0x0
    8000049a:	3f6080e7          	jalr	1014(ra) # 8000088c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000049e:	00037797          	auipc	a5,0x37
    800004a2:	d6a78793          	addi	a5,a5,-662 # 80037208 <devsw>
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
    80000574:	cc07a823          	sw	zero,-816(a5) # 80012240 <pr+0x20>
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
    80000596:	f7650513          	addi	a0,a0,-138 # 80009508 <digits+0x398>
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
    800005c0:	a2f72a23          	sw	a5,-1484(a4) # 80009ff0 <panicked>
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
    800005fc:	c48c2c03          	lw	s8,-952(s8) # 80012240 <pr+0x20>
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
    8000063c:	be850513          	addi	a0,a0,-1048 # 80012220 <pr>
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
    800007e2:	a4250513          	addi	a0,a0,-1470 # 80012220 <pr>
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
    80000868:	9bc48493          	addi	s1,s1,-1604 # 80012220 <pr>
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
    80000954:	a8078793          	addi	a5,a5,-1408 # 800383d0 <end>
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
    80000974:	8d890913          	addi	s2,s2,-1832 # 80012248 <kmem>
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
    80000a1a:	83250513          	addi	a0,a0,-1998 # 80012248 <kmem>
    80000a1e:	00000097          	auipc	ra,0x0
    80000a22:	09e080e7          	jalr	158(ra) # 80000abc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000a26:	45c5                	li	a1,17
    80000a28:	05ee                	slli	a1,a1,0x1b
    80000a2a:	00038517          	auipc	a0,0x38
    80000a2e:	9a650513          	addi	a0,a0,-1626 # 800383d0 <end>
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
    80000a50:	7fc48493          	addi	s1,s1,2044 # 80012248 <kmem>
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
    80000a68:	7e450513          	addi	a0,a0,2020 # 80012248 <kmem>
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
    80000a9a:	7b250513          	addi	a0,a0,1970 # 80012248 <kmem>
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
    80000ab2:	7c253503          	ld	a0,1986(a0) # 80012270 <kmem+0x28>
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
    80000ad2:	5267a783          	lw	a5,1318(a5) # 80009ff4 <nlock>
    80000ad6:	6709                	lui	a4,0x2
    80000ad8:	70f70713          	addi	a4,a4,1807 # 270f <_entry-0x7fffd8f1>
    80000adc:	02f74063          	blt	a4,a5,80000afc <initlock+0x40>
    panic("initlock");
  locks[nlock] = lk;
    80000ae0:	00379693          	slli	a3,a5,0x3
    80000ae4:	00011717          	auipc	a4,0x11
    80000ae8:	79470713          	addi	a4,a4,1940 # 80012278 <locks>
    80000aec:	9736                	add	a4,a4,a3
    80000aee:	e308                	sd	a0,0(a4)
  nlock++;
    80000af0:	2785                	addiw	a5,a5,1
    80000af2:	00009717          	auipc	a4,0x9
    80000af6:	50f72123          	sw	a5,1282(a4) # 80009ff4 <nlock>
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
    80000cf8:	11e080e7          	jalr	286(ra) # 80002e12 <argint>
    80000cfc:	12054463          	bltz	a0,80000e24 <sys_ntas+0x150>
    return -1;
  }
  if(zero == 0) {
    80000d00:	fac42783          	lw	a5,-84(s0)
    80000d04:	e39d                	bnez	a5,80000d2a <sys_ntas+0x56>
    80000d06:	00011797          	auipc	a5,0x11
    80000d0a:	57278793          	addi	a5,a5,1394 # 80012278 <locks>
    80000d0e:	00025697          	auipc	a3,0x25
    80000d12:	dea68693          	addi	a3,a3,-534 # 80025af8 <pid_lock>
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
    80000d3e:	53eb0b13          	addi	s6,s6,1342 # 80012278 <locks>
    80000d42:	00025b97          	auipc	s7,0x25
    80000d46:	db6b8b93          	addi	s7,s7,-586 # 80025af8 <pid_lock>
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
    80000db4:	4c848493          	addi	s1,s1,1224 # 80012278 <locks>
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
    8000105c:	fa070713          	addi	a4,a4,-96 # 80009ff8 <started>
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
    80001092:	91a080e7          	jalr	-1766(ra) # 800029a8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001096:	00005097          	auipc	ra,0x5
    8000109a:	e7a080e7          	jalr	-390(ra) # 80005f10 <plicinithart>
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
    800010ba:	45250513          	addi	a0,a0,1106 # 80009508 <digits+0x398>
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	508080e7          	jalr	1288(ra) # 800005c6 <printf>
    printf("xv6 kernel is booting\n");
    800010c6:	00008517          	auipc	a0,0x8
    800010ca:	17a50513          	addi	a0,a0,378 # 80009240 <digits+0xd0>
    800010ce:	fffff097          	auipc	ra,0xfffff
    800010d2:	4f8080e7          	jalr	1272(ra) # 800005c6 <printf>
    printf("\n");
    800010d6:	00008517          	auipc	a0,0x8
    800010da:	43250513          	addi	a0,a0,1074 # 80009508 <digits+0x398>
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
    8000110a:	87a080e7          	jalr	-1926(ra) # 80002980 <trapinit>
    trapinithart();  // install kernel trap vector
    8000110e:	00002097          	auipc	ra,0x2
    80001112:	89a080e7          	jalr	-1894(ra) # 800029a8 <trapinithart>
    plicinit();      // set up interrupt controller
    80001116:	00005097          	auipc	ra,0x5
    8000111a:	de4080e7          	jalr	-540(ra) # 80005efa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111e:	00005097          	auipc	ra,0x5
    80001122:	df2080e7          	jalr	-526(ra) # 80005f10 <plicinithart>
    binit();         // buffer cache
    80001126:	00002097          	auipc	ra,0x2
    8000112a:	fcc080e7          	jalr	-52(ra) # 800030f2 <binit>
    iinit();         // inode cache
    8000112e:	00002097          	auipc	ra,0x2
    80001132:	65c080e7          	jalr	1628(ra) # 8000378a <iinit>
    fileinit();      // file table
    80001136:	00003097          	auipc	ra,0x3
    8000113a:	5f4080e7          	jalr	1524(ra) # 8000472a <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000113e:	00005097          	auipc	ra,0x5
    80001142:	eca080e7          	jalr	-310(ra) # 80006008 <virtio_disk_init>
    userinit();      // first user process
    80001146:	00001097          	auipc	ra,0x1
    8000114a:	cb2080e7          	jalr	-846(ra) # 80001df8 <userinit>
    __sync_synchronize();
    8000114e:	0ff0000f          	fence
    started = 1;
    80001152:	4785                	li	a5,1
    80001154:	00009717          	auipc	a4,0x9
    80001158:	eaf72223          	sw	a5,-348(a4) # 80009ff8 <started>
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
    80001278:	d8c7b783          	ld	a5,-628(a5) # 8000a000 <kernel_pagetable>
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
    80001386:	c7e53503          	ld	a0,-898(a0) # 8000a000 <kernel_pagetable>
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
    800013c2:	c4a7b123          	sd	a0,-958(a5) # 8000a000 <kernel_pagetable>
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

    // wait timing data
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


//timing functions
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
    80001a76:	08650513          	addi	a0,a0,134 # 80025af8 <pid_lock>
    80001a7a:	fffff097          	auipc	ra,0xfffff
    80001a7e:	042080e7          	jalr	66(ra) # 80000abc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a82:	00024917          	auipc	s2,0x24
    80001a86:	49690913          	addi	s2,s2,1174 # 80025f18 <proc>
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
    80001aa8:	274a0a13          	addi	s4,s4,628 # 8002cd18 <tickslock>
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
    80001b44:	fd850513          	addi	a0,a0,-40 # 80025b18 <cpus>
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
    80001b6c:	f9070713          	addi	a4,a4,-112 # 80025af8 <pid_lock>
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
    80001ba4:	4007a783          	lw	a5,1024(a5) # 80009fa0 <first.1>
    80001ba8:	eb89                	bnez	a5,80001bba <forkret+0x32>
  usertrapret();
    80001baa:	00001097          	auipc	ra,0x1
    80001bae:	e16080e7          	jalr	-490(ra) # 800029c0 <usertrapret>
}
    80001bb2:	60a2                	ld	ra,8(sp)
    80001bb4:	6402                	ld	s0,0(sp)
    80001bb6:	0141                	addi	sp,sp,16
    80001bb8:	8082                	ret
    first = 0;
    80001bba:	00008797          	auipc	a5,0x8
    80001bbe:	3e07a323          	sw	zero,998(a5) # 80009fa0 <first.1>
    fsinit(ROOTDEV);
    80001bc2:	4505                	li	a0,1
    80001bc4:	00002097          	auipc	ra,0x2
    80001bc8:	b46080e7          	jalr	-1210(ra) # 8000370a <fsinit>
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
    80001bde:	f1e90913          	addi	s2,s2,-226 # 80025af8 <pid_lock>
    80001be2:	854a                	mv	a0,s2
    80001be4:	fffff097          	auipc	ra,0xfffff
    80001be8:	fae080e7          	jalr	-82(ra) # 80000b92 <acquire>
  pid = nextpid;
    80001bec:	00008797          	auipc	a5,0x8
    80001bf0:	3b878793          	addi	a5,a5,952 # 80009fa4 <nextpid>
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
    80001c80:	29c48493          	addi	s1,s1,668 # 80025f18 <proc>
    80001c84:	0002b917          	auipc	s2,0x2b
    80001c88:	09490913          	addi	s2,s2,148 # 8002cd18 <tickslock>
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
    80001e10:	1ea7be23          	sd	a0,508(a5) # 8000a008 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e14:	03400613          	li	a2,52
    80001e18:	00008597          	auipc	a1,0x8
    80001e1c:	19858593          	addi	a1,a1,408 # 80009fb0 <initcode>
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
    80001e5a:	2e2080e7          	jalr	738(ra) # 80004138 <namei>
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
    80001fac:	814080e7          	jalr	-2028(ra) # 800047bc <filedup>
    80001fb0:	00a93023          	sd	a0,0(s2)
    80001fb4:	b7e5                	j	80001f9c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001fb6:	158ab503          	ld	a0,344(s5)
    80001fba:	00002097          	auipc	ra,0x2
    80001fbe:	98a080e7          	jalr	-1654(ra) # 80003944 <idup>
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
    80002022:	efa48493          	addi	s1,s1,-262 # 80025f18 <proc>
      pp->parent = initproc;
    80002026:	00008a17          	auipc	s4,0x8
    8000202a:	fe2a0a13          	addi	s4,s4,-30 # 8000a008 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000202e:	0002b997          	auipc	s3,0x2b
    80002032:	cea98993          	addi	s3,s3,-790 # 8002cd18 <tickslock>
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
    80002098:	a6470713          	addi	a4,a4,-1436 # 80025af8 <pid_lock>
    8000209c:	975e                	add	a4,a4,s7
    8000209e:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    800020a2:	00024717          	auipc	a4,0x24
    800020a6:	a7e70713          	addi	a4,a4,-1410 # 80025b20 <cpus+0x8>
    800020aa:	9bba                	add	s7,s7,a4
        p->state = RUNNING;
    800020ac:	4c0d                	li	s8,3
        c->proc = p;
    800020ae:	079e                	slli	a5,a5,0x7
    800020b0:	00024917          	auipc	s2,0x24
    800020b4:	a4890913          	addi	s2,s2,-1464 # 80025af8 <pid_lock>
    800020b8:	993e                	add	s2,s2,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ba:	0002ba97          	auipc	s5,0x2b
    800020be:	c5ea8a93          	addi	s5,s5,-930 # 8002cd18 <tickslock>
    800020c2:	a07d                	j	80002170 <scheduler+0xfe>
  asm volatile ("rdtime %0" : "=r" (time)); 
    800020c4:	c01026f3          	rdtime	a3
          p->total_wait_time += getTime() - p->wait_start;
    800020c8:	1984b703          	ld	a4,408(s1)
    800020cc:	40f707b3          	sub	a5,a4,a5
    800020d0:	97b6                	add	a5,a5,a3
    800020d2:	18f4bc23          	sd	a5,408(s1)
          p->wait_start = 0;
    800020d6:	1a04b423          	sd	zero,424(s1)
    800020da:	a091                	j	8000211e <scheduler+0xac>
  asm volatile ("rdtime %0" : "=r" (time)); 
    800020dc:	c01027f3          	rdtime	a5
          p->first_run_time = getTime();
    800020e0:	18f4b023          	sd	a5,384(s1)
          p->first_run = 1;
    800020e4:	1b64aa23          	sw	s6,436(s1)
    800020e8:	a835                	j	80002124 <scheduler+0xb2>
        c->proc = 0;
    800020ea:	02093023          	sd	zero,32(s2)
        found = 1;
    800020ee:	8cda                	mv	s9,s6
      c->intena = 0;
    800020f0:	08092e23          	sw	zero,156(s2)
      release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	b6c080e7          	jalr	-1172(ra) # 80000c62 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020fe:	1b848493          	addi	s1,s1,440
    80002102:	07548363          	beq	s1,s5,80002168 <scheduler+0xf6>
      acquire(&p->lock);
    80002106:	89a6                	mv	s3,s1
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	a88080e7          	jalr	-1400(ra) # 80000b92 <acquire>
      if(p->state == RUNNABLE) {
    80002112:	509c                	lw	a5,32(s1)
    80002114:	fd479ee3          	bne	a5,s4,800020f0 <scheduler+0x7e>
        if(p->wait_start != 0){
    80002118:	1a84b783          	ld	a5,424(s1)
    8000211c:	f7c5                	bnez	a5,800020c4 <scheduler+0x52>
        if(p->first_run == 0) {
    8000211e:	1b44a783          	lw	a5,436(s1)
    80002122:	dfcd                	beqz	a5,800020dc <scheduler+0x6a>
        p->state = RUNNING;
    80002124:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    80002128:	02993023          	sd	s1,32(s2)
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000212c:	c01027f3          	rdtime	a5
        p->last_scheduled = getTime();
    80002130:	18f4b823          	sd	a5,400(s1)
        p->context_switches++;
    80002134:	1b04a783          	lw	a5,432(s1)
    80002138:	2785                	addiw	a5,a5,1
    8000213a:	1af4a823          	sw	a5,432(s1)
        swtch(&c->scheduler, &p->context);
    8000213e:	06898593          	addi	a1,s3,104
    80002142:	855e                	mv	a0,s7
    80002144:	00000097          	auipc	ra,0x0
    80002148:	738080e7          	jalr	1848(ra) # 8000287c <swtch>
        if(c->proc != 0) {  // process still exists
    8000214c:	02093783          	ld	a5,32(s2)
    80002150:	dfc9                	beqz	a5,800020ea <scheduler+0x78>
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002152:	c0102773          	rdtime	a4
          p->total_run_time += getTime() - p->last_scheduled;
    80002156:	1884b783          	ld	a5,392(s1)
    8000215a:	1904b683          	ld	a3,400(s1)
    8000215e:	8f95                	sub	a5,a5,a3
    80002160:	97ba                	add	a5,a5,a4
    80002162:	18f4b423          	sd	a5,392(s1)
    80002166:	b751                	j	800020ea <scheduler+0x78>
    if(found == 0){
    80002168:	000c9463          	bnez	s9,80002170 <scheduler+0xfe>
      asm volatile("wfi");
    8000216c:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002170:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002174:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002178:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000217c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002180:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002182:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002186:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002188:	00024497          	auipc	s1,0x24
    8000218c:	d9048493          	addi	s1,s1,-624 # 80025f18 <proc>
      if(p->state == RUNNABLE) {
    80002190:	4a09                	li	s4,2
        found = 1;
    80002192:	4b05                	li	s6,1
    80002194:	bf8d                	j	80002106 <scheduler+0x94>

0000000080002196 <sched>:
{
    80002196:	7179                	addi	sp,sp,-48
    80002198:	f406                	sd	ra,40(sp)
    8000219a:	f022                	sd	s0,32(sp)
    8000219c:	ec26                	sd	s1,24(sp)
    8000219e:	e84a                	sd	s2,16(sp)
    800021a0:	e44e                	sd	s3,8(sp)
    800021a2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021a4:	00000097          	auipc	ra,0x0
    800021a8:	9ac080e7          	jalr	-1620(ra) # 80001b50 <myproc>
    800021ac:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	966080e7          	jalr	-1690(ra) # 80000b14 <holding>
    800021b6:	c93d                	beqz	a0,8000222c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021b8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021ba:	2781                	sext.w	a5,a5
    800021bc:	079e                	slli	a5,a5,0x7
    800021be:	00024717          	auipc	a4,0x24
    800021c2:	93a70713          	addi	a4,a4,-1734 # 80025af8 <pid_lock>
    800021c6:	97ba                	add	a5,a5,a4
    800021c8:	0987a703          	lw	a4,152(a5)
    800021cc:	4785                	li	a5,1
    800021ce:	06f71763          	bne	a4,a5,8000223c <sched+0xa6>
  if(p->state == RUNNING)
    800021d2:	5098                	lw	a4,32(s1)
    800021d4:	478d                	li	a5,3
    800021d6:	06f70b63          	beq	a4,a5,8000224c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021da:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021de:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021e0:	efb5                	bnez	a5,8000225c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021e2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800021e4:	00024917          	auipc	s2,0x24
    800021e8:	91490913          	addi	s2,s2,-1772 # 80025af8 <pid_lock>
    800021ec:	2781                	sext.w	a5,a5
    800021ee:	079e                	slli	a5,a5,0x7
    800021f0:	97ca                	add	a5,a5,s2
    800021f2:	09c7a983          	lw	s3,156(a5)
    800021f6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    800021f8:	2781                	sext.w	a5,a5
    800021fa:	079e                	slli	a5,a5,0x7
    800021fc:	00024597          	auipc	a1,0x24
    80002200:	92458593          	addi	a1,a1,-1756 # 80025b20 <cpus+0x8>
    80002204:	95be                	add	a1,a1,a5
    80002206:	06848513          	addi	a0,s1,104
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	672080e7          	jalr	1650(ra) # 8000287c <swtch>
    80002212:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002214:	2781                	sext.w	a5,a5
    80002216:	079e                	slli	a5,a5,0x7
    80002218:	97ca                	add	a5,a5,s2
    8000221a:	0937ae23          	sw	s3,156(a5)
}
    8000221e:	70a2                	ld	ra,40(sp)
    80002220:	7402                	ld	s0,32(sp)
    80002222:	64e2                	ld	s1,24(sp)
    80002224:	6942                	ld	s2,16(sp)
    80002226:	69a2                	ld	s3,8(sp)
    80002228:	6145                	addi	sp,sp,48
    8000222a:	8082                	ret
    panic("sched p->lock");
    8000222c:	00007517          	auipc	a0,0x7
    80002230:	19c50513          	addi	a0,a0,412 # 800093c8 <digits+0x258>
    80002234:	ffffe097          	auipc	ra,0xffffe
    80002238:	330080e7          	jalr	816(ra) # 80000564 <panic>
    panic("sched locks");
    8000223c:	00007517          	auipc	a0,0x7
    80002240:	19c50513          	addi	a0,a0,412 # 800093d8 <digits+0x268>
    80002244:	ffffe097          	auipc	ra,0xffffe
    80002248:	320080e7          	jalr	800(ra) # 80000564 <panic>
    panic("sched running");
    8000224c:	00007517          	auipc	a0,0x7
    80002250:	19c50513          	addi	a0,a0,412 # 800093e8 <digits+0x278>
    80002254:	ffffe097          	auipc	ra,0xffffe
    80002258:	310080e7          	jalr	784(ra) # 80000564 <panic>
    panic("sched interruptible");
    8000225c:	00007517          	auipc	a0,0x7
    80002260:	19c50513          	addi	a0,a0,412 # 800093f8 <digits+0x288>
    80002264:	ffffe097          	auipc	ra,0xffffe
    80002268:	300080e7          	jalr	768(ra) # 80000564 <panic>

000000008000226c <exit>:
{
    8000226c:	7139                	addi	sp,sp,-64
    8000226e:	fc06                	sd	ra,56(sp)
    80002270:	f822                	sd	s0,48(sp)
    80002272:	f426                	sd	s1,40(sp)
    80002274:	f04a                	sd	s2,32(sp)
    80002276:	ec4e                	sd	s3,24(sp)
    80002278:	e852                	sd	s4,16(sp)
    8000227a:	e456                	sd	s5,8(sp)
    8000227c:	0080                	addi	s0,sp,64
    8000227e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002280:	00000097          	auipc	ra,0x0
    80002284:	8d0080e7          	jalr	-1840(ra) # 80001b50 <myproc>
  if(p == initproc)
    80002288:	00008797          	auipc	a5,0x8
    8000228c:	d807b783          	ld	a5,-640(a5) # 8000a008 <initproc>
    80002290:	0ea78463          	beq	a5,a0,80002378 <exit+0x10c>
    80002294:	892a                	mv	s2,a0
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002296:	c01024f3          	rdtime	s1
  p->completion_time = getTime();
    8000229a:	1a953023          	sd	s1,416(a0)
  uint64 turnaround = p->completion_time - p->creation_time;
    8000229e:	17853783          	ld	a5,376(a0)
    800022a2:	8c9d                	sub	s1,s1,a5
  uint64 response = (p->first_run == 1) ? (p->first_run_time - p->creation_time) : 0;
    800022a4:	1b452683          	lw	a3,436(a0)
    800022a8:	4705                	li	a4,1
    800022aa:	4a81                	li	s5,0
    800022ac:	0ce68e63          	beq	a3,a4,80002388 <exit+0x11c>
  uint64 cpu_percent = turnaround > 0 ? (p->total_run_time * 100) / turnaround : 0;
    800022b0:	89a6                	mv	s3,s1
    800022b2:	c889                	beqz	s1,800022c4 <exit+0x58>
    800022b4:	18893783          	ld	a5,392(s2)
    800022b8:	06400993          	li	s3,100
    800022bc:	02f989b3          	mul	s3,s3,a5
    800022c0:	0299d9b3          	divu	s3,s3,s1
  printf("\n ***Process Exit Metrics***\n");
    800022c4:	00007517          	auipc	a0,0x7
    800022c8:	15c50513          	addi	a0,a0,348 # 80009420 <digits+0x2b0>
    800022cc:	ffffe097          	auipc	ra,0xffffe
    800022d0:	2fa080e7          	jalr	762(ra) # 800005c6 <printf>
  printf("PID: %d\n", p->pid);
    800022d4:	04092583          	lw	a1,64(s2)
    800022d8:	00007517          	auipc	a0,0x7
    800022dc:	16850513          	addi	a0,a0,360 # 80009440 <digits+0x2d0>
    800022e0:	ffffe097          	auipc	ra,0xffffe
    800022e4:	2e6080e7          	jalr	742(ra) # 800005c6 <printf>
  printf("Name: %s\n", p->name);
    800022e8:	16090593          	addi	a1,s2,352
    800022ec:	00007517          	auipc	a0,0x7
    800022f0:	16450513          	addi	a0,a0,356 # 80009450 <digits+0x2e0>
    800022f4:	ffffe097          	auipc	ra,0xffffe
    800022f8:	2d2080e7          	jalr	722(ra) # 800005c6 <printf>
  printf("Turnaround Time: %ld ticks\n", turnaround);
    800022fc:	85a6                	mv	a1,s1
    800022fe:	00007517          	auipc	a0,0x7
    80002302:	16250513          	addi	a0,a0,354 # 80009460 <digits+0x2f0>
    80002306:	ffffe097          	auipc	ra,0xffffe
    8000230a:	2c0080e7          	jalr	704(ra) # 800005c6 <printf>
  printf("Waiting Time: %ld ticks\n", p->total_wait_time);
    8000230e:	19893583          	ld	a1,408(s2)
    80002312:	00007517          	auipc	a0,0x7
    80002316:	16e50513          	addi	a0,a0,366 # 80009480 <digits+0x310>
    8000231a:	ffffe097          	auipc	ra,0xffffe
    8000231e:	2ac080e7          	jalr	684(ra) # 800005c6 <printf>
  printf("Response Time: %ld ticks\n", response);
    80002322:	85d6                	mv	a1,s5
    80002324:	00007517          	auipc	a0,0x7
    80002328:	17c50513          	addi	a0,a0,380 # 800094a0 <digits+0x330>
    8000232c:	ffffe097          	auipc	ra,0xffffe
    80002330:	29a080e7          	jalr	666(ra) # 800005c6 <printf>
  printf("Total Run Time: %ld ticks\n", p->total_run_time);
    80002334:	18893583          	ld	a1,392(s2)
    80002338:	00007517          	auipc	a0,0x7
    8000233c:	18850513          	addi	a0,a0,392 # 800094c0 <digits+0x350>
    80002340:	ffffe097          	auipc	ra,0xffffe
    80002344:	286080e7          	jalr	646(ra) # 800005c6 <printf>
  printf("Context Switches: %d\n", p->context_switches);
    80002348:	1b092583          	lw	a1,432(s2)
    8000234c:	00007517          	auipc	a0,0x7
    80002350:	19450513          	addi	a0,a0,404 # 800094e0 <digits+0x370>
    80002354:	ffffe097          	auipc	ra,0xffffe
    80002358:	272080e7          	jalr	626(ra) # 800005c6 <printf>
  printf("CPU Share: %ld%%\n", cpu_percent);
    8000235c:	85ce                	mv	a1,s3
    8000235e:	00007517          	auipc	a0,0x7
    80002362:	19a50513          	addi	a0,a0,410 # 800094f8 <digits+0x388>
    80002366:	ffffe097          	auipc	ra,0xffffe
    8000236a:	260080e7          	jalr	608(ra) # 800005c6 <printf>
  for(int fd = 0; fd < NOFILE; fd++){
    8000236e:	0d890493          	addi	s1,s2,216
    80002372:	15890993          	addi	s3,s2,344
    80002376:	a03d                	j	800023a4 <exit+0x138>
    panic("init exiting");
    80002378:	00007517          	auipc	a0,0x7
    8000237c:	09850513          	addi	a0,a0,152 # 80009410 <digits+0x2a0>
    80002380:	ffffe097          	auipc	ra,0xffffe
    80002384:	1e4080e7          	jalr	484(ra) # 80000564 <panic>
  uint64 response = (p->first_run == 1) ? (p->first_run_time - p->creation_time) : 0;
    80002388:	18053a83          	ld	s5,384(a0)
    8000238c:	40fa8ab3          	sub	s5,s5,a5
    80002390:	b705                	j	800022b0 <exit+0x44>
      fileclose(f);
    80002392:	00002097          	auipc	ra,0x2
    80002396:	47c080e7          	jalr	1148(ra) # 8000480e <fileclose>
      p->ofile[fd] = 0;
    8000239a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000239e:	04a1                	addi	s1,s1,8
    800023a0:	01348563          	beq	s1,s3,800023aa <exit+0x13e>
    if(p->ofile[fd]){
    800023a4:	6088                	ld	a0,0(s1)
    800023a6:	f575                	bnez	a0,80002392 <exit+0x126>
    800023a8:	bfdd                	j	8000239e <exit+0x132>
  begin_op();
    800023aa:	00002097          	auipc	ra,0x2
    800023ae:	f9a080e7          	jalr	-102(ra) # 80004344 <begin_op>
  iput(p->cwd);
    800023b2:	15893503          	ld	a0,344(s2)
    800023b6:	00001097          	auipc	ra,0x1
    800023ba:	786080e7          	jalr	1926(ra) # 80003b3c <iput>
  end_op();
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	006080e7          	jalr	6(ra) # 800043c4 <end_op>
  p->cwd = 0;
    800023c6:	14093c23          	sd	zero,344(s2)
  acquire(&initproc->lock);
    800023ca:	00008497          	auipc	s1,0x8
    800023ce:	c3e48493          	addi	s1,s1,-962 # 8000a008 <initproc>
    800023d2:	6088                	ld	a0,0(s1)
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	7be080e7          	jalr	1982(ra) # 80000b92 <acquire>
  wakeup1(initproc);
    800023dc:	6088                	ld	a0,0(s1)
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	62a080e7          	jalr	1578(ra) # 80001a08 <wakeup1>
  release(&initproc->lock);
    800023e6:	6088                	ld	a0,0(s1)
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	87a080e7          	jalr	-1926(ra) # 80000c62 <release>
  acquire(&p->lock);
    800023f0:	854a                	mv	a0,s2
    800023f2:	ffffe097          	auipc	ra,0xffffe
    800023f6:	7a0080e7          	jalr	1952(ra) # 80000b92 <acquire>
  struct proc *original_parent = p->parent;
    800023fa:	02893483          	ld	s1,40(s2)
  release(&p->lock);
    800023fe:	854a                	mv	a0,s2
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	862080e7          	jalr	-1950(ra) # 80000c62 <release>
  acquire(&original_parent->lock);
    80002408:	8526                	mv	a0,s1
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	788080e7          	jalr	1928(ra) # 80000b92 <acquire>
  acquire(&p->lock);
    80002412:	854a                	mv	a0,s2
    80002414:	ffffe097          	auipc	ra,0xffffe
    80002418:	77e080e7          	jalr	1918(ra) # 80000b92 <acquire>
  reparent(p);
    8000241c:	854a                	mv	a0,s2
    8000241e:	00000097          	auipc	ra,0x0
    80002422:	bee080e7          	jalr	-1042(ra) # 8000200c <reparent>
  wakeup1(original_parent);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	5e0080e7          	jalr	1504(ra) # 80001a08 <wakeup1>
  p->xstate = status;
    80002430:	03492e23          	sw	s4,60(s2)
  p->state = ZOMBIE;
    80002434:	4791                	li	a5,4
    80002436:	02f92023          	sw	a5,32(s2)
  release(&original_parent->lock);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	826080e7          	jalr	-2010(ra) # 80000c62 <release>
  sched();
    80002444:	00000097          	auipc	ra,0x0
    80002448:	d52080e7          	jalr	-686(ra) # 80002196 <sched>
  panic("zombie exit");
    8000244c:	00007517          	auipc	a0,0x7
    80002450:	0c450513          	addi	a0,a0,196 # 80009510 <digits+0x3a0>
    80002454:	ffffe097          	auipc	ra,0xffffe
    80002458:	110080e7          	jalr	272(ra) # 80000564 <panic>

000000008000245c <yield>:
{
    8000245c:	1101                	addi	sp,sp,-32
    8000245e:	ec06                	sd	ra,24(sp)
    80002460:	e822                	sd	s0,16(sp)
    80002462:	e426                	sd	s1,8(sp)
    80002464:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	6ea080e7          	jalr	1770(ra) # 80001b50 <myproc>
    8000246e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002470:	ffffe097          	auipc	ra,0xffffe
    80002474:	722080e7          	jalr	1826(ra) # 80000b92 <acquire>
  p->state = RUNNABLE;
    80002478:	4789                	li	a5,2
    8000247a:	d09c                	sw	a5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000247c:	c01027f3          	rdtime	a5
  p->wait_start = getTime();
    80002480:	1af4b423          	sd	a5,424(s1)
  sched();
    80002484:	00000097          	auipc	ra,0x0
    80002488:	d12080e7          	jalr	-750(ra) # 80002196 <sched>
  release(&p->lock);
    8000248c:	8526                	mv	a0,s1
    8000248e:	ffffe097          	auipc	ra,0xffffe
    80002492:	7d4080e7          	jalr	2004(ra) # 80000c62 <release>
}
    80002496:	60e2                	ld	ra,24(sp)
    80002498:	6442                	ld	s0,16(sp)
    8000249a:	64a2                	ld	s1,8(sp)
    8000249c:	6105                	addi	sp,sp,32
    8000249e:	8082                	ret

00000000800024a0 <sleep>:
{
    800024a0:	7179                	addi	sp,sp,-48
    800024a2:	f406                	sd	ra,40(sp)
    800024a4:	f022                	sd	s0,32(sp)
    800024a6:	ec26                	sd	s1,24(sp)
    800024a8:	e84a                	sd	s2,16(sp)
    800024aa:	e44e                	sd	s3,8(sp)
    800024ac:	1800                	addi	s0,sp,48
    800024ae:	89aa                	mv	s3,a0
    800024b0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	69e080e7          	jalr	1694(ra) # 80001b50 <myproc>
    800024ba:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024bc:	05250663          	beq	a0,s2,80002508 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	6d2080e7          	jalr	1746(ra) # 80000b92 <acquire>
    release(lk);
    800024c8:	854a                	mv	a0,s2
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	798080e7          	jalr	1944(ra) # 80000c62 <release>
  p->chan = chan;
    800024d2:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    800024d6:	4785                	li	a5,1
    800024d8:	d09c                	sw	a5,32(s1)
  sched();
    800024da:	00000097          	auipc	ra,0x0
    800024de:	cbc080e7          	jalr	-836(ra) # 80002196 <sched>
  p->chan = 0;
    800024e2:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	77a080e7          	jalr	1914(ra) # 80000c62 <release>
    acquire(lk);
    800024f0:	854a                	mv	a0,s2
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	6a0080e7          	jalr	1696(ra) # 80000b92 <acquire>
}
    800024fa:	70a2                	ld	ra,40(sp)
    800024fc:	7402                	ld	s0,32(sp)
    800024fe:	64e2                	ld	s1,24(sp)
    80002500:	6942                	ld	s2,16(sp)
    80002502:	69a2                	ld	s3,8(sp)
    80002504:	6145                	addi	sp,sp,48
    80002506:	8082                	ret
  p->chan = chan;
    80002508:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    8000250c:	4785                	li	a5,1
    8000250e:	d11c                	sw	a5,32(a0)
  sched();
    80002510:	00000097          	auipc	ra,0x0
    80002514:	c86080e7          	jalr	-890(ra) # 80002196 <sched>
  p->chan = 0;
    80002518:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    8000251c:	bff9                	j	800024fa <sleep+0x5a>

000000008000251e <wait>:
{
    8000251e:	715d                	addi	sp,sp,-80
    80002520:	e486                	sd	ra,72(sp)
    80002522:	e0a2                	sd	s0,64(sp)
    80002524:	fc26                	sd	s1,56(sp)
    80002526:	f84a                	sd	s2,48(sp)
    80002528:	f44e                	sd	s3,40(sp)
    8000252a:	f052                	sd	s4,32(sp)
    8000252c:	ec56                	sd	s5,24(sp)
    8000252e:	e85a                	sd	s6,16(sp)
    80002530:	e45e                	sd	s7,8(sp)
    80002532:	0880                	addi	s0,sp,80
    80002534:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	61a080e7          	jalr	1562(ra) # 80001b50 <myproc>
    8000253e:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	652080e7          	jalr	1618(ra) # 80000b92 <acquire>
    havekids = 0;
    80002548:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000254a:	4a11                	li	s4,4
        havekids = 1;
    8000254c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000254e:	0002a997          	auipc	s3,0x2a
    80002552:	7ca98993          	addi	s3,s3,1994 # 8002cd18 <tickslock>
    havekids = 0;
    80002556:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002558:	00024497          	auipc	s1,0x24
    8000255c:	9c048493          	addi	s1,s1,-1600 # 80025f18 <proc>
    80002560:	a08d                	j	800025c2 <wait+0xa4>
          pid = np->pid;
    80002562:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002566:	000b0e63          	beqz	s6,80002582 <wait+0x64>
    8000256a:	4691                	li	a3,4
    8000256c:	03c48613          	addi	a2,s1,60
    80002570:	85da                	mv	a1,s6
    80002572:	05893503          	ld	a0,88(s2)
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	28a080e7          	jalr	650(ra) # 80001800 <copyout>
    8000257e:	02054263          	bltz	a0,800025a2 <wait+0x84>
          freeproc(np);
    80002582:	8526                	mv	a0,s1
    80002584:	00000097          	auipc	ra,0x0
    80002588:	81c080e7          	jalr	-2020(ra) # 80001da0 <freeproc>
          release(&np->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	6d4080e7          	jalr	1748(ra) # 80000c62 <release>
          release(&p->lock);
    80002596:	854a                	mv	a0,s2
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	6ca080e7          	jalr	1738(ra) # 80000c62 <release>
          return pid;
    800025a0:	a8a9                	j	800025fa <wait+0xdc>
            release(&np->lock);
    800025a2:	8526                	mv	a0,s1
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	6be080e7          	jalr	1726(ra) # 80000c62 <release>
            release(&p->lock);
    800025ac:	854a                	mv	a0,s2
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	6b4080e7          	jalr	1716(ra) # 80000c62 <release>
            return -1;
    800025b6:	59fd                	li	s3,-1
    800025b8:	a089                	j	800025fa <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800025ba:	1b848493          	addi	s1,s1,440
    800025be:	03348463          	beq	s1,s3,800025e6 <wait+0xc8>
      if(np->parent == p){
    800025c2:	749c                	ld	a5,40(s1)
    800025c4:	ff279be3          	bne	a5,s2,800025ba <wait+0x9c>
        acquire(&np->lock);
    800025c8:	8526                	mv	a0,s1
    800025ca:	ffffe097          	auipc	ra,0xffffe
    800025ce:	5c8080e7          	jalr	1480(ra) # 80000b92 <acquire>
        if(np->state == ZOMBIE){
    800025d2:	509c                	lw	a5,32(s1)
    800025d4:	f94787e3          	beq	a5,s4,80002562 <wait+0x44>
        release(&np->lock);
    800025d8:	8526                	mv	a0,s1
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	688080e7          	jalr	1672(ra) # 80000c62 <release>
        havekids = 1;
    800025e2:	8756                	mv	a4,s5
    800025e4:	bfd9                	j	800025ba <wait+0x9c>
    if(!havekids || p->killed){
    800025e6:	c701                	beqz	a4,800025ee <wait+0xd0>
    800025e8:	03892783          	lw	a5,56(s2)
    800025ec:	c39d                	beqz	a5,80002612 <wait+0xf4>
      release(&p->lock);
    800025ee:	854a                	mv	a0,s2
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	672080e7          	jalr	1650(ra) # 80000c62 <release>
      return -1;
    800025f8:	59fd                	li	s3,-1
}
    800025fa:	854e                	mv	a0,s3
    800025fc:	60a6                	ld	ra,72(sp)
    800025fe:	6406                	ld	s0,64(sp)
    80002600:	74e2                	ld	s1,56(sp)
    80002602:	7942                	ld	s2,48(sp)
    80002604:	79a2                	ld	s3,40(sp)
    80002606:	7a02                	ld	s4,32(sp)
    80002608:	6ae2                	ld	s5,24(sp)
    8000260a:	6b42                	ld	s6,16(sp)
    8000260c:	6ba2                	ld	s7,8(sp)
    8000260e:	6161                	addi	sp,sp,80
    80002610:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002612:	85ca                	mv	a1,s2
    80002614:	854a                	mv	a0,s2
    80002616:	00000097          	auipc	ra,0x0
    8000261a:	e8a080e7          	jalr	-374(ra) # 800024a0 <sleep>
    havekids = 0;
    8000261e:	bf25                	j	80002556 <wait+0x38>

0000000080002620 <wakeup>:
{
    80002620:	7139                	addi	sp,sp,-64
    80002622:	fc06                	sd	ra,56(sp)
    80002624:	f822                	sd	s0,48(sp)
    80002626:	f426                	sd	s1,40(sp)
    80002628:	f04a                	sd	s2,32(sp)
    8000262a:	ec4e                	sd	s3,24(sp)
    8000262c:	e852                	sd	s4,16(sp)
    8000262e:	e456                	sd	s5,8(sp)
    80002630:	0080                	addi	s0,sp,64
    80002632:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002634:	00024497          	auipc	s1,0x24
    80002638:	8e448493          	addi	s1,s1,-1820 # 80025f18 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000263c:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000263e:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002640:	0002a917          	auipc	s2,0x2a
    80002644:	6d890913          	addi	s2,s2,1752 # 8002cd18 <tickslock>
    80002648:	a811                	j	8000265c <wakeup+0x3c>
    release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	616080e7          	jalr	1558(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002654:	1b848493          	addi	s1,s1,440
    80002658:	03248463          	beq	s1,s2,80002680 <wakeup+0x60>
    acquire(&p->lock);
    8000265c:	8526                	mv	a0,s1
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	534080e7          	jalr	1332(ra) # 80000b92 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002666:	509c                	lw	a5,32(s1)
    80002668:	ff3791e3          	bne	a5,s3,8000264a <wakeup+0x2a>
    8000266c:	789c                	ld	a5,48(s1)
    8000266e:	fd479ee3          	bne	a5,s4,8000264a <wakeup+0x2a>
      p->state = RUNNABLE;
    80002672:	0354a023          	sw	s5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002676:	c01027f3          	rdtime	a5
      p->wait_start = getTime();
    8000267a:	1af4b423          	sd	a5,424(s1)
    8000267e:	b7f1                	j	8000264a <wakeup+0x2a>
}
    80002680:	70e2                	ld	ra,56(sp)
    80002682:	7442                	ld	s0,48(sp)
    80002684:	74a2                	ld	s1,40(sp)
    80002686:	7902                	ld	s2,32(sp)
    80002688:	69e2                	ld	s3,24(sp)
    8000268a:	6a42                	ld	s4,16(sp)
    8000268c:	6aa2                	ld	s5,8(sp)
    8000268e:	6121                	addi	sp,sp,64
    80002690:	8082                	ret

0000000080002692 <kill>:
{
    80002692:	7179                	addi	sp,sp,-48
    80002694:	f406                	sd	ra,40(sp)
    80002696:	f022                	sd	s0,32(sp)
    80002698:	ec26                	sd	s1,24(sp)
    8000269a:	e84a                	sd	s2,16(sp)
    8000269c:	e44e                	sd	s3,8(sp)
    8000269e:	1800                	addi	s0,sp,48
    800026a0:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    800026a2:	00024497          	auipc	s1,0x24
    800026a6:	87648493          	addi	s1,s1,-1930 # 80025f18 <proc>
    800026aa:	0002a997          	auipc	s3,0x2a
    800026ae:	66e98993          	addi	s3,s3,1646 # 8002cd18 <tickslock>
    acquire(&p->lock);
    800026b2:	8526                	mv	a0,s1
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	4de080e7          	jalr	1246(ra) # 80000b92 <acquire>
    if(p->pid == pid){
    800026bc:	40bc                	lw	a5,64(s1)
    800026be:	01278d63          	beq	a5,s2,800026d8 <kill+0x46>
    release(&p->lock);
    800026c2:	8526                	mv	a0,s1
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	59e080e7          	jalr	1438(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800026cc:	1b848493          	addi	s1,s1,440
    800026d0:	ff3491e3          	bne	s1,s3,800026b2 <kill+0x20>
  return -1;
    800026d4:	557d                	li	a0,-1
    800026d6:	a821                	j	800026ee <kill+0x5c>
      p->killed = 1;
    800026d8:	4785                	li	a5,1
    800026da:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    800026dc:	5098                	lw	a4,32(s1)
    800026de:	00f70f63          	beq	a4,a5,800026fc <kill+0x6a>
      release(&p->lock);
    800026e2:	8526                	mv	a0,s1
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	57e080e7          	jalr	1406(ra) # 80000c62 <release>
      return 0;
    800026ec:	4501                	li	a0,0
}
    800026ee:	70a2                	ld	ra,40(sp)
    800026f0:	7402                	ld	s0,32(sp)
    800026f2:	64e2                	ld	s1,24(sp)
    800026f4:	6942                	ld	s2,16(sp)
    800026f6:	69a2                	ld	s3,8(sp)
    800026f8:	6145                	addi	sp,sp,48
    800026fa:	8082                	ret
        p->state = RUNNABLE;
    800026fc:	4789                	li	a5,2
    800026fe:	d09c                	sw	a5,32(s1)
    80002700:	b7cd                	j	800026e2 <kill+0x50>

0000000080002702 <either_copyout>:
{
    80002702:	7179                	addi	sp,sp,-48
    80002704:	f406                	sd	ra,40(sp)
    80002706:	f022                	sd	s0,32(sp)
    80002708:	ec26                	sd	s1,24(sp)
    8000270a:	e84a                	sd	s2,16(sp)
    8000270c:	e44e                	sd	s3,8(sp)
    8000270e:	e052                	sd	s4,0(sp)
    80002710:	1800                	addi	s0,sp,48
    80002712:	84aa                	mv	s1,a0
    80002714:	892e                	mv	s2,a1
    80002716:	89b2                	mv	s3,a2
    80002718:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000271a:	fffff097          	auipc	ra,0xfffff
    8000271e:	436080e7          	jalr	1078(ra) # 80001b50 <myproc>
  if(user_dst){
    80002722:	c08d                	beqz	s1,80002744 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002724:	86d2                	mv	a3,s4
    80002726:	864e                	mv	a2,s3
    80002728:	85ca                	mv	a1,s2
    8000272a:	6d28                	ld	a0,88(a0)
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	0d4080e7          	jalr	212(ra) # 80001800 <copyout>
}
    80002734:	70a2                	ld	ra,40(sp)
    80002736:	7402                	ld	s0,32(sp)
    80002738:	64e2                	ld	s1,24(sp)
    8000273a:	6942                	ld	s2,16(sp)
    8000273c:	69a2                	ld	s3,8(sp)
    8000273e:	6a02                	ld	s4,0(sp)
    80002740:	6145                	addi	sp,sp,48
    80002742:	8082                	ret
    memmove((char *)dst, src, len);
    80002744:	000a061b          	sext.w	a2,s4
    80002748:	85ce                	mv	a1,s3
    8000274a:	854a                	mv	a0,s2
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	786080e7          	jalr	1926(ra) # 80000ed2 <memmove>
    return 0;
    80002754:	8526                	mv	a0,s1
    80002756:	bff9                	j	80002734 <either_copyout+0x32>

0000000080002758 <either_copyin>:
{
    80002758:	7179                	addi	sp,sp,-48
    8000275a:	f406                	sd	ra,40(sp)
    8000275c:	f022                	sd	s0,32(sp)
    8000275e:	ec26                	sd	s1,24(sp)
    80002760:	e84a                	sd	s2,16(sp)
    80002762:	e44e                	sd	s3,8(sp)
    80002764:	e052                	sd	s4,0(sp)
    80002766:	1800                	addi	s0,sp,48
    80002768:	892a                	mv	s2,a0
    8000276a:	84ae                	mv	s1,a1
    8000276c:	89b2                	mv	s3,a2
    8000276e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	3e0080e7          	jalr	992(ra) # 80001b50 <myproc>
  if(user_src){
    80002778:	c08d                	beqz	s1,8000279a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000277a:	86d2                	mv	a3,s4
    8000277c:	864e                	mv	a2,s3
    8000277e:	85ca                	mv	a1,s2
    80002780:	6d28                	ld	a0,88(a0)
    80002782:	fffff097          	auipc	ra,0xfffff
    80002786:	10a080e7          	jalr	266(ra) # 8000188c <copyin>
}
    8000278a:	70a2                	ld	ra,40(sp)
    8000278c:	7402                	ld	s0,32(sp)
    8000278e:	64e2                	ld	s1,24(sp)
    80002790:	6942                	ld	s2,16(sp)
    80002792:	69a2                	ld	s3,8(sp)
    80002794:	6a02                	ld	s4,0(sp)
    80002796:	6145                	addi	sp,sp,48
    80002798:	8082                	ret
    memmove(dst, (char*)src, len);
    8000279a:	000a061b          	sext.w	a2,s4
    8000279e:	85ce                	mv	a1,s3
    800027a0:	854a                	mv	a0,s2
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	730080e7          	jalr	1840(ra) # 80000ed2 <memmove>
    return 0;
    800027aa:	8526                	mv	a0,s1
    800027ac:	bff9                	j	8000278a <either_copyin+0x32>

00000000800027ae <procdump>:
{
    800027ae:	715d                	addi	sp,sp,-80
    800027b0:	e486                	sd	ra,72(sp)
    800027b2:	e0a2                	sd	s0,64(sp)
    800027b4:	fc26                	sd	s1,56(sp)
    800027b6:	f84a                	sd	s2,48(sp)
    800027b8:	f44e                	sd	s3,40(sp)
    800027ba:	f052                	sd	s4,32(sp)
    800027bc:	ec56                	sd	s5,24(sp)
    800027be:	e85a                	sd	s6,16(sp)
    800027c0:	e45e                	sd	s7,8(sp)
    800027c2:	0880                	addi	s0,sp,80
  printf("\n");
    800027c4:	00007517          	auipc	a0,0x7
    800027c8:	d4450513          	addi	a0,a0,-700 # 80009508 <digits+0x398>
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	dfa080e7          	jalr	-518(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027d4:	00024497          	auipc	s1,0x24
    800027d8:	8a448493          	addi	s1,s1,-1884 # 80026078 <proc+0x160>
    800027dc:	0002a917          	auipc	s2,0x2a
    800027e0:	69c90913          	addi	s2,s2,1692 # 8002ce78 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027e4:	4b11                	li	s6,4
      state = "???";
    800027e6:	00007997          	auipc	s3,0x7
    800027ea:	d3a98993          	addi	s3,s3,-710 # 80009520 <digits+0x3b0>
    printf("%d %s %s", p->pid, state, p->name);
    800027ee:	00007a97          	auipc	s5,0x7
    800027f2:	d3aa8a93          	addi	s5,s5,-710 # 80009528 <digits+0x3b8>
    printf("\n");
    800027f6:	00007a17          	auipc	s4,0x7
    800027fa:	d12a0a13          	addi	s4,s4,-750 # 80009508 <digits+0x398>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027fe:	00007b97          	auipc	s7,0x7
    80002802:	d62b8b93          	addi	s7,s7,-670 # 80009560 <states.0>
    80002806:	a00d                	j	80002828 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002808:	ee06a583          	lw	a1,-288(a3)
    8000280c:	8556                	mv	a0,s5
    8000280e:	ffffe097          	auipc	ra,0xffffe
    80002812:	db8080e7          	jalr	-584(ra) # 800005c6 <printf>
    printf("\n");
    80002816:	8552                	mv	a0,s4
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	dae080e7          	jalr	-594(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002820:	1b848493          	addi	s1,s1,440
    80002824:	03248163          	beq	s1,s2,80002846 <procdump+0x98>
    if(p->state == UNUSED)
    80002828:	86a6                	mv	a3,s1
    8000282a:	ec04a783          	lw	a5,-320(s1)
    8000282e:	dbed                	beqz	a5,80002820 <procdump+0x72>
      state = "???";
    80002830:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002832:	fcfb6be3          	bltu	s6,a5,80002808 <procdump+0x5a>
    80002836:	1782                	slli	a5,a5,0x20
    80002838:	9381                	srli	a5,a5,0x20
    8000283a:	078e                	slli	a5,a5,0x3
    8000283c:	97de                	add	a5,a5,s7
    8000283e:	6390                	ld	a2,0(a5)
    80002840:	f661                	bnez	a2,80002808 <procdump+0x5a>
      state = "???";
    80002842:	864e                	mv	a2,s3
    80002844:	b7d1                	j	80002808 <procdump+0x5a>
}
    80002846:	60a6                	ld	ra,72(sp)
    80002848:	6406                	ld	s0,64(sp)
    8000284a:	74e2                	ld	s1,56(sp)
    8000284c:	7942                	ld	s2,48(sp)
    8000284e:	79a2                	ld	s3,40(sp)
    80002850:	7a02                	ld	s4,32(sp)
    80002852:	6ae2                	ld	s5,24(sp)
    80002854:	6b42                	ld	s6,16(sp)
    80002856:	6ba2                	ld	s7,8(sp)
    80002858:	6161                	addi	sp,sp,80
    8000285a:	8082                	ret

000000008000285c <getTime>:
unsigned long getTime() { 
    8000285c:	1141                	addi	sp,sp,-16
    8000285e:	e422                	sd	s0,8(sp)
    80002860:	0800                	addi	s0,sp,16
  asm volatile ("rdtime %0" : "=r" (time)); 
    80002862:	c0102573          	rdtime	a0
  return time; 
}
    80002866:	6422                	ld	s0,8(sp)
    80002868:	0141                	addi	sp,sp,16
    8000286a:	8082                	ret

000000008000286c <getCycles>:

unsigned long getCycles() { 
    8000286c:	1141                	addi	sp,sp,-16
    8000286e:	e422                	sd	s0,8(sp)
    80002870:	0800                	addi	s0,sp,16
  unsigned long cycles; 
  asm volatile ("rdcycle %0" : "=r" (cycles)); 
    80002872:	c0002573          	rdcycle	a0
  return cycles; 
    80002876:	6422                	ld	s0,8(sp)
    80002878:	0141                	addi	sp,sp,16
    8000287a:	8082                	ret

000000008000287c <swtch>:
    8000287c:	00153023          	sd	ra,0(a0)
    80002880:	00253423          	sd	sp,8(a0)
    80002884:	e900                	sd	s0,16(a0)
    80002886:	ed04                	sd	s1,24(a0)
    80002888:	03253023          	sd	s2,32(a0)
    8000288c:	03353423          	sd	s3,40(a0)
    80002890:	03453823          	sd	s4,48(a0)
    80002894:	03553c23          	sd	s5,56(a0)
    80002898:	05653023          	sd	s6,64(a0)
    8000289c:	05753423          	sd	s7,72(a0)
    800028a0:	05853823          	sd	s8,80(a0)
    800028a4:	05953c23          	sd	s9,88(a0)
    800028a8:	07a53023          	sd	s10,96(a0)
    800028ac:	07b53423          	sd	s11,104(a0)
    800028b0:	0005b083          	ld	ra,0(a1)
    800028b4:	0085b103          	ld	sp,8(a1)
    800028b8:	6980                	ld	s0,16(a1)
    800028ba:	6d84                	ld	s1,24(a1)
    800028bc:	0205b903          	ld	s2,32(a1)
    800028c0:	0285b983          	ld	s3,40(a1)
    800028c4:	0305ba03          	ld	s4,48(a1)
    800028c8:	0385ba83          	ld	s5,56(a1)
    800028cc:	0405bb03          	ld	s6,64(a1)
    800028d0:	0485bb83          	ld	s7,72(a1)
    800028d4:	0505bc03          	ld	s8,80(a1)
    800028d8:	0585bc83          	ld	s9,88(a1)
    800028dc:	0605bd03          	ld	s10,96(a1)
    800028e0:	0685bd83          	ld	s11,104(a1)
    800028e4:	8082                	ret

00000000800028e6 <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    800028e6:	1141                	addi	sp,sp,-16
    800028e8:	e422                	sd	s0,8(sp)
    800028ea:	0800                	addi	s0,sp,16
    800028ec:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    800028ee:	00151713          	slli	a4,a0,0x1
    800028f2:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    800028f4:	04054c63          	bltz	a0,8000294c <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    800028f8:	5685                	li	a3,-31
    800028fa:	8285                	srli	a3,a3,0x1
    800028fc:	8ee9                	and	a3,a3,a0
    800028fe:	caad                	beqz	a3,80002970 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002900:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002902:	00007517          	auipc	a0,0x7
    80002906:	c8650513          	addi	a0,a0,-890 # 80009588 <states.0+0x28>
    } else if (code <= 23) {
    8000290a:	06e6f063          	bgeu	a3,a4,8000296a <scause_desc+0x84>
    } else if (code <= 31) {
    8000290e:	fc100693          	li	a3,-63
    80002912:	8285                	srli	a3,a3,0x1
    80002914:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    80002916:	00007517          	auipc	a0,0x7
    8000291a:	c9a50513          	addi	a0,a0,-870 # 800095b0 <states.0+0x50>
    } else if (code <= 31) {
    8000291e:	c6b1                	beqz	a3,8000296a <scause_desc+0x84>
    } else if (code <= 47) {
    80002920:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    80002924:	00007517          	auipc	a0,0x7
    80002928:	c6450513          	addi	a0,a0,-924 # 80009588 <states.0+0x28>
    } else if (code <= 47) {
    8000292c:	02e6ff63          	bgeu	a3,a4,8000296a <scause_desc+0x84>
    } else if (code <= 63) {
    80002930:	f8100513          	li	a0,-127
    80002934:	8105                	srli	a0,a0,0x1
    80002936:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    80002938:	00007517          	auipc	a0,0x7
    8000293c:	c7850513          	addi	a0,a0,-904 # 800095b0 <states.0+0x50>
    } else if (code <= 63) {
    80002940:	c78d                	beqz	a5,8000296a <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    80002942:	00007517          	auipc	a0,0x7
    80002946:	c4650513          	addi	a0,a0,-954 # 80009588 <states.0+0x28>
    8000294a:	a005                	j	8000296a <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    8000294c:	5505                	li	a0,-31
    8000294e:	8105                	srli	a0,a0,0x1
    80002950:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    80002952:	00007517          	auipc	a0,0x7
    80002956:	c7e50513          	addi	a0,a0,-898 # 800095d0 <states.0+0x70>
    if (code < NELEM(intr_desc)) {
    8000295a:	eb81                	bnez	a5,8000296a <scause_desc+0x84>
      return intr_desc[code];
    8000295c:	070e                	slli	a4,a4,0x3
    8000295e:	00007797          	auipc	a5,0x7
    80002962:	f8278793          	addi	a5,a5,-126 # 800098e0 <intr_desc.1>
    80002966:	973e                	add	a4,a4,a5
    80002968:	6308                	ld	a0,0(a4)
    }
  }
}
    8000296a:	6422                	ld	s0,8(sp)
    8000296c:	0141                	addi	sp,sp,16
    8000296e:	8082                	ret
      return nointr_desc[code];
    80002970:	070e                	slli	a4,a4,0x3
    80002972:	00007797          	auipc	a5,0x7
    80002976:	f6e78793          	addi	a5,a5,-146 # 800098e0 <intr_desc.1>
    8000297a:	973e                	add	a4,a4,a5
    8000297c:	6348                	ld	a0,128(a4)
    8000297e:	b7f5                	j	8000296a <scause_desc+0x84>

0000000080002980 <trapinit>:
{
    80002980:	1141                	addi	sp,sp,-16
    80002982:	e406                	sd	ra,8(sp)
    80002984:	e022                	sd	s0,0(sp)
    80002986:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002988:	00007597          	auipc	a1,0x7
    8000298c:	c6858593          	addi	a1,a1,-920 # 800095f0 <states.0+0x90>
    80002990:	0002a517          	auipc	a0,0x2a
    80002994:	38850513          	addi	a0,a0,904 # 8002cd18 <tickslock>
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	124080e7          	jalr	292(ra) # 80000abc <initlock>
}
    800029a0:	60a2                	ld	ra,8(sp)
    800029a2:	6402                	ld	s0,0(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <trapinithart>:
{
    800029a8:	1141                	addi	sp,sp,-16
    800029aa:	e422                	sd	s0,8(sp)
    800029ac:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029ae:	00003797          	auipc	a5,0x3
    800029b2:	49278793          	addi	a5,a5,1170 # 80005e40 <kernelvec>
    800029b6:	10579073          	csrw	stvec,a5
}
    800029ba:	6422                	ld	s0,8(sp)
    800029bc:	0141                	addi	sp,sp,16
    800029be:	8082                	ret

00000000800029c0 <usertrapret>:
{
    800029c0:	1141                	addi	sp,sp,-16
    800029c2:	e406                	sd	ra,8(sp)
    800029c4:	e022                	sd	s0,0(sp)
    800029c6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029c8:	fffff097          	auipc	ra,0xfffff
    800029cc:	188080e7          	jalr	392(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d6:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800029da:	00005617          	auipc	a2,0x5
    800029de:	62660613          	addi	a2,a2,1574 # 80008000 <_trampoline>
    800029e2:	00005697          	auipc	a3,0x5
    800029e6:	61e68693          	addi	a3,a3,1566 # 80008000 <_trampoline>
    800029ea:	8e91                	sub	a3,a3,a2
    800029ec:	040007b7          	lui	a5,0x4000
    800029f0:	17fd                	addi	a5,a5,-1
    800029f2:	07b2                	slli	a5,a5,0xc
    800029f4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029f6:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029fa:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029fc:	180026f3          	csrr	a3,satp
    80002a00:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a02:	7138                	ld	a4,96(a0)
    80002a04:	6534                	ld	a3,72(a0)
    80002a06:	6585                	lui	a1,0x1
    80002a08:	96ae                	add	a3,a3,a1
    80002a0a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a0c:	7138                	ld	a4,96(a0)
    80002a0e:	00000697          	auipc	a3,0x0
    80002a12:	12268693          	addi	a3,a3,290 # 80002b30 <usertrap>
    80002a16:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a18:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a1a:	8692                	mv	a3,tp
    80002a1c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a1e:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a22:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a26:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a2a:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    80002a2e:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a30:	6f18                	ld	a4,24(a4)
    80002a32:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a36:	6d2c                	ld	a1,88(a0)
    80002a38:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a3a:	00005717          	auipc	a4,0x5
    80002a3e:	65670713          	addi	a4,a4,1622 # 80008090 <userret>
    80002a42:	8f11                	sub	a4,a4,a2
    80002a44:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    80002a46:	577d                	li	a4,-1
    80002a48:	177e                	slli	a4,a4,0x3f
    80002a4a:	8dd9                	or	a1,a1,a4
    80002a4c:	17053503          	ld	a0,368(a0)
    80002a50:	9782                	jalr	a5
}
    80002a52:	60a2                	ld	ra,8(sp)
    80002a54:	6402                	ld	s0,0(sp)
    80002a56:	0141                	addi	sp,sp,16
    80002a58:	8082                	ret

0000000080002a5a <clockintr>:
{
    80002a5a:	1101                	addi	sp,sp,-32
    80002a5c:	ec06                	sd	ra,24(sp)
    80002a5e:	e822                	sd	s0,16(sp)
    80002a60:	e426                	sd	s1,8(sp)
    80002a62:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a64:	0002a497          	auipc	s1,0x2a
    80002a68:	2b448493          	addi	s1,s1,692 # 8002cd18 <tickslock>
    80002a6c:	8526                	mv	a0,s1
    80002a6e:	ffffe097          	auipc	ra,0xffffe
    80002a72:	124080e7          	jalr	292(ra) # 80000b92 <acquire>
  ticks++;
    80002a76:	00007517          	auipc	a0,0x7
    80002a7a:	59a50513          	addi	a0,a0,1434 # 8000a010 <ticks>
    80002a7e:	411c                	lw	a5,0(a0)
    80002a80:	2785                	addiw	a5,a5,1
    80002a82:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	b9c080e7          	jalr	-1124(ra) # 80002620 <wakeup>
  release(&tickslock);
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	1d4080e7          	jalr	468(ra) # 80000c62 <release>
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6105                	addi	sp,sp,32
    80002a9e:	8082                	ret

0000000080002aa0 <devintr>:
{
    80002aa0:	1101                	addi	sp,sp,-32
    80002aa2:	ec06                	sd	ra,24(sp)
    80002aa4:	e822                	sd	s0,16(sp)
    80002aa6:	e426                	sd	s1,8(sp)
    80002aa8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aaa:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002aae:	00074d63          	bltz	a4,80002ac8 <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002ab2:	57fd                	li	a5,-1
    80002ab4:	17fe                	slli	a5,a5,0x3f
    80002ab6:	0785                	addi	a5,a5,1
    return 0;
    80002ab8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002aba:	04f70a63          	beq	a4,a5,80002b0e <devintr+0x6e>
}
    80002abe:	60e2                	ld	ra,24(sp)
    80002ac0:	6442                	ld	s0,16(sp)
    80002ac2:	64a2                	ld	s1,8(sp)
    80002ac4:	6105                	addi	sp,sp,32
    80002ac6:	8082                	ret
     (scause & 0xff) == 9){
    80002ac8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002acc:	46a5                	li	a3,9
    80002ace:	fed792e3          	bne	a5,a3,80002ab2 <devintr+0x12>
    int irq = plic_claim();
    80002ad2:	00003097          	auipc	ra,0x3
    80002ad6:	476080e7          	jalr	1142(ra) # 80005f48 <plic_claim>
    80002ada:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002adc:	47a9                	li	a5,10
    80002ade:	00f50863          	beq	a0,a5,80002aee <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002ae2:	4785                	li	a5,1
    80002ae4:	02f50063          	beq	a0,a5,80002b04 <devintr+0x64>
    return 1;
    80002ae8:	4505                	li	a0,1
    if(irq)
    80002aea:	d8f1                	beqz	s1,80002abe <devintr+0x1e>
    80002aec:	a029                	j	80002af6 <devintr+0x56>
      uartintr();
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	e22080e7          	jalr	-478(ra) # 80000910 <uartintr>
      plic_complete(irq);
    80002af6:	8526                	mv	a0,s1
    80002af8:	00003097          	auipc	ra,0x3
    80002afc:	474080e7          	jalr	1140(ra) # 80005f6c <plic_complete>
    return 1;
    80002b00:	4505                	li	a0,1
    80002b02:	bf75                	j	80002abe <devintr+0x1e>
      virtio_disk_intr();
    80002b04:	00004097          	auipc	ra,0x4
    80002b08:	920080e7          	jalr	-1760(ra) # 80006424 <virtio_disk_intr>
    80002b0c:	b7ed                	j	80002af6 <devintr+0x56>
    if(cpuid() == 0){
    80002b0e:	fffff097          	auipc	ra,0xfffff
    80002b12:	016080e7          	jalr	22(ra) # 80001b24 <cpuid>
    80002b16:	c901                	beqz	a0,80002b26 <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b18:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b1c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b1e:	14479073          	csrw	sip,a5
    return 2;
    80002b22:	4509                	li	a0,2
    80002b24:	bf69                	j	80002abe <devintr+0x1e>
      clockintr();
    80002b26:	00000097          	auipc	ra,0x0
    80002b2a:	f34080e7          	jalr	-204(ra) # 80002a5a <clockintr>
    80002b2e:	b7ed                	j	80002b18 <devintr+0x78>

0000000080002b30 <usertrap>:
{
    80002b30:	7179                	addi	sp,sp,-48
    80002b32:	f406                	sd	ra,40(sp)
    80002b34:	f022                	sd	s0,32(sp)
    80002b36:	ec26                	sd	s1,24(sp)
    80002b38:	e84a                	sd	s2,16(sp)
    80002b3a:	e44e                	sd	s3,8(sp)
    80002b3c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b3e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b42:	1007f793          	andi	a5,a5,256
    80002b46:	e3b5                	bnez	a5,80002baa <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b48:	00003797          	auipc	a5,0x3
    80002b4c:	2f878793          	addi	a5,a5,760 # 80005e40 <kernelvec>
    80002b50:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b54:	fffff097          	auipc	ra,0xfffff
    80002b58:	ffc080e7          	jalr	-4(ra) # 80001b50 <myproc>
    80002b5c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b5e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b60:	14102773          	csrr	a4,sepc
    80002b64:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b66:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b6a:	47a1                	li	a5,8
    80002b6c:	04f71d63          	bne	a4,a5,80002bc6 <usertrap+0x96>
    if(p->killed)
    80002b70:	5d1c                	lw	a5,56(a0)
    80002b72:	e7a1                	bnez	a5,80002bba <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002b74:	70b8                	ld	a4,96(s1)
    80002b76:	6f1c                	ld	a5,24(a4)
    80002b78:	0791                	addi	a5,a5,4
    80002b7a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b7c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b80:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b84:	10079073          	csrw	sstatus,a5
    syscall();
    80002b88:	00000097          	auipc	ra,0x0
    80002b8c:	2fe080e7          	jalr	766(ra) # 80002e86 <syscall>
  if(p->killed)
    80002b90:	5c9c                	lw	a5,56(s1)
    80002b92:	e3cd                	bnez	a5,80002c34 <usertrap+0x104>
  usertrapret();
    80002b94:	00000097          	auipc	ra,0x0
    80002b98:	e2c080e7          	jalr	-468(ra) # 800029c0 <usertrapret>
}
    80002b9c:	70a2                	ld	ra,40(sp)
    80002b9e:	7402                	ld	s0,32(sp)
    80002ba0:	64e2                	ld	s1,24(sp)
    80002ba2:	6942                	ld	s2,16(sp)
    80002ba4:	69a2                	ld	s3,8(sp)
    80002ba6:	6145                	addi	sp,sp,48
    80002ba8:	8082                	ret
    panic("usertrap: not from user mode");
    80002baa:	00007517          	auipc	a0,0x7
    80002bae:	a4e50513          	addi	a0,a0,-1458 # 800095f8 <states.0+0x98>
    80002bb2:	ffffe097          	auipc	ra,0xffffe
    80002bb6:	9b2080e7          	jalr	-1614(ra) # 80000564 <panic>
      exit(-1);
    80002bba:	557d                	li	a0,-1
    80002bbc:	fffff097          	auipc	ra,0xfffff
    80002bc0:	6b0080e7          	jalr	1712(ra) # 8000226c <exit>
    80002bc4:	bf45                	j	80002b74 <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	eda080e7          	jalr	-294(ra) # 80002aa0 <devintr>
    80002bce:	892a                	mv	s2,a0
    80002bd0:	c501                	beqz	a0,80002bd8 <usertrap+0xa8>
  if(p->killed)
    80002bd2:	5c9c                	lw	a5,56(s1)
    80002bd4:	cba1                	beqz	a5,80002c24 <usertrap+0xf4>
    80002bd6:	a091                	j	80002c1a <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd8:	142029f3          	csrr	s3,scause
    80002bdc:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002be0:	00000097          	auipc	ra,0x0
    80002be4:	d06080e7          	jalr	-762(ra) # 800028e6 <scause_desc>
    80002be8:	862a                	mv	a2,a0
    80002bea:	40b4                	lw	a3,64(s1)
    80002bec:	85ce                	mv	a1,s3
    80002bee:	00007517          	auipc	a0,0x7
    80002bf2:	a2a50513          	addi	a0,a0,-1494 # 80009618 <states.0+0xb8>
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	9d0080e7          	jalr	-1584(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bfe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c02:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c06:	00007517          	auipc	a0,0x7
    80002c0a:	a4250513          	addi	a0,a0,-1470 # 80009648 <states.0+0xe8>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	9b8080e7          	jalr	-1608(ra) # 800005c6 <printf>
    p->killed = 1;
    80002c16:	4785                	li	a5,1
    80002c18:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c1a:	557d                	li	a0,-1
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	650080e7          	jalr	1616(ra) # 8000226c <exit>
  if(which_dev == 2)
    80002c24:	4789                	li	a5,2
    80002c26:	f6f917e3          	bne	s2,a5,80002b94 <usertrap+0x64>
    yield();
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	832080e7          	jalr	-1998(ra) # 8000245c <yield>
    80002c32:	b78d                	j	80002b94 <usertrap+0x64>
  int which_dev = 0;
    80002c34:	4901                	li	s2,0
    80002c36:	b7d5                	j	80002c1a <usertrap+0xea>

0000000080002c38 <kerneltrap>:
{
    80002c38:	7179                	addi	sp,sp,-48
    80002c3a:	f406                	sd	ra,40(sp)
    80002c3c:	f022                	sd	s0,32(sp)
    80002c3e:	ec26                	sd	s1,24(sp)
    80002c40:	e84a                	sd	s2,16(sp)
    80002c42:	e44e                	sd	s3,8(sp)
    80002c44:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c46:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c52:	1004f793          	andi	a5,s1,256
    80002c56:	cb85                	beqz	a5,80002c86 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c58:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c5c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c5e:	ef85                	bnez	a5,80002c96 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	e40080e7          	jalr	-448(ra) # 80002aa0 <devintr>
    80002c68:	cd1d                	beqz	a0,80002ca6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c6a:	4789                	li	a5,2
    80002c6c:	08f50063          	beq	a0,a5,80002cec <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c70:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c74:	10049073          	csrw	sstatus,s1
}
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6942                	ld	s2,16(sp)
    80002c80:	69a2                	ld	s3,8(sp)
    80002c82:	6145                	addi	sp,sp,48
    80002c84:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c86:	00007517          	auipc	a0,0x7
    80002c8a:	9e250513          	addi	a0,a0,-1566 # 80009668 <states.0+0x108>
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	8d6080e7          	jalr	-1834(ra) # 80000564 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c96:	00007517          	auipc	a0,0x7
    80002c9a:	9fa50513          	addi	a0,a0,-1542 # 80009690 <states.0+0x130>
    80002c9e:	ffffe097          	auipc	ra,0xffffe
    80002ca2:	8c6080e7          	jalr	-1850(ra) # 80000564 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002ca6:	854e                	mv	a0,s3
    80002ca8:	00000097          	auipc	ra,0x0
    80002cac:	c3e080e7          	jalr	-962(ra) # 800028e6 <scause_desc>
    80002cb0:	862a                	mv	a2,a0
    80002cb2:	85ce                	mv	a1,s3
    80002cb4:	00007517          	auipc	a0,0x7
    80002cb8:	9fc50513          	addi	a0,a0,-1540 # 800096b0 <states.0+0x150>
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	90a080e7          	jalr	-1782(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cc4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cc8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ccc:	00007517          	auipc	a0,0x7
    80002cd0:	9f450513          	addi	a0,a0,-1548 # 800096c0 <states.0+0x160>
    80002cd4:	ffffe097          	auipc	ra,0xffffe
    80002cd8:	8f2080e7          	jalr	-1806(ra) # 800005c6 <printf>
    panic("kerneltrap");
    80002cdc:	00007517          	auipc	a0,0x7
    80002ce0:	9fc50513          	addi	a0,a0,-1540 # 800096d8 <states.0+0x178>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	880080e7          	jalr	-1920(ra) # 80000564 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	e64080e7          	jalr	-412(ra) # 80001b50 <myproc>
    80002cf4:	dd35                	beqz	a0,80002c70 <kerneltrap+0x38>
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	e5a080e7          	jalr	-422(ra) # 80001b50 <myproc>
    80002cfe:	5118                	lw	a4,32(a0)
    80002d00:	478d                	li	a5,3
    80002d02:	f6f717e3          	bne	a4,a5,80002c70 <kerneltrap+0x38>
    yield();
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	756080e7          	jalr	1878(ra) # 8000245c <yield>
    80002d0e:	b78d                	j	80002c70 <kerneltrap+0x38>

0000000080002d10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	e34080e7          	jalr	-460(ra) # 80001b50 <myproc>
  switch (n) {
    80002d24:	4795                	li	a5,5
    80002d26:	0497e163          	bltu	a5,s1,80002d68 <argraw+0x58>
    80002d2a:	048a                	slli	s1,s1,0x2
    80002d2c:	00007717          	auipc	a4,0x7
    80002d30:	cdc70713          	addi	a4,a4,-804 # 80009a08 <nointr_desc.0+0xa8>
    80002d34:	94ba                	add	s1,s1,a4
    80002d36:	409c                	lw	a5,0(s1)
    80002d38:	97ba                	add	a5,a5,a4
    80002d3a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d3c:	713c                	ld	a5,96(a0)
    80002d3e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d40:	60e2                	ld	ra,24(sp)
    80002d42:	6442                	ld	s0,16(sp)
    80002d44:	64a2                	ld	s1,8(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret
    return p->trapframe->a1;
    80002d4a:	713c                	ld	a5,96(a0)
    80002d4c:	7fa8                	ld	a0,120(a5)
    80002d4e:	bfcd                	j	80002d40 <argraw+0x30>
    return p->trapframe->a2;
    80002d50:	713c                	ld	a5,96(a0)
    80002d52:	63c8                	ld	a0,128(a5)
    80002d54:	b7f5                	j	80002d40 <argraw+0x30>
    return p->trapframe->a3;
    80002d56:	713c                	ld	a5,96(a0)
    80002d58:	67c8                	ld	a0,136(a5)
    80002d5a:	b7dd                	j	80002d40 <argraw+0x30>
    return p->trapframe->a4;
    80002d5c:	713c                	ld	a5,96(a0)
    80002d5e:	6bc8                	ld	a0,144(a5)
    80002d60:	b7c5                	j	80002d40 <argraw+0x30>
    return p->trapframe->a5;
    80002d62:	713c                	ld	a5,96(a0)
    80002d64:	6fc8                	ld	a0,152(a5)
    80002d66:	bfe9                	j	80002d40 <argraw+0x30>
  panic("argraw");
    80002d68:	00007517          	auipc	a0,0x7
    80002d6c:	c7850513          	addi	a0,a0,-904 # 800099e0 <nointr_desc.0+0x80>
    80002d70:	ffffd097          	auipc	ra,0xffffd
    80002d74:	7f4080e7          	jalr	2036(ra) # 80000564 <panic>

0000000080002d78 <fetchaddr>:
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	e04a                	sd	s2,0(sp)
    80002d82:	1000                	addi	s0,sp,32
    80002d84:	84aa                	mv	s1,a0
    80002d86:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	dc8080e7          	jalr	-568(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d90:	693c                	ld	a5,80(a0)
    80002d92:	02f4f863          	bgeu	s1,a5,80002dc2 <fetchaddr+0x4a>
    80002d96:	00848713          	addi	a4,s1,8
    80002d9a:	02e7e663          	bltu	a5,a4,80002dc6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d9e:	46a1                	li	a3,8
    80002da0:	8626                	mv	a2,s1
    80002da2:	85ca                	mv	a1,s2
    80002da4:	6d28                	ld	a0,88(a0)
    80002da6:	fffff097          	auipc	ra,0xfffff
    80002daa:	ae6080e7          	jalr	-1306(ra) # 8000188c <copyin>
    80002dae:	00a03533          	snez	a0,a0
    80002db2:	40a00533          	neg	a0,a0
}
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	64a2                	ld	s1,8(sp)
    80002dbc:	6902                	ld	s2,0(sp)
    80002dbe:	6105                	addi	sp,sp,32
    80002dc0:	8082                	ret
    return -1;
    80002dc2:	557d                	li	a0,-1
    80002dc4:	bfcd                	j	80002db6 <fetchaddr+0x3e>
    80002dc6:	557d                	li	a0,-1
    80002dc8:	b7fd                	j	80002db6 <fetchaddr+0x3e>

0000000080002dca <fetchstr>:
{
    80002dca:	7179                	addi	sp,sp,-48
    80002dcc:	f406                	sd	ra,40(sp)
    80002dce:	f022                	sd	s0,32(sp)
    80002dd0:	ec26                	sd	s1,24(sp)
    80002dd2:	e84a                	sd	s2,16(sp)
    80002dd4:	e44e                	sd	s3,8(sp)
    80002dd6:	1800                	addi	s0,sp,48
    80002dd8:	892a                	mv	s2,a0
    80002dda:	84ae                	mv	s1,a1
    80002ddc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002dde:	fffff097          	auipc	ra,0xfffff
    80002de2:	d72080e7          	jalr	-654(ra) # 80001b50 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002de6:	86ce                	mv	a3,s3
    80002de8:	864a                	mv	a2,s2
    80002dea:	85a6                	mv	a1,s1
    80002dec:	6d28                	ld	a0,88(a0)
    80002dee:	fffff097          	auipc	ra,0xfffff
    80002df2:	b2c080e7          	jalr	-1236(ra) # 8000191a <copyinstr>
  if(err < 0)
    80002df6:	00054763          	bltz	a0,80002e04 <fetchstr+0x3a>
  return strlen(buf);
    80002dfa:	8526                	mv	a0,s1
    80002dfc:	ffffe097          	auipc	ra,0xffffe
    80002e00:	222080e7          	jalr	546(ra) # 8000101e <strlen>
}
    80002e04:	70a2                	ld	ra,40(sp)
    80002e06:	7402                	ld	s0,32(sp)
    80002e08:	64e2                	ld	s1,24(sp)
    80002e0a:	6942                	ld	s2,16(sp)
    80002e0c:	69a2                	ld	s3,8(sp)
    80002e0e:	6145                	addi	sp,sp,48
    80002e10:	8082                	ret

0000000080002e12 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e12:	1101                	addi	sp,sp,-32
    80002e14:	ec06                	sd	ra,24(sp)
    80002e16:	e822                	sd	s0,16(sp)
    80002e18:	e426                	sd	s1,8(sp)
    80002e1a:	1000                	addi	s0,sp,32
    80002e1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e1e:	00000097          	auipc	ra,0x0
    80002e22:	ef2080e7          	jalr	-270(ra) # 80002d10 <argraw>
    80002e26:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e28:	4501                	li	a0,0
    80002e2a:	60e2                	ld	ra,24(sp)
    80002e2c:	6442                	ld	s0,16(sp)
    80002e2e:	64a2                	ld	s1,8(sp)
    80002e30:	6105                	addi	sp,sp,32
    80002e32:	8082                	ret

0000000080002e34 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	1000                	addi	s0,sp,32
    80002e3e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	ed0080e7          	jalr	-304(ra) # 80002d10 <argraw>
    80002e48:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e4a:	4501                	li	a0,0
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6105                	addi	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	e426                	sd	s1,8(sp)
    80002e5e:	e04a                	sd	s2,0(sp)
    80002e60:	1000                	addi	s0,sp,32
    80002e62:	84ae                	mv	s1,a1
    80002e64:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e66:	00000097          	auipc	ra,0x0
    80002e6a:	eaa080e7          	jalr	-342(ra) # 80002d10 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e6e:	864a                	mv	a2,s2
    80002e70:	85a6                	mv	a1,s1
    80002e72:	00000097          	auipc	ra,0x0
    80002e76:	f58080e7          	jalr	-168(ra) # 80002dca <fetchstr>
}
    80002e7a:	60e2                	ld	ra,24(sp)
    80002e7c:	6442                	ld	s0,16(sp)
    80002e7e:	64a2                	ld	s1,8(sp)
    80002e80:	6902                	ld	s2,0(sp)
    80002e82:	6105                	addi	sp,sp,32
    80002e84:	8082                	ret

0000000080002e86 <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002e86:	1101                	addi	sp,sp,-32
    80002e88:	ec06                	sd	ra,24(sp)
    80002e8a:	e822                	sd	s0,16(sp)
    80002e8c:	e426                	sd	s1,8(sp)
    80002e8e:	e04a                	sd	s2,0(sp)
    80002e90:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e92:	fffff097          	auipc	ra,0xfffff
    80002e96:	cbe080e7          	jalr	-834(ra) # 80001b50 <myproc>
    80002e9a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e9c:	06053903          	ld	s2,96(a0)
    80002ea0:	0a893783          	ld	a5,168(s2)
    80002ea4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ea8:	37fd                	addiw	a5,a5,-1
    80002eaa:	4759                	li	a4,22
    80002eac:	00f76f63          	bltu	a4,a5,80002eca <syscall+0x44>
    80002eb0:	00369713          	slli	a4,a3,0x3
    80002eb4:	00007797          	auipc	a5,0x7
    80002eb8:	b6c78793          	addi	a5,a5,-1172 # 80009a20 <syscalls>
    80002ebc:	97ba                	add	a5,a5,a4
    80002ebe:	639c                	ld	a5,0(a5)
    80002ec0:	c789                	beqz	a5,80002eca <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ec2:	9782                	jalr	a5
    80002ec4:	06a93823          	sd	a0,112(s2)
    80002ec8:	a839                	j	80002ee6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002eca:	16048613          	addi	a2,s1,352
    80002ece:	40ac                	lw	a1,64(s1)
    80002ed0:	00007517          	auipc	a0,0x7
    80002ed4:	b1850513          	addi	a0,a0,-1256 # 800099e8 <nointr_desc.0+0x88>
    80002ed8:	ffffd097          	auipc	ra,0xffffd
    80002edc:	6ee080e7          	jalr	1774(ra) # 800005c6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ee0:	70bc                	ld	a5,96(s1)
    80002ee2:	577d                	li	a4,-1
    80002ee4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ee6:	60e2                	ld	ra,24(sp)
    80002ee8:	6442                	ld	s0,16(sp)
    80002eea:	64a2                	ld	s1,8(sp)
    80002eec:	6902                	ld	s2,0(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret

0000000080002ef2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ef2:	1101                	addi	sp,sp,-32
    80002ef4:	ec06                	sd	ra,24(sp)
    80002ef6:	e822                	sd	s0,16(sp)
    80002ef8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002efa:	fec40593          	addi	a1,s0,-20
    80002efe:	4501                	li	a0,0
    80002f00:	00000097          	auipc	ra,0x0
    80002f04:	f12080e7          	jalr	-238(ra) # 80002e12 <argint>
    return -1;
    80002f08:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f0a:	00054963          	bltz	a0,80002f1c <sys_exit+0x2a>
  exit(n);
    80002f0e:	fec42503          	lw	a0,-20(s0)
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	35a080e7          	jalr	858(ra) # 8000226c <exit>
  return 0;  // not reached
    80002f1a:	4781                	li	a5,0
}
    80002f1c:	853e                	mv	a0,a5
    80002f1e:	60e2                	ld	ra,24(sp)
    80002f20:	6442                	ld	s0,16(sp)
    80002f22:	6105                	addi	sp,sp,32
    80002f24:	8082                	ret

0000000080002f26 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f26:	1141                	addi	sp,sp,-16
    80002f28:	e406                	sd	ra,8(sp)
    80002f2a:	e022                	sd	s0,0(sp)
    80002f2c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f2e:	fffff097          	auipc	ra,0xfffff
    80002f32:	c22080e7          	jalr	-990(ra) # 80001b50 <myproc>
}
    80002f36:	4128                	lw	a0,64(a0)
    80002f38:	60a2                	ld	ra,8(sp)
    80002f3a:	6402                	ld	s0,0(sp)
    80002f3c:	0141                	addi	sp,sp,16
    80002f3e:	8082                	ret

0000000080002f40 <sys_fork>:

uint64
sys_fork(void)
{
    80002f40:	1141                	addi	sp,sp,-16
    80002f42:	e406                	sd	ra,8(sp)
    80002f44:	e022                	sd	s0,0(sp)
    80002f46:	0800                	addi	s0,sp,16
  return fork();
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	fae080e7          	jalr	-82(ra) # 80001ef6 <fork>
}
    80002f50:	60a2                	ld	ra,8(sp)
    80002f52:	6402                	ld	s0,0(sp)
    80002f54:	0141                	addi	sp,sp,16
    80002f56:	8082                	ret

0000000080002f58 <sys_wait>:

uint64
sys_wait(void)
{
    80002f58:	1101                	addi	sp,sp,-32
    80002f5a:	ec06                	sd	ra,24(sp)
    80002f5c:	e822                	sd	s0,16(sp)
    80002f5e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f60:	fe840593          	addi	a1,s0,-24
    80002f64:	4501                	li	a0,0
    80002f66:	00000097          	auipc	ra,0x0
    80002f6a:	ece080e7          	jalr	-306(ra) # 80002e34 <argaddr>
    80002f6e:	87aa                	mv	a5,a0
    return -1;
    80002f70:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f72:	0007c863          	bltz	a5,80002f82 <sys_wait+0x2a>
  return wait(p);
    80002f76:	fe843503          	ld	a0,-24(s0)
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	5a4080e7          	jalr	1444(ra) # 8000251e <wait>
}
    80002f82:	60e2                	ld	ra,24(sp)
    80002f84:	6442                	ld	s0,16(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret

0000000080002f8a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f8a:	7179                	addi	sp,sp,-48
    80002f8c:	f406                	sd	ra,40(sp)
    80002f8e:	f022                	sd	s0,32(sp)
    80002f90:	ec26                	sd	s1,24(sp)
    80002f92:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f94:	fdc40593          	addi	a1,s0,-36
    80002f98:	4501                	li	a0,0
    80002f9a:	00000097          	auipc	ra,0x0
    80002f9e:	e78080e7          	jalr	-392(ra) # 80002e12 <argint>
    return -1;
    80002fa2:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002fa4:	00054f63          	bltz	a0,80002fc2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002fa8:	fffff097          	auipc	ra,0xfffff
    80002fac:	ba8080e7          	jalr	-1112(ra) # 80001b50 <myproc>
    80002fb0:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002fb2:	fdc42503          	lw	a0,-36(s0)
    80002fb6:	fffff097          	auipc	ra,0xfffff
    80002fba:	ecc080e7          	jalr	-308(ra) # 80001e82 <growproc>
    80002fbe:	00054863          	bltz	a0,80002fce <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fc2:	8526                	mv	a0,s1
    80002fc4:	70a2                	ld	ra,40(sp)
    80002fc6:	7402                	ld	s0,32(sp)
    80002fc8:	64e2                	ld	s1,24(sp)
    80002fca:	6145                	addi	sp,sp,48
    80002fcc:	8082                	ret
    return -1;
    80002fce:	54fd                	li	s1,-1
    80002fd0:	bfcd                	j	80002fc2 <sys_sbrk+0x38>

0000000080002fd2 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fd2:	7139                	addi	sp,sp,-64
    80002fd4:	fc06                	sd	ra,56(sp)
    80002fd6:	f822                	sd	s0,48(sp)
    80002fd8:	f426                	sd	s1,40(sp)
    80002fda:	f04a                	sd	s2,32(sp)
    80002fdc:	ec4e                	sd	s3,24(sp)
    80002fde:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fe0:	fcc40593          	addi	a1,s0,-52
    80002fe4:	4501                	li	a0,0
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	e2c080e7          	jalr	-468(ra) # 80002e12 <argint>
    return -1;
    80002fee:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ff0:	06054563          	bltz	a0,8000305a <sys_sleep+0x88>
  acquire(&tickslock);
    80002ff4:	0002a517          	auipc	a0,0x2a
    80002ff8:	d2450513          	addi	a0,a0,-732 # 8002cd18 <tickslock>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	b96080e7          	jalr	-1130(ra) # 80000b92 <acquire>
  ticks0 = ticks;
    80003004:	00007917          	auipc	s2,0x7
    80003008:	00c92903          	lw	s2,12(s2) # 8000a010 <ticks>
  while(ticks - ticks0 < n){
    8000300c:	fcc42783          	lw	a5,-52(s0)
    80003010:	cf85                	beqz	a5,80003048 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003012:	0002a997          	auipc	s3,0x2a
    80003016:	d0698993          	addi	s3,s3,-762 # 8002cd18 <tickslock>
    8000301a:	00007497          	auipc	s1,0x7
    8000301e:	ff648493          	addi	s1,s1,-10 # 8000a010 <ticks>
    if(myproc()->killed){
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	b2e080e7          	jalr	-1234(ra) # 80001b50 <myproc>
    8000302a:	5d1c                	lw	a5,56(a0)
    8000302c:	ef9d                	bnez	a5,8000306a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000302e:	85ce                	mv	a1,s3
    80003030:	8526                	mv	a0,s1
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	46e080e7          	jalr	1134(ra) # 800024a0 <sleep>
  while(ticks - ticks0 < n){
    8000303a:	409c                	lw	a5,0(s1)
    8000303c:	412787bb          	subw	a5,a5,s2
    80003040:	fcc42703          	lw	a4,-52(s0)
    80003044:	fce7efe3          	bltu	a5,a4,80003022 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003048:	0002a517          	auipc	a0,0x2a
    8000304c:	cd050513          	addi	a0,a0,-816 # 8002cd18 <tickslock>
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	c12080e7          	jalr	-1006(ra) # 80000c62 <release>
  return 0;
    80003058:	4781                	li	a5,0
}
    8000305a:	853e                	mv	a0,a5
    8000305c:	70e2                	ld	ra,56(sp)
    8000305e:	7442                	ld	s0,48(sp)
    80003060:	74a2                	ld	s1,40(sp)
    80003062:	7902                	ld	s2,32(sp)
    80003064:	69e2                	ld	s3,24(sp)
    80003066:	6121                	addi	sp,sp,64
    80003068:	8082                	ret
      release(&tickslock);
    8000306a:	0002a517          	auipc	a0,0x2a
    8000306e:	cae50513          	addi	a0,a0,-850 # 8002cd18 <tickslock>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	bf0080e7          	jalr	-1040(ra) # 80000c62 <release>
      return -1;
    8000307a:	57fd                	li	a5,-1
    8000307c:	bff9                	j	8000305a <sys_sleep+0x88>

000000008000307e <sys_kill>:

uint64
sys_kill(void)
{
    8000307e:	1101                	addi	sp,sp,-32
    80003080:	ec06                	sd	ra,24(sp)
    80003082:	e822                	sd	s0,16(sp)
    80003084:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003086:	fec40593          	addi	a1,s0,-20
    8000308a:	4501                	li	a0,0
    8000308c:	00000097          	auipc	ra,0x0
    80003090:	d86080e7          	jalr	-634(ra) # 80002e12 <argint>
    80003094:	87aa                	mv	a5,a0
    return -1;
    80003096:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003098:	0007c863          	bltz	a5,800030a8 <sys_kill+0x2a>
  return kill(pid);
    8000309c:	fec42503          	lw	a0,-20(s0)
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	5f2080e7          	jalr	1522(ra) # 80002692 <kill>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret

00000000800030b0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030b0:	1101                	addi	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ba:	0002a517          	auipc	a0,0x2a
    800030be:	c5e50513          	addi	a0,a0,-930 # 8002cd18 <tickslock>
    800030c2:	ffffe097          	auipc	ra,0xffffe
    800030c6:	ad0080e7          	jalr	-1328(ra) # 80000b92 <acquire>
  xticks = ticks;
    800030ca:	00007497          	auipc	s1,0x7
    800030ce:	f464a483          	lw	s1,-186(s1) # 8000a010 <ticks>
  release(&tickslock);
    800030d2:	0002a517          	auipc	a0,0x2a
    800030d6:	c4650513          	addi	a0,a0,-954 # 8002cd18 <tickslock>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	b88080e7          	jalr	-1144(ra) # 80000c62 <release>
  return xticks;
    800030e2:	02049513          	slli	a0,s1,0x20
    800030e6:	9101                	srli	a0,a0,0x20
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	64a2                	ld	s1,8(sp)
    800030ee:	6105                	addi	sp,sp,32
    800030f0:	8082                	ret

00000000800030f2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030f2:	7179                	addi	sp,sp,-48
    800030f4:	f406                	sd	ra,40(sp)
    800030f6:	f022                	sd	s0,32(sp)
    800030f8:	ec26                	sd	s1,24(sp)
    800030fa:	e84a                	sd	s2,16(sp)
    800030fc:	e44e                	sd	s3,8(sp)
    800030fe:	e052                	sd	s4,0(sp)
    80003100:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003102:	00007597          	auipc	a1,0x7
    80003106:	9de58593          	addi	a1,a1,-1570 # 80009ae0 <syscalls+0xc0>
    8000310a:	0002a517          	auipc	a0,0x2a
    8000310e:	c2e50513          	addi	a0,a0,-978 # 8002cd38 <bcache>
    80003112:	ffffe097          	auipc	ra,0xffffe
    80003116:	9aa080e7          	jalr	-1622(ra) # 80000abc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000311a:	00032797          	auipc	a5,0x32
    8000311e:	c1e78793          	addi	a5,a5,-994 # 80034d38 <bcache+0x8000>
    80003122:	00032717          	auipc	a4,0x32
    80003126:	f7670713          	addi	a4,a4,-138 # 80035098 <bcache+0x8360>
    8000312a:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    8000312e:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003132:	0002a497          	auipc	s1,0x2a
    80003136:	c2648493          	addi	s1,s1,-986 # 8002cd58 <bcache+0x20>
    b->next = bcache.head.next;
    8000313a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000313c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000313e:	00007a17          	auipc	s4,0x7
    80003142:	9aaa0a13          	addi	s4,s4,-1622 # 80009ae8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80003146:	3b893783          	ld	a5,952(s2)
    8000314a:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    8000314c:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    80003150:	85d2                	mv	a1,s4
    80003152:	01048513          	addi	a0,s1,16
    80003156:	00001097          	auipc	ra,0x1
    8000315a:	4aa080e7          	jalr	1194(ra) # 80004600 <initsleeplock>
    bcache.head.next->prev = b;
    8000315e:	3b893783          	ld	a5,952(s2)
    80003162:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    80003164:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003168:	46048493          	addi	s1,s1,1120
    8000316c:	fd349de3          	bne	s1,s3,80003146 <binit+0x54>
  }
}
    80003170:	70a2                	ld	ra,40(sp)
    80003172:	7402                	ld	s0,32(sp)
    80003174:	64e2                	ld	s1,24(sp)
    80003176:	6942                	ld	s2,16(sp)
    80003178:	69a2                	ld	s3,8(sp)
    8000317a:	6a02                	ld	s4,0(sp)
    8000317c:	6145                	addi	sp,sp,48
    8000317e:	8082                	ret

0000000080003180 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003180:	7179                	addi	sp,sp,-48
    80003182:	f406                	sd	ra,40(sp)
    80003184:	f022                	sd	s0,32(sp)
    80003186:	ec26                	sd	s1,24(sp)
    80003188:	e84a                	sd	s2,16(sp)
    8000318a:	e44e                	sd	s3,8(sp)
    8000318c:	1800                	addi	s0,sp,48
    8000318e:	892a                	mv	s2,a0
    80003190:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003192:	0002a517          	auipc	a0,0x2a
    80003196:	ba650513          	addi	a0,a0,-1114 # 8002cd38 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	9f8080e7          	jalr	-1544(ra) # 80000b92 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031a2:	00032497          	auipc	s1,0x32
    800031a6:	f4e4b483          	ld	s1,-178(s1) # 800350f0 <bcache+0x83b8>
    800031aa:	00032797          	auipc	a5,0x32
    800031ae:	eee78793          	addi	a5,a5,-274 # 80035098 <bcache+0x8360>
    800031b2:	02f48f63          	beq	s1,a5,800031f0 <bread+0x70>
    800031b6:	873e                	mv	a4,a5
    800031b8:	a021                	j	800031c0 <bread+0x40>
    800031ba:	6ca4                	ld	s1,88(s1)
    800031bc:	02e48a63          	beq	s1,a4,800031f0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800031c0:	449c                	lw	a5,8(s1)
    800031c2:	ff279ce3          	bne	a5,s2,800031ba <bread+0x3a>
    800031c6:	44dc                	lw	a5,12(s1)
    800031c8:	ff3799e3          	bne	a5,s3,800031ba <bread+0x3a>
      b->refcnt++;
    800031cc:	44bc                	lw	a5,72(s1)
    800031ce:	2785                	addiw	a5,a5,1
    800031d0:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800031d2:	0002a517          	auipc	a0,0x2a
    800031d6:	b6650513          	addi	a0,a0,-1178 # 8002cd38 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	a88080e7          	jalr	-1400(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    800031e2:	01048513          	addi	a0,s1,16
    800031e6:	00001097          	auipc	ra,0x1
    800031ea:	454080e7          	jalr	1108(ra) # 8000463a <acquiresleep>
      return b;
    800031ee:	a8b9                	j	8000324c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031f0:	00032497          	auipc	s1,0x32
    800031f4:	ef84b483          	ld	s1,-264(s1) # 800350e8 <bcache+0x83b0>
    800031f8:	00032797          	auipc	a5,0x32
    800031fc:	ea078793          	addi	a5,a5,-352 # 80035098 <bcache+0x8360>
    80003200:	00f48863          	beq	s1,a5,80003210 <bread+0x90>
    80003204:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003206:	44bc                	lw	a5,72(s1)
    80003208:	cf81                	beqz	a5,80003220 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000320a:	68a4                	ld	s1,80(s1)
    8000320c:	fee49de3          	bne	s1,a4,80003206 <bread+0x86>
  panic("bget: no buffers");
    80003210:	00007517          	auipc	a0,0x7
    80003214:	8e050513          	addi	a0,a0,-1824 # 80009af0 <syscalls+0xd0>
    80003218:	ffffd097          	auipc	ra,0xffffd
    8000321c:	34c080e7          	jalr	844(ra) # 80000564 <panic>
      b->dev = dev;
    80003220:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003224:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003228:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000322c:	4785                	li	a5,1
    8000322e:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003230:	0002a517          	auipc	a0,0x2a
    80003234:	b0850513          	addi	a0,a0,-1272 # 8002cd38 <bcache>
    80003238:	ffffe097          	auipc	ra,0xffffe
    8000323c:	a2a080e7          	jalr	-1494(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    80003240:	01048513          	addi	a0,s1,16
    80003244:	00001097          	auipc	ra,0x1
    80003248:	3f6080e7          	jalr	1014(ra) # 8000463a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000324c:	409c                	lw	a5,0(s1)
    8000324e:	cb89                	beqz	a5,80003260 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003250:	8526                	mv	a0,s1
    80003252:	70a2                	ld	ra,40(sp)
    80003254:	7402                	ld	s0,32(sp)
    80003256:	64e2                	ld	s1,24(sp)
    80003258:	6942                	ld	s2,16(sp)
    8000325a:	69a2                	ld	s3,8(sp)
    8000325c:	6145                	addi	sp,sp,48
    8000325e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003260:	4581                	li	a1,0
    80003262:	8526                	mv	a0,s1
    80003264:	00003097          	auipc	ra,0x3
    80003268:	f92080e7          	jalr	-110(ra) # 800061f6 <virtio_disk_rw>
    b->valid = 1;
    8000326c:	4785                	li	a5,1
    8000326e:	c09c                	sw	a5,0(s1)
  return b;
    80003270:	b7c5                	j	80003250 <bread+0xd0>

0000000080003272 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003272:	1101                	addi	sp,sp,-32
    80003274:	ec06                	sd	ra,24(sp)
    80003276:	e822                	sd	s0,16(sp)
    80003278:	e426                	sd	s1,8(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000327e:	0541                	addi	a0,a0,16
    80003280:	00001097          	auipc	ra,0x1
    80003284:	454080e7          	jalr	1108(ra) # 800046d4 <holdingsleep>
    80003288:	cd01                	beqz	a0,800032a0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000328a:	4585                	li	a1,1
    8000328c:	8526                	mv	a0,s1
    8000328e:	00003097          	auipc	ra,0x3
    80003292:	f68080e7          	jalr	-152(ra) # 800061f6 <virtio_disk_rw>
}
    80003296:	60e2                	ld	ra,24(sp)
    80003298:	6442                	ld	s0,16(sp)
    8000329a:	64a2                	ld	s1,8(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret
    panic("bwrite");
    800032a0:	00007517          	auipc	a0,0x7
    800032a4:	86850513          	addi	a0,a0,-1944 # 80009b08 <syscalls+0xe8>
    800032a8:	ffffd097          	auipc	ra,0xffffd
    800032ac:	2bc080e7          	jalr	700(ra) # 80000564 <panic>

00000000800032b0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	e04a                	sd	s2,0(sp)
    800032ba:	1000                	addi	s0,sp,32
    800032bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032be:	01050913          	addi	s2,a0,16
    800032c2:	854a                	mv	a0,s2
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	410080e7          	jalr	1040(ra) # 800046d4 <holdingsleep>
    800032cc:	c92d                	beqz	a0,8000333e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032ce:	854a                	mv	a0,s2
    800032d0:	00001097          	auipc	ra,0x1
    800032d4:	3c0080e7          	jalr	960(ra) # 80004690 <releasesleep>

  acquire(&bcache.lock);
    800032d8:	0002a517          	auipc	a0,0x2a
    800032dc:	a6050513          	addi	a0,a0,-1440 # 8002cd38 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	8b2080e7          	jalr	-1870(ra) # 80000b92 <acquire>
  b->refcnt--;
    800032e8:	44bc                	lw	a5,72(s1)
    800032ea:	37fd                	addiw	a5,a5,-1
    800032ec:	0007871b          	sext.w	a4,a5
    800032f0:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800032f2:	eb05                	bnez	a4,80003322 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032f4:	6cbc                	ld	a5,88(s1)
    800032f6:	68b8                	ld	a4,80(s1)
    800032f8:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800032fa:	68bc                	ld	a5,80(s1)
    800032fc:	6cb8                	ld	a4,88(s1)
    800032fe:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    80003300:	00032797          	auipc	a5,0x32
    80003304:	a3878793          	addi	a5,a5,-1480 # 80034d38 <bcache+0x8000>
    80003308:	3b87b703          	ld	a4,952(a5)
    8000330c:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    8000330e:	00032717          	auipc	a4,0x32
    80003312:	d8a70713          	addi	a4,a4,-630 # 80035098 <bcache+0x8360>
    80003316:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003318:	3b87b703          	ld	a4,952(a5)
    8000331c:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    8000331e:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003322:	0002a517          	auipc	a0,0x2a
    80003326:	a1650513          	addi	a0,a0,-1514 # 8002cd38 <bcache>
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	938080e7          	jalr	-1736(ra) # 80000c62 <release>
}
    80003332:	60e2                	ld	ra,24(sp)
    80003334:	6442                	ld	s0,16(sp)
    80003336:	64a2                	ld	s1,8(sp)
    80003338:	6902                	ld	s2,0(sp)
    8000333a:	6105                	addi	sp,sp,32
    8000333c:	8082                	ret
    panic("brelse");
    8000333e:	00006517          	auipc	a0,0x6
    80003342:	7d250513          	addi	a0,a0,2002 # 80009b10 <syscalls+0xf0>
    80003346:	ffffd097          	auipc	ra,0xffffd
    8000334a:	21e080e7          	jalr	542(ra) # 80000564 <panic>

000000008000334e <bpin>:

void
bpin(struct buf *b) {
    8000334e:	1101                	addi	sp,sp,-32
    80003350:	ec06                	sd	ra,24(sp)
    80003352:	e822                	sd	s0,16(sp)
    80003354:	e426                	sd	s1,8(sp)
    80003356:	1000                	addi	s0,sp,32
    80003358:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000335a:	0002a517          	auipc	a0,0x2a
    8000335e:	9de50513          	addi	a0,a0,-1570 # 8002cd38 <bcache>
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	830080e7          	jalr	-2000(ra) # 80000b92 <acquire>
  b->refcnt++;
    8000336a:	44bc                	lw	a5,72(s1)
    8000336c:	2785                	addiw	a5,a5,1
    8000336e:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003370:	0002a517          	auipc	a0,0x2a
    80003374:	9c850513          	addi	a0,a0,-1592 # 8002cd38 <bcache>
    80003378:	ffffe097          	auipc	ra,0xffffe
    8000337c:	8ea080e7          	jalr	-1814(ra) # 80000c62 <release>
}
    80003380:	60e2                	ld	ra,24(sp)
    80003382:	6442                	ld	s0,16(sp)
    80003384:	64a2                	ld	s1,8(sp)
    80003386:	6105                	addi	sp,sp,32
    80003388:	8082                	ret

000000008000338a <bunpin>:

void
bunpin(struct buf *b) {
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	1000                	addi	s0,sp,32
    80003394:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003396:	0002a517          	auipc	a0,0x2a
    8000339a:	9a250513          	addi	a0,a0,-1630 # 8002cd38 <bcache>
    8000339e:	ffffd097          	auipc	ra,0xffffd
    800033a2:	7f4080e7          	jalr	2036(ra) # 80000b92 <acquire>
  b->refcnt--;
    800033a6:	44bc                	lw	a5,72(s1)
    800033a8:	37fd                	addiw	a5,a5,-1
    800033aa:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800033ac:	0002a517          	auipc	a0,0x2a
    800033b0:	98c50513          	addi	a0,a0,-1652 # 8002cd38 <bcache>
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	8ae080e7          	jalr	-1874(ra) # 80000c62 <release>
}
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	64a2                	ld	s1,8(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret

00000000800033c6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033c6:	1101                	addi	sp,sp,-32
    800033c8:	ec06                	sd	ra,24(sp)
    800033ca:	e822                	sd	s0,16(sp)
    800033cc:	e426                	sd	s1,8(sp)
    800033ce:	e04a                	sd	s2,0(sp)
    800033d0:	1000                	addi	s0,sp,32
    800033d2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033d4:	00d5d59b          	srliw	a1,a1,0xd
    800033d8:	00032797          	auipc	a5,0x32
    800033dc:	13c7a783          	lw	a5,316(a5) # 80035514 <sb+0x1c>
    800033e0:	9dbd                	addw	a1,a1,a5
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	d9e080e7          	jalr	-610(ra) # 80003180 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033ea:	0074f713          	andi	a4,s1,7
    800033ee:	4785                	li	a5,1
    800033f0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033f4:	14ce                	slli	s1,s1,0x33
    800033f6:	90d9                	srli	s1,s1,0x36
    800033f8:	00950733          	add	a4,a0,s1
    800033fc:	06074703          	lbu	a4,96(a4)
    80003400:	00e7f6b3          	and	a3,a5,a4
    80003404:	c69d                	beqz	a3,80003432 <bfree+0x6c>
    80003406:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003408:	94aa                	add	s1,s1,a0
    8000340a:	fff7c793          	not	a5,a5
    8000340e:	8ff9                	and	a5,a5,a4
    80003410:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003414:	00001097          	auipc	ra,0x1
    80003418:	106080e7          	jalr	262(ra) # 8000451a <log_write>
  brelse(bp);
    8000341c:	854a                	mv	a0,s2
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	e92080e7          	jalr	-366(ra) # 800032b0 <brelse>
}
    80003426:	60e2                	ld	ra,24(sp)
    80003428:	6442                	ld	s0,16(sp)
    8000342a:	64a2                	ld	s1,8(sp)
    8000342c:	6902                	ld	s2,0(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret
    panic("freeing free block");
    80003432:	00006517          	auipc	a0,0x6
    80003436:	6e650513          	addi	a0,a0,1766 # 80009b18 <syscalls+0xf8>
    8000343a:	ffffd097          	auipc	ra,0xffffd
    8000343e:	12a080e7          	jalr	298(ra) # 80000564 <panic>

0000000080003442 <balloc>:
{
    80003442:	711d                	addi	sp,sp,-96
    80003444:	ec86                	sd	ra,88(sp)
    80003446:	e8a2                	sd	s0,80(sp)
    80003448:	e4a6                	sd	s1,72(sp)
    8000344a:	e0ca                	sd	s2,64(sp)
    8000344c:	fc4e                	sd	s3,56(sp)
    8000344e:	f852                	sd	s4,48(sp)
    80003450:	f456                	sd	s5,40(sp)
    80003452:	f05a                	sd	s6,32(sp)
    80003454:	ec5e                	sd	s7,24(sp)
    80003456:	e862                	sd	s8,16(sp)
    80003458:	e466                	sd	s9,8(sp)
    8000345a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000345c:	00032797          	auipc	a5,0x32
    80003460:	0a07a783          	lw	a5,160(a5) # 800354fc <sb+0x4>
    80003464:	cbd1                	beqz	a5,800034f8 <balloc+0xb6>
    80003466:	8baa                	mv	s7,a0
    80003468:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000346a:	00032b17          	auipc	s6,0x32
    8000346e:	08eb0b13          	addi	s6,s6,142 # 800354f8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003472:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003474:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003476:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003478:	6c89                	lui	s9,0x2
    8000347a:	a831                	j	80003496 <balloc+0x54>
    brelse(bp);
    8000347c:	854a                	mv	a0,s2
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	e32080e7          	jalr	-462(ra) # 800032b0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003486:	015c87bb          	addw	a5,s9,s5
    8000348a:	00078a9b          	sext.w	s5,a5
    8000348e:	004b2703          	lw	a4,4(s6)
    80003492:	06eaf363          	bgeu	s5,a4,800034f8 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003496:	41fad79b          	sraiw	a5,s5,0x1f
    8000349a:	0137d79b          	srliw	a5,a5,0x13
    8000349e:	015787bb          	addw	a5,a5,s5
    800034a2:	40d7d79b          	sraiw	a5,a5,0xd
    800034a6:	01cb2583          	lw	a1,28(s6)
    800034aa:	9dbd                	addw	a1,a1,a5
    800034ac:	855e                	mv	a0,s7
    800034ae:	00000097          	auipc	ra,0x0
    800034b2:	cd2080e7          	jalr	-814(ra) # 80003180 <bread>
    800034b6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034b8:	004b2503          	lw	a0,4(s6)
    800034bc:	000a849b          	sext.w	s1,s5
    800034c0:	8662                	mv	a2,s8
    800034c2:	faa4fde3          	bgeu	s1,a0,8000347c <balloc+0x3a>
      m = 1 << (bi % 8);
    800034c6:	41f6579b          	sraiw	a5,a2,0x1f
    800034ca:	01d7d69b          	srliw	a3,a5,0x1d
    800034ce:	00c6873b          	addw	a4,a3,a2
    800034d2:	00777793          	andi	a5,a4,7
    800034d6:	9f95                	subw	a5,a5,a3
    800034d8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034dc:	4037571b          	sraiw	a4,a4,0x3
    800034e0:	00e906b3          	add	a3,s2,a4
    800034e4:	0606c683          	lbu	a3,96(a3)
    800034e8:	00d7f5b3          	and	a1,a5,a3
    800034ec:	cd91                	beqz	a1,80003508 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ee:	2605                	addiw	a2,a2,1
    800034f0:	2485                	addiw	s1,s1,1
    800034f2:	fd4618e3          	bne	a2,s4,800034c2 <balloc+0x80>
    800034f6:	b759                	j	8000347c <balloc+0x3a>
  panic("balloc: out of blocks");
    800034f8:	00006517          	auipc	a0,0x6
    800034fc:	63850513          	addi	a0,a0,1592 # 80009b30 <syscalls+0x110>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	064080e7          	jalr	100(ra) # 80000564 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003508:	974a                	add	a4,a4,s2
    8000350a:	8fd5                	or	a5,a5,a3
    8000350c:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003510:	854a                	mv	a0,s2
    80003512:	00001097          	auipc	ra,0x1
    80003516:	008080e7          	jalr	8(ra) # 8000451a <log_write>
        brelse(bp);
    8000351a:	854a                	mv	a0,s2
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	d94080e7          	jalr	-620(ra) # 800032b0 <brelse>
  bp = bread(dev, bno);
    80003524:	85a6                	mv	a1,s1
    80003526:	855e                	mv	a0,s7
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	c58080e7          	jalr	-936(ra) # 80003180 <bread>
    80003530:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003532:	40000613          	li	a2,1024
    80003536:	4581                	li	a1,0
    80003538:	06050513          	addi	a0,a0,96
    8000353c:	ffffe097          	auipc	ra,0xffffe
    80003540:	93a080e7          	jalr	-1734(ra) # 80000e76 <memset>
  log_write(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	00001097          	auipc	ra,0x1
    8000354a:	fd4080e7          	jalr	-44(ra) # 8000451a <log_write>
  brelse(bp);
    8000354e:	854a                	mv	a0,s2
    80003550:	00000097          	auipc	ra,0x0
    80003554:	d60080e7          	jalr	-672(ra) # 800032b0 <brelse>
}
    80003558:	8526                	mv	a0,s1
    8000355a:	60e6                	ld	ra,88(sp)
    8000355c:	6446                	ld	s0,80(sp)
    8000355e:	64a6                	ld	s1,72(sp)
    80003560:	6906                	ld	s2,64(sp)
    80003562:	79e2                	ld	s3,56(sp)
    80003564:	7a42                	ld	s4,48(sp)
    80003566:	7aa2                	ld	s5,40(sp)
    80003568:	7b02                	ld	s6,32(sp)
    8000356a:	6be2                	ld	s7,24(sp)
    8000356c:	6c42                	ld	s8,16(sp)
    8000356e:	6ca2                	ld	s9,8(sp)
    80003570:	6125                	addi	sp,sp,96
    80003572:	8082                	ret

0000000080003574 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003574:	7179                	addi	sp,sp,-48
    80003576:	f406                	sd	ra,40(sp)
    80003578:	f022                	sd	s0,32(sp)
    8000357a:	ec26                	sd	s1,24(sp)
    8000357c:	e84a                	sd	s2,16(sp)
    8000357e:	e44e                	sd	s3,8(sp)
    80003580:	e052                	sd	s4,0(sp)
    80003582:	1800                	addi	s0,sp,48
    80003584:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003586:	47ad                	li	a5,11
    80003588:	04b7fe63          	bgeu	a5,a1,800035e4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000358c:	ff45849b          	addiw	s1,a1,-12
    80003590:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003594:	0ff00793          	li	a5,255
    80003598:	0ae7e363          	bltu	a5,a4,8000363e <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000359c:	08852583          	lw	a1,136(a0)
    800035a0:	c5ad                	beqz	a1,8000360a <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800035a2:	00092503          	lw	a0,0(s2)
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	bda080e7          	jalr	-1062(ra) # 80003180 <bread>
    800035ae:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035b0:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800035b4:	02049593          	slli	a1,s1,0x20
    800035b8:	9181                	srli	a1,a1,0x20
    800035ba:	058a                	slli	a1,a1,0x2
    800035bc:	00b784b3          	add	s1,a5,a1
    800035c0:	0004a983          	lw	s3,0(s1)
    800035c4:	04098d63          	beqz	s3,8000361e <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800035c8:	8552                	mv	a0,s4
    800035ca:	00000097          	auipc	ra,0x0
    800035ce:	ce6080e7          	jalr	-794(ra) # 800032b0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800035d2:	854e                	mv	a0,s3
    800035d4:	70a2                	ld	ra,40(sp)
    800035d6:	7402                	ld	s0,32(sp)
    800035d8:	64e2                	ld	s1,24(sp)
    800035da:	6942                	ld	s2,16(sp)
    800035dc:	69a2                	ld	s3,8(sp)
    800035de:	6a02                	ld	s4,0(sp)
    800035e0:	6145                	addi	sp,sp,48
    800035e2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800035e4:	02059493          	slli	s1,a1,0x20
    800035e8:	9081                	srli	s1,s1,0x20
    800035ea:	048a                	slli	s1,s1,0x2
    800035ec:	94aa                	add	s1,s1,a0
    800035ee:	0584a983          	lw	s3,88(s1)
    800035f2:	fe0990e3          	bnez	s3,800035d2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800035f6:	4108                	lw	a0,0(a0)
    800035f8:	00000097          	auipc	ra,0x0
    800035fc:	e4a080e7          	jalr	-438(ra) # 80003442 <balloc>
    80003600:	0005099b          	sext.w	s3,a0
    80003604:	0534ac23          	sw	s3,88(s1)
    80003608:	b7e9                	j	800035d2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000360a:	4108                	lw	a0,0(a0)
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	e36080e7          	jalr	-458(ra) # 80003442 <balloc>
    80003614:	0005059b          	sext.w	a1,a0
    80003618:	08b92423          	sw	a1,136(s2)
    8000361c:	b759                	j	800035a2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000361e:	00092503          	lw	a0,0(s2)
    80003622:	00000097          	auipc	ra,0x0
    80003626:	e20080e7          	jalr	-480(ra) # 80003442 <balloc>
    8000362a:	0005099b          	sext.w	s3,a0
    8000362e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003632:	8552                	mv	a0,s4
    80003634:	00001097          	auipc	ra,0x1
    80003638:	ee6080e7          	jalr	-282(ra) # 8000451a <log_write>
    8000363c:	b771                	j	800035c8 <bmap+0x54>
  panic("bmap: out of range");
    8000363e:	00006517          	auipc	a0,0x6
    80003642:	50a50513          	addi	a0,a0,1290 # 80009b48 <syscalls+0x128>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	f1e080e7          	jalr	-226(ra) # 80000564 <panic>

000000008000364e <iget>:
{
    8000364e:	7179                	addi	sp,sp,-48
    80003650:	f406                	sd	ra,40(sp)
    80003652:	f022                	sd	s0,32(sp)
    80003654:	ec26                	sd	s1,24(sp)
    80003656:	e84a                	sd	s2,16(sp)
    80003658:	e44e                	sd	s3,8(sp)
    8000365a:	e052                	sd	s4,0(sp)
    8000365c:	1800                	addi	s0,sp,48
    8000365e:	89aa                	mv	s3,a0
    80003660:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003662:	00032517          	auipc	a0,0x32
    80003666:	eb650513          	addi	a0,a0,-330 # 80035518 <icache>
    8000366a:	ffffd097          	auipc	ra,0xffffd
    8000366e:	528080e7          	jalr	1320(ra) # 80000b92 <acquire>
  empty = 0;
    80003672:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003674:	00032497          	auipc	s1,0x32
    80003678:	ec448493          	addi	s1,s1,-316 # 80035538 <icache+0x20>
    8000367c:	00034697          	auipc	a3,0x34
    80003680:	adc68693          	addi	a3,a3,-1316 # 80037158 <log>
    80003684:	a039                	j	80003692 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003686:	02090b63          	beqz	s2,800036bc <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000368a:	09048493          	addi	s1,s1,144
    8000368e:	02d48a63          	beq	s1,a3,800036c2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003692:	449c                	lw	a5,8(s1)
    80003694:	fef059e3          	blez	a5,80003686 <iget+0x38>
    80003698:	4098                	lw	a4,0(s1)
    8000369a:	ff3716e3          	bne	a4,s3,80003686 <iget+0x38>
    8000369e:	40d8                	lw	a4,4(s1)
    800036a0:	ff4713e3          	bne	a4,s4,80003686 <iget+0x38>
      ip->ref++;
    800036a4:	2785                	addiw	a5,a5,1
    800036a6:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800036a8:	00032517          	auipc	a0,0x32
    800036ac:	e7050513          	addi	a0,a0,-400 # 80035518 <icache>
    800036b0:	ffffd097          	auipc	ra,0xffffd
    800036b4:	5b2080e7          	jalr	1458(ra) # 80000c62 <release>
      return ip;
    800036b8:	8926                	mv	s2,s1
    800036ba:	a03d                	j	800036e8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036bc:	f7f9                	bnez	a5,8000368a <iget+0x3c>
    800036be:	8926                	mv	s2,s1
    800036c0:	b7e9                	j	8000368a <iget+0x3c>
  if(empty == 0)
    800036c2:	02090c63          	beqz	s2,800036fa <iget+0xac>
  ip->dev = dev;
    800036c6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800036ca:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800036ce:	4785                	li	a5,1
    800036d0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800036d4:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800036d8:	00032517          	auipc	a0,0x32
    800036dc:	e4050513          	addi	a0,a0,-448 # 80035518 <icache>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	582080e7          	jalr	1410(ra) # 80000c62 <release>
}
    800036e8:	854a                	mv	a0,s2
    800036ea:	70a2                	ld	ra,40(sp)
    800036ec:	7402                	ld	s0,32(sp)
    800036ee:	64e2                	ld	s1,24(sp)
    800036f0:	6942                	ld	s2,16(sp)
    800036f2:	69a2                	ld	s3,8(sp)
    800036f4:	6a02                	ld	s4,0(sp)
    800036f6:	6145                	addi	sp,sp,48
    800036f8:	8082                	ret
    panic("iget: no inodes");
    800036fa:	00006517          	auipc	a0,0x6
    800036fe:	46650513          	addi	a0,a0,1126 # 80009b60 <syscalls+0x140>
    80003702:	ffffd097          	auipc	ra,0xffffd
    80003706:	e62080e7          	jalr	-414(ra) # 80000564 <panic>

000000008000370a <fsinit>:
fsinit(int dev) {
    8000370a:	7179                	addi	sp,sp,-48
    8000370c:	f406                	sd	ra,40(sp)
    8000370e:	f022                	sd	s0,32(sp)
    80003710:	ec26                	sd	s1,24(sp)
    80003712:	e84a                	sd	s2,16(sp)
    80003714:	e44e                	sd	s3,8(sp)
    80003716:	1800                	addi	s0,sp,48
    80003718:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000371a:	4585                	li	a1,1
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	a64080e7          	jalr	-1436(ra) # 80003180 <bread>
    80003724:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003726:	00032997          	auipc	s3,0x32
    8000372a:	dd298993          	addi	s3,s3,-558 # 800354f8 <sb>
    8000372e:	02000613          	li	a2,32
    80003732:	06050593          	addi	a1,a0,96
    80003736:	854e                	mv	a0,s3
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	79a080e7          	jalr	1946(ra) # 80000ed2 <memmove>
  brelse(bp);
    80003740:	8526                	mv	a0,s1
    80003742:	00000097          	auipc	ra,0x0
    80003746:	b6e080e7          	jalr	-1170(ra) # 800032b0 <brelse>
  if(sb.magic != FSMAGIC)
    8000374a:	0009a703          	lw	a4,0(s3)
    8000374e:	102037b7          	lui	a5,0x10203
    80003752:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003756:	02f71263          	bne	a4,a5,8000377a <fsinit+0x70>
  initlog(dev, &sb);
    8000375a:	00032597          	auipc	a1,0x32
    8000375e:	d9e58593          	addi	a1,a1,-610 # 800354f8 <sb>
    80003762:	854a                	mv	a0,s2
    80003764:	00001097          	auipc	ra,0x1
    80003768:	b3e080e7          	jalr	-1218(ra) # 800042a2 <initlog>
}
    8000376c:	70a2                	ld	ra,40(sp)
    8000376e:	7402                	ld	s0,32(sp)
    80003770:	64e2                	ld	s1,24(sp)
    80003772:	6942                	ld	s2,16(sp)
    80003774:	69a2                	ld	s3,8(sp)
    80003776:	6145                	addi	sp,sp,48
    80003778:	8082                	ret
    panic("invalid file system");
    8000377a:	00006517          	auipc	a0,0x6
    8000377e:	3f650513          	addi	a0,a0,1014 # 80009b70 <syscalls+0x150>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	de2080e7          	jalr	-542(ra) # 80000564 <panic>

000000008000378a <iinit>:
{
    8000378a:	7179                	addi	sp,sp,-48
    8000378c:	f406                	sd	ra,40(sp)
    8000378e:	f022                	sd	s0,32(sp)
    80003790:	ec26                	sd	s1,24(sp)
    80003792:	e84a                	sd	s2,16(sp)
    80003794:	e44e                	sd	s3,8(sp)
    80003796:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003798:	00006597          	auipc	a1,0x6
    8000379c:	3f058593          	addi	a1,a1,1008 # 80009b88 <syscalls+0x168>
    800037a0:	00032517          	auipc	a0,0x32
    800037a4:	d7850513          	addi	a0,a0,-648 # 80035518 <icache>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	314080e7          	jalr	788(ra) # 80000abc <initlock>
  for(i = 0; i < NINODE; i++) {
    800037b0:	00032497          	auipc	s1,0x32
    800037b4:	d9848493          	addi	s1,s1,-616 # 80035548 <icache+0x30>
    800037b8:	00034997          	auipc	s3,0x34
    800037bc:	9b098993          	addi	s3,s3,-1616 # 80037168 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800037c0:	00006917          	auipc	s2,0x6
    800037c4:	3d090913          	addi	s2,s2,976 # 80009b90 <syscalls+0x170>
    800037c8:	85ca                	mv	a1,s2
    800037ca:	8526                	mv	a0,s1
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	e34080e7          	jalr	-460(ra) # 80004600 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037d4:	09048493          	addi	s1,s1,144
    800037d8:	ff3498e3          	bne	s1,s3,800037c8 <iinit+0x3e>
}
    800037dc:	70a2                	ld	ra,40(sp)
    800037de:	7402                	ld	s0,32(sp)
    800037e0:	64e2                	ld	s1,24(sp)
    800037e2:	6942                	ld	s2,16(sp)
    800037e4:	69a2                	ld	s3,8(sp)
    800037e6:	6145                	addi	sp,sp,48
    800037e8:	8082                	ret

00000000800037ea <ialloc>:
{
    800037ea:	715d                	addi	sp,sp,-80
    800037ec:	e486                	sd	ra,72(sp)
    800037ee:	e0a2                	sd	s0,64(sp)
    800037f0:	fc26                	sd	s1,56(sp)
    800037f2:	f84a                	sd	s2,48(sp)
    800037f4:	f44e                	sd	s3,40(sp)
    800037f6:	f052                	sd	s4,32(sp)
    800037f8:	ec56                	sd	s5,24(sp)
    800037fa:	e85a                	sd	s6,16(sp)
    800037fc:	e45e                	sd	s7,8(sp)
    800037fe:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003800:	00032717          	auipc	a4,0x32
    80003804:	d0472703          	lw	a4,-764(a4) # 80035504 <sb+0xc>
    80003808:	4785                	li	a5,1
    8000380a:	04e7fa63          	bgeu	a5,a4,8000385e <ialloc+0x74>
    8000380e:	8aaa                	mv	s5,a0
    80003810:	8bae                	mv	s7,a1
    80003812:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003814:	00032a17          	auipc	s4,0x32
    80003818:	ce4a0a13          	addi	s4,s4,-796 # 800354f8 <sb>
    8000381c:	00048b1b          	sext.w	s6,s1
    80003820:	0044d793          	srli	a5,s1,0x4
    80003824:	018a2583          	lw	a1,24(s4)
    80003828:	9dbd                	addw	a1,a1,a5
    8000382a:	8556                	mv	a0,s5
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	954080e7          	jalr	-1708(ra) # 80003180 <bread>
    80003834:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003836:	06050993          	addi	s3,a0,96
    8000383a:	00f4f793          	andi	a5,s1,15
    8000383e:	079a                	slli	a5,a5,0x6
    80003840:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003842:	00099783          	lh	a5,0(s3)
    80003846:	c785                	beqz	a5,8000386e <ialloc+0x84>
    brelse(bp);
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	a68080e7          	jalr	-1432(ra) # 800032b0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003850:	0485                	addi	s1,s1,1
    80003852:	00ca2703          	lw	a4,12(s4)
    80003856:	0004879b          	sext.w	a5,s1
    8000385a:	fce7e1e3          	bltu	a5,a4,8000381c <ialloc+0x32>
  panic("ialloc: no inodes");
    8000385e:	00006517          	auipc	a0,0x6
    80003862:	33a50513          	addi	a0,a0,826 # 80009b98 <syscalls+0x178>
    80003866:	ffffd097          	auipc	ra,0xffffd
    8000386a:	cfe080e7          	jalr	-770(ra) # 80000564 <panic>
      memset(dip, 0, sizeof(*dip));
    8000386e:	04000613          	li	a2,64
    80003872:	4581                	li	a1,0
    80003874:	854e                	mv	a0,s3
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	600080e7          	jalr	1536(ra) # 80000e76 <memset>
      dip->type = type;
    8000387e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003882:	854a                	mv	a0,s2
    80003884:	00001097          	auipc	ra,0x1
    80003888:	c96080e7          	jalr	-874(ra) # 8000451a <log_write>
      brelse(bp);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00000097          	auipc	ra,0x0
    80003892:	a22080e7          	jalr	-1502(ra) # 800032b0 <brelse>
      return iget(dev, inum);
    80003896:	85da                	mv	a1,s6
    80003898:	8556                	mv	a0,s5
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	db4080e7          	jalr	-588(ra) # 8000364e <iget>
}
    800038a2:	60a6                	ld	ra,72(sp)
    800038a4:	6406                	ld	s0,64(sp)
    800038a6:	74e2                	ld	s1,56(sp)
    800038a8:	7942                	ld	s2,48(sp)
    800038aa:	79a2                	ld	s3,40(sp)
    800038ac:	7a02                	ld	s4,32(sp)
    800038ae:	6ae2                	ld	s5,24(sp)
    800038b0:	6b42                	ld	s6,16(sp)
    800038b2:	6ba2                	ld	s7,8(sp)
    800038b4:	6161                	addi	sp,sp,80
    800038b6:	8082                	ret

00000000800038b8 <iupdate>:
{
    800038b8:	1101                	addi	sp,sp,-32
    800038ba:	ec06                	sd	ra,24(sp)
    800038bc:	e822                	sd	s0,16(sp)
    800038be:	e426                	sd	s1,8(sp)
    800038c0:	e04a                	sd	s2,0(sp)
    800038c2:	1000                	addi	s0,sp,32
    800038c4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038c6:	415c                	lw	a5,4(a0)
    800038c8:	0047d79b          	srliw	a5,a5,0x4
    800038cc:	00032597          	auipc	a1,0x32
    800038d0:	c445a583          	lw	a1,-956(a1) # 80035510 <sb+0x18>
    800038d4:	9dbd                	addw	a1,a1,a5
    800038d6:	4108                	lw	a0,0(a0)
    800038d8:	00000097          	auipc	ra,0x0
    800038dc:	8a8080e7          	jalr	-1880(ra) # 80003180 <bread>
    800038e0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038e2:	06050793          	addi	a5,a0,96
    800038e6:	40c8                	lw	a0,4(s1)
    800038e8:	893d                	andi	a0,a0,15
    800038ea:	051a                	slli	a0,a0,0x6
    800038ec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038ee:	04c49703          	lh	a4,76(s1)
    800038f2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038f6:	04e49703          	lh	a4,78(s1)
    800038fa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038fe:	05049703          	lh	a4,80(s1)
    80003902:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003906:	05249703          	lh	a4,82(s1)
    8000390a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000390e:	48f8                	lw	a4,84(s1)
    80003910:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003912:	03400613          	li	a2,52
    80003916:	05848593          	addi	a1,s1,88
    8000391a:	0531                	addi	a0,a0,12
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	5b6080e7          	jalr	1462(ra) # 80000ed2 <memmove>
  log_write(bp);
    80003924:	854a                	mv	a0,s2
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	bf4080e7          	jalr	-1036(ra) # 8000451a <log_write>
  brelse(bp);
    8000392e:	854a                	mv	a0,s2
    80003930:	00000097          	auipc	ra,0x0
    80003934:	980080e7          	jalr	-1664(ra) # 800032b0 <brelse>
}
    80003938:	60e2                	ld	ra,24(sp)
    8000393a:	6442                	ld	s0,16(sp)
    8000393c:	64a2                	ld	s1,8(sp)
    8000393e:	6902                	ld	s2,0(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <idup>:
{
    80003944:	1101                	addi	sp,sp,-32
    80003946:	ec06                	sd	ra,24(sp)
    80003948:	e822                	sd	s0,16(sp)
    8000394a:	e426                	sd	s1,8(sp)
    8000394c:	1000                	addi	s0,sp,32
    8000394e:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003950:	00032517          	auipc	a0,0x32
    80003954:	bc850513          	addi	a0,a0,-1080 # 80035518 <icache>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	23a080e7          	jalr	570(ra) # 80000b92 <acquire>
  ip->ref++;
    80003960:	449c                	lw	a5,8(s1)
    80003962:	2785                	addiw	a5,a5,1
    80003964:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003966:	00032517          	auipc	a0,0x32
    8000396a:	bb250513          	addi	a0,a0,-1102 # 80035518 <icache>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	2f4080e7          	jalr	756(ra) # 80000c62 <release>
}
    80003976:	8526                	mv	a0,s1
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret

0000000080003982 <ilock>:
{
    80003982:	1101                	addi	sp,sp,-32
    80003984:	ec06                	sd	ra,24(sp)
    80003986:	e822                	sd	s0,16(sp)
    80003988:	e426                	sd	s1,8(sp)
    8000398a:	e04a                	sd	s2,0(sp)
    8000398c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000398e:	c115                	beqz	a0,800039b2 <ilock+0x30>
    80003990:	84aa                	mv	s1,a0
    80003992:	451c                	lw	a5,8(a0)
    80003994:	00f05f63          	blez	a5,800039b2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003998:	0541                	addi	a0,a0,16
    8000399a:	00001097          	auipc	ra,0x1
    8000399e:	ca0080e7          	jalr	-864(ra) # 8000463a <acquiresleep>
  if(ip->valid == 0){
    800039a2:	44bc                	lw	a5,72(s1)
    800039a4:	cf99                	beqz	a5,800039c2 <ilock+0x40>
}
    800039a6:	60e2                	ld	ra,24(sp)
    800039a8:	6442                	ld	s0,16(sp)
    800039aa:	64a2                	ld	s1,8(sp)
    800039ac:	6902                	ld	s2,0(sp)
    800039ae:	6105                	addi	sp,sp,32
    800039b0:	8082                	ret
    panic("ilock");
    800039b2:	00006517          	auipc	a0,0x6
    800039b6:	1fe50513          	addi	a0,a0,510 # 80009bb0 <syscalls+0x190>
    800039ba:	ffffd097          	auipc	ra,0xffffd
    800039be:	baa080e7          	jalr	-1110(ra) # 80000564 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039c2:	40dc                	lw	a5,4(s1)
    800039c4:	0047d79b          	srliw	a5,a5,0x4
    800039c8:	00032597          	auipc	a1,0x32
    800039cc:	b485a583          	lw	a1,-1208(a1) # 80035510 <sb+0x18>
    800039d0:	9dbd                	addw	a1,a1,a5
    800039d2:	4088                	lw	a0,0(s1)
    800039d4:	fffff097          	auipc	ra,0xfffff
    800039d8:	7ac080e7          	jalr	1964(ra) # 80003180 <bread>
    800039dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039de:	06050593          	addi	a1,a0,96
    800039e2:	40dc                	lw	a5,4(s1)
    800039e4:	8bbd                	andi	a5,a5,15
    800039e6:	079a                	slli	a5,a5,0x6
    800039e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039ea:	00059783          	lh	a5,0(a1)
    800039ee:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    800039f2:	00259783          	lh	a5,2(a1)
    800039f6:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800039fa:	00459783          	lh	a5,4(a1)
    800039fe:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a02:	00659783          	lh	a5,6(a1)
    80003a06:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a0a:	459c                	lw	a5,8(a1)
    80003a0c:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a0e:	03400613          	li	a2,52
    80003a12:	05b1                	addi	a1,a1,12
    80003a14:	05848513          	addi	a0,s1,88
    80003a18:	ffffd097          	auipc	ra,0xffffd
    80003a1c:	4ba080e7          	jalr	1210(ra) # 80000ed2 <memmove>
    brelse(bp);
    80003a20:	854a                	mv	a0,s2
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	88e080e7          	jalr	-1906(ra) # 800032b0 <brelse>
    ip->valid = 1;
    80003a2a:	4785                	li	a5,1
    80003a2c:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003a2e:	04c49783          	lh	a5,76(s1)
    80003a32:	fbb5                	bnez	a5,800039a6 <ilock+0x24>
      panic("ilock: no type");
    80003a34:	00006517          	auipc	a0,0x6
    80003a38:	18450513          	addi	a0,a0,388 # 80009bb8 <syscalls+0x198>
    80003a3c:	ffffd097          	auipc	ra,0xffffd
    80003a40:	b28080e7          	jalr	-1240(ra) # 80000564 <panic>

0000000080003a44 <iunlock>:
{
    80003a44:	1101                	addi	sp,sp,-32
    80003a46:	ec06                	sd	ra,24(sp)
    80003a48:	e822                	sd	s0,16(sp)
    80003a4a:	e426                	sd	s1,8(sp)
    80003a4c:	e04a                	sd	s2,0(sp)
    80003a4e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a50:	c905                	beqz	a0,80003a80 <iunlock+0x3c>
    80003a52:	84aa                	mv	s1,a0
    80003a54:	01050913          	addi	s2,a0,16
    80003a58:	854a                	mv	a0,s2
    80003a5a:	00001097          	auipc	ra,0x1
    80003a5e:	c7a080e7          	jalr	-902(ra) # 800046d4 <holdingsleep>
    80003a62:	cd19                	beqz	a0,80003a80 <iunlock+0x3c>
    80003a64:	449c                	lw	a5,8(s1)
    80003a66:	00f05d63          	blez	a5,80003a80 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00001097          	auipc	ra,0x1
    80003a70:	c24080e7          	jalr	-988(ra) # 80004690 <releasesleep>
}
    80003a74:	60e2                	ld	ra,24(sp)
    80003a76:	6442                	ld	s0,16(sp)
    80003a78:	64a2                	ld	s1,8(sp)
    80003a7a:	6902                	ld	s2,0(sp)
    80003a7c:	6105                	addi	sp,sp,32
    80003a7e:	8082                	ret
    panic("iunlock");
    80003a80:	00006517          	auipc	a0,0x6
    80003a84:	14850513          	addi	a0,a0,328 # 80009bc8 <syscalls+0x1a8>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	adc080e7          	jalr	-1316(ra) # 80000564 <panic>

0000000080003a90 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	e052                	sd	s4,0(sp)
    80003a9e:	1800                	addi	s0,sp,48
    80003aa0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aa2:	05850493          	addi	s1,a0,88
    80003aa6:	08850913          	addi	s2,a0,136
    80003aaa:	a021                	j	80003ab2 <itrunc+0x22>
    80003aac:	0491                	addi	s1,s1,4
    80003aae:	01248d63          	beq	s1,s2,80003ac8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003ab2:	408c                	lw	a1,0(s1)
    80003ab4:	dde5                	beqz	a1,80003aac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ab6:	0009a503          	lw	a0,0(s3)
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	90c080e7          	jalr	-1780(ra) # 800033c6 <bfree>
      ip->addrs[i] = 0;
    80003ac2:	0004a023          	sw	zero,0(s1)
    80003ac6:	b7dd                	j	80003aac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ac8:	0889a583          	lw	a1,136(s3)
    80003acc:	e185                	bnez	a1,80003aec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ace:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003ad2:	854e                	mv	a0,s3
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	de4080e7          	jalr	-540(ra) # 800038b8 <iupdate>
}
    80003adc:	70a2                	ld	ra,40(sp)
    80003ade:	7402                	ld	s0,32(sp)
    80003ae0:	64e2                	ld	s1,24(sp)
    80003ae2:	6942                	ld	s2,16(sp)
    80003ae4:	69a2                	ld	s3,8(sp)
    80003ae6:	6a02                	ld	s4,0(sp)
    80003ae8:	6145                	addi	sp,sp,48
    80003aea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003aec:	0009a503          	lw	a0,0(s3)
    80003af0:	fffff097          	auipc	ra,0xfffff
    80003af4:	690080e7          	jalr	1680(ra) # 80003180 <bread>
    80003af8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003afa:	06050493          	addi	s1,a0,96
    80003afe:	46050913          	addi	s2,a0,1120
    80003b02:	a021                	j	80003b0a <itrunc+0x7a>
    80003b04:	0491                	addi	s1,s1,4
    80003b06:	01248b63          	beq	s1,s2,80003b1c <itrunc+0x8c>
      if(a[j])
    80003b0a:	408c                	lw	a1,0(s1)
    80003b0c:	dde5                	beqz	a1,80003b04 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b0e:	0009a503          	lw	a0,0(s3)
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	8b4080e7          	jalr	-1868(ra) # 800033c6 <bfree>
    80003b1a:	b7ed                	j	80003b04 <itrunc+0x74>
    brelse(bp);
    80003b1c:	8552                	mv	a0,s4
    80003b1e:	fffff097          	auipc	ra,0xfffff
    80003b22:	792080e7          	jalr	1938(ra) # 800032b0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b26:	0889a583          	lw	a1,136(s3)
    80003b2a:	0009a503          	lw	a0,0(s3)
    80003b2e:	00000097          	auipc	ra,0x0
    80003b32:	898080e7          	jalr	-1896(ra) # 800033c6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b36:	0809a423          	sw	zero,136(s3)
    80003b3a:	bf51                	j	80003ace <itrunc+0x3e>

0000000080003b3c <iput>:
{
    80003b3c:	1101                	addi	sp,sp,-32
    80003b3e:	ec06                	sd	ra,24(sp)
    80003b40:	e822                	sd	s0,16(sp)
    80003b42:	e426                	sd	s1,8(sp)
    80003b44:	e04a                	sd	s2,0(sp)
    80003b46:	1000                	addi	s0,sp,32
    80003b48:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003b4a:	00032517          	auipc	a0,0x32
    80003b4e:	9ce50513          	addi	a0,a0,-1586 # 80035518 <icache>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	040080e7          	jalr	64(ra) # 80000b92 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b5a:	4498                	lw	a4,8(s1)
    80003b5c:	4785                	li	a5,1
    80003b5e:	02f70363          	beq	a4,a5,80003b84 <iput+0x48>
  ip->ref--;
    80003b62:	449c                	lw	a5,8(s1)
    80003b64:	37fd                	addiw	a5,a5,-1
    80003b66:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003b68:	00032517          	auipc	a0,0x32
    80003b6c:	9b050513          	addi	a0,a0,-1616 # 80035518 <icache>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	0f2080e7          	jalr	242(ra) # 80000c62 <release>
}
    80003b78:	60e2                	ld	ra,24(sp)
    80003b7a:	6442                	ld	s0,16(sp)
    80003b7c:	64a2                	ld	s1,8(sp)
    80003b7e:	6902                	ld	s2,0(sp)
    80003b80:	6105                	addi	sp,sp,32
    80003b82:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b84:	44bc                	lw	a5,72(s1)
    80003b86:	dff1                	beqz	a5,80003b62 <iput+0x26>
    80003b88:	05249783          	lh	a5,82(s1)
    80003b8c:	fbf9                	bnez	a5,80003b62 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b8e:	01048913          	addi	s2,s1,16
    80003b92:	854a                	mv	a0,s2
    80003b94:	00001097          	auipc	ra,0x1
    80003b98:	aa6080e7          	jalr	-1370(ra) # 8000463a <acquiresleep>
    release(&icache.lock);
    80003b9c:	00032517          	auipc	a0,0x32
    80003ba0:	97c50513          	addi	a0,a0,-1668 # 80035518 <icache>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	0be080e7          	jalr	190(ra) # 80000c62 <release>
    itrunc(ip);
    80003bac:	8526                	mv	a0,s1
    80003bae:	00000097          	auipc	ra,0x0
    80003bb2:	ee2080e7          	jalr	-286(ra) # 80003a90 <itrunc>
    ip->type = 0;
    80003bb6:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003bba:	8526                	mv	a0,s1
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	cfc080e7          	jalr	-772(ra) # 800038b8 <iupdate>
    ip->valid = 0;
    80003bc4:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003bc8:	854a                	mv	a0,s2
    80003bca:	00001097          	auipc	ra,0x1
    80003bce:	ac6080e7          	jalr	-1338(ra) # 80004690 <releasesleep>
    acquire(&icache.lock);
    80003bd2:	00032517          	auipc	a0,0x32
    80003bd6:	94650513          	addi	a0,a0,-1722 # 80035518 <icache>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	fb8080e7          	jalr	-72(ra) # 80000b92 <acquire>
    80003be2:	b741                	j	80003b62 <iput+0x26>

0000000080003be4 <iunlockput>:
{
    80003be4:	1101                	addi	sp,sp,-32
    80003be6:	ec06                	sd	ra,24(sp)
    80003be8:	e822                	sd	s0,16(sp)
    80003bea:	e426                	sd	s1,8(sp)
    80003bec:	1000                	addi	s0,sp,32
    80003bee:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bf0:	00000097          	auipc	ra,0x0
    80003bf4:	e54080e7          	jalr	-428(ra) # 80003a44 <iunlock>
  iput(ip);
    80003bf8:	8526                	mv	a0,s1
    80003bfa:	00000097          	auipc	ra,0x0
    80003bfe:	f42080e7          	jalr	-190(ra) # 80003b3c <iput>
}
    80003c02:	60e2                	ld	ra,24(sp)
    80003c04:	6442                	ld	s0,16(sp)
    80003c06:	64a2                	ld	s1,8(sp)
    80003c08:	6105                	addi	sp,sp,32
    80003c0a:	8082                	ret

0000000080003c0c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c0c:	1141                	addi	sp,sp,-16
    80003c0e:	e422                	sd	s0,8(sp)
    80003c10:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c12:	411c                	lw	a5,0(a0)
    80003c14:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c16:	415c                	lw	a5,4(a0)
    80003c18:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c1a:	04c51783          	lh	a5,76(a0)
    80003c1e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c22:	05251783          	lh	a5,82(a0)
    80003c26:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c2a:	05456783          	lwu	a5,84(a0)
    80003c2e:	e99c                	sd	a5,16(a1)
}
    80003c30:	6422                	ld	s0,8(sp)
    80003c32:	0141                	addi	sp,sp,16
    80003c34:	8082                	ret

0000000080003c36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c36:	497c                	lw	a5,84(a0)
    80003c38:	0ed7e963          	bltu	a5,a3,80003d2a <readi+0xf4>
{
    80003c3c:	7159                	addi	sp,sp,-112
    80003c3e:	f486                	sd	ra,104(sp)
    80003c40:	f0a2                	sd	s0,96(sp)
    80003c42:	eca6                	sd	s1,88(sp)
    80003c44:	e8ca                	sd	s2,80(sp)
    80003c46:	e4ce                	sd	s3,72(sp)
    80003c48:	e0d2                	sd	s4,64(sp)
    80003c4a:	fc56                	sd	s5,56(sp)
    80003c4c:	f85a                	sd	s6,48(sp)
    80003c4e:	f45e                	sd	s7,40(sp)
    80003c50:	f062                	sd	s8,32(sp)
    80003c52:	ec66                	sd	s9,24(sp)
    80003c54:	e86a                	sd	s10,16(sp)
    80003c56:	e46e                	sd	s11,8(sp)
    80003c58:	1880                	addi	s0,sp,112
    80003c5a:	8baa                	mv	s7,a0
    80003c5c:	8c2e                	mv	s8,a1
    80003c5e:	8ab2                	mv	s5,a2
    80003c60:	84b6                	mv	s1,a3
    80003c62:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c64:	9f35                	addw	a4,a4,a3
    return 0;
    80003c66:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c68:	0ad76063          	bltu	a4,a3,80003d08 <readi+0xd2>
  if(off + n > ip->size)
    80003c6c:	00e7f463          	bgeu	a5,a4,80003c74 <readi+0x3e>
    n = ip->size - off;
    80003c70:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c74:	0a0b0963          	beqz	s6,80003d26 <readi+0xf0>
    80003c78:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c7a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c7e:	5cfd                	li	s9,-1
    80003c80:	a82d                	j	80003cba <readi+0x84>
    80003c82:	020a1d93          	slli	s11,s4,0x20
    80003c86:	020ddd93          	srli	s11,s11,0x20
    80003c8a:	06090793          	addi	a5,s2,96
    80003c8e:	86ee                	mv	a3,s11
    80003c90:	963e                	add	a2,a2,a5
    80003c92:	85d6                	mv	a1,s5
    80003c94:	8562                	mv	a0,s8
    80003c96:	fffff097          	auipc	ra,0xfffff
    80003c9a:	a6c080e7          	jalr	-1428(ra) # 80002702 <either_copyout>
    80003c9e:	05950d63          	beq	a0,s9,80003cf8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ca2:	854a                	mv	a0,s2
    80003ca4:	fffff097          	auipc	ra,0xfffff
    80003ca8:	60c080e7          	jalr	1548(ra) # 800032b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cac:	013a09bb          	addw	s3,s4,s3
    80003cb0:	009a04bb          	addw	s1,s4,s1
    80003cb4:	9aee                	add	s5,s5,s11
    80003cb6:	0569f763          	bgeu	s3,s6,80003d04 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cba:	000ba903          	lw	s2,0(s7)
    80003cbe:	00a4d59b          	srliw	a1,s1,0xa
    80003cc2:	855e                	mv	a0,s7
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	8b0080e7          	jalr	-1872(ra) # 80003574 <bmap>
    80003ccc:	0005059b          	sext.w	a1,a0
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	fffff097          	auipc	ra,0xfffff
    80003cd6:	4ae080e7          	jalr	1198(ra) # 80003180 <bread>
    80003cda:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cdc:	3ff4f613          	andi	a2,s1,1023
    80003ce0:	40cd07bb          	subw	a5,s10,a2
    80003ce4:	413b073b          	subw	a4,s6,s3
    80003ce8:	8a3e                	mv	s4,a5
    80003cea:	2781                	sext.w	a5,a5
    80003cec:	0007069b          	sext.w	a3,a4
    80003cf0:	f8f6f9e3          	bgeu	a3,a5,80003c82 <readi+0x4c>
    80003cf4:	8a3a                	mv	s4,a4
    80003cf6:	b771                	j	80003c82 <readi+0x4c>
      brelse(bp);
    80003cf8:	854a                	mv	a0,s2
    80003cfa:	fffff097          	auipc	ra,0xfffff
    80003cfe:	5b6080e7          	jalr	1462(ra) # 800032b0 <brelse>
      tot = -1;
    80003d02:	59fd                	li	s3,-1
  }
  return tot;
    80003d04:	0009851b          	sext.w	a0,s3
}
    80003d08:	70a6                	ld	ra,104(sp)
    80003d0a:	7406                	ld	s0,96(sp)
    80003d0c:	64e6                	ld	s1,88(sp)
    80003d0e:	6946                	ld	s2,80(sp)
    80003d10:	69a6                	ld	s3,72(sp)
    80003d12:	6a06                	ld	s4,64(sp)
    80003d14:	7ae2                	ld	s5,56(sp)
    80003d16:	7b42                	ld	s6,48(sp)
    80003d18:	7ba2                	ld	s7,40(sp)
    80003d1a:	7c02                	ld	s8,32(sp)
    80003d1c:	6ce2                	ld	s9,24(sp)
    80003d1e:	6d42                	ld	s10,16(sp)
    80003d20:	6da2                	ld	s11,8(sp)
    80003d22:	6165                	addi	sp,sp,112
    80003d24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d26:	89da                	mv	s3,s6
    80003d28:	bff1                	j	80003d04 <readi+0xce>
    return 0;
    80003d2a:	4501                	li	a0,0
}
    80003d2c:	8082                	ret

0000000080003d2e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d2e:	497c                	lw	a5,84(a0)
    80003d30:	10d7e863          	bltu	a5,a3,80003e40 <writei+0x112>
{
    80003d34:	7159                	addi	sp,sp,-112
    80003d36:	f486                	sd	ra,104(sp)
    80003d38:	f0a2                	sd	s0,96(sp)
    80003d3a:	eca6                	sd	s1,88(sp)
    80003d3c:	e8ca                	sd	s2,80(sp)
    80003d3e:	e4ce                	sd	s3,72(sp)
    80003d40:	e0d2                	sd	s4,64(sp)
    80003d42:	fc56                	sd	s5,56(sp)
    80003d44:	f85a                	sd	s6,48(sp)
    80003d46:	f45e                	sd	s7,40(sp)
    80003d48:	f062                	sd	s8,32(sp)
    80003d4a:	ec66                	sd	s9,24(sp)
    80003d4c:	e86a                	sd	s10,16(sp)
    80003d4e:	e46e                	sd	s11,8(sp)
    80003d50:	1880                	addi	s0,sp,112
    80003d52:	8b2a                	mv	s6,a0
    80003d54:	8c2e                	mv	s8,a1
    80003d56:	8ab2                	mv	s5,a2
    80003d58:	8936                	mv	s2,a3
    80003d5a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003d5c:	00e687bb          	addw	a5,a3,a4
    80003d60:	0ed7e263          	bltu	a5,a3,80003e44 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d64:	00043737          	lui	a4,0x43
    80003d68:	0ef76063          	bltu	a4,a5,80003e48 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d6c:	0c0b8863          	beqz	s7,80003e3c <writei+0x10e>
    80003d70:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d72:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d76:	5cfd                	li	s9,-1
    80003d78:	a091                	j	80003dbc <writei+0x8e>
    80003d7a:	02099d93          	slli	s11,s3,0x20
    80003d7e:	020ddd93          	srli	s11,s11,0x20
    80003d82:	06048793          	addi	a5,s1,96
    80003d86:	86ee                	mv	a3,s11
    80003d88:	8656                	mv	a2,s5
    80003d8a:	85e2                	mv	a1,s8
    80003d8c:	953e                	add	a0,a0,a5
    80003d8e:	fffff097          	auipc	ra,0xfffff
    80003d92:	9ca080e7          	jalr	-1590(ra) # 80002758 <either_copyin>
    80003d96:	07950263          	beq	a0,s9,80003dfa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	77e080e7          	jalr	1918(ra) # 8000451a <log_write>
    brelse(bp);
    80003da4:	8526                	mv	a0,s1
    80003da6:	fffff097          	auipc	ra,0xfffff
    80003daa:	50a080e7          	jalr	1290(ra) # 800032b0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dae:	01498a3b          	addw	s4,s3,s4
    80003db2:	0129893b          	addw	s2,s3,s2
    80003db6:	9aee                	add	s5,s5,s11
    80003db8:	057a7663          	bgeu	s4,s7,80003e04 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003dbc:	000b2483          	lw	s1,0(s6)
    80003dc0:	00a9559b          	srliw	a1,s2,0xa
    80003dc4:	855a                	mv	a0,s6
    80003dc6:	fffff097          	auipc	ra,0xfffff
    80003dca:	7ae080e7          	jalr	1966(ra) # 80003574 <bmap>
    80003dce:	0005059b          	sext.w	a1,a0
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	fffff097          	auipc	ra,0xfffff
    80003dd8:	3ac080e7          	jalr	940(ra) # 80003180 <bread>
    80003ddc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dde:	3ff97513          	andi	a0,s2,1023
    80003de2:	40ad07bb          	subw	a5,s10,a0
    80003de6:	414b873b          	subw	a4,s7,s4
    80003dea:	89be                	mv	s3,a5
    80003dec:	2781                	sext.w	a5,a5
    80003dee:	0007069b          	sext.w	a3,a4
    80003df2:	f8f6f4e3          	bgeu	a3,a5,80003d7a <writei+0x4c>
    80003df6:	89ba                	mv	s3,a4
    80003df8:	b749                	j	80003d7a <writei+0x4c>
      brelse(bp);
    80003dfa:	8526                	mv	a0,s1
    80003dfc:	fffff097          	auipc	ra,0xfffff
    80003e00:	4b4080e7          	jalr	1204(ra) # 800032b0 <brelse>
  }

  if(off > ip->size)
    80003e04:	054b2783          	lw	a5,84(s6)
    80003e08:	0127f463          	bgeu	a5,s2,80003e10 <writei+0xe2>
    ip->size = off;
    80003e0c:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e10:	855a                	mv	a0,s6
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	aa6080e7          	jalr	-1370(ra) # 800038b8 <iupdate>

  return tot;
    80003e1a:	000a051b          	sext.w	a0,s4
}
    80003e1e:	70a6                	ld	ra,104(sp)
    80003e20:	7406                	ld	s0,96(sp)
    80003e22:	64e6                	ld	s1,88(sp)
    80003e24:	6946                	ld	s2,80(sp)
    80003e26:	69a6                	ld	s3,72(sp)
    80003e28:	6a06                	ld	s4,64(sp)
    80003e2a:	7ae2                	ld	s5,56(sp)
    80003e2c:	7b42                	ld	s6,48(sp)
    80003e2e:	7ba2                	ld	s7,40(sp)
    80003e30:	7c02                	ld	s8,32(sp)
    80003e32:	6ce2                	ld	s9,24(sp)
    80003e34:	6d42                	ld	s10,16(sp)
    80003e36:	6da2                	ld	s11,8(sp)
    80003e38:	6165                	addi	sp,sp,112
    80003e3a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e3c:	8a5e                	mv	s4,s7
    80003e3e:	bfc9                	j	80003e10 <writei+0xe2>
    return -1;
    80003e40:	557d                	li	a0,-1
}
    80003e42:	8082                	ret
    return -1;
    80003e44:	557d                	li	a0,-1
    80003e46:	bfe1                	j	80003e1e <writei+0xf0>
    return -1;
    80003e48:	557d                	li	a0,-1
    80003e4a:	bfd1                	j	80003e1e <writei+0xf0>

0000000080003e4c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e4c:	1141                	addi	sp,sp,-16
    80003e4e:	e406                	sd	ra,8(sp)
    80003e50:	e022                	sd	s0,0(sp)
    80003e52:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e54:	4639                	li	a2,14
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	11c080e7          	jalr	284(ra) # 80000f72 <strncmp>
}
    80003e5e:	60a2                	ld	ra,8(sp)
    80003e60:	6402                	ld	s0,0(sp)
    80003e62:	0141                	addi	sp,sp,16
    80003e64:	8082                	ret

0000000080003e66 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e66:	7139                	addi	sp,sp,-64
    80003e68:	fc06                	sd	ra,56(sp)
    80003e6a:	f822                	sd	s0,48(sp)
    80003e6c:	f426                	sd	s1,40(sp)
    80003e6e:	f04a                	sd	s2,32(sp)
    80003e70:	ec4e                	sd	s3,24(sp)
    80003e72:	e852                	sd	s4,16(sp)
    80003e74:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e76:	04c51703          	lh	a4,76(a0)
    80003e7a:	4785                	li	a5,1
    80003e7c:	00f71a63          	bne	a4,a5,80003e90 <dirlookup+0x2a>
    80003e80:	892a                	mv	s2,a0
    80003e82:	89ae                	mv	s3,a1
    80003e84:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e86:	497c                	lw	a5,84(a0)
    80003e88:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e8a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e8c:	e79d                	bnez	a5,80003eba <dirlookup+0x54>
    80003e8e:	a8a5                	j	80003f06 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e90:	00006517          	auipc	a0,0x6
    80003e94:	d4050513          	addi	a0,a0,-704 # 80009bd0 <syscalls+0x1b0>
    80003e98:	ffffc097          	auipc	ra,0xffffc
    80003e9c:	6cc080e7          	jalr	1740(ra) # 80000564 <panic>
      panic("dirlookup read");
    80003ea0:	00006517          	auipc	a0,0x6
    80003ea4:	d4850513          	addi	a0,a0,-696 # 80009be8 <syscalls+0x1c8>
    80003ea8:	ffffc097          	auipc	ra,0xffffc
    80003eac:	6bc080e7          	jalr	1724(ra) # 80000564 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eb0:	24c1                	addiw	s1,s1,16
    80003eb2:	05492783          	lw	a5,84(s2)
    80003eb6:	04f4f763          	bgeu	s1,a5,80003f04 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eba:	4741                	li	a4,16
    80003ebc:	86a6                	mv	a3,s1
    80003ebe:	fc040613          	addi	a2,s0,-64
    80003ec2:	4581                	li	a1,0
    80003ec4:	854a                	mv	a0,s2
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	d70080e7          	jalr	-656(ra) # 80003c36 <readi>
    80003ece:	47c1                	li	a5,16
    80003ed0:	fcf518e3          	bne	a0,a5,80003ea0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ed4:	fc045783          	lhu	a5,-64(s0)
    80003ed8:	dfe1                	beqz	a5,80003eb0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eda:	fc240593          	addi	a1,s0,-62
    80003ede:	854e                	mv	a0,s3
    80003ee0:	00000097          	auipc	ra,0x0
    80003ee4:	f6c080e7          	jalr	-148(ra) # 80003e4c <namecmp>
    80003ee8:	f561                	bnez	a0,80003eb0 <dirlookup+0x4a>
      if(poff)
    80003eea:	000a0463          	beqz	s4,80003ef2 <dirlookup+0x8c>
        *poff = off;
    80003eee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ef2:	fc045583          	lhu	a1,-64(s0)
    80003ef6:	00092503          	lw	a0,0(s2)
    80003efa:	fffff097          	auipc	ra,0xfffff
    80003efe:	754080e7          	jalr	1876(ra) # 8000364e <iget>
    80003f02:	a011                	j	80003f06 <dirlookup+0xa0>
  return 0;
    80003f04:	4501                	li	a0,0
}
    80003f06:	70e2                	ld	ra,56(sp)
    80003f08:	7442                	ld	s0,48(sp)
    80003f0a:	74a2                	ld	s1,40(sp)
    80003f0c:	7902                	ld	s2,32(sp)
    80003f0e:	69e2                	ld	s3,24(sp)
    80003f10:	6a42                	ld	s4,16(sp)
    80003f12:	6121                	addi	sp,sp,64
    80003f14:	8082                	ret

0000000080003f16 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f16:	711d                	addi	sp,sp,-96
    80003f18:	ec86                	sd	ra,88(sp)
    80003f1a:	e8a2                	sd	s0,80(sp)
    80003f1c:	e4a6                	sd	s1,72(sp)
    80003f1e:	e0ca                	sd	s2,64(sp)
    80003f20:	fc4e                	sd	s3,56(sp)
    80003f22:	f852                	sd	s4,48(sp)
    80003f24:	f456                	sd	s5,40(sp)
    80003f26:	f05a                	sd	s6,32(sp)
    80003f28:	ec5e                	sd	s7,24(sp)
    80003f2a:	e862                	sd	s8,16(sp)
    80003f2c:	e466                	sd	s9,8(sp)
    80003f2e:	1080                	addi	s0,sp,96
    80003f30:	84aa                	mv	s1,a0
    80003f32:	8aae                	mv	s5,a1
    80003f34:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f36:	00054703          	lbu	a4,0(a0)
    80003f3a:	02f00793          	li	a5,47
    80003f3e:	02f70363          	beq	a4,a5,80003f64 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f42:	ffffe097          	auipc	ra,0xffffe
    80003f46:	c0e080e7          	jalr	-1010(ra) # 80001b50 <myproc>
    80003f4a:	15853503          	ld	a0,344(a0)
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	9f6080e7          	jalr	-1546(ra) # 80003944 <idup>
    80003f56:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f58:	02f00913          	li	s2,47
  len = path - s;
    80003f5c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f5e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f60:	4b85                	li	s7,1
    80003f62:	a865                	j	8000401a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f64:	4585                	li	a1,1
    80003f66:	4505                	li	a0,1
    80003f68:	fffff097          	auipc	ra,0xfffff
    80003f6c:	6e6080e7          	jalr	1766(ra) # 8000364e <iget>
    80003f70:	89aa                	mv	s3,a0
    80003f72:	b7dd                	j	80003f58 <namex+0x42>
      iunlockput(ip);
    80003f74:	854e                	mv	a0,s3
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	c6e080e7          	jalr	-914(ra) # 80003be4 <iunlockput>
      return 0;
    80003f7e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f80:	854e                	mv	a0,s3
    80003f82:	60e6                	ld	ra,88(sp)
    80003f84:	6446                	ld	s0,80(sp)
    80003f86:	64a6                	ld	s1,72(sp)
    80003f88:	6906                	ld	s2,64(sp)
    80003f8a:	79e2                	ld	s3,56(sp)
    80003f8c:	7a42                	ld	s4,48(sp)
    80003f8e:	7aa2                	ld	s5,40(sp)
    80003f90:	7b02                	ld	s6,32(sp)
    80003f92:	6be2                	ld	s7,24(sp)
    80003f94:	6c42                	ld	s8,16(sp)
    80003f96:	6ca2                	ld	s9,8(sp)
    80003f98:	6125                	addi	sp,sp,96
    80003f9a:	8082                	ret
      iunlock(ip);
    80003f9c:	854e                	mv	a0,s3
    80003f9e:	00000097          	auipc	ra,0x0
    80003fa2:	aa6080e7          	jalr	-1370(ra) # 80003a44 <iunlock>
      return ip;
    80003fa6:	bfe9                	j	80003f80 <namex+0x6a>
      iunlockput(ip);
    80003fa8:	854e                	mv	a0,s3
    80003faa:	00000097          	auipc	ra,0x0
    80003fae:	c3a080e7          	jalr	-966(ra) # 80003be4 <iunlockput>
      return 0;
    80003fb2:	89e6                	mv	s3,s9
    80003fb4:	b7f1                	j	80003f80 <namex+0x6a>
  len = path - s;
    80003fb6:	40b48633          	sub	a2,s1,a1
    80003fba:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fbe:	099c5463          	bge	s8,s9,80004046 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fc2:	4639                	li	a2,14
    80003fc4:	8552                	mv	a0,s4
    80003fc6:	ffffd097          	auipc	ra,0xffffd
    80003fca:	f0c080e7          	jalr	-244(ra) # 80000ed2 <memmove>
  while(*path == '/')
    80003fce:	0004c783          	lbu	a5,0(s1)
    80003fd2:	01279763          	bne	a5,s2,80003fe0 <namex+0xca>
    path++;
    80003fd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fd8:	0004c783          	lbu	a5,0(s1)
    80003fdc:	ff278de3          	beq	a5,s2,80003fd6 <namex+0xc0>
    ilock(ip);
    80003fe0:	854e                	mv	a0,s3
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	9a0080e7          	jalr	-1632(ra) # 80003982 <ilock>
    if(ip->type != T_DIR){
    80003fea:	04c99783          	lh	a5,76(s3)
    80003fee:	f97793e3          	bne	a5,s7,80003f74 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ff2:	000a8563          	beqz	s5,80003ffc <namex+0xe6>
    80003ff6:	0004c783          	lbu	a5,0(s1)
    80003ffa:	d3cd                	beqz	a5,80003f9c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ffc:	865a                	mv	a2,s6
    80003ffe:	85d2                	mv	a1,s4
    80004000:	854e                	mv	a0,s3
    80004002:	00000097          	auipc	ra,0x0
    80004006:	e64080e7          	jalr	-412(ra) # 80003e66 <dirlookup>
    8000400a:	8caa                	mv	s9,a0
    8000400c:	dd51                	beqz	a0,80003fa8 <namex+0x92>
    iunlockput(ip);
    8000400e:	854e                	mv	a0,s3
    80004010:	00000097          	auipc	ra,0x0
    80004014:	bd4080e7          	jalr	-1068(ra) # 80003be4 <iunlockput>
    ip = next;
    80004018:	89e6                	mv	s3,s9
  while(*path == '/')
    8000401a:	0004c783          	lbu	a5,0(s1)
    8000401e:	05279763          	bne	a5,s2,8000406c <namex+0x156>
    path++;
    80004022:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004024:	0004c783          	lbu	a5,0(s1)
    80004028:	ff278de3          	beq	a5,s2,80004022 <namex+0x10c>
  if(*path == 0)
    8000402c:	c79d                	beqz	a5,8000405a <namex+0x144>
    path++;
    8000402e:	85a6                	mv	a1,s1
  len = path - s;
    80004030:	8cda                	mv	s9,s6
    80004032:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004034:	01278963          	beq	a5,s2,80004046 <namex+0x130>
    80004038:	dfbd                	beqz	a5,80003fb6 <namex+0xa0>
    path++;
    8000403a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000403c:	0004c783          	lbu	a5,0(s1)
    80004040:	ff279ce3          	bne	a5,s2,80004038 <namex+0x122>
    80004044:	bf8d                	j	80003fb6 <namex+0xa0>
    memmove(name, s, len);
    80004046:	2601                	sext.w	a2,a2
    80004048:	8552                	mv	a0,s4
    8000404a:	ffffd097          	auipc	ra,0xffffd
    8000404e:	e88080e7          	jalr	-376(ra) # 80000ed2 <memmove>
    name[len] = 0;
    80004052:	9cd2                	add	s9,s9,s4
    80004054:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004058:	bf9d                	j	80003fce <namex+0xb8>
  if(nameiparent){
    8000405a:	f20a83e3          	beqz	s5,80003f80 <namex+0x6a>
    iput(ip);
    8000405e:	854e                	mv	a0,s3
    80004060:	00000097          	auipc	ra,0x0
    80004064:	adc080e7          	jalr	-1316(ra) # 80003b3c <iput>
    return 0;
    80004068:	4981                	li	s3,0
    8000406a:	bf19                	j	80003f80 <namex+0x6a>
  if(*path == 0)
    8000406c:	d7fd                	beqz	a5,8000405a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000406e:	0004c783          	lbu	a5,0(s1)
    80004072:	85a6                	mv	a1,s1
    80004074:	b7d1                	j	80004038 <namex+0x122>

0000000080004076 <dirlink>:
{
    80004076:	7139                	addi	sp,sp,-64
    80004078:	fc06                	sd	ra,56(sp)
    8000407a:	f822                	sd	s0,48(sp)
    8000407c:	f426                	sd	s1,40(sp)
    8000407e:	f04a                	sd	s2,32(sp)
    80004080:	ec4e                	sd	s3,24(sp)
    80004082:	e852                	sd	s4,16(sp)
    80004084:	0080                	addi	s0,sp,64
    80004086:	892a                	mv	s2,a0
    80004088:	8a2e                	mv	s4,a1
    8000408a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000408c:	4601                	li	a2,0
    8000408e:	00000097          	auipc	ra,0x0
    80004092:	dd8080e7          	jalr	-552(ra) # 80003e66 <dirlookup>
    80004096:	e93d                	bnez	a0,8000410c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004098:	05492483          	lw	s1,84(s2)
    8000409c:	c49d                	beqz	s1,800040ca <dirlink+0x54>
    8000409e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a0:	4741                	li	a4,16
    800040a2:	86a6                	mv	a3,s1
    800040a4:	fc040613          	addi	a2,s0,-64
    800040a8:	4581                	li	a1,0
    800040aa:	854a                	mv	a0,s2
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	b8a080e7          	jalr	-1142(ra) # 80003c36 <readi>
    800040b4:	47c1                	li	a5,16
    800040b6:	06f51163          	bne	a0,a5,80004118 <dirlink+0xa2>
    if(de.inum == 0)
    800040ba:	fc045783          	lhu	a5,-64(s0)
    800040be:	c791                	beqz	a5,800040ca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040c0:	24c1                	addiw	s1,s1,16
    800040c2:	05492783          	lw	a5,84(s2)
    800040c6:	fcf4ede3          	bltu	s1,a5,800040a0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040ca:	4639                	li	a2,14
    800040cc:	85d2                	mv	a1,s4
    800040ce:	fc240513          	addi	a0,s0,-62
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	edc080e7          	jalr	-292(ra) # 80000fae <strncpy>
  de.inum = inum;
    800040da:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040de:	4741                	li	a4,16
    800040e0:	86a6                	mv	a3,s1
    800040e2:	fc040613          	addi	a2,s0,-64
    800040e6:	4581                	li	a1,0
    800040e8:	854a                	mv	a0,s2
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	c44080e7          	jalr	-956(ra) # 80003d2e <writei>
    800040f2:	872a                	mv	a4,a0
    800040f4:	47c1                	li	a5,16
  return 0;
    800040f6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040f8:	02f71863          	bne	a4,a5,80004128 <dirlink+0xb2>
}
    800040fc:	70e2                	ld	ra,56(sp)
    800040fe:	7442                	ld	s0,48(sp)
    80004100:	74a2                	ld	s1,40(sp)
    80004102:	7902                	ld	s2,32(sp)
    80004104:	69e2                	ld	s3,24(sp)
    80004106:	6a42                	ld	s4,16(sp)
    80004108:	6121                	addi	sp,sp,64
    8000410a:	8082                	ret
    iput(ip);
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	a30080e7          	jalr	-1488(ra) # 80003b3c <iput>
    return -1;
    80004114:	557d                	li	a0,-1
    80004116:	b7dd                	j	800040fc <dirlink+0x86>
      panic("dirlink read");
    80004118:	00006517          	auipc	a0,0x6
    8000411c:	ae050513          	addi	a0,a0,-1312 # 80009bf8 <syscalls+0x1d8>
    80004120:	ffffc097          	auipc	ra,0xffffc
    80004124:	444080e7          	jalr	1092(ra) # 80000564 <panic>
    panic("dirlink");
    80004128:	00006517          	auipc	a0,0x6
    8000412c:	be050513          	addi	a0,a0,-1056 # 80009d08 <syscalls+0x2e8>
    80004130:	ffffc097          	auipc	ra,0xffffc
    80004134:	434080e7          	jalr	1076(ra) # 80000564 <panic>

0000000080004138 <namei>:

struct inode*
namei(char *path)
{
    80004138:	1101                	addi	sp,sp,-32
    8000413a:	ec06                	sd	ra,24(sp)
    8000413c:	e822                	sd	s0,16(sp)
    8000413e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004140:	fe040613          	addi	a2,s0,-32
    80004144:	4581                	li	a1,0
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	dd0080e7          	jalr	-560(ra) # 80003f16 <namex>
}
    8000414e:	60e2                	ld	ra,24(sp)
    80004150:	6442                	ld	s0,16(sp)
    80004152:	6105                	addi	sp,sp,32
    80004154:	8082                	ret

0000000080004156 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004156:	1141                	addi	sp,sp,-16
    80004158:	e406                	sd	ra,8(sp)
    8000415a:	e022                	sd	s0,0(sp)
    8000415c:	0800                	addi	s0,sp,16
    8000415e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004160:	4585                	li	a1,1
    80004162:	00000097          	auipc	ra,0x0
    80004166:	db4080e7          	jalr	-588(ra) # 80003f16 <namex>
}
    8000416a:	60a2                	ld	ra,8(sp)
    8000416c:	6402                	ld	s0,0(sp)
    8000416e:	0141                	addi	sp,sp,16
    80004170:	8082                	ret

0000000080004172 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004172:	1101                	addi	sp,sp,-32
    80004174:	ec06                	sd	ra,24(sp)
    80004176:	e822                	sd	s0,16(sp)
    80004178:	e426                	sd	s1,8(sp)
    8000417a:	e04a                	sd	s2,0(sp)
    8000417c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000417e:	00033917          	auipc	s2,0x33
    80004182:	fda90913          	addi	s2,s2,-38 # 80037158 <log>
    80004186:	02092583          	lw	a1,32(s2)
    8000418a:	03092503          	lw	a0,48(s2)
    8000418e:	fffff097          	auipc	ra,0xfffff
    80004192:	ff2080e7          	jalr	-14(ra) # 80003180 <bread>
    80004196:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004198:	03492683          	lw	a3,52(s2)
    8000419c:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000419e:	02d05763          	blez	a3,800041cc <write_head+0x5a>
    800041a2:	00033797          	auipc	a5,0x33
    800041a6:	fee78793          	addi	a5,a5,-18 # 80037190 <log+0x38>
    800041aa:	06450713          	addi	a4,a0,100
    800041ae:	36fd                	addiw	a3,a3,-1
    800041b0:	1682                	slli	a3,a3,0x20
    800041b2:	9281                	srli	a3,a3,0x20
    800041b4:	068a                	slli	a3,a3,0x2
    800041b6:	00033617          	auipc	a2,0x33
    800041ba:	fde60613          	addi	a2,a2,-34 # 80037194 <log+0x3c>
    800041be:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041c0:	4390                	lw	a2,0(a5)
    800041c2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041c4:	0791                	addi	a5,a5,4
    800041c6:	0711                	addi	a4,a4,4
    800041c8:	fed79ce3          	bne	a5,a3,800041c0 <write_head+0x4e>
  }
  bwrite(buf);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	0a4080e7          	jalr	164(ra) # 80003272 <bwrite>
  brelse(buf);
    800041d6:	8526                	mv	a0,s1
    800041d8:	fffff097          	auipc	ra,0xfffff
    800041dc:	0d8080e7          	jalr	216(ra) # 800032b0 <brelse>
}
    800041e0:	60e2                	ld	ra,24(sp)
    800041e2:	6442                	ld	s0,16(sp)
    800041e4:	64a2                	ld	s1,8(sp)
    800041e6:	6902                	ld	s2,0(sp)
    800041e8:	6105                	addi	sp,sp,32
    800041ea:	8082                	ret

00000000800041ec <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ec:	00033797          	auipc	a5,0x33
    800041f0:	fa07a783          	lw	a5,-96(a5) # 8003718c <log+0x34>
    800041f4:	0af05663          	blez	a5,800042a0 <install_trans+0xb4>
{
    800041f8:	7139                	addi	sp,sp,-64
    800041fa:	fc06                	sd	ra,56(sp)
    800041fc:	f822                	sd	s0,48(sp)
    800041fe:	f426                	sd	s1,40(sp)
    80004200:	f04a                	sd	s2,32(sp)
    80004202:	ec4e                	sd	s3,24(sp)
    80004204:	e852                	sd	s4,16(sp)
    80004206:	e456                	sd	s5,8(sp)
    80004208:	0080                	addi	s0,sp,64
    8000420a:	00033a97          	auipc	s5,0x33
    8000420e:	f86a8a93          	addi	s5,s5,-122 # 80037190 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004212:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004214:	00033997          	auipc	s3,0x33
    80004218:	f4498993          	addi	s3,s3,-188 # 80037158 <log>
    8000421c:	0209a583          	lw	a1,32(s3)
    80004220:	014585bb          	addw	a1,a1,s4
    80004224:	2585                	addiw	a1,a1,1
    80004226:	0309a503          	lw	a0,48(s3)
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	f56080e7          	jalr	-170(ra) # 80003180 <bread>
    80004232:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004234:	000aa583          	lw	a1,0(s5)
    80004238:	0309a503          	lw	a0,48(s3)
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	f44080e7          	jalr	-188(ra) # 80003180 <bread>
    80004244:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004246:	40000613          	li	a2,1024
    8000424a:	06090593          	addi	a1,s2,96
    8000424e:	06050513          	addi	a0,a0,96
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	c80080e7          	jalr	-896(ra) # 80000ed2 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000425a:	8526                	mv	a0,s1
    8000425c:	fffff097          	auipc	ra,0xfffff
    80004260:	016080e7          	jalr	22(ra) # 80003272 <bwrite>
    bunpin(dbuf);
    80004264:	8526                	mv	a0,s1
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	124080e7          	jalr	292(ra) # 8000338a <bunpin>
    brelse(lbuf);
    8000426e:	854a                	mv	a0,s2
    80004270:	fffff097          	auipc	ra,0xfffff
    80004274:	040080e7          	jalr	64(ra) # 800032b0 <brelse>
    brelse(dbuf);
    80004278:	8526                	mv	a0,s1
    8000427a:	fffff097          	auipc	ra,0xfffff
    8000427e:	036080e7          	jalr	54(ra) # 800032b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004282:	2a05                	addiw	s4,s4,1
    80004284:	0a91                	addi	s5,s5,4
    80004286:	0349a783          	lw	a5,52(s3)
    8000428a:	f8fa49e3          	blt	s4,a5,8000421c <install_trans+0x30>
}
    8000428e:	70e2                	ld	ra,56(sp)
    80004290:	7442                	ld	s0,48(sp)
    80004292:	74a2                	ld	s1,40(sp)
    80004294:	7902                	ld	s2,32(sp)
    80004296:	69e2                	ld	s3,24(sp)
    80004298:	6a42                	ld	s4,16(sp)
    8000429a:	6aa2                	ld	s5,8(sp)
    8000429c:	6121                	addi	sp,sp,64
    8000429e:	8082                	ret
    800042a0:	8082                	ret

00000000800042a2 <initlog>:
{
    800042a2:	7179                	addi	sp,sp,-48
    800042a4:	f406                	sd	ra,40(sp)
    800042a6:	f022                	sd	s0,32(sp)
    800042a8:	ec26                	sd	s1,24(sp)
    800042aa:	e84a                	sd	s2,16(sp)
    800042ac:	e44e                	sd	s3,8(sp)
    800042ae:	1800                	addi	s0,sp,48
    800042b0:	892a                	mv	s2,a0
    800042b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042b4:	00033497          	auipc	s1,0x33
    800042b8:	ea448493          	addi	s1,s1,-348 # 80037158 <log>
    800042bc:	00006597          	auipc	a1,0x6
    800042c0:	94c58593          	addi	a1,a1,-1716 # 80009c08 <syscalls+0x1e8>
    800042c4:	8526                	mv	a0,s1
    800042c6:	ffffc097          	auipc	ra,0xffffc
    800042ca:	7f6080e7          	jalr	2038(ra) # 80000abc <initlock>
  log.start = sb->logstart;
    800042ce:	0149a583          	lw	a1,20(s3)
    800042d2:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    800042d4:	0109a783          	lw	a5,16(s3)
    800042d8:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    800042da:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042de:	854a                	mv	a0,s2
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	ea0080e7          	jalr	-352(ra) # 80003180 <bread>
  log.lh.n = lh->n;
    800042e8:	5134                	lw	a3,96(a0)
    800042ea:	d8d4                	sw	a3,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ec:	02d05563          	blez	a3,80004316 <initlog+0x74>
    800042f0:	06450793          	addi	a5,a0,100
    800042f4:	00033717          	auipc	a4,0x33
    800042f8:	e9c70713          	addi	a4,a4,-356 # 80037190 <log+0x38>
    800042fc:	36fd                	addiw	a3,a3,-1
    800042fe:	1682                	slli	a3,a3,0x20
    80004300:	9281                	srli	a3,a3,0x20
    80004302:	068a                	slli	a3,a3,0x2
    80004304:	06850613          	addi	a2,a0,104
    80004308:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000430a:	4390                	lw	a2,0(a5)
    8000430c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000430e:	0791                	addi	a5,a5,4
    80004310:	0711                	addi	a4,a4,4
    80004312:	fed79ce3          	bne	a5,a3,8000430a <initlog+0x68>
  brelse(buf);
    80004316:	fffff097          	auipc	ra,0xfffff
    8000431a:	f9a080e7          	jalr	-102(ra) # 800032b0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000431e:	00000097          	auipc	ra,0x0
    80004322:	ece080e7          	jalr	-306(ra) # 800041ec <install_trans>
  log.lh.n = 0;
    80004326:	00033797          	auipc	a5,0x33
    8000432a:	e607a323          	sw	zero,-410(a5) # 8003718c <log+0x34>
  write_head(); // clear the log
    8000432e:	00000097          	auipc	ra,0x0
    80004332:	e44080e7          	jalr	-444(ra) # 80004172 <write_head>
}
    80004336:	70a2                	ld	ra,40(sp)
    80004338:	7402                	ld	s0,32(sp)
    8000433a:	64e2                	ld	s1,24(sp)
    8000433c:	6942                	ld	s2,16(sp)
    8000433e:	69a2                	ld	s3,8(sp)
    80004340:	6145                	addi	sp,sp,48
    80004342:	8082                	ret

0000000080004344 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	e04a                	sd	s2,0(sp)
    8000434e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004350:	00033517          	auipc	a0,0x33
    80004354:	e0850513          	addi	a0,a0,-504 # 80037158 <log>
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	83a080e7          	jalr	-1990(ra) # 80000b92 <acquire>
  while(1){
    if(log.committing){
    80004360:	00033497          	auipc	s1,0x33
    80004364:	df848493          	addi	s1,s1,-520 # 80037158 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004368:	4979                	li	s2,30
    8000436a:	a039                	j	80004378 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000436c:	85a6                	mv	a1,s1
    8000436e:	8526                	mv	a0,s1
    80004370:	ffffe097          	auipc	ra,0xffffe
    80004374:	130080e7          	jalr	304(ra) # 800024a0 <sleep>
    if(log.committing){
    80004378:	54dc                	lw	a5,44(s1)
    8000437a:	fbed                	bnez	a5,8000436c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000437c:	549c                	lw	a5,40(s1)
    8000437e:	0017871b          	addiw	a4,a5,1
    80004382:	0007069b          	sext.w	a3,a4
    80004386:	0027179b          	slliw	a5,a4,0x2
    8000438a:	9fb9                	addw	a5,a5,a4
    8000438c:	0017979b          	slliw	a5,a5,0x1
    80004390:	58d8                	lw	a4,52(s1)
    80004392:	9fb9                	addw	a5,a5,a4
    80004394:	00f95963          	bge	s2,a5,800043a6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004398:	85a6                	mv	a1,s1
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffe097          	auipc	ra,0xffffe
    800043a0:	104080e7          	jalr	260(ra) # 800024a0 <sleep>
    800043a4:	bfd1                	j	80004378 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800043a6:	00033517          	auipc	a0,0x33
    800043aa:	db250513          	addi	a0,a0,-590 # 80037158 <log>
    800043ae:	d514                	sw	a3,40(a0)
      release(&log.lock);
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	8b2080e7          	jalr	-1870(ra) # 80000c62 <release>
      break;
    }
  }
}
    800043b8:	60e2                	ld	ra,24(sp)
    800043ba:	6442                	ld	s0,16(sp)
    800043bc:	64a2                	ld	s1,8(sp)
    800043be:	6902                	ld	s2,0(sp)
    800043c0:	6105                	addi	sp,sp,32
    800043c2:	8082                	ret

00000000800043c4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043c4:	7139                	addi	sp,sp,-64
    800043c6:	fc06                	sd	ra,56(sp)
    800043c8:	f822                	sd	s0,48(sp)
    800043ca:	f426                	sd	s1,40(sp)
    800043cc:	f04a                	sd	s2,32(sp)
    800043ce:	ec4e                	sd	s3,24(sp)
    800043d0:	e852                	sd	s4,16(sp)
    800043d2:	e456                	sd	s5,8(sp)
    800043d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043d6:	00033497          	auipc	s1,0x33
    800043da:	d8248493          	addi	s1,s1,-638 # 80037158 <log>
    800043de:	8526                	mv	a0,s1
    800043e0:	ffffc097          	auipc	ra,0xffffc
    800043e4:	7b2080e7          	jalr	1970(ra) # 80000b92 <acquire>
  log.outstanding -= 1;
    800043e8:	549c                	lw	a5,40(s1)
    800043ea:	37fd                	addiw	a5,a5,-1
    800043ec:	0007891b          	sext.w	s2,a5
    800043f0:	d49c                	sw	a5,40(s1)
  if(log.committing)
    800043f2:	54dc                	lw	a5,44(s1)
    800043f4:	e7b9                	bnez	a5,80004442 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043f6:	04091e63          	bnez	s2,80004452 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043fa:	00033497          	auipc	s1,0x33
    800043fe:	d5e48493          	addi	s1,s1,-674 # 80037158 <log>
    80004402:	4785                	li	a5,1
    80004404:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004406:	8526                	mv	a0,s1
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	85a080e7          	jalr	-1958(ra) # 80000c62 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    80004410:	58dc                	lw	a5,52(s1)
    80004412:	06f04763          	bgtz	a5,80004480 <end_op+0xbc>
    acquire(&log.lock);
    80004416:	00033497          	auipc	s1,0x33
    8000441a:	d4248493          	addi	s1,s1,-702 # 80037158 <log>
    8000441e:	8526                	mv	a0,s1
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	772080e7          	jalr	1906(ra) # 80000b92 <acquire>
    log.committing = 0;
    80004428:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    8000442c:	8526                	mv	a0,s1
    8000442e:	ffffe097          	auipc	ra,0xffffe
    80004432:	1f2080e7          	jalr	498(ra) # 80002620 <wakeup>
    release(&log.lock);
    80004436:	8526                	mv	a0,s1
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	82a080e7          	jalr	-2006(ra) # 80000c62 <release>
}
    80004440:	a03d                	j	8000446e <end_op+0xaa>
    panic("log.committing");
    80004442:	00005517          	auipc	a0,0x5
    80004446:	7ce50513          	addi	a0,a0,1998 # 80009c10 <syscalls+0x1f0>
    8000444a:	ffffc097          	auipc	ra,0xffffc
    8000444e:	11a080e7          	jalr	282(ra) # 80000564 <panic>
    wakeup(&log);
    80004452:	00033497          	auipc	s1,0x33
    80004456:	d0648493          	addi	s1,s1,-762 # 80037158 <log>
    8000445a:	8526                	mv	a0,s1
    8000445c:	ffffe097          	auipc	ra,0xffffe
    80004460:	1c4080e7          	jalr	452(ra) # 80002620 <wakeup>
  release(&log.lock);
    80004464:	8526                	mv	a0,s1
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	7fc080e7          	jalr	2044(ra) # 80000c62 <release>
}
    8000446e:	70e2                	ld	ra,56(sp)
    80004470:	7442                	ld	s0,48(sp)
    80004472:	74a2                	ld	s1,40(sp)
    80004474:	7902                	ld	s2,32(sp)
    80004476:	69e2                	ld	s3,24(sp)
    80004478:	6a42                	ld	s4,16(sp)
    8000447a:	6aa2                	ld	s5,8(sp)
    8000447c:	6121                	addi	sp,sp,64
    8000447e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004480:	00033a97          	auipc	s5,0x33
    80004484:	d10a8a93          	addi	s5,s5,-752 # 80037190 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004488:	00033a17          	auipc	s4,0x33
    8000448c:	cd0a0a13          	addi	s4,s4,-816 # 80037158 <log>
    80004490:	020a2583          	lw	a1,32(s4)
    80004494:	012585bb          	addw	a1,a1,s2
    80004498:	2585                	addiw	a1,a1,1
    8000449a:	030a2503          	lw	a0,48(s4)
    8000449e:	fffff097          	auipc	ra,0xfffff
    800044a2:	ce2080e7          	jalr	-798(ra) # 80003180 <bread>
    800044a6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800044a8:	000aa583          	lw	a1,0(s5)
    800044ac:	030a2503          	lw	a0,48(s4)
    800044b0:	fffff097          	auipc	ra,0xfffff
    800044b4:	cd0080e7          	jalr	-816(ra) # 80003180 <bread>
    800044b8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044ba:	40000613          	li	a2,1024
    800044be:	06050593          	addi	a1,a0,96
    800044c2:	06048513          	addi	a0,s1,96
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	a0c080e7          	jalr	-1524(ra) # 80000ed2 <memmove>
    bwrite(to);  // write the log
    800044ce:	8526                	mv	a0,s1
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	da2080e7          	jalr	-606(ra) # 80003272 <bwrite>
    brelse(from);
    800044d8:	854e                	mv	a0,s3
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	dd6080e7          	jalr	-554(ra) # 800032b0 <brelse>
    brelse(to);
    800044e2:	8526                	mv	a0,s1
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	dcc080e7          	jalr	-564(ra) # 800032b0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ec:	2905                	addiw	s2,s2,1
    800044ee:	0a91                	addi	s5,s5,4
    800044f0:	034a2783          	lw	a5,52(s4)
    800044f4:	f8f94ee3          	blt	s2,a5,80004490 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	c7a080e7          	jalr	-902(ra) # 80004172 <write_head>
    install_trans(); // Now install writes to home locations
    80004500:	00000097          	auipc	ra,0x0
    80004504:	cec080e7          	jalr	-788(ra) # 800041ec <install_trans>
    log.lh.n = 0;
    80004508:	00033797          	auipc	a5,0x33
    8000450c:	c807a223          	sw	zero,-892(a5) # 8003718c <log+0x34>
    write_head();    // Erase the transaction from the log
    80004510:	00000097          	auipc	ra,0x0
    80004514:	c62080e7          	jalr	-926(ra) # 80004172 <write_head>
    80004518:	bdfd                	j	80004416 <end_op+0x52>

000000008000451a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000451a:	1101                	addi	sp,sp,-32
    8000451c:	ec06                	sd	ra,24(sp)
    8000451e:	e822                	sd	s0,16(sp)
    80004520:	e426                	sd	s1,8(sp)
    80004522:	e04a                	sd	s2,0(sp)
    80004524:	1000                	addi	s0,sp,32
    80004526:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004528:	00033917          	auipc	s2,0x33
    8000452c:	c3090913          	addi	s2,s2,-976 # 80037158 <log>
    80004530:	854a                	mv	a0,s2
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	660080e7          	jalr	1632(ra) # 80000b92 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000453a:	03492603          	lw	a2,52(s2)
    8000453e:	47f5                	li	a5,29
    80004540:	06c7c563          	blt	a5,a2,800045aa <log_write+0x90>
    80004544:	00033797          	auipc	a5,0x33
    80004548:	c387a783          	lw	a5,-968(a5) # 8003717c <log+0x24>
    8000454c:	37fd                	addiw	a5,a5,-1
    8000454e:	04f65e63          	bge	a2,a5,800045aa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004552:	00033797          	auipc	a5,0x33
    80004556:	c2e7a783          	lw	a5,-978(a5) # 80037180 <log+0x28>
    8000455a:	06f05063          	blez	a5,800045ba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000455e:	4781                	li	a5,0
    80004560:	06c05563          	blez	a2,800045ca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004564:	44cc                	lw	a1,12(s1)
    80004566:	00033717          	auipc	a4,0x33
    8000456a:	c2a70713          	addi	a4,a4,-982 # 80037190 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    8000456e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004570:	4314                	lw	a3,0(a4)
    80004572:	04b68c63          	beq	a3,a1,800045ca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004576:	2785                	addiw	a5,a5,1
    80004578:	0711                	addi	a4,a4,4
    8000457a:	fef61be3          	bne	a2,a5,80004570 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000457e:	0631                	addi	a2,a2,12
    80004580:	060a                	slli	a2,a2,0x2
    80004582:	00033797          	auipc	a5,0x33
    80004586:	bd678793          	addi	a5,a5,-1066 # 80037158 <log>
    8000458a:	963e                	add	a2,a2,a5
    8000458c:	44dc                	lw	a5,12(s1)
    8000458e:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004590:	8526                	mv	a0,s1
    80004592:	fffff097          	auipc	ra,0xfffff
    80004596:	dbc080e7          	jalr	-580(ra) # 8000334e <bpin>
    log.lh.n++;
    8000459a:	00033717          	auipc	a4,0x33
    8000459e:	bbe70713          	addi	a4,a4,-1090 # 80037158 <log>
    800045a2:	5b5c                	lw	a5,52(a4)
    800045a4:	2785                	addiw	a5,a5,1
    800045a6:	db5c                	sw	a5,52(a4)
    800045a8:	a835                	j	800045e4 <log_write+0xca>
    panic("too big a transaction");
    800045aa:	00005517          	auipc	a0,0x5
    800045ae:	67650513          	addi	a0,a0,1654 # 80009c20 <syscalls+0x200>
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	fb2080e7          	jalr	-78(ra) # 80000564 <panic>
    panic("log_write outside of trans");
    800045ba:	00005517          	auipc	a0,0x5
    800045be:	67e50513          	addi	a0,a0,1662 # 80009c38 <syscalls+0x218>
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	fa2080e7          	jalr	-94(ra) # 80000564 <panic>
  log.lh.block[i] = b->blockno;
    800045ca:	00c78713          	addi	a4,a5,12
    800045ce:	00271693          	slli	a3,a4,0x2
    800045d2:	00033717          	auipc	a4,0x33
    800045d6:	b8670713          	addi	a4,a4,-1146 # 80037158 <log>
    800045da:	9736                	add	a4,a4,a3
    800045dc:	44d4                	lw	a3,12(s1)
    800045de:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045e0:	faf608e3          	beq	a2,a5,80004590 <log_write+0x76>
  }
  release(&log.lock);
    800045e4:	00033517          	auipc	a0,0x33
    800045e8:	b7450513          	addi	a0,a0,-1164 # 80037158 <log>
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	676080e7          	jalr	1654(ra) # 80000c62 <release>
}
    800045f4:	60e2                	ld	ra,24(sp)
    800045f6:	6442                	ld	s0,16(sp)
    800045f8:	64a2                	ld	s1,8(sp)
    800045fa:	6902                	ld	s2,0(sp)
    800045fc:	6105                	addi	sp,sp,32
    800045fe:	8082                	ret

0000000080004600 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004600:	1101                	addi	sp,sp,-32
    80004602:	ec06                	sd	ra,24(sp)
    80004604:	e822                	sd	s0,16(sp)
    80004606:	e426                	sd	s1,8(sp)
    80004608:	e04a                	sd	s2,0(sp)
    8000460a:	1000                	addi	s0,sp,32
    8000460c:	84aa                	mv	s1,a0
    8000460e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004610:	00005597          	auipc	a1,0x5
    80004614:	64858593          	addi	a1,a1,1608 # 80009c58 <syscalls+0x238>
    80004618:	0521                	addi	a0,a0,8
    8000461a:	ffffc097          	auipc	ra,0xffffc
    8000461e:	4a2080e7          	jalr	1186(ra) # 80000abc <initlock>
  lk->name = name;
    80004622:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004626:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000462a:	0204a823          	sw	zero,48(s1)
}
    8000462e:	60e2                	ld	ra,24(sp)
    80004630:	6442                	ld	s0,16(sp)
    80004632:	64a2                	ld	s1,8(sp)
    80004634:	6902                	ld	s2,0(sp)
    80004636:	6105                	addi	sp,sp,32
    80004638:	8082                	ret

000000008000463a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000463a:	1101                	addi	sp,sp,-32
    8000463c:	ec06                	sd	ra,24(sp)
    8000463e:	e822                	sd	s0,16(sp)
    80004640:	e426                	sd	s1,8(sp)
    80004642:	e04a                	sd	s2,0(sp)
    80004644:	1000                	addi	s0,sp,32
    80004646:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004648:	00850913          	addi	s2,a0,8
    8000464c:	854a                	mv	a0,s2
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	544080e7          	jalr	1348(ra) # 80000b92 <acquire>
  while (lk->locked) {
    80004656:	409c                	lw	a5,0(s1)
    80004658:	cb89                	beqz	a5,8000466a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000465a:	85ca                	mv	a1,s2
    8000465c:	8526                	mv	a0,s1
    8000465e:	ffffe097          	auipc	ra,0xffffe
    80004662:	e42080e7          	jalr	-446(ra) # 800024a0 <sleep>
  while (lk->locked) {
    80004666:	409c                	lw	a5,0(s1)
    80004668:	fbed                	bnez	a5,8000465a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000466a:	4785                	li	a5,1
    8000466c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000466e:	ffffd097          	auipc	ra,0xffffd
    80004672:	4e2080e7          	jalr	1250(ra) # 80001b50 <myproc>
    80004676:	413c                	lw	a5,64(a0)
    80004678:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000467a:	854a                	mv	a0,s2
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	5e6080e7          	jalr	1510(ra) # 80000c62 <release>
}
    80004684:	60e2                	ld	ra,24(sp)
    80004686:	6442                	ld	s0,16(sp)
    80004688:	64a2                	ld	s1,8(sp)
    8000468a:	6902                	ld	s2,0(sp)
    8000468c:	6105                	addi	sp,sp,32
    8000468e:	8082                	ret

0000000080004690 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004690:	1101                	addi	sp,sp,-32
    80004692:	ec06                	sd	ra,24(sp)
    80004694:	e822                	sd	s0,16(sp)
    80004696:	e426                	sd	s1,8(sp)
    80004698:	e04a                	sd	s2,0(sp)
    8000469a:	1000                	addi	s0,sp,32
    8000469c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000469e:	00850913          	addi	s2,a0,8
    800046a2:	854a                	mv	a0,s2
    800046a4:	ffffc097          	auipc	ra,0xffffc
    800046a8:	4ee080e7          	jalr	1262(ra) # 80000b92 <acquire>
  lk->locked = 0;
    800046ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046b0:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800046b4:	8526                	mv	a0,s1
    800046b6:	ffffe097          	auipc	ra,0xffffe
    800046ba:	f6a080e7          	jalr	-150(ra) # 80002620 <wakeup>
  release(&lk->lk);
    800046be:	854a                	mv	a0,s2
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	5a2080e7          	jalr	1442(ra) # 80000c62 <release>
}
    800046c8:	60e2                	ld	ra,24(sp)
    800046ca:	6442                	ld	s0,16(sp)
    800046cc:	64a2                	ld	s1,8(sp)
    800046ce:	6902                	ld	s2,0(sp)
    800046d0:	6105                	addi	sp,sp,32
    800046d2:	8082                	ret

00000000800046d4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046d4:	7179                	addi	sp,sp,-48
    800046d6:	f406                	sd	ra,40(sp)
    800046d8:	f022                	sd	s0,32(sp)
    800046da:	ec26                	sd	s1,24(sp)
    800046dc:	e84a                	sd	s2,16(sp)
    800046de:	e44e                	sd	s3,8(sp)
    800046e0:	1800                	addi	s0,sp,48
    800046e2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046e4:	00850913          	addi	s2,a0,8
    800046e8:	854a                	mv	a0,s2
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	4a8080e7          	jalr	1192(ra) # 80000b92 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046f2:	409c                	lw	a5,0(s1)
    800046f4:	ef99                	bnez	a5,80004712 <holdingsleep+0x3e>
    800046f6:	4481                	li	s1,0
  release(&lk->lk);
    800046f8:	854a                	mv	a0,s2
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	568080e7          	jalr	1384(ra) # 80000c62 <release>
  return r;
}
    80004702:	8526                	mv	a0,s1
    80004704:	70a2                	ld	ra,40(sp)
    80004706:	7402                	ld	s0,32(sp)
    80004708:	64e2                	ld	s1,24(sp)
    8000470a:	6942                	ld	s2,16(sp)
    8000470c:	69a2                	ld	s3,8(sp)
    8000470e:	6145                	addi	sp,sp,48
    80004710:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004712:	0304a983          	lw	s3,48(s1)
    80004716:	ffffd097          	auipc	ra,0xffffd
    8000471a:	43a080e7          	jalr	1082(ra) # 80001b50 <myproc>
    8000471e:	4124                	lw	s1,64(a0)
    80004720:	413484b3          	sub	s1,s1,s3
    80004724:	0014b493          	seqz	s1,s1
    80004728:	bfc1                	j	800046f8 <holdingsleep+0x24>

000000008000472a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000472a:	1141                	addi	sp,sp,-16
    8000472c:	e406                	sd	ra,8(sp)
    8000472e:	e022                	sd	s0,0(sp)
    80004730:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004732:	00005597          	auipc	a1,0x5
    80004736:	53658593          	addi	a1,a1,1334 # 80009c68 <syscalls+0x248>
    8000473a:	00033517          	auipc	a0,0x33
    8000473e:	b6e50513          	addi	a0,a0,-1170 # 800372a8 <ftable>
    80004742:	ffffc097          	auipc	ra,0xffffc
    80004746:	37a080e7          	jalr	890(ra) # 80000abc <initlock>
}
    8000474a:	60a2                	ld	ra,8(sp)
    8000474c:	6402                	ld	s0,0(sp)
    8000474e:	0141                	addi	sp,sp,16
    80004750:	8082                	ret

0000000080004752 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004752:	1101                	addi	sp,sp,-32
    80004754:	ec06                	sd	ra,24(sp)
    80004756:	e822                	sd	s0,16(sp)
    80004758:	e426                	sd	s1,8(sp)
    8000475a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000475c:	00033517          	auipc	a0,0x33
    80004760:	b4c50513          	addi	a0,a0,-1204 # 800372a8 <ftable>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	42e080e7          	jalr	1070(ra) # 80000b92 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000476c:	00033497          	auipc	s1,0x33
    80004770:	b5c48493          	addi	s1,s1,-1188 # 800372c8 <ftable+0x20>
    80004774:	00034717          	auipc	a4,0x34
    80004778:	af470713          	addi	a4,a4,-1292 # 80038268 <disk>
    if(f->ref == 0){
    8000477c:	40dc                	lw	a5,4(s1)
    8000477e:	cf99                	beqz	a5,8000479c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004780:	02848493          	addi	s1,s1,40
    80004784:	fee49ce3          	bne	s1,a4,8000477c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004788:	00033517          	auipc	a0,0x33
    8000478c:	b2050513          	addi	a0,a0,-1248 # 800372a8 <ftable>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	4d2080e7          	jalr	1234(ra) # 80000c62 <release>
  return 0;
    80004798:	4481                	li	s1,0
    8000479a:	a819                	j	800047b0 <filealloc+0x5e>
      f->ref = 1;
    8000479c:	4785                	li	a5,1
    8000479e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047a0:	00033517          	auipc	a0,0x33
    800047a4:	b0850513          	addi	a0,a0,-1272 # 800372a8 <ftable>
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	4ba080e7          	jalr	1210(ra) # 80000c62 <release>
}
    800047b0:	8526                	mv	a0,s1
    800047b2:	60e2                	ld	ra,24(sp)
    800047b4:	6442                	ld	s0,16(sp)
    800047b6:	64a2                	ld	s1,8(sp)
    800047b8:	6105                	addi	sp,sp,32
    800047ba:	8082                	ret

00000000800047bc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047bc:	1101                	addi	sp,sp,-32
    800047be:	ec06                	sd	ra,24(sp)
    800047c0:	e822                	sd	s0,16(sp)
    800047c2:	e426                	sd	s1,8(sp)
    800047c4:	1000                	addi	s0,sp,32
    800047c6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047c8:	00033517          	auipc	a0,0x33
    800047cc:	ae050513          	addi	a0,a0,-1312 # 800372a8 <ftable>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	3c2080e7          	jalr	962(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    800047d8:	40dc                	lw	a5,4(s1)
    800047da:	02f05263          	blez	a5,800047fe <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047de:	2785                	addiw	a5,a5,1
    800047e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047e2:	00033517          	auipc	a0,0x33
    800047e6:	ac650513          	addi	a0,a0,-1338 # 800372a8 <ftable>
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	478080e7          	jalr	1144(ra) # 80000c62 <release>
  return f;
}
    800047f2:	8526                	mv	a0,s1
    800047f4:	60e2                	ld	ra,24(sp)
    800047f6:	6442                	ld	s0,16(sp)
    800047f8:	64a2                	ld	s1,8(sp)
    800047fa:	6105                	addi	sp,sp,32
    800047fc:	8082                	ret
    panic("filedup");
    800047fe:	00005517          	auipc	a0,0x5
    80004802:	47250513          	addi	a0,a0,1138 # 80009c70 <syscalls+0x250>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	d5e080e7          	jalr	-674(ra) # 80000564 <panic>

000000008000480e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000480e:	7139                	addi	sp,sp,-64
    80004810:	fc06                	sd	ra,56(sp)
    80004812:	f822                	sd	s0,48(sp)
    80004814:	f426                	sd	s1,40(sp)
    80004816:	f04a                	sd	s2,32(sp)
    80004818:	ec4e                	sd	s3,24(sp)
    8000481a:	e852                	sd	s4,16(sp)
    8000481c:	e456                	sd	s5,8(sp)
    8000481e:	0080                	addi	s0,sp,64
    80004820:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004822:	00033517          	auipc	a0,0x33
    80004826:	a8650513          	addi	a0,a0,-1402 # 800372a8 <ftable>
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	368080e7          	jalr	872(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    80004832:	40dc                	lw	a5,4(s1)
    80004834:	06f05163          	blez	a5,80004896 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004838:	37fd                	addiw	a5,a5,-1
    8000483a:	0007871b          	sext.w	a4,a5
    8000483e:	c0dc                	sw	a5,4(s1)
    80004840:	06e04363          	bgtz	a4,800048a6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004844:	0004a903          	lw	s2,0(s1)
    80004848:	0094ca83          	lbu	s5,9(s1)
    8000484c:	0104ba03          	ld	s4,16(s1)
    80004850:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004854:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004858:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000485c:	00033517          	auipc	a0,0x33
    80004860:	a4c50513          	addi	a0,a0,-1460 # 800372a8 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	3fe080e7          	jalr	1022(ra) # 80000c62 <release>

  if(ff.type == FD_PIPE){
    8000486c:	4785                	li	a5,1
    8000486e:	04f90d63          	beq	s2,a5,800048c8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004872:	3979                	addiw	s2,s2,-2
    80004874:	4785                	li	a5,1
    80004876:	0527e063          	bltu	a5,s2,800048b6 <fileclose+0xa8>
    begin_op();
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	aca080e7          	jalr	-1334(ra) # 80004344 <begin_op>
    iput(ff.ip);
    80004882:	854e                	mv	a0,s3
    80004884:	fffff097          	auipc	ra,0xfffff
    80004888:	2b8080e7          	jalr	696(ra) # 80003b3c <iput>
    end_op();
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	b38080e7          	jalr	-1224(ra) # 800043c4 <end_op>
    80004894:	a00d                	j	800048b6 <fileclose+0xa8>
    panic("fileclose");
    80004896:	00005517          	auipc	a0,0x5
    8000489a:	3e250513          	addi	a0,a0,994 # 80009c78 <syscalls+0x258>
    8000489e:	ffffc097          	auipc	ra,0xffffc
    800048a2:	cc6080e7          	jalr	-826(ra) # 80000564 <panic>
    release(&ftable.lock);
    800048a6:	00033517          	auipc	a0,0x33
    800048aa:	a0250513          	addi	a0,a0,-1534 # 800372a8 <ftable>
    800048ae:	ffffc097          	auipc	ra,0xffffc
    800048b2:	3b4080e7          	jalr	948(ra) # 80000c62 <release>
  }
}
    800048b6:	70e2                	ld	ra,56(sp)
    800048b8:	7442                	ld	s0,48(sp)
    800048ba:	74a2                	ld	s1,40(sp)
    800048bc:	7902                	ld	s2,32(sp)
    800048be:	69e2                	ld	s3,24(sp)
    800048c0:	6a42                	ld	s4,16(sp)
    800048c2:	6aa2                	ld	s5,8(sp)
    800048c4:	6121                	addi	sp,sp,64
    800048c6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048c8:	85d6                	mv	a1,s5
    800048ca:	8552                	mv	a0,s4
    800048cc:	00000097          	auipc	ra,0x0
    800048d0:	354080e7          	jalr	852(ra) # 80004c20 <pipeclose>
    800048d4:	b7cd                	j	800048b6 <fileclose+0xa8>

00000000800048d6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048d6:	715d                	addi	sp,sp,-80
    800048d8:	e486                	sd	ra,72(sp)
    800048da:	e0a2                	sd	s0,64(sp)
    800048dc:	fc26                	sd	s1,56(sp)
    800048de:	f84a                	sd	s2,48(sp)
    800048e0:	f44e                	sd	s3,40(sp)
    800048e2:	0880                	addi	s0,sp,80
    800048e4:	84aa                	mv	s1,a0
    800048e6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048e8:	ffffd097          	auipc	ra,0xffffd
    800048ec:	268080e7          	jalr	616(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048f0:	409c                	lw	a5,0(s1)
    800048f2:	37f9                	addiw	a5,a5,-2
    800048f4:	4705                	li	a4,1
    800048f6:	04f76763          	bltu	a4,a5,80004944 <filestat+0x6e>
    800048fa:	892a                	mv	s2,a0
    ilock(f->ip);
    800048fc:	6c88                	ld	a0,24(s1)
    800048fe:	fffff097          	auipc	ra,0xfffff
    80004902:	084080e7          	jalr	132(ra) # 80003982 <ilock>
    stati(f->ip, &st);
    80004906:	fb840593          	addi	a1,s0,-72
    8000490a:	6c88                	ld	a0,24(s1)
    8000490c:	fffff097          	auipc	ra,0xfffff
    80004910:	300080e7          	jalr	768(ra) # 80003c0c <stati>
    iunlock(f->ip);
    80004914:	6c88                	ld	a0,24(s1)
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	12e080e7          	jalr	302(ra) # 80003a44 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000491e:	46e1                	li	a3,24
    80004920:	fb840613          	addi	a2,s0,-72
    80004924:	85ce                	mv	a1,s3
    80004926:	05893503          	ld	a0,88(s2)
    8000492a:	ffffd097          	auipc	ra,0xffffd
    8000492e:	ed6080e7          	jalr	-298(ra) # 80001800 <copyout>
    80004932:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004936:	60a6                	ld	ra,72(sp)
    80004938:	6406                	ld	s0,64(sp)
    8000493a:	74e2                	ld	s1,56(sp)
    8000493c:	7942                	ld	s2,48(sp)
    8000493e:	79a2                	ld	s3,40(sp)
    80004940:	6161                	addi	sp,sp,80
    80004942:	8082                	ret
  return -1;
    80004944:	557d                	li	a0,-1
    80004946:	bfc5                	j	80004936 <filestat+0x60>

0000000080004948 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004948:	7179                	addi	sp,sp,-48
    8000494a:	f406                	sd	ra,40(sp)
    8000494c:	f022                	sd	s0,32(sp)
    8000494e:	ec26                	sd	s1,24(sp)
    80004950:	e84a                	sd	s2,16(sp)
    80004952:	e44e                	sd	s3,8(sp)
    80004954:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004956:	00854783          	lbu	a5,8(a0)
    8000495a:	c7c5                	beqz	a5,80004a02 <fileread+0xba>
    8000495c:	84aa                	mv	s1,a0
    8000495e:	89ae                	mv	s3,a1
    80004960:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004962:	411c                	lw	a5,0(a0)
    80004964:	4705                	li	a4,1
    80004966:	04e78963          	beq	a5,a4,800049b8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000496a:	470d                	li	a4,3
    8000496c:	04e78d63          	beq	a5,a4,800049c6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004970:	4709                	li	a4,2
    80004972:	08e79063          	bne	a5,a4,800049f2 <fileread+0xaa>
    ilock(f->ip);
    80004976:	6d08                	ld	a0,24(a0)
    80004978:	fffff097          	auipc	ra,0xfffff
    8000497c:	00a080e7          	jalr	10(ra) # 80003982 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004980:	874a                	mv	a4,s2
    80004982:	5094                	lw	a3,32(s1)
    80004984:	864e                	mv	a2,s3
    80004986:	4585                	li	a1,1
    80004988:	6c88                	ld	a0,24(s1)
    8000498a:	fffff097          	auipc	ra,0xfffff
    8000498e:	2ac080e7          	jalr	684(ra) # 80003c36 <readi>
    80004992:	892a                	mv	s2,a0
    80004994:	00a05563          	blez	a0,8000499e <fileread+0x56>
      f->off += r;
    80004998:	509c                	lw	a5,32(s1)
    8000499a:	9fa9                	addw	a5,a5,a0
    8000499c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000499e:	6c88                	ld	a0,24(s1)
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	0a4080e7          	jalr	164(ra) # 80003a44 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049a8:	854a                	mv	a0,s2
    800049aa:	70a2                	ld	ra,40(sp)
    800049ac:	7402                	ld	s0,32(sp)
    800049ae:	64e2                	ld	s1,24(sp)
    800049b0:	6942                	ld	s2,16(sp)
    800049b2:	69a2                	ld	s3,8(sp)
    800049b4:	6145                	addi	sp,sp,48
    800049b6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049b8:	6908                	ld	a0,16(a0)
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	3c8080e7          	jalr	968(ra) # 80004d82 <piperead>
    800049c2:	892a                	mv	s2,a0
    800049c4:	b7d5                	j	800049a8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049c6:	02451783          	lh	a5,36(a0)
    800049ca:	03079693          	slli	a3,a5,0x30
    800049ce:	92c1                	srli	a3,a3,0x30
    800049d0:	4725                	li	a4,9
    800049d2:	02d76a63          	bltu	a4,a3,80004a06 <fileread+0xbe>
    800049d6:	0792                	slli	a5,a5,0x4
    800049d8:	00033717          	auipc	a4,0x33
    800049dc:	83070713          	addi	a4,a4,-2000 # 80037208 <devsw>
    800049e0:	97ba                	add	a5,a5,a4
    800049e2:	639c                	ld	a5,0(a5)
    800049e4:	c39d                	beqz	a5,80004a0a <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    800049e6:	86b2                	mv	a3,a2
    800049e8:	862e                	mv	a2,a1
    800049ea:	4585                	li	a1,1
    800049ec:	9782                	jalr	a5
    800049ee:	892a                	mv	s2,a0
    800049f0:	bf65                	j	800049a8 <fileread+0x60>
    panic("fileread");
    800049f2:	00005517          	auipc	a0,0x5
    800049f6:	29650513          	addi	a0,a0,662 # 80009c88 <syscalls+0x268>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	b6a080e7          	jalr	-1174(ra) # 80000564 <panic>
    return -1;
    80004a02:	597d                	li	s2,-1
    80004a04:	b755                	j	800049a8 <fileread+0x60>
      return -1;
    80004a06:	597d                	li	s2,-1
    80004a08:	b745                	j	800049a8 <fileread+0x60>
    80004a0a:	597d                	li	s2,-1
    80004a0c:	bf71                	j	800049a8 <fileread+0x60>

0000000080004a0e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a0e:	715d                	addi	sp,sp,-80
    80004a10:	e486                	sd	ra,72(sp)
    80004a12:	e0a2                	sd	s0,64(sp)
    80004a14:	fc26                	sd	s1,56(sp)
    80004a16:	f84a                	sd	s2,48(sp)
    80004a18:	f44e                	sd	s3,40(sp)
    80004a1a:	f052                	sd	s4,32(sp)
    80004a1c:	ec56                	sd	s5,24(sp)
    80004a1e:	e85a                	sd	s6,16(sp)
    80004a20:	e45e                	sd	s7,8(sp)
    80004a22:	e062                	sd	s8,0(sp)
    80004a24:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a26:	00954783          	lbu	a5,9(a0)
    80004a2a:	10078863          	beqz	a5,80004b3a <filewrite+0x12c>
    80004a2e:	892a                	mv	s2,a0
    80004a30:	8aae                	mv	s5,a1
    80004a32:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a34:	411c                	lw	a5,0(a0)
    80004a36:	4705                	li	a4,1
    80004a38:	02e78263          	beq	a5,a4,80004a5c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a3c:	470d                	li	a4,3
    80004a3e:	02e78663          	beq	a5,a4,80004a6a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004a42:	4709                	li	a4,2
    80004a44:	0ee79363          	bne	a5,a4,80004b2a <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a48:	0ac05f63          	blez	a2,80004b06 <filewrite+0xf8>
    int i = 0;
    80004a4c:	4981                	li	s3,0
    80004a4e:	6b05                	lui	s6,0x1
    80004a50:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a54:	6b85                	lui	s7,0x1
    80004a56:	c00b8b9b          	addiw	s7,s7,-1024
    80004a5a:	a871                	j	80004af6 <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    80004a5c:	6908                	ld	a0,16(a0)
    80004a5e:	00000097          	auipc	ra,0x0
    80004a62:	232080e7          	jalr	562(ra) # 80004c90 <pipewrite>
    80004a66:	8a2a                	mv	s4,a0
    80004a68:	a055                	j	80004b0c <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a6a:	02451783          	lh	a5,36(a0)
    80004a6e:	03079693          	slli	a3,a5,0x30
    80004a72:	92c1                	srli	a3,a3,0x30
    80004a74:	4725                	li	a4,9
    80004a76:	0cd76463          	bltu	a4,a3,80004b3e <filewrite+0x130>
    80004a7a:	0792                	slli	a5,a5,0x4
    80004a7c:	00032717          	auipc	a4,0x32
    80004a80:	78c70713          	addi	a4,a4,1932 # 80037208 <devsw>
    80004a84:	97ba                	add	a5,a5,a4
    80004a86:	679c                	ld	a5,8(a5)
    80004a88:	cfcd                	beqz	a5,80004b42 <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004a8a:	86b2                	mv	a3,a2
    80004a8c:	862e                	mv	a2,a1
    80004a8e:	4585                	li	a1,1
    80004a90:	9782                	jalr	a5
    80004a92:	8a2a                	mv	s4,a0
    80004a94:	a8a5                	j	80004b0c <filewrite+0xfe>
    80004a96:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a9a:	00000097          	auipc	ra,0x0
    80004a9e:	8aa080e7          	jalr	-1878(ra) # 80004344 <begin_op>
      ilock(f->ip);
    80004aa2:	01893503          	ld	a0,24(s2)
    80004aa6:	fffff097          	auipc	ra,0xfffff
    80004aaa:	edc080e7          	jalr	-292(ra) # 80003982 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004aae:	8762                	mv	a4,s8
    80004ab0:	02092683          	lw	a3,32(s2)
    80004ab4:	01598633          	add	a2,s3,s5
    80004ab8:	4585                	li	a1,1
    80004aba:	01893503          	ld	a0,24(s2)
    80004abe:	fffff097          	auipc	ra,0xfffff
    80004ac2:	270080e7          	jalr	624(ra) # 80003d2e <writei>
    80004ac6:	84aa                	mv	s1,a0
    80004ac8:	00a05763          	blez	a0,80004ad6 <filewrite+0xc8>
        f->off += r;
    80004acc:	02092783          	lw	a5,32(s2)
    80004ad0:	9fa9                	addw	a5,a5,a0
    80004ad2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ad6:	01893503          	ld	a0,24(s2)
    80004ada:	fffff097          	auipc	ra,0xfffff
    80004ade:	f6a080e7          	jalr	-150(ra) # 80003a44 <iunlock>
      end_op();
    80004ae2:	00000097          	auipc	ra,0x0
    80004ae6:	8e2080e7          	jalr	-1822(ra) # 800043c4 <end_op>

      if(r != n1){
    80004aea:	009c1f63          	bne	s8,s1,80004b08 <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    80004aee:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004af2:	0149db63          	bge	s3,s4,80004b08 <filewrite+0xfa>
      int n1 = n - i;
    80004af6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004afa:	84be                	mv	s1,a5
    80004afc:	2781                	sext.w	a5,a5
    80004afe:	f8fb5ce3          	bge	s6,a5,80004a96 <filewrite+0x88>
    80004b02:	84de                	mv	s1,s7
    80004b04:	bf49                	j	80004a96 <filewrite+0x88>
    int i = 0;
    80004b06:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b08:	013a1f63          	bne	s4,s3,80004b26 <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b0c:	8552                	mv	a0,s4
    80004b0e:	60a6                	ld	ra,72(sp)
    80004b10:	6406                	ld	s0,64(sp)
    80004b12:	74e2                	ld	s1,56(sp)
    80004b14:	7942                	ld	s2,48(sp)
    80004b16:	79a2                	ld	s3,40(sp)
    80004b18:	7a02                	ld	s4,32(sp)
    80004b1a:	6ae2                	ld	s5,24(sp)
    80004b1c:	6b42                	ld	s6,16(sp)
    80004b1e:	6ba2                	ld	s7,8(sp)
    80004b20:	6c02                	ld	s8,0(sp)
    80004b22:	6161                	addi	sp,sp,80
    80004b24:	8082                	ret
    ret = (i == n ? n : -1);
    80004b26:	5a7d                	li	s4,-1
    80004b28:	b7d5                	j	80004b0c <filewrite+0xfe>
    panic("filewrite");
    80004b2a:	00005517          	auipc	a0,0x5
    80004b2e:	16e50513          	addi	a0,a0,366 # 80009c98 <syscalls+0x278>
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	a32080e7          	jalr	-1486(ra) # 80000564 <panic>
    return -1;
    80004b3a:	5a7d                	li	s4,-1
    80004b3c:	bfc1                	j	80004b0c <filewrite+0xfe>
      return -1;
    80004b3e:	5a7d                	li	s4,-1
    80004b40:	b7f1                	j	80004b0c <filewrite+0xfe>
    80004b42:	5a7d                	li	s4,-1
    80004b44:	b7e1                	j	80004b0c <filewrite+0xfe>

0000000080004b46 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b46:	7179                	addi	sp,sp,-48
    80004b48:	f406                	sd	ra,40(sp)
    80004b4a:	f022                	sd	s0,32(sp)
    80004b4c:	ec26                	sd	s1,24(sp)
    80004b4e:	e84a                	sd	s2,16(sp)
    80004b50:	e44e                	sd	s3,8(sp)
    80004b52:	e052                	sd	s4,0(sp)
    80004b54:	1800                	addi	s0,sp,48
    80004b56:	84aa                	mv	s1,a0
    80004b58:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b5a:	0005b023          	sd	zero,0(a1)
    80004b5e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b62:	00000097          	auipc	ra,0x0
    80004b66:	bf0080e7          	jalr	-1040(ra) # 80004752 <filealloc>
    80004b6a:	e088                	sd	a0,0(s1)
    80004b6c:	c551                	beqz	a0,80004bf8 <pipealloc+0xb2>
    80004b6e:	00000097          	auipc	ra,0x0
    80004b72:	be4080e7          	jalr	-1052(ra) # 80004752 <filealloc>
    80004b76:	00aa3023          	sd	a0,0(s4)
    80004b7a:	c92d                	beqz	a0,80004bec <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b7c:	ffffc097          	auipc	ra,0xffffc
    80004b80:	ec6080e7          	jalr	-314(ra) # 80000a42 <kalloc>
    80004b84:	892a                	mv	s2,a0
    80004b86:	c125                	beqz	a0,80004be6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b88:	4985                	li	s3,1
    80004b8a:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004b8e:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004b92:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004b96:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004b9a:	00005597          	auipc	a1,0x5
    80004b9e:	10e58593          	addi	a1,a1,270 # 80009ca8 <syscalls+0x288>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	f1a080e7          	jalr	-230(ra) # 80000abc <initlock>
  (*f0)->type = FD_PIPE;
    80004baa:	609c                	ld	a5,0(s1)
    80004bac:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bb0:	609c                	ld	a5,0(s1)
    80004bb2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bb6:	609c                	ld	a5,0(s1)
    80004bb8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bbc:	609c                	ld	a5,0(s1)
    80004bbe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bc2:	000a3783          	ld	a5,0(s4)
    80004bc6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bca:	000a3783          	ld	a5,0(s4)
    80004bce:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bd2:	000a3783          	ld	a5,0(s4)
    80004bd6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bda:	000a3783          	ld	a5,0(s4)
    80004bde:	0127b823          	sd	s2,16(a5)
  return 0;
    80004be2:	4501                	li	a0,0
    80004be4:	a025                	j	80004c0c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004be6:	6088                	ld	a0,0(s1)
    80004be8:	e501                	bnez	a0,80004bf0 <pipealloc+0xaa>
    80004bea:	a039                	j	80004bf8 <pipealloc+0xb2>
    80004bec:	6088                	ld	a0,0(s1)
    80004bee:	c51d                	beqz	a0,80004c1c <pipealloc+0xd6>
    fileclose(*f0);
    80004bf0:	00000097          	auipc	ra,0x0
    80004bf4:	c1e080e7          	jalr	-994(ra) # 8000480e <fileclose>
  if(*f1)
    80004bf8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bfc:	557d                	li	a0,-1
  if(*f1)
    80004bfe:	c799                	beqz	a5,80004c0c <pipealloc+0xc6>
    fileclose(*f1);
    80004c00:	853e                	mv	a0,a5
    80004c02:	00000097          	auipc	ra,0x0
    80004c06:	c0c080e7          	jalr	-1012(ra) # 8000480e <fileclose>
  return -1;
    80004c0a:	557d                	li	a0,-1
}
    80004c0c:	70a2                	ld	ra,40(sp)
    80004c0e:	7402                	ld	s0,32(sp)
    80004c10:	64e2                	ld	s1,24(sp)
    80004c12:	6942                	ld	s2,16(sp)
    80004c14:	69a2                	ld	s3,8(sp)
    80004c16:	6a02                	ld	s4,0(sp)
    80004c18:	6145                	addi	sp,sp,48
    80004c1a:	8082                	ret
  return -1;
    80004c1c:	557d                	li	a0,-1
    80004c1e:	b7fd                	j	80004c0c <pipealloc+0xc6>

0000000080004c20 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c20:	1101                	addi	sp,sp,-32
    80004c22:	ec06                	sd	ra,24(sp)
    80004c24:	e822                	sd	s0,16(sp)
    80004c26:	e426                	sd	s1,8(sp)
    80004c28:	e04a                	sd	s2,0(sp)
    80004c2a:	1000                	addi	s0,sp,32
    80004c2c:	84aa                	mv	s1,a0
    80004c2e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	f62080e7          	jalr	-158(ra) # 80000b92 <acquire>
  if(writable){
    80004c38:	02090d63          	beqz	s2,80004c72 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c3c:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004c40:	22048513          	addi	a0,s1,544
    80004c44:	ffffe097          	auipc	ra,0xffffe
    80004c48:	9dc080e7          	jalr	-1572(ra) # 80002620 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c4c:	2284b783          	ld	a5,552(s1)
    80004c50:	eb95                	bnez	a5,80004c84 <pipeclose+0x64>
    release(&pi->lock);
    80004c52:	8526                	mv	a0,s1
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	00e080e7          	jalr	14(ra) # 80000c62 <release>
    kfree((char*)pi);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	cde080e7          	jalr	-802(ra) # 8000093c <kfree>
  } else
    release(&pi->lock);
}
    80004c66:	60e2                	ld	ra,24(sp)
    80004c68:	6442                	ld	s0,16(sp)
    80004c6a:	64a2                	ld	s1,8(sp)
    80004c6c:	6902                	ld	s2,0(sp)
    80004c6e:	6105                	addi	sp,sp,32
    80004c70:	8082                	ret
    pi->readopen = 0;
    80004c72:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004c76:	22448513          	addi	a0,s1,548
    80004c7a:	ffffe097          	auipc	ra,0xffffe
    80004c7e:	9a6080e7          	jalr	-1626(ra) # 80002620 <wakeup>
    80004c82:	b7e9                	j	80004c4c <pipeclose+0x2c>
    release(&pi->lock);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffc097          	auipc	ra,0xffffc
    80004c8a:	fdc080e7          	jalr	-36(ra) # 80000c62 <release>
}
    80004c8e:	bfe1                	j	80004c66 <pipeclose+0x46>

0000000080004c90 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c90:	711d                	addi	sp,sp,-96
    80004c92:	ec86                	sd	ra,88(sp)
    80004c94:	e8a2                	sd	s0,80(sp)
    80004c96:	e4a6                	sd	s1,72(sp)
    80004c98:	e0ca                	sd	s2,64(sp)
    80004c9a:	fc4e                	sd	s3,56(sp)
    80004c9c:	f852                	sd	s4,48(sp)
    80004c9e:	f456                	sd	s5,40(sp)
    80004ca0:	f05a                	sd	s6,32(sp)
    80004ca2:	ec5e                	sd	s7,24(sp)
    80004ca4:	e862                	sd	s8,16(sp)
    80004ca6:	1080                	addi	s0,sp,96
    80004ca8:	84aa                	mv	s1,a0
    80004caa:	8aae                	mv	s5,a1
    80004cac:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	ea2080e7          	jalr	-350(ra) # 80001b50 <myproc>
    80004cb6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004cb8:	8526                	mv	a0,s1
    80004cba:	ffffc097          	auipc	ra,0xffffc
    80004cbe:	ed8080e7          	jalr	-296(ra) # 80000b92 <acquire>
  while(i < n){
    80004cc2:	0b405363          	blez	s4,80004d68 <pipewrite+0xd8>
  int i = 0;
    80004cc6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cc8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cca:	22048c13          	addi	s8,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004cce:	22448b93          	addi	s7,s1,548
    80004cd2:	a089                	j	80004d14 <pipewrite+0x84>
      release(&pi->lock);
    80004cd4:	8526                	mv	a0,s1
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	f8c080e7          	jalr	-116(ra) # 80000c62 <release>
      return -1;
    80004cde:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ce0:	854a                	mv	a0,s2
    80004ce2:	60e6                	ld	ra,88(sp)
    80004ce4:	6446                	ld	s0,80(sp)
    80004ce6:	64a6                	ld	s1,72(sp)
    80004ce8:	6906                	ld	s2,64(sp)
    80004cea:	79e2                	ld	s3,56(sp)
    80004cec:	7a42                	ld	s4,48(sp)
    80004cee:	7aa2                	ld	s5,40(sp)
    80004cf0:	7b02                	ld	s6,32(sp)
    80004cf2:	6be2                	ld	s7,24(sp)
    80004cf4:	6c42                	ld	s8,16(sp)
    80004cf6:	6125                	addi	sp,sp,96
    80004cf8:	8082                	ret
      wakeup(&pi->nread);
    80004cfa:	8562                	mv	a0,s8
    80004cfc:	ffffe097          	auipc	ra,0xffffe
    80004d00:	924080e7          	jalr	-1756(ra) # 80002620 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d04:	85a6                	mv	a1,s1
    80004d06:	855e                	mv	a0,s7
    80004d08:	ffffd097          	auipc	ra,0xffffd
    80004d0c:	798080e7          	jalr	1944(ra) # 800024a0 <sleep>
  while(i < n){
    80004d10:	05495d63          	bge	s2,s4,80004d6a <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004d14:	2284a783          	lw	a5,552(s1)
    80004d18:	dfd5                	beqz	a5,80004cd4 <pipewrite+0x44>
    80004d1a:	0389a783          	lw	a5,56(s3)
    80004d1e:	fbdd                	bnez	a5,80004cd4 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d20:	2204a783          	lw	a5,544(s1)
    80004d24:	2244a703          	lw	a4,548(s1)
    80004d28:	2007879b          	addiw	a5,a5,512
    80004d2c:	fcf707e3          	beq	a4,a5,80004cfa <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d30:	4685                	li	a3,1
    80004d32:	01590633          	add	a2,s2,s5
    80004d36:	faf40593          	addi	a1,s0,-81
    80004d3a:	0589b503          	ld	a0,88(s3)
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	b4e080e7          	jalr	-1202(ra) # 8000188c <copyin>
    80004d46:	03650263          	beq	a0,s6,80004d6a <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d4a:	2244a783          	lw	a5,548(s1)
    80004d4e:	0017871b          	addiw	a4,a5,1
    80004d52:	22e4a223          	sw	a4,548(s1)
    80004d56:	1ff7f793          	andi	a5,a5,511
    80004d5a:	97a6                	add	a5,a5,s1
    80004d5c:	faf44703          	lbu	a4,-81(s0)
    80004d60:	02e78023          	sb	a4,32(a5)
      i++;
    80004d64:	2905                	addiw	s2,s2,1
    80004d66:	b76d                	j	80004d10 <pipewrite+0x80>
  int i = 0;
    80004d68:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d6a:	22048513          	addi	a0,s1,544
    80004d6e:	ffffe097          	auipc	ra,0xffffe
    80004d72:	8b2080e7          	jalr	-1870(ra) # 80002620 <wakeup>
  release(&pi->lock);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	eea080e7          	jalr	-278(ra) # 80000c62 <release>
  return i;
    80004d80:	b785                	j	80004ce0 <pipewrite+0x50>

0000000080004d82 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d82:	715d                	addi	sp,sp,-80
    80004d84:	e486                	sd	ra,72(sp)
    80004d86:	e0a2                	sd	s0,64(sp)
    80004d88:	fc26                	sd	s1,56(sp)
    80004d8a:	f84a                	sd	s2,48(sp)
    80004d8c:	f44e                	sd	s3,40(sp)
    80004d8e:	f052                	sd	s4,32(sp)
    80004d90:	ec56                	sd	s5,24(sp)
    80004d92:	e85a                	sd	s6,16(sp)
    80004d94:	0880                	addi	s0,sp,80
    80004d96:	84aa                	mv	s1,a0
    80004d98:	892e                	mv	s2,a1
    80004d9a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d9c:	ffffd097          	auipc	ra,0xffffd
    80004da0:	db4080e7          	jalr	-588(ra) # 80001b50 <myproc>
    80004da4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	dea080e7          	jalr	-534(ra) # 80000b92 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004db0:	2204a703          	lw	a4,544(s1)
    80004db4:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004db8:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dbc:	02f71463          	bne	a4,a5,80004de4 <piperead+0x62>
    80004dc0:	22c4a783          	lw	a5,556(s1)
    80004dc4:	c385                	beqz	a5,80004de4 <piperead+0x62>
    if(pr->killed){
    80004dc6:	038a2783          	lw	a5,56(s4)
    80004dca:	ebc1                	bnez	a5,80004e5a <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dcc:	85a6                	mv	a1,s1
    80004dce:	854e                	mv	a0,s3
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	6d0080e7          	jalr	1744(ra) # 800024a0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dd8:	2204a703          	lw	a4,544(s1)
    80004ddc:	2244a783          	lw	a5,548(s1)
    80004de0:	fef700e3          	beq	a4,a5,80004dc0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004de4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004de6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004de8:	05505363          	blez	s5,80004e2e <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004dec:	2204a783          	lw	a5,544(s1)
    80004df0:	2244a703          	lw	a4,548(s1)
    80004df4:	02f70d63          	beq	a4,a5,80004e2e <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004df8:	0017871b          	addiw	a4,a5,1
    80004dfc:	22e4a023          	sw	a4,544(s1)
    80004e00:	1ff7f793          	andi	a5,a5,511
    80004e04:	97a6                	add	a5,a5,s1
    80004e06:	0207c783          	lbu	a5,32(a5)
    80004e0a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e0e:	4685                	li	a3,1
    80004e10:	fbf40613          	addi	a2,s0,-65
    80004e14:	85ca                	mv	a1,s2
    80004e16:	058a3503          	ld	a0,88(s4)
    80004e1a:	ffffd097          	auipc	ra,0xffffd
    80004e1e:	9e6080e7          	jalr	-1562(ra) # 80001800 <copyout>
    80004e22:	01650663          	beq	a0,s6,80004e2e <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e26:	2985                	addiw	s3,s3,1
    80004e28:	0905                	addi	s2,s2,1
    80004e2a:	fd3a91e3          	bne	s5,s3,80004dec <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e2e:	22448513          	addi	a0,s1,548
    80004e32:	ffffd097          	auipc	ra,0xffffd
    80004e36:	7ee080e7          	jalr	2030(ra) # 80002620 <wakeup>
  release(&pi->lock);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	e26080e7          	jalr	-474(ra) # 80000c62 <release>
  return i;
}
    80004e44:	854e                	mv	a0,s3
    80004e46:	60a6                	ld	ra,72(sp)
    80004e48:	6406                	ld	s0,64(sp)
    80004e4a:	74e2                	ld	s1,56(sp)
    80004e4c:	7942                	ld	s2,48(sp)
    80004e4e:	79a2                	ld	s3,40(sp)
    80004e50:	7a02                	ld	s4,32(sp)
    80004e52:	6ae2                	ld	s5,24(sp)
    80004e54:	6b42                	ld	s6,16(sp)
    80004e56:	6161                	addi	sp,sp,80
    80004e58:	8082                	ret
      release(&pi->lock);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	ffffc097          	auipc	ra,0xffffc
    80004e60:	e06080e7          	jalr	-506(ra) # 80000c62 <release>
      return -1;
    80004e64:	59fd                	li	s3,-1
    80004e66:	bff9                	j	80004e44 <piperead+0xc2>

0000000080004e68 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e68:	de010113          	addi	sp,sp,-544
    80004e6c:	20113c23          	sd	ra,536(sp)
    80004e70:	20813823          	sd	s0,528(sp)
    80004e74:	20913423          	sd	s1,520(sp)
    80004e78:	21213023          	sd	s2,512(sp)
    80004e7c:	ffce                	sd	s3,504(sp)
    80004e7e:	fbd2                	sd	s4,496(sp)
    80004e80:	f7d6                	sd	s5,488(sp)
    80004e82:	f3da                	sd	s6,480(sp)
    80004e84:	efde                	sd	s7,472(sp)
    80004e86:	ebe2                	sd	s8,464(sp)
    80004e88:	e7e6                	sd	s9,456(sp)
    80004e8a:	e3ea                	sd	s10,448(sp)
    80004e8c:	ff6e                	sd	s11,440(sp)
    80004e8e:	1400                	addi	s0,sp,544
    80004e90:	892a                	mv	s2,a0
    80004e92:	dea43423          	sd	a0,-536(s0)
    80004e96:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e9a:	ffffd097          	auipc	ra,0xffffd
    80004e9e:	cb6080e7          	jalr	-842(ra) # 80001b50 <myproc>
    80004ea2:	84aa                	mv	s1,a0

  begin_op();
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	4a0080e7          	jalr	1184(ra) # 80004344 <begin_op>

  if((ip = namei(path)) == 0){
    80004eac:	854a                	mv	a0,s2
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	28a080e7          	jalr	650(ra) # 80004138 <namei>
    80004eb6:	c93d                	beqz	a0,80004f2c <exec+0xc4>
    80004eb8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	ac8080e7          	jalr	-1336(ra) # 80003982 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ec2:	04000713          	li	a4,64
    80004ec6:	4681                	li	a3,0
    80004ec8:	e5040613          	addi	a2,s0,-432
    80004ecc:	4581                	li	a1,0
    80004ece:	8556                	mv	a0,s5
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	d66080e7          	jalr	-666(ra) # 80003c36 <readi>
    80004ed8:	04000793          	li	a5,64
    80004edc:	00f51a63          	bne	a0,a5,80004ef0 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ee0:	e5042703          	lw	a4,-432(s0)
    80004ee4:	464c47b7          	lui	a5,0x464c4
    80004ee8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eec:	04f70663          	beq	a4,a5,80004f38 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ef0:	8556                	mv	a0,s5
    80004ef2:	fffff097          	auipc	ra,0xfffff
    80004ef6:	cf2080e7          	jalr	-782(ra) # 80003be4 <iunlockput>
    end_op();
    80004efa:	fffff097          	auipc	ra,0xfffff
    80004efe:	4ca080e7          	jalr	1226(ra) # 800043c4 <end_op>
  }
  return -1;
    80004f02:	557d                	li	a0,-1
}
    80004f04:	21813083          	ld	ra,536(sp)
    80004f08:	21013403          	ld	s0,528(sp)
    80004f0c:	20813483          	ld	s1,520(sp)
    80004f10:	20013903          	ld	s2,512(sp)
    80004f14:	79fe                	ld	s3,504(sp)
    80004f16:	7a5e                	ld	s4,496(sp)
    80004f18:	7abe                	ld	s5,488(sp)
    80004f1a:	7b1e                	ld	s6,480(sp)
    80004f1c:	6bfe                	ld	s7,472(sp)
    80004f1e:	6c5e                	ld	s8,464(sp)
    80004f20:	6cbe                	ld	s9,456(sp)
    80004f22:	6d1e                	ld	s10,448(sp)
    80004f24:	7dfa                	ld	s11,440(sp)
    80004f26:	22010113          	addi	sp,sp,544
    80004f2a:	8082                	ret
    end_op();
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	498080e7          	jalr	1176(ra) # 800043c4 <end_op>
    return -1;
    80004f34:	557d                	li	a0,-1
    80004f36:	b7f9                	j	80004f04 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f38:	8526                	mv	a0,s1
    80004f3a:	ffffd097          	auipc	ra,0xffffd
    80004f3e:	cda080e7          	jalr	-806(ra) # 80001c14 <proc_pagetable>
    80004f42:	8b2a                	mv	s6,a0
    80004f44:	d555                	beqz	a0,80004ef0 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f46:	e7042783          	lw	a5,-400(s0)
    80004f4a:	e8845703          	lhu	a4,-376(s0)
    80004f4e:	c735                	beqz	a4,80004fba <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f50:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f52:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004f56:	6a05                	lui	s4,0x1
    80004f58:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f5c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f60:	6d85                	lui	s11,0x1
    80004f62:	7d7d                	lui	s10,0xfffff
    80004f64:	ac1d                	j	8000519a <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f66:	00005517          	auipc	a0,0x5
    80004f6a:	d4a50513          	addi	a0,a0,-694 # 80009cb0 <syscalls+0x290>
    80004f6e:	ffffb097          	auipc	ra,0xffffb
    80004f72:	5f6080e7          	jalr	1526(ra) # 80000564 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f76:	874a                	mv	a4,s2
    80004f78:	009c86bb          	addw	a3,s9,s1
    80004f7c:	4581                	li	a1,0
    80004f7e:	8556                	mv	a0,s5
    80004f80:	fffff097          	auipc	ra,0xfffff
    80004f84:	cb6080e7          	jalr	-842(ra) # 80003c36 <readi>
    80004f88:	2501                	sext.w	a0,a0
    80004f8a:	1aa91863          	bne	s2,a0,8000513a <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004f8e:	009d84bb          	addw	s1,s11,s1
    80004f92:	013d09bb          	addw	s3,s10,s3
    80004f96:	1f74f263          	bgeu	s1,s7,8000517a <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004f9a:	02049593          	slli	a1,s1,0x20
    80004f9e:	9181                	srli	a1,a1,0x20
    80004fa0:	95e2                	add	a1,a1,s8
    80004fa2:	855a                	mv	a0,s6
    80004fa4:	ffffc097          	auipc	ra,0xffffc
    80004fa8:	2ee080e7          	jalr	750(ra) # 80001292 <walkaddr>
    80004fac:	862a                	mv	a2,a0
    if(pa == 0)
    80004fae:	dd45                	beqz	a0,80004f66 <exec+0xfe>
      n = PGSIZE;
    80004fb0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fb2:	fd49f2e3          	bgeu	s3,s4,80004f76 <exec+0x10e>
      n = sz - i;
    80004fb6:	894e                	mv	s2,s3
    80004fb8:	bf7d                	j	80004f76 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fba:	4481                	li	s1,0
  iunlockput(ip);
    80004fbc:	8556                	mv	a0,s5
    80004fbe:	fffff097          	auipc	ra,0xfffff
    80004fc2:	c26080e7          	jalr	-986(ra) # 80003be4 <iunlockput>
  end_op();
    80004fc6:	fffff097          	auipc	ra,0xfffff
    80004fca:	3fe080e7          	jalr	1022(ra) # 800043c4 <end_op>
  p = myproc();
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	b82080e7          	jalr	-1150(ra) # 80001b50 <myproc>
    80004fd6:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004fd8:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004fdc:	6785                	lui	a5,0x1
    80004fde:	17fd                	addi	a5,a5,-1
    80004fe0:	94be                	add	s1,s1,a5
    80004fe2:	77fd                	lui	a5,0xfffff
    80004fe4:	8fe5                	and	a5,a5,s1
    80004fe6:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fea:	6609                	lui	a2,0x2
    80004fec:	963e                	add	a2,a2,a5
    80004fee:	85be                	mv	a1,a5
    80004ff0:	855a                	mv	a0,s6
    80004ff2:	ffffc097          	auipc	ra,0xffffc
    80004ff6:	634080e7          	jalr	1588(ra) # 80001626 <uvmalloc>
    80004ffa:	8c2a                	mv	s8,a0
  ip = 0;
    80004ffc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ffe:	12050e63          	beqz	a0,8000513a <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005002:	75f9                	lui	a1,0xffffe
    80005004:	95aa                	add	a1,a1,a0
    80005006:	855a                	mv	a0,s6
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	7c6080e7          	jalr	1990(ra) # 800017ce <uvmclear>
  stackbase = sp - PGSIZE;
    80005010:	7afd                	lui	s5,0xfffff
    80005012:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005014:	df043783          	ld	a5,-528(s0)
    80005018:	6388                	ld	a0,0(a5)
    8000501a:	c925                	beqz	a0,8000508a <exec+0x222>
    8000501c:	e9040993          	addi	s3,s0,-368
    80005020:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005024:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005026:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	ff6080e7          	jalr	-10(ra) # 8000101e <strlen>
    80005030:	0015079b          	addiw	a5,a0,1
    80005034:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005038:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000503c:	13596363          	bltu	s2,s5,80005162 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005040:	df043d83          	ld	s11,-528(s0)
    80005044:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005048:	8552                	mv	a0,s4
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	fd4080e7          	jalr	-44(ra) # 8000101e <strlen>
    80005052:	0015069b          	addiw	a3,a0,1
    80005056:	8652                	mv	a2,s4
    80005058:	85ca                	mv	a1,s2
    8000505a:	855a                	mv	a0,s6
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	7a4080e7          	jalr	1956(ra) # 80001800 <copyout>
    80005064:	10054363          	bltz	a0,8000516a <exec+0x302>
    ustack[argc] = sp;
    80005068:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000506c:	0485                	addi	s1,s1,1
    8000506e:	008d8793          	addi	a5,s11,8
    80005072:	def43823          	sd	a5,-528(s0)
    80005076:	008db503          	ld	a0,8(s11)
    8000507a:	c911                	beqz	a0,8000508e <exec+0x226>
    if(argc >= MAXARG)
    8000507c:	09a1                	addi	s3,s3,8
    8000507e:	fb3c95e3          	bne	s9,s3,80005028 <exec+0x1c0>
  sz = sz1;
    80005082:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005086:	4a81                	li	s5,0
    80005088:	a84d                	j	8000513a <exec+0x2d2>
  sp = sz;
    8000508a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000508c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000508e:	00349793          	slli	a5,s1,0x3
    80005092:	f9040713          	addi	a4,s0,-112
    80005096:	97ba                	add	a5,a5,a4
    80005098:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffc6b30>
  sp -= (argc+1) * sizeof(uint64);
    8000509c:	00148693          	addi	a3,s1,1
    800050a0:	068e                	slli	a3,a3,0x3
    800050a2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050a6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800050aa:	01597663          	bgeu	s2,s5,800050b6 <exec+0x24e>
  sz = sz1;
    800050ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050b2:	4a81                	li	s5,0
    800050b4:	a059                	j	8000513a <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050b6:	e9040613          	addi	a2,s0,-368
    800050ba:	85ca                	mv	a1,s2
    800050bc:	855a                	mv	a0,s6
    800050be:	ffffc097          	auipc	ra,0xffffc
    800050c2:	742080e7          	jalr	1858(ra) # 80001800 <copyout>
    800050c6:	0a054663          	bltz	a0,80005172 <exec+0x30a>
  p->trapframe->a1 = sp;
    800050ca:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800050ce:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050d2:	de843783          	ld	a5,-536(s0)
    800050d6:	0007c703          	lbu	a4,0(a5)
    800050da:	cf11                	beqz	a4,800050f6 <exec+0x28e>
    800050dc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050de:	02f00693          	li	a3,47
    800050e2:	a039                	j	800050f0 <exec+0x288>
      last = s+1;
    800050e4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050e8:	0785                	addi	a5,a5,1
    800050ea:	fff7c703          	lbu	a4,-1(a5)
    800050ee:	c701                	beqz	a4,800050f6 <exec+0x28e>
    if(*s == '/')
    800050f0:	fed71ce3          	bne	a4,a3,800050e8 <exec+0x280>
    800050f4:	bfc5                	j	800050e4 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800050f6:	4641                	li	a2,16
    800050f8:	de843583          	ld	a1,-536(s0)
    800050fc:	160b8513          	addi	a0,s7,352
    80005100:	ffffc097          	auipc	ra,0xffffc
    80005104:	eec080e7          	jalr	-276(ra) # 80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    80005108:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000510c:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005110:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005114:	060bb783          	ld	a5,96(s7)
    80005118:	e6843703          	ld	a4,-408(s0)
    8000511c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000511e:	060bb783          	ld	a5,96(s7)
    80005122:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005126:	85ea                	mv	a1,s10
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	c20080e7          	jalr	-992(ra) # 80001d48 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005130:	0004851b          	sext.w	a0,s1
    80005134:	bbc1                	j	80004f04 <exec+0x9c>
    80005136:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000513a:	df843583          	ld	a1,-520(s0)
    8000513e:	855a                	mv	a0,s6
    80005140:	ffffd097          	auipc	ra,0xffffd
    80005144:	c08080e7          	jalr	-1016(ra) # 80001d48 <proc_freepagetable>
  if(ip){
    80005148:	da0a94e3          	bnez	s5,80004ef0 <exec+0x88>
  return -1;
    8000514c:	557d                	li	a0,-1
    8000514e:	bb5d                	j	80004f04 <exec+0x9c>
    80005150:	de943c23          	sd	s1,-520(s0)
    80005154:	b7dd                	j	8000513a <exec+0x2d2>
    80005156:	de943c23          	sd	s1,-520(s0)
    8000515a:	b7c5                	j	8000513a <exec+0x2d2>
    8000515c:	de943c23          	sd	s1,-520(s0)
    80005160:	bfe9                	j	8000513a <exec+0x2d2>
  sz = sz1;
    80005162:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005166:	4a81                	li	s5,0
    80005168:	bfc9                	j	8000513a <exec+0x2d2>
  sz = sz1;
    8000516a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000516e:	4a81                	li	s5,0
    80005170:	b7e9                	j	8000513a <exec+0x2d2>
  sz = sz1;
    80005172:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005176:	4a81                	li	s5,0
    80005178:	b7c9                	j	8000513a <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000517a:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000517e:	e0843783          	ld	a5,-504(s0)
    80005182:	0017869b          	addiw	a3,a5,1
    80005186:	e0d43423          	sd	a3,-504(s0)
    8000518a:	e0043783          	ld	a5,-512(s0)
    8000518e:	0387879b          	addiw	a5,a5,56
    80005192:	e8845703          	lhu	a4,-376(s0)
    80005196:	e2e6d3e3          	bge	a3,a4,80004fbc <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000519a:	2781                	sext.w	a5,a5
    8000519c:	e0f43023          	sd	a5,-512(s0)
    800051a0:	03800713          	li	a4,56
    800051a4:	86be                	mv	a3,a5
    800051a6:	e1840613          	addi	a2,s0,-488
    800051aa:	4581                	li	a1,0
    800051ac:	8556                	mv	a0,s5
    800051ae:	fffff097          	auipc	ra,0xfffff
    800051b2:	a88080e7          	jalr	-1400(ra) # 80003c36 <readi>
    800051b6:	03800793          	li	a5,56
    800051ba:	f6f51ee3          	bne	a0,a5,80005136 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800051be:	e1842783          	lw	a5,-488(s0)
    800051c2:	4705                	li	a4,1
    800051c4:	fae79de3          	bne	a5,a4,8000517e <exec+0x316>
    if(ph.memsz < ph.filesz)
    800051c8:	e4043603          	ld	a2,-448(s0)
    800051cc:	e3843783          	ld	a5,-456(s0)
    800051d0:	f8f660e3          	bltu	a2,a5,80005150 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051d4:	e2843783          	ld	a5,-472(s0)
    800051d8:	963e                	add	a2,a2,a5
    800051da:	f6f66ee3          	bltu	a2,a5,80005156 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051de:	85a6                	mv	a1,s1
    800051e0:	855a                	mv	a0,s6
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	444080e7          	jalr	1092(ra) # 80001626 <uvmalloc>
    800051ea:	dea43c23          	sd	a0,-520(s0)
    800051ee:	d53d                	beqz	a0,8000515c <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    800051f0:	e2843c03          	ld	s8,-472(s0)
    800051f4:	de043783          	ld	a5,-544(s0)
    800051f8:	00fc77b3          	and	a5,s8,a5
    800051fc:	ff9d                	bnez	a5,8000513a <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051fe:	e2042c83          	lw	s9,-480(s0)
    80005202:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005206:	f60b8ae3          	beqz	s7,8000517a <exec+0x312>
    8000520a:	89de                	mv	s3,s7
    8000520c:	4481                	li	s1,0
    8000520e:	b371                	j	80004f9a <exec+0x132>

0000000080005210 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005210:	7179                	addi	sp,sp,-48
    80005212:	f406                	sd	ra,40(sp)
    80005214:	f022                	sd	s0,32(sp)
    80005216:	ec26                	sd	s1,24(sp)
    80005218:	e84a                	sd	s2,16(sp)
    8000521a:	1800                	addi	s0,sp,48
    8000521c:	892e                	mv	s2,a1
    8000521e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005220:	fdc40593          	addi	a1,s0,-36
    80005224:	ffffe097          	auipc	ra,0xffffe
    80005228:	bee080e7          	jalr	-1042(ra) # 80002e12 <argint>
    8000522c:	04054063          	bltz	a0,8000526c <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005230:	fdc42703          	lw	a4,-36(s0)
    80005234:	47bd                	li	a5,15
    80005236:	02e7ed63          	bltu	a5,a4,80005270 <argfd+0x60>
    8000523a:	ffffd097          	auipc	ra,0xffffd
    8000523e:	916080e7          	jalr	-1770(ra) # 80001b50 <myproc>
    80005242:	fdc42703          	lw	a4,-36(s0)
    80005246:	01a70793          	addi	a5,a4,26
    8000524a:	078e                	slli	a5,a5,0x3
    8000524c:	953e                	add	a0,a0,a5
    8000524e:	651c                	ld	a5,8(a0)
    80005250:	c395                	beqz	a5,80005274 <argfd+0x64>
    return -1;
  if(pfd)
    80005252:	00090463          	beqz	s2,8000525a <argfd+0x4a>
    *pfd = fd;
    80005256:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000525a:	4501                	li	a0,0
  if(pf)
    8000525c:	c091                	beqz	s1,80005260 <argfd+0x50>
    *pf = f;
    8000525e:	e09c                	sd	a5,0(s1)
}
    80005260:	70a2                	ld	ra,40(sp)
    80005262:	7402                	ld	s0,32(sp)
    80005264:	64e2                	ld	s1,24(sp)
    80005266:	6942                	ld	s2,16(sp)
    80005268:	6145                	addi	sp,sp,48
    8000526a:	8082                	ret
    return -1;
    8000526c:	557d                	li	a0,-1
    8000526e:	bfcd                	j	80005260 <argfd+0x50>
    return -1;
    80005270:	557d                	li	a0,-1
    80005272:	b7fd                	j	80005260 <argfd+0x50>
    80005274:	557d                	li	a0,-1
    80005276:	b7ed                	j	80005260 <argfd+0x50>

0000000080005278 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005278:	1101                	addi	sp,sp,-32
    8000527a:	ec06                	sd	ra,24(sp)
    8000527c:	e822                	sd	s0,16(sp)
    8000527e:	e426                	sd	s1,8(sp)
    80005280:	1000                	addi	s0,sp,32
    80005282:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005284:	ffffd097          	auipc	ra,0xffffd
    80005288:	8cc080e7          	jalr	-1844(ra) # 80001b50 <myproc>
    8000528c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000528e:	0d850793          	addi	a5,a0,216
    80005292:	4501                	li	a0,0
    80005294:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005296:	6398                	ld	a4,0(a5)
    80005298:	cb19                	beqz	a4,800052ae <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000529a:	2505                	addiw	a0,a0,1
    8000529c:	07a1                	addi	a5,a5,8
    8000529e:	fed51ce3          	bne	a0,a3,80005296 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052a2:	557d                	li	a0,-1
}
    800052a4:	60e2                	ld	ra,24(sp)
    800052a6:	6442                	ld	s0,16(sp)
    800052a8:	64a2                	ld	s1,8(sp)
    800052aa:	6105                	addi	sp,sp,32
    800052ac:	8082                	ret
      p->ofile[fd] = f;
    800052ae:	01a50793          	addi	a5,a0,26
    800052b2:	078e                	slli	a5,a5,0x3
    800052b4:	963e                	add	a2,a2,a5
    800052b6:	e604                	sd	s1,8(a2)
      return fd;
    800052b8:	b7f5                	j	800052a4 <fdalloc+0x2c>

00000000800052ba <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052ba:	715d                	addi	sp,sp,-80
    800052bc:	e486                	sd	ra,72(sp)
    800052be:	e0a2                	sd	s0,64(sp)
    800052c0:	fc26                	sd	s1,56(sp)
    800052c2:	f84a                	sd	s2,48(sp)
    800052c4:	f44e                	sd	s3,40(sp)
    800052c6:	f052                	sd	s4,32(sp)
    800052c8:	ec56                	sd	s5,24(sp)
    800052ca:	0880                	addi	s0,sp,80
    800052cc:	89ae                	mv	s3,a1
    800052ce:	8ab2                	mv	s5,a2
    800052d0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052d2:	fb040593          	addi	a1,s0,-80
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	e80080e7          	jalr	-384(ra) # 80004156 <nameiparent>
    800052de:	892a                	mv	s2,a0
    800052e0:	12050e63          	beqz	a0,8000541c <create+0x162>
    return 0;

  ilock(dp);
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	69e080e7          	jalr	1694(ra) # 80003982 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052ec:	4601                	li	a2,0
    800052ee:	fb040593          	addi	a1,s0,-80
    800052f2:	854a                	mv	a0,s2
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	b72080e7          	jalr	-1166(ra) # 80003e66 <dirlookup>
    800052fc:	84aa                	mv	s1,a0
    800052fe:	c921                	beqz	a0,8000534e <create+0x94>
    iunlockput(dp);
    80005300:	854a                	mv	a0,s2
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	8e2080e7          	jalr	-1822(ra) # 80003be4 <iunlockput>
    ilock(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	676080e7          	jalr	1654(ra) # 80003982 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005314:	2981                	sext.w	s3,s3
    80005316:	4789                	li	a5,2
    80005318:	02f99463          	bne	s3,a5,80005340 <create+0x86>
    8000531c:	04c4d783          	lhu	a5,76(s1)
    80005320:	37f9                	addiw	a5,a5,-2
    80005322:	17c2                	slli	a5,a5,0x30
    80005324:	93c1                	srli	a5,a5,0x30
    80005326:	4705                	li	a4,1
    80005328:	00f76c63          	bltu	a4,a5,80005340 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000532c:	8526                	mv	a0,s1
    8000532e:	60a6                	ld	ra,72(sp)
    80005330:	6406                	ld	s0,64(sp)
    80005332:	74e2                	ld	s1,56(sp)
    80005334:	7942                	ld	s2,48(sp)
    80005336:	79a2                	ld	s3,40(sp)
    80005338:	7a02                	ld	s4,32(sp)
    8000533a:	6ae2                	ld	s5,24(sp)
    8000533c:	6161                	addi	sp,sp,80
    8000533e:	8082                	ret
    iunlockput(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	8a2080e7          	jalr	-1886(ra) # 80003be4 <iunlockput>
    return 0;
    8000534a:	4481                	li	s1,0
    8000534c:	b7c5                	j	8000532c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000534e:	85ce                	mv	a1,s3
    80005350:	00092503          	lw	a0,0(s2)
    80005354:	ffffe097          	auipc	ra,0xffffe
    80005358:	496080e7          	jalr	1174(ra) # 800037ea <ialloc>
    8000535c:	84aa                	mv	s1,a0
    8000535e:	c521                	beqz	a0,800053a6 <create+0xec>
  ilock(ip);
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	622080e7          	jalr	1570(ra) # 80003982 <ilock>
  ip->major = major;
    80005368:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    8000536c:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    80005370:	4a05                	li	s4,1
    80005372:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    80005376:	8526                	mv	a0,s1
    80005378:	ffffe097          	auipc	ra,0xffffe
    8000537c:	540080e7          	jalr	1344(ra) # 800038b8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005380:	2981                	sext.w	s3,s3
    80005382:	03498a63          	beq	s3,s4,800053b6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005386:	40d0                	lw	a2,4(s1)
    80005388:	fb040593          	addi	a1,s0,-80
    8000538c:	854a                	mv	a0,s2
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	ce8080e7          	jalr	-792(ra) # 80004076 <dirlink>
    80005396:	06054b63          	bltz	a0,8000540c <create+0x152>
  iunlockput(dp);
    8000539a:	854a                	mv	a0,s2
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	848080e7          	jalr	-1976(ra) # 80003be4 <iunlockput>
  return ip;
    800053a4:	b761                	j	8000532c <create+0x72>
    panic("create: ialloc");
    800053a6:	00005517          	auipc	a0,0x5
    800053aa:	92a50513          	addi	a0,a0,-1750 # 80009cd0 <syscalls+0x2b0>
    800053ae:	ffffb097          	auipc	ra,0xffffb
    800053b2:	1b6080e7          	jalr	438(ra) # 80000564 <panic>
    dp->nlink++;  // for ".."
    800053b6:	05295783          	lhu	a5,82(s2)
    800053ba:	2785                	addiw	a5,a5,1
    800053bc:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800053c0:	854a                	mv	a0,s2
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	4f6080e7          	jalr	1270(ra) # 800038b8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ca:	40d0                	lw	a2,4(s1)
    800053cc:	00005597          	auipc	a1,0x5
    800053d0:	91458593          	addi	a1,a1,-1772 # 80009ce0 <syscalls+0x2c0>
    800053d4:	8526                	mv	a0,s1
    800053d6:	fffff097          	auipc	ra,0xfffff
    800053da:	ca0080e7          	jalr	-864(ra) # 80004076 <dirlink>
    800053de:	00054f63          	bltz	a0,800053fc <create+0x142>
    800053e2:	00492603          	lw	a2,4(s2)
    800053e6:	00005597          	auipc	a1,0x5
    800053ea:	90258593          	addi	a1,a1,-1790 # 80009ce8 <syscalls+0x2c8>
    800053ee:	8526                	mv	a0,s1
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	c86080e7          	jalr	-890(ra) # 80004076 <dirlink>
    800053f8:	f80557e3          	bgez	a0,80005386 <create+0xcc>
      panic("create dots");
    800053fc:	00005517          	auipc	a0,0x5
    80005400:	8f450513          	addi	a0,a0,-1804 # 80009cf0 <syscalls+0x2d0>
    80005404:	ffffb097          	auipc	ra,0xffffb
    80005408:	160080e7          	jalr	352(ra) # 80000564 <panic>
    panic("create: dirlink");
    8000540c:	00005517          	auipc	a0,0x5
    80005410:	8f450513          	addi	a0,a0,-1804 # 80009d00 <syscalls+0x2e0>
    80005414:	ffffb097          	auipc	ra,0xffffb
    80005418:	150080e7          	jalr	336(ra) # 80000564 <panic>
    return 0;
    8000541c:	84aa                	mv	s1,a0
    8000541e:	b739                	j	8000532c <create+0x72>

0000000080005420 <sys_dup>:
{
    80005420:	7179                	addi	sp,sp,-48
    80005422:	f406                	sd	ra,40(sp)
    80005424:	f022                	sd	s0,32(sp)
    80005426:	ec26                	sd	s1,24(sp)
    80005428:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000542a:	fd840613          	addi	a2,s0,-40
    8000542e:	4581                	li	a1,0
    80005430:	4501                	li	a0,0
    80005432:	00000097          	auipc	ra,0x0
    80005436:	dde080e7          	jalr	-546(ra) # 80005210 <argfd>
    return -1;
    8000543a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000543c:	02054363          	bltz	a0,80005462 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005440:	fd843503          	ld	a0,-40(s0)
    80005444:	00000097          	auipc	ra,0x0
    80005448:	e34080e7          	jalr	-460(ra) # 80005278 <fdalloc>
    8000544c:	84aa                	mv	s1,a0
    return -1;
    8000544e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005450:	00054963          	bltz	a0,80005462 <sys_dup+0x42>
  filedup(f);
    80005454:	fd843503          	ld	a0,-40(s0)
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	364080e7          	jalr	868(ra) # 800047bc <filedup>
  return fd;
    80005460:	87a6                	mv	a5,s1
}
    80005462:	853e                	mv	a0,a5
    80005464:	70a2                	ld	ra,40(sp)
    80005466:	7402                	ld	s0,32(sp)
    80005468:	64e2                	ld	s1,24(sp)
    8000546a:	6145                	addi	sp,sp,48
    8000546c:	8082                	ret

000000008000546e <sys_read>:
{
    8000546e:	7179                	addi	sp,sp,-48
    80005470:	f406                	sd	ra,40(sp)
    80005472:	f022                	sd	s0,32(sp)
    80005474:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005476:	fe840613          	addi	a2,s0,-24
    8000547a:	4581                	li	a1,0
    8000547c:	4501                	li	a0,0
    8000547e:	00000097          	auipc	ra,0x0
    80005482:	d92080e7          	jalr	-622(ra) # 80005210 <argfd>
    return -1;
    80005486:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005488:	04054163          	bltz	a0,800054ca <sys_read+0x5c>
    8000548c:	fe440593          	addi	a1,s0,-28
    80005490:	4509                	li	a0,2
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	980080e7          	jalr	-1664(ra) # 80002e12 <argint>
    return -1;
    8000549a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549c:	02054763          	bltz	a0,800054ca <sys_read+0x5c>
    800054a0:	fd840593          	addi	a1,s0,-40
    800054a4:	4505                	li	a0,1
    800054a6:	ffffe097          	auipc	ra,0xffffe
    800054aa:	98e080e7          	jalr	-1650(ra) # 80002e34 <argaddr>
    return -1;
    800054ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b0:	00054d63          	bltz	a0,800054ca <sys_read+0x5c>
  return fileread(f, p, n);
    800054b4:	fe442603          	lw	a2,-28(s0)
    800054b8:	fd843583          	ld	a1,-40(s0)
    800054bc:	fe843503          	ld	a0,-24(s0)
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	488080e7          	jalr	1160(ra) # 80004948 <fileread>
    800054c8:	87aa                	mv	a5,a0
}
    800054ca:	853e                	mv	a0,a5
    800054cc:	70a2                	ld	ra,40(sp)
    800054ce:	7402                	ld	s0,32(sp)
    800054d0:	6145                	addi	sp,sp,48
    800054d2:	8082                	ret

00000000800054d4 <sys_write>:
{
    800054d4:	7179                	addi	sp,sp,-48
    800054d6:	f406                	sd	ra,40(sp)
    800054d8:	f022                	sd	s0,32(sp)
    800054da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054dc:	fe840613          	addi	a2,s0,-24
    800054e0:	4581                	li	a1,0
    800054e2:	4501                	li	a0,0
    800054e4:	00000097          	auipc	ra,0x0
    800054e8:	d2c080e7          	jalr	-724(ra) # 80005210 <argfd>
    return -1;
    800054ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ee:	04054163          	bltz	a0,80005530 <sys_write+0x5c>
    800054f2:	fe440593          	addi	a1,s0,-28
    800054f6:	4509                	li	a0,2
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	91a080e7          	jalr	-1766(ra) # 80002e12 <argint>
    return -1;
    80005500:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005502:	02054763          	bltz	a0,80005530 <sys_write+0x5c>
    80005506:	fd840593          	addi	a1,s0,-40
    8000550a:	4505                	li	a0,1
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	928080e7          	jalr	-1752(ra) # 80002e34 <argaddr>
    return -1;
    80005514:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005516:	00054d63          	bltz	a0,80005530 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000551a:	fe442603          	lw	a2,-28(s0)
    8000551e:	fd843583          	ld	a1,-40(s0)
    80005522:	fe843503          	ld	a0,-24(s0)
    80005526:	fffff097          	auipc	ra,0xfffff
    8000552a:	4e8080e7          	jalr	1256(ra) # 80004a0e <filewrite>
    8000552e:	87aa                	mv	a5,a0
}
    80005530:	853e                	mv	a0,a5
    80005532:	70a2                	ld	ra,40(sp)
    80005534:	7402                	ld	s0,32(sp)
    80005536:	6145                	addi	sp,sp,48
    80005538:	8082                	ret

000000008000553a <sys_close>:
{
    8000553a:	1101                	addi	sp,sp,-32
    8000553c:	ec06                	sd	ra,24(sp)
    8000553e:	e822                	sd	s0,16(sp)
    80005540:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005542:	fe040613          	addi	a2,s0,-32
    80005546:	fec40593          	addi	a1,s0,-20
    8000554a:	4501                	li	a0,0
    8000554c:	00000097          	auipc	ra,0x0
    80005550:	cc4080e7          	jalr	-828(ra) # 80005210 <argfd>
    return -1;
    80005554:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005556:	02054463          	bltz	a0,8000557e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000555a:	ffffc097          	auipc	ra,0xffffc
    8000555e:	5f6080e7          	jalr	1526(ra) # 80001b50 <myproc>
    80005562:	fec42783          	lw	a5,-20(s0)
    80005566:	07e9                	addi	a5,a5,26
    80005568:	078e                	slli	a5,a5,0x3
    8000556a:	97aa                	add	a5,a5,a0
    8000556c:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005570:	fe043503          	ld	a0,-32(s0)
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	29a080e7          	jalr	666(ra) # 8000480e <fileclose>
  return 0;
    8000557c:	4781                	li	a5,0
}
    8000557e:	853e                	mv	a0,a5
    80005580:	60e2                	ld	ra,24(sp)
    80005582:	6442                	ld	s0,16(sp)
    80005584:	6105                	addi	sp,sp,32
    80005586:	8082                	ret

0000000080005588 <sys_fstat>:
{
    80005588:	1101                	addi	sp,sp,-32
    8000558a:	ec06                	sd	ra,24(sp)
    8000558c:	e822                	sd	s0,16(sp)
    8000558e:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005590:	fe840613          	addi	a2,s0,-24
    80005594:	4581                	li	a1,0
    80005596:	4501                	li	a0,0
    80005598:	00000097          	auipc	ra,0x0
    8000559c:	c78080e7          	jalr	-904(ra) # 80005210 <argfd>
    return -1;
    800055a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055a2:	02054563          	bltz	a0,800055cc <sys_fstat+0x44>
    800055a6:	fe040593          	addi	a1,s0,-32
    800055aa:	4505                	li	a0,1
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	888080e7          	jalr	-1912(ra) # 80002e34 <argaddr>
    return -1;
    800055b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055b6:	00054b63          	bltz	a0,800055cc <sys_fstat+0x44>
  return filestat(f, st);
    800055ba:	fe043583          	ld	a1,-32(s0)
    800055be:	fe843503          	ld	a0,-24(s0)
    800055c2:	fffff097          	auipc	ra,0xfffff
    800055c6:	314080e7          	jalr	788(ra) # 800048d6 <filestat>
    800055ca:	87aa                	mv	a5,a0
}
    800055cc:	853e                	mv	a0,a5
    800055ce:	60e2                	ld	ra,24(sp)
    800055d0:	6442                	ld	s0,16(sp)
    800055d2:	6105                	addi	sp,sp,32
    800055d4:	8082                	ret

00000000800055d6 <sys_link>:
{
    800055d6:	7169                	addi	sp,sp,-304
    800055d8:	f606                	sd	ra,296(sp)
    800055da:	f222                	sd	s0,288(sp)
    800055dc:	ee26                	sd	s1,280(sp)
    800055de:	ea4a                	sd	s2,272(sp)
    800055e0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e2:	08000613          	li	a2,128
    800055e6:	ed040593          	addi	a1,s0,-304
    800055ea:	4501                	li	a0,0
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	86a080e7          	jalr	-1942(ra) # 80002e56 <argstr>
    return -1;
    800055f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055f6:	10054e63          	bltz	a0,80005712 <sys_link+0x13c>
    800055fa:	08000613          	li	a2,128
    800055fe:	f5040593          	addi	a1,s0,-176
    80005602:	4505                	li	a0,1
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	852080e7          	jalr	-1966(ra) # 80002e56 <argstr>
    return -1;
    8000560c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000560e:	10054263          	bltz	a0,80005712 <sys_link+0x13c>
  begin_op();
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	d32080e7          	jalr	-718(ra) # 80004344 <begin_op>
  if((ip = namei(old)) == 0){
    8000561a:	ed040513          	addi	a0,s0,-304
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	b1a080e7          	jalr	-1254(ra) # 80004138 <namei>
    80005626:	84aa                	mv	s1,a0
    80005628:	c551                	beqz	a0,800056b4 <sys_link+0xde>
  ilock(ip);
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	358080e7          	jalr	856(ra) # 80003982 <ilock>
  if(ip->type == T_DIR){
    80005632:	04c49703          	lh	a4,76(s1)
    80005636:	4785                	li	a5,1
    80005638:	08f70463          	beq	a4,a5,800056c0 <sys_link+0xea>
  ip->nlink++;
    8000563c:	0524d783          	lhu	a5,82(s1)
    80005640:	2785                	addiw	a5,a5,1
    80005642:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	270080e7          	jalr	624(ra) # 800038b8 <iupdate>
  iunlock(ip);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	3f2080e7          	jalr	1010(ra) # 80003a44 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000565a:	fd040593          	addi	a1,s0,-48
    8000565e:	f5040513          	addi	a0,s0,-176
    80005662:	fffff097          	auipc	ra,0xfffff
    80005666:	af4080e7          	jalr	-1292(ra) # 80004156 <nameiparent>
    8000566a:	892a                	mv	s2,a0
    8000566c:	c935                	beqz	a0,800056e0 <sys_link+0x10a>
  ilock(dp);
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	314080e7          	jalr	788(ra) # 80003982 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005676:	00092703          	lw	a4,0(s2)
    8000567a:	409c                	lw	a5,0(s1)
    8000567c:	04f71d63          	bne	a4,a5,800056d6 <sys_link+0x100>
    80005680:	40d0                	lw	a2,4(s1)
    80005682:	fd040593          	addi	a1,s0,-48
    80005686:	854a                	mv	a0,s2
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	9ee080e7          	jalr	-1554(ra) # 80004076 <dirlink>
    80005690:	04054363          	bltz	a0,800056d6 <sys_link+0x100>
  iunlockput(dp);
    80005694:	854a                	mv	a0,s2
    80005696:	ffffe097          	auipc	ra,0xffffe
    8000569a:	54e080e7          	jalr	1358(ra) # 80003be4 <iunlockput>
  iput(ip);
    8000569e:	8526                	mv	a0,s1
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	49c080e7          	jalr	1180(ra) # 80003b3c <iput>
  end_op();
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	d1c080e7          	jalr	-740(ra) # 800043c4 <end_op>
  return 0;
    800056b0:	4781                	li	a5,0
    800056b2:	a085                	j	80005712 <sys_link+0x13c>
    end_op();
    800056b4:	fffff097          	auipc	ra,0xfffff
    800056b8:	d10080e7          	jalr	-752(ra) # 800043c4 <end_op>
    return -1;
    800056bc:	57fd                	li	a5,-1
    800056be:	a891                	j	80005712 <sys_link+0x13c>
    iunlockput(ip);
    800056c0:	8526                	mv	a0,s1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	522080e7          	jalr	1314(ra) # 80003be4 <iunlockput>
    end_op();
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	cfa080e7          	jalr	-774(ra) # 800043c4 <end_op>
    return -1;
    800056d2:	57fd                	li	a5,-1
    800056d4:	a83d                	j	80005712 <sys_link+0x13c>
    iunlockput(dp);
    800056d6:	854a                	mv	a0,s2
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	50c080e7          	jalr	1292(ra) # 80003be4 <iunlockput>
  ilock(ip);
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	2a0080e7          	jalr	672(ra) # 80003982 <ilock>
  ip->nlink--;
    800056ea:	0524d783          	lhu	a5,82(s1)
    800056ee:	37fd                	addiw	a5,a5,-1
    800056f0:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800056f4:	8526                	mv	a0,s1
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	1c2080e7          	jalr	450(ra) # 800038b8 <iupdate>
  iunlockput(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	4e4080e7          	jalr	1252(ra) # 80003be4 <iunlockput>
  end_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	cbc080e7          	jalr	-836(ra) # 800043c4 <end_op>
  return -1;
    80005710:	57fd                	li	a5,-1
}
    80005712:	853e                	mv	a0,a5
    80005714:	70b2                	ld	ra,296(sp)
    80005716:	7412                	ld	s0,288(sp)
    80005718:	64f2                	ld	s1,280(sp)
    8000571a:	6952                	ld	s2,272(sp)
    8000571c:	6155                	addi	sp,sp,304
    8000571e:	8082                	ret

0000000080005720 <sys_unlink>:
{
    80005720:	7151                	addi	sp,sp,-240
    80005722:	f586                	sd	ra,232(sp)
    80005724:	f1a2                	sd	s0,224(sp)
    80005726:	eda6                	sd	s1,216(sp)
    80005728:	e9ca                	sd	s2,208(sp)
    8000572a:	e5ce                	sd	s3,200(sp)
    8000572c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000572e:	08000613          	li	a2,128
    80005732:	f3040593          	addi	a1,s0,-208
    80005736:	4501                	li	a0,0
    80005738:	ffffd097          	auipc	ra,0xffffd
    8000573c:	71e080e7          	jalr	1822(ra) # 80002e56 <argstr>
    80005740:	18054163          	bltz	a0,800058c2 <sys_unlink+0x1a2>
  begin_op();
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	c00080e7          	jalr	-1024(ra) # 80004344 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000574c:	fb040593          	addi	a1,s0,-80
    80005750:	f3040513          	addi	a0,s0,-208
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	a02080e7          	jalr	-1534(ra) # 80004156 <nameiparent>
    8000575c:	84aa                	mv	s1,a0
    8000575e:	c979                	beqz	a0,80005834 <sys_unlink+0x114>
  ilock(dp);
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	222080e7          	jalr	546(ra) # 80003982 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005768:	00004597          	auipc	a1,0x4
    8000576c:	57858593          	addi	a1,a1,1400 # 80009ce0 <syscalls+0x2c0>
    80005770:	fb040513          	addi	a0,s0,-80
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	6d8080e7          	jalr	1752(ra) # 80003e4c <namecmp>
    8000577c:	14050a63          	beqz	a0,800058d0 <sys_unlink+0x1b0>
    80005780:	00004597          	auipc	a1,0x4
    80005784:	56858593          	addi	a1,a1,1384 # 80009ce8 <syscalls+0x2c8>
    80005788:	fb040513          	addi	a0,s0,-80
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	6c0080e7          	jalr	1728(ra) # 80003e4c <namecmp>
    80005794:	12050e63          	beqz	a0,800058d0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005798:	f2c40613          	addi	a2,s0,-212
    8000579c:	fb040593          	addi	a1,s0,-80
    800057a0:	8526                	mv	a0,s1
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	6c4080e7          	jalr	1732(ra) # 80003e66 <dirlookup>
    800057aa:	892a                	mv	s2,a0
    800057ac:	12050263          	beqz	a0,800058d0 <sys_unlink+0x1b0>
  ilock(ip);
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	1d2080e7          	jalr	466(ra) # 80003982 <ilock>
  if(ip->nlink < 1)
    800057b8:	05291783          	lh	a5,82(s2)
    800057bc:	08f05263          	blez	a5,80005840 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057c0:	04c91703          	lh	a4,76(s2)
    800057c4:	4785                	li	a5,1
    800057c6:	08f70563          	beq	a4,a5,80005850 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057ca:	4641                	li	a2,16
    800057cc:	4581                	li	a1,0
    800057ce:	fc040513          	addi	a0,s0,-64
    800057d2:	ffffb097          	auipc	ra,0xffffb
    800057d6:	6a4080e7          	jalr	1700(ra) # 80000e76 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057da:	4741                	li	a4,16
    800057dc:	f2c42683          	lw	a3,-212(s0)
    800057e0:	fc040613          	addi	a2,s0,-64
    800057e4:	4581                	li	a1,0
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	546080e7          	jalr	1350(ra) # 80003d2e <writei>
    800057f0:	47c1                	li	a5,16
    800057f2:	0af51563          	bne	a0,a5,8000589c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057f6:	04c91703          	lh	a4,76(s2)
    800057fa:	4785                	li	a5,1
    800057fc:	0af70863          	beq	a4,a5,800058ac <sys_unlink+0x18c>
  iunlockput(dp);
    80005800:	8526                	mv	a0,s1
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	3e2080e7          	jalr	994(ra) # 80003be4 <iunlockput>
  ip->nlink--;
    8000580a:	05295783          	lhu	a5,82(s2)
    8000580e:	37fd                	addiw	a5,a5,-1
    80005810:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005814:	854a                	mv	a0,s2
    80005816:	ffffe097          	auipc	ra,0xffffe
    8000581a:	0a2080e7          	jalr	162(ra) # 800038b8 <iupdate>
  iunlockput(ip);
    8000581e:	854a                	mv	a0,s2
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	3c4080e7          	jalr	964(ra) # 80003be4 <iunlockput>
  end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	b9c080e7          	jalr	-1124(ra) # 800043c4 <end_op>
  return 0;
    80005830:	4501                	li	a0,0
    80005832:	a84d                	j	800058e4 <sys_unlink+0x1c4>
    end_op();
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	b90080e7          	jalr	-1136(ra) # 800043c4 <end_op>
    return -1;
    8000583c:	557d                	li	a0,-1
    8000583e:	a05d                	j	800058e4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005840:	00004517          	auipc	a0,0x4
    80005844:	4d050513          	addi	a0,a0,1232 # 80009d10 <syscalls+0x2f0>
    80005848:	ffffb097          	auipc	ra,0xffffb
    8000584c:	d1c080e7          	jalr	-740(ra) # 80000564 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005850:	05492703          	lw	a4,84(s2)
    80005854:	02000793          	li	a5,32
    80005858:	f6e7f9e3          	bgeu	a5,a4,800057ca <sys_unlink+0xaa>
    8000585c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005860:	4741                	li	a4,16
    80005862:	86ce                	mv	a3,s3
    80005864:	f1840613          	addi	a2,s0,-232
    80005868:	4581                	li	a1,0
    8000586a:	854a                	mv	a0,s2
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	3ca080e7          	jalr	970(ra) # 80003c36 <readi>
    80005874:	47c1                	li	a5,16
    80005876:	00f51b63          	bne	a0,a5,8000588c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000587a:	f1845783          	lhu	a5,-232(s0)
    8000587e:	e7a1                	bnez	a5,800058c6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005880:	29c1                	addiw	s3,s3,16
    80005882:	05492783          	lw	a5,84(s2)
    80005886:	fcf9ede3          	bltu	s3,a5,80005860 <sys_unlink+0x140>
    8000588a:	b781                	j	800057ca <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000588c:	00004517          	auipc	a0,0x4
    80005890:	49c50513          	addi	a0,a0,1180 # 80009d28 <syscalls+0x308>
    80005894:	ffffb097          	auipc	ra,0xffffb
    80005898:	cd0080e7          	jalr	-816(ra) # 80000564 <panic>
    panic("unlink: writei");
    8000589c:	00004517          	auipc	a0,0x4
    800058a0:	4a450513          	addi	a0,a0,1188 # 80009d40 <syscalls+0x320>
    800058a4:	ffffb097          	auipc	ra,0xffffb
    800058a8:	cc0080e7          	jalr	-832(ra) # 80000564 <panic>
    dp->nlink--;
    800058ac:	0524d783          	lhu	a5,82(s1)
    800058b0:	37fd                	addiw	a5,a5,-1
    800058b2:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	000080e7          	jalr	ra # 800038b8 <iupdate>
    800058c0:	b781                	j	80005800 <sys_unlink+0xe0>
    return -1;
    800058c2:	557d                	li	a0,-1
    800058c4:	a005                	j	800058e4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058c6:	854a                	mv	a0,s2
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	31c080e7          	jalr	796(ra) # 80003be4 <iunlockput>
  iunlockput(dp);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	312080e7          	jalr	786(ra) # 80003be4 <iunlockput>
  end_op();
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	aea080e7          	jalr	-1302(ra) # 800043c4 <end_op>
  return -1;
    800058e2:	557d                	li	a0,-1
}
    800058e4:	70ae                	ld	ra,232(sp)
    800058e6:	740e                	ld	s0,224(sp)
    800058e8:	64ee                	ld	s1,216(sp)
    800058ea:	694e                	ld	s2,208(sp)
    800058ec:	69ae                	ld	s3,200(sp)
    800058ee:	616d                	addi	sp,sp,240
    800058f0:	8082                	ret

00000000800058f2 <sys_open>:

uint64
sys_open(void)
{
    800058f2:	7131                	addi	sp,sp,-192
    800058f4:	fd06                	sd	ra,184(sp)
    800058f6:	f922                	sd	s0,176(sp)
    800058f8:	f526                	sd	s1,168(sp)
    800058fa:	f14a                	sd	s2,160(sp)
    800058fc:	ed4e                	sd	s3,152(sp)
    800058fe:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005900:	08000613          	li	a2,128
    80005904:	f5040593          	addi	a1,s0,-176
    80005908:	4501                	li	a0,0
    8000590a:	ffffd097          	auipc	ra,0xffffd
    8000590e:	54c080e7          	jalr	1356(ra) # 80002e56 <argstr>
    return -1;
    80005912:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005914:	0c054163          	bltz	a0,800059d6 <sys_open+0xe4>
    80005918:	f4c40593          	addi	a1,s0,-180
    8000591c:	4505                	li	a0,1
    8000591e:	ffffd097          	auipc	ra,0xffffd
    80005922:	4f4080e7          	jalr	1268(ra) # 80002e12 <argint>
    80005926:	0a054863          	bltz	a0,800059d6 <sys_open+0xe4>

  begin_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	a1a080e7          	jalr	-1510(ra) # 80004344 <begin_op>

  if(omode & O_CREATE){
    80005932:	f4c42783          	lw	a5,-180(s0)
    80005936:	2007f793          	andi	a5,a5,512
    8000593a:	cbdd                	beqz	a5,800059f0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000593c:	4681                	li	a3,0
    8000593e:	4601                	li	a2,0
    80005940:	4589                	li	a1,2
    80005942:	f5040513          	addi	a0,s0,-176
    80005946:	00000097          	auipc	ra,0x0
    8000594a:	974080e7          	jalr	-1676(ra) # 800052ba <create>
    8000594e:	892a                	mv	s2,a0
    if(ip == 0){
    80005950:	c959                	beqz	a0,800059e6 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005952:	04c91703          	lh	a4,76(s2)
    80005956:	478d                	li	a5,3
    80005958:	00f71763          	bne	a4,a5,80005966 <sys_open+0x74>
    8000595c:	04e95703          	lhu	a4,78(s2)
    80005960:	47a5                	li	a5,9
    80005962:	0ce7ec63          	bltu	a5,a4,80005a3a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	dec080e7          	jalr	-532(ra) # 80004752 <filealloc>
    8000596e:	89aa                	mv	s3,a0
    80005970:	10050663          	beqz	a0,80005a7c <sys_open+0x18a>
    80005974:	00000097          	auipc	ra,0x0
    80005978:	904080e7          	jalr	-1788(ra) # 80005278 <fdalloc>
    8000597c:	84aa                	mv	s1,a0
    8000597e:	0e054a63          	bltz	a0,80005a72 <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005982:	04c91703          	lh	a4,76(s2)
    80005986:	478d                	li	a5,3
    80005988:	0cf70463          	beq	a4,a5,80005a50 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    8000598c:	4789                	li	a5,2
    8000598e:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005992:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005996:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    8000599a:	f4c42783          	lw	a5,-180(s0)
    8000599e:	0017c713          	xori	a4,a5,1
    800059a2:	8b05                	andi	a4,a4,1
    800059a4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059a8:	0037f713          	andi	a4,a5,3
    800059ac:	00e03733          	snez	a4,a4
    800059b0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059b4:	4007f793          	andi	a5,a5,1024
    800059b8:	c791                	beqz	a5,800059c4 <sys_open+0xd2>
    800059ba:	04c91703          	lh	a4,76(s2)
    800059be:	4789                	li	a5,2
    800059c0:	0af70363          	beq	a4,a5,80005a66 <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    800059c4:	854a                	mv	a0,s2
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	07e080e7          	jalr	126(ra) # 80003a44 <iunlock>
  end_op();
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	9f6080e7          	jalr	-1546(ra) # 800043c4 <end_op>

  return fd;
}
    800059d6:	8526                	mv	a0,s1
    800059d8:	70ea                	ld	ra,184(sp)
    800059da:	744a                	ld	s0,176(sp)
    800059dc:	74aa                	ld	s1,168(sp)
    800059de:	790a                	ld	s2,160(sp)
    800059e0:	69ea                	ld	s3,152(sp)
    800059e2:	6129                	addi	sp,sp,192
    800059e4:	8082                	ret
      end_op();
    800059e6:	fffff097          	auipc	ra,0xfffff
    800059ea:	9de080e7          	jalr	-1570(ra) # 800043c4 <end_op>
      return -1;
    800059ee:	b7e5                	j	800059d6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059f0:	f5040513          	addi	a0,s0,-176
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	744080e7          	jalr	1860(ra) # 80004138 <namei>
    800059fc:	892a                	mv	s2,a0
    800059fe:	c905                	beqz	a0,80005a2e <sys_open+0x13c>
    ilock(ip);
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	f82080e7          	jalr	-126(ra) # 80003982 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a08:	04c91703          	lh	a4,76(s2)
    80005a0c:	4785                	li	a5,1
    80005a0e:	f4f712e3          	bne	a4,a5,80005952 <sys_open+0x60>
    80005a12:	f4c42783          	lw	a5,-180(s0)
    80005a16:	dba1                	beqz	a5,80005966 <sys_open+0x74>
      iunlockput(ip);
    80005a18:	854a                	mv	a0,s2
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	1ca080e7          	jalr	458(ra) # 80003be4 <iunlockput>
      end_op();
    80005a22:	fffff097          	auipc	ra,0xfffff
    80005a26:	9a2080e7          	jalr	-1630(ra) # 800043c4 <end_op>
      return -1;
    80005a2a:	54fd                	li	s1,-1
    80005a2c:	b76d                	j	800059d6 <sys_open+0xe4>
      end_op();
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	996080e7          	jalr	-1642(ra) # 800043c4 <end_op>
      return -1;
    80005a36:	54fd                	li	s1,-1
    80005a38:	bf79                	j	800059d6 <sys_open+0xe4>
    iunlockput(ip);
    80005a3a:	854a                	mv	a0,s2
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	1a8080e7          	jalr	424(ra) # 80003be4 <iunlockput>
    end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	980080e7          	jalr	-1664(ra) # 800043c4 <end_op>
    return -1;
    80005a4c:	54fd                	li	s1,-1
    80005a4e:	b761                	j	800059d6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a50:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a54:	04e91783          	lh	a5,78(s2)
    80005a58:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005a5c:	05091783          	lh	a5,80(s2)
    80005a60:	02f99323          	sh	a5,38(s3)
    80005a64:	b73d                	j	80005992 <sys_open+0xa0>
    itrunc(ip);
    80005a66:	854a                	mv	a0,s2
    80005a68:	ffffe097          	auipc	ra,0xffffe
    80005a6c:	028080e7          	jalr	40(ra) # 80003a90 <itrunc>
    80005a70:	bf91                	j	800059c4 <sys_open+0xd2>
      fileclose(f);
    80005a72:	854e                	mv	a0,s3
    80005a74:	fffff097          	auipc	ra,0xfffff
    80005a78:	d9a080e7          	jalr	-614(ra) # 8000480e <fileclose>
    iunlockput(ip);
    80005a7c:	854a                	mv	a0,s2
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	166080e7          	jalr	358(ra) # 80003be4 <iunlockput>
    end_op();
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	93e080e7          	jalr	-1730(ra) # 800043c4 <end_op>
    return -1;
    80005a8e:	54fd                	li	s1,-1
    80005a90:	b799                	j	800059d6 <sys_open+0xe4>

0000000080005a92 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a92:	7175                	addi	sp,sp,-144
    80005a94:	e506                	sd	ra,136(sp)
    80005a96:	e122                	sd	s0,128(sp)
    80005a98:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a9a:	fffff097          	auipc	ra,0xfffff
    80005a9e:	8aa080e7          	jalr	-1878(ra) # 80004344 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005aa2:	08000613          	li	a2,128
    80005aa6:	f7040593          	addi	a1,s0,-144
    80005aaa:	4501                	li	a0,0
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	3aa080e7          	jalr	938(ra) # 80002e56 <argstr>
    80005ab4:	02054963          	bltz	a0,80005ae6 <sys_mkdir+0x54>
    80005ab8:	4681                	li	a3,0
    80005aba:	4601                	li	a2,0
    80005abc:	4585                	li	a1,1
    80005abe:	f7040513          	addi	a0,s0,-144
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	7f8080e7          	jalr	2040(ra) # 800052ba <create>
    80005aca:	cd11                	beqz	a0,80005ae6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	118080e7          	jalr	280(ra) # 80003be4 <iunlockput>
  end_op();
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	8f0080e7          	jalr	-1808(ra) # 800043c4 <end_op>
  return 0;
    80005adc:	4501                	li	a0,0
}
    80005ade:	60aa                	ld	ra,136(sp)
    80005ae0:	640a                	ld	s0,128(sp)
    80005ae2:	6149                	addi	sp,sp,144
    80005ae4:	8082                	ret
    end_op();
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	8de080e7          	jalr	-1826(ra) # 800043c4 <end_op>
    return -1;
    80005aee:	557d                	li	a0,-1
    80005af0:	b7fd                	j	80005ade <sys_mkdir+0x4c>

0000000080005af2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005af2:	7135                	addi	sp,sp,-160
    80005af4:	ed06                	sd	ra,152(sp)
    80005af6:	e922                	sd	s0,144(sp)
    80005af8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	84a080e7          	jalr	-1974(ra) # 80004344 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b02:	08000613          	li	a2,128
    80005b06:	f7040593          	addi	a1,s0,-144
    80005b0a:	4501                	li	a0,0
    80005b0c:	ffffd097          	auipc	ra,0xffffd
    80005b10:	34a080e7          	jalr	842(ra) # 80002e56 <argstr>
    80005b14:	04054a63          	bltz	a0,80005b68 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b18:	f6c40593          	addi	a1,s0,-148
    80005b1c:	4505                	li	a0,1
    80005b1e:	ffffd097          	auipc	ra,0xffffd
    80005b22:	2f4080e7          	jalr	756(ra) # 80002e12 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b26:	04054163          	bltz	a0,80005b68 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b2a:	f6840593          	addi	a1,s0,-152
    80005b2e:	4509                	li	a0,2
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	2e2080e7          	jalr	738(ra) # 80002e12 <argint>
     argint(1, &major) < 0 ||
    80005b38:	02054863          	bltz	a0,80005b68 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b3c:	f6841683          	lh	a3,-152(s0)
    80005b40:	f6c41603          	lh	a2,-148(s0)
    80005b44:	458d                	li	a1,3
    80005b46:	f7040513          	addi	a0,s0,-144
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	770080e7          	jalr	1904(ra) # 800052ba <create>
     argint(2, &minor) < 0 ||
    80005b52:	c919                	beqz	a0,80005b68 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b54:	ffffe097          	auipc	ra,0xffffe
    80005b58:	090080e7          	jalr	144(ra) # 80003be4 <iunlockput>
  end_op();
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	868080e7          	jalr	-1944(ra) # 800043c4 <end_op>
  return 0;
    80005b64:	4501                	li	a0,0
    80005b66:	a031                	j	80005b72 <sys_mknod+0x80>
    end_op();
    80005b68:	fffff097          	auipc	ra,0xfffff
    80005b6c:	85c080e7          	jalr	-1956(ra) # 800043c4 <end_op>
    return -1;
    80005b70:	557d                	li	a0,-1
}
    80005b72:	60ea                	ld	ra,152(sp)
    80005b74:	644a                	ld	s0,144(sp)
    80005b76:	610d                	addi	sp,sp,160
    80005b78:	8082                	ret

0000000080005b7a <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b7a:	7135                	addi	sp,sp,-160
    80005b7c:	ed06                	sd	ra,152(sp)
    80005b7e:	e922                	sd	s0,144(sp)
    80005b80:	e526                	sd	s1,136(sp)
    80005b82:	e14a                	sd	s2,128(sp)
    80005b84:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b86:	ffffc097          	auipc	ra,0xffffc
    80005b8a:	fca080e7          	jalr	-54(ra) # 80001b50 <myproc>
    80005b8e:	892a                	mv	s2,a0
  
  begin_op();
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	7b4080e7          	jalr	1972(ra) # 80004344 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b98:	08000613          	li	a2,128
    80005b9c:	f6040593          	addi	a1,s0,-160
    80005ba0:	4501                	li	a0,0
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	2b4080e7          	jalr	692(ra) # 80002e56 <argstr>
    80005baa:	04054b63          	bltz	a0,80005c00 <sys_chdir+0x86>
    80005bae:	f6040513          	addi	a0,s0,-160
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	586080e7          	jalr	1414(ra) # 80004138 <namei>
    80005bba:	84aa                	mv	s1,a0
    80005bbc:	c131                	beqz	a0,80005c00 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bbe:	ffffe097          	auipc	ra,0xffffe
    80005bc2:	dc4080e7          	jalr	-572(ra) # 80003982 <ilock>
  if(ip->type != T_DIR){
    80005bc6:	04c49703          	lh	a4,76(s1)
    80005bca:	4785                	li	a5,1
    80005bcc:	04f71063          	bne	a4,a5,80005c0c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bd0:	8526                	mv	a0,s1
    80005bd2:	ffffe097          	auipc	ra,0xffffe
    80005bd6:	e72080e7          	jalr	-398(ra) # 80003a44 <iunlock>
  iput(p->cwd);
    80005bda:	15893503          	ld	a0,344(s2)
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	f5e080e7          	jalr	-162(ra) # 80003b3c <iput>
  end_op();
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	7de080e7          	jalr	2014(ra) # 800043c4 <end_op>
  p->cwd = ip;
    80005bee:	14993c23          	sd	s1,344(s2)
  return 0;
    80005bf2:	4501                	li	a0,0
}
    80005bf4:	60ea                	ld	ra,152(sp)
    80005bf6:	644a                	ld	s0,144(sp)
    80005bf8:	64aa                	ld	s1,136(sp)
    80005bfa:	690a                	ld	s2,128(sp)
    80005bfc:	610d                	addi	sp,sp,160
    80005bfe:	8082                	ret
    end_op();
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	7c4080e7          	jalr	1988(ra) # 800043c4 <end_op>
    return -1;
    80005c08:	557d                	li	a0,-1
    80005c0a:	b7ed                	j	80005bf4 <sys_chdir+0x7a>
    iunlockput(ip);
    80005c0c:	8526                	mv	a0,s1
    80005c0e:	ffffe097          	auipc	ra,0xffffe
    80005c12:	fd6080e7          	jalr	-42(ra) # 80003be4 <iunlockput>
    end_op();
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	7ae080e7          	jalr	1966(ra) # 800043c4 <end_op>
    return -1;
    80005c1e:	557d                	li	a0,-1
    80005c20:	bfd1                	j	80005bf4 <sys_chdir+0x7a>

0000000080005c22 <sys_exec>:

uint64
sys_exec(void)
{
    80005c22:	7145                	addi	sp,sp,-464
    80005c24:	e786                	sd	ra,456(sp)
    80005c26:	e3a2                	sd	s0,448(sp)
    80005c28:	ff26                	sd	s1,440(sp)
    80005c2a:	fb4a                	sd	s2,432(sp)
    80005c2c:	f74e                	sd	s3,424(sp)
    80005c2e:	f352                	sd	s4,416(sp)
    80005c30:	ef56                	sd	s5,408(sp)
    80005c32:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c34:	08000613          	li	a2,128
    80005c38:	f4040593          	addi	a1,s0,-192
    80005c3c:	4501                	li	a0,0
    80005c3e:	ffffd097          	auipc	ra,0xffffd
    80005c42:	218080e7          	jalr	536(ra) # 80002e56 <argstr>
    return -1;
    80005c46:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c48:	0c054a63          	bltz	a0,80005d1c <sys_exec+0xfa>
    80005c4c:	e3840593          	addi	a1,s0,-456
    80005c50:	4505                	li	a0,1
    80005c52:	ffffd097          	auipc	ra,0xffffd
    80005c56:	1e2080e7          	jalr	482(ra) # 80002e34 <argaddr>
    80005c5a:	0c054163          	bltz	a0,80005d1c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c5e:	10000613          	li	a2,256
    80005c62:	4581                	li	a1,0
    80005c64:	e4040513          	addi	a0,s0,-448
    80005c68:	ffffb097          	auipc	ra,0xffffb
    80005c6c:	20e080e7          	jalr	526(ra) # 80000e76 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c70:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c74:	89a6                	mv	s3,s1
    80005c76:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c78:	02000a13          	li	s4,32
    80005c7c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c80:	00391793          	slli	a5,s2,0x3
    80005c84:	e3040593          	addi	a1,s0,-464
    80005c88:	e3843503          	ld	a0,-456(s0)
    80005c8c:	953e                	add	a0,a0,a5
    80005c8e:	ffffd097          	auipc	ra,0xffffd
    80005c92:	0ea080e7          	jalr	234(ra) # 80002d78 <fetchaddr>
    80005c96:	02054a63          	bltz	a0,80005cca <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c9a:	e3043783          	ld	a5,-464(s0)
    80005c9e:	c3b9                	beqz	a5,80005ce4 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ca0:	ffffb097          	auipc	ra,0xffffb
    80005ca4:	da2080e7          	jalr	-606(ra) # 80000a42 <kalloc>
    80005ca8:	85aa                	mv	a1,a0
    80005caa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cae:	cd11                	beqz	a0,80005cca <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cb0:	6605                	lui	a2,0x1
    80005cb2:	e3043503          	ld	a0,-464(s0)
    80005cb6:	ffffd097          	auipc	ra,0xffffd
    80005cba:	114080e7          	jalr	276(ra) # 80002dca <fetchstr>
    80005cbe:	00054663          	bltz	a0,80005cca <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005cc2:	0905                	addi	s2,s2,1
    80005cc4:	09a1                	addi	s3,s3,8
    80005cc6:	fb491be3          	bne	s2,s4,80005c7c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cca:	10048913          	addi	s2,s1,256
    80005cce:	6088                	ld	a0,0(s1)
    80005cd0:	c529                	beqz	a0,80005d1a <sys_exec+0xf8>
    kfree(argv[i]);
    80005cd2:	ffffb097          	auipc	ra,0xffffb
    80005cd6:	c6a080e7          	jalr	-918(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cda:	04a1                	addi	s1,s1,8
    80005cdc:	ff2499e3          	bne	s1,s2,80005cce <sys_exec+0xac>
  return -1;
    80005ce0:	597d                	li	s2,-1
    80005ce2:	a82d                	j	80005d1c <sys_exec+0xfa>
      argv[i] = 0;
    80005ce4:	0a8e                	slli	s5,s5,0x3
    80005ce6:	fc040793          	addi	a5,s0,-64
    80005cea:	9abe                	add	s5,s5,a5
    80005cec:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc6ab0>
  int ret = exec(path, argv);
    80005cf0:	e4040593          	addi	a1,s0,-448
    80005cf4:	f4040513          	addi	a0,s0,-192
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	170080e7          	jalr	368(ra) # 80004e68 <exec>
    80005d00:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d02:	10048993          	addi	s3,s1,256
    80005d06:	6088                	ld	a0,0(s1)
    80005d08:	c911                	beqz	a0,80005d1c <sys_exec+0xfa>
    kfree(argv[i]);
    80005d0a:	ffffb097          	auipc	ra,0xffffb
    80005d0e:	c32080e7          	jalr	-974(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d12:	04a1                	addi	s1,s1,8
    80005d14:	ff3499e3          	bne	s1,s3,80005d06 <sys_exec+0xe4>
    80005d18:	a011                	j	80005d1c <sys_exec+0xfa>
  return -1;
    80005d1a:	597d                	li	s2,-1
}
    80005d1c:	854a                	mv	a0,s2
    80005d1e:	60be                	ld	ra,456(sp)
    80005d20:	641e                	ld	s0,448(sp)
    80005d22:	74fa                	ld	s1,440(sp)
    80005d24:	795a                	ld	s2,432(sp)
    80005d26:	79ba                	ld	s3,424(sp)
    80005d28:	7a1a                	ld	s4,416(sp)
    80005d2a:	6afa                	ld	s5,408(sp)
    80005d2c:	6179                	addi	sp,sp,464
    80005d2e:	8082                	ret

0000000080005d30 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d30:	7139                	addi	sp,sp,-64
    80005d32:	fc06                	sd	ra,56(sp)
    80005d34:	f822                	sd	s0,48(sp)
    80005d36:	f426                	sd	s1,40(sp)
    80005d38:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d3a:	ffffc097          	auipc	ra,0xffffc
    80005d3e:	e16080e7          	jalr	-490(ra) # 80001b50 <myproc>
    80005d42:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d44:	fd840593          	addi	a1,s0,-40
    80005d48:	4501                	li	a0,0
    80005d4a:	ffffd097          	auipc	ra,0xffffd
    80005d4e:	0ea080e7          	jalr	234(ra) # 80002e34 <argaddr>
    return -1;
    80005d52:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d54:	0e054063          	bltz	a0,80005e34 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d58:	fc840593          	addi	a1,s0,-56
    80005d5c:	fd040513          	addi	a0,s0,-48
    80005d60:	fffff097          	auipc	ra,0xfffff
    80005d64:	de6080e7          	jalr	-538(ra) # 80004b46 <pipealloc>
    return -1;
    80005d68:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d6a:	0c054563          	bltz	a0,80005e34 <sys_pipe+0x104>
  fd0 = -1;
    80005d6e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d72:	fd043503          	ld	a0,-48(s0)
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	502080e7          	jalr	1282(ra) # 80005278 <fdalloc>
    80005d7e:	fca42223          	sw	a0,-60(s0)
    80005d82:	08054c63          	bltz	a0,80005e1a <sys_pipe+0xea>
    80005d86:	fc843503          	ld	a0,-56(s0)
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	4ee080e7          	jalr	1262(ra) # 80005278 <fdalloc>
    80005d92:	fca42023          	sw	a0,-64(s0)
    80005d96:	06054863          	bltz	a0,80005e06 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d9a:	4691                	li	a3,4
    80005d9c:	fc440613          	addi	a2,s0,-60
    80005da0:	fd843583          	ld	a1,-40(s0)
    80005da4:	6ca8                	ld	a0,88(s1)
    80005da6:	ffffc097          	auipc	ra,0xffffc
    80005daa:	a5a080e7          	jalr	-1446(ra) # 80001800 <copyout>
    80005dae:	02054063          	bltz	a0,80005dce <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005db2:	4691                	li	a3,4
    80005db4:	fc040613          	addi	a2,s0,-64
    80005db8:	fd843583          	ld	a1,-40(s0)
    80005dbc:	0591                	addi	a1,a1,4
    80005dbe:	6ca8                	ld	a0,88(s1)
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	a40080e7          	jalr	-1472(ra) # 80001800 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005dc8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005dca:	06055563          	bgez	a0,80005e34 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005dce:	fc442783          	lw	a5,-60(s0)
    80005dd2:	07e9                	addi	a5,a5,26
    80005dd4:	078e                	slli	a5,a5,0x3
    80005dd6:	97a6                	add	a5,a5,s1
    80005dd8:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005ddc:	fc042503          	lw	a0,-64(s0)
    80005de0:	0569                	addi	a0,a0,26
    80005de2:	050e                	slli	a0,a0,0x3
    80005de4:	9526                	add	a0,a0,s1
    80005de6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005dea:	fd043503          	ld	a0,-48(s0)
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	a20080e7          	jalr	-1504(ra) # 8000480e <fileclose>
    fileclose(wf);
    80005df6:	fc843503          	ld	a0,-56(s0)
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	a14080e7          	jalr	-1516(ra) # 8000480e <fileclose>
    return -1;
    80005e02:	57fd                	li	a5,-1
    80005e04:	a805                	j	80005e34 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e06:	fc442783          	lw	a5,-60(s0)
    80005e0a:	0007c863          	bltz	a5,80005e1a <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e0e:	01a78513          	addi	a0,a5,26
    80005e12:	050e                	slli	a0,a0,0x3
    80005e14:	9526                	add	a0,a0,s1
    80005e16:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e1a:	fd043503          	ld	a0,-48(s0)
    80005e1e:	fffff097          	auipc	ra,0xfffff
    80005e22:	9f0080e7          	jalr	-1552(ra) # 8000480e <fileclose>
    fileclose(wf);
    80005e26:	fc843503          	ld	a0,-56(s0)
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	9e4080e7          	jalr	-1564(ra) # 8000480e <fileclose>
    return -1;
    80005e32:	57fd                	li	a5,-1
}
    80005e34:	853e                	mv	a0,a5
    80005e36:	70e2                	ld	ra,56(sp)
    80005e38:	7442                	ld	s0,48(sp)
    80005e3a:	74a2                	ld	s1,40(sp)
    80005e3c:	6121                	addi	sp,sp,64
    80005e3e:	8082                	ret

0000000080005e40 <kernelvec>:
    80005e40:	7111                	addi	sp,sp,-256
    80005e42:	e006                	sd	ra,0(sp)
    80005e44:	e40a                	sd	sp,8(sp)
    80005e46:	e80e                	sd	gp,16(sp)
    80005e48:	ec12                	sd	tp,24(sp)
    80005e4a:	f016                	sd	t0,32(sp)
    80005e4c:	f41a                	sd	t1,40(sp)
    80005e4e:	f81e                	sd	t2,48(sp)
    80005e50:	fc22                	sd	s0,56(sp)
    80005e52:	e0a6                	sd	s1,64(sp)
    80005e54:	e4aa                	sd	a0,72(sp)
    80005e56:	e8ae                	sd	a1,80(sp)
    80005e58:	ecb2                	sd	a2,88(sp)
    80005e5a:	f0b6                	sd	a3,96(sp)
    80005e5c:	f4ba                	sd	a4,104(sp)
    80005e5e:	f8be                	sd	a5,112(sp)
    80005e60:	fcc2                	sd	a6,120(sp)
    80005e62:	e146                	sd	a7,128(sp)
    80005e64:	e54a                	sd	s2,136(sp)
    80005e66:	e94e                	sd	s3,144(sp)
    80005e68:	ed52                	sd	s4,152(sp)
    80005e6a:	f156                	sd	s5,160(sp)
    80005e6c:	f55a                	sd	s6,168(sp)
    80005e6e:	f95e                	sd	s7,176(sp)
    80005e70:	fd62                	sd	s8,184(sp)
    80005e72:	e1e6                	sd	s9,192(sp)
    80005e74:	e5ea                	sd	s10,200(sp)
    80005e76:	e9ee                	sd	s11,208(sp)
    80005e78:	edf2                	sd	t3,216(sp)
    80005e7a:	f1f6                	sd	t4,224(sp)
    80005e7c:	f5fa                	sd	t5,232(sp)
    80005e7e:	f9fe                	sd	t6,240(sp)
    80005e80:	db9fc0ef          	jal	ra,80002c38 <kerneltrap>
    80005e84:	6082                	ld	ra,0(sp)
    80005e86:	6122                	ld	sp,8(sp)
    80005e88:	61c2                	ld	gp,16(sp)
    80005e8a:	7282                	ld	t0,32(sp)
    80005e8c:	7322                	ld	t1,40(sp)
    80005e8e:	73c2                	ld	t2,48(sp)
    80005e90:	7462                	ld	s0,56(sp)
    80005e92:	6486                	ld	s1,64(sp)
    80005e94:	6526                	ld	a0,72(sp)
    80005e96:	65c6                	ld	a1,80(sp)
    80005e98:	6666                	ld	a2,88(sp)
    80005e9a:	7686                	ld	a3,96(sp)
    80005e9c:	7726                	ld	a4,104(sp)
    80005e9e:	77c6                	ld	a5,112(sp)
    80005ea0:	7866                	ld	a6,120(sp)
    80005ea2:	688a                	ld	a7,128(sp)
    80005ea4:	692a                	ld	s2,136(sp)
    80005ea6:	69ca                	ld	s3,144(sp)
    80005ea8:	6a6a                	ld	s4,152(sp)
    80005eaa:	7a8a                	ld	s5,160(sp)
    80005eac:	7b2a                	ld	s6,168(sp)
    80005eae:	7bca                	ld	s7,176(sp)
    80005eb0:	7c6a                	ld	s8,184(sp)
    80005eb2:	6c8e                	ld	s9,192(sp)
    80005eb4:	6d2e                	ld	s10,200(sp)
    80005eb6:	6dce                	ld	s11,208(sp)
    80005eb8:	6e6e                	ld	t3,216(sp)
    80005eba:	7e8e                	ld	t4,224(sp)
    80005ebc:	7f2e                	ld	t5,232(sp)
    80005ebe:	7fce                	ld	t6,240(sp)
    80005ec0:	6111                	addi	sp,sp,256
    80005ec2:	10200073          	sret
    80005ec6:	00000013          	nop
    80005eca:	00000013          	nop
    80005ece:	0001                	nop

0000000080005ed0 <timervec>:
    80005ed0:	34051573          	csrrw	a0,mscratch,a0
    80005ed4:	e10c                	sd	a1,0(a0)
    80005ed6:	e510                	sd	a2,8(a0)
    80005ed8:	e914                	sd	a3,16(a0)
    80005eda:	6d0c                	ld	a1,24(a0)
    80005edc:	7110                	ld	a2,32(a0)
    80005ede:	6194                	ld	a3,0(a1)
    80005ee0:	96b2                	add	a3,a3,a2
    80005ee2:	e194                	sd	a3,0(a1)
    80005ee4:	4589                	li	a1,2
    80005ee6:	14459073          	csrw	sip,a1
    80005eea:	6914                	ld	a3,16(a0)
    80005eec:	6510                	ld	a2,8(a0)
    80005eee:	610c                	ld	a1,0(a0)
    80005ef0:	34051573          	csrrw	a0,mscratch,a0
    80005ef4:	30200073          	mret
	...

0000000080005efa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005efa:	1141                	addi	sp,sp,-16
    80005efc:	e422                	sd	s0,8(sp)
    80005efe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f00:	0c0007b7          	lui	a5,0xc000
    80005f04:	4705                	li	a4,1
    80005f06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f08:	c3d8                	sw	a4,4(a5)
}
    80005f0a:	6422                	ld	s0,8(sp)
    80005f0c:	0141                	addi	sp,sp,16
    80005f0e:	8082                	ret

0000000080005f10 <plicinithart>:

void
plicinithart(void)
{
    80005f10:	1141                	addi	sp,sp,-16
    80005f12:	e406                	sd	ra,8(sp)
    80005f14:	e022                	sd	s0,0(sp)
    80005f16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f18:	ffffc097          	auipc	ra,0xffffc
    80005f1c:	c0c080e7          	jalr	-1012(ra) # 80001b24 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f20:	0085171b          	slliw	a4,a0,0x8
    80005f24:	0c0027b7          	lui	a5,0xc002
    80005f28:	97ba                	add	a5,a5,a4
    80005f2a:	40200713          	li	a4,1026
    80005f2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f32:	00d5151b          	slliw	a0,a0,0xd
    80005f36:	0c2017b7          	lui	a5,0xc201
    80005f3a:	953e                	add	a0,a0,a5
    80005f3c:	00052023          	sw	zero,0(a0)
}
    80005f40:	60a2                	ld	ra,8(sp)
    80005f42:	6402                	ld	s0,0(sp)
    80005f44:	0141                	addi	sp,sp,16
    80005f46:	8082                	ret

0000000080005f48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f48:	1141                	addi	sp,sp,-16
    80005f4a:	e406                	sd	ra,8(sp)
    80005f4c:	e022                	sd	s0,0(sp)
    80005f4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f50:	ffffc097          	auipc	ra,0xffffc
    80005f54:	bd4080e7          	jalr	-1068(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f58:	00d5179b          	slliw	a5,a0,0xd
    80005f5c:	0c201537          	lui	a0,0xc201
    80005f60:	953e                	add	a0,a0,a5
  return irq;
}
    80005f62:	4148                	lw	a0,4(a0)
    80005f64:	60a2                	ld	ra,8(sp)
    80005f66:	6402                	ld	s0,0(sp)
    80005f68:	0141                	addi	sp,sp,16
    80005f6a:	8082                	ret

0000000080005f6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f6c:	1101                	addi	sp,sp,-32
    80005f6e:	ec06                	sd	ra,24(sp)
    80005f70:	e822                	sd	s0,16(sp)
    80005f72:	e426                	sd	s1,8(sp)
    80005f74:	1000                	addi	s0,sp,32
    80005f76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f78:	ffffc097          	auipc	ra,0xffffc
    80005f7c:	bac080e7          	jalr	-1108(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f80:	00d5151b          	slliw	a0,a0,0xd
    80005f84:	0c2017b7          	lui	a5,0xc201
    80005f88:	97aa                	add	a5,a5,a0
    80005f8a:	c3c4                	sw	s1,4(a5)
}
    80005f8c:	60e2                	ld	ra,24(sp)
    80005f8e:	6442                	ld	s0,16(sp)
    80005f90:	64a2                	ld	s1,8(sp)
    80005f92:	6105                	addi	sp,sp,32
    80005f94:	8082                	ret

0000000080005f96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f96:	1141                	addi	sp,sp,-16
    80005f98:	e406                	sd	ra,8(sp)
    80005f9a:	e022                	sd	s0,0(sp)
    80005f9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f9e:	479d                	li	a5,7
    80005fa0:	04a7c463          	blt	a5,a0,80005fe8 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005fa4:	00032797          	auipc	a5,0x32
    80005fa8:	2c478793          	addi	a5,a5,708 # 80038268 <disk>
    80005fac:	97aa                	add	a5,a5,a0
    80005fae:	0187c783          	lbu	a5,24(a5)
    80005fb2:	e3b9                	bnez	a5,80005ff8 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005fb4:	00032797          	auipc	a5,0x32
    80005fb8:	2b478793          	addi	a5,a5,692 # 80038268 <disk>
    80005fbc:	6398                	ld	a4,0(a5)
    80005fbe:	00451693          	slli	a3,a0,0x4
    80005fc2:	9736                	add	a4,a4,a3
    80005fc4:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80005fc8:	953e                	add	a0,a0,a5
    80005fca:	4785                	li	a5,1
    80005fcc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fd0:	00032517          	auipc	a0,0x32
    80005fd4:	2b050513          	addi	a0,a0,688 # 80038280 <disk+0x18>
    80005fd8:	ffffc097          	auipc	ra,0xffffc
    80005fdc:	648080e7          	jalr	1608(ra) # 80002620 <wakeup>
}
    80005fe0:	60a2                	ld	ra,8(sp)
    80005fe2:	6402                	ld	s0,0(sp)
    80005fe4:	0141                	addi	sp,sp,16
    80005fe6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005fe8:	00004517          	auipc	a0,0x4
    80005fec:	d6850513          	addi	a0,a0,-664 # 80009d50 <syscalls+0x330>
    80005ff0:	ffffa097          	auipc	ra,0xffffa
    80005ff4:	574080e7          	jalr	1396(ra) # 80000564 <panic>
    panic("virtio_disk_intr 2");
    80005ff8:	00004517          	auipc	a0,0x4
    80005ffc:	d7050513          	addi	a0,a0,-656 # 80009d68 <syscalls+0x348>
    80006000:	ffffa097          	auipc	ra,0xffffa
    80006004:	564080e7          	jalr	1380(ra) # 80000564 <panic>

0000000080006008 <virtio_disk_init>:
{
    80006008:	1101                	addi	sp,sp,-32
    8000600a:	ec06                	sd	ra,24(sp)
    8000600c:	e822                	sd	s0,16(sp)
    8000600e:	e426                	sd	s1,8(sp)
    80006010:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006012:	00032497          	auipc	s1,0x32
    80006016:	25648493          	addi	s1,s1,598 # 80038268 <disk>
    8000601a:	00004597          	auipc	a1,0x4
    8000601e:	d6658593          	addi	a1,a1,-666 # 80009d80 <syscalls+0x360>
    80006022:	00032517          	auipc	a0,0x32
    80006026:	36e50513          	addi	a0,a0,878 # 80038390 <disk+0x128>
    8000602a:	ffffb097          	auipc	ra,0xffffb
    8000602e:	a92080e7          	jalr	-1390(ra) # 80000abc <initlock>
  disk.desc = kalloc();
    80006032:	ffffb097          	auipc	ra,0xffffb
    80006036:	a10080e7          	jalr	-1520(ra) # 80000a42 <kalloc>
    8000603a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    8000603c:	ffffb097          	auipc	ra,0xffffb
    80006040:	a06080e7          	jalr	-1530(ra) # 80000a42 <kalloc>
    80006044:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006046:	ffffb097          	auipc	ra,0xffffb
    8000604a:	9fc080e7          	jalr	-1540(ra) # 80000a42 <kalloc>
    8000604e:	87aa                	mv	a5,a0
    80006050:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006052:	6088                	ld	a0,0(s1)
    80006054:	14050163          	beqz	a0,80006196 <virtio_disk_init+0x18e>
    80006058:	00032717          	auipc	a4,0x32
    8000605c:	21873703          	ld	a4,536(a4) # 80038270 <disk+0x8>
    80006060:	12070b63          	beqz	a4,80006196 <virtio_disk_init+0x18e>
    80006064:	12078963          	beqz	a5,80006196 <virtio_disk_init+0x18e>
  memset(disk.desc, 0, PGSIZE);
    80006068:	6605                	lui	a2,0x1
    8000606a:	4581                	li	a1,0
    8000606c:	ffffb097          	auipc	ra,0xffffb
    80006070:	e0a080e7          	jalr	-502(ra) # 80000e76 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006074:	00032497          	auipc	s1,0x32
    80006078:	1f448493          	addi	s1,s1,500 # 80038268 <disk>
    8000607c:	6605                	lui	a2,0x1
    8000607e:	4581                	li	a1,0
    80006080:	6488                	ld	a0,8(s1)
    80006082:	ffffb097          	auipc	ra,0xffffb
    80006086:	df4080e7          	jalr	-524(ra) # 80000e76 <memset>
  memset(disk.used, 0, PGSIZE);
    8000608a:	6605                	lui	a2,0x1
    8000608c:	4581                	li	a1,0
    8000608e:	6888                	ld	a0,16(s1)
    80006090:	ffffb097          	auipc	ra,0xffffb
    80006094:	de6080e7          	jalr	-538(ra) # 80000e76 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006098:	100017b7          	lui	a5,0x10001
    8000609c:	4398                	lw	a4,0(a5)
    8000609e:	2701                	sext.w	a4,a4
    800060a0:	747277b7          	lui	a5,0x74727
    800060a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060a8:	0ef71f63          	bne	a4,a5,800061a6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060ac:	100017b7          	lui	a5,0x10001
    800060b0:	43dc                	lw	a5,4(a5)
    800060b2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060b4:	4709                	li	a4,2
    800060b6:	0ee79863          	bne	a5,a4,800061a6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ba:	100017b7          	lui	a5,0x10001
    800060be:	479c                	lw	a5,8(a5)
    800060c0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060c2:	0ee79263          	bne	a5,a4,800061a6 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800060c6:	100017b7          	lui	a5,0x10001
    800060ca:	47d8                	lw	a4,12(a5)
    800060cc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060ce:	554d47b7          	lui	a5,0x554d4
    800060d2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800060d6:	0cf71863          	bne	a4,a5,800061a6 <virtio_disk_init+0x19e>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060da:	100017b7          	lui	a5,0x10001
    800060de:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e2:	4705                	li	a4,1
    800060e4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060e6:	470d                	li	a4,3
    800060e8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800060ea:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800060ec:	c7ffe737          	lui	a4,0xc7ffe
    800060f0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc638f>
    800060f4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800060f6:	2701                	sext.w	a4,a4
    800060f8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800060fa:	472d                	li	a4,11
    800060fc:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800060fe:	5bbc                	lw	a5,112(a5)
    80006100:	0007861b          	sext.w	a2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006104:	8ba1                	andi	a5,a5,8
    80006106:	cbc5                	beqz	a5,800061b6 <virtio_disk_init+0x1ae>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006108:	100017b7          	lui	a5,0x10001
    8000610c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006110:	43fc                	lw	a5,68(a5)
    80006112:	2781                	sext.w	a5,a5
    80006114:	ebcd                	bnez	a5,800061c6 <virtio_disk_init+0x1be>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006116:	100017b7          	lui	a5,0x10001
    8000611a:	5bdc                	lw	a5,52(a5)
    8000611c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000611e:	cfc5                	beqz	a5,800061d6 <virtio_disk_init+0x1ce>
  if(max < NUM)
    80006120:	471d                	li	a4,7
    80006122:	0cf77263          	bgeu	a4,a5,800061e6 <virtio_disk_init+0x1de>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006126:	10001737          	lui	a4,0x10001
    8000612a:	47a1                	li	a5,8
    8000612c:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    8000612e:	00032797          	auipc	a5,0x32
    80006132:	13a78793          	addi	a5,a5,314 # 80038268 <disk>
    80006136:	4394                	lw	a3,0(a5)
    80006138:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    8000613c:	43d4                	lw	a3,4(a5)
    8000613e:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    80006142:	6794                	ld	a3,8(a5)
    80006144:	0006859b          	sext.w	a1,a3
    80006148:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000614c:	9681                	srai	a3,a3,0x20
    8000614e:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    80006152:	6b94                	ld	a3,16(a5)
    80006154:	0006859b          	sext.w	a1,a3
    80006158:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000615c:	9681                	srai	a3,a3,0x20
    8000615e:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006162:	4685                	li	a3,1
    80006164:	c374                	sw	a3,68(a4)
    disk.free[i] = 1;
    80006166:	00d78c23          	sb	a3,24(a5)
    8000616a:	00d78ca3          	sb	a3,25(a5)
    8000616e:	00d78d23          	sb	a3,26(a5)
    80006172:	00d78da3          	sb	a3,27(a5)
    80006176:	00d78e23          	sb	a3,28(a5)
    8000617a:	00d78ea3          	sb	a3,29(a5)
    8000617e:	00d78f23          	sb	a3,30(a5)
    80006182:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006186:	00466793          	ori	a5,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000618a:	db3c                	sw	a5,112(a4)
}
    8000618c:	60e2                	ld	ra,24(sp)
    8000618e:	6442                	ld	s0,16(sp)
    80006190:	64a2                	ld	s1,8(sp)
    80006192:	6105                	addi	sp,sp,32
    80006194:	8082                	ret
    panic("virtio disk kalloc");
    80006196:	00004517          	auipc	a0,0x4
    8000619a:	bfa50513          	addi	a0,a0,-1030 # 80009d90 <syscalls+0x370>
    8000619e:	ffffa097          	auipc	ra,0xffffa
    800061a2:	3c6080e7          	jalr	966(ra) # 80000564 <panic>
    panic("could not find virtio disk");
    800061a6:	00004517          	auipc	a0,0x4
    800061aa:	c0250513          	addi	a0,a0,-1022 # 80009da8 <syscalls+0x388>
    800061ae:	ffffa097          	auipc	ra,0xffffa
    800061b2:	3b6080e7          	jalr	950(ra) # 80000564 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061b6:	00004517          	auipc	a0,0x4
    800061ba:	c1250513          	addi	a0,a0,-1006 # 80009dc8 <syscalls+0x3a8>
    800061be:	ffffa097          	auipc	ra,0xffffa
    800061c2:	3a6080e7          	jalr	934(ra) # 80000564 <panic>
    panic("virtio disk ready not zero");
    800061c6:	00004517          	auipc	a0,0x4
    800061ca:	c2250513          	addi	a0,a0,-990 # 80009de8 <syscalls+0x3c8>
    800061ce:	ffffa097          	auipc	ra,0xffffa
    800061d2:	396080e7          	jalr	918(ra) # 80000564 <panic>
    panic("virtio disk has no queue 0");
    800061d6:	00004517          	auipc	a0,0x4
    800061da:	c3250513          	addi	a0,a0,-974 # 80009e08 <syscalls+0x3e8>
    800061de:	ffffa097          	auipc	ra,0xffffa
    800061e2:	386080e7          	jalr	902(ra) # 80000564 <panic>
    panic("virtio disk max queue too short");
    800061e6:	00004517          	auipc	a0,0x4
    800061ea:	c4250513          	addi	a0,a0,-958 # 80009e28 <syscalls+0x408>
    800061ee:	ffffa097          	auipc	ra,0xffffa
    800061f2:	376080e7          	jalr	886(ra) # 80000564 <panic>

00000000800061f6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061f6:	7119                	addi	sp,sp,-128
    800061f8:	fc86                	sd	ra,120(sp)
    800061fa:	f8a2                	sd	s0,112(sp)
    800061fc:	f4a6                	sd	s1,104(sp)
    800061fe:	f0ca                	sd	s2,96(sp)
    80006200:	ecce                	sd	s3,88(sp)
    80006202:	e8d2                	sd	s4,80(sp)
    80006204:	e4d6                	sd	s5,72(sp)
    80006206:	e0da                	sd	s6,64(sp)
    80006208:	fc5e                	sd	s7,56(sp)
    8000620a:	f862                	sd	s8,48(sp)
    8000620c:	f466                	sd	s9,40(sp)
    8000620e:	f06a                	sd	s10,32(sp)
    80006210:	ec6e                	sd	s11,24(sp)
    80006212:	0100                	addi	s0,sp,128
    80006214:	8aaa                	mv	s5,a0
    80006216:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006218:	00c52d03          	lw	s10,12(a0)
    8000621c:	001d1d1b          	slliw	s10,s10,0x1
    80006220:	1d02                	slli	s10,s10,0x20
    80006222:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006226:	00032517          	auipc	a0,0x32
    8000622a:	16a50513          	addi	a0,a0,362 # 80038390 <disk+0x128>
    8000622e:	ffffb097          	auipc	ra,0xffffb
    80006232:	964080e7          	jalr	-1692(ra) # 80000b92 <acquire>
  for(int i = 0; i < 3; i++){
    80006236:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006238:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000623a:	00032b97          	auipc	s7,0x32
    8000623e:	02eb8b93          	addi	s7,s7,46 # 80038268 <disk>
  for(int i = 0; i < 3; i++){
    80006242:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006244:	00032c97          	auipc	s9,0x32
    80006248:	14cc8c93          	addi	s9,s9,332 # 80038390 <disk+0x128>
    8000624c:	a08d                	j	800062ae <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000624e:	00fb8733          	add	a4,s7,a5
    80006252:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006256:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006258:	0207c563          	bltz	a5,80006282 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000625c:	2905                	addiw	s2,s2,1
    8000625e:	0611                	addi	a2,a2,4
    80006260:	0b690263          	beq	s2,s6,80006304 <virtio_disk_rw+0x10e>
    idx[i] = alloc_desc();
    80006264:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006266:	00032717          	auipc	a4,0x32
    8000626a:	00270713          	addi	a4,a4,2 # 80038268 <disk>
    8000626e:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006270:	01874683          	lbu	a3,24(a4)
    80006274:	fee9                	bnez	a3,8000624e <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006276:	2785                	addiw	a5,a5,1
    80006278:	0705                	addi	a4,a4,1
    8000627a:	fe979be3          	bne	a5,s1,80006270 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000627e:	57fd                	li	a5,-1
    80006280:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006282:	01205d63          	blez	s2,8000629c <virtio_disk_rw+0xa6>
    80006286:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006288:	000a2503          	lw	a0,0(s4)
    8000628c:	00000097          	auipc	ra,0x0
    80006290:	d0a080e7          	jalr	-758(ra) # 80005f96 <free_desc>
      for(int j = 0; j < i; j++)
    80006294:	2d85                	addiw	s11,s11,1
    80006296:	0a11                	addi	s4,s4,4
    80006298:	ffb918e3          	bne	s2,s11,80006288 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000629c:	85e6                	mv	a1,s9
    8000629e:	00032517          	auipc	a0,0x32
    800062a2:	fe250513          	addi	a0,a0,-30 # 80038280 <disk+0x18>
    800062a6:	ffffc097          	auipc	ra,0xffffc
    800062aa:	1fa080e7          	jalr	506(ra) # 800024a0 <sleep>
  for(int i = 0; i < 3; i++){
    800062ae:	f8040a13          	addi	s4,s0,-128
{
    800062b2:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062b4:	894e                	mv	s2,s3
    800062b6:	b77d                	j	80006264 <virtio_disk_rw+0x6e>
      i = disk.desc[i].next;
    800062b8:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800062bc:	8526                	mv	a0,s1
    800062be:	00000097          	auipc	ra,0x0
    800062c2:	cd8080e7          	jalr	-808(ra) # 80005f96 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    800062c6:	0492                	slli	s1,s1,0x4
    800062c8:	00093783          	ld	a5,0(s2)
    800062cc:	94be                	add	s1,s1,a5
    800062ce:	00c4d783          	lhu	a5,12(s1)
    800062d2:	8b85                	andi	a5,a5,1
    800062d4:	f3f5                	bnez	a5,800062b8 <virtio_disk_rw+0xc2>
  }

  disk.info[idx[0]].b = 0;
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062d6:	00032517          	auipc	a0,0x32
    800062da:	0ba50513          	addi	a0,a0,186 # 80038390 <disk+0x128>
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	984080e7          	jalr	-1660(ra) # 80000c62 <release>
}
    800062e6:	70e6                	ld	ra,120(sp)
    800062e8:	7446                	ld	s0,112(sp)
    800062ea:	74a6                	ld	s1,104(sp)
    800062ec:	7906                	ld	s2,96(sp)
    800062ee:	69e6                	ld	s3,88(sp)
    800062f0:	6a46                	ld	s4,80(sp)
    800062f2:	6aa6                	ld	s5,72(sp)
    800062f4:	6b06                	ld	s6,64(sp)
    800062f6:	7be2                	ld	s7,56(sp)
    800062f8:	7c42                	ld	s8,48(sp)
    800062fa:	7ca2                	ld	s9,40(sp)
    800062fc:	7d02                	ld	s10,32(sp)
    800062fe:	6de2                	ld	s11,24(sp)
    80006300:	6109                	addi	sp,sp,128
    80006302:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006304:	f8042583          	lw	a1,-128(s0)
    80006308:	00a58793          	addi	a5,a1,10
    8000630c:	0792                	slli	a5,a5,0x4
  if(write)
    8000630e:	00032617          	auipc	a2,0x32
    80006312:	f5a60613          	addi	a2,a2,-166 # 80038268 <disk>
    80006316:	00f60733          	add	a4,a2,a5
    8000631a:	018036b3          	snez	a3,s8
    8000631e:	c714                	sw	a3,8(a4)
  buf0->reserved = 0;
    80006320:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006324:	01a73823          	sd	s10,16(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006328:	f6078693          	addi	a3,a5,-160
    8000632c:	6218                	ld	a4,0(a2)
    8000632e:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006330:	00878513          	addi	a0,a5,8
    80006334:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006336:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006338:	6208                	ld	a0,0(a2)
    8000633a:	96aa                	add	a3,a3,a0
    8000633c:	4741                	li	a4,16
    8000633e:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    80006340:	4705                	li	a4,1
    80006342:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006346:	f8442703          	lw	a4,-124(s0)
    8000634a:	00e69723          	sh	a4,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    8000634e:	0712                	slli	a4,a4,0x4
    80006350:	953a                	add	a0,a0,a4
    80006352:	060a8693          	addi	a3,s5,96
    80006356:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006358:	6208                	ld	a0,0(a2)
    8000635a:	972a                	add	a4,a4,a0
    8000635c:	40000693          	li	a3,1024
    80006360:	c714                	sw	a3,8(a4)
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    80006362:	001c3c13          	seqz	s8,s8
    80006366:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    80006368:	001c6c13          	ori	s8,s8,1
    8000636c:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006370:	f8842603          	lw	a2,-120(s0)
    80006374:	00c71723          	sh	a2,14(a4)
  disk.info[idx[0]].status = 0;
    80006378:	00032697          	auipc	a3,0x32
    8000637c:	ef068693          	addi	a3,a3,-272 # 80038268 <disk>
    80006380:	00258713          	addi	a4,a1,2
    80006384:	0712                	slli	a4,a4,0x4
    80006386:	9736                	add	a4,a4,a3
    80006388:	00070823          	sb	zero,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000638c:	0612                	slli	a2,a2,0x4
    8000638e:	9532                	add	a0,a0,a2
    80006390:	f9078793          	addi	a5,a5,-112
    80006394:	97b6                	add	a5,a5,a3
    80006396:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006398:	629c                	ld	a5,0(a3)
    8000639a:	97b2                	add	a5,a5,a2
    8000639c:	4605                	li	a2,1
    8000639e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    800063a0:	4509                	li	a0,2
    800063a2:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800063a6:	00079723          	sh	zero,14(a5)
  b->disk = 1;
    800063aa:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063ae:	01573423          	sd	s5,8(a4)
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063b2:	6698                	ld	a4,8(a3)
    800063b4:	00275783          	lhu	a5,2(a4)
    800063b8:	8b9d                	andi	a5,a5,7
    800063ba:	0786                	slli	a5,a5,0x1
    800063bc:	97ba                	add	a5,a5,a4
    800063be:	00b79223          	sh	a1,4(a5)
  __sync_synchronize();
    800063c2:	0ff0000f          	fence
  disk.avail->idx += 1;
    800063c6:	6698                	ld	a4,8(a3)
    800063c8:	00275783          	lhu	a5,2(a4)
    800063cc:	2785                	addiw	a5,a5,1
    800063ce:	00f71123          	sh	a5,2(a4)
  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063d2:	100017b7          	lui	a5,0x10001
    800063d6:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
  while(b->disk == 1) {
    800063da:	004aa783          	lw	a5,4(s5)
    800063de:	02c79163          	bne	a5,a2,80006400 <virtio_disk_rw+0x20a>
    sleep(b, &disk.vdisk_lock);
    800063e2:	00032917          	auipc	s2,0x32
    800063e6:	fae90913          	addi	s2,s2,-82 # 80038390 <disk+0x128>
  while(b->disk == 1) {
    800063ea:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063ec:	85ca                	mv	a1,s2
    800063ee:	8556                	mv	a0,s5
    800063f0:	ffffc097          	auipc	ra,0xffffc
    800063f4:	0b0080e7          	jalr	176(ra) # 800024a0 <sleep>
  while(b->disk == 1) {
    800063f8:	004aa783          	lw	a5,4(s5)
    800063fc:	fe9788e3          	beq	a5,s1,800063ec <virtio_disk_rw+0x1f6>
  disk.info[idx[0]].b = 0;
    80006400:	f8042483          	lw	s1,-128(s0)
    80006404:	00248793          	addi	a5,s1,2
    80006408:	00479713          	slli	a4,a5,0x4
    8000640c:	00032797          	auipc	a5,0x32
    80006410:	e5c78793          	addi	a5,a5,-420 # 80038268 <disk>
    80006414:	97ba                	add	a5,a5,a4
    80006416:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    8000641a:	00032917          	auipc	s2,0x32
    8000641e:	e4e90913          	addi	s2,s2,-434 # 80038268 <disk>
    80006422:	bd69                	j	800062bc <virtio_disk_rw+0xc6>

0000000080006424 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    80006424:	1101                	addi	sp,sp,-32
    80006426:	ec06                	sd	ra,24(sp)
    80006428:	e822                	sd	s0,16(sp)
    8000642a:	e426                	sd	s1,8(sp)
    8000642c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000642e:	00032497          	auipc	s1,0x32
    80006432:	e3a48493          	addi	s1,s1,-454 # 80038268 <disk>
    80006436:	00032517          	auipc	a0,0x32
    8000643a:	f5a50513          	addi	a0,a0,-166 # 80038390 <disk+0x128>
    8000643e:	ffffa097          	auipc	ra,0xffffa
    80006442:	754080e7          	jalr	1876(ra) # 80000b92 <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    80006446:	0204d783          	lhu	a5,32(s1)
    8000644a:	6898                	ld	a4,16(s1)
    8000644c:	00275683          	lhu	a3,2(a4)
    80006450:	8ebd                	xor	a3,a3,a5
    80006452:	8a9d                	andi	a3,a3,7
    80006454:	c2b1                	beqz	a3,80006498 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    80006456:	078e                	slli	a5,a5,0x3
    80006458:	97ba                	add	a5,a5,a4
    8000645a:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000645c:	00278713          	addi	a4,a5,2
    80006460:	0712                	slli	a4,a4,0x4
    80006462:	9726                	add	a4,a4,s1
    80006464:	01074703          	lbu	a4,16(a4)
    80006468:	eb31                	bnez	a4,800064bc <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000646a:	0789                	addi	a5,a5,2
    8000646c:	0792                	slli	a5,a5,0x4
    8000646e:	97a6                	add	a5,a5,s1
    80006470:	6798                	ld	a4,8(a5)
    80006472:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006476:	6788                	ld	a0,8(a5)
    80006478:	ffffc097          	auipc	ra,0xffffc
    8000647c:	1a8080e7          	jalr	424(ra) # 80002620 <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006480:	0204d783          	lhu	a5,32(s1)
    80006484:	2785                	addiw	a5,a5,1
    80006486:	8b9d                	andi	a5,a5,7
    80006488:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    8000648c:	6898                	ld	a4,16(s1)
    8000648e:	00275683          	lhu	a3,2(a4)
    80006492:	8a9d                	andi	a3,a3,7
    80006494:	fcf691e3          	bne	a3,a5,80006456 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006498:	10001737          	lui	a4,0x10001
    8000649c:	533c                	lw	a5,96(a4)
    8000649e:	8b8d                	andi	a5,a5,3
    800064a0:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800064a2:	00032517          	auipc	a0,0x32
    800064a6:	eee50513          	addi	a0,a0,-274 # 80038390 <disk+0x128>
    800064aa:	ffffa097          	auipc	ra,0xffffa
    800064ae:	7b8080e7          	jalr	1976(ra) # 80000c62 <release>
}
    800064b2:	60e2                	ld	ra,24(sp)
    800064b4:	6442                	ld	s0,16(sp)
    800064b6:	64a2                	ld	s1,8(sp)
    800064b8:	6105                	addi	sp,sp,32
    800064ba:	8082                	ret
      panic("virtio_disk_intr status");
    800064bc:	00004517          	auipc	a0,0x4
    800064c0:	98c50513          	addi	a0,a0,-1652 # 80009e48 <syscalls+0x428>
    800064c4:	ffffa097          	auipc	ra,0xffffa
    800064c8:	0a0080e7          	jalr	160(ra) # 80000564 <panic>

00000000800064cc <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800064cc:	1141                	addi	sp,sp,-16
    800064ce:	e422                	sd	s0,8(sp)
    800064d0:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    800064d2:	41f5d79b          	sraiw	a5,a1,0x1f
    800064d6:	01d7d79b          	srliw	a5,a5,0x1d
    800064da:	9dbd                	addw	a1,a1,a5
    800064dc:	0075f713          	andi	a4,a1,7
    800064e0:	9f1d                	subw	a4,a4,a5
    800064e2:	4785                	li	a5,1
    800064e4:	00e797bb          	sllw	a5,a5,a4
    800064e8:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    800064ec:	4035d59b          	sraiw	a1,a1,0x3
    800064f0:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800064f2:	0005c503          	lbu	a0,0(a1)
    800064f6:	8d7d                	and	a0,a0,a5
    800064f8:	8d1d                	sub	a0,a0,a5
}
    800064fa:	00153513          	seqz	a0,a0
    800064fe:	6422                	ld	s0,8(sp)
    80006500:	0141                	addi	sp,sp,16
    80006502:	8082                	ret

0000000080006504 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006504:	1141                	addi	sp,sp,-16
    80006506:	e422                	sd	s0,8(sp)
    80006508:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000650a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000650e:	01d7d79b          	srliw	a5,a5,0x1d
    80006512:	9dbd                	addw	a1,a1,a5
    80006514:	4035d71b          	sraiw	a4,a1,0x3
    80006518:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000651a:	899d                	andi	a1,a1,7
    8000651c:	9d9d                	subw	a1,a1,a5
    8000651e:	4785                	li	a5,1
    80006520:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    80006524:	00054783          	lbu	a5,0(a0)
    80006528:	8ddd                	or	a1,a1,a5
    8000652a:	00b50023          	sb	a1,0(a0)
}
    8000652e:	6422                	ld	s0,8(sp)
    80006530:	0141                	addi	sp,sp,16
    80006532:	8082                	ret

0000000080006534 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    80006534:	1141                	addi	sp,sp,-16
    80006536:	e422                	sd	s0,8(sp)
    80006538:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000653a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000653e:	01d7d79b          	srliw	a5,a5,0x1d
    80006542:	9dbd                	addw	a1,a1,a5
    80006544:	4035d71b          	sraiw	a4,a1,0x3
    80006548:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000654a:	899d                	andi	a1,a1,7
    8000654c:	9d9d                	subw	a1,a1,a5
    8000654e:	4785                	li	a5,1
    80006550:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    80006554:	fff5c593          	not	a1,a1
    80006558:	00054783          	lbu	a5,0(a0)
    8000655c:	8dfd                	and	a1,a1,a5
    8000655e:	00b50023          	sb	a1,0(a0)
}
    80006562:	6422                	ld	s0,8(sp)
    80006564:	0141                	addi	sp,sp,16
    80006566:	8082                	ret

0000000080006568 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006568:	715d                	addi	sp,sp,-80
    8000656a:	e486                	sd	ra,72(sp)
    8000656c:	e0a2                	sd	s0,64(sp)
    8000656e:	fc26                	sd	s1,56(sp)
    80006570:	f84a                	sd	s2,48(sp)
    80006572:	f44e                	sd	s3,40(sp)
    80006574:	f052                	sd	s4,32(sp)
    80006576:	ec56                	sd	s5,24(sp)
    80006578:	e85a                	sd	s6,16(sp)
    8000657a:	e45e                	sd	s7,8(sp)
    8000657c:	0880                	addi	s0,sp,80
    8000657e:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006580:	08b05b63          	blez	a1,80006616 <bd_print_vector+0xae>
    80006584:	89aa                	mv	s3,a0
    80006586:	4481                	li	s1,0
  lb = 0;
    80006588:	4a81                	li	s5,0
  last = 1;
    8000658a:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000658c:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000658e:	00004b97          	auipc	s7,0x4
    80006592:	8d2b8b93          	addi	s7,s7,-1838 # 80009e60 <syscalls+0x440>
    80006596:	a821                	j	800065ae <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006598:	85a6                	mv	a1,s1
    8000659a:	854e                	mv	a0,s3
    8000659c:	00000097          	auipc	ra,0x0
    800065a0:	f30080e7          	jalr	-208(ra) # 800064cc <bit_isset>
    800065a4:	892a                	mv	s2,a0
    800065a6:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    800065a8:	2485                	addiw	s1,s1,1
    800065aa:	029a0463          	beq	s4,s1,800065d2 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    800065ae:	85a6                	mv	a1,s1
    800065b0:	854e                	mv	a0,s3
    800065b2:	00000097          	auipc	ra,0x0
    800065b6:	f1a080e7          	jalr	-230(ra) # 800064cc <bit_isset>
    800065ba:	ff2507e3          	beq	a0,s2,800065a8 <bd_print_vector+0x40>
    if(last == 1)
    800065be:	fd691de3          	bne	s2,s6,80006598 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    800065c2:	8626                	mv	a2,s1
    800065c4:	85d6                	mv	a1,s5
    800065c6:	855e                	mv	a0,s7
    800065c8:	ffffa097          	auipc	ra,0xffffa
    800065cc:	ffe080e7          	jalr	-2(ra) # 800005c6 <printf>
    800065d0:	b7e1                	j	80006598 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    800065d2:	000a8563          	beqz	s5,800065dc <bd_print_vector+0x74>
    800065d6:	4785                	li	a5,1
    800065d8:	00f91c63          	bne	s2,a5,800065f0 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    800065dc:	8652                	mv	a2,s4
    800065de:	85d6                	mv	a1,s5
    800065e0:	00004517          	auipc	a0,0x4
    800065e4:	88050513          	addi	a0,a0,-1920 # 80009e60 <syscalls+0x440>
    800065e8:	ffffa097          	auipc	ra,0xffffa
    800065ec:	fde080e7          	jalr	-34(ra) # 800005c6 <printf>
  }
  printf("\n");
    800065f0:	00003517          	auipc	a0,0x3
    800065f4:	f1850513          	addi	a0,a0,-232 # 80009508 <digits+0x398>
    800065f8:	ffffa097          	auipc	ra,0xffffa
    800065fc:	fce080e7          	jalr	-50(ra) # 800005c6 <printf>
}
    80006600:	60a6                	ld	ra,72(sp)
    80006602:	6406                	ld	s0,64(sp)
    80006604:	74e2                	ld	s1,56(sp)
    80006606:	7942                	ld	s2,48(sp)
    80006608:	79a2                	ld	s3,40(sp)
    8000660a:	7a02                	ld	s4,32(sp)
    8000660c:	6ae2                	ld	s5,24(sp)
    8000660e:	6b42                	ld	s6,16(sp)
    80006610:	6ba2                	ld	s7,8(sp)
    80006612:	6161                	addi	sp,sp,80
    80006614:	8082                	ret
  lb = 0;
    80006616:	4a81                	li	s5,0
    80006618:	b7d1                	j	800065dc <bd_print_vector+0x74>

000000008000661a <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000661a:	00004697          	auipc	a3,0x4
    8000661e:	a0e6a683          	lw	a3,-1522(a3) # 8000a028 <nsizes>
    80006622:	10d05063          	blez	a3,80006722 <bd_print+0x108>
bd_print() {
    80006626:	711d                	addi	sp,sp,-96
    80006628:	ec86                	sd	ra,88(sp)
    8000662a:	e8a2                	sd	s0,80(sp)
    8000662c:	e4a6                	sd	s1,72(sp)
    8000662e:	e0ca                	sd	s2,64(sp)
    80006630:	fc4e                	sd	s3,56(sp)
    80006632:	f852                	sd	s4,48(sp)
    80006634:	f456                	sd	s5,40(sp)
    80006636:	f05a                	sd	s6,32(sp)
    80006638:	ec5e                	sd	s7,24(sp)
    8000663a:	e862                	sd	s8,16(sp)
    8000663c:	e466                	sd	s9,8(sp)
    8000663e:	e06a                	sd	s10,0(sp)
    80006640:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    80006642:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006644:	4a85                	li	s5,1
    80006646:	4c41                	li	s8,16
    80006648:	00004b97          	auipc	s7,0x4
    8000664c:	828b8b93          	addi	s7,s7,-2008 # 80009e70 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    80006650:	00004a17          	auipc	s4,0x4
    80006654:	9d0a0a13          	addi	s4,s4,-1584 # 8000a020 <bd_sizes>
    printf("  alloc:");
    80006658:	00004b17          	auipc	s6,0x4
    8000665c:	840b0b13          	addi	s6,s6,-1984 # 80009e98 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006660:	00004997          	auipc	s3,0x4
    80006664:	9c898993          	addi	s3,s3,-1592 # 8000a028 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006668:	00004c97          	auipc	s9,0x4
    8000666c:	840c8c93          	addi	s9,s9,-1984 # 80009ea8 <syscalls+0x488>
    80006670:	a801                	j	80006680 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    80006672:	0009a683          	lw	a3,0(s3)
    80006676:	0485                	addi	s1,s1,1
    80006678:	0004879b          	sext.w	a5,s1
    8000667c:	08d7d563          	bge	a5,a3,80006706 <bd_print+0xec>
    80006680:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006684:	36fd                	addiw	a3,a3,-1
    80006686:	9e85                	subw	a3,a3,s1
    80006688:	00da96bb          	sllw	a3,s5,a3
    8000668c:	009c1633          	sll	a2,s8,s1
    80006690:	85ca                	mv	a1,s2
    80006692:	855e                	mv	a0,s7
    80006694:	ffffa097          	auipc	ra,0xffffa
    80006698:	f32080e7          	jalr	-206(ra) # 800005c6 <printf>
    lst_print(&bd_sizes[k].free);
    8000669c:	00549d13          	slli	s10,s1,0x5
    800066a0:	000a3503          	ld	a0,0(s4)
    800066a4:	956a                	add	a0,a0,s10
    800066a6:	00001097          	auipc	ra,0x1
    800066aa:	a56080e7          	jalr	-1450(ra) # 800070fc <lst_print>
    printf("  alloc:");
    800066ae:	855a                	mv	a0,s6
    800066b0:	ffffa097          	auipc	ra,0xffffa
    800066b4:	f16080e7          	jalr	-234(ra) # 800005c6 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800066b8:	0009a583          	lw	a1,0(s3)
    800066bc:	35fd                	addiw	a1,a1,-1
    800066be:	412585bb          	subw	a1,a1,s2
    800066c2:	000a3783          	ld	a5,0(s4)
    800066c6:	97ea                	add	a5,a5,s10
    800066c8:	00ba95bb          	sllw	a1,s5,a1
    800066cc:	6b88                	ld	a0,16(a5)
    800066ce:	00000097          	auipc	ra,0x0
    800066d2:	e9a080e7          	jalr	-358(ra) # 80006568 <bd_print_vector>
    if(k > 0) {
    800066d6:	f9205ee3          	blez	s2,80006672 <bd_print+0x58>
      printf("  split:");
    800066da:	8566                	mv	a0,s9
    800066dc:	ffffa097          	auipc	ra,0xffffa
    800066e0:	eea080e7          	jalr	-278(ra) # 800005c6 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    800066e4:	0009a583          	lw	a1,0(s3)
    800066e8:	35fd                	addiw	a1,a1,-1
    800066ea:	412585bb          	subw	a1,a1,s2
    800066ee:	000a3783          	ld	a5,0(s4)
    800066f2:	9d3e                	add	s10,s10,a5
    800066f4:	00ba95bb          	sllw	a1,s5,a1
    800066f8:	018d3503          	ld	a0,24(s10) # fffffffffffff018 <end+0xffffffff7ffc6c48>
    800066fc:	00000097          	auipc	ra,0x0
    80006700:	e6c080e7          	jalr	-404(ra) # 80006568 <bd_print_vector>
    80006704:	b7bd                	j	80006672 <bd_print+0x58>
    }
  }
}
    80006706:	60e6                	ld	ra,88(sp)
    80006708:	6446                	ld	s0,80(sp)
    8000670a:	64a6                	ld	s1,72(sp)
    8000670c:	6906                	ld	s2,64(sp)
    8000670e:	79e2                	ld	s3,56(sp)
    80006710:	7a42                	ld	s4,48(sp)
    80006712:	7aa2                	ld	s5,40(sp)
    80006714:	7b02                	ld	s6,32(sp)
    80006716:	6be2                	ld	s7,24(sp)
    80006718:	6c42                	ld	s8,16(sp)
    8000671a:	6ca2                	ld	s9,8(sp)
    8000671c:	6d02                	ld	s10,0(sp)
    8000671e:	6125                	addi	sp,sp,96
    80006720:	8082                	ret
    80006722:	8082                	ret

0000000080006724 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006724:	1141                	addi	sp,sp,-16
    80006726:	e422                	sd	s0,8(sp)
    80006728:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    8000672a:	47c1                	li	a5,16
    8000672c:	00a7fb63          	bgeu	a5,a0,80006742 <firstk+0x1e>
    80006730:	872a                	mv	a4,a0
  int k = 0;
    80006732:	4501                	li	a0,0
    k++;
    80006734:	2505                	addiw	a0,a0,1
    size *= 2;
    80006736:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006738:	fee7eee3          	bltu	a5,a4,80006734 <firstk+0x10>
  }
  return k;
}
    8000673c:	6422                	ld	s0,8(sp)
    8000673e:	0141                	addi	sp,sp,16
    80006740:	8082                	ret
  int k = 0;
    80006742:	4501                	li	a0,0
    80006744:	bfe5                	j	8000673c <firstk+0x18>

0000000080006746 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006746:	1141                	addi	sp,sp,-16
    80006748:	e422                	sd	s0,8(sp)
    8000674a:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    8000674c:	00004797          	auipc	a5,0x4
    80006750:	8cc7b783          	ld	a5,-1844(a5) # 8000a018 <bd_base>
    80006754:	9d9d                	subw	a1,a1,a5
    80006756:	47c1                	li	a5,16
    80006758:	00a797b3          	sll	a5,a5,a0
    8000675c:	02f5c5b3          	div	a1,a1,a5
}
    80006760:	0005851b          	sext.w	a0,a1
    80006764:	6422                	ld	s0,8(sp)
    80006766:	0141                	addi	sp,sp,16
    80006768:	8082                	ret

000000008000676a <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    8000676a:	1141                	addi	sp,sp,-16
    8000676c:	e422                	sd	s0,8(sp)
    8000676e:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006770:	47c1                	li	a5,16
    80006772:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006776:	02b787bb          	mulw	a5,a5,a1
}
    8000677a:	00004517          	auipc	a0,0x4
    8000677e:	89e53503          	ld	a0,-1890(a0) # 8000a018 <bd_base>
    80006782:	953e                	add	a0,a0,a5
    80006784:	6422                	ld	s0,8(sp)
    80006786:	0141                	addi	sp,sp,16
    80006788:	8082                	ret

000000008000678a <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    8000678a:	7159                	addi	sp,sp,-112
    8000678c:	f486                	sd	ra,104(sp)
    8000678e:	f0a2                	sd	s0,96(sp)
    80006790:	eca6                	sd	s1,88(sp)
    80006792:	e8ca                	sd	s2,80(sp)
    80006794:	e4ce                	sd	s3,72(sp)
    80006796:	e0d2                	sd	s4,64(sp)
    80006798:	fc56                	sd	s5,56(sp)
    8000679a:	f85a                	sd	s6,48(sp)
    8000679c:	f45e                	sd	s7,40(sp)
    8000679e:	f062                	sd	s8,32(sp)
    800067a0:	ec66                	sd	s9,24(sp)
    800067a2:	e86a                	sd	s10,16(sp)
    800067a4:	e46e                	sd	s11,8(sp)
    800067a6:	1880                	addi	s0,sp,112
    800067a8:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800067aa:	00032517          	auipc	a0,0x32
    800067ae:	c0650513          	addi	a0,a0,-1018 # 800383b0 <lock>
    800067b2:	ffffa097          	auipc	ra,0xffffa
    800067b6:	3e0080e7          	jalr	992(ra) # 80000b92 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800067ba:	8526                	mv	a0,s1
    800067bc:	00000097          	auipc	ra,0x0
    800067c0:	f68080e7          	jalr	-152(ra) # 80006724 <firstk>
  for (k = fk; k < nsizes; k++) {
    800067c4:	00004797          	auipc	a5,0x4
    800067c8:	8647a783          	lw	a5,-1948(a5) # 8000a028 <nsizes>
    800067cc:	02f55d63          	bge	a0,a5,80006806 <bd_malloc+0x7c>
    800067d0:	8c2a                	mv	s8,a0
    800067d2:	00551913          	slli	s2,a0,0x5
    800067d6:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800067d8:	00004997          	auipc	s3,0x4
    800067dc:	84898993          	addi	s3,s3,-1976 # 8000a020 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800067e0:	00004a17          	auipc	s4,0x4
    800067e4:	848a0a13          	addi	s4,s4,-1976 # 8000a028 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800067e8:	0009b503          	ld	a0,0(s3)
    800067ec:	954a                	add	a0,a0,s2
    800067ee:	00001097          	auipc	ra,0x1
    800067f2:	894080e7          	jalr	-1900(ra) # 80007082 <lst_empty>
    800067f6:	c115                	beqz	a0,8000681a <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800067f8:	2485                	addiw	s1,s1,1
    800067fa:	02090913          	addi	s2,s2,32
    800067fe:	000a2783          	lw	a5,0(s4)
    80006802:	fef4c3e3          	blt	s1,a5,800067e8 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006806:	00032517          	auipc	a0,0x32
    8000680a:	baa50513          	addi	a0,a0,-1110 # 800383b0 <lock>
    8000680e:	ffffa097          	auipc	ra,0xffffa
    80006812:	454080e7          	jalr	1108(ra) # 80000c62 <release>
    return 0;
    80006816:	4b01                	li	s6,0
    80006818:	a0e1                	j	800068e0 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    8000681a:	00004797          	auipc	a5,0x4
    8000681e:	80e7a783          	lw	a5,-2034(a5) # 8000a028 <nsizes>
    80006822:	fef4d2e3          	bge	s1,a5,80006806 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006826:	00549993          	slli	s3,s1,0x5
    8000682a:	00003917          	auipc	s2,0x3
    8000682e:	7f690913          	addi	s2,s2,2038 # 8000a020 <bd_sizes>
    80006832:	00093503          	ld	a0,0(s2)
    80006836:	954e                	add	a0,a0,s3
    80006838:	00001097          	auipc	ra,0x1
    8000683c:	876080e7          	jalr	-1930(ra) # 800070ae <lst_pop>
    80006840:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006842:	00003597          	auipc	a1,0x3
    80006846:	7d65b583          	ld	a1,2006(a1) # 8000a018 <bd_base>
    8000684a:	40b505bb          	subw	a1,a0,a1
    8000684e:	47c1                	li	a5,16
    80006850:	009797b3          	sll	a5,a5,s1
    80006854:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    80006858:	00093783          	ld	a5,0(s2)
    8000685c:	97ce                	add	a5,a5,s3
    8000685e:	2581                	sext.w	a1,a1
    80006860:	6b88                	ld	a0,16(a5)
    80006862:	00000097          	auipc	ra,0x0
    80006866:	ca2080e7          	jalr	-862(ra) # 80006504 <bit_set>
  for(; k > fk; k--) {
    8000686a:	069c5363          	bge	s8,s1,800068d0 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000686e:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006870:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006872:	00003d17          	auipc	s10,0x3
    80006876:	7a6d0d13          	addi	s10,s10,1958 # 8000a018 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    8000687a:	85a6                	mv	a1,s1
    8000687c:	34fd                	addiw	s1,s1,-1
    8000687e:	009b9ab3          	sll	s5,s7,s1
    80006882:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006886:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    8000688a:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000688e:	412b093b          	subw	s2,s6,s2
    80006892:	00bb95b3          	sll	a1,s7,a1
    80006896:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000689a:	013a07b3          	add	a5,s4,s3
    8000689e:	2581                	sext.w	a1,a1
    800068a0:	6f88                	ld	a0,24(a5)
    800068a2:	00000097          	auipc	ra,0x0
    800068a6:	c62080e7          	jalr	-926(ra) # 80006504 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068aa:	1981                	addi	s3,s3,-32
    800068ac:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800068ae:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    800068b2:	2581                	sext.w	a1,a1
    800068b4:	010a3503          	ld	a0,16(s4)
    800068b8:	00000097          	auipc	ra,0x0
    800068bc:	c4c080e7          	jalr	-948(ra) # 80006504 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    800068c0:	85e6                	mv	a1,s9
    800068c2:	8552                	mv	a0,s4
    800068c4:	00001097          	auipc	ra,0x1
    800068c8:	820080e7          	jalr	-2016(ra) # 800070e4 <lst_push>
  for(; k > fk; k--) {
    800068cc:	fb8497e3          	bne	s1,s8,8000687a <bd_malloc+0xf0>
  }
  release(&lock);
    800068d0:	00032517          	auipc	a0,0x32
    800068d4:	ae050513          	addi	a0,a0,-1312 # 800383b0 <lock>
    800068d8:	ffffa097          	auipc	ra,0xffffa
    800068dc:	38a080e7          	jalr	906(ra) # 80000c62 <release>

  return p;
}
    800068e0:	855a                	mv	a0,s6
    800068e2:	70a6                	ld	ra,104(sp)
    800068e4:	7406                	ld	s0,96(sp)
    800068e6:	64e6                	ld	s1,88(sp)
    800068e8:	6946                	ld	s2,80(sp)
    800068ea:	69a6                	ld	s3,72(sp)
    800068ec:	6a06                	ld	s4,64(sp)
    800068ee:	7ae2                	ld	s5,56(sp)
    800068f0:	7b42                	ld	s6,48(sp)
    800068f2:	7ba2                	ld	s7,40(sp)
    800068f4:	7c02                	ld	s8,32(sp)
    800068f6:	6ce2                	ld	s9,24(sp)
    800068f8:	6d42                	ld	s10,16(sp)
    800068fa:	6da2                	ld	s11,8(sp)
    800068fc:	6165                	addi	sp,sp,112
    800068fe:	8082                	ret

0000000080006900 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006900:	7139                	addi	sp,sp,-64
    80006902:	fc06                	sd	ra,56(sp)
    80006904:	f822                	sd	s0,48(sp)
    80006906:	f426                	sd	s1,40(sp)
    80006908:	f04a                	sd	s2,32(sp)
    8000690a:	ec4e                	sd	s3,24(sp)
    8000690c:	e852                	sd	s4,16(sp)
    8000690e:	e456                	sd	s5,8(sp)
    80006910:	e05a                	sd	s6,0(sp)
    80006912:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006914:	00003a97          	auipc	s5,0x3
    80006918:	714aaa83          	lw	s5,1812(s5) # 8000a028 <nsizes>
  return n / BLK_SIZE(k);
    8000691c:	00003a17          	auipc	s4,0x3
    80006920:	6fca3a03          	ld	s4,1788(s4) # 8000a018 <bd_base>
    80006924:	41450a3b          	subw	s4,a0,s4
    80006928:	00003497          	auipc	s1,0x3
    8000692c:	6f84b483          	ld	s1,1784(s1) # 8000a020 <bd_sizes>
    80006930:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006934:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006936:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006938:	03595363          	bge	s2,s5,8000695e <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000693c:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006940:	013b15b3          	sll	a1,s6,s3
    80006944:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006948:	2581                	sext.w	a1,a1
    8000694a:	6088                	ld	a0,0(s1)
    8000694c:	00000097          	auipc	ra,0x0
    80006950:	b80080e7          	jalr	-1152(ra) # 800064cc <bit_isset>
    80006954:	02048493          	addi	s1,s1,32
    80006958:	e501                	bnez	a0,80006960 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    8000695a:	894e                	mv	s2,s3
    8000695c:	bff1                	j	80006938 <size+0x38>
      return k;
    }
  }
  return 0;
    8000695e:	4901                	li	s2,0
}
    80006960:	854a                	mv	a0,s2
    80006962:	70e2                	ld	ra,56(sp)
    80006964:	7442                	ld	s0,48(sp)
    80006966:	74a2                	ld	s1,40(sp)
    80006968:	7902                	ld	s2,32(sp)
    8000696a:	69e2                	ld	s3,24(sp)
    8000696c:	6a42                	ld	s4,16(sp)
    8000696e:	6aa2                	ld	s5,8(sp)
    80006970:	6b02                	ld	s6,0(sp)
    80006972:	6121                	addi	sp,sp,64
    80006974:	8082                	ret

0000000080006976 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006976:	7159                	addi	sp,sp,-112
    80006978:	f486                	sd	ra,104(sp)
    8000697a:	f0a2                	sd	s0,96(sp)
    8000697c:	eca6                	sd	s1,88(sp)
    8000697e:	e8ca                	sd	s2,80(sp)
    80006980:	e4ce                	sd	s3,72(sp)
    80006982:	e0d2                	sd	s4,64(sp)
    80006984:	fc56                	sd	s5,56(sp)
    80006986:	f85a                	sd	s6,48(sp)
    80006988:	f45e                	sd	s7,40(sp)
    8000698a:	f062                	sd	s8,32(sp)
    8000698c:	ec66                	sd	s9,24(sp)
    8000698e:	e86a                	sd	s10,16(sp)
    80006990:	e46e                	sd	s11,8(sp)
    80006992:	1880                	addi	s0,sp,112
    80006994:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006996:	00032517          	auipc	a0,0x32
    8000699a:	a1a50513          	addi	a0,a0,-1510 # 800383b0 <lock>
    8000699e:	ffffa097          	auipc	ra,0xffffa
    800069a2:	1f4080e7          	jalr	500(ra) # 80000b92 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800069a6:	8556                	mv	a0,s5
    800069a8:	00000097          	auipc	ra,0x0
    800069ac:	f58080e7          	jalr	-168(ra) # 80006900 <size>
    800069b0:	84aa                	mv	s1,a0
    800069b2:	00003797          	auipc	a5,0x3
    800069b6:	6767a783          	lw	a5,1654(a5) # 8000a028 <nsizes>
    800069ba:	37fd                	addiw	a5,a5,-1
    800069bc:	0cf55063          	bge	a0,a5,80006a7c <bd_free+0x106>
    800069c0:	00150a13          	addi	s4,a0,1
    800069c4:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    800069c6:	00003c17          	auipc	s8,0x3
    800069ca:	652c0c13          	addi	s8,s8,1618 # 8000a018 <bd_base>
  return n / BLK_SIZE(k);
    800069ce:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    800069d0:	00003b17          	auipc	s6,0x3
    800069d4:	650b0b13          	addi	s6,s6,1616 # 8000a020 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    800069d8:	00003c97          	auipc	s9,0x3
    800069dc:	650c8c93          	addi	s9,s9,1616 # 8000a028 <nsizes>
    800069e0:	a82d                	j	80006a1a <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    800069e2:	fff58d9b          	addiw	s11,a1,-1
    800069e6:	a881                	j	80006a36 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069e8:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    800069ea:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    800069ee:	40ba85bb          	subw	a1,s5,a1
    800069f2:	009b97b3          	sll	a5,s7,s1
    800069f6:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    800069fa:	000b3783          	ld	a5,0(s6)
    800069fe:	97d2                	add	a5,a5,s4
    80006a00:	2581                	sext.w	a1,a1
    80006a02:	6f88                	ld	a0,24(a5)
    80006a04:	00000097          	auipc	ra,0x0
    80006a08:	b30080e7          	jalr	-1232(ra) # 80006534 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a0c:	020a0a13          	addi	s4,s4,32
    80006a10:	000ca783          	lw	a5,0(s9)
    80006a14:	37fd                	addiw	a5,a5,-1
    80006a16:	06f4d363          	bge	s1,a5,80006a7c <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006a1a:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006a1e:	009b99b3          	sll	s3,s7,s1
    80006a22:	412a87bb          	subw	a5,s5,s2
    80006a26:	0337c7b3          	div	a5,a5,s3
    80006a2a:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a2e:	8b85                	andi	a5,a5,1
    80006a30:	fbcd                	bnez	a5,800069e2 <bd_free+0x6c>
    80006a32:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006a36:	fe0a0d13          	addi	s10,s4,-32
    80006a3a:	000b3783          	ld	a5,0(s6)
    80006a3e:	9d3e                	add	s10,s10,a5
    80006a40:	010d3503          	ld	a0,16(s10)
    80006a44:	00000097          	auipc	ra,0x0
    80006a48:	af0080e7          	jalr	-1296(ra) # 80006534 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006a4c:	85ee                	mv	a1,s11
    80006a4e:	010d3503          	ld	a0,16(s10)
    80006a52:	00000097          	auipc	ra,0x0
    80006a56:	a7a080e7          	jalr	-1414(ra) # 800064cc <bit_isset>
    80006a5a:	e10d                	bnez	a0,80006a7c <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006a5c:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006a60:	03b989bb          	mulw	s3,s3,s11
    80006a64:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006a66:	854a                	mv	a0,s2
    80006a68:	00000097          	auipc	ra,0x0
    80006a6c:	630080e7          	jalr	1584(ra) # 80007098 <lst_remove>
    if(buddy % 2 == 0) {
    80006a70:	001d7d13          	andi	s10,s10,1
    80006a74:	f60d1ae3          	bnez	s10,800069e8 <bd_free+0x72>
      p = q;
    80006a78:	8aca                	mv	s5,s2
    80006a7a:	b7bd                	j	800069e8 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006a7c:	0496                	slli	s1,s1,0x5
    80006a7e:	85d6                	mv	a1,s5
    80006a80:	00003517          	auipc	a0,0x3
    80006a84:	5a053503          	ld	a0,1440(a0) # 8000a020 <bd_sizes>
    80006a88:	9526                	add	a0,a0,s1
    80006a8a:	00000097          	auipc	ra,0x0
    80006a8e:	65a080e7          	jalr	1626(ra) # 800070e4 <lst_push>
  release(&lock);
    80006a92:	00032517          	auipc	a0,0x32
    80006a96:	91e50513          	addi	a0,a0,-1762 # 800383b0 <lock>
    80006a9a:	ffffa097          	auipc	ra,0xffffa
    80006a9e:	1c8080e7          	jalr	456(ra) # 80000c62 <release>
}
    80006aa2:	70a6                	ld	ra,104(sp)
    80006aa4:	7406                	ld	s0,96(sp)
    80006aa6:	64e6                	ld	s1,88(sp)
    80006aa8:	6946                	ld	s2,80(sp)
    80006aaa:	69a6                	ld	s3,72(sp)
    80006aac:	6a06                	ld	s4,64(sp)
    80006aae:	7ae2                	ld	s5,56(sp)
    80006ab0:	7b42                	ld	s6,48(sp)
    80006ab2:	7ba2                	ld	s7,40(sp)
    80006ab4:	7c02                	ld	s8,32(sp)
    80006ab6:	6ce2                	ld	s9,24(sp)
    80006ab8:	6d42                	ld	s10,16(sp)
    80006aba:	6da2                	ld	s11,8(sp)
    80006abc:	6165                	addi	sp,sp,112
    80006abe:	8082                	ret

0000000080006ac0 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006ac0:	1141                	addi	sp,sp,-16
    80006ac2:	e422                	sd	s0,8(sp)
    80006ac4:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006ac6:	00003797          	auipc	a5,0x3
    80006aca:	5527b783          	ld	a5,1362(a5) # 8000a018 <bd_base>
    80006ace:	8d9d                	sub	a1,a1,a5
    80006ad0:	47c1                	li	a5,16
    80006ad2:	00a797b3          	sll	a5,a5,a0
    80006ad6:	02f5c533          	div	a0,a1,a5
    80006ada:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006adc:	02f5e5b3          	rem	a1,a1,a5
    80006ae0:	c191                	beqz	a1,80006ae4 <blk_index_next+0x24>
      n++;
    80006ae2:	2505                	addiw	a0,a0,1
  return n ;
}
    80006ae4:	6422                	ld	s0,8(sp)
    80006ae6:	0141                	addi	sp,sp,16
    80006ae8:	8082                	ret

0000000080006aea <log2>:

int
log2(uint64 n) {
    80006aea:	1141                	addi	sp,sp,-16
    80006aec:	e422                	sd	s0,8(sp)
    80006aee:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006af0:	4705                	li	a4,1
    80006af2:	00a77b63          	bgeu	a4,a0,80006b08 <log2+0x1e>
    80006af6:	87aa                	mv	a5,a0
  int k = 0;
    80006af8:	4501                	li	a0,0
    k++;
    80006afa:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006afc:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006afe:	fef76ee3          	bltu	a4,a5,80006afa <log2+0x10>
  }
  return k;
}
    80006b02:	6422                	ld	s0,8(sp)
    80006b04:	0141                	addi	sp,sp,16
    80006b06:	8082                	ret
  int k = 0;
    80006b08:	4501                	li	a0,0
    80006b0a:	bfe5                	j	80006b02 <log2+0x18>

0000000080006b0c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006b0c:	711d                	addi	sp,sp,-96
    80006b0e:	ec86                	sd	ra,88(sp)
    80006b10:	e8a2                	sd	s0,80(sp)
    80006b12:	e4a6                	sd	s1,72(sp)
    80006b14:	e0ca                	sd	s2,64(sp)
    80006b16:	fc4e                	sd	s3,56(sp)
    80006b18:	f852                	sd	s4,48(sp)
    80006b1a:	f456                	sd	s5,40(sp)
    80006b1c:	f05a                	sd	s6,32(sp)
    80006b1e:	ec5e                	sd	s7,24(sp)
    80006b20:	e862                	sd	s8,16(sp)
    80006b22:	e466                	sd	s9,8(sp)
    80006b24:	e06a                	sd	s10,0(sp)
    80006b26:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006b28:	00b56933          	or	s2,a0,a1
    80006b2c:	00f97913          	andi	s2,s2,15
    80006b30:	04091263          	bnez	s2,80006b74 <bd_mark+0x68>
    80006b34:	8b2a                	mv	s6,a0
    80006b36:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006b38:	00003c17          	auipc	s8,0x3
    80006b3c:	4f0c2c03          	lw	s8,1264(s8) # 8000a028 <nsizes>
    80006b40:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006b42:	00003d17          	auipc	s10,0x3
    80006b46:	4d6d0d13          	addi	s10,s10,1238 # 8000a018 <bd_base>
  return n / BLK_SIZE(k);
    80006b4a:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006b4c:	00003a97          	auipc	s5,0x3
    80006b50:	4d4a8a93          	addi	s5,s5,1236 # 8000a020 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006b54:	07804563          	bgtz	s8,80006bbe <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006b58:	60e6                	ld	ra,88(sp)
    80006b5a:	6446                	ld	s0,80(sp)
    80006b5c:	64a6                	ld	s1,72(sp)
    80006b5e:	6906                	ld	s2,64(sp)
    80006b60:	79e2                	ld	s3,56(sp)
    80006b62:	7a42                	ld	s4,48(sp)
    80006b64:	7aa2                	ld	s5,40(sp)
    80006b66:	7b02                	ld	s6,32(sp)
    80006b68:	6be2                	ld	s7,24(sp)
    80006b6a:	6c42                	ld	s8,16(sp)
    80006b6c:	6ca2                	ld	s9,8(sp)
    80006b6e:	6d02                	ld	s10,0(sp)
    80006b70:	6125                	addi	sp,sp,96
    80006b72:	8082                	ret
    panic("bd_mark");
    80006b74:	00003517          	auipc	a0,0x3
    80006b78:	34450513          	addi	a0,a0,836 # 80009eb8 <syscalls+0x498>
    80006b7c:	ffffa097          	auipc	ra,0xffffa
    80006b80:	9e8080e7          	jalr	-1560(ra) # 80000564 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006b84:	000ab783          	ld	a5,0(s5)
    80006b88:	97ca                	add	a5,a5,s2
    80006b8a:	85a6                	mv	a1,s1
    80006b8c:	6b88                	ld	a0,16(a5)
    80006b8e:	00000097          	auipc	ra,0x0
    80006b92:	976080e7          	jalr	-1674(ra) # 80006504 <bit_set>
    for(; bi < bj; bi++) {
    80006b96:	2485                	addiw	s1,s1,1
    80006b98:	009a0e63          	beq	s4,s1,80006bb4 <bd_mark+0xa8>
      if(k > 0) {
    80006b9c:	ff3054e3          	blez	s3,80006b84 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006ba0:	000ab783          	ld	a5,0(s5)
    80006ba4:	97ca                	add	a5,a5,s2
    80006ba6:	85a6                	mv	a1,s1
    80006ba8:	6f88                	ld	a0,24(a5)
    80006baa:	00000097          	auipc	ra,0x0
    80006bae:	95a080e7          	jalr	-1702(ra) # 80006504 <bit_set>
    80006bb2:	bfc9                	j	80006b84 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006bb4:	2985                	addiw	s3,s3,1
    80006bb6:	02090913          	addi	s2,s2,32
    80006bba:	f9898fe3          	beq	s3,s8,80006b58 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006bbe:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006bc2:	409b04bb          	subw	s1,s6,s1
    80006bc6:	013c97b3          	sll	a5,s9,s3
    80006bca:	02f4c4b3          	div	s1,s1,a5
    80006bce:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006bd0:	85de                	mv	a1,s7
    80006bd2:	854e                	mv	a0,s3
    80006bd4:	00000097          	auipc	ra,0x0
    80006bd8:	eec080e7          	jalr	-276(ra) # 80006ac0 <blk_index_next>
    80006bdc:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006bde:	faa4cfe3          	blt	s1,a0,80006b9c <bd_mark+0x90>
    80006be2:	bfc9                	j	80006bb4 <bd_mark+0xa8>

0000000080006be4 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006be4:	7139                	addi	sp,sp,-64
    80006be6:	fc06                	sd	ra,56(sp)
    80006be8:	f822                	sd	s0,48(sp)
    80006bea:	f426                	sd	s1,40(sp)
    80006bec:	f04a                	sd	s2,32(sp)
    80006bee:	ec4e                	sd	s3,24(sp)
    80006bf0:	e852                	sd	s4,16(sp)
    80006bf2:	e456                	sd	s5,8(sp)
    80006bf4:	e05a                	sd	s6,0(sp)
    80006bf6:	0080                	addi	s0,sp,64
    80006bf8:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bfa:	00058a9b          	sext.w	s5,a1
    80006bfe:	0015f793          	andi	a5,a1,1
    80006c02:	ebad                	bnez	a5,80006c74 <bd_initfree_pair+0x90>
    80006c04:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c08:	00599493          	slli	s1,s3,0x5
    80006c0c:	00003797          	auipc	a5,0x3
    80006c10:	4147b783          	ld	a5,1044(a5) # 8000a020 <bd_sizes>
    80006c14:	94be                	add	s1,s1,a5
    80006c16:	0104bb03          	ld	s6,16(s1)
    80006c1a:	855a                	mv	a0,s6
    80006c1c:	00000097          	auipc	ra,0x0
    80006c20:	8b0080e7          	jalr	-1872(ra) # 800064cc <bit_isset>
    80006c24:	892a                	mv	s2,a0
    80006c26:	85d2                	mv	a1,s4
    80006c28:	855a                	mv	a0,s6
    80006c2a:	00000097          	auipc	ra,0x0
    80006c2e:	8a2080e7          	jalr	-1886(ra) # 800064cc <bit_isset>
  int free = 0;
    80006c32:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c34:	02a90563          	beq	s2,a0,80006c5e <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006c38:	45c1                	li	a1,16
    80006c3a:	013599b3          	sll	s3,a1,s3
    80006c3e:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006c42:	02090c63          	beqz	s2,80006c7a <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006c46:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006c4a:	00003597          	auipc	a1,0x3
    80006c4e:	3ce5b583          	ld	a1,974(a1) # 8000a018 <bd_base>
    80006c52:	95ce                	add	a1,a1,s3
    80006c54:	8526                	mv	a0,s1
    80006c56:	00000097          	auipc	ra,0x0
    80006c5a:	48e080e7          	jalr	1166(ra) # 800070e4 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006c5e:	855a                	mv	a0,s6
    80006c60:	70e2                	ld	ra,56(sp)
    80006c62:	7442                	ld	s0,48(sp)
    80006c64:	74a2                	ld	s1,40(sp)
    80006c66:	7902                	ld	s2,32(sp)
    80006c68:	69e2                	ld	s3,24(sp)
    80006c6a:	6a42                	ld	s4,16(sp)
    80006c6c:	6aa2                	ld	s5,8(sp)
    80006c6e:	6b02                	ld	s6,0(sp)
    80006c70:	6121                	addi	sp,sp,64
    80006c72:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c74:	fff58a1b          	addiw	s4,a1,-1
    80006c78:	bf41                	j	80006c08 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006c7a:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006c7e:	00003597          	auipc	a1,0x3
    80006c82:	39a5b583          	ld	a1,922(a1) # 8000a018 <bd_base>
    80006c86:	95ce                	add	a1,a1,s3
    80006c88:	8526                	mv	a0,s1
    80006c8a:	00000097          	auipc	ra,0x0
    80006c8e:	45a080e7          	jalr	1114(ra) # 800070e4 <lst_push>
    80006c92:	b7f1                	j	80006c5e <bd_initfree_pair+0x7a>

0000000080006c94 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006c94:	711d                	addi	sp,sp,-96
    80006c96:	ec86                	sd	ra,88(sp)
    80006c98:	e8a2                	sd	s0,80(sp)
    80006c9a:	e4a6                	sd	s1,72(sp)
    80006c9c:	e0ca                	sd	s2,64(sp)
    80006c9e:	fc4e                	sd	s3,56(sp)
    80006ca0:	f852                	sd	s4,48(sp)
    80006ca2:	f456                	sd	s5,40(sp)
    80006ca4:	f05a                	sd	s6,32(sp)
    80006ca6:	ec5e                	sd	s7,24(sp)
    80006ca8:	e862                	sd	s8,16(sp)
    80006caa:	e466                	sd	s9,8(sp)
    80006cac:	e06a                	sd	s10,0(sp)
    80006cae:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006cb0:	00003717          	auipc	a4,0x3
    80006cb4:	37872703          	lw	a4,888(a4) # 8000a028 <nsizes>
    80006cb8:	4785                	li	a5,1
    80006cba:	06e7db63          	bge	a5,a4,80006d30 <bd_initfree+0x9c>
    80006cbe:	8aaa                	mv	s5,a0
    80006cc0:	8b2e                	mv	s6,a1
    80006cc2:	4901                	li	s2,0
  int free = 0;
    80006cc4:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006cc6:	00003c97          	auipc	s9,0x3
    80006cca:	352c8c93          	addi	s9,s9,850 # 8000a018 <bd_base>
  return n / BLK_SIZE(k);
    80006cce:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006cd0:	00003b97          	auipc	s7,0x3
    80006cd4:	358b8b93          	addi	s7,s7,856 # 8000a028 <nsizes>
    80006cd8:	a039                	j	80006ce6 <bd_initfree+0x52>
    80006cda:	2905                	addiw	s2,s2,1
    80006cdc:	000ba783          	lw	a5,0(s7)
    80006ce0:	37fd                	addiw	a5,a5,-1
    80006ce2:	04f95863          	bge	s2,a5,80006d32 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006ce6:	85d6                	mv	a1,s5
    80006ce8:	854a                	mv	a0,s2
    80006cea:	00000097          	auipc	ra,0x0
    80006cee:	dd6080e7          	jalr	-554(ra) # 80006ac0 <blk_index_next>
    80006cf2:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006cf4:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006cf8:	409b04bb          	subw	s1,s6,s1
    80006cfc:	012c17b3          	sll	a5,s8,s2
    80006d00:	02f4c4b3          	div	s1,s1,a5
    80006d04:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006d06:	85aa                	mv	a1,a0
    80006d08:	854a                	mv	a0,s2
    80006d0a:	00000097          	auipc	ra,0x0
    80006d0e:	eda080e7          	jalr	-294(ra) # 80006be4 <bd_initfree_pair>
    80006d12:	01450d3b          	addw	s10,a0,s4
    80006d16:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006d1a:	fc99d0e3          	bge	s3,s1,80006cda <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006d1e:	85a6                	mv	a1,s1
    80006d20:	854a                	mv	a0,s2
    80006d22:	00000097          	auipc	ra,0x0
    80006d26:	ec2080e7          	jalr	-318(ra) # 80006be4 <bd_initfree_pair>
    80006d2a:	00ad0a3b          	addw	s4,s10,a0
    80006d2e:	b775                	j	80006cda <bd_initfree+0x46>
  int free = 0;
    80006d30:	4a01                	li	s4,0
  }
  return free;
}
    80006d32:	8552                	mv	a0,s4
    80006d34:	60e6                	ld	ra,88(sp)
    80006d36:	6446                	ld	s0,80(sp)
    80006d38:	64a6                	ld	s1,72(sp)
    80006d3a:	6906                	ld	s2,64(sp)
    80006d3c:	79e2                	ld	s3,56(sp)
    80006d3e:	7a42                	ld	s4,48(sp)
    80006d40:	7aa2                	ld	s5,40(sp)
    80006d42:	7b02                	ld	s6,32(sp)
    80006d44:	6be2                	ld	s7,24(sp)
    80006d46:	6c42                	ld	s8,16(sp)
    80006d48:	6ca2                	ld	s9,8(sp)
    80006d4a:	6d02                	ld	s10,0(sp)
    80006d4c:	6125                	addi	sp,sp,96
    80006d4e:	8082                	ret

0000000080006d50 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006d50:	7179                	addi	sp,sp,-48
    80006d52:	f406                	sd	ra,40(sp)
    80006d54:	f022                	sd	s0,32(sp)
    80006d56:	ec26                	sd	s1,24(sp)
    80006d58:	e84a                	sd	s2,16(sp)
    80006d5a:	e44e                	sd	s3,8(sp)
    80006d5c:	1800                	addi	s0,sp,48
    80006d5e:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006d60:	00003997          	auipc	s3,0x3
    80006d64:	2b898993          	addi	s3,s3,696 # 8000a018 <bd_base>
    80006d68:	0009b483          	ld	s1,0(s3)
    80006d6c:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006d70:	00003797          	auipc	a5,0x3
    80006d74:	2b87a783          	lw	a5,696(a5) # 8000a028 <nsizes>
    80006d78:	37fd                	addiw	a5,a5,-1
    80006d7a:	4641                	li	a2,16
    80006d7c:	00f61633          	sll	a2,a2,a5
    80006d80:	85a6                	mv	a1,s1
    80006d82:	00003517          	auipc	a0,0x3
    80006d86:	13e50513          	addi	a0,a0,318 # 80009ec0 <syscalls+0x4a0>
    80006d8a:	ffffa097          	auipc	ra,0xffffa
    80006d8e:	83c080e7          	jalr	-1988(ra) # 800005c6 <printf>
  bd_mark(bd_base, p);
    80006d92:	85ca                	mv	a1,s2
    80006d94:	0009b503          	ld	a0,0(s3)
    80006d98:	00000097          	auipc	ra,0x0
    80006d9c:	d74080e7          	jalr	-652(ra) # 80006b0c <bd_mark>
  return meta;
}
    80006da0:	8526                	mv	a0,s1
    80006da2:	70a2                	ld	ra,40(sp)
    80006da4:	7402                	ld	s0,32(sp)
    80006da6:	64e2                	ld	s1,24(sp)
    80006da8:	6942                	ld	s2,16(sp)
    80006daa:	69a2                	ld	s3,8(sp)
    80006dac:	6145                	addi	sp,sp,48
    80006dae:	8082                	ret

0000000080006db0 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006db0:	1101                	addi	sp,sp,-32
    80006db2:	ec06                	sd	ra,24(sp)
    80006db4:	e822                	sd	s0,16(sp)
    80006db6:	e426                	sd	s1,8(sp)
    80006db8:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006dba:	00003497          	auipc	s1,0x3
    80006dbe:	26e4a483          	lw	s1,622(s1) # 8000a028 <nsizes>
    80006dc2:	fff4879b          	addiw	a5,s1,-1
    80006dc6:	44c1                	li	s1,16
    80006dc8:	00f494b3          	sll	s1,s1,a5
    80006dcc:	00003797          	auipc	a5,0x3
    80006dd0:	24c7b783          	ld	a5,588(a5) # 8000a018 <bd_base>
    80006dd4:	8d1d                	sub	a0,a0,a5
    80006dd6:	40a4853b          	subw	a0,s1,a0
    80006dda:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006dde:	00905a63          	blez	s1,80006df2 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006de2:	357d                	addiw	a0,a0,-1
    80006de4:	41f5549b          	sraiw	s1,a0,0x1f
    80006de8:	01c4d49b          	srliw	s1,s1,0x1c
    80006dec:	9ca9                	addw	s1,s1,a0
    80006dee:	98c1                	andi	s1,s1,-16
    80006df0:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006df2:	85a6                	mv	a1,s1
    80006df4:	00003517          	auipc	a0,0x3
    80006df8:	10450513          	addi	a0,a0,260 # 80009ef8 <syscalls+0x4d8>
    80006dfc:	ffff9097          	auipc	ra,0xffff9
    80006e00:	7ca080e7          	jalr	1994(ra) # 800005c6 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006e04:	00003717          	auipc	a4,0x3
    80006e08:	21473703          	ld	a4,532(a4) # 8000a018 <bd_base>
    80006e0c:	00003597          	auipc	a1,0x3
    80006e10:	21c5a583          	lw	a1,540(a1) # 8000a028 <nsizes>
    80006e14:	fff5879b          	addiw	a5,a1,-1
    80006e18:	45c1                	li	a1,16
    80006e1a:	00f595b3          	sll	a1,a1,a5
    80006e1e:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006e22:	95ba                	add	a1,a1,a4
    80006e24:	953a                	add	a0,a0,a4
    80006e26:	00000097          	auipc	ra,0x0
    80006e2a:	ce6080e7          	jalr	-794(ra) # 80006b0c <bd_mark>
  return unavailable;
}
    80006e2e:	8526                	mv	a0,s1
    80006e30:	60e2                	ld	ra,24(sp)
    80006e32:	6442                	ld	s0,16(sp)
    80006e34:	64a2                	ld	s1,8(sp)
    80006e36:	6105                	addi	sp,sp,32
    80006e38:	8082                	ret

0000000080006e3a <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006e3a:	715d                	addi	sp,sp,-80
    80006e3c:	e486                	sd	ra,72(sp)
    80006e3e:	e0a2                	sd	s0,64(sp)
    80006e40:	fc26                	sd	s1,56(sp)
    80006e42:	f84a                	sd	s2,48(sp)
    80006e44:	f44e                	sd	s3,40(sp)
    80006e46:	f052                	sd	s4,32(sp)
    80006e48:	ec56                	sd	s5,24(sp)
    80006e4a:	e85a                	sd	s6,16(sp)
    80006e4c:	e45e                	sd	s7,8(sp)
    80006e4e:	e062                	sd	s8,0(sp)
    80006e50:	0880                	addi	s0,sp,80
    80006e52:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006e54:	fff50493          	addi	s1,a0,-1
    80006e58:	98c1                	andi	s1,s1,-16
    80006e5a:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006e5c:	00003597          	auipc	a1,0x3
    80006e60:	0bc58593          	addi	a1,a1,188 # 80009f18 <syscalls+0x4f8>
    80006e64:	00031517          	auipc	a0,0x31
    80006e68:	54c50513          	addi	a0,a0,1356 # 800383b0 <lock>
    80006e6c:	ffffa097          	auipc	ra,0xffffa
    80006e70:	c50080e7          	jalr	-944(ra) # 80000abc <initlock>
  bd_base = (void *) p;
    80006e74:	00003797          	auipc	a5,0x3
    80006e78:	1a97b223          	sd	s1,420(a5) # 8000a018 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e7c:	409c0933          	sub	s2,s8,s1
    80006e80:	43f95513          	srai	a0,s2,0x3f
    80006e84:	893d                	andi	a0,a0,15
    80006e86:	954a                	add	a0,a0,s2
    80006e88:	8511                	srai	a0,a0,0x4
    80006e8a:	00000097          	auipc	ra,0x0
    80006e8e:	c60080e7          	jalr	-928(ra) # 80006aea <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006e92:	47c1                	li	a5,16
    80006e94:	00a797b3          	sll	a5,a5,a0
    80006e98:	1b27c663          	blt	a5,s2,80007044 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006e9c:	2505                	addiw	a0,a0,1
    80006e9e:	00003797          	auipc	a5,0x3
    80006ea2:	18a7a523          	sw	a0,394(a5) # 8000a028 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006ea6:	00003997          	auipc	s3,0x3
    80006eaa:	18298993          	addi	s3,s3,386 # 8000a028 <nsizes>
    80006eae:	0009a603          	lw	a2,0(s3)
    80006eb2:	85ca                	mv	a1,s2
    80006eb4:	00003517          	auipc	a0,0x3
    80006eb8:	06c50513          	addi	a0,a0,108 # 80009f20 <syscalls+0x500>
    80006ebc:	ffff9097          	auipc	ra,0xffff9
    80006ec0:	70a080e7          	jalr	1802(ra) # 800005c6 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006ec4:	00003797          	auipc	a5,0x3
    80006ec8:	1497be23          	sd	s1,348(a5) # 8000a020 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006ecc:	0009a603          	lw	a2,0(s3)
    80006ed0:	00561913          	slli	s2,a2,0x5
    80006ed4:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006ed6:	0056161b          	slliw	a2,a2,0x5
    80006eda:	4581                	li	a1,0
    80006edc:	8526                	mv	a0,s1
    80006ede:	ffffa097          	auipc	ra,0xffffa
    80006ee2:	f98080e7          	jalr	-104(ra) # 80000e76 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006ee6:	0009a783          	lw	a5,0(s3)
    80006eea:	06f05a63          	blez	a5,80006f5e <bd_init+0x124>
    80006eee:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006ef0:	00003a97          	auipc	s5,0x3
    80006ef4:	130a8a93          	addi	s5,s5,304 # 8000a020 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006ef8:	00003a17          	auipc	s4,0x3
    80006efc:	130a0a13          	addi	s4,s4,304 # 8000a028 <nsizes>
    80006f00:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006f02:	00599b93          	slli	s7,s3,0x5
    80006f06:	000ab503          	ld	a0,0(s5)
    80006f0a:	955e                	add	a0,a0,s7
    80006f0c:	00000097          	auipc	ra,0x0
    80006f10:	166080e7          	jalr	358(ra) # 80007072 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f14:	000a2483          	lw	s1,0(s4)
    80006f18:	34fd                	addiw	s1,s1,-1
    80006f1a:	413484bb          	subw	s1,s1,s3
    80006f1e:	009b14bb          	sllw	s1,s6,s1
    80006f22:	fff4879b          	addiw	a5,s1,-1
    80006f26:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f2a:	01d4d49b          	srliw	s1,s1,0x1d
    80006f2e:	9cbd                	addw	s1,s1,a5
    80006f30:	98e1                	andi	s1,s1,-8
    80006f32:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006f34:	000ab783          	ld	a5,0(s5)
    80006f38:	9bbe                	add	s7,s7,a5
    80006f3a:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006f3e:	848d                	srai	s1,s1,0x3
    80006f40:	8626                	mv	a2,s1
    80006f42:	4581                	li	a1,0
    80006f44:	854a                	mv	a0,s2
    80006f46:	ffffa097          	auipc	ra,0xffffa
    80006f4a:	f30080e7          	jalr	-208(ra) # 80000e76 <memset>
    p += sz;
    80006f4e:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006f50:	0985                	addi	s3,s3,1
    80006f52:	000a2703          	lw	a4,0(s4)
    80006f56:	0009879b          	sext.w	a5,s3
    80006f5a:	fae7c4e3          	blt	a5,a4,80006f02 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006f5e:	00003797          	auipc	a5,0x3
    80006f62:	0ca7a783          	lw	a5,202(a5) # 8000a028 <nsizes>
    80006f66:	4705                	li	a4,1
    80006f68:	06f75163          	bge	a4,a5,80006fca <bd_init+0x190>
    80006f6c:	02000a13          	li	s4,32
    80006f70:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f72:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006f74:	00003b17          	auipc	s6,0x3
    80006f78:	0acb0b13          	addi	s6,s6,172 # 8000a020 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006f7c:	00003a97          	auipc	s5,0x3
    80006f80:	0aca8a93          	addi	s5,s5,172 # 8000a028 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006f84:	37fd                	addiw	a5,a5,-1
    80006f86:	413787bb          	subw	a5,a5,s3
    80006f8a:	00fb94bb          	sllw	s1,s7,a5
    80006f8e:	fff4879b          	addiw	a5,s1,-1
    80006f92:	41f7d49b          	sraiw	s1,a5,0x1f
    80006f96:	01d4d49b          	srliw	s1,s1,0x1d
    80006f9a:	9cbd                	addw	s1,s1,a5
    80006f9c:	98e1                	andi	s1,s1,-8
    80006f9e:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80006fa0:	000b3783          	ld	a5,0(s6)
    80006fa4:	97d2                	add	a5,a5,s4
    80006fa6:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80006faa:	848d                	srai	s1,s1,0x3
    80006fac:	8626                	mv	a2,s1
    80006fae:	4581                	li	a1,0
    80006fb0:	854a                	mv	a0,s2
    80006fb2:	ffffa097          	auipc	ra,0xffffa
    80006fb6:	ec4080e7          	jalr	-316(ra) # 80000e76 <memset>
    p += sz;
    80006fba:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80006fbc:	2985                	addiw	s3,s3,1
    80006fbe:	000aa783          	lw	a5,0(s5)
    80006fc2:	020a0a13          	addi	s4,s4,32
    80006fc6:	faf9cfe3          	blt	s3,a5,80006f84 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80006fca:	197d                	addi	s2,s2,-1
    80006fcc:	ff097913          	andi	s2,s2,-16
    80006fd0:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80006fd2:	854a                	mv	a0,s2
    80006fd4:	00000097          	auipc	ra,0x0
    80006fd8:	d7c080e7          	jalr	-644(ra) # 80006d50 <bd_mark_data_structures>
    80006fdc:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80006fde:	85ca                	mv	a1,s2
    80006fe0:	8562                	mv	a0,s8
    80006fe2:	00000097          	auipc	ra,0x0
    80006fe6:	dce080e7          	jalr	-562(ra) # 80006db0 <bd_mark_unavailable>
    80006fea:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006fec:	00003a97          	auipc	s5,0x3
    80006ff0:	03ca8a93          	addi	s5,s5,60 # 8000a028 <nsizes>
    80006ff4:	000aa783          	lw	a5,0(s5)
    80006ff8:	37fd                	addiw	a5,a5,-1
    80006ffa:	44c1                	li	s1,16
    80006ffc:	00f497b3          	sll	a5,s1,a5
    80007000:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007002:	00003597          	auipc	a1,0x3
    80007006:	0165b583          	ld	a1,22(a1) # 8000a018 <bd_base>
    8000700a:	95be                	add	a1,a1,a5
    8000700c:	854a                	mv	a0,s2
    8000700e:	00000097          	auipc	ra,0x0
    80007012:	c86080e7          	jalr	-890(ra) # 80006c94 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007016:	000aa603          	lw	a2,0(s5)
    8000701a:	367d                	addiw	a2,a2,-1
    8000701c:	00c49633          	sll	a2,s1,a2
    80007020:	41460633          	sub	a2,a2,s4
    80007024:	41360633          	sub	a2,a2,s3
    80007028:	02c51463          	bne	a0,a2,80007050 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    8000702c:	60a6                	ld	ra,72(sp)
    8000702e:	6406                	ld	s0,64(sp)
    80007030:	74e2                	ld	s1,56(sp)
    80007032:	7942                	ld	s2,48(sp)
    80007034:	79a2                	ld	s3,40(sp)
    80007036:	7a02                	ld	s4,32(sp)
    80007038:	6ae2                	ld	s5,24(sp)
    8000703a:	6b42                	ld	s6,16(sp)
    8000703c:	6ba2                	ld	s7,8(sp)
    8000703e:	6c02                	ld	s8,0(sp)
    80007040:	6161                	addi	sp,sp,80
    80007042:	8082                	ret
    nsizes++;  // round up to the next power of 2
    80007044:	2509                	addiw	a0,a0,2
    80007046:	00003797          	auipc	a5,0x3
    8000704a:	fea7a123          	sw	a0,-30(a5) # 8000a028 <nsizes>
    8000704e:	bda1                	j	80006ea6 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007050:	85aa                	mv	a1,a0
    80007052:	00003517          	auipc	a0,0x3
    80007056:	f0e50513          	addi	a0,a0,-242 # 80009f60 <syscalls+0x540>
    8000705a:	ffff9097          	auipc	ra,0xffff9
    8000705e:	56c080e7          	jalr	1388(ra) # 800005c6 <printf>
    panic("bd_init: free mem");
    80007062:	00003517          	auipc	a0,0x3
    80007066:	f0e50513          	addi	a0,a0,-242 # 80009f70 <syscalls+0x550>
    8000706a:	ffff9097          	auipc	ra,0xffff9
    8000706e:	4fa080e7          	jalr	1274(ra) # 80000564 <panic>

0000000080007072 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007072:	1141                	addi	sp,sp,-16
    80007074:	e422                	sd	s0,8(sp)
    80007076:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007078:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000707a:	e508                	sd	a0,8(a0)
}
    8000707c:	6422                	ld	s0,8(sp)
    8000707e:	0141                	addi	sp,sp,16
    80007080:	8082                	ret

0000000080007082 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007082:	1141                	addi	sp,sp,-16
    80007084:	e422                	sd	s0,8(sp)
    80007086:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007088:	611c                	ld	a5,0(a0)
    8000708a:	40a78533          	sub	a0,a5,a0
}
    8000708e:	00153513          	seqz	a0,a0
    80007092:	6422                	ld	s0,8(sp)
    80007094:	0141                	addi	sp,sp,16
    80007096:	8082                	ret

0000000080007098 <lst_remove>:

void
lst_remove(struct list *e) {
    80007098:	1141                	addi	sp,sp,-16
    8000709a:	e422                	sd	s0,8(sp)
    8000709c:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    8000709e:	6518                	ld	a4,8(a0)
    800070a0:	611c                	ld	a5,0(a0)
    800070a2:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    800070a4:	6518                	ld	a4,8(a0)
    800070a6:	e798                	sd	a4,8(a5)
}
    800070a8:	6422                	ld	s0,8(sp)
    800070aa:	0141                	addi	sp,sp,16
    800070ac:	8082                	ret

00000000800070ae <lst_pop>:

void*
lst_pop(struct list *lst) {
    800070ae:	1101                	addi	sp,sp,-32
    800070b0:	ec06                	sd	ra,24(sp)
    800070b2:	e822                	sd	s0,16(sp)
    800070b4:	e426                	sd	s1,8(sp)
    800070b6:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    800070b8:	6104                	ld	s1,0(a0)
    800070ba:	00a48d63          	beq	s1,a0,800070d4 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    800070be:	8526                	mv	a0,s1
    800070c0:	00000097          	auipc	ra,0x0
    800070c4:	fd8080e7          	jalr	-40(ra) # 80007098 <lst_remove>
  return (void *)p;
}
    800070c8:	8526                	mv	a0,s1
    800070ca:	60e2                	ld	ra,24(sp)
    800070cc:	6442                	ld	s0,16(sp)
    800070ce:	64a2                	ld	s1,8(sp)
    800070d0:	6105                	addi	sp,sp,32
    800070d2:	8082                	ret
    panic("lst_pop");
    800070d4:	00003517          	auipc	a0,0x3
    800070d8:	eb450513          	addi	a0,a0,-332 # 80009f88 <syscalls+0x568>
    800070dc:	ffff9097          	auipc	ra,0xffff9
    800070e0:	488080e7          	jalr	1160(ra) # 80000564 <panic>

00000000800070e4 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800070e4:	1141                	addi	sp,sp,-16
    800070e6:	e422                	sd	s0,8(sp)
    800070e8:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800070ea:	611c                	ld	a5,0(a0)
    800070ec:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800070ee:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800070f0:	611c                	ld	a5,0(a0)
    800070f2:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800070f4:	e10c                	sd	a1,0(a0)
}
    800070f6:	6422                	ld	s0,8(sp)
    800070f8:	0141                	addi	sp,sp,16
    800070fa:	8082                	ret

00000000800070fc <lst_print>:

void
lst_print(struct list *lst)
{
    800070fc:	7179                	addi	sp,sp,-48
    800070fe:	f406                	sd	ra,40(sp)
    80007100:	f022                	sd	s0,32(sp)
    80007102:	ec26                	sd	s1,24(sp)
    80007104:	e84a                	sd	s2,16(sp)
    80007106:	e44e                	sd	s3,8(sp)
    80007108:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000710a:	6104                	ld	s1,0(a0)
    8000710c:	02950063          	beq	a0,s1,8000712c <lst_print+0x30>
    80007110:	892a                	mv	s2,a0
    printf(" %p", p);
    80007112:	00003997          	auipc	s3,0x3
    80007116:	e7e98993          	addi	s3,s3,-386 # 80009f90 <syscalls+0x570>
    8000711a:	85a6                	mv	a1,s1
    8000711c:	854e                	mv	a0,s3
    8000711e:	ffff9097          	auipc	ra,0xffff9
    80007122:	4a8080e7          	jalr	1192(ra) # 800005c6 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    80007126:	6084                	ld	s1,0(s1)
    80007128:	fe9919e3          	bne	s2,s1,8000711a <lst_print+0x1e>
  }
  printf("\n");
    8000712c:	00002517          	auipc	a0,0x2
    80007130:	3dc50513          	addi	a0,a0,988 # 80009508 <digits+0x398>
    80007134:	ffff9097          	auipc	ra,0xffff9
    80007138:	492080e7          	jalr	1170(ra) # 800005c6 <printf>
}
    8000713c:	70a2                	ld	ra,40(sp)
    8000713e:	7402                	ld	s0,32(sp)
    80007140:	64e2                	ld	s1,24(sp)
    80007142:	6942                	ld	s2,16(sp)
    80007144:	69a2                	ld	s3,8(sp)
    80007146:	6145                	addi	sp,sp,48
    80007148:	8082                	ret
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

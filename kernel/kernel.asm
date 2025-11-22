
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
    80000068:	eec78793          	addi	a5,a5,-276 # 80005f50 <timervec>
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
    80000172:	36a080e7          	jalr	874(ra) # 800024d8 <sleep>
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
    800001ae:	5ce080e7          	jalr	1486(ra) # 80002778 <either_copyout>
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
    800002a0:	532080e7          	jalr	1330(ra) # 800027ce <either_copyin>
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
    8000031c:	50c080e7          	jalr	1292(ra) # 80002824 <procdump>
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
    80000470:	22a080e7          	jalr	554(ra) # 80002696 <wakeup>
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
    80000cf8:	194080e7          	jalr	404(ra) # 80002e88 <argint>
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
    80001092:	990080e7          	jalr	-1648(ra) # 80002a1e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001096:	00005097          	auipc	ra,0x5
    8000109a:	efa080e7          	jalr	-262(ra) # 80005f90 <plicinithart>
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
    8000110a:	8f0080e7          	jalr	-1808(ra) # 800029f6 <trapinit>
    trapinithart();  // install kernel trap vector
    8000110e:	00002097          	auipc	ra,0x2
    80001112:	910080e7          	jalr	-1776(ra) # 80002a1e <trapinithart>
    plicinit();      // set up interrupt controller
    80001116:	00005097          	auipc	ra,0x5
    8000111a:	e64080e7          	jalr	-412(ra) # 80005f7a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111e:	00005097          	auipc	ra,0x5
    80001122:	e72080e7          	jalr	-398(ra) # 80005f90 <plicinithart>
    binit();         // buffer cache
    80001126:	00002097          	auipc	ra,0x2
    8000112a:	042080e7          	jalr	66(ra) # 80003168 <binit>
    iinit();         // inode cache
    8000112e:	00002097          	auipc	ra,0x2
    80001132:	6d2080e7          	jalr	1746(ra) # 80003800 <iinit>
    fileinit();      // file table
    80001136:	00003097          	auipc	ra,0x3
    8000113a:	66a080e7          	jalr	1642(ra) # 800047a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000113e:	00005097          	auipc	ra,0x5
    80001142:	f4a080e7          	jalr	-182(ra) # 80006088 <virtio_disk_init>
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
    80001bae:	e8c080e7          	jalr	-372(ra) # 80002a36 <usertrapret>
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
    80001bc8:	bbc080e7          	jalr	-1092(ra) # 80003780 <fsinit>
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
    80001e5a:	358080e7          	jalr	856(ra) # 800041ae <namei>
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
    80001fac:	88a080e7          	jalr	-1910(ra) # 80004832 <filedup>
    80001fb0:	00a93023          	sd	a0,0(s2)
    80001fb4:	b7e5                	j	80001f9c <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001fb6:	158ab503          	ld	a0,344(s5)
    80001fba:	00002097          	auipc	ra,0x2
    80001fbe:	a00080e7          	jalr	-1536(ra) # 800039ba <idup>
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
    80002100:	7f6080e7          	jalr	2038(ra) # 800028f2 <swtch>
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
    800021f8:	6fe080e7          	jalr	1790(ra) # 800028f2 <swtch>
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
    800023be:	4ca080e7          	jalr	1226(ra) # 80004884 <fileclose>
      p->ofile[fd] = 0;
    800023c2:	0004b023          	sd	zero,0(s1)
    800023c6:	b7ed                	j	800023b0 <exit+0x146>
  begin_op();
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	ff2080e7          	jalr	-14(ra) # 800043ba <begin_op>
  iput(p->cwd);
    800023d0:	15893503          	ld	a0,344(s2)
    800023d4:	00001097          	auipc	ra,0x1
    800023d8:	7de080e7          	jalr	2014(ra) # 80003bb2 <iput>
  end_op();
    800023dc:	00002097          	auipc	ra,0x2
    800023e0:	05e080e7          	jalr	94(ra) # 8000443a <end_op>
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
  if(p->last_scheduled != 0) {
    80002496:	1904b783          	ld	a5,400(s1)
    8000249a:	e78d                	bnez	a5,800024c4 <yield+0x4a>
  p->state = RUNNABLE;
    8000249c:	4789                	li	a5,2
    8000249e:	d09c                	sw	a5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    800024a0:	c01027f3          	rdtime	a5
  p->wait_start = getTime();
    800024a4:	1af4b423          	sd	a5,424(s1)
  sched();
    800024a8:	00000097          	auipc	ra,0x0
    800024ac:	cd2080e7          	jalr	-814(ra) # 8000217a <sched>
  release(&p->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	7b0080e7          	jalr	1968(ra) # 80000c62 <release>
}
    800024ba:	60e2                	ld	ra,24(sp)
    800024bc:	6442                	ld	s0,16(sp)
    800024be:	64a2                	ld	s1,8(sp)
    800024c0:	6105                	addi	sp,sp,32
    800024c2:	8082                	ret
  asm volatile ("rdtime %0" : "=r" (time)); 
    800024c4:	c01026f3          	rdtime	a3
    p->total_run_time += getTime() - p->last_scheduled;
    800024c8:	1884b703          	ld	a4,392(s1)
    800024cc:	40f707b3          	sub	a5,a4,a5
    800024d0:	97b6                	add	a5,a5,a3
    800024d2:	18f4b423          	sd	a5,392(s1)
    800024d6:	b7d9                	j	8000249c <yield+0x22>

00000000800024d8 <sleep>:
{
    800024d8:	7179                	addi	sp,sp,-48
    800024da:	f406                	sd	ra,40(sp)
    800024dc:	f022                	sd	s0,32(sp)
    800024de:	ec26                	sd	s1,24(sp)
    800024e0:	e84a                	sd	s2,16(sp)
    800024e2:	e44e                	sd	s3,8(sp)
    800024e4:	e052                	sd	s4,0(sp)
    800024e6:	1800                	addi	s0,sp,48
    800024e8:	892a                	mv	s2,a0
    800024ea:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	664080e7          	jalr	1636(ra) # 80001b50 <myproc>
    800024f4:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800024f6:	8a2a                	mv	s4,a0
    800024f8:	09350063          	beq	a0,s3,80002578 <sleep+0xa0>
    acquire(&p->lock);  //DOC: sleeplock1
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	696080e7          	jalr	1686(ra) # 80000b92 <acquire>
    release(lk);
    80002504:	854e                	mv	a0,s3
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	75c080e7          	jalr	1884(ra) # 80000c62 <release>
  if(p->last_scheduled != 0) {
    8000250e:	1904b783          	ld	a5,400(s1)
    80002512:	ef8d                	bnez	a5,8000254c <sleep+0x74>
  p->chan = chan;
    80002514:	0324b823          	sd	s2,48(s1)
  p->state = SLEEPING;
    80002518:	4785                	li	a5,1
    8000251a:	d09c                	sw	a5,32(s1)
  sched();
    8000251c:	00000097          	auipc	ra,0x0
    80002520:	c5e080e7          	jalr	-930(ra) # 8000217a <sched>
  p->chan = 0;
    80002524:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	738080e7          	jalr	1848(ra) # 80000c62 <release>
    acquire(lk);
    80002532:	854e                	mv	a0,s3
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	65e080e7          	jalr	1630(ra) # 80000b92 <acquire>
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6a02                	ld	s4,0(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret
  asm volatile ("rdtime %0" : "=r" (time)); 
    8000254c:	c0102773          	rdtime	a4
    p->total_run_time += getTime() - p->last_scheduled;
    80002550:	1884b683          	ld	a3,392(s1)
    80002554:	9736                	add	a4,a4,a3
    80002556:	40f707b3          	sub	a5,a4,a5
    8000255a:	18f4b423          	sd	a5,392(s1)
  p->chan = chan;
    8000255e:	0324b823          	sd	s2,48(s1)
  p->state = SLEEPING;
    80002562:	4785                	li	a5,1
    80002564:	d09c                	sw	a5,32(s1)
  sched();
    80002566:	00000097          	auipc	ra,0x0
    8000256a:	c14080e7          	jalr	-1004(ra) # 8000217a <sched>
  p->chan = 0;
    8000256e:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002572:	fb3a1be3          	bne	s4,s3,80002528 <sleep+0x50>
    80002576:	b7d9                	j	8000253c <sleep+0x64>
  if(p->last_scheduled != 0) {
    80002578:	19053783          	ld	a5,400(a0)
    8000257c:	fbe1                	bnez	a5,8000254c <sleep+0x74>
  p->chan = chan;
    8000257e:	0324b823          	sd	s2,48(s1)
  p->state = SLEEPING;
    80002582:	4785                	li	a5,1
    80002584:	d09c                	sw	a5,32(s1)
  sched();
    80002586:	00000097          	auipc	ra,0x0
    8000258a:	bf4080e7          	jalr	-1036(ra) # 8000217a <sched>
  p->chan = 0;
    8000258e:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    80002592:	b76d                	j	8000253c <sleep+0x64>

0000000080002594 <wait>:
{
    80002594:	715d                	addi	sp,sp,-80
    80002596:	e486                	sd	ra,72(sp)
    80002598:	e0a2                	sd	s0,64(sp)
    8000259a:	fc26                	sd	s1,56(sp)
    8000259c:	f84a                	sd	s2,48(sp)
    8000259e:	f44e                	sd	s3,40(sp)
    800025a0:	f052                	sd	s4,32(sp)
    800025a2:	ec56                	sd	s5,24(sp)
    800025a4:	e85a                	sd	s6,16(sp)
    800025a6:	e45e                	sd	s7,8(sp)
    800025a8:	0880                	addi	s0,sp,80
    800025aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	5a4080e7          	jalr	1444(ra) # 80001b50 <myproc>
    800025b4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	5dc080e7          	jalr	1500(ra) # 80000b92 <acquire>
    havekids = 0;
    800025be:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800025c0:	4a11                	li	s4,4
        havekids = 1;
    800025c2:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800025c4:	0002a997          	auipc	s3,0x2a
    800025c8:	74498993          	addi	s3,s3,1860 # 8002cd08 <tickslock>
    havekids = 0;
    800025cc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800025ce:	00024497          	auipc	s1,0x24
    800025d2:	93a48493          	addi	s1,s1,-1734 # 80025f08 <proc>
    800025d6:	a08d                	j	80002638 <wait+0xa4>
          pid = np->pid;
    800025d8:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025dc:	000b0e63          	beqz	s6,800025f8 <wait+0x64>
    800025e0:	4691                	li	a3,4
    800025e2:	03c48613          	addi	a2,s1,60
    800025e6:	85da                	mv	a1,s6
    800025e8:	05893503          	ld	a0,88(s2)
    800025ec:	fffff097          	auipc	ra,0xfffff
    800025f0:	214080e7          	jalr	532(ra) # 80001800 <copyout>
    800025f4:	02054263          	bltz	a0,80002618 <wait+0x84>
          freeproc(np);
    800025f8:	8526                	mv	a0,s1
    800025fa:	fffff097          	auipc	ra,0xfffff
    800025fe:	7a6080e7          	jalr	1958(ra) # 80001da0 <freeproc>
          release(&np->lock);
    80002602:	8526                	mv	a0,s1
    80002604:	ffffe097          	auipc	ra,0xffffe
    80002608:	65e080e7          	jalr	1630(ra) # 80000c62 <release>
          release(&p->lock);
    8000260c:	854a                	mv	a0,s2
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	654080e7          	jalr	1620(ra) # 80000c62 <release>
          return pid;
    80002616:	a8a9                	j	80002670 <wait+0xdc>
            release(&np->lock);
    80002618:	8526                	mv	a0,s1
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	648080e7          	jalr	1608(ra) # 80000c62 <release>
            release(&p->lock);
    80002622:	854a                	mv	a0,s2
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	63e080e7          	jalr	1598(ra) # 80000c62 <release>
            return -1;
    8000262c:	59fd                	li	s3,-1
    8000262e:	a089                	j	80002670 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002630:	1b848493          	addi	s1,s1,440
    80002634:	03348463          	beq	s1,s3,8000265c <wait+0xc8>
      if(np->parent == p){
    80002638:	749c                	ld	a5,40(s1)
    8000263a:	ff279be3          	bne	a5,s2,80002630 <wait+0x9c>
        acquire(&np->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	552080e7          	jalr	1362(ra) # 80000b92 <acquire>
        if(np->state == ZOMBIE){
    80002648:	509c                	lw	a5,32(s1)
    8000264a:	f94787e3          	beq	a5,s4,800025d8 <wait+0x44>
        release(&np->lock);
    8000264e:	8526                	mv	a0,s1
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	612080e7          	jalr	1554(ra) # 80000c62 <release>
        havekids = 1;
    80002658:	8756                	mv	a4,s5
    8000265a:	bfd9                	j	80002630 <wait+0x9c>
    if(!havekids || p->killed){
    8000265c:	c701                	beqz	a4,80002664 <wait+0xd0>
    8000265e:	03892783          	lw	a5,56(s2)
    80002662:	c39d                	beqz	a5,80002688 <wait+0xf4>
      release(&p->lock);
    80002664:	854a                	mv	a0,s2
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	5fc080e7          	jalr	1532(ra) # 80000c62 <release>
      return -1;
    8000266e:	59fd                	li	s3,-1
}
    80002670:	854e                	mv	a0,s3
    80002672:	60a6                	ld	ra,72(sp)
    80002674:	6406                	ld	s0,64(sp)
    80002676:	74e2                	ld	s1,56(sp)
    80002678:	7942                	ld	s2,48(sp)
    8000267a:	79a2                	ld	s3,40(sp)
    8000267c:	7a02                	ld	s4,32(sp)
    8000267e:	6ae2                	ld	s5,24(sp)
    80002680:	6b42                	ld	s6,16(sp)
    80002682:	6ba2                	ld	s7,8(sp)
    80002684:	6161                	addi	sp,sp,80
    80002686:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002688:	85ca                	mv	a1,s2
    8000268a:	854a                	mv	a0,s2
    8000268c:	00000097          	auipc	ra,0x0
    80002690:	e4c080e7          	jalr	-436(ra) # 800024d8 <sleep>
    havekids = 0;
    80002694:	bf25                	j	800025cc <wait+0x38>

0000000080002696 <wakeup>:
{
    80002696:	7139                	addi	sp,sp,-64
    80002698:	fc06                	sd	ra,56(sp)
    8000269a:	f822                	sd	s0,48(sp)
    8000269c:	f426                	sd	s1,40(sp)
    8000269e:	f04a                	sd	s2,32(sp)
    800026a0:	ec4e                	sd	s3,24(sp)
    800026a2:	e852                	sd	s4,16(sp)
    800026a4:	e456                	sd	s5,8(sp)
    800026a6:	0080                	addi	s0,sp,64
    800026a8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800026aa:	00024497          	auipc	s1,0x24
    800026ae:	85e48493          	addi	s1,s1,-1954 # 80025f08 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800026b2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800026b4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800026b6:	0002a917          	auipc	s2,0x2a
    800026ba:	65290913          	addi	s2,s2,1618 # 8002cd08 <tickslock>
    800026be:	a811                	j	800026d2 <wakeup+0x3c>
    release(&p->lock);
    800026c0:	8526                	mv	a0,s1
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	5a0080e7          	jalr	1440(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026ca:	1b848493          	addi	s1,s1,440
    800026ce:	03248463          	beq	s1,s2,800026f6 <wakeup+0x60>
    acquire(&p->lock);
    800026d2:	8526                	mv	a0,s1
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	4be080e7          	jalr	1214(ra) # 80000b92 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800026dc:	509c                	lw	a5,32(s1)
    800026de:	ff3791e3          	bne	a5,s3,800026c0 <wakeup+0x2a>
    800026e2:	789c                	ld	a5,48(s1)
    800026e4:	fd479ee3          	bne	a5,s4,800026c0 <wakeup+0x2a>
      p->state = RUNNABLE;
    800026e8:	0354a023          	sw	s5,32(s1)
  asm volatile ("rdtime %0" : "=r" (time)); 
    800026ec:	c01027f3          	rdtime	a5
      p->wait_start = getTime();
    800026f0:	1af4b423          	sd	a5,424(s1)
    800026f4:	b7f1                	j	800026c0 <wakeup+0x2a>
}
    800026f6:	70e2                	ld	ra,56(sp)
    800026f8:	7442                	ld	s0,48(sp)
    800026fa:	74a2                	ld	s1,40(sp)
    800026fc:	7902                	ld	s2,32(sp)
    800026fe:	69e2                	ld	s3,24(sp)
    80002700:	6a42                	ld	s4,16(sp)
    80002702:	6aa2                	ld	s5,8(sp)
    80002704:	6121                	addi	sp,sp,64
    80002706:	8082                	ret

0000000080002708 <kill>:
{
    80002708:	7179                	addi	sp,sp,-48
    8000270a:	f406                	sd	ra,40(sp)
    8000270c:	f022                	sd	s0,32(sp)
    8000270e:	ec26                	sd	s1,24(sp)
    80002710:	e84a                	sd	s2,16(sp)
    80002712:	e44e                	sd	s3,8(sp)
    80002714:	1800                	addi	s0,sp,48
    80002716:	892a                	mv	s2,a0
  for(p = proc; p < &proc[NPROC]; p++){
    80002718:	00023497          	auipc	s1,0x23
    8000271c:	7f048493          	addi	s1,s1,2032 # 80025f08 <proc>
    80002720:	0002a997          	auipc	s3,0x2a
    80002724:	5e898993          	addi	s3,s3,1512 # 8002cd08 <tickslock>
    acquire(&p->lock);
    80002728:	8526                	mv	a0,s1
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	468080e7          	jalr	1128(ra) # 80000b92 <acquire>
    if(p->pid == pid){
    80002732:	40bc                	lw	a5,64(s1)
    80002734:	01278d63          	beq	a5,s2,8000274e <kill+0x46>
    release(&p->lock);
    80002738:	8526                	mv	a0,s1
    8000273a:	ffffe097          	auipc	ra,0xffffe
    8000273e:	528080e7          	jalr	1320(ra) # 80000c62 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002742:	1b848493          	addi	s1,s1,440
    80002746:	ff3491e3          	bne	s1,s3,80002728 <kill+0x20>
  return -1;
    8000274a:	557d                	li	a0,-1
    8000274c:	a821                	j	80002764 <kill+0x5c>
      p->killed = 1;
    8000274e:	4785                	li	a5,1
    80002750:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    80002752:	5098                	lw	a4,32(s1)
    80002754:	00f70f63          	beq	a4,a5,80002772 <kill+0x6a>
      release(&p->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	508080e7          	jalr	1288(ra) # 80000c62 <release>
      return 0;
    80002762:	4501                	li	a0,0
}
    80002764:	70a2                	ld	ra,40(sp)
    80002766:	7402                	ld	s0,32(sp)
    80002768:	64e2                	ld	s1,24(sp)
    8000276a:	6942                	ld	s2,16(sp)
    8000276c:	69a2                	ld	s3,8(sp)
    8000276e:	6145                	addi	sp,sp,48
    80002770:	8082                	ret
        p->state = RUNNABLE;
    80002772:	4789                	li	a5,2
    80002774:	d09c                	sw	a5,32(s1)
    80002776:	b7cd                	j	80002758 <kill+0x50>

0000000080002778 <either_copyout>:
{
    80002778:	7179                	addi	sp,sp,-48
    8000277a:	f406                	sd	ra,40(sp)
    8000277c:	f022                	sd	s0,32(sp)
    8000277e:	ec26                	sd	s1,24(sp)
    80002780:	e84a                	sd	s2,16(sp)
    80002782:	e44e                	sd	s3,8(sp)
    80002784:	e052                	sd	s4,0(sp)
    80002786:	1800                	addi	s0,sp,48
    80002788:	84aa                	mv	s1,a0
    8000278a:	892e                	mv	s2,a1
    8000278c:	89b2                	mv	s3,a2
    8000278e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002790:	fffff097          	auipc	ra,0xfffff
    80002794:	3c0080e7          	jalr	960(ra) # 80001b50 <myproc>
  if(user_dst){
    80002798:	c08d                	beqz	s1,800027ba <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000279a:	86d2                	mv	a3,s4
    8000279c:	864e                	mv	a2,s3
    8000279e:	85ca                	mv	a1,s2
    800027a0:	6d28                	ld	a0,88(a0)
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	05e080e7          	jalr	94(ra) # 80001800 <copyout>
}
    800027aa:	70a2                	ld	ra,40(sp)
    800027ac:	7402                	ld	s0,32(sp)
    800027ae:	64e2                	ld	s1,24(sp)
    800027b0:	6942                	ld	s2,16(sp)
    800027b2:	69a2                	ld	s3,8(sp)
    800027b4:	6a02                	ld	s4,0(sp)
    800027b6:	6145                	addi	sp,sp,48
    800027b8:	8082                	ret
    memmove((char *)dst, src, len);
    800027ba:	000a061b          	sext.w	a2,s4
    800027be:	85ce                	mv	a1,s3
    800027c0:	854a                	mv	a0,s2
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	710080e7          	jalr	1808(ra) # 80000ed2 <memmove>
    return 0;
    800027ca:	8526                	mv	a0,s1
    800027cc:	bff9                	j	800027aa <either_copyout+0x32>

00000000800027ce <either_copyin>:
{
    800027ce:	7179                	addi	sp,sp,-48
    800027d0:	f406                	sd	ra,40(sp)
    800027d2:	f022                	sd	s0,32(sp)
    800027d4:	ec26                	sd	s1,24(sp)
    800027d6:	e84a                	sd	s2,16(sp)
    800027d8:	e44e                	sd	s3,8(sp)
    800027da:	e052                	sd	s4,0(sp)
    800027dc:	1800                	addi	s0,sp,48
    800027de:	892a                	mv	s2,a0
    800027e0:	84ae                	mv	s1,a1
    800027e2:	89b2                	mv	s3,a2
    800027e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	36a080e7          	jalr	874(ra) # 80001b50 <myproc>
  if(user_src){
    800027ee:	c08d                	beqz	s1,80002810 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027f0:	86d2                	mv	a3,s4
    800027f2:	864e                	mv	a2,s3
    800027f4:	85ca                	mv	a1,s2
    800027f6:	6d28                	ld	a0,88(a0)
    800027f8:	fffff097          	auipc	ra,0xfffff
    800027fc:	094080e7          	jalr	148(ra) # 8000188c <copyin>
}
    80002800:	70a2                	ld	ra,40(sp)
    80002802:	7402                	ld	s0,32(sp)
    80002804:	64e2                	ld	s1,24(sp)
    80002806:	6942                	ld	s2,16(sp)
    80002808:	69a2                	ld	s3,8(sp)
    8000280a:	6a02                	ld	s4,0(sp)
    8000280c:	6145                	addi	sp,sp,48
    8000280e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002810:	000a061b          	sext.w	a2,s4
    80002814:	85ce                	mv	a1,s3
    80002816:	854a                	mv	a0,s2
    80002818:	ffffe097          	auipc	ra,0xffffe
    8000281c:	6ba080e7          	jalr	1722(ra) # 80000ed2 <memmove>
    return 0;
    80002820:	8526                	mv	a0,s1
    80002822:	bff9                	j	80002800 <either_copyin+0x32>

0000000080002824 <procdump>:
{
    80002824:	715d                	addi	sp,sp,-80
    80002826:	e486                	sd	ra,72(sp)
    80002828:	e0a2                	sd	s0,64(sp)
    8000282a:	fc26                	sd	s1,56(sp)
    8000282c:	f84a                	sd	s2,48(sp)
    8000282e:	f44e                	sd	s3,40(sp)
    80002830:	f052                	sd	s4,32(sp)
    80002832:	ec56                	sd	s5,24(sp)
    80002834:	e85a                	sd	s6,16(sp)
    80002836:	e45e                	sd	s7,8(sp)
    80002838:	0880                	addi	s0,sp,80
  printf("\n");
    8000283a:	00007517          	auipc	a0,0x7
    8000283e:	9c650513          	addi	a0,a0,-1594 # 80009200 <digits+0x90>
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	d84080e7          	jalr	-636(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000284a:	00024497          	auipc	s1,0x24
    8000284e:	81e48493          	addi	s1,s1,-2018 # 80026068 <proc+0x160>
    80002852:	0002a917          	auipc	s2,0x2a
    80002856:	61690913          	addi	s2,s2,1558 # 8002ce68 <bcache+0x140>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000285a:	4b11                	li	s6,4
      state = "???";
    8000285c:	00007997          	auipc	s3,0x7
    80002860:	cbc98993          	addi	s3,s3,-836 # 80009518 <digits+0x3a8>
    printf("%d %s %s", p->pid, state, p->name);
    80002864:	00007a97          	auipc	s5,0x7
    80002868:	cbca8a93          	addi	s5,s5,-836 # 80009520 <digits+0x3b0>
    printf("\n");
    8000286c:	00007a17          	auipc	s4,0x7
    80002870:	994a0a13          	addi	s4,s4,-1644 # 80009200 <digits+0x90>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002874:	00007b97          	auipc	s7,0x7
    80002878:	ce4b8b93          	addi	s7,s7,-796 # 80009558 <states.0>
    8000287c:	a00d                	j	8000289e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000287e:	ee06a583          	lw	a1,-288(a3)
    80002882:	8556                	mv	a0,s5
    80002884:	ffffe097          	auipc	ra,0xffffe
    80002888:	d42080e7          	jalr	-702(ra) # 800005c6 <printf>
    printf("\n");
    8000288c:	8552                	mv	a0,s4
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	d38080e7          	jalr	-712(ra) # 800005c6 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002896:	1b848493          	addi	s1,s1,440
    8000289a:	03248163          	beq	s1,s2,800028bc <procdump+0x98>
    if(p->state == UNUSED)
    8000289e:	86a6                	mv	a3,s1
    800028a0:	ec04a783          	lw	a5,-320(s1)
    800028a4:	dbed                	beqz	a5,80002896 <procdump+0x72>
      state = "???";
    800028a6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a8:	fcfb6be3          	bltu	s6,a5,8000287e <procdump+0x5a>
    800028ac:	1782                	slli	a5,a5,0x20
    800028ae:	9381                	srli	a5,a5,0x20
    800028b0:	078e                	slli	a5,a5,0x3
    800028b2:	97de                	add	a5,a5,s7
    800028b4:	6390                	ld	a2,0(a5)
    800028b6:	f661                	bnez	a2,8000287e <procdump+0x5a>
      state = "???";
    800028b8:	864e                	mv	a2,s3
    800028ba:	b7d1                	j	8000287e <procdump+0x5a>
}
    800028bc:	60a6                	ld	ra,72(sp)
    800028be:	6406                	ld	s0,64(sp)
    800028c0:	74e2                	ld	s1,56(sp)
    800028c2:	7942                	ld	s2,48(sp)
    800028c4:	79a2                	ld	s3,40(sp)
    800028c6:	7a02                	ld	s4,32(sp)
    800028c8:	6ae2                	ld	s5,24(sp)
    800028ca:	6b42                	ld	s6,16(sp)
    800028cc:	6ba2                	ld	s7,8(sp)
    800028ce:	6161                	addi	sp,sp,80
    800028d0:	8082                	ret

00000000800028d2 <getTime>:
unsigned long getTime() { 
    800028d2:	1141                	addi	sp,sp,-16
    800028d4:	e422                	sd	s0,8(sp)
    800028d6:	0800                	addi	s0,sp,16
  asm volatile ("rdtime %0" : "=r" (time)); 
    800028d8:	c0102573          	rdtime	a0
  return time; 
}
    800028dc:	6422                	ld	s0,8(sp)
    800028de:	0141                	addi	sp,sp,16
    800028e0:	8082                	ret

00000000800028e2 <getCycles>:

unsigned long getCycles() { 
    800028e2:	1141                	addi	sp,sp,-16
    800028e4:	e422                	sd	s0,8(sp)
    800028e6:	0800                	addi	s0,sp,16
  unsigned long cycles; 
  asm volatile ("rdcycle %0" : "=r" (cycles)); 
    800028e8:	c0002573          	rdcycle	a0
  return cycles; 
    800028ec:	6422                	ld	s0,8(sp)
    800028ee:	0141                	addi	sp,sp,16
    800028f0:	8082                	ret

00000000800028f2 <swtch>:
    800028f2:	00153023          	sd	ra,0(a0)
    800028f6:	00253423          	sd	sp,8(a0)
    800028fa:	e900                	sd	s0,16(a0)
    800028fc:	ed04                	sd	s1,24(a0)
    800028fe:	03253023          	sd	s2,32(a0)
    80002902:	03353423          	sd	s3,40(a0)
    80002906:	03453823          	sd	s4,48(a0)
    8000290a:	03553c23          	sd	s5,56(a0)
    8000290e:	05653023          	sd	s6,64(a0)
    80002912:	05753423          	sd	s7,72(a0)
    80002916:	05853823          	sd	s8,80(a0)
    8000291a:	05953c23          	sd	s9,88(a0)
    8000291e:	07a53023          	sd	s10,96(a0)
    80002922:	07b53423          	sd	s11,104(a0)
    80002926:	0005b083          	ld	ra,0(a1)
    8000292a:	0085b103          	ld	sp,8(a1)
    8000292e:	6980                	ld	s0,16(a1)
    80002930:	6d84                	ld	s1,24(a1)
    80002932:	0205b903          	ld	s2,32(a1)
    80002936:	0285b983          	ld	s3,40(a1)
    8000293a:	0305ba03          	ld	s4,48(a1)
    8000293e:	0385ba83          	ld	s5,56(a1)
    80002942:	0405bb03          	ld	s6,64(a1)
    80002946:	0485bb83          	ld	s7,72(a1)
    8000294a:	0505bc03          	ld	s8,80(a1)
    8000294e:	0585bc83          	ld	s9,88(a1)
    80002952:	0605bd03          	ld	s10,96(a1)
    80002956:	0685bd83          	ld	s11,104(a1)
    8000295a:	8082                	ret

000000008000295c <scause_desc>:
  }
}

static const char *
scause_desc(uint64 stval)
{
    8000295c:	1141                	addi	sp,sp,-16
    8000295e:	e422                	sd	s0,8(sp)
    80002960:	0800                	addi	s0,sp,16
    80002962:	87aa                	mv	a5,a0
    [13] "load page fault",
    [14] "<reserved for future standard use>",
    [15] "store/AMO page fault",
  };
  uint64 interrupt = stval & 0x8000000000000000L;
  uint64 code = stval & ~0x8000000000000000L;
    80002964:	00151713          	slli	a4,a0,0x1
    80002968:	8305                	srli	a4,a4,0x1
  if (interrupt) {
    8000296a:	04054c63          	bltz	a0,800029c2 <scause_desc+0x66>
      return intr_desc[code];
    } else {
      return "<reserved for platform use>";
    }
  } else {
    if (code < NELEM(nointr_desc)) {
    8000296e:	5685                	li	a3,-31
    80002970:	8285                	srli	a3,a3,0x1
    80002972:	8ee9                	and	a3,a3,a0
    80002974:	caad                	beqz	a3,800029e6 <scause_desc+0x8a>
      return nointr_desc[code];
    } else if (code <= 23) {
    80002976:	46dd                	li	a3,23
      return "<reserved for future standard use>";
    80002978:	00007517          	auipc	a0,0x7
    8000297c:	c0850513          	addi	a0,a0,-1016 # 80009580 <states.0+0x28>
    } else if (code <= 23) {
    80002980:	06e6f063          	bgeu	a3,a4,800029e0 <scause_desc+0x84>
    } else if (code <= 31) {
    80002984:	fc100693          	li	a3,-63
    80002988:	8285                	srli	a3,a3,0x1
    8000298a:	8efd                	and	a3,a3,a5
      return "<reserved for custom use>";
    8000298c:	00007517          	auipc	a0,0x7
    80002990:	c1c50513          	addi	a0,a0,-996 # 800095a8 <states.0+0x50>
    } else if (code <= 31) {
    80002994:	c6b1                	beqz	a3,800029e0 <scause_desc+0x84>
    } else if (code <= 47) {
    80002996:	02f00693          	li	a3,47
      return "<reserved for future standard use>";
    8000299a:	00007517          	auipc	a0,0x7
    8000299e:	be650513          	addi	a0,a0,-1050 # 80009580 <states.0+0x28>
    } else if (code <= 47) {
    800029a2:	02e6ff63          	bgeu	a3,a4,800029e0 <scause_desc+0x84>
    } else if (code <= 63) {
    800029a6:	f8100513          	li	a0,-127
    800029aa:	8105                	srli	a0,a0,0x1
    800029ac:	8fe9                	and	a5,a5,a0
      return "<reserved for custom use>";
    800029ae:	00007517          	auipc	a0,0x7
    800029b2:	bfa50513          	addi	a0,a0,-1030 # 800095a8 <states.0+0x50>
    } else if (code <= 63) {
    800029b6:	c78d                	beqz	a5,800029e0 <scause_desc+0x84>
    } else {
      return "<reserved for future standard use>";
    800029b8:	00007517          	auipc	a0,0x7
    800029bc:	bc850513          	addi	a0,a0,-1080 # 80009580 <states.0+0x28>
    800029c0:	a005                	j	800029e0 <scause_desc+0x84>
    if (code < NELEM(intr_desc)) {
    800029c2:	5505                	li	a0,-31
    800029c4:	8105                	srli	a0,a0,0x1
    800029c6:	8fe9                	and	a5,a5,a0
      return "<reserved for platform use>";
    800029c8:	00007517          	auipc	a0,0x7
    800029cc:	c0050513          	addi	a0,a0,-1024 # 800095c8 <states.0+0x70>
    if (code < NELEM(intr_desc)) {
    800029d0:	eb81                	bnez	a5,800029e0 <scause_desc+0x84>
      return intr_desc[code];
    800029d2:	070e                	slli	a4,a4,0x3
    800029d4:	00007797          	auipc	a5,0x7
    800029d8:	f0478793          	addi	a5,a5,-252 # 800098d8 <intr_desc.1>
    800029dc:	973e                	add	a4,a4,a5
    800029de:	6308                	ld	a0,0(a4)
    }
  }
}
    800029e0:	6422                	ld	s0,8(sp)
    800029e2:	0141                	addi	sp,sp,16
    800029e4:	8082                	ret
      return nointr_desc[code];
    800029e6:	070e                	slli	a4,a4,0x3
    800029e8:	00007797          	auipc	a5,0x7
    800029ec:	ef078793          	addi	a5,a5,-272 # 800098d8 <intr_desc.1>
    800029f0:	973e                	add	a4,a4,a5
    800029f2:	6348                	ld	a0,128(a4)
    800029f4:	b7f5                	j	800029e0 <scause_desc+0x84>

00000000800029f6 <trapinit>:
{
    800029f6:	1141                	addi	sp,sp,-16
    800029f8:	e406                	sd	ra,8(sp)
    800029fa:	e022                	sd	s0,0(sp)
    800029fc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029fe:	00007597          	auipc	a1,0x7
    80002a02:	bea58593          	addi	a1,a1,-1046 # 800095e8 <states.0+0x90>
    80002a06:	0002a517          	auipc	a0,0x2a
    80002a0a:	30250513          	addi	a0,a0,770 # 8002cd08 <tickslock>
    80002a0e:	ffffe097          	auipc	ra,0xffffe
    80002a12:	0ae080e7          	jalr	174(ra) # 80000abc <initlock>
}
    80002a16:	60a2                	ld	ra,8(sp)
    80002a18:	6402                	ld	s0,0(sp)
    80002a1a:	0141                	addi	sp,sp,16
    80002a1c:	8082                	ret

0000000080002a1e <trapinithart>:
{
    80002a1e:	1141                	addi	sp,sp,-16
    80002a20:	e422                	sd	s0,8(sp)
    80002a22:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a24:	00003797          	auipc	a5,0x3
    80002a28:	49c78793          	addi	a5,a5,1180 # 80005ec0 <kernelvec>
    80002a2c:	10579073          	csrw	stvec,a5
}
    80002a30:	6422                	ld	s0,8(sp)
    80002a32:	0141                	addi	sp,sp,16
    80002a34:	8082                	ret

0000000080002a36 <usertrapret>:
{
    80002a36:	1141                	addi	sp,sp,-16
    80002a38:	e406                	sd	ra,8(sp)
    80002a3a:	e022                	sd	s0,0(sp)
    80002a3c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a3e:	fffff097          	auipc	ra,0xfffff
    80002a42:	112080e7          	jalr	274(ra) # 80001b50 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a4a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4c:	10079073          	csrw	sstatus,a5
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002a50:	00005617          	auipc	a2,0x5
    80002a54:	5b060613          	addi	a2,a2,1456 # 80008000 <_trampoline>
    80002a58:	00005697          	auipc	a3,0x5
    80002a5c:	5a868693          	addi	a3,a3,1448 # 80008000 <_trampoline>
    80002a60:	8e91                	sub	a3,a3,a2
    80002a62:	040007b7          	lui	a5,0x4000
    80002a66:	17fd                	addi	a5,a5,-1
    80002a68:	07b2                	slli	a5,a5,0xc
    80002a6a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a6c:	10569073          	csrw	stvec,a3
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a70:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a72:	180026f3          	csrr	a3,satp
    80002a76:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a78:	7138                	ld	a4,96(a0)
    80002a7a:	6534                	ld	a3,72(a0)
    80002a7c:	6585                	lui	a1,0x1
    80002a7e:	96ae                	add	a3,a3,a1
    80002a80:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a82:	7138                	ld	a4,96(a0)
    80002a84:	00000697          	auipc	a3,0x0
    80002a88:	12268693          	addi	a3,a3,290 # 80002ba6 <usertrap>
    80002a8c:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a8e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a90:	8692                	mv	a3,tp
    80002a92:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a94:	100026f3          	csrr	a3,sstatus
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a98:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a9c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aa0:	10069073          	csrw	sstatus,a3
  w_sepc(p->trapframe->epc);
    80002aa4:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002aa6:	6f18                	ld	a4,24(a4)
    80002aa8:	14171073          	csrw	sepc,a4
  uint64 satp = MAKE_SATP(p->pagetable);
    80002aac:	6d2c                	ld	a1,88(a0)
    80002aae:	81b1                	srli	a1,a1,0xc
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002ab0:	00005717          	auipc	a4,0x5
    80002ab4:	5e070713          	addi	a4,a4,1504 # 80008090 <userret>
    80002ab8:	8f11                	sub	a4,a4,a2
    80002aba:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(p->trap_va, satp);
    80002abc:	577d                	li	a4,-1
    80002abe:	177e                	slli	a4,a4,0x3f
    80002ac0:	8dd9                	or	a1,a1,a4
    80002ac2:	17053503          	ld	a0,368(a0)
    80002ac6:	9782                	jalr	a5
}
    80002ac8:	60a2                	ld	ra,8(sp)
    80002aca:	6402                	ld	s0,0(sp)
    80002acc:	0141                	addi	sp,sp,16
    80002ace:	8082                	ret

0000000080002ad0 <clockintr>:
{
    80002ad0:	1101                	addi	sp,sp,-32
    80002ad2:	ec06                	sd	ra,24(sp)
    80002ad4:	e822                	sd	s0,16(sp)
    80002ad6:	e426                	sd	s1,8(sp)
    80002ad8:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ada:	0002a497          	auipc	s1,0x2a
    80002ade:	22e48493          	addi	s1,s1,558 # 8002cd08 <tickslock>
    80002ae2:	8526                	mv	a0,s1
    80002ae4:	ffffe097          	auipc	ra,0xffffe
    80002ae8:	0ae080e7          	jalr	174(ra) # 80000b92 <acquire>
  ticks++;
    80002aec:	00007517          	auipc	a0,0x7
    80002af0:	51450513          	addi	a0,a0,1300 # 8000a000 <ticks>
    80002af4:	411c                	lw	a5,0(a0)
    80002af6:	2785                	addiw	a5,a5,1
    80002af8:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	b9c080e7          	jalr	-1124(ra) # 80002696 <wakeup>
  release(&tickslock);
    80002b02:	8526                	mv	a0,s1
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	15e080e7          	jalr	350(ra) # 80000c62 <release>
}
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6105                	addi	sp,sp,32
    80002b14:	8082                	ret

0000000080002b16 <devintr>:
{
    80002b16:	1101                	addi	sp,sp,-32
    80002b18:	ec06                	sd	ra,24(sp)
    80002b1a:	e822                	sd	s0,16(sp)
    80002b1c:	e426                	sd	s1,8(sp)
    80002b1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b20:	14202773          	csrr	a4,scause
  if((scause & 0x8000000000000000L) &&
    80002b24:	00074d63          	bltz	a4,80002b3e <devintr+0x28>
  } else if(scause == 0x8000000000000001L){
    80002b28:	57fd                	li	a5,-1
    80002b2a:	17fe                	slli	a5,a5,0x3f
    80002b2c:	0785                	addi	a5,a5,1
    return 0;
    80002b2e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b30:	04f70a63          	beq	a4,a5,80002b84 <devintr+0x6e>
}
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	64a2                	ld	s1,8(sp)
    80002b3a:	6105                	addi	sp,sp,32
    80002b3c:	8082                	ret
     (scause & 0xff) == 9){
    80002b3e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b42:	46a5                	li	a3,9
    80002b44:	fed792e3          	bne	a5,a3,80002b28 <devintr+0x12>
    int irq = plic_claim();
    80002b48:	00003097          	auipc	ra,0x3
    80002b4c:	480080e7          	jalr	1152(ra) # 80005fc8 <plic_claim>
    80002b50:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b52:	47a9                	li	a5,10
    80002b54:	00f50863          	beq	a0,a5,80002b64 <devintr+0x4e>
    } else if(irq == VIRTIO0_IRQ){
    80002b58:	4785                	li	a5,1
    80002b5a:	02f50063          	beq	a0,a5,80002b7a <devintr+0x64>
    return 1;
    80002b5e:	4505                	li	a0,1
    if(irq)
    80002b60:	d8f1                	beqz	s1,80002b34 <devintr+0x1e>
    80002b62:	a029                	j	80002b6c <devintr+0x56>
      uartintr();
    80002b64:	ffffe097          	auipc	ra,0xffffe
    80002b68:	dac080e7          	jalr	-596(ra) # 80000910 <uartintr>
      plic_complete(irq);
    80002b6c:	8526                	mv	a0,s1
    80002b6e:	00003097          	auipc	ra,0x3
    80002b72:	47e080e7          	jalr	1150(ra) # 80005fec <plic_complete>
    return 1;
    80002b76:	4505                	li	a0,1
    80002b78:	bf75                	j	80002b34 <devintr+0x1e>
      virtio_disk_intr();
    80002b7a:	00004097          	auipc	ra,0x4
    80002b7e:	92a080e7          	jalr	-1750(ra) # 800064a4 <virtio_disk_intr>
    80002b82:	b7ed                	j	80002b6c <devintr+0x56>
    if(cpuid() == 0){
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	fa0080e7          	jalr	-96(ra) # 80001b24 <cpuid>
    80002b8c:	c901                	beqz	a0,80002b9c <devintr+0x86>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b8e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b92:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b94:	14479073          	csrw	sip,a5
    return 2;
    80002b98:	4509                	li	a0,2
    80002b9a:	bf69                	j	80002b34 <devintr+0x1e>
      clockintr();
    80002b9c:	00000097          	auipc	ra,0x0
    80002ba0:	f34080e7          	jalr	-204(ra) # 80002ad0 <clockintr>
    80002ba4:	b7ed                	j	80002b8e <devintr+0x78>

0000000080002ba6 <usertrap>:
{
    80002ba6:	7179                	addi	sp,sp,-48
    80002ba8:	f406                	sd	ra,40(sp)
    80002baa:	f022                	sd	s0,32(sp)
    80002bac:	ec26                	sd	s1,24(sp)
    80002bae:	e84a                	sd	s2,16(sp)
    80002bb0:	e44e                	sd	s3,8(sp)
    80002bb2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb4:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bb8:	1007f793          	andi	a5,a5,256
    80002bbc:	e3b5                	bnez	a5,80002c20 <usertrap+0x7a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bbe:	00003797          	auipc	a5,0x3
    80002bc2:	30278793          	addi	a5,a5,770 # 80005ec0 <kernelvec>
    80002bc6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bca:	fffff097          	auipc	ra,0xfffff
    80002bce:	f86080e7          	jalr	-122(ra) # 80001b50 <myproc>
    80002bd2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bd4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bd6:	14102773          	csrr	a4,sepc
    80002bda:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bdc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002be0:	47a1                	li	a5,8
    80002be2:	04f71d63          	bne	a4,a5,80002c3c <usertrap+0x96>
    if(p->killed)
    80002be6:	5d1c                	lw	a5,56(a0)
    80002be8:	e7a1                	bnez	a5,80002c30 <usertrap+0x8a>
    p->trapframe->epc += 4;
    80002bea:	70b8                	ld	a4,96(s1)
    80002bec:	6f1c                	ld	a5,24(a4)
    80002bee:	0791                	addi	a5,a5,4
    80002bf0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bf6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bfa:	10079073          	csrw	sstatus,a5
    syscall();
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	2fe080e7          	jalr	766(ra) # 80002efc <syscall>
  if(p->killed)
    80002c06:	5c9c                	lw	a5,56(s1)
    80002c08:	e3cd                	bnez	a5,80002caa <usertrap+0x104>
  usertrapret();
    80002c0a:	00000097          	auipc	ra,0x0
    80002c0e:	e2c080e7          	jalr	-468(ra) # 80002a36 <usertrapret>
}
    80002c12:	70a2                	ld	ra,40(sp)
    80002c14:	7402                	ld	s0,32(sp)
    80002c16:	64e2                	ld	s1,24(sp)
    80002c18:	6942                	ld	s2,16(sp)
    80002c1a:	69a2                	ld	s3,8(sp)
    80002c1c:	6145                	addi	sp,sp,48
    80002c1e:	8082                	ret
    panic("usertrap: not from user mode");
    80002c20:	00007517          	auipc	a0,0x7
    80002c24:	9d050513          	addi	a0,a0,-1584 # 800095f0 <states.0+0x98>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	93c080e7          	jalr	-1732(ra) # 80000564 <panic>
      exit(-1);
    80002c30:	557d                	li	a0,-1
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	638080e7          	jalr	1592(ra) # 8000226a <exit>
    80002c3a:	bf45                	j	80002bea <usertrap+0x44>
  } else if((which_dev = devintr()) != 0){
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	eda080e7          	jalr	-294(ra) # 80002b16 <devintr>
    80002c44:	892a                	mv	s2,a0
    80002c46:	c501                	beqz	a0,80002c4e <usertrap+0xa8>
  if(p->killed)
    80002c48:	5c9c                	lw	a5,56(s1)
    80002c4a:	cba1                	beqz	a5,80002c9a <usertrap+0xf4>
    80002c4c:	a091                	j	80002c90 <usertrap+0xea>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c4e:	142029f3          	csrr	s3,scause
    80002c52:	14202573          	csrr	a0,scause
    printf("usertrap(): unexpected scause %p (%s) pid=%d\n", r_scause(), scause_desc(r_scause()), p->pid);
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	d06080e7          	jalr	-762(ra) # 8000295c <scause_desc>
    80002c5e:	862a                	mv	a2,a0
    80002c60:	40b4                	lw	a3,64(s1)
    80002c62:	85ce                	mv	a1,s3
    80002c64:	00007517          	auipc	a0,0x7
    80002c68:	9ac50513          	addi	a0,a0,-1620 # 80009610 <states.0+0xb8>
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	95a080e7          	jalr	-1702(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c74:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c78:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c7c:	00007517          	auipc	a0,0x7
    80002c80:	9c450513          	addi	a0,a0,-1596 # 80009640 <states.0+0xe8>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	942080e7          	jalr	-1726(ra) # 800005c6 <printf>
    p->killed = 1;
    80002c8c:	4785                	li	a5,1
    80002c8e:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002c90:	557d                	li	a0,-1
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	5d8080e7          	jalr	1496(ra) # 8000226a <exit>
  if(which_dev == 2)
    80002c9a:	4789                	li	a5,2
    80002c9c:	f6f917e3          	bne	s2,a5,80002c0a <usertrap+0x64>
    yield();
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	7da080e7          	jalr	2010(ra) # 8000247a <yield>
    80002ca8:	b78d                	j	80002c0a <usertrap+0x64>
  int which_dev = 0;
    80002caa:	4901                	li	s2,0
    80002cac:	b7d5                	j	80002c90 <usertrap+0xea>

0000000080002cae <kerneltrap>:
{
    80002cae:	7179                	addi	sp,sp,-48
    80002cb0:	f406                	sd	ra,40(sp)
    80002cb2:	f022                	sd	s0,32(sp)
    80002cb4:	ec26                	sd	s1,24(sp)
    80002cb6:	e84a                	sd	s2,16(sp)
    80002cb8:	e44e                	sd	s3,8(sp)
    80002cba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cbc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cc4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cc8:	1004f793          	andi	a5,s1,256
    80002ccc:	cb85                	beqz	a5,80002cfc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cd2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cd4:	ef85                	bnez	a5,80002d0c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cd6:	00000097          	auipc	ra,0x0
    80002cda:	e40080e7          	jalr	-448(ra) # 80002b16 <devintr>
    80002cde:	cd1d                	beqz	a0,80002d1c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ce0:	4789                	li	a5,2
    80002ce2:	08f50063          	beq	a0,a5,80002d62 <kerneltrap+0xb4>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ce6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cea:	10049073          	csrw	sstatus,s1
}
    80002cee:	70a2                	ld	ra,40(sp)
    80002cf0:	7402                	ld	s0,32(sp)
    80002cf2:	64e2                	ld	s1,24(sp)
    80002cf4:	6942                	ld	s2,16(sp)
    80002cf6:	69a2                	ld	s3,8(sp)
    80002cf8:	6145                	addi	sp,sp,48
    80002cfa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cfc:	00007517          	auipc	a0,0x7
    80002d00:	96450513          	addi	a0,a0,-1692 # 80009660 <states.0+0x108>
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	860080e7          	jalr	-1952(ra) # 80000564 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d0c:	00007517          	auipc	a0,0x7
    80002d10:	97c50513          	addi	a0,a0,-1668 # 80009688 <states.0+0x130>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	850080e7          	jalr	-1968(ra) # 80000564 <panic>
    printf("scause %p (%s)\n", scause, scause_desc(scause));
    80002d1c:	854e                	mv	a0,s3
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	c3e080e7          	jalr	-962(ra) # 8000295c <scause_desc>
    80002d26:	862a                	mv	a2,a0
    80002d28:	85ce                	mv	a1,s3
    80002d2a:	00007517          	auipc	a0,0x7
    80002d2e:	97e50513          	addi	a0,a0,-1666 # 800096a8 <states.0+0x150>
    80002d32:	ffffe097          	auipc	ra,0xffffe
    80002d36:	894080e7          	jalr	-1900(ra) # 800005c6 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d3a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d3e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d42:	00007517          	auipc	a0,0x7
    80002d46:	97650513          	addi	a0,a0,-1674 # 800096b8 <states.0+0x160>
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	87c080e7          	jalr	-1924(ra) # 800005c6 <printf>
    panic("kerneltrap");
    80002d52:	00007517          	auipc	a0,0x7
    80002d56:	97e50513          	addi	a0,a0,-1666 # 800096d0 <states.0+0x178>
    80002d5a:	ffffe097          	auipc	ra,0xffffe
    80002d5e:	80a080e7          	jalr	-2038(ra) # 80000564 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	dee080e7          	jalr	-530(ra) # 80001b50 <myproc>
    80002d6a:	dd35                	beqz	a0,80002ce6 <kerneltrap+0x38>
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	de4080e7          	jalr	-540(ra) # 80001b50 <myproc>
    80002d74:	5118                	lw	a4,32(a0)
    80002d76:	478d                	li	a5,3
    80002d78:	f6f717e3          	bne	a4,a5,80002ce6 <kerneltrap+0x38>
    yield();
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	6fe080e7          	jalr	1790(ra) # 8000247a <yield>
    80002d84:	b78d                	j	80002ce6 <kerneltrap+0x38>

0000000080002d86 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d86:	1101                	addi	sp,sp,-32
    80002d88:	ec06                	sd	ra,24(sp)
    80002d8a:	e822                	sd	s0,16(sp)
    80002d8c:	e426                	sd	s1,8(sp)
    80002d8e:	1000                	addi	s0,sp,32
    80002d90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	dbe080e7          	jalr	-578(ra) # 80001b50 <myproc>
  switch (n) {
    80002d9a:	4795                	li	a5,5
    80002d9c:	0497e163          	bltu	a5,s1,80002dde <argraw+0x58>
    80002da0:	048a                	slli	s1,s1,0x2
    80002da2:	00007717          	auipc	a4,0x7
    80002da6:	c5e70713          	addi	a4,a4,-930 # 80009a00 <nointr_desc.0+0xa8>
    80002daa:	94ba                	add	s1,s1,a4
    80002dac:	409c                	lw	a5,0(s1)
    80002dae:	97ba                	add	a5,a5,a4
    80002db0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002db2:	713c                	ld	a5,96(a0)
    80002db4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	64a2                	ld	s1,8(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret
    return p->trapframe->a1;
    80002dc0:	713c                	ld	a5,96(a0)
    80002dc2:	7fa8                	ld	a0,120(a5)
    80002dc4:	bfcd                	j	80002db6 <argraw+0x30>
    return p->trapframe->a2;
    80002dc6:	713c                	ld	a5,96(a0)
    80002dc8:	63c8                	ld	a0,128(a5)
    80002dca:	b7f5                	j	80002db6 <argraw+0x30>
    return p->trapframe->a3;
    80002dcc:	713c                	ld	a5,96(a0)
    80002dce:	67c8                	ld	a0,136(a5)
    80002dd0:	b7dd                	j	80002db6 <argraw+0x30>
    return p->trapframe->a4;
    80002dd2:	713c                	ld	a5,96(a0)
    80002dd4:	6bc8                	ld	a0,144(a5)
    80002dd6:	b7c5                	j	80002db6 <argraw+0x30>
    return p->trapframe->a5;
    80002dd8:	713c                	ld	a5,96(a0)
    80002dda:	6fc8                	ld	a0,152(a5)
    80002ddc:	bfe9                	j	80002db6 <argraw+0x30>
  panic("argraw");
    80002dde:	00007517          	auipc	a0,0x7
    80002de2:	bfa50513          	addi	a0,a0,-1030 # 800099d8 <nointr_desc.0+0x80>
    80002de6:	ffffd097          	auipc	ra,0xffffd
    80002dea:	77e080e7          	jalr	1918(ra) # 80000564 <panic>

0000000080002dee <fetchaddr>:
{
    80002dee:	1101                	addi	sp,sp,-32
    80002df0:	ec06                	sd	ra,24(sp)
    80002df2:	e822                	sd	s0,16(sp)
    80002df4:	e426                	sd	s1,8(sp)
    80002df6:	e04a                	sd	s2,0(sp)
    80002df8:	1000                	addi	s0,sp,32
    80002dfa:	84aa                	mv	s1,a0
    80002dfc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	d52080e7          	jalr	-686(ra) # 80001b50 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002e06:	693c                	ld	a5,80(a0)
    80002e08:	02f4f863          	bgeu	s1,a5,80002e38 <fetchaddr+0x4a>
    80002e0c:	00848713          	addi	a4,s1,8
    80002e10:	02e7e663          	bltu	a5,a4,80002e3c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e14:	46a1                	li	a3,8
    80002e16:	8626                	mv	a2,s1
    80002e18:	85ca                	mv	a1,s2
    80002e1a:	6d28                	ld	a0,88(a0)
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	a70080e7          	jalr	-1424(ra) # 8000188c <copyin>
    80002e24:	00a03533          	snez	a0,a0
    80002e28:	40a00533          	neg	a0,a0
}
    80002e2c:	60e2                	ld	ra,24(sp)
    80002e2e:	6442                	ld	s0,16(sp)
    80002e30:	64a2                	ld	s1,8(sp)
    80002e32:	6902                	ld	s2,0(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret
    return -1;
    80002e38:	557d                	li	a0,-1
    80002e3a:	bfcd                	j	80002e2c <fetchaddr+0x3e>
    80002e3c:	557d                	li	a0,-1
    80002e3e:	b7fd                	j	80002e2c <fetchaddr+0x3e>

0000000080002e40 <fetchstr>:
{
    80002e40:	7179                	addi	sp,sp,-48
    80002e42:	f406                	sd	ra,40(sp)
    80002e44:	f022                	sd	s0,32(sp)
    80002e46:	ec26                	sd	s1,24(sp)
    80002e48:	e84a                	sd	s2,16(sp)
    80002e4a:	e44e                	sd	s3,8(sp)
    80002e4c:	1800                	addi	s0,sp,48
    80002e4e:	892a                	mv	s2,a0
    80002e50:	84ae                	mv	s1,a1
    80002e52:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e54:	fffff097          	auipc	ra,0xfffff
    80002e58:	cfc080e7          	jalr	-772(ra) # 80001b50 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e5c:	86ce                	mv	a3,s3
    80002e5e:	864a                	mv	a2,s2
    80002e60:	85a6                	mv	a1,s1
    80002e62:	6d28                	ld	a0,88(a0)
    80002e64:	fffff097          	auipc	ra,0xfffff
    80002e68:	ab6080e7          	jalr	-1354(ra) # 8000191a <copyinstr>
  if(err < 0)
    80002e6c:	00054763          	bltz	a0,80002e7a <fetchstr+0x3a>
  return strlen(buf);
    80002e70:	8526                	mv	a0,s1
    80002e72:	ffffe097          	auipc	ra,0xffffe
    80002e76:	1ac080e7          	jalr	428(ra) # 8000101e <strlen>
}
    80002e7a:	70a2                	ld	ra,40(sp)
    80002e7c:	7402                	ld	s0,32(sp)
    80002e7e:	64e2                	ld	s1,24(sp)
    80002e80:	6942                	ld	s2,16(sp)
    80002e82:	69a2                	ld	s3,8(sp)
    80002e84:	6145                	addi	sp,sp,48
    80002e86:	8082                	ret

0000000080002e88 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	e426                	sd	s1,8(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	ef2080e7          	jalr	-270(ra) # 80002d86 <argraw>
    80002e9c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e9e:	4501                	li	a0,0
    80002ea0:	60e2                	ld	ra,24(sp)
    80002ea2:	6442                	ld	s0,16(sp)
    80002ea4:	64a2                	ld	s1,8(sp)
    80002ea6:	6105                	addi	sp,sp,32
    80002ea8:	8082                	ret

0000000080002eaa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002eaa:	1101                	addi	sp,sp,-32
    80002eac:	ec06                	sd	ra,24(sp)
    80002eae:	e822                	sd	s0,16(sp)
    80002eb0:	e426                	sd	s1,8(sp)
    80002eb2:	1000                	addi	s0,sp,32
    80002eb4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	ed0080e7          	jalr	-304(ra) # 80002d86 <argraw>
    80002ebe:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ec0:	4501                	li	a0,0
    80002ec2:	60e2                	ld	ra,24(sp)
    80002ec4:	6442                	ld	s0,16(sp)
    80002ec6:	64a2                	ld	s1,8(sp)
    80002ec8:	6105                	addi	sp,sp,32
    80002eca:	8082                	ret

0000000080002ecc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	e426                	sd	s1,8(sp)
    80002ed4:	e04a                	sd	s2,0(sp)
    80002ed6:	1000                	addi	s0,sp,32
    80002ed8:	84ae                	mv	s1,a1
    80002eda:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	eaa080e7          	jalr	-342(ra) # 80002d86 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ee4:	864a                	mv	a2,s2
    80002ee6:	85a6                	mv	a1,s1
    80002ee8:	00000097          	auipc	ra,0x0
    80002eec:	f58080e7          	jalr	-168(ra) # 80002e40 <fetchstr>
}
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	64a2                	ld	s1,8(sp)
    80002ef6:	6902                	ld	s2,0(sp)
    80002ef8:	6105                	addi	sp,sp,32
    80002efa:	8082                	ret

0000000080002efc <syscall>:
[SYS_nfree]   sys_nfree,
};

void
syscall(void)
{
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	e426                	sd	s1,8(sp)
    80002f04:	e04a                	sd	s2,0(sp)
    80002f06:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002f08:	fffff097          	auipc	ra,0xfffff
    80002f0c:	c48080e7          	jalr	-952(ra) # 80001b50 <myproc>
    80002f10:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002f12:	06053903          	ld	s2,96(a0)
    80002f16:	0a893783          	ld	a5,168(s2)
    80002f1a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f1e:	37fd                	addiw	a5,a5,-1
    80002f20:	4759                	li	a4,22
    80002f22:	00f76f63          	bltu	a4,a5,80002f40 <syscall+0x44>
    80002f26:	00369713          	slli	a4,a3,0x3
    80002f2a:	00007797          	auipc	a5,0x7
    80002f2e:	aee78793          	addi	a5,a5,-1298 # 80009a18 <syscalls>
    80002f32:	97ba                	add	a5,a5,a4
    80002f34:	639c                	ld	a5,0(a5)
    80002f36:	c789                	beqz	a5,80002f40 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f38:	9782                	jalr	a5
    80002f3a:	06a93823          	sd	a0,112(s2)
    80002f3e:	a839                	j	80002f5c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f40:	16048613          	addi	a2,s1,352
    80002f44:	40ac                	lw	a1,64(s1)
    80002f46:	00007517          	auipc	a0,0x7
    80002f4a:	a9a50513          	addi	a0,a0,-1382 # 800099e0 <nointr_desc.0+0x88>
    80002f4e:	ffffd097          	auipc	ra,0xffffd
    80002f52:	678080e7          	jalr	1656(ra) # 800005c6 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f56:	70bc                	ld	a5,96(s1)
    80002f58:	577d                	li	a4,-1
    80002f5a:	fbb8                	sd	a4,112(a5)
  }
}
    80002f5c:	60e2                	ld	ra,24(sp)
    80002f5e:	6442                	ld	s0,16(sp)
    80002f60:	64a2                	ld	s1,8(sp)
    80002f62:	6902                	ld	s2,0(sp)
    80002f64:	6105                	addi	sp,sp,32
    80002f66:	8082                	ret

0000000080002f68 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f70:	fec40593          	addi	a1,s0,-20
    80002f74:	4501                	li	a0,0
    80002f76:	00000097          	auipc	ra,0x0
    80002f7a:	f12080e7          	jalr	-238(ra) # 80002e88 <argint>
    return -1;
    80002f7e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f80:	00054963          	bltz	a0,80002f92 <sys_exit+0x2a>
  exit(n);
    80002f84:	fec42503          	lw	a0,-20(s0)
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	2e2080e7          	jalr	738(ra) # 8000226a <exit>
  return 0;  // not reached
    80002f90:	4781                	li	a5,0
}
    80002f92:	853e                	mv	a0,a5
    80002f94:	60e2                	ld	ra,24(sp)
    80002f96:	6442                	ld	s0,16(sp)
    80002f98:	6105                	addi	sp,sp,32
    80002f9a:	8082                	ret

0000000080002f9c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f9c:	1141                	addi	sp,sp,-16
    80002f9e:	e406                	sd	ra,8(sp)
    80002fa0:	e022                	sd	s0,0(sp)
    80002fa2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002fa4:	fffff097          	auipc	ra,0xfffff
    80002fa8:	bac080e7          	jalr	-1108(ra) # 80001b50 <myproc>
}
    80002fac:	4128                	lw	a0,64(a0)
    80002fae:	60a2                	ld	ra,8(sp)
    80002fb0:	6402                	ld	s0,0(sp)
    80002fb2:	0141                	addi	sp,sp,16
    80002fb4:	8082                	ret

0000000080002fb6 <sys_fork>:

uint64
sys_fork(void)
{
    80002fb6:	1141                	addi	sp,sp,-16
    80002fb8:	e406                	sd	ra,8(sp)
    80002fba:	e022                	sd	s0,0(sp)
    80002fbc:	0800                	addi	s0,sp,16
  return fork();
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	f38080e7          	jalr	-200(ra) # 80001ef6 <fork>
}
    80002fc6:	60a2                	ld	ra,8(sp)
    80002fc8:	6402                	ld	s0,0(sp)
    80002fca:	0141                	addi	sp,sp,16
    80002fcc:	8082                	ret

0000000080002fce <sys_wait>:

uint64
sys_wait(void)
{
    80002fce:	1101                	addi	sp,sp,-32
    80002fd0:	ec06                	sd	ra,24(sp)
    80002fd2:	e822                	sd	s0,16(sp)
    80002fd4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fd6:	fe840593          	addi	a1,s0,-24
    80002fda:	4501                	li	a0,0
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	ece080e7          	jalr	-306(ra) # 80002eaa <argaddr>
    80002fe4:	87aa                	mv	a5,a0
    return -1;
    80002fe6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fe8:	0007c863          	bltz	a5,80002ff8 <sys_wait+0x2a>
  return wait(p);
    80002fec:	fe843503          	ld	a0,-24(s0)
    80002ff0:	fffff097          	auipc	ra,0xfffff
    80002ff4:	5a4080e7          	jalr	1444(ra) # 80002594 <wait>
}
    80002ff8:	60e2                	ld	ra,24(sp)
    80002ffa:	6442                	ld	s0,16(sp)
    80002ffc:	6105                	addi	sp,sp,32
    80002ffe:	8082                	ret

0000000080003000 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003000:	7179                	addi	sp,sp,-48
    80003002:	f406                	sd	ra,40(sp)
    80003004:	f022                	sd	s0,32(sp)
    80003006:	ec26                	sd	s1,24(sp)
    80003008:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    8000300a:	fdc40593          	addi	a1,s0,-36
    8000300e:	4501                	li	a0,0
    80003010:	00000097          	auipc	ra,0x0
    80003014:	e78080e7          	jalr	-392(ra) # 80002e88 <argint>
    return -1;
    80003018:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    8000301a:	00054f63          	bltz	a0,80003038 <sys_sbrk+0x38>
  addr = myproc()->sz;
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	b32080e7          	jalr	-1230(ra) # 80001b50 <myproc>
    80003026:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003028:	fdc42503          	lw	a0,-36(s0)
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	e56080e7          	jalr	-426(ra) # 80001e82 <growproc>
    80003034:	00054863          	bltz	a0,80003044 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003038:	8526                	mv	a0,s1
    8000303a:	70a2                	ld	ra,40(sp)
    8000303c:	7402                	ld	s0,32(sp)
    8000303e:	64e2                	ld	s1,24(sp)
    80003040:	6145                	addi	sp,sp,48
    80003042:	8082                	ret
    return -1;
    80003044:	54fd                	li	s1,-1
    80003046:	bfcd                	j	80003038 <sys_sbrk+0x38>

0000000080003048 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003048:	7139                	addi	sp,sp,-64
    8000304a:	fc06                	sd	ra,56(sp)
    8000304c:	f822                	sd	s0,48(sp)
    8000304e:	f426                	sd	s1,40(sp)
    80003050:	f04a                	sd	s2,32(sp)
    80003052:	ec4e                	sd	s3,24(sp)
    80003054:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003056:	fcc40593          	addi	a1,s0,-52
    8000305a:	4501                	li	a0,0
    8000305c:	00000097          	auipc	ra,0x0
    80003060:	e2c080e7          	jalr	-468(ra) # 80002e88 <argint>
    return -1;
    80003064:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003066:	06054563          	bltz	a0,800030d0 <sys_sleep+0x88>
  acquire(&tickslock);
    8000306a:	0002a517          	auipc	a0,0x2a
    8000306e:	c9e50513          	addi	a0,a0,-866 # 8002cd08 <tickslock>
    80003072:	ffffe097          	auipc	ra,0xffffe
    80003076:	b20080e7          	jalr	-1248(ra) # 80000b92 <acquire>
  ticks0 = ticks;
    8000307a:	00007917          	auipc	s2,0x7
    8000307e:	f8692903          	lw	s2,-122(s2) # 8000a000 <ticks>
  while(ticks - ticks0 < n){
    80003082:	fcc42783          	lw	a5,-52(s0)
    80003086:	cf85                	beqz	a5,800030be <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003088:	0002a997          	auipc	s3,0x2a
    8000308c:	c8098993          	addi	s3,s3,-896 # 8002cd08 <tickslock>
    80003090:	00007497          	auipc	s1,0x7
    80003094:	f7048493          	addi	s1,s1,-144 # 8000a000 <ticks>
    if(myproc()->killed){
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	ab8080e7          	jalr	-1352(ra) # 80001b50 <myproc>
    800030a0:	5d1c                	lw	a5,56(a0)
    800030a2:	ef9d                	bnez	a5,800030e0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800030a4:	85ce                	mv	a1,s3
    800030a6:	8526                	mv	a0,s1
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	430080e7          	jalr	1072(ra) # 800024d8 <sleep>
  while(ticks - ticks0 < n){
    800030b0:	409c                	lw	a5,0(s1)
    800030b2:	412787bb          	subw	a5,a5,s2
    800030b6:	fcc42703          	lw	a4,-52(s0)
    800030ba:	fce7efe3          	bltu	a5,a4,80003098 <sys_sleep+0x50>
  }
  release(&tickslock);
    800030be:	0002a517          	auipc	a0,0x2a
    800030c2:	c4a50513          	addi	a0,a0,-950 # 8002cd08 <tickslock>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	b9c080e7          	jalr	-1124(ra) # 80000c62 <release>
  return 0;
    800030ce:	4781                	li	a5,0
}
    800030d0:	853e                	mv	a0,a5
    800030d2:	70e2                	ld	ra,56(sp)
    800030d4:	7442                	ld	s0,48(sp)
    800030d6:	74a2                	ld	s1,40(sp)
    800030d8:	7902                	ld	s2,32(sp)
    800030da:	69e2                	ld	s3,24(sp)
    800030dc:	6121                	addi	sp,sp,64
    800030de:	8082                	ret
      release(&tickslock);
    800030e0:	0002a517          	auipc	a0,0x2a
    800030e4:	c2850513          	addi	a0,a0,-984 # 8002cd08 <tickslock>
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	b7a080e7          	jalr	-1158(ra) # 80000c62 <release>
      return -1;
    800030f0:	57fd                	li	a5,-1
    800030f2:	bff9                	j	800030d0 <sys_sleep+0x88>

00000000800030f4 <sys_kill>:

uint64
sys_kill(void)
{
    800030f4:	1101                	addi	sp,sp,-32
    800030f6:	ec06                	sd	ra,24(sp)
    800030f8:	e822                	sd	s0,16(sp)
    800030fa:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030fc:	fec40593          	addi	a1,s0,-20
    80003100:	4501                	li	a0,0
    80003102:	00000097          	auipc	ra,0x0
    80003106:	d86080e7          	jalr	-634(ra) # 80002e88 <argint>
    8000310a:	87aa                	mv	a5,a0
    return -1;
    8000310c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000310e:	0007c863          	bltz	a5,8000311e <sys_kill+0x2a>
  return kill(pid);
    80003112:	fec42503          	lw	a0,-20(s0)
    80003116:	fffff097          	auipc	ra,0xfffff
    8000311a:	5f2080e7          	jalr	1522(ra) # 80002708 <kill>
}
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	6105                	addi	sp,sp,32
    80003124:	8082                	ret

0000000080003126 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003126:	1101                	addi	sp,sp,-32
    80003128:	ec06                	sd	ra,24(sp)
    8000312a:	e822                	sd	s0,16(sp)
    8000312c:	e426                	sd	s1,8(sp)
    8000312e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003130:	0002a517          	auipc	a0,0x2a
    80003134:	bd850513          	addi	a0,a0,-1064 # 8002cd08 <tickslock>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	a5a080e7          	jalr	-1446(ra) # 80000b92 <acquire>
  xticks = ticks;
    80003140:	00007497          	auipc	s1,0x7
    80003144:	ec04a483          	lw	s1,-320(s1) # 8000a000 <ticks>
  release(&tickslock);
    80003148:	0002a517          	auipc	a0,0x2a
    8000314c:	bc050513          	addi	a0,a0,-1088 # 8002cd08 <tickslock>
    80003150:	ffffe097          	auipc	ra,0xffffe
    80003154:	b12080e7          	jalr	-1262(ra) # 80000c62 <release>
  return xticks;
    80003158:	02049513          	slli	a0,s1,0x20
    8000315c:	9101                	srli	a0,a0,0x20
    8000315e:	60e2                	ld	ra,24(sp)
    80003160:	6442                	ld	s0,16(sp)
    80003162:	64a2                	ld	s1,8(sp)
    80003164:	6105                	addi	sp,sp,32
    80003166:	8082                	ret

0000000080003168 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003168:	7179                	addi	sp,sp,-48
    8000316a:	f406                	sd	ra,40(sp)
    8000316c:	f022                	sd	s0,32(sp)
    8000316e:	ec26                	sd	s1,24(sp)
    80003170:	e84a                	sd	s2,16(sp)
    80003172:	e44e                	sd	s3,8(sp)
    80003174:	e052                	sd	s4,0(sp)
    80003176:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003178:	00007597          	auipc	a1,0x7
    8000317c:	96058593          	addi	a1,a1,-1696 # 80009ad8 <syscalls+0xc0>
    80003180:	0002a517          	auipc	a0,0x2a
    80003184:	ba850513          	addi	a0,a0,-1112 # 8002cd28 <bcache>
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	934080e7          	jalr	-1740(ra) # 80000abc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003190:	00032797          	auipc	a5,0x32
    80003194:	b9878793          	addi	a5,a5,-1128 # 80034d28 <bcache+0x8000>
    80003198:	00032717          	auipc	a4,0x32
    8000319c:	ef070713          	addi	a4,a4,-272 # 80035088 <bcache+0x8360>
    800031a0:	3ae7b823          	sd	a4,944(a5)
  bcache.head.next = &bcache.head;
    800031a4:	3ae7bc23          	sd	a4,952(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031a8:	0002a497          	auipc	s1,0x2a
    800031ac:	ba048493          	addi	s1,s1,-1120 # 8002cd48 <bcache+0x20>
    b->next = bcache.head.next;
    800031b0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031b2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031b4:	00007a17          	auipc	s4,0x7
    800031b8:	92ca0a13          	addi	s4,s4,-1748 # 80009ae0 <syscalls+0xc8>
    b->next = bcache.head.next;
    800031bc:	3b893783          	ld	a5,952(s2)
    800031c0:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    800031c2:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    800031c6:	85d2                	mv	a1,s4
    800031c8:	01048513          	addi	a0,s1,16
    800031cc:	00001097          	auipc	ra,0x1
    800031d0:	4aa080e7          	jalr	1194(ra) # 80004676 <initsleeplock>
    bcache.head.next->prev = b;
    800031d4:	3b893783          	ld	a5,952(s2)
    800031d8:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    800031da:	3a993c23          	sd	s1,952(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031de:	46048493          	addi	s1,s1,1120
    800031e2:	fd349de3          	bne	s1,s3,800031bc <binit+0x54>
  }
}
    800031e6:	70a2                	ld	ra,40(sp)
    800031e8:	7402                	ld	s0,32(sp)
    800031ea:	64e2                	ld	s1,24(sp)
    800031ec:	6942                	ld	s2,16(sp)
    800031ee:	69a2                	ld	s3,8(sp)
    800031f0:	6a02                	ld	s4,0(sp)
    800031f2:	6145                	addi	sp,sp,48
    800031f4:	8082                	ret

00000000800031f6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800031f6:	7179                	addi	sp,sp,-48
    800031f8:	f406                	sd	ra,40(sp)
    800031fa:	f022                	sd	s0,32(sp)
    800031fc:	ec26                	sd	s1,24(sp)
    800031fe:	e84a                	sd	s2,16(sp)
    80003200:	e44e                	sd	s3,8(sp)
    80003202:	1800                	addi	s0,sp,48
    80003204:	892a                	mv	s2,a0
    80003206:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003208:	0002a517          	auipc	a0,0x2a
    8000320c:	b2050513          	addi	a0,a0,-1248 # 8002cd28 <bcache>
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	982080e7          	jalr	-1662(ra) # 80000b92 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003218:	00032497          	auipc	s1,0x32
    8000321c:	ec84b483          	ld	s1,-312(s1) # 800350e0 <bcache+0x83b8>
    80003220:	00032797          	auipc	a5,0x32
    80003224:	e6878793          	addi	a5,a5,-408 # 80035088 <bcache+0x8360>
    80003228:	02f48f63          	beq	s1,a5,80003266 <bread+0x70>
    8000322c:	873e                	mv	a4,a5
    8000322e:	a021                	j	80003236 <bread+0x40>
    80003230:	6ca4                	ld	s1,88(s1)
    80003232:	02e48a63          	beq	s1,a4,80003266 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003236:	449c                	lw	a5,8(s1)
    80003238:	ff279ce3          	bne	a5,s2,80003230 <bread+0x3a>
    8000323c:	44dc                	lw	a5,12(s1)
    8000323e:	ff3799e3          	bne	a5,s3,80003230 <bread+0x3a>
      b->refcnt++;
    80003242:	44bc                	lw	a5,72(s1)
    80003244:	2785                	addiw	a5,a5,1
    80003246:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    80003248:	0002a517          	auipc	a0,0x2a
    8000324c:	ae050513          	addi	a0,a0,-1312 # 8002cd28 <bcache>
    80003250:	ffffe097          	auipc	ra,0xffffe
    80003254:	a12080e7          	jalr	-1518(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    80003258:	01048513          	addi	a0,s1,16
    8000325c:	00001097          	auipc	ra,0x1
    80003260:	454080e7          	jalr	1108(ra) # 800046b0 <acquiresleep>
      return b;
    80003264:	a8b9                	j	800032c2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003266:	00032497          	auipc	s1,0x32
    8000326a:	e724b483          	ld	s1,-398(s1) # 800350d8 <bcache+0x83b0>
    8000326e:	00032797          	auipc	a5,0x32
    80003272:	e1a78793          	addi	a5,a5,-486 # 80035088 <bcache+0x8360>
    80003276:	00f48863          	beq	s1,a5,80003286 <bread+0x90>
    8000327a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000327c:	44bc                	lw	a5,72(s1)
    8000327e:	cf81                	beqz	a5,80003296 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003280:	68a4                	ld	s1,80(s1)
    80003282:	fee49de3          	bne	s1,a4,8000327c <bread+0x86>
  panic("bget: no buffers");
    80003286:	00007517          	auipc	a0,0x7
    8000328a:	86250513          	addi	a0,a0,-1950 # 80009ae8 <syscalls+0xd0>
    8000328e:	ffffd097          	auipc	ra,0xffffd
    80003292:	2d6080e7          	jalr	726(ra) # 80000564 <panic>
      b->dev = dev;
    80003296:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000329a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000329e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032a2:	4785                	li	a5,1
    800032a4:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800032a6:	0002a517          	auipc	a0,0x2a
    800032aa:	a8250513          	addi	a0,a0,-1406 # 8002cd28 <bcache>
    800032ae:	ffffe097          	auipc	ra,0xffffe
    800032b2:	9b4080e7          	jalr	-1612(ra) # 80000c62 <release>
      acquiresleep(&b->lock);
    800032b6:	01048513          	addi	a0,s1,16
    800032ba:	00001097          	auipc	ra,0x1
    800032be:	3f6080e7          	jalr	1014(ra) # 800046b0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032c2:	409c                	lw	a5,0(s1)
    800032c4:	cb89                	beqz	a5,800032d6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032c6:	8526                	mv	a0,s1
    800032c8:	70a2                	ld	ra,40(sp)
    800032ca:	7402                	ld	s0,32(sp)
    800032cc:	64e2                	ld	s1,24(sp)
    800032ce:	6942                	ld	s2,16(sp)
    800032d0:	69a2                	ld	s3,8(sp)
    800032d2:	6145                	addi	sp,sp,48
    800032d4:	8082                	ret
    virtio_disk_rw(b, 0);
    800032d6:	4581                	li	a1,0
    800032d8:	8526                	mv	a0,s1
    800032da:	00003097          	auipc	ra,0x3
    800032de:	f9c080e7          	jalr	-100(ra) # 80006276 <virtio_disk_rw>
    b->valid = 1;
    800032e2:	4785                	li	a5,1
    800032e4:	c09c                	sw	a5,0(s1)
  return b;
    800032e6:	b7c5                	j	800032c6 <bread+0xd0>

00000000800032e8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032e8:	1101                	addi	sp,sp,-32
    800032ea:	ec06                	sd	ra,24(sp)
    800032ec:	e822                	sd	s0,16(sp)
    800032ee:	e426                	sd	s1,8(sp)
    800032f0:	1000                	addi	s0,sp,32
    800032f2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032f4:	0541                	addi	a0,a0,16
    800032f6:	00001097          	auipc	ra,0x1
    800032fa:	454080e7          	jalr	1108(ra) # 8000474a <holdingsleep>
    800032fe:	cd01                	beqz	a0,80003316 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003300:	4585                	li	a1,1
    80003302:	8526                	mv	a0,s1
    80003304:	00003097          	auipc	ra,0x3
    80003308:	f72080e7          	jalr	-142(ra) # 80006276 <virtio_disk_rw>
}
    8000330c:	60e2                	ld	ra,24(sp)
    8000330e:	6442                	ld	s0,16(sp)
    80003310:	64a2                	ld	s1,8(sp)
    80003312:	6105                	addi	sp,sp,32
    80003314:	8082                	ret
    panic("bwrite");
    80003316:	00006517          	auipc	a0,0x6
    8000331a:	7ea50513          	addi	a0,a0,2026 # 80009b00 <syscalls+0xe8>
    8000331e:	ffffd097          	auipc	ra,0xffffd
    80003322:	246080e7          	jalr	582(ra) # 80000564 <panic>

0000000080003326 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003326:	1101                	addi	sp,sp,-32
    80003328:	ec06                	sd	ra,24(sp)
    8000332a:	e822                	sd	s0,16(sp)
    8000332c:	e426                	sd	s1,8(sp)
    8000332e:	e04a                	sd	s2,0(sp)
    80003330:	1000                	addi	s0,sp,32
    80003332:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003334:	01050913          	addi	s2,a0,16
    80003338:	854a                	mv	a0,s2
    8000333a:	00001097          	auipc	ra,0x1
    8000333e:	410080e7          	jalr	1040(ra) # 8000474a <holdingsleep>
    80003342:	c92d                	beqz	a0,800033b4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003344:	854a                	mv	a0,s2
    80003346:	00001097          	auipc	ra,0x1
    8000334a:	3c0080e7          	jalr	960(ra) # 80004706 <releasesleep>

  acquire(&bcache.lock);
    8000334e:	0002a517          	auipc	a0,0x2a
    80003352:	9da50513          	addi	a0,a0,-1574 # 8002cd28 <bcache>
    80003356:	ffffe097          	auipc	ra,0xffffe
    8000335a:	83c080e7          	jalr	-1988(ra) # 80000b92 <acquire>
  b->refcnt--;
    8000335e:	44bc                	lw	a5,72(s1)
    80003360:	37fd                	addiw	a5,a5,-1
    80003362:	0007871b          	sext.w	a4,a5
    80003366:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    80003368:	eb05                	bnez	a4,80003398 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000336a:	6cbc                	ld	a5,88(s1)
    8000336c:	68b8                	ld	a4,80(s1)
    8000336e:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    80003370:	68bc                	ld	a5,80(s1)
    80003372:	6cb8                	ld	a4,88(s1)
    80003374:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    80003376:	00032797          	auipc	a5,0x32
    8000337a:	9b278793          	addi	a5,a5,-1614 # 80034d28 <bcache+0x8000>
    8000337e:	3b87b703          	ld	a4,952(a5)
    80003382:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    80003384:	00032717          	auipc	a4,0x32
    80003388:	d0470713          	addi	a4,a4,-764 # 80035088 <bcache+0x8360>
    8000338c:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    8000338e:	3b87b703          	ld	a4,952(a5)
    80003392:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    80003394:	3a97bc23          	sd	s1,952(a5)
  }
  
  release(&bcache.lock);
    80003398:	0002a517          	auipc	a0,0x2a
    8000339c:	99050513          	addi	a0,a0,-1648 # 8002cd28 <bcache>
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	8c2080e7          	jalr	-1854(ra) # 80000c62 <release>
}
    800033a8:	60e2                	ld	ra,24(sp)
    800033aa:	6442                	ld	s0,16(sp)
    800033ac:	64a2                	ld	s1,8(sp)
    800033ae:	6902                	ld	s2,0(sp)
    800033b0:	6105                	addi	sp,sp,32
    800033b2:	8082                	ret
    panic("brelse");
    800033b4:	00006517          	auipc	a0,0x6
    800033b8:	75450513          	addi	a0,a0,1876 # 80009b08 <syscalls+0xf0>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	1a8080e7          	jalr	424(ra) # 80000564 <panic>

00000000800033c4 <bpin>:

void
bpin(struct buf *b) {
    800033c4:	1101                	addi	sp,sp,-32
    800033c6:	ec06                	sd	ra,24(sp)
    800033c8:	e822                	sd	s0,16(sp)
    800033ca:	e426                	sd	s1,8(sp)
    800033cc:	1000                	addi	s0,sp,32
    800033ce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033d0:	0002a517          	auipc	a0,0x2a
    800033d4:	95850513          	addi	a0,a0,-1704 # 8002cd28 <bcache>
    800033d8:	ffffd097          	auipc	ra,0xffffd
    800033dc:	7ba080e7          	jalr	1978(ra) # 80000b92 <acquire>
  b->refcnt++;
    800033e0:	44bc                	lw	a5,72(s1)
    800033e2:	2785                	addiw	a5,a5,1
    800033e4:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800033e6:	0002a517          	auipc	a0,0x2a
    800033ea:	94250513          	addi	a0,a0,-1726 # 8002cd28 <bcache>
    800033ee:	ffffe097          	auipc	ra,0xffffe
    800033f2:	874080e7          	jalr	-1932(ra) # 80000c62 <release>
}
    800033f6:	60e2                	ld	ra,24(sp)
    800033f8:	6442                	ld	s0,16(sp)
    800033fa:	64a2                	ld	s1,8(sp)
    800033fc:	6105                	addi	sp,sp,32
    800033fe:	8082                	ret

0000000080003400 <bunpin>:

void
bunpin(struct buf *b) {
    80003400:	1101                	addi	sp,sp,-32
    80003402:	ec06                	sd	ra,24(sp)
    80003404:	e822                	sd	s0,16(sp)
    80003406:	e426                	sd	s1,8(sp)
    80003408:	1000                	addi	s0,sp,32
    8000340a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000340c:	0002a517          	auipc	a0,0x2a
    80003410:	91c50513          	addi	a0,a0,-1764 # 8002cd28 <bcache>
    80003414:	ffffd097          	auipc	ra,0xffffd
    80003418:	77e080e7          	jalr	1918(ra) # 80000b92 <acquire>
  b->refcnt--;
    8000341c:	44bc                	lw	a5,72(s1)
    8000341e:	37fd                	addiw	a5,a5,-1
    80003420:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003422:	0002a517          	auipc	a0,0x2a
    80003426:	90650513          	addi	a0,a0,-1786 # 8002cd28 <bcache>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	838080e7          	jalr	-1992(ra) # 80000c62 <release>
}
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	64a2                	ld	s1,8(sp)
    80003438:	6105                	addi	sp,sp,32
    8000343a:	8082                	ret

000000008000343c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000343c:	1101                	addi	sp,sp,-32
    8000343e:	ec06                	sd	ra,24(sp)
    80003440:	e822                	sd	s0,16(sp)
    80003442:	e426                	sd	s1,8(sp)
    80003444:	e04a                	sd	s2,0(sp)
    80003446:	1000                	addi	s0,sp,32
    80003448:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000344a:	00d5d59b          	srliw	a1,a1,0xd
    8000344e:	00032797          	auipc	a5,0x32
    80003452:	0b67a783          	lw	a5,182(a5) # 80035504 <sb+0x1c>
    80003456:	9dbd                	addw	a1,a1,a5
    80003458:	00000097          	auipc	ra,0x0
    8000345c:	d9e080e7          	jalr	-610(ra) # 800031f6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003460:	0074f713          	andi	a4,s1,7
    80003464:	4785                	li	a5,1
    80003466:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000346a:	14ce                	slli	s1,s1,0x33
    8000346c:	90d9                	srli	s1,s1,0x36
    8000346e:	00950733          	add	a4,a0,s1
    80003472:	06074703          	lbu	a4,96(a4)
    80003476:	00e7f6b3          	and	a3,a5,a4
    8000347a:	c69d                	beqz	a3,800034a8 <bfree+0x6c>
    8000347c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000347e:	94aa                	add	s1,s1,a0
    80003480:	fff7c793          	not	a5,a5
    80003484:	8ff9                	and	a5,a5,a4
    80003486:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    8000348a:	00001097          	auipc	ra,0x1
    8000348e:	106080e7          	jalr	262(ra) # 80004590 <log_write>
  brelse(bp);
    80003492:	854a                	mv	a0,s2
    80003494:	00000097          	auipc	ra,0x0
    80003498:	e92080e7          	jalr	-366(ra) # 80003326 <brelse>
}
    8000349c:	60e2                	ld	ra,24(sp)
    8000349e:	6442                	ld	s0,16(sp)
    800034a0:	64a2                	ld	s1,8(sp)
    800034a2:	6902                	ld	s2,0(sp)
    800034a4:	6105                	addi	sp,sp,32
    800034a6:	8082                	ret
    panic("freeing free block");
    800034a8:	00006517          	auipc	a0,0x6
    800034ac:	66850513          	addi	a0,a0,1640 # 80009b10 <syscalls+0xf8>
    800034b0:	ffffd097          	auipc	ra,0xffffd
    800034b4:	0b4080e7          	jalr	180(ra) # 80000564 <panic>

00000000800034b8 <balloc>:
{
    800034b8:	711d                	addi	sp,sp,-96
    800034ba:	ec86                	sd	ra,88(sp)
    800034bc:	e8a2                	sd	s0,80(sp)
    800034be:	e4a6                	sd	s1,72(sp)
    800034c0:	e0ca                	sd	s2,64(sp)
    800034c2:	fc4e                	sd	s3,56(sp)
    800034c4:	f852                	sd	s4,48(sp)
    800034c6:	f456                	sd	s5,40(sp)
    800034c8:	f05a                	sd	s6,32(sp)
    800034ca:	ec5e                	sd	s7,24(sp)
    800034cc:	e862                	sd	s8,16(sp)
    800034ce:	e466                	sd	s9,8(sp)
    800034d0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034d2:	00032797          	auipc	a5,0x32
    800034d6:	01a7a783          	lw	a5,26(a5) # 800354ec <sb+0x4>
    800034da:	cbd1                	beqz	a5,8000356e <balloc+0xb6>
    800034dc:	8baa                	mv	s7,a0
    800034de:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034e0:	00032b17          	auipc	s6,0x32
    800034e4:	008b0b13          	addi	s6,s6,8 # 800354e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034e8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034ea:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ec:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034ee:	6c89                	lui	s9,0x2
    800034f0:	a831                	j	8000350c <balloc+0x54>
    brelse(bp);
    800034f2:	854a                	mv	a0,s2
    800034f4:	00000097          	auipc	ra,0x0
    800034f8:	e32080e7          	jalr	-462(ra) # 80003326 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034fc:	015c87bb          	addw	a5,s9,s5
    80003500:	00078a9b          	sext.w	s5,a5
    80003504:	004b2703          	lw	a4,4(s6)
    80003508:	06eaf363          	bgeu	s5,a4,8000356e <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000350c:	41fad79b          	sraiw	a5,s5,0x1f
    80003510:	0137d79b          	srliw	a5,a5,0x13
    80003514:	015787bb          	addw	a5,a5,s5
    80003518:	40d7d79b          	sraiw	a5,a5,0xd
    8000351c:	01cb2583          	lw	a1,28(s6)
    80003520:	9dbd                	addw	a1,a1,a5
    80003522:	855e                	mv	a0,s7
    80003524:	00000097          	auipc	ra,0x0
    80003528:	cd2080e7          	jalr	-814(ra) # 800031f6 <bread>
    8000352c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000352e:	004b2503          	lw	a0,4(s6)
    80003532:	000a849b          	sext.w	s1,s5
    80003536:	8662                	mv	a2,s8
    80003538:	faa4fde3          	bgeu	s1,a0,800034f2 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000353c:	41f6579b          	sraiw	a5,a2,0x1f
    80003540:	01d7d69b          	srliw	a3,a5,0x1d
    80003544:	00c6873b          	addw	a4,a3,a2
    80003548:	00777793          	andi	a5,a4,7
    8000354c:	9f95                	subw	a5,a5,a3
    8000354e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003552:	4037571b          	sraiw	a4,a4,0x3
    80003556:	00e906b3          	add	a3,s2,a4
    8000355a:	0606c683          	lbu	a3,96(a3)
    8000355e:	00d7f5b3          	and	a1,a5,a3
    80003562:	cd91                	beqz	a1,8000357e <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003564:	2605                	addiw	a2,a2,1
    80003566:	2485                	addiw	s1,s1,1
    80003568:	fd4618e3          	bne	a2,s4,80003538 <balloc+0x80>
    8000356c:	b759                	j	800034f2 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000356e:	00006517          	auipc	a0,0x6
    80003572:	5ba50513          	addi	a0,a0,1466 # 80009b28 <syscalls+0x110>
    80003576:	ffffd097          	auipc	ra,0xffffd
    8000357a:	fee080e7          	jalr	-18(ra) # 80000564 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000357e:	974a                	add	a4,a4,s2
    80003580:	8fd5                	or	a5,a5,a3
    80003582:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003586:	854a                	mv	a0,s2
    80003588:	00001097          	auipc	ra,0x1
    8000358c:	008080e7          	jalr	8(ra) # 80004590 <log_write>
        brelse(bp);
    80003590:	854a                	mv	a0,s2
    80003592:	00000097          	auipc	ra,0x0
    80003596:	d94080e7          	jalr	-620(ra) # 80003326 <brelse>
  bp = bread(dev, bno);
    8000359a:	85a6                	mv	a1,s1
    8000359c:	855e                	mv	a0,s7
    8000359e:	00000097          	auipc	ra,0x0
    800035a2:	c58080e7          	jalr	-936(ra) # 800031f6 <bread>
    800035a6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035a8:	40000613          	li	a2,1024
    800035ac:	4581                	li	a1,0
    800035ae:	06050513          	addi	a0,a0,96
    800035b2:	ffffe097          	auipc	ra,0xffffe
    800035b6:	8c4080e7          	jalr	-1852(ra) # 80000e76 <memset>
  log_write(bp);
    800035ba:	854a                	mv	a0,s2
    800035bc:	00001097          	auipc	ra,0x1
    800035c0:	fd4080e7          	jalr	-44(ra) # 80004590 <log_write>
  brelse(bp);
    800035c4:	854a                	mv	a0,s2
    800035c6:	00000097          	auipc	ra,0x0
    800035ca:	d60080e7          	jalr	-672(ra) # 80003326 <brelse>
}
    800035ce:	8526                	mv	a0,s1
    800035d0:	60e6                	ld	ra,88(sp)
    800035d2:	6446                	ld	s0,80(sp)
    800035d4:	64a6                	ld	s1,72(sp)
    800035d6:	6906                	ld	s2,64(sp)
    800035d8:	79e2                	ld	s3,56(sp)
    800035da:	7a42                	ld	s4,48(sp)
    800035dc:	7aa2                	ld	s5,40(sp)
    800035de:	7b02                	ld	s6,32(sp)
    800035e0:	6be2                	ld	s7,24(sp)
    800035e2:	6c42                	ld	s8,16(sp)
    800035e4:	6ca2                	ld	s9,8(sp)
    800035e6:	6125                	addi	sp,sp,96
    800035e8:	8082                	ret

00000000800035ea <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800035ea:	7179                	addi	sp,sp,-48
    800035ec:	f406                	sd	ra,40(sp)
    800035ee:	f022                	sd	s0,32(sp)
    800035f0:	ec26                	sd	s1,24(sp)
    800035f2:	e84a                	sd	s2,16(sp)
    800035f4:	e44e                	sd	s3,8(sp)
    800035f6:	e052                	sd	s4,0(sp)
    800035f8:	1800                	addi	s0,sp,48
    800035fa:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035fc:	47ad                	li	a5,11
    800035fe:	04b7fe63          	bgeu	a5,a1,8000365a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003602:	ff45849b          	addiw	s1,a1,-12
    80003606:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000360a:	0ff00793          	li	a5,255
    8000360e:	0ae7e363          	bltu	a5,a4,800036b4 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003612:	08852583          	lw	a1,136(a0)
    80003616:	c5ad                	beqz	a1,80003680 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003618:	00092503          	lw	a0,0(s2)
    8000361c:	00000097          	auipc	ra,0x0
    80003620:	bda080e7          	jalr	-1062(ra) # 800031f6 <bread>
    80003624:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003626:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    8000362a:	02049593          	slli	a1,s1,0x20
    8000362e:	9181                	srli	a1,a1,0x20
    80003630:	058a                	slli	a1,a1,0x2
    80003632:	00b784b3          	add	s1,a5,a1
    80003636:	0004a983          	lw	s3,0(s1)
    8000363a:	04098d63          	beqz	s3,80003694 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000363e:	8552                	mv	a0,s4
    80003640:	00000097          	auipc	ra,0x0
    80003644:	ce6080e7          	jalr	-794(ra) # 80003326 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003648:	854e                	mv	a0,s3
    8000364a:	70a2                	ld	ra,40(sp)
    8000364c:	7402                	ld	s0,32(sp)
    8000364e:	64e2                	ld	s1,24(sp)
    80003650:	6942                	ld	s2,16(sp)
    80003652:	69a2                	ld	s3,8(sp)
    80003654:	6a02                	ld	s4,0(sp)
    80003656:	6145                	addi	sp,sp,48
    80003658:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000365a:	02059493          	slli	s1,a1,0x20
    8000365e:	9081                	srli	s1,s1,0x20
    80003660:	048a                	slli	s1,s1,0x2
    80003662:	94aa                	add	s1,s1,a0
    80003664:	0584a983          	lw	s3,88(s1)
    80003668:	fe0990e3          	bnez	s3,80003648 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000366c:	4108                	lw	a0,0(a0)
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	e4a080e7          	jalr	-438(ra) # 800034b8 <balloc>
    80003676:	0005099b          	sext.w	s3,a0
    8000367a:	0534ac23          	sw	s3,88(s1)
    8000367e:	b7e9                	j	80003648 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003680:	4108                	lw	a0,0(a0)
    80003682:	00000097          	auipc	ra,0x0
    80003686:	e36080e7          	jalr	-458(ra) # 800034b8 <balloc>
    8000368a:	0005059b          	sext.w	a1,a0
    8000368e:	08b92423          	sw	a1,136(s2)
    80003692:	b759                	j	80003618 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003694:	00092503          	lw	a0,0(s2)
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	e20080e7          	jalr	-480(ra) # 800034b8 <balloc>
    800036a0:	0005099b          	sext.w	s3,a0
    800036a4:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800036a8:	8552                	mv	a0,s4
    800036aa:	00001097          	auipc	ra,0x1
    800036ae:	ee6080e7          	jalr	-282(ra) # 80004590 <log_write>
    800036b2:	b771                	j	8000363e <bmap+0x54>
  panic("bmap: out of range");
    800036b4:	00006517          	auipc	a0,0x6
    800036b8:	48c50513          	addi	a0,a0,1164 # 80009b40 <syscalls+0x128>
    800036bc:	ffffd097          	auipc	ra,0xffffd
    800036c0:	ea8080e7          	jalr	-344(ra) # 80000564 <panic>

00000000800036c4 <iget>:
{
    800036c4:	7179                	addi	sp,sp,-48
    800036c6:	f406                	sd	ra,40(sp)
    800036c8:	f022                	sd	s0,32(sp)
    800036ca:	ec26                	sd	s1,24(sp)
    800036cc:	e84a                	sd	s2,16(sp)
    800036ce:	e44e                	sd	s3,8(sp)
    800036d0:	e052                	sd	s4,0(sp)
    800036d2:	1800                	addi	s0,sp,48
    800036d4:	89aa                	mv	s3,a0
    800036d6:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800036d8:	00032517          	auipc	a0,0x32
    800036dc:	e3050513          	addi	a0,a0,-464 # 80035508 <icache>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	4b2080e7          	jalr	1202(ra) # 80000b92 <acquire>
  empty = 0;
    800036e8:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800036ea:	00032497          	auipc	s1,0x32
    800036ee:	e3e48493          	addi	s1,s1,-450 # 80035528 <icache+0x20>
    800036f2:	00034697          	auipc	a3,0x34
    800036f6:	a5668693          	addi	a3,a3,-1450 # 80037148 <log>
    800036fa:	a039                	j	80003708 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800036fc:	02090b63          	beqz	s2,80003732 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003700:	09048493          	addi	s1,s1,144
    80003704:	02d48a63          	beq	s1,a3,80003738 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003708:	449c                	lw	a5,8(s1)
    8000370a:	fef059e3          	blez	a5,800036fc <iget+0x38>
    8000370e:	4098                	lw	a4,0(s1)
    80003710:	ff3716e3          	bne	a4,s3,800036fc <iget+0x38>
    80003714:	40d8                	lw	a4,4(s1)
    80003716:	ff4713e3          	bne	a4,s4,800036fc <iget+0x38>
      ip->ref++;
    8000371a:	2785                	addiw	a5,a5,1
    8000371c:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000371e:	00032517          	auipc	a0,0x32
    80003722:	dea50513          	addi	a0,a0,-534 # 80035508 <icache>
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	53c080e7          	jalr	1340(ra) # 80000c62 <release>
      return ip;
    8000372e:	8926                	mv	s2,s1
    80003730:	a03d                	j	8000375e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003732:	f7f9                	bnez	a5,80003700 <iget+0x3c>
    80003734:	8926                	mv	s2,s1
    80003736:	b7e9                	j	80003700 <iget+0x3c>
  if(empty == 0)
    80003738:	02090c63          	beqz	s2,80003770 <iget+0xac>
  ip->dev = dev;
    8000373c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003740:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003744:	4785                	li	a5,1
    80003746:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000374a:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    8000374e:	00032517          	auipc	a0,0x32
    80003752:	dba50513          	addi	a0,a0,-582 # 80035508 <icache>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	50c080e7          	jalr	1292(ra) # 80000c62 <release>
}
    8000375e:	854a                	mv	a0,s2
    80003760:	70a2                	ld	ra,40(sp)
    80003762:	7402                	ld	s0,32(sp)
    80003764:	64e2                	ld	s1,24(sp)
    80003766:	6942                	ld	s2,16(sp)
    80003768:	69a2                	ld	s3,8(sp)
    8000376a:	6a02                	ld	s4,0(sp)
    8000376c:	6145                	addi	sp,sp,48
    8000376e:	8082                	ret
    panic("iget: no inodes");
    80003770:	00006517          	auipc	a0,0x6
    80003774:	3e850513          	addi	a0,a0,1000 # 80009b58 <syscalls+0x140>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	dec080e7          	jalr	-532(ra) # 80000564 <panic>

0000000080003780 <fsinit>:
fsinit(int dev) {
    80003780:	7179                	addi	sp,sp,-48
    80003782:	f406                	sd	ra,40(sp)
    80003784:	f022                	sd	s0,32(sp)
    80003786:	ec26                	sd	s1,24(sp)
    80003788:	e84a                	sd	s2,16(sp)
    8000378a:	e44e                	sd	s3,8(sp)
    8000378c:	1800                	addi	s0,sp,48
    8000378e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003790:	4585                	li	a1,1
    80003792:	00000097          	auipc	ra,0x0
    80003796:	a64080e7          	jalr	-1436(ra) # 800031f6 <bread>
    8000379a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000379c:	00032997          	auipc	s3,0x32
    800037a0:	d4c98993          	addi	s3,s3,-692 # 800354e8 <sb>
    800037a4:	02000613          	li	a2,32
    800037a8:	06050593          	addi	a1,a0,96
    800037ac:	854e                	mv	a0,s3
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	724080e7          	jalr	1828(ra) # 80000ed2 <memmove>
  brelse(bp);
    800037b6:	8526                	mv	a0,s1
    800037b8:	00000097          	auipc	ra,0x0
    800037bc:	b6e080e7          	jalr	-1170(ra) # 80003326 <brelse>
  if(sb.magic != FSMAGIC)
    800037c0:	0009a703          	lw	a4,0(s3)
    800037c4:	102037b7          	lui	a5,0x10203
    800037c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037cc:	02f71263          	bne	a4,a5,800037f0 <fsinit+0x70>
  initlog(dev, &sb);
    800037d0:	00032597          	auipc	a1,0x32
    800037d4:	d1858593          	addi	a1,a1,-744 # 800354e8 <sb>
    800037d8:	854a                	mv	a0,s2
    800037da:	00001097          	auipc	ra,0x1
    800037de:	b3e080e7          	jalr	-1218(ra) # 80004318 <initlog>
}
    800037e2:	70a2                	ld	ra,40(sp)
    800037e4:	7402                	ld	s0,32(sp)
    800037e6:	64e2                	ld	s1,24(sp)
    800037e8:	6942                	ld	s2,16(sp)
    800037ea:	69a2                	ld	s3,8(sp)
    800037ec:	6145                	addi	sp,sp,48
    800037ee:	8082                	ret
    panic("invalid file system");
    800037f0:	00006517          	auipc	a0,0x6
    800037f4:	37850513          	addi	a0,a0,888 # 80009b68 <syscalls+0x150>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	d6c080e7          	jalr	-660(ra) # 80000564 <panic>

0000000080003800 <iinit>:
{
    80003800:	7179                	addi	sp,sp,-48
    80003802:	f406                	sd	ra,40(sp)
    80003804:	f022                	sd	s0,32(sp)
    80003806:	ec26                	sd	s1,24(sp)
    80003808:	e84a                	sd	s2,16(sp)
    8000380a:	e44e                	sd	s3,8(sp)
    8000380c:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000380e:	00006597          	auipc	a1,0x6
    80003812:	37258593          	addi	a1,a1,882 # 80009b80 <syscalls+0x168>
    80003816:	00032517          	auipc	a0,0x32
    8000381a:	cf250513          	addi	a0,a0,-782 # 80035508 <icache>
    8000381e:	ffffd097          	auipc	ra,0xffffd
    80003822:	29e080e7          	jalr	670(ra) # 80000abc <initlock>
  for(i = 0; i < NINODE; i++) {
    80003826:	00032497          	auipc	s1,0x32
    8000382a:	d1248493          	addi	s1,s1,-750 # 80035538 <icache+0x30>
    8000382e:	00034997          	auipc	s3,0x34
    80003832:	92a98993          	addi	s3,s3,-1750 # 80037158 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003836:	00006917          	auipc	s2,0x6
    8000383a:	35290913          	addi	s2,s2,850 # 80009b88 <syscalls+0x170>
    8000383e:	85ca                	mv	a1,s2
    80003840:	8526                	mv	a0,s1
    80003842:	00001097          	auipc	ra,0x1
    80003846:	e34080e7          	jalr	-460(ra) # 80004676 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000384a:	09048493          	addi	s1,s1,144
    8000384e:	ff3498e3          	bne	s1,s3,8000383e <iinit+0x3e>
}
    80003852:	70a2                	ld	ra,40(sp)
    80003854:	7402                	ld	s0,32(sp)
    80003856:	64e2                	ld	s1,24(sp)
    80003858:	6942                	ld	s2,16(sp)
    8000385a:	69a2                	ld	s3,8(sp)
    8000385c:	6145                	addi	sp,sp,48
    8000385e:	8082                	ret

0000000080003860 <ialloc>:
{
    80003860:	715d                	addi	sp,sp,-80
    80003862:	e486                	sd	ra,72(sp)
    80003864:	e0a2                	sd	s0,64(sp)
    80003866:	fc26                	sd	s1,56(sp)
    80003868:	f84a                	sd	s2,48(sp)
    8000386a:	f44e                	sd	s3,40(sp)
    8000386c:	f052                	sd	s4,32(sp)
    8000386e:	ec56                	sd	s5,24(sp)
    80003870:	e85a                	sd	s6,16(sp)
    80003872:	e45e                	sd	s7,8(sp)
    80003874:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003876:	00032717          	auipc	a4,0x32
    8000387a:	c7e72703          	lw	a4,-898(a4) # 800354f4 <sb+0xc>
    8000387e:	4785                	li	a5,1
    80003880:	04e7fa63          	bgeu	a5,a4,800038d4 <ialloc+0x74>
    80003884:	8aaa                	mv	s5,a0
    80003886:	8bae                	mv	s7,a1
    80003888:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000388a:	00032a17          	auipc	s4,0x32
    8000388e:	c5ea0a13          	addi	s4,s4,-930 # 800354e8 <sb>
    80003892:	00048b1b          	sext.w	s6,s1
    80003896:	0044d793          	srli	a5,s1,0x4
    8000389a:	018a2583          	lw	a1,24(s4)
    8000389e:	9dbd                	addw	a1,a1,a5
    800038a0:	8556                	mv	a0,s5
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	954080e7          	jalr	-1708(ra) # 800031f6 <bread>
    800038aa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038ac:	06050993          	addi	s3,a0,96
    800038b0:	00f4f793          	andi	a5,s1,15
    800038b4:	079a                	slli	a5,a5,0x6
    800038b6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038b8:	00099783          	lh	a5,0(s3)
    800038bc:	c785                	beqz	a5,800038e4 <ialloc+0x84>
    brelse(bp);
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	a68080e7          	jalr	-1432(ra) # 80003326 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038c6:	0485                	addi	s1,s1,1
    800038c8:	00ca2703          	lw	a4,12(s4)
    800038cc:	0004879b          	sext.w	a5,s1
    800038d0:	fce7e1e3          	bltu	a5,a4,80003892 <ialloc+0x32>
  panic("ialloc: no inodes");
    800038d4:	00006517          	auipc	a0,0x6
    800038d8:	2bc50513          	addi	a0,a0,700 # 80009b90 <syscalls+0x178>
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	c88080e7          	jalr	-888(ra) # 80000564 <panic>
      memset(dip, 0, sizeof(*dip));
    800038e4:	04000613          	li	a2,64
    800038e8:	4581                	li	a1,0
    800038ea:	854e                	mv	a0,s3
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	58a080e7          	jalr	1418(ra) # 80000e76 <memset>
      dip->type = type;
    800038f4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800038f8:	854a                	mv	a0,s2
    800038fa:	00001097          	auipc	ra,0x1
    800038fe:	c96080e7          	jalr	-874(ra) # 80004590 <log_write>
      brelse(bp);
    80003902:	854a                	mv	a0,s2
    80003904:	00000097          	auipc	ra,0x0
    80003908:	a22080e7          	jalr	-1502(ra) # 80003326 <brelse>
      return iget(dev, inum);
    8000390c:	85da                	mv	a1,s6
    8000390e:	8556                	mv	a0,s5
    80003910:	00000097          	auipc	ra,0x0
    80003914:	db4080e7          	jalr	-588(ra) # 800036c4 <iget>
}
    80003918:	60a6                	ld	ra,72(sp)
    8000391a:	6406                	ld	s0,64(sp)
    8000391c:	74e2                	ld	s1,56(sp)
    8000391e:	7942                	ld	s2,48(sp)
    80003920:	79a2                	ld	s3,40(sp)
    80003922:	7a02                	ld	s4,32(sp)
    80003924:	6ae2                	ld	s5,24(sp)
    80003926:	6b42                	ld	s6,16(sp)
    80003928:	6ba2                	ld	s7,8(sp)
    8000392a:	6161                	addi	sp,sp,80
    8000392c:	8082                	ret

000000008000392e <iupdate>:
{
    8000392e:	1101                	addi	sp,sp,-32
    80003930:	ec06                	sd	ra,24(sp)
    80003932:	e822                	sd	s0,16(sp)
    80003934:	e426                	sd	s1,8(sp)
    80003936:	e04a                	sd	s2,0(sp)
    80003938:	1000                	addi	s0,sp,32
    8000393a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000393c:	415c                	lw	a5,4(a0)
    8000393e:	0047d79b          	srliw	a5,a5,0x4
    80003942:	00032597          	auipc	a1,0x32
    80003946:	bbe5a583          	lw	a1,-1090(a1) # 80035500 <sb+0x18>
    8000394a:	9dbd                	addw	a1,a1,a5
    8000394c:	4108                	lw	a0,0(a0)
    8000394e:	00000097          	auipc	ra,0x0
    80003952:	8a8080e7          	jalr	-1880(ra) # 800031f6 <bread>
    80003956:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003958:	06050793          	addi	a5,a0,96
    8000395c:	40c8                	lw	a0,4(s1)
    8000395e:	893d                	andi	a0,a0,15
    80003960:	051a                	slli	a0,a0,0x6
    80003962:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003964:	04c49703          	lh	a4,76(s1)
    80003968:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000396c:	04e49703          	lh	a4,78(s1)
    80003970:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003974:	05049703          	lh	a4,80(s1)
    80003978:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000397c:	05249703          	lh	a4,82(s1)
    80003980:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003984:	48f8                	lw	a4,84(s1)
    80003986:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003988:	03400613          	li	a2,52
    8000398c:	05848593          	addi	a1,s1,88
    80003990:	0531                	addi	a0,a0,12
    80003992:	ffffd097          	auipc	ra,0xffffd
    80003996:	540080e7          	jalr	1344(ra) # 80000ed2 <memmove>
  log_write(bp);
    8000399a:	854a                	mv	a0,s2
    8000399c:	00001097          	auipc	ra,0x1
    800039a0:	bf4080e7          	jalr	-1036(ra) # 80004590 <log_write>
  brelse(bp);
    800039a4:	854a                	mv	a0,s2
    800039a6:	00000097          	auipc	ra,0x0
    800039aa:	980080e7          	jalr	-1664(ra) # 80003326 <brelse>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6902                	ld	s2,0(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret

00000000800039ba <idup>:
{
    800039ba:	1101                	addi	sp,sp,-32
    800039bc:	ec06                	sd	ra,24(sp)
    800039be:	e822                	sd	s0,16(sp)
    800039c0:	e426                	sd	s1,8(sp)
    800039c2:	1000                	addi	s0,sp,32
    800039c4:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039c6:	00032517          	auipc	a0,0x32
    800039ca:	b4250513          	addi	a0,a0,-1214 # 80035508 <icache>
    800039ce:	ffffd097          	auipc	ra,0xffffd
    800039d2:	1c4080e7          	jalr	452(ra) # 80000b92 <acquire>
  ip->ref++;
    800039d6:	449c                	lw	a5,8(s1)
    800039d8:	2785                	addiw	a5,a5,1
    800039da:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039dc:	00032517          	auipc	a0,0x32
    800039e0:	b2c50513          	addi	a0,a0,-1236 # 80035508 <icache>
    800039e4:	ffffd097          	auipc	ra,0xffffd
    800039e8:	27e080e7          	jalr	638(ra) # 80000c62 <release>
}
    800039ec:	8526                	mv	a0,s1
    800039ee:	60e2                	ld	ra,24(sp)
    800039f0:	6442                	ld	s0,16(sp)
    800039f2:	64a2                	ld	s1,8(sp)
    800039f4:	6105                	addi	sp,sp,32
    800039f6:	8082                	ret

00000000800039f8 <ilock>:
{
    800039f8:	1101                	addi	sp,sp,-32
    800039fa:	ec06                	sd	ra,24(sp)
    800039fc:	e822                	sd	s0,16(sp)
    800039fe:	e426                	sd	s1,8(sp)
    80003a00:	e04a                	sd	s2,0(sp)
    80003a02:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a04:	c115                	beqz	a0,80003a28 <ilock+0x30>
    80003a06:	84aa                	mv	s1,a0
    80003a08:	451c                	lw	a5,8(a0)
    80003a0a:	00f05f63          	blez	a5,80003a28 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a0e:	0541                	addi	a0,a0,16
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	ca0080e7          	jalr	-864(ra) # 800046b0 <acquiresleep>
  if(ip->valid == 0){
    80003a18:	44bc                	lw	a5,72(s1)
    80003a1a:	cf99                	beqz	a5,80003a38 <ilock+0x40>
}
    80003a1c:	60e2                	ld	ra,24(sp)
    80003a1e:	6442                	ld	s0,16(sp)
    80003a20:	64a2                	ld	s1,8(sp)
    80003a22:	6902                	ld	s2,0(sp)
    80003a24:	6105                	addi	sp,sp,32
    80003a26:	8082                	ret
    panic("ilock");
    80003a28:	00006517          	auipc	a0,0x6
    80003a2c:	18050513          	addi	a0,a0,384 # 80009ba8 <syscalls+0x190>
    80003a30:	ffffd097          	auipc	ra,0xffffd
    80003a34:	b34080e7          	jalr	-1228(ra) # 80000564 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a38:	40dc                	lw	a5,4(s1)
    80003a3a:	0047d79b          	srliw	a5,a5,0x4
    80003a3e:	00032597          	auipc	a1,0x32
    80003a42:	ac25a583          	lw	a1,-1342(a1) # 80035500 <sb+0x18>
    80003a46:	9dbd                	addw	a1,a1,a5
    80003a48:	4088                	lw	a0,0(s1)
    80003a4a:	fffff097          	auipc	ra,0xfffff
    80003a4e:	7ac080e7          	jalr	1964(ra) # 800031f6 <bread>
    80003a52:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a54:	06050593          	addi	a1,a0,96
    80003a58:	40dc                	lw	a5,4(s1)
    80003a5a:	8bbd                	andi	a5,a5,15
    80003a5c:	079a                	slli	a5,a5,0x6
    80003a5e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a60:	00059783          	lh	a5,0(a1)
    80003a64:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    80003a68:	00259783          	lh	a5,2(a1)
    80003a6c:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003a70:	00459783          	lh	a5,4(a1)
    80003a74:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    80003a78:	00659783          	lh	a5,6(a1)
    80003a7c:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003a80:	459c                	lw	a5,8(a1)
    80003a82:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003a84:	03400613          	li	a2,52
    80003a88:	05b1                	addi	a1,a1,12
    80003a8a:	05848513          	addi	a0,s1,88
    80003a8e:	ffffd097          	auipc	ra,0xffffd
    80003a92:	444080e7          	jalr	1092(ra) # 80000ed2 <memmove>
    brelse(bp);
    80003a96:	854a                	mv	a0,s2
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	88e080e7          	jalr	-1906(ra) # 80003326 <brelse>
    ip->valid = 1;
    80003aa0:	4785                	li	a5,1
    80003aa2:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003aa4:	04c49783          	lh	a5,76(s1)
    80003aa8:	fbb5                	bnez	a5,80003a1c <ilock+0x24>
      panic("ilock: no type");
    80003aaa:	00006517          	auipc	a0,0x6
    80003aae:	10650513          	addi	a0,a0,262 # 80009bb0 <syscalls+0x198>
    80003ab2:	ffffd097          	auipc	ra,0xffffd
    80003ab6:	ab2080e7          	jalr	-1358(ra) # 80000564 <panic>

0000000080003aba <iunlock>:
{
    80003aba:	1101                	addi	sp,sp,-32
    80003abc:	ec06                	sd	ra,24(sp)
    80003abe:	e822                	sd	s0,16(sp)
    80003ac0:	e426                	sd	s1,8(sp)
    80003ac2:	e04a                	sd	s2,0(sp)
    80003ac4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ac6:	c905                	beqz	a0,80003af6 <iunlock+0x3c>
    80003ac8:	84aa                	mv	s1,a0
    80003aca:	01050913          	addi	s2,a0,16
    80003ace:	854a                	mv	a0,s2
    80003ad0:	00001097          	auipc	ra,0x1
    80003ad4:	c7a080e7          	jalr	-902(ra) # 8000474a <holdingsleep>
    80003ad8:	cd19                	beqz	a0,80003af6 <iunlock+0x3c>
    80003ada:	449c                	lw	a5,8(s1)
    80003adc:	00f05d63          	blez	a5,80003af6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003ae0:	854a                	mv	a0,s2
    80003ae2:	00001097          	auipc	ra,0x1
    80003ae6:	c24080e7          	jalr	-988(ra) # 80004706 <releasesleep>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	64a2                	ld	s1,8(sp)
    80003af0:	6902                	ld	s2,0(sp)
    80003af2:	6105                	addi	sp,sp,32
    80003af4:	8082                	ret
    panic("iunlock");
    80003af6:	00006517          	auipc	a0,0x6
    80003afa:	0ca50513          	addi	a0,a0,202 # 80009bc0 <syscalls+0x1a8>
    80003afe:	ffffd097          	auipc	ra,0xffffd
    80003b02:	a66080e7          	jalr	-1434(ra) # 80000564 <panic>

0000000080003b06 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b06:	7179                	addi	sp,sp,-48
    80003b08:	f406                	sd	ra,40(sp)
    80003b0a:	f022                	sd	s0,32(sp)
    80003b0c:	ec26                	sd	s1,24(sp)
    80003b0e:	e84a                	sd	s2,16(sp)
    80003b10:	e44e                	sd	s3,8(sp)
    80003b12:	e052                	sd	s4,0(sp)
    80003b14:	1800                	addi	s0,sp,48
    80003b16:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b18:	05850493          	addi	s1,a0,88
    80003b1c:	08850913          	addi	s2,a0,136
    80003b20:	a021                	j	80003b28 <itrunc+0x22>
    80003b22:	0491                	addi	s1,s1,4
    80003b24:	01248d63          	beq	s1,s2,80003b3e <itrunc+0x38>
    if(ip->addrs[i]){
    80003b28:	408c                	lw	a1,0(s1)
    80003b2a:	dde5                	beqz	a1,80003b22 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b2c:	0009a503          	lw	a0,0(s3)
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	90c080e7          	jalr	-1780(ra) # 8000343c <bfree>
      ip->addrs[i] = 0;
    80003b38:	0004a023          	sw	zero,0(s1)
    80003b3c:	b7dd                	j	80003b22 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b3e:	0889a583          	lw	a1,136(s3)
    80003b42:	e185                	bnez	a1,80003b62 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b44:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    80003b48:	854e                	mv	a0,s3
    80003b4a:	00000097          	auipc	ra,0x0
    80003b4e:	de4080e7          	jalr	-540(ra) # 8000392e <iupdate>
}
    80003b52:	70a2                	ld	ra,40(sp)
    80003b54:	7402                	ld	s0,32(sp)
    80003b56:	64e2                	ld	s1,24(sp)
    80003b58:	6942                	ld	s2,16(sp)
    80003b5a:	69a2                	ld	s3,8(sp)
    80003b5c:	6a02                	ld	s4,0(sp)
    80003b5e:	6145                	addi	sp,sp,48
    80003b60:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b62:	0009a503          	lw	a0,0(s3)
    80003b66:	fffff097          	auipc	ra,0xfffff
    80003b6a:	690080e7          	jalr	1680(ra) # 800031f6 <bread>
    80003b6e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b70:	06050493          	addi	s1,a0,96
    80003b74:	46050913          	addi	s2,a0,1120
    80003b78:	a021                	j	80003b80 <itrunc+0x7a>
    80003b7a:	0491                	addi	s1,s1,4
    80003b7c:	01248b63          	beq	s1,s2,80003b92 <itrunc+0x8c>
      if(a[j])
    80003b80:	408c                	lw	a1,0(s1)
    80003b82:	dde5                	beqz	a1,80003b7a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003b84:	0009a503          	lw	a0,0(s3)
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	8b4080e7          	jalr	-1868(ra) # 8000343c <bfree>
    80003b90:	b7ed                	j	80003b7a <itrunc+0x74>
    brelse(bp);
    80003b92:	8552                	mv	a0,s4
    80003b94:	fffff097          	auipc	ra,0xfffff
    80003b98:	792080e7          	jalr	1938(ra) # 80003326 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b9c:	0889a583          	lw	a1,136(s3)
    80003ba0:	0009a503          	lw	a0,0(s3)
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	898080e7          	jalr	-1896(ra) # 8000343c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bac:	0809a423          	sw	zero,136(s3)
    80003bb0:	bf51                	j	80003b44 <itrunc+0x3e>

0000000080003bb2 <iput>:
{
    80003bb2:	1101                	addi	sp,sp,-32
    80003bb4:	ec06                	sd	ra,24(sp)
    80003bb6:	e822                	sd	s0,16(sp)
    80003bb8:	e426                	sd	s1,8(sp)
    80003bba:	e04a                	sd	s2,0(sp)
    80003bbc:	1000                	addi	s0,sp,32
    80003bbe:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003bc0:	00032517          	auipc	a0,0x32
    80003bc4:	94850513          	addi	a0,a0,-1720 # 80035508 <icache>
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	fca080e7          	jalr	-54(ra) # 80000b92 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bd0:	4498                	lw	a4,8(s1)
    80003bd2:	4785                	li	a5,1
    80003bd4:	02f70363          	beq	a4,a5,80003bfa <iput+0x48>
  ip->ref--;
    80003bd8:	449c                	lw	a5,8(s1)
    80003bda:	37fd                	addiw	a5,a5,-1
    80003bdc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003bde:	00032517          	auipc	a0,0x32
    80003be2:	92a50513          	addi	a0,a0,-1750 # 80035508 <icache>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	07c080e7          	jalr	124(ra) # 80000c62 <release>
}
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	64a2                	ld	s1,8(sp)
    80003bf4:	6902                	ld	s2,0(sp)
    80003bf6:	6105                	addi	sp,sp,32
    80003bf8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bfa:	44bc                	lw	a5,72(s1)
    80003bfc:	dff1                	beqz	a5,80003bd8 <iput+0x26>
    80003bfe:	05249783          	lh	a5,82(s1)
    80003c02:	fbf9                	bnez	a5,80003bd8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003c04:	01048913          	addi	s2,s1,16
    80003c08:	854a                	mv	a0,s2
    80003c0a:	00001097          	auipc	ra,0x1
    80003c0e:	aa6080e7          	jalr	-1370(ra) # 800046b0 <acquiresleep>
    release(&icache.lock);
    80003c12:	00032517          	auipc	a0,0x32
    80003c16:	8f650513          	addi	a0,a0,-1802 # 80035508 <icache>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	048080e7          	jalr	72(ra) # 80000c62 <release>
    itrunc(ip);
    80003c22:	8526                	mv	a0,s1
    80003c24:	00000097          	auipc	ra,0x0
    80003c28:	ee2080e7          	jalr	-286(ra) # 80003b06 <itrunc>
    ip->type = 0;
    80003c2c:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003c30:	8526                	mv	a0,s1
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	cfc080e7          	jalr	-772(ra) # 8000392e <iupdate>
    ip->valid = 0;
    80003c3a:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003c3e:	854a                	mv	a0,s2
    80003c40:	00001097          	auipc	ra,0x1
    80003c44:	ac6080e7          	jalr	-1338(ra) # 80004706 <releasesleep>
    acquire(&icache.lock);
    80003c48:	00032517          	auipc	a0,0x32
    80003c4c:	8c050513          	addi	a0,a0,-1856 # 80035508 <icache>
    80003c50:	ffffd097          	auipc	ra,0xffffd
    80003c54:	f42080e7          	jalr	-190(ra) # 80000b92 <acquire>
    80003c58:	b741                	j	80003bd8 <iput+0x26>

0000000080003c5a <iunlockput>:
{
    80003c5a:	1101                	addi	sp,sp,-32
    80003c5c:	ec06                	sd	ra,24(sp)
    80003c5e:	e822                	sd	s0,16(sp)
    80003c60:	e426                	sd	s1,8(sp)
    80003c62:	1000                	addi	s0,sp,32
    80003c64:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c66:	00000097          	auipc	ra,0x0
    80003c6a:	e54080e7          	jalr	-428(ra) # 80003aba <iunlock>
  iput(ip);
    80003c6e:	8526                	mv	a0,s1
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	f42080e7          	jalr	-190(ra) # 80003bb2 <iput>
}
    80003c78:	60e2                	ld	ra,24(sp)
    80003c7a:	6442                	ld	s0,16(sp)
    80003c7c:	64a2                	ld	s1,8(sp)
    80003c7e:	6105                	addi	sp,sp,32
    80003c80:	8082                	ret

0000000080003c82 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003c82:	1141                	addi	sp,sp,-16
    80003c84:	e422                	sd	s0,8(sp)
    80003c86:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003c88:	411c                	lw	a5,0(a0)
    80003c8a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003c8c:	415c                	lw	a5,4(a0)
    80003c8e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c90:	04c51783          	lh	a5,76(a0)
    80003c94:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c98:	05251783          	lh	a5,82(a0)
    80003c9c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003ca0:	05456783          	lwu	a5,84(a0)
    80003ca4:	e99c                	sd	a5,16(a1)
}
    80003ca6:	6422                	ld	s0,8(sp)
    80003ca8:	0141                	addi	sp,sp,16
    80003caa:	8082                	ret

0000000080003cac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cac:	497c                	lw	a5,84(a0)
    80003cae:	0ed7e963          	bltu	a5,a3,80003da0 <readi+0xf4>
{
    80003cb2:	7159                	addi	sp,sp,-112
    80003cb4:	f486                	sd	ra,104(sp)
    80003cb6:	f0a2                	sd	s0,96(sp)
    80003cb8:	eca6                	sd	s1,88(sp)
    80003cba:	e8ca                	sd	s2,80(sp)
    80003cbc:	e4ce                	sd	s3,72(sp)
    80003cbe:	e0d2                	sd	s4,64(sp)
    80003cc0:	fc56                	sd	s5,56(sp)
    80003cc2:	f85a                	sd	s6,48(sp)
    80003cc4:	f45e                	sd	s7,40(sp)
    80003cc6:	f062                	sd	s8,32(sp)
    80003cc8:	ec66                	sd	s9,24(sp)
    80003cca:	e86a                	sd	s10,16(sp)
    80003ccc:	e46e                	sd	s11,8(sp)
    80003cce:	1880                	addi	s0,sp,112
    80003cd0:	8baa                	mv	s7,a0
    80003cd2:	8c2e                	mv	s8,a1
    80003cd4:	8ab2                	mv	s5,a2
    80003cd6:	84b6                	mv	s1,a3
    80003cd8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cda:	9f35                	addw	a4,a4,a3
    return 0;
    80003cdc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003cde:	0ad76063          	bltu	a4,a3,80003d7e <readi+0xd2>
  if(off + n > ip->size)
    80003ce2:	00e7f463          	bgeu	a5,a4,80003cea <readi+0x3e>
    n = ip->size - off;
    80003ce6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cea:	0a0b0963          	beqz	s6,80003d9c <readi+0xf0>
    80003cee:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cf0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003cf4:	5cfd                	li	s9,-1
    80003cf6:	a82d                	j	80003d30 <readi+0x84>
    80003cf8:	020a1d93          	slli	s11,s4,0x20
    80003cfc:	020ddd93          	srli	s11,s11,0x20
    80003d00:	06090793          	addi	a5,s2,96
    80003d04:	86ee                	mv	a3,s11
    80003d06:	963e                	add	a2,a2,a5
    80003d08:	85d6                	mv	a1,s5
    80003d0a:	8562                	mv	a0,s8
    80003d0c:	fffff097          	auipc	ra,0xfffff
    80003d10:	a6c080e7          	jalr	-1428(ra) # 80002778 <either_copyout>
    80003d14:	05950d63          	beq	a0,s9,80003d6e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d18:	854a                	mv	a0,s2
    80003d1a:	fffff097          	auipc	ra,0xfffff
    80003d1e:	60c080e7          	jalr	1548(ra) # 80003326 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d22:	013a09bb          	addw	s3,s4,s3
    80003d26:	009a04bb          	addw	s1,s4,s1
    80003d2a:	9aee                	add	s5,s5,s11
    80003d2c:	0569f763          	bgeu	s3,s6,80003d7a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003d30:	000ba903          	lw	s2,0(s7)
    80003d34:	00a4d59b          	srliw	a1,s1,0xa
    80003d38:	855e                	mv	a0,s7
    80003d3a:	00000097          	auipc	ra,0x0
    80003d3e:	8b0080e7          	jalr	-1872(ra) # 800035ea <bmap>
    80003d42:	0005059b          	sext.w	a1,a0
    80003d46:	854a                	mv	a0,s2
    80003d48:	fffff097          	auipc	ra,0xfffff
    80003d4c:	4ae080e7          	jalr	1198(ra) # 800031f6 <bread>
    80003d50:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d52:	3ff4f613          	andi	a2,s1,1023
    80003d56:	40cd07bb          	subw	a5,s10,a2
    80003d5a:	413b073b          	subw	a4,s6,s3
    80003d5e:	8a3e                	mv	s4,a5
    80003d60:	2781                	sext.w	a5,a5
    80003d62:	0007069b          	sext.w	a3,a4
    80003d66:	f8f6f9e3          	bgeu	a3,a5,80003cf8 <readi+0x4c>
    80003d6a:	8a3a                	mv	s4,a4
    80003d6c:	b771                	j	80003cf8 <readi+0x4c>
      brelse(bp);
    80003d6e:	854a                	mv	a0,s2
    80003d70:	fffff097          	auipc	ra,0xfffff
    80003d74:	5b6080e7          	jalr	1462(ra) # 80003326 <brelse>
      tot = -1;
    80003d78:	59fd                	li	s3,-1
  }
  return tot;
    80003d7a:	0009851b          	sext.w	a0,s3
}
    80003d7e:	70a6                	ld	ra,104(sp)
    80003d80:	7406                	ld	s0,96(sp)
    80003d82:	64e6                	ld	s1,88(sp)
    80003d84:	6946                	ld	s2,80(sp)
    80003d86:	69a6                	ld	s3,72(sp)
    80003d88:	6a06                	ld	s4,64(sp)
    80003d8a:	7ae2                	ld	s5,56(sp)
    80003d8c:	7b42                	ld	s6,48(sp)
    80003d8e:	7ba2                	ld	s7,40(sp)
    80003d90:	7c02                	ld	s8,32(sp)
    80003d92:	6ce2                	ld	s9,24(sp)
    80003d94:	6d42                	ld	s10,16(sp)
    80003d96:	6da2                	ld	s11,8(sp)
    80003d98:	6165                	addi	sp,sp,112
    80003d9a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d9c:	89da                	mv	s3,s6
    80003d9e:	bff1                	j	80003d7a <readi+0xce>
    return 0;
    80003da0:	4501                	li	a0,0
}
    80003da2:	8082                	ret

0000000080003da4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003da4:	497c                	lw	a5,84(a0)
    80003da6:	10d7e863          	bltu	a5,a3,80003eb6 <writei+0x112>
{
    80003daa:	7159                	addi	sp,sp,-112
    80003dac:	f486                	sd	ra,104(sp)
    80003dae:	f0a2                	sd	s0,96(sp)
    80003db0:	eca6                	sd	s1,88(sp)
    80003db2:	e8ca                	sd	s2,80(sp)
    80003db4:	e4ce                	sd	s3,72(sp)
    80003db6:	e0d2                	sd	s4,64(sp)
    80003db8:	fc56                	sd	s5,56(sp)
    80003dba:	f85a                	sd	s6,48(sp)
    80003dbc:	f45e                	sd	s7,40(sp)
    80003dbe:	f062                	sd	s8,32(sp)
    80003dc0:	ec66                	sd	s9,24(sp)
    80003dc2:	e86a                	sd	s10,16(sp)
    80003dc4:	e46e                	sd	s11,8(sp)
    80003dc6:	1880                	addi	s0,sp,112
    80003dc8:	8b2a                	mv	s6,a0
    80003dca:	8c2e                	mv	s8,a1
    80003dcc:	8ab2                	mv	s5,a2
    80003dce:	8936                	mv	s2,a3
    80003dd0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003dd2:	00e687bb          	addw	a5,a3,a4
    80003dd6:	0ed7e263          	bltu	a5,a3,80003eba <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dda:	00043737          	lui	a4,0x43
    80003dde:	0ef76063          	bltu	a4,a5,80003ebe <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003de2:	0c0b8863          	beqz	s7,80003eb2 <writei+0x10e>
    80003de6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003dec:	5cfd                	li	s9,-1
    80003dee:	a091                	j	80003e32 <writei+0x8e>
    80003df0:	02099d93          	slli	s11,s3,0x20
    80003df4:	020ddd93          	srli	s11,s11,0x20
    80003df8:	06048793          	addi	a5,s1,96
    80003dfc:	86ee                	mv	a3,s11
    80003dfe:	8656                	mv	a2,s5
    80003e00:	85e2                	mv	a1,s8
    80003e02:	953e                	add	a0,a0,a5
    80003e04:	fffff097          	auipc	ra,0xfffff
    80003e08:	9ca080e7          	jalr	-1590(ra) # 800027ce <either_copyin>
    80003e0c:	07950263          	beq	a0,s9,80003e70 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e10:	8526                	mv	a0,s1
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	77e080e7          	jalr	1918(ra) # 80004590 <log_write>
    brelse(bp);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	50a080e7          	jalr	1290(ra) # 80003326 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e24:	01498a3b          	addw	s4,s3,s4
    80003e28:	0129893b          	addw	s2,s3,s2
    80003e2c:	9aee                	add	s5,s5,s11
    80003e2e:	057a7663          	bgeu	s4,s7,80003e7a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e32:	000b2483          	lw	s1,0(s6)
    80003e36:	00a9559b          	srliw	a1,s2,0xa
    80003e3a:	855a                	mv	a0,s6
    80003e3c:	fffff097          	auipc	ra,0xfffff
    80003e40:	7ae080e7          	jalr	1966(ra) # 800035ea <bmap>
    80003e44:	0005059b          	sext.w	a1,a0
    80003e48:	8526                	mv	a0,s1
    80003e4a:	fffff097          	auipc	ra,0xfffff
    80003e4e:	3ac080e7          	jalr	940(ra) # 800031f6 <bread>
    80003e52:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e54:	3ff97513          	andi	a0,s2,1023
    80003e58:	40ad07bb          	subw	a5,s10,a0
    80003e5c:	414b873b          	subw	a4,s7,s4
    80003e60:	89be                	mv	s3,a5
    80003e62:	2781                	sext.w	a5,a5
    80003e64:	0007069b          	sext.w	a3,a4
    80003e68:	f8f6f4e3          	bgeu	a3,a5,80003df0 <writei+0x4c>
    80003e6c:	89ba                	mv	s3,a4
    80003e6e:	b749                	j	80003df0 <writei+0x4c>
      brelse(bp);
    80003e70:	8526                	mv	a0,s1
    80003e72:	fffff097          	auipc	ra,0xfffff
    80003e76:	4b4080e7          	jalr	1204(ra) # 80003326 <brelse>
  }

  if(off > ip->size)
    80003e7a:	054b2783          	lw	a5,84(s6)
    80003e7e:	0127f463          	bgeu	a5,s2,80003e86 <writei+0xe2>
    ip->size = off;
    80003e82:	052b2a23          	sw	s2,84(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003e86:	855a                	mv	a0,s6
    80003e88:	00000097          	auipc	ra,0x0
    80003e8c:	aa6080e7          	jalr	-1370(ra) # 8000392e <iupdate>

  return tot;
    80003e90:	000a051b          	sext.w	a0,s4
}
    80003e94:	70a6                	ld	ra,104(sp)
    80003e96:	7406                	ld	s0,96(sp)
    80003e98:	64e6                	ld	s1,88(sp)
    80003e9a:	6946                	ld	s2,80(sp)
    80003e9c:	69a6                	ld	s3,72(sp)
    80003e9e:	6a06                	ld	s4,64(sp)
    80003ea0:	7ae2                	ld	s5,56(sp)
    80003ea2:	7b42                	ld	s6,48(sp)
    80003ea4:	7ba2                	ld	s7,40(sp)
    80003ea6:	7c02                	ld	s8,32(sp)
    80003ea8:	6ce2                	ld	s9,24(sp)
    80003eaa:	6d42                	ld	s10,16(sp)
    80003eac:	6da2                	ld	s11,8(sp)
    80003eae:	6165                	addi	sp,sp,112
    80003eb0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eb2:	8a5e                	mv	s4,s7
    80003eb4:	bfc9                	j	80003e86 <writei+0xe2>
    return -1;
    80003eb6:	557d                	li	a0,-1
}
    80003eb8:	8082                	ret
    return -1;
    80003eba:	557d                	li	a0,-1
    80003ebc:	bfe1                	j	80003e94 <writei+0xf0>
    return -1;
    80003ebe:	557d                	li	a0,-1
    80003ec0:	bfd1                	j	80003e94 <writei+0xf0>

0000000080003ec2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ec2:	1141                	addi	sp,sp,-16
    80003ec4:	e406                	sd	ra,8(sp)
    80003ec6:	e022                	sd	s0,0(sp)
    80003ec8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eca:	4639                	li	a2,14
    80003ecc:	ffffd097          	auipc	ra,0xffffd
    80003ed0:	0a6080e7          	jalr	166(ra) # 80000f72 <strncmp>
}
    80003ed4:	60a2                	ld	ra,8(sp)
    80003ed6:	6402                	ld	s0,0(sp)
    80003ed8:	0141                	addi	sp,sp,16
    80003eda:	8082                	ret

0000000080003edc <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003edc:	7139                	addi	sp,sp,-64
    80003ede:	fc06                	sd	ra,56(sp)
    80003ee0:	f822                	sd	s0,48(sp)
    80003ee2:	f426                	sd	s1,40(sp)
    80003ee4:	f04a                	sd	s2,32(sp)
    80003ee6:	ec4e                	sd	s3,24(sp)
    80003ee8:	e852                	sd	s4,16(sp)
    80003eea:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003eec:	04c51703          	lh	a4,76(a0)
    80003ef0:	4785                	li	a5,1
    80003ef2:	00f71a63          	bne	a4,a5,80003f06 <dirlookup+0x2a>
    80003ef6:	892a                	mv	s2,a0
    80003ef8:	89ae                	mv	s3,a1
    80003efa:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003efc:	497c                	lw	a5,84(a0)
    80003efe:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f00:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f02:	e79d                	bnez	a5,80003f30 <dirlookup+0x54>
    80003f04:	a8a5                	j	80003f7c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f06:	00006517          	auipc	a0,0x6
    80003f0a:	cc250513          	addi	a0,a0,-830 # 80009bc8 <syscalls+0x1b0>
    80003f0e:	ffffc097          	auipc	ra,0xffffc
    80003f12:	656080e7          	jalr	1622(ra) # 80000564 <panic>
      panic("dirlookup read");
    80003f16:	00006517          	auipc	a0,0x6
    80003f1a:	cca50513          	addi	a0,a0,-822 # 80009be0 <syscalls+0x1c8>
    80003f1e:	ffffc097          	auipc	ra,0xffffc
    80003f22:	646080e7          	jalr	1606(ra) # 80000564 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f26:	24c1                	addiw	s1,s1,16
    80003f28:	05492783          	lw	a5,84(s2)
    80003f2c:	04f4f763          	bgeu	s1,a5,80003f7a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f30:	4741                	li	a4,16
    80003f32:	86a6                	mv	a3,s1
    80003f34:	fc040613          	addi	a2,s0,-64
    80003f38:	4581                	li	a1,0
    80003f3a:	854a                	mv	a0,s2
    80003f3c:	00000097          	auipc	ra,0x0
    80003f40:	d70080e7          	jalr	-656(ra) # 80003cac <readi>
    80003f44:	47c1                	li	a5,16
    80003f46:	fcf518e3          	bne	a0,a5,80003f16 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f4a:	fc045783          	lhu	a5,-64(s0)
    80003f4e:	dfe1                	beqz	a5,80003f26 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f50:	fc240593          	addi	a1,s0,-62
    80003f54:	854e                	mv	a0,s3
    80003f56:	00000097          	auipc	ra,0x0
    80003f5a:	f6c080e7          	jalr	-148(ra) # 80003ec2 <namecmp>
    80003f5e:	f561                	bnez	a0,80003f26 <dirlookup+0x4a>
      if(poff)
    80003f60:	000a0463          	beqz	s4,80003f68 <dirlookup+0x8c>
        *poff = off;
    80003f64:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f68:	fc045583          	lhu	a1,-64(s0)
    80003f6c:	00092503          	lw	a0,0(s2)
    80003f70:	fffff097          	auipc	ra,0xfffff
    80003f74:	754080e7          	jalr	1876(ra) # 800036c4 <iget>
    80003f78:	a011                	j	80003f7c <dirlookup+0xa0>
  return 0;
    80003f7a:	4501                	li	a0,0
}
    80003f7c:	70e2                	ld	ra,56(sp)
    80003f7e:	7442                	ld	s0,48(sp)
    80003f80:	74a2                	ld	s1,40(sp)
    80003f82:	7902                	ld	s2,32(sp)
    80003f84:	69e2                	ld	s3,24(sp)
    80003f86:	6a42                	ld	s4,16(sp)
    80003f88:	6121                	addi	sp,sp,64
    80003f8a:	8082                	ret

0000000080003f8c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003f8c:	711d                	addi	sp,sp,-96
    80003f8e:	ec86                	sd	ra,88(sp)
    80003f90:	e8a2                	sd	s0,80(sp)
    80003f92:	e4a6                	sd	s1,72(sp)
    80003f94:	e0ca                	sd	s2,64(sp)
    80003f96:	fc4e                	sd	s3,56(sp)
    80003f98:	f852                	sd	s4,48(sp)
    80003f9a:	f456                	sd	s5,40(sp)
    80003f9c:	f05a                	sd	s6,32(sp)
    80003f9e:	ec5e                	sd	s7,24(sp)
    80003fa0:	e862                	sd	s8,16(sp)
    80003fa2:	e466                	sd	s9,8(sp)
    80003fa4:	1080                	addi	s0,sp,96
    80003fa6:	84aa                	mv	s1,a0
    80003fa8:	8aae                	mv	s5,a1
    80003faa:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fac:	00054703          	lbu	a4,0(a0)
    80003fb0:	02f00793          	li	a5,47
    80003fb4:	02f70363          	beq	a4,a5,80003fda <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fb8:	ffffe097          	auipc	ra,0xffffe
    80003fbc:	b98080e7          	jalr	-1128(ra) # 80001b50 <myproc>
    80003fc0:	15853503          	ld	a0,344(a0)
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	9f6080e7          	jalr	-1546(ra) # 800039ba <idup>
    80003fcc:	89aa                	mv	s3,a0
  while(*path == '/')
    80003fce:	02f00913          	li	s2,47
  len = path - s;
    80003fd2:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003fd4:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003fd6:	4b85                	li	s7,1
    80003fd8:	a865                	j	80004090 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003fda:	4585                	li	a1,1
    80003fdc:	4505                	li	a0,1
    80003fde:	fffff097          	auipc	ra,0xfffff
    80003fe2:	6e6080e7          	jalr	1766(ra) # 800036c4 <iget>
    80003fe6:	89aa                	mv	s3,a0
    80003fe8:	b7dd                	j	80003fce <namex+0x42>
      iunlockput(ip);
    80003fea:	854e                	mv	a0,s3
    80003fec:	00000097          	auipc	ra,0x0
    80003ff0:	c6e080e7          	jalr	-914(ra) # 80003c5a <iunlockput>
      return 0;
    80003ff4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ff6:	854e                	mv	a0,s3
    80003ff8:	60e6                	ld	ra,88(sp)
    80003ffa:	6446                	ld	s0,80(sp)
    80003ffc:	64a6                	ld	s1,72(sp)
    80003ffe:	6906                	ld	s2,64(sp)
    80004000:	79e2                	ld	s3,56(sp)
    80004002:	7a42                	ld	s4,48(sp)
    80004004:	7aa2                	ld	s5,40(sp)
    80004006:	7b02                	ld	s6,32(sp)
    80004008:	6be2                	ld	s7,24(sp)
    8000400a:	6c42                	ld	s8,16(sp)
    8000400c:	6ca2                	ld	s9,8(sp)
    8000400e:	6125                	addi	sp,sp,96
    80004010:	8082                	ret
      iunlock(ip);
    80004012:	854e                	mv	a0,s3
    80004014:	00000097          	auipc	ra,0x0
    80004018:	aa6080e7          	jalr	-1370(ra) # 80003aba <iunlock>
      return ip;
    8000401c:	bfe9                	j	80003ff6 <namex+0x6a>
      iunlockput(ip);
    8000401e:	854e                	mv	a0,s3
    80004020:	00000097          	auipc	ra,0x0
    80004024:	c3a080e7          	jalr	-966(ra) # 80003c5a <iunlockput>
      return 0;
    80004028:	89e6                	mv	s3,s9
    8000402a:	b7f1                	j	80003ff6 <namex+0x6a>
  len = path - s;
    8000402c:	40b48633          	sub	a2,s1,a1
    80004030:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004034:	099c5463          	bge	s8,s9,800040bc <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004038:	4639                	li	a2,14
    8000403a:	8552                	mv	a0,s4
    8000403c:	ffffd097          	auipc	ra,0xffffd
    80004040:	e96080e7          	jalr	-362(ra) # 80000ed2 <memmove>
  while(*path == '/')
    80004044:	0004c783          	lbu	a5,0(s1)
    80004048:	01279763          	bne	a5,s2,80004056 <namex+0xca>
    path++;
    8000404c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000404e:	0004c783          	lbu	a5,0(s1)
    80004052:	ff278de3          	beq	a5,s2,8000404c <namex+0xc0>
    ilock(ip);
    80004056:	854e                	mv	a0,s3
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	9a0080e7          	jalr	-1632(ra) # 800039f8 <ilock>
    if(ip->type != T_DIR){
    80004060:	04c99783          	lh	a5,76(s3)
    80004064:	f97793e3          	bne	a5,s7,80003fea <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004068:	000a8563          	beqz	s5,80004072 <namex+0xe6>
    8000406c:	0004c783          	lbu	a5,0(s1)
    80004070:	d3cd                	beqz	a5,80004012 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004072:	865a                	mv	a2,s6
    80004074:	85d2                	mv	a1,s4
    80004076:	854e                	mv	a0,s3
    80004078:	00000097          	auipc	ra,0x0
    8000407c:	e64080e7          	jalr	-412(ra) # 80003edc <dirlookup>
    80004080:	8caa                	mv	s9,a0
    80004082:	dd51                	beqz	a0,8000401e <namex+0x92>
    iunlockput(ip);
    80004084:	854e                	mv	a0,s3
    80004086:	00000097          	auipc	ra,0x0
    8000408a:	bd4080e7          	jalr	-1068(ra) # 80003c5a <iunlockput>
    ip = next;
    8000408e:	89e6                	mv	s3,s9
  while(*path == '/')
    80004090:	0004c783          	lbu	a5,0(s1)
    80004094:	05279763          	bne	a5,s2,800040e2 <namex+0x156>
    path++;
    80004098:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000409a:	0004c783          	lbu	a5,0(s1)
    8000409e:	ff278de3          	beq	a5,s2,80004098 <namex+0x10c>
  if(*path == 0)
    800040a2:	c79d                	beqz	a5,800040d0 <namex+0x144>
    path++;
    800040a4:	85a6                	mv	a1,s1
  len = path - s;
    800040a6:	8cda                	mv	s9,s6
    800040a8:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800040aa:	01278963          	beq	a5,s2,800040bc <namex+0x130>
    800040ae:	dfbd                	beqz	a5,8000402c <namex+0xa0>
    path++;
    800040b0:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800040b2:	0004c783          	lbu	a5,0(s1)
    800040b6:	ff279ce3          	bne	a5,s2,800040ae <namex+0x122>
    800040ba:	bf8d                	j	8000402c <namex+0xa0>
    memmove(name, s, len);
    800040bc:	2601                	sext.w	a2,a2
    800040be:	8552                	mv	a0,s4
    800040c0:	ffffd097          	auipc	ra,0xffffd
    800040c4:	e12080e7          	jalr	-494(ra) # 80000ed2 <memmove>
    name[len] = 0;
    800040c8:	9cd2                	add	s9,s9,s4
    800040ca:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800040ce:	bf9d                	j	80004044 <namex+0xb8>
  if(nameiparent){
    800040d0:	f20a83e3          	beqz	s5,80003ff6 <namex+0x6a>
    iput(ip);
    800040d4:	854e                	mv	a0,s3
    800040d6:	00000097          	auipc	ra,0x0
    800040da:	adc080e7          	jalr	-1316(ra) # 80003bb2 <iput>
    return 0;
    800040de:	4981                	li	s3,0
    800040e0:	bf19                	j	80003ff6 <namex+0x6a>
  if(*path == 0)
    800040e2:	d7fd                	beqz	a5,800040d0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800040e4:	0004c783          	lbu	a5,0(s1)
    800040e8:	85a6                	mv	a1,s1
    800040ea:	b7d1                	j	800040ae <namex+0x122>

00000000800040ec <dirlink>:
{
    800040ec:	7139                	addi	sp,sp,-64
    800040ee:	fc06                	sd	ra,56(sp)
    800040f0:	f822                	sd	s0,48(sp)
    800040f2:	f426                	sd	s1,40(sp)
    800040f4:	f04a                	sd	s2,32(sp)
    800040f6:	ec4e                	sd	s3,24(sp)
    800040f8:	e852                	sd	s4,16(sp)
    800040fa:	0080                	addi	s0,sp,64
    800040fc:	892a                	mv	s2,a0
    800040fe:	8a2e                	mv	s4,a1
    80004100:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004102:	4601                	li	a2,0
    80004104:	00000097          	auipc	ra,0x0
    80004108:	dd8080e7          	jalr	-552(ra) # 80003edc <dirlookup>
    8000410c:	e93d                	bnez	a0,80004182 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410e:	05492483          	lw	s1,84(s2)
    80004112:	c49d                	beqz	s1,80004140 <dirlink+0x54>
    80004114:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004116:	4741                	li	a4,16
    80004118:	86a6                	mv	a3,s1
    8000411a:	fc040613          	addi	a2,s0,-64
    8000411e:	4581                	li	a1,0
    80004120:	854a                	mv	a0,s2
    80004122:	00000097          	auipc	ra,0x0
    80004126:	b8a080e7          	jalr	-1142(ra) # 80003cac <readi>
    8000412a:	47c1                	li	a5,16
    8000412c:	06f51163          	bne	a0,a5,8000418e <dirlink+0xa2>
    if(de.inum == 0)
    80004130:	fc045783          	lhu	a5,-64(s0)
    80004134:	c791                	beqz	a5,80004140 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004136:	24c1                	addiw	s1,s1,16
    80004138:	05492783          	lw	a5,84(s2)
    8000413c:	fcf4ede3          	bltu	s1,a5,80004116 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004140:	4639                	li	a2,14
    80004142:	85d2                	mv	a1,s4
    80004144:	fc240513          	addi	a0,s0,-62
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	e66080e7          	jalr	-410(ra) # 80000fae <strncpy>
  de.inum = inum;
    80004150:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004154:	4741                	li	a4,16
    80004156:	86a6                	mv	a3,s1
    80004158:	fc040613          	addi	a2,s0,-64
    8000415c:	4581                	li	a1,0
    8000415e:	854a                	mv	a0,s2
    80004160:	00000097          	auipc	ra,0x0
    80004164:	c44080e7          	jalr	-956(ra) # 80003da4 <writei>
    80004168:	872a                	mv	a4,a0
    8000416a:	47c1                	li	a5,16
  return 0;
    8000416c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000416e:	02f71863          	bne	a4,a5,8000419e <dirlink+0xb2>
}
    80004172:	70e2                	ld	ra,56(sp)
    80004174:	7442                	ld	s0,48(sp)
    80004176:	74a2                	ld	s1,40(sp)
    80004178:	7902                	ld	s2,32(sp)
    8000417a:	69e2                	ld	s3,24(sp)
    8000417c:	6a42                	ld	s4,16(sp)
    8000417e:	6121                	addi	sp,sp,64
    80004180:	8082                	ret
    iput(ip);
    80004182:	00000097          	auipc	ra,0x0
    80004186:	a30080e7          	jalr	-1488(ra) # 80003bb2 <iput>
    return -1;
    8000418a:	557d                	li	a0,-1
    8000418c:	b7dd                	j	80004172 <dirlink+0x86>
      panic("dirlink read");
    8000418e:	00006517          	auipc	a0,0x6
    80004192:	a6250513          	addi	a0,a0,-1438 # 80009bf0 <syscalls+0x1d8>
    80004196:	ffffc097          	auipc	ra,0xffffc
    8000419a:	3ce080e7          	jalr	974(ra) # 80000564 <panic>
    panic("dirlink");
    8000419e:	00006517          	auipc	a0,0x6
    800041a2:	b6250513          	addi	a0,a0,-1182 # 80009d00 <syscalls+0x2e8>
    800041a6:	ffffc097          	auipc	ra,0xffffc
    800041aa:	3be080e7          	jalr	958(ra) # 80000564 <panic>

00000000800041ae <namei>:

struct inode*
namei(char *path)
{
    800041ae:	1101                	addi	sp,sp,-32
    800041b0:	ec06                	sd	ra,24(sp)
    800041b2:	e822                	sd	s0,16(sp)
    800041b4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041b6:	fe040613          	addi	a2,s0,-32
    800041ba:	4581                	li	a1,0
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	dd0080e7          	jalr	-560(ra) # 80003f8c <namex>
}
    800041c4:	60e2                	ld	ra,24(sp)
    800041c6:	6442                	ld	s0,16(sp)
    800041c8:	6105                	addi	sp,sp,32
    800041ca:	8082                	ret

00000000800041cc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041cc:	1141                	addi	sp,sp,-16
    800041ce:	e406                	sd	ra,8(sp)
    800041d0:	e022                	sd	s0,0(sp)
    800041d2:	0800                	addi	s0,sp,16
    800041d4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041d6:	4585                	li	a1,1
    800041d8:	00000097          	auipc	ra,0x0
    800041dc:	db4080e7          	jalr	-588(ra) # 80003f8c <namex>
}
    800041e0:	60a2                	ld	ra,8(sp)
    800041e2:	6402                	ld	s0,0(sp)
    800041e4:	0141                	addi	sp,sp,16
    800041e6:	8082                	ret

00000000800041e8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041e8:	1101                	addi	sp,sp,-32
    800041ea:	ec06                	sd	ra,24(sp)
    800041ec:	e822                	sd	s0,16(sp)
    800041ee:	e426                	sd	s1,8(sp)
    800041f0:	e04a                	sd	s2,0(sp)
    800041f2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800041f4:	00033917          	auipc	s2,0x33
    800041f8:	f5490913          	addi	s2,s2,-172 # 80037148 <log>
    800041fc:	02092583          	lw	a1,32(s2)
    80004200:	03092503          	lw	a0,48(s2)
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	ff2080e7          	jalr	-14(ra) # 800031f6 <bread>
    8000420c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000420e:	03492683          	lw	a3,52(s2)
    80004212:	d134                	sw	a3,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004214:	02d05763          	blez	a3,80004242 <write_head+0x5a>
    80004218:	00033797          	auipc	a5,0x33
    8000421c:	f6878793          	addi	a5,a5,-152 # 80037180 <log+0x38>
    80004220:	06450713          	addi	a4,a0,100
    80004224:	36fd                	addiw	a3,a3,-1
    80004226:	1682                	slli	a3,a3,0x20
    80004228:	9281                	srli	a3,a3,0x20
    8000422a:	068a                	slli	a3,a3,0x2
    8000422c:	00033617          	auipc	a2,0x33
    80004230:	f5860613          	addi	a2,a2,-168 # 80037184 <log+0x3c>
    80004234:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004236:	4390                	lw	a2,0(a5)
    80004238:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000423a:	0791                	addi	a5,a5,4
    8000423c:	0711                	addi	a4,a4,4
    8000423e:	fed79ce3          	bne	a5,a3,80004236 <write_head+0x4e>
  }
  bwrite(buf);
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	0a4080e7          	jalr	164(ra) # 800032e8 <bwrite>
  brelse(buf);
    8000424c:	8526                	mv	a0,s1
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	0d8080e7          	jalr	216(ra) # 80003326 <brelse>
}
    80004256:	60e2                	ld	ra,24(sp)
    80004258:	6442                	ld	s0,16(sp)
    8000425a:	64a2                	ld	s1,8(sp)
    8000425c:	6902                	ld	s2,0(sp)
    8000425e:	6105                	addi	sp,sp,32
    80004260:	8082                	ret

0000000080004262 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004262:	00033797          	auipc	a5,0x33
    80004266:	f1a7a783          	lw	a5,-230(a5) # 8003717c <log+0x34>
    8000426a:	0af05663          	blez	a5,80004316 <install_trans+0xb4>
{
    8000426e:	7139                	addi	sp,sp,-64
    80004270:	fc06                	sd	ra,56(sp)
    80004272:	f822                	sd	s0,48(sp)
    80004274:	f426                	sd	s1,40(sp)
    80004276:	f04a                	sd	s2,32(sp)
    80004278:	ec4e                	sd	s3,24(sp)
    8000427a:	e852                	sd	s4,16(sp)
    8000427c:	e456                	sd	s5,8(sp)
    8000427e:	0080                	addi	s0,sp,64
    80004280:	00033a97          	auipc	s5,0x33
    80004284:	f00a8a93          	addi	s5,s5,-256 # 80037180 <log+0x38>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004288:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000428a:	00033997          	auipc	s3,0x33
    8000428e:	ebe98993          	addi	s3,s3,-322 # 80037148 <log>
    80004292:	0209a583          	lw	a1,32(s3)
    80004296:	014585bb          	addw	a1,a1,s4
    8000429a:	2585                	addiw	a1,a1,1
    8000429c:	0309a503          	lw	a0,48(s3)
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	f56080e7          	jalr	-170(ra) # 800031f6 <bread>
    800042a8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042aa:	000aa583          	lw	a1,0(s5)
    800042ae:	0309a503          	lw	a0,48(s3)
    800042b2:	fffff097          	auipc	ra,0xfffff
    800042b6:	f44080e7          	jalr	-188(ra) # 800031f6 <bread>
    800042ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042bc:	40000613          	li	a2,1024
    800042c0:	06090593          	addi	a1,s2,96
    800042c4:	06050513          	addi	a0,a0,96
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	c0a080e7          	jalr	-1014(ra) # 80000ed2 <memmove>
    bwrite(dbuf);  // write dst to disk
    800042d0:	8526                	mv	a0,s1
    800042d2:	fffff097          	auipc	ra,0xfffff
    800042d6:	016080e7          	jalr	22(ra) # 800032e8 <bwrite>
    bunpin(dbuf);
    800042da:	8526                	mv	a0,s1
    800042dc:	fffff097          	auipc	ra,0xfffff
    800042e0:	124080e7          	jalr	292(ra) # 80003400 <bunpin>
    brelse(lbuf);
    800042e4:	854a                	mv	a0,s2
    800042e6:	fffff097          	auipc	ra,0xfffff
    800042ea:	040080e7          	jalr	64(ra) # 80003326 <brelse>
    brelse(dbuf);
    800042ee:	8526                	mv	a0,s1
    800042f0:	fffff097          	auipc	ra,0xfffff
    800042f4:	036080e7          	jalr	54(ra) # 80003326 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042f8:	2a05                	addiw	s4,s4,1
    800042fa:	0a91                	addi	s5,s5,4
    800042fc:	0349a783          	lw	a5,52(s3)
    80004300:	f8fa49e3          	blt	s4,a5,80004292 <install_trans+0x30>
}
    80004304:	70e2                	ld	ra,56(sp)
    80004306:	7442                	ld	s0,48(sp)
    80004308:	74a2                	ld	s1,40(sp)
    8000430a:	7902                	ld	s2,32(sp)
    8000430c:	69e2                	ld	s3,24(sp)
    8000430e:	6a42                	ld	s4,16(sp)
    80004310:	6aa2                	ld	s5,8(sp)
    80004312:	6121                	addi	sp,sp,64
    80004314:	8082                	ret
    80004316:	8082                	ret

0000000080004318 <initlog>:
{
    80004318:	7179                	addi	sp,sp,-48
    8000431a:	f406                	sd	ra,40(sp)
    8000431c:	f022                	sd	s0,32(sp)
    8000431e:	ec26                	sd	s1,24(sp)
    80004320:	e84a                	sd	s2,16(sp)
    80004322:	e44e                	sd	s3,8(sp)
    80004324:	1800                	addi	s0,sp,48
    80004326:	892a                	mv	s2,a0
    80004328:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000432a:	00033497          	auipc	s1,0x33
    8000432e:	e1e48493          	addi	s1,s1,-482 # 80037148 <log>
    80004332:	00006597          	auipc	a1,0x6
    80004336:	8ce58593          	addi	a1,a1,-1842 # 80009c00 <syscalls+0x1e8>
    8000433a:	8526                	mv	a0,s1
    8000433c:	ffffc097          	auipc	ra,0xffffc
    80004340:	780080e7          	jalr	1920(ra) # 80000abc <initlock>
  log.start = sb->logstart;
    80004344:	0149a583          	lw	a1,20(s3)
    80004348:	d08c                	sw	a1,32(s1)
  log.size = sb->nlog;
    8000434a:	0109a783          	lw	a5,16(s3)
    8000434e:	d0dc                	sw	a5,36(s1)
  log.dev = dev;
    80004350:	0324a823          	sw	s2,48(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004354:	854a                	mv	a0,s2
    80004356:	fffff097          	auipc	ra,0xfffff
    8000435a:	ea0080e7          	jalr	-352(ra) # 800031f6 <bread>
  log.lh.n = lh->n;
    8000435e:	5134                	lw	a3,96(a0)
    80004360:	d8d4                	sw	a3,52(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004362:	02d05563          	blez	a3,8000438c <initlog+0x74>
    80004366:	06450793          	addi	a5,a0,100
    8000436a:	00033717          	auipc	a4,0x33
    8000436e:	e1670713          	addi	a4,a4,-490 # 80037180 <log+0x38>
    80004372:	36fd                	addiw	a3,a3,-1
    80004374:	1682                	slli	a3,a3,0x20
    80004376:	9281                	srli	a3,a3,0x20
    80004378:	068a                	slli	a3,a3,0x2
    8000437a:	06850613          	addi	a2,a0,104
    8000437e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004380:	4390                	lw	a2,0(a5)
    80004382:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004384:	0791                	addi	a5,a5,4
    80004386:	0711                	addi	a4,a4,4
    80004388:	fed79ce3          	bne	a5,a3,80004380 <initlog+0x68>
  brelse(buf);
    8000438c:	fffff097          	auipc	ra,0xfffff
    80004390:	f9a080e7          	jalr	-102(ra) # 80003326 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004394:	00000097          	auipc	ra,0x0
    80004398:	ece080e7          	jalr	-306(ra) # 80004262 <install_trans>
  log.lh.n = 0;
    8000439c:	00033797          	auipc	a5,0x33
    800043a0:	de07a023          	sw	zero,-544(a5) # 8003717c <log+0x34>
  write_head(); // clear the log
    800043a4:	00000097          	auipc	ra,0x0
    800043a8:	e44080e7          	jalr	-444(ra) # 800041e8 <write_head>
}
    800043ac:	70a2                	ld	ra,40(sp)
    800043ae:	7402                	ld	s0,32(sp)
    800043b0:	64e2                	ld	s1,24(sp)
    800043b2:	6942                	ld	s2,16(sp)
    800043b4:	69a2                	ld	s3,8(sp)
    800043b6:	6145                	addi	sp,sp,48
    800043b8:	8082                	ret

00000000800043ba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043ba:	1101                	addi	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	e426                	sd	s1,8(sp)
    800043c2:	e04a                	sd	s2,0(sp)
    800043c4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043c6:	00033517          	auipc	a0,0x33
    800043ca:	d8250513          	addi	a0,a0,-638 # 80037148 <log>
    800043ce:	ffffc097          	auipc	ra,0xffffc
    800043d2:	7c4080e7          	jalr	1988(ra) # 80000b92 <acquire>
  while(1){
    if(log.committing){
    800043d6:	00033497          	auipc	s1,0x33
    800043da:	d7248493          	addi	s1,s1,-654 # 80037148 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043de:	4979                	li	s2,30
    800043e0:	a039                	j	800043ee <begin_op+0x34>
      sleep(&log, &log.lock);
    800043e2:	85a6                	mv	a1,s1
    800043e4:	8526                	mv	a0,s1
    800043e6:	ffffe097          	auipc	ra,0xffffe
    800043ea:	0f2080e7          	jalr	242(ra) # 800024d8 <sleep>
    if(log.committing){
    800043ee:	54dc                	lw	a5,44(s1)
    800043f0:	fbed                	bnez	a5,800043e2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800043f2:	549c                	lw	a5,40(s1)
    800043f4:	0017871b          	addiw	a4,a5,1
    800043f8:	0007069b          	sext.w	a3,a4
    800043fc:	0027179b          	slliw	a5,a4,0x2
    80004400:	9fb9                	addw	a5,a5,a4
    80004402:	0017979b          	slliw	a5,a5,0x1
    80004406:	58d8                	lw	a4,52(s1)
    80004408:	9fb9                	addw	a5,a5,a4
    8000440a:	00f95963          	bge	s2,a5,8000441c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000440e:	85a6                	mv	a1,s1
    80004410:	8526                	mv	a0,s1
    80004412:	ffffe097          	auipc	ra,0xffffe
    80004416:	0c6080e7          	jalr	198(ra) # 800024d8 <sleep>
    8000441a:	bfd1                	j	800043ee <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000441c:	00033517          	auipc	a0,0x33
    80004420:	d2c50513          	addi	a0,a0,-724 # 80037148 <log>
    80004424:	d514                	sw	a3,40(a0)
      release(&log.lock);
    80004426:	ffffd097          	auipc	ra,0xffffd
    8000442a:	83c080e7          	jalr	-1988(ra) # 80000c62 <release>
      break;
    }
  }
}
    8000442e:	60e2                	ld	ra,24(sp)
    80004430:	6442                	ld	s0,16(sp)
    80004432:	64a2                	ld	s1,8(sp)
    80004434:	6902                	ld	s2,0(sp)
    80004436:	6105                	addi	sp,sp,32
    80004438:	8082                	ret

000000008000443a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000443a:	7139                	addi	sp,sp,-64
    8000443c:	fc06                	sd	ra,56(sp)
    8000443e:	f822                	sd	s0,48(sp)
    80004440:	f426                	sd	s1,40(sp)
    80004442:	f04a                	sd	s2,32(sp)
    80004444:	ec4e                	sd	s3,24(sp)
    80004446:	e852                	sd	s4,16(sp)
    80004448:	e456                	sd	s5,8(sp)
    8000444a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000444c:	00033497          	auipc	s1,0x33
    80004450:	cfc48493          	addi	s1,s1,-772 # 80037148 <log>
    80004454:	8526                	mv	a0,s1
    80004456:	ffffc097          	auipc	ra,0xffffc
    8000445a:	73c080e7          	jalr	1852(ra) # 80000b92 <acquire>
  log.outstanding -= 1;
    8000445e:	549c                	lw	a5,40(s1)
    80004460:	37fd                	addiw	a5,a5,-1
    80004462:	0007891b          	sext.w	s2,a5
    80004466:	d49c                	sw	a5,40(s1)
  if(log.committing)
    80004468:	54dc                	lw	a5,44(s1)
    8000446a:	e7b9                	bnez	a5,800044b8 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000446c:	04091e63          	bnez	s2,800044c8 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004470:	00033497          	auipc	s1,0x33
    80004474:	cd848493          	addi	s1,s1,-808 # 80037148 <log>
    80004478:	4785                	li	a5,1
    8000447a:	d4dc                	sw	a5,44(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000447c:	8526                	mv	a0,s1
    8000447e:	ffffc097          	auipc	ra,0xffffc
    80004482:	7e4080e7          	jalr	2020(ra) # 80000c62 <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    80004486:	58dc                	lw	a5,52(s1)
    80004488:	06f04763          	bgtz	a5,800044f6 <end_op+0xbc>
    acquire(&log.lock);
    8000448c:	00033497          	auipc	s1,0x33
    80004490:	cbc48493          	addi	s1,s1,-836 # 80037148 <log>
    80004494:	8526                	mv	a0,s1
    80004496:	ffffc097          	auipc	ra,0xffffc
    8000449a:	6fc080e7          	jalr	1788(ra) # 80000b92 <acquire>
    log.committing = 0;
    8000449e:	0204a623          	sw	zero,44(s1)
    wakeup(&log);
    800044a2:	8526                	mv	a0,s1
    800044a4:	ffffe097          	auipc	ra,0xffffe
    800044a8:	1f2080e7          	jalr	498(ra) # 80002696 <wakeup>
    release(&log.lock);
    800044ac:	8526                	mv	a0,s1
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	7b4080e7          	jalr	1972(ra) # 80000c62 <release>
}
    800044b6:	a03d                	j	800044e4 <end_op+0xaa>
    panic("log.committing");
    800044b8:	00005517          	auipc	a0,0x5
    800044bc:	75050513          	addi	a0,a0,1872 # 80009c08 <syscalls+0x1f0>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	0a4080e7          	jalr	164(ra) # 80000564 <panic>
    wakeup(&log);
    800044c8:	00033497          	auipc	s1,0x33
    800044cc:	c8048493          	addi	s1,s1,-896 # 80037148 <log>
    800044d0:	8526                	mv	a0,s1
    800044d2:	ffffe097          	auipc	ra,0xffffe
    800044d6:	1c4080e7          	jalr	452(ra) # 80002696 <wakeup>
  release(&log.lock);
    800044da:	8526                	mv	a0,s1
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	786080e7          	jalr	1926(ra) # 80000c62 <release>
}
    800044e4:	70e2                	ld	ra,56(sp)
    800044e6:	7442                	ld	s0,48(sp)
    800044e8:	74a2                	ld	s1,40(sp)
    800044ea:	7902                	ld	s2,32(sp)
    800044ec:	69e2                	ld	s3,24(sp)
    800044ee:	6a42                	ld	s4,16(sp)
    800044f0:	6aa2                	ld	s5,8(sp)
    800044f2:	6121                	addi	sp,sp,64
    800044f4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800044f6:	00033a97          	auipc	s5,0x33
    800044fa:	c8aa8a93          	addi	s5,s5,-886 # 80037180 <log+0x38>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800044fe:	00033a17          	auipc	s4,0x33
    80004502:	c4aa0a13          	addi	s4,s4,-950 # 80037148 <log>
    80004506:	020a2583          	lw	a1,32(s4)
    8000450a:	012585bb          	addw	a1,a1,s2
    8000450e:	2585                	addiw	a1,a1,1
    80004510:	030a2503          	lw	a0,48(s4)
    80004514:	fffff097          	auipc	ra,0xfffff
    80004518:	ce2080e7          	jalr	-798(ra) # 800031f6 <bread>
    8000451c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000451e:	000aa583          	lw	a1,0(s5)
    80004522:	030a2503          	lw	a0,48(s4)
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	cd0080e7          	jalr	-816(ra) # 800031f6 <bread>
    8000452e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004530:	40000613          	li	a2,1024
    80004534:	06050593          	addi	a1,a0,96
    80004538:	06048513          	addi	a0,s1,96
    8000453c:	ffffd097          	auipc	ra,0xffffd
    80004540:	996080e7          	jalr	-1642(ra) # 80000ed2 <memmove>
    bwrite(to);  // write the log
    80004544:	8526                	mv	a0,s1
    80004546:	fffff097          	auipc	ra,0xfffff
    8000454a:	da2080e7          	jalr	-606(ra) # 800032e8 <bwrite>
    brelse(from);
    8000454e:	854e                	mv	a0,s3
    80004550:	fffff097          	auipc	ra,0xfffff
    80004554:	dd6080e7          	jalr	-554(ra) # 80003326 <brelse>
    brelse(to);
    80004558:	8526                	mv	a0,s1
    8000455a:	fffff097          	auipc	ra,0xfffff
    8000455e:	dcc080e7          	jalr	-564(ra) # 80003326 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004562:	2905                	addiw	s2,s2,1
    80004564:	0a91                	addi	s5,s5,4
    80004566:	034a2783          	lw	a5,52(s4)
    8000456a:	f8f94ee3          	blt	s2,a5,80004506 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000456e:	00000097          	auipc	ra,0x0
    80004572:	c7a080e7          	jalr	-902(ra) # 800041e8 <write_head>
    install_trans(); // Now install writes to home locations
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	cec080e7          	jalr	-788(ra) # 80004262 <install_trans>
    log.lh.n = 0;
    8000457e:	00033797          	auipc	a5,0x33
    80004582:	be07af23          	sw	zero,-1026(a5) # 8003717c <log+0x34>
    write_head();    // Erase the transaction from the log
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	c62080e7          	jalr	-926(ra) # 800041e8 <write_head>
    8000458e:	bdfd                	j	8000448c <end_op+0x52>

0000000080004590 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004590:	1101                	addi	sp,sp,-32
    80004592:	ec06                	sd	ra,24(sp)
    80004594:	e822                	sd	s0,16(sp)
    80004596:	e426                	sd	s1,8(sp)
    80004598:	e04a                	sd	s2,0(sp)
    8000459a:	1000                	addi	s0,sp,32
    8000459c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000459e:	00033917          	auipc	s2,0x33
    800045a2:	baa90913          	addi	s2,s2,-1110 # 80037148 <log>
    800045a6:	854a                	mv	a0,s2
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	5ea080e7          	jalr	1514(ra) # 80000b92 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045b0:	03492603          	lw	a2,52(s2)
    800045b4:	47f5                	li	a5,29
    800045b6:	06c7c563          	blt	a5,a2,80004620 <log_write+0x90>
    800045ba:	00033797          	auipc	a5,0x33
    800045be:	bb27a783          	lw	a5,-1102(a5) # 8003716c <log+0x24>
    800045c2:	37fd                	addiw	a5,a5,-1
    800045c4:	04f65e63          	bge	a2,a5,80004620 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045c8:	00033797          	auipc	a5,0x33
    800045cc:	ba87a783          	lw	a5,-1112(a5) # 80037170 <log+0x28>
    800045d0:	06f05063          	blez	a5,80004630 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045d4:	4781                	li	a5,0
    800045d6:	06c05563          	blez	a2,80004640 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045da:	44cc                	lw	a1,12(s1)
    800045dc:	00033717          	auipc	a4,0x33
    800045e0:	ba470713          	addi	a4,a4,-1116 # 80037180 <log+0x38>
  for (i = 0; i < log.lh.n; i++) {
    800045e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045e6:	4314                	lw	a3,0(a4)
    800045e8:	04b68c63          	beq	a3,a1,80004640 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800045ec:	2785                	addiw	a5,a5,1
    800045ee:	0711                	addi	a4,a4,4
    800045f0:	fef61be3          	bne	a2,a5,800045e6 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800045f4:	0631                	addi	a2,a2,12
    800045f6:	060a                	slli	a2,a2,0x2
    800045f8:	00033797          	auipc	a5,0x33
    800045fc:	b5078793          	addi	a5,a5,-1200 # 80037148 <log>
    80004600:	963e                	add	a2,a2,a5
    80004602:	44dc                	lw	a5,12(s1)
    80004604:	c61c                	sw	a5,8(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004606:	8526                	mv	a0,s1
    80004608:	fffff097          	auipc	ra,0xfffff
    8000460c:	dbc080e7          	jalr	-580(ra) # 800033c4 <bpin>
    log.lh.n++;
    80004610:	00033717          	auipc	a4,0x33
    80004614:	b3870713          	addi	a4,a4,-1224 # 80037148 <log>
    80004618:	5b5c                	lw	a5,52(a4)
    8000461a:	2785                	addiw	a5,a5,1
    8000461c:	db5c                	sw	a5,52(a4)
    8000461e:	a835                	j	8000465a <log_write+0xca>
    panic("too big a transaction");
    80004620:	00005517          	auipc	a0,0x5
    80004624:	5f850513          	addi	a0,a0,1528 # 80009c18 <syscalls+0x200>
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	f3c080e7          	jalr	-196(ra) # 80000564 <panic>
    panic("log_write outside of trans");
    80004630:	00005517          	auipc	a0,0x5
    80004634:	60050513          	addi	a0,a0,1536 # 80009c30 <syscalls+0x218>
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	f2c080e7          	jalr	-212(ra) # 80000564 <panic>
  log.lh.block[i] = b->blockno;
    80004640:	00c78713          	addi	a4,a5,12
    80004644:	00271693          	slli	a3,a4,0x2
    80004648:	00033717          	auipc	a4,0x33
    8000464c:	b0070713          	addi	a4,a4,-1280 # 80037148 <log>
    80004650:	9736                	add	a4,a4,a3
    80004652:	44d4                	lw	a3,12(s1)
    80004654:	c714                	sw	a3,8(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004656:	faf608e3          	beq	a2,a5,80004606 <log_write+0x76>
  }
  release(&log.lock);
    8000465a:	00033517          	auipc	a0,0x33
    8000465e:	aee50513          	addi	a0,a0,-1298 # 80037148 <log>
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	600080e7          	jalr	1536(ra) # 80000c62 <release>
}
    8000466a:	60e2                	ld	ra,24(sp)
    8000466c:	6442                	ld	s0,16(sp)
    8000466e:	64a2                	ld	s1,8(sp)
    80004670:	6902                	ld	s2,0(sp)
    80004672:	6105                	addi	sp,sp,32
    80004674:	8082                	ret

0000000080004676 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004676:	1101                	addi	sp,sp,-32
    80004678:	ec06                	sd	ra,24(sp)
    8000467a:	e822                	sd	s0,16(sp)
    8000467c:	e426                	sd	s1,8(sp)
    8000467e:	e04a                	sd	s2,0(sp)
    80004680:	1000                	addi	s0,sp,32
    80004682:	84aa                	mv	s1,a0
    80004684:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004686:	00005597          	auipc	a1,0x5
    8000468a:	5ca58593          	addi	a1,a1,1482 # 80009c50 <syscalls+0x238>
    8000468e:	0521                	addi	a0,a0,8
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	42c080e7          	jalr	1068(ra) # 80000abc <initlock>
  lk->name = name;
    80004698:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    8000469c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046a0:	0204a823          	sw	zero,48(s1)
}
    800046a4:	60e2                	ld	ra,24(sp)
    800046a6:	6442                	ld	s0,16(sp)
    800046a8:	64a2                	ld	s1,8(sp)
    800046aa:	6902                	ld	s2,0(sp)
    800046ac:	6105                	addi	sp,sp,32
    800046ae:	8082                	ret

00000000800046b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046b0:	1101                	addi	sp,sp,-32
    800046b2:	ec06                	sd	ra,24(sp)
    800046b4:	e822                	sd	s0,16(sp)
    800046b6:	e426                	sd	s1,8(sp)
    800046b8:	e04a                	sd	s2,0(sp)
    800046ba:	1000                	addi	s0,sp,32
    800046bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046be:	00850913          	addi	s2,a0,8
    800046c2:	854a                	mv	a0,s2
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	4ce080e7          	jalr	1230(ra) # 80000b92 <acquire>
  while (lk->locked) {
    800046cc:	409c                	lw	a5,0(s1)
    800046ce:	cb89                	beqz	a5,800046e0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046d0:	85ca                	mv	a1,s2
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	e04080e7          	jalr	-508(ra) # 800024d8 <sleep>
  while (lk->locked) {
    800046dc:	409c                	lw	a5,0(s1)
    800046de:	fbed                	bnez	a5,800046d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800046e0:	4785                	li	a5,1
    800046e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046e4:	ffffd097          	auipc	ra,0xffffd
    800046e8:	46c080e7          	jalr	1132(ra) # 80001b50 <myproc>
    800046ec:	413c                	lw	a5,64(a0)
    800046ee:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	570080e7          	jalr	1392(ra) # 80000c62 <release>
}
    800046fa:	60e2                	ld	ra,24(sp)
    800046fc:	6442                	ld	s0,16(sp)
    800046fe:	64a2                	ld	s1,8(sp)
    80004700:	6902                	ld	s2,0(sp)
    80004702:	6105                	addi	sp,sp,32
    80004704:	8082                	ret

0000000080004706 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004706:	1101                	addi	sp,sp,-32
    80004708:	ec06                	sd	ra,24(sp)
    8000470a:	e822                	sd	s0,16(sp)
    8000470c:	e426                	sd	s1,8(sp)
    8000470e:	e04a                	sd	s2,0(sp)
    80004710:	1000                	addi	s0,sp,32
    80004712:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004714:	00850913          	addi	s2,a0,8
    80004718:	854a                	mv	a0,s2
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	478080e7          	jalr	1144(ra) # 80000b92 <acquire>
  lk->locked = 0;
    80004722:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004726:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    8000472a:	8526                	mv	a0,s1
    8000472c:	ffffe097          	auipc	ra,0xffffe
    80004730:	f6a080e7          	jalr	-150(ra) # 80002696 <wakeup>
  release(&lk->lk);
    80004734:	854a                	mv	a0,s2
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	52c080e7          	jalr	1324(ra) # 80000c62 <release>
}
    8000473e:	60e2                	ld	ra,24(sp)
    80004740:	6442                	ld	s0,16(sp)
    80004742:	64a2                	ld	s1,8(sp)
    80004744:	6902                	ld	s2,0(sp)
    80004746:	6105                	addi	sp,sp,32
    80004748:	8082                	ret

000000008000474a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000474a:	7179                	addi	sp,sp,-48
    8000474c:	f406                	sd	ra,40(sp)
    8000474e:	f022                	sd	s0,32(sp)
    80004750:	ec26                	sd	s1,24(sp)
    80004752:	e84a                	sd	s2,16(sp)
    80004754:	e44e                	sd	s3,8(sp)
    80004756:	1800                	addi	s0,sp,48
    80004758:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000475a:	00850913          	addi	s2,a0,8
    8000475e:	854a                	mv	a0,s2
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	432080e7          	jalr	1074(ra) # 80000b92 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004768:	409c                	lw	a5,0(s1)
    8000476a:	ef99                	bnez	a5,80004788 <holdingsleep+0x3e>
    8000476c:	4481                	li	s1,0
  release(&lk->lk);
    8000476e:	854a                	mv	a0,s2
    80004770:	ffffc097          	auipc	ra,0xffffc
    80004774:	4f2080e7          	jalr	1266(ra) # 80000c62 <release>
  return r;
}
    80004778:	8526                	mv	a0,s1
    8000477a:	70a2                	ld	ra,40(sp)
    8000477c:	7402                	ld	s0,32(sp)
    8000477e:	64e2                	ld	s1,24(sp)
    80004780:	6942                	ld	s2,16(sp)
    80004782:	69a2                	ld	s3,8(sp)
    80004784:	6145                	addi	sp,sp,48
    80004786:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004788:	0304a983          	lw	s3,48(s1)
    8000478c:	ffffd097          	auipc	ra,0xffffd
    80004790:	3c4080e7          	jalr	964(ra) # 80001b50 <myproc>
    80004794:	4124                	lw	s1,64(a0)
    80004796:	413484b3          	sub	s1,s1,s3
    8000479a:	0014b493          	seqz	s1,s1
    8000479e:	bfc1                	j	8000476e <holdingsleep+0x24>

00000000800047a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047a0:	1141                	addi	sp,sp,-16
    800047a2:	e406                	sd	ra,8(sp)
    800047a4:	e022                	sd	s0,0(sp)
    800047a6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047a8:	00005597          	auipc	a1,0x5
    800047ac:	4b858593          	addi	a1,a1,1208 # 80009c60 <syscalls+0x248>
    800047b0:	00033517          	auipc	a0,0x33
    800047b4:	ae850513          	addi	a0,a0,-1304 # 80037298 <ftable>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	304080e7          	jalr	772(ra) # 80000abc <initlock>
}
    800047c0:	60a2                	ld	ra,8(sp)
    800047c2:	6402                	ld	s0,0(sp)
    800047c4:	0141                	addi	sp,sp,16
    800047c6:	8082                	ret

00000000800047c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047c8:	1101                	addi	sp,sp,-32
    800047ca:	ec06                	sd	ra,24(sp)
    800047cc:	e822                	sd	s0,16(sp)
    800047ce:	e426                	sd	s1,8(sp)
    800047d0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047d2:	00033517          	auipc	a0,0x33
    800047d6:	ac650513          	addi	a0,a0,-1338 # 80037298 <ftable>
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	3b8080e7          	jalr	952(ra) # 80000b92 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047e2:	00033497          	auipc	s1,0x33
    800047e6:	ad648493          	addi	s1,s1,-1322 # 800372b8 <ftable+0x20>
    800047ea:	00034717          	auipc	a4,0x34
    800047ee:	a6e70713          	addi	a4,a4,-1426 # 80038258 <disk>
    if(f->ref == 0){
    800047f2:	40dc                	lw	a5,4(s1)
    800047f4:	cf99                	beqz	a5,80004812 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047f6:	02848493          	addi	s1,s1,40
    800047fa:	fee49ce3          	bne	s1,a4,800047f2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047fe:	00033517          	auipc	a0,0x33
    80004802:	a9a50513          	addi	a0,a0,-1382 # 80037298 <ftable>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	45c080e7          	jalr	1116(ra) # 80000c62 <release>
  return 0;
    8000480e:	4481                	li	s1,0
    80004810:	a819                	j	80004826 <filealloc+0x5e>
      f->ref = 1;
    80004812:	4785                	li	a5,1
    80004814:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004816:	00033517          	auipc	a0,0x33
    8000481a:	a8250513          	addi	a0,a0,-1406 # 80037298 <ftable>
    8000481e:	ffffc097          	auipc	ra,0xffffc
    80004822:	444080e7          	jalr	1092(ra) # 80000c62 <release>
}
    80004826:	8526                	mv	a0,s1
    80004828:	60e2                	ld	ra,24(sp)
    8000482a:	6442                	ld	s0,16(sp)
    8000482c:	64a2                	ld	s1,8(sp)
    8000482e:	6105                	addi	sp,sp,32
    80004830:	8082                	ret

0000000080004832 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004832:	1101                	addi	sp,sp,-32
    80004834:	ec06                	sd	ra,24(sp)
    80004836:	e822                	sd	s0,16(sp)
    80004838:	e426                	sd	s1,8(sp)
    8000483a:	1000                	addi	s0,sp,32
    8000483c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000483e:	00033517          	auipc	a0,0x33
    80004842:	a5a50513          	addi	a0,a0,-1446 # 80037298 <ftable>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	34c080e7          	jalr	844(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    8000484e:	40dc                	lw	a5,4(s1)
    80004850:	02f05263          	blez	a5,80004874 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004854:	2785                	addiw	a5,a5,1
    80004856:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004858:	00033517          	auipc	a0,0x33
    8000485c:	a4050513          	addi	a0,a0,-1472 # 80037298 <ftable>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	402080e7          	jalr	1026(ra) # 80000c62 <release>
  return f;
}
    80004868:	8526                	mv	a0,s1
    8000486a:	60e2                	ld	ra,24(sp)
    8000486c:	6442                	ld	s0,16(sp)
    8000486e:	64a2                	ld	s1,8(sp)
    80004870:	6105                	addi	sp,sp,32
    80004872:	8082                	ret
    panic("filedup");
    80004874:	00005517          	auipc	a0,0x5
    80004878:	3f450513          	addi	a0,a0,1012 # 80009c68 <syscalls+0x250>
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	ce8080e7          	jalr	-792(ra) # 80000564 <panic>

0000000080004884 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004884:	7139                	addi	sp,sp,-64
    80004886:	fc06                	sd	ra,56(sp)
    80004888:	f822                	sd	s0,48(sp)
    8000488a:	f426                	sd	s1,40(sp)
    8000488c:	f04a                	sd	s2,32(sp)
    8000488e:	ec4e                	sd	s3,24(sp)
    80004890:	e852                	sd	s4,16(sp)
    80004892:	e456                	sd	s5,8(sp)
    80004894:	0080                	addi	s0,sp,64
    80004896:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004898:	00033517          	auipc	a0,0x33
    8000489c:	a0050513          	addi	a0,a0,-1536 # 80037298 <ftable>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	2f2080e7          	jalr	754(ra) # 80000b92 <acquire>
  if(f->ref < 1)
    800048a8:	40dc                	lw	a5,4(s1)
    800048aa:	06f05163          	blez	a5,8000490c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048ae:	37fd                	addiw	a5,a5,-1
    800048b0:	0007871b          	sext.w	a4,a5
    800048b4:	c0dc                	sw	a5,4(s1)
    800048b6:	06e04363          	bgtz	a4,8000491c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048ba:	0004a903          	lw	s2,0(s1)
    800048be:	0094ca83          	lbu	s5,9(s1)
    800048c2:	0104ba03          	ld	s4,16(s1)
    800048c6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048ca:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048ce:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048d2:	00033517          	auipc	a0,0x33
    800048d6:	9c650513          	addi	a0,a0,-1594 # 80037298 <ftable>
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	388080e7          	jalr	904(ra) # 80000c62 <release>

  if(ff.type == FD_PIPE){
    800048e2:	4785                	li	a5,1
    800048e4:	04f90d63          	beq	s2,a5,8000493e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048e8:	3979                	addiw	s2,s2,-2
    800048ea:	4785                	li	a5,1
    800048ec:	0527e063          	bltu	a5,s2,8000492c <fileclose+0xa8>
    begin_op();
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	aca080e7          	jalr	-1334(ra) # 800043ba <begin_op>
    iput(ff.ip);
    800048f8:	854e                	mv	a0,s3
    800048fa:	fffff097          	auipc	ra,0xfffff
    800048fe:	2b8080e7          	jalr	696(ra) # 80003bb2 <iput>
    end_op();
    80004902:	00000097          	auipc	ra,0x0
    80004906:	b38080e7          	jalr	-1224(ra) # 8000443a <end_op>
    8000490a:	a00d                	j	8000492c <fileclose+0xa8>
    panic("fileclose");
    8000490c:	00005517          	auipc	a0,0x5
    80004910:	36450513          	addi	a0,a0,868 # 80009c70 <syscalls+0x258>
    80004914:	ffffc097          	auipc	ra,0xffffc
    80004918:	c50080e7          	jalr	-944(ra) # 80000564 <panic>
    release(&ftable.lock);
    8000491c:	00033517          	auipc	a0,0x33
    80004920:	97c50513          	addi	a0,a0,-1668 # 80037298 <ftable>
    80004924:	ffffc097          	auipc	ra,0xffffc
    80004928:	33e080e7          	jalr	830(ra) # 80000c62 <release>
  }
}
    8000492c:	70e2                	ld	ra,56(sp)
    8000492e:	7442                	ld	s0,48(sp)
    80004930:	74a2                	ld	s1,40(sp)
    80004932:	7902                	ld	s2,32(sp)
    80004934:	69e2                	ld	s3,24(sp)
    80004936:	6a42                	ld	s4,16(sp)
    80004938:	6aa2                	ld	s5,8(sp)
    8000493a:	6121                	addi	sp,sp,64
    8000493c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000493e:	85d6                	mv	a1,s5
    80004940:	8552                	mv	a0,s4
    80004942:	00000097          	auipc	ra,0x0
    80004946:	354080e7          	jalr	852(ra) # 80004c96 <pipeclose>
    8000494a:	b7cd                	j	8000492c <fileclose+0xa8>

000000008000494c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000494c:	715d                	addi	sp,sp,-80
    8000494e:	e486                	sd	ra,72(sp)
    80004950:	e0a2                	sd	s0,64(sp)
    80004952:	fc26                	sd	s1,56(sp)
    80004954:	f84a                	sd	s2,48(sp)
    80004956:	f44e                	sd	s3,40(sp)
    80004958:	0880                	addi	s0,sp,80
    8000495a:	84aa                	mv	s1,a0
    8000495c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000495e:	ffffd097          	auipc	ra,0xffffd
    80004962:	1f2080e7          	jalr	498(ra) # 80001b50 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004966:	409c                	lw	a5,0(s1)
    80004968:	37f9                	addiw	a5,a5,-2
    8000496a:	4705                	li	a4,1
    8000496c:	04f76763          	bltu	a4,a5,800049ba <filestat+0x6e>
    80004970:	892a                	mv	s2,a0
    ilock(f->ip);
    80004972:	6c88                	ld	a0,24(s1)
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	084080e7          	jalr	132(ra) # 800039f8 <ilock>
    stati(f->ip, &st);
    8000497c:	fb840593          	addi	a1,s0,-72
    80004980:	6c88                	ld	a0,24(s1)
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	300080e7          	jalr	768(ra) # 80003c82 <stati>
    iunlock(f->ip);
    8000498a:	6c88                	ld	a0,24(s1)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	12e080e7          	jalr	302(ra) # 80003aba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004994:	46e1                	li	a3,24
    80004996:	fb840613          	addi	a2,s0,-72
    8000499a:	85ce                	mv	a1,s3
    8000499c:	05893503          	ld	a0,88(s2)
    800049a0:	ffffd097          	auipc	ra,0xffffd
    800049a4:	e60080e7          	jalr	-416(ra) # 80001800 <copyout>
    800049a8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049ac:	60a6                	ld	ra,72(sp)
    800049ae:	6406                	ld	s0,64(sp)
    800049b0:	74e2                	ld	s1,56(sp)
    800049b2:	7942                	ld	s2,48(sp)
    800049b4:	79a2                	ld	s3,40(sp)
    800049b6:	6161                	addi	sp,sp,80
    800049b8:	8082                	ret
  return -1;
    800049ba:	557d                	li	a0,-1
    800049bc:	bfc5                	j	800049ac <filestat+0x60>

00000000800049be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049be:	7179                	addi	sp,sp,-48
    800049c0:	f406                	sd	ra,40(sp)
    800049c2:	f022                	sd	s0,32(sp)
    800049c4:	ec26                	sd	s1,24(sp)
    800049c6:	e84a                	sd	s2,16(sp)
    800049c8:	e44e                	sd	s3,8(sp)
    800049ca:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049cc:	00854783          	lbu	a5,8(a0)
    800049d0:	c7c5                	beqz	a5,80004a78 <fileread+0xba>
    800049d2:	84aa                	mv	s1,a0
    800049d4:	89ae                	mv	s3,a1
    800049d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049d8:	411c                	lw	a5,0(a0)
    800049da:	4705                	li	a4,1
    800049dc:	04e78963          	beq	a5,a4,80004a2e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049e0:	470d                	li	a4,3
    800049e2:	04e78d63          	beq	a5,a4,80004a3c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    800049e6:	4709                	li	a4,2
    800049e8:	08e79063          	bne	a5,a4,80004a68 <fileread+0xaa>
    ilock(f->ip);
    800049ec:	6d08                	ld	a0,24(a0)
    800049ee:	fffff097          	auipc	ra,0xfffff
    800049f2:	00a080e7          	jalr	10(ra) # 800039f8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800049f6:	874a                	mv	a4,s2
    800049f8:	5094                	lw	a3,32(s1)
    800049fa:	864e                	mv	a2,s3
    800049fc:	4585                	li	a1,1
    800049fe:	6c88                	ld	a0,24(s1)
    80004a00:	fffff097          	auipc	ra,0xfffff
    80004a04:	2ac080e7          	jalr	684(ra) # 80003cac <readi>
    80004a08:	892a                	mv	s2,a0
    80004a0a:	00a05563          	blez	a0,80004a14 <fileread+0x56>
      f->off += r;
    80004a0e:	509c                	lw	a5,32(s1)
    80004a10:	9fa9                	addw	a5,a5,a0
    80004a12:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a14:	6c88                	ld	a0,24(s1)
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	0a4080e7          	jalr	164(ra) # 80003aba <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a1e:	854a                	mv	a0,s2
    80004a20:	70a2                	ld	ra,40(sp)
    80004a22:	7402                	ld	s0,32(sp)
    80004a24:	64e2                	ld	s1,24(sp)
    80004a26:	6942                	ld	s2,16(sp)
    80004a28:	69a2                	ld	s3,8(sp)
    80004a2a:	6145                	addi	sp,sp,48
    80004a2c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a2e:	6908                	ld	a0,16(a0)
    80004a30:	00000097          	auipc	ra,0x0
    80004a34:	3c8080e7          	jalr	968(ra) # 80004df8 <piperead>
    80004a38:	892a                	mv	s2,a0
    80004a3a:	b7d5                	j	80004a1e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a3c:	02451783          	lh	a5,36(a0)
    80004a40:	03079693          	slli	a3,a5,0x30
    80004a44:	92c1                	srli	a3,a3,0x30
    80004a46:	4725                	li	a4,9
    80004a48:	02d76a63          	bltu	a4,a3,80004a7c <fileread+0xbe>
    80004a4c:	0792                	slli	a5,a5,0x4
    80004a4e:	00032717          	auipc	a4,0x32
    80004a52:	7aa70713          	addi	a4,a4,1962 # 800371f8 <devsw>
    80004a56:	97ba                	add	a5,a5,a4
    80004a58:	639c                	ld	a5,0(a5)
    80004a5a:	c39d                	beqz	a5,80004a80 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    80004a5c:	86b2                	mv	a3,a2
    80004a5e:	862e                	mv	a2,a1
    80004a60:	4585                	li	a1,1
    80004a62:	9782                	jalr	a5
    80004a64:	892a                	mv	s2,a0
    80004a66:	bf65                	j	80004a1e <fileread+0x60>
    panic("fileread");
    80004a68:	00005517          	auipc	a0,0x5
    80004a6c:	21850513          	addi	a0,a0,536 # 80009c80 <syscalls+0x268>
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	af4080e7          	jalr	-1292(ra) # 80000564 <panic>
    return -1;
    80004a78:	597d                	li	s2,-1
    80004a7a:	b755                	j	80004a1e <fileread+0x60>
      return -1;
    80004a7c:	597d                	li	s2,-1
    80004a7e:	b745                	j	80004a1e <fileread+0x60>
    80004a80:	597d                	li	s2,-1
    80004a82:	bf71                	j	80004a1e <fileread+0x60>

0000000080004a84 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a84:	715d                	addi	sp,sp,-80
    80004a86:	e486                	sd	ra,72(sp)
    80004a88:	e0a2                	sd	s0,64(sp)
    80004a8a:	fc26                	sd	s1,56(sp)
    80004a8c:	f84a                	sd	s2,48(sp)
    80004a8e:	f44e                	sd	s3,40(sp)
    80004a90:	f052                	sd	s4,32(sp)
    80004a92:	ec56                	sd	s5,24(sp)
    80004a94:	e85a                	sd	s6,16(sp)
    80004a96:	e45e                	sd	s7,8(sp)
    80004a98:	e062                	sd	s8,0(sp)
    80004a9a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a9c:	00954783          	lbu	a5,9(a0)
    80004aa0:	10078863          	beqz	a5,80004bb0 <filewrite+0x12c>
    80004aa4:	892a                	mv	s2,a0
    80004aa6:	8aae                	mv	s5,a1
    80004aa8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aaa:	411c                	lw	a5,0(a0)
    80004aac:	4705                	li	a4,1
    80004aae:	02e78263          	beq	a5,a4,80004ad2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ab2:	470d                	li	a4,3
    80004ab4:	02e78663          	beq	a5,a4,80004ae0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004ab8:	4709                	li	a4,2
    80004aba:	0ee79363          	bne	a5,a4,80004ba0 <filewrite+0x11c>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004abe:	0ac05f63          	blez	a2,80004b7c <filewrite+0xf8>
    int i = 0;
    80004ac2:	4981                	li	s3,0
    80004ac4:	6b05                	lui	s6,0x1
    80004ac6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004aca:	6b85                	lui	s7,0x1
    80004acc:	c00b8b9b          	addiw	s7,s7,-1024
    80004ad0:	a871                	j	80004b6c <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    80004ad2:	6908                	ld	a0,16(a0)
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	232080e7          	jalr	562(ra) # 80004d06 <pipewrite>
    80004adc:	8a2a                	mv	s4,a0
    80004ade:	a055                	j	80004b82 <filewrite+0xfe>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004ae0:	02451783          	lh	a5,36(a0)
    80004ae4:	03079693          	slli	a3,a5,0x30
    80004ae8:	92c1                	srli	a3,a3,0x30
    80004aea:	4725                	li	a4,9
    80004aec:	0cd76463          	bltu	a4,a3,80004bb4 <filewrite+0x130>
    80004af0:	0792                	slli	a5,a5,0x4
    80004af2:	00032717          	auipc	a4,0x32
    80004af6:	70670713          	addi	a4,a4,1798 # 800371f8 <devsw>
    80004afa:	97ba                	add	a5,a5,a4
    80004afc:	679c                	ld	a5,8(a5)
    80004afe:	cfcd                	beqz	a5,80004bb8 <filewrite+0x134>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004b00:	86b2                	mv	a3,a2
    80004b02:	862e                	mv	a2,a1
    80004b04:	4585                	li	a1,1
    80004b06:	9782                	jalr	a5
    80004b08:	8a2a                	mv	s4,a0
    80004b0a:	a8a5                	j	80004b82 <filewrite+0xfe>
    80004b0c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b10:	00000097          	auipc	ra,0x0
    80004b14:	8aa080e7          	jalr	-1878(ra) # 800043ba <begin_op>
      ilock(f->ip);
    80004b18:	01893503          	ld	a0,24(s2)
    80004b1c:	fffff097          	auipc	ra,0xfffff
    80004b20:	edc080e7          	jalr	-292(ra) # 800039f8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b24:	8762                	mv	a4,s8
    80004b26:	02092683          	lw	a3,32(s2)
    80004b2a:	01598633          	add	a2,s3,s5
    80004b2e:	4585                	li	a1,1
    80004b30:	01893503          	ld	a0,24(s2)
    80004b34:	fffff097          	auipc	ra,0xfffff
    80004b38:	270080e7          	jalr	624(ra) # 80003da4 <writei>
    80004b3c:	84aa                	mv	s1,a0
    80004b3e:	00a05763          	blez	a0,80004b4c <filewrite+0xc8>
        f->off += r;
    80004b42:	02092783          	lw	a5,32(s2)
    80004b46:	9fa9                	addw	a5,a5,a0
    80004b48:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b4c:	01893503          	ld	a0,24(s2)
    80004b50:	fffff097          	auipc	ra,0xfffff
    80004b54:	f6a080e7          	jalr	-150(ra) # 80003aba <iunlock>
      end_op();
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	8e2080e7          	jalr	-1822(ra) # 8000443a <end_op>

      if(r != n1){
    80004b60:	009c1f63          	bne	s8,s1,80004b7e <filewrite+0xfa>
        // error from writei
        break;
      }
      i += r;
    80004b64:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b68:	0149db63          	bge	s3,s4,80004b7e <filewrite+0xfa>
      int n1 = n - i;
    80004b6c:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b70:	84be                	mv	s1,a5
    80004b72:	2781                	sext.w	a5,a5
    80004b74:	f8fb5ce3          	bge	s6,a5,80004b0c <filewrite+0x88>
    80004b78:	84de                	mv	s1,s7
    80004b7a:	bf49                	j	80004b0c <filewrite+0x88>
    int i = 0;
    80004b7c:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b7e:	013a1f63          	bne	s4,s3,80004b9c <filewrite+0x118>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b82:	8552                	mv	a0,s4
    80004b84:	60a6                	ld	ra,72(sp)
    80004b86:	6406                	ld	s0,64(sp)
    80004b88:	74e2                	ld	s1,56(sp)
    80004b8a:	7942                	ld	s2,48(sp)
    80004b8c:	79a2                	ld	s3,40(sp)
    80004b8e:	7a02                	ld	s4,32(sp)
    80004b90:	6ae2                	ld	s5,24(sp)
    80004b92:	6b42                	ld	s6,16(sp)
    80004b94:	6ba2                	ld	s7,8(sp)
    80004b96:	6c02                	ld	s8,0(sp)
    80004b98:	6161                	addi	sp,sp,80
    80004b9a:	8082                	ret
    ret = (i == n ? n : -1);
    80004b9c:	5a7d                	li	s4,-1
    80004b9e:	b7d5                	j	80004b82 <filewrite+0xfe>
    panic("filewrite");
    80004ba0:	00005517          	auipc	a0,0x5
    80004ba4:	0f050513          	addi	a0,a0,240 # 80009c90 <syscalls+0x278>
    80004ba8:	ffffc097          	auipc	ra,0xffffc
    80004bac:	9bc080e7          	jalr	-1604(ra) # 80000564 <panic>
    return -1;
    80004bb0:	5a7d                	li	s4,-1
    80004bb2:	bfc1                	j	80004b82 <filewrite+0xfe>
      return -1;
    80004bb4:	5a7d                	li	s4,-1
    80004bb6:	b7f1                	j	80004b82 <filewrite+0xfe>
    80004bb8:	5a7d                	li	s4,-1
    80004bba:	b7e1                	j	80004b82 <filewrite+0xfe>

0000000080004bbc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bbc:	7179                	addi	sp,sp,-48
    80004bbe:	f406                	sd	ra,40(sp)
    80004bc0:	f022                	sd	s0,32(sp)
    80004bc2:	ec26                	sd	s1,24(sp)
    80004bc4:	e84a                	sd	s2,16(sp)
    80004bc6:	e44e                	sd	s3,8(sp)
    80004bc8:	e052                	sd	s4,0(sp)
    80004bca:	1800                	addi	s0,sp,48
    80004bcc:	84aa                	mv	s1,a0
    80004bce:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bd0:	0005b023          	sd	zero,0(a1)
    80004bd4:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bd8:	00000097          	auipc	ra,0x0
    80004bdc:	bf0080e7          	jalr	-1040(ra) # 800047c8 <filealloc>
    80004be0:	e088                	sd	a0,0(s1)
    80004be2:	c551                	beqz	a0,80004c6e <pipealloc+0xb2>
    80004be4:	00000097          	auipc	ra,0x0
    80004be8:	be4080e7          	jalr	-1052(ra) # 800047c8 <filealloc>
    80004bec:	00aa3023          	sd	a0,0(s4)
    80004bf0:	c92d                	beqz	a0,80004c62 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	e50080e7          	jalr	-432(ra) # 80000a42 <kalloc>
    80004bfa:	892a                	mv	s2,a0
    80004bfc:	c125                	beqz	a0,80004c5c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004bfe:	4985                	li	s3,1
    80004c00:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004c04:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004c08:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004c0c:	22052023          	sw	zero,544(a0)
  initlock(&pi->lock, "pipe");
    80004c10:	00005597          	auipc	a1,0x5
    80004c14:	09058593          	addi	a1,a1,144 # 80009ca0 <syscalls+0x288>
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	ea4080e7          	jalr	-348(ra) # 80000abc <initlock>
  (*f0)->type = FD_PIPE;
    80004c20:	609c                	ld	a5,0(s1)
    80004c22:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c26:	609c                	ld	a5,0(s1)
    80004c28:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c2c:	609c                	ld	a5,0(s1)
    80004c2e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c32:	609c                	ld	a5,0(s1)
    80004c34:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c38:	000a3783          	ld	a5,0(s4)
    80004c3c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c40:	000a3783          	ld	a5,0(s4)
    80004c44:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c48:	000a3783          	ld	a5,0(s4)
    80004c4c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c50:	000a3783          	ld	a5,0(s4)
    80004c54:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c58:	4501                	li	a0,0
    80004c5a:	a025                	j	80004c82 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c5c:	6088                	ld	a0,0(s1)
    80004c5e:	e501                	bnez	a0,80004c66 <pipealloc+0xaa>
    80004c60:	a039                	j	80004c6e <pipealloc+0xb2>
    80004c62:	6088                	ld	a0,0(s1)
    80004c64:	c51d                	beqz	a0,80004c92 <pipealloc+0xd6>
    fileclose(*f0);
    80004c66:	00000097          	auipc	ra,0x0
    80004c6a:	c1e080e7          	jalr	-994(ra) # 80004884 <fileclose>
  if(*f1)
    80004c6e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c72:	557d                	li	a0,-1
  if(*f1)
    80004c74:	c799                	beqz	a5,80004c82 <pipealloc+0xc6>
    fileclose(*f1);
    80004c76:	853e                	mv	a0,a5
    80004c78:	00000097          	auipc	ra,0x0
    80004c7c:	c0c080e7          	jalr	-1012(ra) # 80004884 <fileclose>
  return -1;
    80004c80:	557d                	li	a0,-1
}
    80004c82:	70a2                	ld	ra,40(sp)
    80004c84:	7402                	ld	s0,32(sp)
    80004c86:	64e2                	ld	s1,24(sp)
    80004c88:	6942                	ld	s2,16(sp)
    80004c8a:	69a2                	ld	s3,8(sp)
    80004c8c:	6a02                	ld	s4,0(sp)
    80004c8e:	6145                	addi	sp,sp,48
    80004c90:	8082                	ret
  return -1;
    80004c92:	557d                	li	a0,-1
    80004c94:	b7fd                	j	80004c82 <pipealloc+0xc6>

0000000080004c96 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c96:	1101                	addi	sp,sp,-32
    80004c98:	ec06                	sd	ra,24(sp)
    80004c9a:	e822                	sd	s0,16(sp)
    80004c9c:	e426                	sd	s1,8(sp)
    80004c9e:	e04a                	sd	s2,0(sp)
    80004ca0:	1000                	addi	s0,sp,32
    80004ca2:	84aa                	mv	s1,a0
    80004ca4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	eec080e7          	jalr	-276(ra) # 80000b92 <acquire>
  if(writable){
    80004cae:	02090d63          	beqz	s2,80004ce8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004cb2:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004cb6:	22048513          	addi	a0,s1,544
    80004cba:	ffffe097          	auipc	ra,0xffffe
    80004cbe:	9dc080e7          	jalr	-1572(ra) # 80002696 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cc2:	2284b783          	ld	a5,552(s1)
    80004cc6:	eb95                	bnez	a5,80004cfa <pipeclose+0x64>
    release(&pi->lock);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	f98080e7          	jalr	-104(ra) # 80000c62 <release>
    kfree((char*)pi);
    80004cd2:	8526                	mv	a0,s1
    80004cd4:	ffffc097          	auipc	ra,0xffffc
    80004cd8:	c68080e7          	jalr	-920(ra) # 8000093c <kfree>
  } else
    release(&pi->lock);
}
    80004cdc:	60e2                	ld	ra,24(sp)
    80004cde:	6442                	ld	s0,16(sp)
    80004ce0:	64a2                	ld	s1,8(sp)
    80004ce2:	6902                	ld	s2,0(sp)
    80004ce4:	6105                	addi	sp,sp,32
    80004ce6:	8082                	ret
    pi->readopen = 0;
    80004ce8:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004cec:	22448513          	addi	a0,s1,548
    80004cf0:	ffffe097          	auipc	ra,0xffffe
    80004cf4:	9a6080e7          	jalr	-1626(ra) # 80002696 <wakeup>
    80004cf8:	b7e9                	j	80004cc2 <pipeclose+0x2c>
    release(&pi->lock);
    80004cfa:	8526                	mv	a0,s1
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	f66080e7          	jalr	-154(ra) # 80000c62 <release>
}
    80004d04:	bfe1                	j	80004cdc <pipeclose+0x46>

0000000080004d06 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d06:	711d                	addi	sp,sp,-96
    80004d08:	ec86                	sd	ra,88(sp)
    80004d0a:	e8a2                	sd	s0,80(sp)
    80004d0c:	e4a6                	sd	s1,72(sp)
    80004d0e:	e0ca                	sd	s2,64(sp)
    80004d10:	fc4e                	sd	s3,56(sp)
    80004d12:	f852                	sd	s4,48(sp)
    80004d14:	f456                	sd	s5,40(sp)
    80004d16:	f05a                	sd	s6,32(sp)
    80004d18:	ec5e                	sd	s7,24(sp)
    80004d1a:	e862                	sd	s8,16(sp)
    80004d1c:	1080                	addi	s0,sp,96
    80004d1e:	84aa                	mv	s1,a0
    80004d20:	8aae                	mv	s5,a1
    80004d22:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	e2c080e7          	jalr	-468(ra) # 80001b50 <myproc>
    80004d2c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	e62080e7          	jalr	-414(ra) # 80000b92 <acquire>
  while(i < n){
    80004d38:	0b405363          	blez	s4,80004dde <pipewrite+0xd8>
  int i = 0;
    80004d3c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d3e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d40:	22048c13          	addi	s8,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004d44:	22448b93          	addi	s7,s1,548
    80004d48:	a089                	j	80004d8a <pipewrite+0x84>
      release(&pi->lock);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	f16080e7          	jalr	-234(ra) # 80000c62 <release>
      return -1;
    80004d54:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d56:	854a                	mv	a0,s2
    80004d58:	60e6                	ld	ra,88(sp)
    80004d5a:	6446                	ld	s0,80(sp)
    80004d5c:	64a6                	ld	s1,72(sp)
    80004d5e:	6906                	ld	s2,64(sp)
    80004d60:	79e2                	ld	s3,56(sp)
    80004d62:	7a42                	ld	s4,48(sp)
    80004d64:	7aa2                	ld	s5,40(sp)
    80004d66:	7b02                	ld	s6,32(sp)
    80004d68:	6be2                	ld	s7,24(sp)
    80004d6a:	6c42                	ld	s8,16(sp)
    80004d6c:	6125                	addi	sp,sp,96
    80004d6e:	8082                	ret
      wakeup(&pi->nread);
    80004d70:	8562                	mv	a0,s8
    80004d72:	ffffe097          	auipc	ra,0xffffe
    80004d76:	924080e7          	jalr	-1756(ra) # 80002696 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d7a:	85a6                	mv	a1,s1
    80004d7c:	855e                	mv	a0,s7
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	75a080e7          	jalr	1882(ra) # 800024d8 <sleep>
  while(i < n){
    80004d86:	05495d63          	bge	s2,s4,80004de0 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004d8a:	2284a783          	lw	a5,552(s1)
    80004d8e:	dfd5                	beqz	a5,80004d4a <pipewrite+0x44>
    80004d90:	0389a783          	lw	a5,56(s3)
    80004d94:	fbdd                	bnez	a5,80004d4a <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d96:	2204a783          	lw	a5,544(s1)
    80004d9a:	2244a703          	lw	a4,548(s1)
    80004d9e:	2007879b          	addiw	a5,a5,512
    80004da2:	fcf707e3          	beq	a4,a5,80004d70 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004da6:	4685                	li	a3,1
    80004da8:	01590633          	add	a2,s2,s5
    80004dac:	faf40593          	addi	a1,s0,-81
    80004db0:	0589b503          	ld	a0,88(s3)
    80004db4:	ffffd097          	auipc	ra,0xffffd
    80004db8:	ad8080e7          	jalr	-1320(ra) # 8000188c <copyin>
    80004dbc:	03650263          	beq	a0,s6,80004de0 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dc0:	2244a783          	lw	a5,548(s1)
    80004dc4:	0017871b          	addiw	a4,a5,1
    80004dc8:	22e4a223          	sw	a4,548(s1)
    80004dcc:	1ff7f793          	andi	a5,a5,511
    80004dd0:	97a6                	add	a5,a5,s1
    80004dd2:	faf44703          	lbu	a4,-81(s0)
    80004dd6:	02e78023          	sb	a4,32(a5)
      i++;
    80004dda:	2905                	addiw	s2,s2,1
    80004ddc:	b76d                	j	80004d86 <pipewrite+0x80>
  int i = 0;
    80004dde:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004de0:	22048513          	addi	a0,s1,544
    80004de4:	ffffe097          	auipc	ra,0xffffe
    80004de8:	8b2080e7          	jalr	-1870(ra) # 80002696 <wakeup>
  release(&pi->lock);
    80004dec:	8526                	mv	a0,s1
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	e74080e7          	jalr	-396(ra) # 80000c62 <release>
  return i;
    80004df6:	b785                	j	80004d56 <pipewrite+0x50>

0000000080004df8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004df8:	715d                	addi	sp,sp,-80
    80004dfa:	e486                	sd	ra,72(sp)
    80004dfc:	e0a2                	sd	s0,64(sp)
    80004dfe:	fc26                	sd	s1,56(sp)
    80004e00:	f84a                	sd	s2,48(sp)
    80004e02:	f44e                	sd	s3,40(sp)
    80004e04:	f052                	sd	s4,32(sp)
    80004e06:	ec56                	sd	s5,24(sp)
    80004e08:	e85a                	sd	s6,16(sp)
    80004e0a:	0880                	addi	s0,sp,80
    80004e0c:	84aa                	mv	s1,a0
    80004e0e:	892e                	mv	s2,a1
    80004e10:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e12:	ffffd097          	auipc	ra,0xffffd
    80004e16:	d3e080e7          	jalr	-706(ra) # 80001b50 <myproc>
    80004e1a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	d74080e7          	jalr	-652(ra) # 80000b92 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e26:	2204a703          	lw	a4,544(s1)
    80004e2a:	2244a783          	lw	a5,548(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e2e:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e32:	02f71463          	bne	a4,a5,80004e5a <piperead+0x62>
    80004e36:	22c4a783          	lw	a5,556(s1)
    80004e3a:	c385                	beqz	a5,80004e5a <piperead+0x62>
    if(pr->killed){
    80004e3c:	038a2783          	lw	a5,56(s4)
    80004e40:	ebc1                	bnez	a5,80004ed0 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e42:	85a6                	mv	a1,s1
    80004e44:	854e                	mv	a0,s3
    80004e46:	ffffd097          	auipc	ra,0xffffd
    80004e4a:	692080e7          	jalr	1682(ra) # 800024d8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e4e:	2204a703          	lw	a4,544(s1)
    80004e52:	2244a783          	lw	a5,548(s1)
    80004e56:	fef700e3          	beq	a4,a5,80004e36 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e5a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e5c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e5e:	05505363          	blez	s5,80004ea4 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004e62:	2204a783          	lw	a5,544(s1)
    80004e66:	2244a703          	lw	a4,548(s1)
    80004e6a:	02f70d63          	beq	a4,a5,80004ea4 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e6e:	0017871b          	addiw	a4,a5,1
    80004e72:	22e4a023          	sw	a4,544(s1)
    80004e76:	1ff7f793          	andi	a5,a5,511
    80004e7a:	97a6                	add	a5,a5,s1
    80004e7c:	0207c783          	lbu	a5,32(a5)
    80004e80:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e84:	4685                	li	a3,1
    80004e86:	fbf40613          	addi	a2,s0,-65
    80004e8a:	85ca                	mv	a1,s2
    80004e8c:	058a3503          	ld	a0,88(s4)
    80004e90:	ffffd097          	auipc	ra,0xffffd
    80004e94:	970080e7          	jalr	-1680(ra) # 80001800 <copyout>
    80004e98:	01650663          	beq	a0,s6,80004ea4 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e9c:	2985                	addiw	s3,s3,1
    80004e9e:	0905                	addi	s2,s2,1
    80004ea0:	fd3a91e3          	bne	s5,s3,80004e62 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ea4:	22448513          	addi	a0,s1,548
    80004ea8:	ffffd097          	auipc	ra,0xffffd
    80004eac:	7ee080e7          	jalr	2030(ra) # 80002696 <wakeup>
  release(&pi->lock);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	db0080e7          	jalr	-592(ra) # 80000c62 <release>
  return i;
}
    80004eba:	854e                	mv	a0,s3
    80004ebc:	60a6                	ld	ra,72(sp)
    80004ebe:	6406                	ld	s0,64(sp)
    80004ec0:	74e2                	ld	s1,56(sp)
    80004ec2:	7942                	ld	s2,48(sp)
    80004ec4:	79a2                	ld	s3,40(sp)
    80004ec6:	7a02                	ld	s4,32(sp)
    80004ec8:	6ae2                	ld	s5,24(sp)
    80004eca:	6b42                	ld	s6,16(sp)
    80004ecc:	6161                	addi	sp,sp,80
    80004ece:	8082                	ret
      release(&pi->lock);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	ffffc097          	auipc	ra,0xffffc
    80004ed6:	d90080e7          	jalr	-624(ra) # 80000c62 <release>
      return -1;
    80004eda:	59fd                	li	s3,-1
    80004edc:	bff9                	j	80004eba <piperead+0xc2>

0000000080004ede <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ede:	de010113          	addi	sp,sp,-544
    80004ee2:	20113c23          	sd	ra,536(sp)
    80004ee6:	20813823          	sd	s0,528(sp)
    80004eea:	20913423          	sd	s1,520(sp)
    80004eee:	21213023          	sd	s2,512(sp)
    80004ef2:	ffce                	sd	s3,504(sp)
    80004ef4:	fbd2                	sd	s4,496(sp)
    80004ef6:	f7d6                	sd	s5,488(sp)
    80004ef8:	f3da                	sd	s6,480(sp)
    80004efa:	efde                	sd	s7,472(sp)
    80004efc:	ebe2                	sd	s8,464(sp)
    80004efe:	e7e6                	sd	s9,456(sp)
    80004f00:	e3ea                	sd	s10,448(sp)
    80004f02:	ff6e                	sd	s11,440(sp)
    80004f04:	1400                	addi	s0,sp,544
    80004f06:	892a                	mv	s2,a0
    80004f08:	dea43423          	sd	a0,-536(s0)
    80004f0c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f10:	ffffd097          	auipc	ra,0xffffd
    80004f14:	c40080e7          	jalr	-960(ra) # 80001b50 <myproc>
    80004f18:	84aa                	mv	s1,a0

  begin_op();
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	4a0080e7          	jalr	1184(ra) # 800043ba <begin_op>

  if((ip = namei(path)) == 0){
    80004f22:	854a                	mv	a0,s2
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	28a080e7          	jalr	650(ra) # 800041ae <namei>
    80004f2c:	c93d                	beqz	a0,80004fa2 <exec+0xc4>
    80004f2e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f30:	fffff097          	auipc	ra,0xfffff
    80004f34:	ac8080e7          	jalr	-1336(ra) # 800039f8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f38:	04000713          	li	a4,64
    80004f3c:	4681                	li	a3,0
    80004f3e:	e5040613          	addi	a2,s0,-432
    80004f42:	4581                	li	a1,0
    80004f44:	8556                	mv	a0,s5
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	d66080e7          	jalr	-666(ra) # 80003cac <readi>
    80004f4e:	04000793          	li	a5,64
    80004f52:	00f51a63          	bne	a0,a5,80004f66 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f56:	e5042703          	lw	a4,-432(s0)
    80004f5a:	464c47b7          	lui	a5,0x464c4
    80004f5e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f62:	04f70663          	beq	a4,a5,80004fae <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f66:	8556                	mv	a0,s5
    80004f68:	fffff097          	auipc	ra,0xfffff
    80004f6c:	cf2080e7          	jalr	-782(ra) # 80003c5a <iunlockput>
    end_op();
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	4ca080e7          	jalr	1226(ra) # 8000443a <end_op>
  }
  return -1;
    80004f78:	557d                	li	a0,-1
}
    80004f7a:	21813083          	ld	ra,536(sp)
    80004f7e:	21013403          	ld	s0,528(sp)
    80004f82:	20813483          	ld	s1,520(sp)
    80004f86:	20013903          	ld	s2,512(sp)
    80004f8a:	79fe                	ld	s3,504(sp)
    80004f8c:	7a5e                	ld	s4,496(sp)
    80004f8e:	7abe                	ld	s5,488(sp)
    80004f90:	7b1e                	ld	s6,480(sp)
    80004f92:	6bfe                	ld	s7,472(sp)
    80004f94:	6c5e                	ld	s8,464(sp)
    80004f96:	6cbe                	ld	s9,456(sp)
    80004f98:	6d1e                	ld	s10,448(sp)
    80004f9a:	7dfa                	ld	s11,440(sp)
    80004f9c:	22010113          	addi	sp,sp,544
    80004fa0:	8082                	ret
    end_op();
    80004fa2:	fffff097          	auipc	ra,0xfffff
    80004fa6:	498080e7          	jalr	1176(ra) # 8000443a <end_op>
    return -1;
    80004faa:	557d                	li	a0,-1
    80004fac:	b7f9                	j	80004f7a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004fae:	8526                	mv	a0,s1
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	c64080e7          	jalr	-924(ra) # 80001c14 <proc_pagetable>
    80004fb8:	8b2a                	mv	s6,a0
    80004fba:	d555                	beqz	a0,80004f66 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fbc:	e7042783          	lw	a5,-400(s0)
    80004fc0:	e8845703          	lhu	a4,-376(s0)
    80004fc4:	c735                	beqz	a4,80005030 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fc6:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fc8:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004fcc:	6a05                	lui	s4,0x1
    80004fce:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fd2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004fd6:	6d85                	lui	s11,0x1
    80004fd8:	7d7d                	lui	s10,0xfffff
    80004fda:	ac1d                	j	80005210 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fdc:	00005517          	auipc	a0,0x5
    80004fe0:	ccc50513          	addi	a0,a0,-820 # 80009ca8 <syscalls+0x290>
    80004fe4:	ffffb097          	auipc	ra,0xffffb
    80004fe8:	580080e7          	jalr	1408(ra) # 80000564 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fec:	874a                	mv	a4,s2
    80004fee:	009c86bb          	addw	a3,s9,s1
    80004ff2:	4581                	li	a1,0
    80004ff4:	8556                	mv	a0,s5
    80004ff6:	fffff097          	auipc	ra,0xfffff
    80004ffa:	cb6080e7          	jalr	-842(ra) # 80003cac <readi>
    80004ffe:	2501                	sext.w	a0,a0
    80005000:	1aa91863          	bne	s2,a0,800051b0 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80005004:	009d84bb          	addw	s1,s11,s1
    80005008:	013d09bb          	addw	s3,s10,s3
    8000500c:	1f74f263          	bgeu	s1,s7,800051f0 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80005010:	02049593          	slli	a1,s1,0x20
    80005014:	9181                	srli	a1,a1,0x20
    80005016:	95e2                	add	a1,a1,s8
    80005018:	855a                	mv	a0,s6
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	278080e7          	jalr	632(ra) # 80001292 <walkaddr>
    80005022:	862a                	mv	a2,a0
    if(pa == 0)
    80005024:	dd45                	beqz	a0,80004fdc <exec+0xfe>
      n = PGSIZE;
    80005026:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005028:	fd49f2e3          	bgeu	s3,s4,80004fec <exec+0x10e>
      n = sz - i;
    8000502c:	894e                	mv	s2,s3
    8000502e:	bf7d                	j	80004fec <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005030:	4481                	li	s1,0
  iunlockput(ip);
    80005032:	8556                	mv	a0,s5
    80005034:	fffff097          	auipc	ra,0xfffff
    80005038:	c26080e7          	jalr	-986(ra) # 80003c5a <iunlockput>
  end_op();
    8000503c:	fffff097          	auipc	ra,0xfffff
    80005040:	3fe080e7          	jalr	1022(ra) # 8000443a <end_op>
  p = myproc();
    80005044:	ffffd097          	auipc	ra,0xffffd
    80005048:	b0c080e7          	jalr	-1268(ra) # 80001b50 <myproc>
    8000504c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000504e:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005052:	6785                	lui	a5,0x1
    80005054:	17fd                	addi	a5,a5,-1
    80005056:	94be                	add	s1,s1,a5
    80005058:	77fd                	lui	a5,0xfffff
    8000505a:	8fe5                	and	a5,a5,s1
    8000505c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005060:	6609                	lui	a2,0x2
    80005062:	963e                	add	a2,a2,a5
    80005064:	85be                	mv	a1,a5
    80005066:	855a                	mv	a0,s6
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	5be080e7          	jalr	1470(ra) # 80001626 <uvmalloc>
    80005070:	8c2a                	mv	s8,a0
  ip = 0;
    80005072:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005074:	12050e63          	beqz	a0,800051b0 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005078:	75f9                	lui	a1,0xffffe
    8000507a:	95aa                	add	a1,a1,a0
    8000507c:	855a                	mv	a0,s6
    8000507e:	ffffc097          	auipc	ra,0xffffc
    80005082:	750080e7          	jalr	1872(ra) # 800017ce <uvmclear>
  stackbase = sp - PGSIZE;
    80005086:	7afd                	lui	s5,0xfffff
    80005088:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000508a:	df043783          	ld	a5,-528(s0)
    8000508e:	6388                	ld	a0,0(a5)
    80005090:	c925                	beqz	a0,80005100 <exec+0x222>
    80005092:	e9040993          	addi	s3,s0,-368
    80005096:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000509a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000509c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	f80080e7          	jalr	-128(ra) # 8000101e <strlen>
    800050a6:	0015079b          	addiw	a5,a0,1
    800050aa:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050ae:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050b2:	13596363          	bltu	s2,s5,800051d8 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050b6:	df043d83          	ld	s11,-528(s0)
    800050ba:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800050be:	8552                	mv	a0,s4
    800050c0:	ffffc097          	auipc	ra,0xffffc
    800050c4:	f5e080e7          	jalr	-162(ra) # 8000101e <strlen>
    800050c8:	0015069b          	addiw	a3,a0,1
    800050cc:	8652                	mv	a2,s4
    800050ce:	85ca                	mv	a1,s2
    800050d0:	855a                	mv	a0,s6
    800050d2:	ffffc097          	auipc	ra,0xffffc
    800050d6:	72e080e7          	jalr	1838(ra) # 80001800 <copyout>
    800050da:	10054363          	bltz	a0,800051e0 <exec+0x302>
    ustack[argc] = sp;
    800050de:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050e2:	0485                	addi	s1,s1,1
    800050e4:	008d8793          	addi	a5,s11,8
    800050e8:	def43823          	sd	a5,-528(s0)
    800050ec:	008db503          	ld	a0,8(s11)
    800050f0:	c911                	beqz	a0,80005104 <exec+0x226>
    if(argc >= MAXARG)
    800050f2:	09a1                	addi	s3,s3,8
    800050f4:	fb3c95e3          	bne	s9,s3,8000509e <exec+0x1c0>
  sz = sz1;
    800050f8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050fc:	4a81                	li	s5,0
    800050fe:	a84d                	j	800051b0 <exec+0x2d2>
  sp = sz;
    80005100:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005102:	4481                	li	s1,0
  ustack[argc] = 0;
    80005104:	00349793          	slli	a5,s1,0x3
    80005108:	f9040713          	addi	a4,s0,-112
    8000510c:	97ba                	add	a5,a5,a4
    8000510e:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffc6b40>
  sp -= (argc+1) * sizeof(uint64);
    80005112:	00148693          	addi	a3,s1,1
    80005116:	068e                	slli	a3,a3,0x3
    80005118:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000511c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005120:	01597663          	bgeu	s2,s5,8000512c <exec+0x24e>
  sz = sz1;
    80005124:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005128:	4a81                	li	s5,0
    8000512a:	a059                	j	800051b0 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000512c:	e9040613          	addi	a2,s0,-368
    80005130:	85ca                	mv	a1,s2
    80005132:	855a                	mv	a0,s6
    80005134:	ffffc097          	auipc	ra,0xffffc
    80005138:	6cc080e7          	jalr	1740(ra) # 80001800 <copyout>
    8000513c:	0a054663          	bltz	a0,800051e8 <exec+0x30a>
  p->trapframe->a1 = sp;
    80005140:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    80005144:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005148:	de843783          	ld	a5,-536(s0)
    8000514c:	0007c703          	lbu	a4,0(a5)
    80005150:	cf11                	beqz	a4,8000516c <exec+0x28e>
    80005152:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005154:	02f00693          	li	a3,47
    80005158:	a039                	j	80005166 <exec+0x288>
      last = s+1;
    8000515a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000515e:	0785                	addi	a5,a5,1
    80005160:	fff7c703          	lbu	a4,-1(a5)
    80005164:	c701                	beqz	a4,8000516c <exec+0x28e>
    if(*s == '/')
    80005166:	fed71ce3          	bne	a4,a3,8000515e <exec+0x280>
    8000516a:	bfc5                	j	8000515a <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    8000516c:	4641                	li	a2,16
    8000516e:	de843583          	ld	a1,-536(s0)
    80005172:	160b8513          	addi	a0,s7,352
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	e76080e7          	jalr	-394(ra) # 80000fec <safestrcpy>
  oldpagetable = p->pagetable;
    8000517e:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005182:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005186:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000518a:	060bb783          	ld	a5,96(s7)
    8000518e:	e6843703          	ld	a4,-408(s0)
    80005192:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005194:	060bb783          	ld	a5,96(s7)
    80005198:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000519c:	85ea                	mv	a1,s10
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	baa080e7          	jalr	-1110(ra) # 80001d48 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051a6:	0004851b          	sext.w	a0,s1
    800051aa:	bbc1                	j	80004f7a <exec+0x9c>
    800051ac:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    800051b0:	df843583          	ld	a1,-520(s0)
    800051b4:	855a                	mv	a0,s6
    800051b6:	ffffd097          	auipc	ra,0xffffd
    800051ba:	b92080e7          	jalr	-1134(ra) # 80001d48 <proc_freepagetable>
  if(ip){
    800051be:	da0a94e3          	bnez	s5,80004f66 <exec+0x88>
  return -1;
    800051c2:	557d                	li	a0,-1
    800051c4:	bb5d                	j	80004f7a <exec+0x9c>
    800051c6:	de943c23          	sd	s1,-520(s0)
    800051ca:	b7dd                	j	800051b0 <exec+0x2d2>
    800051cc:	de943c23          	sd	s1,-520(s0)
    800051d0:	b7c5                	j	800051b0 <exec+0x2d2>
    800051d2:	de943c23          	sd	s1,-520(s0)
    800051d6:	bfe9                	j	800051b0 <exec+0x2d2>
  sz = sz1;
    800051d8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051dc:	4a81                	li	s5,0
    800051de:	bfc9                	j	800051b0 <exec+0x2d2>
  sz = sz1;
    800051e0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051e4:	4a81                	li	s5,0
    800051e6:	b7e9                	j	800051b0 <exec+0x2d2>
  sz = sz1;
    800051e8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051ec:	4a81                	li	s5,0
    800051ee:	b7c9                	j	800051b0 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051f0:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051f4:	e0843783          	ld	a5,-504(s0)
    800051f8:	0017869b          	addiw	a3,a5,1
    800051fc:	e0d43423          	sd	a3,-504(s0)
    80005200:	e0043783          	ld	a5,-512(s0)
    80005204:	0387879b          	addiw	a5,a5,56
    80005208:	e8845703          	lhu	a4,-376(s0)
    8000520c:	e2e6d3e3          	bge	a3,a4,80005032 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005210:	2781                	sext.w	a5,a5
    80005212:	e0f43023          	sd	a5,-512(s0)
    80005216:	03800713          	li	a4,56
    8000521a:	86be                	mv	a3,a5
    8000521c:	e1840613          	addi	a2,s0,-488
    80005220:	4581                	li	a1,0
    80005222:	8556                	mv	a0,s5
    80005224:	fffff097          	auipc	ra,0xfffff
    80005228:	a88080e7          	jalr	-1400(ra) # 80003cac <readi>
    8000522c:	03800793          	li	a5,56
    80005230:	f6f51ee3          	bne	a0,a5,800051ac <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005234:	e1842783          	lw	a5,-488(s0)
    80005238:	4705                	li	a4,1
    8000523a:	fae79de3          	bne	a5,a4,800051f4 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000523e:	e4043603          	ld	a2,-448(s0)
    80005242:	e3843783          	ld	a5,-456(s0)
    80005246:	f8f660e3          	bltu	a2,a5,800051c6 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000524a:	e2843783          	ld	a5,-472(s0)
    8000524e:	963e                	add	a2,a2,a5
    80005250:	f6f66ee3          	bltu	a2,a5,800051cc <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005254:	85a6                	mv	a1,s1
    80005256:	855a                	mv	a0,s6
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	3ce080e7          	jalr	974(ra) # 80001626 <uvmalloc>
    80005260:	dea43c23          	sd	a0,-520(s0)
    80005264:	d53d                	beqz	a0,800051d2 <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    80005266:	e2843c03          	ld	s8,-472(s0)
    8000526a:	de043783          	ld	a5,-544(s0)
    8000526e:	00fc77b3          	and	a5,s8,a5
    80005272:	ff9d                	bnez	a5,800051b0 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005274:	e2042c83          	lw	s9,-480(s0)
    80005278:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000527c:	f60b8ae3          	beqz	s7,800051f0 <exec+0x312>
    80005280:	89de                	mv	s3,s7
    80005282:	4481                	li	s1,0
    80005284:	b371                	j	80005010 <exec+0x132>

0000000080005286 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005286:	7179                	addi	sp,sp,-48
    80005288:	f406                	sd	ra,40(sp)
    8000528a:	f022                	sd	s0,32(sp)
    8000528c:	ec26                	sd	s1,24(sp)
    8000528e:	e84a                	sd	s2,16(sp)
    80005290:	1800                	addi	s0,sp,48
    80005292:	892e                	mv	s2,a1
    80005294:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005296:	fdc40593          	addi	a1,s0,-36
    8000529a:	ffffe097          	auipc	ra,0xffffe
    8000529e:	bee080e7          	jalr	-1042(ra) # 80002e88 <argint>
    800052a2:	04054063          	bltz	a0,800052e2 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052a6:	fdc42703          	lw	a4,-36(s0)
    800052aa:	47bd                	li	a5,15
    800052ac:	02e7ed63          	bltu	a5,a4,800052e6 <argfd+0x60>
    800052b0:	ffffd097          	auipc	ra,0xffffd
    800052b4:	8a0080e7          	jalr	-1888(ra) # 80001b50 <myproc>
    800052b8:	fdc42703          	lw	a4,-36(s0)
    800052bc:	01a70793          	addi	a5,a4,26
    800052c0:	078e                	slli	a5,a5,0x3
    800052c2:	953e                	add	a0,a0,a5
    800052c4:	651c                	ld	a5,8(a0)
    800052c6:	c395                	beqz	a5,800052ea <argfd+0x64>
    return -1;
  if(pfd)
    800052c8:	00090463          	beqz	s2,800052d0 <argfd+0x4a>
    *pfd = fd;
    800052cc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052d0:	4501                	li	a0,0
  if(pf)
    800052d2:	c091                	beqz	s1,800052d6 <argfd+0x50>
    *pf = f;
    800052d4:	e09c                	sd	a5,0(s1)
}
    800052d6:	70a2                	ld	ra,40(sp)
    800052d8:	7402                	ld	s0,32(sp)
    800052da:	64e2                	ld	s1,24(sp)
    800052dc:	6942                	ld	s2,16(sp)
    800052de:	6145                	addi	sp,sp,48
    800052e0:	8082                	ret
    return -1;
    800052e2:	557d                	li	a0,-1
    800052e4:	bfcd                	j	800052d6 <argfd+0x50>
    return -1;
    800052e6:	557d                	li	a0,-1
    800052e8:	b7fd                	j	800052d6 <argfd+0x50>
    800052ea:	557d                	li	a0,-1
    800052ec:	b7ed                	j	800052d6 <argfd+0x50>

00000000800052ee <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052ee:	1101                	addi	sp,sp,-32
    800052f0:	ec06                	sd	ra,24(sp)
    800052f2:	e822                	sd	s0,16(sp)
    800052f4:	e426                	sd	s1,8(sp)
    800052f6:	1000                	addi	s0,sp,32
    800052f8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052fa:	ffffd097          	auipc	ra,0xffffd
    800052fe:	856080e7          	jalr	-1962(ra) # 80001b50 <myproc>
    80005302:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005304:	0d850793          	addi	a5,a0,216
    80005308:	4501                	li	a0,0
    8000530a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000530c:	6398                	ld	a4,0(a5)
    8000530e:	cb19                	beqz	a4,80005324 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005310:	2505                	addiw	a0,a0,1
    80005312:	07a1                	addi	a5,a5,8
    80005314:	fed51ce3          	bne	a0,a3,8000530c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005318:	557d                	li	a0,-1
}
    8000531a:	60e2                	ld	ra,24(sp)
    8000531c:	6442                	ld	s0,16(sp)
    8000531e:	64a2                	ld	s1,8(sp)
    80005320:	6105                	addi	sp,sp,32
    80005322:	8082                	ret
      p->ofile[fd] = f;
    80005324:	01a50793          	addi	a5,a0,26
    80005328:	078e                	slli	a5,a5,0x3
    8000532a:	963e                	add	a2,a2,a5
    8000532c:	e604                	sd	s1,8(a2)
      return fd;
    8000532e:	b7f5                	j	8000531a <fdalloc+0x2c>

0000000080005330 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005330:	715d                	addi	sp,sp,-80
    80005332:	e486                	sd	ra,72(sp)
    80005334:	e0a2                	sd	s0,64(sp)
    80005336:	fc26                	sd	s1,56(sp)
    80005338:	f84a                	sd	s2,48(sp)
    8000533a:	f44e                	sd	s3,40(sp)
    8000533c:	f052                	sd	s4,32(sp)
    8000533e:	ec56                	sd	s5,24(sp)
    80005340:	0880                	addi	s0,sp,80
    80005342:	89ae                	mv	s3,a1
    80005344:	8ab2                	mv	s5,a2
    80005346:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005348:	fb040593          	addi	a1,s0,-80
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	e80080e7          	jalr	-384(ra) # 800041cc <nameiparent>
    80005354:	892a                	mv	s2,a0
    80005356:	12050e63          	beqz	a0,80005492 <create+0x162>
    return 0;

  ilock(dp);
    8000535a:	ffffe097          	auipc	ra,0xffffe
    8000535e:	69e080e7          	jalr	1694(ra) # 800039f8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005362:	4601                	li	a2,0
    80005364:	fb040593          	addi	a1,s0,-80
    80005368:	854a                	mv	a0,s2
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	b72080e7          	jalr	-1166(ra) # 80003edc <dirlookup>
    80005372:	84aa                	mv	s1,a0
    80005374:	c921                	beqz	a0,800053c4 <create+0x94>
    iunlockput(dp);
    80005376:	854a                	mv	a0,s2
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	8e2080e7          	jalr	-1822(ra) # 80003c5a <iunlockput>
    ilock(ip);
    80005380:	8526                	mv	a0,s1
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	676080e7          	jalr	1654(ra) # 800039f8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000538a:	2981                	sext.w	s3,s3
    8000538c:	4789                	li	a5,2
    8000538e:	02f99463          	bne	s3,a5,800053b6 <create+0x86>
    80005392:	04c4d783          	lhu	a5,76(s1)
    80005396:	37f9                	addiw	a5,a5,-2
    80005398:	17c2                	slli	a5,a5,0x30
    8000539a:	93c1                	srli	a5,a5,0x30
    8000539c:	4705                	li	a4,1
    8000539e:	00f76c63          	bltu	a4,a5,800053b6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800053a2:	8526                	mv	a0,s1
    800053a4:	60a6                	ld	ra,72(sp)
    800053a6:	6406                	ld	s0,64(sp)
    800053a8:	74e2                	ld	s1,56(sp)
    800053aa:	7942                	ld	s2,48(sp)
    800053ac:	79a2                	ld	s3,40(sp)
    800053ae:	7a02                	ld	s4,32(sp)
    800053b0:	6ae2                	ld	s5,24(sp)
    800053b2:	6161                	addi	sp,sp,80
    800053b4:	8082                	ret
    iunlockput(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	8a2080e7          	jalr	-1886(ra) # 80003c5a <iunlockput>
    return 0;
    800053c0:	4481                	li	s1,0
    800053c2:	b7c5                	j	800053a2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800053c4:	85ce                	mv	a1,s3
    800053c6:	00092503          	lw	a0,0(s2)
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	496080e7          	jalr	1174(ra) # 80003860 <ialloc>
    800053d2:	84aa                	mv	s1,a0
    800053d4:	c521                	beqz	a0,8000541c <create+0xec>
  ilock(ip);
    800053d6:	ffffe097          	auipc	ra,0xffffe
    800053da:	622080e7          	jalr	1570(ra) # 800039f8 <ilock>
  ip->major = major;
    800053de:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800053e2:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800053e6:	4a05                	li	s4,1
    800053e8:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800053ec:	8526                	mv	a0,s1
    800053ee:	ffffe097          	auipc	ra,0xffffe
    800053f2:	540080e7          	jalr	1344(ra) # 8000392e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053f6:	2981                	sext.w	s3,s3
    800053f8:	03498a63          	beq	s3,s4,8000542c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053fc:	40d0                	lw	a2,4(s1)
    800053fe:	fb040593          	addi	a1,s0,-80
    80005402:	854a                	mv	a0,s2
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	ce8080e7          	jalr	-792(ra) # 800040ec <dirlink>
    8000540c:	06054b63          	bltz	a0,80005482 <create+0x152>
  iunlockput(dp);
    80005410:	854a                	mv	a0,s2
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	848080e7          	jalr	-1976(ra) # 80003c5a <iunlockput>
  return ip;
    8000541a:	b761                	j	800053a2 <create+0x72>
    panic("create: ialloc");
    8000541c:	00005517          	auipc	a0,0x5
    80005420:	8ac50513          	addi	a0,a0,-1876 # 80009cc8 <syscalls+0x2b0>
    80005424:	ffffb097          	auipc	ra,0xffffb
    80005428:	140080e7          	jalr	320(ra) # 80000564 <panic>
    dp->nlink++;  // for ".."
    8000542c:	05295783          	lhu	a5,82(s2)
    80005430:	2785                	addiw	a5,a5,1
    80005432:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005436:	854a                	mv	a0,s2
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	4f6080e7          	jalr	1270(ra) # 8000392e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005440:	40d0                	lw	a2,4(s1)
    80005442:	00005597          	auipc	a1,0x5
    80005446:	89658593          	addi	a1,a1,-1898 # 80009cd8 <syscalls+0x2c0>
    8000544a:	8526                	mv	a0,s1
    8000544c:	fffff097          	auipc	ra,0xfffff
    80005450:	ca0080e7          	jalr	-864(ra) # 800040ec <dirlink>
    80005454:	00054f63          	bltz	a0,80005472 <create+0x142>
    80005458:	00492603          	lw	a2,4(s2)
    8000545c:	00005597          	auipc	a1,0x5
    80005460:	88458593          	addi	a1,a1,-1916 # 80009ce0 <syscalls+0x2c8>
    80005464:	8526                	mv	a0,s1
    80005466:	fffff097          	auipc	ra,0xfffff
    8000546a:	c86080e7          	jalr	-890(ra) # 800040ec <dirlink>
    8000546e:	f80557e3          	bgez	a0,800053fc <create+0xcc>
      panic("create dots");
    80005472:	00005517          	auipc	a0,0x5
    80005476:	87650513          	addi	a0,a0,-1930 # 80009ce8 <syscalls+0x2d0>
    8000547a:	ffffb097          	auipc	ra,0xffffb
    8000547e:	0ea080e7          	jalr	234(ra) # 80000564 <panic>
    panic("create: dirlink");
    80005482:	00005517          	auipc	a0,0x5
    80005486:	87650513          	addi	a0,a0,-1930 # 80009cf8 <syscalls+0x2e0>
    8000548a:	ffffb097          	auipc	ra,0xffffb
    8000548e:	0da080e7          	jalr	218(ra) # 80000564 <panic>
    return 0;
    80005492:	84aa                	mv	s1,a0
    80005494:	b739                	j	800053a2 <create+0x72>

0000000080005496 <sys_dup>:
{
    80005496:	7179                	addi	sp,sp,-48
    80005498:	f406                	sd	ra,40(sp)
    8000549a:	f022                	sd	s0,32(sp)
    8000549c:	ec26                	sd	s1,24(sp)
    8000549e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054a0:	fd840613          	addi	a2,s0,-40
    800054a4:	4581                	li	a1,0
    800054a6:	4501                	li	a0,0
    800054a8:	00000097          	auipc	ra,0x0
    800054ac:	dde080e7          	jalr	-546(ra) # 80005286 <argfd>
    return -1;
    800054b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054b2:	02054363          	bltz	a0,800054d8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800054b6:	fd843503          	ld	a0,-40(s0)
    800054ba:	00000097          	auipc	ra,0x0
    800054be:	e34080e7          	jalr	-460(ra) # 800052ee <fdalloc>
    800054c2:	84aa                	mv	s1,a0
    return -1;
    800054c4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054c6:	00054963          	bltz	a0,800054d8 <sys_dup+0x42>
  filedup(f);
    800054ca:	fd843503          	ld	a0,-40(s0)
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	364080e7          	jalr	868(ra) # 80004832 <filedup>
  return fd;
    800054d6:	87a6                	mv	a5,s1
}
    800054d8:	853e                	mv	a0,a5
    800054da:	70a2                	ld	ra,40(sp)
    800054dc:	7402                	ld	s0,32(sp)
    800054de:	64e2                	ld	s1,24(sp)
    800054e0:	6145                	addi	sp,sp,48
    800054e2:	8082                	ret

00000000800054e4 <sys_read>:
{
    800054e4:	7179                	addi	sp,sp,-48
    800054e6:	f406                	sd	ra,40(sp)
    800054e8:	f022                	sd	s0,32(sp)
    800054ea:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ec:	fe840613          	addi	a2,s0,-24
    800054f0:	4581                	li	a1,0
    800054f2:	4501                	li	a0,0
    800054f4:	00000097          	auipc	ra,0x0
    800054f8:	d92080e7          	jalr	-622(ra) # 80005286 <argfd>
    return -1;
    800054fc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054fe:	04054163          	bltz	a0,80005540 <sys_read+0x5c>
    80005502:	fe440593          	addi	a1,s0,-28
    80005506:	4509                	li	a0,2
    80005508:	ffffe097          	auipc	ra,0xffffe
    8000550c:	980080e7          	jalr	-1664(ra) # 80002e88 <argint>
    return -1;
    80005510:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005512:	02054763          	bltz	a0,80005540 <sys_read+0x5c>
    80005516:	fd840593          	addi	a1,s0,-40
    8000551a:	4505                	li	a0,1
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	98e080e7          	jalr	-1650(ra) # 80002eaa <argaddr>
    return -1;
    80005524:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005526:	00054d63          	bltz	a0,80005540 <sys_read+0x5c>
  return fileread(f, p, n);
    8000552a:	fe442603          	lw	a2,-28(s0)
    8000552e:	fd843583          	ld	a1,-40(s0)
    80005532:	fe843503          	ld	a0,-24(s0)
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	488080e7          	jalr	1160(ra) # 800049be <fileread>
    8000553e:	87aa                	mv	a5,a0
}
    80005540:	853e                	mv	a0,a5
    80005542:	70a2                	ld	ra,40(sp)
    80005544:	7402                	ld	s0,32(sp)
    80005546:	6145                	addi	sp,sp,48
    80005548:	8082                	ret

000000008000554a <sys_write>:
{
    8000554a:	7179                	addi	sp,sp,-48
    8000554c:	f406                	sd	ra,40(sp)
    8000554e:	f022                	sd	s0,32(sp)
    80005550:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005552:	fe840613          	addi	a2,s0,-24
    80005556:	4581                	li	a1,0
    80005558:	4501                	li	a0,0
    8000555a:	00000097          	auipc	ra,0x0
    8000555e:	d2c080e7          	jalr	-724(ra) # 80005286 <argfd>
    return -1;
    80005562:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005564:	04054163          	bltz	a0,800055a6 <sys_write+0x5c>
    80005568:	fe440593          	addi	a1,s0,-28
    8000556c:	4509                	li	a0,2
    8000556e:	ffffe097          	auipc	ra,0xffffe
    80005572:	91a080e7          	jalr	-1766(ra) # 80002e88 <argint>
    return -1;
    80005576:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005578:	02054763          	bltz	a0,800055a6 <sys_write+0x5c>
    8000557c:	fd840593          	addi	a1,s0,-40
    80005580:	4505                	li	a0,1
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	928080e7          	jalr	-1752(ra) # 80002eaa <argaddr>
    return -1;
    8000558a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000558c:	00054d63          	bltz	a0,800055a6 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005590:	fe442603          	lw	a2,-28(s0)
    80005594:	fd843583          	ld	a1,-40(s0)
    80005598:	fe843503          	ld	a0,-24(s0)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	4e8080e7          	jalr	1256(ra) # 80004a84 <filewrite>
    800055a4:	87aa                	mv	a5,a0
}
    800055a6:	853e                	mv	a0,a5
    800055a8:	70a2                	ld	ra,40(sp)
    800055aa:	7402                	ld	s0,32(sp)
    800055ac:	6145                	addi	sp,sp,48
    800055ae:	8082                	ret

00000000800055b0 <sys_close>:
{
    800055b0:	1101                	addi	sp,sp,-32
    800055b2:	ec06                	sd	ra,24(sp)
    800055b4:	e822                	sd	s0,16(sp)
    800055b6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055b8:	fe040613          	addi	a2,s0,-32
    800055bc:	fec40593          	addi	a1,s0,-20
    800055c0:	4501                	li	a0,0
    800055c2:	00000097          	auipc	ra,0x0
    800055c6:	cc4080e7          	jalr	-828(ra) # 80005286 <argfd>
    return -1;
    800055ca:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055cc:	02054463          	bltz	a0,800055f4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055d0:	ffffc097          	auipc	ra,0xffffc
    800055d4:	580080e7          	jalr	1408(ra) # 80001b50 <myproc>
    800055d8:	fec42783          	lw	a5,-20(s0)
    800055dc:	07e9                	addi	a5,a5,26
    800055de:	078e                	slli	a5,a5,0x3
    800055e0:	97aa                	add	a5,a5,a0
    800055e2:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800055e6:	fe043503          	ld	a0,-32(s0)
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	29a080e7          	jalr	666(ra) # 80004884 <fileclose>
  return 0;
    800055f2:	4781                	li	a5,0
}
    800055f4:	853e                	mv	a0,a5
    800055f6:	60e2                	ld	ra,24(sp)
    800055f8:	6442                	ld	s0,16(sp)
    800055fa:	6105                	addi	sp,sp,32
    800055fc:	8082                	ret

00000000800055fe <sys_fstat>:
{
    800055fe:	1101                	addi	sp,sp,-32
    80005600:	ec06                	sd	ra,24(sp)
    80005602:	e822                	sd	s0,16(sp)
    80005604:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005606:	fe840613          	addi	a2,s0,-24
    8000560a:	4581                	li	a1,0
    8000560c:	4501                	li	a0,0
    8000560e:	00000097          	auipc	ra,0x0
    80005612:	c78080e7          	jalr	-904(ra) # 80005286 <argfd>
    return -1;
    80005616:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005618:	02054563          	bltz	a0,80005642 <sys_fstat+0x44>
    8000561c:	fe040593          	addi	a1,s0,-32
    80005620:	4505                	li	a0,1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	888080e7          	jalr	-1912(ra) # 80002eaa <argaddr>
    return -1;
    8000562a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000562c:	00054b63          	bltz	a0,80005642 <sys_fstat+0x44>
  return filestat(f, st);
    80005630:	fe043583          	ld	a1,-32(s0)
    80005634:	fe843503          	ld	a0,-24(s0)
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	314080e7          	jalr	788(ra) # 8000494c <filestat>
    80005640:	87aa                	mv	a5,a0
}
    80005642:	853e                	mv	a0,a5
    80005644:	60e2                	ld	ra,24(sp)
    80005646:	6442                	ld	s0,16(sp)
    80005648:	6105                	addi	sp,sp,32
    8000564a:	8082                	ret

000000008000564c <sys_link>:
{
    8000564c:	7169                	addi	sp,sp,-304
    8000564e:	f606                	sd	ra,296(sp)
    80005650:	f222                	sd	s0,288(sp)
    80005652:	ee26                	sd	s1,280(sp)
    80005654:	ea4a                	sd	s2,272(sp)
    80005656:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005658:	08000613          	li	a2,128
    8000565c:	ed040593          	addi	a1,s0,-304
    80005660:	4501                	li	a0,0
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	86a080e7          	jalr	-1942(ra) # 80002ecc <argstr>
    return -1;
    8000566a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000566c:	10054e63          	bltz	a0,80005788 <sys_link+0x13c>
    80005670:	08000613          	li	a2,128
    80005674:	f5040593          	addi	a1,s0,-176
    80005678:	4505                	li	a0,1
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	852080e7          	jalr	-1966(ra) # 80002ecc <argstr>
    return -1;
    80005682:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005684:	10054263          	bltz	a0,80005788 <sys_link+0x13c>
  begin_op();
    80005688:	fffff097          	auipc	ra,0xfffff
    8000568c:	d32080e7          	jalr	-718(ra) # 800043ba <begin_op>
  if((ip = namei(old)) == 0){
    80005690:	ed040513          	addi	a0,s0,-304
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	b1a080e7          	jalr	-1254(ra) # 800041ae <namei>
    8000569c:	84aa                	mv	s1,a0
    8000569e:	c551                	beqz	a0,8000572a <sys_link+0xde>
  ilock(ip);
    800056a0:	ffffe097          	auipc	ra,0xffffe
    800056a4:	358080e7          	jalr	856(ra) # 800039f8 <ilock>
  if(ip->type == T_DIR){
    800056a8:	04c49703          	lh	a4,76(s1)
    800056ac:	4785                	li	a5,1
    800056ae:	08f70463          	beq	a4,a5,80005736 <sys_link+0xea>
  ip->nlink++;
    800056b2:	0524d783          	lhu	a5,82(s1)
    800056b6:	2785                	addiw	a5,a5,1
    800056b8:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800056bc:	8526                	mv	a0,s1
    800056be:	ffffe097          	auipc	ra,0xffffe
    800056c2:	270080e7          	jalr	624(ra) # 8000392e <iupdate>
  iunlock(ip);
    800056c6:	8526                	mv	a0,s1
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	3f2080e7          	jalr	1010(ra) # 80003aba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056d0:	fd040593          	addi	a1,s0,-48
    800056d4:	f5040513          	addi	a0,s0,-176
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	af4080e7          	jalr	-1292(ra) # 800041cc <nameiparent>
    800056e0:	892a                	mv	s2,a0
    800056e2:	c935                	beqz	a0,80005756 <sys_link+0x10a>
  ilock(dp);
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	314080e7          	jalr	788(ra) # 800039f8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056ec:	00092703          	lw	a4,0(s2)
    800056f0:	409c                	lw	a5,0(s1)
    800056f2:	04f71d63          	bne	a4,a5,8000574c <sys_link+0x100>
    800056f6:	40d0                	lw	a2,4(s1)
    800056f8:	fd040593          	addi	a1,s0,-48
    800056fc:	854a                	mv	a0,s2
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	9ee080e7          	jalr	-1554(ra) # 800040ec <dirlink>
    80005706:	04054363          	bltz	a0,8000574c <sys_link+0x100>
  iunlockput(dp);
    8000570a:	854a                	mv	a0,s2
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	54e080e7          	jalr	1358(ra) # 80003c5a <iunlockput>
  iput(ip);
    80005714:	8526                	mv	a0,s1
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	49c080e7          	jalr	1180(ra) # 80003bb2 <iput>
  end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	d1c080e7          	jalr	-740(ra) # 8000443a <end_op>
  return 0;
    80005726:	4781                	li	a5,0
    80005728:	a085                	j	80005788 <sys_link+0x13c>
    end_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	d10080e7          	jalr	-752(ra) # 8000443a <end_op>
    return -1;
    80005732:	57fd                	li	a5,-1
    80005734:	a891                	j	80005788 <sys_link+0x13c>
    iunlockput(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	522080e7          	jalr	1314(ra) # 80003c5a <iunlockput>
    end_op();
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	cfa080e7          	jalr	-774(ra) # 8000443a <end_op>
    return -1;
    80005748:	57fd                	li	a5,-1
    8000574a:	a83d                	j	80005788 <sys_link+0x13c>
    iunlockput(dp);
    8000574c:	854a                	mv	a0,s2
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	50c080e7          	jalr	1292(ra) # 80003c5a <iunlockput>
  ilock(ip);
    80005756:	8526                	mv	a0,s1
    80005758:	ffffe097          	auipc	ra,0xffffe
    8000575c:	2a0080e7          	jalr	672(ra) # 800039f8 <ilock>
  ip->nlink--;
    80005760:	0524d783          	lhu	a5,82(s1)
    80005764:	37fd                	addiw	a5,a5,-1
    80005766:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	1c2080e7          	jalr	450(ra) # 8000392e <iupdate>
  iunlockput(ip);
    80005774:	8526                	mv	a0,s1
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	4e4080e7          	jalr	1252(ra) # 80003c5a <iunlockput>
  end_op();
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	cbc080e7          	jalr	-836(ra) # 8000443a <end_op>
  return -1;
    80005786:	57fd                	li	a5,-1
}
    80005788:	853e                	mv	a0,a5
    8000578a:	70b2                	ld	ra,296(sp)
    8000578c:	7412                	ld	s0,288(sp)
    8000578e:	64f2                	ld	s1,280(sp)
    80005790:	6952                	ld	s2,272(sp)
    80005792:	6155                	addi	sp,sp,304
    80005794:	8082                	ret

0000000080005796 <sys_unlink>:
{
    80005796:	7151                	addi	sp,sp,-240
    80005798:	f586                	sd	ra,232(sp)
    8000579a:	f1a2                	sd	s0,224(sp)
    8000579c:	eda6                	sd	s1,216(sp)
    8000579e:	e9ca                	sd	s2,208(sp)
    800057a0:	e5ce                	sd	s3,200(sp)
    800057a2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057a4:	08000613          	li	a2,128
    800057a8:	f3040593          	addi	a1,s0,-208
    800057ac:	4501                	li	a0,0
    800057ae:	ffffd097          	auipc	ra,0xffffd
    800057b2:	71e080e7          	jalr	1822(ra) # 80002ecc <argstr>
    800057b6:	18054163          	bltz	a0,80005938 <sys_unlink+0x1a2>
  begin_op();
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	c00080e7          	jalr	-1024(ra) # 800043ba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057c2:	fb040593          	addi	a1,s0,-80
    800057c6:	f3040513          	addi	a0,s0,-208
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	a02080e7          	jalr	-1534(ra) # 800041cc <nameiparent>
    800057d2:	84aa                	mv	s1,a0
    800057d4:	c979                	beqz	a0,800058aa <sys_unlink+0x114>
  ilock(dp);
    800057d6:	ffffe097          	auipc	ra,0xffffe
    800057da:	222080e7          	jalr	546(ra) # 800039f8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057de:	00004597          	auipc	a1,0x4
    800057e2:	4fa58593          	addi	a1,a1,1274 # 80009cd8 <syscalls+0x2c0>
    800057e6:	fb040513          	addi	a0,s0,-80
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	6d8080e7          	jalr	1752(ra) # 80003ec2 <namecmp>
    800057f2:	14050a63          	beqz	a0,80005946 <sys_unlink+0x1b0>
    800057f6:	00004597          	auipc	a1,0x4
    800057fa:	4ea58593          	addi	a1,a1,1258 # 80009ce0 <syscalls+0x2c8>
    800057fe:	fb040513          	addi	a0,s0,-80
    80005802:	ffffe097          	auipc	ra,0xffffe
    80005806:	6c0080e7          	jalr	1728(ra) # 80003ec2 <namecmp>
    8000580a:	12050e63          	beqz	a0,80005946 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000580e:	f2c40613          	addi	a2,s0,-212
    80005812:	fb040593          	addi	a1,s0,-80
    80005816:	8526                	mv	a0,s1
    80005818:	ffffe097          	auipc	ra,0xffffe
    8000581c:	6c4080e7          	jalr	1732(ra) # 80003edc <dirlookup>
    80005820:	892a                	mv	s2,a0
    80005822:	12050263          	beqz	a0,80005946 <sys_unlink+0x1b0>
  ilock(ip);
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	1d2080e7          	jalr	466(ra) # 800039f8 <ilock>
  if(ip->nlink < 1)
    8000582e:	05291783          	lh	a5,82(s2)
    80005832:	08f05263          	blez	a5,800058b6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005836:	04c91703          	lh	a4,76(s2)
    8000583a:	4785                	li	a5,1
    8000583c:	08f70563          	beq	a4,a5,800058c6 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005840:	4641                	li	a2,16
    80005842:	4581                	li	a1,0
    80005844:	fc040513          	addi	a0,s0,-64
    80005848:	ffffb097          	auipc	ra,0xffffb
    8000584c:	62e080e7          	jalr	1582(ra) # 80000e76 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005850:	4741                	li	a4,16
    80005852:	f2c42683          	lw	a3,-212(s0)
    80005856:	fc040613          	addi	a2,s0,-64
    8000585a:	4581                	li	a1,0
    8000585c:	8526                	mv	a0,s1
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	546080e7          	jalr	1350(ra) # 80003da4 <writei>
    80005866:	47c1                	li	a5,16
    80005868:	0af51563          	bne	a0,a5,80005912 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000586c:	04c91703          	lh	a4,76(s2)
    80005870:	4785                	li	a5,1
    80005872:	0af70863          	beq	a4,a5,80005922 <sys_unlink+0x18c>
  iunlockput(dp);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	3e2080e7          	jalr	994(ra) # 80003c5a <iunlockput>
  ip->nlink--;
    80005880:	05295783          	lhu	a5,82(s2)
    80005884:	37fd                	addiw	a5,a5,-1
    80005886:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    8000588a:	854a                	mv	a0,s2
    8000588c:	ffffe097          	auipc	ra,0xffffe
    80005890:	0a2080e7          	jalr	162(ra) # 8000392e <iupdate>
  iunlockput(ip);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	3c4080e7          	jalr	964(ra) # 80003c5a <iunlockput>
  end_op();
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	b9c080e7          	jalr	-1124(ra) # 8000443a <end_op>
  return 0;
    800058a6:	4501                	li	a0,0
    800058a8:	a84d                	j	8000595a <sys_unlink+0x1c4>
    end_op();
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	b90080e7          	jalr	-1136(ra) # 8000443a <end_op>
    return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	a05d                	j	8000595a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058b6:	00004517          	auipc	a0,0x4
    800058ba:	45250513          	addi	a0,a0,1106 # 80009d08 <syscalls+0x2f0>
    800058be:	ffffb097          	auipc	ra,0xffffb
    800058c2:	ca6080e7          	jalr	-858(ra) # 80000564 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c6:	05492703          	lw	a4,84(s2)
    800058ca:	02000793          	li	a5,32
    800058ce:	f6e7f9e3          	bgeu	a5,a4,80005840 <sys_unlink+0xaa>
    800058d2:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058d6:	4741                	li	a4,16
    800058d8:	86ce                	mv	a3,s3
    800058da:	f1840613          	addi	a2,s0,-232
    800058de:	4581                	li	a1,0
    800058e0:	854a                	mv	a0,s2
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	3ca080e7          	jalr	970(ra) # 80003cac <readi>
    800058ea:	47c1                	li	a5,16
    800058ec:	00f51b63          	bne	a0,a5,80005902 <sys_unlink+0x16c>
    if(de.inum != 0)
    800058f0:	f1845783          	lhu	a5,-232(s0)
    800058f4:	e7a1                	bnez	a5,8000593c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058f6:	29c1                	addiw	s3,s3,16
    800058f8:	05492783          	lw	a5,84(s2)
    800058fc:	fcf9ede3          	bltu	s3,a5,800058d6 <sys_unlink+0x140>
    80005900:	b781                	j	80005840 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005902:	00004517          	auipc	a0,0x4
    80005906:	41e50513          	addi	a0,a0,1054 # 80009d20 <syscalls+0x308>
    8000590a:	ffffb097          	auipc	ra,0xffffb
    8000590e:	c5a080e7          	jalr	-934(ra) # 80000564 <panic>
    panic("unlink: writei");
    80005912:	00004517          	auipc	a0,0x4
    80005916:	42650513          	addi	a0,a0,1062 # 80009d38 <syscalls+0x320>
    8000591a:	ffffb097          	auipc	ra,0xffffb
    8000591e:	c4a080e7          	jalr	-950(ra) # 80000564 <panic>
    dp->nlink--;
    80005922:	0524d783          	lhu	a5,82(s1)
    80005926:	37fd                	addiw	a5,a5,-1
    80005928:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	000080e7          	jalr	ra # 8000392e <iupdate>
    80005936:	b781                	j	80005876 <sys_unlink+0xe0>
    return -1;
    80005938:	557d                	li	a0,-1
    8000593a:	a005                	j	8000595a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000593c:	854a                	mv	a0,s2
    8000593e:	ffffe097          	auipc	ra,0xffffe
    80005942:	31c080e7          	jalr	796(ra) # 80003c5a <iunlockput>
  iunlockput(dp);
    80005946:	8526                	mv	a0,s1
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	312080e7          	jalr	786(ra) # 80003c5a <iunlockput>
  end_op();
    80005950:	fffff097          	auipc	ra,0xfffff
    80005954:	aea080e7          	jalr	-1302(ra) # 8000443a <end_op>
  return -1;
    80005958:	557d                	li	a0,-1
}
    8000595a:	70ae                	ld	ra,232(sp)
    8000595c:	740e                	ld	s0,224(sp)
    8000595e:	64ee                	ld	s1,216(sp)
    80005960:	694e                	ld	s2,208(sp)
    80005962:	69ae                	ld	s3,200(sp)
    80005964:	616d                	addi	sp,sp,240
    80005966:	8082                	ret

0000000080005968 <sys_open>:

uint64
sys_open(void)
{
    80005968:	7131                	addi	sp,sp,-192
    8000596a:	fd06                	sd	ra,184(sp)
    8000596c:	f922                	sd	s0,176(sp)
    8000596e:	f526                	sd	s1,168(sp)
    80005970:	f14a                	sd	s2,160(sp)
    80005972:	ed4e                	sd	s3,152(sp)
    80005974:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005976:	08000613          	li	a2,128
    8000597a:	f5040593          	addi	a1,s0,-176
    8000597e:	4501                	li	a0,0
    80005980:	ffffd097          	auipc	ra,0xffffd
    80005984:	54c080e7          	jalr	1356(ra) # 80002ecc <argstr>
    return -1;
    80005988:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000598a:	0c054163          	bltz	a0,80005a4c <sys_open+0xe4>
    8000598e:	f4c40593          	addi	a1,s0,-180
    80005992:	4505                	li	a0,1
    80005994:	ffffd097          	auipc	ra,0xffffd
    80005998:	4f4080e7          	jalr	1268(ra) # 80002e88 <argint>
    8000599c:	0a054863          	bltz	a0,80005a4c <sys_open+0xe4>

  begin_op();
    800059a0:	fffff097          	auipc	ra,0xfffff
    800059a4:	a1a080e7          	jalr	-1510(ra) # 800043ba <begin_op>

  if(omode & O_CREATE){
    800059a8:	f4c42783          	lw	a5,-180(s0)
    800059ac:	2007f793          	andi	a5,a5,512
    800059b0:	cbdd                	beqz	a5,80005a66 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059b2:	4681                	li	a3,0
    800059b4:	4601                	li	a2,0
    800059b6:	4589                	li	a1,2
    800059b8:	f5040513          	addi	a0,s0,-176
    800059bc:	00000097          	auipc	ra,0x0
    800059c0:	974080e7          	jalr	-1676(ra) # 80005330 <create>
    800059c4:	892a                	mv	s2,a0
    if(ip == 0){
    800059c6:	c959                	beqz	a0,80005a5c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059c8:	04c91703          	lh	a4,76(s2)
    800059cc:	478d                	li	a5,3
    800059ce:	00f71763          	bne	a4,a5,800059dc <sys_open+0x74>
    800059d2:	04e95703          	lhu	a4,78(s2)
    800059d6:	47a5                	li	a5,9
    800059d8:	0ce7ec63          	bltu	a5,a4,80005ab0 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059dc:	fffff097          	auipc	ra,0xfffff
    800059e0:	dec080e7          	jalr	-532(ra) # 800047c8 <filealloc>
    800059e4:	89aa                	mv	s3,a0
    800059e6:	10050663          	beqz	a0,80005af2 <sys_open+0x18a>
    800059ea:	00000097          	auipc	ra,0x0
    800059ee:	904080e7          	jalr	-1788(ra) # 800052ee <fdalloc>
    800059f2:	84aa                	mv	s1,a0
    800059f4:	0e054a63          	bltz	a0,80005ae8 <sys_open+0x180>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059f8:	04c91703          	lh	a4,76(s2)
    800059fc:	478d                	li	a5,3
    800059fe:	0cf70463          	beq	a4,a5,80005ac6 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    80005a02:	4789                	li	a5,2
    80005a04:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    80005a08:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    80005a0c:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    80005a10:	f4c42783          	lw	a5,-180(s0)
    80005a14:	0017c713          	xori	a4,a5,1
    80005a18:	8b05                	andi	a4,a4,1
    80005a1a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a1e:	0037f713          	andi	a4,a5,3
    80005a22:	00e03733          	snez	a4,a4
    80005a26:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a2a:	4007f793          	andi	a5,a5,1024
    80005a2e:	c791                	beqz	a5,80005a3a <sys_open+0xd2>
    80005a30:	04c91703          	lh	a4,76(s2)
    80005a34:	4789                	li	a5,2
    80005a36:	0af70363          	beq	a4,a5,80005adc <sys_open+0x174>
    itrunc(ip);
  }

  iunlock(ip);
    80005a3a:	854a                	mv	a0,s2
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	07e080e7          	jalr	126(ra) # 80003aba <iunlock>
  end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	9f6080e7          	jalr	-1546(ra) # 8000443a <end_op>

  return fd;
}
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	70ea                	ld	ra,184(sp)
    80005a50:	744a                	ld	s0,176(sp)
    80005a52:	74aa                	ld	s1,168(sp)
    80005a54:	790a                	ld	s2,160(sp)
    80005a56:	69ea                	ld	s3,152(sp)
    80005a58:	6129                	addi	sp,sp,192
    80005a5a:	8082                	ret
      end_op();
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	9de080e7          	jalr	-1570(ra) # 8000443a <end_op>
      return -1;
    80005a64:	b7e5                	j	80005a4c <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005a66:	f5040513          	addi	a0,s0,-176
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	744080e7          	jalr	1860(ra) # 800041ae <namei>
    80005a72:	892a                	mv	s2,a0
    80005a74:	c905                	beqz	a0,80005aa4 <sys_open+0x13c>
    ilock(ip);
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	f82080e7          	jalr	-126(ra) # 800039f8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a7e:	04c91703          	lh	a4,76(s2)
    80005a82:	4785                	li	a5,1
    80005a84:	f4f712e3          	bne	a4,a5,800059c8 <sys_open+0x60>
    80005a88:	f4c42783          	lw	a5,-180(s0)
    80005a8c:	dba1                	beqz	a5,800059dc <sys_open+0x74>
      iunlockput(ip);
    80005a8e:	854a                	mv	a0,s2
    80005a90:	ffffe097          	auipc	ra,0xffffe
    80005a94:	1ca080e7          	jalr	458(ra) # 80003c5a <iunlockput>
      end_op();
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	9a2080e7          	jalr	-1630(ra) # 8000443a <end_op>
      return -1;
    80005aa0:	54fd                	li	s1,-1
    80005aa2:	b76d                	j	80005a4c <sys_open+0xe4>
      end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	996080e7          	jalr	-1642(ra) # 8000443a <end_op>
      return -1;
    80005aac:	54fd                	li	s1,-1
    80005aae:	bf79                	j	80005a4c <sys_open+0xe4>
    iunlockput(ip);
    80005ab0:	854a                	mv	a0,s2
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	1a8080e7          	jalr	424(ra) # 80003c5a <iunlockput>
    end_op();
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	980080e7          	jalr	-1664(ra) # 8000443a <end_op>
    return -1;
    80005ac2:	54fd                	li	s1,-1
    80005ac4:	b761                	j	80005a4c <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005ac6:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005aca:	04e91783          	lh	a5,78(s2)
    80005ace:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005ad2:	05091783          	lh	a5,80(s2)
    80005ad6:	02f99323          	sh	a5,38(s3)
    80005ada:	b73d                	j	80005a08 <sys_open+0xa0>
    itrunc(ip);
    80005adc:	854a                	mv	a0,s2
    80005ade:	ffffe097          	auipc	ra,0xffffe
    80005ae2:	028080e7          	jalr	40(ra) # 80003b06 <itrunc>
    80005ae6:	bf91                	j	80005a3a <sys_open+0xd2>
      fileclose(f);
    80005ae8:	854e                	mv	a0,s3
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	d9a080e7          	jalr	-614(ra) # 80004884 <fileclose>
    iunlockput(ip);
    80005af2:	854a                	mv	a0,s2
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	166080e7          	jalr	358(ra) # 80003c5a <iunlockput>
    end_op();
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	93e080e7          	jalr	-1730(ra) # 8000443a <end_op>
    return -1;
    80005b04:	54fd                	li	s1,-1
    80005b06:	b799                	j	80005a4c <sys_open+0xe4>

0000000080005b08 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b08:	7175                	addi	sp,sp,-144
    80005b0a:	e506                	sd	ra,136(sp)
    80005b0c:	e122                	sd	s0,128(sp)
    80005b0e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	8aa080e7          	jalr	-1878(ra) # 800043ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b18:	08000613          	li	a2,128
    80005b1c:	f7040593          	addi	a1,s0,-144
    80005b20:	4501                	li	a0,0
    80005b22:	ffffd097          	auipc	ra,0xffffd
    80005b26:	3aa080e7          	jalr	938(ra) # 80002ecc <argstr>
    80005b2a:	02054963          	bltz	a0,80005b5c <sys_mkdir+0x54>
    80005b2e:	4681                	li	a3,0
    80005b30:	4601                	li	a2,0
    80005b32:	4585                	li	a1,1
    80005b34:	f7040513          	addi	a0,s0,-144
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	7f8080e7          	jalr	2040(ra) # 80005330 <create>
    80005b40:	cd11                	beqz	a0,80005b5c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	118080e7          	jalr	280(ra) # 80003c5a <iunlockput>
  end_op();
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	8f0080e7          	jalr	-1808(ra) # 8000443a <end_op>
  return 0;
    80005b52:	4501                	li	a0,0
}
    80005b54:	60aa                	ld	ra,136(sp)
    80005b56:	640a                	ld	s0,128(sp)
    80005b58:	6149                	addi	sp,sp,144
    80005b5a:	8082                	ret
    end_op();
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	8de080e7          	jalr	-1826(ra) # 8000443a <end_op>
    return -1;
    80005b64:	557d                	li	a0,-1
    80005b66:	b7fd                	j	80005b54 <sys_mkdir+0x4c>

0000000080005b68 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b68:	7135                	addi	sp,sp,-160
    80005b6a:	ed06                	sd	ra,152(sp)
    80005b6c:	e922                	sd	s0,144(sp)
    80005b6e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	84a080e7          	jalr	-1974(ra) # 800043ba <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b78:	08000613          	li	a2,128
    80005b7c:	f7040593          	addi	a1,s0,-144
    80005b80:	4501                	li	a0,0
    80005b82:	ffffd097          	auipc	ra,0xffffd
    80005b86:	34a080e7          	jalr	842(ra) # 80002ecc <argstr>
    80005b8a:	04054a63          	bltz	a0,80005bde <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b8e:	f6c40593          	addi	a1,s0,-148
    80005b92:	4505                	li	a0,1
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	2f4080e7          	jalr	756(ra) # 80002e88 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b9c:	04054163          	bltz	a0,80005bde <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ba0:	f6840593          	addi	a1,s0,-152
    80005ba4:	4509                	li	a0,2
    80005ba6:	ffffd097          	auipc	ra,0xffffd
    80005baa:	2e2080e7          	jalr	738(ra) # 80002e88 <argint>
     argint(1, &major) < 0 ||
    80005bae:	02054863          	bltz	a0,80005bde <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bb2:	f6841683          	lh	a3,-152(s0)
    80005bb6:	f6c41603          	lh	a2,-148(s0)
    80005bba:	458d                	li	a1,3
    80005bbc:	f7040513          	addi	a0,s0,-144
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	770080e7          	jalr	1904(ra) # 80005330 <create>
     argint(2, &minor) < 0 ||
    80005bc8:	c919                	beqz	a0,80005bde <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bca:	ffffe097          	auipc	ra,0xffffe
    80005bce:	090080e7          	jalr	144(ra) # 80003c5a <iunlockput>
  end_op();
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	868080e7          	jalr	-1944(ra) # 8000443a <end_op>
  return 0;
    80005bda:	4501                	li	a0,0
    80005bdc:	a031                	j	80005be8 <sys_mknod+0x80>
    end_op();
    80005bde:	fffff097          	auipc	ra,0xfffff
    80005be2:	85c080e7          	jalr	-1956(ra) # 8000443a <end_op>
    return -1;
    80005be6:	557d                	li	a0,-1
}
    80005be8:	60ea                	ld	ra,152(sp)
    80005bea:	644a                	ld	s0,144(sp)
    80005bec:	610d                	addi	sp,sp,160
    80005bee:	8082                	ret

0000000080005bf0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bf0:	7135                	addi	sp,sp,-160
    80005bf2:	ed06                	sd	ra,152(sp)
    80005bf4:	e922                	sd	s0,144(sp)
    80005bf6:	e526                	sd	s1,136(sp)
    80005bf8:	e14a                	sd	s2,128(sp)
    80005bfa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bfc:	ffffc097          	auipc	ra,0xffffc
    80005c00:	f54080e7          	jalr	-172(ra) # 80001b50 <myproc>
    80005c04:	892a                	mv	s2,a0
  
  begin_op();
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	7b4080e7          	jalr	1972(ra) # 800043ba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c0e:	08000613          	li	a2,128
    80005c12:	f6040593          	addi	a1,s0,-160
    80005c16:	4501                	li	a0,0
    80005c18:	ffffd097          	auipc	ra,0xffffd
    80005c1c:	2b4080e7          	jalr	692(ra) # 80002ecc <argstr>
    80005c20:	04054b63          	bltz	a0,80005c76 <sys_chdir+0x86>
    80005c24:	f6040513          	addi	a0,s0,-160
    80005c28:	ffffe097          	auipc	ra,0xffffe
    80005c2c:	586080e7          	jalr	1414(ra) # 800041ae <namei>
    80005c30:	84aa                	mv	s1,a0
    80005c32:	c131                	beqz	a0,80005c76 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c34:	ffffe097          	auipc	ra,0xffffe
    80005c38:	dc4080e7          	jalr	-572(ra) # 800039f8 <ilock>
  if(ip->type != T_DIR){
    80005c3c:	04c49703          	lh	a4,76(s1)
    80005c40:	4785                	li	a5,1
    80005c42:	04f71063          	bne	a4,a5,80005c82 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c46:	8526                	mv	a0,s1
    80005c48:	ffffe097          	auipc	ra,0xffffe
    80005c4c:	e72080e7          	jalr	-398(ra) # 80003aba <iunlock>
  iput(p->cwd);
    80005c50:	15893503          	ld	a0,344(s2)
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	f5e080e7          	jalr	-162(ra) # 80003bb2 <iput>
  end_op();
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	7de080e7          	jalr	2014(ra) # 8000443a <end_op>
  p->cwd = ip;
    80005c64:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c68:	4501                	li	a0,0
}
    80005c6a:	60ea                	ld	ra,152(sp)
    80005c6c:	644a                	ld	s0,144(sp)
    80005c6e:	64aa                	ld	s1,136(sp)
    80005c70:	690a                	ld	s2,128(sp)
    80005c72:	610d                	addi	sp,sp,160
    80005c74:	8082                	ret
    end_op();
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	7c4080e7          	jalr	1988(ra) # 8000443a <end_op>
    return -1;
    80005c7e:	557d                	li	a0,-1
    80005c80:	b7ed                	j	80005c6a <sys_chdir+0x7a>
    iunlockput(ip);
    80005c82:	8526                	mv	a0,s1
    80005c84:	ffffe097          	auipc	ra,0xffffe
    80005c88:	fd6080e7          	jalr	-42(ra) # 80003c5a <iunlockput>
    end_op();
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	7ae080e7          	jalr	1966(ra) # 8000443a <end_op>
    return -1;
    80005c94:	557d                	li	a0,-1
    80005c96:	bfd1                	j	80005c6a <sys_chdir+0x7a>

0000000080005c98 <sys_exec>:

uint64
sys_exec(void)
{
    80005c98:	7145                	addi	sp,sp,-464
    80005c9a:	e786                	sd	ra,456(sp)
    80005c9c:	e3a2                	sd	s0,448(sp)
    80005c9e:	ff26                	sd	s1,440(sp)
    80005ca0:	fb4a                	sd	s2,432(sp)
    80005ca2:	f74e                	sd	s3,424(sp)
    80005ca4:	f352                	sd	s4,416(sp)
    80005ca6:	ef56                	sd	s5,408(sp)
    80005ca8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005caa:	08000613          	li	a2,128
    80005cae:	f4040593          	addi	a1,s0,-192
    80005cb2:	4501                	li	a0,0
    80005cb4:	ffffd097          	auipc	ra,0xffffd
    80005cb8:	218080e7          	jalr	536(ra) # 80002ecc <argstr>
    return -1;
    80005cbc:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005cbe:	0c054a63          	bltz	a0,80005d92 <sys_exec+0xfa>
    80005cc2:	e3840593          	addi	a1,s0,-456
    80005cc6:	4505                	li	a0,1
    80005cc8:	ffffd097          	auipc	ra,0xffffd
    80005ccc:	1e2080e7          	jalr	482(ra) # 80002eaa <argaddr>
    80005cd0:	0c054163          	bltz	a0,80005d92 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005cd4:	10000613          	li	a2,256
    80005cd8:	4581                	li	a1,0
    80005cda:	e4040513          	addi	a0,s0,-448
    80005cde:	ffffb097          	auipc	ra,0xffffb
    80005ce2:	198080e7          	jalr	408(ra) # 80000e76 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ce6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cea:	89a6                	mv	s3,s1
    80005cec:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cee:	02000a13          	li	s4,32
    80005cf2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cf6:	00391793          	slli	a5,s2,0x3
    80005cfa:	e3040593          	addi	a1,s0,-464
    80005cfe:	e3843503          	ld	a0,-456(s0)
    80005d02:	953e                	add	a0,a0,a5
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	0ea080e7          	jalr	234(ra) # 80002dee <fetchaddr>
    80005d0c:	02054a63          	bltz	a0,80005d40 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005d10:	e3043783          	ld	a5,-464(s0)
    80005d14:	c3b9                	beqz	a5,80005d5a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d16:	ffffb097          	auipc	ra,0xffffb
    80005d1a:	d2c080e7          	jalr	-724(ra) # 80000a42 <kalloc>
    80005d1e:	85aa                	mv	a1,a0
    80005d20:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d24:	cd11                	beqz	a0,80005d40 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d26:	6605                	lui	a2,0x1
    80005d28:	e3043503          	ld	a0,-464(s0)
    80005d2c:	ffffd097          	auipc	ra,0xffffd
    80005d30:	114080e7          	jalr	276(ra) # 80002e40 <fetchstr>
    80005d34:	00054663          	bltz	a0,80005d40 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005d38:	0905                	addi	s2,s2,1
    80005d3a:	09a1                	addi	s3,s3,8
    80005d3c:	fb491be3          	bne	s2,s4,80005cf2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d40:	10048913          	addi	s2,s1,256
    80005d44:	6088                	ld	a0,0(s1)
    80005d46:	c529                	beqz	a0,80005d90 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d48:	ffffb097          	auipc	ra,0xffffb
    80005d4c:	bf4080e7          	jalr	-1036(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d50:	04a1                	addi	s1,s1,8
    80005d52:	ff2499e3          	bne	s1,s2,80005d44 <sys_exec+0xac>
  return -1;
    80005d56:	597d                	li	s2,-1
    80005d58:	a82d                	j	80005d92 <sys_exec+0xfa>
      argv[i] = 0;
    80005d5a:	0a8e                	slli	s5,s5,0x3
    80005d5c:	fc040793          	addi	a5,s0,-64
    80005d60:	9abe                	add	s5,s5,a5
    80005d62:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffc6ac0>
  int ret = exec(path, argv);
    80005d66:	e4040593          	addi	a1,s0,-448
    80005d6a:	f4040513          	addi	a0,s0,-192
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	170080e7          	jalr	368(ra) # 80004ede <exec>
    80005d76:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d78:	10048993          	addi	s3,s1,256
    80005d7c:	6088                	ld	a0,0(s1)
    80005d7e:	c911                	beqz	a0,80005d92 <sys_exec+0xfa>
    kfree(argv[i]);
    80005d80:	ffffb097          	auipc	ra,0xffffb
    80005d84:	bbc080e7          	jalr	-1092(ra) # 8000093c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d88:	04a1                	addi	s1,s1,8
    80005d8a:	ff3499e3          	bne	s1,s3,80005d7c <sys_exec+0xe4>
    80005d8e:	a011                	j	80005d92 <sys_exec+0xfa>
  return -1;
    80005d90:	597d                	li	s2,-1
}
    80005d92:	854a                	mv	a0,s2
    80005d94:	60be                	ld	ra,456(sp)
    80005d96:	641e                	ld	s0,448(sp)
    80005d98:	74fa                	ld	s1,440(sp)
    80005d9a:	795a                	ld	s2,432(sp)
    80005d9c:	79ba                	ld	s3,424(sp)
    80005d9e:	7a1a                	ld	s4,416(sp)
    80005da0:	6afa                	ld	s5,408(sp)
    80005da2:	6179                	addi	sp,sp,464
    80005da4:	8082                	ret

0000000080005da6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005da6:	7139                	addi	sp,sp,-64
    80005da8:	fc06                	sd	ra,56(sp)
    80005daa:	f822                	sd	s0,48(sp)
    80005dac:	f426                	sd	s1,40(sp)
    80005dae:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005db0:	ffffc097          	auipc	ra,0xffffc
    80005db4:	da0080e7          	jalr	-608(ra) # 80001b50 <myproc>
    80005db8:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005dba:	fd840593          	addi	a1,s0,-40
    80005dbe:	4501                	li	a0,0
    80005dc0:	ffffd097          	auipc	ra,0xffffd
    80005dc4:	0ea080e7          	jalr	234(ra) # 80002eaa <argaddr>
    return -1;
    80005dc8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005dca:	0e054063          	bltz	a0,80005eaa <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005dce:	fc840593          	addi	a1,s0,-56
    80005dd2:	fd040513          	addi	a0,s0,-48
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	de6080e7          	jalr	-538(ra) # 80004bbc <pipealloc>
    return -1;
    80005dde:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005de0:	0c054563          	bltz	a0,80005eaa <sys_pipe+0x104>
  fd0 = -1;
    80005de4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005de8:	fd043503          	ld	a0,-48(s0)
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	502080e7          	jalr	1282(ra) # 800052ee <fdalloc>
    80005df4:	fca42223          	sw	a0,-60(s0)
    80005df8:	08054c63          	bltz	a0,80005e90 <sys_pipe+0xea>
    80005dfc:	fc843503          	ld	a0,-56(s0)
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	4ee080e7          	jalr	1262(ra) # 800052ee <fdalloc>
    80005e08:	fca42023          	sw	a0,-64(s0)
    80005e0c:	06054863          	bltz	a0,80005e7c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e10:	4691                	li	a3,4
    80005e12:	fc440613          	addi	a2,s0,-60
    80005e16:	fd843583          	ld	a1,-40(s0)
    80005e1a:	6ca8                	ld	a0,88(s1)
    80005e1c:	ffffc097          	auipc	ra,0xffffc
    80005e20:	9e4080e7          	jalr	-1564(ra) # 80001800 <copyout>
    80005e24:	02054063          	bltz	a0,80005e44 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e28:	4691                	li	a3,4
    80005e2a:	fc040613          	addi	a2,s0,-64
    80005e2e:	fd843583          	ld	a1,-40(s0)
    80005e32:	0591                	addi	a1,a1,4
    80005e34:	6ca8                	ld	a0,88(s1)
    80005e36:	ffffc097          	auipc	ra,0xffffc
    80005e3a:	9ca080e7          	jalr	-1590(ra) # 80001800 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e3e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e40:	06055563          	bgez	a0,80005eaa <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005e44:	fc442783          	lw	a5,-60(s0)
    80005e48:	07e9                	addi	a5,a5,26
    80005e4a:	078e                	slli	a5,a5,0x3
    80005e4c:	97a6                	add	a5,a5,s1
    80005e4e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e52:	fc042503          	lw	a0,-64(s0)
    80005e56:	0569                	addi	a0,a0,26
    80005e58:	050e                	slli	a0,a0,0x3
    80005e5a:	9526                	add	a0,a0,s1
    80005e5c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e60:	fd043503          	ld	a0,-48(s0)
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	a20080e7          	jalr	-1504(ra) # 80004884 <fileclose>
    fileclose(wf);
    80005e6c:	fc843503          	ld	a0,-56(s0)
    80005e70:	fffff097          	auipc	ra,0xfffff
    80005e74:	a14080e7          	jalr	-1516(ra) # 80004884 <fileclose>
    return -1;
    80005e78:	57fd                	li	a5,-1
    80005e7a:	a805                	j	80005eaa <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e7c:	fc442783          	lw	a5,-60(s0)
    80005e80:	0007c863          	bltz	a5,80005e90 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e84:	01a78513          	addi	a0,a5,26
    80005e88:	050e                	slli	a0,a0,0x3
    80005e8a:	9526                	add	a0,a0,s1
    80005e8c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e90:	fd043503          	ld	a0,-48(s0)
    80005e94:	fffff097          	auipc	ra,0xfffff
    80005e98:	9f0080e7          	jalr	-1552(ra) # 80004884 <fileclose>
    fileclose(wf);
    80005e9c:	fc843503          	ld	a0,-56(s0)
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	9e4080e7          	jalr	-1564(ra) # 80004884 <fileclose>
    return -1;
    80005ea8:	57fd                	li	a5,-1
}
    80005eaa:	853e                	mv	a0,a5
    80005eac:	70e2                	ld	ra,56(sp)
    80005eae:	7442                	ld	s0,48(sp)
    80005eb0:	74a2                	ld	s1,40(sp)
    80005eb2:	6121                	addi	sp,sp,64
    80005eb4:	8082                	ret
	...

0000000080005ec0 <kernelvec>:
    80005ec0:	7111                	addi	sp,sp,-256
    80005ec2:	e006                	sd	ra,0(sp)
    80005ec4:	e40a                	sd	sp,8(sp)
    80005ec6:	e80e                	sd	gp,16(sp)
    80005ec8:	ec12                	sd	tp,24(sp)
    80005eca:	f016                	sd	t0,32(sp)
    80005ecc:	f41a                	sd	t1,40(sp)
    80005ece:	f81e                	sd	t2,48(sp)
    80005ed0:	fc22                	sd	s0,56(sp)
    80005ed2:	e0a6                	sd	s1,64(sp)
    80005ed4:	e4aa                	sd	a0,72(sp)
    80005ed6:	e8ae                	sd	a1,80(sp)
    80005ed8:	ecb2                	sd	a2,88(sp)
    80005eda:	f0b6                	sd	a3,96(sp)
    80005edc:	f4ba                	sd	a4,104(sp)
    80005ede:	f8be                	sd	a5,112(sp)
    80005ee0:	fcc2                	sd	a6,120(sp)
    80005ee2:	e146                	sd	a7,128(sp)
    80005ee4:	e54a                	sd	s2,136(sp)
    80005ee6:	e94e                	sd	s3,144(sp)
    80005ee8:	ed52                	sd	s4,152(sp)
    80005eea:	f156                	sd	s5,160(sp)
    80005eec:	f55a                	sd	s6,168(sp)
    80005eee:	f95e                	sd	s7,176(sp)
    80005ef0:	fd62                	sd	s8,184(sp)
    80005ef2:	e1e6                	sd	s9,192(sp)
    80005ef4:	e5ea                	sd	s10,200(sp)
    80005ef6:	e9ee                	sd	s11,208(sp)
    80005ef8:	edf2                	sd	t3,216(sp)
    80005efa:	f1f6                	sd	t4,224(sp)
    80005efc:	f5fa                	sd	t5,232(sp)
    80005efe:	f9fe                	sd	t6,240(sp)
    80005f00:	daffc0ef          	jal	ra,80002cae <kerneltrap>
    80005f04:	6082                	ld	ra,0(sp)
    80005f06:	6122                	ld	sp,8(sp)
    80005f08:	61c2                	ld	gp,16(sp)
    80005f0a:	7282                	ld	t0,32(sp)
    80005f0c:	7322                	ld	t1,40(sp)
    80005f0e:	73c2                	ld	t2,48(sp)
    80005f10:	7462                	ld	s0,56(sp)
    80005f12:	6486                	ld	s1,64(sp)
    80005f14:	6526                	ld	a0,72(sp)
    80005f16:	65c6                	ld	a1,80(sp)
    80005f18:	6666                	ld	a2,88(sp)
    80005f1a:	7686                	ld	a3,96(sp)
    80005f1c:	7726                	ld	a4,104(sp)
    80005f1e:	77c6                	ld	a5,112(sp)
    80005f20:	7866                	ld	a6,120(sp)
    80005f22:	688a                	ld	a7,128(sp)
    80005f24:	692a                	ld	s2,136(sp)
    80005f26:	69ca                	ld	s3,144(sp)
    80005f28:	6a6a                	ld	s4,152(sp)
    80005f2a:	7a8a                	ld	s5,160(sp)
    80005f2c:	7b2a                	ld	s6,168(sp)
    80005f2e:	7bca                	ld	s7,176(sp)
    80005f30:	7c6a                	ld	s8,184(sp)
    80005f32:	6c8e                	ld	s9,192(sp)
    80005f34:	6d2e                	ld	s10,200(sp)
    80005f36:	6dce                	ld	s11,208(sp)
    80005f38:	6e6e                	ld	t3,216(sp)
    80005f3a:	7e8e                	ld	t4,224(sp)
    80005f3c:	7f2e                	ld	t5,232(sp)
    80005f3e:	7fce                	ld	t6,240(sp)
    80005f40:	6111                	addi	sp,sp,256
    80005f42:	10200073          	sret
    80005f46:	00000013          	nop
    80005f4a:	00000013          	nop
    80005f4e:	0001                	nop

0000000080005f50 <timervec>:
    80005f50:	34051573          	csrrw	a0,mscratch,a0
    80005f54:	e10c                	sd	a1,0(a0)
    80005f56:	e510                	sd	a2,8(a0)
    80005f58:	e914                	sd	a3,16(a0)
    80005f5a:	6d0c                	ld	a1,24(a0)
    80005f5c:	7110                	ld	a2,32(a0)
    80005f5e:	6194                	ld	a3,0(a1)
    80005f60:	96b2                	add	a3,a3,a2
    80005f62:	e194                	sd	a3,0(a1)
    80005f64:	4589                	li	a1,2
    80005f66:	14459073          	csrw	sip,a1
    80005f6a:	6914                	ld	a3,16(a0)
    80005f6c:	6510                	ld	a2,8(a0)
    80005f6e:	610c                	ld	a1,0(a0)
    80005f70:	34051573          	csrrw	a0,mscratch,a0
    80005f74:	30200073          	mret
	...

0000000080005f7a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f7a:	1141                	addi	sp,sp,-16
    80005f7c:	e422                	sd	s0,8(sp)
    80005f7e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f80:	0c0007b7          	lui	a5,0xc000
    80005f84:	4705                	li	a4,1
    80005f86:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f88:	c3d8                	sw	a4,4(a5)
}
    80005f8a:	6422                	ld	s0,8(sp)
    80005f8c:	0141                	addi	sp,sp,16
    80005f8e:	8082                	ret

0000000080005f90 <plicinithart>:

void
plicinithart(void)
{
    80005f90:	1141                	addi	sp,sp,-16
    80005f92:	e406                	sd	ra,8(sp)
    80005f94:	e022                	sd	s0,0(sp)
    80005f96:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f98:	ffffc097          	auipc	ra,0xffffc
    80005f9c:	b8c080e7          	jalr	-1140(ra) # 80001b24 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fa0:	0085171b          	slliw	a4,a0,0x8
    80005fa4:	0c0027b7          	lui	a5,0xc002
    80005fa8:	97ba                	add	a5,a5,a4
    80005faa:	40200713          	li	a4,1026
    80005fae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fb2:	00d5151b          	slliw	a0,a0,0xd
    80005fb6:	0c2017b7          	lui	a5,0xc201
    80005fba:	953e                	add	a0,a0,a5
    80005fbc:	00052023          	sw	zero,0(a0)
}
    80005fc0:	60a2                	ld	ra,8(sp)
    80005fc2:	6402                	ld	s0,0(sp)
    80005fc4:	0141                	addi	sp,sp,16
    80005fc6:	8082                	ret

0000000080005fc8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fc8:	1141                	addi	sp,sp,-16
    80005fca:	e406                	sd	ra,8(sp)
    80005fcc:	e022                	sd	s0,0(sp)
    80005fce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fd0:	ffffc097          	auipc	ra,0xffffc
    80005fd4:	b54080e7          	jalr	-1196(ra) # 80001b24 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fd8:	00d5179b          	slliw	a5,a0,0xd
    80005fdc:	0c201537          	lui	a0,0xc201
    80005fe0:	953e                	add	a0,a0,a5
  return irq;
}
    80005fe2:	4148                	lw	a0,4(a0)
    80005fe4:	60a2                	ld	ra,8(sp)
    80005fe6:	6402                	ld	s0,0(sp)
    80005fe8:	0141                	addi	sp,sp,16
    80005fea:	8082                	ret

0000000080005fec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fec:	1101                	addi	sp,sp,-32
    80005fee:	ec06                	sd	ra,24(sp)
    80005ff0:	e822                	sd	s0,16(sp)
    80005ff2:	e426                	sd	s1,8(sp)
    80005ff4:	1000                	addi	s0,sp,32
    80005ff6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	b2c080e7          	jalr	-1236(ra) # 80001b24 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006000:	00d5151b          	slliw	a0,a0,0xd
    80006004:	0c2017b7          	lui	a5,0xc201
    80006008:	97aa                	add	a5,a5,a0
    8000600a:	c3c4                	sw	s1,4(a5)
}
    8000600c:	60e2                	ld	ra,24(sp)
    8000600e:	6442                	ld	s0,16(sp)
    80006010:	64a2                	ld	s1,8(sp)
    80006012:	6105                	addi	sp,sp,32
    80006014:	8082                	ret

0000000080006016 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006016:	1141                	addi	sp,sp,-16
    80006018:	e406                	sd	ra,8(sp)
    8000601a:	e022                	sd	s0,0(sp)
    8000601c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000601e:	479d                	li	a5,7
    80006020:	04a7c463          	blt	a5,a0,80006068 <free_desc+0x52>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80006024:	00032797          	auipc	a5,0x32
    80006028:	23478793          	addi	a5,a5,564 # 80038258 <disk>
    8000602c:	97aa                	add	a5,a5,a0
    8000602e:	0187c783          	lbu	a5,24(a5)
    80006032:	e3b9                	bnez	a5,80006078 <free_desc+0x62>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80006034:	00032797          	auipc	a5,0x32
    80006038:	22478793          	addi	a5,a5,548 # 80038258 <disk>
    8000603c:	6398                	ld	a4,0(a5)
    8000603e:	00451693          	slli	a3,a0,0x4
    80006042:	9736                	add	a4,a4,a3
    80006044:	00073023          	sd	zero,0(a4)
  disk.free[i] = 1;
    80006048:	953e                	add	a0,a0,a5
    8000604a:	4785                	li	a5,1
    8000604c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006050:	00032517          	auipc	a0,0x32
    80006054:	22050513          	addi	a0,a0,544 # 80038270 <disk+0x18>
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	63e080e7          	jalr	1598(ra) # 80002696 <wakeup>
}
    80006060:	60a2                	ld	ra,8(sp)
    80006062:	6402                	ld	s0,0(sp)
    80006064:	0141                	addi	sp,sp,16
    80006066:	8082                	ret
    panic("virtio_disk_intr 1");
    80006068:	00004517          	auipc	a0,0x4
    8000606c:	ce050513          	addi	a0,a0,-800 # 80009d48 <syscalls+0x330>
    80006070:	ffffa097          	auipc	ra,0xffffa
    80006074:	4f4080e7          	jalr	1268(ra) # 80000564 <panic>
    panic("virtio_disk_intr 2");
    80006078:	00004517          	auipc	a0,0x4
    8000607c:	ce850513          	addi	a0,a0,-792 # 80009d60 <syscalls+0x348>
    80006080:	ffffa097          	auipc	ra,0xffffa
    80006084:	4e4080e7          	jalr	1252(ra) # 80000564 <panic>

0000000080006088 <virtio_disk_init>:
{
    80006088:	1101                	addi	sp,sp,-32
    8000608a:	ec06                	sd	ra,24(sp)
    8000608c:	e822                	sd	s0,16(sp)
    8000608e:	e426                	sd	s1,8(sp)
    80006090:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006092:	00032497          	auipc	s1,0x32
    80006096:	1c648493          	addi	s1,s1,454 # 80038258 <disk>
    8000609a:	00004597          	auipc	a1,0x4
    8000609e:	cde58593          	addi	a1,a1,-802 # 80009d78 <syscalls+0x360>
    800060a2:	00032517          	auipc	a0,0x32
    800060a6:	2de50513          	addi	a0,a0,734 # 80038380 <disk+0x128>
    800060aa:	ffffb097          	auipc	ra,0xffffb
    800060ae:	a12080e7          	jalr	-1518(ra) # 80000abc <initlock>
  disk.desc = kalloc();
    800060b2:	ffffb097          	auipc	ra,0xffffb
    800060b6:	990080e7          	jalr	-1648(ra) # 80000a42 <kalloc>
    800060ba:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060bc:	ffffb097          	auipc	ra,0xffffb
    800060c0:	986080e7          	jalr	-1658(ra) # 80000a42 <kalloc>
    800060c4:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060c6:	ffffb097          	auipc	ra,0xffffb
    800060ca:	97c080e7          	jalr	-1668(ra) # 80000a42 <kalloc>
    800060ce:	87aa                	mv	a5,a0
    800060d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060d2:	6088                	ld	a0,0(s1)
    800060d4:	14050163          	beqz	a0,80006216 <virtio_disk_init+0x18e>
    800060d8:	00032717          	auipc	a4,0x32
    800060dc:	18873703          	ld	a4,392(a4) # 80038260 <disk+0x8>
    800060e0:	12070b63          	beqz	a4,80006216 <virtio_disk_init+0x18e>
    800060e4:	12078963          	beqz	a5,80006216 <virtio_disk_init+0x18e>
  memset(disk.desc, 0, PGSIZE);
    800060e8:	6605                	lui	a2,0x1
    800060ea:	4581                	li	a1,0
    800060ec:	ffffb097          	auipc	ra,0xffffb
    800060f0:	d8a080e7          	jalr	-630(ra) # 80000e76 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060f4:	00032497          	auipc	s1,0x32
    800060f8:	16448493          	addi	s1,s1,356 # 80038258 <disk>
    800060fc:	6605                	lui	a2,0x1
    800060fe:	4581                	li	a1,0
    80006100:	6488                	ld	a0,8(s1)
    80006102:	ffffb097          	auipc	ra,0xffffb
    80006106:	d74080e7          	jalr	-652(ra) # 80000e76 <memset>
  memset(disk.used, 0, PGSIZE);
    8000610a:	6605                	lui	a2,0x1
    8000610c:	4581                	li	a1,0
    8000610e:	6888                	ld	a0,16(s1)
    80006110:	ffffb097          	auipc	ra,0xffffb
    80006114:	d66080e7          	jalr	-666(ra) # 80000e76 <memset>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006118:	100017b7          	lui	a5,0x10001
    8000611c:	4398                	lw	a4,0(a5)
    8000611e:	2701                	sext.w	a4,a4
    80006120:	747277b7          	lui	a5,0x74727
    80006124:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006128:	0ef71f63          	bne	a4,a5,80006226 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000612c:	100017b7          	lui	a5,0x10001
    80006130:	43dc                	lw	a5,4(a5)
    80006132:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006134:	4709                	li	a4,2
    80006136:	0ee79863          	bne	a5,a4,80006226 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000613a:	100017b7          	lui	a5,0x10001
    8000613e:	479c                	lw	a5,8(a5)
    80006140:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006142:	0ee79263          	bne	a5,a4,80006226 <virtio_disk_init+0x19e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006146:	100017b7          	lui	a5,0x10001
    8000614a:	47d8                	lw	a4,12(a5)
    8000614c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000614e:	554d47b7          	lui	a5,0x554d4
    80006152:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006156:	0cf71863          	bne	a4,a5,80006226 <virtio_disk_init+0x19e>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000615a:	100017b7          	lui	a5,0x10001
    8000615e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006162:	4705                	li	a4,1
    80006164:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006166:	470d                	li	a4,3
    80006168:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000616a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000616c:	c7ffe737          	lui	a4,0xc7ffe
    80006170:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fc639f>
    80006174:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006176:	2701                	sext.w	a4,a4
    80006178:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617a:	472d                	li	a4,11
    8000617c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000617e:	5bbc                	lw	a5,112(a5)
    80006180:	0007861b          	sext.w	a2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006184:	8ba1                	andi	a5,a5,8
    80006186:	cbc5                	beqz	a5,80006236 <virtio_disk_init+0x1ae>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006190:	43fc                	lw	a5,68(a5)
    80006192:	2781                	sext.w	a5,a5
    80006194:	ebcd                	bnez	a5,80006246 <virtio_disk_init+0x1be>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006196:	100017b7          	lui	a5,0x10001
    8000619a:	5bdc                	lw	a5,52(a5)
    8000619c:	2781                	sext.w	a5,a5
  if(max == 0)
    8000619e:	cfc5                	beqz	a5,80006256 <virtio_disk_init+0x1ce>
  if(max < NUM)
    800061a0:	471d                	li	a4,7
    800061a2:	0cf77263          	bgeu	a4,a5,80006266 <virtio_disk_init+0x1de>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061a6:	10001737          	lui	a4,0x10001
    800061aa:	47a1                	li	a5,8
    800061ac:	df1c                	sw	a5,56(a4)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW)   = (uint64)disk.desc;
    800061ae:	00032797          	auipc	a5,0x32
    800061b2:	0aa78793          	addi	a5,a5,170 # 80038258 <disk>
    800061b6:	4394                	lw	a3,0(a5)
    800061b8:	08d72023          	sw	a3,128(a4) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH)  = (uint64)disk.desc >> 32;
    800061bc:	43d4                	lw	a3,4(a5)
    800061be:	08d72223          	sw	a3,132(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW)  = (uint64)disk.avail;
    800061c2:	6794                	ld	a3,8(a5)
    800061c4:	0006859b          	sext.w	a1,a3
    800061c8:	08b72823          	sw	a1,144(a4)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061cc:	9681                	srai	a3,a3,0x20
    800061ce:	08d72a23          	sw	a3,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW)  = (uint64)disk.used;
    800061d2:	6b94                	ld	a3,16(a5)
    800061d4:	0006859b          	sext.w	a1,a3
    800061d8:	0ab72023          	sw	a1,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800061dc:	9681                	srai	a3,a3,0x20
    800061de:	0ad72223          	sw	a3,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800061e2:	4685                	li	a3,1
    800061e4:	c374                	sw	a3,68(a4)
    disk.free[i] = 1;
    800061e6:	00d78c23          	sb	a3,24(a5)
    800061ea:	00d78ca3          	sb	a3,25(a5)
    800061ee:	00d78d23          	sb	a3,26(a5)
    800061f2:	00d78da3          	sb	a3,27(a5)
    800061f6:	00d78e23          	sb	a3,28(a5)
    800061fa:	00d78ea3          	sb	a3,29(a5)
    800061fe:	00d78f23          	sb	a3,30(a5)
    80006202:	00d78fa3          	sb	a3,31(a5)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006206:	00466793          	ori	a5,a2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000620a:	db3c                	sw	a5,112(a4)
}
    8000620c:	60e2                	ld	ra,24(sp)
    8000620e:	6442                	ld	s0,16(sp)
    80006210:	64a2                	ld	s1,8(sp)
    80006212:	6105                	addi	sp,sp,32
    80006214:	8082                	ret
    panic("virtio disk kalloc");
    80006216:	00004517          	auipc	a0,0x4
    8000621a:	b7250513          	addi	a0,a0,-1166 # 80009d88 <syscalls+0x370>
    8000621e:	ffffa097          	auipc	ra,0xffffa
    80006222:	346080e7          	jalr	838(ra) # 80000564 <panic>
    panic("could not find virtio disk");
    80006226:	00004517          	auipc	a0,0x4
    8000622a:	b7a50513          	addi	a0,a0,-1158 # 80009da0 <syscalls+0x388>
    8000622e:	ffffa097          	auipc	ra,0xffffa
    80006232:	336080e7          	jalr	822(ra) # 80000564 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006236:	00004517          	auipc	a0,0x4
    8000623a:	b8a50513          	addi	a0,a0,-1142 # 80009dc0 <syscalls+0x3a8>
    8000623e:	ffffa097          	auipc	ra,0xffffa
    80006242:	326080e7          	jalr	806(ra) # 80000564 <panic>
    panic("virtio disk ready not zero");
    80006246:	00004517          	auipc	a0,0x4
    8000624a:	b9a50513          	addi	a0,a0,-1126 # 80009de0 <syscalls+0x3c8>
    8000624e:	ffffa097          	auipc	ra,0xffffa
    80006252:	316080e7          	jalr	790(ra) # 80000564 <panic>
    panic("virtio disk has no queue 0");
    80006256:	00004517          	auipc	a0,0x4
    8000625a:	baa50513          	addi	a0,a0,-1110 # 80009e00 <syscalls+0x3e8>
    8000625e:	ffffa097          	auipc	ra,0xffffa
    80006262:	306080e7          	jalr	774(ra) # 80000564 <panic>
    panic("virtio disk max queue too short");
    80006266:	00004517          	auipc	a0,0x4
    8000626a:	bba50513          	addi	a0,a0,-1094 # 80009e20 <syscalls+0x408>
    8000626e:	ffffa097          	auipc	ra,0xffffa
    80006272:	2f6080e7          	jalr	758(ra) # 80000564 <panic>

0000000080006276 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006276:	7119                	addi	sp,sp,-128
    80006278:	fc86                	sd	ra,120(sp)
    8000627a:	f8a2                	sd	s0,112(sp)
    8000627c:	f4a6                	sd	s1,104(sp)
    8000627e:	f0ca                	sd	s2,96(sp)
    80006280:	ecce                	sd	s3,88(sp)
    80006282:	e8d2                	sd	s4,80(sp)
    80006284:	e4d6                	sd	s5,72(sp)
    80006286:	e0da                	sd	s6,64(sp)
    80006288:	fc5e                	sd	s7,56(sp)
    8000628a:	f862                	sd	s8,48(sp)
    8000628c:	f466                	sd	s9,40(sp)
    8000628e:	f06a                	sd	s10,32(sp)
    80006290:	ec6e                	sd	s11,24(sp)
    80006292:	0100                	addi	s0,sp,128
    80006294:	8aaa                	mv	s5,a0
    80006296:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006298:	00c52d03          	lw	s10,12(a0)
    8000629c:	001d1d1b          	slliw	s10,s10,0x1
    800062a0:	1d02                	slli	s10,s10,0x20
    800062a2:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800062a6:	00032517          	auipc	a0,0x32
    800062aa:	0da50513          	addi	a0,a0,218 # 80038380 <disk+0x128>
    800062ae:	ffffb097          	auipc	ra,0xffffb
    800062b2:	8e4080e7          	jalr	-1820(ra) # 80000b92 <acquire>
  for(int i = 0; i < 3; i++){
    800062b6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062b8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062ba:	00032b97          	auipc	s7,0x32
    800062be:	f9eb8b93          	addi	s7,s7,-98 # 80038258 <disk>
  for(int i = 0; i < 3; i++){
    800062c2:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062c4:	00032c97          	auipc	s9,0x32
    800062c8:	0bcc8c93          	addi	s9,s9,188 # 80038380 <disk+0x128>
    800062cc:	a08d                	j	8000632e <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800062ce:	00fb8733          	add	a4,s7,a5
    800062d2:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062d6:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062d8:	0207c563          	bltz	a5,80006302 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800062dc:	2905                	addiw	s2,s2,1
    800062de:	0611                	addi	a2,a2,4
    800062e0:	0b690263          	beq	s2,s6,80006384 <virtio_disk_rw+0x10e>
    idx[i] = alloc_desc();
    800062e4:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800062e6:	00032717          	auipc	a4,0x32
    800062ea:	f7270713          	addi	a4,a4,-142 # 80038258 <disk>
    800062ee:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800062f0:	01874683          	lbu	a3,24(a4)
    800062f4:	fee9                	bnez	a3,800062ce <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800062f6:	2785                	addiw	a5,a5,1
    800062f8:	0705                	addi	a4,a4,1
    800062fa:	fe979be3          	bne	a5,s1,800062f0 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800062fe:	57fd                	li	a5,-1
    80006300:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006302:	01205d63          	blez	s2,8000631c <virtio_disk_rw+0xa6>
    80006306:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006308:	000a2503          	lw	a0,0(s4)
    8000630c:	00000097          	auipc	ra,0x0
    80006310:	d0a080e7          	jalr	-758(ra) # 80006016 <free_desc>
      for(int j = 0; j < i; j++)
    80006314:	2d85                	addiw	s11,s11,1
    80006316:	0a11                	addi	s4,s4,4
    80006318:	ffb918e3          	bne	s2,s11,80006308 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000631c:	85e6                	mv	a1,s9
    8000631e:	00032517          	auipc	a0,0x32
    80006322:	f5250513          	addi	a0,a0,-174 # 80038270 <disk+0x18>
    80006326:	ffffc097          	auipc	ra,0xffffc
    8000632a:	1b2080e7          	jalr	434(ra) # 800024d8 <sleep>
  for(int i = 0; i < 3; i++){
    8000632e:	f8040a13          	addi	s4,s0,-128
{
    80006332:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006334:	894e                	mv	s2,s3
    80006336:	b77d                	j	800062e4 <virtio_disk_rw+0x6e>
      i = disk.desc[i].next;
    80006338:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000633c:	8526                	mv	a0,s1
    8000633e:	00000097          	auipc	ra,0x0
    80006342:	cd8080e7          	jalr	-808(ra) # 80006016 <free_desc>
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    80006346:	0492                	slli	s1,s1,0x4
    80006348:	00093783          	ld	a5,0(s2)
    8000634c:	94be                	add	s1,s1,a5
    8000634e:	00c4d783          	lhu	a5,12(s1)
    80006352:	8b85                	andi	a5,a5,1
    80006354:	f3f5                	bnez	a5,80006338 <virtio_disk_rw+0xc2>
  }

  disk.info[idx[0]].b = 0;
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006356:	00032517          	auipc	a0,0x32
    8000635a:	02a50513          	addi	a0,a0,42 # 80038380 <disk+0x128>
    8000635e:	ffffb097          	auipc	ra,0xffffb
    80006362:	904080e7          	jalr	-1788(ra) # 80000c62 <release>
}
    80006366:	70e6                	ld	ra,120(sp)
    80006368:	7446                	ld	s0,112(sp)
    8000636a:	74a6                	ld	s1,104(sp)
    8000636c:	7906                	ld	s2,96(sp)
    8000636e:	69e6                	ld	s3,88(sp)
    80006370:	6a46                	ld	s4,80(sp)
    80006372:	6aa6                	ld	s5,72(sp)
    80006374:	6b06                	ld	s6,64(sp)
    80006376:	7be2                	ld	s7,56(sp)
    80006378:	7c42                	ld	s8,48(sp)
    8000637a:	7ca2                	ld	s9,40(sp)
    8000637c:	7d02                	ld	s10,32(sp)
    8000637e:	6de2                	ld	s11,24(sp)
    80006380:	6109                	addi	sp,sp,128
    80006382:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006384:	f8042583          	lw	a1,-128(s0)
    80006388:	00a58793          	addi	a5,a1,10
    8000638c:	0792                	slli	a5,a5,0x4
  if(write)
    8000638e:	00032617          	auipc	a2,0x32
    80006392:	eca60613          	addi	a2,a2,-310 # 80038258 <disk>
    80006396:	00f60733          	add	a4,a2,a5
    8000639a:	018036b3          	snez	a3,s8
    8000639e:	c714                	sw	a3,8(a4)
  buf0->reserved = 0;
    800063a0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063a4:	01a73823          	sd	s10,16(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063a8:	f6078693          	addi	a3,a5,-160
    800063ac:	6218                	ld	a4,0(a2)
    800063ae:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063b0:	00878513          	addi	a0,a5,8
    800063b4:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063b6:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063b8:	6208                	ld	a0,0(a2)
    800063ba:	96aa                	add	a3,a3,a0
    800063bc:	4741                	li	a4,16
    800063be:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VIRTQ_DESC_F_NEXT;
    800063c0:	4705                	li	a4,1
    800063c2:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063c6:	f8442703          	lw	a4,-124(s0)
    800063ca:	00e69723          	sh	a4,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800063ce:	0712                	slli	a4,a4,0x4
    800063d0:	953a                	add	a0,a0,a4
    800063d2:	060a8693          	addi	a3,s5,96
    800063d6:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063d8:	6208                	ld	a0,0(a2)
    800063da:	972a                	add	a4,a4,a0
    800063dc:	40000693          	li	a3,1024
    800063e0:	c714                	sw	a3,8(a4)
    disk.desc[idx[1]].flags = VIRTQ_DESC_F_WRITE; // device writes b->data
    800063e2:	001c3c13          	seqz	s8,s8
    800063e6:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VIRTQ_DESC_F_NEXT;
    800063e8:	001c6c13          	ori	s8,s8,1
    800063ec:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800063f0:	f8842603          	lw	a2,-120(s0)
    800063f4:	00c71723          	sh	a2,14(a4)
  disk.info[idx[0]].status = 0;
    800063f8:	00032697          	auipc	a3,0x32
    800063fc:	e6068693          	addi	a3,a3,-416 # 80038258 <disk>
    80006400:	00258713          	addi	a4,a1,2
    80006404:	0712                	slli	a4,a4,0x4
    80006406:	9736                	add	a4,a4,a3
    80006408:	00070823          	sb	zero,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000640c:	0612                	slli	a2,a2,0x4
    8000640e:	9532                	add	a0,a0,a2
    80006410:	f9078793          	addi	a5,a5,-112
    80006414:	97b6                	add	a5,a5,a3
    80006416:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    80006418:	629c                	ld	a5,0(a3)
    8000641a:	97b2                	add	a5,a5,a2
    8000641c:	4605                	li	a2,1
    8000641e:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VIRTQ_DESC_F_WRITE; // device writes the status
    80006420:	4509                	li	a0,2
    80006422:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    80006426:	00079723          	sh	zero,14(a5)
  b->disk = 1;
    8000642a:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    8000642e:	01573423          	sd	s5,8(a4)
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006432:	6698                	ld	a4,8(a3)
    80006434:	00275783          	lhu	a5,2(a4)
    80006438:	8b9d                	andi	a5,a5,7
    8000643a:	0786                	slli	a5,a5,0x1
    8000643c:	97ba                	add	a5,a5,a4
    8000643e:	00b79223          	sh	a1,4(a5)
  __sync_synchronize();
    80006442:	0ff0000f          	fence
  disk.avail->idx += 1;
    80006446:	6698                	ld	a4,8(a3)
    80006448:	00275783          	lhu	a5,2(a4)
    8000644c:	2785                	addiw	a5,a5,1
    8000644e:	00f71123          	sh	a5,2(a4)
  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006452:	100017b7          	lui	a5,0x10001
    80006456:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
  while(b->disk == 1) {
    8000645a:	004aa783          	lw	a5,4(s5)
    8000645e:	02c79163          	bne	a5,a2,80006480 <virtio_disk_rw+0x20a>
    sleep(b, &disk.vdisk_lock);
    80006462:	00032917          	auipc	s2,0x32
    80006466:	f1e90913          	addi	s2,s2,-226 # 80038380 <disk+0x128>
  while(b->disk == 1) {
    8000646a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000646c:	85ca                	mv	a1,s2
    8000646e:	8556                	mv	a0,s5
    80006470:	ffffc097          	auipc	ra,0xffffc
    80006474:	068080e7          	jalr	104(ra) # 800024d8 <sleep>
  while(b->disk == 1) {
    80006478:	004aa783          	lw	a5,4(s5)
    8000647c:	fe9788e3          	beq	a5,s1,8000646c <virtio_disk_rw+0x1f6>
  disk.info[idx[0]].b = 0;
    80006480:	f8042483          	lw	s1,-128(s0)
    80006484:	00248793          	addi	a5,s1,2
    80006488:	00479713          	slli	a4,a5,0x4
    8000648c:	00032797          	auipc	a5,0x32
    80006490:	dcc78793          	addi	a5,a5,-564 # 80038258 <disk>
    80006494:	97ba                	add	a5,a5,a4
    80006496:	0007b423          	sd	zero,8(a5)
    if(disk.desc[i].flags & VIRTQ_DESC_F_NEXT)
    8000649a:	00032917          	auipc	s2,0x32
    8000649e:	dbe90913          	addi	s2,s2,-578 # 80038258 <disk>
    800064a2:	bd69                	j	8000633c <virtio_disk_rw+0xc6>

00000000800064a4 <virtio_disk_intr>:

void
virtio_disk_intr(void)
{
    800064a4:	1101                	addi	sp,sp,-32
    800064a6:	ec06                	sd	ra,24(sp)
    800064a8:	e822                	sd	s0,16(sp)
    800064aa:	e426                	sd	s1,8(sp)
    800064ac:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800064ae:	00032497          	auipc	s1,0x32
    800064b2:	daa48493          	addi	s1,s1,-598 # 80038258 <disk>
    800064b6:	00032517          	auipc	a0,0x32
    800064ba:	eca50513          	addi	a0,a0,-310 # 80038380 <disk+0x128>
    800064be:	ffffa097          	auipc	ra,0xffffa
    800064c2:	6d4080e7          	jalr	1748(ra) # 80000b92 <acquire>

  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    800064c6:	0204d783          	lhu	a5,32(s1)
    800064ca:	6898                	ld	a4,16(s1)
    800064cc:	00275683          	lhu	a3,2(a4)
    800064d0:	8ebd                	xor	a3,a3,a5
    800064d2:	8a9d                	andi	a3,a3,7
    800064d4:	c2b1                	beqz	a3,80006518 <virtio_disk_intr+0x74>
    int id = disk.used->ring[disk.used_idx].id;
    800064d6:	078e                	slli	a5,a5,0x3
    800064d8:	97ba                	add	a5,a5,a4
    800064da:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800064dc:	00278713          	addi	a4,a5,2
    800064e0:	0712                	slli	a4,a4,0x4
    800064e2:	9726                	add	a4,a4,s1
    800064e4:	01074703          	lbu	a4,16(a4)
    800064e8:	eb31                	bnez	a4,8000653c <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    800064ea:	0789                	addi	a5,a5,2
    800064ec:	0792                	slli	a5,a5,0x4
    800064ee:	97a6                	add	a5,a5,s1
    800064f0:	6798                	ld	a4,8(a5)
    800064f2:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800064f6:	6788                	ld	a0,8(a5)
    800064f8:	ffffc097          	auipc	ra,0xffffc
    800064fc:	19e080e7          	jalr	414(ra) # 80002696 <wakeup>

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006500:	0204d783          	lhu	a5,32(s1)
    80006504:	2785                	addiw	a5,a5,1
    80006506:	8b9d                	andi	a5,a5,7
    80006508:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->idx % NUM)){
    8000650c:	6898                	ld	a4,16(s1)
    8000650e:	00275683          	lhu	a3,2(a4)
    80006512:	8a9d                	andi	a3,a3,7
    80006514:	fcf691e3          	bne	a3,a5,800064d6 <virtio_disk_intr+0x32>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006518:	10001737          	lui	a4,0x10001
    8000651c:	533c                	lw	a5,96(a4)
    8000651e:	8b8d                	andi	a5,a5,3
    80006520:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006522:	00032517          	auipc	a0,0x32
    80006526:	e5e50513          	addi	a0,a0,-418 # 80038380 <disk+0x128>
    8000652a:	ffffa097          	auipc	ra,0xffffa
    8000652e:	738080e7          	jalr	1848(ra) # 80000c62 <release>
}
    80006532:	60e2                	ld	ra,24(sp)
    80006534:	6442                	ld	s0,16(sp)
    80006536:	64a2                	ld	s1,8(sp)
    80006538:	6105                	addi	sp,sp,32
    8000653a:	8082                	ret
      panic("virtio_disk_intr status");
    8000653c:	00004517          	auipc	a0,0x4
    80006540:	90450513          	addi	a0,a0,-1788 # 80009e40 <syscalls+0x428>
    80006544:	ffffa097          	auipc	ra,0xffffa
    80006548:	020080e7          	jalr	32(ra) # 80000564 <panic>

000000008000654c <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    8000654c:	1141                	addi	sp,sp,-16
    8000654e:	e422                	sd	s0,8(sp)
    80006550:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    80006552:	41f5d79b          	sraiw	a5,a1,0x1f
    80006556:	01d7d79b          	srliw	a5,a5,0x1d
    8000655a:	9dbd                	addw	a1,a1,a5
    8000655c:	0075f713          	andi	a4,a1,7
    80006560:	9f1d                	subw	a4,a4,a5
    80006562:	4785                	li	a5,1
    80006564:	00e797bb          	sllw	a5,a5,a4
    80006568:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    8000656c:	4035d59b          	sraiw	a1,a1,0x3
    80006570:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006572:	0005c503          	lbu	a0,0(a1)
    80006576:	8d7d                	and	a0,a0,a5
    80006578:	8d1d                	sub	a0,a0,a5
}
    8000657a:	00153513          	seqz	a0,a0
    8000657e:	6422                	ld	s0,8(sp)
    80006580:	0141                	addi	sp,sp,16
    80006582:	8082                	ret

0000000080006584 <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    80006584:	1141                	addi	sp,sp,-16
    80006586:	e422                	sd	s0,8(sp)
    80006588:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000658a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000658e:	01d7d79b          	srliw	a5,a5,0x1d
    80006592:	9dbd                	addw	a1,a1,a5
    80006594:	4035d71b          	sraiw	a4,a1,0x3
    80006598:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000659a:	899d                	andi	a1,a1,7
    8000659c:	9d9d                	subw	a1,a1,a5
    8000659e:	4785                	li	a5,1
    800065a0:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800065a4:	00054783          	lbu	a5,0(a0)
    800065a8:	8ddd                	or	a1,a1,a5
    800065aa:	00b50023          	sb	a1,0(a0)
}
    800065ae:	6422                	ld	s0,8(sp)
    800065b0:	0141                	addi	sp,sp,16
    800065b2:	8082                	ret

00000000800065b4 <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800065b4:	1141                	addi	sp,sp,-16
    800065b6:	e422                	sd	s0,8(sp)
    800065b8:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800065ba:	41f5d79b          	sraiw	a5,a1,0x1f
    800065be:	01d7d79b          	srliw	a5,a5,0x1d
    800065c2:	9dbd                	addw	a1,a1,a5
    800065c4:	4035d71b          	sraiw	a4,a1,0x3
    800065c8:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800065ca:	899d                	andi	a1,a1,7
    800065cc:	9d9d                	subw	a1,a1,a5
    800065ce:	4785                	li	a5,1
    800065d0:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    800065d4:	fff5c593          	not	a1,a1
    800065d8:	00054783          	lbu	a5,0(a0)
    800065dc:	8dfd                	and	a1,a1,a5
    800065de:	00b50023          	sb	a1,0(a0)
}
    800065e2:	6422                	ld	s0,8(sp)
    800065e4:	0141                	addi	sp,sp,16
    800065e6:	8082                	ret

00000000800065e8 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    800065e8:	715d                	addi	sp,sp,-80
    800065ea:	e486                	sd	ra,72(sp)
    800065ec:	e0a2                	sd	s0,64(sp)
    800065ee:	fc26                	sd	s1,56(sp)
    800065f0:	f84a                	sd	s2,48(sp)
    800065f2:	f44e                	sd	s3,40(sp)
    800065f4:	f052                	sd	s4,32(sp)
    800065f6:	ec56                	sd	s5,24(sp)
    800065f8:	e85a                	sd	s6,16(sp)
    800065fa:	e45e                	sd	s7,8(sp)
    800065fc:	0880                	addi	s0,sp,80
    800065fe:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006600:	08b05b63          	blez	a1,80006696 <bd_print_vector+0xae>
    80006604:	89aa                	mv	s3,a0
    80006606:	4481                	li	s1,0
  lb = 0;
    80006608:	4a81                	li	s5,0
  last = 1;
    8000660a:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    8000660c:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    8000660e:	00004b97          	auipc	s7,0x4
    80006612:	84ab8b93          	addi	s7,s7,-1974 # 80009e58 <syscalls+0x440>
    80006616:	a821                	j	8000662e <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006618:	85a6                	mv	a1,s1
    8000661a:	854e                	mv	a0,s3
    8000661c:	00000097          	auipc	ra,0x0
    80006620:	f30080e7          	jalr	-208(ra) # 8000654c <bit_isset>
    80006624:	892a                	mv	s2,a0
    80006626:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006628:	2485                	addiw	s1,s1,1
    8000662a:	029a0463          	beq	s4,s1,80006652 <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    8000662e:	85a6                	mv	a1,s1
    80006630:	854e                	mv	a0,s3
    80006632:	00000097          	auipc	ra,0x0
    80006636:	f1a080e7          	jalr	-230(ra) # 8000654c <bit_isset>
    8000663a:	ff2507e3          	beq	a0,s2,80006628 <bd_print_vector+0x40>
    if(last == 1)
    8000663e:	fd691de3          	bne	s2,s6,80006618 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    80006642:	8626                	mv	a2,s1
    80006644:	85d6                	mv	a1,s5
    80006646:	855e                	mv	a0,s7
    80006648:	ffffa097          	auipc	ra,0xffffa
    8000664c:	f7e080e7          	jalr	-130(ra) # 800005c6 <printf>
    80006650:	b7e1                	j	80006618 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    80006652:	000a8563          	beqz	s5,8000665c <bd_print_vector+0x74>
    80006656:	4785                	li	a5,1
    80006658:	00f91c63          	bne	s2,a5,80006670 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    8000665c:	8652                	mv	a2,s4
    8000665e:	85d6                	mv	a1,s5
    80006660:	00003517          	auipc	a0,0x3
    80006664:	7f850513          	addi	a0,a0,2040 # 80009e58 <syscalls+0x440>
    80006668:	ffffa097          	auipc	ra,0xffffa
    8000666c:	f5e080e7          	jalr	-162(ra) # 800005c6 <printf>
  }
  printf("\n");
    80006670:	00003517          	auipc	a0,0x3
    80006674:	b9050513          	addi	a0,a0,-1136 # 80009200 <digits+0x90>
    80006678:	ffffa097          	auipc	ra,0xffffa
    8000667c:	f4e080e7          	jalr	-178(ra) # 800005c6 <printf>
}
    80006680:	60a6                	ld	ra,72(sp)
    80006682:	6406                	ld	s0,64(sp)
    80006684:	74e2                	ld	s1,56(sp)
    80006686:	7942                	ld	s2,48(sp)
    80006688:	79a2                	ld	s3,40(sp)
    8000668a:	7a02                	ld	s4,32(sp)
    8000668c:	6ae2                	ld	s5,24(sp)
    8000668e:	6b42                	ld	s6,16(sp)
    80006690:	6ba2                	ld	s7,8(sp)
    80006692:	6161                	addi	sp,sp,80
    80006694:	8082                	ret
  lb = 0;
    80006696:	4a81                	li	s5,0
    80006698:	b7d1                	j	8000665c <bd_print_vector+0x74>

000000008000669a <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000669a:	00004697          	auipc	a3,0x4
    8000669e:	97e6a683          	lw	a3,-1666(a3) # 8000a018 <nsizes>
    800066a2:	10d05063          	blez	a3,800067a2 <bd_print+0x108>
bd_print() {
    800066a6:	711d                	addi	sp,sp,-96
    800066a8:	ec86                	sd	ra,88(sp)
    800066aa:	e8a2                	sd	s0,80(sp)
    800066ac:	e4a6                	sd	s1,72(sp)
    800066ae:	e0ca                	sd	s2,64(sp)
    800066b0:	fc4e                	sd	s3,56(sp)
    800066b2:	f852                	sd	s4,48(sp)
    800066b4:	f456                	sd	s5,40(sp)
    800066b6:	f05a                	sd	s6,32(sp)
    800066b8:	ec5e                	sd	s7,24(sp)
    800066ba:	e862                	sd	s8,16(sp)
    800066bc:	e466                	sd	s9,8(sp)
    800066be:	e06a                	sd	s10,0(sp)
    800066c0:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800066c2:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800066c4:	4a85                	li	s5,1
    800066c6:	4c41                	li	s8,16
    800066c8:	00003b97          	auipc	s7,0x3
    800066cc:	7a0b8b93          	addi	s7,s7,1952 # 80009e68 <syscalls+0x450>
    lst_print(&bd_sizes[k].free);
    800066d0:	00004a17          	auipc	s4,0x4
    800066d4:	940a0a13          	addi	s4,s4,-1728 # 8000a010 <bd_sizes>
    printf("  alloc:");
    800066d8:	00003b17          	auipc	s6,0x3
    800066dc:	7b8b0b13          	addi	s6,s6,1976 # 80009e90 <syscalls+0x478>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800066e0:	00004997          	auipc	s3,0x4
    800066e4:	93898993          	addi	s3,s3,-1736 # 8000a018 <nsizes>
    if(k > 0) {
      printf("  split:");
    800066e8:	00003c97          	auipc	s9,0x3
    800066ec:	7b8c8c93          	addi	s9,s9,1976 # 80009ea0 <syscalls+0x488>
    800066f0:	a801                	j	80006700 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    800066f2:	0009a683          	lw	a3,0(s3)
    800066f6:	0485                	addi	s1,s1,1
    800066f8:	0004879b          	sext.w	a5,s1
    800066fc:	08d7d563          	bge	a5,a3,80006786 <bd_print+0xec>
    80006700:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    80006704:	36fd                	addiw	a3,a3,-1
    80006706:	9e85                	subw	a3,a3,s1
    80006708:	00da96bb          	sllw	a3,s5,a3
    8000670c:	009c1633          	sll	a2,s8,s1
    80006710:	85ca                	mv	a1,s2
    80006712:	855e                	mv	a0,s7
    80006714:	ffffa097          	auipc	ra,0xffffa
    80006718:	eb2080e7          	jalr	-334(ra) # 800005c6 <printf>
    lst_print(&bd_sizes[k].free);
    8000671c:	00549d13          	slli	s10,s1,0x5
    80006720:	000a3503          	ld	a0,0(s4)
    80006724:	956a                	add	a0,a0,s10
    80006726:	00001097          	auipc	ra,0x1
    8000672a:	a56080e7          	jalr	-1450(ra) # 8000717c <lst_print>
    printf("  alloc:");
    8000672e:	855a                	mv	a0,s6
    80006730:	ffffa097          	auipc	ra,0xffffa
    80006734:	e96080e7          	jalr	-362(ra) # 800005c6 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006738:	0009a583          	lw	a1,0(s3)
    8000673c:	35fd                	addiw	a1,a1,-1
    8000673e:	412585bb          	subw	a1,a1,s2
    80006742:	000a3783          	ld	a5,0(s4)
    80006746:	97ea                	add	a5,a5,s10
    80006748:	00ba95bb          	sllw	a1,s5,a1
    8000674c:	6b88                	ld	a0,16(a5)
    8000674e:	00000097          	auipc	ra,0x0
    80006752:	e9a080e7          	jalr	-358(ra) # 800065e8 <bd_print_vector>
    if(k > 0) {
    80006756:	f9205ee3          	blez	s2,800066f2 <bd_print+0x58>
      printf("  split:");
    8000675a:	8566                	mv	a0,s9
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	e6a080e7          	jalr	-406(ra) # 800005c6 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    80006764:	0009a583          	lw	a1,0(s3)
    80006768:	35fd                	addiw	a1,a1,-1
    8000676a:	412585bb          	subw	a1,a1,s2
    8000676e:	000a3783          	ld	a5,0(s4)
    80006772:	9d3e                	add	s10,s10,a5
    80006774:	00ba95bb          	sllw	a1,s5,a1
    80006778:	018d3503          	ld	a0,24(s10) # fffffffffffff018 <end+0xffffffff7ffc6c58>
    8000677c:	00000097          	auipc	ra,0x0
    80006780:	e6c080e7          	jalr	-404(ra) # 800065e8 <bd_print_vector>
    80006784:	b7bd                	j	800066f2 <bd_print+0x58>
    }
  }
}
    80006786:	60e6                	ld	ra,88(sp)
    80006788:	6446                	ld	s0,80(sp)
    8000678a:	64a6                	ld	s1,72(sp)
    8000678c:	6906                	ld	s2,64(sp)
    8000678e:	79e2                	ld	s3,56(sp)
    80006790:	7a42                	ld	s4,48(sp)
    80006792:	7aa2                	ld	s5,40(sp)
    80006794:	7b02                	ld	s6,32(sp)
    80006796:	6be2                	ld	s7,24(sp)
    80006798:	6c42                	ld	s8,16(sp)
    8000679a:	6ca2                	ld	s9,8(sp)
    8000679c:	6d02                	ld	s10,0(sp)
    8000679e:	6125                	addi	sp,sp,96
    800067a0:	8082                	ret
    800067a2:	8082                	ret

00000000800067a4 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800067a4:	1141                	addi	sp,sp,-16
    800067a6:	e422                	sd	s0,8(sp)
    800067a8:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800067aa:	47c1                	li	a5,16
    800067ac:	00a7fb63          	bgeu	a5,a0,800067c2 <firstk+0x1e>
    800067b0:	872a                	mv	a4,a0
  int k = 0;
    800067b2:	4501                	li	a0,0
    k++;
    800067b4:	2505                	addiw	a0,a0,1
    size *= 2;
    800067b6:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800067b8:	fee7eee3          	bltu	a5,a4,800067b4 <firstk+0x10>
  }
  return k;
}
    800067bc:	6422                	ld	s0,8(sp)
    800067be:	0141                	addi	sp,sp,16
    800067c0:	8082                	ret
  int k = 0;
    800067c2:	4501                	li	a0,0
    800067c4:	bfe5                	j	800067bc <firstk+0x18>

00000000800067c6 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800067c6:	1141                	addi	sp,sp,-16
    800067c8:	e422                	sd	s0,8(sp)
    800067ca:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800067cc:	00004797          	auipc	a5,0x4
    800067d0:	83c7b783          	ld	a5,-1988(a5) # 8000a008 <bd_base>
    800067d4:	9d9d                	subw	a1,a1,a5
    800067d6:	47c1                	li	a5,16
    800067d8:	00a797b3          	sll	a5,a5,a0
    800067dc:	02f5c5b3          	div	a1,a1,a5
}
    800067e0:	0005851b          	sext.w	a0,a1
    800067e4:	6422                	ld	s0,8(sp)
    800067e6:	0141                	addi	sp,sp,16
    800067e8:	8082                	ret

00000000800067ea <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    800067ea:	1141                	addi	sp,sp,-16
    800067ec:	e422                	sd	s0,8(sp)
    800067ee:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    800067f0:	47c1                	li	a5,16
    800067f2:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    800067f6:	02b787bb          	mulw	a5,a5,a1
}
    800067fa:	00004517          	auipc	a0,0x4
    800067fe:	80e53503          	ld	a0,-2034(a0) # 8000a008 <bd_base>
    80006802:	953e                	add	a0,a0,a5
    80006804:	6422                	ld	s0,8(sp)
    80006806:	0141                	addi	sp,sp,16
    80006808:	8082                	ret

000000008000680a <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    8000680a:	7159                	addi	sp,sp,-112
    8000680c:	f486                	sd	ra,104(sp)
    8000680e:	f0a2                	sd	s0,96(sp)
    80006810:	eca6                	sd	s1,88(sp)
    80006812:	e8ca                	sd	s2,80(sp)
    80006814:	e4ce                	sd	s3,72(sp)
    80006816:	e0d2                	sd	s4,64(sp)
    80006818:	fc56                	sd	s5,56(sp)
    8000681a:	f85a                	sd	s6,48(sp)
    8000681c:	f45e                	sd	s7,40(sp)
    8000681e:	f062                	sd	s8,32(sp)
    80006820:	ec66                	sd	s9,24(sp)
    80006822:	e86a                	sd	s10,16(sp)
    80006824:	e46e                	sd	s11,8(sp)
    80006826:	1880                	addi	s0,sp,112
    80006828:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    8000682a:	00032517          	auipc	a0,0x32
    8000682e:	b7650513          	addi	a0,a0,-1162 # 800383a0 <lock>
    80006832:	ffffa097          	auipc	ra,0xffffa
    80006836:	360080e7          	jalr	864(ra) # 80000b92 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    8000683a:	8526                	mv	a0,s1
    8000683c:	00000097          	auipc	ra,0x0
    80006840:	f68080e7          	jalr	-152(ra) # 800067a4 <firstk>
  for (k = fk; k < nsizes; k++) {
    80006844:	00003797          	auipc	a5,0x3
    80006848:	7d47a783          	lw	a5,2004(a5) # 8000a018 <nsizes>
    8000684c:	02f55d63          	bge	a0,a5,80006886 <bd_malloc+0x7c>
    80006850:	8c2a                	mv	s8,a0
    80006852:	00551913          	slli	s2,a0,0x5
    80006856:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006858:	00003997          	auipc	s3,0x3
    8000685c:	7b898993          	addi	s3,s3,1976 # 8000a010 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006860:	00003a17          	auipc	s4,0x3
    80006864:	7b8a0a13          	addi	s4,s4,1976 # 8000a018 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006868:	0009b503          	ld	a0,0(s3)
    8000686c:	954a                	add	a0,a0,s2
    8000686e:	00001097          	auipc	ra,0x1
    80006872:	894080e7          	jalr	-1900(ra) # 80007102 <lst_empty>
    80006876:	c115                	beqz	a0,8000689a <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006878:	2485                	addiw	s1,s1,1
    8000687a:	02090913          	addi	s2,s2,32
    8000687e:	000a2783          	lw	a5,0(s4)
    80006882:	fef4c3e3          	blt	s1,a5,80006868 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006886:	00032517          	auipc	a0,0x32
    8000688a:	b1a50513          	addi	a0,a0,-1254 # 800383a0 <lock>
    8000688e:	ffffa097          	auipc	ra,0xffffa
    80006892:	3d4080e7          	jalr	980(ra) # 80000c62 <release>
    return 0;
    80006896:	4b01                	li	s6,0
    80006898:	a0e1                	j	80006960 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    8000689a:	00003797          	auipc	a5,0x3
    8000689e:	77e7a783          	lw	a5,1918(a5) # 8000a018 <nsizes>
    800068a2:	fef4d2e3          	bge	s1,a5,80006886 <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800068a6:	00549993          	slli	s3,s1,0x5
    800068aa:	00003917          	auipc	s2,0x3
    800068ae:	76690913          	addi	s2,s2,1894 # 8000a010 <bd_sizes>
    800068b2:	00093503          	ld	a0,0(s2)
    800068b6:	954e                	add	a0,a0,s3
    800068b8:	00001097          	auipc	ra,0x1
    800068bc:	876080e7          	jalr	-1930(ra) # 8000712e <lst_pop>
    800068c0:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800068c2:	00003597          	auipc	a1,0x3
    800068c6:	7465b583          	ld	a1,1862(a1) # 8000a008 <bd_base>
    800068ca:	40b505bb          	subw	a1,a0,a1
    800068ce:	47c1                	li	a5,16
    800068d0:	009797b3          	sll	a5,a5,s1
    800068d4:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800068d8:	00093783          	ld	a5,0(s2)
    800068dc:	97ce                	add	a5,a5,s3
    800068de:	2581                	sext.w	a1,a1
    800068e0:	6b88                	ld	a0,16(a5)
    800068e2:	00000097          	auipc	ra,0x0
    800068e6:	ca2080e7          	jalr	-862(ra) # 80006584 <bit_set>
  for(; k > fk; k--) {
    800068ea:	069c5363          	bge	s8,s1,80006950 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800068ee:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800068f0:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800068f2:	00003d17          	auipc	s10,0x3
    800068f6:	716d0d13          	addi	s10,s10,1814 # 8000a008 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    800068fa:	85a6                	mv	a1,s1
    800068fc:	34fd                	addiw	s1,s1,-1
    800068fe:	009b9ab3          	sll	s5,s7,s1
    80006902:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006906:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    8000690a:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000690e:	412b093b          	subw	s2,s6,s2
    80006912:	00bb95b3          	sll	a1,s7,a1
    80006916:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000691a:	013a07b3          	add	a5,s4,s3
    8000691e:	2581                	sext.w	a1,a1
    80006920:	6f88                	ld	a0,24(a5)
    80006922:	00000097          	auipc	ra,0x0
    80006926:	c62080e7          	jalr	-926(ra) # 80006584 <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    8000692a:	1981                	addi	s3,s3,-32
    8000692c:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    8000692e:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006932:	2581                	sext.w	a1,a1
    80006934:	010a3503          	ld	a0,16(s4)
    80006938:	00000097          	auipc	ra,0x0
    8000693c:	c4c080e7          	jalr	-948(ra) # 80006584 <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006940:	85e6                	mv	a1,s9
    80006942:	8552                	mv	a0,s4
    80006944:	00001097          	auipc	ra,0x1
    80006948:	820080e7          	jalr	-2016(ra) # 80007164 <lst_push>
  for(; k > fk; k--) {
    8000694c:	fb8497e3          	bne	s1,s8,800068fa <bd_malloc+0xf0>
  }
  release(&lock);
    80006950:	00032517          	auipc	a0,0x32
    80006954:	a5050513          	addi	a0,a0,-1456 # 800383a0 <lock>
    80006958:	ffffa097          	auipc	ra,0xffffa
    8000695c:	30a080e7          	jalr	778(ra) # 80000c62 <release>

  return p;
}
    80006960:	855a                	mv	a0,s6
    80006962:	70a6                	ld	ra,104(sp)
    80006964:	7406                	ld	s0,96(sp)
    80006966:	64e6                	ld	s1,88(sp)
    80006968:	6946                	ld	s2,80(sp)
    8000696a:	69a6                	ld	s3,72(sp)
    8000696c:	6a06                	ld	s4,64(sp)
    8000696e:	7ae2                	ld	s5,56(sp)
    80006970:	7b42                	ld	s6,48(sp)
    80006972:	7ba2                	ld	s7,40(sp)
    80006974:	7c02                	ld	s8,32(sp)
    80006976:	6ce2                	ld	s9,24(sp)
    80006978:	6d42                	ld	s10,16(sp)
    8000697a:	6da2                	ld	s11,8(sp)
    8000697c:	6165                	addi	sp,sp,112
    8000697e:	8082                	ret

0000000080006980 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006980:	7139                	addi	sp,sp,-64
    80006982:	fc06                	sd	ra,56(sp)
    80006984:	f822                	sd	s0,48(sp)
    80006986:	f426                	sd	s1,40(sp)
    80006988:	f04a                	sd	s2,32(sp)
    8000698a:	ec4e                	sd	s3,24(sp)
    8000698c:	e852                	sd	s4,16(sp)
    8000698e:	e456                	sd	s5,8(sp)
    80006990:	e05a                	sd	s6,0(sp)
    80006992:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006994:	00003a97          	auipc	s5,0x3
    80006998:	684aaa83          	lw	s5,1668(s5) # 8000a018 <nsizes>
  return n / BLK_SIZE(k);
    8000699c:	00003a17          	auipc	s4,0x3
    800069a0:	66ca3a03          	ld	s4,1644(s4) # 8000a008 <bd_base>
    800069a4:	41450a3b          	subw	s4,a0,s4
    800069a8:	00003497          	auipc	s1,0x3
    800069ac:	6684b483          	ld	s1,1640(s1) # 8000a010 <bd_sizes>
    800069b0:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    800069b4:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    800069b6:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    800069b8:	03595363          	bge	s2,s5,800069de <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800069bc:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    800069c0:	013b15b3          	sll	a1,s6,s3
    800069c4:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    800069c8:	2581                	sext.w	a1,a1
    800069ca:	6088                	ld	a0,0(s1)
    800069cc:	00000097          	auipc	ra,0x0
    800069d0:	b80080e7          	jalr	-1152(ra) # 8000654c <bit_isset>
    800069d4:	02048493          	addi	s1,s1,32
    800069d8:	e501                	bnez	a0,800069e0 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    800069da:	894e                	mv	s2,s3
    800069dc:	bff1                	j	800069b8 <size+0x38>
      return k;
    }
  }
  return 0;
    800069de:	4901                	li	s2,0
}
    800069e0:	854a                	mv	a0,s2
    800069e2:	70e2                	ld	ra,56(sp)
    800069e4:	7442                	ld	s0,48(sp)
    800069e6:	74a2                	ld	s1,40(sp)
    800069e8:	7902                	ld	s2,32(sp)
    800069ea:	69e2                	ld	s3,24(sp)
    800069ec:	6a42                	ld	s4,16(sp)
    800069ee:	6aa2                	ld	s5,8(sp)
    800069f0:	6b02                	ld	s6,0(sp)
    800069f2:	6121                	addi	sp,sp,64
    800069f4:	8082                	ret

00000000800069f6 <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    800069f6:	7159                	addi	sp,sp,-112
    800069f8:	f486                	sd	ra,104(sp)
    800069fa:	f0a2                	sd	s0,96(sp)
    800069fc:	eca6                	sd	s1,88(sp)
    800069fe:	e8ca                	sd	s2,80(sp)
    80006a00:	e4ce                	sd	s3,72(sp)
    80006a02:	e0d2                	sd	s4,64(sp)
    80006a04:	fc56                	sd	s5,56(sp)
    80006a06:	f85a                	sd	s6,48(sp)
    80006a08:	f45e                	sd	s7,40(sp)
    80006a0a:	f062                	sd	s8,32(sp)
    80006a0c:	ec66                	sd	s9,24(sp)
    80006a0e:	e86a                	sd	s10,16(sp)
    80006a10:	e46e                	sd	s11,8(sp)
    80006a12:	1880                	addi	s0,sp,112
    80006a14:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006a16:	00032517          	auipc	a0,0x32
    80006a1a:	98a50513          	addi	a0,a0,-1654 # 800383a0 <lock>
    80006a1e:	ffffa097          	auipc	ra,0xffffa
    80006a22:	174080e7          	jalr	372(ra) # 80000b92 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a26:	8556                	mv	a0,s5
    80006a28:	00000097          	auipc	ra,0x0
    80006a2c:	f58080e7          	jalr	-168(ra) # 80006980 <size>
    80006a30:	84aa                	mv	s1,a0
    80006a32:	00003797          	auipc	a5,0x3
    80006a36:	5e67a783          	lw	a5,1510(a5) # 8000a018 <nsizes>
    80006a3a:	37fd                	addiw	a5,a5,-1
    80006a3c:	0cf55063          	bge	a0,a5,80006afc <bd_free+0x106>
    80006a40:	00150a13          	addi	s4,a0,1
    80006a44:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006a46:	00003c17          	auipc	s8,0x3
    80006a4a:	5c2c0c13          	addi	s8,s8,1474 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    80006a4e:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006a50:	00003b17          	auipc	s6,0x3
    80006a54:	5c0b0b13          	addi	s6,s6,1472 # 8000a010 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a58:	00003c97          	auipc	s9,0x3
    80006a5c:	5c0c8c93          	addi	s9,s9,1472 # 8000a018 <nsizes>
    80006a60:	a82d                	j	80006a9a <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006a62:	fff58d9b          	addiw	s11,a1,-1
    80006a66:	a881                	j	80006ab6 <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006a68:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006a6a:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006a6e:	40ba85bb          	subw	a1,s5,a1
    80006a72:	009b97b3          	sll	a5,s7,s1
    80006a76:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006a7a:	000b3783          	ld	a5,0(s6)
    80006a7e:	97d2                	add	a5,a5,s4
    80006a80:	2581                	sext.w	a1,a1
    80006a82:	6f88                	ld	a0,24(a5)
    80006a84:	00000097          	auipc	ra,0x0
    80006a88:	b30080e7          	jalr	-1232(ra) # 800065b4 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a8c:	020a0a13          	addi	s4,s4,32
    80006a90:	000ca783          	lw	a5,0(s9)
    80006a94:	37fd                	addiw	a5,a5,-1
    80006a96:	06f4d363          	bge	s1,a5,80006afc <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006a9a:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006a9e:	009b99b3          	sll	s3,s7,s1
    80006aa2:	412a87bb          	subw	a5,s5,s2
    80006aa6:	0337c7b3          	div	a5,a5,s3
    80006aaa:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006aae:	8b85                	andi	a5,a5,1
    80006ab0:	fbcd                	bnez	a5,80006a62 <bd_free+0x6c>
    80006ab2:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006ab6:	fe0a0d13          	addi	s10,s4,-32
    80006aba:	000b3783          	ld	a5,0(s6)
    80006abe:	9d3e                	add	s10,s10,a5
    80006ac0:	010d3503          	ld	a0,16(s10)
    80006ac4:	00000097          	auipc	ra,0x0
    80006ac8:	af0080e7          	jalr	-1296(ra) # 800065b4 <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006acc:	85ee                	mv	a1,s11
    80006ace:	010d3503          	ld	a0,16(s10)
    80006ad2:	00000097          	auipc	ra,0x0
    80006ad6:	a7a080e7          	jalr	-1414(ra) # 8000654c <bit_isset>
    80006ada:	e10d                	bnez	a0,80006afc <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006adc:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006ae0:	03b989bb          	mulw	s3,s3,s11
    80006ae4:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006ae6:	854a                	mv	a0,s2
    80006ae8:	00000097          	auipc	ra,0x0
    80006aec:	630080e7          	jalr	1584(ra) # 80007118 <lst_remove>
    if(buddy % 2 == 0) {
    80006af0:	001d7d13          	andi	s10,s10,1
    80006af4:	f60d1ae3          	bnez	s10,80006a68 <bd_free+0x72>
      p = q;
    80006af8:	8aca                	mv	s5,s2
    80006afa:	b7bd                	j	80006a68 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006afc:	0496                	slli	s1,s1,0x5
    80006afe:	85d6                	mv	a1,s5
    80006b00:	00003517          	auipc	a0,0x3
    80006b04:	51053503          	ld	a0,1296(a0) # 8000a010 <bd_sizes>
    80006b08:	9526                	add	a0,a0,s1
    80006b0a:	00000097          	auipc	ra,0x0
    80006b0e:	65a080e7          	jalr	1626(ra) # 80007164 <lst_push>
  release(&lock);
    80006b12:	00032517          	auipc	a0,0x32
    80006b16:	88e50513          	addi	a0,a0,-1906 # 800383a0 <lock>
    80006b1a:	ffffa097          	auipc	ra,0xffffa
    80006b1e:	148080e7          	jalr	328(ra) # 80000c62 <release>
}
    80006b22:	70a6                	ld	ra,104(sp)
    80006b24:	7406                	ld	s0,96(sp)
    80006b26:	64e6                	ld	s1,88(sp)
    80006b28:	6946                	ld	s2,80(sp)
    80006b2a:	69a6                	ld	s3,72(sp)
    80006b2c:	6a06                	ld	s4,64(sp)
    80006b2e:	7ae2                	ld	s5,56(sp)
    80006b30:	7b42                	ld	s6,48(sp)
    80006b32:	7ba2                	ld	s7,40(sp)
    80006b34:	7c02                	ld	s8,32(sp)
    80006b36:	6ce2                	ld	s9,24(sp)
    80006b38:	6d42                	ld	s10,16(sp)
    80006b3a:	6da2                	ld	s11,8(sp)
    80006b3c:	6165                	addi	sp,sp,112
    80006b3e:	8082                	ret

0000000080006b40 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006b40:	1141                	addi	sp,sp,-16
    80006b42:	e422                	sd	s0,8(sp)
    80006b44:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006b46:	00003797          	auipc	a5,0x3
    80006b4a:	4c27b783          	ld	a5,1218(a5) # 8000a008 <bd_base>
    80006b4e:	8d9d                	sub	a1,a1,a5
    80006b50:	47c1                	li	a5,16
    80006b52:	00a797b3          	sll	a5,a5,a0
    80006b56:	02f5c533          	div	a0,a1,a5
    80006b5a:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006b5c:	02f5e5b3          	rem	a1,a1,a5
    80006b60:	c191                	beqz	a1,80006b64 <blk_index_next+0x24>
      n++;
    80006b62:	2505                	addiw	a0,a0,1
  return n ;
}
    80006b64:	6422                	ld	s0,8(sp)
    80006b66:	0141                	addi	sp,sp,16
    80006b68:	8082                	ret

0000000080006b6a <log2>:

int
log2(uint64 n) {
    80006b6a:	1141                	addi	sp,sp,-16
    80006b6c:	e422                	sd	s0,8(sp)
    80006b6e:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006b70:	4705                	li	a4,1
    80006b72:	00a77b63          	bgeu	a4,a0,80006b88 <log2+0x1e>
    80006b76:	87aa                	mv	a5,a0
  int k = 0;
    80006b78:	4501                	li	a0,0
    k++;
    80006b7a:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006b7c:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006b7e:	fef76ee3          	bltu	a4,a5,80006b7a <log2+0x10>
  }
  return k;
}
    80006b82:	6422                	ld	s0,8(sp)
    80006b84:	0141                	addi	sp,sp,16
    80006b86:	8082                	ret
  int k = 0;
    80006b88:	4501                	li	a0,0
    80006b8a:	bfe5                	j	80006b82 <log2+0x18>

0000000080006b8c <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006b8c:	711d                	addi	sp,sp,-96
    80006b8e:	ec86                	sd	ra,88(sp)
    80006b90:	e8a2                	sd	s0,80(sp)
    80006b92:	e4a6                	sd	s1,72(sp)
    80006b94:	e0ca                	sd	s2,64(sp)
    80006b96:	fc4e                	sd	s3,56(sp)
    80006b98:	f852                	sd	s4,48(sp)
    80006b9a:	f456                	sd	s5,40(sp)
    80006b9c:	f05a                	sd	s6,32(sp)
    80006b9e:	ec5e                	sd	s7,24(sp)
    80006ba0:	e862                	sd	s8,16(sp)
    80006ba2:	e466                	sd	s9,8(sp)
    80006ba4:	e06a                	sd	s10,0(sp)
    80006ba6:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006ba8:	00b56933          	or	s2,a0,a1
    80006bac:	00f97913          	andi	s2,s2,15
    80006bb0:	04091263          	bnez	s2,80006bf4 <bd_mark+0x68>
    80006bb4:	8b2a                	mv	s6,a0
    80006bb6:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006bb8:	00003c17          	auipc	s8,0x3
    80006bbc:	460c2c03          	lw	s8,1120(s8) # 8000a018 <nsizes>
    80006bc0:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006bc2:	00003d17          	auipc	s10,0x3
    80006bc6:	446d0d13          	addi	s10,s10,1094 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    80006bca:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006bcc:	00003a97          	auipc	s5,0x3
    80006bd0:	444a8a93          	addi	s5,s5,1092 # 8000a010 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006bd4:	07804563          	bgtz	s8,80006c3e <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006bd8:	60e6                	ld	ra,88(sp)
    80006bda:	6446                	ld	s0,80(sp)
    80006bdc:	64a6                	ld	s1,72(sp)
    80006bde:	6906                	ld	s2,64(sp)
    80006be0:	79e2                	ld	s3,56(sp)
    80006be2:	7a42                	ld	s4,48(sp)
    80006be4:	7aa2                	ld	s5,40(sp)
    80006be6:	7b02                	ld	s6,32(sp)
    80006be8:	6be2                	ld	s7,24(sp)
    80006bea:	6c42                	ld	s8,16(sp)
    80006bec:	6ca2                	ld	s9,8(sp)
    80006bee:	6d02                	ld	s10,0(sp)
    80006bf0:	6125                	addi	sp,sp,96
    80006bf2:	8082                	ret
    panic("bd_mark");
    80006bf4:	00003517          	auipc	a0,0x3
    80006bf8:	2bc50513          	addi	a0,a0,700 # 80009eb0 <syscalls+0x498>
    80006bfc:	ffffa097          	auipc	ra,0xffffa
    80006c00:	968080e7          	jalr	-1688(ra) # 80000564 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006c04:	000ab783          	ld	a5,0(s5)
    80006c08:	97ca                	add	a5,a5,s2
    80006c0a:	85a6                	mv	a1,s1
    80006c0c:	6b88                	ld	a0,16(a5)
    80006c0e:	00000097          	auipc	ra,0x0
    80006c12:	976080e7          	jalr	-1674(ra) # 80006584 <bit_set>
    for(; bi < bj; bi++) {
    80006c16:	2485                	addiw	s1,s1,1
    80006c18:	009a0e63          	beq	s4,s1,80006c34 <bd_mark+0xa8>
      if(k > 0) {
    80006c1c:	ff3054e3          	blez	s3,80006c04 <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006c20:	000ab783          	ld	a5,0(s5)
    80006c24:	97ca                	add	a5,a5,s2
    80006c26:	85a6                	mv	a1,s1
    80006c28:	6f88                	ld	a0,24(a5)
    80006c2a:	00000097          	auipc	ra,0x0
    80006c2e:	95a080e7          	jalr	-1702(ra) # 80006584 <bit_set>
    80006c32:	bfc9                	j	80006c04 <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006c34:	2985                	addiw	s3,s3,1
    80006c36:	02090913          	addi	s2,s2,32
    80006c3a:	f9898fe3          	beq	s3,s8,80006bd8 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006c3e:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006c42:	409b04bb          	subw	s1,s6,s1
    80006c46:	013c97b3          	sll	a5,s9,s3
    80006c4a:	02f4c4b3          	div	s1,s1,a5
    80006c4e:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006c50:	85de                	mv	a1,s7
    80006c52:	854e                	mv	a0,s3
    80006c54:	00000097          	auipc	ra,0x0
    80006c58:	eec080e7          	jalr	-276(ra) # 80006b40 <blk_index_next>
    80006c5c:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006c5e:	faa4cfe3          	blt	s1,a0,80006c1c <bd_mark+0x90>
    80006c62:	bfc9                	j	80006c34 <bd_mark+0xa8>

0000000080006c64 <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006c64:	7139                	addi	sp,sp,-64
    80006c66:	fc06                	sd	ra,56(sp)
    80006c68:	f822                	sd	s0,48(sp)
    80006c6a:	f426                	sd	s1,40(sp)
    80006c6c:	f04a                	sd	s2,32(sp)
    80006c6e:	ec4e                	sd	s3,24(sp)
    80006c70:	e852                	sd	s4,16(sp)
    80006c72:	e456                	sd	s5,8(sp)
    80006c74:	e05a                	sd	s6,0(sp)
    80006c76:	0080                	addi	s0,sp,64
    80006c78:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006c7a:	00058a9b          	sext.w	s5,a1
    80006c7e:	0015f793          	andi	a5,a1,1
    80006c82:	ebad                	bnez	a5,80006cf4 <bd_initfree_pair+0x90>
    80006c84:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006c88:	00599493          	slli	s1,s3,0x5
    80006c8c:	00003797          	auipc	a5,0x3
    80006c90:	3847b783          	ld	a5,900(a5) # 8000a010 <bd_sizes>
    80006c94:	94be                	add	s1,s1,a5
    80006c96:	0104bb03          	ld	s6,16(s1)
    80006c9a:	855a                	mv	a0,s6
    80006c9c:	00000097          	auipc	ra,0x0
    80006ca0:	8b0080e7          	jalr	-1872(ra) # 8000654c <bit_isset>
    80006ca4:	892a                	mv	s2,a0
    80006ca6:	85d2                	mv	a1,s4
    80006ca8:	855a                	mv	a0,s6
    80006caa:	00000097          	auipc	ra,0x0
    80006cae:	8a2080e7          	jalr	-1886(ra) # 8000654c <bit_isset>
  int free = 0;
    80006cb2:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006cb4:	02a90563          	beq	s2,a0,80006cde <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006cb8:	45c1                	li	a1,16
    80006cba:	013599b3          	sll	s3,a1,s3
    80006cbe:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006cc2:	02090c63          	beqz	s2,80006cfa <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006cc6:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006cca:	00003597          	auipc	a1,0x3
    80006cce:	33e5b583          	ld	a1,830(a1) # 8000a008 <bd_base>
    80006cd2:	95ce                	add	a1,a1,s3
    80006cd4:	8526                	mv	a0,s1
    80006cd6:	00000097          	auipc	ra,0x0
    80006cda:	48e080e7          	jalr	1166(ra) # 80007164 <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006cde:	855a                	mv	a0,s6
    80006ce0:	70e2                	ld	ra,56(sp)
    80006ce2:	7442                	ld	s0,48(sp)
    80006ce4:	74a2                	ld	s1,40(sp)
    80006ce6:	7902                	ld	s2,32(sp)
    80006ce8:	69e2                	ld	s3,24(sp)
    80006cea:	6a42                	ld	s4,16(sp)
    80006cec:	6aa2                	ld	s5,8(sp)
    80006cee:	6b02                	ld	s6,0(sp)
    80006cf0:	6121                	addi	sp,sp,64
    80006cf2:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006cf4:	fff58a1b          	addiw	s4,a1,-1
    80006cf8:	bf41                	j	80006c88 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006cfa:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006cfe:	00003597          	auipc	a1,0x3
    80006d02:	30a5b583          	ld	a1,778(a1) # 8000a008 <bd_base>
    80006d06:	95ce                	add	a1,a1,s3
    80006d08:	8526                	mv	a0,s1
    80006d0a:	00000097          	auipc	ra,0x0
    80006d0e:	45a080e7          	jalr	1114(ra) # 80007164 <lst_push>
    80006d12:	b7f1                	j	80006cde <bd_initfree_pair+0x7a>

0000000080006d14 <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006d14:	711d                	addi	sp,sp,-96
    80006d16:	ec86                	sd	ra,88(sp)
    80006d18:	e8a2                	sd	s0,80(sp)
    80006d1a:	e4a6                	sd	s1,72(sp)
    80006d1c:	e0ca                	sd	s2,64(sp)
    80006d1e:	fc4e                	sd	s3,56(sp)
    80006d20:	f852                	sd	s4,48(sp)
    80006d22:	f456                	sd	s5,40(sp)
    80006d24:	f05a                	sd	s6,32(sp)
    80006d26:	ec5e                	sd	s7,24(sp)
    80006d28:	e862                	sd	s8,16(sp)
    80006d2a:	e466                	sd	s9,8(sp)
    80006d2c:	e06a                	sd	s10,0(sp)
    80006d2e:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006d30:	00003717          	auipc	a4,0x3
    80006d34:	2e872703          	lw	a4,744(a4) # 8000a018 <nsizes>
    80006d38:	4785                	li	a5,1
    80006d3a:	06e7db63          	bge	a5,a4,80006db0 <bd_initfree+0x9c>
    80006d3e:	8aaa                	mv	s5,a0
    80006d40:	8b2e                	mv	s6,a1
    80006d42:	4901                	li	s2,0
  int free = 0;
    80006d44:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006d46:	00003c97          	auipc	s9,0x3
    80006d4a:	2c2c8c93          	addi	s9,s9,706 # 8000a008 <bd_base>
  return n / BLK_SIZE(k);
    80006d4e:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006d50:	00003b97          	auipc	s7,0x3
    80006d54:	2c8b8b93          	addi	s7,s7,712 # 8000a018 <nsizes>
    80006d58:	a039                	j	80006d66 <bd_initfree+0x52>
    80006d5a:	2905                	addiw	s2,s2,1
    80006d5c:	000ba783          	lw	a5,0(s7)
    80006d60:	37fd                	addiw	a5,a5,-1
    80006d62:	04f95863          	bge	s2,a5,80006db2 <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006d66:	85d6                	mv	a1,s5
    80006d68:	854a                	mv	a0,s2
    80006d6a:	00000097          	auipc	ra,0x0
    80006d6e:	dd6080e7          	jalr	-554(ra) # 80006b40 <blk_index_next>
    80006d72:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006d74:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006d78:	409b04bb          	subw	s1,s6,s1
    80006d7c:	012c17b3          	sll	a5,s8,s2
    80006d80:	02f4c4b3          	div	s1,s1,a5
    80006d84:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006d86:	85aa                	mv	a1,a0
    80006d88:	854a                	mv	a0,s2
    80006d8a:	00000097          	auipc	ra,0x0
    80006d8e:	eda080e7          	jalr	-294(ra) # 80006c64 <bd_initfree_pair>
    80006d92:	01450d3b          	addw	s10,a0,s4
    80006d96:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006d9a:	fc99d0e3          	bge	s3,s1,80006d5a <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006d9e:	85a6                	mv	a1,s1
    80006da0:	854a                	mv	a0,s2
    80006da2:	00000097          	auipc	ra,0x0
    80006da6:	ec2080e7          	jalr	-318(ra) # 80006c64 <bd_initfree_pair>
    80006daa:	00ad0a3b          	addw	s4,s10,a0
    80006dae:	b775                	j	80006d5a <bd_initfree+0x46>
  int free = 0;
    80006db0:	4a01                	li	s4,0
  }
  return free;
}
    80006db2:	8552                	mv	a0,s4
    80006db4:	60e6                	ld	ra,88(sp)
    80006db6:	6446                	ld	s0,80(sp)
    80006db8:	64a6                	ld	s1,72(sp)
    80006dba:	6906                	ld	s2,64(sp)
    80006dbc:	79e2                	ld	s3,56(sp)
    80006dbe:	7a42                	ld	s4,48(sp)
    80006dc0:	7aa2                	ld	s5,40(sp)
    80006dc2:	7b02                	ld	s6,32(sp)
    80006dc4:	6be2                	ld	s7,24(sp)
    80006dc6:	6c42                	ld	s8,16(sp)
    80006dc8:	6ca2                	ld	s9,8(sp)
    80006dca:	6d02                	ld	s10,0(sp)
    80006dcc:	6125                	addi	sp,sp,96
    80006dce:	8082                	ret

0000000080006dd0 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006dd0:	7179                	addi	sp,sp,-48
    80006dd2:	f406                	sd	ra,40(sp)
    80006dd4:	f022                	sd	s0,32(sp)
    80006dd6:	ec26                	sd	s1,24(sp)
    80006dd8:	e84a                	sd	s2,16(sp)
    80006dda:	e44e                	sd	s3,8(sp)
    80006ddc:	1800                	addi	s0,sp,48
    80006dde:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006de0:	00003997          	auipc	s3,0x3
    80006de4:	22898993          	addi	s3,s3,552 # 8000a008 <bd_base>
    80006de8:	0009b483          	ld	s1,0(s3)
    80006dec:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006df0:	00003797          	auipc	a5,0x3
    80006df4:	2287a783          	lw	a5,552(a5) # 8000a018 <nsizes>
    80006df8:	37fd                	addiw	a5,a5,-1
    80006dfa:	4641                	li	a2,16
    80006dfc:	00f61633          	sll	a2,a2,a5
    80006e00:	85a6                	mv	a1,s1
    80006e02:	00003517          	auipc	a0,0x3
    80006e06:	0b650513          	addi	a0,a0,182 # 80009eb8 <syscalls+0x4a0>
    80006e0a:	ffff9097          	auipc	ra,0xffff9
    80006e0e:	7bc080e7          	jalr	1980(ra) # 800005c6 <printf>
  bd_mark(bd_base, p);
    80006e12:	85ca                	mv	a1,s2
    80006e14:	0009b503          	ld	a0,0(s3)
    80006e18:	00000097          	auipc	ra,0x0
    80006e1c:	d74080e7          	jalr	-652(ra) # 80006b8c <bd_mark>
  return meta;
}
    80006e20:	8526                	mv	a0,s1
    80006e22:	70a2                	ld	ra,40(sp)
    80006e24:	7402                	ld	s0,32(sp)
    80006e26:	64e2                	ld	s1,24(sp)
    80006e28:	6942                	ld	s2,16(sp)
    80006e2a:	69a2                	ld	s3,8(sp)
    80006e2c:	6145                	addi	sp,sp,48
    80006e2e:	8082                	ret

0000000080006e30 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006e30:	1101                	addi	sp,sp,-32
    80006e32:	ec06                	sd	ra,24(sp)
    80006e34:	e822                	sd	s0,16(sp)
    80006e36:	e426                	sd	s1,8(sp)
    80006e38:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006e3a:	00003497          	auipc	s1,0x3
    80006e3e:	1de4a483          	lw	s1,478(s1) # 8000a018 <nsizes>
    80006e42:	fff4879b          	addiw	a5,s1,-1
    80006e46:	44c1                	li	s1,16
    80006e48:	00f494b3          	sll	s1,s1,a5
    80006e4c:	00003797          	auipc	a5,0x3
    80006e50:	1bc7b783          	ld	a5,444(a5) # 8000a008 <bd_base>
    80006e54:	8d1d                	sub	a0,a0,a5
    80006e56:	40a4853b          	subw	a0,s1,a0
    80006e5a:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006e5e:	00905a63          	blez	s1,80006e72 <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006e62:	357d                	addiw	a0,a0,-1
    80006e64:	41f5549b          	sraiw	s1,a0,0x1f
    80006e68:	01c4d49b          	srliw	s1,s1,0x1c
    80006e6c:	9ca9                	addw	s1,s1,a0
    80006e6e:	98c1                	andi	s1,s1,-16
    80006e70:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006e72:	85a6                	mv	a1,s1
    80006e74:	00003517          	auipc	a0,0x3
    80006e78:	07c50513          	addi	a0,a0,124 # 80009ef0 <syscalls+0x4d8>
    80006e7c:	ffff9097          	auipc	ra,0xffff9
    80006e80:	74a080e7          	jalr	1866(ra) # 800005c6 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006e84:	00003717          	auipc	a4,0x3
    80006e88:	18473703          	ld	a4,388(a4) # 8000a008 <bd_base>
    80006e8c:	00003597          	auipc	a1,0x3
    80006e90:	18c5a583          	lw	a1,396(a1) # 8000a018 <nsizes>
    80006e94:	fff5879b          	addiw	a5,a1,-1
    80006e98:	45c1                	li	a1,16
    80006e9a:	00f595b3          	sll	a1,a1,a5
    80006e9e:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006ea2:	95ba                	add	a1,a1,a4
    80006ea4:	953a                	add	a0,a0,a4
    80006ea6:	00000097          	auipc	ra,0x0
    80006eaa:	ce6080e7          	jalr	-794(ra) # 80006b8c <bd_mark>
  return unavailable;
}
    80006eae:	8526                	mv	a0,s1
    80006eb0:	60e2                	ld	ra,24(sp)
    80006eb2:	6442                	ld	s0,16(sp)
    80006eb4:	64a2                	ld	s1,8(sp)
    80006eb6:	6105                	addi	sp,sp,32
    80006eb8:	8082                	ret

0000000080006eba <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006eba:	715d                	addi	sp,sp,-80
    80006ebc:	e486                	sd	ra,72(sp)
    80006ebe:	e0a2                	sd	s0,64(sp)
    80006ec0:	fc26                	sd	s1,56(sp)
    80006ec2:	f84a                	sd	s2,48(sp)
    80006ec4:	f44e                	sd	s3,40(sp)
    80006ec6:	f052                	sd	s4,32(sp)
    80006ec8:	ec56                	sd	s5,24(sp)
    80006eca:	e85a                	sd	s6,16(sp)
    80006ecc:	e45e                	sd	s7,8(sp)
    80006ece:	e062                	sd	s8,0(sp)
    80006ed0:	0880                	addi	s0,sp,80
    80006ed2:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006ed4:	fff50493          	addi	s1,a0,-1
    80006ed8:	98c1                	andi	s1,s1,-16
    80006eda:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006edc:	00003597          	auipc	a1,0x3
    80006ee0:	03458593          	addi	a1,a1,52 # 80009f10 <syscalls+0x4f8>
    80006ee4:	00031517          	auipc	a0,0x31
    80006ee8:	4bc50513          	addi	a0,a0,1212 # 800383a0 <lock>
    80006eec:	ffffa097          	auipc	ra,0xffffa
    80006ef0:	bd0080e7          	jalr	-1072(ra) # 80000abc <initlock>
  bd_base = (void *) p;
    80006ef4:	00003797          	auipc	a5,0x3
    80006ef8:	1097ba23          	sd	s1,276(a5) # 8000a008 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006efc:	409c0933          	sub	s2,s8,s1
    80006f00:	43f95513          	srai	a0,s2,0x3f
    80006f04:	893d                	andi	a0,a0,15
    80006f06:	954a                	add	a0,a0,s2
    80006f08:	8511                	srai	a0,a0,0x4
    80006f0a:	00000097          	auipc	ra,0x0
    80006f0e:	c60080e7          	jalr	-928(ra) # 80006b6a <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    80006f12:	47c1                	li	a5,16
    80006f14:	00a797b3          	sll	a5,a5,a0
    80006f18:	1b27c663          	blt	a5,s2,800070c4 <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80006f1c:	2505                	addiw	a0,a0,1
    80006f1e:	00003797          	auipc	a5,0x3
    80006f22:	0ea7ad23          	sw	a0,250(a5) # 8000a018 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    80006f26:	00003997          	auipc	s3,0x3
    80006f2a:	0f298993          	addi	s3,s3,242 # 8000a018 <nsizes>
    80006f2e:	0009a603          	lw	a2,0(s3)
    80006f32:	85ca                	mv	a1,s2
    80006f34:	00003517          	auipc	a0,0x3
    80006f38:	fe450513          	addi	a0,a0,-28 # 80009f18 <syscalls+0x500>
    80006f3c:	ffff9097          	auipc	ra,0xffff9
    80006f40:	68a080e7          	jalr	1674(ra) # 800005c6 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    80006f44:	00003797          	auipc	a5,0x3
    80006f48:	0c97b623          	sd	s1,204(a5) # 8000a010 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80006f4c:	0009a603          	lw	a2,0(s3)
    80006f50:	00561913          	slli	s2,a2,0x5
    80006f54:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    80006f56:	0056161b          	slliw	a2,a2,0x5
    80006f5a:	4581                	li	a1,0
    80006f5c:	8526                	mv	a0,s1
    80006f5e:	ffffa097          	auipc	ra,0xffffa
    80006f62:	f18080e7          	jalr	-232(ra) # 80000e76 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    80006f66:	0009a783          	lw	a5,0(s3)
    80006f6a:	06f05a63          	blez	a5,80006fde <bd_init+0x124>
    80006f6e:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80006f70:	00003a97          	auipc	s5,0x3
    80006f74:	0a0a8a93          	addi	s5,s5,160 # 8000a010 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f78:	00003a17          	auipc	s4,0x3
    80006f7c:	0a0a0a13          	addi	s4,s4,160 # 8000a018 <nsizes>
    80006f80:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    80006f82:	00599b93          	slli	s7,s3,0x5
    80006f86:	000ab503          	ld	a0,0(s5)
    80006f8a:	955e                	add	a0,a0,s7
    80006f8c:	00000097          	auipc	ra,0x0
    80006f90:	166080e7          	jalr	358(ra) # 800070f2 <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80006f94:	000a2483          	lw	s1,0(s4)
    80006f98:	34fd                	addiw	s1,s1,-1
    80006f9a:	413484bb          	subw	s1,s1,s3
    80006f9e:	009b14bb          	sllw	s1,s6,s1
    80006fa2:	fff4879b          	addiw	a5,s1,-1
    80006fa6:	41f7d49b          	sraiw	s1,a5,0x1f
    80006faa:	01d4d49b          	srliw	s1,s1,0x1d
    80006fae:	9cbd                	addw	s1,s1,a5
    80006fb0:	98e1                	andi	s1,s1,-8
    80006fb2:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    80006fb4:	000ab783          	ld	a5,0(s5)
    80006fb8:	9bbe                	add	s7,s7,a5
    80006fba:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    80006fbe:	848d                	srai	s1,s1,0x3
    80006fc0:	8626                	mv	a2,s1
    80006fc2:	4581                	li	a1,0
    80006fc4:	854a                	mv	a0,s2
    80006fc6:	ffffa097          	auipc	ra,0xffffa
    80006fca:	eb0080e7          	jalr	-336(ra) # 80000e76 <memset>
    p += sz;
    80006fce:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    80006fd0:	0985                	addi	s3,s3,1
    80006fd2:	000a2703          	lw	a4,0(s4)
    80006fd6:	0009879b          	sext.w	a5,s3
    80006fda:	fae7c4e3          	blt	a5,a4,80006f82 <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    80006fde:	00003797          	auipc	a5,0x3
    80006fe2:	03a7a783          	lw	a5,58(a5) # 8000a018 <nsizes>
    80006fe6:	4705                	li	a4,1
    80006fe8:	06f75163          	bge	a4,a5,8000704a <bd_init+0x190>
    80006fec:	02000a13          	li	s4,32
    80006ff0:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80006ff2:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    80006ff4:	00003b17          	auipc	s6,0x3
    80006ff8:	01cb0b13          	addi	s6,s6,28 # 8000a010 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80006ffc:	00003a97          	auipc	s5,0x3
    80007000:	01ca8a93          	addi	s5,s5,28 # 8000a018 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    80007004:	37fd                	addiw	a5,a5,-1
    80007006:	413787bb          	subw	a5,a5,s3
    8000700a:	00fb94bb          	sllw	s1,s7,a5
    8000700e:	fff4879b          	addiw	a5,s1,-1
    80007012:	41f7d49b          	sraiw	s1,a5,0x1f
    80007016:	01d4d49b          	srliw	s1,s1,0x1d
    8000701a:	9cbd                	addw	s1,s1,a5
    8000701c:	98e1                	andi	s1,s1,-8
    8000701e:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007020:	000b3783          	ld	a5,0(s6)
    80007024:	97d2                	add	a5,a5,s4
    80007026:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    8000702a:	848d                	srai	s1,s1,0x3
    8000702c:	8626                	mv	a2,s1
    8000702e:	4581                	li	a1,0
    80007030:	854a                	mv	a0,s2
    80007032:	ffffa097          	auipc	ra,0xffffa
    80007036:	e44080e7          	jalr	-444(ra) # 80000e76 <memset>
    p += sz;
    8000703a:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    8000703c:	2985                	addiw	s3,s3,1
    8000703e:	000aa783          	lw	a5,0(s5)
    80007042:	020a0a13          	addi	s4,s4,32
    80007046:	faf9cfe3          	blt	s3,a5,80007004 <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    8000704a:	197d                	addi	s2,s2,-1
    8000704c:	ff097913          	andi	s2,s2,-16
    80007050:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    80007052:	854a                	mv	a0,s2
    80007054:	00000097          	auipc	ra,0x0
    80007058:	d7c080e7          	jalr	-644(ra) # 80006dd0 <bd_mark_data_structures>
    8000705c:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    8000705e:	85ca                	mv	a1,s2
    80007060:	8562                	mv	a0,s8
    80007062:	00000097          	auipc	ra,0x0
    80007066:	dce080e7          	jalr	-562(ra) # 80006e30 <bd_mark_unavailable>
    8000706a:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    8000706c:	00003a97          	auipc	s5,0x3
    80007070:	faca8a93          	addi	s5,s5,-84 # 8000a018 <nsizes>
    80007074:	000aa783          	lw	a5,0(s5)
    80007078:	37fd                	addiw	a5,a5,-1
    8000707a:	44c1                	li	s1,16
    8000707c:	00f497b3          	sll	a5,s1,a5
    80007080:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    80007082:	00003597          	auipc	a1,0x3
    80007086:	f865b583          	ld	a1,-122(a1) # 8000a008 <bd_base>
    8000708a:	95be                	add	a1,a1,a5
    8000708c:	854a                	mv	a0,s2
    8000708e:	00000097          	auipc	ra,0x0
    80007092:	c86080e7          	jalr	-890(ra) # 80006d14 <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    80007096:	000aa603          	lw	a2,0(s5)
    8000709a:	367d                	addiw	a2,a2,-1
    8000709c:	00c49633          	sll	a2,s1,a2
    800070a0:	41460633          	sub	a2,a2,s4
    800070a4:	41360633          	sub	a2,a2,s3
    800070a8:	02c51463          	bne	a0,a2,800070d0 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800070ac:	60a6                	ld	ra,72(sp)
    800070ae:	6406                	ld	s0,64(sp)
    800070b0:	74e2                	ld	s1,56(sp)
    800070b2:	7942                	ld	s2,48(sp)
    800070b4:	79a2                	ld	s3,40(sp)
    800070b6:	7a02                	ld	s4,32(sp)
    800070b8:	6ae2                	ld	s5,24(sp)
    800070ba:	6b42                	ld	s6,16(sp)
    800070bc:	6ba2                	ld	s7,8(sp)
    800070be:	6c02                	ld	s8,0(sp)
    800070c0:	6161                	addi	sp,sp,80
    800070c2:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800070c4:	2509                	addiw	a0,a0,2
    800070c6:	00003797          	auipc	a5,0x3
    800070ca:	f4a7a923          	sw	a0,-174(a5) # 8000a018 <nsizes>
    800070ce:	bda1                	j	80006f26 <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800070d0:	85aa                	mv	a1,a0
    800070d2:	00003517          	auipc	a0,0x3
    800070d6:	e8650513          	addi	a0,a0,-378 # 80009f58 <syscalls+0x540>
    800070da:	ffff9097          	auipc	ra,0xffff9
    800070de:	4ec080e7          	jalr	1260(ra) # 800005c6 <printf>
    panic("bd_init: free mem");
    800070e2:	00003517          	auipc	a0,0x3
    800070e6:	e8650513          	addi	a0,a0,-378 # 80009f68 <syscalls+0x550>
    800070ea:	ffff9097          	auipc	ra,0xffff9
    800070ee:	47a080e7          	jalr	1146(ra) # 80000564 <panic>

00000000800070f2 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    800070f2:	1141                	addi	sp,sp,-16
    800070f4:	e422                	sd	s0,8(sp)
    800070f6:	0800                	addi	s0,sp,16
  lst->next = lst;
    800070f8:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    800070fa:	e508                	sd	a0,8(a0)
}
    800070fc:	6422                	ld	s0,8(sp)
    800070fe:	0141                	addi	sp,sp,16
    80007100:	8082                	ret

0000000080007102 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007102:	1141                	addi	sp,sp,-16
    80007104:	e422                	sd	s0,8(sp)
    80007106:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007108:	611c                	ld	a5,0(a0)
    8000710a:	40a78533          	sub	a0,a5,a0
}
    8000710e:	00153513          	seqz	a0,a0
    80007112:	6422                	ld	s0,8(sp)
    80007114:	0141                	addi	sp,sp,16
    80007116:	8082                	ret

0000000080007118 <lst_remove>:

void
lst_remove(struct list *e) {
    80007118:	1141                	addi	sp,sp,-16
    8000711a:	e422                	sd	s0,8(sp)
    8000711c:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    8000711e:	6518                	ld	a4,8(a0)
    80007120:	611c                	ld	a5,0(a0)
    80007122:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007124:	6518                	ld	a4,8(a0)
    80007126:	e798                	sd	a4,8(a5)
}
    80007128:	6422                	ld	s0,8(sp)
    8000712a:	0141                	addi	sp,sp,16
    8000712c:	8082                	ret

000000008000712e <lst_pop>:

void*
lst_pop(struct list *lst) {
    8000712e:	1101                	addi	sp,sp,-32
    80007130:	ec06                	sd	ra,24(sp)
    80007132:	e822                	sd	s0,16(sp)
    80007134:	e426                	sd	s1,8(sp)
    80007136:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007138:	6104                	ld	s1,0(a0)
    8000713a:	00a48d63          	beq	s1,a0,80007154 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    8000713e:	8526                	mv	a0,s1
    80007140:	00000097          	auipc	ra,0x0
    80007144:	fd8080e7          	jalr	-40(ra) # 80007118 <lst_remove>
  return (void *)p;
}
    80007148:	8526                	mv	a0,s1
    8000714a:	60e2                	ld	ra,24(sp)
    8000714c:	6442                	ld	s0,16(sp)
    8000714e:	64a2                	ld	s1,8(sp)
    80007150:	6105                	addi	sp,sp,32
    80007152:	8082                	ret
    panic("lst_pop");
    80007154:	00003517          	auipc	a0,0x3
    80007158:	e2c50513          	addi	a0,a0,-468 # 80009f80 <syscalls+0x568>
    8000715c:	ffff9097          	auipc	ra,0xffff9
    80007160:	408080e7          	jalr	1032(ra) # 80000564 <panic>

0000000080007164 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007164:	1141                	addi	sp,sp,-16
    80007166:	e422                	sd	s0,8(sp)
    80007168:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000716a:	611c                	ld	a5,0(a0)
    8000716c:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    8000716e:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007170:	611c                	ld	a5,0(a0)
    80007172:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007174:	e10c                	sd	a1,0(a0)
}
    80007176:	6422                	ld	s0,8(sp)
    80007178:	0141                	addi	sp,sp,16
    8000717a:	8082                	ret

000000008000717c <lst_print>:

void
lst_print(struct list *lst)
{
    8000717c:	7179                	addi	sp,sp,-48
    8000717e:	f406                	sd	ra,40(sp)
    80007180:	f022                	sd	s0,32(sp)
    80007182:	ec26                	sd	s1,24(sp)
    80007184:	e84a                	sd	s2,16(sp)
    80007186:	e44e                	sd	s3,8(sp)
    80007188:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000718a:	6104                	ld	s1,0(a0)
    8000718c:	02950063          	beq	a0,s1,800071ac <lst_print+0x30>
    80007190:	892a                	mv	s2,a0
    printf(" %p", p);
    80007192:	00003997          	auipc	s3,0x3
    80007196:	df698993          	addi	s3,s3,-522 # 80009f88 <syscalls+0x570>
    8000719a:	85a6                	mv	a1,s1
    8000719c:	854e                	mv	a0,s3
    8000719e:	ffff9097          	auipc	ra,0xffff9
    800071a2:	428080e7          	jalr	1064(ra) # 800005c6 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800071a6:	6084                	ld	s1,0(s1)
    800071a8:	fe9919e3          	bne	s2,s1,8000719a <lst_print+0x1e>
  }
  printf("\n");
    800071ac:	00002517          	auipc	a0,0x2
    800071b0:	05450513          	addi	a0,a0,84 # 80009200 <digits+0x90>
    800071b4:	ffff9097          	auipc	ra,0xffff9
    800071b8:	412080e7          	jalr	1042(ra) # 800005c6 <printf>
}
    800071bc:	70a2                	ld	ra,40(sp)
    800071be:	7402                	ld	s0,32(sp)
    800071c0:	64e2                	ld	s1,24(sp)
    800071c2:	6942                	ld	s2,16(sp)
    800071c4:	69a2                	ld	s3,8(sp)
    800071c6:	6145                	addi	sp,sp,48
    800071c8:	8082                	ret
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

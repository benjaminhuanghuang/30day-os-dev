## PIC(programmable interrupt controller)

CPU单独只能处理一个中断，这不够用，需要辅助芯片来处理更多的中断

PIC是将8个中断信号集合成一个中断信号的装置。PIC监视着输入管脚的8个中断信号，只要有一个中断信号进来，就将唯一的输出管脚信号变成ON，并通知给CPU。

与CPU直接相连的PIC称为主PIC（master PIC），与主PIC相连的PIC称为从PIC（slave PIC）。
master PIC负责处理第0到第7号中断信号，从PIC负责处理第8到第15号中断信号
另外，slavee PIC通过第2号IRQ与主PIC相连。

从CPU的角度来看，PIC是外部设备，CPU使用OUT指令进行操作

PIC内部有很多8位寄存器，用端口号码对彼此进行区别，以决定是写入哪一个寄存器。
- IMR(interrupt mask register)。8位分别对应8路IRQ(interrupt request)信号。如果某一位的值是1，则该位所对应的IRQ信号被屏蔽，PIC就忽视该路信号
- ICW(initial control word) 
  - ICW1和ICW4与PIC主板配线方式、中断信号的电气特性等有关。电脑上设定的是上述程序所示的固定值，不会设定其他的值
  - ICW3是有关主—从连接的设定，对主PIC而言，第几号IRQ与从PIC相连，是用8位来设定的。如果把这些位全部设为1，那么主PIC就能驱动8个从PIC（那样的话，最大就可能有64个IRQ），但我们所用的电脑并不是这样的，所以就设定成00000100。另外，对从PIC来说，该从PIC与主PIC的第几号相连，用3位来设定。因为硬件上已经不可能更改了，如果软件上设定不一致的话，只会发生错误，所以只能维持现有设定不变。
  - ICW2，决定了IRQ以哪一号中断通知CPU, IRQ0-7 is received by INT20-27, IRQ8-15 is received by INT28-2f

bootpack.h
```
  void init_pic(void);
  void inthandler27(int *esp);
  #define PIC0_ICW1		0x0020
  #define PIC0_OCW2		0x0020
  #define PIC0_IMR		0x0021
  #define PIC0_ICW2		0x0021
  #define PIC0_ICW3		0x0021
  #define PIC0_ICW4		0x0021
 
  #define PIC1_ICW1		0x00a0
  #define PIC1_OCW2		0x00a0
  #define PIC1_IMR		0x00a1
  #define PIC1_ICW2		0x00a1
  #define PIC1_ICW3		0x00a1
  #define PIC1_ICW4		0x00a1
```
int.c
```
  void init_pic(void) /*PIC initialization */
  {
    io_out8(PIC0_IMR, 0xff); /*Do not accept all interrupts */
    io_out8(PIC1_IMR, 0xff); /*Do not accept all interrupts */

    io_out8(PIC0_ICW1, 0x11);   /*Edge trigger mode */
    io_out8(PIC0_ICW2, 0x20);   /*IRQ0-7 is received by INT20-27 */
    io_out8(PIC0_ICW3, 1 << 2); /*PIC1 is connected by IRQ2 */
    io_out8(PIC0_ICW4, 0x01);   /*Non-buffer mode */

    io_out8(PIC1_ICW1, 0x11); /*Edge trigger mode */
    io_out8(PIC1_ICW2, 0x28); /*IRQ8-15 is received by INT28-2f */
    io_out8(PIC1_ICW3, 2);    /*PIC1 is connected by IRQ2 */
    io_out8(PIC1_ICW4, 0x01); /*Non-buffer mode */

    io_out8(PIC0_IMR, 0xfb); /*11111011 All except PIC1 prohibited */
    io_out8(PIC1_IMR, 0xff); /*11111111 Do not accept all interrupts */

    return;
  }

  void inthandler27(int *esp)
  {
    io_out8(PIC0_OCW2, 0x67); /* 通知PIC IRQ-07接受完成 */
    return;
  }
```

中断处理完成之后，不能执行“return; ”（=RET指令），而是必须执行IRETD指令。而且，这个指令还不能用C语言写。所以需要写一个asm 函数

naskfunc.nas
```
_asm_inthandler21:
   PUSH	ES
   PUSH	DS
   PUSHAD
   MOV		EAX,ESP
   PUSH	EAX
   MOV		AX,SS
   MOV		DS,AX
   MOV		ES,AX
   CALL	_inthandler21
   POP		EAX
   POPAD
   POP		DS
   POP		ES
   IRETD
```
这个函数只是将寄存器的值保存到栈里，然后将DS和ES调整到与SS相等，再调用_inthandler21
关于在DS和ES中放入SS值的部分，因为C语言自以为是地认为“DS也好，ES也好，SS也好，它们都是指同一个段”


## 注册 inthandler
dsctbl.c / init_gdtidt
```
  set_gatedesc(idt + 0x21, (int) asm_inthandler21, 2 * 8, AR_INTGATE32);
```

asm_inthandler21注册在idt的第0x21号。如果发生中断了，CPU就会自动调用asm_inthandler21。
这里的2 * 8表示的是asm_inthandler21属于哪一个段，即段号是2，乘以8是因为低3位有着别的意思，这里低3位必须是0。所以，“2 * 8”也可以写成 “2<<3”，当然，写成16也可以。

最后的AR_INTGATE32将IDT的属性，设定为0x008e。表示这是用于中断处理的有效设定。


最后，修改了PIC的IMR，以便接受来自键盘和鼠标的中断, 键盘是 IRQ1, 鼠标是 IRQ 12
```
	io_out8(PIC0_IMR, 0xf9); /* 键盘和IRQ2:(11111001) */
	io_out8(PIC1_IMR, 0xef); /* 鼠标: (11101111) */
```

## 中断处理函数
键盘对应的中断是IRQ1, 但是由于CPU内部会自动产生INT 0x00 ~ 0x0f, IRQ0 ~ IRQ15被映射到INT 0x20 ~ 0x2f
代码见 init_pic()

因此键盘对应到中断为INT21
```
  void inthandler21()
  {
    unsigned char data, s[4];
    // 通知 PIC IRQ-01已经处理完毕， 将 0x60+IRQ号码 输出给OCW2就可以
    io_out8(PICO_OCW2, 0x61);
    // 从编号为0x0060的设备输入的8位信息是按键编码
    data = io_in8(0x0060);

    sprintf(s, "%02x", data)

  }
```

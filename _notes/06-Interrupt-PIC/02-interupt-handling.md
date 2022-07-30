
键盘的中断号吗是IRQ1, 鼠标的中断号码是IRQ12, 对应中断 0x21 和 0x2C

对某些机器, PIC 初始化时会产生 IRQ7 中断, 需要设置STI 设置中断标志位 (见 7.1)
```
  void inthandler27(int *esp)
  {
    io_out8(PIC0_OCW2, 0x67); /* 通知PIC IRQ-07接受完成 */
    return;
  }
```
## 中断处理函数
中断处理完成之后，不能执行 return;（=RET指令），而必须执行IRETD指令。这个指令不能用C语言写。所以需要写一个asm 函数
```
;; naskfunc.nas

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

## 注册 inthandler
dsctbl.c / init_gdtidt
```
/* IDT的设定 */

set_gatedesc(idt + 0x21, (int) asm_inthandler21, 2 * 8, AR_INTGATE32);
set_gatedesc(idt + 0x2c, (int) asm_inthandler2c, 2 * 8, AR_INTGATE32);
```

这里的2 * 8表示的是asm_inthandler21属于哪一个段，即段号是2，
乘以8是因为低3位有着别的意思，这里低3位必须是0。所以，“2 * 8”也可以写成 “2<<3”，当然，写成16也可以。

最后的AR_INTGATE32将IDT的属性，设定为0x008e。表示这是用于中断处理的有效设定。

使用段号2 是因为 在设置 GDT 时 把bootpack.hrb 放入了 2号段
```
set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER);
```


## 开中断
最后，修改了PIC的IMR，以便接受来自键盘和鼠标的中断, 键盘是 IRQ1, 鼠标是 IRQ 12
```
	io_out8(PIC0_IMR, 0xf9); /* 键盘和IRQ2:(11111001) */
	io_out8(PIC1_IMR, 0xef); /* 鼠标: (11101111) */
```


## 通知PIC继续检测中断
```
void inthandler21()
  {
    unsigned char data, s[4];
    // 通知 PIC IRQ-01已经处理完毕， 将 0x60+IRQ号码 输出给OCW2就可以
    // 通知PIC继续监视IRQ1中断是否发生。否则，PIC就不再监视IRQ1中断
    io_out8(PICO_OCW2, 0x61);
    // 从编号为0x0060的设备输入的8位信息是按键编码
    data = io_in8(0x0060);

    sprintf(s, "%02x", data)
  }
```

## 加快中断处理
不要在中断处理期间, CPU不能接受别的中断, 因此不要在中断处理函数中进行耗时操作
比如, 键盘中断处理函数只负责记录按键, 再由主循环处理按键, 而不是由中断处理函数处理按键





## reference
https://zhuanlan.zhihu.com/p/112485932


GDT 和 IDT 是与CPU有关的设定。为了让操作系统能够使用32位模式，需要对CPU做各种设定

## GDT (global segement descriptor table)

- 为什么要分段

	汇编语言有一个ORG指令，如果不用ORG指令明确声明程序要读入的内存地址，就不能写出正确的程序来。

	当操作系统同时运行多个程序时，需要避免多个程序被加载到相同的地址空间。

	分段就是将4GB的内存分成很多block，每一块的起始地址都看作0。有了这个功能，任何程序都可以先写上一句ORG 0。
	像这样分割出来的块，就称为段（segment）

- 寻址

	16位模式下
	```
	MOV AL,[DS:EBX]
	```
	address = DS * 16 + EBX

	32位模式下，
	```
	MOV AL,[DS:EBX]
	```
	CPU会往EBX里加上某个值来计算地址，这个值不是DS的16倍，而是DS所表示的段的起始地址。

	即使省略段寄存器（segment register）的地址，也会自动认为是指定了DS。这个规则不管是16位模式还是32位模式，都是一样的。

- Setup GDT
	
	表示一个段，需要有以下信息。
	- 段的大小是多少
	- 段的起始地址在哪里
	- 段的管理属性（禁止写入，禁止执行，系统专用等）

	CPU用8个字节（=64位）的数据来表示这些信息。但是，用于指定段的寄存器只有16位，因此不能把这64位的信息直接放在段寄存器中，
	而要使用和调色板类似的处理方法：
	先有一个段号，存放在段寄存器里。然后预先设定好段号与段的对应关系。
	段号寄存器是16位，但由于CPU设计上的原因，段寄存器的低3位不能使用。因此能够使用的段号只有13位，因此段号的取值范围是`0～8191`

	8192 个段的设定信息会占用 8192*8字节=65536字节（64KB）= 0xffff，这个信息块会被放在内存中，

	设定GDT就是将GDT在内存中的起始地址和有效设定个数放在CPU内被称作GDTR的寄存器中

	GDTR是一个很特别的`6字节，48位寄存器`，不能用MOV指令来赋值。给它赋值的时候，唯一的方法就是指定一个内存地址，用`LGDT`指令从指定的地址读取6个字节（也就是48位），赋值给GDTR寄存器。

	GDTR寄存器的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。剩下的高32位（即剩余的4个字节），代表GDT的开始地址。


## IDT（interrupt descriptor table）

	当CPU遇到外部状况变化，或者是内部偶然发生某些错误时，会临时切换过去处理这种突发事件。这就是中断功能。

	处理各种外部设备（鼠标，键盘，网卡...）的输入，首先想到的处理方法是`查询`，但为了能够及时处理各种设备输入，就必须不断查询，
	这是很浪费CPU资源的做法

	正是为解决以上问题，才有了中断机制。各个设备有变化时就产生中断，中断发生后，CPU暂时停止正在处理的任务，并做好接下来能够继续处理的准备，
	转而执行中断程序。

	中断程序执行完以后，再调用事先设定好的函数，返回处理中的任务。这样一来，CPU就可以不用一直查询键盘，鼠标，网卡等设备的状态，将精力集中在处理任务上。

	IDT记录了0～255的中断号码与调用函数的对应关系

	这次是以INT 0x20～0x2f接收中断信号IRQ0～15而设定的。INT 0x00～0x1f不能用于IRQ，因为应用程序想要对操作系统干坏事的时候，CPU内部会自动产生INT 0x00～0x1f，如果IRQ与这些号码重复了，CPU就分不清它到底是IRQ，还是CPU的系统保护通知。
	

bootpack.h
```
/*
	存放 8 字节 GDT

	段的基地址共 32 位: base_low, base_mid, base_high
		基地址分成3段主要是为了与80286的程序不用修改就可以386以后的CPU上运行。

	段上限最大是4GB，也就是一个32位的数值，如果直接放进去，这个数值本身就要占用4个字节，再加上基址（base），一共就要8个字节，
	这就把整个结构体占满了。这样一来，就没有地方保存段的管理属性信息了。
	Intel在段的属性里设计了一个标志位，叫做Gbit（granularity）。这个标志位是1的时候，limit的单位不解释成字节（byte），而解释成页（page）
	段上限只能用 20 位，写到limit_low(16位)和limit_high(8位)里，而段属性又会占用limit_high的高4位，最终段上限总共20位

	段属性有 12 位 段属性又称为“段的访问权属性”，在程序中用变量名access_right或ar来表示
	其中高4位放在limit_high的高4位里，所以程序里有意把ar当作如下的16位构成来处理：xxxx0000xxxxxxxx

	ar的高4位被称为“扩展访问权”，由 G D 0 0 构成
	G是G bit, G=1的时候，limit的单位不解释成字节（byte），而解释成页（page）
	D是指段的模式，1是指32位模式，0是指16位模式。

	ar的低8位从80286时代就已经有了
	00000000 (0x00) : 未使用的descriptor table
	00000000 (0x92) : 系统专用，可读写，不可执行
	00000000 (0x9a) : 系统专用，readonly，可执行
	00000000 (0xf2) : app专用，可读写，不可执行
	00000000 (0xfa) : app专用，readonly，可执行


*/
struct SEGMENT_DESCRIPTOR {
	short limit_low, base_low;
	char base_mid, access_right;
	char limit_high, base_high;
};

// 存放 8 字节 IDT
struct GATE_DESCRIPTOR {
	short offset_low, selector;
	char dw_count, access_right;
	short offset_high;
};

void init_gdtidt(void);

void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar);

```


dsctbl.c
```
void init_gdtidt(void)
{
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) 0x00270000;
	struct GATE_DESCRIPTOR    *idt = (struct GATE_DESCRIPTOR    *) 0x0026f800;
	int i;

	/* 
		初始化 8192 个 GDT, 8192 * 8 = 65536 = 0xffff+1
		将它们的上限（limit，指段的字节数-1）、基址（base）、访问权限都设为0。
	*/
	for (i = 0; i < 8192; i++) {
		set_segmdesc(gdt + i, 0, 0, 0);
	}
	/*
		段号为1的段，上限值为0xffffffff即大小正好是4GB），地址是0，它表示的是CPU所能管理的全部内存本身。段的属性设为0x4092，它的含义我们留待明天再说。
		段号为2的段，它的大小是512KB，地址是0x280000。这正好是为bootpack.hrb而准备的。用这个段，就可以执行bootpack.hrb。
		因为bootpack.hrb是以ORG 0为前提翻译成的机器语言
	*/
	set_segmdesc(gdt + 1, 0xffffffff, 0x00000000, 0x4092);
	set_segmdesc(gdt + 2, 0x0007ffff, 0x00280000, 0x409a);

	// C语言里不能给GDTR赋值，所以要借助汇编语言
	load_gdtr(0xffff, 0x00270000);

	/* 初始化 256 个 ID, 256 * 8=2048 = 0x7ff+1 */
	for (i = 0; i < 256; i++) {
		set_gatedesc(idt + i, 0, 0, 0);
	}

	load_idtr(0x7ff, 0x0026f800);

	return;
}

void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar)
{
	if (limit > 0xfffff) {
		ar |= 0x8000; /* G_bit = 1 */
		limit /= 0x1000;
	}
	sd->limit_low    = limit & 0xffff;
	sd->base_low     = base & 0xffff;
	sd->base_mid     = (base >> 16) & 0xff;
	sd->access_right = ar & 0xff;
	sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
	sd->base_high    = (base >> 24) & 0xff;
	return;
}

void set_gatedesc(struct GATE_DESCRIPTOR *gd, int offset, int selector, int ar)
{
	gd->offset_low   = offset & 0xffff;
	gd->selector     = selector;
	gd->dw_count     = (ar >> 8) & 0xff;
	gd->access_right = ar & 0xff;
	gd->offset_high  = (offset >> 16) & 0xffff;
	return;
}
```

naskfunc.nas
```
_load_gdtr:		; void load_gdtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LGDT	[ESP+6]
   RET

_load_idtr:		; void load_idtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LIDT	[ESP+6]
   RET

```

执行_load_gdtr时，DWORD[ESP+4]里存放的是段上限，DWORD[ESP+8]里存放的是地址。实际运行时就是0x0000ffff和0x00270000。
把它们按字节写出来的话，就成了[FF FF 00 00 00 00 27 00]（要注意低位放在内存地址小的字节里）。

GDTR寄存器的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。剩下的高32位（即剩余的4个字节），代表GDT的开始地址。

为了执行LGDT，希望把它们排列成[FF FF 00 00 27 00]的样子，所以就先用“MOV AX, [ESP+4]”读取最初的0xffff，然后再写到[ESP+6]里。这样，结果就成了[FF FF FF FF 00 00 27 00]，如果从[ESP+6]开始读6字节的话，正好是我们想要的结果。
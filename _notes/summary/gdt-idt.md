
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

	8192 个段的设定信息会占用 8192*8字节=65536字节（64KB），这个信息块会被放在内存中，

	设定GDT就是将GDT在内存中的起始地址和有效设定个数放在CPU内被称作GDTR的寄存器中


## IDT（interrupt descriptor table）

	当CPU遇到外部状况变化，或者是内部偶然发生某些错误时，会临时切换过去处理这种突发事件。这就是中断功能。

	处理各种外部设备（鼠标，键盘，网卡...）的输入，首先想到的处理方法是`查询`，但为了能够及时处理各种设备输入，就必须不断查询，
	这是很浪费CPU资源的做法

	正是为解决以上问题，才有了中断机制。各个设备有变化时就产生中断，中断发生后，CPU暂时停止正在处理的任务，并做好接下来能够继续处理的准备，
	转而执行中断程序。

	中断程序执行完以后，再调用事先设定好的函数，返回处理中的任务。这样一来，CPU就可以不用一直查询键盘，鼠标，网卡等设备的状态，将精力集中在处理任务上。

	IDT记录了0～255的中断号码与调用函数的对应关系


bootpack.h
```
// 存放 8 字节 GDT
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
bootpack.c
```
void init_gdtidt(void)
{
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) 0x00270000;
	struct GATE_DESCRIPTOR    *idt = (struct GATE_DESCRIPTOR    *) 0x0026f800;
	int i;

	/* 
		初始化 8192 个 GDT  
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

	/* 初始化 256 个 ID */
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
# Day 5 - 3
## GDT与IDT的初始化（harib02i）

GDT 和 IDT 都是与CPU有关的设定。

为了让操作系统能够使用32位模式，需要对CPU做各种设定

分段就是按照自己喜欢的方式，将4GB内存分成很多块（block），每一块的起始地址都看作0来处理。

有了这个功能，任何程序都可以先写上一句ORG 0。像这样分割出来的块，就称为段（segment）。

如果不用分段而用分页[插图]（paging），也能解决问题。不过我们目前还不讨论分页。

16位的分段，计算地址，只要将地址乘以16就可以了。

32位下如果写成“MOV AL, [DS:EBX]”, CPU会往EBX里加上某个值来计算地址，这个值不是DS的16倍，而是DS所表示的段的起始地址。即使省略段寄存器（segment register）的地址，也会自动认为是指定了DS。

按这种分段方法，为了表示一个段，需要有以下信息。
- 段的大小是多少 
- 段的起始地址在哪里
- 段的管理属性（禁止写入，禁止执行，系统专用等）


模仿图像调色板的做法。先有一个段号，存放在段寄存器里。然后预先设定好段号与段的对应关系。调色板中，色号可以使用0～255的数。段号可以用0～8191的数。因为段寄存器是16位，所以本来应该能够处理0～65535范围的数，但由于CPU设计上的原因，段寄存器的低3位不能使用。因此能够使用的段号只有13位，能够处理的就只有位于0～8191的区域了。

但因为能够使用0～8191的范围，即可以定义8192个段，所以设定这么多段就需要8192×8=65536字节（64KB）

GDT是“global（segment）descriptor table”的缩写，意思是全局段号记录表。将这些数据整齐地排列在内存的某个地方，然后将内存的起始地址和有效设定个数放在CPU内被称作GDTR的特殊寄存器中，设定就完成了。

IDT是“interrupt descriptor table”的缩写，直译过来就是“中断记录表”。
各个设备有变化时就产生中断，中断发生后，CPU暂时停止正在处理的任务，并做好接下来能够继续处理的准备，转而执行中断程序。中断程序执行完以后，再调用事先设定好的函数，返回处理中的任务。正是得益于中断机制，CPU可以不用一直查询键盘，鼠标，网卡等设备的状态，将精力集中在处理任务上。

IDT记录了0～255的中断号码与调用函数的对应关系

如果段的设定还没顺利完成就设定IDT的话，会比较麻烦，所以必须先进行GDT的设定。

## Move mouse (GDT Global Descriptor Table and IDT Interupt Descriptor Table)
p101

## 16位寻址
Intel在8086 CPU中设置了四个段寄存器：CS、DS、SS和ES，分别用于可执行代码段、数据段、堆栈段及其他段

```
MOV AL, [DS:EBX]
```
DS 表示段的起始地址

## 32位寻址
段寄信息(8 bytes)
- 段大小
- 段起始地址
- 段访问权限

段寄存器 (16 bytes, 只能用高13位), 因此段号的取值范围是 0~ 8191

8191 x 8 = 65536 bytes = 64KB

这段内存的起始地址和大小被放在 GDTR 寄存器中

这是一个很特别的48位寄存器，并不能用我们常用的MOV指令来赋值。
给它赋值的时候，唯一的方法就是指定一个内存地址，从指定的地址读取6个字节（也就是48位），
然后赋值给GDTR寄存器。完成这一任务的指令，就是LGDT。
该寄存器的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。
剩下的高32位（即剩余的4个字节），代表GDT的开始地址。


## Interupt
IDT Interupt Descriptor Table 中记录了0~255个中断的号码和对应的函数调用

代码见 https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02i

```

struct SEGMENT_DESCRIPTOR {
	short limit_low, base_low;
	char base_mid, access_right;
	char limit_high, base_high;
};

struct GATE_DESCRIPTOR {
	short offset_low, selector;
	char dw_count, access_right;
	short offset_high;
};

void init_gdtidt(void);
void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar);
void set_gatedesc(struct GATE_DESCRIPTOR *gd, int offset, int selector, int ar);
void load_gdtr(int limit, int addr);
void load_idtr(int limit, int addr);

```



CPU到底是处于系统模式还是应用模式，取决于执行中的应用程序是位于访问权为0x9a的段，还是位于访问权为0xfa的段。

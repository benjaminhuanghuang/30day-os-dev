# Day 5 - 3 处理 Mouse 中断

移动mouse需要处理中断
https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02i


## GDT(global（segment）descriptor table)与IDT(interrupt descriptor table)的初始化（harib02i）

- GDT(global（segment）descriptor table)
为了让操作系统能够使用32位模式，需要对CPU做各种设定


16位的分段，计算地址，只要将地址乘以16就可以了。

32位下如果写成“MOV AL, [DS:EBX]”, CPU会往EBX里加上某个值来计算地址，这个值不是DS的16倍，而是DS所表示的段的起始地址。即使省略段寄存器（segment register）的地址，也会自动认为是指定了DS。

按这种分段方法，为了表示一个段，需要有以下信息。
- 段的大小是多少 
- 段的起始地址在哪里
- 段的管理属性（禁止写入，禁止执行，系统专用等）


模仿图像调色板的做法。先有一个段号，存放在段寄存器里。然后预先设定好段号与段的对应关系。调色板中，色号可以使用0～255的数。

段号可以用0～8191的数。段寄存器是16位，所以本来应该能够处理0～65535范围的数，但由于CPU设计上的原因，段寄存器的低3位不能使用。因此能够使用的段号只有13位，能够处理的就只有位于0～8191的区域了。即可以定义8192个段，所以设定这么多段就需要8192×8=65536字节（64KB）

这段内存的起始地址和大小被放在 GDTR 寄存器中.
GDTR 有48位，不能用MOV指令来赋值。 给它赋值的时候，唯一的方法就是指定一个内存地址，用LGDT指令从指定的地址读取6个字节（也就是48位）
GDTR的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。 高32位（即剩余的4个字节），代表GDT的开始地址。


- IDT(interrupt descriptor table)

IDT记录了0～255的中断号码与调用函数的对应关系

如果段的设定还没顺利完成就设定IDT的话，会比较麻烦，所以必须先进行GDT的设定。


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
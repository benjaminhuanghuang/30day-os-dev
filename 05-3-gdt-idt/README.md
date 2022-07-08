# Day 5 - 3

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




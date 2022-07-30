## IDT(interrupt descriptor table)

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

```
; 指定的段上限（limit）和地址值赋值给GDTR寄存器。
; GDTR 有 48位寄存器，不能用MOV指令来赋值。
; 需要使用 LGDT 指令从指定的地址读取6个字节（也就是48位），
; GDTR 低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。
;      高32位（即剩余的4个字节），代表GDT的开始地址。
_load_gdtr:		; void load_gdtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LGDT	  [ESP+6]
   RET

_load_idtr:		; void load_idtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LIDT	[ESP+6]
   RET
```
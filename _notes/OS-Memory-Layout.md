Day5 P105 P106 
GDT 被设定为 0x270000 ~ 0x27FFFF

IDT 被设定为 0x26F800 ~ 0x26FFFF
```
#define ADR_IDT			0x0026f800
#define LIMIT_IDT		0x000007ff
#define ADR_GDT			0x00270000
#define LIMIT_GDT		0x0000ffff
```

bootpack.harb 是以ORG 0位前提编译的, asmhead.s 会把bootpack.harb 加载到 0x280000~0x2fffff




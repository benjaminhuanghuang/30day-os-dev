##
```
; haribote os(haribote.sys)
; |---------------------------------------------------|
; |             | header added |     bootpack.hrb     |
; | asmhead.nas |              |                      |
; |             |  by linker   | haribote os (C part) |
; |---------------------------------------------------|
```

## 内存分布
```
  0x00000000 - 0x000fffff: BIOS, VRAM (1M)
  
  0x00100000 - 0x00267fff: floppy disk (1440KB)

  0x00268000 - 0x0026f7ff: Empty (30KB)

  0x0026f800 - 0x0026ffff: IDT (2KB)
  
  0x00270000 - 0x0027ffff: GDT (1440KB)

  0x00280000 - 0x002fffff: bootpack.hrb (512)

  0x00300000 - 0x003fffff: stack (1MB)

  0x00400000 -             Empty




; 0x00000000|-------------------------|
;           |      infos by BIOS      |
; 0x00100000|=========================|
;           |  memory floppy storage  |
; 0x267fffh |=========================|
;           |       IDT, GDT          |
; 280000h   |=========================|
;           |   haribote os(C part)   |
; 0x2fffff  |=========================|
;           |  stack and global-data  |
;           |  haribote os (C part)   |
; 0x3fffff  |=========================|
;           |          ....           |

```

## Files
ipl10.nas    : initial program load

asmhead.nas  : 

naskfunc.nas :

bootpack.c   :

bootpack.h   : 函数，变量声明 

graphic.h    : 调色板，字体，draw text, draw mouse cursor

dsctbl.c     : idt, gdt 初始化

int.c        : 中断处理, 键盘，鼠标 

fifo.c       : FIFO buffer, 接收鼠标，键盘数据

hankaku.txt  : Font

keyboard.c   : 中断处理函数，keyboard setup

mouse.c      : 中断处理函数，mouse setup

memory.c     : memory

sheet.c      : 


## OS Memory Layout
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





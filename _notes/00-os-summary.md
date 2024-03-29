ipl.asm 会被加载到0x7c00处


Fat格式的磁盘上第一个文件的起始位置在 512 * 33 = 0x4200

因为loader会把disk上从C0-H0-S2开始到C0-H0-S18的内容加载到0x8200，

所以kernel(磁盘上唯一的文件,位于磁盘0x4200)会被加载到内存(0x8200-0x200)+0x4200 = 0xc200的位置。

因此kernel.asm中 org 应为 0xc2000， loader中最后要jmp到0xc2000 开始执行





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


## Kernel 加载
ORG   0xc200            ; 程序被加载的内存地址  
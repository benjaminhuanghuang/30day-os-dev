# Day 5 - 1
Refactor the makefile

## struct 
haribo02b
```
struct BOOTINFO {
	char cyls, leds, vmode, reserve;
	short scrnx, scrny;
	char *vram;
};


struct BOOTINFO *binfo = (struct BOOTINFO *) 0x0ff0; 
xsize = (*binfo).scrnx;
ysize = binfo->scrnx;
```

## text
每一个字符都是一个 8x16 的点阵, 也就是 16个bytes, 某个bit为1就染一个pixel, 为0则略过
```
  static char font_A[16] = {
		0x00, 0x18, 0x18, 0x18, 0x18, 0x24, 0x24, 0x24,
		0x24, 0x7e, 0x42, 0x42, 0x42, 0xe7, 0x00, 0x00
	};


  void putfont8(char *vram, int xsize, int x, int y, char c, char *font);
```

## font
Conert hankaku.txt to a asm data 
```
  _hankaku:
    DB....
```
hankaku.txt 包含 256 个字符 

A 的编码是 0x41, 也就是A的ASCII 码, 其数据就在 hankaku + 'A' * 16 的地方

use it in C
```
  extra char hankadu[4096];

  putfont8(binfo->vram, binfo->scrnx,  8, 8, COL8_FFFFFF, hankaku + 'A' * 16);

  putfonts8_asc(binfo->vram, binfo->scrnx,  8,  8, COL8_FFFFFF, "ABC 123");
```


## use sprintf 修改链接方式
harib02g
sprintf 只是将内容输出到内存中, 不依赖os
```
  #include "stdio.h"

  char s[40];
  sprintf(s, "scrnx = %d", binfo->scrnx);
	putfonts8_asc(binfo->vram, binfo->scrnx, 16, 64, COL8_FFFFFF, s);	
```
to fix 
```
stdio.c:(.text+0x2b2): undefined reference to `__stack_chk_fail'
```
add CFLAGS
```
  -fno-stack-protector
```

前几章一直使用ld 链接生成 kernel.bin
sprintf() 不能正常工作,什么也不显示, 参考 https://gitee.com/ghosind/HariboteOS/blob/main/day5/Makefile 的做法
1. 把 asmhead.asm 编译成 bin 文件, 并使用 ORG   0xc200 指定加载位置
2. 其余部分(kernel_c)用ld 链接, 并指定起始地址为 0
3. 用 cat命令把 asmhead.o 和 kernel_c.o 写入同一个文件

同时需要修改 ld 中对memory的设定
```
MEMORY
{
  rom : ORIGIN = 0x000000, LENGTH = 0x280000
  ram : ORIGIN = 0x280000, LENGTH = 0x020000
}
```


## Draw = 写 VRAM

```
write_mem8:	; void write_mem8(int addr, int data);
   MOV		ECX,[ESP+4]		; [ESP+4] address of target address
   MOV		AL,[ESP+8]		; [ESP+8] address of data
   MOV		[ECX],AL
   RET
```

使用pointer
```
  unsigned char *p = (unsigned char *) 0xa0000;

	for (int i = 0; i <= 0xffff; i++) {
	  *(p + i) = i & 0x0f;
    // 
    p[i] = i & 0x0f;
	}
```

## 256 palette

VGA 320x200 8 位调色板模式，8 位只能使用 0 ～ 255，256 种颜色，

而 RGB 方式，用 6 位十六进制数，也就是 24 位（二进制）来指定颜色。8 位数完全不够。

这个 8 位彩色模式，是由程序员随意指定 0 ～ 255 的数字所对应的颜色的。比如 25 号颜色对应#ffffff,26 号颜色对应#123456 等。这种方式就叫做调色板（palette）。

缺省情况下 0 号颜色是 #000000， 15 号颜色是#ffffff

https://gitee.com/paud/30daysOS/blob/master/projects/04_day/harib01f/

```
    init_palette()

    set_palette();           // 用到了io 操作
```

本书只用了 16 种颜色

## Draw rectangle

https://gitee.com/paud/30daysOS/tree/master/projects/04_day/harib01g

在当前画面模式中，画面上有 320×200（=64000）个像素。
假设左上点的坐标是（0,0），右下点的坐标是（319,199），那么像素坐标（x, y）对应的 VRAM 地址
为 0xa0000 + x + y \* 320

其他画面模式也基本相同，只是 0xa0000 这个起始地址和 y 的系数 320 有些不同。

## Draw text

以前显示字符靠调用 BIOS 函数，在 32 位模式，不能再依赖 BIOS 了
https://gitee.com/paud/30daysOS/blob/master/projects/05_day/harib02d

字符可以用 8×16 的长方形像素点阵来表示, 空白的地方用 0， 其它部分用 1

要显示一个字符需要 16 个字节

```
    // Font data for charactor A
    static char font_A[16] = {
        0x00, 0x18, 0x18, 0x18, 0x18, 0x24, 0x24, 0x24,
        0x24, 0x7e, 0x42, 0x42, 0x42, 0xe7, 0x00, 0x00
    };
```

显示字符

用 for 语句将画 8 个像素的程序循环 16 遍，就可以显示出一个字符了

```
    void putfont8(char *vram, int xsize, int x, int y, char color, char *font);
```

## 增加字体(harib02e)

https://gitee.com/paud/30daysOS/blob/master/projects/05_day/harib02e

The font data is a text file contains information of 256 charactors

makefont.exe 将Font 文件（256个字符的字体文件）读进来，然后输出成16×256=4096字节的文件。

编译后生成hankaku.bin文件，但仅有这个文件还不能与bootpack.obj连接，因为它不是目标（obj）文件。所以，还要加上连接所必需的接口信息，将它变成目标文件。这项工作由bin2obj.exe来完成。

如果在C语言中使用这种字体数据，只需要写上
```
	extern char hankaku[4096];
```

https://vanya.jp.net/os/haribote.html#hrb
提供了另一个方法，把 txt file 转化成 c 文件，直接编译

s X X X \_ \_ X X X，

（（（（（（（（（0）_ 2 +1）_ 2 +1）_ 2 +1）_ 2）_ 2）_ 2 +1）_ 2 +1）_ 2 +1

128 + 64 + 32 + 4 + 2 + 1
以二进制表示，为“ 11100111”


## 使用 sprintf
sprintf 与printf函数的功能很相近。自制操作系统中不能随便使用printf函数，但sprintf可以使用。因为sprintf不是按指定格式输出，只是将输出内容作为字符串写在内存中。

要在C语言中使用sprintf函数，必须在源程序的开头写上#include<stdio.h>

这个sprintf函数，是本次使用的名为GO的C编译器附带的函数。它在制作者的精心设计之下能够不使用操作系统的任何功能。

## 显示鼠标指针（harib02h）
首先，将鼠标指针的大小定为16×16。
准备16×16=256字节的内存，然后往里面写入鼠标指针的数据。见 init_mouse_cursor8



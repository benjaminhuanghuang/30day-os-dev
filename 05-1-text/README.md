# Day 5 - 1

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
  
  void putfonts8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s);

```
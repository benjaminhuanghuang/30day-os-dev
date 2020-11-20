## 叠加处理（harib07b）
图层的信息

```
#define MAX_SHEETS		256
struct SHEET {
	unsigned char *buf;
	int bxsize, bysize, vx0, vy0, col_inv, height, flags;
};
```
buf是用来记录图层上所描画内容的地址（buffer的略语）。
图层的整体大小，用bxsize*bysize表示。
vx0和vy0是表示图层在画面上位置的坐标，v是VRAM的略语。
col_inv表示透明色色号，它是color（颜色）和invisible（透明）的组合略语。
height表示图层高度。(z-order)
Flags用于存放有关图层的各种设定信息。


管理多重图层信息的结构
```
struct SHTCTL {
	unsigned char *vram;
	int xsize, ysize, top;
	struct SHEET *sheets[MAX_SHEETS];
	struct SHEET sheets0[MAX_SHEETS];
};
struct SHTCTL *shtctl_init(struct MEMMAN *memman, unsigned char *vram, int xsize, int ysize);
struct SHEET *sheet_alloc(struct SHTCTL *ctl);
void sheet_setbuf(struct SHEET *sht, unsigned char *buf, int xsize, int ysize, int col_inv);
void sheet_updown(struct SHTCTL *ctl, struct SHEET *sht, int height);
void sheet_refresh(struct SHTCTL *ctl);
void sheet_slide(struct SHTCTL *ctl, struct SHEET *sht, int vx0, int vy0);
void sheet_free(struct SHTCTL *ctl, struct SHEET *sht);
```
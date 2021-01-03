## 叠加处理（harib07b）
我们并不是像上面那样仅仅把两张大小相同的图层重叠在一起，而是要从大到小准备很多张图层。最上面的小图层用来描绘鼠标指针，它下面的几张图层是用来存放窗口的，而最下面的一张图层用来存放桌面壁纸。同时，我们还要通过移动图层的方法实现鼠标指针的移动以及窗口的移动

```
/* sheet.c */
#define MAX_SHEETS		256

struct SHEET {
	unsigned char *buf;
	int bxsize, bysize, vx0, vy0, col_inv, height, flags;
};
```
sheet这个词，表示“透明图层”的意思

buf是用来记录图层上所描画内容的地址（buffer的略语）。
图层的整体大小，用bxsize*bysize表示。
vx0和vy0是表示图层在画面上位置的坐标，v是VRAM的略语。
col_inv表示透明色色号，它是color（颜色）和invisible（透明）的组合略语。
height表示图层高度。(z-order)
Flags用于存放有关图层的各种设定信息。use or unsuse

管理多重图层信息的结构
```
struct SHTCTL {
	unsigned char *vram;
	int xsize, ysize, top;
	struct SHEET *sheets[MAX_SHEETS];
	struct SHEET sheets0[MAX_SHEETS];
};
```
vram、xsize、ysize代表VRAM的地址和画面的大小
top代表最上面图层的高度
sheets0这个结构体用于存放我们准备的256个图层的信息
而sheets是记忆地址变量，由于sheets0中的图层顺序混乱，所以我们把它们按照高度进行升序排列，然后将其地址写入sheets中


```
struct SHTCTL *shtctl_init(struct MEMMAN *memman, unsigned char *vram, int xsize, int ysize);
struct SHEET *sheet_alloc(struct SHTCTL *ctl);
void sheet_setbuf(struct SHEET *sht, unsigned char *buf, int xsize, int ysize, int col_inv);
void sheet_updown(struct SHTCTL *ctl, struct SHEET *sht, int height);
void sheet_refresh(struct SHTCTL *ctl);
void sheet_slide(struct SHTCTL *ctl, struct SHEET *sht, int vx0, int vy0);
void sheet_free(struct SHTCTL *ctl, struct SHEET *sht);
```
## 3 提高叠加处理速度（1）（harib07c）
只重新描绘移动相关的部分，也就是图层移动前后的部分就可以了



## 4 提高叠加处理速度（2）（harib07d）
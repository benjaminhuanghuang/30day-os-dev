
#ifndef _SHEET_H_
#define _SHEET_H_

#include "memory.h"

#define MAX_SHEETS 256
#define SHEET_USE 1

struct Sheet {
  unsigned char *buf;
  int bxsize, bysize, vx0, vy0, col_inv, height, flags;
};

struct Shtctl {
  unsigned char *vram;
  int xsize, ysize, top;
  struct Sheet *sheets[MAX_SHEETS];
  struct Sheet sheets0[MAX_SHEETS];
};

struct Shtctl *shtctl_init(struct MemMan *memman, unsigned char *vram,
                           int xsize, int ysize);
struct Sheet *sheet_alloc(struct Shtctl *ctl);
void sheet_setbuf(struct Sheet *sht, unsigned char *buf, int xsize, int ysize,
                  int col_inv);
void sheet_updown(struct Shtctl *ctl, struct Sheet *sht, int height);
void sheet_refreshsub(struct Shtctl *ctl, int vx0, int vy0, int vx1, int vy1);
void sheet_refresh(struct Shtctl *ctl, struct Sheet *sht, int bx0, int by0,
                   int bx1, int by1);
void sheet_slide(struct Shtctl *ctl, struct Sheet *sht, int vx0, int vy0);
void sheet_free(struct Shtctl *ctl, struct Sheet *sht);

#endif // _SHEET_H_
#include "stdio.h"

#include "bootpack.h"
#include "desctbl.h"
#include "fifo.h"
#include "graphic.h"
#include "int.h"
#include "io.h"
#include "keyboard.h"
#include "mouse.h"

int main(void)
{
  struct BOOTINFO *binfo = (struct BOOTINFO *)0x0ff0;
  char s[40], mcursor[256];
  int mx, my, i;

  init_gdtidt();
  init_pic();
  io_sti();
  fifo8_init(&keyfifo, 32, keybuf);
  fifo8_init(&mousefifo, 128, mousebuf);
  io_out8(PIC0_IMR, 0xf9); /* enable PCI 1 and keyboard (11111001) */
  io_out8(PIC1_IMR, 0xef); /* enable mouse (11101111) */

  init_keyboard();

  init_palette();
  init_screen8(binfo->vram, binfo->scrnx, binfo->scrny);

  mx = (binfo->scrnx - 16) / 2;
  my = (binfo->scrny - 28 - 16) / 2;

  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);
  sprintf(s, "(%d, %d)", mx, my);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF, s);

  enable_mouse();
  
  for (;;)
  {
    io_cli();
    if (fifo8_status(&keyfifo) + fifo8_status(&mousefifo) == 0)
    {
      io_stihlt();
    }
    else
    {
      if (fifo8_status(&keyfifo) != 0)
      {
        i = fifo8_get(&keyfifo);
        io_sti();
        sprintf(s, "%02X", i);
        boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
        putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
      }
      else if (fifo8_status(&mousefifo) != 0)
      {
        i = fifo8_get(&mousefifo);
        io_sti();
        sprintf(s, "%02X", i);
        boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 32, 16, 47, 31);
        putfonts8_asc(binfo->vram, binfo->scrnx, 32, 16, COL8_FFFFFF, s);
      }
    }
  }
}

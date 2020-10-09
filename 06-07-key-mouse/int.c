/* 中断相关 */

#include "bootpack.h"
#include <stdio.h>

void init_pic(void)
/*PIC initialization */
{
  io_out8(PIC0_IMR, 0xff); /*Do not accept all interrupts */
  io_out8(PIC1_IMR, 0xff); /*Do not accept all interrupts */

  io_out8(PIC0_ICW1, 0x11);   /*Edge trigger mode */
  io_out8(PIC0_ICW2, 0x20);   /*IRQ0-7 is received by INT20-27 */
  io_out8(PIC0_ICW3, 1 << 2); /*PIC1 is connected by IRQ2 */
  io_out8(PIC0_ICW4, 0x01);   /*Non-buffer mode */

  io_out8(PIC1_ICW1, 0x11); /*Edge trigger mode */
  io_out8(PIC1_ICW2, 0x28); /*IRQ8-15 is received by INT28-2f */
  io_out8(PIC1_ICW3, 2);    /*PIC1 is connected by IRQ2 */
  io_out8(PIC1_ICW4, 0x01); /*Non-buffer mode */

  io_out8(PIC0_IMR, 0xfb); /*11111011 All except PIC1 prohibited */
  io_out8(PIC1_IMR, 0xff); /*11111111 Do not accept all interrupts */

  return;
}

#define PORT_KEYDAT		0x0060
struct FIFO8 keyfifo;

void inthandler21(int *esp)
/* PS/2 Keyboard */
{
	unsigned char data;
	io_out8(PIC0_OCW2, 0x61);	/* IRQ-01受付完了をPICに通知 */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&keyfifo, data);
	return;
}

struct FIFO8 mousefifo;
void inthandler2c(int *esp)
/* PS/2 mouse */
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);	/* 通知PIC1 IRQ-12接受完成 */
	io_out8(PIC0_OCW2, 0x62);	/* 通知PIC0 IRQ-02接受完成 */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

void inthandler27(int *esp)
{
	io_out8(PIC0_OCW2, 0x67); /* 通知PIC IRQ-07接受完成 */
	return;
}
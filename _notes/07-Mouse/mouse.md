
鼠标的中断号码是IRQ12

当鼠标刚刚作为计算机的一个外部设备开始使用的时候，几乎所有的操作系统都不支持它。
因此主板上的鼠标控制电路缺省被disabled。 必须发行指令激活鼠标控制电路和鼠标本身

见 http://cummitity.osdev.info


鼠标控制电路包含在键盘控制电路里


```
#define PORT_KEYDAT				0x0060
#define PORT_KEYSTA				0x0064
#define PORT_KEYCMD				0x0064
#define KEYSTA_SEND_NOTREADY	0x02
#define KEYCMD_WRITE_MODE		0x60
#define KBC_MODE				0x47

void wait_KBC_sendready(void)
{
	/* Wating for keyboard controller, 控制电路比较慢*/
	for (;;) {
		// CPU从设备号码0x0064处所读取的数据的倒数第二位
		if ((io_in8(PORT_KEYSTA) & KEYSTA_SEND_NOTREADY) == 0) {
			break;
		}
	}
	return;
}

void init_keyboard(void)
{
	/* 初始化键盘控制电路 */
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_WRITE_MODE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, KBC_MODE);
	return;
}

#define KEYCMD_SENDTO_MOUSE		0xd4
#define MOUSECMD_ENABLE			0xf4

/*
  如果往键盘控制电路发送指令0xd4，下一个数据就会自动发送给鼠标。根据这一特性来发送激活鼠标的指令。
  鼠标收到激活指令以后，马上就给CPU发送答复信息0xfa。
*/
void enable_mouse(void)
{
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, MOUSECMD_ENABLE);
	return; 
}
```



## Mouse 中断处理
```
struct FIFO8 mousefifo;

/*
  IRQ-12是从PIC的第4号（从PIC相当于IRQ-08～IRQ-15），首先要通知IRQ-12受理已完成，然后再通知主PIC。
*/

void inthandler2c(int *esp)
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);	/* 通知PIC1 IRQ-12接受完成 */
	io_out8(PIC0_OCW2, 0x62);	/* 通知PIC0 IRQ-02接受完成 */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

```

## 接收鼠标数据
每次从鼠标那里送过来的数据都应该是3个字节一组的，所以每当数据累积到3个字节，就把它显示在屏幕上。

变量mouse_phase用来记住接收鼠标数据的工作进展到了什么阶段（phase）。接收到的数据放在mouse_dbuf[0～2]内。

```
  unsigned char mouse_dbuf[3], mouse_phase;

  i = fifo8_get(&mousefifo);

  if(moues_phase == 0){
    if(i == 0xfa){
      mouse_phase = 1;
    }
  }
  else if(moues_phase == 1){
    mouse_dbf[0] = i;
    mouse_phase = 2;
  }
  else if(moues_phase == 2){
    mouse_dbf[1] = i;
    mouse_phase = 3;
  }
  else if(moues_phase == 3){
    mouse_dbf[2] = i;
    mouse_phase = 1;
    // render the mouse
  }
```

## Mouse 数据解读
代码见 mouse_decode()

鼠标button的状态，放在buf[0]的低3位
x和y，基本上是直接使用buf[1]和buf[2]，但是需要使用第一字节中对鼠标移动有反应的几位信息，将x和y的第8位及第8位以后全部都设成1，或全部都保留为0。这样就能正确地解读x和y。
```
  mdec->btn = mdec->buf[0] & 0x07;
  mdec->x = mdec->buf[1];
  mdec->y = mdec->buf[2];

  if ((mdec->buf[0] & 0x10) != 0) {
    mdec->x |= 0xffffff00;
  }
  if ((mdec->buf[0] & 0x20) != 0) {
    mdec->y |= 0xffffff00;
  }
  mdec->y = - mdec->y; /* mouse 与屏幕的Y方向相反 */
```

## 移动Mouse
````
  
  boxfill8(binfo->vram, binfo->scrnx, COL8_008484, mx, my, mx + 15, my + 15); /* Hide mouse */

  mx += mdec.x;
  my += mdec.y;
  if (mx < 0) {
    mx = 0;
  }
  if (my < 0) {
    my = 0;
  }
  if (mx > binfo->scrnx - 16) {
    mx = binfo->scrnx - 16;
  }
  if (my > binfo->scrny - 16) {
    my = binfo->scrny - 16;
  } 

  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16); /* show mouse */
```

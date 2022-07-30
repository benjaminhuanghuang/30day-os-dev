

键盘对应的中断是IRQ1, 
但是由于CPU内部会自动产生INT 0x00 ~ 0x0f, IRQ0 ~ IRQ15被映射到INT 0x20 ~ 0x2f
代码见 init_pic()

因此键盘对应到中断为INT21

```
  void inthandler21()
  {
    unsigned char data, s[4];
    // 通知 PIC IRQ-01已经处理完毕， 将 0x60+IRQ号码 输出给OCW2就可以
    io_out8(PICO_OCW2, 0x61);
    // 从编号为0x0060的设备输入的8位信息是按键编码
    data = io_in8(0x0060);

    sprintf(s, "%02x", data)

  }
```
键按下去之后，随即就会显示出一个数字（十六进制），键松开之后也会显示出一个数字。所以，计算机不光知道什么时候按下了键，还知道什么时候把键松开了

## FIFO Buffer
不能在中断处理函数中执行耗时太多的工作，中断处理进行期间，不再接受别的中断。所以如果处理键盘的中断速度太慢，会干扰别处理别的设备的输入

解决方案是 在 inthandler21 写 buffer， 在主程序中 读 buffer

注意当按下右Ctrl键时，会产生两个字节的键码值“E0 1D”，而松开这个键之后，会产生两个字节的键码值“E0 9D”。
在一次产生两个字节键码值的情况下，键盘内部电路一次只能发送一个字节，所以一次按键就会产生两次中断，第一次中断时发送E0，第二次中断时发送1D。

```
struct KEYBUT {
	unsigned char data[32];
	int next_r, next_w, len;
};

```

Write
```
void inthandler21(int *esp)
{
	unsigned char data;
	io_out8(PIC0_OCW2, 0x61);	

	data = io_in8(PORT_KEYDAT);
	
  if (keybuf.len < 32) {
		keybuf.data[keybuf.next_w] = data;
		keybuf.len++;
		keybuf.next_w++;
		if (keybuf.next_w == 32) {
			keybuf.next_w = 0;
		}
	}
	return;
}
```

Read
```
  i = keybuf.data[keybuf.next_r];
  keybuf.len--;
  keybuf.next_r++;
  if (keybuf.next_r == 32) {
    keybuf.next_r = 0;
  }

```

这个实现可以被提取成一个通用的 FIFO8
代码见 fifo.c





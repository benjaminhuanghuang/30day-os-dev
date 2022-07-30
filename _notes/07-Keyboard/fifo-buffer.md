## FIFO Buffer
不能在中断处理函数中执行耗时太多的工作，中断处理进行期间，不再接受别的中断。
如果处理键盘的中断速度太慢，会干扰别处理别的设备的输入

解决方案是 在 inthandler21 写 buffer， 在主程序中 读 buffer
```
struct KEYBUT {
	unsigned char data[32];
	int next_r, next_w, len;
};

```

注意当按下右Ctrl键时，会产生两个字节的键码值“E0 1D”，而松开这个键之后，会产生两个字节的键码值“E0 9D”。
在一次产生两个字节键码值的情况下，键盘内部电路一次只能发送一个字节，所以一次按键就会产生两次中断，第一次中断时发送E0，第二次中断时发送1D。



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

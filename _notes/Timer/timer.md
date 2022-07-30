

http://community.osdev.info/? (PIT) 8254

定时器（harib09a）

1
2
3
4

	

IRQ0的中断周期变更：
AL = 0x34
AL = 中断周期的低8位
AL = 中断周期的高8位

如果指定中断周期是0，会被看做指定为65536。实际的中断产生的频率是单位时间周期数（主频）/ 设定的数值。比如设定1000，那么中断产生的频率就是1.19318KHz。设定值为10000的话，中断产生频率就是119.318Hz。再比如设定值是11932的话，中断产生的频率大约就是100Hz了，即每10ms发生一次中断。

11932换算成十六进制就是0x2e9c

```
#define PIT_CTRL	0x0043
#define PIT_CNT0	0x0040
void init_pit(void)
{
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);
	io_out8(PIT_CNT0, 0x2e);
	return;
}
```
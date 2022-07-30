

键盘对应的中断是IRQ1, 由于CPU内部会自动产生INT 0x00 ~ 0x0f, IRQ0 ~ IRQ15被映射到INT 0x20 ~ 0x2f
代码见 init_pic()

## 键盘对应的中断为INT21
```
  void inthandler21()
  {
    unsigned char data, s[4];
    // 通知 PIC IRQ-01已经处理完毕， 将 0x60+IRQ号码 输出给OCW2就可以
    // 通知PIC继续监视IRQ1中断是否发生。否则，PIC就不再监视IRQ1中断
    io_out8(PICO_OCW2, 0x61);

    // 从编号为0x0060的设备输入的8位信息是按键编码
    data = io_in8(0x0060);

    sprintf(s, "%02x", data)
  }
```
键按下会显示出一个数字（十六进制），松开之后也会显示出一个数字。所以，计算机不光知道什么时候按下了键，还知道什么时候把键松开了






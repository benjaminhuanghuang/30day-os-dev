# Day 7 FIFO 与鼠标控制

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04a

在键盘对应的中断函数inthandler21中 从 PORT 0x60 读取 按键信息

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04b
在inthandler21 写 buffer， 在主程序中 读 buffer, 每次只能接受一个字节


- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04c
用 array 做buffer
```
struct KEYBUF {
  unsigned char data[32];
  int next;
};
```

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04d
双指针 buffer
```
struct KEYBUF {
  unsigned char data[32];
  int next_r, next_w, len;
};
```
inthandler21() 负责写 buffer

main() 读buffer

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04e
可变size buffer
```
struct FIFO8 {
  unsigned char *buf;
  int p, q, size, free, flags;
};
```

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04f
激活鼠标

- https://gitee.com/paud/30daysOS/tree/master/projects/07_day/harib04g
读写mousefifo
int.c




## 1 简化字符串显示（harib10a）
Add function draw text on sheet and refresh
```
void putfonts8_asc_sht(struct SHEET *sht, int x, int y, int c, int b, char *s, int l);
```


## 2 重新调整FIFO缓冲区（1）（harib10b）

把定时器用的多个FIFO缓冲区都集中成1个
在超时的情况下，往FIFO内写入不同的数据，就可以正常地分辨出是哪个定时器超时。

Change keyboard.c

remove
``` 
extern struct FIFO8 mousefifo;
extern struct FIFO8 keyfifo;
```


## 3 测试性能（harib10c～harib10f）

执行“count++; ”语句。当到了10秒后超时的时候，再显示这个count值



## 4 重新调整FIFO缓冲区（2）（harib10g）
通过往FIFO内写入不同的数据，可以把3个定时器归入1个FIFO缓冲区里。同理，分别将从键盘和鼠标输入的数据也设定为其他值就可以了

0～1…………………光标闪烁用定时器
3…………………3秒定时器
10…………………10秒定时器
256～511…………………键盘输入（从键盘控制器读入的值再加上256）
512～767……鼠标输入（从键盘控制器读入的值再加上512）

不过fifo8_put函数中的参数是char型，所以不能指定767那样的数值。

因此新增 FIFO32
```
struct FIFO32 {
    int ＊buf;
    int p, q, size, free, flags;
};
```

## 5 加快中断处理（4）（harib10h）

Use linked list

## 6 使用“哨兵”简化程序（harib10i）

using

## 1 闲置任务（harib14a）

当所有LEVEL中都没有任务存在的时候，就需要HTL了

创建这样一个任务，并把它一直放在最下层LEVEL中

```
void task_idle(void)
{
    for (; ; ) {
        io_hlt();
    }
}
```

即便任务A进入休眠状态，系统也会自动切换到上面这个闲置任务，于是便开始执行HTL

## 2 创建命令行窗口（harib14b）
Create task for console



## 3 切换输入窗口（harib14c）
```
void make_wtitle8(unsigned char *buf, int xsize, char *title, char act);
```

key_to这个变量，用于记录键盘输入（key）应该发送到（to）哪里。为0则发送到任务A，为1则发送到命令行窗口任务。


## 4 实现字符输入（harib14d）
把struct FIFO放到struct TASK里面, 没有什么任务是完全用不到FIFO的
```
struct TASK {
    int sel, flags; 
    int level, priority;
    struct FIFO32 fifo;
    struct TSS32 tss;
};
```
Update main() and console()



## 5 符号的输入（harib14e）
准备一个key_shift变量，当左Shift按下时置为1，右Shift按下时置为2，两个都不按时置为0，两个都按下时就置为3。
当key_shift为0时，我们用keytable0[] 将按键编码转换为字符编码，
而当key_shift不为0时，则使用keytable1[]进行转换。

## 6 大写字母与小写字母（harib14f）

要实现区分大写、小写字母的输入，必须要同时判断Shift键的状态以及CapsLock的状态。
```
binfo->leds的第4位 -> ScrollLock状态
binfo->leds的第5位 -> NumLock状态
binfo->leds的第6位 -> CapsLock状态
```

ASCII码中，大写字母的编码加上0x20，就得到相应的小写字母编码



## 7 对各种锁定键的支持（harib14g）
关于LED的控制:

对于NumLock和CapsLock等LED的控制，可采用下面的方法向键盘发送指令和数据。◆ 读取状态寄存器，等待bit 1的值变为0。◆ 向数据输出（0060）写入要发送的1个字节数据。◆ 等待键盘返回1个字节的信息，这和等待键盘输入所采用的方法相同（用IRQ等待或者用轮询状态寄存器bit 1的值直到其变为0都可以）。◆ 返回的信息如果为0xfa，表明1个字节的数据已成功发送给键盘。如为0xfe则表明发送失败，需要返回第1步重新发送。■ 要控制LED的状态，需要按上述方法执行两次，向键盘发送EDxx数据。其中，xx的bit 0代表ScrollLock, bit 1代表NumLock, bit 2代表CapsLock（0表示熄灭，1表示点亮）。bit 3～7为保留位，置0即可
```
	struct FIFO32 fifo, keycmd;
	int fifobuf[128], keycmd_wait = -1;
```



## 1 蜂鸣器发声（harib22a）

音高操作 
AL = 0xb6; OUT(0x43, AL)； 
AL = 设定值的低位8bit; OUT(0x42, AL)；
AL = 设定值的高位8bit; OUT(0x42, AL)； 
设定值为0时当作65536来处理。 
发声的音高为时钟除以设定值，也就是说设定值为1000时相当于发出1.19318KHz的声音；设定值为10000时相当于119.318Hz。因此设定2712即可发出约440Hz的声音


蜂鸣器ON/OFF 
使用I/O端口0x61控制。 
ON:IN(AL, 0x61); AL |= 0x03; AL &= 0x0f; OUT(0x61, AL)； 
OFF:IN(AL, 0x61); AL &= 0xd; OUT(0x61, AL)；


## 2 增加更多的颜色（1）（harib22b）


## 4 窗口初始位置（harib22d）
希望让窗口总是显示在画面的中央，而且显示窗口时的图层高度也不能总是固定为3，而是要判断当前画面中窗口的数量并自动显示在最上面

edx = 5

## 5 增加命令行窗口（1）（harib22e）
目前不能同时启动两个应用程序

要解决这个问题，可以考虑修改一下命令行窗口，使其在应用程序运行中就可以输入下一条命令，不过这样的修改量实在太大，讲解起来也会很麻烦，
因此改用同时启动两个命令行窗口

task_cons -> task_cons[0]和task_cons[1]

## 6 增加命令行窗口（2）（harib22f）
每个task 必须有各自独立的 consol 和 ds_base
```
struct TASK {
    int sel, flags; /＊ sel代表GDT编号＊/
    int level, priority;
    struct FIFO32 fifo;
    struct TSS32 tss;
    struct CONSOLE ＊cons;   
    int ds_base;             
};
```

## 7 增加命令行窗口（3）（harib22g）



## 9 变得更像真正的操作系统（1）（harib22i）

remove task_a from bootpack.c


## 10 变得更像真正的操作系统（2）（harib22j）


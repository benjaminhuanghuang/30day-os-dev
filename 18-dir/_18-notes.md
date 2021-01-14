## 1 控制光标闪烁（1）（harib15a）

判断是否按下Tab键的是HariMain，而控制光标闪烁的是HariMain和console_task

当不想显示光标的时候，使cursor_c为负值


## 2 控制光标闪烁（2）（harib15b）

怎样由HariMain（任务A）向console_task（命令行窗口）传递信息，告诉它“不需让光标闪烁”或者“需要让光标闪烁”呢？
像传递按键编码一样，我们可以使用FIFO来实现。我们先将光标开始闪烁定义为2，停止闪烁定义为3。


## 3 对回车键的支持（harib15c）
```
    if (i == 256 + 0x1c) {	/* Enter */
      if (key_to != 0) {	
        fifo32_put(&task_cons->fifo, 10 + 256);
      }
    }
```
修改接收数据的console_task。之前已经有了一个cursor_x变量，再创建一个cursor_y变量，当按下回车键时，将cursor_y加1就可以


## 4 对窗口滚动的支持（harib15d）

In the console, 将所有的像素向上移动一行

## 5 mem命令（harib15e）

cmdline[30];


## 6 cls命令（harib15f）


## 7 dir命令（harib15g）
在磁盘映像中加入了haribote.sys、ipl10.nas和make.bat这3个文件

查看磁盘映像中0x002600字节以后的部分

```
struct FILEINFO {
    unsigned char name[8], ext[3], type;
    char reserve[10];
    unsigned short time, date, clustno;
    unsigned int size;
};
```

如果文件名的第一个字节为0xe5，代表这个文件已经被删除了
文件名第一个字节为0x00，代表这一段不包含任何文件名信息。

从磁盘映像的0x004200就开始存放文件haribote.sys了，因此文件信息最多可以存放224个。


```
0x01……只读文件（不可写入）
0x02……隐藏文件
0x04……系统文件
0x08……非文件信息（比如磁盘名称等）
0x10……目录
```

#define ADR_DISKIMG		0x00100000



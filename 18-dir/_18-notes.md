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



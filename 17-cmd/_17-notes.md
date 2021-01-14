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
把struct FIFO放到struct TASK里面



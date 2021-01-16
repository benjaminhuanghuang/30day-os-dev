## 9 变得更像真正的操作系统（1）（harib22i）

remove task_a from bootpack.c


## 10 变得更像真正的操作系统（2）（harib22j）
因为命令行窗口任务的优先级比较低，只有当bootpack.c的HariMain休眠之后才会运行命令行窗口任务，
而如果不运行这个任务的话，FIFO缓冲区就不会被初始化，这就相当于我们在向一个还没初始化的FIFO强行发送数据，于是造成fifo32_put混乱而导致重启。




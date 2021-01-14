## 1 任务管理自动化（harib13a）
Add TASKCTL and task_timer


## 2 让任务休眠（harib13b）

将一个任务从tasks中删除的操作，用多任务中的术语来说叫做“休眠”（sleep）。

当FIFO有数据过来的时候，必须要把任务A唤醒
```
struct FIFO32 {
    int ＊buf;
    int p, q, size, free, flags;
    struct TASK ＊task;
};
```

## 3 增加窗口数量（harib13c）
为系统增加更多的任务: 任务A、任务B0、任务B1和任务B2


## 4 设定任务优先级（1）（harib13d）
Add priority
```
struct TASK {
    int sel, flags; /* sel代表GDT编号 */
    int priority;   
    struct TSS32 tss;
};
```

Update task_init() 


Add priority to task_run
```
void task_run(struct TASK *task, int priority)
```
一开始我们先判断了priority的值，当为0时则表示不改变当前已经设定的优先级。这样的设计主要是为了在唤醒休眠任务的时候使用。


update task_switch()



Update fifo32_put()
只是将任务唤醒，并不改变其优先级，因此只要将优先级设置为0就可以了。


Call it it main
```
    task_run(task_b[i], i);
```
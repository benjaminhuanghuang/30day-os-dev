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


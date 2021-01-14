## 1 任务管理自动化（harib13a）
Add TASKCTL and task_timer


## 2 让任务休眠（harib13b）

将一个任务从tasks中删除的操作，用多任务中的术语来说叫做“休眠”（sleep）。

当FIFO有数据过来的时候，必须要把任务A唤醒
```
struct FIFO32 {
    int *buf;
    int p, q, size, free, flags;
    struct TASK *task;
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

## 5 设定任务优先级（2）（harib13e）
在操作系统中有一些处理，即使牺牲其他任务的性能也必须要尽快完成，比如task_a对鼠标的处理。
对于这类任务，我们可以让它在处理结束后马上休眠，而优先级则可以设置得非常高。
这种宁可牺牲其他任务性能也必须要尽快处理的任务 有键盘处理，网络处理，播放音乐...

需要设计一种架构，使得高优先级的任务同时运行，也能够区分哪个更加优先。
```
#define MAX_TASKS_LV     100
#define MAX_TASKLEVELS  10

struct TASK {
    int sel, flags; /* se1用来存放GDT的编号*/
    int level, priority;
    struct TSS32 tss;
};

struct TASKLEVEL {
    int running; /*正在运行的任务数量*/
    int now; /*这个变量用来记录当前正在运行的是哪个任务*/
    struct TASK *tasks[MAX_TASKS_LV];
};

struct TASKCTL {
    int now_lv; /*现在活动中的LEVEL */
    char lv_change; /*在下次任务切换时是否需要改变LEVEL */
    struct TASKLEVEL level[MAX_TASKLEVELS];
    struct TASK tasks0[MAX_TASKS];
};
```

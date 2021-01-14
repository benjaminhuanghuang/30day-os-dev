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


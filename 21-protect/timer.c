#include "bootpack.h"

#define PIT_CTRL 0x0043
#define PIT_CNT0 0x0040

struct TIMERCTL timerctl;

#define TIMER_FLAGS_ALLOC 1
#define TIMER_FLAGS_USING 2

void init_pit(void)
{   /*
    中断产生的频率是单位时间周期数（主频）/ 设定的数值。
    比如设定1000, 中断产生的频率就是1.19318KHz
    Set 11932的话，中断产生的频率大约就是100Hz了，即每10ms发生一次中断。
    11932换算成十六进制就是0x2e9c
    */
    int i;
    struct TIMER *t;
    io_out8(PIT_CTRL, 0x34);
    io_out8(PIT_CNT0, 0x9c);
    io_out8(PIT_CNT0, 0x2e);
    timerctl.count = 0;
    for (i = 0; i < MAX_TIMER; i++)
    {
        timerctl.timers0[i].flags = 0; /* 没有使用 */
    }
    t = timer_alloc(); /* 取得一个 */
    t->timeout = 0xffffffff;
    t->flags = TIMER_FLAGS_USING;
    t->next = 0;                /* 末尾 */
    timerctl.t0 = t;            /* 因为现在只有哨兵，所以他就在最前面*/
    timerctl.next = 0xffffffff; /* 因为只有哨兵，所以下一个超时时刻就是哨兵的时刻 */
    // timerctl.using = 1;
    return;
}

struct TIMER *timer_alloc(void)
{
    int i;
    for (i = 0; i < MAX_TIMER; i++)
    {
        if (timerctl.timers0[i].flags == 0)
        {
            timerctl.timers0[i].flags = TIMER_FLAGS_ALLOC;
            return &timerctl.timers0[i];
        }
    }
    return 0;
}

void timer_free(struct TIMER *timer)
{
    timer->flags = 0;
    return;
}

void timer_init(struct TIMER *timer, struct FIFO32 *fifo, int data)
{
    timer->fifo = fifo;
    timer->data = data;
    return;
}

void timer_settime(struct TIMER *timer, unsigned int timeout)
{
    int e;
    struct TIMER *t, *s;
    timer->timeout = timeout + timerctl.count;
    timer->flags = TIMER_FLAGS_USING;
    e = io_load_eflags();
    io_cli();
    t = timerctl.t0;
    if (timer->timeout <= t->timeout)
    {
        /* 插入最前面的情况 */
        timerctl.t0 = timer;
        timer->next = t; /* 下面是设定t */
        timerctl.next = timer->timeout;
        io_store_eflags(e);
        return;
    }
    /* 搜寻插入位置 */
    for (;;)
    {
        s = t;
        t = t->next;
        if (timer->timeout <= t->timeout)
        {
            /* 插入s和t之间的情况 */
            s->next = timer; /* s下一个是timer */
            timer->next = t; /* timer的下一个是t */
            io_store_eflags(e);
            return;
        }
    }
}

void inthandler20(int *esp)
{
    struct TIMER *timer;
    char ts = 0;
    io_out8(PIC0_OCW2, 0x60); /* 把IRQ-00接收信号结束的信息通知给PIC */

    timerctl.count++;
    if (timerctl.next > timerctl.count)
    {
        return;
    }
    timer = timerctl.t0; /* 首先把最前面的地址赋给timer*/
    for (;;)
    {
        /* 因为timers的定时器都处于运行状态，所以不确认flags */
        if (timer->timeout > timerctl.count)
        {
            break;
        }
        /* 超时 */
        timer->flags = TIMER_FLAGS_ALLOC;
        if (timer != task_timer)
        {
            fifo32_put(timer->fifo, timer->data);
        }
        else
        {
            ts = 1; /* mt_timer timed out */
        }

        timer = timer->next; /* 将下一个定时器的地址赋给timer*/
    }
    timerctl.t0 = timer;
    timerctl.next = timer->timeout;
    if (ts != 0) {
		task_switch();
	}

    return;
}

## 1 使用定时器（harib09a）
Timer的原理 每隔一段时间（比如0.01秒）就发送一个中断信号给CPU

要在电脑中管理定时器，只需对PIT（Programmable Interval Timer）进行设定就可以了。
我们可以通过设定PIT，让定时器每隔多少秒就产生一次中断。
因为在电脑中PIT连接着IRQ（interrupt request，参考第6章）的0号，所以只要设定了PIT就可以设定IRQ0的中断间隔。

http://community.osdev.info/? (PIT) 8254

 IRQ0的中断周期变更：
 - AL=0x34:OUT(0x43, AL)；
 - AL=中断周期的低8位；OUT(0x40, AL)；
 - AL=中断周期的高8位；OUT(0x40, AL)；
 
 如果指定中断周期为0，会被看作是指定为65536。实际的中断产生的频率是单位时间时钟周期数（即主频）/设定的数值。
 比如设定值如果是1000，那么中断产生的频率就是1.19318KHz。
 设定值是10000的话，中断产生频率就是119.318Hz。
 设定值是11932的话，中断产生的频率大约就是100Hz了，即每10ms发生一次中断。
 
 只要执行3次OUT指令设定就完成了。将中断周期设定为11932的话，中断频率好像就是100Hz，也就是说1秒钟会发生100次中断。
 ```
 ```

中断处理函数


中断处理程序注册到IDT, init_gdtidt函数中也要加上几行


## 2 计量时间（harib09b）


## 3 超时功能（harib09c）
```
  /* timer.c */
  struct TIMERCTL {
    unsigned int count;
    unsigned int timeout;
    struct FIFO8 *fifo;
    unsigned char data;
  };
```
timeout用来记录离超时还有多长时间。一旦这个剩余时间达到0，程序就往FIFO缓冲区里发送数据。


## 4 设定多个定时器（harib09d）
```
  /* timer.c */
  #define MAX_TIMER		500

  struct TIMER {
    unsigned int timeout, flags;
    struct FIFO8 *fifo;
    unsigned char data;
  };
  
  struct TIMERCTL {
    unsigned int count;
    struct TIMER timer[MAX_TIMER];
  };
```

## Timer
Timer每隔一段时间（比如0.01秒）就发送一个中断信号给CPU

要在电脑中管理定时器，只需对PIT进行设定就可以了。PIT是“ Programmable Interval Timer”的缩写，
我们可以通过设定PIT，让定时器每隔多少秒就产生一次中断。因为在电脑中PIT连接着IRQ（interrupt request，参考第6章）的0号，所以只要设定了PIT就可以设定IRQ0的中断间隔。
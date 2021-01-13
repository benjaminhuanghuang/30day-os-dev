## 1 挑战任务切换（harib12a）

向CPU发出任务切换的指令时，CPU会先把寄存器中的值全部写入内存中，这样做是为了当以后切换回这个程序的时候，可以从中断的地方继续运行。接下来，为了运行下一个程序，CPU会把所有寄存器中的值从内存中读取出来（当然，这个读取的地址和刚刚写入的地址一定是不同的，不然就相当于什么都没变嘛），这样就完成了一次切换。我们前面所说的任务切换所需要的时间，正是对内存进行写入和读取操作所消耗的时间


EIP(extended instructionpointer): CPU用来记录下一条需要执行的指令位于内存中哪个地址的寄存器

JMP指令实际上是一个向EIP寄存器赋值的指令。JMP0x1234这种写法，CPU会解释为MOV EIP,0x1234，并向EIP赋值

JMP指令分为两种，只改写EIP的称为near模式，同时改写EIP和CS的称为far模式

TR(task register): CPU记住当前正在运行哪一个任务。当进行任务切换的时候，TR寄存器的值也会自动变化，给TR寄存器赋值的时候，必须把GDT的编号乘以8


A to B

## 2 任务切换进阶（harib12b）
B to A


## 3 做个简单的多任务（1）（harib12c）

```
  _farjmp:         ; void farjmp(int eip, int cs);
    JMP      FAR [ESP+4]               ; eip, cs
    RET


  taskswitch3(); -> farjmp(0, 3 ＊ 8)；
  taskswitch4(); -> farjmp(0, 4 ＊ 8)；  
```

## 4 做个简单的多任务（2）（harib12d）


## 5 提高运行速度（harib12e）


## 6 测试运行速度（harib12f）


## 7 多任务进阶（harib12g）
Add mtask.c

Change timer interupt handler

为什么不在for loop中调用mt_taskswitch
调用mt_taskswitch进行任务切换的时候，即便中断处理还没完成，IF（中断允许标志）的值也可能会被重设回1（因为任务切换的时候会同时切换EFLAGS）。这样可不行，在中断处理还没完成的时候，可能会产生下一个中断请求，这会导致程序出错。

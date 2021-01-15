## 1 保护操作系统（5）（harib19a）


## 2 帮助发现bug（harib19b）

栈异常的中断号为0x0c

add _asm_inthandler0c and _inthandler0c()

注册IDT


产生异常时寄存器值:
```
esp[ 0] : EDI
esp[ 1] : ESI        esp[0～7]为_asm_inthandler中PUSHAD的结果
esp[ 2] : EBP
esp[ 4] : EBX
esp[ 5] : EDX
esp[ 6] : ECX
esp[ 7] : EAX
esp[ 8] : DS         esp[8～9]为_asm_inthandler中PUSH的结果
esp[ 9] : ES
esp[10] : 错误编号（基本上是0，显示出来也没什么意思）
esp[11] : EIP
esp[12] : CS         esp[10～15]为异常产生时CPU自动PUSH的结果
esp[13] : EFLAGS
esp[14] : ESP （应用程序用ESP）
esp[15] : SS  （应用程序用SS）
```

## 3 强制结束应用程序（harib19c）

强制结束键我们就定义为“Shift+F1”

当按下强制结束键时，改写命令行窗口任务的的寄存器值，并goto到asm_end_app。这样一来程序会被强制结束，但也有个问题，那就是当应用程序没有在运行的时候，按下强制结束键会发生误操作。这样可不行，必须要确认task_cons -> tss.ss0不为0时才能继续进行处理。为此，我们还得进行一些修改，使得当应用程序运行时，该值一定不为0；而当应用程序没有运行时，该值一定为0。


## 4 用C语言显示字符串（1）（harib19d）


## 5 用C语言显示字符串（2）（harib19e）

hrb file
```
0x0000 (DWORD)  请求操作系统为应用程序准备的数据段的大小
0x0004 (DWORD)  “Hari”（.hrb文件的标记）
0x0008 (DWORD)  数据段内预备空间的大小
0x000c (DWORD)  ESP初始值&数据部分传送目的地址
0x0010 (DWORD)  hrb文件内数据部分的大小
0x0014 (DWORD)  hrb文件内数据部分从哪里开始
0x0018 (DWORD)  0xe9000000
0x001c (DWORD)  应用程序运行入口地址 -0x20
0x0020 (DWORD)  malloc空间的起始地址
```
Add hrb file support in console.c


## 6 显示窗口（harib19f）
```
EDX = 5
EBX = 窗口缓冲区
ESI = 窗口在x轴方向上的大小（即窗口宽度）
EDI = 窗口在y轴方向上的大小（即窗口高度）
EAX = 透明色ECX = 窗口名称调用后，返

回值如下：
EAX =用于操作窗口的句柄（用于刷新窗口等操作）
```
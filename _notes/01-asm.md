
## DB, DW, DD
DB指令是“define byte”的缩写，也就是往文件里直接写入1个字节的指令。大写和小写的“db”一样。
只要有了DB指令，我们就可以用它做出任何数据（甚至是程序

还可以定义字符串
```
  DB "Hello"
```
汇编器会自动地查找字符串中每一个字符所对应的编码，然后把它们一个字节一个字节地排列起来。


## RESB
RESB指令是“reserve byte”的略写，从当前地址开始空出N个字节来，并在空出来的地址上自动填入0x00。


## ORG
这个指令会告诉nask，在开始执行的时候，把这些机器语言指令装载到内存中的哪个地址



## Register
AX——accumulator，累加寄存器

CX——counter，计数寄存器

DX——data，数据寄存器

BX——base，基址寄存器

SP——stack pointer，栈指针寄存器

BP——base pointer，基址指针寄存器

SI——source index，源变址寄存器

DI——destination index，目的变址寄存器

ES——附加段寄存器（extra segment）

CS——代码段寄存器（code segment）

SS——栈段寄存器（stack segment）

DS——数据段寄存器（data segment）

FS——没有名称（segment part 2）

GS——没有名称（segment part 3）


可以用寄存器来指定内存地址的寄存器只有BX、BP、SI、DI这几个。剩下的AX、CX、DX、SP不能用来指定内存地址，这是因为CPU没有处理这种指令的电路
```
  MOV AL, BYTE [BX]
```

不管我们要指定内存的什么地址，都必须同时指定段寄存器，这是规定。
一般如果省略的话就会把“DS:”作为默认的段寄存器。以前我们用的“MOV CX, [1234]”，其实是“MOV CX, [DS:1234]”的意思。“MOV AL, [SI]”，也就是“MOV AL, [DS:SI]”的意思。


## JMP, JC
JC，是“jump if carry”的缩写，意思是如果进位标志（carry flag）是1的话，就跳转




## EFLAGS
这是由名为FLAGS的16位寄存器扩展而来的32位寄存器。
FLAGS是存储进位标志和中断标志等标志的寄存器。
进位标志(进位标志是EFLAGS的第0位)可以通过JC或JNC等跳转指令来简单地判断到底是0还是1。
但对于中断标志，没有类似的JI或JNI命令，所以只能读入EFLAGS，再检查第9位是0还是1。
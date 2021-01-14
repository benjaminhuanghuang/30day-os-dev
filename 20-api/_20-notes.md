## 1 程序整理（harib17a）

file.c

console.c


## 2 显示单个字符的API（1）（harib17b）

做一个测试用的应用程序，将要显示的字符编码存入AL寄存器，然后调用操作系统的函数，字符就显示出来了
```
[BITS 32]
  MOV      AL, 'A'
  CALL    （cons_putchar的地址）
fin:
  HLT
  JMP      fin
```
hlt.nas这个应用程序在汇编时并不包含操作系统本身的代码，因此汇编器无法得知要调用的函数地址，汇编就会出错。要解决这个问题，必须人工查好地址后直接写到代码中

cons_putchar是用C语言写的函数，即便我们将字符编码存入寄存器，函数也无法接收，因此我们必须在CALL之前将文字编码推入`栈`才行
因此要改写naskfunc.nas。
```
_asm_cons_putchar:
        PUSH     1
        AND      EAX,0xff     ; 将AH和EAX的高位置0，将EAX置为已存入字符编码的状态
        PUSH     EAX
        PUSH    （cons的地址）
        CALL     _cons_putchar
        ADD      ESP,12       ; 将栈中的数据丢弃
        RET
```


另一方面，在应用程序中，我们CALL的地址不再是cons_putchar，而是变成了新写的_asm_cons_putchar。

_asm_cons_putchar的地址在bootpack.map中


## 3 显示单个字符的API（2）（harib17c）


## 4 结束应用程序（harib17d）
这个问题是由于_asm_cons_putchar的RET指令所造成的。普通的RET指令是用于普通的CALL的返回，而不能用于far-CALL的返回，既然我们用了far-CALL，就必须相应地使用far-RET，也就是RETF指令


## 5 不随操作系统版本而改变的API（harib17e）

CPU中有个专门用来注册函数的地方，也许大家一下子想不起来，笔者说的其实是中断处理程序。

在前面我们曾经做过“当发生IRQ-1的时候调用这个函数”这样的设置，大家还记得吗？这是在IDT中设置的。反正IRQ只有0～15，而CPU用于通知异常状态的中断最多也只有32种，这些都在CPU规格说明书中有明确记载。不过，IDT中却最多可以设置256个函数，因此还剩下很多没有使用的项。

我们的操作系统从这些项里面借用一个的话，CPU应该也不会有什么意见的吧。所以我们就从IDT中找一个空闲的项来用一下。好，我们就选0x40号（其实0x30～0xff都是空闲的，只要在这个范围内任意一个都可以），并将_asm_cons_putchar注册在这里。

```
	set_gatedesc(idt + 0x40, (int) asm_cons_putchar, 2 * 8, AR_INTGATE32);
```
```
void farjmp(int eip, int cs);
void farcall(int eip, int cs);
void asm_cons_putchar(void);
```
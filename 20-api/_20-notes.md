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
序对API执行CALL的时候，千万不能忘记加上段号。应用程序所在的段为“1003 * 8”，而操作系统所在的段为“2 * 8”，因此我们不能使用普通的CALL，而应该使用far-CALL。


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

## 6 为应用程序自由命名（harib17f）

update cons_runcmd in console.c

add cmd_app()


## 7 当心寄存器（harib17g）
Use register in hello.nas

给_asm_cons_putchar添上PUSHAD和POPAD。


## 8 用API显示字符串（harib17h）
显示字符串的API有两种方式：
一种是显示一串字符，遇到字符编码0则结束；
另一种是先指定好要显示的字符串的长度再显示
```
void cons_putstr0(struct CONSOLE *cons, char *s);
void cons_putstr1(struct CONSOLE *cons, char *s, int l);
```
use cons_putstr0 in console.c

最简单的方法就是像显示单个字符的API那样，分配INT 0x41和INT 0x42来调用这两个函数。不过这样一来，只能设置256个项目的IDT很快就会被用光。
```
void hrb_api(int edi, int esi, int ebp, int esp, int ebx, int edx, int ecx, int eax)
{
	struct CONSOLE *cons = (struct CONSOLE *) *((int *) 0x0fec);
	if (edx == 1) {
		cons_putchar(cons, eax & 0xff, 1);
	} else if (edx == 2) {
		cons_putstr0(cons, (char *) ebx);
	} else if (edx == 3) {
		cons_putstr1(cons, (char *) ebx, ecx);
	}
	return;
}
```

鉴BIOS的调用方式，在寄存器中存入功能号，使得只用1个INT就可以选择调用不同的函数。
在BIOS中，用来存放功能号的寄存器一般是AH，我们也可以照搬，但这样最多只能设置256个API函数。而如果我们改用EDX来存放功能号，
```
功能号1……显示单个字符（AL = 字符编码）
功能号2……显示字符串0（EBX = 字符串地址）
功能号3……显示字符串1（EBX = 字符串地址，ECX = 字符串长度）
```
还得改一下IDT的设置，将INT 0x40改为调用_asm_hrb_api。


Update naskfunc.nas
```
  GLOBAL	_asm_hrb_api
  EXTERN	_hrb_api
```


显示单个字符时，我们用[CS:ECX]的方式特意指定了CS（代码段寄存器），因此可以成功读取msg的内容。但在显示字符串时，由于无法指定段地址，程序误以为是DS而从完全错误的内存地址中读取了内容，碰巧读出的内容是0，于是就什么都没有显示出来。

hrb_api并不知道代码段的起始位置位于内存的哪个地址，但cmd_app应该知道，因为当初设置这个代码段的正是cmd_app。由于我们没有办法从cmd_app向hrb_api直接传递数据，因此只好又在内存里找个地方存放一下了。0xfec这个位置之前已经用过了，这次我们放在它前面的0xfe8好了。


## 1 攻克难题——字符串显示API（harib18a）

显示单个字符时，我们用[CS:ECX]的方式特意指定了CS（代码段寄存器），因此可以成功读取msg的内容。但在显示字符串时，由于无法指定段地址，程序误以为是DS而从完全错误的内存地址中读取了内容，碰巧读出的内容是0，于是就什么都没有显示出来。

hrb_api并不知道代码段的起始位置位于内存的哪个地址，但cmd_app应该知道，因为当初设置这个代码段的正是cmd_app。由于我们没有办法从cmd_app向hrb_api直接传递数据，因此只好又在内存里找个地方存放一下了。0xfec这个位置之前已经用过了，这次我们放在它前面的0xfe8了。


## 2 用C语言编写应用程序（harib18b）
```
void api_putchar(int c);

void HariMain(void)
{
	api_putchar('A');
	return;
}
```
要实现C语言编写应用程序，需要在应用程序方面创建一个api_putchar函数。注意，这个函数不是创建在操作系统中。api_putchar函数的功能是向EDX和AL赋值，并调用INT 0x40。
```
	GLOBAL	_api_putchar

[SECTION .text]

_api_putchar:	; void api_putchar(int c);
		MOV		EDX,1
		MOV		AL,[ESP+4]		; c
		INT		0x40
		RET
```

在asmhead.nas中，最后调用bootpack.hrb的时候有这样一句：
```
JMP DWORD 2＊8:0x0000001b
```

也就是先调用0x1b这个地址的函数，从函数返回后再执行far-RET，仅此而已。这里的0x1b，其实就是
```
[BITS 32]
        CALL     0x1b
        RETF
```
需要把hrb文件的开头的6个字节替换成“E8 16 00 00 00 CB”

凡是通过bim2hrb生成的hrb文件，其第4～7字节一定为“Hari”，因此程序通过判断第4～7字节的内容，将读取的数据先进行修改之后再运行。

make file
```
a.bim : a.obj a_nask.obj Makefile
    $(OBJ2BIM) @$(RULEFILE) out:a.bim map:a.map a.obj a_nask.obj

a.hrb : a.bim Makefile
    $(BIM2HRB) a.bim a.hrb 0
```


## 3 保护操作系统（1）（harib18c）
```
void HariMain(void)
{
    ＊((char ＊) 0x00102600) = 0;
    return;
}
```

## 4 保护操作系统（2）（harib18d）

crack app 擅自访问了本该由操作系统来管理的内存空间。

需要为应用程序提供专用的内存空间，并且告诉它们“别的地方不许碰哦”。
要做到这一点，我们可以创建应用程序专用的数据段，并在应用程序运行期间，将DS和SS指向该段地址。
操作系统用代码段……2 ＊ 8
操作系统用数据段……1 ＊ 8
应用程序用代码段……1003 ＊ 8
应用程序用数据段……1004 ＊ 8
（3 ＊ 8～1002 ＊ 8为TSS所使用的段）

update cmd_app()

add asm function
```
	void start_app(int eip, int cs, int esp, int ds);
```

## 5 对异常的支持（harib18e）
要想强制结束程序，只要在中断号0x0d中注册一个函数即可，这是因为在x86架构规范中，当应用程序试图破坏操作系统，或者试图违背操作系统的设置时，就会自动产生0x0d中断，因此该中断也被称为“异常”。

create _asm_inthandler0d

将_asm_inthandler0d注册到IDT中

## 6 保护操作系统（3）（harib18f）

如果忽略操作系统指定的DS，而是用汇编语言直接将操作系统用的段地址存入DS的话，就又可以干坏事了
```
[INSTRSET "i486p"]
[BITS 32]
        MOV      EAX,1＊8          ; OS用的段号
        MOV      DS, AX             ; 将其存入DS
        MOV      BYTE [0x102600],0
        RETF
```

## 7 保护操作系统（4）（harib18g）

在段定义的地方，如果将访问权限加上0x60的话，就可以将段设置为应用程序用。
当CS中的段地址为应用程序用段地址时，CPU会认为“当前正在运行应用程序”，这时如果存入操作系统用的段地址就会产生异常。

Change cmd_app
```
	struct TASK *task = task_now();
	set_segmdesc(gdt + 1003, finfo->size - 1, (int) p, AR_CODE32_ER + 0x60);
	set_segmdesc(gdt + 1004, 64 * 1024 - 1,   (int) q, AR_DATA32_RW + 0x60);
		...
	start_app(0, 1003 * 8, 64 * 1024, 1004 * 8, &(task->tss.esp0));

```
change naskfunc.nas
```
	_start_app:		; void start_app(int eip, int cs, int esp, int ds, int *tss_esp0);
```

在启动应用程序的时候我们需要让“操作系统向应用程序用的段执行far-CALL”，但根据x86的规则，是不允许操作系统CALL应用程序的（如果强行CALL的话会产生异常）。可能有人会想如果CALL不行的话JMP总可以吧，但在x86中“操作系统向应用程序用的段进行far-JMP”也是被禁止的。

之前我们一直讲RETF是当far-CALL调用后进行返回的指令，其实即便没有被CALL调用，也可以进行RETF。说穿了，RETF的本质就是从栈中将地址POP出来，然后JMP到该地址而已。因此正如这次我们所做的一样，可以用RETF来代替far-JMP的功能。

修改一下IDT的设置。在我们已经清晰地区分操作系统段和应用程序段的情况下，当应用程序试图调用未经操作系统授权的中断时，CPU会认为“这家伙乱用奇怪的中断号，想把操作系统搞坏，是坏人”，并产生异常。因此，我们需要在IDT中将INT 0x40设置为“可供应用程序作为API来调用的中断”。


应用程序也需要修改一下，因为已经不能通过RETF来结束程序了


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

make file
```
a.bim : a.obj a_nask.obj Makefile
    $(OBJ2BIM) @$(RULEFILE) out:a.bim map:a.map a.obj a_nask.obj

a.hrb : a.bim Makefile
    $(BIM2HRB) a.bim a.hrb 0
```
凡是通过bim2hrb生成的hrb文件，其第4～7字节一定为“Hari”，因此程序通过判断第4～7字节的内容，将读取的数据先进行修改之后再运行。这样一来，不需要用二进制编辑器手工修改，程序应该也可以正常运行了


## 
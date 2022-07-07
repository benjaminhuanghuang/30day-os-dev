## Use C language
从本节开始，
os 分成 ASM 和 C语言两部分编写的。
ASM 部分为 asmhead.asm
C 语言部分文件名是bootpack.c。以后为了启动操作系统，还要写各种其他的处理，我们想要把这些处理打成一个包（pack）

函数名HariMain非常重要，程序就是从以HariMain命名的函数开始运行的，所以这个函数名不能更改。

C 代码处理
1. 使用cc1.exe从bootpack.c生成bootpack.gas。
2. 使用gas2nask.exe从bootpack.gas生成bootpack.nas。
3. 使用nask.exe从bootpack.nas生成bootpack.obj。
4. 使用obi2bim.exe从bootpack.obj生成bootpack.bim。
5. 使用bim2hrb.exe从bootpack.bim生成bootpack.hrb。 这样就做成了机器语言，再使用copy指令将asmhead.bin与bootpack.hrb单纯结合到起来，就成了haribote.sys。

`c1`是C编译器，可以将C语言程序编译成汇编语言源程序。但这个C编译器是笔者从名为gcc的编译器改造而来，而gcc又是以gas汇编语言为基础，输出的是gas用的源程序

所以我们需要把gas变换成nask能翻译的语法，这就是`gas2nask`.

一旦转换成nas文件，要用`nask`生成 obj file， 目标文件是一种特殊的机器语言文件，必须与其他文件链接（link）后才能变成真正可以执行的机器语言。

将必要的目标文件全部链接上，需要使用`obj2bim`。bim是笔者设计的一种文件格式，意思是“binary image”，它是一个二进制映像文件。bim文件也“不是本来的状态，而是一种代替的形式”，也还不是完成品。这只是将各个部分全部都链接在一起，做成了一个完整的机器语言文件，

而为了能实际使用，还需要针对每一个**不同操作系统的要求进行必要的加工**，比如说加上识别用的文件头，或者压缩等。笔者为此专门写了一个程序bim2hrb.exe


## Link C code with ASM code
naskfunc.nas

用汇编写的函数，之后还要与bootpack.obj链接，所以也需要编译成目标文件。因此将输出格式设定为WCOFF模式。另外，还要设定成32位机器语言模式。

在nask目标文件的模式下，必须设定文件名信息，然后再写明下面程序的函数名。注意要在函数名的前面加上“_”，否则就不能很好地与C语言函数链接。

需要链接的函数名，都要用GLOBAL指令声明。下面写一个实际的函数。写起来很简单，先写一个与用GLOBAL声明的函数名相同的标号（label），
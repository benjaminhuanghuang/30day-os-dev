# Toolset
这本书的例子必须使用作者提供的toolset

作者在(http://hrb.osask.jp/)提供了 windows， linux， macos下的tool set

在开发操作系统时，需要用到CPU上的许多控制操作系统的寄存器。一般的C编译器都是用于开发应用程序的，所以根本没有任何操作这些寄存器的命令。
另外，C编译器还的自动优化功能，有时候会给带来麻烦。

asm + c 的混合编译在不同的环境下会出问题

## 汇编器 nask
nask 很多语法都模仿了NASM

```
  nask helloos.nas helloos.img
```

## Tools for C language
`c1`是C编译器，可以将C语言程序编译成汇编语言源程序。但这个C编译器是笔者从名为gcc的编译器改造而来，而gcc又是以gas汇编语言为基础，输出的是gas用的源程序

所以我们需要把gas变换成nask能翻译的语法，这就是`gas2nask`.

一旦转换成nas文件，要用`nask`生成 obj file， 目标文件是一种特殊的机器语言文件，必须与其他文件链接（link）后才能变成真正可以执行的机器语言。

将必要的目标文件全部链接上，需要使用`obj2bim`。bim是笔者设计的一种文件格式，意思是“binary image”，它是一个二进制映像文件。bim文件也“不是本来的状态，而是一种代替的形式”，也还不是完成品。这只是将各个部分全部都链接在一起，做成了一个完整的机器语言文件，

而为了能实际使用，还需要针对每一个**不同操作系统的要求进行必要的加工**，比如说加上识别用的文件头，或者压缩等。作者为此专门写了一个程序bim2hrb.exe







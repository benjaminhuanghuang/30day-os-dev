# Toolset
作者在(http://hrb.osask.jp/)提供了 windows， linux， macos下的tool set



在开发操作系统时，需要用到CPU上的许多控制操作系统的寄存器。一般的C编译器都是用于开发应用程序的，所以根本没有任何操作这些寄存器的命令。
另外，C编译器还的自动优化功能，有时候会给带来麻烦。



asm + c 的混合编译在不同的环境下会出问题


## 汇编器 nask
nask 很多语法都模仿了NASM

```
  nask helloos.nas helloos.img
```


## 用ASM 写 initial program loader（IPL）

在asm代码直接包含了FAT12文件系统信息

计算机读写软盘的时候，并不是一个字节一个字节地读写的，而是以512字节为一个单位进行读写。因此，软盘的512字节就称为一个扇区。
一张软盘的空间共有1440KB，也就是1474560字节，除以512得2880，这也就是说一张软盘共有2880个扇区。

如果第一个扇区最后2个字最后两个字节正好是0x55 AA，那它就认为这个扇区的开头是启动程序，并开始执行这个程序。

业界标准规定 boot section 的512 字节要被加载到内存的  0x7c00 ~ 0x7dff

这就是汇编代码 `ORG    0x7C00` 的原因

Complie the boot.nas
```
  z_tools\nask.exe ipl.nas ipl.bin ipl.lst
```
列表文件ipl.lst是一个文本文件，可以用来简单地确认每个指令是怎样翻译成机器语言的。


## 寻址
MOV AL, [ES:BX]    ; ES*16+BX  
Address is 2^20 = 1M

DS is the default Segment Register
MOV CX,[1234]  
equals to 
MOV CX,[DS:1234]  





## Use sprintf
https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02g

这个sprintf是作者使用的c编译器自带的函数
sprintf的特点是只操作内存，不依靠任何操作系统，因此可以在任何平台运行
因此必须使用作者提供的Toolset(hrb.osask.jp)



## Mouse 
https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02h



## GDT & IDT
https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02i


需要注意的一点是，我们用16位的时候曾经讲解过的段寄存器。这里的分段，使用的就是这个段寄存器。但是16位的时候，如果计算地址，只要将地址乘以16就可以了。但现在已经是32位了，不能再这么用了。如果写成“MOV AL, [DS:EBX]”,CPU会往EBX里加上某个值来计算地址，这个值不是DS的16倍，而是DS所表示的段的起始地址。即使省略段寄存器（segment register）的地址，也会自动认为是指定了DS。这个规则不管是16位模式还是32位模式，都是一样的。

调色板中，色号可以使用0～255的数。段号可以用0～8191的数。因为段寄存器是16位，所以本来应该能够处理0～65535范围的数，但由于CPU设计上的原因，段寄存器的低3位不能使用。因此能够使用的段号只有13位，能够处理的就只有位于0～8191的区域了



GDT是“global（segment）descriptor table”的缩写，意思是全局段号记录表。将这些数据整齐地排列在内存的某个地方，然后将内存的起始地址和有效设定个数放在CPU内被称作GDTR的特殊寄存器中，设定就完成了。

这是一个很特别的48位寄存器，并不能用我们常用的MOV指令来赋值。
给它赋值的时候，唯一的方法就是指定一个内存地址，从指定的地址读取6个字节（也就是48位），
然后赋值给GDTR寄存器。完成这一任务的指令，就是LGDT。
该寄存器的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。
剩下的高32位（即剩余的4个字节），代表GDT的开始地址。


另外，IDT是“interrupt descriptor table”的缩写，直译过来就是“中断记录表”。当CPU遇到外部状况变化，或者是内部偶然发生某些错误时，会临时切换过去处理这种突发事件。这就是中断功能。

IDT记录了0～255的中断号码与调用函数的对应关系，比如说发生了123号中断，就调用〇×函数，其设定方法与GDT很相似


CPU到底是处于系统模式还是应用模式，取决于执行中的应用程序是位于访问权为0x9a的段，还是位于访问权为0xfa的段。
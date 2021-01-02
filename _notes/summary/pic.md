# PIC(programmable interrupt controller)

CPU单独只能处理一个中断，这不够用

PIC是将8个中断信号集合成一个中断信号的装置。PIC监视着输入管脚的8个中断信号，只要有一个中断信号进来，就将唯一的输出管脚信号变成ON，并通知给CPU。

与CPU直接相连的PIC称为主PIC（master PIC），与主PIC相连的PIC称为从PIC（slave PIC）。
主PIC负责处理第0到第7号中断信号，从PIC负责处理第8到第15号中断信号
另外，从PIC通过第2号IRQ与主PIC相连。

从CPU的角度来看，PIC是外部设备，CPU使用OUT指令进行操作

IMR(interrupt mask register)。8位分别对应8路IRQ信号。如果某一位的值是1，则该位所对应的IRQ信号被屏蔽，PIC就忽视该路信号


鼠标是IRQ12，键盘是IRQ1

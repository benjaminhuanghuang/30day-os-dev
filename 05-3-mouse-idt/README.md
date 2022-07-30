# Day 5 - 3 处理 Mouse 中断

移动mouse需要处理中断
https://gitee.com/paud/30daysOS/tree/master/projects/05_day/harib02i

中断需要 IDT

设置IDT 要先设置 GDT(global（segment）descriptor table) 

harib02i


CPU到底是处于系统模式还是应用模式，取决于执行中的应用程序是位于访问权为0x9a的段，还是位于访问权为0xfa的段。

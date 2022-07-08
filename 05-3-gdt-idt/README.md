# Day 5 - 3

## Move mouse (GDT Global Descriptor Table and LDT Local Descriptor Table)
p101

## 16位寻址
Intel在8086 CPU中设置了四个段寄存器：CS、DS、SS和ES，分别用于可执行代码段、数据段、堆栈段及其他段

```
MOV AL, [DS:EBX]
```
DS 表示段的起始地址


段寄信息(8 bytes)
- 段大小
- 段起始地址
- 段访问权限

段寄存器 (16 bytes, 只能用高13位), 因此段号的取值范围是 0~ 8189



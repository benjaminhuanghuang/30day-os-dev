## Read Floppy Disk: INT 0x13
对于 Floppy Disk
每个盘   80  磁道(柱面) (0 ~ 79)
每个柱面 18  扇区       (0 ~ 17)
每个扇区 512 bytes

```
mov CH, 1    ; CH 用来存储柱面号
mov DH, 0    ; DH 用来存储磁头号
mov CL, 2    ; CL 用来存储扇区号

mov BX, msg  ; ES:BX 数据存储缓冲区

mov AH, 0x02 ; AH = 02 表示要做的是read操作
mov AL, 1    ; AL 表示要练习读取几个扇区
mov DL, 0    ; 驱动器编号，一般我们只有一个软盘驱动器，所以写死为0
INT 0x13     ; 调用BIOS中断实现磁盘读取功能
JC error     ; 如果读盘出现错误， FLGCSS 寄存器 CF 会为 1， JC当CF为1时跳转到error处执行相应代码
```



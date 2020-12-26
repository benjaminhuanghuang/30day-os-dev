
## Print 
```
  MOV    SI, msg
  
putloop:
  MOV    AL,[SI]
  ADD    SI,1        ; 给SI加1
  CMP    AL,0

  JE    fin
  MOV    AH,0x0e      ; 显示一个文字
  MOV    BX,15        ; 指定字符颜色
  INT    0x10         ; 调用显卡BIOS
  JMP    putloop
fin:
  
```

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

## Set video mode INT 10

```
AH=0x00
AL=模式（省略了一些不重要的画面模式）
  0x03:16色字符模式，80× 25
  0x12:VGA图形模式，640× 480× 4位彩色模式，独特的4面存储模式
  0x13:VGA图形模式，320× 200× 8位彩色模式，调色板模式
  0x6a：扩展VGA图形模式，800× 600× 4位彩色模式，独特的4面存储模式（有的显卡不支持这个模式）
  
返回值：无
```
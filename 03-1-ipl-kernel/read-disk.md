## 加载更多的扇区
1张软盘有80个柱面(Cylinder)，2个磁头(Head)，18个扇区(Sector)，且一个扇区有512字节。所以，一张软盘的容量是：

80×2×18×512 = 1474560 Byte = 1440KB

含有IPL的启动区，位于C0-H0-S1（柱面0，磁头0，扇区1的缩写）


## BIOS 0x13
- http://community.osdev.info/? (AT)BIOS

- https://en.wikipedia.org/wiki/INT_13H

```
  AH=0x02;（读盘）
  AH=0x03;（写盘）
  AH=0x04;（校验）
  AH=0x0c;（寻道）
  
  
  AL=处理对象的扇区数；（只能同时处理连续的扇区）
  CH=柱面号 &0xff；
  CL=扇区号（0-5位）|（柱面号&0x300）>>2；
  DH=磁头号；
  DL=驱动器号；
  ES:BX=缓冲地址；(校验及寻道时不使用)
  
  
  返回值：
  FLACS.CF==0：没有错误，AH==0
  FLAGS.CF==1：有错误，错误号码存入AH内（与重置（reset）功能一样）
```

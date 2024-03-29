# IPL(Initial Program Loader) vs kernle

## 本节目标
读取 floppy disk上最初的`10`个柱面 到 地址 ES: BX

1张软盘有80个柱面(Cylinder), 2个磁头(Head)，18个扇区(Sector), 且一个扇区有512字节. 

IPL 位于 C0-H0-S1, 下一个扇区是C0-H0-S2
IPL 会把磁盘上C0-H0-S2到C0-H0-S18的512×17=8704字节的内容，装载到了内存的0x8200～0xa3ff处
C0-H0-S18 的下一个扇区是 C0-H1-S1, 一直读到C9-H1-S18

最终floppy disk上最初的10个柱面: 10 * 2 * 18 * 512 = 184320 bytes = 180K 被加载到内存`0x8200～0x34fff`处

代码见
harib00c
harib00d

## 如何读取N个扇区
理论上在调用BIOS INT 0x13时, 只要将AL(读取扇区数)的值设置成 N 就能将读取 N个扇区的数据。
但实践上使用loop 来读取 N 个扇区

因为笔者注意到了磁盘BIOS读盘函数说明的“补充说明”部分：
指定处理的扇区数(AL)，范围在0x01～0xff 指定0x02以上的数值时，要特别注意能够连续处理多个扇区的条件。如果是FD的话，似乎`不能跨越多个磁道(Cylinder)，也不能超过64KB的界限`。

读取的地址为 ES: BX
要读下一个扇区(512 bytes = 0x200 bytes), 需要给CL 加 1, 给ES 加 0x20


## 是否依赖文件系统
让 loader 加载 kernel有两种做法

1. 不依赖FAT12文件系统
ipl.asm 不包含 FAT 12 文件信息，用工具把 ipl.bin写入第一个sector，并在0x510处写上0x55AA，把第一个sector标记为启动扇区。
然后把 kernel.bin 写入第2扇区

loader启动后会把kernel加载到0x8000，然后Jump 到 0x8000

- [用java做操作系统内核：软盘读写](https://blog.csdn.net/tyler_download/article/details/51815483)
- [](https://www.bilibili.com/video/BV1hJ411n7rs?p=3)


- [java开发操作系统内核：让内核突破512字节的限制](https://blog.csdn.net/tyler_download/article/details/51970921)



2. 使用FAT12，《30天自制操作系统》day 3使用这种方法， 这种方法易于管理文件
代码见 harib00e

ipl.asm 包含 FAT12信息以及 0x55AA 标记，用 dd 命令把ipl.bin写入第一个sector

P55: 向一个空floppy disk写入文件时，文件名会出现在磁盘`0x2600`, 文件内容会出现在磁盘`0x4200`.

根目录区从19扇区开始，每个扇区512bytes，因此根目录下第一个文件的目录信息开始于19*512 = 0x2600

数据区开始扇区号 = 根目录开始扇区号+ 目录所占区号 = 19 + 14 = 33


把haribote.sys(kernel)作为文件copy到disk的文件系统中
```
haribote.img : ipl.bin haribote.sys Makefile
	$(EDIMG)   imgin:../../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0  \
		copy from:haribote.sys to:@: \
		imgout:haribote.img
```


https://superuser.com/questions/868117/layouting-a-disk-image-and-copying-files-into-it

Ubuntu 上的做法如下: (!这种做法不能正常工作, 原因待查!!!!)
```
  sudo mount -t vfat -o loop myos.img ~/temp/mnt
	sudo mcopy kernel.bin ~/temp/mnt
	sudo umount ~/temp/mnt
```


3. 折衷方案
根据 FAT的定义, 磁盘的数据区起始于33 扇区,  因此 把 kerenl 文件 用 dd 复制到第 33 扇区
```
  dd if=kernel.bin of=myos.img seek=33 bs=512 conv=notrunc
``` 


## 加载到内存什么位置

第一个文件的起始位置在 512 * 33 = 0x4200

因为loader会把disk上从C0-H0-S2开始到C0-H0-S18的内容加载到0x8200，

所以kernel(位于磁盘0x4200)会被加载到内存(0x8200-0x200)+0x4200 = 0xc200的位置。

因此kernel.asm中 org 应为 0xc2000， loader中最后要jmp到0xc2000 开始执行






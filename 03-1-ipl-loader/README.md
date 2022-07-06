# IPL(Initial Program Loader) vs kernle

1张软盘有80个柱面，2个磁头，18个扇区，且一个扇区有512字节。 IPL 位于 C0-H0-S1, 下一个扇区是C0-H0-S2

ipl会把磁盘上C0-H0-S2到C0-H0-S18的512×17=8704字节的内容，装载到了内存的0x8200～0xa3ff处
C0-H0-S18 的下一个扇区是 C0-H1-S1

最终floppy disk的 10 * 2 * 18 * 512 = 184320 bytes = 180K 被加载到内存0x8200～0x34fff处

## 如何读取多个扇区
在调用BIOS INT 0x13的地方，只要将AL(读取扇区数)的值设置成17就行了。一下子就能将扇区2～18共17个扇区的数据完整地读进来。
之所以将这部分做成循环是因为笔者注意到了磁盘BIOS读盘函数说明的“补充说明”部分：
指定处理的扇区数(AL)，范围在0x01～0xff 指定0x02以上的数值时，要特别注意能够连续处理多个扇区的条件。如果是FD的话，似乎不能跨越多个磁道，也不能超过64KB的界限。
因此使用loop 来读取 17个扇区





让 loader 加载 kernel有两种做法

1. 不依赖FAT12文件系统
loader.asm 不包含 FAT 12 文件信息，用 java app 把 loader.bin写入第一个sector，
并在0x510处写上0x55AA，把第一个sector标记为启动扇区。
loader启动后会把kernel加载到0x8000，然后执行

kernel.asm中程序运行的地址为org   0x8000，用java app 把 kernel.bin写入第2扇区

- [用java做操作系统内核：软盘读写](https://blog.csdn.net/tyler_download/article/details/51815483)
- [](https://www.bilibili.com/video/BV1hJ411n7rs?p=3)


- [java开发操作系统内核：让内核突破512字节的限制](https://blog.csdn.net/tyler_download/article/details/51970921)



2. 使用FAT12，《30天自制操作系统》day 3使用这种方法， 这种方法易于管理文件

FAT12对引导扇区的格式有规定
![](./_images/fat12-boot.png)

loader.asm 包含 FAT12信息以及 0x55AA 标记，用 dd 命令把loader.bin写入第一个sector
把kernel.bin作为文件copy到disk的文件系统中
P55: 向一个空floppy disk写入文件时，文件名会出现在磁盘0x2600
文件内容会出现在磁盘0x4200.

因为根目录区从19扇区开始，每个扇区512bytes，因此根目录下第一个文件的目录信息开始于19*512 = 0x2600
数据区开始扇区号 = 根目录开始扇区号+ 目录所占区号 = 19 + 14 = 33
第一个文件的起始位置在 512 * 33 = 0x4200

因为loader会把disk上从C0-H0-S2开始到C0-H0-S18的内容加载到0x8200，

C0-H0-S1启动扇区会被加载到0x8000
所以磁盘0x4200的内容会被加载到内存0x8000+0x4200 = 0xc200的位置。
因此kernel.asm中 org 应为 0xc2000， loader中最后要jmp到0xc2000 开始执行






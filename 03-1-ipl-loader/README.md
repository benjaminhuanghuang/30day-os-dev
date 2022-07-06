# IPL(Initial Program Loader) vs kernle

- loader.bin
位于 Cylinder 0 - Head 0 - Sector1
load kernel from sector 2 to 0x8000 and execute.

- kernel.bin
位于 Cylinder 0 - Head 0 - Sector2

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

因为loader会把disk上从C0-H0-S2开始到内容加载到0x8200，C0-H0-S1启动扇区会被加载到0x8000
所以磁盘0x4200的内容会被加载到内存0x8000+0x4200 = 0xc200的位置。
因此kernel.asm中 org 应为 0xc2000， loader中最后要jmp到0xc2000 开始执行





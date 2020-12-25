一开始要写一个“只要一通电就能运行的程序”。这部分用C语言写起来有些困难，所以主要还是用汇编语言来写。

## 实验 1
用二进制Editor 编写一个 helloos.img (成品见 随书光盘中名为projects\01_day\helloos0)

0 ～ 000089，输入一些code

000090～168000 全是 0

0001FE 处为 55 AA F0 FF FF      1FF = 511, 1FE = 55, 1FF = AA,说明这是启动扇区 

001400 处为 F0 FF FF


16进制168000 = 10进制1474560 = 1440×1024字节, 这正好是一个floppy disk的大小

把这个helloos.imge 写入A盘就可以启动机器
```
  z_tools\imgtol.com w a: helloos.img
```

或者用 虚拟机软件 qemu 来加载这个img
```
  qemu-system-x86_64 -fda boot.bin -boot a
``` 
## 实验2: 用ASM 写 initial program loader（IPL）

在asm代码直接包含了FAT12文件系统信息

![](./_images/fat12.png)

![](./_images/fat12-boot.png)


因为根目录区从19扇区开始，每个扇区512bytes，因此根目录下第一个文件的目录信息开始于19*512 = 0x2600

数据区开始扇区号 = 根目录开始扇区号+ 目录所占区号 = 19 + 14 = 33

第一个文件的起始位置在 512 * 33 = 0x4200

计算机读写软盘的时候，并不是一个字节一个字节地读写的，而是以512字节为一个单位进行读写。因此，软盘的512字节就称为一个扇区。
一张软盘的空间共有1440KB，也就是1474560字节，除以512得2880，这也就是说一张软盘共有2880个扇区。

如果第一个扇区最后2个字最后两个字节正好是0x55 AA，那它就认为这个扇区的开头是启动程序，并开始执行这个程序。

业界标准规定 boot section 的512 字节要被加载到内存的  0x7c00 ~ 0x7dff

这就是汇编代码 `ORG    0x7C00` 的原因

Complie the boot.nas
```
  z_tools\nask.exe ipl.nas ipl.bin ipl.lst
```
列表文件ipl.lst是一个文本文件，可以用来简单地确认每个指令是怎样翻译成机器语言的。

## Method 1: Run the boot.bin using qemu
```
  qemu-system-x86_64 -fda boot.bin -boot a
```
-fda or -fdb 指定软盘
-hda/-hdb/-hdc/-hdd 指定硬盘
-cdrom 指定光盘
-boot 指定从哪个设备启动 a(软盘),c(硬盘),d(光盘),n(网络)


## Method 2: Run the boot.bin to an img file and run in virtual box as a floppy disk
- Use java app write the boot.bin into a img file, 

- Create a VM in virtual box and insert the img file as a floppy disk
vm settings -> storagte -> add Floppy and insert image file


## Method 3: Write boot.bin to USB disk, and run it
```
sudo diskutil unmountDisk /dev/disk2
sudo dd if=ipl.bin of=/dev/disk2 # 将软盘镜像写入u盘中

写好后重新插拔一次u盘
sudo diskutil unmountDisk /dev/disk2

sudo qemu-system-i386 -fda /dev/disk2 -boot a
```


## Check binary file format
```
xxd boot.bin | less

file boot.bin # 显示为：DOS floppy 1440k, x86 hard disk boot sector

qemu-img info boot.bin # 其对应的qemu镜像类型为raw
```
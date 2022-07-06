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
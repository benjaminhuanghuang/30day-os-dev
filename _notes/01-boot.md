
用java做一个最小的操作系统内核2.
https://blog.csdn.net/tyler_download/article/details/51761750

《30天自制操作系统》——虚拟机使用
https://blog.csdn.net/ekkie/article/details/51345149


##  Complie the boot.nas
```
  brew install nasm
  
  nasm -f bin boot.asm -o boot.bin -l boot.lst
```

## Method 2: Run the boot.bin using qemu
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
qemu 是一个硬件虚拟化程序( hypervisor that performs hardware virtualization)，VMware / VirtualBox 之类的虚拟机不同，
它可以通过 binary translation 模拟各种硬件平台（比如在 x86 机器上模拟 ARM 处理器）。
而 VirtualBox 等更多是通过虚拟化来进行资源隔离，以便在其上运行多个 guest os。

qemu 与 VirtualBox 另一个不同点在于，在 VirtualBox 上必须安装一个完整的操作系统套件，
而通过 qemu 可以通过参数直接启动到一个裸的 Linux Kernel，连 bootloader 都不需要关心。


## Install qemu（quick emulator）
MacOs 
```
  brew install qemu
```
Ubuntu
```
  apt-get install qemu
```

安装完成后，可以看到系统中有很多个 qemu-system-XXX 开头的命令，用于模拟各种硬件平台，比如 
```
qemu-system-x86_64 
```

## Run the boot.bin as a floppy disk using qemu
```
  qemu-system-x86_64 -fda boot.bin -boot a
```
-fda or -fdb 指定软盘
-hda/-hdb/-hdc/-hdd 指定硬盘
-cdrom 指定光盘
-boot 指定从哪个设备启动 a(软盘),c(硬盘),d(光盘),n(网络)


## Run the Linux kernel
```
  # 构建一个压缩过的内核镜像
  make bzImage      #  编译成功后，bzImage 文件将出现在 arch/x86_64/boot/bzImage。


  qemu-system-x86_64 \
    -m 512M \  # 指定内存大小
    -smp 4\  # 指定虚拟的 CPU 数量
    -kernel ./bzImage  # 指定内核文件路径
```

## Create and run vm
1. 创建虚拟机文件系统
```
qemu-img create /f qcow2 xxx.img 10G
```
2. 在虚拟机文件系统中安装操作系统
```
qemu-system-i386 -hda xxx.img -cdrom xxx.iso -boot d 以xxx.img为文件系统，xxx.iso是系统安装ISO文件
```
3. 运行安装好的操作系统
```
qemu-system-i386 -hda xxx.img 运行xxx.img中的系统
```

## Create floppy image
```
  qemu-img create -f raw myos.img 1440k
  
  qemu-img info myos.img
```

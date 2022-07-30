```
# Create a img file
qemu-img create -f raw myos.img 1440k

# create 1.44M img file
dd if=/dev/zero of=myos.img bs=512 count=2880


# Formats the disk image as FAT32
mkfs.vfat myos.img -F 32
```

Moidfy image

```
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc

  notrunc：不截短输出文件
```

Install img find using mtools on Ubuntu
```
	mformat -f 1440 -C -B boot.bin -i myos.img ::
	mcopy loader.bin -i myos.img ::
```
https://superuser.com/questions/868117/layouting-a-disk-image-and-copying-files-into-it
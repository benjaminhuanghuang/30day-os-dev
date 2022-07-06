# initial program load (IPL)
## 目标

1. 用汇编代码生成 512 bytes的boot section
2. 把这个 boot section 写入 image
3. 用qemu加载 image

重点在如何生成 boot image

## 原书
使用 edimg.exe 向 empty image fdimg0at.tek 写入ipl.bi, 生成 helloos.img
```
helloos.img : ipl.bin Makefile
	../z_tools/edimg.exe   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0   imgout:helloos.img
```

## 改进
Use `dd` command in Ubuntu environment.
```
	dd if=ipl.bin of=myos.img bs=512 count=1
```
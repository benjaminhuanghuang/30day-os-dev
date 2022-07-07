1. 编译 .c 文件， 生成 32-bit elf 格式的obj文件
```
  gcc -m32 -fno-pie -o bootpack.o -c bootpack.c
```
gcc在ubuntu 17.04上默认会生成-fpic代码，默认情况下会链接-fPIE, 要禁止这个选项

PIE能使程序像共享库一样在主存任何位置装载，这需要将程序编译成位置无关，并链接为ELF共享对象。
引入PIE的原因是让程序能装载在随机的地址，通常情况下，内核都在固定的地址运行，如果能改用位置无关，那攻击者就很难借助系统中的可执行码实施攻击了。

2. 编译 .asm 文件， 生成 32-bit elf 格式的obj文件
```
  nasm -f elf32 asmhead.asm -o asmhead.o -l asmhead.lst
```
注意, 对于 ipl.asm, 不需要link, 可以直接生成 bin 文件


3. 最关键的一步: link
```
  ld -m elf_i386 --oformat binary -T bootpack.ld asmhead.o bootpack.o asmfunc.o -o kernel.bin
```
原书中 使用 cat 命令吧 asmhead.asm 和 bootpack.c 组合成一个文件
```
  cat asmhead.o bootpack.hrb > haribote.sys
```

我使用了ld 把 bootpack.o asmhead.o asmfunc.o 组合在一起.
asmhead.o 一定要放在最前面, 否则无法正常工作, 比如
```
ld -m elf_i386 --oformat binary -T bootpack.ld bootpack.o asmhead.o  asmfunc.o -o kernel.bin
```
感觉 ld 是按顺序把 .o 文件组合在一起


--oformat binary 告诉 ld不要生成 elf header之类的信息, 否则要使用下面的命令来提取.text section中的代码
```
	objcopy -O binary -j.text kernel.elf.bin kernel.bin  
```
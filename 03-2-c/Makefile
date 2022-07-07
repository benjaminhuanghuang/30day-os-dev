ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

asmhead.o: asmhead.asm 
	nasm -f elf32 asmhead.asm -o asmhead.o

asmfunc.o: asmfunc.asm
	nasm -f elf32 asmfunc.asm -o asmfunc.o

bootpack.o: bootpack.c
	gcc -m32 -fno-pie -o bootpack.o -c bootpack.c

bootpack.bin: bootpack.o asmfunc.o asmhead.o 
	ld -m elf_i386 -Ttext 0xc200 bootpack.o asmfunc.o asmhead.o -o bootpack.bin

kernel.bin: bootpack.bin
	objcopy -O binary -j.text bootpack.bin kernel.bin  

img: ipl.bin kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc
	sudo mount -t vfat -o loop myos.img ~/temp/mnt
	sudo mcopy kernel.bin ~/temp/mnt
	sudo umount ~/temp/mnt

run: img
	qemu-system-i386 -fda myos.img -boot a

debug: img
	qemu-system-i386 -fda myos.img -boot a -s -S

clean:
	rm *.bin *.img

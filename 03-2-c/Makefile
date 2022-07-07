bin: boot.bin	kernel.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin

asmhead.bin : asmhead.asm 
	nasm asmhead.asm -o asmhead.bin

bootpack.elf.o: bootpack.c
	gcc -m32 -fno-pie -o bootpack.elf.o -c bootpack.c

asmfunc.o : asmfunc.asm
	nasm -f elf32 asmfunc.asm -o asmfunc.o

bootpack.bin : bootpack.c asmfunc.o  
	#
	nasm kernel.asm -o kernel.bin


kernel.bin : asmhead.bin bootpack.bin
	cat asmhead.bin bootpack.bin > kernel.bin


img: bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc
	sudo mount -t vfat -o loop myos.img ~/temp/mnt
	sudo mcopy kernel.bin ~/temp/mnt
	sudo umount ~/temp/mnt

run: img
	qemu-system-i386 -fda myos.img -boot a

debug :
	qemu-system-i386 -fda myos.img -boot a -s -S

clean:
	rm *.bin *.img

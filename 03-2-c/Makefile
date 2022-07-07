bin: boot.bin	kernel.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin

asmhead.bin : asmhead.asm 
	nasm asmhead.asm -o asmhead.bin

kernel.bin : asmhead.bin bootpack.bin
	cat asmhead.bin bootpack.bin > kernel.bin


bootpack.bin : bootpack.c asmfunc.o  
	#
	nasm kernel.asm -o kernel.bin

asmfunc.o : asmfunc.asm
	nasm -g -f elf nasmfunc.asm -o nasmfunc.o


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

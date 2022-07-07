bin: boot.bin	kernel.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin
	
kernel.bin : kernel.asm
	nasm kernel.asm -o kernel.bin

img: ipl.bin kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc
	mkfs.vfat -F 12 myos.img
	sudo mount -t vfat -o loop myos.img ~/temp/mnt
	sudo cp kernel.bin ~/temp/mnt
	sudo umount ~/temp/mnt

run: img
	qemu-system-i386 -fda myos.img -boot a

clean:
	rm *.bin *.img

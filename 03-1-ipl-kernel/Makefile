bin: boot.bin	kernel.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin
	
kernel.bin : kernel.asm
	nasm kernel.asm -o kernel.bin

img: ipl.bin kernel.bin
	dd if=ipl.bin of=myos.img bs=512 count=1
	# copy kernel.bin to fdisk
	dd if=loader.bin of=myos.img bs=512 count=1 seek=1

run: img
	qemu-system-i386 -fda myos.img -boot a

clean:
	rm *.bin *.img

bin: boot.bin	kernel.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin
	
kernel.bin : kernel.asm
	nasm kernel.asm -o kernel.bin

img: ipl.bin kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	mcopy -i myos.img kernel.bin ::

run: img
	qemu-system-i386 -fda myos.img -boot a

clean:
	rm *.bin *.img

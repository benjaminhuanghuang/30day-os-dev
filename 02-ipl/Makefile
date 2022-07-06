
ipl.bin : ipl.asm Makefile
	nasm ipl.asm -o ipl.bin

img : ipl.bin Makefile
	dd if=ipl.bin of=myos.img bs=512 count=1

run : img
	qemu-system-i386 -fda myos.img -boot a


clean :
	rm ipl.bin

default:
	make img
	
boot.bin : boot.asm 
	nasm boot.asm -o boot.bin 

asmhead.bin : asmhead.asm 
	nasm asmhead.asm -o asmhead.bin

bootpack.hrb : bootpack.c har.ld       
	gcc -march=i486 -m32 -nostdlib -T har.ld bootpack.c -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

myos.img : boot.bin haribote.sys
	mformat -f 1440 -C -B boot.bin -i myos.img ::
	mcopy haribote.sys -i myos.img ::

img :
	make -r myos.img

run :
	make img
	qemu-system-i386 -fda myos.img  # "-fda" for floppy disk
		
debug :
	make img
	qemu-system-i386 -fda myos.img -gdb tcp::10000 -S

clean :
	rm *.lst *.bin *.sys *.img *.hrb *.o
default:
	make img
	
boot.bin : boot.asm 
	nasm boot.asm -o boot.bin 

loader.bin : loader.asm 
	nasm loader.asm -o loader.bin

myos.img : boot.bin loader.bin
	mformat -f 1440 -C -B boot.bin -i myos.img ::
	mcopy loader.bin -i myos.img ::

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
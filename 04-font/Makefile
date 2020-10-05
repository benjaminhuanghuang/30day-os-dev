CC = gcc
CFLAGS = -c -m32 -march=i486 -nostdlib

default:
	make img
	
boot.bin : boot.asm 
	nasm boot.asm -o boot.bin 

asmhead.bin : asmhead.asm 
	nasm asmhead.asm -o asmhead.bin

nasmfunc.o : nasmfunc.asm
	nasm -g -f elf nasmfunc.asm -o nasmfunc.o

font.o : font.c
	$(CC) $(CFLAGS) font.c -o font.o

mysprintf.o : mysprintf.c
  $(CC) $(CFLAGS) -nostdlib $^ -o $@

bootpack.hrb : bootpack.c font.c har.ld nasmfunc.o font.o mysprintf.o
	gcc -march=i486 -m32 -nostdlib -T har.ld -fno-pie bootpack.c font.o mysprintf.o nasmfunc.o -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

myos.img : boot.bin haribote.sys
	mformat -f 1440 -C -B boot.bin -i myos.img ::
	mcopy haribote.sys -i myos.img ::

img :
	make -r myos.img

run :
	make img
	qemu-system-i386 -fda myos.img -boot a
		
debug :
	make img
	qemu-system-i386 -fda myos.img -gdb tcp::10000 -S

clean :
	rm *.lst *.bin *.sys *.img *.hrb *.o

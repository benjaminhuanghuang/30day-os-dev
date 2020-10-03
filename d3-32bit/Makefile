all: boot.bin	loader.bin

boot.bin : boot.asm
	nasm -f bin boot.asm -o boot.bin

#
loader.bin : bootpack.o asmhead.o
	ld -s -o loader.bin bootpack.o asmhead.o

asmhead.o : asmhead.asm 
	nasm -f bin asmhead.asm -o asmhead.o 

bootpack.o : bootpack.c 
	gcc -c -o bootpack.o bootpack.c 

clean:
	rm *.bin myos.img *.o

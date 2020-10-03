all: loader.bin	kernel.bin

boot.bin : boot.asm
	nasm -f bin boot.asm -o boot.bin
	
loader.bin : loader.asm
	nasm -f bin loader.asm -o loader.bin
	
clean:
	rm *.bin myos.img

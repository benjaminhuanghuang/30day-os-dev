all: loader.bin	kernel.bin

loader.bin : loader.asm
	nasm -f bin loader.asm -o loader.bin

kernel.bin : kernel.asm
	nasm -f bin kernel.asm -o kernel.bin
	
clean:
	rm *.bin

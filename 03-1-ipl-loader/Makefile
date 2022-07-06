bin: boot.bin	loader.bin

ipl.bin : ipl.asm
	nasm ipl.asm -o ipl.bin
	
loader.bin : loader.asm
	nasm loader.asm -o loader.bin

img: ipl.bin loader.bin
	dd if=ipl.bin of=myos.img bs=512 count=1
	dd if=loader.bin of=myos.img bs=512 count=1 seek=1

run: img
	qemu-system-i386 -fda myos.img -boot a

clean:
	rm *.bin *.img

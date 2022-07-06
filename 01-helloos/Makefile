img: helloos.asm
	nasm helloos.asm -o os.bin
	
run: img
	qemu-system-i386 -fda os.bin -boot a

clean:
	rm os.bin
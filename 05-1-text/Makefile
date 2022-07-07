ipl.bin: ipl.asm
	nasm ipl.asm -o ipl.bin

asmhead.o: asmhead.asm 
	nasm -f elf32 asmhead.asm -o asmhead.o -l asmhead.lst

asmfunc.o: asmfunc.asm
	nasm -f elf32 asmfunc.asm -o asmfunc.o -l asmfunc.lst

bootpack.o: bootpack.c
	gcc -m32 -fno-pie -o bootpack.o -c bootpack.c

hankaku.o: hankaku.c
	gcc -m32 -fno-pie -o hankaku.o -c hankaku.c

kernel.bin: bootpack.o asmfunc.o asmhead.o hankaku.o
	ld -m elf_i386 --oformat binary -T bootpack.ld  asmhead.o bootpack.o hankaku.o asmfunc.o -o kernel.bin

img: ipl.bin kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc
	dd if=kernel.bin of=myos.img seek=33 bs=512 conv=notrunc

run: img
	qemu-system-i386 -fda myos.img -boot a

debug: img
	qemu-system-i386 -fda myos.img -boot a -s -S

clean:
	rm *.bin *.img *.o *.lst
	

	

OBJS_BOOTPACK = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj in

ASM:= nasm
ASFLAGS:= -f elf32

CC:= gcc
# CFLAGS += -Wall -Wno-format -Wno-unused
CFLAGS+= -std=c11 -fno-stack-protector
# CFLAGS += -ffunction-sections -fno-builtin -ffreestanding -nostdinc -nostdlib 
CFLAGS+= -fno-pie -m32 -c

# Kernel Objects, the order matters!
OBJS:= bootpack.o font.o stdio.o graphic.o dsctbl.o int.o asmfunc.o

ipl.bin: ipl.asm
	$(ASM) ipl.asm -o ipl.bin

asmhead.bin: asmhead.asm
	$(ASM) -f bin asmhead.asm -o asmhead.bin

# Compile asmhead.asm and asmfunc.asm
%.o: %.asm 
	$(ASM) ${ASFLAGS} $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@

kernel_c.bin: ${OBJS}
	ld -m elf_i386 --oformat binary -T bootpack.ld $^ -o $@

kernel.bin: kernel_c.bin asmhead.bin
	cat asmhead.bin > kernel.bin
	cat kernel_c.bin >> kernel.bin

img: ipl.bin kernel.bin
	dd if=/dev/zero of=myos.img bs=512 count=2880
	dd if=ipl.bin of=myos.img bs=512 count=1 conv=notrunc
	dd if=kernel.bin of=myos.img seek=33 bs=512 conv=notrunc

run: img
	qemu-system-i386 -fda myos.img -boot a

debug: img
	qemu-system-i386 -fda myos.img -boot a -s -S

clean:
	rm *.bin *.img *.o
	

	

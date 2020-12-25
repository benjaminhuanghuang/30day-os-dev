TOOLPATH = ../z_tools/

MAKE     = make
NASK     = $(TOOLPATH)nask
EDIMG    = $(TOOLPATH)edimg

default :
	$(MAKE) img

ipl.bin : ipl.asm Makefile
	$(NASK) ipl.asm ipl.bin ipl.lst

myos.img : ipl.bin Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		imgout:myos.img

img:
	$(MAKE) myos.img

run :
	$(MAKE) img
	qemu-system-i386 -fda myos.img -boot a


clean :
	rm ipl.bin
	rm ipl.lst

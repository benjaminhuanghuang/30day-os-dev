TOOLPATH = ../z_tools/
INCPATH  = ../z_tools/haribote/

MAKE     = make
NASK     = $(TOOLPATH)nask
CC1      = $(TOOLPATH)gocc1 -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask -a
OBJ2BIM  = $(TOOLPATH)obj2bim
BIM2HRB  = $(TOOLPATH)bim2hrb
BIN2OBJ  = $(TOOLPATH)bin2obj
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG    = $(TOOLPATH)edimg
MAKEFONT = $(TOOLPATH)makefont
IMGTOL   = $(TOOLPATH)imgtol.com
DEL      = rm

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

boot.bin : boot.asm Makefile
	$(NASK) boot.asm boot.bin

asmhead.bin : asmhead.asm Makefile
	$(NASK) asmhead.asm asmhead.bin

bootpack.gas : bootpack.c Makefile
	$(CC1) -o bootpack.gas bootpack.c

bootpack.nas : bootpack.gas Makefile
	$(GAS2NASK) bootpack.gas bootpack.nas

bootpack.obj : bootpack.nas Makefile
	$(NASK) bootpack.nas bootpack.obj bootpack.lst

nasmfunc.obj : nasmfunc.asm Makefile
	$(NASK) nasmfunc.asm nasmfunc.obj nasmfunc.lst


bootpack.bim : bootpack.obj nasmfunc.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		bootpack.obj nasmfunc.obj 

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

haribote.sys : asmhead.bin bootpack.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img : boot.bin haribote.sys Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:boot.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		imgout:haribote.img

img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	qemu-system-i386 -fda haribote.img -boot a

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(DEL) *.bin
	-$(DEL) *.lst
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) bootpack.nas
	-$(DEL) bootpack.map
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb
	-$(DEL) haribote.sys
	-$(DEL) *.img
	-$(DEL) *.o
src_only :
	$(MAKE) clean
	-$(DEL) haribote.img
OBJS_BOOTPACK = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj \
						    int.obj fifo.obj keyboard.obj mouse.obj memory.obj sheet.obj \
								timer.obj mtask.obj window.obj console.obj file.obj

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

# Default action

default :
	$(MAKE) img

# File generation rules
boot.bin : boot.nas Makefile
	$(NASK) boot.nas boot.bin

asmhead.bin : asmhead.nas Makefile
	$(NASK) asmhead.nas asmhead.bin
	
hankaku.bin : hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj : hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

bootpack.bim : $(OBJS_BOOTPACK) Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		$(OBJS_BOOTPACK)
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

hello.bim : hello.obj a_nask.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:hello.bim map:hello.map hello.obj a_nask.obj

hello.hrb : hello.bim Makefile
	$(BIM2HRB) hello.bim hello.hrb 0

haribote.sys : asmhead.bin bootpack.hrb hello.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys

bug1.bim : bug1.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bug1.bim map:bug1.map bug1.obj a_nask.obj

bug1.hrb : bug1.bim Makefile
	$(BIM2HRB) bug1.bim bug1.hrb 0

bug3.bim : bug3.obj Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bug3.bim map:bug3.map bug3.obj a_nask.obj

bug3.hrb : bug3.bim Makefile
	$(BIM2HRB) bug3.bim bug3.hrb 0

haribote.img : boot.bin haribote.sys Makefile \
		hello.hrb bug1.hrb bug3.hrb
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:boot.bin len:512 from:0 to:0 \
		copy from:haribote.sys to:@: \
		copy from:int.c to:@: \
		copy from:hello.hrb to:@: \
		copy from:bug1.hrb to:@: \
		copy from:bug3.hrb to:@: \
		imgout:haribote.img

# general rules
%.gas : %.c Makefile
	$(CC1) -o $*.gas $*.c

%.nas : %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj : %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst



img :
	$(MAKE) haribote.img

run :
	$(MAKE) img
	qemu-system-i386 -fda haribote.img -boot a

install :
	$(MAKE) img
	$(IMGTOL) w a: haribote.img

clean :
	-$(DEL) *.gas
	-$(DEL) *.obj
	-$(DEL) *.lst
	-$(DEL) *.bin
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
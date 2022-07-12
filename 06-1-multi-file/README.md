# Day 6 Refactor
https://gitee.com/paud/30daysOS/tree/master/projects/06_day/harib03a

Split bootpack.c to  graphic.c, dsctlt.c, bootpack.c, 引入 bootpack.h

修改Mackefile, 使用通用规则
```
%.gas : %.c Makefile
  $(CC1) -o $*.gas $*.c

%.nas : %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj : %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst
```
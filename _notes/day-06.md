## 分割源文件
https://gitee.com/paud/30daysOS/tree/master/projects/06_day/harib03a


Split bootpack.c into
bootpack.c, graphic.c, dsctbl.c

## Refactor Makefile and .h file
https://gitee.com/paud/30daysOS/blob/master/projects/06_day/harib03b
https://gitee.com/paud/30daysOS/blob/master/projects/06_day/harib03c

Use general rule for 
c -> gas -> nas ->obj

```
# general rules
%.gas : %.c Makefile
	$(CC1) -o $*.gas $*.c

%.nas : %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj : %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst
```  


## GDT & IDT





## # general rules
```
%.gas : %.c Makefile
	$(CC1) -o $*.gas $*.c

%.nas : %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj : %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst
```

make.exe会首先寻找普通的生成规则，如果没找到，就尝试用一般规则

普通生成规则的优先级更高。比如虽然某个文件的扩展名也是．c，但是想用单独的规则来编译它，这也没问题。


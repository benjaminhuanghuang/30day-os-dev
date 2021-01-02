## 2 内存容量检查（1）（harib06b）

内存管理首先要搞清楚内存究竟有多大，范围是到哪里。如果连这一点都搞不清楚的话，内存管理就无从谈起。

在最初启动时，BIOS肯定要检查内存容量，所以只要我们问一问BIOS，就能知道内存容量有多大。但如果那样做的话，
一方面asmhead.nas会变长，另一方面，BIOS版本不同，BIOS函数的调用方法也不相同。
所以不如自己去检查内存。

暂时让486以后的CPU的高速缓存（cache）功能无效。

先查查CPU是不是在486以上，如果是，就将缓存设为OFF

最初对EFLAGS进行的处理，是检查CPU是486以上还是386。如果是486以上，EFLAGS寄存器的第18位应该是所谓的AC标志位；
如果CPU是386，那么就没有这个标志位，第18位一直是0。


Add asm functions into naskfunc.nas :
_memtest_sub _load_cr0, _store_cr0


## 内存管理（harib06d）
bootpack.c
```
#define MEMMAN_FREES		4090	/* これで約32KB */
#define MEMMAN_ADDR			0x003c0000

struct FREEINFO {	/* あき情報 */
	unsigned int addr, size;
};

struct MEMMAN {		/* メモリ管理 */
	int frees, maxfrees, lostsize, losts;
	struct FREEINFO free[MEMMAN_FREES];
};

unsigned int memtest(unsigned int start, unsigned int end);
void memman_init(struct MEMMAN *man);
unsigned int memman_total(struct MEMMAN *man);
unsigned int memman_alloc(struct MEMMAN *man, unsigned int size);
```


## Refactor memory.c（harib07a）


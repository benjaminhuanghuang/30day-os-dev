## 2 内存容量检查（1）（harib06b）
在最初启动时，BIOS要检查内存容量，所以只要问一问BIOS，就能知道内存容量有多大。
但BIOS版本不同，BIOS函数的调用方法也不相同。所以，不如自己去检查内存。

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
memman_alloc和memman_free能够以1字节为单位进行内存管理，这种方式虽然不错，但是有一点不足——在反复进行内存分配和内存释放之后，内存中就会出现很多不连续的小段未使用空间，这样就会把man->frees消耗殆尽


因此，我们要编写一些总是以0x1000字节为单位进行内存分配和释放的函数，它们会把指定的内存大小按0x1000字节为单位向上舍入（roundup），而之所以要以0x1000字节为单位，是因为笔者觉得这个数比较规整。另外，0x1000字节的大小正好是4KB。

```
	// 向上
	i = (i + 0xfff) & 0xfffff000;

	// 向下
	i = i & 0xfffff000;
```
## 叠加处理（harib07b）

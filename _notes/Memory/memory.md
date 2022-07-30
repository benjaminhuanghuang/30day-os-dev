## Cache
每次访问内存，都要将所访问的地址和内容存入到高速缓存里。比如存放18号地址的值是54。
如果下次再要用18号地址的内容，CPU就不再读内存了，而是使用高速缓存的信息，马上就能回答出18号地址的内容是54

往内存里写入数据时也一样，首先更新cache，然后再写入内存。如果先写入内存的话，在等待写入完成的期间，CPU处于空闲状态，这样就会影响速度。所以，先更新缓存，缓存控制电路配合内存的速度，然后再慢慢发送内存写入命令。

386的CPU没有缓存，486的缓存只有8-16KB

## 内存容量检查（harib06b）

内存管理首先要搞清楚内存究竟有多大，范围是到哪里。如果连这一点都搞不清楚的话，内存管理就无从谈起。

在最初启动时，BIOS肯定要检查内存容量，所以只要我们问一问BIOS，就能知道内存容量有多大。但如果那样做的话，
一方面asmhead.nas会变长，另一方面，BIOS版本不同，BIOS函数的调用方法也不相同。
所以不如自己去检查内存。

检查内存需要关闭cache， 否则写入和读出的不是内存，而是缓存。结果，所有的内存都“正常”，检查处理不能完成。

如果是486以上，EFLAGS寄存器的第18位应该是所谓的AC标志位；如果CPU是386，那么就没有这个标志位，第18位一直是0。
```
	#define EFLAGS_AC_BIT		0x00040000

	char flg486 = 0;
	unsigned int eflg, cr0, i;

	eflg = io_load_eflags();
	eflg |= EFLAGS_AC_BIT; /* AC-bit = 1 */

	io_store_eflags(eflg);
	eflg = io_load_eflags();
	if ((eflg & EFLAGS_AC_BIT) != 0) {
		/*
			如果是386， 即使设定AC=1，AC还是为0
		*/
		flg486 = 1;
	}
	eflg &= ~EFLAGS_AC_BIT; /* AC-bit = 0 */
	io_store_eflags(eflg);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 |= CR0_CACHE_DISABLE; /* 禁止Cache */
		store_cr0(cr0);
	}

	i = memtest_sub(start, end);

	if (flg486 != 0) {
		cr0 = load_cr0();
		cr0 &= ~CR0_CACHE_DISABLE; /* 允许Cache */
		store_cr0(cr0);
	}


```

naskfunc.nas
```
_load_cr0:		; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET


_memtest_sub:	; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH	EDI						; （EBX, ESI, EDI も使いたいので）
		PUSH	ESI
		PUSH	EBX
		MOV		ESI,0xaa55aa55			; pat0 = 0xaa55aa55;
		MOV		EDI,0x55aa55aa			; pat1 = 0x55aa55aa;
		MOV		EAX,[ESP+12+4]			; i = start;
mts_loop:
		MOV		EBX,EAX
		ADD		EBX,0xffc				; p = i + 0xffc;
		MOV		EDX,[EBX]				; old = *p;
		MOV		[EBX],ESI				; *p = pat0;
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff;
		CMP		EDI,[EBX]				; if (*p != pat1) goto fin;
		JNE		mts_fin
		XOR		DWORD [EBX],0xffffffff	; *p ^= 0xffffffff;
		CMP		ESI,[EBX]				; if (*p != pat0) goto fin;
		JNE		mts_fin
		MOV		[EBX],EDX				; *p = old;
		ADD		EAX,0x1000				; i += 0x1000;
		CMP		EAX,[ESP+12+8]			; if (i <= end) goto mts_loop;
		JBE		mts_loop
		POP		EBX
		POP		ESI
		POP		EDI
		RET
mts_fin:
		MOV		[EBX],EDX				; *p = old;
		POP		EBX
		POP		ESI
		POP		EDI
		RET
```


## 内存管理（harib06d）

内存管理的基础，一是内存分配，一是内存释放


bootpack.c
```
#define MEMMAN_FREES		4090	/* 大约32KB */
#define MEMMAN_ADDR			0x003c0000

struct FREEINFO {	/* 可用信息 */
	unsigned int addr, size;
};

/*
 需要 32KB
*/
struct MEMMAN {		/* 内存管理 */
	int frees, maxfrees, lostsize, losts;
	struct FREEINFO free[MEMMAN_FREES];
};

unsigned int memtest(unsigned int start, unsigned int end);
void memman_init(struct MEMMAN *man);
unsigned int memman_total(struct MEMMAN *man);
unsigned int memman_alloc(struct MEMMAN *man, unsigned int size);
```
memman需要32KB，我们暂时决定使用自0x003c0000开始的32KB（0x00300000号地址以后，今后的程序即使有所增加，预计也不会到达0x003c0000，所以我们使用这一数值），然后计算内存总量memtotal，将现在不用的内存以0x1000个字节为单位注册到memman里。最后，显示出合计可用内存容量。在QEMU上执行时，有时会注册成632KB和28MB。632+28672=29304，所以屏幕上会显示出29304KB。

## Refactor memory.c（harib07a）


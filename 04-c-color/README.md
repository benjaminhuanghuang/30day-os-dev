# Day 4

## 有关指针操作 (p69)

```
  unsigned char *p = (unsigned char *) 0xa0000;

	for (int i = 0; i <= 0xffff; i++) {
	  *(p + i) = i & 0x0f;
    // 
    p[i] = i & 0x0f;
	}
```

```
_write_mem8: 	; void write_mem8(int addr, int dat);
		MOV		ECX,[ESP+4]		; [ESP+4]存放的是地址
		MOV		AL,[ESP+8]		; [ESP+8]存放的是数据
		MOV		[ECX],AL
		RET
```

## static
static 指令用于数据，等效于DB指令, 避免被编译成赋值语句
```
  static unsigned char table_rgb[16 * 3] = {
  }
	
  table_rbg:
		DB 0x00, 0x02,...
```
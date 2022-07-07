[BITS 32]
GLOBAL  io_hlt, write_mem8

[section .text]


io_hlt:        ; void io_hlt(void);
  HLT
  RET

write_mem8:	; void write_mem8(int addr, int data);
  MOV		ECX,[ESP+4]		; [ESP+4]存放的是地址
  MOV		AL,[ESP+8]		; [ESP+8]存放的是数据
  MOV		[ECX],AL
  RET   
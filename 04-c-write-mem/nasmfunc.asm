section .text
   GLOBAL  io_hlt

io_hlt:        ; void io_hlt(void);
   HLT
   RET


_write_mem8:	; void write_mem8(int addr, int data);
   MOV		ECX,[ESP+4]		; [ESP+4] address of target address
   MOV		AL,[ESP+8]		; [ESP+8] address of data
   MOV		[ECX],AL
   RET

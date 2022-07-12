[BITS 32]						; 
   GLOBAL  _io_hlt,  _io_cli,  _io_sti, _io_stihlt
   GLOBAL  _io_in8,   _io_in16,   _io_in32
   GLOBAL  _io_out8,  _io_out16,  _io_out32
   GLOBAL  _io_load_eflags,  _io_store_eflags
   GLOBAL  write_mem8
   GLOBAL	_load_gdtr, _load_idtr


[SECTION .text]
_io_hlt:        ; void io_hlt(void);
   HLT
   RET


write_mem8:	; void write_mem8(int addr, int data);
   MOV		ECX,[ESP+4]		; [ESP+4] address of target address
   MOV		AL,[ESP+8]		; [ESP+8] address of data
   MOV		[ECX],AL
   RET

_io_cli:	; void io_cli(void);
   CLI
   RET

_io_sti:	; void io_sti(void);
   STI
   RET

_io_stihlt:	; void io_stihlt(void);
   STI
   HLT
   RET

_io_in8:	; int io_in8(int port);
   MOV	EDX,[ESP+4]		; port
   MOV	EAX,0
   IN		AL,DX
   RET

_io_in16:	; int io_in16(int port);
   MOV	EDX,[ESP+4]		; port
   MOV	EAX,0
   IN		AX,DX
   RET

_io_in32:	; int io_in32(int port);
   MOV	EDX,[ESP+4]		; port
   IN		EAX,DX
   RET

_io_out8:	; void io_out8(int port, int data);
   MOV		EDX,[ESP+4]		; port
   MOV		AL,[ESP+8]		; data
   OUT		DX,AL
   RET

_io_out16:	; void io_out16(int port, int data);
   MOV		EDX,[ESP+4]		; port
   MOV		EAX,[ESP+8]		; data
   OUT		DX,AX
   RET

_io_out32:	; void io_out32(int port, int data);
   MOV		EDX,[ESP+4]		; port
   MOV		EAX,[ESP+8]		; data
   OUT		DX,EAX
   RET

_io_load_eflags:	; int io_load_eflags(void);
   PUSHFD		; PUSH EFLAGS double-word
   POP		EAX
   RET

_io_store_eflags:	; void io_store_eflags(int eflags);
   MOV		EAX,[ESP+4]
   PUSH	EAX
   POPFD		; POP EFLAGS
   RET

; 指定的段上限（limit）和地址值赋值给名为GDTR的48位寄存器。
; 这是一个很特别的48位寄存器，并不能用我们常用的MOV指令来赋值。
; 给它赋值的时候，唯一的方法就是指定一个内存地址，从指定的地址读取6个字节（也就是48位），
; 然后赋值给GDTR寄存器。完成这一任务的指令，就是LGDT。
; 该寄存器的低16位（即内存的最初2个字节）是段上限，它等于“GDT的有效字节数 -1”。
; 剩下的高32位（即剩余的4个字节），代表GDT的开始地址。
_load_gdtr:		; void load_gdtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LGDT	  [ESP+6]
   RET

_load_idtr:		; void load_idtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LIDT	[ESP+6]
   RET


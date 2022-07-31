[BITS 32]						; 
  GLOBAL	load_gdtr, load_idtr
  GLOBAL	asm_int_handler21, asm_int_handler27, asm_int_handler2c
	EXTERN	int_handler21, int_handler27, int_handler2c

   
[SECTION .text]
load_gdtr:		; void load_gdtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LGDT	  [ESP+6]
   RET

load_idtr:		; void load_idtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LIDT	[ESP+6]
   RET

asm_int_handler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	int_handler21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

asm_int_handler27:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	int_handler27
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

asm_int_handler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	int_handler2c
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD
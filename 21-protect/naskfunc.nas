[FORMAT "WCOFF"]				; 
[INSTRSET "i486p"]			; 
[BITS 32]						; 
[FILE "naskfunc.nas"]			
   
   GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
   GLOBAL	_io_in8,  _io_in16,  _io_in32
   GLOBAL	_io_out8, _io_out16, _io_out32
   GLOBAL	_io_load_eflags, _io_store_eflags
   GLOBAL	_load_gdtr, _load_idtr
   GLOBAL	_load_cr0, _store_cr0
   GLOBAL	_load_tr
   GLOBAL	_asm_inthandler20, _asm_inthandler21
   GLOBAL	_asm_inthandler27, _asm_inthandler2c
   GLOBAL	_asm_inthandler0d
   GLOBAL	_memtest_sub
   GLOBAL	_farjmp, _farcall
   GLOBAL	_asm_hrb_api, _start_app
   EXTERN	_inthandler20, _inthandler21
   EXTERN	_inthandler27, _inthandler2c
   EXTERN	_inthandler0d
   EXTERN	_hrb_api


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
   LGDT	[ESP+6]
   RET

_load_idtr:		; void load_idtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LIDT	[ESP+6]
   RET

_load_cr0:		; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET

_load_tr:		; void load_tr(int tr);
		LTR		[ESP+4]			; tr
		RET

_asm_inthandler0d:
        STI
        PUSH     ES
        PUSH     DS
        PUSHAD
        MOV      EAX, ESP
        PUSH     EAX
        MOV      AX, SS
        MOV      DS, AX
        MOV      ES, AX
        CALL     _inthandler0d
        CMP      EAX,0        ; 只有这里不同
        JNE      end_app      ; 只有这里不同
        POP      EAX
        POPAD
        POP      DS
        POP      ES
        ADD      ESP,4             ; 在INT 0x0d中需要这句
        IRETD

_asm_inthandler20:
        PUSH     ES
        PUSH     DS
        PUSHAD
        MOV      EAX, ESP
        PUSH     EAX
        MOV      AX, SS
        MOV      DS, AX
        MOV      ES, AX
        CALL     _inthandler20
        POP      EAX
        POPAD
        POP      DS
        POP      ES
        IRETD

_asm_inthandler21:
   PUSH	ES
   PUSH	DS
   PUSHAD
   MOV		EAX,ESP
   PUSH	EAX
   MOV		AX,SS
   MOV		DS,AX
   MOV		ES,AX
   CALL	_inthandler21
   POP		EAX
   POPAD
   POP		DS
   POP		ES
   IRETD

_asm_inthandler27:
   PUSH	ES
   PUSH	DS
   PUSHAD
   MOV		EAX,ESP
   PUSH	EAX
   MOV		AX,SS
   MOV		DS,AX
   MOV		ES,AX
   CALL	_inthandler27
   POP		EAX
   POPAD
   POP		DS
   POP		ES
   IRETD

_asm_inthandler2c:
   PUSH	ES
   PUSH	DS
   PUSHAD
   MOV		EAX,ESP
   PUSH	EAX
   MOV		AX,SS
   MOV		DS,AX
   MOV		ES,AX
   CALL	_inthandler2c
   POP		EAX
   POPAD
   POP		DS
   POP		ES
   IRETD

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

_farjmp:		; void farjmp(int eip, int cs);
		JMP		FAR	[ESP+4]				; eip, cs
		RET

_farcall:		; void farcall(int eip, int cs);
		CALL	FAR	[ESP+4]				; eip, cs
		RET

_asm_hrb_api:
		STI
		PUSH     DS
		PUSH     ES
		PUSHAD ; PUSH for storage
		PUSHAD ; PUSH to pass to hrb_api
		MOV AX,SS
		MOV DS,AX ; put segments for OS into DS and ES
		MOV ES,AX
		CALL _hrb_api
		CMP EAX,0 ; end app if EAX is not 0
		JNE end_app
		ADD ESP,32
		POPAD
		POP ES
		POP DS
		IRETD

end_app:
; EAX is the number of tss.esp0
		MOV ESP,[EAX]
		POPAD
		RET ; return to cmd_app

_start_app:		; void start_app(int eip, int cs, int esp, int ds, int *tss_esp0);      
      PUSHAD                     ; 将32位寄存器的值全部保存起来
      MOV      EAX, [ESP+36]     ; 应用程序用EIP
      MOV      ECX, [ESP+40]     ; 应用程序用CS
      MOV      EDX, [ESP+44]     ; 应用程序用ESP
      MOV      EBX, [ESP+48]     ; 应用程序用DS/SS
      MOV      EBP, [ESP+52]     ; tss.esp0
      MOV      [EBP], ESP        ; 操作系统用ESP
      MOV      [EBP+4], SS       ; 操作系统用SS
      MOV      ES, BX
      MOV      DS, BX
      MOV      FS, BX
      MOV      GS, BX
      OR       ECX, 3 ; OR 3 to the segment number for the app
		OR       EBX, 3 ; OR 3 into the segment number for the app
		PUSH     EBX ; SS for app
		PUSH     EDX ; ESP for app
		PUSH     ECX ; CS for app
		PUSH     EAX ; EIP for app
		RETF

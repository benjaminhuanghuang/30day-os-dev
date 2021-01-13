; kernel.bin is at 0x4200 on disk, 
; The disk will be load to 0x8000 in memory, So the address is 0x8000+0x4200 = 0xc200
[INSTRSET "i486p"]

VBEMODE	EQU		0x105			; 1024 x  768 x 8bit color
;	0x100 :  640 x  400 x 8bit
;	0x101 :  640 x  480 x 8bit
;	0x103 :  800 x  600 x 8bit
;	0x105 : 1024 x  768 x 8bit
;	0x107 : 1280 x 1024 x 8bit


BOTPAK	EQU		0x00280000		; bootpack加载地址
DSKCAC	EQU		0x00100000		; 磁盘缓存
DSKCAC0	EQU		0x00008000		; 磁盘缓存(real mode)


; BOOT_INFO 记录系统信息
CYLS	EQU		0x0ff0			; 
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 记录VMODE how many bits for color？
SCRNX	EQU		0x0ff4			; 分辨率X
SCRNY	EQU		0x0ff6			; 分辨率Y
VRAM	EQU		0x0ff8			; 图形缓冲区起始地址


  ORG		0xc200			; 

  ; check VBE(VESA BIOS extension)

		MOV		AX,0x9000
		MOV		ES,AX
		MOV		DI,0
		MOV		AX,0x4f00
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320

; VBE version check

		MOV		AX,[ES:DI+4]
		CMP		AX,0x0200
		JB		scrn320			; if (AX < 0x0200) goto scrn320

; get screen mode information
		MOV		CX,VBEMODE
		MOV		AX,0x4f01
		INT		0x10
		CMP		AX,0x004f
		JNE		scrn320

; Check the screen mode information.

		CMP		BYTE [ES:DI+0x19],8
		JNE		scrn320
		CMP		BYTE [ES:DI+0x1b],4
		JNE		scrn320
		MOV		AX,[ES:DI+0x00]
		AND		AX,0x0080
		JZ		scrn320			; bit7 of the mode attribute was 0, so we give up.

; Switching screen modes
		MOV		BX,VBEMODE+0x4000
		MOV		AX,0x4f02
		INT		0x10
		MOV		BYTE [VMODE],8	; 画面モードをメモする（C言語が参照する）
		MOV		AX,[ES:DI+0x12]
		MOV		[SCRNX],AX
		MOV		AX,[ES:DI+0x14]
		MOV		[SCRNY],AX
		MOV		EAX,[ES:DI+0x28]
		MOV		[VRAM],EAX
		JMP		keystatus

scrn320:
		MOV		AL,0x13			; VGA 320x200x8bit
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; 8 bit
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; Ask the BIOS to tell you the LED status of the keyboard.
  MOV		AH,0x02
  INT		0x16 			; keyboard BIOS
  MOV		[LEDS],AL

; 防止PIC接受任何中断
  MOV		AL,0xff
  OUT		0x21,AL
  NOP						; 如果重复执行OUT命令，似乎有些模型不起作用
  OUT		0xa1,AL

  CLI						; 在CPU级别，也禁止中断。


; 设置A20GATE以便CPU可以访问1MB或更多的内存。
  CALL	waitkbdout
  MOV		AL,0xd1
  OUT		0x64,AL
  CALL	waitkbdout
  MOV		AL,0xdf			; enable A20
  OUT		0x60,AL
  CALL	waitkbdout


;
; 保护模式转换
;
	LGDT	[GDTR0]			; 设置临时GDT
	MOV		EAX,CR0
	AND		EAX,0x7fffffff	; 将bit31设置为0（禁止分页）
	OR		EAX,0x00000001	; 将bit0设置为1（用于过渡到保护模式）
	MOV		CR0,EAX
	JMP		pipelineflush

pipelineflush:
	MOV		AX,1*8			;  读/写段32bit
	MOV		DS,AX
	MOV		ES,AX
	MOV		FS,AX
	MOV		GS,AX
	MOV		SS,AX

; bootpack
	MOV		ESI,bootpack	;
	MOV		EDI,BOTPAK		;
	MOV		ECX,512*1024/4
	CALL	memcpy

; 

; 

	MOV		ESI,0x7c00		; source
	MOV		EDI,DSKCAC		; target
	MOV		ECX,512/4
	CALL	memcpy

;
	MOV		ESI,DSKCAC0+512	; source
	MOV		EDI,DSKCAC+512	; target
	MOV		ECX,0
	MOV		CL,BYTE [CYLS]
	IMUL	ECX,512*18*2/4	; 从柱面数转换为字节数/ 4
	SUB		ECX,512/4		; 仅扣除IPL
	CALL	memcpy


; bootpack

	MOV		EBX,BOTPAK
	MOV		ECX,[EBX+16]
	ADD		ECX,3			; ECX += 3;
	SHR		ECX,2			; ECX /= 4;
	JZ		skip			; 
	MOV		ESI,[EBX+20]	; source
	ADD		ESI,EBX
	MOV		EDI,[EBX+12]	; target
	CALL	memcpy
	
skip:
	MOV		ESP,[EBX+12]	; スタック初期値
	JMP		DWORD 2*8:0x0000001b

waitkbdout:
	IN		 AL,0x64
	AND		 AL,0x02
	JNZ		waitkbdout		; 如果AND的结果不为0，jump to waitkbdout
	RET

memcpy:
	MOV		EAX,[ESI]
	ADD		ESI,4
	MOV		[EDI],EAX
	ADD		EDI,4
	SUB		ECX,1
	JNZ		memcpy			; 如果减法的结果不为0，jump to memcpy
	RET

; memcpy
	ALIGNB	16
	
GDT0:
	RESB	8				; 
	DW		0xffff,0x0000,0x9200,0x00cf	; 读/写段32bit
	DW		0xffff,0x0000,0x9a28,0x0047	; 可执行段32bit（用于bootpack）

	DW		0
GDTR0:
	DW		8*3-1
	DD		GDT0

	ALIGNB	16
bootpack:
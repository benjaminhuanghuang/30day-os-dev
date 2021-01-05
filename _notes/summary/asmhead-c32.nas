;
; https://gitee.com/paud/30daysOS/blob/master/projects/03_day/harib00i/asmhead.nas
;

; haribote-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; kernel会被加载到这个地址
DSKCAC	EQU		0x00100000		; 磁盘缓存地址
DSKCAC0	EQU		0x00008000		; 实模式下，整个磁盘被加载到了这个地址

; BOOT_INFO 全局变量，记录系统信息
CYLS	EQU		0x0ff0			; ipl 在启动时set这个值
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; 8位色
SCRNX	EQU		0x0ff4			; width
SCRNY	EQU		0x0ff6			; height
VRAM	EQU		0x0ff8			; vga起始地址


; ipl会把整个软盘加载到 0x8000，根据FAT12的文件格式，文件系统中的第一个文件在磁盘的位置为0x004200
; (从33扇区开始)，因此kernel在内存中的地址为 0x8000 + 0x4200 = 0xC200
; 
		ORG		0xc200			; kernel 会被加载到这个地址并开始执行

; 调用BIOS 0x10, 设置显示模式为 320 * 200 * 8bit

		MOV		AL,0x13			
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE], 8
		MOV		WORD [SCRNX], 320
		MOV		WORD [SCRNY], 200
		MOV		DWORD [VRAM],0x000a0000

; 调用BIOS 0x16 读取 键盘LED信息

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

;防止PIC接受任何中断
;根据AT兼容机的规格，如果要初始化PIC，
;如果在CLI之前执行此操作，它有时会挂起
; PIC初始化将在以后完成

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; 如果继续执行OUT命令，似乎有些机型不起作用。
		OUT		0xa1,AL

		CLI						; 禁止所有中断

; 设置A20GATE，以便CPU可以访问1MB或更多的内存

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; !! 进入保护模式

[INSTRSET "i486p"]				; 说明要使用486命令

		LGDT	[GDTR0]			; 临时GDT设置
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; bit31=0 禁止分页
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

; 传输 bootpack

		MOV		ESI,bootpack	; source
		MOV		EDI,BOTPAK		; target
		MOV		ECX,512*1024/4
		CALL	memcpy

; 顺便说一下，磁盘数据也被传送到原始位置

; copy 引导区

		MOV		ESI,0x7c00		; source
		MOV		EDI,DSKCAC		; target
		MOV		ECX,512/4
		CALL	memcpy

; the rest

		MOV		ESI,DSKCAC0+512	; source
		MOV		EDI,DSKCAC+512	; target
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; 从柱面数转换为字节数 / 4
		SUB		ECX,512/4		; 扣除 IPL
		CALL	memcpy

; asmhead工作完成
;	剩下的工作有C语言代码完成

; bootpack启动

		MOV		EBX,BOTPAK
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; 
		MOV		ESI,[EBX+20]	; 
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; 
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; 初始堆栈
		JMP		DWORD 2*8:0x0000001b

waitkbdout:
		IN		 AL,0x64
		AND		 AL,0x02
		JNZ		waitkbdout		; 如果AND的结果不为0，跳转到waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; 如果减法的结果不为0，跳转到memcpy
		RET
; memcpy
    ; 告诉汇编程序，本伪指令下面的内存变量必须从下一个能被Num整除的地址开始分配
		ALIGNB	16
GDT0:
		RESB	8				; Empty selector
		DW		0xffff,0x0000,0x9200,0x00cf	; 读/写段32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; 可执行段32bit（用于bootpack）

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0
    ; 告诉汇编程序，本伪指令下面的内存变量必须从下一个能被Num整除的地址开始分配
		ALIGNB	16
bootpack:


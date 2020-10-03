; kernel.bin is at 0x4200 on disk, 
; The disk will be load to 0x8000 in memory, So the address is 0x8000+0x4200 = 0xc200

; BOOT_INFO関係
CYLS	EQU		0x0ff0			; ブートセクタが設定する
LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2			; how many bits for color？
SCRNX	EQU		0x0ff4			; 分辨率X
SCRNY	EQU		0x0ff6			; 分辨率Y
VRAM	EQU		0x0ff8			; 图形缓冲区起始地址


		ORG		0xc200			; 

		MOV		AL,0x13			; VGA图形，320x200x8bit彩色
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8 	       ;  record mode
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; Get keyboard LED status
		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

fin:
		HLT
		JMP		fin
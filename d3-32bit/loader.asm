;
;  https://gitee.com/paud/30daysOS/blob/master/projects/03_day/harib00b/ipl.nas
;  
;  Load 10 Cylinder(C0 to C9) 10 * 2 * 18 * 512 = 180 kB to memory

org  0x7c00;

LOAD_ADDR  EQU  0X8000
CYLS	   EQU	10		    ; read 10 Cylinders

entry:
    MOV		AX, 0			; init register
    MOV		SS, AX
    MOV		SP, 0x7c00
    MOV		DS, AX

; Read disk
    MOV		AX, 0x0820      ; ES = 0x8200, that is address [ES:BX]to put data
    MOV		ES, AX
    MOV		CH, 0			; Cylinder 0
    MOV		DH, 0			; Head 0
    MOV		CL, 2			; Sector 2
readloop:
    MOV		SI, 0			; SI keeps the failed times
retry:
    MOV		AH, 0x02		; AH=0x02 : means read
    MOV		AL, 1			; how many sector to read
    MOV		BX, 0           ; [ES:BX] to put data
    MOV		DL, 0x00		; A Driver
    INT		0x13			; BIOS INT13: Read Disk
    JNC		next		    ; Jump to next if no error
    ADD		SI, 1			; SI + 1 if error
    CMP		SI, 5			; SI compare 5
    JAE		error			; SI >= 5 jump to error
    MOV		AH,0x00         ; Reset Driver
    MOV		DL,0x00			; A Driver
    INT		0x13			; BIOS INT13: reset Disk A (AH=0, DL=0)
    JMP		retry
next:
    MOV		AX,ES			; ES + 0x20(= 512 / 16), the new address is [ES:BX], the new addrss = old address + 512
    ADD		AX,0x0020
    MOV		ES,AX			; can not put number to ES directly like ADD ES,0x020  
    ADD		CL,1			; Cylinder + 1  
    CMP		CL,18			; CL compare 18
    JBE		readloop		; CL <= 18 jump readloop
    MOV		CL,1            ; read C0-H1-S1
    ADD		DH,1
    CMP		DH,2
    JB		readloop		; DH < 2 jump to readloop
    MOV		DH,0        
    ADD		CH,1
    CMP		CH,CYLS
    JB		readloop		; CH < CYLS jump to readloop
; sleep

fin:
    HLT						; 
    JMP		fin				; 

error:
    MOV		SI,msg
putloop:
    MOV		AL,[SI]
    ADD		SI,1			; SI + 1
    CMP		AL,0            ; end of string
    JE		fin
    MOV		AH,0x0e			; display 1 charactor
    MOV		BX,15			; color
    INT		0x10			; Call BIOS INT 0x10
    JMP		putloop
msg:
    DB		0x0a, 0x0a		; new line * 2
    DB		"load error"
    DB		0x0a			; new line
    DB		0

    RESB	0x7dfe-$		; fill 0 from current address to 0x7dfe

    DB		0x55, 0xaa




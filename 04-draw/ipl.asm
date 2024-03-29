;
;  https://gitee.com/paud/30daysOS/blob/master/projects/03_day/harib00f/ipl.nas
;  
;  Load 10 Cylinder(C0 to C9) 10 * 2 * 18 * 512 = 180 kB to memory

CYLS	EQU		10				; read 10 Cylinder

ORG    0x7C00     ; 程序加载到内存地址0x7C00后

; 以下的记述用于标准FAT12格式的软盘
start:
    JMP   entry
    DB	  0x90          ; nop
    DB    "HELLOIPL"    ; 厂商名(8字节)
    DW    0x200        ; 扇区大小(512字节)
    DB    1        ; 每簇扇区大小(1扇区)
    DW    1        ; Boot记录占多少扇区，也就是FAT起始位置
    DB    2        ; FAT table个数
    DW    0xE0        ; 根目录文件最大数(224项)
    DW    0xB40        ; 磁盘扇区总数(2880扇区)
    DB    0xF0        ; 磁盘种类
    DW    9            ; FAT长度
    DW    0x12        ; 每个磁道扇区数(18)
    DW    2           ; 磁头数
    DD    0           ; 不使用分区
    DD    0           ; 重写一次磁盘扇区总数(2880扇区)
    DB    0           ; INT13 驱动器号
    DB    0           ; non use
    DB    0x29        ; 扩展引导标记
    DD    0x0    ; 可能是卷序列号(4bytes)
    DB    "HELLO-OS   "    ; 磁盘名称(11字节)
    DB    "FAT12   "    ; 格式名称(8字节)

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

; Execute kernel
; kernel.bin is at 0x4200 on disk, 
; The disk will be load to 0x8000 in memory, So the address is 0x8000+0x4200 = 0xc200
    MOV		[0x0ff0],CH		; 
    JMP		0xc200         

error:
    MOV		SI, msg
putloop:
    MOV		AL,[SI]
    ADD		SI,1			; SI + 1
    CMP		AL,0            ; end of string
    JE		fin
    MOV		AH,0x0e			; display 1 charactor
    MOV		BX,15			; color
    INT		0x10			; Call BIOS INT 0x10
    JMP		putloop

fin:
    HLT						; 
    JMP		fin				; 

msg:
  DB		0x0a, 0x0a		; 换行两次
  DB		"Load Error!"
  DB		0x0a			; 换行
  DB		0

  times 0x001fe-($-$$) DB 0

  DB		0x55, 0xaa      ; 512 = 0x200
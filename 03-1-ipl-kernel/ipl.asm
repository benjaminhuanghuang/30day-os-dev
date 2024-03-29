CYLS 	EQU 	10				; 声明扇面数		

ORG		0x7c00			    ; 指明程序装载地址

; 标准FAT12格式软盘专用的代码 Stand FAT12 format floppy code

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; 启动扇区名称（8字节）
		DW		512				; 每个扇区（sector）大小（必须512字节）
		DB		1				; 簇（cluster）大小（必须为1个扇区）
		DW		1				; FAT起始位置（一般为第一个扇区）
		DB		2				; FAT个数（必须为2）
		DW		224				; 根目录大小（一般为224项）
		DW		2880			; 该磁盘大小（必须为2880扇区1440*1024/512）
		DB		0xf0			; 磁盘类型（必须为0xf0）
		DW		9				; FAT的长度（必??9扇区）
		DW		18				; 一个磁道（track）有几个扇区（必须为18）
		DW		2				; 磁头数（必??2）
		DD		0				; 不使用分区，必须是0
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 意义不明（固定）
		DD		0xffffffff		; （可能是）卷标号码
		DB		"HELLO-OS   "	; 磁盘的名称（必须为11字?，不足填空格）
		DB		"FAT12   "		; 磁盘格式名称（必??8字?，不足填空格）
		;RESB	18				; 先空出18字节
    times 18 DB 0
; 程序主体

entry:
  MOV		AX,0			; 初始化寄存器
  MOV		SS,AX
  MOV		SP,0x7c00
  MOV		DS,AX

; Read Disk
  MOV     AX,0X0820           ; 存放读取的内容到 0X0820 
  MOV     ES,AX
  MOV     CH,0                ; 柱面0
  MOV     DH,0                ; 磁头0
  MOV     CL,2                ; 扇区2

readloop:
  MOV     SI, 0               ; 记录失败次数

retry: 
  MOV     AH,0x02             ; AH=0x02 : 读盘
  MOV     AL,1                ; 1个扇区
  MOV     BX,0
  MOV     DL,0x00             ; 驱动器编号, 0isA驱动器
  INT     0x13                ; 调用磁盘BIOS
  JNC     next                ; if No error, read next sector
  ADD     SI, 1        
  CMP     SI, 5
  JAE     error               ; if SI >=5, jump to error, else reset dirver & retry
  MOV  AH, 0x00               ; reset dirver
  MOV  DL , 0x00              ; Dirver A
  INT  0x13                   ; reset Driver
  JMP  retry

next:
		MOV		AX,ES			; 把内存地址后移0x200, 因为每次读取512(0x200)bytes
		ADD		AX,0X0020
		MOV		ES,AX			; 因为没有ADD ES，0x020指令，这里绕个弯
		ADD		CL,1			; 往CL里加1
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; 如果CL<=18 跳转至readloop
		MOV		CL,1
		ADD 	DH,1
		CMP		DH,2
		JB 		readloop		; 如果DH<2，跳转到readloop, 交替读取 Driver Head 0 and Deirver Head 1
		MOV		DH,0
		ADD 	CH,1
		CMP 	CH,CYLS			
		JB 		readloop		; 如果CH<CYLS，跳转到readloop

; Execute kernel
; kernel.bin is at 0x4200 on disk, 
; The 第二扇区 will be load to 0x8200 in memory, So the address 0x4200 on disk will be 0x8000+0x4200 = 0xc200 in the memory
fin:
  MOV		[0x0ff0],CH           ; 记录CH             
  JMP		0xc200                ; jump to kernel

error:
  MOV     SI,msg

putloop:
  MOV     AL,[SI]
  ADD     SI,1                ; 给SI加1
  CMP     AL,0
  JE      fin
  MOV     AH,0x0e             ; 显示一个文字
  MOV     BX,15               ; 指定字符颜色
  INT     0x10                ; 调用显卡BIOS
  JMP     putloop

msg:
  DB		0x0a, 0x0a		; 换行两次
  DB		"Load Error!"
  DB		0x0a			; 换行
  DB		0

  times 0x001fe-($-$$) DB 0

  DB		0x55, 0xaa      ; 512 = 0x200
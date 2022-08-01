
# 如何进入32位模式

见 book ch 8.5

```
;; asmhead.nas

MOV AL,0xff
OUT 0x21,AL          ; io_out(PIC0_IMR, 0xff);  禁止主PIC的全部中断 
NOP                  ; 如果连续执行OUT指令， 有些机器会无法正常运行
OUT 0xA1,AL          ; io_out(PIC1_IMR, 0xff);  禁止从PIC的全部中断 

CLI                  ; 禁止CPU级别的中断


; 为了让CPU能够访问1MB以上的内存空间，设定A20GATE

CALL waitkbdout
MOV AL,0xd1
OUT 0x64,AL          ; io_out(0x64, 0xd1);  写keyboard port
CALL waitkbdout
MOV AL,0xdf ;        ; io_out(0x60, 0xdf);  enable A20
OUT 0x60,AL
CALL waitkbdout



; 保护模式转换
; Intel处理器规定GDT中的第一个描述符必须是空描述符
LGDT	[GDTR0]			    ; 把临时GDT的地址和大小被保存到GDTR寄存器
MOV		EAX,CR0
AND		EAX,0x7fffffff	; 设置 bit31 为 0（禁用分页）
OR		EAX,0x00000001	; 设置 bit0  为 1（保护模式过渡）
MOV		CR0,EAX

; 汇编中存在一个流水线技术的概念。处理器为了提高效率将当前指令和后续指令预取到流水线，因此，可能同时预期的指令中既有 16 位代码又有 32 位代码。
; 为了避免将 32 位代码用 16 位代码的方式运行，需要刷新流水线，此时便需要使用 jmp 强制刷新流水线。
JMP		pipelineflush   ; 

pipelineflush:
MOV		AX,1*8			;  把除了CS之外的所有段寄存器的值都设置成8, 也就是第一个 segment selector
MOV		DS,AX
MOV		ES,AX
MOV		FS,AX
MOV		GS,AX
MOV		SS,AX

; 把 bootpack 处的512K copy 到 BOTPAK(0x280000)
; memcpy(bootpack, BOTPAK, 512*1024/4)
; memcpy 的单位是4个字节
MOV		ESI,bootpack	  ; 源
MOV		EDI,BOTPAK		  ; 目标
MOV		ECX,512*1024/4  ; 传输数据大小以双字为单位,因此要/4
CALL	memcpy

; 把 0x7c00 处的 512 bytes copy 到 DSKCAC(1MB)处的内存
; memcpy(0x7c00, DSKCAC, 512/4)
; memcpy 的单位是4个字节
MOV		ESI,0x7c00		; 源
MOV		EDI,DSKCAC		; 目标 DSKCAC=0x100000
MOV		ECX,512/4     ; 传输数据大小以双字为单位,因此要/4
CALL	memcpy


; 把 0x8200 处的 512 bytes copy 到 DSKCAC+512(1MB+0x200)处的内存
; memcpy(DSKCAC0+512, DSKCAC+512, 512/4)
; memcpy 的单位是4个字节
MOV		ESI,DSKCAC0+512	; 源 DSKCAC0=0x8000
MOV		EDI,DSKCAC+512	; 目标 0x100200
MOV		ECX,0
MOV		CL,BYTE [CYLS]   ; ECX = 柱面数 
IMUL	ECX, 512*18*2/4	 ; 从柱面数转换成字节数/4
SUB		ECX, 512/4		   ; 减去启动扇区的512/4
CALL	memcpy

```
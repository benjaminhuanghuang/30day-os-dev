[BITS 32]

GLOBAL  io_hlt, write_mem8, myprint

[section .text]


io_hlt:        ; void io_hlt(void);
  HLT
  RET

write_mem8:	; void write_mem8(int addr, int data);
  MOV		ECX,[ESP+4]		; [ESP+4]存放的是地址
  MOV		AL,[ESP+8]		; [ESP+8]存放的是数据
  MOV		[ECX],AL
  RET   


myprint:
	mov ax,0xb800
	mov es,ax
	mov byte [es: 0x00], 'K'
  mov byte [es: 0x01], 0x24
  mov byte [es: 0x02], 'E'
  mov byte [es: 0x03], 0X41
  mov byte [es: 0x04], 'R'
  mov byte [es: 0x05], 0XA4
  mov byte [es: 0x06], 'N'
  mov byte [es: 0x07], 0XA4
  mov byte [es: 0x08], 'E'
  mov byte [es: 0x09], 0XA4
  mov byte [es: 0xA], 'L'
  mov byte [es: 0xB], 0XA4
	ret  
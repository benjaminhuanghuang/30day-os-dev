; kernel.bin is at 0x4200 on disk, 
; The disk will be load to 0x8000 in memory, So the address is 0x8000+0x4200 = 0xc200

  ORG		0xc200			;

  MOV		AL,0x13			; VGA, 320x200x8bit color
  MOV		AH,0x00
  INT		0x10
fin:
  HLT
  JMP		fin
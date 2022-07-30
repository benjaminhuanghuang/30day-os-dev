;

load_gdtr:		; void load_gdtr(int limit, int addr);
   MOV		AX,[ESP+4]		; limit
   MOV		[ESP+6],AX
   LGDT	  [ESP+6]
   RET

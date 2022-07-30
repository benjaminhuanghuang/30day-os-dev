PUSHAD Push All General-Purpose Registers
相当于
```
PUSH EAX
PUSH ECX
PUSH EDX
PUSH EBX
PUSH ESP
PUSH EBP
PUSH ESI
PUSH EDI
```
POPAD 把他们全 pop 出来



sample
```
_asm_inthandler21:
  PUSH ES
  PUSH DS
  PUSHAD
  MOV EAX,ESP
  PUSH EAX
  MOV AX,SS
  MOV DS,AX
  MOV ES,AX
  CALL _inthandler21
  POP EAX
  POPAD
  POP DS
  POP ES
  IRETD
```
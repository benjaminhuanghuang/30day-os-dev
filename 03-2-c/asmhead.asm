extern HariMain        ; from C fun
[BITS 16]
[section .text]
global _start


_start:
  call HariMain ; asm call c function



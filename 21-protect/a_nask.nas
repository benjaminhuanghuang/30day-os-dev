[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[BITS 32]
[FILE "a_nask.nas"]

        GLOBAL  _api_putchar
        GLOBAL  _api_end         ; 这里！

[SECTION .text]

_api_putchar:   ; void api_putchar(int c);
        MOV      EDX,1
        MOV      AL, [ESP+4]       ; c
        INT      0x40
        RET

_api_end:   ; void api_end(void);   ; 从此开始
        MOV      EDX,4
        INT      0x40                  ; 到此结束
        
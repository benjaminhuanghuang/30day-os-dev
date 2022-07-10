
load_kernel:
  mov DX, 0       ; DH:head, DL:driver
  mov CX, 2       ; CH: 磁道号的低8位数, CL:低5位放入所读起始扇区号，位7-6表示磁道号的高2位 注意Section Number从1开始
  mov AX, 0       ; read kernel to ES:BX (0x900)
  mov ES, AX
  mov BX, 0x900
  mov AH, 0x02    ; 调用读扇区功能
  mov AL, 1       ; 要读的扇区数目
  int 0x13

  jnc kernel_load_ok  ; check CF 如果CF=1，AX中存放出错状态
  jmp load_kernel     ; keep loading

kernel_load_ok:
  jmp 0x900    ; execute the kernel

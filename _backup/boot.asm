;
; https://blog.csdn.net/ekkie/article/details/51345149
; 
; boot.nas   create a 1.5M floppy disk image
;
;
   
    ORG    0x7C00     ; 程序加载到内存地址0x7C00后

; 以下的记述用于标准FAT12格式的软盘
start:
    JMP   entry
    DB    "HELLOIPL"    ; 启动区名称(8字节)
    DW    512        ; 扇区大小(512字节)
    DB    1        ; 簇大小(1扇区)
    DW    1        ; FAT起始位置
    DB    2        ; FAT个数
    DW    224        ; 根目录大小(224项)
    DW    2880        ; 磁盘大小(2880扇区)
    DB    0xf0        ; 磁盘种类
    DW    9        ; FAT长度
    DW    18        ; 每个磁道扇区数
    DW    2        ; 磁头数
    DD    0        ; 不使用分区
    DD    2880        ; 重写一次磁盘大小
    DB    0,0,0x29    ; 意义不明
    DD    0xffffffff    ; 可能是卷标号码
    DB    "HELLO-OS   "    ; 磁盘名称(11字节)
    DB    "FAT12   "    ; 格式名称(8字节)
    RESB  18        ; 空出18字节

entry:
    MOV    AX,0        ; 初始化寄存器
    MOV    SS,AX
    MOV    SP,0x7c00
    MOV    DS,AX
    MOV    ES,AX
; 读磁盘
    CYLS    EQU    10
    MOV    AX,0x0820
    MOV    ES,AX
    MOV    CH,0        ; 柱面0
    MOV    DH,0        ; 磁头0
    MOV    CL,2        ; 扇区2
readloop:
    MOV    SI,0        ; 记录失败次数

retry:
    MOV    AH,0x02        ; 读盘
    MOV    AL,1        ; 1个扇区
    MOV    BX,0
    MOV    DL,0x00       ; A驱动器
    INT    0x13        ; 调用磁盘BIOS
    JNC    next        ; 没出错跳转fin
    ADD    SI,1        
    CMP    SI,5        ; 比较SI与5
    JAE    error        ; SI >= 5时，跳转到error
    MOV    AH,0x00
    MOV    DL,0x00
    INT    0x13        ; 重置驱动器
    JMP    retry
next:
    MOV    AX,ES
    ADD    AX,0x0020    ; 把内存地址后移0x200
    MOV    ES,AX        ; 因为没有ADD ES,0x20
    ADD    CL,1
    CMP    CL,18
    JBE    readloop    ; 如果CL <= 18，跳转至readloop
    MOV    CL,1
    ADD    DH,1        ; 读磁盘另一面
    CMP    DH,2
    JB    readloop
    MOV    DH,0
    ADD    CH,1
    CMP    CH,CYLS        ; 读CYLS个柱面
    JB    readloop

; 输出helloworld

    MOV    SI, msg
putloop:
    MOV    AL,[SI]
    ADD    SI,1        ; 给SI加1
    CMP    AL,0

    JE    fin
    MOV    AH,0x0e      ; 显示一个文字
    MOV    BX,15        ; 指定字符颜色
    INT    0x10         ; 调用显卡BIOS
    JMP    putloop
fin:
    HLT
    JMP    fin
error:
    MOV    SI, errmsg
errloop:
    MOV    AL, [SI]
    ADD    SI, 1        ; 给SI加1
    CMP    AL, 0

    JE     fin
    MOV    AH,0x0e       ; 显示一个文字
    MOV    BX,15         ; 指定字符颜色
    INT    0x10          ; 调用显卡BIOS INT
    JMP    errloop

msg:
    DB    0x0a, 0x0a            ; 换行2次
    DB    "hello, world!!!"
    DB    0x0a                  ; 换行
    DB    0                     ; 字符串结束

errmsg:
    DB    0x0a, 0x0a            ; 换行2次
    DB    "disk error"
    DB    0x0a                  ; 换行
    DB    0                     ; 字符串结束

marker:
    RESB   0x1fe-(marker-start)   ; 0x1fe = 510 , reserve bytes
    DB     0x55, 0xaa             ; 512 标志位 0x55aa
    
; 以下是磁盘其他内容
    DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB  4600      ; reserve bytes
    DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB  1469432   ; reserve bytes     ; fill the rest part of the floppy disk 1474560(= 1440 * 1024)
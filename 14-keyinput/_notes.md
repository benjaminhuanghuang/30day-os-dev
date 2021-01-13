## 1 继续测试性能（harib11a ～ harib11c）




## 2 提高分辨率（1）（harib11d）
```
; 设定画面模式

        MOV      BX,0x4101        ; VBE的640x480x8bi彩色
        MOV      AX,0x4f02
        INT      0x10
        MOV      BYTE [VMODE],8  ; 记下画面模式（参考C语言）
        MOV      WORD [SCRNX],640
        MOV      WORD [SCRNY],480
        MOV      DWORD [VRAM],0xe0000000
```

## 3 提高分辨率（2）（harib11e）
https://gitee.com/paud/30daysOS/blob/master/projects/14_day/harib11e/asmhead.nas

## 4 键盘输入（1）（harib11f）

下键时的数值 + 0x80 = 键弹起时的数值
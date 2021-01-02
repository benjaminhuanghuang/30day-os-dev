
## Print 
```
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
  
```




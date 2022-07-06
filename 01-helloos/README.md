# Day 01

## 原书
用汇编代码生成 1.4M 的 img 文件
其中前512 bytes为boot section

asm.bat
```
  nask.exe helloos.nas heloos.img  
```

然后用qemu加载heloos.img

## 改进
在ubuntu中, 用 nasm 生成 bin , 然后用qume 加载



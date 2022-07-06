# qemu + GDB 调试引导程序

https://www.qemu.org/docs/master/system/qemu-manpage.html

https://blog.csdn.net/judyge/article/details/52281374

https://blog.csdn.net/qwe19910328/article/details/107009326


启动qemu
```
  qemu-system-i386 -fda myos.img -boot a -s -S
  
  -S: Do not start CPU at startup (you must type 'c' in the monitor).
  -s: Shorthand for -gdb tcp::1234, i.e. open a gdbserver on TCP port 1234
```

在另一个终端调用gdb 通过 qemu 进行 debug
```
(gdb) target remote localhost:1234

(gdb) file boot

(gdb) set arch i8086 

(gdb) break * 0x7c00

(gdb) c

(gdb) si

(gdb) info reg
```
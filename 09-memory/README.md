# Day 9 Memory

- https://gitee.com/paud/30daysOS/tree/master/projects/09_day/harib06a

refactor, 拆分文件 mouse.c, keyboard.c, 修改Makefile


- https://gitee.com/paud/30daysOS/tree/master/projects/09_day/harib06b
检查内存容量

方法1: 在启动时，通过BIOS检查内存容量. 但那样做的话，一方面asmhead.nas会变长，另一方面，BIOS版本不同，BIOS函数的调用方法也不相同


方法2: 暂时让486以后的CPU的高速缓存（cache）功能无效。
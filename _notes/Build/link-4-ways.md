最终的kernel.bin 由3部分代码组成
1. asmheader.asm 是整个内核的入口, 负责初始化GDT, 然后跳转到 32位的代码空间
2. 若干个 asm 代码文件, 包含硬件操作, 比如IO操作
3. 若干个 c 代码文件, 


## Way1
1. 编译 .c 文件, 生成 32-bit elf 格式的 .obj文件
```
  gcc -m32 -fno-pie -o kernel_c.elf.o -c kernal_c.c
```

2. 把 .c 文件生成的 .obj 反汇编成 汇编代码
```
```

3. 把 .c 文件生成的 汇编代码 include 或 copy-paste 到 asmhead.asm 中
copy-paste 的时候手动移除 extern 等函数声明, 因为最终所有的代码都包含在一个文件中, 不再需要这些声明


4. 把最终生成的, 包含所有kernel代码的 asmheader.asm 编译成 bin 格式

在 asmheader.asm 中用 org 指令指定 代码开始执行的地址

## Way2

把 kernel 的c语言部分(多个.c文件) 编译成 32-bit elf 格式的.obj 文件, 

把所有的 asm 代码, 包括 asmheader.asm 全都编译成 32-bit elf 格式的.obj 文件

此时的 asmheader.asm 不用 org 指令指定代码的加载地址, 这个工作交给 ld 来做

链接 asm 生成的 obj文件 和 c 生成的 obj 文件, 通过链接器参数 或 链接脚本 指定 代码的起始地址, 生成一个包含elf文件信息的kernel.bin

最后把kernel.bin中的有用部分, 比如代码, 数据, 堆栈, 提取出来

## Way3 

把 kernel 的c语言部分(多个.c文件) 编译成 32-bit elf 格式的.obj 文件, 

把所有的 asm 代码, 包括 asmheader.asm 全都编译成 32-bit elf 格式的.obj 文件

此时的 asmheader.asm 不用 org 指令指定代码的加载地址, 这个工作交给 ld 来做

链接 asm 生成的 obj文件 和 c 生成的 obj 文件, 通过链接器参数 或 链接脚本 指定 代码的起始地址, 同时指定输出格式为 binary, 直接生成kernel.bin

## Way 4

把 c 代码 和 asm 代码 都编译成 32-bit elf 格式的.obj 文件, 

链接多个 obj 文件, 指定代码加载地址为 0x0, 同时指定输出格式为 binary, 直接生成kernel_c.bin

asmheader.asm 编译成 binary 格式的kernel_asm.bin 文件

把两部分直接拼接成最终的 kernel.bin
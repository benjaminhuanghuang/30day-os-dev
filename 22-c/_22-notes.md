## 1 保护操作系统（5）（harib19a）


## 2 帮助发现bug（harib19b）

栈异常的中断号为0x0c

add _asm_inthandler0c and _inthandler0c()

注册IDT


产生异常时寄存器值:
```
esp[ 0] : EDI
esp[ 1] : ESI        esp[0～7]为_asm_inthandler中PUSHAD的结果
esp[ 2] : EBP
esp[ 4] : EBX
esp[ 5] : EDX
esp[ 6] : ECX
esp[ 7] : EAX
esp[ 8] : DS         esp[8～9]为_asm_inthandler中PUSH的结果
esp[ 9] : ES
esp[10] : 错误编号（基本上是0，显示出来也没什么意思）
esp[11] : EIP
esp[12] : CS         esp[10～15]为异常产生时CPU自动PUSH的结果
esp[13] : EFLAGS
esp[14] : ESP （应用程序用ESP）
esp[15] : SS  （应用程序用SS）
```

## 3 强制结束应用程序（harib19c）

强制结束键我们就定义为“Shift+F1”

当按下强制结束键时，改写命令行窗口任务的的寄存器值，并goto到asm_end_app。这样一来程序会被强制结束，但也有个问题，那就是当应用程序没有在运行的时候，按下强制结束键会发生误操作。这样可不行，必须要确认task_cons -> tss.ss0不为0时才能继续进行处理。为此，我们还得进行一些修改，使得当应用程序运行时，该值一定不为0；而当应用程序没有运行时，该值一定为0。


## C + ASM 混合编译
https://blog.goo.ne.jp/nekomemo2/e/f9718b447d4461507b182e371009b859

https://qiita.com/pollenjp/items/8fcb9573cdf2dc6e2668

https://vanya.jp.net/os/haribote.html#hrb

使用GCC支持.hrb格式
在不使用tolset进行开发时，您需要注意二进制执行格式。 
这是因为在“ OS自制简介”中，OS及其应用程序的二进制格式被假定为tolset创建的格式。 
需要在link时指定链接描述文件
```
  gcc -T har.ld
```

OS
```
OUTPUT_FORMAT("binary");
OUTPUT_ARCH(i386)

SECTIONS
{
    .head 0x0 : {
        LONG(64 * 1024)  /*  0 : stack+.data+heap の大きさ（4KBの倍数） */
        LONG(0x69726148)      /*  4 : シグネチャ "Hari" */
        LONG(0)               /*  8 : mmarea の大きさ（4KBの倍数） */
        LONG(0x310000)        /* 12 : スタック初期値＆.data転送先 */
        LONG(SIZEOF(.data))   /* 16 : .dataサイズ */
        LONG(LOADADDR(.data)) /* 20 : .dataの初期値列のファイル位置 */
        LONG(0xE9000000)      /* 24 : 0xE9000000 */
        LONG(HariMain - 0x20) /* 28 : エントリアドレス - 0x20 */
        LONG(0)               /* 32 : heap領域（malloc領域）開始アドレス */
    }

    .text : { *(.text) }

    .data 0x310000 : AT ( ADDR(.text) + SIZEOF(.text) ) {
        *(.data)
        *(.rodata*)
        *(.bss)
    }

    /DISCARD/ : { *(.eh_frame) }

}
```
APP
```
UTPUT_FORMAT("binary");
OUTPUT_ARCH(i386)

SECTIONS
{
    .head 0x0 : {
        LONG(128 * 1024)  /*  0 : stack+.data+heap の大きさ（4KBの倍数） */
        LONG(0x69726148)      /*  4 : シグネチャ "Hari" */
        LONG(0)               /*  8 : mmarea の大きさ（4KBの倍数） */
        LONG(0x0400)          /* 12 : スタック初期値＆.data転送先 */
        LONG(SIZEOF(.data))   /* 16 : .dataサイズ */
        LONG(LOADADDR(.data)) /* 20 : .dataの初期値列のファイル位置 */
        LONG(0xE9000000)      /* 24 : 0xE9000000 */
        LONG(HariMain - 0x20) /* 28 : エントリアドレス - 0x20 */
        LONG(24 * 1024)       /* 32 : heap領域（malloc領域）開始アドレス */
    }

    .text : { *(.text) }

    .data 0x0400 : AT ( ADDR(.text) + SIZEOF(.text) ) {
        *(.data)
        *(.rodata*)
        *(.bss)
    }

    /DISCARD/ : { *(.eh_frame) }

}
```

gcc 在Mac OS X上无法使用链接描述文件
Linux上的GNU ld程序接受-T <scriptname>选项，但在Mac OS上，-T是未知命令选项。


## 256 palette
VGA 320*200 8 位调色板模式，8位 means 256种颜色，但本质上VGA还是RGB模式，需要3个字节表示一个完整的颜色，
缺省情况下 0号颜色是 #000000， 15号颜色是#ffffff

https://gitee.com/paud/30daysOS/blob/master/projects/04_day/harib01f/





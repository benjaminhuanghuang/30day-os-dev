## 256 palette

VGA 320x200 8 位调色板模式，8 位只能使用 0 ～ 255，256 种颜色，

而 RGB 方式，用 6 位十六进制数，也就是 24 位（二进制）来指定颜色。8 位数完全不够。

这个 8 位彩色模式，是由程序员随意指定 0 ～ 255 的数字所对应的颜色的。比如 25 号颜色对应#ffffff,26 号颜色对应#123456 等。这种方式就叫做调色板（palette）。

缺省情况下 0 号颜色是 #000000， 15 号颜色是#ffffff

https://gitee.com/paud/30daysOS/blob/master/projects/04_day/harib01f/

```
    init_palette()

    set_palette();           // 用到了io 操作
```

本书只用了 16 种颜色

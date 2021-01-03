
## 1 鼠标显示问题（harib08a）
Fix 鼠标位置
导致图层超出画面的问题

## 2 实现画面外的支持（harib08b）
修改 sheet_refreshsub(), clip refresh 范围


## 3 shtctl的指定省略（harib08c）
在struct SHEET中加入struct SHTCTL *ctl

对函数shtctl_init也进行追加，仅追加1行即可。

修改sheet相关函数，让它们都不用指定ctl。

## 4 显示窗口（harib08d）
只要先准备一张图层，然后在图层缓冲区内描绘一个貌似窗口的图就可以了
make_window8


## 6 高速计数器（harib08f）


## 7 消除闪烁（1）（harib08g）

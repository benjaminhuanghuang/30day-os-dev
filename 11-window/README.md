# Day 11 Window

## mouse
- https://gitee.com/paud/30daysOS/tree/master/projects/11_day/harib08a
使鼠标可以移出屏幕
```
if (mx > binfo->scrnx - 1) {
  mx = binfo->scrnx - 1;
}
if (my > binfo->scrny - 1) {
  my = binfo->scrny - 1;
}
```

## fix sheet_refreshsub
- https://gitee.com/paud/30daysOS/tree/master/projects/11_day/harib08a

不刷新画面以外的部分


## 从sheet 相关的函数中移除*ctl
把ctlt移到 struct SHTCTL

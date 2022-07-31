# Day 8 鼠标控制与32位模式切换

- https://gitee.com/paud/30daysOS/tree/master/projects/08_day/harib05a

首先要把最初读到的 0xfa舍弃掉。之后，每次从鼠标那里送过来的数据都应该是3个字节一组的，所以每当数据累积到
3个字节，就把它显示在屏幕上

变量mouse_phase用来记住接收鼠标数据的工作进 展到了什么阶段（phase）。接收到的数据放在mouse_dbuf[0~2]内。
```
if (mouse_phase == 0) {
  各种处理;
} else if (mouse_phase == 1) {
  各种处理;
} else if (mouse_phase == 2) {
  各种处理;
} else if (mouse_phase == 3) {
  各种处理;
}
```
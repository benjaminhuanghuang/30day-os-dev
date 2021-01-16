## 1 提高窗口移动速度（1）（harib23a）
sheet.c sheet_refreshmap()
在进入bx和by的for循环之前先判断这个图层是否有透明部分，如果有透明部分的话还按现有程序执行，否则执行一个没有if语句的两层循环
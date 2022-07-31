## 判断某一位
```
if ((io_in8(PORT_KEYSTA) & KEYSTA_SEND_NOTREADY) == 0) {
	break;
}
```
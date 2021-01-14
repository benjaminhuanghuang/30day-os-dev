## 1 type命令（harib16a）

```
struct FILEINFO
{
	unsigned char name[8], ext[3], type;
	char reserve[10];
	unsigned short time, date, clustno;
	unsigned int size;
};
```
clustno这个成员，代表文件从磁盘上的哪个扇区开始存放

磁盘映像中的地址 = clustno ＊ 512 + 0x003e00


## 2 type命令改良（harib16b）
0x09……制表符：显示空格直到x被4整除为止
0x0a……换行符：换行
0x0d……回车符：忽略


## 3 对FAT的支持（harib16c）



## 4 代码整理（harib16d）

窗口相关函数 → window.c

命令行窗口相关函数 → console.c

文件相关函数 → file.c
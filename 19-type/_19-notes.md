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


## 5 第一个应用程序（harib16e）

像type命令一样，我们用file_loadfile将文件的内容读到内存中

应用程序不知道自己被读到哪个内存地址，这里暂且由ORG 0来生成。

为了应用程序能够顺利运行，我们需要为其创建一个内存段。段创建好之后，接下来只要goto到该段中的程序，程序应该就会开始运行了。

要goto到其他的内存段，在汇编语言中用farjmp指令。

```
	p = (char *)memman_alloc_4k(memman, finfo[x].size);
	file_loadfile(finfo[x].clustno, finfo[x].size, p, fat, (char *)(ADR_DISKIMG + 0x003e00));
	set_segmdesc(gdt + 1003, finfo[x].size - 1, (int)p, AR_CODE32_ER);
	farjmp(0, 1003 * 8);
	memman_free_4k(memman, (int)p, finfo[x].size);
```

hlt.hrb成功读入内存之后，将其注册为GDT的1003号。为什么要用1003号呢？100号或者12号不行吗？还真不行，因为1～2号由dsctbl.c使用，而3～1002号由mtask.c使用，所以我们用了1003号




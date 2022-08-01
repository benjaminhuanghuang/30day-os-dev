# Day 10 Memory

## memman_alloc_4k, memman_free_4k
- https://gitee.com/paud/30daysOS/tree/master/projects/10_day/harib07a

```
unsigned int memman_alloc_4k(struct MemMan *man, unsigned int size) {
  // 向上取整
  size = (size + 0xfff) & 0xfffff000;
  return memman_alloc(man, size);
}
```
## 图层叠加
- https://gitee.com/paud/30daysOS/tree/master/projects/10_day/harib07b

```
#define MAX_SHEETS 256

struct SHTCTL {
  unsigned char *vram;
  int xsize, ysize, top;
  struct SHEET *sheets[MAX_SHEETS];
  struct SHEET sheets0[MAX_SHEETS];
};
```

## 图层叠加优化
- https://gitee.com/paud/30daysOS/tree/master/projects/10_day/harib07c
只刷新鼠标所在的区域


## 图层叠加优化 2
- https://gitee.com/paud/30daysOS/tree/master/projects/10_day/harib07d
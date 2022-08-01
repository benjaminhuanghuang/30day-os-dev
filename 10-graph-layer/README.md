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




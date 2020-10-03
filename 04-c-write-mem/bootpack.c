
extern void io_hlt(void);
extern void write_mem8(int addr, int data);

void HariMain(void)
{
  // for (int i = 0xa0000; i < 0xaffff; i++)
  // {
  //   write_mem8(i, 15); // MOV BTYPE [i], 15
  // }

  char *p = (char *) 0xa0000;

	for (int i = 0; i <= 0xffff; i++) {
		*(p + i) = i & 0x0f;
	}

  for(;;){
    io_hlt();
  }
}
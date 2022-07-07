
extern void io_hlt(void);
extern void write_mem8(int addr, int data);
extern void myprint();


int main(void)
{
  unsigned char *p = (unsigned char *) 0xa0000;
	for (int i = 0; i <= 0xffff; i++) {
	  *(p + i) = i & 0x0f;
	}
  
  for(;;){
		io_hlt();
	}

}
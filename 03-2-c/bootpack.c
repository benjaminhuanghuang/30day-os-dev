
extern void io_hlt(void);
extern void write_mem8(int addr, int data);
extern void myprint();


void HariMain(void)
{
  // int i;
  // char *p;
	// for(i = 0xa0000; i <= 0xaffff; i++){
	// 	//write_mem8(i, i&0x0f);
  //   p = i;
  //   *p = i&0x0f;
	// }
  myprint();
	// for(;;){
	// 	io_hlt();
	// }

}
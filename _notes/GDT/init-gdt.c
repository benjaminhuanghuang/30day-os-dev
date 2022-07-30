struct SEGMENT_DESCRIPTOR {
	short limit_low, base_low;
	char base_mid, access_right;
	char limit_high, base_high;
};


#define ADR_GDT			0x00270000
#define LIMIT_GDT		0x0000ffff
#define ADR_BOTPAK		0x00280000
#define LIMIT_BOTPAK	0x0007ffff
#define AR_DATA32_RW	0x4092
#define AR_CODE32_ER	0x409a


void init_gdtidt(void)
{
  // 将 0x270000 ~ 0x27ffff设置为
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) 0x00270000;

  // 设置8192个段描述符, limit=0, base=0, privilege=0
	for (int i = 0; i < 8192; i++) {
		set_segmdesc(gdt + i, 0, 0, 0);
	}
  // #1段 limit=4G, base=0, privilege=4092
	set_segmdesc(gdt + 1, 0xffffffff, 0x00000000, 0x4092);
  // #2段 limit=512KB, base=0x280000, privilege=409a, for bootpack
	set_segmdesc(gdt + 2, 0x0007ffff, 0x00280000, 0x409a);
	
  load_gdtr(0xffff, 0x00270000);  // limit, addr
	return;
}

void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar)
{
	if (limit > 0xfffff) {
		ar |= 0x8000; /* G_bit = 1 */
		limit /= 0x1000;
	}
	sd->limit_low    = limit & 0xffff;
	sd->base_low     = base & 0xffff;
	sd->base_mid     = (base >> 16) & 0xff;
	sd->access_right = ar & 0xff;
	sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
	sd->base_high    = (base >> 24) & 0xff;
	return;
}

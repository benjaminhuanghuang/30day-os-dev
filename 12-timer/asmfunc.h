#ifndef _ASM_FUNC_H_
#define _ASM_FUNC_H_

#define EFLAGS_AC_BIT 0x00040000
#define CR0_CACHE_DISABLE 0x60000000

int load_cr0(void);

void store_cr0(int cr0);

#endif // _ASM_FUNC_H_
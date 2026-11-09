// Replacement for riscv-tests benchmarks/common/util.h (which assumes the HTIF environment).
#ifndef __UTIL_H
#define __UTIL_H
#include "mmio.h"
#define read_csr(reg) ({ unsigned long __tmp; __asm__ volatile("csrr %0, " #reg : "=r"(__tmp)); __tmp; })
void setStats(int enable);
int printf(const char *fmt, ...);
#endif

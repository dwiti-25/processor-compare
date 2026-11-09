// Testbench MMIO (common/wrapper/README.md)
#ifndef MMIO_H
#define MMIO_H
#define MMIO_PUTCHAR 0x80000000
#define MMIO_EXIT    0x80000008
#define MMIO_MARK    0x80000010
#ifndef __ASSEMBLER__
#include <stdint.h>
static inline void mmio_putchar(char c) { *(volatile uint8_t *)MMIO_PUTCHAR = (uint8_t)c; }
static inline void mmio_mark(int on) { *(volatile uint32_t *)MMIO_MARK = (uint32_t)on; }
static inline uint32_t rd_mcycle(void) { uint32_t v; __asm__ volatile("csrr %0, mcycle" : "=r"(v)); return v; }
static inline uint32_t rd_minstret(void) { uint32_t v; __asm__ volatile("csrr %0, minstret" : "=r"(v)); return v; }
#endif
#endif

// Common startup for all benchmarks: gp/sp, clear .bss, trap vector, main(), exit(main's return).
#include "mmio.h"
  .section .text.entry, "ax"
  .globl _start
_start:
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la sp, __stack_top
  la t0, __bss_start
  la t1, __bss_end
1:
  bgeu t0, t1, 2f
  sw zero, 0(t0)
  addi t0, t0, 4
  j 1b
2:
  la t0, trap_entry
  csrw mtvec, t0          // base only: Ibex treats it as vectored, others as direct
  csrw mcountinhibit, zero  // enable mcycle/minstret (Hazard3 resets with them inhibited)
  call main
  li t0, MMIO_EXIT
  sw a0, 0(t0)
3:
  j 3b

  // Any trap is a failure: exit code 0x1000 | mcause. 256-byte aligned for Ibex's vectored mtvec
  // (own section, so the alignment doesn't move _start off 0x80); a jump table fills the vector
  // slots so every entry lands in the handler.
  .section .text.trap, "ax"
  .align 8
trap_entry:
  .rept 32
  j trap_handler
  .endr
trap_handler:
  csrr t1, mcause
  li t2, 0x1000
  or t1, t1, t2
  li t0, MMIO_EXIT
  sw t1, 0(t0)
4:
  j 4b

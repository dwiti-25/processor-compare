// riscv-tests environment for the project testbench (replaces env/p/riscv_test.h, which uses
// HTIF/tohost). Entry at 0x80 (the common reset vector); pass/fail are written to the exit MMIO.
// Fail code = (TESTNUM << 1) | 1, as in upstream; any trap exits with 0x1000 | mcause.
#ifndef _ENV_PROJECT_TB_H
#define _ENV_PROJECT_TB_H

#include "mmio.h"

#define RVTEST_RV64U .macro init; .endm
#define RVTEST_RV32U .macro init; .endm

#define TESTNUM gp

#define RVTEST_CODE_BEGIN                                               \
        .section .text.entry, "ax";                                     \
        .globl _start;                                                  \
_start:                                                                 \
        j reset_vector;                                                 \
        .section .text.init, "ax";                                      \
        .pushsection .text.trap, "ax";                                  \
        .align 8;                                                       \
trap_vector:                                                            \
        .rept 32; j trap_fail; .endr;                                   \
trap_fail:                                                              \
        csrr t1, mcause;                                                \
        li a0, 0x1000;                                                  \
        or a0, a0, t1;                                                  \
        li t0, MMIO_EXIT;                                               \
        sw a0, 0(t0);                                                   \
1:      j 1b;                                                           \
        .popsection;                                                    \
reset_vector:                                                           \
        la t0, trap_vector;                                             \
        csrw mtvec, t0;                                                 \
        li TESTNUM, 0;                                                  \
        init;

#define RVTEST_CODE_END unimp

#define RVTEST_PASS                                                     \
        fence;                                                          \
        li a0, 0;                                                       \
        li t0, MMIO_EXIT;                                               \
        sw a0, 0(t0);                                                   \
1:      j 1b;

#define RVTEST_FAIL                                                     \
        fence;                                                          \
1:      beqz TESTNUM, 1b;                                               \
        sll a0, TESTNUM, 1;                                             \
        or a0, a0, 1;                                                   \
        li t0, MMIO_EXIT;                                               \
        sw a0, 0(t0);                                                   \
2:      j 2b;

#define EXTRA_DATA
#define RVTEST_DATA_BEGIN EXTRA_DATA .pushsection .data; .align 4;
#define RVTEST_DATA_END .popsection

#endif

/*
 Copyright 2019-2026 Western Digital Corporation or its affiliates.
 Copyright 2022-2026 Antmicro <www.antmicro.com>

 SPDX-License-Identifier: Apache-2.0
 Licensed under the Apache License, Version 2.0, see LICENSE for details.

 This is an automatically generated file by dwitisuchak on Mon Nov  9 19:43:36 IST 2026

 cmd:    veer -target=typical_pd -fpga_optimize=0 -set=iccm_enable=0 -set=dccm_enable=0 -set=icache_enable=0 -set=user_mode=0 -set=lockstep_enable=0 -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0 -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0 -set=pic_total_int=1 

*/
OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init .  : { *(.text.init) }
  
  .text . : { *(.text) }
  _end = .;
  . = 0xd0580000;
  .data.io .  : { *(.data.io) }
    . = 0xc0580000 ;
  .data  :  ALIGN(0x800) { *(.*data) *(.rodata*)}
  .bss :  {BSS_START = .; *(.*bss)}
  BSS_END = .;
  STACK = ALIGN(16) + 0x1000;
  
  
}


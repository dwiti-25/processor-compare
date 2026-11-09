/* Common memory layout for every core (one binary per benchmark).
   0x0_0000-0x1_FFFF : code (entry 0x80, the common reset vector)
   0x2_0000-0x3_FFFF : read-only data, data, bss, stack
   The testbench RAM is one flat 256 KiB, so the split only matters for VeeR EL2's "tcm" config,
   where code sits in ICCM and data in DCCM (VeeR's load/store unit cannot read ICCM). */
OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY {
  CODE (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
  DATA (rw)  : ORIGIN = 0x00020000, LENGTH = 128K
}
SECTIONS
{
  /* only the entry jump/startup lives here, so no alignment inside a test can move it off 0x80 */
  .text.entry 0x80 : { *(.text.entry) } > CODE
  .text : { *(.text.init) *(.text .text.*) } > CODE
  .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } > DATA
  .data : ALIGN(8) {
    *(.data .data.*)
    __global_pointer$ = . + 0x800;
    *(.sdata .sdata.*)
  } > DATA
  .bss (NOLOAD) : ALIGN(8) {
    __bss_start = .;
    *(.sbss .sbss.* .bss .bss.* COMMON)
    . = ALIGN(8);
    __bss_end = .;
  } > DATA
  _end = .;
  __stack_top = ORIGIN(DATA) + LENGTH(DATA);
}

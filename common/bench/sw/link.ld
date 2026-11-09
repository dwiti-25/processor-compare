/* Common memory layout: 256 KiB RAM at 0x0, entry at 0x80 (all three cores reset there). */
OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY { RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 256K }
SECTIONS
{

  /* only the entry jump/startup lives here, so no alignment inside a test can move it off 0x80 */
  .text.entry 0x80 : { *(.text.entry) } > RAM
  .text : { *(.text.init) *(.text .text.*) } > RAM
  .rodata : { *(.rodata .rodata.* .srodata .srodata.*) } > RAM
  .data : ALIGN(8) {
    *(.data .data.*)
    __global_pointer$ = . + 0x800;
    *(.sdata .sdata.*)
  } > RAM
  .bss (NOLOAD) : ALIGN(8) {
    __bss_start = .;
    *(.sbss .sbss.* .bss .bss.* COMMON)
    . = ALIGN(8);
    __bss_end = .;
  } > RAM
  _end = .;
  __stack_top = ORIGIN(RAM) + LENGTH(RAM);
}

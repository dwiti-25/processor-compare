# Benchmarks for all cores: one binary per benchmark, same GCC and flags for every core.
#   make -C common/bench            -> build/bench/<name>.{elf,hex,dis}
# Outputs go to $(REPO)/build/bench (gitignored).
REPO    := $(abspath ../..)
OUT     := $(REPO)/build/bench
GCC_DIR ?= $(HOME)/tools/xpack-riscv-none-elf-gcc-15.2.0-1/bin
CC      := $(GCC_DIR)/riscv-none-elf-gcc
OBJCOPY := $(GCC_DIR)/riscv-none-elf-objcopy
OBJDUMP := $(GCC_DIR)/riscv-none-elf-objdump

ARCH    := -march=rv32imc_zicsr -mabi=ilp32
# Flags follow riscv-tests' benchmark flags (minus -ffast-math: no FP here), C level -O2.
CFLAGS  := $(ARCH) -O2 -g -static -std=gnu99 -fno-common -fno-builtin-printf \
           -fno-tree-loop-distribute-patterns -Isw/include
LDFLAGS := $(ARCH) -static -nostdlib -nostartfiles -T sw/link.ld -Wl,--no-warn-rwx-segments
RT      := sw/crt0.S sw/libc.c
LIBS    := -lgcc

# CoreMark: fixed iteration count for simulation (CoreMark/MHz = iterations / Mcycles)
COREMARK_ITER ?= 10
COREMARK_SRC  := $(addprefix coremark/,core_list_join.c core_main.c core_matrix.c core_state.c core_util.c) \
                 $(addprefix coremark_port/,core_portme.c ee_printf.c)
COREMARK_FLAGS := -Icoremark -Icoremark_port -DITERATIONS=$(COREMARK_ITER) -DPERFORMANCE_RUN=1 \
                  -DCOMPILER_FLAGS='"$(CFLAGS)"'

DHRY_SRC   := riscv-tests/benchmarks/dhrystone/dhrystone.c riscv-tests/benchmarks/dhrystone/dhrystone_main.c
DHRY_FLAGS := -Wno-implicit-int -Wno-implicit-function-declaration -std=gnu89 -Wno-return-type \
              -Wno-incompatible-pointer-types -Wno-int-conversion

# riscv-tests ISA subset (rv32 I/M/C): fence_i needs Zifencei (not in our ISA); ma_data tests
# misaligned access, which the cores handle differently by design.
ISA_UI := $(filter-out fence_i ma_data,$(basename $(notdir $(wildcard riscv-tests/isa/rv32ui/*.S))))
ISA_UM := $(basename $(notdir $(wildcard riscv-tests/isa/rv32um/*.S)))
ISA_UC := rvc
ISA    := $(addprefix rv32ui-,$(ISA_UI)) $(addprefix rv32um-,$(ISA_UM)) $(addprefix rv32uc-,$(ISA_UC))
ISA_INC := -Iisa_env -Iriscv-tests/isa/macros/scalar -Isw/include

ALL := hello dhrystone coremark $(ISA)
# Power-activity CoreMark: identical source and flags, 1 iteration (short SAIF window). Not part of
# ALL (not a pass/fail benchmark). make -C common/bench power
POWER := coremark_pwr
POWER_ITER := 1
.PHONY: all list clean power
all: $(addprefix $(OUT)/,$(addsuffix .hex,$(ALL)))
power: $(addprefix $(OUT)/,$(addsuffix .hex,$(POWER)))
list:
	@echo $(ALL)

$(OUT)/%.hex: $(OUT)/%.elf
	$(OBJCOPY) -O verilog $< $@
	$(OBJDUMP) -d $< > $(OUT)/$*.dis

$(OUT)/hello.elf: hello/hello.c $(RT) | $(OUT)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(RT) $< $(LIBS)

$(OUT)/coremark.elf: $(COREMARK_SRC) $(RT) | $(OUT)
	$(CC) $(CFLAGS) $(COREMARK_FLAGS) $(LDFLAGS) -o $@ $(RT) $(COREMARK_SRC) $(LIBS)

$(OUT)/coremark_pwr.elf: $(COREMARK_SRC) $(RT) | $(OUT)
	$(CC) $(CFLAGS) $(subst -DITERATIONS=$(COREMARK_ITER),-DITERATIONS=$(POWER_ITER),$(COREMARK_FLAGS)) $(LDFLAGS) -o $@ $(RT) $(COREMARK_SRC) $(LIBS)

$(OUT)/dhrystone.elf: $(DHRY_SRC) $(RT) | $(OUT)
	$(CC) $(CFLAGS) $(DHRY_FLAGS) $(LDFLAGS) -o $@ $(RT) $(DHRY_SRC) $(LIBS)

$(OUT)/rv32ui-%.elf: riscv-tests/isa/rv32ui/%.S | $(OUT)
	$(CC) $(ARCH) $(ISA_INC) $(LDFLAGS) -o $@ $<
$(OUT)/rv32um-%.elf: riscv-tests/isa/rv32um/%.S | $(OUT)
	$(CC) $(ARCH) $(ISA_INC) $(LDFLAGS) -o $@ $<
$(OUT)/rv32uc-%.elf: riscv-tests/isa/rv32uc/%.S | $(OUT)
	$(CC) $(ARCH) $(ISA_INC) $(LDFLAGS) -o $@ $<

$(OUT):
	mkdir -p $@

clean:
	rm -rf $(OUT)

# Initial results: Hazard3, Ibex, VeeR EL2 on SKY130 (core-only synthesis + RTL benchmarks)

Dwiti Suchak, Ayush. BITS Pilani. Data as of <!-- BEGIN collect.py:data_time -->2026-11-19 16:24 (IST)<!-- END collect.py -->.

## What was run

- **Scope:** core only (no memories, no pads). The padded chip top comes later. The core-only scope
  is the core plus a thin wrapper with identical ports for all three cores (adapters to a common
  64-bit memory interface, unused inputs tied to constants, unused outputs left open). Wrapping
  removes logic that only serves unused interfaces (e.g. VeeR's DMA slave, debug system bus and
  trace outputs), the same way for every core. The row marked "vendor top (old)" (VeeR "bp", a
  sensitivity point) is the first synthesis of VeeR's own top and will be redone with the wrapper.
- **Flow:** LibreLane 3.0.17 (Docker image), sky130A (open_pdks `8afc8346`), `sky130_fd_sc_hd`, LibreLane
  default synthesis settings (`SYNTH_STRATEGY = AREA 0`, flattened). Same flow and versions for all
  three cores (see `docs/VERSIONS.md`). Synthesis clock target 50 MHz.
- **ISA:** rv32imc_zicsr for all cores; unused features switched off where the core allows it.
- **Area** is Yosys cell area after technology mapping, before placement (no fill, taps or buffering).
- **Headline configs:** Hazard3 "default", Ibex "small", **VeeR EL2 "min"** (no tightly-coupled
  memories, no caches, branch predictor off).
- **fmax:** the table reports pre-layout estimates from post-global-placement timing at the
  typical corner. These are useful for comparison but are not routed, sign-off timing results.
  Routed SKY130 timing and sign-off status are reported separately in `results/harden_results.csv`.

## Synthesis (SKY130, core-only)

<!-- BEGIN collect.py:synth -->
| Core | Config | Synthesized top | Frontend | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | Latches | Pre-layout fmax estimate (MHz) |
|---|---|---|---|---:|---:|---:|---:|---:|---|
| Hazard3 | default | core + wrapper | Yosys read_verilog | 13,152 | 156,519 | 1.00× | 1,940 | 0 | 47.6 |
| Ibex | small | core + wrapper | yosys-slang | 11,922 | 150,477 | 0.96× | 1,924 | 1 | 49.3 |
| VeeR EL2 | min | core + wrapper | yosys-slang | 50,627 | 579,032 | 3.70× | 6,384 | 224 | 24.2 |
| VeeR EL2 | bp | vendor top (old) | yosys-slang | 61,383 | 720,779 | 4.61× | 8,521 | 305 | 20.1 |
<!-- END collect.py -->

## Benchmarks in RTL simulation

Same binaries for every core (GCC 15.2, `-march=rv32imc_zicsr -O2`), Verilator, a shared testbench
with a 1-cycle 64-bit memory. CoreMark: 10 iterations, all CRCs match the official values. Dhrystone:
riscv-tests version, 500 runs, DMIPS = Dhrystones/s / 1757. Test set: hello, Dhrystone, CoreMark
and the riscv-tests rv32ui/um/uc subset (failures explained under limitations).

<!-- BEGIN collect.py:sim_email -->
| Core | Config | Tests passed | CoreMark/MHz | DMIPS/MHz | Published CoreMark/MHz | Measured / published |
|---|---|---:|---:|---:|---:|---:|
| Hazard3 | default | 52/52 | 2.75 | 1.08 | 4.15 | 0.66 |
| Ibex | small | 52/52 | 2.23 | 0.83 | 2.47 | 0.90 |
| VeeR EL2 | no TCM (min) | 52/52 | 0.81 | 0.34 | 3.6 | 0.22 |
| VeeR EL2 | ICCM + DCCM (tcm) | 51/52 | 3.07 | 1.25 | 3.6 | 0.85 |
<!-- END collect.py -->

Published figures and why ours differ:
- **Hazard3** ([source](https://github.com/Wren6991/Hazard3#rp2350)): measured on the RP2350
  configuration with Zba/Zbb/Zbkb/Zbs, the faster multiplier, a branch predictor and heavily tuned
  GCC `-O3` flags. We have no bitmanip, no branch predictor, the single-cycle multiplier and `-O2`.
- **Ibex** ([source](https://github.com/lowRISC/ibex#configuration)): same "small" configuration, but
  compiled with `-O3 -funroll-all-loops -falign-functions=16`; we use `-O2` for every core.
- **VeeR EL2** ([source](https://www.westerndigital.com/company/newsroom/press-releases/2019/2019-12-10-western-digital-brings-memory-closer-to-compute-with-new-risc-v-innovations)):
  a simulated vendor figure; VeeR is built to run from its tightly-coupled memories. Without them
  ("min") every fetch goes over the AXI bus and VeeR is far slower. With ICCM + DCCM ("tcm", RTL
  simulation only) it is <!-- BEGIN collect.py:veer_tcm_ratio -->3.8<!-- END collect.py -->× faster and close to the published figure;
  the rest is `-O2` and its branch predictor being off.

## Configurations

| Core | Config name | Settings |
|---|---|---|
| Hazard3 (v1.1.1) | default | `hazard3_cpu_2port`; M with single-cycle multiplier (`MUL_FAST=1`), C, Zicsr + counters; A, debug, PMP, triggers, bitmanip, branch predictor off. 3-stage pipeline |
| Ibex | small | `ibex_top`, lowRISC "small" config: RV32IMC (Zca), 2-stage, `RV32MFast`, flop register file; PMP, B, I-cache, branch predictor, security features off |
| VeeR EL2 | min (primary) | `el2_veer` from `veer.config -target=typical_pd -fpga_optimize=0`; ICCM, DCCM, I-cache, U-mode, bitmanip, lockstep off; 1 interrupt; branch predictor off. 4-stage pipeline |
| VeeR EL2 | tcm (simulation only) | as `min`, plus ICCM (128 KiB at 0x0) and DCCM (128 KiB at 0x2_0000), behavioural memory models |
| VeeR EL2 | bp | as `min`, but with VeeR's typical_pd branch predictor (BTB 32, BHT 128, RAS 2) |

Frontend: Hazard3 is plain Verilog and uses Yosys' own reader. Ibex and VeeR use the yosys-slang
SystemVerilog frontend; sv2v isn't needed.

## Limitations so far (details in `docs/LIMITATIONS.md`)

1. **VeeR EL2 can't drop PMP or its debug module through its config.** `pmp_entries=0` doesn't
   elaborate (zero-sized arrays in the RTL), so VeeR carries 16 PMP entries and its debug module.
   Hazard3 and Ibex have neither. This inflates VeeR's area; a patch is possible.
2. **VeeR without tightly-coupled memories** (our fairness rule) loses most of its performance. ASIC
   results use "min" for now; "tcm" is simulation-only, so its SRAM area is not in any ASIC number.
   In "tcm", the riscv-test `rvc` fails because it loads data placed in its code section, which
   VeeR's load/store unit cannot read from ICCM by design.
3. **Two small RTL patches** are applied to build copies (vendor submodules untouched, reasons in
   `docs/DECISIONS.md`). Ibex: a lint-only signal rewritten so yosys-slang accepts it. VeeR: tie-off
   of ECC signals left undriven when DCCM is disabled.
4. **VeeR's clock gates** are its behavioural latch+AND model (counted as latches above); they should
   map to sky130 `dlclkp` integrated clock-gate cells for hardening.

## Next steps

1. SKY130 core-only RTL-to-GDS (DRC/LVS/antenna clean) for all three cores: running now, then a
   clock sweep per core.
2. Shared padded chip top (SRAM, UART, GPIO, sky130 I/O pad ring), proven on Hazard3 first.
3. FPGA (PYNQ), then SCL 180 nm once PDK access and tool rules are in place.

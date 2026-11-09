# Decisions

One entry per decision: date, decision, reason, who decided.

- 2026-11-06: Cores = Hazard3, Ibex, VeeR EL2 (professor).
- 2026-11-06: Software ISA = rv32imc_zicsr for all cores, because Ibex and VeeR EL2 can't disable C.
- 2026-11-06: Report two ASIC scopes: core-only macro and padded chip top.
- 2026-11-09: This round is SKY130 only; FPGA and SCL 180 deferred (Dwiti).
- 2026-11-09: ASIC flow runs on Dwiti's MacBook (arm64) through the LibreLane 3.0.17 Docker image; LibreLane's own Yosys step does the synthesis, so the synthesis numbers come from the same flow that will harden the cores (Claude Code).
- 2026-11-09: Pre-layout timing estimate = OpenROAD `repair_design` (max-fanout 10 / slew / cap buffering, no placement, liberty wire-load model) on LibreLane's synthesized netlist, then STA with LibreLane's default `base.sdc` (ideal clock, 0.25 ns uncertainty, 5% derate, IO delay 20% of period). Estimated fmax = 1 / (T − worst reg-to-reg slack), at tt_025C_1v80 and ss_100C_1v60. We use reg-to-reg because core-only IO delays are arbitrary. Reason: LibreLane synthesis doesn't buffer (it leaves that to placement), and the unbuffered netlist gives meaningless 400-fanout paths (Claude Code).
- 2026-11-09: Core-only synthesis tops are each core's vendor top with no memories. A shared thin wrapper with identical ports comes with the testbench (P1) and will be used for hardening (Claude Code).
- 2026-11-09: VeeR EL2 is configured with `veer.config -target=typical_pd -fpga_optimize=0` plus the overrides below. `fpga_optimize` defaults to 1, which removes all of VeeR's clock gating; that is wrong for ASIC, so it is off (Claude Code).
- 2026-11-09: VeeR EL2 is reported in two configs. `min` (primary, BTB off) matches Hazard3 and Ibex, which have no branch predictor. `bp` (typical_pd predictor: BTB 32 / BHT 128 / RAS 2) is a sensitivity point closer to how VeeR is normally built. **Dwiti/Ayush to confirm which one is the headline config** (Claude Code, pending).
- 2026-11-09: Hazard3 multiplier = `MUL_FAST=1` (single-cycle multiply, MULH via the sequential divider). It's the closest match to Ibex `RV32MFast` and VeeR's pipelined multiplier. Default `MUL_FAST=0` would give a much slower, 32+-cycle multiply (Claude Code).
- 2026-11-09: Frontends: Hazard3 = Yosys `read_verilog` (plain Verilog 2005; yosys-slang turns its static functions, called from two always blocks, into multiply-driven flops). Ibex and VeeR EL2 = yosys-slang (`USE_SLANG` in LibreLane). sv2v is not needed (Claude Code).

## Patches
| Core | Patch | Reason |
|---|---|---|
| Ibex | `cores/ibex/patches/0001-ibex_top-unused-scramble-assign.patch` | `logic unused_scramble_inputs = ...;` in `ibex_top.sv` is a lint-only variable with a declaration initialiser that reads nets; yosys-slang rejects it ("reading net state during design initialization unsupported"). The patch makes it a continuous `assign`, with no functional change (the signal is unused). Applied to a copy in `build/patched/`; the submodule is untouched. |

## Per-core configuration
| Core | Commit | Config / parameters | Pipeline stages | Disabled features |
|---|---|---|---|---|
| Hazard3 | 8af9929 (v1.1.1) | top `hazard3_cpu_2port`; `EXTENSION_A=0 EXTENSION_C=1 EXTENSION_M=1 CSR_COUNTER=1 DEBUG_SUPPORT=0 PMP_REGIONS=0 BREAKPOINT_TRIGGERS=0 MUL_FAST=1 MULH_FAST=0`; other parameters at defaults (no Zb*/Zc*, U-mode off, BRANCH_PREDICTOR=0, NUM_IRQS=1) | 3 (F/X/M) | A, debug, PMP, triggers, bitmanip, U-mode, branch predictor |
| Ibex | 626034d7 | top `ibex_top`; lowRISC "small" config: `RV32M=RV32MFast RV32B=RV32BNone RV32ZC=RV32Zca RegFile=RegFileFF BranchTargetALU=0 WritebackStage=0 ICache=0 BranchPredictor=0 DbgTriggerEn=0 DbgHwBreakNum=1 SecureIbex=0 PMPEnable=0 MHPMCounterNum=0` | 2 (IF/ID-EX) | B, PMP, I-cache, writeback stage, branch predictor, security features, debug triggers. Debug mode itself can't be removed from Ibex. |
| VeeR EL2 | 12e7adc | top `el2_veer` (core without `el2_mem` arrays and without the JTAG TAP/DMI wrapper); `cores/veer_el2/gen_config.sh` → `config/min`: `typical_pd`, `fpga_optimize=0`, `iccm_enable=0 dccm_enable=0 icache_enable=0 user_mode=0 lockstep_enable=0`, all bitmanip off, `pic_total_int=1`, `btb_enable=0`; AXI4 bus | 4 (per the VeeR EL2 PRM) | ICCM, DCCM, I-cache, U-mode, bitmanip, lockstep, BTB (in `min`). **PMP stays at 16 entries and the debug module stays in**: neither can be removed without RTL patches (see LIMITATIONS.md). |

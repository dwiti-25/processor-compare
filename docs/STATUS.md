# Status

Update at the start and end of every Claude Code session.

## Current (session 2026-11-18): FPGA handoff kit (P3, RUNSHEET Prompt 7)
### Plan
1. One PL shell for all cores (BRAM, MMIO and counters identical to the RTL testbench) + a top per core using the ASIC wrappers/configs.
2. Prove each top in Verilator over AXI4-Lite, the way the PS drives it: all 52 programs must match RTL sim exactly.
3. Vivado batch Tcl (one command per core), PYNQ notebook, fpga/README.md, collect.py FPGA table. Ayush runs Vivado and the board.

### Progress
- VeeR config `min_fpga` (= min + VeeR's fpga_optimize): RTL sim 52/52 identical to `min`, cycles included (DECISIONS.md 2026-11-18).
- FPGA sim (`fpga/sim/run_sim.sh <core>`): **Hazard3 52/52, Ibex 52/52, VeeR EL2 52/52** identical to RTL sim (exit, console, total and marked cycles). `results/raw/fpga/sim/<core>/summary.txt`.
- Written but **not run** (no Vivado on the Mac): `fpga/vivado/build.tcl`, `fpga/pynq/processor_compare.ipynb` (+ `runner.py`; its hex loader checked against `objcopy -O binary`), `scripts/collect.py --md fpga` (parsers tested only on synthetic report snippets).
- VeeR AXI adapter fix (bcb0f10): `axi2obi64` no longer adds a cycle to every response, so VeeR sees the same 1-cycle memory as Hazard3 and Ibex. VeeR min RTL sim 52/52, CoreMark CRCs correct, CoreMark **14,642,602 → 12,369,671** marked cycles (0.683 → 0.808 CoreMark/MHz), Dhrystone 1,005,172 → 849,645 (same 196,023 instructions); min_fpga still identical to min; tcm unchanged (51/52 as before). FPGA sim 52/52 identical with the new counts; notebook reference (`fpga/sw/manifest.json`) regenerated. VeeR CoreMark SAIF window 1,464,345 → 1,237,037 cycles. VeeR wrapped synthesis (`synth_min_wrap_50MHz`) **rerun with the new adapter** (no longer stale; old run in git at 293447d): cells 50,509 → 50,627, cell area 578,750 → 579,032 µm² (+0.05%). The old run was synthesis-only (low Docker memory); this one adds the pre-layout timing estimate (post-GPL, tt, ideal clocks): reg-to-reg WS −21.3 ns at 50 MHz, est. fmax 24.2 MHz (vendor top: 25.1). Critical path: LSU `addr_external_r` through a chain of `clkdlybuf4s25_1` fanout buffers (the known estimate artifact; layout excludes those cells). The new memory→VeeR paths are **not critical**: worst from the memory-response ports +9.17 ns to a flop (`i_rvalid`/`d_rvalid`), +14.3 ns from `d_rdata`, +14.8 ns from `i_rdata`, with a 4 ns input delay; `i_rvalid` also reaches a VeeR clock-gate latch with 1.44 ns time borrowing (met). `sta_postgpl/mem_in_paths.rpt`. Still to check post-layout and in Vivado (DECISIONS.md 2026-11-18). Report tables regenerated (`reports/initial_synthesis.md`/.pdf, `email_prof_draft.md`, `email_final.md`): these also still had the 2-cycle-adapter VeeR benchmark row (0.68 CoreMark/MHz → 0.81).
- Open: the board (Z1/Z2) and Vivado version are still blank in PROJECT_FACTS.md (same part, same bitstream either way). The two clock-gating mappings (Ibex BUFGCE, VeeR min_fpga) were approved by Dwiti on 2026-11-18.

## Previous (session 2026-11-10 evening → overnight, unattended)
### Plan (Dwiti's decisions, 2026-11-10 17:30)
1. Slew fix = post-route repair step (DECISIONS.md 2026-11-10): RCX → repair_design + repair_timing on extracted parasitics → re-route. Same for all cores. Verified on the Hazard3 @40 `_margin` design before launching.
2. Layout queue, one at a time, flow `HARDEN=1 PGRT=1 REPAIR_MARGIN=1 POSTROUTE=1 TAG=postroute`: Hazard3 @30 MHz → Ibex @30 MHz → VeeR EL2 min @30 MHz. Report fmax at tt (nom_tt_025C_1v80) and ss (nom_ss_100C_1v60). STATUS update + commit after each run.
3. While layouts run: realistic power prep: switching activity (SAIF) from a short CoreMark run per core (RTL sim, CoreMark timed window), plus an OpenSTA power script for the final netlist + SPEF; reports annotation coverage. No power numbers quoted until the layouts are final.
4. Pad ring: not started tonight; plan below.

### Progress tonight
- 17:00 Post-route repair step written and bench-tested on the Hazard3 @40 `_margin` design (DECISIONS.md). Approved cleanup of old build/ run dirs (diagnostics + vendor-top synth; reports kept in results/raw): 8.7 → 20 GiB free.
- 19:13 Power prep done: `SAIF=1 flows/sim.sh <core> coremark_pwr` (CoreMark, 1 iteration, SAIF over the timed window: Hazard3 363,251 / Ibex 448,506 / VeeR min 1,464,345 cycles, consistent with the RTL CoreMark/MHz); `flows/power.sh <core> <run>` = OpenSTA on final netlist + nom RCX SPEF at nom_tt, activity scaled to the run's clock; `collect.py` adds `power_coremark_tt_w` and register-annotation coverage. Tested on the old Hazard3 @40 layout: 1,939/1,940 register outputs annotated (number not quoted; that layout is superseded).
- 19:14 Running: Hazard3 @30 MHz post-route flow (`flows/run_layout.sh`, log `results/raw/sky130/queue.log`). Docker still 3.83 GiB: VeeR runs only if Docker ≥ 5.5 GiB by then (`run_layout.sh veer_el2 30 5.5`), else skipped and logged.
- 21:51 **Hazard3 @30 MHz, post-route flow** (`harden_default_wrap_30MHz_postroute`, 2 h 37 min; `collect.py`): fmax tt / ss / ss-maxRC = **61.0 / 30.5 / 29.9 MHz** (was 52.0 / 25.9 at the same target without the step). DRC 0/0, LVS 0, antenna 0, route DRC 0, hold met everywhere (+0.06 ns, ff). Setup met at nom_ss (+0.58 ns) and min_ss (+1.00); **max_ss_100C_1v60 still fails by −0.078 ns (4 paths)**. Max-slew 3,190 → 595 at the worst corner (max_ss; nom_ss 235, nom_tt 29), max-cap 5 → 2. **Not sign-off clean.** Repair step log (RCX view): slew 3,190 → 634 estimated, ss setup −6.27 → +0.03 ns; the remaining slews are on nets the one repair pass could not fix and on nets re-routed differently. CoreMark-activity power (nom_tt, 30 MHz, 1,939/1,940 register outputs annotated): **10.2 mW** (LibreLane default-activity figure for the same layout: 20.8 mW). Flow left unchanged for the other cores, so the comparison stays fair.
- 21:52 Ibex @30 MHz started, same flow.
- 23:24 **Ibex @30 MHz, post-route flow** (`harden_default_wrap_30MHz_postroute`, 1 h 32 min): fmax tt / ss / ss-maxRC = **52.7 / 29.6 / 28.9 MHz** (Ibex @40 without the step: 63.6 / 33.3, at a different target; see the fmax-vs-target note below). DRC 0/0, LVS 0, antenna 0, route DRC 0, hold met everywhere (+0.09 ns, ff). **Setup fails at nom_ss (−0.40 ns, 54 paths) and max_ss (−1.22 ns, 220 paths)**; min_ss passes (+0.21). Max-slew 4,020 → 881 at max_ss (nom_ss 345, nom_tt 51), cap 4. **Not sign-off clean.** Repair log: estimated ss setup −5.44 → +0.03 ns before re-route, so the re-route gives back ~0.4-1.2 ns. CoreMark-activity power (nom_tt, 30 MHz): **22.1 mW** with all 1,924/1,924 register outputs annotated (register-accurate mapping, 2026-11-11; the first figure that night, 20.4 mW with 1,775/1,924 by literal name matching, is superseded). LibreLane default-activity figure: 50.9 mW.
- 23:25 **VeeR EL2 min skipped**: Docker still 3.83 GiB (< 5.5 GiB gate). Nothing running.

### Summary for the morning (Dwiti)
| Core @30 MHz, post-route flow | fmax tt / ss (MHz) | Worst setup WS | Slew viol. (worst corner) | DRC/LVS/antenna/hold | CoreMark power, tt |
|---|---|---|---|---|---|
| Hazard3 | 61.0 / 30.5 | −0.08 ns (max_ss) | 595 | clean | 10.2 mW (1,940/1,940 regs, register-accurate mapping; rerun 2026-11-18, unchanged from literal matching) |
| Ibex | 52.7 / 29.6 | −1.22 ns (max_ss) | 881 | clean | 22.1 mW (1,924/1,924 regs, register-accurate mapping; was 20.4 with 1,775) |

All from `scripts/collect.py` (`results/harden_results.csv`). The post-route step works: it took ss setup from about −5 ns to within ~0.1-1.2 ns, and slew to about one fifth. Neither core is sign-off clean yet.

Decisions needed:
1. **Close the rest**: (a) a second repair pass (RCX → repair → re-route ×2), the same for all cores; costs ~1 h extra per core; most likely to close Hazard3, probably Ibex. (b) Sign off at a lower clock (e.g. 25 MHz). Note: the ss slews don't depend on the clock, so (b) alone may still leave slew violations. (c) Report the current numbers with the ss slew/setup gap as a limitation of the open flow.
2. **Docker memory** to ≥ 6 GB for VeeR (still 3.83 GiB tonight). Then `flows/run_layout.sh veer_el2 30 5.5`, then `flows/power.sh veer_el2 harden_min_wrap_30MHz_postroute` (SAIF already dumped).
3. ~~Ibex power annotation~~ **done 2026-11-11** (`flows/actmap.py`, DECISIONS.md): all 1,924 Ibex registers annotated; Ibex CoreMark power 20.4 → **22.1 mW**. ~~Hazard3~~ **done 2026-11-18**: rerun with the register-accurate mapping, 1,940/1,940 registers annotated, CoreMark power still **10.2 mW** (DECISIONS.md 2026-11-18). VeeR still to do, the same way.

Also: fmax depends on the target clock (timing repair stops at the target), so the final fmax should come from a sweep point near each core's ss fmax.

### Pad-ring plan (P4, not started)
1. Shared chip top in `common/chiptop/`: core wrapper + small on-chip SRAM (OpenRAM sky130 macro, e.g. 2× `sky130_sram_1kbyte_1rw1r_32x256_8`) + UART + 8 GPIO + clk/rst; ≤32 signal pads, identical for every core.
2. I/O: `sky130_fd_io` signal pads (`sky130_ef_io__gpiov2_pad_wrapped`), vccd/vssd/vddio/vssio power pads, corner and filler cells, placed with OpenROAD's pad placement (ICeWall, LibreLane `pad.tcl`). Pad-limited die, same die and pad order for all three cores.
3. Prove on Hazard3 first (DRC/LVS/antenna clean, GLS hello through the pads), then reuse unchanged for Ibex and VeeR.
4. Still open with the professor: own pad ring vs Caravel harness (decides whether step 2 is needed at all).

## Previous (end of session, 2026-11-10 morning)
- Phase: P1 done (RTL benchmarks); P2 (SKY130 core-only layout) in progress. FPGA and SCL 180 deferred.
- Running: nothing. Docker idle.
- Email to the professor: `reports/email_final.md` + `reports/initial_synthesis.pdf` (data 2026-11-10 02:02 IST). Ready for Dwiti to check against the tool reports and send. Not sent.

### Pending decisions (Dwiti)
1. **Slow-corner (ss) slew/setup fix for layout.** After all fixes so far, ss still has ~2,200-3,600 max-slew violations and failing setup, for both Hazard3 and Ibex. Cause: design repair works from pre-route parasitic estimates; post-route RCX wire loads are much larger (e.g. a clkbuf_1 driving 105 fF of routed wire, 1.33 ns slew at nom_tt), and LibreLane Classic has no repair after detailed routing. Relaxing the clock does not help (Hazard3 @30 MHz came out worse than @40). Options:
   - (a) **recommended:** add a post-route repair step (OpenROAD repair_design/repair_timing on RCX parasitics + ECO detailed route; a custom LibreLane step);
   - (b) larger pre-route repair margins (e.g. 50%; cheap, may not be enough);
   - (c) document ss slew as an open-flow limitation and sign off timing at a relaxed clock.
2. **Raise Docker Desktop memory to 6-8 GB** (currently 3.8 GB). Needed for VeeR EL2 layout (Hazard3 routing peaked at 2 GiB for ~22k cells; VeeR min is ~3.8x larger). VeeR layout was skipped for this reason.

Also open with the professor (questions in the email): VeeR with/without TCMs, VeeR PMP/debug patching, SCL 180 access/tools/AI permission, own pad ring vs Caravel.

### Current results (all generated by `scripts/collect.py`)
Synthesis (core + wrapper, SKY130, 50 MHz target): `reports/initial_synthesis.md` / `results/results.csv`.

RTL simulation (`collect.py --md sim`, `results/sim_results.csv`):

| Core | Config | Tests passed | CoreMark/MHz | Dhrystone cycles/run | DMIPS/MHz |
|---|---|---:|---:|---:|---:|
| Hazard3 | default | 52/52 | 2.753 | 528.1 | 1.078 |
| Ibex | small | 52/52 | 2.23 | 687.1 | 0.828 |
| VeeR EL2 | min | 52/52 | 0.808 | 1699.3 | 0.335 |
| VeeR EL2 | tcm | 51/52 | 3.072 | 454.1 | 1.253 |

Core-only layout (`collect.py --md harden`, `results/harden_results.csv`; abridged columns). The current flow settings are in DECISIONS.md; `_baseline`, `_nodlybuf`, `_pgrt`, `_multicorner` are the diagnostic runs from tonight:

| Core | Clock (MHz) | Flow settings | fmax tt / ss (MHz) | Setup WS tt / ss / ff (ns) | Setup viol. | Hold WS (ns) | Slew / cap viol. | Sign-off clean (all corners) |
|---|---:|---|---|---|---:|---:|---|---|
| Hazard3 | 30 | exclude clkdlybuf4s*, post-GRT repair, wire-length 400um + 30% repair margin + CTS cluster 10 | 52.0 / 25.9 | +11.91 / -5.21 / +17.20 | 307 | +0.06 | 3190 / 5 | no |
| Hazard3 | 40 | LibreLane defaults (baseline) | 65.9 / 34.3 | +8.25 / -4.13 / +11.70 | 1375 | +0.11 | 5707 / 36 | no |
| Hazard3 | 40 | exclude clkdlybuf4s*, post-GRT repair, wire-length 400um + 30% repair margin + CTS cluster 10 | 67.0 / 34.5 | +8.53 / -3.98 / +12.34 | 716 | +0.09 | 2795 / 3 | no |
| Hazard3 | 40 | exclude clkdlybuf4s*, post-GRT repair, wire-length 400um + 30% repair margin + CTS cluster 10, multi-corner PnR (tt/ss/ff) | 67.0 / 34.5 | +8.53 / -3.98 / +12.34 | 716 | +0.09 | 2795 / 3 | no |
| Hazard3 | 40 | exclude clkdlybuf4s* | 66.7 / 34.2 | +8.50 / -4.22 / +12.12 | 758 | +0.10 | 5903 / 68 | no |
| Hazard3 | 40 | exclude clkdlybuf4s*, post-GRT repair | 66.6 / 34.2 | +8.47 / -4.25 / +12.30 | 750 | +0.10 | 5647 / 50 | no |
| Ibex | 40 | exclude clkdlybuf4s*, post-GRT repair, wire-length 400um + 30% repair margin + CTS cluster 10 | 63.6 / 33.3 | +7.23 / -5.06 / +7.36 | 3667 | +0.10 | 3652 / 1 | no |

Reported layout power uses LibreLane's default switching activity, not a benchmark VCD. Don't quote it until checked (Ibex 68 mW vs Hazard3 28 mW looks suspicious).

### Next steps
1. Implement the ss slew fix chosen in decision 1; re-run Hazard3 @40 MHz first, then Ibex.
2. Once ss closes: clock sweep per core (3 points around the ss fmax), and quote fmax from runs whose target is near the achieved fmax.
3. After Docker memory is raised: VeeR min wrapped synthesis + timing estimate + layout (same settings).
4. Power from benchmark activity (GLS VCD, P6) instead of default activity.
5. ~~Then P4: padded chip top (pads, SRAM, UART, GPIO), Hazard3 first; then FPGA (needs the x86 Vivado PC) and SCL 180 (needs PDK access + rules in PROJECT_FACTS.md).~~ **Superseded** by the 2026-11-18 section (FPGA kit built; Vivado/board runs with Ayush). P4 and SCL 180 are still to do; the P4 plan is under "Pad-ring plan".
6. Housekeeping: delete unused flows/{estimate.sh, est_env.py, sta_estimate.tcl, sta_prelayout.tcl, yosys_synth.ys.in} (permission was denied to Claude); fill in docs/PROJECT_FACTS.md.

## Plan for P1 (2026-11-09): benchmarks in RTL sim
1. Shared memory map: RAM at 0x0 (entry 0x80), MMIO at 0x8000_0000: putchar, exit, cycle-count start/stop markers.
2. One wrapper per core (`cores/<core>/wrapper/`) with identical simple instruction and data ports; Hazard3 AHB, Ibex OBI and VeeR AXI4 adapt in the wrapper.
3. `common/tb`: fixed-latency dual-port memory model + MMIO + cycle counter, Verilator top shared by all cores.
4. `common/bench`: hello, riscv-tests rv32ui/um/uc, Dhrystone, CoreMark, one Makefile with identical flags (rv32imc_zicsr).
5. Run all on all three cores; report cycles and CoreMark/MHz vs published figures. No layout runs (P2) until Docker memory is raised (Dwiti).

## Log
- 2026-11-06: Professor confirmed Hazard3, Ibex, VeeR EL2; SKY130 + SCL 180 with I/O pads. Repo kit created.
- 2026-11-09: Tools installed on the MacBook (see VERSIONS.md). LibreLane runs on macOS through its Docker image (`flows/librelane.sh`); `--dockerized` needs a TTY, so we call `docker run` directly.
- 2026-11-09: Flow smoke test passed: 16-bit counter to GDS (`flows/smoke/counter`): Magic DRC 0, KLayout DRC 0, LVS clean, antenna 0, setup WNS +12.68 ns / hold WNS +0.12 ns at 50 MHz across all corners. 11 max-slew warnings at max_ss_100C_1v60 only.
- 2026-11-09: Submodules pinned: Hazard3 8af9929 (v1.1.1), Ibex 626034d7, VeeR EL2 12e7adc. All Apache-2.0.
- 2026-11-09: All three cores elaborate in Yosys. Hazard3 uses Yosys read_verilog (yosys-slang mis-handles its static functions), Ibex and VeeR use yosys-slang. Ibex needs one patch; VeeR needs `-fpga_optimize=0` (see DECISIONS.md).
- 2026-11-09: Core-only synthesis at 50 MHz done for all three cores (+ VeeR bp variant) through LibreLane's Yosys step; table in `reports/initial_synthesis.md` (generated by `scripts/collect.py`). Email draft in `reports/email_prof_draft.md` (not sent).
- 2026-11-09: Timing-estimate method changed twice, for cause (see DECISIONS.md). (1) Netlist-only STA: unbuffered nets, meaningless. (2) OpenROAD repair without placement: left VeeR's 8,264-fanout reset unrepaired. (3) Final: LibreLane flow to post-GPL repair + STA with ideal clocks, plus a post-CTS + timing-repair stage. Post-GPL numbers are pessimistic, VeeR's especially (delay-cell fanout buffers).
- 2026-11-09: Patches: Ibex 0001 (yosys-slang declaration initialiser), VeeR 0001 (undriven ECC bits with DCCM off). VeeR needed `fpga_optimize=0`, which veer.config otherwise defaults to 1 (no clock gating).

## Passed / failed / running / next
- Passed: tool install; counter smoke to GDS; core + wrapper synthesis of all three cores; RTL sim: Hazard3, Ibex, VeeR min 52/52, VeeR tcm 51/52 (rvc expected failure); CoreMark CRCs correct on all; Hazard3 and Ibex layouts DRC/LVS/antenna clean, hold met.
- Failed: layout sign-off at the ss corner (setup + max slew) for Hazard3 and Ibex; see pending decision 1.
- Running: nothing.
- Next: see "Next steps" above.

## Machine
LibreLane installs and runs on this MacBook Air M3 (Docker image, arm64). The whole SKY130 flow
(synthesis → GDS → DRC/LVS) works here: the counter went through all 76 steps. Limits: 8 GB RAM,
Docker VM capped at 3.8 GB, 30 GB free disk. Hazard3/Ibex hardening should be fine. VeeR (≈57k cells,
~0.65 mm² cell area) should fit, but routing/DRC will be slow and memory-tight. For the overnight
clock sweep (3 cores × 3 points) a Linux x86 box with ≥16 GB RAM and ≥8 cores (BITS lab server or
cloud VM) would be much faster. Raising Docker Desktop's memory limit to ~6 GB is the cheap fix here.
- 2026-11-09: Wrapped (core + thin wrapper) synthesis for Hazard3 and Ibex; the report now prefers wrapped rows. VeeR wrapped synthesis is still to run.
- 2026-11-09: P1: common wrappers, testbench and benchmarks built. Hazard3 and Ibex pass all 52 programs (hello, Dhrystone, CoreMark, 49 riscv-tests). The Ibex hang was a TB bug: rst_n started at 0 with no falling edge, so Ibex's async-reset flops behind its clock gate never reset (priv level came up as U-mode). Fixed in tb_top.
- 2026-11-10: VeeR wrapper fixed (mpc_reset_run_req=1; generator handles multi-dim ports and the ifdef'd regfile port). All three cores pass all 52 programs, and CoreMark CRCs match the official 2K performance values on all three. CoreMark/MHz and DMIPS/MHz come from `scripts/collect.py --md sim` (results/sim_results.csv). VeeR is ~5× below its usual published CoreMark/MHz because TCMs/I-cache are off; see LIMITATIONS.md. Needs a decision.
- 2026-11-10: Old-top VeeR min and wrapped Ibex post-CTS estimates stopped (Dwiti); timing will come from the layout runs. Report/PDF/email use wrapped synthesis for all three headline cores.
- 2026-11-10: Core-only layout (LibreLane Classic, default settings, FP_CORE_UTIL 50%) started on Dwiti's go-ahead. Hazard3 @ 40 MHz reached GDS: Magic/KLayout DRC 0, LVS 0, antenna 0, hold met in all corners, setup met at tt/ff but **violated at ss** (nom_ss -4.13 ns, max_ss -5.19 ns; 1,375 paths), plus 5,707 max-slew / 36 max-cap violations. Per CLAUDE.md: clock relaxed, Hazard3 re-run queued at 30 MHz (after Ibex @ 40 MHz). No checks changed.
- 2026-11-10: **VeeR min core-only layout skipped tonight (memory).** Hazard3 detailed routing peaked at 2 GiB RSS for ~22k cells; VeeR min is ~3.8x larger, so routing would very likely exceed Docker's 3.8 GiB limit. Rerun once Dwiti raises Docker memory (target 6-8 GB).
- 2026-11-10: Root cause of Hazard3's 5,707 max-slew / 36 max-cap violations: OpenROAD design repair used `sky130_fd_sc_hd__clkdlybuf4s25_1` (a clock *delay* cell, weak drive) as its fanout buffer 1,169 times; slews up to 1.3 ns already at nom_tt (limit 0.75 ns), worse at ss. LibreLane excludes these cells from synthesis but not from PnR. Fix: `EXTRA_EXCLUDED_CELLS = sky130_fd_sc_hd__clkdlybuf4s*` for all layout runs (flows/synth.sh HARDEN). Also seen: 57 max-fanout violations (mostly CTS leaf buffers driving 12 sinks > 10). Baseline run kept as `harden_default_wrap_40MHz_baseline`. Hazard3 @40 MHz re-running with the fix; post-GRT multi-corner repair (LibreLane: experimental) only if violations remain.
- 2026-11-10: Note: LibreLane's default sign-off checkers only flag setup at `*tt*` corners and don't flag slew/cap at all (MAX_SLEW/CAP_VIOLATION_CORNERS = ['']), so "Flow complete" is not sign-off. `collect.py` judges sign-off over all nine corners (setup, hold, slew, cap, DRC, LVS, antenna).
- 2026-11-10 (night): Slew/cap root cause, refined. (1) Excluding clkdlybuf cells removed them but did not reduce slew violations; repair then used buf_1/clkbuf_1. (2) Post-GRT multi-corner repair ran (no hang) but barely helped (5,647 vs 5,707). (3) Mid-PnR STA after GRT + antenna repair shows 0 slew violations at nom_tt, while post-route STA with RCX shows 1,292: the violations appear only with extracted parasitics, and the Classic flow has no design repair after detailed routing. Example: net682, clkbuf_1 driving 105 fF of routed wire (10 fF of pins), 1.33 ns slew at nom_tt. Running now: Hazard3 @40 MHz with max wire length 400 um, 30% repair slew/cap margins (sign-off limits unchanged) and CTS sink clustering 10. Kept runs: _baseline, _nodlybuf, _pgrt.
- 2026-11-10 04:40: Margin run (_margin): worst-corner slew 5,707 -> 2,795, nom_tt slew 147, cap 36 -> 3, fanout 49 -> 2; ss still bad (2,187 slew, setup -3.98 ns). **Second root cause confirmed in LibreLane code: `corners = PNR_CORNERS or [DEFAULT_CORNER]`**, so with PNR_CORNERS unset all PnR steps (repair, CTS, timing repair) see only nom_tt; the slow corner is never optimised. Running: Hazard3 @40 MHz with PNR_CORNERS = nom_tt, nom_ss, max_ss, nom_ff, min_ff (plus the margin settings).
- 2026-11-10 05:25: **Correction:** the "PnR only sees nom_tt" finding was wrong. `PNR_CORNERS or [DEFAULT_CORNER]` is only the default; LibreLane's resizer and CTS steps pass `RSZ_CORNERS or STA_CORNERS` / `CTS_CORNERS or STA_CORNERS`, and the logs show all 9 corners loaded in every run, baseline included. The PNR_CORNERS run (_multicorner) is bit-identical to _margin. Root cause stands as the pre-route-estimate vs post-route-RCX parasitic gap with no post-detailed-route repair in the Classic flow; ss suffers most. Best settings so far (_margin): worst-corner slew 5,707 -> 2,795, cap 36 -> 3, fanout 49 -> 2, nom_tt slew 147; ss slew 2,187 remain. Not sign-off clean.
- 2026-11-10 05:25: Running: Ibex @40 MHz (core + wrapper) with the _margin settings, then Hazard3 @30 MHz with the same settings (ss timing-closure attempt). VeeR skipped (memory).
- Options to close slew at ss (need a decision): (a) add a post-route repair step (OpenROAD repair_design on RCX parasitics + ECO detailed routing; not in LibreLane Classic, would need a custom step); (b) larger pre-route repair margins (e.g. 50%); (c) report ss slew as a limitation of the open flow and sign off timing at a relaxed clock.
- 2026-11-10 06:30: Ibex @40 MHz (margin settings): fmax tt/ss 63.6/33.3 MHz, DRC/LVS/antenna 0, hold met, setup fails at ss (-5.06 ns, 3,667 paths), slew/cap 3,652/1. Not sign-off clean. Reported power (Ibex 68.1 mW vs Hazard3 27.9 mW) uses LibreLane's default activity, not a benchmark VCD; check before reporting.
- 2026-11-10 06:30: Hazard3 @30 MHz (margin settings) came out **worse** than @40: fmax tt/ss 52.0/25.9 MHz, ss setup -5.21 ns, ss slew 2,545. At a looser target, timing repair does less work and the ss slews (unchanged problem) stretch ss paths. Conclusions: (1) relaxing the clock cannot close ss until the post-route slew problem is fixed; (2) fmax derived from slack depends on the target, so quote fmax from the run whose target is closest to it (Hazard3: the 40 MHz run). Nothing further queued; waiting on Dwiti's choice of slew fix (post-route repair recommended) and Docker memory for VeeR.

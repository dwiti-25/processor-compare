# Status

Update at the start and end of every Claude Code session.

## Current
- Phase: P0 (setup + initial synthesis), SKY130 only (FPGA and SCL 180 deferred by Dwiti, 2026-11-09)
- Running in background: core-only synthesis at 50 MHz via `flows/synth.sh` (log: `build/synth50.console.log`)
- Blocked on: none

## Plan for P0 (2026-11-09)
1. Install tools in user space on Dwiti's MacBook (OSS CAD Suite, LibreLane 3.0.17 via Docker, sky130A via ciel, GCC, sv2v); prove the flow with a counter to GDS.
2. Add Hazard3, Ibex and VeeR EL2 as pinned submodules; choose configs per the CLAUDE.md rules.
3. Synthesize core-only at 50 MHz with LibreLane's Yosys step; timing estimate with OpenROAD.
4. `scripts/collect.py` → `results/results.csv` → `reports/initial_synthesis.md` + email draft.

## Log
- 2026-11-06: Professor confirmed Hazard3, Ibex, VeeR EL2; SKY130 + SCL 180 with I/O pads. Repo kit created.
- 2026-11-09: Tools installed on the MacBook (see VERSIONS.md). LibreLane runs on macOS through its Docker image (`flows/librelane.sh`); `--dockerized` needs a TTY, so we call `docker run` directly.
- 2026-11-09: Flow smoke test passed: 16-bit counter to GDS (`flows/smoke/counter`): Magic DRC 0, KLayout DRC 0, LVS clean, antenna 0, setup WNS +12.68 ns / hold WNS +0.12 ns at 50 MHz across all corners. 11 max-slew warnings at max_ss_100C_1v60 only.
- 2026-11-09: Submodules pinned: Hazard3 8af9929 (v1.1.1), Ibex 626034d7, VeeR EL2 12e7adc. All Apache-2.0.
- 2026-11-09: All three cores elaborate in Yosys. Hazard3 uses Yosys read_verilog (yosys-slang mis-handles its static functions), Ibex and VeeR use yosys-slang. Ibex needs one patch; VeeR needs `-fpga_optimize=0` (see DECISIONS.md).

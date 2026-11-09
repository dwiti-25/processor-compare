# Plan (updated 6 Nov 2026 after the professor's reply)

## Goal
Hazard3, Ibex and VeeR EL2 through FPGA (PYNQ), SKY130 RTL-to-GDS with pads,
and SCL 180 nm RTL-to-GDS with pads, compared on area, timing and power using
the same benchmarks. Output: results tables, limitation notes, a paper, and
one core tape-out-ready.

## Result grid (every cell gets a number or a limitation note)

| | Hazard3 | Ibex | VeeR EL2 |
|---|---|---|---|
| Yosys synth, SKY130 | | | |
| RTL sim + CoreMark/Dhrystone | | | |
| FPGA (PYNQ): LUT/FF/BRAM, fmax, power, cycles | | | |
| SKY130 core-only GDS: area, fmax, power | | | |
| SKY130 padded chip GDS: area, fmax, power | | | |
| SKY130 gate-level sim | | | |
| SCL 180 synth | | | |
| SCL 180 core-only layout | | | |
| SCL 180 padded chip layout | | | |

## Priority order (if time runs out, cut from the bottom)

1. **P0**: tools installed; Yosys synthesis of all three on SKY130 → initial synthesis report to the prof
2. **P1**: shared testbench; CoreMark + Dhrystone cycle counts on all three in RTL sim
3. **P2**: SKY130 core-only hardening of all three, clock sweep (overnight)
4. **P3**: FPGA builds of all three on PYNQ + board run
5. **P4**: SKY130 padded chip top (shared top, all three cores)
6. **P5**: SCL 180 synthesis, then layout (depends on PDK access)
7. **P6**: gate-level sim, post-layout power from VCD, results tables, paper draft
8. **P7** (stretch): tape-out prep for the best core on the college's chosen shuttle

## Known risks
- **VeeR EL2 is the largest core and uses heavy SystemVerilog.** It's the most
  likely to fail in Yosys or miss timing. Check it first in P0.
- **The SCL 180 PDK is under NDA, and access may take days.** Start the request now.
- **Pad ring on SKY130 is more manual than core hardening.** Prove it on Hazard3
  first, then reuse it.
- **Vivado can't run on the Mac.** It needs an x86 lab PC.

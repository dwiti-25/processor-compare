# Professor's brief

## Email (verbatim)

> Dear Dwiti and Ayush,
> Please proceed with the three RISC-V processors (Hazard3, Ibex, and VeeR EL2) for a fair comparison using the same benchmarks.
> The objective is to complete FPGA implementation followed by the RTL-to-GDS flow, including I/O pads, using SkyWater 130 nm and then SCL 180 nm technology. Please evaluate all three processors in both technologies, wherever feasible, and compare the results in terms of area, timing, and power.
> You may use the PYNQ board for FPGA implementation and continue setting up Yosys and OpenLane in parallel. If you encounter any limitations in implementing a core in either technology, please document them and discuss them with me.
> Please share the initial synthesis results once available.
> Regards,
> Govind Prasad

## Requirements extracted

| # | Requirement | Where it's handled |
|---|---|---|
| R1 | Three cores: Hazard3, Ibex, VeeR EL2 | CLAUDE.md core table |
| R2 | Fair comparison, same benchmarks | CLAUDE.md fair-comparison rules |
| R3 | FPGA implementation on PYNQ first | Run sheet, FPGA blocks |
| R4 | RTL-to-GDS including I/O pads, SKY130 | Padded chip-top scope |
| R5 | Then RTL-to-GDS including I/O pads, SCL 180 nm | SCL rules + run sheet |
| R6 | All three cores in both technologies, wherever feasible | results.csv covers every (core × tech) cell |
| R7 | Compare area, timing, power | collect.py + paper tables |
| R8 | Set up Yosys/OpenLane in parallel with FPGA | Run sheet, day 1 |
| R9 | Document limitations and discuss them | docs/LIMITATIONS.md + reports/ |
| R10 | Share initial synthesis results soon | reports/initial_synthesis.md, first priority |

## Questions to raise with the professor (with the synthesis results)

1. SCL 180 nm PDK: how do we get access, which tools does it support (open
   flow or Cadence), and may we use AI coding tools on the PDK files?
2. I/O pads on SKY130: our own pad ring using sky130_fd_io cells, or the Caravel
   harness (the shuttle frame)? Caravel matters only if we tape out via
   ChipFoundry.
3. Chip top: is a small on-chip SRAM + UART + GPIO top acceptable, with core-only
   macro results reported separately?
4. Which tape-out shuttle and deadline does the college have in mind?

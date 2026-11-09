**To:** Prof. Govind Prasad
**From:** Dwiti Suchak, Ayush
**Subject:** Initial synthesis results: Hazard3, Ibex, VeeR EL2 on SKY130

Dear Sir,

Please find below our initial synthesis results for the three cores on SkyWater 130 nm. All three
are synthesized core-only (no memories or pads) with the same open-source flow (LibreLane 3.0.17,
Yosys, OpenROAD, sky130_fd_sc_hd standard cells), the same 50 MHz clock target, and rv32imc_zicsr
configurations with unused features disabled.

<!-- BEGIN collect.py --md synth -->
| Core | Config | Frontend | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | Latches | Est. fmax, post-CTS, tt (MHz) | Reg-to-reg slack @ target, post-CTS (ns) | Est. fmax, post-GPL, tt (MHz) |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Hazard3 | default | Yosys read_verilog | 12,823 | 152,032 | 1.00× | 1,849 | 0 | pending | pending | 49 |
| Ibex | default | yosys-slang | 12,173 | 152,431 | 1.00× | 1,950 | 1 | pending | pending | 48 |
| VeeR EL2 | min | yosys-slang | 56,639 | 650,156 | 4.28× | 7,071 | 258 | pending | pending | 25 |
| VeeR EL2 | bp | yosys-slang | 61,383 | 720,779 | 4.74× | 8,521 | 305 | pending | pending | 20 |
<!-- END collect.py -->

Notes:
- Area is standard-cell area after synthesis. The fmax figures are early, pessimistic estimates
  (after placement but before timing optimisation, typical corner). Numbers after clock-tree
  synthesis and timing optimisation will follow in a few days, and full RTL-to-GDS results after that.
- VeeR EL2 "min" has its branch predictor off, to match Hazard3 and Ibex; "bp" keeps VeeR's
  standard predictor. VeeR's configuration cannot remove its PMP unit (16 entries) or its debug
  module, which partly explains its larger area. We have documented this as a limitation.
- Next: benchmark simulation (CoreMark, Dhrystone) on all three cores, then core-only RTL-to-GDS
  on SKY130, then the padded chip top.

We would be grateful for your guidance on a few points:

1. **SCL 180 nm PDK:** how do we get access, which tools does it support (open-source flow or
   Cadence), and may we use AI coding tools on the PDK files?
2. **I/O pads on SKY130:** should we build our own pad ring with the sky130_fd_io cells, or use the
   Caravel harness? Caravel matters only if we tape out via ChipFoundry.
3. **Chip top:** is a small on-chip SRAM + UART + GPIO top acceptable, with core-only macro results
   reported separately?
4. **Tape-out:** which shuttle and deadline does the college have in mind?

Thank you.

Regards,
Dwiti Suchak and Ayush

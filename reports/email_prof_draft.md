**To:** Prof. Govind Prasad
**From:** Dwiti Suchak, Ayush
**Subject:** Initial synthesis results: Hazard3, Ibex, VeeR EL2 on SKY130

Dear Sir,

Please find below our initial synthesis results for the three cores on SkyWater 130 nm. All three
are synthesized core-only (no memories or pads) with the same open-source flow (LibreLane 3.0.17,
Yosys, OpenROAD, sky130_fd_sc_hd standard cells), the same 50 MHz clock target, and rv32imc_zicsr
configurations with unused features disabled.

<!-- BEGIN collect.py:headline -->
| Core | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | fmax |
|---|---:|---:|---:|---:|---|
| Hazard3 | 13,152 | 156,519 | 1.00× | 1,940 | pending, will come from full layout |
| Ibex (small) | 11,922 | 150,477 | 0.96× | 1,924 | pending, will come from full layout |
| VeeR EL2 (min) | 50,627 | 579,032 | 3.70× | 6,384 | pending, will come from full layout |
<!-- END collect.py -->

\* Pre-route estimate at the typical corner (25 °C, 1.8 V): after placement, clock-tree synthesis and
timing optimisation, but before routing. The remaining estimates are still running and will
follow; signed-off post-route numbers will come from the full RTL-to-GDS runs.

Notes:
- Area is standard-cell area after synthesis (before placement).
- VeeR EL2 is shown with its branch predictor off, to match Hazard3 and Ibex, which have none.
  With VeeR's standard predictor on, its area grows further; we will report that as a separate
  data point.
- VeeR's configuration cannot remove its PMP unit (16 entries) or its debug module, which partly
  explains its larger area. We have documented this as a limitation and can patch it out for a
  strictly like-for-like comparison if you prefer.
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

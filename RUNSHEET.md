# Run sheet: paste one prompt per Claude Code session

Start Claude Code in the repo folder (`claude`). Paste **Prompt 0** at the start
of every session, then the next prompt in order. Steps marked **[YOU]** are ones
only you can do. If time runs out, cut from the bottom of `docs/PLAN.md`'s
priority list, not from the top.

---

## Prompt 0: start of every session
> Read CLAUDE.md and everything in docs/. Tell me in 5 lines or fewer: where we
> are, what's running, and anything missing or contradictory in PROJECT_FACTS.md.
> Then wait for my next prompt.

---

## Block 1: setup + initial synthesis for the prof (P0) — do this first

**[YOU], today:**
- Fill in `docs/PROJECT_FACTS.md`.
- Create the GitHub repo and run `gh auth login`.
- Start the Vivado install on the x86 lab PC.
- Ask the lab or the prof for SCL 180 PDK access, and whether AI tools may read the PDK files.

**Prompt 1: environment**
> Set up the SKY130 ASIC environment on this machine: OSS CAD Suite, LibreLane
> with sky130A via ciel, KLayout, sv2v, a RISC-V GCC toolchain that can target
> rv32imc_zicsr, and Perl. Use user-space installs where possible; ask before
> sudo. Record versions in docs/VERSIONS.md. Create the repo layout and a
> Makefile skeleton from CLAUDE.md. Prove the flow by hardening a small counter
> to GDS with LibreLane and report DRC/LVS/timing. If anything fails, stop and
> tell me exactly what.

**Prompt 2: three cores + Yosys synthesis**
> Add Hazard3, Ibex and VeeR EL2 as pinned submodules under cores/. For each,
> confirm licence and HDL dialect. Choose a config per the CLAUDE.md rules
> (rv32imc_zicsr, unused features off; for VeeR, generate the config with
> veer.config and disable ICCM/DCCM/I-cache if the core allows it). Log each
> config in docs/DECISIONS.md. Get each core through Yosys: use direct read,
> sv2v or Slang, whichever works, and note which in DECISIONS.md. Synthesize
> core-only on sky130_fd_sc_hd at a 50 MHz target and collect cell count, cell
> area, flop count and a pre-layout timing estimate with OpenSTA. Put every
> failure in docs/LIMITATIONS.md. Start with VeeR EL2, since it's the most
> likely to fail.

**Prompt 3: report + email to the prof**
> Write reports/initial_synthesis.md: one table (core, config, frontend used,
> cells, area µm², flops, estimated fmax), plus short notes on limitations so
> far and our next steps. Every number must come from scripts/collect.py. Then
> draft a short email to Prof. Govind Prasad from Dwiti and Ayush with that
> table and the 4 questions in docs/PROF_BRIEF.md. Show me the draft; don't send
> anything.

**[YOU]:** check the numbers against the Yosys/OpenSTA reports, then send the email.

---

## Block 2: benchmarks in RTL sim (P1)

**Prompt 4**
> Build common/tb: a fixed-latency memory model, MMIO for putchar and test exit,
> and cycle/instret counters. Write one thin wrapper per core with identical
> ports. Build hello, an rv32ui/rv32um/rv32uc riscv-tests subset, Dhrystone and
> CoreMark for rv32imc_zicsr with identical flags. Run everything on all three
> cores in Verilator. Report cycle counts and CoreMark/MHz against each core's
> published figure, and flag any big gap.

---

## Block 3: SKY130 core-only hardening (P2) — start before you sleep

**Prompt 5**
> Write a LibreLane config for each core (core-only scope) and start a clock
> sweep in the background inside tmux, all three cores, 3 clock points each
> (pick them from the synthesis timing estimate). Log to results/raw/sky130/.
> Tell me the tmux session name and how to check progress, then stop.

**Prompt 6 (next morning)**
> Check the sweep. For each run report DRC, LVS, antenna, setup/hold slack,
> die/core area, cell count and power. Fix failures by changing constraints,
> utilisation or density only (no waivers), rerun, and log every change.
> Update results.csv and STATUS.md.

---

## Block 4: FPGA on PYNQ (P3), in parallel with Block 3

**Prompt 7** (can be written on any machine)
> Write the Vivado batch flow for our PYNQ board (part from PROJECT_FACTS.md):
> each core + wrapper + BRAM program memory + AXI-mapped cycle counter and
> start/done registers, block design TCL, XDC, and scripts exporting
> utilisation, timing and power reports. Use the same clock target for all
> three cores. Write a PYNQ notebook that loads each bitstream and benchmark,
> runs it and reads back cycles and output.

**[YOU]:** on the Vivado PC (with Claude Code installed there):
> Build all three bitstreams with flows/fpga_build.tcl, fix errors, collect reports.

**[YOU]:** run the notebook on the board and commit its output (about 2 hours).

---

## Block 5: SKY130 padded chip top (P4)

**Prompt 8**
> Build common/chiptop: the same chip top for all cores, with clock/reset, a
> small sky130 SRAM macro (or DFF RAM if the macro can't close), UART, a few
> GPIO, and a pad ring using sky130_fd_io pad cells placed with OpenROAD's pad
> commands in LibreLane. Keep signal pads to about 32 or fewer. Prove it on
> Hazard3 first (zero DRC/LVS), then run Ibex and VeeR EL2. Report chip area,
> core area, pad count, fmax and power separately from the core-only numbers.

---

## Block 6: SCL 180 nm (P5) — only once PDK access and tool rules are in PROJECT_FACTS.md

**Prompt 9**
> Using PROJECT_FACTS.md, write the SCL 180 flow without opening any PDK file
> unless the facts say it's allowed. Yosys (or Genus) synthesis → place & route
> (OpenROAD or Innovus) → DRC/LVS, using the same steps, scopes and clock
> methodology as SKY130, and paths that come only from SCL_PDK_ROOT. Give me
> exact commands to run; I'll paste back the summaries. Start with synthesis of
> all three cores.

---

## Block 7: GLS, power, results, paper (P6)

**Prompt 10**
> For each clean SKY130 core-only layout: gate-level sim with sky130 cell models
> (hello + reduced-iteration CoreMark), matching RTL sim output and cycles; dump
> VCD; post-layout power with OpenROAD/OpenSTA using that activity.

**Prompt 11**
> Write scripts/collect.py and scripts/plots.py. Generate results/results.csv
> covering the full grid in docs/PLAN.md: a number or a pointer to
> LIMITATIONS.md in every cell. Add derived metrics: CoreMark/MHz,
> CoreMark/MHz per mm², energy per CoreMark iteration. Render GDS images with
> KLayout. Draft the paper in IEEE conference LaTeX: intro, related work (cite
> only papers you can link; mark gaps TODO), methodology, results with
> generated tables, limitations, conclusion. Every number from results.csv.

---

## End of every session
> Update docs/STATUS.md (passed / failed / running / next), list any number you
> aren't sure of and why, and commit.

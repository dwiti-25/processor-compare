# FPGA flow: PYNQ-Z1 / PYNQ-Z2 (Zynq-7020), Vivado

This builds each of the three cores (Hazard3, Ibex, VeeR EL2) as a PYNQ overlay. A Jupyter
notebook on the board then runs the project's benchmarks and reads back the cycle counters.

The flow reuses the ASIC flow's core wrappers, configurations, RTL patches and benchmark
binaries, so FPGA and ASIC numbers stay comparable. The two FPGA-specific changes are listed
under "What differs from the ASIC flow" below.

**Status (2026-11-18)**
- **Simulation:** each core's FPGA design passes the project's 52 programs in simulation on the
  Mac, with exit code, console output, total cycles and marked cycles identical to the RTL
  simulation (`results/raw/fpga/sim/<core>/summary.txt`).
- **Vivado:** the build script has **not been run yet**, because Vivado doesn't run on the M3
  Mac. Expect to fix small things on the first build; see "First-build risks" below.

## What's here

```
fpga/
  rtl/fpga_shell.sv        PL shell, the same for every core: 256 KiB block RAM, MMIO, cycle counters,
                           AXI4-Lite slave for the PS (register map in the file header)
  rtl/<core>_fpga.v        top per core = fpga_shell + cores/<core>/wrapper/<core>_wrap.sv
  vivado/build.tcl         one-command Vivado build: block design, synthesis, implementation,
                           bitstream, reports
  vivado/sources.tcl       source list from cores/<core>/sky130/{sources.f,synth.conf} + patches
                           (shared by Vivado and the simulation, so both build the same design)
  sim/tb_fpga.sv           testbench: drives the top over AXI4-Lite exactly like the notebook
  sim/run_sim.sh           build + run in Verilator, compare every program with the RTL simulation
  sim/xilinx_models.sv     BUFGCE model (simulation only; Vivado uses its own)
  sw/hex/*.hex             the 52 benchmark images, copied from build/bench/ by sw/export.py
  sw/manifest.json         sha256 per image + RTL-simulation reference result per core
  pynq/runner.py           board-side driver (load, run, read counters, compare, save)
  pynq/processor_compare.ipynb   the notebook
```

## How it works

- **The shell copies the testbench.** The shell (`fpga/rtl/fpga_shell.sv`) does in block RAM
  what `common/tb/tb_mem.sv` and `tb_top.sv` do in simulation:
  - RAM at 0x0, 256 KiB, 64 bits wide, 1-cycle read latency, read-first. Port A is the data port;
    port B is the instruction port.
  - The same MMIO at 0x8000_0000: putchar, exit and the benchmark start/stop marker.
  - The same cycle and marked-window counters.
  
  The same binary should therefore take exactly the same number of cycles on the board as in RTL
  simulation. The notebook checks this for every program.
- **The PS controls everything.** The Zynq PS talks to the shell through M_AXI_GP0 at
  `0x4000_0000` (a 512 KiB window). It holds the core in reset, writes the image into RAM, sets
  RUN, polls DONE, then reads EXIT, CYCLES, MARKED and the console buffer.
- **One PL clock.** FCLK_CLK0 from the PS (default 50 MHz) clocks the core and the shell. The PL
  uses no pins, so there's no pin XDC and the bitstream is the same for PYNQ-Z1 and PYNQ-Z2
  (both `xc7z020clg400-1`). The PS7 constrains FCLK_CLK0 itself.

### What differs from the ASIC flow (`docs/DECISIONS.md`, 2026-11-18, waiting for Dwiti's confirmation)

The only FPGA-specific change is how clock gating is mapped. Function and cycle counts are
unchanged:

| Core | ASIC | FPGA | Evidence that behaviour is unchanged |
|---|---|---|---|
| Hazard3 | no clock gates | same | n/a |
| Ibex | `prim_generic` clock gate (latch + AND) | lowRISC's own `prim_xilinx` gate (a BUFGCE); same module, one instance (the core sleep gate) | FPGA sim 52/52 identical to RTL sim |
| VeeR EL2 | config `min` (`fpga_optimize=0`, latch clock gates) | config `min_fpga` = `min` + VeeR's own `fpga_optimize=1` (clock gates become flop enables) | headers differ only by `RV_FPGA_OPTIMIZE`; RTL sim of `min_fpga` is identical to `min` on 52/52 programs, cycles included |

Why: VeeR has dozens of clock gates, and a Zynq-7020 has only 32 global clock buffers. Gating
them in LUT fabric would make timing unreliable.

## Steps for Ayush

### 0. Prerequisites

- **Vivado:** use the version that matches the PYNQ image on the SD card; the PYNQ release notes
  name it.
  - Record the Vivado version in `docs/VERSIONS.md`.
  - Record the board (Z1 or Z2) and the PYNQ image version in `docs/PROJECT_FACTS.md`.
  - The same Vivado version must be used for all three cores.
- **Board files (optional but recommended):** PYNQ-Z2 board files come from TUL; PYNQ-Z1 board
  files come from Digilent's `vivado-boards`. Install them into Vivado's `data/boards/board_files`.
  - With them, the PS7 gets the board's DDR/MIO preset.
  - Without them, the build still works: the bitstream is identical, and only the PS7 settings
    recorded in the `.hwh` differ. The PYNQ image configures the PS itself at boot.
  - `summary.txt` records which board part was used.
- **Clone with submodules:**
  ```sh
  git clone --recurse-submodules https://github.com/dwiti-25/processor-compare.git
  ```
- **No RISC-V toolchain needed:** the benchmark images are committed in `fpga/sw/`.

### 1. (Optional) Re-run the simulation check

This needs Linux or macOS with Verilator ≥ 5.0 and tclsh. `flows/env.sh` looks for OSS CAD
Suite in `~/tools/oss-cad-suite`.

```sh
fpga/sim/run_sim.sh hazard3          # all 52 programs; also: ibex, veer_el2
```

Each run prints `PASS`/`FAIL` per program and writes `results/raw/fpga/sim/<core>/summary.txt`.
It exits non-zero unless every program is identical to the RTL simulation.

### 2. Build each core: one command per core

From the repo root, on the Vivado machine:

```sh
vivado -mode batch -source fpga/vivado/build.tcl -tclargs hazard3  50
vivado -mode batch -source fpga/vivado/build.tcl -tclargs ibex     50
vivado -mode batch -source fpga/vivado/build.tcl -tclargs veer_el2 50
```

Arguments are `<core> [clk_mhz=50] [board=auto|pynq-z2|pynq-z1|none]`. With `auto`, the script
uses the PYNQ-Z2 board files if they're installed, then PYNQ-Z1, then the bare part.

Each run:
1. Creates `fpga/build/<core>/`, a Vivado project (gitignored).
2. Builds the block design: PS7 → AXI interconnect → `<core>_fpga` module reference.
3. Runs synthesis, implementation and bitstream generation.
4. Writes the overlay `fpga/out/<core>/<core>.bit` and `<core>.hwh` (gitignored).
5. Writes reports to `results/raw/fpga/<core>/vivado_<cfg>_<clk>MHz/`:
   - `utilization_synth.rpt`, `utilization.rpt`, `utilization_hier.rpt`
   - `timing_summary.rpt`, `timing_paths.rpt`
   - `power.rpt`, `clock_utilization.rpt`, `drc.rpt`, `methodology.rpt`
   - `summary.txt` (timing values queried from Vivado), `build.log`

**Check timing before using a bitstream.** `wns_ns` and `whs_ns` in `summary.txt` must be ≥ 0.

**Use the same clock for every core** (`CLAUDE.md`, clock targets). If any core misses timing
at 50 MHz:
- Don't loosen or waive anything.
- Rebuild **all three** at a lower clock, e.g. 40, and keep both points.
- Tell Dwiti.

### 3. Copy to the board

Copy into the board's notebook folder, e.g. `/home/xilinx/jupyter_notebooks/processor_compare/`
(the folder name doesn't matter, but the layout below does):

```
processor_compare/runner.py                  <- fpga/pynq/runner.py
processor_compare/processor_compare.ipynb    <- fpga/pynq/processor_compare.ipynb
processor_compare/sw/                        <- fpga/sw/            (manifest.json + hex/)
processor_compare/overlays/<core>.bit, .hwh  <- fpga/out/<core>/    (all three cores)
```

For example: `scp -r fpga/pynq/* fpga/sw fpga/out/*/ xilinx@<board>:...`, then move the
`.bit`/`.hwh` files into `overlays/`.

### 4. Run the notebook

Open `processor_compare.ipynb`, set `CORE`, and run all cells. Repeat for each core. The
notebook:
- Checks the overlay ID and each image's sha256.
- Runs `hello`, then all 52 programs.
- Prints how many passed and how many are identical to the RTL simulation.
- Saves `results/<core>_<clk>MHz.json`.

A program that is **not identical** to the RTL simulation is a finding. Report it; don't tune
it away.

### 5. Commit the results

```sh
mkdir -p results/raw/fpga/<core>/board_<clk>MHz
cp <board>:.../results/<core>_<clk>MHz.json results/raw/fpga/<core>/board_<clk>MHz/
scripts/collect.py --md fpga         # rebuilds results/fpga_results.csv and prints the table below
git add results/raw/fpga results/fpga_results.csv && git commit
```

## Results table (template)

`scripts/collect.py --md fpga` generates this table from the reports above. Never fill it in
by hand. Before any build, it looks like this:

| Core | Config | Clock (MHz) | WNS (ns) | fmax (MHz) | Core LUTs | Core FFs | Core BRAM36 | Core DSP | Power total / core (W, vectorless) | FPGA sim vs RTL sim | Board: passed / identical to RTL sim | Board CoreMark/MHz | Board DMIPS/MHz |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---|---|---:|---:|
| Hazard3 | | | | | | | | | / | 52/52 | / | | |
| Ibex | | | | | | | | | / | 52/52 | / | | |
| VeeR EL2 | | | | | | | | | / | 52/52 | / | | |

Column definitions:
- **Clock**: the FCLK_CLK0 frequency the PS actually generates.
- **fmax**: 1000 / (period − WNS) for the PL clock (all paths in the clock domain, shell
  included).
- **Core \***: the `u_core` instance in `utilization_hier.rpt`. That's the core plus its thin
  common wrapper, the same scope as the ASIC core-only macro. The 256 KiB RAM is in the shell,
  not in `u_core`.
- **Power**: Vivado `report_power` with default (vectorless) activity, total on-chip (PS
  included) and `u_core`. It's an estimate, not a measurement: the PYNQ boards have no PL power
  sensor.
- **Board CoreMark/MHz, DMIPS/MHz**: from the board's marked cycles, with the same formula as
  the RTL-simulation table. CoreMark runs 10 iterations (`common/bench/Makefile`), the same
  binary as RTL sim. That's not the ≥10 s run required for an official EEMBC score.

## First-build risks (the Vivado script is untested)

- **Module reference of a SystemVerilog hierarchy.** The top `<core>_fpga.v` is plain Verilog on
  purpose, since a module-reference top can't be SystemVerilog. If `create_bd_cell -type module`
  complains, check that every file in `sources.tcl` was added as SystemVerilog.
- **VeeR config headers.** `sources.tcl` generates `veer_el2_global.svh`, a guarded include of
  `common_defines.vh` and `el2_pdef.vh`, marked as a Vivado global include. If Vivado reports
  `el2_param_t` undefined or redefined, that file is where to look.
- **Automation rule options.** The `apply_bd_automation` option names
  (`processing_system7`, `axi4`) have changed slightly between Vivado versions. If one is
  rejected, run the same automation in the GUI once and copy the Tcl it prints.
- **Ibex's BUFGCE** is cascaded after the PS clock's BUFG. Vivado should time it as the same
  clock; check `clock_utilization.rpt`.

If you change anything to get past these, keep the RTL and configs the same as the ASIC flow,
log the change in `docs/DECISIONS.md`, and rerun `fpga/sim/run_sim.sh` for all three cores.

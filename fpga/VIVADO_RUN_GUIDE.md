# Vivado and PYNQ run guide

This guide takes you from the project checkout on your Vivado laptop to three PYNQ overlays, board benchmark results, and the generated FPGA results table. The supported targets are Hazard3, Ibex, and VeeR EL2 on a PYNQ-Z1 or PYNQ-Z2 (both use `xc7z020clg400-1`). The FPGA flow is in `fpga/`; you do not need to create a Vivado project by hand or add the RTL files one by one.

> **Current status:** `fpga/README.md` records that FPGA simulation passed for all three cores, but the Vivado build script has not yet been run. Expect the first build to expose version-specific Tcl or elaboration issues. Keep the first build log and fix the cause before continuing.

## 1. Prepare the laptop checkout

Use a local clone with the core submodules. From a terminal:

```sh
git clone --recurse-submodules <repository-url>
cd processor-compare
```

If you already have a clone, open a terminal in the repository root and run:

```sh
git submodule update --init --recursive
git status --short
```

The repository root is the folder containing `README.md`, `CLAUDE.md`, `cores/`, and `fpga/`. Run all commands below from that folder. If the checkout has local changes, keep them; do not reset or overwrite them.

Confirm these paths exist before opening Vivado:

```text
fpga/vivado/build.tcl
fpga/vivado/sources.tcl
fpga/rtl/fpga_shell.sv
fpga/rtl/hazard3_fpga.v
fpga/rtl/ibex_fpga.v
fpga/rtl/veer_el2_fpga.v
fpga/sw/manifest.json
fpga/sw/hex/
fpga/pynq/runner.py
fpga/pynq/processor_compare.ipynb
cores/hazard3/rtl/
cores/ibex/rtl/
cores/veer_el2/rtl/
```

The prebuilt benchmark hex images are committed in `fpga/sw/`; no RISC-V compiler is needed for these FPGA runs.

## 2. Record the machine, Vivado, and board details

Use a Vivado release supported by the PYNQ image installed on the SD card. Use that same Vivado release for every core. In Vivado, check **Help → About** (or run `vivado -version`) and record the full version in `docs/VERSIONS.md`.

Boot the PYNQ board and identify whether it is a PYNQ-Z1 or PYNQ-Z2. Record the model and the PYNQ image version in `docs/PROJECT_FACTS.md`. If the board is not one of those models, stop and check the FPGA README before building; the current script targets the Zynq-7020 part.

Optional board files provide a board preset for PS DDR/MIO settings. The build script can also use the bare FPGA part. Since this design uses no PL pins, it does not need a pin XDC. The script records the selected board part in each build's `summary.txt`.

## 3. Understand which files Vivado uses

Use the checked-in flow as a unit:

| File or folder | Purpose |
|---|---|
| `fpga/vivado/build.tcl` | Main entry point. Creates the Vivado project/block design, runs synthesis and implementation through bitstream, writes reports and copies the `.bit`/`.hwh` overlay. |
| `fpga/vivado/sources.tcl` | Selects the correct core file list, config, include paths, defines and patches. It also adds the shared wrapper and FPGA shell. The build script calls it automatically. |
| `cores/<core>/sky130/sources.f` and `synth.conf` | Existing project source list and core configuration reused by the FPGA source selector. Do not substitute another core's list/config. |
| `cores/<core>/patches/` | Project patches applied to temporary copies during source preparation. Vendor submodule RTL is not edited. |
| `cores/<core>/wrapper/<core>_wrap.sv` and `common/wrapper/` | Common interface adapters around each CPU core. |
| `fpga/rtl/fpga_shell.sv` | Shared block RAM, MMIO, control/status registers, and cycle counters. |
| `fpga/rtl/<core>_fpga.v` | Per-core FPGA top that connects the shell to that core's wrapper. |
| `fpga/sw/manifest.json`, `fpga/sw/hex/` | Benchmark binaries and their SHA256/reference results, used by the board notebook. |
| `fpga/pynq/runner.py`, `processor_compare.ipynb` | PYNQ-side overlay/benchmark runner and notebook. |
| `fpga/sim/` | Simulation-only testbench and Xilinx primitive model. These are not the Vivado project top. |

The top level is generated as a Zynq block design: PS7 → AXI interconnect → the chosen `<core>_fpga` top. The processor and shell run from PS `FCLK_CLK0`; the default target is 50 MHz. The script chooses the matching configuration automatically: Hazard3 `default`, Ibex `default`, VeeR EL2 `min_fpga`.

**Do not add every file under `cores/` manually.** `build.tcl` obtains the intended sources from `sources.tcl`, which reads the per-core source list and config, applies patches to a temporary copy, and supplies the FPGA-specific clock-gating selection. In particular, Ibex uses its Xilinx BUFGCE clock gate and VeeR uses the FPGA-compatible `min_fpga` config. These choices are intentional and have simulation evidence in `fpga/README.md` and `docs/DECISIONS.md`.

## 4. Run the first Vivado build: Hazard3

Open a terminal where `vivado` is on `PATH`, change directory to the repository root, and run:

```sh
vivado -mode batch -source fpga/vivado/build.tcl -tclargs hazard3 50
```

This is a batch build; the Tcl script creates and drives the Vivado project without requiring GUI clicks. Arguments are `<core> [clock_MHz] [board]`. The clock defaults to 50 MHz and board defaults to `auto`. Valid core names are exactly `hazard3`, `ibex`, and `veer_el2`. Valid board arguments are `auto`, `pynq-z1`, `pynq-z2`, or `none`.

If the board files are installed and correctly detected, `auto` selects a PYNQ board preset (Z2 is preferred if both are found). If not, the script uses the bare part. To explicitly select a board preset, for example:

```sh
vivado -mode batch -source fpga/vivado/build.tcl -tclargs hazard3 50 pynq-z1
```

Use `none` to force the bare part:

```sh
vivado -mode batch -source fpga/vivado/build.tcl -tclargs hazard3 50 none
```

The Tcl script prints progress and the Vivado version. Let the command finish; implementation and bitstream writing take time. A successful build ends with a `FPGA build done` message.

### Files created by the build

For Hazard3, expect:

```text
fpga/build/hazard3/                         Vivado project and implementation runs
fpga/out/hazard3/hazard3.bit                FPGA bitstream
fpga/out/hazard3/hazard3.hwh                PYNQ hardware handoff metadata
results/raw/fpga/hazard3/vivado_default_50MHz/
  utilization_synth.rpt
  utilization.rpt
  utilization_hier.rpt
  timing_summary.rpt
  timing_paths.rpt
  power.rpt
  clock_utilization.rpt
  drc.rpt
  methodology.rpt                           may be absent if Vivado does not emit it
  summary.txt
  build.log
```

The project and overlay output directories are gitignored build products. The `results/raw` reports are the run evidence to retain in the repository.

**Rerun caution:** `build.tcl` deletes `fpga/build/<core>/` and the report folder for the same core/config/clock before rebuilding. Copy any reports you need to preserve before rerunning at the same clock. A different clock uses a different report folder.

## 5. Review a build before using its overlay

First ensure the build reached 100% and that both overlay files exist and are non-empty. Then inspect `summary.txt`, `timing_summary.rpt`, `utilization_hier.rpt`, `power.rpt`, `drc.rpt`, and `clock_utilization.rpt`.

In `summary.txt`, verify:

- `core`, `config`, `top`, `vivado`, and `part` match the intended build.
- `clk_actual_mhz` is the clock you requested.
- `wns_ns` (setup slack) is **at least zero**.
- `whs_ns` (hold slack) is **at least zero**.
- setup and hold failing endpoint counts are zero.

Do not treat a generated bitstream as timing-passing if WNS or WHS is negative. If any core misses timing at 50 MHz, keep the 50 MHz reports, inform Dwiti, and rebuild **all three cores** at the same lower target (for example 40 MHz). Do not lower the clock for only one core or waive timing checks. Keep both clock points and report which meets timing.

For area/resource values used in the comparison, use the `u_core` hierarchy in `utilization_hier.rpt` (CPU plus thin common wrapper). The shell's 256 KiB BRAM is outside that instance. `power.rpt` is a vectorless Vivado estimate, not a board power measurement; distinguish total design/PS power from the `u_core` estimate.

## 6. Build Ibex and VeeR EL2

Once the Hazard3 build process works, repeat from the same repository root and Vivado release:

```sh
vivado -mode batch -source fpga/vivado/build.tcl -tclargs ibex 50
vivado -mode batch -source fpga/vivado/build.tcl -tclargs veer_el2 50
```

Review each build in the same way. Expected paths are:

```text
fpga/out/ibex/ibex.bit
fpga/out/ibex/ibex.hwh
results/raw/fpga/ibex/vivado_default_50MHz/

fpga/out/veer_el2/veer_el2.bit
fpga/out/veer_el2/veer_el2.hwh
results/raw/fpga/veer_el2/vivado_min_fpga_50MHz/
```

The VeeR directory contains `min_fpga` in its name because that is its configured FPGA variant. Do not replace it with the ASIC `min` configuration.

## 7. Put overlays and runner files on the PYNQ board

Create this layout in the board's Jupyter notebook directory, for example `/home/xilinx/jupyter_notebooks/processor_compare/`:

```text
processor_compare/
  runner.py
  processor_compare.ipynb
  sw/
    manifest.json
    hex/*.hex
  overlays/
    hazard3.bit       hazard3.hwh
    ibex.bit          ibex.hwh
    veer_el2.bit      veer_el2.hwh
```

Copy `fpga/pynq/runner.py` and `fpga/pynq/processor_compare.ipynb`; copy the complete `fpga/sw/` directory; copy each `.bit` and `.hwh` pair from `fpga/out/<core>/` into the board's `overlays/` folder. Preserve these names and directory structure because the notebook/runner expects them.

You can use `scp` from Linux/macOS or a Windows SSH client. Example from a Linux-like terminal, after replacing the host and destination with the board's actual address:

```sh
scp fpga/pynq/runner.py fpga/pynq/processor_compare.ipynb xilinx@<board-host>:/home/xilinx/jupyter_notebooks/processor_compare/
scp -r fpga/sw xilinx@<board-host>:/home/xilinx/jupyter_notebooks/processor_compare/
scp fpga/out/hazard3/hazard3.bit fpga/out/hazard3/hazard3.hwh xilinx@<board-host>:/home/xilinx/jupyter_notebooks/processor_compare/overlays/
scp fpga/out/ibex/ibex.bit fpga/out/ibex/ibex.hwh xilinx@<board-host>:/home/xilinx/jupyter_notebooks/processor_compare/overlays/
scp fpga/out/veer_el2/veer_el2.bit fpga/out/veer_el2/veer_el2.hwh xilinx@<board-host>:/home/xilinx/jupyter_notebooks/processor_compare/overlays/
```

Create the destination folders before copying if they do not exist. On Windows, use PowerShell `scp` if OpenSSH is installed, or transfer the same files with an SSH/SFTP client. Confirm in the Jupyter file browser that the folder tree and all filenames match the layout above.

## 8. Run benchmarks from the PYNQ notebook

Open `processor_compare.ipynb` in the board's Jupyter page. Set the notebook's `ROOT` (if needed) to the `processor_compare` directory and set `CORE` to one of `hazard3`, `ibex`, or `veer_el2`. Run all cells for that core. Repeat the notebook run for each core.

The runner loads the overlay, checks the core ID, verifies each benchmark image against `sw/manifest.json`, writes the program into FPGA block RAM, starts it, and reads exit status, console output, total cycles, and marked cycles. It compares these to the saved RTL-simulation references. Let it run through `hello` and the full benchmark set; do not report only the CoreMark result if the other checks fail.

The notebook saves a result JSON under the board-side `results/` folder, named like `hazard3_50MHz.json`. Copy each JSON back to the matching laptop folder:

```text
results/raw/fpga/hazard3/board_50MHz/
results/raw/fpga/ibex/board_50MHz/
results/raw/fpga/veer_el2/board_50MHz/
```

Keep the JSON intact. A board program that fails, times out, or differs from the RTL reference is a result to investigate and document, not a number to silently replace.

## 9. Generate the project table

From the repository root, after reports and board JSON files are in place, run:

```sh
scripts/collect.py --md fpga
```

This parses the raw Vivado reports and board JSON into `results/fpga_results.csv` and prints the table. Do not type resource, timing, power, or cycle values into the CSV by hand. Check the generated table for blank/unparsed values, the common clock used, board pass/identical counts, and CoreMark/DMIPS metrics. Save the command output or generated CSV for the report.

Before committing, inspect:

```sh
git status --short
```

Commit the evidence and generated table (along with the machine/version facts and any documented decisions):

```sh
git add docs/PROJECT_FACTS.md docs/VERSIONS.md docs/DECISIONS.md results/raw/fpga results/fpga_results.csv
git commit -m "Add FPGA Vivado and PYNQ results"
```

Only stage files that belong to this run; do not add the gitignored Vivado project or overlay build folders.

## 10. If the first build fails

Do not immediately edit core RTL or change the processor configuration. Save the complete terminal transcript and `fpga/build/<core>/` logs, note the Vivado version, exact command, and first meaningful error, then check the corresponding risk in `fpga/README.md`:

- A SystemVerilog module-reference issue: check that source files were added with the intended language type; `build.tcl` marks `.sv`, `.svh`, and `.vh` files as SystemVerilog.
- An included header reported as needing to be added to the project (for example Hazard3's `hazard3_config_inst.vh` or VeeR's `.svh` files): `build.tcl` scans the HDL sources and explicitly adds `.vh`/`.svh` headers from the configured include directories. For VeeR, it marks `common_defines.vh` and the typedef-bearing `el2_pdef.vh` as global includes.
- VeeR `el2_param_t` missing/redefined: inspect the generated `veer_el2_global.svh` under `fpga/build/veer_el2/gen/` and the include settings from `sources.tcl`.
- Block-design automation option rejected: the automation rules can vary by Vivado release. Record the exact error and the Tcl Vivado emits if configuring the same design in GUI is needed.
- Clock buffer/timing issue in Ibex: inspect `clock_utilization.rpt`; Ibex's FPGA clock gate uses BUFGCE.

If a change is needed, keep the core RTL/configuration aligned with the project decisions, record the change in `docs/DECISIONS.md`, and rerun `fpga/sim/run_sim.sh` for all three cores as the README directs. Preserve the initial failed log so the issue and fix are traceable.

## Quick command checklist

Run on the Vivado laptop from the project root:

```sh
vivado -version
vivado -mode batch -source fpga/vivado/build.tcl -tclargs hazard3 50
vivado -mode batch -source fpga/vivado/build.tcl -tclargs ibex 50
vivado -mode batch -source fpga/vivado/build.tcl -tclargs veer_el2 50
scripts/collect.py --md fpga
```

Use the lower common clock for all three builds if any 50 MHz run fails timing, and copy each board JSON into `results/raw/fpga/<core>/board_<clock>MHz/` before collecting the final table.

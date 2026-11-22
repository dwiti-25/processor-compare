# Viewing processor waveforms with Vivado

## Important: which waveform file this project creates

`TRACE=1 fpga/sim/run_sim.sh <core>` runs the design in **Verilator** and writes a VCD file such as `results/raw/fpga/waves/hazard3_rv32ui-simple.vcd`. Vivado's waveform viewer does not import arbitrary VCD files. In particular, AMD documents VCD as an export format for third-party viewers; it does not import VCD into the Vivado waveform viewer. The guide below explains how to generate and inspect a native Vivado/XSim waveform instead.

The project testbench at `fpga/sim/tb_fpga.sv` is Verilator-oriented and is not a drop-in XSim testbench. Vivado/XSim may reject Verilator-specific constructs such as `void'(...)`, `$dumpvars`, `$dumpon`, and `$dumpoff`. Use the Vivado GUI's simulation flow with an XSim-compatible testbench; do not expect to open the Verilator VCD as a Vivado waveform database.

## A. Open the built Vivado project

1. Start Vivado.
2. Choose **File → Project → Open**.
3. Open `fpga/build/hazard3/hazard3.xpr` (or `ibex/ibex.xpr`, `veer_el2/veer_el2.xpr`). The project is created by `fpga/vivado/build.tcl`.
4. In **Flow Navigator**, select **Simulation → Run Simulation → Run Behavioral Simulation**. The existing project is primarily a synthesis/implementation project and may not yet have a simulation top or simulation testbench configured. If this menu item is disabled or reports no simulation top, use section B.
5. In the simulation window, find the **Scopes** pane. Expand `tb_fpga` and `dut` (if present), select a scope, then in **Objects** select signals. Right-click and choose **Add to Wave Window**. To add everything in a scope, right-click the scope and choose **Add to Wave Window → All Signals**.
6. Click **Run All** (or enter a simulation duration in the toolbar and click **Run For**). Use **Zoom Fit** to show the full captured time range. Expand buses and change their radix by right-clicking a signal and choosing **Radix**.
7. Save the waveform layout with **File → Simulation Waveform → Save Configuration**. This saves a `.wcfg` layout; the simulation data itself is in the XSim `.wdb` database.

## B. Configure an XSim testbench if the project has none

1. In the open project, choose **Add Sources → Add or Create Simulation Sources**.
2. Add an XSim-compatible SystemVerilog testbench as a simulation source. The existing `fpga/sim/tb_fpga.sv` was written for Verilator, so first make an XSim-compatible copy: remove the VCD dump system tasks and Verilator-only `void'(...)` syntax. Keep the testbench stimulus, clock, reset, and DUT connections.
3. Make sure the simulation sources include the same processor RTL, FPGA wrapper, include directories, and defines used by the build. The canonical source/configuration list is in `fpga/vivado/sources.tcl`; the top module for each core is `<core>_fpga`.
4. Set the testbench module as simulation top: in **Sources → Simulation Sources**, right-click it and select **Set as Top**.
5. Ensure the test program image can be found by the testbench. For XSim, use a project-relative path or an absolute path to the relevant image under `fpga/sw/hex/` and load it with `$readmemh`.
6. Click **Run Simulation → Run Behavioral Simulation**. When the simulation opens, add the desired DUT and internal core signals from **Scopes/Objects** to the Wave window, then run and save the `.wcfg` as described above.

## C. Open a saved native Vivado waveform later

1. Open the same Vivado project and launch the simulation that created the database, or use **File → Open Waveform Configuration** to load a `.wcfg` while the matching simulation objects/database are available.
2. If the `.wcfg` opens without data, open the associated XSim waveform database (`.wdb`) from the simulation run directory or rerun the simulation. A `.wcfg` stores signal selection, grouping, radix, and zoom/layout preferences; it does not contain the sampled simulation values.

## For the VCD produced by the current Verilator command

Keep the VCD at `results/raw/fpga/waves/<core>_rv32ui-simple.vcd`. View that file with GTKWave, EPWave, or another VCD viewer. To use Vivado's waveform window, rerun the design under XSim with an XSim-compatible testbench and save its native `.wdb`/`.wcfg` outputs. RTL simulation waveforms show functional signal changes; they are not Vivado static timing path graphs or timing-slack reports.

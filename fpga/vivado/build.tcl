# Vivado batch build of one core for PYNQ-Z1 / PYNQ-Z2 (both xc7z020clg400-1).
#
#   vivado -mode batch -source fpga/vivado/build.tcl -tclargs <core> [clk_mhz] [board]
#     core    : hazard3 | ibex | veer_el2
#     clk_mhz : PL clock FCLK_CLK0 (default 50; use the same value for every core)
#     board   : auto (default: PYNQ-Z2, else PYNQ-Z1 board files if installed) | pynq-z2 | pynq-z1 | none
#
# Design: block design "ps" = Zynq PS7 (FCLK_CLK0, M_AXI_GP0) -> AXI interconnect -> module reference
# <core>_fpga (fpga/rtl/: fpga_shell + the ASIC flow's core wrapper), slave window 0x4000_0000, 512 KiB.
# No PL pins are used (everything goes through the PS), so there is no pin XDC and the bitstream is the
# same for Z1 and Z2; the board preset only sets the PS7 DDR/MIO configuration in the .hwh.
#
# Outputs
#   fpga/build/<core>/                         Vivado project (gitignored)
#   fpga/out/<core>/<core>.bit, <core>.hwh     overlay for the PYNQ notebook (gitignored; copy to the board)
#   results/raw/fpga/<core>/vivado_<cfg>_<clk>MHz/   reports to commit:
#     utilization_synth.rpt, utilization.rpt, utilization_hier.rpt, timing_summary.rpt,
#     timing_paths.rpt, power.rpt, clock_utilization.rpt, drc.rpt, methodology.rpt, summary.txt, build.log
# summary.txt holds timing key=value pairs queried from Vivado; scripts/collect.py --md fpga parses it
# together with utilization_hier.rpt and power.rpt.

set argv_core [lindex $argv 0]
if {$argv_core eq ""} { error "usage: vivado -mode batch -source fpga/vivado/build.tcl -tclargs <core> \[clk_mhz\] \[board\]" }
set clk_mhz [expr {[llength $argv] > 1 ? [lindex $argv 1] : 50}]
set board   [expr {[llength $argv] > 2 ? [lindex $argv 2] : "auto"}]
set part    xc7z020clg400-1

set repo [file normalize [file join [file dirname [info script]] .. ..]]
source [file join $repo fpga vivado sources.tcl]

set proj_dir [file join $repo fpga build $argv_core]
set out_dir  [file join $repo fpga out $argv_core]
file delete -force $proj_dir
file mkdir $proj_dir $out_dir
set src [fpga_src::sources $repo $argv_core [file join $proj_dir gen] vivado]
set top [dict get $src top]
set cfg [dict get $src cfg]
set rpt_dir [file join $repo results raw fpga $argv_core vivado_${cfg}_${clk_mhz}MHz]
file delete -force $rpt_dir
file mkdir $rpt_dir
puts "FPGA build: core=$argv_core cfg=$cfg top=$top clk=${clk_mhz} MHz board=$board Vivado [version -short]"

# ------------------------------------------------------------------ project + sources
create_project $argv_core $proj_dir -part $part -force
set board_part ""
if {$board ne "none"} {
    set pats [expr {$board eq "auto" ? {*pynq-z2* *pynq-z1*} : [list *${board}*]}]
    foreach p $pats {
        set bp [lindex [lsort [get_board_parts -quiet $p]] end]
        if {$bp ne ""} { set board_part $bp; break }
    }
    if {$board_part eq "" && $board ne "auto"} {
        error "board files for $board not installed (see fpga/README.md), or use board 'none'"
    }
}
if {$board_part ne ""} { set_property board_part $board_part [current_project] }
puts "FPGA build: board_part='$board_part'"

# Module-reference elaboration needs the included headers registered with the
# project as header files, not only discoverable through include_dirs. Without
# scanning includes Vivado 2026.1 can reject Hazard3's hazard3_config_inst.vh
# while creating the block-design module reference.
set header_files {}
foreach incdir [dict get $src incdirs] {
    foreach pattern {*.vh *.svh} {
        foreach header [glob -nocomplain -directory $incdir $pattern] {
            lappend header_files $header
        }
    }
}
if {[llength $header_files]} {
    add_files -norecurse $header_files
    foreach header $header_files {
        set_property file_type {Verilog Header} [get_files $header]
    }
}
if {$argv_core eq "veer_el2"} {
    # Match VeeR's own Vivado setup: its typedef-bearing parameter header must
    # be a project SystemVerilog global include. The simulation flow uses a
    # generated wrapper header instead; Vivado gets these original headers.
    set cfg_dir [file join $repo cores veer_el2 config $cfg]
    set common_defs [file join $cfg_dir common_defines.vh]
    set pdef [file join $cfg_dir el2_pdef.vh]
    set_property is_global_include true [get_files $common_defs]
    set_property is_global_include true [get_files $pdef]
}
add_files -scan_for_includes -norecurse [dict get $src files]
foreach f [dict get $src files] {
    if {[regexp {\.(sv|svh|vh)$} $f]} { set_property file_type SystemVerilog [get_files $f] }
}
if {$argv_core eq "veer_el2"} {
    # The include scan recognizes .vh as a Verilog Header and can reset its
    # language type; restore SystemVerilog after all scans are complete.
    set_property file_type SystemVerilog [get_files $pdef]
}
set gi [dict get $src global_include]
if {$gi ne ""} {
    # VeeR's generated global header includes the selected config headers; scan
    # it too so those headers are registered for module-reference elaboration.
    add_files -scan_for_includes -norecurse $gi
    set_property file_type {Verilog Header} [get_files $gi]
    set_property is_global_include true [get_files $gi]
}
set_property include_dirs [dict get $src incdirs] [current_fileset]
if {[llength [dict get $src defines]]} {
    set_property verilog_define [dict get $src defines] [current_fileset]
}
update_compile_order -fileset sources_1

# ------------------------------------------------------------------ block design
create_bd_design ps
set ps7 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config [list make_external "FIXED_IO, DDR" apply_board_preset [expr {$board_part ne "" ? 1 : 0}] \
                  Master Disable Slave Disable] $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 1 CONFIG.PCW_EN_CLK0_PORT 1 CONFIG.PCW_EN_RST0_PORT 1 \
                         CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $clk_mhz] $ps7
set core [create_bd_cell -type module -reference $top core]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 \
    -config [list Clk_master Auto Clk_slave Auto Clk_xbar Auto Master /ps7/M_AXI_GP0 Slave /core/s_axi \
                  intc_ip {New AXI Interconnect} master_apm 0] [get_bd_intf_pins core/s_axi]
foreach seg [get_bd_addr_segs -of_objects [get_bd_addr_spaces ps7/Data]] {
    set_property offset 0x40000000 $seg
    set_property range 512K $seg
}
validate_bd_design
set clk_actual [get_property CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ $ps7]
puts "FPGA build: FCLK_CLK0 requested $clk_mhz MHz, PS7 gives $clk_actual MHz"
save_bd_design
set bd_file [get_files ps.bd]
generate_target all $bd_file
set wrapper [make_wrapper -files $bd_file -top]
if {$wrapper eq "" || ![file exists $wrapper]} {
    set wrapper [lindex [glob -nocomplain [file join $proj_dir * sources_1 bd ps hdl ps_wrapper.v]] 0]
}
add_files -norecurse $wrapper
set_property top ps_wrapper [current_fileset]
update_compile_order -fileset sources_1

# ------------------------------------------------------------------ synthesis + implementation
set jobs 4
catch { set jobs [expr {min(8, [get_param general.maxThreads])}] }
launch_runs synth_1 -jobs $jobs
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { error "synthesis failed, see $proj_dir" }
open_run synth_1
report_utilization -file [file join $rpt_dir utilization_synth.rpt]
close_design

launch_runs impl_1 -to_step write_bitstream -jobs $jobs
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "implementation failed, see $proj_dir" }
open_run impl_1

# ------------------------------------------------------------------ reports
report_utilization               -file [file join $rpt_dir utilization.rpt]
report_utilization -hierarchical -hierarchical_depth 4 -file [file join $rpt_dir utilization_hier.rpt]
report_timing_summary -max_paths 10 -report_unconstrained -file [file join $rpt_dir timing_summary.rpt]
report_timing -setup -max_paths 20 -nworst 1 -path_type full -file [file join $rpt_dir timing_paths.rpt]
report_power -hierarchical_depth 4 -file [file join $rpt_dir power.rpt]
report_clock_utilization         -file [file join $rpt_dir clock_utilization.rpt]
report_drc                       -file [file join $rpt_dir drc.rpt]
catch { report_methodology       -file [file join $rpt_dir methodology.rpt] }

# summary.txt: timing values queried from Vivado (not typed). Utilization and power per instance
# (core = u_core, the core + its thin wrapper, comparable to the ASIC core-only scope) are parsed
# by scripts/collect.py from utilization_hier.rpt and power.rpt. fmax = 1000 / (T - WNS).
set clk_obj [get_clocks -quiet clk_fpga_0]
if {$clk_obj eq ""} { set clk_obj [lindex [get_clocks] 0] }
set setup_p [lindex [get_timing_paths -setup -max_paths 1 -nworst 1 -group [get_property NAME $clk_obj]] 0]
set hold_p  [lindex [get_timing_paths -hold  -max_paths 1 -nworst 1 -group [get_property NAME $clk_obj]] 0]
set f [open [file join $rpt_dir summary.txt] w]
puts $f "core=$argv_core"
puts $f "config=$cfg"
puts $f "top=$top"
puts $f "vivado=[version -short]"
puts $f "part=$part"
puts $f "board_part=$board_part"
puts $f "clk_target_mhz=$clk_mhz"
puts $f "clk_actual_mhz=$clk_actual"
puts $f "clock=[get_property NAME $clk_obj]"
puts $f "period_ns=[get_property PERIOD $clk_obj]"
puts $f "wns_ns=[get_property SLACK $setup_p]"
puts $f "whs_ns=[get_property SLACK $hold_p]"
puts $f "setup_failing_endpoints=[llength [get_timing_paths -quiet -setup -slack_lesser_than 0 -max_paths 100000 -nworst 1 -unique_pins]]"
puts $f "hold_failing_endpoints=[llength [get_timing_paths -quiet -hold -slack_lesser_than 0 -max_paths 100000 -nworst 1 -unique_pins]]"
puts $f "worst_setup_start=[get_property STARTPOINT_PIN $setup_p]"
puts $f "worst_setup_end=[get_property ENDPOINT_PIN $setup_p]"
puts $f "power_activity=vectorless"
close $f

# ------------------------------------------------------------------ overlay files for PYNQ
set bit [lindex [glob -nocomplain [file join $proj_dir ${argv_core}.runs impl_1 *.bit]] 0]
set hwh [lindex [get_files -all -quiet -filter {FILE_TYPE == "Hardware Handoff"} *ps.hwh] 0]
if {$hwh eq ""} { set hwh [lindex [glob -nocomplain [file join $proj_dir * sources_1 bd ps hw_handoff ps.hwh]] 0] }
file copy -force $bit [file join $out_dir ${argv_core}.bit]
file copy -force $hwh [file join $out_dir ${argv_core}.hwh]
catch { file copy -force [file join $proj_dir ${argv_core}.runs impl_1 runme.log] [file join $rpt_dir build.log] }
puts "FPGA build done: [file join $out_dir ${argv_core}.bit] (+ .hwh), reports in $rpt_dir"

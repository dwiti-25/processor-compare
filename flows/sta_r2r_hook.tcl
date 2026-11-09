# Sourced by LibreLane's STA (openroad/sta/corner.tcl) via STA_EXTRA_CORNER_TCL_FILE.
# Adds r2r.rpt: worst setup path between sequential elements (no ports at either end) for every
# loaded corner. LibreLane's own max.rpt shows only the worst path per endpoint for one corner,
# so a register's internal path can be hidden behind a worse input-port path.
# Before CTS there is no clock tree, so a propagated clock just measures one unbuffered net
# driving every flop: use ideal clocks then (the usual pre-CTS convention). After CTS (clock tree
# buffers named clkbuf_* exist) keep LibreLane's propagated clocks.
set cts_done [expr {[llength [get_cells -quiet clkbuf_*]] > 0}]
if { !$cts_done } { unset_propagated_clock [all_clocks] }
puts "%OL_CREATE_REPORT r2r.rpt"
puts [expr {$cts_done ? "clocks propagated (post-CTS)" : "clocks ideal (pre-CTS)"}]
foreach c [sta::corners] {
    set n [$c name]
    set paths [find_timing_paths -path_delay max -sort_by_slack -corner $n \
        -from [all_registers -clock_pins] -to [all_registers -data_pins]]
    if { [llength $paths] == 0 } {
        puts "r2r $n none"
        continue
    }
    set p [lindex $paths 0]
    puts "r2r $n slack [format %.4f [get_property $p slack]] from [get_full_name [get_property $p startpoint]] to [get_full_name [get_property $p endpoint]]"
}
foreach c [sta::corners] {
    set n [$c name]
    puts "\n======================= $n reg-to-reg ======================="
    report_checks -path_delay max -corner $n -from [all_registers -clock_pins] -to [all_registers -data_pins] \
        -fields {slew cap fanout} -format full_clock_expanded
}
puts "%OL_END_REPORT"

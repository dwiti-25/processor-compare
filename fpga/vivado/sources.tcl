# FPGA source list for one core: the same RTL, file lists, patches, parameters and defines as the
# ASIC flow (cores/<core>/sky130/{sources.f,synth.conf}, cores/<core>/patches/, cores/<core>/wrapper/),
# plus the FPGA shell (fpga/rtl/). Used by fpga/vivado/build.tcl (Vivado) and fpga/sim/run_sim.sh
# (Verilator, through tclsh), so the simulated and the implemented design use one list.
#
# FPGA-specific differences (fpga/README.md, docs/DECISIONS.md 2026-11-18):
#   Ibex : prim_clock_gating from lowRISC's own prim_xilinx (BUFGCE) instead of prim_generic (latch + AND)
#   VeeR : config min_fpga = min + VeeR's fpga_optimize (clock gates -> flop enables; cycle-identical)
#
# Standalone (prints the list):  tclsh fpga/vivado/sources.tcl <core> <outdir> [sim|vivado]
# Pure Tcl 8.5, no external programs, so it runs the same on Linux, Windows and macOS.

namespace eval fpga_src {}

# core -> {config name, CORE_ID, FPGA top module}
proc fpga_src::core_info {core} {
    switch -- $core {
        hazard3  { return {default 1 hazard3_fpga} }
        ibex     { return {default 2 ibex_fpga} }
        veer_el2 { return {min_fpga 3 veer_el2_fpga} }
        default  { error "unknown core '$core' (hazard3 | ibex | veer_el2)" }
    }
}

proc fpga_src::read_file {path} {
    set f [open $path r]; fconfigure $f -translation auto
    set s [read $f]; close $f
    return $s
}
proc fpga_src::write_file {path s} {
    file mkdir [file dirname $path]
    set f [open $path w]; fconfigure $f -translation lf
    puts -nonewline $f $s; close $f
}

# KEY=value / KEY="value" lines of a synth.conf (bash), with ${CFG:-x} and $CFG expanded.
proc fpga_src::read_conf {path cfg} {
    set conf [dict create]
    foreach line [split [read_file $path] "\n"] {
        if {![regexp {^([A-Z_]+)=(.*)$} [string trim $line] -> k v]} continue
        regsub {^"(.*)"$} $v {\1} v
        regsub -all {\$\{CFG(:-[^\}]*)?\}} $v $cfg v
        regsub -all {\$CFG\M} $v $cfg v
        dict set conf $k $v
    }
    return $conf
}

# Minimal unified-diff applier (the patches here are small, exact-context hunks).
proc fpga_src::apply_patch {patch_path root} {
    set lines [split [read_file $patch_path] "\n"]
    set n [llength $lines]
    set i 0
    while {$i < $n} {
        set l [lindex $lines $i]
        if {[regexp {^\+\+\+ b/(\S+)} $l -> rel]} {
            set target [file join $root $rel]
            set src [split [read_file $target] "\n"]
            set out {}
            set pos 0
            incr i
            while {$i < $n && ![string match "diff *" [lindex $lines $i]] && ![string match "--- *" [lindex $lines $i]]} {
                set h [lindex $lines $i]
                if {[regexp {^@@ -(\d+)(?:,\d+)? \+\d+(?:,\d+)? @@} $h -> old_start]} {
                    set start [expr {$old_start - 1}]
                    if {$old_start == 0} { set start 0 }
                    while {$pos < $start} { lappend out [lindex $src $pos]; incr pos }
                    incr i
                    while {$i < $n} {
                        set hl [lindex $lines $i]
                        set c [string index $hl 0]
                        set body [string range $hl 1 end]
                        if {$c eq " "} {
                            if {[lindex $src $pos] ne $body} { error "patch $patch_path: context mismatch at $rel:[expr {$pos+1}]" }
                            lappend out $body; incr pos
                        } elseif {$c eq "-"} {
                            if {[lindex $src $pos] ne $body} { error "patch $patch_path: removed line mismatch at $rel:[expr {$pos+1}]" }
                            incr pos
                        } elseif {$c eq "+"} {
                            lappend out $body
                        } elseif {$c eq "\\"} {
                        } else { break }
                        incr i
                    }
                } else { incr i }
            }
            while {$pos < [llength $src]} { lappend out [lindex $src $pos]; incr pos }
            write_file $target [join $out "\n"]
        } else { incr i }
    }
}

# Returns a dict: files (ordered), incdirs, defines, global_include (or ""), top, core_id, cfg.
# Paths are absolute. outdir receives patched copies and generated headers.
proc fpga_src::sources {repo core outdir mode} {
    lassign [core_info $core] cfg core_id top
    set conf [read_conf [file join $repo cores $core sky130 synth.conf] $cfg]
    set rtl [file join $repo cores $core rtl]

    set files {}
    set incdirs {}
    foreach line [split [read_file [file join $repo cores $core sky130 sources.f]] "\n"] {
        set line [string trim $line]
        if {$line eq "" || [string match "//*" $line]} continue
        if {[regexp {^\+incdir\+(.*)$} $line -> d]} { lappend incdirs [file join $repo $d]; continue }
        lappend files [file join $repo $line]
    }
    if {[dict exists $conf EXTRA_INC] && [dict get $conf EXTRA_INC] ne ""} {
        foreach d [dict get $conf EXTRA_INC] { lappend incdirs [file join $repo $d] }
    }
    set pre {}
    if {[dict exists $conf PRE_SOURCES]} {
        foreach p [dict get $conf PRE_SOURCES] { lappend pre [file join $repo $p] }
    }

    # patches: copy each patched file to outdir/patched/<path below rtl/> and apply (as flows/sim.sh)
    set pdir [file join $outdir patched]
    file delete -force $pdir
    foreach pf [lsort [glob -nocomplain [file join $repo cores $core patches *.patch]]] {
        foreach l [split [read_file $pf] "\n"] {
            if {![regexp {^\+\+\+ b/(\S+)} $l -> rel]} continue
            set dst [file join $pdir $rel]
            if {![file exists $dst]} {
                file mkdir [file dirname $dst]
                file copy -force [file join $rtl $rel] $dst
            }
            set idx [lsearch -exact $files [file join $rtl $rel]]
            if {$idx >= 0} { set files [lreplace $files $idx $idx $dst] }
        }
        apply_patch $pf $pdir
    }

    # FPGA mapping of Ibex's clock gate: lowRISC's Xilinx primitive (BUFGCE), same module name
    if {$core eq "ibex"} {
        set gen [file join $rtl vendor lowrisc_ip ip prim_generic rtl prim_clock_gating.sv]
        set xil [file join $rtl vendor lowrisc_ip ip prim_xilinx rtl prim_clock_gating.sv]
        set idx [lsearch -exact $files $gen]
        if {$idx < 0} { error "prim_clock_gating not found in Ibex sources.f" }
        set files [lreplace $files $idx $idx $xil]
        if {$mode eq "sim"} { lappend files [file join $repo fpga sim xilinx_models.sv] }
    }

    # VeeR config headers: one guarded global header (common_defines.vh + el2_pdef.vh typedef), first in
    # compile order for Verilator, Vivado "global include". The guard makes it valid whether the
    # tool compiles all files as one unit or each file separately.
    set global ""
    if {$core eq "veer_el2"} {
        set cdir [file join $repo cores veer_el2 config $cfg]
        set global [file join $outdir veer_el2_global.svh]
        set s "// generated by fpga/vivado/sources.tcl: VeeR EL2 config '$cfg' (cores/veer_el2/config/$cfg)\n"
        append s "`ifndef FPGA_VEER_GLOBAL_SVH\n`define FPGA_VEER_GLOBAL_SVH\n"
        append s "`include \"[file join $cdir common_defines.vh]\"\n"
        foreach p $pre { append s "`include \"$p\"\n" }
        append s "`endif\n"
        write_file $global $s
        set pre {}
    }

    set wrap [list [file join $repo common wrapper obi32to64.sv] [file join $repo common wrapper ahbl2obi.sv] \
                   [file join $repo common wrapper axi2obi64.sv] [file join $repo cores $core wrapper ${core}_wrap.sv] \
                   [file join $repo fpga rtl fpga_shell.sv] [file join $repo fpga rtl ${top}.v]]
    set all [concat $pre $files $wrap]
    if {$global ne "" && $mode eq "sim"} { set all [linsert $all 0 $global] }

    # defines: synth.conf DEFINES. Vivado: SYNTHESIS (YOSYS only selects Yosys assertion macros).
    # Simulation: as flows/sim.sh (SYNTHESIS dropped).
    set defines {}
    if {[dict exists $conf DEFINES]} {
        foreach d [dict get $conf DEFINES] {
            if {$mode eq "sim" && $d eq "SYNTHESIS"} continue
            if {$mode eq "vivado" && $d eq "YOSYS"} continue
            lappend defines $d
        }
    }
    foreach f $all { if {![file exists $f]} { error "missing source $f (submodules checked out? git submodule update --init)" } }
    return [dict create files $all incdirs $incdirs defines $defines global_include $global \
                top $top core_id $core_id cfg $cfg]
}

if {[info exists argv0] && [file tail $argv0] eq "sources.tcl"} {
    lassign $argv core outdir mode
    if {$mode eq ""} { set mode sim }
    set repo [file normalize [file join [file dirname [info script]] .. ..]]
    set d [fpga_src::sources $repo $core [file normalize $outdir] $mode]
    puts "TOP [dict get $d top]"
    puts "CFG [dict get $d cfg]"
    foreach k {defines incdirs} { foreach v [dict get $d $k] { puts "[string toupper [string range $k 0 2]] $v" } }
    foreach v [dict get $d files] { puts "SRC $v" }
}

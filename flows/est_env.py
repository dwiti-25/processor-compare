#!/usr/bin/env python3
"""Turn a LibreLane resolved.json into Tcl variables for flows/sta_estimate.tcl.
usage: est_env.py <resolved.json> <corner, e.g. tt_025C_1v80>"""
import fnmatch
import json
import sys

r = json.load(open(sys.argv[1]))
corner = sys.argv[2]
libs = [l for pat, ls in r["LIB"].items() if fnmatch.fnmatch("nom_" + corner, pat) for l in ls]
assert libs, f"no liberty for corner {corner}"
print(f'set tech_lef {{{r["TECH_LEFS"]["nom_*"]}}}')
print(f'set cell_lefs {{{" ".join(r["CELL_LEFS"])}}}')
print(f'set libs {{{" ".join(libs)}}}')
print(f'set top {r["DESIGN_NAME"]}')
for k in ["CLOCK_PORT", "CLOCK_PERIOD", "IO_DELAY_CONSTRAINT", "MAX_FANOUT_CONSTRAINT", "OUTPUT_CAP_LOAD",
          "CLOCK_UNCERTAINTY_CONSTRAINT", "CLOCK_TRANSITION_CONSTRAINT", "TIME_DERATING_CONSTRAINT",
          "SYNTH_DRIVING_CELL", "MAX_TRANSITION_CONSTRAINT", "MAX_CAPACITANCE_CONSTRAINT"]:
    print(f"set ::env({k}) {{{r[k]}}}")
print("set ::env(OPENLANE_SDC_IDEAL_CLOCKS) 1")

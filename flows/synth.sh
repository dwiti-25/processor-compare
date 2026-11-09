#!/usr/bin/env bash
# Core-only synthesis on sky130_fd_sc_hd with LibreLane's own Yosys step (same synthesis the
# hardening flow uses). For the timing estimate the LibreLane Classic flow continues through
# floorplan, global placement and post-placement design repair (buffering), then runs LibreLane's
# mid-PnR STA (placement-estimated parasitics, ideal clocks). Stops there: no CTS or routing.
# usage: flows/synth.sh <core> [CLK_MHZ] [CFG]
#   core    : hazard3 | ibex | veer_el2
#   CLK_MHZ : clock target (default 50)
#   CFG     : config name (default "default"; VeeR: min | bp)
# Output: results/raw/sky130/<core>/synth_<cfg>_<clk>MHz/  (LibreLane run dir under build/, gitignored)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
source flows/env.sh

CORE=${1:?core}
CLK_MHZ=${2:-50}
CFG=${3:-}
[ -z "$CFG" ] && { [ "$CORE" = veer_el2 ] && CFG=min || CFG=default; }
export CFG
source "cores/$CORE/sky130/synth.conf"

RUN=synth_${CFG}_${CLK_MHZ}MHz
OUT=results/raw/sky130/$CORE/$RUN
BUILD=build/librelane/$CORE/$RUN
rm -rf "$OUT" "$BUILD"; mkdir -p "$OUT" "$BUILD"

SRCS="${PRE_SOURCES:-} $(grep -v -e '^//' -e '^+' -e '^\s*$' "cores/$CORE/sky130/sources.f" | tr '\n' ' ')"
INCS="$(sed -n 's/^+incdir+//p' "cores/$CORE/sky130/sources.f") $EXTRA_INC"

# Vendor RTL is never edited: files touched by cores/<core>/patches/*.patch are copied to
# build/patched/<core>/, patched there, and substituted into the source list.
PATCHED=build/patched/$CORE
rm -rf "$PATCHED"
for pf in cores/$CORE/patches/*.patch; do
  [ -f "$pf" ] || continue
  for f in $(sed -n 's#^+++ b/##p' "$pf"); do
    mkdir -p "$PATCHED/$(dirname "$f")"
    [ -f "$PATCHED/$f" ] || cp "cores/$CORE/rtl/$f" "$PATCHED/$f"
    SRCS=$(echo " $SRCS " | sed "s# cores/$CORE/rtl/$f # $PATCHED/$f #")
  done
  patch -s -p1 -d "$PATCHED" < "$pf"
done

# LibreLane config (absolute paths; repo is mounted at the same path in the container)
REPO="$REPO" TOP="$TOP" CLK_PORT="$CLK_PORT" CLK_MHZ="$CLK_MHZ" SRCS="$SRCS" INCS="$INCS" \
DEFINES="$DEFINES" PARAMS="$PARAMS" FRONTEND="${FRONTEND:-slang}" python3 - > "$BUILD/config.json" <<'EOF'
import json, os
e = os.environ
ab = lambda p: os.path.join(e["REPO"], p)
cfg = {
    "DESIGN_NAME": e["TOP"],
    "VERILOG_FILES": [ab(f) for f in e["SRCS"].split()],
    "VERILOG_INCLUDE_DIRS": [ab(d) for d in e["INCS"].split()],
    "VERILOG_DEFINES": e["DEFINES"].split(),
    "SYNTH_PARAMETERS": e["PARAMS"].split(),
    "CLOCK_PORT": e["CLK_PORT"],
    "CLOCK_PERIOD": round(1000.0 / float(e["CLK_MHZ"]), 4),
    "RUN_LINTER": False,
    "STA_EXTRA_CORNER_TCL_FILE": ab("flows/sta_r2r_hook.tcl"),
    # Run LibreLane's mid-PnR STA once more right after post-placement repair, and stop there.
    "meta": {"version": 3, "flow": "Classic",
             "substituting_steps": {"+OpenROAD.RepairDesignPostGPL": "OpenROAD.STAMidPNR"}},
}
if e["FRONTEND"] == "slang":
    cfg["USE_SLANG"] = True
    cfg["SLANG_ARGUMENTS"] = ["--std", "latest", "--single-unit", "--allow-hierarchical-const",
                              "--libraries-inherit-macros", "--no-implicit-memories"]
print(json.dumps(cfg, indent=2))
EOF

{
  echo "core=$CORE"; echo "config=$CFG"; echo "top=$TOP"; echo "params=$PARAMS"
  echo "core_commit=$(git -C cores/$CORE/rtl rev-parse HEAD)"
  echo "clk_mhz=$CLK_MHZ"; echo "frontend=${FRONTEND:-slang}"
  echo "patches=$(cd cores/$CORE/patches && ls *.patch 2>/dev/null | tr '\n' ' ')"
  echo "librelane_image=$LIBRELANE_IMAGE"
  echo "pdk=$PDK"; echo "pdk_version=$(basename "$(dirname "$(readlink "$PDK_ROOT/$PDK")")")"
  echo "date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "$OUT/run.info"

echo "[synth] $CORE cfg=$CFG clk=${CLK_MHZ}MHz -> $OUT"
flows/librelane.sh "$BUILD/config.json" --run-tag run --overwrite --to OpenROAD.STAMidPNR-1 > "$OUT/librelane.log" 2>&1 \
  || { echo "[synth] LibreLane failed, see $OUT/librelane.log"; exit 1; }
LR=$BUILD/runs/run

# keep the reports, not the run dir
SYN=$(ls -d "$LR"/*-yosys-synthesis)
cp -R "$SYN"/reports "$OUT/yosys_reports"
cp "$SYN"/*.log "$OUT/" 2>/dev/null || true
cp "$LR/resolved.json" "$OUT/"
cp "$SYN"/*.nl.v "$OUT/netlist.v"
STA=$(ls -d "$LR"/*-openroad-stamidpnr-1)
mkdir -p "$OUT/sta_postgpl"
cp "$STA"/*.rpt "$STA"/state_out.json "$STA"/*.log "$OUT/sta_postgpl/"
test -s "$OUT/sta_postgpl/r2r.rpt" || { echo "[synth] r2r.rpt missing"; exit 1; }
cp "$(ls -d "$LR"/*-openroad-floorplan)"/*.log "$OUT/" 2>/dev/null || true
echo "[synth] done: $OUT"

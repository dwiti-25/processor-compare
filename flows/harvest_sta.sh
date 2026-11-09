#!/usr/bin/env bash
# Copy per-corner post-route STA summaries (r2r.rpt from flows/sta_r2r_hook.tcl, ws/tns reports)
# from a finished layout run into its results directory.
# usage: flows/harvest_sta.sh <results/raw/sky130/<core>/<harden_run>> <build/librelane/<core>/<harden_run>>
set -euo pipefail
OUT=${1:?results dir}; BUILD=${2:?build dir}
STA=$(ls -d "$BUILD"/runs/run/*-openroad-stapostpnr | tail -1)
for c in "$STA"/*/; do
  c=$(basename "$c")
  mkdir -p "$OUT/sta_postpnr/$c"
  cp "$STA/$c"/r2r.rpt "$STA/$c"/ws.max.rpt "$STA/$c"/wns.max.rpt "$STA/$c"/tns.max.rpt "$OUT/sta_postpnr/$c/" 2>/dev/null || true
done
echo "[harvest] $OUT/sta_postpnr: $(ls "$OUT/sta_postpnr" | wc -l | tr -d ' ') corners"

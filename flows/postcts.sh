#!/usr/bin/env bash
# Second timing-estimate stage for a finished flows/synth.sh run: resume the same LibreLane run
# through detailed placement, CTS and post-CTS timing repair (all LibreLane defaults), then
# LibreLane's mid-PnR STA with the propagated clock tree. Still no routing.
# usage: flows/postcts.sh <core> [CLK_MHZ] [CFG]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
source flows/env.sh

CORE=${1:?core}
CLK_MHZ=${2:-50}
CFG=${3:-}
[ -z "$CFG" ] && { [ "$CORE" = veer_el2 ] && CFG=min || CFG=default; }
RUN=synth_${CFG}_${CLK_MHZ}MHz
OUT=results/raw/sky130/$CORE/$RUN
BUILD=build/librelane/$CORE/$RUN
[ -d "$BUILD/runs/run" ] || { echo "[postcts] no LibreLane run at $BUILD, run flows/synth.sh first"; exit 1; }

echo "[postcts] $CORE cfg=$CFG clk=${CLK_MHZ}MHz -> $OUT/sta_postcts"
flows/librelane.sh "$BUILD/config.json" --run-tag run --from OpenROAD.DetailedPlacement --to OpenROAD.STAMidPNR-3 \
  > "$OUT/librelane_postcts.log" 2>&1 || { echo "[postcts] LibreLane failed, see $OUT/librelane_postcts.log"; exit 1; }
LR=$BUILD/runs/run
STA=$(ls -d "$LR"/*-openroad-stamidpnr-3 | tail -1)
rm -rf "$OUT/sta_postcts"; mkdir -p "$OUT/sta_postcts"
cp "$STA"/*.rpt "$STA"/state_out.json "$STA"/*.log "$OUT/sta_postcts/"
cp "$(ls -d "$LR"/*-openroad-resizertimingpostcts | tail -1)"/*.log "$OUT/sta_postcts/" 2>/dev/null || true
grep -q "post-CTS" "$OUT/sta_postcts/r2r.rpt" || { echo "[postcts] r2r.rpt is not post-CTS"; exit 1; }
echo "[postcts] done: $OUT/sta_postcts"

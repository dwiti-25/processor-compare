#!/usr/bin/env bash
# Post-layout power of a core-only layout run with CoreMark switching activity (typical corner).
# usage: flows/power.sh <core> <harden_run>     e.g. flows/power.sh hazard3 harden_default_wrap_30MHz_postroute
# Needs: the run's build dir (final netlist, nom SPEF, SDC) and the SAIF from
#   SAIF=1 flows/sim.sh <core> coremark_pwr   -> results/raw/power/<core>_<cfg>/coremark_pwr.saif
# Output: results/raw/sky130/<core>/<harden_run>/power_coremark/{power.rpt,annotation.txt,...}
# Corner: nom_tt_025C_1v80 liberty + nom RCX SPEF.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
source flows/env.sh
CORE=${1:?core}; RUN=${2:?harden run name}
OUT=results/raw/sky130/$CORE/$RUN
FIN=build/librelane/$CORE/$RUN/runs/run/final
CFG=$(sed -n 's/^config=//p' "$OUT/run.info"); TOP=$(sed -n 's/^top=//p' "$OUT/run.info")
CLK=$(sed -n 's/^clk_mhz=//p' "$OUT/run.info")
SAIF=results/raw/power/${CORE}_${CFG}/coremark_pwr.saif
[ -f "$SAIF" ] || { echo "[power] missing $SAIF (run: SAIF=1 flows/sim.sh $CORE coremark_pwr)"; exit 1; }
P=$OUT/power_coremark; mkdir -p "$P"
python3 flows/saif2act.py "$SAIF" "build/power_${CORE}_${RUN}.acts.tcl"
LIBS=$(python3 -c "import json; print(' '.join(json.load(open('$OUT/resolved.json'))['LIB']['*_tt_025C_1v80']))")
docker run --rm -v "$REPO:$REPO" -v "$PDK_ROOT:$PDK_ROOT" -w "$REPO" \
  -e PWR_LIBS="$LIBS" -e PWR_NETLIST="$FIN/nl/$TOP.nl.v" -e PWR_TOP="$TOP" \
  -e PWR_SPEF="$(ls $FIN/spef/nom/*.spef)" -e PWR_SDC="$(ls $FIN/sdc/*.sdc)" \
  -e PWR_ACTS="build/power_${CORE}_${RUN}.acts.tcl" -e PWR_CLK_MHZ="$CLK" -e PWR_OUT="$P" \
  "$LIBRELANE_IMAGE" sta -no_splash -exit flows/power.tcl > "$P/sta.log" 2>&1 \
  || { echo "[power] sta failed, see $P/sta.log"; tail -5 "$P/sta.log"; exit 1; }
{ echo "saif=$SAIF"; echo "saif_sha1=$(shasum "$SAIF" | cut -d' ' -f1)"; echo "corner=nom_tt_025C_1v80"; } > "$P/power.info"
echo "[power] $CORE $RUN: $(tail -1 "$P/sta.log")"; cat "$P/annotation.txt"

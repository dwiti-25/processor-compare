#!/usr/bin/env bash
# RTL simulation of one core (common wrapper + common testbench) in Verilator.
# usage: flows/sim.sh <core> [bench ...]      (default: all benchmarks in common/bench)
#   core : hazard3 | ibex | veer_el2   (VeeR config via CFG=min|bp, default min)
# Builds build/sim/<core>_<cfg>/Vtb_top once, runs each build/bench/<bench>.hex and writes
# results/raw/sim/<core>_<cfg>/<bench>.log (the last line is the testbench's TB_RESULT line).
# SAIF=1: separate build with --trace-saif; each run dumps switching activity of the core wrapper over
#         the benchmark's timed window (start..stop marker) to results/raw/power/<core>_<cfg>/<bench>.saif
#   TRACE=vcd   with SAIF=1: VCD instead of SAIF (use with DUMPLIMIT=1 for a header with declared ranges)
#   DUMPLIMIT=n end the dump window after n cycles
#   PWRMON=file include a generated FSM state monitor (flows/actmap.py --gen-mon); own build dir
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
source flows/env.sh

CORE=${1:?core}; shift
CFG=${CFG:-}
[ -z "$CFG" ] && { [ "$CORE" = veer_el2 ] && CFG=min || CFG=default; }
export CFG
source "cores/$CORE/sky130/synth.conf"

NAME=${CORE}_${CFG}
SIMDIR=build/sim/$NAME
LOGDIR=results/raw/sim/$NAME
TRACEARGS=""
if [ "${SAIF:-0}" = 1 ]; then
  SIMDIR=build/sim/${NAME}_saif
  LOGDIR=results/raw/power/$NAME
  TRACEARGS="--trace-saif +define+TB_SAIF"
  EXT=saif
  if [ "${TRACE:-saif}" = vcd ]; then SIMDIR=build/sim/${NAME}_vcd; TRACEARGS="--trace +define+TB_SAIF"; EXT=vcd; fi
  if [ -n "${PWRMON:-}" ]; then
    SIMDIR=${SIMDIR}_mon
    TRACEARGS="$TRACEARGS +define+TB_PWR_MON=\"$REPO/$PWRMON\""
  fi
fi
mkdir -p "$SIMDIR" "$LOGDIR"

# same sources (and patches) as synthesis
SRCS="${PRE_SOURCES:-} $(grep -v -e '^//' -e '^+' -e '^\s*$' "cores/$CORE/sky130/sources.f" | tr '\n' ' ')"
INCS="$(sed -n 's/^+incdir+//p' "cores/$CORE/sky130/sources.f") $EXTRA_INC"
PATCHED=build/patched/sim/$CORE
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
[ "$CORE" = veer_el2 ] && SRCS="cores/veer_el2/config/$CFG/common_defines.vh $SRCS"

WRAP=cores/$CORE/wrapper/${CORE}_wrap.sv
WRAPMOD=${CORE}_wrap
if [ "$CORE" = veer_el2 ] && [ "$CFG" = tcm ]; then
  # VeeR with ICCM/DCCM: el2_veer_wrapper (core + el2_mem + JTAG/DMI) + behavioural TCM banks
  R=cores/veer_el2/rtl/design
  SRCS="$SRCS $R/el2_mem.sv $R/el2_veer_wrapper.sv $R/el2_veer_lockstep.sv $R/dmi/dmi_mux.v $R/dmi/dmi_wrapper.v \
        $R/dmi/dmi_jtag_to_core_sync.v $R/dmi/rvjtag_tap.v cores/veer_el2/wrapper/veer_tcm_mem.sv"
  WRAP=cores/veer_el2/wrapper/veer_el2_tcm_wrap.sv
  WRAPMOD=veer_el2_tcm_wrap
fi
INCARGS=""; for i in $INCS; do INCARGS="$INCARGS -I$i"; done
DEFARGS=""; for d in $DEFINES; do [ "$d" = SYNTHESIS ] || DEFARGS="$DEFARGS +define+$d"; done

if [ ! -x "$SIMDIR/Vtb_top" ] || [ -n "${REBUILD:-}" ]; then
  echo "[sim] building $NAME"
  verilator --binary --timing -j 4 -O3 $TRACEARGS --x-assign fast --x-initial fast \
    -Wno-fatal -Wno-lint -Wno-style -Wno-TIMESCALEMOD -Wno-MULTIDRIVEN -Wno-UNOPTFLAT \
    -Wno-IMPLICITSTATIC -Wno-INITIALDLY -Wno-SIDEEFFECT -Wno-ASCRANGE -Wno-LATCH \
    --top-module tb_top +define+CORE_WRAP=$WRAPMOD $DEFARGS $INCARGS \
    --Mdir "$SIMDIR/obj" -o ../Vtb_top \
    $SRCS common/wrapper/obi32to64.sv common/wrapper/ahbl2obi.sv common/wrapper/axi2obi64.sv \
    "$WRAP" common/tb/tb_mem.sv common/tb/tb_top.sv > "$SIMDIR/build.log" 2>&1 \
    || { echo "[sim] build failed, see $SIMDIR/build.log"; tail -20 "$SIMDIR/build.log"; exit 1; }
fi

BENCHES=${*:-$(make -s -C common/bench list)}
make -s -C common/bench all power > /dev/null
for b in $BENCHES; do
  hex=build/bench/$b.hex
  [ -f "$hex" ] || { echo "[sim] missing $hex"; exit 1; }
  PLUS=""; [ "${SAIF:-0}" = 1 ] && PLUS="+saif=$LOGDIR/$b${TRACE:+_$TRACE}.${EXT}"
  [ -n "${DUMPLIMIT:-}" ] && PLUS="$PLUS +dumplimit=$DUMPLIMIT"
  "$SIMDIR/Vtb_top" +hex="$hex" $PLUS > "$LOGDIR/$b.log" 2>&1 || true
  echo "[sim] $NAME $b: $(grep TB_RESULT "$LOGDIR/$b.log" || echo 'no TB_RESULT (crash?)')"
done

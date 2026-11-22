#!/usr/bin/env bash
# Simulate one FPGA top (fpga/rtl/<core>_fpga.v = fpga_shell + the ASIC flow's core wrapper) in
# Verilator, driven over AXI4-Lite like the PS (fpga/sim/tb_fpga.sv), and compare every benchmark
# with the core's RTL simulation (results/raw/sim/<core>_<cfg>/<bench>.log, flows/sim.sh):
# exit code, console output, total cycles and marked (benchmark-window) cycles must all be identical.
# usage: fpga/sim/run_sim.sh <core> [bench ...]     (default: all benchmarks, as flows/sim.sh)
# Sources come from fpga/vivado/sources.tcl, the same list Vivado builds.
# Logs: results/raw/fpga/sim/<core>/<bench>.log and summary.txt. Exit status 0 only if all match.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO"
source flows/env.sh
CORE=${1:?core (hazard3 | ibex | veer_el2)}; shift
case $CORE in veer_el2) RTLCFG=min ;; *) RTLCFG=default ;; esac   # RTL-sim reference (ASIC config)
OUT=build/fpga/$CORE
LOG=results/raw/fpga/sim/$CORE
mkdir -p "$OUT" "$LOG"

LIST=$(tclsh fpga/vivado/sources.tcl "$CORE" "$OUT" sim)
TOP=$(sed -n 's/^TOP //p' <<<"$LIST")
SRCS=$(sed -n 's/^SRC //p' <<<"$LIST" | tr '\n' ' ')
INCARGS=$(sed -n 's/^INC /-I/p' <<<"$LIST" | tr '\n' ' ')
DEFARGS=$(sed -n 's/^DEF /+define+/p' <<<"$LIST" | tr '\n' ' ')
TRACE=${TRACE:-0}
TRACE_ARGS=()
if [ "$TRACE" = "1" ]; then TRACE_ARGS+=(--trace --trace-structs); fi

if [ ! -x "$OUT/Vtb_fpga" ] || [ -n "${REBUILD:-}" ] || [ "$TRACE" = "1" ]; then
  echo "[fpga-sim] building $TOP"
  verilator --binary --timing -j 4 -O3 --x-assign fast --x-initial fast \
    "${TRACE_ARGS[@]}" \
    -Wno-fatal -Wno-lint -Wno-style -Wno-TIMESCALEMOD -Wno-MULTIDRIVEN -Wno-UNOPTFLAT \
    -Wno-IMPLICITSTATIC -Wno-INITIALDLY -Wno-SIDEEFFECT -Wno-ASCRANGE -Wno-LATCH \
    --top-module tb_fpga +define+FPGA_TOP=$TOP $DEFARGS $INCARGS \
    --Mdir "$OUT/obj" -o ../Vtb_fpga $SRCS fpga/sim/tb_fpga.sv > "$OUT/build.log" 2>&1 \
    || { echo "[fpga-sim] build failed, see $OUT/build.log"; tail -20 "$OUT/build.log"; exit 1; }
fi

if [ "$TRACE" = "1" ]; then
  # Trace mode uses the checked-in Verilog hex images so generating a waveform
  # does not require rebuilding software with the RISC-V GCC toolchain.
  TRACE_BENCH=${TRACE_BENCH:-${*:-rv32ui-simple}}
  BENCHES=$TRACE_BENCH
  mkdir -p results/raw/fpga/waves
else
  BENCHES=${*:-$(make -s -C common/bench list)}
  make -s -C common/bench all > /dev/null
fi
for b in $BENCHES; do
  if [ "$TRACE" = "1" ]; then
    hex="fpga/sw/hex/$b.hex"
    if [ ! -f "$hex" ]; then
      echo "[fpga-sim] trace image not found: $hex"
      exit 1
    fi
    "$OUT/Vtb_fpga" +hex="$hex" +trace=results/raw/fpga/waves/${CORE}_${b}.vcd > "$LOG/$b.log" 2>&1 || true
  else
    "$OUT/Vtb_fpga" +hex=build/bench/$b.hex > "$LOG/$b.log" 2>&1 || true
  fi
done
python3 - "$CORE" "$LOG" "results/raw/sim/${CORE}_$RTLCFG" $BENCHES <<'PY'
import re, sys, os
core, log, ref, benches = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
def parse(path, tag):
    t = open(path, errors="replace").read()
    m = re.search(tag + r" core=\S+ exit=(\S+) cycles=(\d+) marked_cycles=(\d+)", t)
    if not m: return None
    con = t[:m.start()]
    if tag == "TB_RESULT":   # RTL tb prints console live; drop Verilator's trailing newline handling
        pass
    return m.group(1), int(m.group(2)), int(m.group(3)), con.rstrip("\n")
lines, ok = [], 0
for b in benches:
    f = parse(os.path.join(log, b + ".log"), "FPGA_RESULT")
    r = parse(os.path.join(ref, b + ".log"), "TB_RESULT")
    if f is None or r is None:
        lines.append(f"FAIL {b}: missing result (fpga={f is not None}, rtl={r is not None})"); continue
    same = f[0] == r[0] and f[1] == r[1] and f[2] == r[2] and f[3] == r[3]
    st = "PASS" if same and f[0] == "0" else "FAIL"
    ok += st == "PASS"
    lines.append(f"{st} {b}: exit fpga={f[0]} rtl={r[0]}  cycles fpga={f[1]} rtl={r[1]}  "
                 f"marked fpga={f[2]} rtl={r[2]}  console {'same' if f[3] == r[3] else 'DIFFERENT'}")
lines.append(f"{core}: {ok}/{len(benches)} benchmarks identical to RTL simulation ({ref})")
open(os.path.join(log, "summary.txt"), "w").write("\n".join(lines) + "\n")
print("\n".join(lines))
sys.exit(0 if ok == len(benches) else 1)
PY

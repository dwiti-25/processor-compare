#!/usr/bin/env bash
# Unattended core-only layout with the current flow settings (DECISIONS.md: post-route repair).
# usage: flows/run_layout.sh <core> <clk_mhz> [min_docker_gib]
# - waits for the Docker daemon; if a run dies because Docker restarted, retries once (RETRY=0: never)
# - flows/memwatch.sh samples container memory and free disk into the run dir (memwatch.log);
#   it stops the container cleanly if free disk drops below 1 GiB
# - min_docker_gib: skip (exit 3) unless the Docker VM has at least this much memory
# Progress lines go to results/raw/sky130/queue.log.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
CORE=${1:?core}; CLK=${2:?clk}; MINGIB=${3:-0}
Q=results/raw/sky130/queue.log
log() { echo "$(date '+%F %T') $CORE@${CLK}: $*" | tee -a "$Q"; }
wait_docker() { for _ in $(seq 1 360); do docker info >/dev/null 2>&1 && return 0; sleep 10; done; return 1; }

wait_docker || { log "docker not available after 1 h, giving up"; exit 2; }
MEM=$(docker info --format '{{.MemTotal}}')
if [ "$MINGIB" != 0 ] && [ "$MEM" -lt $(python3 -c "print(int($MINGIB*2**30))") ]; then
  log "skipped: Docker memory $(python3 -c "print(round($MEM/2**30,2))") GiB < $MINGIB GiB"
  exit 3
fi
for attempt in $(seq 1 $((1 + ${RETRY:-1}))); do
  log "start (attempt $attempt, Docker $(python3 -c "print(round($MEM/2**30,2))") GiB)"
  ML=build/memwatch_${CORE}_${CLK}MHz.log; rm -f "$ML"
  flows/memwatch.sh "$ML" 15 1 & MW=$!
  WRAP=1 HARDEN=1 PGRT=1 REPAIR_MARGIN=1 POSTROUTE=1 TAG=postroute flows/synth.sh "$CORE" "$CLK"
  rc=$?
  kill $MW; wait $MW 2>/dev/null
  RD=$(ls -d results/raw/sky130/$CORE/harden_*_${CLK}MHz_postroute 2>/dev/null | head -1)
  [ -n "$RD" ] && cp "$ML" "$RD/memwatch.log"
  log "peak container memory $(sed -n 's/.*peak_container_mem_mib //p' "$ML") MiB"
  [ $rc = 0 ] && { log "done"; exit 0; }
  if ! docker info >/dev/null 2>&1 || grep -q "Cannot connect to the Docker daemon" \
      "results/raw/sky130/$CORE"/harden_*_${CLK}MHz_postroute/librelane.log 2>/dev/null; then
    log "failed rc=$rc with Docker down/restarted; waiting to retry"
    wait_docker || { log "docker not back"; exit 2; }
    MEM=$(docker info --format '{{.MemTotal}}')
    continue
  fi
  log "failed rc=$rc (not a Docker restart); see librelane.log"
  exit 1
done
log "failed (no retries left)"; exit 1

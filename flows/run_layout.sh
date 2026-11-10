#!/usr/bin/env bash
# Unattended core-only layout with the current flow settings (DECISIONS.md: post-route repair).
# usage: flows/run_layout.sh <core> <clk_mhz> [min_docker_gib]
# - waits for the Docker daemon; if a run dies because Docker restarted, retries once
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
for attempt in 1 2; do
  log "start (attempt $attempt, Docker $(python3 -c "print(round($MEM/2**30,2))") GiB)"
  WRAP=1 HARDEN=1 PGRT=1 REPAIR_MARGIN=1 POSTROUTE=1 TAG=postroute flows/synth.sh "$CORE" "$CLK"
  rc=$?
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
log "failed twice"; exit 1

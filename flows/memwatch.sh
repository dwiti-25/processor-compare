#!/usr/bin/env bash
# Sample memory of the running LibreLane container(s) and free disk while a layout runs.
# usage: flows/memwatch.sh <log> [interval_s=15] [min_free_gib=1]
# Each line: time, container memory use / limit (docker stats), free disk on the repo volume.
# Ends with "peak <MiB>" lines when killed (SIGTERM) by the caller. If free disk drops below
# min_free_gib, the LibreLane container is stopped (clean failure, recorded in the log).
set -u
LOG=${1:?log}; IV=${2:-15}; MINFREE=${3:-1}
REPO="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO/flows/env.sh"
peak=0
finish() { echo "$(date '+%F %T') peak_container_mem_mib $peak" >> "$LOG"; exit 0; }
trap finish TERM INT
echo "# $(date '+%F %T') memwatch start; Docker VM memory $(docker info --format '{{.MemTotal}}' 2>/dev/null) bytes" >> "$LOG"
while :; do
  ids=$(docker ps -q --filter ancestor="$LIBRELANE_IMAGE")   # LibreLane only, not other containers
  line=""
  [ -n "$ids" ] && line=$(docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' $ids 2>/dev/null | head -1)
  free_k=$(df -k "$REPO" | awk 'NR==2 {print $4}')
  if [ -n "$line" ]; then
    used=$(echo "$line" | awk '{print $2}')
    mib=$(python3 -c "
import re,sys; m=re.match(r'([0-9.]+)([KMG]i?B)', sys.argv[1]); v,u=float(m.group(1)),m.group(2)
print(int(v*{'KiB':1/1024,'kB':1/1024,'MiB':1,'MB':1,'GiB':1024,'GB':1024}[u]))" "$used" 2>/dev/null || echo 0)
    [ "$mib" -gt "$peak" ] && peak=$mib
    echo "$(date '+%F %T') $line free_disk_gib $(python3 -c "print(round($free_k/2**20,2))")" >> "$LOG"
  fi
  if [ "$free_k" -lt $(python3 -c "print(int($MINFREE*2**20))") ]; then
    echo "$(date '+%F %T') STOP: free disk below $MINFREE GiB; stopping LibreLane container" >> "$LOG"
    docker ps -q --filter ancestor="$LIBRELANE_IMAGE" | xargs -r docker stop >/dev/null 2>&1
  fi
  sleep "$IV" & wait $!
done

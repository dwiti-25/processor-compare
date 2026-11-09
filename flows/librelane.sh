#!/usr/bin/env bash
# Run LibreLane inside its pinned container. Repo and PDK are mounted at the same absolute paths.
# usage: flows/librelane.sh <config.json> [librelane args...]
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO/flows/env.sh"
docker run --rm -v "$REPO:$REPO" -v "$PDK_ROOT:$PDK_ROOT" -w "$REPO" \
  -e PDK_ROOT="$PDK_ROOT" -e PDK="$PDK" \
  "$LIBRELANE_IMAGE" librelane --manual-pdk --pdk-root "$PDK_ROOT" --pdk "$PDK" "$@"

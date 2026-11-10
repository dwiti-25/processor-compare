#!/usr/bin/env bash
# Run LibreLane inside its pinned container. Repo and PDK are mounted at the same absolute paths.
# usage: flows/librelane.sh <config.json> [librelane args...]
# flows/llplugins is on PYTHONPATH so LibreLane discovers our plugin (post-route repair flow).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO/flows/env.sh"
docker run --rm -v "$REPO:$REPO" -v "$PDK_ROOT:$PDK_ROOT" -w "$REPO" \
  -e PDK_ROOT="$PDK_ROOT" -e PDK="$PDK" \
  -e PYTHONPATH="$REPO/flows/llplugins" \
  "$LIBRELANE_IMAGE" librelane --manual-pdk --pdk-root "$PDK_ROOT" --pdk "$PDK" "$@"

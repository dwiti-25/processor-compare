# Common tool environment, sourced by flows/*.sh. Override any variable from the shell.
: "${OSS_CAD_SUITE:=$HOME/tools/oss-cad-suite}"
: "${PDK_ROOT:=$HOME/.ciel}"
: "${PDK:=sky130A}"
: "${LIBRELANE_IMAGE:=ghcr.io/librelane/librelane:3.0.17}"
export PDK_ROOT PDK
if ! command -v yosys >/dev/null 2>&1 && [ -f "$OSS_CAD_SUITE/environment" ]; then
  # shellcheck disable=SC1091
  source "$OSS_CAD_SUITE/environment"
fi

# OpenSTA: native `sta` if present, otherwise the one inside the LibreLane container
# (repo and PDK are mounted at the same absolute paths).
run_sta() {
  if command -v sta >/dev/null 2>&1; then
    sta -no_init -no_splash -exit "$@"
  else
    docker run --rm -v "$PWD:$PWD" -v "$PDK_ROOT:$PDK_ROOT" -w "$PWD" \
      $(env | grep -E '^STA_' | sed 's/^/-e /' | cut -d= -f1) \
      "$LIBRELANE_IMAGE" sta -no_init -no_splash -exit "$@"
  fi
}

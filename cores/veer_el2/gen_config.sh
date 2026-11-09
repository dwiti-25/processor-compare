#!/usr/bin/env bash
# Generate the VeeR EL2 configurations used in this project with veer.config.
# Output goes to cores/veer_el2/config/<name>/ (vendor tree untouched).
#   min : no ICCM/DCCM/I-cache, no U-mode/bitmanip/lockstep, 1 IRQ, BTB off  (primary, fair-comparison config)
#   bp  : same as min but with the typical_pd branch predictor (BTB 32 / BHT 128 / RAS 2)  (sensitivity point)
# PMP stays at the RTL minimum of 16 entries: pmp_entries=0 is accepted by veer.config
# but the RTL declares [PMP_ENTRIES]-sized arrays, which do not elaborate at 0 (see docs/LIMITATIONS.md).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
export RV_ROOT="$HERE/rtl"

COMMON=(
  -target=typical_pd  # VeeR's physical-design target: AXI4, no ICCM, BTB 32 / BHT 128 / RAS 2
  -fpga_optimize=0   # ASIC: keep VeeR's clock gating (veer.config defaults to 1 = FPGA style)
  -set=iccm_enable=0 -set=dccm_enable=0 -set=icache_enable=0
  -set=user_mode=0 -set=lockstep_enable=0
  -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0
  -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0
  -set=pic_total_int=1
)

gen() {
  local name=$1; shift
  rm -rf "$HERE/config/$name"
  mkdir -p "$HERE/config/$name"
  (cd "$HERE/config/$name" && BUILD_PATH="$HERE/config/$name" perl "$RV_ROOT/configs/veer.config" "${COMMON[@]}" "$@" > gen.log 2>&1)
}

gen min -set=btb_enable=0
gen bp

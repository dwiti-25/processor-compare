# RISC-V processor comparison: top-level entry points.
#   make <core>-synth  TECH=sky130 CLK=50 [CFG=...]   core-only synthesis + timing estimate
#   make <core>-sim                                    RTL sim (P1, not yet implemented)
#   make <core>-harden TECH=sky130 SCOPE=core CLK=50   LibreLane RTL-to-GDS (P2, not yet implemented)
#   make smoke                                         LibreLane counter to GDS (flow check)
#   make all-synth / all-results
CORES := hazard3 ibex veer_el2
TECH  ?= sky130
CLK   ?= 50
SCOPE ?= core
CFG   ?=

.PHONY: all-synth all-results smoke veer-configs $(addsuffix -synth,$(CORES)) $(addsuffix -sim,$(CORES)) $(addsuffix -harden,$(CORES))

veer-configs:
	cores/veer_el2/gen_config.sh

$(addsuffix -synth,$(CORES)): %-synth:
	@test "$(TECH)" = sky130 || { echo "TECH=$(TECH) not implemented yet"; exit 1; }
	flows/synth.sh $* $(CLK) $(CFG)

veer_el2-synth: veer-configs

all-synth: $(addsuffix -synth,$(CORES))
	flows/synth.sh veer_el2 $(CLK) bp

$(addsuffix -sim,$(CORES)) $(addsuffix -harden,$(CORES)):
	@echo "$@: not implemented yet (see RUNSHEET.md, prompts 4-5)"; exit 1

smoke:
	flows/librelane.sh flows/smoke/counter/config.json --run-tag smoke --overwrite

all-results:
	scripts/collect.py

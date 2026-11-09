# RISC-V processor comparison: top-level entry points.
#   make <core>-synth  TECH=sky130 CLK=50 [CFG=...]   core-only synthesis + post-GPL timing estimate
#   make <core>-postcts CLK=50 [CFG=...]               + CTS / timing repair estimate (after -synth)
#   make <core>-sim                                    RTL sim (P1, not yet implemented)
#   make <core>-harden TECH=sky130 SCOPE=core CLK=50   LibreLane RTL-to-GDS (P2, not yet implemented)
#   make smoke                                         LibreLane counter to GDS (flow check)
#   make all-synth / all-results
CORES := hazard3 ibex veer_el2
TECH  ?= sky130
CLK   ?= 50
SCOPE ?= core
CFG   ?=

.PHONY: all-synth all-results smoke veer-configs $(addsuffix -synth,$(CORES)) $(addsuffix -sim,$(CORES)) $(addsuffix -harden,$(CORES)) $(addsuffix -postcts,$(CORES))

veer-configs:
	cores/veer_el2/gen_config.sh

$(addsuffix -synth,$(CORES)): %-synth:
	@test "$(TECH)" = sky130 || { echo "TECH=$(TECH) not implemented yet"; exit 1; }
	flows/synth.sh $* $(CLK) $(CFG)

veer_el2-synth: veer-configs

$(addsuffix -postcts,$(CORES)): %-postcts:
	flows/postcts.sh $* $(CLK) $(CFG)

all-synth: $(addsuffix -synth,$(CORES))
	flows/synth.sh veer_el2 $(CLK) bp
	for c in $(CORES); do flows/postcts.sh $$c $(CLK); done
	flows/postcts.sh veer_el2 $(CLK) bp

$(addsuffix -sim,$(CORES)) $(addsuffix -harden,$(CORES)):
	@echo "$@: not implemented yet (see RUNSHEET.md, prompts 4-5)"; exit 1

smoke:
	flows/librelane.sh flows/smoke/counter/config.json --run-tag smoke --overwrite

all-results:
	scripts/collect.py --update-report reports/initial_synthesis.md
	scripts/collect.py --headline --update-report reports/email_prof_draft.md
	~/tools/venv/bin/python scripts/md2pdf.py reports/initial_synthesis.md

# Post-route repair for the LibreLane Classic flow (project flow change, same for every core).
#
# Why: OpenROAD's design/timing repair in the Classic flow works only from pre-route parasitic
# estimates (placement or global-routing RC). After detailed routing, RCX shows much larger wire
# loads on some nets (e.g. a clkbuf_1 driving 105 fF of routed wire, 1.33 ns slew at nom_tt), and
# the Classic flow has no repair after detailed routing, so max-slew/max-cap and ss setup fail.
#
# What: after the first detailed route, extract parasitics (RCX), annotate them in STA on every
# STA corner, run repair_design + repair_timing (setup, then hold) against those extracted
# parasitics, legalise the placement, drop the signal routing, and route again
# (GRT -> antenna repair -> DRT). The rest of the Classic flow (fill, RCX, sign-off STA, DRC,
# LVS, checkers) then runs unchanged on the re-routed design. Sign-off limits are not touched.
#
# Loaded by LibreLane's plugin discovery (module name librelane_plugin_*), via PYTHONPATH set in
# flows/librelane.sh. Select with meta.flow = "ClassicPostRouteRepair".
import os
from typing import List, Tuple

from librelane.flows import Flow
from librelane.flows.classic import Classic
from librelane.state import DesignFormat
from librelane.steps import OpenROAD, Step, TclStep
from librelane.steps.openroad import ResizerStep


def _union_vars(*classes):
    seen, out = set(), []
    for c in classes:
        for v in c.config_vars:
            if v.name not in seen:
                seen.add(v.name)
                out.append(v)
    return out


@Step.factory.register()
class PostRouteRepair(ResizerStep):
    """
    Design-rule (slew/cap/fanout) and timing (setup, hold) repair using RCX parasitics of the
    detailed-routed design. Placement is re-legalised and signal routing removed, so the flow must
    route again afterwards.
    """

    id = "PostRoute.Repair"
    name = "Repair Design + Timing on Extracted (Post-Route) Parasitics"

    inputs = [DesignFormat.ODB, DesignFormat.SPEF]
    # Reuses the post-GRT repair knobs (GRT_DESIGN_REPAIR_*, GRT_RESIZER_*), so the post-route
    # repair uses exactly the margins of the post-GRT repair.
    config_vars = _union_vars(
        ResizerStep, OpenROAD.RepairDesignPostGRT, OpenROAD.ResizerTimingPostGRT
    )

    def get_script_path(self):
        return os.path.join(os.path.dirname(__file__), "postroute_repair.tcl")

    def run(self, state_in, **kwargs):
        kwargs, env = self.extract_env(kwargs)
        spef_dict = state_in.get(DesignFormat.SPEF)
        if not isinstance(spef_dict, dict) or not spef_dict:
            raise RuntimeError("PostRoute.Repair needs RCX SPEFs in the input state")
        corners = self.config["RSZ_CORNERS"] or self.config["STA_CORNERS"]
        pairs: List[Tuple[str, str]] = []
        for corner in corners:
            spefs = self.toolbox.filter_views(self.config, spef_dict, corner)
            if len(spefs) < 1:
                raise RuntimeError(f"no SPEF for corner {corner}")
            pairs.append((corner, str(spefs[0])))
        env["_PR_SPEFS"] = TclStep.value_to_tcl([list(p) for p in pairs])
        views, metrics = super().run(state_in, env=env, **kwargs)
        # SPEFs no longer match the design (cells resized/added, routing removed).
        views[DesignFormat.SPEF] = None
        return views, metrics


def _post_route_steps():
    steps = list(Classic.Steps)
    i = steps.index(OpenROAD.DetailedRouting)
    return (
        steps[: i + 1]
        + [
            OpenROAD.RCX,
            PostRouteRepair,
            OpenROAD.GlobalRouting,
            OpenROAD.RepairAntennas,
            OpenROAD.DetailedRouting,
        ]
        + steps[i + 1 :]
    )


@Flow.factory.register()
class ClassicPostRouteRepair(Classic):
    """Classic flow + one repair pass on extracted parasitics after detailed routing."""

    Steps = _post_route_steps()

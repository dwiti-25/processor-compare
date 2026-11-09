#!/usr/bin/env python3
"""Parse tool reports under results/raw/ into results/results.csv.

Every number in tables, reports, emails or the paper must come from this script.

usage:
  scripts/collect.py              # rebuild results/results.csv
  scripts/collect.py --md synth   # also print the synthesis table as Markdown
  scripts/collect.py --update-report reports/initial_synthesis.md
  scripts/collect.py --headline --update-report reports/email_prof_draft.md
                                  # rewrite the table between the BEGIN/END collect.py markers
"""
import argparse
import csv
import glob
import json
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(REPO, "results", "raw")
CSV = os.path.join(REPO, "results", "results.csv")
SIM_CSV = os.path.join(REPO, "results", "sim_results.csv")
SIM_COLUMNS = ["core", "config", "bench", "exit", "cycles", "marked_cycles", "iterations",
               "coremark_per_mhz", "dhrystone_cycles_per_run", "dmips_per_mhz", "log_path"]
HARDEN_CSV = os.path.join(REPO, "results", "harden_results.csv")
HARDEN_COLUMNS = ["core", "config", "top", "clock_target_mhz", "run_id", "settings",
                  "r2r_slack_tt_ns", "fmax_tt_mhz", "r2r_slack_ss_ns", "fmax_ss_mhz",
                  "r2r_slack_ss_maxrc_ns", "fmax_ss_maxrc_mhz", "magic_drc", "klayout_drc", "lvs_errors",
                  "antenna_nets", "route_drc", "setup_ws_tt_ns", "setup_ws_ss_ns", "setup_ws_ff_ns",
                  "setup_ws_worst_ns", "setup_vio_count", "hold_ws_worst_ns", "hold_vio_count",
                  "max_slew_vio", "max_cap_vio", "die_area_um2", "core_area_um2", "stdcells",
                  "power_total_w", "signoff_clean", "report_path"]
COREMARK_ITER = 10      # common/bench/Makefile COREMARK_ITER
# Published CoreMark/MHz (source, configuration it was measured with)
PUBLISHED = {
    "hazard3": (4.15, "https://github.com/Wren6991/Hazard3#rp2350",
                "RP2350 config: Zba/Zbb/Zbkb/Zbs, fast multiply, branch predictor; GCC -O3 + tuning flags"),
    "ibex": (2.47, "https://github.com/lowRISC/ibex#configuration",
             "\"small\" config on Ibex Simple System; -O3 -funroll-all-loops"),
    "veer_el2": (3.6, "https://www.westerndigital.com/company/newsroom/press-releases/2019/2019-12-10-western-digital-brings-memory-closer-to-compute-with-new-risc-v-innovations",
                 "Western Digital, simulated; memory configuration not stated"),
}
DHRYSTONE_RUNS = 500    # riscv-tests dhrystone.h NUMBER_OF_RUNS

COLUMNS = [
    "core", "core_commit", "config", "top", "technology", "scope", "stage", "clock_target_mhz", "run_id",
    "frontend", "patches", "tool_versions", "pdk_version",
    "cells", "area_um2", "sequential_area_um2", "flops", "latches", "clock_gates",
    "setup_ws_all_ns_postgpl_tt", "reg2reg_slack_ns_postgpl_tt", "fmax_est_mhz_postgpl_tt",
    "setup_ws_all_ns_postcts_tt", "reg2reg_slack_ns_postcts_tt", "fmax_est_mhz_postcts_tt",
    "report_path",
]

FRONTEND_NAMES = {"slang": "yosys-slang", "verilog": "Yosys read_verilog"}
# Display names for configs whose run directories use the flow's generic CFG name.
CONFIG_LABELS = {("ibex", "default"): "small"}


def read_kv(path):
    out = {}
    with open(path) as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            k, _, v = line.partition("=") if "=" in line.split(" ", 1)[0] else line.partition(" ")
            out[k.strip()] = v.strip()
    return out


def classify(cell):
    """sky130_fd_sc_hd cell name -> 'flop' | 'latch' | 'icg' | None"""
    base = cell.split("__", 1)[-1]
    if base.startswith("dlclkp") or base.startswith("sdlclkp"):
        return "icg"
    if re.match(r"(df|edf|sdf|sedf)", base):
        return "flop"
    if re.match(r"dl", base):
        return "latch"
    return None


def parse_r2r(rpt):
    """{corner: (slack_ns, startpoint, endpoint)} from flows/sta_r2r_hook.tcl's r2r.rpt."""
    out = {}
    for line in open(rpt):
        f = line.split()
        if len(f) >= 8 and f[0] == "r2r" and f[2] == "slack":
            out[f[1]] = (float(f[3]), f[5], f[7])
    return out


def parse_synth(run_dir):
    info = read_kv(os.path.join(run_dir, "run.info"))
    stat = json.load(open(os.path.join(run_dir, "yosys_reports", "stat.json")))
    mods = stat["modules"]
    assert len(mods) == 1, f"expected one flattened module in {run_dir}"
    m = next(iter(mods.values()))
    counts = {"flop": 0, "latch": 0, "icg": 0}
    for cell, n in m["num_cells_by_type"].items():
        c = classify(cell)
        if c:
            counts[c] += n

    # timing estimates (tt only; LibreLane mid-PnR STA loads only the default corner):
    #   postgpl: after global placement + design-rule repair, ideal clocks
    #   postcts: after detailed placement, CTS and post-CTS timing repair, propagated clocks
    corner = "nom_tt_025C_1v80"
    period = float(json.load(open(os.path.join(run_dir, "resolved.json")))["CLOCK_PERIOD"])
    est = {}
    for stage in ("postgpl", "postcts"):
        d = os.path.join(run_dir, f"sta_{stage}")
        if not os.path.exists(os.path.join(d, "r2r.rpt")):
            est[stage] = ("", "", "")
            continue
        slack = parse_r2r(os.path.join(d, "r2r.rpt"))[corner][0]
        ws_all = json.load(open(os.path.join(d, "state_out.json")))["metrics"][f"timing__setup__ws__corner:{corner}"]
        est[stage] = (round(ws_all, 3), round(slack, 3), round(1000.0 / (period - slack), 1))
    yosys_ver = ""
    log = os.path.join(run_dir, "yosys-synthesis.log")
    if os.path.exists(log):
        mm = re.search(r"Yosys (\S+)", open(log, errors="replace").read(4000))
        yosys_ver = mm.group(1) if mm else ""
    return {
        "core": info["core"], "core_commit": info["core_commit"], "config": CONFIG_LABELS.get((info["core"], info["config"]), info["config"]),
        "top": "wrapper" if info["top"].endswith("_wrap") else "vendor",
        "technology": "sky130", "scope": "core", "stage": "synth",
        "clock_target_mhz": info["clk_mhz"], "run_id": os.path.basename(run_dir),
        "frontend": FRONTEND_NAMES.get(info["frontend"], info["frontend"]),
        "patches": info.get("patches", "").strip(),
        "tool_versions": f"{info['librelane_image'].split('/')[-1]}; yosys {yosys_ver}".strip(),
        "pdk_version": f"{info['pdk']} {info['pdk_version']}",
        "cells": m["num_cells"], "area_um2": round(m["area"], 1),
        "sequential_area_um2": round(m.get("sequential_area", 0.0), 1),
        "flops": counts["flop"], "latches": counts["latch"], "clock_gates": counts["icg"],
        **{f"{k}_{stage}_tt": v for stage in ("postgpl", "postcts")
           for k, v in zip(("setup_ws_all_ns", "reg2reg_slack_ns", "fmax_est_mhz"), est[stage])},
        "report_path": os.path.relpath(run_dir, REPO),
    }


def collect():
    rows = []
    for d in sorted(glob.glob(os.path.join(RAW, "sky130", "*", "synth_*"))):
        try:
            rows.append(parse_synth(d))
        except (FileNotFoundError, KeyError) as e:
            print(f"[collect] skipping incomplete run {os.path.relpath(d, REPO)}: {e}", file=sys.stderr)
    return rows


def prefer_wrapped(rows):
    """One row per (core, config): the wrapped run if there is one, else the vendor-top run."""
    best = {}
    for r in rows:
        k = (r["core"], r["config"], r["clock_target_mhz"])
        if k not in best or (r["top"] == "wrapper" and best[k]["top"] != "wrapper"):
            best[k] = r
    return list(best.values())


def collect_harden():
    """Core-only layout runs (results/raw/sky130/<core>/harden_*): sign-off metrics from LibreLane."""
    rows = []
    for d in sorted(glob.glob(os.path.join(RAW, "sky130", "*", "harden_*"))):
        mf = os.path.join(d, "final", "metrics.json")
        if not os.path.exists(mf):
            continue
        info = read_kv(os.path.join(d, "run.info"))
        m = json.load(open(mf))
        g = lambda k: m.get(k, "")
        r = {
            "core": info["core"], "config": CONFIG_LABELS.get((info["core"], info["config"]), info["config"]),
            "top": "wrapper" if info["top"].endswith("_wrap") else "vendor",
            "clock_target_mhz": info["clk_mhz"], "run_id": os.path.basename(d),
            "magic_drc": g("magic__drc_error__count"), "klayout_drc": g("klayout__drc_error__count"),
            "lvs_errors": g("design__lvs_error__count"), "antenna_nets": g("antenna__violating__nets"),
            "route_drc": g("route__drc_errors"),
            "setup_ws_tt_ns": round(g("timing__setup__ws__corner:nom_tt_025C_1v80"), 3),
            "setup_ws_ss_ns": round(g("timing__setup__ws__corner:nom_ss_100C_1v60"), 3),
            "setup_ws_ff_ns": round(g("timing__setup__ws__corner:nom_ff_n40C_1v95"), 3),
            "setup_ws_worst_ns": round(g("timing__setup__ws"), 3), "setup_vio_count": g("timing__setup_vio__count"),
            "hold_ws_worst_ns": round(g("timing__hold__ws"), 3), "hold_vio_count": g("timing__hold_vio__count"),
            "max_slew_vio": g("design__max_slew_violation__count"), "max_cap_vio": g("design__max_cap_violation__count"),
            "die_area_um2": round(g("design__die__area"), 1), "core_area_um2": round(g("design__core__area"), 1),
            "stdcells": g("design__instance__count__stdcell"), "power_total_w": g("power__total"),
            "report_path": os.path.relpath(d, REPO),
        }
        r["settings"] = info.get("harden_settings", "")
        period = 1000.0 / float(info["clk_mhz"])
        for key, corner in (("tt", "nom_tt_025C_1v80"), ("ss", "nom_ss_100C_1v60"), ("ss_maxrc", "max_ss_100C_1v60")):
            rp = os.path.join(d, "sta_postpnr", corner, "r2r.rpt")
            if os.path.exists(rp):
                sl = parse_r2r(rp)[corner][0]
                r[f"r2r_slack_{key}_ns"] = round(sl, 3)
                r[f"fmax_{key}_mhz"] = round(1000.0 / (period - sl), 1)
            else:
                r[f"r2r_slack_{key}_ns"] = r[f"fmax_{key}_mhz"] = ""
        r["signoff_clean"] = all(r[k] == 0 for k in ("magic_drc", "klayout_drc", "lvs_errors", "antenna_nets",
                                                     "setup_vio_count", "hold_vio_count", "max_slew_vio", "max_cap_vio"))
        rows.append(r)
    return rows


def md_harden(rows):
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    out = ["| Core | Clock (MHz) | Flow settings | fmax tt / ss (MHz) | DRC (Magic/KLayout) | LVS | Antenna | "
           "Setup WS tt / ss / ff (ns) | Setup viol. | Hold WS (ns) | Slew / cap viol. | Core area (µm²) | Std cells | "
           "Power (mW) | Sign-off clean (all corners) |",
           "|---|---:|---|---|---|---:|---:|---|---:|---:|---|---:|---:|---:|---|"]
    for r in sorted(rows, key=lambda r: (r["core"], float(r["clock_target_mhz"]), r["run_id"])):
        fm = f"{r['fmax_tt_mhz']} / {r['fmax_ss_mhz']}" if r["fmax_tt_mhz"] != "" else "n/a"
        out.append(f"| {names.get(r['core'], r['core'])} | {r['clock_target_mhz']} | {r['settings'] or 'n/a'} | {fm} | "
                   f"{r['magic_drc']}/{r['klayout_drc']} | "
                   f"{r['lvs_errors']} | {r['antenna_nets']} | {r['setup_ws_tt_ns']:+.2f} / {r['setup_ws_ss_ns']:+.2f} / "
                   f"{r['setup_ws_ff_ns']:+.2f} | {r['setup_vio_count']} | {r['hold_ws_worst_ns']:+.2f} | "
                   f"{r['max_slew_vio']} / {r['max_cap_vio']} | {r['core_area_um2']:,.0f} | {r['stdcells']:,} | "
                   f"{r['power_total_w'] * 1000:.1f} | {'yes' if r['signoff_clean'] else 'no'} |")
    return "\n".join(out)


def collect_sim():
    """RTL simulation results: one row per (core config, benchmark) from results/raw/sim logs."""
    rows = []
    for log in sorted(glob.glob(os.path.join(RAW, "sim", "*", "*.log"))):
        cfgdir = os.path.basename(os.path.dirname(log))
        core, _, config = cfgdir.rpartition("_")
        bench = os.path.splitext(os.path.basename(log))[0]
        m = re.search(r"TB_RESULT core=\S+ exit=(\S+) cycles=(\d+) marked_cycles=(\d+)", open(log, errors="replace").read())
        if not m:
            continue
        exit_, cycles, marked = m.group(1), int(m.group(2)), int(m.group(3))
        r = {"core": core, "config": CONFIG_LABELS.get((core, config), config), "bench": bench,
             "exit": exit_, "cycles": cycles, "marked_cycles": marked, "iterations": "",
             "coremark_per_mhz": "", "dhrystone_cycles_per_run": "", "dmips_per_mhz": "",
             "log_path": os.path.relpath(log, REPO)}
        if bench == "coremark" and exit_ == "0" and marked:
            r["iterations"] = COREMARK_ITER
            r["coremark_per_mhz"] = round(COREMARK_ITER * 1e6 / marked, 3)
        if bench == "dhrystone" and exit_ == "0" and marked:
            r["iterations"] = DHRYSTONE_RUNS
            per = marked / DHRYSTONE_RUNS
            r["dhrystone_cycles_per_run"] = round(per, 1)
            r["dmips_per_mhz"] = round(1e6 / per / 1757, 3)
        rows.append(r)
    return rows


def md_sim(rows):
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    out = ["| Core | Config | Tests passed | CoreMark/MHz | Dhrystone cycles/run | DMIPS/MHz |",
           "|---|---|---:|---:|---:|---:|"]
    for core in ("hazard3", "ibex", "veer_el2"):
        for cfg in sorted({r["config"] for r in rows if r["core"] == core}):
            rs = [r for r in rows if r["core"] == core and r["config"] == cfg]
            cm = next((r for r in rs if r["bench"] == "coremark"), {})
            dh = next((r for r in rs if r["bench"] == "dhrystone"), {})
            passed = sum(r["exit"] == "0" for r in rs)
            out.append(f"| {names[core]} | {cfg} | {passed}/{len(rs)} | {cm.get('coremark_per_mhz', '')} | "
                       f"{dh.get('dhrystone_cycles_per_run', '')} | {dh.get('dmips_per_mhz', '')} |")
    return "\n".join(out)


def md_synth(rows):
    order = {"hazard3": 0, "ibex": 1, "veer_el2": 2}
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    rows = sorted(rows, key=lambda r: (order.get(r["core"], 9), {"bp": 1}.get(r["config"], 0), float(r["clock_target_mhz"])))
    base = next((r["area_um2"] for r in rows if r["core"] == "hazard3"), None)
    out = ["| Core | Config | Synthesized top | Frontend | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | Latches | fmax |",
           "|---|---|---|---|---:|---:|---:|---:|---:|---|"]
    for r in rows:
        top = "core + wrapper" if r["top"] == "wrapper" else "vendor top (old)"
        out.append(f"| {names.get(r['core'], r['core'])} | {r['config']} | {top} | {r['frontend']} | "
                   f"{r['cells']:,} | {r['area_um2']:,.0f} | {r['area_um2'] / base:.2f}× | "
                   f"{r['flops']:,} | {r['latches']:,} | pending (full layout) |")
    return "\n".join(out)


HEADLINE = {"hazard3": "default", "ibex": "small", "veer_el2": "min"}


def md_headline(rows):
    """Short table for emails: one headline config per core."""
    names = {"hazard3": "Hazard3", "ibex": "Ibex (small)", "veer_el2": "VeeR EL2 (min)"}
    rows = [r for c, cfg in HEADLINE.items() for r in rows if r["core"] == c and r["config"] == cfg]
    base = next((r["area_um2"] for r in rows if r["core"] == "hazard3"), None)
    out = ["| Core | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | fmax |",
           "|---|---:|---:|---:|---:|---|"]
    for r in rows:
        name = names[r["core"]] + ("" if r["top"] == "wrapper" else " †")
        out.append(f"| {name} | {r['cells']:,} | {r['area_um2']:,.0f} | {r['area_um2'] / base:.2f}× | "
                   f"{r['flops']:,} | pending, will come from full layout |")
    if any(r["top"] != "wrapper" for r in rows):
        out.append("\n† Synthesized from the core's own top, not yet with the common wrapper; to be updated.")
    return "\n".join(out)


def md_sim_email(rows):
    """Benchmark table with published CoreMark/MHz and measured/published ratio."""
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    out = ["| Core | Config | Tests passed | CoreMark/MHz | DMIPS/MHz | Published CoreMark/MHz | Measured / published |",
           "|---|---|---:|---:|---:|---:|---:|"]
    for core, cfg in (("hazard3", "default"), ("ibex", "small"), ("veer_el2", "min"), ("veer_el2", "tcm")):
        cm = next((r for r in rows if r["core"] == core and r["config"] == cfg and r["bench"] == "coremark"), None)
        dh = next((r for r in rows if r["core"] == core and r["config"] == cfg and r["bench"] == "dhrystone"), None)
        if not cm or cm["coremark_per_mhz"] == "":
            continue
        pub = PUBLISHED[core][0]
        label = {"min": "no TCM (min)", "tcm": "ICCM + DCCM (tcm)"}.get(cfg, cfg)
        rs = [r for r in rows if r["core"] == core and r["config"] == cfg]
        passed = f"{sum(r['exit'] == '0' for r in rs)}/{len(rs)}"
        out.append(f"| {names[core]} | {label} | {passed} | {cm['coremark_per_mhz']:.2f} | "
                   f"{dh['dmips_per_mhz'] if dh else '':.2f} | {pub} | {cm['coremark_per_mhz'] / pub:.2f} |")
    return "\n".join(out)


def veer_tcm_ratio(rows):
    get = lambda cfg: next(r["coremark_per_mhz"] for r in rows
                           if r["core"] == "veer_el2" and r["config"] == cfg and r["bench"] == "coremark")
    return f"{get('tcm') / get('min'):.1f}"


def data_time(paths):
    import datetime
    t = max(os.path.getmtime(p) for p in paths)
    return datetime.datetime.fromtimestamp(t).strftime("%Y-%m-%d %H:%M %Z").strip() + " (IST)"


def fill_markers(path, tables):
    """Replace every <!-- BEGIN collect.py:<name> --> ... <!-- END collect.py --> block."""
    text = open(path).read()
    out, pos = [], 0
    for m in re.finditer(r"<!-- BEGIN collect\.py:(\w+) -->", text):
        end = text.index("<!-- END collect.py -->", m.end())
        out.append(text[pos:m.end()])
        body = tables[m.group(1)]
        out.append(body if "\n" not in body else "\n" + body + "\n")
        pos = end
    out.append(text[pos:])
    open(path, "w").write("".join(out))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", choices=["synth", "sim", "harden"], help="print a Markdown table to stdout")
    ap.add_argument("--update-report", metavar="MD", help="replace the synth table inside MD's markers")
    ap.add_argument("--headline", action="store_true", help="use the short one-config-per-core table")
    a = ap.parse_args()
    rows = collect()
    os.makedirs(os.path.dirname(CSV), exist_ok=True)
    with open(CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS)
        w.writeheader()
        w.writerows(rows)
    print(f"[collect] wrote {len(rows)} rows to {os.path.relpath(CSV, REPO)}", file=sys.stderr)
    sim = collect_sim()
    with open(SIM_CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=SIM_COLUMNS)
        w.writeheader()
        w.writerows(sim)
    print(f"[collect] wrote {len(sim)} rows to {os.path.relpath(SIM_CSV, REPO)}", file=sys.stderr)
    if a.md == "sim":
        print(md_sim(sim))
        return
    harden = collect_harden()
    with open(HARDEN_CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=HARDEN_COLUMNS)
        w.writeheader()
        w.writerows(harden)
    print(f"[collect] wrote {len(harden)} rows to {os.path.relpath(HARDEN_CSV, REPO)}", file=sys.stderr)
    if a.md == "harden":
        print(md_harden(harden))
        return
    synth = prefer_wrapped([r for r in rows if r["stage"] == "synth"])
    table = md_headline(synth) if a.headline else md_synth(synth)
    if a.md == "synth":
        print(table)
    if a.update_report:
        srcs = [os.path.join(REPO, r["report_path"], "yosys_reports", "stat.json") for r in synth] + \
               [os.path.join(REPO, r["log_path"]) for r in sim]
        tables = {"synth": md_synth(synth), "headline": md_headline(synth), "sim": md_sim(sim),
                  "sim_email": md_sim_email(sim), "veer_tcm_ratio": veer_tcm_ratio(sim),
                  "data_time": data_time(srcs)}
        text = open(a.update_report).read()
        if "<!-- BEGIN collect.py --md synth -->" in text:   # legacy single-table marker
            text = text.replace("<!-- BEGIN collect.py --md synth -->",
                                "<!-- BEGIN collect.py:" + ("headline" if a.headline else "synth") + " -->")
            open(a.update_report, "w").write(text)
        fill_markers(a.update_report, tables)
        print(f"[collect] updated tables in {a.update_report}", file=sys.stderr)


if __name__ == "__main__":
    main()

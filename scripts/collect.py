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


def md_synth(rows):
    order = {"hazard3": 0, "ibex": 1, "veer_el2": 2}
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    rows = sorted(rows, key=lambda r: (order.get(r["core"], 9), {"bp": 1}.get(r["config"], 0), float(r["clock_target_mhz"])))
    fmt = lambda v, f: format(v, f) if v != "" else "pending"
    base = next((r["area_um2"] for r in rows if r["core"] == "hazard3"), None)
    out = ["| Core | Config | Synthesized top | Frontend | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | Latches | "
           "Est. fmax, post-CTS, tt (MHz) | Reg-to-reg slack @ target, post-CTS (ns) | Est. fmax, post-GPL, tt (MHz) |",
           "|---|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|"]
    for r in rows:
        top = "core + wrapper" if r["top"] == "wrapper" else "vendor top (old)"
        out.append(f"| {names.get(r['core'], r['core'])} | {r['config']} | {top} | {r['frontend']} | "
                   f"{r['cells']:,} | {r['area_um2']:,.0f} | {fmt(r['area_um2'] / base if base else '', '.2f')}× | "
                   f"{r['flops']:,} | {r['latches']:,} | "
                   f"{fmt(r['fmax_est_mhz_postcts_tt'], '.0f')} | {fmt(r['reg2reg_slack_ns_postcts_tt'], '+.2f')} | "
                   f"{fmt(r['fmax_est_mhz_postgpl_tt'], '.0f')} |")
    return "\n".join(out)


HEADLINE = {"hazard3": "default", "ibex": "small", "veer_el2": "min"}


def md_headline(rows):
    """Short table for emails: one headline config per core, post-CTS estimate only."""
    names = {"hazard3": "Hazard3", "ibex": "Ibex (small)", "veer_el2": "VeeR EL2 (min)"}
    rows = [r for c, cfg in HEADLINE.items() for r in rows if r["core"] == c and r["config"] == cfg]
    base = next((r["area_um2"] for r in rows if r["core"] == "hazard3"), None)
    fmt = lambda v, f: format(v, f) if v != "" else "pending"
    out = ["| Core | Cells | Cell area (µm²) | Area vs Hazard3 | Flops | Est. fmax, tt (MHz)* |",
           "|---|---:|---:|---:|---:|---:|"]
    for r in rows:
        name = names[r["core"]] + ("" if r["top"] == "wrapper" else " †")
        out.append(f"| {name} | {r['cells']:,} | {r['area_um2']:,.0f} | "
                   f"{fmt(r['area_um2'] / base if base else '', '.2f')}× | {r['flops']:,} | "
                   f"{fmt(r['fmax_est_mhz_postcts_tt'], '.0f')} |")
    if any(r["top"] != "wrapper" for r in rows):
        out.append("\n† Synthesized from the core's own top, not yet with the common wrapper; to be updated.")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", choices=["synth"], help="print a Markdown table to stdout")
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
    synth = prefer_wrapped([r for r in rows if r["stage"] == "synth"])
    table = md_headline(synth) if a.headline else md_synth(synth)
    if a.md == "synth":
        print(table)
    if a.update_report:
        begin, end = "<!-- BEGIN collect.py --md synth -->", "<!-- END collect.py -->"
        text = open(a.update_report).read()
        i, j = text.index(begin) + len(begin), text.index(end)
        open(a.update_report, "w").write(text[:i] + "\n" + table + "\n" + text[j:])
        print(f"[collect] updated table in {a.update_report}", file=sys.stderr)


if __name__ == "__main__":
    main()

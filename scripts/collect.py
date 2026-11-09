#!/usr/bin/env python3
"""Parse tool reports under results/raw/ into results/results.csv.

Every number in tables, reports, emails or the paper must come from this script.

usage:
  scripts/collect.py              # rebuild results/results.csv
  scripts/collect.py --md synth   # also print the synthesis table as Markdown
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
    "core", "core_commit", "config", "technology", "scope", "stage", "clock_target_mhz", "run_id",
    "frontend", "patches", "tool_versions", "pdk_version",
    "cells", "area_um2", "sequential_area_um2", "flops", "latches", "clock_gates",
    "reg2reg_slack_tt_ns", "fmax_est_tt_mhz", "reg2reg_slack_ss_ns", "fmax_est_ss_mhz",
    "report_path",
]

FRONTEND_NAMES = {"slang": "yosys-slang", "verilog": "Yosys read_verilog"}


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

    def est(corner):
        p = os.path.join(run_dir, f"est_{corner}.summary.rpt")
        s = read_kv(p)
        period = float(s["period_ns"])
        slack = float(s["reg2reg_slack_ns"])
        return slack, 1000.0 / (period - slack)

    s_tt, f_tt = est("tt_025C_1v80")
    s_ss, f_ss = est("ss_100C_1v60")
    yosys_ver = ""
    log = os.path.join(run_dir, "yosys-synthesis.log")
    if os.path.exists(log):
        mm = re.search(r"Yosys (\S+)", open(log, errors="replace").read(4000))
        yosys_ver = mm.group(1) if mm else ""
    return {
        "core": info["core"], "core_commit": info["core_commit"], "config": info["config"],
        "technology": "sky130", "scope": "core", "stage": "synth",
        "clock_target_mhz": info["clk_mhz"], "run_id": os.path.basename(run_dir),
        "frontend": FRONTEND_NAMES.get(info["frontend"], info["frontend"]),
        "patches": info.get("patches", "").strip(),
        "tool_versions": f"{info['librelane_image'].split('/')[-1]}; yosys {yosys_ver}".strip(),
        "pdk_version": f"{info['pdk']} {info['pdk_version']}",
        "cells": m["num_cells"], "area_um2": round(m["area"], 1),
        "sequential_area_um2": round(m.get("sequential_area", 0.0), 1),
        "flops": counts["flop"], "latches": counts["latch"], "clock_gates": counts["icg"],
        "reg2reg_slack_tt_ns": round(s_tt, 3), "fmax_est_tt_mhz": round(f_tt, 1),
        "reg2reg_slack_ss_ns": round(s_ss, 3), "fmax_est_ss_mhz": round(f_ss, 1),
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


def md_synth(rows):
    order = {"hazard3": 0, "ibex": 1, "veer_el2": 2}
    names = {"hazard3": "Hazard3", "ibex": "Ibex", "veer_el2": "VeeR EL2"}
    rows = sorted(rows, key=lambda r: (order.get(r["core"], 9), r["config"], float(r["clock_target_mhz"])))
    out = ["| Core | Config | Frontend | Cells | Area (µm²) | Flops | Latches / ICGs | "
           "Est. fmax tt (MHz) | Est. fmax ss (MHz) |",
           "|---|---|---|---:|---:|---:|---:|---:|---:|"]
    for r in rows:
        out.append(f"| {names.get(r['core'], r['core'])} | {r['config']} | {r['frontend']} | "
                   f"{r['cells']:,} | {r['area_um2']:,.0f} | {r['flops']:,} | "
                   f"{r['latches']} / {r['clock_gates']} | {r['fmax_est_tt_mhz']:.1f} | {r['fmax_est_ss_mhz']:.1f} |")
    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--md", choices=["synth"], help="print a Markdown table to stdout")
    a = ap.parse_args()
    rows = collect()
    os.makedirs(os.path.dirname(CSV), exist_ok=True)
    with open(CSV, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNS)
        w.writeheader()
        w.writerows(rows)
    print(f"[collect] wrote {len(rows)} rows to {os.path.relpath(CSV, REPO)}", file=sys.stderr)
    if a.md == "synth":
        print(md_synth([r for r in rows if r["stage"] == "synth"]))


if __name__ == "__main__":
    main()

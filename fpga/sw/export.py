#!/usr/bin/env python3
"""Export the benchmark images for the PYNQ notebook (run on the ASIC/sim machine, not the board).

Copies the exact images the RTL simulation runs (build/bench/<bench>.hex, built by common/bench with
the project's one GCC and flag set) to fpga/sw/hex/, and writes fpga/sw/manifest.json with:
  - sha256 of each image (the notebook refuses an image whose hash differs)
  - the RTL-simulation reference result per core (exit, cycles, marked cycles, console), parsed from
    results/raw/sim/<core>_<cfg>/<bench>.log (flows/sim.sh), for the on-board comparison
usage: fpga/sw/export.py            (runs `make -C common/bench all` first)
"""
import hashlib, json, os, re, shutil, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HERE = os.path.join(REPO, "fpga", "sw")
RTL_CFG = {"hazard3": "default", "ibex": "default", "veer_el2": "min"}   # ASIC configs (RTL sim)

def main():
    subprocess.run(["make", "-s", "-C", os.path.join(REPO, "common", "bench"), "all"], check=True,
                   stdout=subprocess.DEVNULL)
    benches = subprocess.run(["make", "-s", "-C", os.path.join(REPO, "common", "bench"), "list"],
                             check=True, capture_output=True, text=True).stdout.split()
    os.makedirs(os.path.join(HERE, "hex"), exist_ok=True)
    man = {"generated_by": "fpga/sw/export.py", "source": "build/bench (common/bench/Makefile)",
           "benches": {}}
    for b in benches:
        src = os.path.join(REPO, "build", "bench", b + ".hex")
        dst = os.path.join(HERE, "hex", b + ".hex")
        shutil.copyfile(src, dst)
        ent = {"hex": "hex/%s.hex" % b, "sha256": hashlib.sha256(open(dst, "rb").read()).hexdigest(),
               "rtl_sim": {}}
        for core, cfg in RTL_CFG.items():
            log = os.path.join(REPO, "results", "raw", "sim", "%s_%s" % (core, cfg), b + ".log")
            if not os.path.exists(log):
                continue
            t = open(log, errors="replace").read()
            m = re.search(r"TB_RESULT core=\S+ exit=(\S+) cycles=(\d+) marked_cycles=(\d+)", t)
            if m:
                ent["rtl_sim"][core] = {"exit": m.group(1), "cycles": int(m.group(2)),
                                        "marked_cycles": int(m.group(3)),
                                        "console": t[:m.start()].rstrip("\n"),
                                        "log": os.path.relpath(log, REPO)}
        man["benches"][b] = ent
    json.dump(man, open(os.path.join(HERE, "manifest.json"), "w"), indent=1)
    print("exported %d images to fpga/sw/hex, manifest fpga/sw/manifest.json" % len(benches))

if __name__ == "__main__":
    main()

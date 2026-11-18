"""Run the project's benchmarks on one core's FPGA overlay (PYNQ-Z1 / PYNQ-Z2) and read back cycles.

Used by processor_compare.ipynb. Board layout (fpga/README.md):
    <dir>/runner.py, processor_compare.ipynb
    <dir>/sw/manifest.json, sw/hex/*.hex          (fpga/sw, exported by fpga/sw/export.py)
    <dir>/overlays/<core>.bit, <core>.hwh          (fpga/out/<core>/, from fpga/vivado/build.tcl)

Register map: fpga/rtl/fpga_shell.sv. The sequence is the same one fpga/sim/tb_fpga.sv simulates:
hold reset, load all 256 KiB of RAM, set RUN, poll DONE, read EXIT / CYCLES / MARKED / console.
"""
import hashlib
import json
import os
import time

RAM_BYTES = 256 * 1024
REG = {"CTRL": 0x40000, "STATUS": 0x40004, "EXIT": 0x40008, "ID": 0x4000C, "CYC_LO": 0x40010,
       "CYC_HI": 0x40014, "MRK_LO": 0x40018, "MRK_HI": 0x4001C, "CON_LEN": 0x40020,
       "ERR_CNT": 0x40024, "ERR_ADDR": 0x40028}
CON_BASE = 0x41000
CORE_IDS = {"hazard3": 1, "ibex": 2, "veer_el2": 3}
DEFAULT_BASE = 0x4000_0000      # fpga/vivado/build.tcl: slave window on M_AXI_GP0
WINDOW = 0x80000


def load_hex(path):
    """objcopy -O verilog image (@<byte address> + byte tokens) -> bytearray(RAM_BYTES),
    as $readmemh into the byte array of common/tb/tb_top.sv / fpga/sim/tb_fpga.sv."""
    img = bytearray(RAM_BYTES)
    addr = 0
    with open(path) as f:
        for tok in f.read().split():
            if tok.startswith("@"):
                addr = int(tok[1:], 16)
            else:
                if addr >= RAM_BYTES:
                    raise ValueError("%s: byte at 0x%x outside the 256 KiB RAM" % (path, addr))
                img[addr] = int(tok, 16)
                addr += 1
    return img


class Board:
    def __init__(self, core, root=None, clk_mhz=None, overlay=True):
        """core: hazard3 | ibex | veer_el2. clk_mhz: None = the clock stored in the overlay's .hwh."""
        self.core = core
        self.root = root or os.path.dirname(os.path.abspath(__file__))
        self.manifest = json.load(open(os.path.join(self.root, "sw", "manifest.json")))
        from pynq import MMIO, Overlay, Clocks  # imported here so load_hex() works off-board
        bit = os.path.join(self.root, "overlays", core + ".bit")
        self.overlay = Overlay(bit) if overlay else None
        if clk_mhz is not None:
            Clocks.fclk0_mhz = clk_mhz
        self.clk_mhz = Clocks.fclk0_mhz
        base = DEFAULT_BASE
        if self.overlay is not None:
            for name, ip in self.overlay.ip_dict.items():
                if name.split("/")[-1] == "core" or name.startswith("core"):
                    base = ip["phys_addr"]
                    break
        self.mmio = MMIO(base, WINDOW)
        ident = self.rd("ID")
        if ident >> 16 != 0xF6A0 or (ident & 0xFF) != CORE_IDS[core]:
            raise RuntimeError("overlay ID 0x%08x does not match core %s" % (ident, core))

    def rd(self, reg):
        return self.mmio.read(REG[reg])

    def wr(self, reg, val):
        self.mmio.write(REG[reg], val)

    def _load(self, img):
        import numpy as np
        words = np.frombuffer(bytes(img), dtype="<u4")
        try:
            self.mmio.array[0:len(words)] = words         # fast path (bulk copy over AXI-Lite)
            back = np.array(self.mmio.array[0:len(words)])
        except Exception:
            back = None
        if back is None or not np.array_equal(back, words):
            for i, w in enumerate(words):                  # safe path: one 32-bit write per word
                self.mmio.write(4 * i, int(w))
            back = np.array([self.mmio.read(4 * i) for i in range(len(words))], dtype="<u4")
            if not np.array_equal(back, words):
                bad = int(np.flatnonzero(back != words)[0])
                raise RuntimeError("RAM readback mismatch at 0x%x" % (4 * bad))

    def run(self, bench, timeout_s=60.0):
        ent = self.manifest["benches"][bench]
        path = os.path.join(self.root, "sw", ent["hex"])
        sha = hashlib.sha256(open(path, "rb").read()).hexdigest()
        if sha != ent["sha256"]:
            raise RuntimeError("%s: sha256 %s differs from manifest (not the RTL-sim binary)" % (bench, sha))
        self.wr("CTRL", 0)                                  # hold the core in reset
        self._load(load_hex(path))
        t0 = time.time()
        self.wr("CTRL", 1)                                  # RUN (clears counters and console)
        while not (self.rd("STATUS") & 1):
            if time.time() - t0 > timeout_s:
                self.wr("CTRL", 0)
                return {"bench": bench, "exit": "timeout"}
        wall = time.time() - t0
        n = self.rd("CON_LEN")
        con = bytearray()
        for k in range(0, min(n, 4096), 4):
            con += self.mmio.read(CON_BASE + k).to_bytes(4, "little")
        st = self.rd("STATUS")
        res = {
            "bench": bench,
            "exit": str(self.rd("EXIT")),
            "cycles": self.rd("CYC_HI") << 32 | self.rd("CYC_LO"),
            "marked_cycles": self.rd("MRK_HI") << 32 | self.rd("MRK_LO"),
            "console": con[:min(n, 4096)].decode("latin-1").rstrip("\n"),
            "console_len": n,
            "bus_errors": self.rd("ERR_CNT"),
            "status": st,
            "wall_s": round(wall, 4),
            "sha256": sha,
        }
        self.wr("CTRL", 0)
        ref = ent["rtl_sim"].get(self.core)
        if ref:
            res["rtl_sim"] = {k: ref[k] for k in ("exit", "cycles", "marked_cycles")}
            res["matches_rtl_sim"] = (res["exit"] == ref["exit"] and res["cycles"] == ref["cycles"]
                                      and res["marked_cycles"] == ref["marked_cycles"]
                                      and res["console"] == ref["console"])
        return res

    def run_all(self, benches=None):
        benches = benches or list(self.manifest["benches"])
        return [self.run(b) for b in benches]

    def save(self, results, out_dir=None):
        """Write results/<core>_<clk>MHz.json (copy it to results/raw/fpga/<core>/board_<clk>MHz/ in the repo)."""
        out_dir = out_dir or os.path.join(self.root, "results")
        os.makedirs(out_dir, exist_ok=True)
        import platform
        meta = {"core": self.core, "fclk0_mhz": self.clk_mhz, "board": platform.node(),
                "pynq": __import__("pynq").__version__, "date": time.strftime("%Y-%m-%d %H:%M:%S"),
                "bitstream_sha256": hashlib.sha256(open(os.path.join(self.root, "overlays", self.core + ".bit"),
                                                        "rb").read()).hexdigest()}
        path = os.path.join(out_dir, "%s_%sMHz.json" % (self.core, int(round(self.clk_mhz))))
        json.dump({"meta": meta, "results": results}, open(path, "w"), indent=1)
        return path

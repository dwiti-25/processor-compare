# Tool and PDK versions

Filled by Claude Code during setup. Same versions for every core.

**All ASIC numbers (synthesis, timing estimate, hardening) come from the tools inside the pinned
LibreLane container**, not from the host OSS CAD Suite. The host tools are for simulation and quick
elaboration checks only.

| Tool | Version | Install method |
|---|---|---|
| LibreLane | 3.0.17 (container `ghcr.io/librelane/librelane:3.0.17`, image id 684afcd5ee43) | pip in `~/tools/venv` (Python 3.12) + Docker Desktop; run via `flows/librelane.sh` |
| Yosys (ASIC flow) | 0.62 (git 7326bb7d), yosys-slang plugin | inside LibreLane container |
| OpenROAD | git dcf36133a369abc8f3c5e5738cd4d82e4903c0e0 | inside LibreLane container |
| OpenSTA | 2.7.0 | inside LibreLane container |
| Magic / Netgen / KLayout | 8.3.623 / 1.5.316 / 0.30.7 | inside LibreLane container |
| Verilator / Icarus (container) | 5.044 / 13.0 (devel) | inside LibreLane container |
| OSS CAD Suite (host) | 2026-11-01 darwin-arm64: Yosys 0.70+286, Verilator 5.053 devel, Icarus 14.0 devel, slang 12.1.0 | tarball in `~/tools/oss-cad-suite` |
| sv2v | v0.0.13 (macOS release) | zip in `~/tools/sv2v/sv2v-macOS` (x86_64 binary, runs under Rosetta) (not used yet: all cores read with Yosys frontends) |
| Slang | yosys-slang plugin (container and host) | bundled |
| RISC-V GCC | xPack riscv-none-elf-gcc 15.2.0-1 (darwin-arm64) | tarball in `~/tools/xpack-riscv-none-elf-gcc-15.2.0-1` |
| Perl | 5.34.1 (macOS system) | system (VeeR `veer.config`) |
| sky130A PDK (ciel hash) | open_pdks 8afc8346a57fe1ab7934ba5a6056ea8b43078e71 (the hash LibreLane 3.0.17 pins) | `ciel enable` into `~/.ciel` (ciel 2.6.1) |
| Vivado | n/a (FPGA out of scope this round) | |
| SCL PDK version | n/a (SCL out of scope this round) | |

Host: MacBook Air M3 (arm64), 8 cores, 8 GB RAM, macOS 26.5.1; Docker Desktop 29.7.2 with a
3.8 GB VM memory limit.

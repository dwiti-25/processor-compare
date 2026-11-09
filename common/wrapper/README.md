# Common core wrapper interface

Every core is wrapped as `<core>_wrap` (in `cores/<core>/wrapper/`) with exactly these ports, so the
testbench, the core-only hardening and the chip top treat all cores the same:

| Port | Dir | Meaning |
|---|---|---|
| `clk`, `rst_n` | in | clock, active-low reset |
| `i_req`, `i_gnt`, `i_addr[31:0]` | out/in/out | instruction request (read only), held until granted |
| `i_rvalid`, `i_rdata[63:0]`, `i_err` | in | response, in order, any number of cycles after the grant |
| `d_req`, `d_gnt`, `d_addr[31:0]`, `d_we`, `d_be[7:0]`, `d_wdata[63:0]` | out/in/out | data request |
| `d_rvalid`, `d_rdata[63:0]`, `d_err` | in | data response (also returned for writes) |
| `irq_timer`, `irq_soft`, `irq_ext` | in | machine timer / software / external interrupt |

Protocol: OBI-style. A request is accepted on a cycle where `req && gnt`; each accepted request gets
exactly one `rvalid`, in order. The memory is 64 bits wide (`addr[2:0]` selects lanes, `be` is
per-lane) because VeeR EL2's IFU and LSU are 64-bit AXI. The 32-bit cores (Hazard3, Ibex) use the
half selected by `addr[2]` (`obi32to64.sv`), so every core sees the same memory, at its native width.

Adapters (thin, synthesized together with the core):
- `obi32to64.sv`: 32-bit OBI → 64-bit port (Ibex directly; Hazard3 after `ahbl2obi`).
- `ahbl2obi.sv`: AHB-Lite master → 32-bit OBI (Hazard3). Reads are issued in the address phase,
  so a 1-cycle memory gives zero-wait-state reads. Writes are issued in the data phase; a read whose
  address phase overlaps a write's data phase is deferred by one cycle.
- `axi2obi64.sv`: AXI4 single-beat → 64-bit OBI (VeeR EL2 IFU and LSU).

Boot: all cores start at 0x0000_0080 (Hazard3 `RESET_VECTOR`, VeeR `rst_vec`, Ibex `boot_addr = 0`,
which Ibex offsets by 0x80).

Memory map used by the testbench (`common/tb`):
- `0x0000_0000`–`0x0003_FFFF`: 256 KiB RAM (instructions and data)
- `0x8000_0000`: putchar (byte write)
- `0x8000_0008`: exit (word write: 0 = pass, otherwise fail code)
- `0x8000_0010`: benchmark marker (word write: 1 = start counting cycles, 0 = stop)

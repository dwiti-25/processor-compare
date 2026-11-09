// Behavioural ICCM/DCCM banks for VeeR EL2's "tcm" configuration (RTL simulation only).
// Same behaviour as VeeR's own testbench SRAM models (design/lib/mem_lib.sv): 1-cycle read,
// {ecc, data} stored per 32-bit word. At start-up the banks are preloaded from the same program
// image the testbench loads (+hex=<file>), like VeeR's testbench preload_iccm/preload_dccm, so
// the same binary runs unchanged: code at ICCM (0x0), data/stack at DCCM (0x2_0000).
module veer_tcm_mem
import el2_pkg::*;
#(
`include "el2_param.vh"
) (
  el2_mem_if.veer_sram_sink mem
);
  localparam int ICCM_DEPTH = (1 << (pt.ICCM_BITS - 2)) / pt.ICCM_NUM_BANKS;  // words per bank
  localparam int DCCM_DEPTH = (1 << (pt.DCCM_BITS - 2)) / pt.DCCM_NUM_BANKS;
  localparam int IB = $clog2(pt.ICCM_NUM_BANKS);
  localparam int DB = $clog2(pt.DCCM_NUM_BANKS);

  logic [38:0] iram [pt.ICCM_NUM_BANKS][ICCM_DEPTH];
  logic [38:0] dram [pt.DCCM_NUM_BANKS][DCCM_DEPTH];
  logic [38:0] iq [pt.ICCM_NUM_BANKS];
  logic [38:0] dq [pt.DCCM_NUM_BANKS];

  for (genvar b = 0; b < pt.ICCM_NUM_BANKS; b++) begin : g_iccm
    always @(posedge mem.clk) if (mem.iccm_clken[b]) begin
      if (mem.iccm_wren_bank[b]) iram[b][mem.iccm_addr_bank[b]] <= {mem.iccm_bank_wr_ecc[b], mem.iccm_bank_wr_data[b]};
      else                       iq[b] <= iram[b][mem.iccm_addr_bank[b]];
    end
    assign mem.iccm_bank_dout[b] = iq[b][31:0];
    assign mem.iccm_bank_ecc[b]  = iq[b][38:32];
  end

  for (genvar b = 0; b < pt.DCCM_NUM_BANKS; b++) begin : g_dccm
    always @(posedge mem.clk) if (mem.dccm_clken[b]) begin
      if (mem.dccm_wren_bank[b]) dram[b][mem.dccm_addr_bank[b]] <= {mem.dccm_wr_ecc_bank[b], mem.dccm_wr_data_bank[b]};
      else                       dq[b] <= dram[b][mem.dccm_addr_bank[b]];
    end
    assign mem.dccm_bank_dout[b] = dq[b][31:0];
    assign mem.dccm_bank_ecc[b]  = dq[b][38:32];
  end

  // VeeR's SEC-DED code for a 32-bit word (copied from VeeR testbench/tb_top.sv riscv_ecc32)
  function automatic logic [6:0] riscv_ecc32(input logic [31:0] data);
    logic [6:0] synd;
    synd[0] = ^(data & 32'h56aa_ad5b);
    synd[1] = ^(data & 32'h9b33_366d);
    synd[2] = ^(data & 32'he3c3_c78e);
    synd[3] = ^(data & 32'h03fc_07f0);
    synd[4] = ^(data & 32'h03ff_f800);
    synd[5] = ^(data & 32'hfc00_0000);
    synd[6] = ^{data, synd[5:0]};
    return synd;
  endfunction

  localparam int unsigned IMG_BYTES = 256 * 1024;
  logic [7:0] img [IMG_BYTES];

  function automatic logic [31:0] tb_word(input int unsigned a);
    return {img[a+3], img[a+2], img[a+1], img[a]};
  endfunction

  // Preload before reset is released.
  initial begin
    string hex;
    logic [31:0] w;  // assigned per word (a declaration initialiser would run only once)
    if (!$value$plusargs("hex=%s", hex)) $fatal(1, "veer_tcm_mem: +hex=<file> required");
    for (int unsigned i = 0; i < IMG_BYTES; i++) img[i] = 8'h00;
    $readmemh(hex, img);
    for (int unsigned a = 0; a < (1 << pt.ICCM_BITS); a += 4) begin
      w = tb_word(pt.ICCM_SADR + a);
      iram[(a >> 2) % pt.ICCM_NUM_BANKS][a >> (2 + IB)] = {riscv_ecc32(w), w};
    end
    for (int unsigned a = 0; a < (1 << pt.DCCM_BITS); a += 4) begin
      w = tb_word(pt.DCCM_SADR + a);
      dram[(a >> 2) % pt.DCCM_NUM_BANKS][a >> (2 + DB)] = {riscv_ecc32(w), w};
    end
    $display("veer_tcm_mem: preloaded ICCM @%h (%0d KiB) and DCCM @%h (%0d KiB)",
             pt.ICCM_SADR, (1 << pt.ICCM_BITS) / 1024, pt.DCCM_SADR, (1 << pt.DCCM_BITS) / 1024);
  end
endmodule

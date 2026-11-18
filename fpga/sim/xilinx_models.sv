// Behavioural models of the Xilinx primitives used by the FPGA build, for Verilator only
// (Vivado uses its own UNISIM library). BUFGCE: glitch-free clock enable, CE sampled while I is low.
module BUFGCE #(parameter SIM_DEVICE = "7SERIES") (input logic I, input logic CE, output logic O);
  logic ce_l /* verilator clock_enable */;
  always_latch if (!I) ce_l = CE;
  assign O = I & ce_l;
endmodule

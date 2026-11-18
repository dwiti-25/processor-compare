// FPGA top for Ibex: ibex_wrap (the same wrapper and configuration as the ASIC flow) + fpga_shell
// (256 KiB block RAM, MMIO, cycle counters, AXI4-Lite slave for the Zynq PS). Plain Verilog so
// Vivado can use it as a block-design module reference (fpga/vivado/build.tcl).
module ibex_fpga (
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET aresetn" *)
  input  wire        clk,
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *)
  (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
  input  wire        aresetn,
  input  wire [18:0] s_axi_awaddr,
  input  wire [2:0]  s_axi_awprot,
  input  wire        s_axi_awvalid,
  output wire        s_axi_awready,
  input  wire [31:0] s_axi_wdata,
  input  wire [3:0]  s_axi_wstrb,
  input  wire        s_axi_wvalid,
  output wire        s_axi_wready,
  output wire [1:0]  s_axi_bresp,
  output wire        s_axi_bvalid,
  input  wire        s_axi_bready,
  input  wire [18:0] s_axi_araddr,
  input  wire [2:0]  s_axi_arprot,
  input  wire        s_axi_arvalid,
  output wire        s_axi_arready,
  output wire [31:0] s_axi_rdata,
  output wire [1:0]  s_axi_rresp,
  output wire        s_axi_rvalid,
  input  wire        s_axi_rready
);
  wire        core_rst_n;
  wire        i_req, i_gnt, i_rvalid, i_err, d_req, d_gnt, d_we, d_rvalid, d_err;
  wire [31:0] i_addr, d_addr;
  wire [7:0]  d_be;
  wire [63:0] i_rdata, d_wdata, d_rdata;

  fpga_shell #(.CORE_ID(8'd2)) u_shell (
    .clk (clk), .aresetn (aresetn),
    .s_axi_awaddr (s_axi_awaddr), .s_axi_awvalid (s_axi_awvalid), .s_axi_awready (s_axi_awready),
    .s_axi_wdata (s_axi_wdata), .s_axi_wstrb (s_axi_wstrb), .s_axi_wvalid (s_axi_wvalid),
    .s_axi_wready (s_axi_wready), .s_axi_bresp (s_axi_bresp), .s_axi_bvalid (s_axi_bvalid),
    .s_axi_bready (s_axi_bready), .s_axi_araddr (s_axi_araddr), .s_axi_arvalid (s_axi_arvalid),
    .s_axi_arready (s_axi_arready), .s_axi_rdata (s_axi_rdata), .s_axi_rresp (s_axi_rresp),
    .s_axi_rvalid (s_axi_rvalid), .s_axi_rready (s_axi_rready),
    .core_rst_n (core_rst_n),
    .i_req (i_req), .i_gnt (i_gnt), .i_addr (i_addr), .i_rvalid (i_rvalid), .i_rdata (i_rdata), .i_err (i_err),
    .d_req (d_req), .d_gnt (d_gnt), .d_addr (d_addr), .d_we (d_we), .d_be (d_be), .d_wdata (d_wdata),
    .d_rvalid (d_rvalid), .d_rdata (d_rdata), .d_err (d_err)
  );

  ibex_wrap u_core (
    .clk (clk), .rst_n (core_rst_n),
    .i_req (i_req), .i_gnt (i_gnt), .i_addr (i_addr), .i_rvalid (i_rvalid), .i_rdata (i_rdata), .i_err (i_err),
    .d_req (d_req), .d_gnt (d_gnt), .d_addr (d_addr), .d_we (d_we), .d_be (d_be), .d_wdata (d_wdata),
    .d_rvalid (d_rvalid), .d_rdata (d_rdata), .d_err (d_err),
    .irq_timer (1'b0), .irq_soft (1'b0), .irq_ext (1'b0)
  );
endmodule

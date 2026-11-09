// Hazard3 in the common wrapper interface (common/wrapper/README.md).
// hazard3_cpu_2port (AHB-Lite I and D) -> ahbl2obi -> obi32to64 on each port.
// Configuration parameters match cores/hazard3/sky130/synth.conf.
module hazard3_wrap (
  input  logic        clk,
  input  logic        rst_n,
  output logic        i_req,
  input  logic        i_gnt,
  output logic [31:0] i_addr,
  input  logic        i_rvalid,
  input  logic [63:0] i_rdata,
  input  logic        i_err,
  output logic        d_req,
  input  logic        d_gnt,
  output logic [31:0] d_addr,
  output logic        d_we,
  output logic [7:0]  d_be,
  output logic [63:0] d_wdata,
  input  logic        d_rvalid,
  input  logic [63:0] d_rdata,
  input  logic        d_err,
  input  logic        irq_timer,
  input  logic        irq_soft,
  input  logic        irq_ext
);
  logic [31:0] i_haddr, d_haddr, i_hrdata, d_hrdata, i_hwdata, d_hwdata;
  logic [1:0]  i_htrans, d_htrans;
  logic [2:0]  i_hsize, d_hsize;
  logic        i_hwrite, d_hwrite, i_hready, d_hready, i_hresp, d_hresp;
  logic        pwrup_req;

  hazard3_cpu_2port #(
    .RESET_VECTOR        (32'h0000_0080),
    .MTVEC_INIT          (32'h0000_0000),
    .EXTENSION_A         (0),
    .EXTENSION_C         (1),
    .EXTENSION_M         (1),
    .CSR_COUNTER         (1),
    .DEBUG_SUPPORT       (0),
    .PMP_REGIONS         (0),
    .BREAKPOINT_TRIGGERS (0),
    .MUL_FAST            (1),
    .MULH_FAST           (0)
  ) u_core (
    .clk                        (clk),
    .clk_always_on              (clk),
    .rst_n                      (rst_n),
    .pwrup_req                  (pwrup_req),
    .pwrup_ack                  (pwrup_req),
    .clk_en                     (),
    .unblock_out                (),
    .unblock_in                 (1'b0),
    .i_haddr                    (i_haddr),
    .i_hwrite                   (i_hwrite),
    .i_htrans                   (i_htrans),
    .i_hsize                    (i_hsize),
    .i_hburst                   (),
    .i_hprot                    (),
    .i_hmastlock                (),
    .i_hmaster                  (),
    .i_hready                   (i_hready),
    .i_hresp                    (i_hresp),
    .i_hwdata                   (i_hwdata),
    .i_hrdata                   (i_hrdata),
    .d_haddr                    (d_haddr),
    .d_hwrite                   (d_hwrite),
    .d_htrans                   (d_htrans),
    .d_hsize                    (d_hsize),
    .d_hburst                   (),
    .d_hprot                    (),
    .d_hmastlock                (),
    .d_hmaster                  (),
    .d_hexcl                    (),
    .d_hready                   (d_hready),
    .d_hresp                    (d_hresp),
    .d_hexokay                  (1'b0),
    .d_hwdata                   (d_hwdata),
    .d_hrdata                   (d_hrdata),
    .fence_i_vld                (),
    .fence_d_vld                (),
    .fence_rdy                  (1'b1),
    .dbg_req_halt               (1'b0),
    .dbg_req_halt_on_reset      (1'b0),
    .dbg_req_resume             (1'b0),
    .dbg_halted                 (),
    .dbg_running                (),
    .dbg_data0_rdata            (32'h0),
    .dbg_data0_wdata            (),
    .dbg_data0_wen              (),
    .dbg_instr_data             (32'h0),
    .dbg_instr_data_vld         (1'b0),
    .dbg_instr_data_rdy         (),
    .dbg_instr_caught_exception (),
    .dbg_instr_caught_ebreak    (),
    .dbg_sbus_addr              (32'h0),
    .dbg_sbus_write             (1'b0),
    .dbg_sbus_size              (2'h0),
    .dbg_sbus_vld               (1'b0),
    .dbg_sbus_rdy               (),
    .dbg_sbus_err               (),
    .dbg_sbus_wdata             (32'h0),
    .dbg_sbus_rdata             (),
    .mhartid_val                (32'h0),
    .eco_version                (4'h0),
    .irq                        (irq_ext),
    .soft_irq                   (irq_soft),
    .timer_irq                  (irq_timer)
  );

  // instruction port
  logic        i_req32, i_gnt32, i_we32, i_rvalid32;
  logic [31:0] i_addr32, i_wdata32, i_rdata32;
  logic [3:0]  i_be32;
  logic [7:0]  i_be_unused;
  logic [63:0] i_wdata_unused;
  logic        i_we_unused;

  ahbl2obi u_i_ahb (
    .clk, .rst_n,
    .haddr (i_haddr), .htrans (i_htrans), .hwrite (i_hwrite), .hsize (i_hsize), .hwdata (i_hwdata),
    .hready (i_hready), .hresp (i_hresp), .hrdata (i_hrdata),
    .req (i_req32), .gnt (i_gnt32), .addr (i_addr32), .we (i_we32), .be (i_be32), .wdata (i_wdata32),
    .rvalid (i_rvalid32), .rdata (i_rdata32)
  );
  obi32to64 u_i_w (
    .clk, .rst_n,
    .req32 (i_req32), .gnt32 (i_gnt32), .addr32 (i_addr32), .we32 (i_we32), .be32 (i_be32),
    .wdata32 (i_wdata32), .rvalid32 (i_rvalid32), .rdata32 (i_rdata32), .err32 (),
    .req (i_req), .gnt (i_gnt), .addr (i_addr), .we (i_we_unused), .be (i_be_unused),
    .wdata (i_wdata_unused), .rvalid (i_rvalid), .rdata (i_rdata), .err (i_err)
  );

  // data port
  logic        d_req32, d_gnt32, d_we32, d_rvalid32;
  logic [31:0] d_addr32, d_wdata32, d_rdata32;
  logic [3:0]  d_be32;

  ahbl2obi u_d_ahb (
    .clk, .rst_n,
    .haddr (d_haddr), .htrans (d_htrans), .hwrite (d_hwrite), .hsize (d_hsize), .hwdata (d_hwdata),
    .hready (d_hready), .hresp (d_hresp), .hrdata (d_hrdata),
    .req (d_req32), .gnt (d_gnt32), .addr (d_addr32), .we (d_we32), .be (d_be32), .wdata (d_wdata32),
    .rvalid (d_rvalid32), .rdata (d_rdata32)
  );
  obi32to64 u_d_w (
    .clk, .rst_n,
    .req32 (d_req32), .gnt32 (d_gnt32), .addr32 (d_addr32), .we32 (d_we32), .be32 (d_be32),
    .wdata32 (d_wdata32), .rvalid32 (d_rvalid32), .rdata32 (d_rdata32), .err32 (),
    .req (d_req), .gnt (d_gnt), .addr (d_addr), .we (d_we), .be (d_be),
    .wdata (d_wdata), .rvalid (d_rvalid), .rdata (d_rdata), .err (d_err)
  );
endmodule

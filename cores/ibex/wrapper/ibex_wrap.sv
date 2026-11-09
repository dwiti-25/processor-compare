// Ibex in the common wrapper interface (common/wrapper/README.md).
// ibex_top (32-bit OBI I and D) -> obi32to64 on each port. "small" configuration, matching
// cores/ibex/sky130/synth.conf. CHERIoT, scrambling, debug, lockstep and RVFI inputs are tied off.
module ibex_wrap (
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
  import ibex_pkg::*;

  logic        instr_req, instr_gnt, instr_rvalid, instr_err;
  logic [31:0] instr_addr, instr_rdata;
  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  ibex_top #(
    .RV32E           (1'b0),
    .RV32M           (RV32MFast),
    .RV32B           (RV32BNone),
    .RV32ZC          (RV32Zca),
    .RegFile         (RegFileFF),
    .BranchTargetALU (1'b0),
    .WritebackStage  (1'b0),
    .ICache          (1'b0),
    .ICacheECC       (1'b0),
    .ICacheScramble  (1'b0),
    .BranchPredictor (1'b0),
    .DbgTriggerEn    (1'b0),
    .DbgHwBreakNum   (1),
    .SecureIbex      (1'b0),
    .PMPEnable       (1'b0),
    .MHPMCounterNum  (0)
  ) u_core (
    .clk_i                   (clk),
    .rst_ni                  (rst_n),
    .test_en_i               (1'b0),
    .ram_cfg_icache_tag_i    ('0),
    .ram_cfg_icache_tag_o    (),
    .ram_cfg_icache_data_i   ('0),
    .ram_cfg_icache_data_o   (),
    .cheriot_enable_i        (IbexMuBiOff),
    .hart_id_i               (32'h0),
    .boot_addr_i             (32'h0),        // Ibex starts at boot_addr + 0x80
    .trvk_heap_base_addr_i   (32'h0),
    .instr_req_o             (instr_req),
    .instr_gnt_i             (instr_gnt),
    .instr_rvalid_i          (instr_rvalid),
    .instr_addr_o            (instr_addr),
    .instr_rdata_i           (instr_rdata),
    .instr_rdata_intg_i      ('0),
    .instr_err_i             (instr_err),
    .data_req_o              (data_req),
    .data_gnt_i              (data_gnt),
    .data_rvalid_i           (data_rvalid),
    .data_we_o               (data_we),
    .data_be_o               (data_be),
    .data_addr_o             (data_addr),
    .data_wdata_o            (data_wdata),
    .data_wdata_intg_o       (),
    .data_tag_o              (),
    .data_rdata_i            (data_rdata),
    .data_rdata_intg_i       ('0),
    .data_tag_i              (1'b0),
    .data_err_i              (data_err),
    .trvk_revbm_req_o        (),
    .trvk_revbm_gnt_i        (1'b0),
    .trvk_revbm_rvalid_i     (1'b0),
    .trvk_revbm_addr_o       (),
    .trvk_revbm_rdata_i      ('0),
    .trvk_revbm_rdata_intg_i ('0),
    .trvk_revbm_err_i        (1'b0),
    .irq_software_i          (irq_soft),
    .irq_timer_i             (irq_timer),
    .irq_external_i          (irq_ext),
    .irq_fast_i              ('0),
    .irq_nm_i                (1'b0),
    .scramble_key_valid_i    (1'b0),
    .scramble_key_i          ('0),
    .scramble_nonce_i        ('0),
    .scramble_req_o          (),
    .debug_req_i             (1'b0),
    .crash_dump_o            (),
    .double_fault_seen_o     (),
    .fetch_enable_i          (IbexMuBiOn),
    .mcounteren_writable_i   (IbexMuBiOn),
    .alert_minor_o           (),
    .alert_major_internal_o  (),
    .alert_major_bus_o       (),
    .core_sleep_o            (),
    .scan_rst_ni             (1'b1),
    .lockstep_cmp_en_o       (),
    .data_req_shadow_o       (),
    .data_we_shadow_o        (),
    .data_be_shadow_o        (),
    .data_addr_shadow_o      (),
    .data_wdata_shadow_o     (),
    .data_wdata_intg_shadow_o(),
    .instr_req_shadow_o      (),
    .instr_addr_shadow_o     ()
  );

  logic [7:0]  i_be_unused;
  logic [63:0] i_wdata_unused;
  logic        i_we_unused;

  obi32to64 u_i_w (
    .clk, .rst_n,
    .req32 (instr_req), .gnt32 (instr_gnt), .addr32 (instr_addr), .we32 (1'b0), .be32 (4'hf),
    .wdata32 (32'h0), .rvalid32 (instr_rvalid), .rdata32 (instr_rdata), .err32 (instr_err),
    .req (i_req), .gnt (i_gnt), .addr (i_addr), .we (i_we_unused), .be (i_be_unused),
    .wdata (i_wdata_unused), .rvalid (i_rvalid), .rdata (i_rdata), .err (i_err)
  );
  obi32to64 u_d_w (
    .clk, .rst_n,
    .req32 (data_req), .gnt32 (data_gnt), .addr32 (data_addr), .we32 (data_we), .be32 (data_be),
    .wdata32 (data_wdata), .rvalid32 (data_rvalid), .rdata32 (data_rdata), .err32 (data_err),
    .req (d_req), .gnt (d_gnt), .addr (d_addr), .we (d_we), .be (d_be),
    .wdata (d_wdata), .rvalid (d_rvalid), .rdata (d_rdata), .err (d_err)
  );
endmodule

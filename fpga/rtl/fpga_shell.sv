// FPGA shell around one core wrapper (common/wrapper/README.md interface), the same for every core.
// Programmable-logic side of the PYNQ design (fpga/README.md):
//   - 256 KiB program/data RAM in block RAM, 64 bits wide, at 0x0 in the core's address space
//     (same size, map and 1-cycle latency as common/tb/tb_mem.sv, so the same binaries run and the
//     cycle counts match RTL simulation)
//   - core MMIO at 0x8000_0000 (putchar / exit / benchmark marker), as in tb_mem
//   - cycle counter and marked-window counter with exactly the semantics of common/tb/tb_top.sv
//   - AXI4-Lite slave for the Zynq PS: load the RAM, release reset, read counters and console
//
// AXI4-Lite map (byte offsets from the slave base; 32-bit accesses):
//   0x0_0000-0x3_FFFF  RAM (read/write only while CTRL.RUN = 0; reads during a run return SLVERR)
//   0x4_0000  CTRL     [0] RUN: 1 = release the core's reset. 0->1 clears all status and counters.
//   0x4_0004  STATUS   [0] DONE (core wrote exit)  [1] RUN  [2] BUS_ERR seen  [3] console overflow
//                      [4] inside a marked window
//   0x4_0008  EXIT     exit code written by the program (0 = pass)
//   0x4_000C  ID       {16'hF6A0, 8'h00, CORE_ID}  (1 = Hazard3, 2 = Ibex, 3 = VeeR EL2)
//   0x4_0010  CYCLES_LO   0x4_0014 CYCLES_HI   cycles with the core out of reset, until exit
//   0x4_0018  MARKED_LO   0x4_001C MARKED_HI   cycles between start/stop markers (summed)
//   0x4_0020  CON_LEN  number of putchar writes (buffer keeps the first 4096)
//   0x4_0024  ERR_CNT  bus errors (access outside RAM/MMIO)
//   0x4_0028  ERR_ADDR address of the first bus error
//   0x4_1000-0x4_1FFF  console buffer, 4 characters per word, little endian
module fpga_shell #(
  parameter logic [7:0] CORE_ID = 8'd0
) (
  input  logic        clk,
  input  logic        aresetn,
  // AXI4-Lite slave
  input  logic [18:0] s_axi_awaddr,
  input  logic        s_axi_awvalid,
  output logic        s_axi_awready,
  input  logic [31:0] s_axi_wdata,
  input  logic [3:0]  s_axi_wstrb,
  input  logic        s_axi_wvalid,
  output logic        s_axi_wready,
  output logic [1:0]  s_axi_bresp,
  output logic        s_axi_bvalid,
  input  logic        s_axi_bready,
  input  logic [18:0] s_axi_araddr,
  input  logic        s_axi_arvalid,
  output logic        s_axi_arready,
  output logic [31:0] s_axi_rdata,
  output logic [1:0]  s_axi_rresp,
  output logic        s_axi_rvalid,
  input  logic        s_axi_rready,
  // core side (common wrapper interface)
  output logic        core_rst_n,
  input  logic        i_req,
  output logic        i_gnt,
  input  logic [31:0] i_addr,
  output logic        i_rvalid,
  output logic [63:0] i_rdata,
  output logic        i_err,
  input  logic        d_req,
  output logic        d_gnt,
  input  logic [31:0] d_addr,
  input  logic        d_we,
  input  logic [7:0]  d_be,
  input  logic [63:0] d_wdata,
  output logic        d_rvalid,
  output logic [63:0] d_rdata,
  output logic        d_err
);
  localparam int unsigned RAM_BYTES = 256 * 1024;   // = tb_mem RAM_BYTES
  localparam int unsigned RAM_WORDS = RAM_BYTES / 8;
  localparam logic [31:0] MMIO_BASE = 32'h8000_0000;

  // ---------------------------------------------------------------- control state
  logic        run_q, done_q, err_seen_q, con_ovf_q, marking_q;
  logic [31:0] exit_q, con_len_q, err_cnt_q, err_addr_q;
  logic [63:0] cycles_q, marked_q, mark_start_q;
  assign core_rst_n = run_q;

  // ---------------------------------------------------------------- AXI-Lite handshakes
  wire wr_go = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid;          // one write per cycle
  logic rd_pend_q;
  wire rd_go = s_axi_arvalid && !rd_pend_q && !s_axi_rvalid && !wr_go;  // writes take priority
  assign s_axi_awready = wr_go;
  assign s_axi_wready  = wr_go;
  assign s_axi_arready = rd_go;

  wire wr_ram = s_axi_awaddr[18] == 1'b0;
  wire rd_ram = s_axi_araddr[18] == 1'b0;

  // ---------------------------------------------------------------- RAM (inferred TDP block RAM)
  // Port A: core data port while running, AXI host while the core is held in reset.
  // Port B: core instruction port (read only). Both read-first, 1-cycle registered output,
  // like tb_mem with LAT=1 (a read returns the value before a same-cycle write).
  logic [63:0] ram [RAM_WORDS];
`ifdef VERILATOR
  initial for (int k = 0; k < RAM_WORDS; k++) ram[k] = 64'h0;   // block RAM powers up as zero
`endif
  logic                         a_en;
  logic [7:0]                   a_we;
  logic [$clog2(RAM_WORDS)-1:0] a_addr, b_addr;
  logic [63:0]                  a_din, a_dout, b_dout;

  wire d_ram  = d_addr < RAM_BYTES;
  wire d_mmio = d_addr >= MMIO_BASE;
  wire d_ok   = d_mmio || d_ram;
  wire i_ok   = i_addr < RAM_BYTES;

  always_comb begin
    if (run_q) begin
      a_en   = 1'b1;
      a_addr = d_addr[17:3];
      a_we   = (d_req && d_we && d_ram) ? d_be : 8'h00;
      a_din  = d_wdata;
    end else begin
      a_en   = (wr_go && wr_ram) || (rd_go && rd_ram);
      a_addr = wr_go ? s_axi_awaddr[17:3] : s_axi_araddr[17:3];
      a_we   = (wr_go && wr_ram) ? (s_axi_awaddr[2] ? {s_axi_wstrb, 4'h0} : {4'h0, s_axi_wstrb}) : 8'h00;
      a_din  = {s_axi_wdata, s_axi_wdata};
    end
  end
  assign b_addr = i_addr[17:3];

  always_ff @(posedge clk) begin
    if (a_en) begin
      for (int b = 0; b < 8; b++)
        if (a_we[b]) ram[a_addr][8*b +: 8] <= a_din[8*b +: 8];
      a_dout <= ram[a_addr];
    end
  end
  always_ff @(posedge clk) b_dout <= ram[b_addr];

  // ---------------------------------------------------------------- core bus responses (= tb_mem)
  logic i_v_q, i_e_q, i_ok_q, d_v_q, d_e_q, d_ramrd_q;
  assign i_gnt    = 1'b1;
  assign d_gnt    = 1'b1;
  assign i_rvalid = i_v_q;
  assign i_err    = i_e_q;
  assign i_rdata  = i_ok_q ? b_dout : 64'h0;
  assign d_rvalid = d_v_q;
  assign d_err    = d_e_q;
  assign d_rdata  = d_ramrd_q ? a_dout : 64'h0;

  always_ff @(posedge clk) begin
    if (!run_q) begin
      i_v_q <= 1'b0; i_e_q <= 1'b0; d_v_q <= 1'b0; d_e_q <= 1'b0;
    end else begin
      i_v_q <= i_req;
      i_e_q <= i_req && !i_ok;
      d_v_q <= d_req;
      d_e_q <= d_req && !d_ok;
    end
    i_ok_q    <= i_ok;
    d_ramrd_q <= d_ok && !d_mmio;
  end

  // MMIO events, registered one cycle like tb_mem
  wire [63:0] d_wval = d_wdata >> (8 * d_addr[2:0]);
  logic       putc_v, exit_v, mark_v;
  logic [7:0] putc_c;
  logic [31:0] exit_c, mark_c;
  always_ff @(posedge clk) begin
    putc_v <= 1'b0; exit_v <= 1'b0; mark_v <= 1'b0;
    if (run_q && d_req && d_we && d_mmio) begin
      case (d_addr[7:0] & 8'hf8)
        8'h00: begin putc_v <= 1'b1; putc_c <= d_wval[7:0]; end
        8'h08: begin exit_v <= 1'b1; exit_c <= d_wval[31:0]; end
        8'h10: begin mark_v <= 1'b1; mark_c <= d_wval[31:0]; end
        default: ;
      endcase
    end
  end

  // ---------------------------------------------------------------- console buffer
  logic [31:0] con [1024];
  logic [31:0] con_dout;
  always_ff @(posedge clk) begin
    if (run_q && !done_q && putc_v && con_len_q < 32'd4096)
      con[con_len_q[11:2]][8*con_len_q[1:0] +: 8] <= putc_c;
    if (rd_go) con_dout <= con[s_axi_araddr[11:2]];
  end

  // addresses of the requests whose responses are erroring (for ERR_ADDR)
  logic [31:0] i_addr_last_q, d_addr_last_q;
  always_ff @(posedge clk) begin
    if (i_req) i_addr_last_q <= i_addr;
    if (d_req) d_addr_last_q <= d_addr;
  end

  // ---------------------------------------------------------------- control, counters (= tb_top)
  wire ctrl_wr = wr_go && s_axi_awaddr[18:0] == 19'h4_0000 && s_axi_wstrb[0];
  wire start   = ctrl_wr && s_axi_wdata[0] && !run_q;

  always_ff @(posedge clk) begin
    if (!aresetn) begin
      run_q <= 1'b0;
    end else if (ctrl_wr) begin
      run_q <= s_axi_wdata[0];
    end
    if (!aresetn || start) begin
      done_q <= 1'b0; err_seen_q <= 1'b0; con_ovf_q <= 1'b0; marking_q <= 1'b0;
      exit_q <= '0; con_len_q <= '0; err_cnt_q <= '0; err_addr_q <= '0;
      cycles_q <= '0; marked_q <= '0; mark_start_q <= '0;
    end else if (run_q && !done_q) begin
      // tb_top: every clock edge with the core out of reset increments `cycles`; the exit event
      // ends the run with the value before this edge's increment.
      if (exit_v) begin
        done_q <= 1'b1;
        exit_q <= exit_c;
      end else begin
        cycles_q <= cycles_q + 64'd1;
      end
      if (mark_v) begin
        if (mark_c != 0) begin marking_q <= 1'b1; mark_start_q <= cycles_q; end
        else if (marking_q) begin marking_q <= 1'b0; marked_q <= marked_q + (cycles_q - mark_start_q); end
      end
      if (putc_v) begin
        con_len_q <= con_len_q + 32'd1;
        if (con_len_q >= 32'd4096) con_ovf_q <= 1'b1;
      end
      if (i_e_q || d_e_q) begin
        if (!err_seen_q) err_addr_q <= i_e_q ? i_addr_last_q : d_addr_last_q;
        err_seen_q <= 1'b1;
        err_cnt_q  <= err_cnt_q + 32'd1;
      end
    end
  end

  // ---------------------------------------------------------------- AXI-Lite responses
  logic [18:0] rd_addr_q;
  always_ff @(posedge clk) begin
    if (!aresetn) begin
      s_axi_bvalid <= 1'b0;
      s_axi_rvalid <= 1'b0;
      rd_pend_q    <= 1'b0;
    end else begin
      if (wr_go) begin
        s_axi_bvalid <= 1'b1;
        s_axi_bresp  <= (wr_ram && run_q) ? 2'b10 : 2'b00;   // RAM is the core's while it runs
      end else if (s_axi_bready) begin
        s_axi_bvalid <= 1'b0;
      end
      if (rd_go) begin
        rd_pend_q <= 1'b1;
        rd_addr_q <= s_axi_araddr;
      end
      if (rd_pend_q) begin                  // block RAM / console data valid this cycle
        rd_pend_q    <= 1'b0;
        s_axi_rvalid <= 1'b1;
        s_axi_rresp  <= 2'b00;
        if (rd_addr_q[18] == 1'b0) begin
          s_axi_rdata <= rd_addr_q[2] ? a_dout[63:32] : a_dout[31:0];
          if (run_q) begin s_axi_rresp <= 2'b10; s_axi_rdata <= 32'h0; end
        end else if (rd_addr_q[12]) begin
          s_axi_rdata <= con_dout;
        end else begin
          case (rd_addr_q[7:0])
            8'h00: s_axi_rdata <= {31'b0, run_q};
            8'h04: s_axi_rdata <= {27'b0, marking_q, con_ovf_q, err_seen_q, run_q, done_q};
            8'h08: s_axi_rdata <= exit_q;
            8'h0C: s_axi_rdata <= {16'hF6A0, 8'h00, CORE_ID};
            8'h10: s_axi_rdata <= cycles_q[31:0];
            8'h14: s_axi_rdata <= cycles_q[63:32];
            8'h18: s_axi_rdata <= marked_q[31:0];
            8'h1C: s_axi_rdata <= marked_q[63:32];
            8'h20: s_axi_rdata <= con_len_q;
            8'h24: s_axi_rdata <= err_cnt_q;
            8'h28: s_axi_rdata <= err_addr_q;
            default: s_axi_rdata <= 32'h0;
          endcase
        end
      end else if (s_axi_rvalid && s_axi_rready) begin
        s_axi_rvalid <= 1'b0;
      end
    end
  end
endmodule

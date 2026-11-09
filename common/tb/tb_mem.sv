// Fixed-latency dual-port memory for the common wrapper interface (common/wrapper/README.md).
// Both ports are always granted; each request gets its response exactly LAT cycles later.
// 64-bit wide, byte-addressed RAM at 0x0, plus test MMIO on the data port at 0x8000_0000.
module tb_mem #(
  parameter int          LAT       = 1,
  parameter int unsigned RAM_BYTES = 256 * 1024
) (
  input  logic        clk,
  input  logic        rst_n,
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
  output logic        d_err,
  // MMIO events (to tb_top)
  output logic        putc_valid,
  output logic [7:0]  putc_char,
  output logic        exit_valid,
  output logic [31:0] exit_code,
  output logic        mark_valid,
  output logic [31:0] mark_value
);
  localparam logic [31:0] MMIO_BASE = 32'h8000_0000;

  logic [7:0] ram [RAM_BYTES];

  assign i_gnt = 1'b1;
  assign d_gnt = 1'b1;

  function automatic logic [63:0] rd64(input logic [31:0] a);
    logic [63:0] v;
    for (int b = 0; b < 8; b++) v[8*b +: 8] = ram[{a[31:3], 3'b000} + b];
    return v;
  endfunction

  // response pipelines
  logic [LAT-1:0]  i_v_q, d_v_q, i_e_q, d_e_q;
  logic [63:0]     i_d_q [LAT];
  logic [63:0]     d_d_q [LAT];

  wire i_ok = i_addr < RAM_BYTES;
  wire d_mmio = d_addr >= MMIO_BASE;
  wire d_ok = d_mmio || (d_addr < RAM_BYTES);

  // value written by a 64-bit-lane store, shifted down to the addressed byte
  wire [63:0] d_wval = d_wdata >> (8 * d_addr[2:0]);

  always_ff @(posedge clk) begin
    putc_valid <= 1'b0;
    exit_valid <= 1'b0;
    mark_valid <= 1'b0;
    if (!rst_n) begin
      i_v_q <= '0;
      d_v_q <= '0;
    end else begin
      i_v_q <= {i_v_q[LAT-2 >= 0 ? LAT-2 : 0 : 0], i_req};
      d_v_q <= {d_v_q[LAT-2 >= 0 ? LAT-2 : 0 : 0], d_req};
      i_e_q <= {i_e_q[LAT-2 >= 0 ? LAT-2 : 0 : 0], i_req && !i_ok};
      d_e_q <= {d_e_q[LAT-2 >= 0 ? LAT-2 : 0 : 0], d_req && !d_ok};
      for (int s = LAT - 1; s > 0; s--) begin
        i_d_q[s] <= i_d_q[s-1];
        d_d_q[s] <= d_d_q[s-1];
      end
      i_d_q[0] <= i_ok ? rd64(i_addr) : 64'h0;
      d_d_q[0] <= (d_ok && !d_mmio) ? rd64(d_addr) : 64'h0;
      if (d_req && d_we && d_ok) begin
        if (d_mmio) begin
          case (d_addr[7:0] & 8'hf8)
            8'h00: begin putc_valid <= 1'b1; putc_char <= d_wval[7:0]; end
            8'h08: begin exit_valid <= 1'b1; exit_code <= d_wval[31:0]; end
            8'h10: begin mark_valid <= 1'b1; mark_value <= d_wval[31:0]; end
            default: ;
          endcase
        end else begin
          for (int b = 0; b < 8; b++)
            if (d_be[b]) ram[{d_addr[31:3], 3'b000} + b] <= d_wdata[8*b +: 8];
        end
      end
    end
  end

  assign i_rvalid = i_v_q[LAT-1];
  assign i_rdata  = i_d_q[LAT-1];
  assign i_err    = i_e_q[LAT-1];
  assign d_rvalid = d_v_q[LAT-1];
  assign d_rdata  = d_d_q[LAT-1];
  assign d_err    = d_e_q[LAT-1];
endmodule

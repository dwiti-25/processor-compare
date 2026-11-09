// 32-bit OBI master -> 64-bit OBI port. Requests pass straight through (byte enables and write
// data are steered to the lane chosen by addr[2]); a small FIFO remembers addr[2] of each
// outstanding request to pick the right half of the read data.
module obi32to64 #(
  parameter int DEPTH = 4  // max outstanding requests
) (
  input  logic        clk,
  input  logic        rst_n,
  // 32-bit side (from the core)
  input  logic        req32,
  output logic        gnt32,
  input  logic [31:0] addr32,
  input  logic        we32,
  input  logic [3:0]  be32,
  input  logic [31:0] wdata32,
  output logic        rvalid32,
  output logic [31:0] rdata32,
  output logic        err32,
  // 64-bit side (to memory)
  output logic        req,
  input  logic        gnt,
  output logic [31:0] addr,
  output logic        we,
  output logic [7:0]  be,
  output logic [63:0] wdata,
  input  logic        rvalid,
  input  logic [63:0] rdata,
  input  logic        err
);
  localparam int PW = $clog2(DEPTH);

  logic [DEPTH-1:0] hi_q;  // addr[2] of each outstanding request
  logic [PW-1:0]    wptr, rptr;
  logic [PW:0]      count;

  wire push = req32 && gnt32;
  wire pop  = rvalid;

  assign req      = req32 && (count < DEPTH);
  assign gnt32    = gnt && (count < DEPTH);
  assign addr     = addr32;
  assign we       = we32;
  assign be       = addr32[2] ? {be32, 4'b0} : {4'b0, be32};
  assign wdata    = {wdata32, wdata32};
  assign rvalid32 = rvalid;
  assign rdata32  = hi_q[rptr] ? rdata[63:32] : rdata[31:0];
  assign err32    = err;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr  <= '0;
      rptr  <= '0;
      count <= '0;
      hi_q  <= '0;
    end else begin
      if (push) begin
        hi_q[wptr] <= addr32[2];
        wptr       <= wptr + 1'b1;
      end
      if (pop) rptr <= rptr + 1'b1;
      count <= count + (push ? 1'b1 : 1'b0) - (pop ? 1'b1 : 1'b0);
    end
  end
endmodule

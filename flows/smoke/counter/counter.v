// Flow smoke test: 16-bit counter with enable
module counter (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        en,
  output reg  [15:0] count
);
  always @(posedge clk or negedge rst_n)
    if (!rst_n)  count <= 16'd0;
    else if (en) count <= count + 16'd1;
endmodule

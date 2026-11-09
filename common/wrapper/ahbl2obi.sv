// AHB-Lite master -> 32-bit OBI. Single master, no wait-state generation beyond what the OBI side
// needs. Reads are issued during the AHB address phase (zero wait states with a 1-cycle memory);
// writes are issued during the data phase, when HWDATA is valid, and complete as soon as they are
// granted (posted; their OBI response is dropped). A read whose address phase coincides with a
// write data phase is issued one cycle later, in its own data phase. HRESP is always OKAY.
module ahbl2obi (
  input  logic        clk,
  input  logic        rst_n,
  // AHB-Lite (from the master)
  input  logic [31:0] haddr,
  input  logic [1:0]  htrans,
  input  logic        hwrite,
  input  logic [2:0]  hsize,
  input  logic [31:0] hwdata,
  output logic        hready,
  output logic        hresp,
  output logic [31:0] hrdata,
  // 32-bit OBI (to memory)
  output logic        req,
  input  logic        gnt,
  output logic [31:0] addr,
  output logic        we,
  output logic [3:0]  be,
  output logic [31:0] wdata,
  input  logic        rvalid,
  input  logic [31:0] rdata
);
  // data-phase state
  logic        dph_v, dph_w, dph_rd_issued;
  logic [31:0] dph_addr;
  logic [2:0]  dph_size;
  // types of outstanding OBI requests (1 = write), in order; at most 2 can be outstanding
  logic [1:0]  ot_w;
  logic [1:0]  ot_n;

  wire aph_v        = htrans[1];
  wire wr_issue     = dph_v && dph_w;                      // write data phase uses the port
  wire rd_issue_dph = dph_v && !dph_w && !dph_rd_issued;   // deferred read
  wire head_is_read = (ot_n != 0) && !ot_w[0];
  wire rd_done      = dph_v && !dph_w && dph_rd_issued && rvalid && head_is_read;

  assign hready = !dph_v || (dph_w ? gnt : rd_done);
  wire aph_rd_issue = aph_v && !hwrite && hready && !wr_issue && !rd_issue_dph;

  function automatic logic [3:0] byte_en(input logic [2:0] size, input logic [1:0] a);
    case (size)
      3'd0:    byte_en = 4'b0001 << a;
      3'd1:    byte_en = a[1] ? 4'b1100 : 4'b0011;
      default: byte_en = 4'b1111;
    endcase
  endfunction

  assign req   = wr_issue || rd_issue_dph || aph_rd_issue;
  assign addr  = (wr_issue || rd_issue_dph) ? dph_addr : haddr;
  assign we    = wr_issue;
  assign be    = wr_issue ? byte_en(dph_size, dph_addr[1:0]) : 4'b1111;
  assign wdata = hwdata;
  assign hresp = 1'b0;
  assign hrdata = rdata;

  wire push = req && gnt;
  wire pop  = rvalid;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dph_v         <= 1'b0;
      dph_w         <= 1'b0;
      dph_rd_issued <= 1'b0;
      dph_addr      <= '0;
      dph_size      <= '0;
      ot_w          <= '0;
      ot_n          <= '0;
    end else begin
      if (hready) begin
        dph_v         <= aph_v;
        dph_w         <= hwrite;
        dph_addr      <= haddr;
        dph_size      <= hsize;
        dph_rd_issued <= aph_rd_issue && gnt;
      end else if (rd_issue_dph && gnt) begin
        dph_rd_issued <= 1'b1;
      end
      // outstanding-type queue (2 entries)
      case ({push, pop})
        2'b10: begin ot_w[ot_n[0]] <= we; ot_n <= ot_n + 1'b1; end
        2'b01: begin ot_w <= {1'b0, ot_w[1]}; ot_n <= ot_n - 1'b1; end
        2'b11: begin
          if (ot_n == 1) ot_w[0] <= we;
          else           begin ot_w[0] <= ot_w[1]; ot_w[1] <= we; end
        end
        default: ;
      endcase
    end
  end

`ifndef SYNTHESIS
  always @(posedge clk) if (rst_n) begin
    assert (!(push && !pop && ot_n == 2)) else $fatal(1, "ahbl2obi: more than 2 outstanding requests");
  end
`endif
endmodule

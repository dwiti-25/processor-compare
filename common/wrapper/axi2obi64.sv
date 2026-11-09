// AXI4 master (single-beat transfers only) -> 64-bit OBI. Writes (AW+W together) have priority
// over reads (AR). Responses come back from OBI in order and are queued with their AXI ID until the
// master takes them on B or R. Up to DEPTH transfers are in flight (issued or queued).
module axi2obi64 #(
  parameter int ID_W  = 3,
  parameter int DEPTH = 4
) (
  input  logic            clk,
  input  logic            rst_n,
  // AXI4 write address / data / response
  input  logic            awvalid,
  output logic            awready,
  input  logic [ID_W-1:0] awid,
  input  logic [31:0]     awaddr,
  input  logic [7:0]      awlen,
  input  logic            wvalid,
  output logic            wready,
  input  logic [63:0]     wdata,
  input  logic [7:0]      wstrb,
  input  logic            wlast,
  output logic            bvalid,
  input  logic            bready,
  output logic [ID_W-1:0] bid,
  output logic [1:0]      bresp,
  // AXI4 read address / data
  input  logic            arvalid,
  output logic            arready,
  input  logic [ID_W-1:0] arid,
  input  logic [31:0]     araddr,
  input  logic [7:0]      arlen,
  output logic            rvalid,
  input  logic            rready,
  output logic [ID_W-1:0] rid,
  output logic [63:0]     rdata,
  output logic [1:0]      rresp,
  output logic            rlast,
  // 64-bit OBI
  output logic            req,
  input  logic            gnt,
  output logic [31:0]     addr,
  output logic            we,
  output logic [7:0]      be,
  output logic [63:0]     wdata_o,
  input  logic            m_rvalid,
  input  logic [63:0]     m_rdata,
  input  logic            m_err
);
  localparam int PW = $clog2(DEPTH);

  // One in-order queue: an entry is allocated when a request is granted and filled with data when
  // its OBI response arrives; the head is presented on B or R once filled.
  logic [DEPTH-1:0]   q_w, q_full;
  logic [ID_W-1:0]    q_id   [DEPTH];
  logic [63:0]        q_data [DEPTH];
  logic [DEPTH-1:0]   q_err;
  logic [PW-1:0]      wp, fp, rp;   // allocate, fill, read pointers
  logic [PW:0]        n;

  wire space  = n < DEPTH;
  wire do_wr  = awvalid && wvalid && space;
  wire do_rd  = arvalid && space && !(awvalid && wvalid);

  assign req     = do_wr || do_rd;
  assign addr    = do_wr ? awaddr : araddr;
  assign we      = do_wr;
  assign be      = do_wr ? wstrb : 8'hff;
  assign wdata_o = wdata;
  assign awready = do_wr && gnt;
  assign wready  = do_wr && gnt;
  assign arready = do_rd && gnt;

  wire head_ok = (n != 0) && q_full[rp];
  assign bvalid = head_ok && q_w[rp];
  assign rvalid = head_ok && !q_w[rp];
  assign bid    = q_id[rp];
  assign rid    = q_id[rp];
  assign rdata  = q_data[rp];
  assign bresp  = q_err[rp] ? 2'b10 : 2'b00;
  assign rresp  = q_err[rp] ? 2'b10 : 2'b00;
  assign rlast  = 1'b1;

  wire alloc = req && gnt;
  wire take  = (bvalid && bready) || (rvalid && rready);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wp <= '0; fp <= '0; rp <= '0; n <= '0;
      q_full <= '0; q_w <= '0; q_err <= '0;
    end else begin
      if (alloc) begin
        q_w[wp]    <= do_wr;
        q_id[wp]   <= do_wr ? awid : arid;
        q_full[wp] <= 1'b0;
        wp         <= wp + 1'b1;
      end
      if (m_rvalid) begin
        q_data[fp] <= m_rdata;
        q_err[fp]  <= m_err;
        q_full[fp] <= 1'b1;
        fp         <= fp + 1'b1;
      end
      if (take) rp <= rp + 1'b1;
      n <= n + (alloc ? 1'b1 : 1'b0) - (take ? 1'b1 : 1'b0);
    end
  end

`ifndef SYNTHESIS
  always @(posedge clk) if (rst_n) begin
    if (awvalid) assert (awlen == 0) else $fatal(1, "axi2obi64: AXI write bursts not supported");
    if (arvalid) assert (arlen == 0) else $fatal(1, "axi2obi64: AXI read bursts not supported");
    if (wvalid)  assert (wlast)      else $fatal(1, "axi2obi64: WLAST expected on single beat");
  end
`endif
endmodule

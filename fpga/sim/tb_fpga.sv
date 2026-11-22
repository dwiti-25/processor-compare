// Simulation testbench (Verilator) for one FPGA top (<core>_fpga: fpga_shell + core wrapper). It plays the Zynq PS
// over AXI4-Lite exactly as the PYNQ notebook does: hold the core in reset, write the program into
// block RAM, check the ID, set CTRL.RUN, poll STATUS.DONE, read EXIT / CYCLES / MARKED / console.
// Plusargs: +hex=<file> (objcopy -O verilog, same image as the RTL sim)  +maxcycles=<n>
// Prints the console, then:  FPGA_RESULT core=<top> exit=<code> cycles=<n> marked_cycles=<n> ...
`ifndef FPGA_TOP
  `define FPGA_TOP hazard3_fpga
`endif
`define STR(x) `"x`"

module tb_fpga;
  logic clk = 1'b0;
  always #5 clk = ~clk;
  logic aresetn = 1'b0;

  logic [18:0] awaddr, araddr;
  logic        awvalid, awready, wvalid, wready, bvalid, bready, arvalid, arready, rvalid, rready;
  logic [31:0] wdata, rdata;
  logic [3:0]  wstrb;
  logic [1:0]  bresp, rresp;

  `FPGA_TOP dut (
    .clk, .aresetn,
    .s_axi_awaddr (awaddr), .s_axi_awprot (3'b0), .s_axi_awvalid (awvalid), .s_axi_awready (awready),
    .s_axi_wdata (wdata), .s_axi_wstrb (wstrb), .s_axi_wvalid (wvalid), .s_axi_wready (wready),
    .s_axi_bresp (bresp), .s_axi_bvalid (bvalid), .s_axi_bready (bready),
    .s_axi_araddr (araddr), .s_axi_arprot (3'b0), .s_axi_arvalid (arvalid), .s_axi_arready (arready),
    .s_axi_rdata (rdata), .s_axi_rresp (rresp), .s_axi_rvalid (rvalid), .s_axi_rready (rready)
  );

  // ------------------------------------------------------------- AXI4-Lite master tasks
  task automatic axi_write(input logic [18:0] a, input logic [31:0] d, output logic [1:0] resp);
    @(negedge clk);
    awaddr = a; awvalid = 1; wdata = d; wstrb = 4'hf; wvalid = 1; bready = 1;
    do @(posedge clk); while (!(awready && wready));
    @(negedge clk); awvalid = 0; wvalid = 0;
    while (!bvalid) @(negedge clk);
    resp = bresp;
    @(posedge clk); @(negedge clk); bready = 0;
  endtask
  task automatic axi_read(input logic [18:0] a, output logic [31:0] d, output logic [1:0] resp);
    @(negedge clk);
    araddr = a; arvalid = 1; rready = 1;
    do @(posedge clk); while (!arready);
    @(negedge clk); arvalid = 0;
    while (!rvalid) @(negedge clk);
    d = rdata; resp = rresp;
    @(posedge clk); @(negedge clk); rready = 0;
  endtask
  task automatic wr(input logic [18:0] a, input logic [31:0] d);
    logic [1:0] r;
    axi_write(a, d, r);
    if (r != 2'b00) $fatal(1, "TB: AXI write %h resp %0d", a, r);
  endtask
  task automatic rd(input logic [18:0] a, output logic [31:0] d);
    logic [1:0] r;
    axi_read(a, d, r);
    if (r != 2'b00) $fatal(1, "TB: AXI read %h resp %0d", a, r);
  endtask

  localparam int RAM_BYTES = 256 * 1024;
  logic [7:0] img [RAM_BYTES];
  string hex, trace_path;
  bit trace_enabled = 1'b0;
  longint unsigned maxcycles = 200_000_000, ncyc = 0;
  always @(posedge clk) ncyc <= ncyc + 1;

  initial begin
    logic [31:0] v, st, exitc, clo, chi, mlo, mhi, clen, ecnt, eaddr, id;
    logic [1:0]  r;
    int unsigned nchk;
    awvalid = 0; wvalid = 0; bready = 0; arvalid = 0; rready = 0; awaddr = 0; araddr = 0; wdata = 0; wstrb = 0;
    if (!$value$plusargs("hex=%s", hex)) $fatal(1, "TB: +hex=<file> required");
    if ($value$plusargs("trace=%s", trace_path)) begin
      trace_enabled = 1'b1;
      $dumpfile(trace_path);
      $dumpvars(0, tb_fpga);
      $dumpoff; // Ignore reset, image loading, and AXI readback; trace the CPU run only.
    end
    void'($value$plusargs("maxcycles=%d", maxcycles));
    for (int k = 0; k < RAM_BYTES; k++) img[k] = 8'h00;
    $readmemh(hex, img);

    repeat (5) @(posedge clk);
    aresetn = 1'b1;                       // PS peripheral reset released
    repeat (2) @(posedge clk);

    rd(19'h4_000C, id);
    if (id[31:16] != 16'hF6A0) $fatal(1, "TB: bad ID %h", id);
    // Simulation only: a short RUN pulse gives the core's asynchronous resets a real falling edge
    // (Verilator does not treat a reset that is low from time 0 as an event; see tb_top.sv). On the
    // board, reset is a level and the notebook does not need this.
    wr(19'h4_0000, 32'h1);
    wr(19'h4_0000, 32'h0);

    // load: every word of the 256 KiB RAM (the image is zero outside the program), like the notebook
    for (int a = 0; a < RAM_BYTES; a += 4)
      wr(a[18:0], {img[a+3], img[a+2], img[a+1], img[a]});
    // read back a sample (every 61st word) + a RAM write during the run must be refused
    nchk = 0;
    for (int a = 0; a < RAM_BYTES; a += 4 * 61) begin
      rd(a[18:0], v);
      if (v != {img[a+3], img[a+2], img[a+1], img[a]}) $fatal(1, "TB: RAM readback %h: %h", a, v);
      nchk++;
    end

    if (trace_enabled) $dumpon;
    wr(19'h4_0000, 32'h1);                // RUN
    axi_write(19'h0_0100, 32'hdead_beef, r);
    if (r != 2'b10) $fatal(1, "TB: RAM write during run not refused");
    do begin
      repeat (2000) @(posedge clk);
      rd(19'h4_0004, st);
      if (ncyc > maxcycles) begin $display("\nFPGA_RESULT core=%s exit=timeout", `STR(`FPGA_TOP)); $finish; end
    end while (!st[0]);
    if (trace_enabled) $dumpoff;

    rd(19'h4_0008, exitc); rd(19'h4_0010, clo); rd(19'h4_0014, chi); rd(19'h4_0018, mlo); rd(19'h4_001C, mhi);
    rd(19'h4_0020, clen); rd(19'h4_0024, ecnt); rd(19'h4_0028, eaddr);
    for (int k = 0; k < clen && k < 4096; k += 4) begin
      rd(19'h4_1000 + k[18:0], v);
      for (int b = 0; b < 4 && k + b < clen; b++) $write("%c", v[8*b +: 8]);
    end
    $display("\nFPGA_RESULT core=%s exit=%0d cycles=%0d marked_cycles=%0d console_len=%0d bus_err=%0d err_addr=%h status=%h id=%h readback_words=%0d",
             `STR(`FPGA_TOP), exitc, {chi, clo}, {mhi, mlo}, clen, ecnt, eaddr, st, id, nchk);
    $finish;
  end
endmodule

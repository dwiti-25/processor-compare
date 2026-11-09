// Shared testbench: one core wrapper (`CORE_WRAP`, common ports) + tb_mem.
// Plusargs: +hex=<file>       program image ($readmemh, byte-wide, from objcopy -O verilog)
//           +maxcycles=<n>    timeout (default 200M)
//           +trace            print every bus request/response (debug)
// Prints the program's putchar output, then one summary line that scripts parse:
//   TB_RESULT core=<name> exit=<code> cycles=<total> marked_cycles=<start..stop>
`ifndef CORE_WRAP
  `define CORE_WRAP hazard3_wrap
`endif
`define STR(x) `"x`"

module tb_top;
  logic clk = 1'b0;
  logic rst_n = 1'b1;  // driven low after time 0 so async resets see a real falling edge
  always #5 clk = ~clk;

  logic        i_req, i_gnt, i_rvalid, i_err;
  logic [31:0] i_addr;
  logic [63:0] i_rdata;
  logic        d_req, d_gnt, d_we, d_rvalid, d_err;
  logic [31:0] d_addr;
  logic [7:0]  d_be;
  logic [63:0] d_wdata, d_rdata;

  logic        putc_valid, exit_valid, mark_valid;
  logic [7:0]  putc_char;
  logic [31:0] exit_code, mark_value;

  `CORE_WRAP dut (
    .clk, .rst_n,
    .i_req, .i_gnt, .i_addr, .i_rvalid, .i_rdata, .i_err,
    .d_req, .d_gnt, .d_addr, .d_we, .d_be, .d_wdata, .d_rvalid, .d_rdata, .d_err,
    .irq_timer (1'b0), .irq_soft (1'b0), .irq_ext (1'b0)
  );

  tb_mem #(.LAT(1)) mem (
    .clk, .rst_n,
    .i_req, .i_gnt, .i_addr, .i_rvalid, .i_rdata, .i_err,
    .d_req, .d_gnt, .d_addr, .d_we, .d_be, .d_wdata, .d_rvalid, .d_rdata, .d_err,
    .putc_valid, .putc_char, .exit_valid, .exit_code, .mark_valid, .mark_value
  );

  longint unsigned cycles = 0, mark_start = 0, marked = 0;
  longint unsigned maxcycles = 200_000_000;
  bit              marking = 0;
  bit              trace = 0;
  string           hex;

  initial begin
    if (!$value$plusargs("hex=%s", hex)) $fatal(1, "TB: +hex=<file> required");
    void'($value$plusargs("maxcycles=%d", maxcycles));
    trace = $test$plusargs("trace");
    $readmemh(hex, mem.ram);
    #1 rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  always @(posedge clk) if (rst_n) begin
    cycles <= cycles + 1;
    if (putc_valid) $write("%c", putc_char);
    if (trace) begin
      if (i_req && i_gnt) $display("TRACE %0d I req  %h", cycles, i_addr);
      if (i_rvalid)       $display("TRACE %0d I resp %h", cycles, i_rdata);
      if (d_req && d_gnt) $display("TRACE %0d D req  %h we=%0d be=%h wdata=%h", cycles, d_addr, d_we, d_be, d_wdata);
      if (d_rvalid)       $display("TRACE %0d D resp %h", cycles, d_rdata);
    end
    if (mark_valid) begin
      if (mark_value != 0) begin marking <= 1; mark_start <= cycles; end
      else if (marking)   begin marking <= 0; marked <= marked + (cycles - mark_start); end
    end
    if (i_err || d_err) begin
      $display("\nTB: bus error (i_err=%0d d_err=%0d i_addr=%h d_addr=%h) at cycle %0d",
               i_err, d_err, i_addr, d_addr, cycles);
    end
    if (exit_valid) begin
      $display("\nTB_RESULT core=%s exit=%0d cycles=%0d marked_cycles=%0d",
               `STR(`CORE_WRAP), exit_code, cycles, marked);
      $finish;
    end
    if (cycles >= maxcycles) begin
      $display("\nTB_RESULT core=%s exit=timeout cycles=%0d marked_cycles=%0d",
               `STR(`CORE_WRAP), cycles, marked);
      $finish;
    end
  end
endmodule

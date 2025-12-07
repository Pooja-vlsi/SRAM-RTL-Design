// testbench.sv
`timescale 1ns/1ps

module testbench;

  // match RTL parameters
  localparam ADDR_WIDTH = 4;
  localparam DATA_WIDTH = 4;

  // DUT signals
  logic                   clk;
  logic                   reset;
  logic                   wr;
  logic                   rd;
  logic [ADDR_WIDTH-1:0]  addr;
  logic [DATA_WIDTH-1:0]  din;
  logic [DATA_WIDTH-1:0]  dout;

  integer cycle;

  // ============================
  // DUT instance
  // ============================
  sram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) dut (
    .clk   (clk),
    .reset (reset),
    .wr    (wr),
    .rd    (rd),
    .addr  (addr),
    .din   (din),
    .dout  (dout)
  );

  // ============================
  // Clock
  // ============================
  initial begin
    clk = 0;
    forever #5 clk = ~clk;          // 10 ns period
  end

  // ============================
  // VCD dump for EPWave
  // ============================
  initial begin
    $dumpfile("sram_tb.vcd");
    $dumpvars(0, testbench);        // dump everything under this TB
  end

  // ============================
  // Main stimulus
  // ============================
  initial begin
    // init
    reset = 1;
    wr    = 0;
    rd    = 0;
    addr  = '0;
    din   = '0;
    cycle = 0;

    // hold reset for a couple of cycles
    repeat (2) @(posedge clk);
    reset = 0;

    // -----------------------------
    // 1) WRITE cycle
    // -----------------------------
    $display("--- Start Write Cycle (WR=1) ---");
    @(posedge clk);
    addr <= 4'h3;          // write address
    din  <= 4'hA;          // write data = 0xA
    wr   <= 1'b1;
    rd   <= 1'b0;

    @(posedge clk);        // write happens here
    wr   <= 1'b0;
    din  <= '0;

    // small gap
    repeat (2) @(posedge clk);

    // -----------------------------
    // 2) READ cycle
    // -----------------------------
    $display("--- Start Read Cycle (RD=1) ---");
    @(posedge clk);
    addr <= 4'h3;
    rd   <= 1'b1;
    wr   <= 1'b0;

    @(posedge clk);        // read happens here
    rd <= 1'b0;

    repeat (2) @(posedge clk);
    $display("Read back: Addr = 0x%0h, Data = 0x%0h", addr, dout);

    // -----------------------------
    // End of test
    // -----------------------------
    $display("--- Test Complete ---");
    #20;
    $finish;
  end

  // Optional: cycle counter
  always @(posedge clk) begin
    cycle <= cycle + 1;
  end

endmodule

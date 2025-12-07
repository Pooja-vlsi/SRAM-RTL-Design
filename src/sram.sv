// design.sv
`timescale 1ns/1ps

// Simple synchronous SRAM
module sram #(
    parameter ADDR_WIDTH = 4,          // 2^4 = 16 locations
    parameter DATA_WIDTH = 4           // 4-bit data
)(
    input  logic                     clk,
    input  logic                     reset,

    input  logic                     wr,      // write enable
    input  logic                     rd,      // read enable
    input  logic [ADDR_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    din,
    output logic [DATA_WIDTH-1:0]    dout
);

    // 16 x 4-bit memory array
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    integer i;

    // Synchronous write + read
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // clear memory and output
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
                mem[i] <= '0;
            dout <= '0;
        end else begin
            // write
            if (wr)
                mem[addr] <= din;

            // read
            if (rd)
                dout <= mem[addr];
            else
                dout <= '0;
        end
    end

endmodule

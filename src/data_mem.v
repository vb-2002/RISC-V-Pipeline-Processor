// ------------------------------------------------------
// 32-word Data Memory (word-addressable)
// - 32-bit address input (uses address[6:2] internally)
// - Combinational read
// - Synchronous write (posedge clk)
// ------------------------------------------------------
// Note: This module is not sythesiable. It is a bmod intended for simulation purposes only.
// ------------------------------------------------------
module data_mem (
    input clk,                    // Clock input
    input r_enable,               // Read enable
    input w_enable,               // Write enable
    input [31:0] address,         // Full 32-bit address input
    input [31:0] wr_data,         // Data to be written
    output reg [31:0] re_data     // Data read
);

    reg [31:0] dmem [31:0];       // 32-word memory
    wire [4:0] word_addr = address[6:2]; // Word-aligned index
    integer i;

    initial begin 
        for(i = 0;i < 32;i = i+1)
	        dmem[i] = 0;; 
    end
    // Synchronous write
    always @(posedge clk) begin
        if (w_enable)
            dmem[word_addr] <= wr_data;
    end

    // Combinational read
    always @(*) begin
        if (r_enable)
            re_data = dmem[word_addr];
        else
            re_data = 32'd0;
    end

endmodule


 
 
 
 
 
 
 

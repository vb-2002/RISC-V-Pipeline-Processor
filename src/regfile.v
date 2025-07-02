// ------------------------------------------------------
// Register File (32 x 32-bit)
// - All registers initialized to 0
// - Register x0 is hardwired to 0 (non-writable)
// - 2 combinational read ports, 1 synchronous write port
// - Simulation-only model
// ------------------------------------------------------
module regfile(
    input [4:0]  readregA,
    input [4:0]  readregB,
    input [4:0]  writereg,
    input [31:0] writedata,
    input        RegWrite,
    input        clk,
    output reg [31:0] readdataA,
    output reg [31:0] readdataB
);

    reg [31:0] regs[31:0];
    integer i;

    // Initialize all registers to 0
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'd0;
        end
    end

    // Combinational read
    always @(*) begin
        readdataA = regs[readregA];
        readdataB = regs[readregB];
    end

    // Synchronous write on negative edge
    always @(negedge clk) begin
        if (RegWrite && writereg != 5'd0)  // Prevent write to x0
            regs[writereg] <= writedata;
    end

endmodule

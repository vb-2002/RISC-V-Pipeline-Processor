// ------------------------------------------------------
// Instruction Memory (Read-only)
// - 32 instructions, word-addressable (PC[6:2])
// ----------------------------------------------
// Note: This module is not sythesiable. It is a bmod intended for simulation purposes only.
// ------------------------------------------------------
module instr_mem (
    input [31:0] PCin,             // Program Counter input (byte address)
    input rst,                     // Reset signal
    output reg [31:0] instruction  // 32-bit instruction output
);

    reg [31:0] memloc[31:0];       // 32-entry instruction memory

    // Initialize instruction memory from file
    initial begin
        $readmemh("./tb/instr_mem.txt", memloc);
    end

    // Combinational read logic
    always @(*) begin
        if (rst)
            instruction = 32'h00000013;  // ADDI x0, x0, 0 (NOP)
        else
            instruction = memloc[PCin[6:2]]; // Word-aligned lookup
    end

endmodule



 

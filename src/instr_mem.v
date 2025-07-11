// ------------------------------------------------------
// Instruction Memory (Read-only)
// - 32 instructions, word-addressable (PC[6:2])
// ----------------------------------------------
// Note: This module is not sythesiable. It is a bmod intended for simulation purposes only.
// ------------------------------------------------------
module instr_mem (
    input  [31:0] PCin,
    input         rst,
    output [31:0] instruction
);

    reg [31:0] mem [0:31];  // 32-entry instruction memory

    // Initialize memory directly
    integer i;
    initial begin
        mem[0]  = 32'h00000293;  // addi x5, x0, 0
        mem[1]  = 32'h00500313;  // addi x6, x0, 5
        mem[2]  = 32'h00b324b3;  // add  x9, x6, x11
        mem[3]  = 32'h0062a433;  // xor  x8, x5, x6
        mem[4]  = 32'h0092b233;  // and  x4, x5, x9
        mem[5]  = 32'h004000ef;  // jal  x1, 4  (if supported)
        mem[6]  = 32'h0002c283;  // lw   x5, 0(x5)
        mem[7]  = 32'h00c32023;  // sw   x12, 0(x6)
        mem[8]  = 32'h00530463;  // beq  x6, x5, +8
        mem[9]  = 32'h00531463;  // bne  x6, x5, +8

        for (i = 10; i < 32; i = i + 1)
            mem[i] = 32'h00000000;
    end

    assign instruction = mem[PCin[6:2]];  // Word-aligned instruction fetch

endmodule




 

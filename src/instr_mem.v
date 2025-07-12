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
        mem[0]  = 32'h00a00093;  // addi x1,x0,10 --> x1 = 0 + 10 = 10
        mem[1]  = 32'h01400113;  // addi x2,x0,20 --> x2 = 0 + 20 = 20
        mem[2]  = 32'h002081b3;  // add x3,x1,x2 --> x3 = x1 + x2 = 30
        mem[3]  = 32'h04000213;  // addi x4,x0,64 --> x4 = 0 + 64 = 64
        mem[4]  = 32'h00312223;  // sw x3,4(x2) --> store x3 at mem[x2+4]
        mem[5]  = 32'h0040e093;  // ori x1,x1,4 --> x1 = x1 | 4 = 14
        mem[6]  = 32'h0010f333;  // and x6,x1,x1 --> x6 = x1 & x1 = 14 (Note: original comment unclear)
        mem[7]  = 32'h002241b3;  // xor x3,x4,x2 --> x3 = x4 ^ x2 = 84
        mem[8]  = 32'h00231393;  // slli x7,x6,2 --> x7 = x6 << 2 = 56
        mem[9]  = 32'h00325413;  // srli x8,x4,3 --> x8 = x4 >> 3 = 8
        mem[10] = 32'h4010d493;  // srai x9,x1,1 --> x9 = x1 >>> 1 = 7
        mem[11] = 32'h00a0a103;  // lw x2,10(x1) --> x2 = mem[x1+10] (changed offset to 10)
        mem[12] = 32'h00708133;  // add x2,x1,x7 --> x2 = x1 + x7 = 14 + 56 = 70
        mem[13] = 32'h00708533;  // add x10,x1,x7 --> x10 = x1 + x7 = 14 + 56 = 70 (same as x2)
        mem[14] = 32'hfea100e3;  // beq x2,x10,-32 --> branch back 32 bytes (always taken since x2 == x10 = 70)
        // Initialize remaining instructions to 0
        for (i = 15; i < 32; i = i + 1)
            mem[i] = 32'h00000000;
    end

    assign instruction = mem[PCin[6:2]];  // Word-aligned instruction fetch

endmodule
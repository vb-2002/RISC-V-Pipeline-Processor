module instr_mem (
    input  logic [31:0] PCin,          // Byte address (from PC)
    input  logic        rst,
    output logic [31:0] instruction    // 32-bit instruction at PC
);

    // Memory of 32 instructions (32-bit each)
    logic [31:0] memloc [0:31];

    // Initialize memory from file
    initial begin
        $readmemh("instr1.txt", memloc);
    end

    // Combinational read
    always_comb begin
        if (rst)
            instruction = 32'd0;  // NOP or reset instruction
        else
            instruction = memloc[PCin[6:2]]; // Word-aligned access
    end

endmodule


 

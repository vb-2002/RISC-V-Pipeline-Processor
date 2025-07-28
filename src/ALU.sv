module ALU (
    input  logic [31:0] A,           // Operand A
    input  logic [31:0] B,           // Operand B
    input  logic [3:0]  ALUcontrol,  // Operation selector
    output logic [31:0] result,      // Result output
    output logic        zeroflag     // Set if result == 0
);

    always_comb begin
        unique case (ALUcontrol)
            4'b0000: result = A & B;                 // AND
            4'b0001: result = A | B;                 // OR
            4'b0010: result = A + B;                 // ADD
            4'b0110: result = A - B;                 // SUB
            4'b0011: result = A ^ B;                 // XOR
            4'b0100: result = A << B[4:0];           // Logical shift left
            4'b0101: result = A >> B[4:0];           // Logical shift right
            4'b0111: result = $signed(A) >>> B[4:0]; // Arithmetic shift right (signed)
            default: result = 32'd0;                 // Default case
        endcase
        zeroflag = (result == 32'd0);
    end

endmodule


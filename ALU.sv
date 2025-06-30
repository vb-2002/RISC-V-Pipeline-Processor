module ALU (
    input  logic         clk,          // Clock input (not used in this combinational version)
    input  logic [31:0]  A,            // First operand
    input  logic [31:0]  B,            // Second operand
    input  logic [3:0]   ALUcontrol,   // ALU operation selector
    output logic [31:0]  result,       // ALU result output
    output logic         zeroflag      // Flag set when result is zero
);

    // Combinational always block: describes purely combinational logic
    always_comb begin
        case (ALUcontrol)
            4'b0000: result = A & B;               // Bitwise AND
            4'b0001: result = A | B;               // Bitwise OR
            4'b0010: result = A + B;               // Addition
            4'b0110: result = A - B;               // Subtraction
            4'b0011: result = A ^ B;               // Bitwise XOR
            4'b0100: result = A << B;              // Logical left shift
            4'b0101: result = A >> B;              // Logical right shift
            4'b0111: result = {A[31], A >> B};     // Arithmetic right shift (preserve sign bit)
            default: result = 32'd0;               // Default result for undefined ALUcontrol
        endcase

        // Set zeroflag if result is zero
        zeroflag = (result == 32'd0);
    end

endmodule

module ALUcontrol (
    input  logic [1:0] ALUop,
    input  logic [6:0] funct_7,
    input  logic [2:0] funct_3,
    output logic [3:0] operation
);

    always_comb begin
        operation = 4'd15; // Default: invalid
        // Load/Store instructions (LW, SW, etc.) — Use ADD
        if (ALUop == 2'b00) begin
            operation = 4'd2; // ADD
        end

        // I-type ALU instructions (ADDI, ORI, ANDI, etc.)
        else if (ALUop == 2'b11) begin
            if (funct_3 == 3'b000)
                operation = 4'd2; // ADDI
            else if (funct_3 == 3'b111)
                operation = 4'd0; // ANDI
            else if (funct_3 == 3'b110)
                operation = 4'd1; // ORI
            else if (funct_3 == 3'b100)
                operation = 4'd3; // XORI
            else if (funct_3 == 3'b001)
                operation = 4'd4; // SLLI
            else if (funct_3 == 3'b101) begin
                if (funct_7 == 7'b0100000)
                    operation = 4'd7; // SRAI
                else
                    operation = 4'd5; // SRLI
            end
        end

        // R-type ALU instructions (ADD, SUB, AND, OR, etc.)
        else if (ALUop == 2'b10) begin
            if (funct_3 == 3'b000 && funct_7 == 7'b0000000)
                operation = 4'd2; // ADD
            else if (funct_3 == 3'b000 && funct_7 == 7'b0100000)
                operation = 4'd6; // SUB
            else if (funct_3 == 3'b111)
                operation = 4'd0; // AND
            else if (funct_3 == 3'b110)
                operation = 4'd1; // OR
            else if (funct_3 == 3'b100)
                operation = 4'd3; // XOR
            else if (funct_3 == 3'b001)
                operation = 4'd4; // SLL
            else if (funct_3 == 3'b101 && funct_7 == 7'b0000000)
                operation = 4'd5; // SRL
            else if (funct_3 == 3'b101 && funct_7 == 7'b0100000)
                operation = 4'd7; // SRA
        end
    end

endmodule



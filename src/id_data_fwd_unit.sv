// ------------------------------------------------------
// ID‑Stage Data Forwarding Unit
// - Forwards register values into the ID stage (e.g. for branch
//   comparisons) when those regs are being written in EX/MEM or MEM/WB.
// - Outputs two 2‑bit controls: 00=use RF, 10=forward from EX/MEM, 01=forward from MEM/WB
// ------------------------------------------------------
module id_data_fwd_unit (
    input  logic [4:0] if_id_rs1,        // rs1 from IF/ID
    input  logic [4:0] if_id_rs2,        // rs2 from IF/ID
    input  logic       ex_mem_RegWrite,  // RegWrite from EX/MEM
    input  logic [4:0] ex_mem_rd,        // rd from EX/MEM
    input  logic       mem_wb_RegWrite,  // RegWrite from MEM/WB
    input  logic [4:0] mem_wb_rd,        // rd from MEM/WB
    output logic [1:0] forward1,         // Forward control for operand1
    output logic [1:0] forward2          // Forward control for operand2
);

    // Encoding:
    // 2'b00: use register file
    // 2'b10: forward from EX/MEM
    // 2'b01: forward from MEM/WB

    always_comb begin
        // Default: no forwarding
        forward1 = 2'b00;
        forward2 = 2'b00;

        // Operand1 forwarding
        if (ex_mem_RegWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == if_id_rs1))
            forward1 = 2'b10;           // highest priority: from EX/MEM
        else if (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == if_id_rs1))
            forward1 = 2'b01;           // next: from MEM/WB

        // Operand2 forwarding
        if (ex_mem_RegWrite && (ex_mem_rd != 5'd0) && (ex_mem_rd == if_id_rs2))
            forward2 = 2'b10;
        else if (mem_wb_RegWrite && (mem_wb_rd != 5'd0) && (mem_wb_rd == if_id_rs2))
            forward2 = 2'b01;
    end

endmodule

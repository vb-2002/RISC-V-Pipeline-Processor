// DATA FORWARD UNIT

module data_fwd_unit(
    input  logic [4:0] id_ex_rs1,
    input  logic [4:0] id_ex_rs2,
    input  logic       ex_mem_RegWrite,
    input  logic [4:0] ex_mem_rd,
    input  logic       mem_wb_RegWrite,
    input  logic [4:0] mem_wb_rd,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

//---- Function ----
// Two signals forwardA & forwardB decide the input to ALU. 
// If EX hazard exists, value from EX/MEM is forwarded.
// If MEM hazard exists, value from MEM/WB is forwarded.
// If both exist, EX has priority over MEM.

always_comb begin
    // ForwardA logic
    if (ex_mem_RegWrite && ex_mem_rd != 5'b0 && ex_mem_rd == id_ex_rs1)
        forwardA = 2'b10;
    else if (mem_wb_RegWrite && mem_wb_rd != 5'b0 && mem_wb_rd == id_ex_rs1)
        forwardA = 2'b01;
    else
        forwardA = 2'b00;

    // ForwardB logic
    if (ex_mem_RegWrite && ex_mem_rd != 5'b0 && ex_mem_rd == id_ex_rs2)
        forwardB = 2'b10;
    else if (mem_wb_RegWrite && mem_wb_rd != 5'b0 && mem_wb_rd == id_ex_rs2)
        forwardB = 2'b01;
    else
        forwardB = 2'b00;
end

endmodule


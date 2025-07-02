// DATA FORWARD UNIT

module fwdunit(
    input  logic [4:0] idex_rs1,
    input logic [4:0] idex_rs2,
    input logic exmem_RegWrite,
    input logic [4:0] exmem_rd,
    input logic memwb_RegWrite,
    input logic [4:0] memwb_rd,
    input logic [1:0] ALUOp,
    output logic [1:0] forwardA,
    output logic [1:0] forwardB);

//Limitations of the module
//    1. It assumes all instruction R type, cases of hazard having other types not included yet.

//---- Function ----
//#Two signals forwardA & forwardB decide the input to ALU. 
//#If EX hazard exist value from exmem is put in ALU
//#If MEM hazard exist value from memwb is put in ALU
//#If both exist EX given priority over MEM

always_comb
begin
    //if I type
    if(ALUOp == 2'b11)
    begin

        //assign forwardA signal 
        if(exmem_RegWrite == 1'b1 && exmem_rd != 5'b0 && exmem_rd == idex_rs1)
            forwardA = 2'b10;
        else if(memwb_RegWrite == 1'b1 && memwb_rd != 5'b0 && memwb_rd == idex_rs1)
                forwardA = 2'b01;
        else
            forwardA = 2'b00;

        //assign forwardB signal
        forwardB = 2'b00;

    end

    //if other types dont skip rs2
    else
    begin

        //assign forwardA signal 
        if(exmem_RegWrite == 1'b1 && exmem_rd != 5'b0 && exmem_rd == idex_rs1)
            forwardA = 2'b10;
        else if(memwb_RegWrite == 1'b1 && memwb_rd != 5'b0 && memwb_rd == idex_rs1)
                forwardA = 2'b01;
        else
            forwardA = 2'b00;

        //assign forwardB signal
        if(exmem_RegWrite == 1'b1 && exmem_rd != 5'b0 && exmem_rd == idex_rs2)
            forwardB = 2'b10;
        else if(memwb_RegWrite == 1'b1 && memwb_rd != 5'b0 && memwb_rd == idex_rs2)
                forwardB  = 2'b01;
        else
            forwardB = 2'b00;
        
    end

end
endmodule

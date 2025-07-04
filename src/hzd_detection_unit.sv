module hzd_detection_unit(
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2, 
    input  logic       id_ex_MemRead,
    input  logic [4:0] id_ex_rd,
    output logic       PCWrite,
    output logic       stall    
);

//---- Function ----
// PCWrite and stall signal control stalling of pipeline in case of load-use hazard.
// If current instruction is a load (id_ex_MemRead), and the destination register is
// used as source in the next instruction (rs1 or rs2), then stall.

always_comb begin
    stall   = 1'b0; // Default: no stall
    PCWrite = 1'b1; // Default: allow PC write

    if (id_ex_MemRead && 
       ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
        stall   = 1'b1;
        PCWrite = 1'b0;
    end
end

endmodule

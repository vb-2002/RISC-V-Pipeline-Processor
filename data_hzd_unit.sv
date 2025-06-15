
module hzdunit(
    input logic [4:0] ifid_rs1,
    input logic [4:0] ifid_rs2, 
    input logic idex_MemRead,
    input logic [4:0] idex_rd,
    output logic PCWrite,
    output logic ifidWrite,
    output logic stall    
);

//---- Function ----
//#Two signals PCWrite & ifidWrite control if values will be written in PC and IFID resp. 
//#stall controls a mux to choose b/w hard ground or CU outputs
//#Detects WB hazard i.e in case of load followed by R type

always_comb
begin
    if(idex_MemRead == 1'b1)
    begin
        if(idex_rd == ifid_rs1 || idex_rd == ifid_rs2)
            begin
            stall = 1'b1;
            PCWrite = 1'b0;
            ifidWrite = 1'b0;
            end
    end
    else
    begin
        stall = 1'b0;
        PCWrite = 1'b1;
        ifidWrite = 1'b1;
    end
end
endmodule
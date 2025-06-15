//Flushing operation incase of normal branch instruction
module flush(
    input logic br, 
    input logic z, 
    input logic [31:0] predadd, //predicted and actual address in branch prediction
    input logic [31:0] actadd,
    output logic f); //This signal will be passed as rst of the pipo reg to flush

always_comb
begin
    if(br && z)
        f = 1;
    else
        f = 0;
end

endmodule
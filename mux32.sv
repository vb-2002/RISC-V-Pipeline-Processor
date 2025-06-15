module mux32 #(parameter N=32) (
    output logic [N-1:0] out, 
    input logic [N-1:0] in0,
    input logic [N-1:0] in1, 
    input logic sel);

assign out[N-1:0]=sel?in1[N-1:0]:in0[N-1:0];

endmodule
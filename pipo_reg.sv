//N-bit parallel in parallel out registers as pipeline-reg.
//Register size is parameterized with N and can be changed while instantiating.
module pipo_reg #(parameter N=32)(
	input logic [N-1:0] in;
	input logic clk;
	input logic rst;
	input logic pipo_write;
	output logic [N-1:0] out;
);

 
 always_ff@(posedge clk or posedge rst) // Asynchronous reset is used for the registers.
 begin
	if(rst)
		out <= 0;
	else if(pipo_write)
		out <= in;
 end

endmodule
	
  

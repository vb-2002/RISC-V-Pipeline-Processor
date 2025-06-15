//N bit parameterized adder
module adder #(parameter N=32)(
	input logic [N-1:0] out,
	input logic [N-1:0] ip1,
	input loigc [N-1:0] ip2);

always_comb begin : adder
	out = ip1+ip2;
end
	
endmodule
 

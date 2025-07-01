// ------------------------------------------------------------------
// 2:1 Multiplexer (N-bit)
// Selects between in0 and in1 based on 'sel'
// Parameterized width (default: N=32)
// ------------------------------------------------------------------

module mux2_1 #(
    parameter int N = 32
) (
    output logic [N-1:0] out,
    input  logic [N-1:0] in0,
    input  logic [N-1:0] in1,
    input  logic         sel
);

    assign out = sel ? in1 : in0;

endmodule

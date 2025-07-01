// ------------------------------------------------------------------
// 4:1 Multiplexer (Parameterized Width)
// Selects one of four inputs based on 2-bit 'sel'
// Default data width: 32 bits
// ------------------------------------------------------------------

module mux4_1 #(
    parameter int N = 32  // Data width parameter (default = 32)
) (
    output logic [N-1:0] out,
    input  logic [N-1:0] in1,
    input  logic [N-1:0] in2,
    input  logic [N-1:0] in3,
    input  logic [N-1:0] in4,
    input  logic [1:0]   sel
);

    always_comb begin
        case (sel)
            2'b00:  out = in1;
            2'b01:  out = in2;
            2'b10:  out = in3;
            2'b11:  out = in4;
            default: out = in1;  // Optional: fallback for simulation safety
        endcase
    end

endmodule

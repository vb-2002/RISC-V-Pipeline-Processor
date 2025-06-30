// N-bit parameterized adder module
module adder #(
    parameter int N = 32                // Default width = 32 bits
) (
    input  logic [N-1:0] ip1,           // First input operand
    input  logic [N-1:0] ip2,           // Second input operand
    output logic [N-1:0] out            // Output: sum of ip1 and ip2
);

    // Combinational addition
    always_comb begin
        out = ip1 + ip2;
    end

endmodule

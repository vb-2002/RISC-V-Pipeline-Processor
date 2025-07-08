/// ------------------------------------------------------------------
// N-bit Pipeline Register Module
// Stores input data 'in' on the rising edge of 'clk'
// Writes only when 'write_en' is high
// Clears to 0 on asynchronous reset or flush
// Width must be specified during instantiation
// ------------------------------------------------------------------

module pipeline_reg #(
    parameter int N // Required width
) (
    input  logic         clk,       // Clock
    input  logic         rst,       // Asynchronous reset
    input  logic         write_en,  // Write enable
    input  logic         flush,     // Synchronous flush (sets output to 0)
    input  logic [N-1:0] in,        // Input data
    output logic [N-1:0] out        // Output data
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= '0;             // Async reset to 0
        else if (write_en)
            out <= flush ? '0 : in;             // Normal update
    end

endmodule


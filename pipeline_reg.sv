// ------------------------------------------------------------------
// N-bit Pipeline Register Module
// Stores input data 'in' on the rising edge of 'clk'
// Writes only when 'write_en' is high; clears on async reset 'rst'
// Width must be specified during instantiation
// ------------------------------------------------------------------

module pipeline_reg #(
    parameter int N // No default value — required at instantiation
) (
    input  logic         clk,       // Clock
    input  logic         rst,       // Asynchronous Reset
    input  logic         write_en,  // Write enable
    input  logic [N-1:0] in,        // Input data
    output logic [N-1:0] out        // Output data
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= '0;             // Reset to 0
        else if (write_en)
            out <= in;             // Latch input to output
    end

endmodule

// ------------------------------------------------------------------
// N-bit Pipeline Register Module
// - Stores input 'in' into 'out' on rising edge of 'clk'
// - Reset is asynchronous (sets out = 0)
// - Flush is synchronous and clears output to 0 when asserted
// - Updates only when write_en is high
// ------------------------------------------------------------------
module pipeline_reg #(
    parameter int N = 32  // Width of the register
) (
    input  logic         clk,       // Clock
    input  logic         rst,       // Asynchronous reset
    input  logic         write_en,  // Write enable
    input  logic         flush,     // Synchronous flush
    input  logic [N-1:0] in,        // Data input
    output logic [N-1:0] out        // Data output
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= '0;
        else if (write_en)
            out <= flush ? '0 : in;
        // If write_en == 0, hold the current value
    end

endmodule


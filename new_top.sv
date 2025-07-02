module top (
    input logic clk,
    input logic rst,
);

typedef struct packed {
    logic [31:0] pc;           // Program Counter
    logic [31:0] instruction;  // Instruction fetched
    logic [1:0] bp_state; // Branch prediction state
    logic branch_taken;        // Branch taken flag
} if_id_reg_t;

if_id_reg_t if_id, if_id_nxt;

pipeline_reg #(.N($bits(if_id_reg_t))) if_id_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(write_if_id),
    .in(if_id_nxt),
    .out(if_id)
);

logic [31:0] pc, next_pc;
logic [31:0] instr;

// PC register
always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'h00000000; // Reset PC to 0
    else if (pc_write_en)
        pc <= next_pc;
end
logic branch_taken_prediction, 

// PC update logic 
assign next_pc = (branch_taken_prediction) ? branch_prediction_target : pc + 4;

// Instruction memory instantiation
instr_mem imem (
    .PCin        (pc),
    .rst         (rst),
    .instruction (instr)
);

branch_predictor bp (
    .clk               (clk),
    .rst               (rst),
    .pc_fetch          (pc),
    .update_en         (branch_update_en),
    .branch_taken      (branch_taken_actual),
    .resolved_pc       (if_id.pc),
    .resolved_target   (resolved_target),
    .resolved_state    (if_id.bp_state),
    .predicted_target  (branch_prediction_target),
    .prediction_taken  (branch_taken_prediction),
    .state             (if_id_nxt.branch_state)
);


endmodule
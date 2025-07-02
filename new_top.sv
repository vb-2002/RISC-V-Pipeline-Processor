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
    .write_en(),
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
    .instruction (if_id_nxt.instruction)
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
///////////////////


typedef struct packed {
    // Data signals
    logic [31:0] pc;           // PC of instruction
    logic [31:0] rs1_val;      // Value from source register 1
    logic [31:0] rs2_val;      // Value from source register 2
    logic [4:0]  rd;           // Destination register
    logic [31:0] imm;          // Sign-extended immediate
    logic [6:0]  opcode;       // Opcode (optional, if needed later)
    logic [2:0]  funct3;       // funct3 for ALU/branch decisions
    logic [6:0]  funct7;       // funct7 for ALU operations
    logic [4:0]  rs1;          // Register ID for forwarding
    logic [4:0]  rs2;          // Register ID for forwarding

    // Control signals
    logic [1:0]  ALUop;
    logic        ALUsrc;
    logic        MtoR;
    logic        regwrite;
    logic        memread;
    logic        memwrite;
    logic        branch;

    // Optional: forwarding and prediction info
    logic [1:0]  branch_state;        // For branch prediction FSM
    logic [31:0] predicted_target;    // Used in EX stage to verify prediction

} id_ex_reg_t;

id_ex_reg_t id_ex, id_ex_nxt;
pipeline_reg #(.N($bits(id_ex_reg_t))) id_ex_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(),
    .in(id_ex_nxt),
    .out(id_ex)
);

regfile regfile (
    .readregA (id_ex_nxt.rs1),
    .readregB (id_ex_nxt.rs2),
    .writereg (),
    .writedata (),
    .clk (clk),
    .rst (rst),
    .regwrite (regwrite)
    .readdataA (id_ex_nxt.rs1_val),
    .readdataB (id_ex_nxt.rs2_val)
);

assign id_ex_nxt.rs1 = if_id.instruction[19:15]; // rs1 field from instruction
assign id_ex_nxt.rs2 = if_id.instruction[24:20]; // rs2 field from instruction
assign id_ex_nxt.rd  = if_id.instruction[11:7];  // rd field

controlunit CU (
    .op        (id_ex_nxt.Opcode),
    .ALUop     (id_ex_nxt.ALUop),
    .ALUsrc    (id_ex_nxt.ALUsrc),
    .MtoR      (id_ex_nxt.MtoR),
    .regwrite  (id_ex_nxt.regwrite),
    .memread   (id_ex_nxt.memread),
    .memwrite  (id_ex_nxt.memwrite),
    .branch    (id_ex_nxt.branch)
);



endmodule
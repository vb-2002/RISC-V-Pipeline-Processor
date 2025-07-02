module top (
    input logic clk,
    input logic rst
);
//IF Stage
// ----------------------------------------
// IF/ID Pipeline Register Definition
// ----------------------------------------
typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instruction;
    logic [1:0]  bp_state;
    logic [31:0] predicted_target; // Target address predicted by branch predictor
} if_id_reg_t;

if_id_reg_t if_id, if_id_nxt;

pipeline_reg #(.N($bits(if_id_reg_t))) if_id_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(1'b1), // Assume always write for now
    .flush(flush),   
    .in(if_id_nxt),
    .out(if_id)
);

// ----------------------------------------
// Program Counter Logic
// ----------------------------------------
logic [31:0] pc, next_pc;
logic        branch_taken_prediction;
logic [31:0] branch_prediction_target;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'h00000000;
    else
        pc <= next_pc;
end

assign next_pc = flush ? resolved_target :
                 (branch_taken_prediction ? branch_prediction_target : pc + 4);

assign if_id_nxt.pc = pc;
assign if_id_nxt.predicted_target = branch_prediction_target;
// ----------------------------------------
// Instruction Memory
// ----------------------------------------
instr_mem instr_mem (
    .PCin(pc),
    .rst(rst),
    .instruction(if_id_nxt.instruction)
);

// ----------------------------------------
// Branch Predictor
// ----------------------------------------
logic branch_taken;
logic [31:0] resolved_target;

branch_predictor bp (
    .clk(clk),
    .rst(rst),
    .pc_fetch(pc),
    .update_en(id_ex_nxt.branch),
    .branch_taken(branch_taken),
    .resolved_pc(if_id.pc),
    .resolved_target(resolved_target),
    .resolved_state(if_id.bp_state),
    .predicted_target(branch_prediction_target),
    .prediction_taken(branch_taken_prediction),
    .state(if_id_nxt.bp_state)
);
// ID Stage
// ----------------------------------------
// ID/EX Pipeline Register Definition
// ----------------------------------------
typedef struct packed {
    logic [31:0] pc;
    logic [31:0] rs1_val;
    logic [31:0] rs2_val;
    logic [4:0]  rd;
    logic [31:0] imm;
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    logic [4:0]  rs1;
    logic [4:0]  rs2;

    logic [1:0]  ALUop;
    logic        ALUsrc;
    logic        MtoR;
    logic        regwrite;
    logic        memread;
    logic        memwrite;
    logic        branch;
} id_ex_reg_t;

id_ex_reg_t id_ex, id_ex_nxt;

pipeline_reg #(.N($bits(id_ex_reg_t))) id_ex_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(1'b1),
    .flush(flush), 
    .in(id_ex_nxt),
    .out(id_ex)
);
// ----------------------------------------
// Decode Stage Logic
// ----------------------------------------

assign id_ex_nxt.pc      = if_id.pc;
assign id_ex_nxt.opcode  = if_id.instruction[6:0];
assign id_ex_nxt.funct3  = if_id.instruction[14:12];
assign id_ex_nxt.funct7  = if_id.instruction[31:25];
assign id_ex_nxt.rs1     = if_id.instruction[19:15];
assign id_ex_nxt.rs2     = if_id.instruction[24:20];
assign id_ex_nxt.rd      = if_id.instruction[11:7];

// Immediate generation
imm_gen imm_gen (
    .out(id_ex_nxt.imm),
    .instr(if_id.instruction),
    .op(id_ex_nxt.opcode)
);

// Register File
logic [31:0] rs1_val, rs2_val;


regfile regfile (
    .readregA(id_ex_nxt.rs1),
    .readregB(id_ex_nxt.rs2),
    .writereg(mem_wb.rd),       
    .writedata(reg_write_data),     
    .clk(clk),
    .RegWrite(mem_wb.regwrite),       
    .readdataA(rs1_val),
    .readdataB(rs2_val)
);

assign id_ex_nxt.rs1_val = rs1_val;
assign id_ex_nxt.rs2_val = rs2_val;

// Control Unit
controlunit CU (
    .op(id_ex_nxt.opcode),
    .ALUop(id_ex_nxt.ALUop),
    .ALUsrc(id_ex_nxt.ALUsrc),
    .MtoR(id_ex_nxt.MtoR),
    .regwrite(id_ex_nxt.regwrite),
    .memread(id_ex_nxt.memread),
    .memwrite(id_ex_nxt.memwrite),
    .branch(id_ex_nxt.branch)
);

// ----------------------------------------
// Branch Resolution (in ID stage)
// ----------------------------------------
// Calculate the target address for branches
// This is done in ID stage to allow for branch prediction
// and to resolve branches early in the pipeline
// Correct target address
assign resolved_target = id_ex_nxt.pc + id_ex_nxt.imm;

// Branch taken condition (simple BEQ and BNE)
assign branch_taken = id_ex_nxt.branch && (
    (id_ex_nxt.funct3 == 3'b000 && (id_ex_nxt.rs1_val == id_ex_nxt.rs2_val)) ||  // BEQ
    (id_ex_nxt.funct3 == 3'b001 && (id_ex_nxt.rs1_val != id_ex_nxt.rs2_val))     // BNE
);

// Pipeline flush logic
logic flush;

// Flush condition: if branch was mispredicted
assign flush = id_ex_nxt.branch && (resolved_target != if_id.predicted_target);

// EX Stage ------------------------

logic [3:0] ALUcontrol;

ALUcontrol alu_control (
    .ALUop(id_ex.ALUop),
    .funct_3(id_ex.funct3),
    .funct_7(id_ex.funct7),
    .operation(ALUcontrol)
);

logic [31:0] ALU_B;
// ALU B input selection based on ALUsrc
// If ALUsrc is 1, use immediate value; otherwise, use rs2 value
assign ALU_B = id_ex.ALUsrc ? id_ex.imm : id_ex.rs2_val;

ALU alu (
    .A(id_ex.rs1_val),
    .B(ALU_B),
    .ALUcontrol(ALUcontrol),
    .result(ex_mem_nxt.alu_result),
    .zeroflag() //umused in this design
);

typedef struct packed {
    logic [31:0] alu_result;   // Result of ALU operation
    logic [31:0] rs2_val;      // Used for store (SW) operations
    logic [4:0]  rd;           // Destination register

    // Control signals needed in MEM and WB stages
    logic        MtoR;         // Memory to Register (load)
    logic        regwrite;     // Write enable for register file
    logic        memread;      // Enable memory read
    logic        memwrite;     // Enable memory write
} ex_mem_reg_t;

ex_mem_reg_t ex_mem, ex_mem_nxt;

pipeline_reg #(.N($bits(ex_mem_reg_t))) ex_mem_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(1'b1), // Assume always write for now
    .flush(1'b0),   
    .in(ex_mem_nxt),
    .out(ex_mem)
);

assign ex_mem_nxt.rs2_val = id_ex.rs2_val;
assign ex_mem_nxt.rd = id_ex.rd;
assign ex_mem_nxt.MtoR = id_ex.MtoR;
assign ex_mem_nxt.regwrite = id_ex.regwrite;
assign ex_mem_nxt.memread = id_ex.memread;
assign ex_mem_nxt.memwrite = id_ex.memwrite;

/// MEM Stage ------------------------

data_mem dmem_inst (
    .clk        (clk),
    .r_enable   (ex_mem.memread),
    .w_enable   (ex_mem.memwrite),
    .address    (ex_mem.alu_result),
    .wr_data    (ex_mem.rs2_val),
    .re_data    (mem_wb_nxt.mem_data)
);

typedef struct packed {
    logic [31:0] mem_data;     // Data read from memory (for loads)
    logic [31:0] alu_result;   // ALU result (used for stores or direct writes)
    logic [4:0]  rd;           // Destination register address

    // Control signals needed in WB stage
    logic        MtoR;         // Select memory or ALU result for write-back
    logic        regwrite;     // Register write enable
} mem_wb_reg_t;
mem_wb_reg_t mem_wb, mem_wb_nxt;

pipeline_reg #(.N($bits(mem_wb_reg_t))) mem_wb_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(1'b1), // Assume always write for now
    .flush(1'b0),   
    .in(mem_wb_nxt),
    .out(mem_wb)
);
//

assign mem_wb_nxt.alu_result = ex_mem.alu_result;
assign mem_wb_nxt.rd = ex_mem.rd;
assign mem_wb_nxt.MtoR = ex_mem.MtoR;
assign mem_wb_nxt.regwrite = ex_mem.regwrite;

// WB Stage ------------------------
logic [31:0] reg_write_data;

assign reg_write_data = mem_wb.MtoR ? mem_wb.mem_data : mem_wb.alu_result;

endmodule



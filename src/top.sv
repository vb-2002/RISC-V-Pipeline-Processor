module top (
    input logic clk,
    input logic rst
);

logic [31:0] pc, pc_nxt;
logic        branch_taken_prediction;
logic [31:0] branch_prediction_target;
logic flush_if_id,PCsrc;
logic PCWrite;
logic branch_taken_actual;
logic [31:0] branch_actual_target, pc_nxt_resolved;
logic flush_id_ex;
logic [31:0] rs1_val, rs2_val;
logic id_inst_branch; // Indicates if the current instruction in ID stage is a branch instruction
logic stall;
//IF Stage
// ----------------------------------------
// IF/ID Pipeline Register Definition
// ----------------------------------------
typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instruction;
    logic [1:0]  bp_state;
} if_id_reg_t;

if_id_reg_t if_id, if_id_nxt;

pipeline_reg #(.N($bits(if_id_reg_t))) if_id_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(~stall), // Assume always write for now
    .flush(flush_if_id), // Flush condition for IF/ID stage
    .in(if_id_nxt),
    .out(if_id)
);

// ----------------------------------------
// Program Counter Logic
// ----------------------------------------

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'h00000000;
    else if (PCWrite) // PCWriteEn is a control signal to enable PC update
        pc <= pc_nxt;
end

assign pc_nxt = PCsrc ? pc_nxt_resolved :
                 (branch_taken_prediction ? branch_prediction_target : pc + 4);

assign if_id_nxt.pc = pc;
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


branch_predictor bp (
    .clk(clk),
    .rst(rst),
    .pc_fetch(pc),
    .update_en(id_inst_branch),
    .branch_taken(branch_taken_actual),
    .resolved_pc(if_id.pc),
    .resolved_target(branch_actual_target),
    .resolved_state(if_id.bp_state),
    .predicted_target(branch_prediction_target),
    .branch_prediction(branch_taken_prediction),
    .state(if_id_nxt.bp_state)
);
// ID Stage


// ----------------------------------------
// ID/EX Pipeline Register Definition
// ----------------------------------------
typedef struct packed {
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
} id_ex_reg_t;

id_ex_reg_t id_ex, id_ex_nxt;

pipeline_reg #(.N($bits(id_ex_reg_t))) id_ex_pipe (
    .clk(clk),
    .rst(rst),
    .write_en(1'b1), // Write only if not stalled
    .flush(flush_id_ex), // Flush condition for ID/EX stage
    .in(id_ex_nxt),
    .out(id_ex)
);
assign flush_id_ex = stall;
// ----------------------------------------
// Decode Stage Logic
// ----------------------------------------

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
logic [31:0] reg_write_data;
// Register File
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
    .branch(id_inst_branch)
);

// Hazard Detection Unit
hzd_detection_unit hzd_unit (
    .if_id_rs1(id_ex_nxt.rs1),
    .if_id_rs2(id_ex_nxt.rs2),
    .id_ex_MemRead(id_ex.memread),
    .id_ex_rd(id_ex.rd),
    .id_ex_regwrite(id_ex.regwrite),
    .ex_mem_MemRead(ex_mem.memread),
    .ex_mem_rd(ex_mem.rd),
    .branch(id_inst_branch),
    .PCWrite(PCWrite),
    .stall(stall) // Stall signal to control pipeline flushing
);

logic [1:0] forward1, forward2;
logic [31:0] rs1_val_fwd, rs2_val_fwd;
// Data Forwarding Unit
// This unit checks if the rs1 or rs2 values need to be forwarded from EX/MEM or MEM/WB stages
// and sets the forward control signals accordingly
id_data_fwd_unit id_data_fwd_unit (
    .if_id_rs1(id_ex_nxt.rs1),
    .if_id_rs2(id_ex_nxt.rs2),
    .ex_mem_RegWrite(ex_mem.regwrite),
    .ex_mem_rd(ex_mem.rd),
    .mem_wb_RegWrite(mem_wb.regwrite),
    .mem_wb_rd(mem_wb.rd),
    .forward1(forward1), // Forward control for rs1
    .forward2(forward2)  // Forward control for rs2
);

always_comb begin
    // Forwarding logic for ALU A input
    case (forward1)
        2'b00: rs1_val_fwd = id_ex_nxt.rs1_val; // No forwarding
        2'b01: rs1_val_fwd = mem_wb.mem_data; // Forward from MEM/WB
        2'b10: rs1_val_fwd = ex_mem.alu_result; // Forward from EX/MEM
        default: rs1_val_fwd = id_ex.rs1_val; // Default case
    endcase

    // Forwarding logic for ALU B input
    case (forward1)
        2'b00: rs2_val_fwd = id_ex_nxt.rs2_val; // No forwarding
        2'b01: rs2_val_fwd = mem_wb.mem_data; // Forward from MEM/WB
        2'b10: rs2_val_fwd = ex_mem.alu_result; // Forward from EX/MEM
        default: rs2_val_fwd = id_ex.rs2_val;
    endcase
    
end

// ----------------------------------------
// Branch Resolution (in ID stage)
// ----------------------------------------
// Branch taken condition (simple BEQ and BNE)
assign branch_taken_actual = id_inst_branch && (
    (id_ex_nxt.funct3 == 3'b000 && (rs1_val_fwd == rs2_val_fwd)) ||  // BEQ
    (id_ex_nxt.funct3 == 3'b001 && (rs1_val_fwd != rs2_val_fwd))     // BNE
);

// Calculate the target address for branches
// This is done in ID stage to allow for branch prediction
// and to resolve branches early in the pipeline
// Correct target address
assign branch_actual_target = if_id.pc + id_ex_nxt.imm;
assign pc_nxt_resolved = branch_taken_actual ? branch_actual_target : if_id.pc + 4;

// Pipeline flush logic
// Flush condition: if branch was mispredicted
assign flush_if_id = id_inst_branch && (pc_nxt_resolved != pc);
assign PCsrc = flush_if_id;

// EX Stage ------------------------

logic [3:0] ALUcontrol;
logic [31:0] ALU_A;
logic [31:0] ALU_B,B;
logic [1:0] forwardA, forwardB; 

ALUcontrol alu_control (
    .ALUop(id_ex.ALUop),
    .funct_3(id_ex.funct3),
    .funct_7(id_ex.funct7),
    .operation(ALUcontrol)
);

ex_data_fwd_unit fwd_unit (
    .id_ex_rs1(id_ex.rs1),
    .id_ex_rs2(id_ex.rs2),
    .ex_mem_RegWrite(ex_mem.regwrite),
    .ex_mem_rd(ex_mem.rd),
    .mem_wb_RegWrite(mem_wb.regwrite),
    .mem_wb_rd(mem_wb.rd),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

always_comb begin
    // Forwarding logic for ALU A input
    case (forwardA)
        2'b00: ALU_A = id_ex.rs1_val; // No forwarding
        2'b01: ALU_A = mem_wb.mem_data; // Forward from MEM/WB
        2'b10: ALU_A = ex_mem.alu_result; // Forward from EX/MEM
        default: ALU_A = id_ex.rs1_val; // Default case
    endcase

    // Forwarding logic for ALU B input
    case (forwardB)
        2'b00: B = id_ex.rs2_val; // No forwarding
        2'b01: B = mem_wb.mem_data; // Forward from MEM/WB
        2'b10: B = ex_mem.alu_result; // Forward from EX/MEM
        default: B = id_ex.rs2_val; // Default case
    endcase
    
end

// ALU B input selection based on ALUsrc
// If ALUsrc is 1, use immediate value; otherwise, use rs2 value
assign ALU_B = id_ex.ALUsrc ? id_ex.imm : B;

ALU alu (
    .A(ALU_A),
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
    .write_en(1'b1), 
    .flush(1'b0),   
    .in(ex_mem_nxt),
    .out(ex_mem)
);

assign ex_mem_nxt.rs2_val = B;
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


assign reg_write_data = mem_wb.MtoR ? mem_wb.mem_data : mem_wb.alu_result;

endmodule



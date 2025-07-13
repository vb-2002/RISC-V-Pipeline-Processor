module top_tb;

    logic clk;
    logic rst;

    top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset
    initial begin
        rst = 1;
        #15;
        rst = 0;
    end

    // Simulation end
    initial begin
        #1000;
        $finish;
    end

    // -----------------------------
    // Flattened pipeline registers
    // -----------------------------

    // IF/ID
    logic [31:0] tb_if_id_pc;
    logic [31:0] tb_if_id_instr;
    logic [1:0]  tb_if_id_bp_state;

    logic [31:0] tb_if_id_nxt_pc;
    logic [31:0] tb_if_id_nxt_instr;
    logic [1:0]  tb_if_id_nxt_bp_state;

    // ID/EX
    logic [31:0] tb_id_ex_rs1_val;
    logic [31:0] tb_id_ex_rs2_val;
    logic [4:0]  tb_id_ex_rd;
    logic [31:0] tb_id_ex_imm;
    logic [6:0]  tb_id_ex_opcode;
    logic [2:0]  tb_id_ex_funct3;
    logic [6:0]  tb_id_ex_funct7;
    logic [4:0]  tb_id_ex_rs1;
    logic [4:0]  tb_id_ex_rs2;
    logic [1:0]  tb_id_ex_ALUop;
    logic        tb_id_ex_ALUsrc;
    logic        tb_id_ex_MtoR;
    logic        tb_id_ex_regwrite;
    logic        tb_id_ex_memread;
    logic        tb_id_ex_memwrite;

    logic [31:0] tb_id_ex_nxt_rs1_val;
    logic [31:0] tb_id_ex_nxt_rs2_val;
    logic [4:0]  tb_id_ex_nxt_rd;
    logic [31:0] tb_id_ex_nxt_imm;
    logic [6:0]  tb_id_ex_nxt_opcode;
    logic [2:0]  tb_id_ex_nxt_funct3;
    logic [6:0]  tb_id_ex_nxt_funct7;
    logic [4:0]  tb_id_ex_nxt_rs1;
    logic [4:0]  tb_id_ex_nxt_rs2;
    logic [1:0]  tb_id_ex_nxt_ALUop;
    logic        tb_id_ex_nxt_ALUsrc;
    logic        tb_id_ex_nxt_MtoR;
    logic        tb_id_ex_nxt_regwrite;
    logic        tb_id_ex_nxt_memread;
    logic        tb_id_ex_nxt_memwrite;

    // EX/MEM
    logic [31:0] tb_ex_mem_alu_result;
    logic [31:0] tb_ex_mem_rs2_val;
    logic [4:0]  tb_ex_mem_rd;
    logic        tb_ex_mem_MtoR;
    logic        tb_ex_mem_regwrite;
    logic        tb_ex_mem_memread;
    logic        tb_ex_mem_memwrite;

    logic [31:0] tb_ex_mem_nxt_alu_result;
    logic [31:0] tb_ex_mem_nxt_rs2_val;
    logic [4:0]  tb_ex_mem_nxt_rd;
    logic        tb_ex_mem_nxt_MtoR;
    logic        tb_ex_mem_nxt_regwrite;
    logic        tb_ex_mem_nxt_memread;
    logic        tb_ex_mem_nxt_memwrite;

    // MEM/WB
    logic [31:0] tb_mem_wb_mem_data;
    logic [31:0] tb_mem_wb_alu_result;
    logic [4:0]  tb_mem_wb_rd;
    logic        tb_mem_wb_MtoR;
    logic        tb_mem_wb_regwrite;

    logic [31:0] tb_mem_wb_nxt_mem_data;
    logic [31:0] tb_mem_wb_nxt_alu_result;
    logic [4:0]  tb_mem_wb_nxt_rd;
    logic        tb_mem_wb_nxt_MtoR;
    logic        tb_mem_wb_nxt_regwrite;

    // -----------------------------
    // Assigns from DUT structs
    // -----------------------------

    // IF/ID
    assign tb_if_id_pc         = uut.if_id.pc;
    assign tb_if_id_instr      = uut.if_id.instruction;
    assign tb_if_id_bp_state   = uut.if_id.bp_state;

    assign tb_if_id_nxt_pc       = uut.if_id_nxt.pc;
    assign tb_if_id_nxt_instr    = uut.if_id_nxt.instruction;
    assign tb_if_id_nxt_bp_state = uut.if_id_nxt.bp_state;

    // ID/EX
    assign tb_id_ex_rs1_val = uut.id_ex.rs1_val;
    assign tb_id_ex_rs2_val = uut.id_ex.rs2_val;
    assign tb_id_ex_rd      = uut.id_ex.rd;
    assign tb_id_ex_imm     = uut.id_ex.imm;
    assign tb_id_ex_opcode  = uut.id_ex.opcode;
    assign tb_id_ex_funct3  = uut.id_ex.funct3;
    assign tb_id_ex_funct7  = uut.id_ex.funct7;
    assign tb_id_ex_rs1     = uut.id_ex.rs1;
    assign tb_id_ex_rs2     = uut.id_ex.rs2;
    assign tb_id_ex_ALUop   = uut.id_ex.ALUop;
    assign tb_id_ex_ALUsrc  = uut.id_ex.ALUsrc;
    assign tb_id_ex_MtoR    = uut.id_ex.MtoR;
    assign tb_id_ex_regwrite= uut.id_ex.regwrite;
    assign tb_id_ex_memread = uut.id_ex.memread;
    assign tb_id_ex_memwrite= uut.id_ex.memwrite;

    assign tb_id_ex_nxt_rs1_val = uut.id_ex_nxt.rs1_val;
    assign tb_id_ex_nxt_rs2_val = uut.id_ex_nxt.rs2_val;
    assign tb_id_ex_nxt_rd      = uut.id_ex_nxt.rd;
    assign tb_id_ex_nxt_imm     = uut.id_ex_nxt.imm;
    assign tb_id_ex_nxt_opcode  = uut.id_ex_nxt.opcode;
    assign tb_id_ex_nxt_funct3  = uut.id_ex_nxt.funct3;
    assign tb_id_ex_nxt_funct7  = uut.id_ex_nxt.funct7;
    assign tb_id_ex_nxt_rs1     = uut.id_ex_nxt.rs1;
    assign tb_id_ex_nxt_rs2     = uut.id_ex_nxt.rs2;
    assign tb_id_ex_nxt_ALUop   = uut.id_ex_nxt.ALUop;
    assign tb_id_ex_nxt_ALUsrc  = uut.id_ex_nxt.ALUsrc;
    assign tb_id_ex_nxt_MtoR    = uut.id_ex_nxt.MtoR;
    assign tb_id_ex_nxt_regwrite= uut.id_ex_nxt.regwrite;
    assign tb_id_ex_nxt_memread = uut.id_ex_nxt.memread;
    assign tb_id_ex_nxt_memwrite= uut.id_ex_nxt.memwrite;

    // EX/MEM
    assign tb_ex_mem_alu_result = uut.ex_mem.alu_result;
    assign tb_ex_mem_rs2_val    = uut.ex_mem.rs2_val;
    assign tb_ex_mem_rd         = uut.ex_mem.rd;
    assign tb_ex_mem_MtoR       = uut.ex_mem.MtoR;
    assign tb_ex_mem_regwrite   = uut.ex_mem.regwrite;
    assign tb_ex_mem_memread    = uut.ex_mem.memread;
    assign tb_ex_mem_memwrite   = uut.ex_mem.memwrite;

    assign tb_ex_mem_nxt_alu_result = uut.ex_mem_nxt.alu_result;
    assign tb_ex_mem_nxt_rs2_val    = uut.ex_mem_nxt.rs2_val;
    assign tb_ex_mem_nxt_rd         = uut.ex_mem_nxt.rd;
    assign tb_ex_mem_nxt_MtoR       = uut.ex_mem_nxt.MtoR;
    assign tb_ex_mem_nxt_regwrite   = uut.ex_mem_nxt.regwrite;
    assign tb_ex_mem_nxt_memread    = uut.ex_mem_nxt.memread;
    assign tb_ex_mem_nxt_memwrite   = uut.ex_mem_nxt.memwrite;

    // MEM/WB
    assign tb_mem_wb_mem_data   = uut.mem_wb.mem_data;
    assign tb_mem_wb_alu_result= uut.mem_wb.alu_result;
    assign tb_mem_wb_rd        = uut.mem_wb.rd;
    assign tb_mem_wb_MtoR      = uut.mem_wb.MtoR;
    assign tb_mem_wb_regwrite  = uut.mem_wb.regwrite;

    assign tb_mem_wb_nxt_mem_data   = uut.mem_wb_nxt.mem_data;
    assign tb_mem_wb_nxt_alu_result= uut.mem_wb_nxt.alu_result;
    assign tb_mem_wb_nxt_rd        = uut.mem_wb_nxt.rd;
    assign tb_mem_wb_nxt_MtoR      = uut.mem_wb_nxt.MtoR;
    assign tb_mem_wb_nxt_regwrite  = uut.mem_wb_nxt.regwrite;

    // -----------------------------
    // FSDB Dump
    // -----------------------------
    initial begin
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars(0, top_tb.uut);
        $fsdbDumpvars(0, top_tb);
    end

endmodule

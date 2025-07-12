module top_tb;

    logic clk;
    logic rst;

    // Instantiate DUT
    top uut (
        .clk(clk),
        .rst(rst)
    );


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

    // -----------------------------------
    // Flattened Pipeline Register Signals
    // -----------------------------------

    // --- IF/ID ---
    logic [31:0] tb_if_id_pc         = uut.if_id.pc;
    logic [31:0] tb_if_id_instr      = uut.if_id.instruction;
    logic [1:0]  tb_if_id_bp_state   = uut.if_id.bp_state;

    logic [31:0] tb_if_id_nxt_pc       = uut.if_id_nxt.pc;
    logic [31:0] tb_if_id_nxt_instr    = uut.if_id_nxt.instruction;
    logic [1:0]  tb_if_id_nxt_bp_state = uut.if_id_nxt.bp_state;

    // --- ID/EX ---
    logic [31:0] tb_id_ex_rs1_val = uut.id_ex.rs1_val;
    logic [31:0] tb_id_ex_rs2_val = uut.id_ex.rs2_val;
    logic [4:0]  tb_id_ex_rd      = uut.id_ex.rd;
    logic [31:0] tb_id_ex_imm     = uut.id_ex.imm;
    logic [6:0]  tb_id_ex_opcode  = uut.id_ex.opcode;
    logic [2:0]  tb_id_ex_funct3  = uut.id_ex.funct3;
    logic [6:0]  tb_id_ex_funct7  = uut.id_ex.funct7;
    logic [4:0]  tb_id_ex_rs1     = uut.id_ex.rs1;
    logic [4:0]  tb_id_ex_rs2     = uut.id_ex.rs2;
    logic [1:0]  tb_id_ex_ALUop   = uut.id_ex.ALUop;
    logic        tb_id_ex_ALUsrc  = uut.id_ex.ALUsrc;
    logic        tb_id_ex_MtoR    = uut.id_ex.MtoR;
    logic        tb_id_ex_regwrite= uut.id_ex.regwrite;
    logic        tb_id_ex_memread = uut.id_ex.memread;
    logic        tb_id_ex_memwrite= uut.id_ex.memwrite;

    logic [31:0] tb_id_ex_nxt_rs1_val = uut.id_ex_nxt.rs1_val;
    logic [31:0] tb_id_ex_nxt_rs2_val = uut.id_ex_nxt.rs2_val;
    logic [4:0]  tb_id_ex_nxt_rd      = uut.id_ex_nxt.rd;
    logic [31:0] tb_id_ex_nxt_imm     = uut.id_ex_nxt.imm;
    logic [6:0]  tb_id_ex_nxt_opcode  = uut.id_ex_nxt.opcode;
    logic [2:0]  tb_id_ex_nxt_funct3  = uut.id_ex_nxt.funct3;
    logic [6:0]  tb_id_ex_nxt_funct7  = uut.id_ex_nxt.funct7;
    logic [4:0]  tb_id_ex_nxt_rs1     = uut.id_ex_nxt.rs1;
    logic [4:0]  tb_id_ex_nxt_rs2     = uut.id_ex_nxt.rs2;
    logic [1:0]  tb_id_ex_nxt_ALUop   = uut.id_ex_nxt.ALUop;
    logic        tb_id_ex_nxt_ALUsrc  = uut.id_ex_nxt.ALUsrc;
    logic        tb_id_ex_nxt_MtoR    = uut.id_ex_nxt.MtoR;
    logic        tb_id_ex_nxt_regwrite= uut.id_ex_nxt.regwrite;
    logic        tb_id_ex_nxt_memread = uut.id_ex_nxt.memread;
    logic        tb_id_ex_nxt_memwrite= uut.id_ex_nxt.memwrite;

    // --- EX/MEM ---
    logic [31:0] tb_ex_mem_alu_result = uut.ex_mem.alu_result;
    logic [31:0] tb_ex_mem_rs2_val    = uut.ex_mem.rs2_val;
    logic [4:0]  tb_ex_mem_rd         = uut.ex_mem.rd;
    logic        tb_ex_mem_MtoR       = uut.ex_mem.MtoR;
    logic        tb_ex_mem_regwrite   = uut.ex_mem.regwrite;
    logic        tb_ex_mem_memread    = uut.ex_mem.memread;
    logic        tb_ex_mem_memwrite   = uut.ex_mem.memwrite;

    logic [31:0] tb_ex_mem_nxt_alu_result = uut.ex_mem_nxt.alu_result;
    logic [31:0] tb_ex_mem_nxt_rs2_val    = uut.ex_mem_nxt.rs2_val;
    logic [4:0]  tb_ex_mem_nxt_rd         = uut.ex_mem_nxt.rd;
    logic        tb_ex_mem_nxt_MtoR       = uut.ex_mem_nxt.MtoR;
    logic        tb_ex_mem_nxt_regwrite   = uut.ex_mem_nxt.regwrite;
    logic        tb_ex_mem_nxt_memread    = uut.ex_mem_nxt.memread;
    logic        tb_ex_mem_nxt_memwrite   = uut.ex_mem_nxt.memwrite;

    // --- MEM/WB ---
    logic [31:0] tb_mem_wb_mem_data   = uut.mem_wb.mem_data;
    logic [31:0] tb_mem_wb_alu_result= uut.mem_wb.alu_result;
    logic [4:0]  tb_mem_wb_rd        = uut.mem_wb.rd;
    logic        tb_mem_wb_MtoR      = uut.mem_wb.MtoR;
    logic        tb_mem_wb_regwrite  = uut.mem_wb.regwrite;

    logic [31:0] tb_mem_wb_nxt_mem_data   = uut.mem_wb_nxt.mem_data;
    logic [31:0] tb_mem_wb_nxt_alu_result= uut.mem_wb_nxt.alu_result;
    logic [4:0]  tb_mem_wb_nxt_rd        = uut.mem_wb_nxt.rd;
    logic        tb_mem_wb_nxt_MtoR      = uut.mem_wb_nxt.MtoR;
    logic        tb_mem_wb_nxt_regwrite  = uut.mem_wb_nxt.regwrite;

    // -----------------------------
    // FSDB Dump
    // -----------------------------
    initial begin
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars(0, top_tb.uut);
        $fsdbDumpvars(0, top_tb);
    end

endmodule

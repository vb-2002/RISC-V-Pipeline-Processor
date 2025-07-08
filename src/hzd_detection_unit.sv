// ------------------------------------------------------
// Hazard Detection Unit
// - Detects load‑use and branch‑use hazards
// - Asserts `stall` and de‑asserts `PCWrite` to freeze IF/ID and PC
// ------------------------------------------------------
module hzd_detection_unit(
    input  logic [4:0] if_id_rs1,       // rs1 from IF/ID
    input  logic [4:0] if_id_rs2,       // rs2 from IF/ID
    input  logic       id_ex_MemRead,   // MemRead from ID/EX
    input  logic [4:0] id_ex_rd,        // rd from ID/EX
    input  logic       id_ex_regwrite,  // RegWrite from ID/EX
    input  logic       ex_mem_MemRead,  // MemRead from EX/MEM
    input  logic [4:0] ex_mem_rd,       // rd from EX/MEM
    input  logic       branch,          // Is current IF/ID instruction a branch?
    output logic       PCWrite,         // Enable updating the PC
    output logic       stall            // Insert a bubble (freeze IF/ID & ID/EX)
);

    always_comb begin
        // By default, no stall and PC proceeds
        stall   = 1'b0;
        PCWrite = 1'b1;

        // 1) Load‑use hazard (next instr needs data still loading):
        if (id_ex_MemRead &&
           ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            stall   = 1'b1;
            PCWrite = 1'b0;
        end

        // 2) Branch‑use hazard in ID stage:
        //    If the branch’s source regs depend on ANY prior instruction
        //    that writes to a reg (load or ALU), stall one cycle.
        else if (branch && id_ex_regwrite &&
                ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            stall   = 1'b1;
            PCWrite = 1'b0;
        end

        // 3) Also catch a load‑use one cycle later (EX/MEM stage)
        else if (branch && ex_mem_MemRead &&
                ((ex_mem_rd == if_id_rs1) || (ex_mem_rd == if_id_rs2))) begin
            stall   = 1'b1;
            PCWrite = 1'b0;
        end
    end

endmodule

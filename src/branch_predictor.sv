module branch_predictor (
    input  logic        clk,
    input  logic        rst,

    // Fetch stage
    input  logic [31:0] pc_fetch,

    // ID stage (resolved branch)
    input  logic        update_en,
    input  logic        branch_taken,
    input  logic [31:0] resolved_pc,
    input  logic [31:0] resolved_target,
    input  logic [1:0]  resolved_state,

    // Outputs to Fetch stage
    output logic [31:0] predicted_target,
    output logic        branch_prediction,
    output logic [1:0]  state
);

    // -------------------------------------
    // BTB Entry Struct Definition
    // -------------------------------------
    typedef struct packed {
        logic        valid;
        logic [24:0] tag;
        logic [31:0] target;
        logic [1:0]  fsm_state;
    } btb_entry_t;

    // -------------------------------------
    // BTB Declaration
    // -------------------------------------
    btb_entry_t btb [31:0];  // 32-entry BTB

    // -------------------------------------
    // Indexing and Tag Extraction
    // -------------------------------------
    logic [4:0]   fetch_index, update_index;
    logic [24:0]  fetch_tag, update_tag;

    assign fetch_index  = pc_fetch[6:2];
    assign fetch_tag    = pc_fetch[31:7];

    assign update_index = resolved_pc[6:2];
    assign update_tag   = resolved_pc[31:7];

    // -------------------------------------
    // Fetch Stage Lookup
    // -------------------------------------
    always_comb begin
        btb_entry_t entry = btb[fetch_index];

        if (entry.valid && (entry.tag == fetch_tag)) begin
            predicted_target  = entry.target;
            branch_prediction = (entry.fsm_state[1] == 1'b1);  // Taken if WEAK_T or STRONG_T
            state             = entry.fsm_state;
        end else begin
            predicted_target  = pc_fetch + 4;
            branch_prediction = 1'b0;
            state             = 2'b00;  // STRONG_NT
        end
    end

    // -------------------------------------
    // 2-bit FSM: Saturating Counter
    // -------------------------------------
    typedef enum logic [1:0] {
        STRONG_NT = 2'b00,
        WEAK_NT   = 2'b01,
        WEAK_T    = 2'b10,
        STRONG_T  = 2'b11
    } state_t;

    state_t next_state;

    always_comb begin
        unique case (resolved_state)
            STRONG_NT: next_state = branch_taken ? WEAK_NT  : STRONG_NT;
            WEAK_NT:   next_state = branch_taken ? STRONG_T : STRONG_NT;
            WEAK_T:    next_state = branch_taken ? STRONG_T : STRONG_NT;
            STRONG_T:  next_state = branch_taken ? STRONG_T : WEAK_T;
            default:   next_state = STRONG_NT;
        endcase
    end

    // -------------------------------------
    // BTB Update Logic
    // -------------------------------------
    btb_entry_t new_entry;

    always_comb begin 
            new_entry.valid     = 1'b1;
            new_entry.tag       = update_tag;
            new_entry.target    = resolved_target;
            new_entry.fsm_state = next_state;
        end
    

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                btb[i] <= '0;
            end
        end else if (update_en) begin
            btb[update_index]   <= new_entry;
        end
    end

endmodule

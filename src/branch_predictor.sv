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
    output logic        prediction_taken,
    output logic [1:0]  state
);

    // -------------------------------------
    // Indexing and Tag Extraction (Word-Aligned)
    // -------------------------------------
    logic [4:0]   fetch_index, update_index;   // 32-entry BTB → 5-bit index
    logic [24:0]  fetch_tag, update_tag;       // 25-bit tag = PC[31:7]

    assign fetch_index  = pc_fetch[6:2];
    assign fetch_tag    = pc_fetch[31:7];

    assign update_index = resolved_pc[6:2];
    assign update_tag   = resolved_pc[31:7];

    // -------------------------------------
    // BTB Entry Format (61 bits):
    // [60]     = valid bit
    // [59:35]  = tag (25 bits)
    // [34:3]   = target address
    // [2:1]    = FSM state
    // -------------------------------------
    logic [60:0] btb [31:0];  // 32 entries, each 61 bits wide

    // Read signals for Fetch stage
    logic        entry_valid;
    logic [24:0] entry_tag;
    logic [31:0] entry_target;
    logic [1:0]  entry_state;

    // -------------------------------------
    // Fetch Stage Lookup
    // -------------------------------------
    always_comb begin
        entry_valid  = btb[fetch_index][60];
        entry_tag    = btb[fetch_index][59:35];
        entry_target = btb[fetch_index][34:3];
        state        = btb[fetch_index][2:1];

        if (entry_valid && (entry_tag == fetch_tag)) begin
            predicted_target = entry_target;
            prediction_taken = (state[1] == 1'b1);  // Taken if WEAK_T or STRONG_T
        end else begin
            predicted_target = pc_fetch + 4;
            prediction_taken = 1'b0;
            state            = 2'b00;  // STRONG_NT default
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
    // Update BTB on Branch Resolution (ID stage)
    // -------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                btb[i] <= 61'd0;
            end
        end else if (update_en) begin
            btb[update_index] <= {1'b1, update_tag, resolved_target, next_state};
        end
    end

endmodule

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
    input  logic [1:0]  resolved_state,   // FSM state of resolved instruction (from ID stage)

    // Outputs to Fetch stage
    output logic [31:0] predicted_target,
    output logic        prediction_taken,
    output logic [1:0]  state              // FSM state for pc_fetch
);

    // Indexing (using lower 5 bits of PC)
    logic [4:0] fetch_index;
    logic [4:0] update_index;

    assign fetch_index  = pc_fetch[4:0];
    assign update_index = resolved_pc[4:0];

    // Branch Target Buffer (BTB)
    // [34:3] = target address (32b), [2:1] = FSM state, [0] = prediction bit
    logic [34:0] btb [0:31];

    // -------------------------------------
    // READ Prediction for Fetch stage
    // -------------------------------------
    always_comb begin
        {predicted_target, state, prediction_taken} = btb[fetch_index];
    end

    // -------------------------------------
    // FSM transition for resolved branch (ID stage)
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
    // Update BTB on branch resolution
    // -------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                btb[i] <= 35'd0;
            end
        end else if (update_en) begin
            btb[update_index] <= {resolved_target, next_state, branch_taken};
        end
    end

endmodule

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

    // Indexing
    logic [4:0] fetch_index, update_index;
    logic [26:0] fetch_tag, update_tag;

    assign fetch_index  = pc_fetch[4:0];
    assign fetch_tag    = pc_fetch[31:5];

    assign update_index = resolved_pc[4:0];
    assign update_tag   = resolved_pc[31:5];

    // BTB entry format (64 bits):
    // [63]     = valid
    // [62:36]  = tag (PC[31:5])
    // [35:4]   = target address
    // [3:2]    = FSM state
    // [1:0]    = prediction bit (taken)
    logic [63:0] btb [0:31];

    // Read signals
    logic        entry_valid;
    logic [26:0] entry_tag;
    logic [31:0] entry_target;
    logic [1:0]  entry_state;
    logic        entry_pred;

    // -------------------------
    // Fetch stage lookup
    // -------------------------
    always_comb begin
        entry_valid  = btb[fetch_index][63];
        entry_tag    = btb[fetch_index][62:36];
        entry_target = btb[fetch_index][35:4];
        state        = btb[fetch_index][3:2];
        entry_pred   = btb[fetch_index][0];

        if (entry_valid && (entry_tag == fetch_tag)) begin
            predicted_target = entry_target;
            prediction_taken = entry_pred;
        end else begin
            predicted_target = pc_fetch + 4;
            prediction_taken = 1'b0;
            state            = 2'b00;
        end
    end

    // -------------------------
    // FSM transition
    // -------------------------
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

    // -------------------------
    // ID stage update
    // -------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                btb[i] <= 64'd0;
            end
        end else if (update_en) begin
            btb[update_index] <= {1'b1, update_tag, resolved_target, next_state, branch_taken};
        end
    end

endmodule

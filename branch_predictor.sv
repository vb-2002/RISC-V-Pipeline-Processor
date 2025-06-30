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

module bp_FSM (
    input  logic       b_res,        // Actual branch outcome (1 if taken)
    input  logic       clk,
    input  logic       rst,
    output logic [1:0] op_state,     // Encoded FSM state
    output logic       pred          // Branch prediction (1 if predicted taken)
);

    typedef enum logic [1:0] {
        STRONG_NT = 2'b00,
        WEAK_NT   = 2'b01,
        WEAK_T    = 2'b10,
        STRONG_T  = 2'b11
    } state_t;

    state_t curr, next;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            curr <= STRONG_NT;
        else
            curr <= next;
    end

    // Next state logic and prediction (Moore: pred based on current state)
    always_comb begin
        case (curr)
            STRONG_NT: begin
                pred = 1'b0;
                next = (b_res) ? WEAK_NT : STRONG_NT;
            end
            WEAK_NT: begin
                pred = 1'b0;
                next = (b_res) ? STRONG_T : STRONG_NT;
            end
            WEAK_T: begin
                pred = 1'b1;
                next = (b_res) ? STRONG_T : STRONG_NT;
            end
            STRONG_T: begin
                pred = 1'b1;
                next = (b_res) ? STRONG_T : WEAK_T;
            end
            default: begin
                pred = 1'b0;
                next = STRONG_NT;
            end
        endcase

        op_state = curr;
    end

endmodule

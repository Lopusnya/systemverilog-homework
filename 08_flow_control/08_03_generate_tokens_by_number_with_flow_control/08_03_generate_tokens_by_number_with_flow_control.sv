//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module generate_tokens_by_number_with_flow_control
#(
    WIDTH = 4
)
(
    input                        clk,
    input                        rst,

    input   logic                up_valid,
    output  logic                up_ready,
    input   logic [WIDTH-1 : 0]  n_tokens,

    output  logic                down_valid,
    input   logic                down_ready,
    output  logic                down_token
);

    // Task:
    // Implement a module that recive an integer N_tokens and generate N_tokens pulses. The module must use signals valid-ready for
    // transfer tokens.

    logic [WIDTH-1:0] count;
    
    typedef enum logic 
    {
        IDLE, 
        GEN
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            count    <= '0;
            up_ready <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    if (up_valid && up_ready) begin
                        if (n_tokens == 0) begin
                            state    <= IDLE;
                            up_ready <= 1'b1;
                        end else begin
                            count    <= n_tokens;
                            state    <= GEN;
                            up_ready <= 1'b0; 
                        end
                    end
                end

                GEN: begin
                    if (down_valid && down_ready) begin
                        if (count == 1) begin
                            state    <= IDLE;
                            up_ready <= 1'b1;
                            count    <= '0;
                        end else begin
                            count    <= count - 1'b1;
                        end
                    end
                end
            endcase
        end
    end


    assign down_token = (state == GEN);
    assign down_valid = (state == GEN);


endmodule


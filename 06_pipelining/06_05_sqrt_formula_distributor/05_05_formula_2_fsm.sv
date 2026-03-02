//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0]
    {
        start_state = 3'd0,
        wait_c = 3'd1,
        wait_sum_b_c = 3'd2,
        wait_b_c = 3'd3,
        wait_sum_a_b_c = 3'd4,
        wait_a_b_c = 3'd5
        // data_out = 3'd6
    }
    state, next_state;

    always_ff @( posedge clk ) 
        if(rst)
            state <= start_state;
        else
            state <= next_state;

    always_comb 
    begin

        next_state = state;
        isqrt_x_vld = '0;
        isqrt_x = 'x;

        case (state)
            start_state:
                begin
                    isqrt_x = c;

                    if(arg_vld)
                        begin
                            isqrt_x_vld = '1;
                            next_state = wait_c;
                        end   
                end

            wait_c:
                begin
                    if(isqrt_y_vld)
                        next_state = wait_sum_b_c;
                end

            wait_sum_b_c:
                begin
                    isqrt_x = b + res;
                    if(sub_sum_vld)
                        begin
                            isqrt_x_vld = '1;
                            next_state = wait_b_c;
                        end 
                end

            wait_b_c:
                begin
                    if(isqrt_y_vld)
                        next_state = wait_sum_a_b_c;
                end

            wait_sum_a_b_c:
                begin
                    isqrt_x = a + res;
                    if(sub_sum_vld)
                        begin
                            isqrt_x_vld = '1;
                            next_state = wait_a_b_c;
                        end
                end

            wait_a_b_c:
                begin
                    if(isqrt_y_vld)
                        next_state = start_state;
                end
        endcase   
    end

    logic sub_sum_vld;
    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state == wait_a_b_c & isqrt_y_vld);

    always_ff @ (posedge clk)
        if (state == start_state)
            res <= '0;
        else if (isqrt_y_vld && state == wait_c)
            begin
                res <= 32' (isqrt_y);
                sub_sum_vld <= '1;
            end
        else if (isqrt_y_vld && state == wait_b_c)
            begin
                res <= 32' (isqrt_y);
                sub_sum_vld <= '1;
            end
        else if (isqrt_y_vld && state == wait_a_b_c)
            begin
                res <= 32' (isqrt_y);
                sub_sum_vld <= '0;
            end


endmodule

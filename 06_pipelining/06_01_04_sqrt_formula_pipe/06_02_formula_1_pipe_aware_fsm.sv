//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    enum logic [1:0]
    {
        IDLE    = 2'b00,
        INPUT_B = 2'b01,
        INPUT_C = 2'b10
    }
     state, next_state;

    //Next state logic ff
    always_ff @( posedge clk )
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    
    always_comb 
    begin
        next_state = state;
        isqrt_x_vld = 'x;
        isqrt_x = 'x;

        case (state)
            IDLE    :
            begin
                isqrt_x = a;
                
                if(arg_vld)
                    begin
                        next_state = INPUT_B;
                        isqrt_x_vld = '1;
                    end
            end
            INPUT_B :
            begin
                isqrt_x = b;
                isqrt_x_vld = '1;
                next_state = INPUT_C;
            end
            
            INPUT_C : 
            begin
                isqrt_x = c;
                isqrt_x_vld = '1;
                next_state = IDLE;
            end
        endcase
    end

    logic [31:0] isqrt_sum_reg;
    always_ff @(posedge clk)
        if (rst)
            isqrt_sum_reg <= '0;
        else
            if (isqrt_y_vld)
                isqrt_sum_reg <= 32'(isqrt_y) + isqrt_sum_reg;
            else
                isqrt_sum_reg <= '0;

    logic [1:0] cnt_vld;
    always_ff @(posedge clk)
        if (rst)
            cnt_vld <= '0;
        else
            if(isqrt_y_vld)
                cnt_vld <= cnt_vld + 2'b1;
            else
                cnt_vld <= '0;
    
    assign res = isqrt_sum_reg;
    assign res_vld = (cnt_vld == 2'd3);

endmodule

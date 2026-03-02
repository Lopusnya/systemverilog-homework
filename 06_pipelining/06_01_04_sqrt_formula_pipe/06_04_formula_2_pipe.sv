//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res

);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    localparam N = 3;

    logic [15:0] isqrt_y_1, isqrt_y_2, isqrt_y_3;
    logic y_vld_1, y_vld_2, y_vld_3;

    isqrt # (.n_pipe_stages (N)) isqrt_1
    (
        .clk   ( clk         ),
        .rst   ( rst         ),
        .x_vld ( arg_vld     ),
        .x     ( c           ),
        .y_vld ( y_vld_1     ),
        .y     ( isqrt_y_1   )
    );

    isqrt # (.n_pipe_stages (N)) isqrt_2
    (
        .clk   ( clk         ),
        .rst   ( rst         ),
        .x_vld ( y_vld_1_reg ),
        .x     ( sum_b_c     ),
        .y_vld ( y_vld_2     ),
        .y     ( isqrt_y_2   )
    );

    isqrt # (.n_pipe_stages (N)) isqrt_3
    (
        .clk   ( clk         ),
        .rst   ( rst         ),
        .x_vld ( y_vld_2_reg ),
        .x     ( sum_a_b_c   ),
        .y_vld ( y_vld_3     ),
        .y     ( isqrt_y_3   )
    );

    logic [31:0] shift_b [0:N-1];
    logic [31:0] shift_a [0:2*N];

    always_ff @ (posedge clk)
        begin
            shift_b[0] <= (arg_vld) ? b : shift_b[0];
            
            for (int i = 0; i < (N - 1); i ++)
                shift_b [i+1] <= (data_vld_b[i]) ? shift_b [i] : shift_b[i+1];

        end

    logic [N - 1:0] data_vld_b;
    always_ff @(posedge clk)
    begin   
        if(rst)
            data_vld_b <= '0;
        else    
            data_vld_b <= {data_vld_b[N - 2: 0], arg_vld};
    end

    always_ff @ (posedge clk)
        begin
            shift_a[0] <= (arg_vld) ? a : shift_a[0];
            
            for (int i = 0; i < (2*N); i ++)
                shift_a [i+1] <= (data_vld_a[i]) ? shift_a [i] : shift_a[i+1];

        end

    logic [2*N:0] data_vld_a;
    always_ff @(posedge clk)
    begin   
        if(rst)
            data_vld_a <= '0;
        else    
            data_vld_a <= {data_vld_a[2*N - 1: 0], arg_vld};
    end

    logic y_vld_1_reg, y_vld_2_reg;

    always_ff @(posedge clk)
        if(rst)
            y_vld_1_reg <= '0;
        else    
            y_vld_1_reg <= y_vld_1;
    
    always_ff @(posedge clk)
        if(rst)
            y_vld_2_reg <= '0;
        else    
            y_vld_2_reg <= y_vld_2;
    
    logic [31:0] sum_b_c, sum_a_b_c;

    always_ff @(posedge clk)
        if(y_vld_1)
            sum_b_c <= 32'(isqrt_y_1) + shift_b[N-1];
        else 
            sum_b_c <= '0;
    
    always_ff @(posedge clk)
        if(y_vld_2)
            sum_a_b_c <= 32'(isqrt_y_2) + shift_a[2*N];
        else 
            sum_a_b_c <= '0;

    logic res_vld_reg;
    always_ff @(posedge clk)
        if(rst)
            res_vld_reg <= '0;
        else    
            res_vld_reg <= y_vld_3;
    
    logic [31:0] res_reg;
    always_ff @(posedge clk)
        if(y_vld_3)  
            res_reg <= isqrt_y_3;

    assign res = res_reg;
    assign res_vld = res_vld_reg;

    //Debug signals
    // logic [31:0] b_shift, a_shift;
    // assign b_shift = shift_b[0];
    // assign a_shift = shift_a[0];

endmodule

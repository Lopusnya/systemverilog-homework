//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_circular
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
    // Implement a pipelined module formula_2_pipe_using_circular
    // that computes the result of the formula defined in the file formula_2_fn.svh.
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
    // 3. Your solution should use circular buffers instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    localparam N = 4;

    wire [15: 0] isqrt_y_1, isqrt_y_2, isqrt_y_3;
    wire isqrt_y_1_vld, isqrt_y_2_vld, isqrt_y_3_vld;

    wire [31:0] buffer_out_n, buffer_out_2n;

    isqrt #(.n_pipe_stages(N)) i_1 
    (
        .clk  (          clk),
        .rst  (          rst),
        .x_vld(      arg_vld),
        .x    (            c),
        .y_vld(isqrt_y_1_vld),
        .y    (    isqrt_y_1)
    );

    isqrt #(.n_pipe_stages(N)) i_2 
    (
        .clk  (          clk),
        .rst  (          rst),
        .x_vld(     vld_r_1 ),
        .x    (     data_r_1),
        .y_vld(isqrt_y_2_vld),
        .y    (    isqrt_y_2)
    );

    isqrt #(.n_pipe_stages(N)) i_3 
    (
        .clk  (          clk),
        .rst  (          rst),
        .x_vld(      vld_r_2),
        .x    (     data_r_2),
        .y_vld(isqrt_y_3_vld),
        .y    (    isqrt_y_3)
    );

    circular_buffer_with_valid #(.depth(N), .width(32))buffer_n
    (
        .clk      (         clk),
        .rst      (         rst),
        .in_valid (     arg_vld),
        .in_data  (           b),
        // .out_valid(          ),
        .out_data (buffer_out_n)
    );

    circular_buffer_with_valid #(.depth(2*N + 1), .width(32))buffer_2n
    (
        .clk      (          clk),
        .rst      (          rst),
        .in_valid (      arg_vld),
        .in_data  (            a),
        // .out_valid(           ),
        .out_data (buffer_out_2n)
    );

    logic vld_r_1, vld_r_2;
    always_ff @( posedge clk ) begin : vld_reg_i1_to_i2
        if(rst)
            vld_r_1 <= '0;
        else
            vld_r_1 <= isqrt_y_1_vld;
    end

    always_ff @( posedge clk ) begin : vld_reg_i2_to_i3
        if(rst)
            vld_r_2 <= '0;
        else
            vld_r_2 <= isqrt_y_2_vld;
    end

    logic [31: 0] data_r_1, data_r_2;
    always_ff @( posedge clk ) begin : data_reg_i1_to_i2
        if (isqrt_y_1_vld)
            data_r_1 <= 32'(isqrt_y_1) + buffer_out_n;
    end

    always_ff @( posedge clk ) begin : data_reg_i2_to_i3
        if (isqrt_y_2_vld)
            data_r_2 <= 32'(isqrt_y_2) + buffer_out_2n;
    end

    assign res_vld = isqrt_y_3_vld;
    assign res = 32'(isqrt_y_3);

endmodule

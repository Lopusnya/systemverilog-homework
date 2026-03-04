//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
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
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
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
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 06_04_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    localparam N = 32;

    wire [15: 0] isqrt_y_1, isqrt_y_2, isqrt_y_3;
    wire isqrt_y_1_vld, isqrt_y_2_vld, isqrt_y_3_vld;

    wire [31:0] buffer_out_n, buffer_out_2n;
    wire full_n, full_2n, empty_n, empty_2n;

    wire push_n  = arg_vld && ~full_n ;
    wire push_2n = arg_vld && ~full_2n;

    wire pop_n  = isqrt_y_1_vld && ~empty_n ;
    wire pop_2n = isqrt_y_2_vld && ~empty_2n;

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

    flip_flop_fifo_with_counter #(.depth(N), .width(32))buffer_n
    (
        .clk          (          clk),
        .rst          (          rst),
        .push         (       push_n),
        .write_data   (            b),
        .pop          (        pop_n),
        .read_data    ( buffer_out_n),
        .full         (       full_n),
        .empty        (      empty_n)
    );

    flip_flop_fifo_with_counter #(.depth(2*N + 1), .width(32))buffer_2n
    (
        .clk          (          clk),
        .rst          (          rst),
        .push         (      push_2n),
        .write_data   (            a),
        .pop          (       pop_2n),
        .read_data    (buffer_out_2n),
        .full         (      full_2n),
        .empty        (     empty_2n)
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

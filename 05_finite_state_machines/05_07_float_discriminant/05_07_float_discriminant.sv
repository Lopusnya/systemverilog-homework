//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    logic [FLEN - 1:0] res_ac, res_4ac, res_bb;
    logic vld_bb, vld_ac, vld_4ac;
    logic [3:0] error_w, busy_w;

    f_mult mult_1 (.a(b),      .b(b),       .clk(clk), .rst(rst), .up_valid(arg_vld),          .res(res_bb),  .down_valid(vld_bb),  .busy(busy_w [0]), .error(error_w [0]));
 
    f_mult mult_2 (.a(a),      .b(c),       .clk(clk), .rst(rst), .up_valid(arg_vld),          .res(res_ac),  .down_valid(vld_ac),  .busy(busy_w [1]), .error(error_w [1]));

    f_mult mult_3 (.a(four),   .b(res_ac),  .clk(clk), .rst(rst), .up_valid(vld_ac),           .res(res_4ac), .down_valid(vld_4ac), .busy(busy_w [2]), .error(error_w [2]));

    f_sub  sub    (.a(res_bb), .b(res_4ac), .clk(clk), .rst(rst), .up_valid(vld_4ac & bb_reg), .res(res),     .down_valid(res_vld), .busy(busy_w [3]), .error(error_w [3]));

    assign busy = (|busy_w );
    assign err  = (|error_w);

    logic bb_reg;
    always_ff @( posedge clk ) 
        if (rst)
            bb_reg <= '0;
        else
            if (vld_bb)
                bb_reg <= vld_bb;


endmodule

module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam N = 10;

    logic [N-1:0] select_shift;
    always_ff @(posedge clk) begin
        if (rst)
            select_shift <= {{(N-2){1'b0}},1'b1};
        else
            select_shift <= {select_shift[N-2:0],select_shift[N - 1]};
    end

    logic [N-1:0] discr_res_vld ;
    logic [N-1:0] discr_negative;
    logic [N-1:0] discr_busy    ;
    logic [N-1:0] discr_err     ;
    logic [N-1:0] reg_valid     ;
    
    logic [FLEN - 1:0] discr_res [N];
    logic [FLEN - 1:0] reg_a     [N];
    logic [FLEN - 1:0] reg_b     [N];
    logic [FLEN - 1:0] reg_c     [N];

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_calc

            always_ff @( posedge clk) begin
              if(rst) begin
                reg_valid[i] <= 1'b0;
              end else begin
                reg_valid[i] <= (arg_vld && select_shift[i]);
              end
            end 

            always_ff @(posedge clk) begin
                if (rst)
                    reg_a[i] <= '0;
                else 
                    if (arg_vld && select_shift[i]) 
                        reg_a[i] <= a;
            end

            always_ff @(posedge clk) begin
                if (rst)
                    reg_b[i] <= '0;
                else 
                    if (arg_vld && select_shift[i]) 
                        reg_b[i] <= b;
            end

            always_ff @(posedge clk) begin
                if (rst)
                    reg_c[i] <= '0;
                else 
                    if (arg_vld && select_shift[i]) 
                        reg_c[i] <= c;
            end

            float_discriminant discr
            (
                .clk(clk),
                .rst(rst), 
                .arg_vld(reg_valid[i]), 
                .a(reg_a[i]), 
                .b(reg_b[i]), 
                .c(reg_c[i]), 
                .res_vld(discr_res_vld[i]), 
                .res(discr_res[i]),
                .res_negative(discr_negative[i]),
                .err(discr_err[i]),
                .busy(discr_busy[i])
            );

        end
    endgenerate

    always_comb begin
        res = '0;
        for(int unsigned i = 0; i < N; i++) begin
            if(discr_res_vld[i]) begin
            res = discr_res[i];
            end
        end
    end
    assign res_vld      = |discr_res_vld ;
    assign res_negative = |discr_negative;
    assign busy         = |discr_busy    ;
    assign err          = |discr_err     ;

endmodule

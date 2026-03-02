module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input  logic        clk,
    input  logic        rst,

    input  logic        arg_vld,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

localparam N = 64; 

    logic [$clog2(N)-1:0] cnt_in;

    always_ff @(posedge clk) begin
        if (rst)
            cnt_in <= '0;
        else 
            if (arg_vld) 
                cnt_in <= cnt_in + 1'b1;
    end

    logic [N-1:0] inst_vld    ;
    logic [N-1:0] inst_res_vld;
    logic [31:0 ] inst_res [N];

    logic [31:0 ] reg_a    [N];
    logic [31:0 ] reg_b    [N];
    logic [31:0 ] reg_c    [N];
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_calc

            always_ff @( posedge clk) begin
              if(rst) begin
                inst_vld[i] <= 1'b0;
              end else begin
                inst_vld[i] <= (arg_vld && (cnt_in == i));
              end
            end 

            always_ff @(posedge clk) begin
                if (rst)
                    reg_a[i] <= '0;
                else 
                    if (arg_vld && (cnt_in == i)) 
                        reg_a[i] <= a;
            end

            always_ff @(posedge clk) begin
                if (rst)
                    reg_b[i] <= '0;
                else 
                    if (arg_vld && (cnt_in == i)) 
                        reg_b[i] <= b;
            end

            always_ff @(posedge clk) begin
                if (rst)
                    reg_c[i] <= '0;
                else 
                    if (arg_vld && (cnt_in == i)) 
                        reg_c[i] <= c;
            end

            if (formula == 1) begin : f1
                if (impl == 1) begin : f1_i1

                    formula_1_impl_1_top inst 
                    (
                        .clk(clk),
                        .rst(rst), 
                        .arg_vld(inst_vld[i]), 
                        .a(reg_a[i]), 
                        .b(reg_b[i]), 
                        .c(reg_c[i]), 
                        .res_vld(inst_res_vld[i]), 
                        .res(inst_res[i])
                    );

                end else begin : f1_i2
                    formula_1_impl_2_top inst 
                    (
                        .clk(clk), 
                        .rst(rst), 
                        .arg_vld(inst_vld[i]), 
                        .a(reg_a[i]), 
                        .b(reg_b[i]), 
                        .c(reg_c[i]), 
                        .res_vld(inst_res_vld[i]), 
                        .res(inst_res[i])
                    );
                end
            end else begin : f2
                formula_2_top inst 
                (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(inst_vld[i]),
                    .a(reg_a[i]), 
                    .b(reg_b[i]), 
                    .c(reg_c[i]), 
                    .res_vld(inst_res_vld[i]), 
                    .res(inst_res[i])
                );
            end
        end
    endgenerate

    always_comb begin
        res = '0;
        for(int unsigned i = 0; i < N; i++) begin
            if(inst_res_vld[i]) begin
            res = inst_res[i];
            end
        end
    end
    assign res_vld = |inst_res_vld;
    
endmodule
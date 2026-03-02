module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output logic                      down_vld,
    output logic [ width   - 1 : 0  ] down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    parameter DEPTH = 8;

    logic [ width   - 1 : 0  ]data_out;
    logic [ n_inputs - 1:  0 ] round_index;
    logic [ n_inputs - 1 : 0 ] vld_line_out;
    logic [ n_inputs-1:0][width-1:0] reg_data [DEPTH]; 
    logic [ n_inputs-1:0] index_line_data_ready [DEPTH];
    logic [ n_inputs-1:0] rdy [DEPTH];
    

    // Round index, choose channel data
    always_ff @( posedge clk ) begin : block_index_round
        if (rst) begin
            round_index <= {{(n_inputs-2){1'b0}},1'b1};
        end else if (down_vld) begin
            round_index <= {round_index[n_inputs - 2: 0],round_index[n_inputs - 1]};
        end
    end

    genvar i;
    generate
        for (i = 0; i < n_inputs; i++) begin

            always_ff @(posedge clk) begin
                if (rst) begin
                    for (int j = 0; j < DEPTH; j++) begin
                        rdy[j][i] <= 1'b0;
                    end
                end else begin
                    if (up_vlds[i]) begin
                        reg_data[0][i] <= up_data[i];
                        rdy[0][i]      <= 1'b1;
                    end

                    for (int j = 1; j < DEPTH; j++) begin
                        if (rdy[j-1][i] && !rdy[j][i]) begin
                            reg_data[j][i] <= reg_data[j-1][i];
                            rdy[j][i]      <= 1'b1;
                            rdy[j-1][i]    <= 1'b0;
                        end
                    end

                    if (round_index[i] && rdy[DEPTH-1][i] && down_vld) begin
                        rdy[DEPTH-1][i] <= 1'b0;
                    end
                end
            end
                
            assign vld_line_out[i] = rdy[DEPTH-1][i];
        end
    endgenerate

    always_comb begin
        down_vld = 1'b0;
        down_data = '0;
        for (int k = 0; k < n_inputs; k++) begin
            if (round_index[k] && vld_line_out[k]) begin
                down_vld = 1'b1;
                down_data = reg_data[DEPTH-1][k];
            end
        end
    end

endmodule

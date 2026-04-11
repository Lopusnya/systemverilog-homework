//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens_with_flow_control
(
    input  clk,
    input  rst,

    input  logic up_valid,
    output logic up_ready,
    input  logic up_token,

    output logic down_valid,
    input  logic down_ready,
    output logic down_data
);

  // Task:
  // Implement module double input signals (tokens). The module must use signals valid-ready for
  // transfer tokens. If the module receives more than 100 sequential tokens then it must set up_ready = 0;

  logic [7:0] cnt_tokens;
  logic [6:0] cnt_overflow;
  logic [2:0] cnt_double_down_ready;

  always_ff @( posedge clk ) begin : tokens_buffer
    if(rst) begin
      cnt_tokens <= '0;
    end else if (up_ready) begin
      if( up_valid & up_token & down_ready)
        cnt_tokens <= cnt_tokens + 8'd1;

      if( ~down_ready & up_token & up_valid)
        cnt_tokens <= cnt_tokens + 8'd2;

      if((cnt_tokens > 0) & down_ready & ((~up_token & up_valid) | ~up_valid))
        cnt_tokens <= cnt_tokens - 8'd1;
    end else begin 
        if(down_ready)
          cnt_tokens <= cnt_tokens - 8'd1;
        else
          cnt_tokens <= cnt_tokens;
    end
  end

  always_ff @( posedge clk ) begin : overflow
    if(rst)
      cnt_overflow <= '0;
    else if(~down_ready & up_token & up_valid & up_ready)
      cnt_overflow <= cnt_overflow + 7'd1;
    else if(cnt_double_down_ready [2])
      cnt_overflow <= cnt_overflow - 7'd1;
  end

  always_ff @( posedge clk ) begin : cnt_for_decrease_overflow
    if(rst)
      cnt_double_down_ready <= {1'b0,1'b0,1'b1};
    else if ((cnt_overflow > 0) & down_ready)
      cnt_double_down_ready <= {cnt_double_down_ready [1:0], cnt_double_down_ready[2]};
    else
      cnt_double_down_ready <= {1'b0,1'b0,1'b1};
  end

  assign down_data  = (up_valid) ? up_token | (|cnt_tokens) : (|cnt_tokens);
  assign down_valid = 1'b1;
  assign up_ready   = (cnt_overflow >= 100) ? 1'b0 : 1'b1;
  
endmodule

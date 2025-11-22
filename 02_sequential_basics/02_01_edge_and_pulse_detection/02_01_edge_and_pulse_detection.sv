//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).

  logic first_ff, second_ff;

  always_ff @( posedge clk )
    
    if (rst) begin

      first_ff <= '0;
      
    end else begin

      first_ff <= a;
      
    end

  always_ff @( posedge clk )
    
    if (rst) begin

      second_ff <= '0;
      
    end else begin

      second_ff <= first_ff;
      
    end

  logic [2:0] outs_from_ff;
  logic out;
  
  assign outs_from_ff = {a,first_ff, second_ff};

  always_comb 

    case (outs_from_ff)

    3'b010: out = '1;

    default: out = '0;
    endcase

  assign detected = out;

endmodule
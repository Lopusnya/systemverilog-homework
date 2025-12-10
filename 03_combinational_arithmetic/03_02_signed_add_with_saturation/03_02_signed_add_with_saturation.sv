//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

  
  logic [3:0] out, pre_sum;
  
  always_comb 
  begin

    pre_sum = a + b;
    case ({~a[3] & ~b[3] & pre_sum[3], a[3] & b[3] & ~pre_sum[3]})

      2'b01: out = 4'b1000;
      2'b10: out = 4'b0111;
      2'b11: out = 'x;

      default: out = pre_sum;
    endcase
  end

  assign sum = out ;

endmodule

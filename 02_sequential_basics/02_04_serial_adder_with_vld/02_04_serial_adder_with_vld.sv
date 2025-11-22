//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_adder_with_vld
(
  input  clk,
  input  rst,
  input  vld,
  input  a,
  input  b,
  input  last,
  output sum
);

  // Task:
  // Implement a module that performs serial addition of two numbers
  // (one pair of bits is summed per clock cycle).
  //
  // It should have input signals a and b, and output signal sum.
  // Additionally, the module have two control signals, vld and last.
  //
  // The vld signal indicates when the input values are valid.
  // The last signal indicates when the last digits of the input numbers has been received.
  //
  // When vld is high, the module should add the values of a and b and produce the sum.
  // When last is high, the module should output the sum and reset its internal state, but
  // only if vld is also high, otherwise last should be ignored.
  //
  // When rst is high, the module should reset its internal state.

  logic carry_d, carry, sum_d, sum_comb;

  assign sum_comb = a ^ b ^ carry_d;
  assign carry = (a & b) | ((a ^ b) & carry_d);

  always_ff @( posedge clk )
    
    if (rst)
      
    carry_d <= '0;

    else

      if(vld && last)

        carry_d <= '0;

      else

        if (vld)

          carry_d <= carry;
      
  logic mux_out;
  always_comb begin

    case ({vld, last})
      2'b10: mux_out = sum_comb;
      2'b11: mux_out = sum_comb; 
      default: mux_out = '0;
    endcase
    
  end

assign sum = mux_out;

endmodule

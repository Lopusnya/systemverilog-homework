//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  logic prev_a_eq_b, prev_a_less_b;

  assign a_eq_b      = prev_a_eq_b & (a == b);
  assign a_less_b    = (~ a & b) | (a == b & prev_a_less_b);
  assign a_greater_b = (~ a_eq_b) & (~ a_less_b);

  always_ff @ (posedge clk)
    if (rst)
    begin
      prev_a_eq_b   <= '1;
      prev_a_less_b <= '0;
    end
    else
    begin
      prev_a_eq_b   <= a_eq_b;
      prev_a_less_b <= a_less_b;
    end

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // Task:
  // Implement a module that compares two numbers in a serial manner.
  // The module inputs a and b are 1-bit digits of the numbers
  // and most significant bits are first.
  // The module outputs a_less_b, a_eq_b, and a_greater_b
  // should indicate whether a is less than, equal to, or greater than b, respectively.
  // The module should also use the clk and rst inputs.
  //
  // See the testbench for the output format ($display task).

typedef enum bit [1:0]
  {
    IDLE    = 2'd0,
    EQ      = 2'd1,
    GREATER = 2'd2,
    LESS    = 2'd3

    // .. = 1'd1;
  }
  state_e;
  state_e state, next_state;

//Register states
always_ff @( posedge clk )

  if (rst)
    state <= IDLE;
  else
    state <= next_state;

// Logic FSM
always_comb begin

  next_state = state;
  case (state)
    IDLE       :   if (a == b)    next_state = EQ;
                   else 
                   if (a  > b)    next_state = GREATER;
                   else
                                  next_state = LESS;

    EQ         :   if (   rst)    next_state = IDLE;
                   else
                   if (a == b)    next_state = EQ;
                   else 
                   if (a  > b)    next_state = GREATER;
                   else
                                  next_state = LESS;

    GREATER    :   if (   rst)    next_state = IDLE;

    LESS       :   if (   rst)    next_state = IDLE;

  endcase
  
end

//OUTPUT FSM (may be need output's register for remember which number is bigger in the end, A or B )
assign a_eq_b = (next_state == (EQ | IDLE));
assign a_greater_b = (next_state == GREATER);
assign a_less_b = (next_state == LESS);
 



  

endmodule

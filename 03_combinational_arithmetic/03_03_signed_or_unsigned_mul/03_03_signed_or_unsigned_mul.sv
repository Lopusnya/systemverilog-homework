//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// A non-parameterized module
// that implements the signed multiplication of 4-bit numbers
// which produces 8-bit result

module signed_mul_4
(
  input  signed [3:0] a, b,
  output signed [7:0] res
);

  assign res = a * b;

endmodule

// A parameterized module
// that implements the unsigned multiplication of N-bit numbers
// which produces 2N-bit result

module unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  output [2 * n - 1:0] res
);

  assign res = a * b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

// Task:
//
// Implement a parameterized module
// that produces either signed or unsigned result
// of the multiplication depending on the 'signed_mul' input bit.

module signed_or_unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  input                signed_mul,
  output [2 * n - 1:0] res
);

  logic [2 * n - 1:0] pre_res, pre_res_2, pre_res_3;
  logic [    n - 1:0] inv_a, inv_b;

  always_comb 
  begin

    inv_a = ((~a) + 1'b1);
    inv_b = ((~b) + 1'b1);
    pre_res_2 = inv_a * inv_b;


    if (signed_mul) 
    begin

        if (a[3] & b[3]) 
        begin

          pre_res = pre_res_2;

        end 
        else 
        begin
          
          if (a[3])

            pre_res = ~(inv_a * b) + 1'b1;
          
          else

            if (b[3])

              pre_res = ~(inv_b * a) + 1'b1;

            else

              pre_res = a * b; 

        end
    end 
    else 
    begin

      pre_res = a * b;  
    
    end

  end

  assign res = pre_res;

endmodule

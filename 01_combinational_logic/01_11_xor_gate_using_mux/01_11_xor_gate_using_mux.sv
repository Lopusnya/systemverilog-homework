//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  wire vss = 0;
  wire vdd = 1;
  wire notb, nota, and_a_notb, and_nota_b;

  mux inv_a
  (
    .d0(vdd), .d1(vss),
    .sel(a),
    .y(nota)
  );

  mux inv_b
  (
    .d0(vdd), .d1(vss),
    .sel(b),
    .y(notb)
  );

  mux my_and_a_notb
  (
    .d0(a), .d1(notb),
    .sel(a),
    .y(and_a_notb)
  );

  mux my_and_nota_b
  (
    .d0(nota), .d1(b),
    .sel(nota),
    .y(and_nota_b)
  );

  mux my_or
  (
    .d0(and_a_notb), .d1(and_nota_b),
    .sel(and_nota_b),
    .y(o)
  );

  

endmodule

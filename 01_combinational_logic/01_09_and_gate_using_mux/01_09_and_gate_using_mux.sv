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

module and_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement and gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  // wire vss = 0;
  // wire vdd = 1;

  mux my_and
  (
    .d0(a), .d1(b),
    .sel(a),
    .y(o)
  );


endmodule

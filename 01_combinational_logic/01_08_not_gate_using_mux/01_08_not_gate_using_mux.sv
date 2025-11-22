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

module not_gate_using_mux
(
    input  i,
    output o
);

  // Task:
  // Implement not gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

  wire vss = 0;
  wire vdd = 1;

  mux inv
  (
    .d0(vdd), .d1(vss),
    .sel(i),
    .y(o)
  );

  


endmodule

//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  // Task:
  // Implement mux_4_1 using three instances of mux_2_1


  logic [3:0] w1, w2, w3;
  wire s1 = sel[0];
  wire s2 = sel[1];
  

  mux_2_1 mux_1
  (
    .d0(d0),
    .d1(d1),
    .sel(s1),
    .y(w1)
  ); 

  mux_2_1 mux_2
  (
    .d0(d2),
    .d1(d3),
    .sel(s1),
    .y(w2)
  );

  mux_2_1 mux_3
  (
    .d0(w1),
    .d1(w2),
    .sel(s2),
    .y(w3)
  );

assign y = w3;

endmodule

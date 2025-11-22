//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_4_1_width_2
(
  input  [1:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [1:0] y
);

  assign y = sel [1] ? (sel [0] ? d3 : d2)
                     : (sel [0] ? d1 : d0);

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
  // Implement mux_4_1 with 4-bit data
  // using two instances of mux_4_1_width_2 with 2-bit data

logic [1:0] w1, w2;
wire [1:0] wd00, wd01, wd02, wd03, wd10, wd11, wd12, wd13;

assign wd00 = d0[1:0];
assign wd01 = d1[1:0];
assign wd02 = d2[1:0];
assign wd03 = d3[1:0];

assign wd10 = d0[3:2];
assign wd11 = d1[3:2];
assign wd12 = d2[3:2];
assign wd13 = d3[3:2];

mux_4_1_width_2 mux_1
(
  .d0(wd00), .d1(wd01), .d2(wd02), .d3(wd03),
  .sel(sel),
  .y(w1)
);

mux_4_1_width_2 mux_2
(
  .d0(wd10), .d1(wd11), .d2(wd12), .d3(wd13),
  .sel(sel),
  .y(w2)
);

assign y = {w2, w1};

endmodule

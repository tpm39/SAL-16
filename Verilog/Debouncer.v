
// A Debouncer

`timescale 1ns/100ps

module Debouncer (
   input sw_in, clk,
   output sw_out
);

   DFF dff1(.D(sw_in), .clk(clk), .rst(1'b0), .Q(q1));

   DFF dff2(.D(q1), .clk(clk), .rst(1'b0), .Q(q2));

   assign sw_out = q1 & ~q2;

endmodule


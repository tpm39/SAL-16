
// A D Flip-Flop

`timescale 1ns/100ps

module DFF (
   input D, clk, rst,
   output reg Q
);

   always @(posedge clk, posedge rst) begin
      if (rst) Q <= 1'b0;
      else Q <= D;
   end

endmodule


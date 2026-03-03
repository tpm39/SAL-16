
// A Clock Generator

`timescale 1ns/100ps

module Clock #(parameter HZ=1) (
   input clk_in,
   output reg clk_out
);
   integer count = 0;
   localparam max = 50_000_000/HZ;
   
   initial begin
      clk_out = 1'b0;
   end
 
   always @ (posedge clk_in) begin
      if (count == max - 1) begin
         count <= 0;
         clk_out <= ~clk_out;
         end 
      else
         count <= count + 1;
   end

endmodule


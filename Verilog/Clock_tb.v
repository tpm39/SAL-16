
// Testbench for a Clock Generator

`timescale 1ns/100ps

module Clock_tb;
   reg clk_in;
   wire clk_out;

   Clock #(25_000_000) dut(.clk_in(clk_in), .clk_out(clk_out));

   always #(5) begin
      clk_in <= ~clk_in;
   end
   
   initial begin
      clk_in = 1'b0;
   end

endmodule



// Testbench for the SAL-16 Clocks Generators

`timescale 1ns/100ps

module Clocks_tb;
   reg clk_in,reset, done;
   wire clk, clk_e, clk_s;

   Clocks dut(.clk_in(clk_in), .rst(reset), .done(done), 
             .clk(clk), .clk_e(clk_e), .clk_s(clk_s));

   always #(5) begin
      clk_in <= ~clk_in;
   end

   initial begin
      clk_in = 1'b0;
      reset = 1'b1;
      done = 1'b0;

      #50 reset = 1'b0;

      #250 done = 1'b1;

      #50 $finish;
   end

endmodule


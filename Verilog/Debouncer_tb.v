
// Testbench for a Debouncer

`timescale 1ns/100ps

module Debouncer_tb;
   reg sw_in, clk;
   wire sw_out;

   Debouncer dut(.sw_in(sw_in), .clk(clk), .sw_out(sw_out));

   always #(50) begin
      clk <= ~clk;
   end

   initial begin
      sw_in = 1'b0;
      clk = 1'b0;

      #100 sw_in = 1'b1;
      #1 sw_in = 1'b0;
      #1 sw_in = 1'b1;
      #1 sw_in = 1'b0;
      #1 sw_in = 1'b1;
      #1 sw_in = 1'b0;
      #1 sw_in = 1'b1;

      #400 sw_in = 1'b0;
      #1 sw_in = 1'b1;
      #1 sw_in = 1'b0;
      #1 sw_in = 1'b1;
      #1 sw_in = 1'b0;
      #1 sw_in = 1'b1;
      #1 sw_in = 1'b0;

      #400 $finish;
   end

endmodule


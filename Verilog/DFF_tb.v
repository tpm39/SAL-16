
// Testbench for a D Flip-Flop

`timescale 1ns/100ps

module DFF_tb;
   reg D, clk, rst;
   wire Q;

   DFF dut(.D(D), .clk(clk), .rst(rst), .Q(Q));

   initial begin
      rst = 1'b1;
      D = 1'b0;
      clk = 1'b0;

      #10 rst = 1'b0;

      #10 D = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;

      #10 D = 1'b0;
      #10 clk = 1'b1;
      #10 clk = 1'b0;

      #10 D = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;

      #10 rst = 1'b1;
      #10 rst = 1'b0;

      #10 $finish;
   end

endmodule


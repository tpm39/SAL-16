
// Testbench for a SAL-16 Output Device

`timescale 1ns/100ps

module OutputDev_tb;
   reg rst, clk, en;
   reg[15:0] addr, in;
   wire[15:0] out;

   OutputDev out_dev(.rst(rst), .clk(clk), .en(en), .id(4'h6), .addr(addr), .in(in), .out(out));

   initial begin
      rst = 1'b1;
      clk = 1'b0;
      en = 1'b0;
      addr = 16'hfff0;
      in = 16'bz;

      #10 rst = 1'b0;

      #10 in = 16'h1234;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'bz;

      addr = 16'hfff6;

      #10 in = 16'h4321;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'bz;

      addr = 16'hffff;

      #10 in = 16'habcd;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'bz;

      addr = 16'hfff6;

      #10 in = 16'hfedc;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 in = 16'bz;

      #10 rst = 1'b1;

      #10 $finish;
   end

endmodule


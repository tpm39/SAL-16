
// Testbench for a SAL-16 Input Device

`timescale 1ns/100ps

module InputDev_tb;
   reg rst, clk, en;
   reg[3:0] id;
   reg[15:0] addr, in;
   wire[15:0] out;

   InputDev dut(.rst(rst), .clk(clk), .en(en), .id(id), .addr(addr), .in(in), .out(out));

   initial begin
      rst = 1'b1;
      clk = 1'b0;
      en = 1'b0;
      id = 4'b0101;
      addr = 16'hfff0;
      in = 16'b0;

      #10 rst = 1'b0;

      #10 in = 16'h1234;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'b0;

      addr = 16'hfff5;

      #10 in = 16'h4321;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'b0;

      addr = 16'hffff;

      #10 in = 16'habcd;
      #10 en = 1'b1;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 en = 1'b0;
      #10 in = 16'b0;

      addr = 16'hfff5;

      #10 in = 16'hfedc;
      #10 clk = 1'b1;
      #10 clk = 1'b0;
      #10 in = 16'b0;

      #10 rst = 1'b1;

      #10 $finish;
   end

endmodule


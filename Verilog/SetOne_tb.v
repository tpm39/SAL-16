
// Testbench for the SAL-16 SetOne unit

`timescale 1ns/100ps

module SetOne_tb;
   reg set;
   reg[15:0] in;
   wire[15:0] out;

   SetOne dut(.set(set), .in(in), .out(out));
   
   initial begin
      set = 1'b0;
      in = 16'h0000;

      #10 set = 1'b1;
      #10 set = 1'b0;

      #10 in = 16'hffff;

      #10 set = 1'b1;
      #10 set = 1'b0;

      #10 in = 16'h0000;

      #10 set = 1'b1;
      #10 set = 1'b0;

      #10 in = 16'h5a5a;

      #10 set = 1'b1;
      #10 set = 1'b0;

      #10 $finish;
   end

endmodule


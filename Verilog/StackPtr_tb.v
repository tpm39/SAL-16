
// Testbench for the SAL-16 Stack Pointer

`timescale 1ns/100ps

module StackPtr_tb;
   reg rst, set, read, i_d;
   wire[15:0] bus_out;

   StackPtr dut(.rst(rst), .set(set), .read(read),
                .i_d(i_d), .bus_out(bus_out));

   initial begin
      // Reset
      rst = 1'b1;
      set = 1'b0;
      read = 1'b0;
      i_d = 1'b0;
      #10 rst = 1'b0;

      // Read
      #10 read = 1'b1;
      #10 read = 1'b0;
      
      // Push
      #10 set = 1'b1;
      i_d = 1'b1;
      #10 set = 1'b0;

      // Read
      #10 read = 1'b1;
      #10 read = 1'b0;
      
      // Push
      #10 set = 1'b1;
      i_d = 1'b1;
      #10 set = 1'b0;

      // Read
      #10 read = 1'b1;
      #10 read = 1'b0;

      // Pop
      #10 set = 1'b1;
      i_d = 1'b0;
      #10 set = 1'b0;
      
      // Read
      #10 read = 1'b1;
      #10 read = 1'b0;

      #10 $finish;
   end

endmodule


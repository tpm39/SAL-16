
// Testbench for the SAL-16 N-bit Register

`timescale 1ns/100ps

module Register_tb;
   localparam width = 16;

   reg rst, write, read;
   reg[width-1:0] in;
   wire[width-1:0] out;

   Register #(width) dut(.rst(rst), .write(write), .read(read), .in(in), .out(out));

   initial begin
      rst = 1'b1;
      write = 1'b0;
      read = 1'b0;
      in = 'bz;

      #10 rst = 1'b0;

      #10 in = 'h1234;
      #10 write = 1'b1;
      #10 write = 1'b0;
      in = 'bz;

      #10 read = 1'b1;
      #10 read = 1'b0;

      #10 in = 'hcdef;
      #10 write = 1'b1;
      #10 write = 1'b0;
      in = 'bz;

      #10 read = 1'b1;
      #10 read = 1'b0;

      #10 in = 'h5a5a;
      #10 write = 1'b1;
      #10 write = 1'b0;
      in = 'bz;

      #10 read = 1'b1;
      #10 read = 1'b0;

      #10 rst = 1'b1;
      #10 rst = 1'b0;

      #10 read = 1'b1;
      #10 read = 1'b0;

      #10 $finish;
   end

endmodule


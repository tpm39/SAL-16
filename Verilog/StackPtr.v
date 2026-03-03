
// The SAL-16 Stack Pointer

`timescale 1ns/100ps

module StackPtr (
   input rst, set, read, i_d,
   output[15:0] bus_out
);
   reg[15:0] sp;

   always @(posedge set, posedge rst) begin
      if (rst) sp <= 16'h87ff;
      else if (i_d) sp <= sp - 1;
      else sp <= sp + 1;
   end

   assign bus_out = read ? sp : 16'bz;

endmodule


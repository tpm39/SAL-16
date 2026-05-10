
// The SAL-16 N-bit Register

`timescale 1ns/100ps

module Register #(parameter N=16) (
   input rst, write, read,
   input[N-1:0] in,
   output[N-1:0] out
);
   reg[N-1:0] conts;

   always @(posedge write, posedge rst) begin
      if (rst) conts <= 'b0;
      else conts <= in;
   end

   assign out = read ? conts : 'bz;

endmodule


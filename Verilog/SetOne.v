
// The SAL-16 SetOne Unit: Set a Bus to the value 1 (Used to increment the PC)

`timescale 1ns/100ps

module SetOne (
   input set,
   input[15:0] in,
   output[15:0] out
);

   assign out = set ? 16'h0001 : in;

endmodule



// The SAL-16 Maths Unit

`timescale 1ns/100ps

module Maths (
   input[15:0] a, b,
   input[1:0] opcode,
   output reg[15:0] c,
   output reg co, z, n, v
);
   localparam SUB  = 2'b00;
   localparam MUL  = 2'b01;
   localparam SDIV = 2'b10;
   localparam UDIV = 2'b11;

   reg[16:0] calc;
   reg[31:0] calc_m;

   reg signed[15:0] sa, sb;

   always @(opcode, a, b) begin
      calc = 17'd0;
      calc_m = 32'd0;
      sa = a;
      sb = b;

      case(opcode)
         // Subtraction
         SUB: calc = a - b;
 
         // Multiplication
         MUL: calc_m = a * b;

         // Signed Division
         SDIV: calc = sa / sb;

         // Unsigned Division
         UDIV: calc = a / b;
      endcase

      // Result & Carry Flag
      co = 1'b0;
      if (opcode == MUL) begin
         c = calc_m[15:0];
         co = |(calc_m[31:16]);
         end
      else begin
         c = calc[15:0];
         if (opcode == SUB) co = calc[16];
      end

      // Zero Flag
      if (c[15:0] == 16'b0) z = 1'b1;
      else z = 1'b0;

      // Negative Flag
      n = c[15];

      // Overflow Flag (only for subtraction/multiplication)
      if (opcode == SUB) begin
         if (!a[15] && b[15] && c[15]) v = 1'b1;
         else if (a[15] && !b[15] && !c[15]) v = 1'b1;
         else v = 1'b0;
         end
      else if (opcode == MUL) begin
         if (!a[15] && !b[15] && c[15]) v = 1'b1;
         else if (!a[15] && b[15] && !c[15]) v = 1'b1;
         else if (a[15] && !b[15] && !c[15]) v = 1'b1;
         else if (a[15] && b[15] && c[15]) v = 1'b1;
         else v = 1'b0;
         // No overflow on a 0 result
         if ((a == 16'd0) || (b == 16'd0)) v = 1'b0;
         end
      else v = 1'b0;
   end

endmodule


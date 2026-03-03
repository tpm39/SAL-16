
// Testbench for the SAL-16 Maths Unit

`timescale 1ns/100ps

module Maths_tb;
   reg[15:0] a, b;
   reg[1:0] opcode;
   wire[15:0] c;
   wire co, z, n, v;

   Maths dut(.a(a), .b(b), .opcode(opcode),
             .c(c), .co(co), .z(z), .n(n), .v(v));

   initial begin
      // 270 - 13 = 257 (0x010e - 0x000d = 0x0101)
      a = 16'd270;
      b = 16'd13;
      #10 opcode = 2'b00;

      // 270 x 13 = 3,510 (0x010e x 0x000d = 0x0db6)
      #10 opcode = 2'b01;

      // 270 / 13 = 20 (0x010e / 0x000d = 0x0014 - signed)
      #10 opcode = 2'b10;
      
      // 270 / 13 = 20 (0x010e / 0x000d = 0x0014 - unsigned)
      #10 opcode = 2'b11;

      // -270 - 13 = -283 (0xfef2 - 0x000d = 0xfee5)
      #10 a = -16'd270;
      #10 opcode = 2'b00;

      // -270 x 13 = -3,510 (0xfef2 x 0x000d = 0xf24a)
      #10 opcode = 2'b01;

      // -270 / 13 = -20 (0xfef2 / 0x000d = 0xffec - signed)
      #10 opcode = 2'b10;
      
      // 65,266 / 13 = 5,020 (0xfef2 / 0x000d = 0x139c - unsigned)
      #10 opcode = 2'b11;

      #10 $finish;
   end

endmodule



// Testbench for the SAL-16 ALU

`timescale 1ns/100ps

module ALU_tb;
   reg[15:0] a, b;
   reg[2:0] opcode;
   reg lr_id, asr;
   wire[15:0] c;
   wire gt, eq, n, z, v, co;

   ALU dut(.a(a), .b(b), .opcode(opcode), .lr_id(lr_id), .asr(asr),
           .c(c), .gt(gt), .eq(eq), .n(n), .z(z), .v(v), .co(co));

   initial begin
      // 0x1234 + 0x2345 = 0x3579
      a = 16'h1234;
      b = 16'h2345;
      opcode = 3'b000;
      lr_id = 1'b0;
      asr = 1'b0;

      // 0x1234 + 0xfedc = 0x1110 (gt, co)
      #10 b = 16'hfedc;

      // 0x8100 + 0x8200 = 0x0300 (v, co)
      #10 a = 16'h8100;
      b = 16'h8200;

      // 0x7000 + 0x6000 = 0xd000 (gt, n, v)
      #10 a = 16'h7000;
      b = 16'h6000;

      // 0xffff + 0x0001 = 0 (z, co)
      #10 a = 16'hffff;
      b = 16'h0001;

      // LSL: 0xff04 << 3 = 0xf820 (n, co)
      #10 a = 16'hff04;
      b = 16'h0003;
      opcode = 3'b001;

      // LSR: 0xff04 >> 3 = 0x1fe0 (co)
      #10 lr_id = 1'b1;

      // ASR: 0xff04 >> 3 = 0xffe0 (n, co)
      #10 asr = 1'b1;

      // Dec: 0x1000 - 0x0001 = 0x0fff (gt)
      #10 a = 16'h1000;
      b = 16'h0001;
      opcode = 3'b010;

      // Inc: 0x1000 + 0x0001 = 0x1001 (gt)
      #10 lr_id = 1'b0;

      // !0xfedc = 0x0123
      #10 a = 16'hfedc;
      opcode = 3'b011;

      // 0x0f0f & 0x00ff = 0x000f (gt)
      #10 a = 16'h0f0f;
      b = 16'h00ff;
      opcode = 3'b100;

      // 0x0f0f | 0x00ff = 0x0fff (gt)
      #10 opcode = 3'b101;

      // 0x0f0f ^ 0x00ff = 0x0ff0 (gt)
      #10 opcode = 3'b110;

      // 0x0f0f > 0x00ff (gt)
      #10 opcode = 3'b111;

      // 0x0f0f = 0x0f0f (eq)
      #10 b = 16'h0f0f;
      
      #10 $finish;
   end

endmodule


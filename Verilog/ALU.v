
// The SAL-16 ALU

`timescale 1ns/100ps

module ALU (
   input[15:0] a, b,
   input[2:0] opcode,
   input asr, lr_id,
   output reg[15:0] c,
   output reg co, gt, eq, z, n, v
);
   reg[16:0] calc;

   always @(opcode, a, b, lr_id, asr) begin
      case(opcode)
         // Addition
         3'b000: calc = a + b;
         
         // Shift Left/Right/Arithmetic
         3'b001: begin
            if (!lr_id) calc = a << b;
            else begin
               calc = a >> b;
               calc[16] = a[b-1];
               if (asr && a[15]) begin
                  calc = calc | (17'h1ffff << (16-b));
                  calc[16] = a[b-1];
                  end
               end
            end
            
         // Inc/Dec
         3'b010: begin
            if (lr_id) calc = a - 1;
            else calc = a + 1;
            end
            
         // Not
         3'b011: begin
            calc = ~a;
            calc[16] = 1'b0;
            end
            
         // And
         3'b100: calc = a & b;
         
         // Or
         3'b101: calc = a | b;
         
         // Xor
         3'b110: calc = a ^ b;
         
         // Cmp
         3'b111: calc = 17'd1;
      endcase

      // Result & Carry Flag
      c = calc[15:0];
      co = calc[16];

      // Greater Than Flag
      if ((a[15] == 1'b0) && (b[15] == 1'b1)) gt = 1'b1;
      else if ((a[15] == b[15]) && (a > b)) gt = 1'b1;
      else gt = 1'b0;

      // Equal Flag
      if (a == b) eq = 1'b1;
      else eq = 1'b0;

      // Zero Flag
      if (calc[15:0] == 16'b0) z = 1'b1;
      else z = 1'b0;

      // Negative Flag
      n = calc[15];

      // Overflow Flag (only for addition)
      if (opcode == 3'b000) begin
         if (!a[15] && !b[15] && c[15]) v = 1'b1;
         else if (a[15] && b[15] && !c[15]) v = 1'b1;
         else v = 1'b0;
         end
      else v = 1'b0;

   end

endmodule


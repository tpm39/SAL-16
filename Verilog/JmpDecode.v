
// The SAL-16 Jump Decoder

`timescale 1ns/100ps

module JmpDecode (
   input[3:0] cond,
   input c, a, e, z, n, v,
   output reg jmp
);

   always @(*) begin
      case (cond)
         4'b0000: begin
            // JEQ
            if (e) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0001: begin
            // JNE
            if (!e) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0010: begin
            // JZ
            if (z) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0011: begin
            // JNZ
            if (!z) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0100: begin
            // JC
            if (c) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0101: begin
            // JNC
            if (!c) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0110: begin
            // JGT
            if (a) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b0111: begin
            // JGE
            if (a || e) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1000: begin
            // JLT
            if (!a && !e) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1001: begin
            // JLE
            if (!a || e) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1010: begin
            // JPL
            if (!z && !n) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1011: begin
            // JMI
            if (!z && n) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1100: begin
            // JV
            if (v) jmp = 1'b1;
            else jmp = 1'b0;
            end

         4'b1101: begin
            // JNV
            if (!v) jmp = 1'b1;
            else jmp = 1'b0;
            end

         default: begin
            jmp = 1'b0;
            end
      endcase
   end

endmodule


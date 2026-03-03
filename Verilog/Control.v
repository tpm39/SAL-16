
// The SAL-16 Control Unit

`timescale 1ns/100ps

module Control (
   input rst, clk, clk_e, clk_s,
   input c, a, e, z, n, v,
   input[15:0] ir,
   output reg[37:0] out
);
   // Output control lines
   localparam OUT_R0_E    = 37;
   localparam OUT_R1_E    = 36;
   localparam OUT_R2_E    = 35;
   localparam OUT_R3_E    = 34;
   localparam OUT_R4_E    = 33;
   localparam OUT_IDX_E   = 32;
   localparam OUT_FP_E    = 31;
   localparam OUT_LR_E    = 30;
   localparam OUT_R0_S    = 29;
   localparam OUT_R1_S    = 28;
   localparam OUT_R2_S    = 27;
   localparam OUT_R3_S    = 26;
   localparam OUT_R4_S    = 25;
   localparam OUT_IDX_S   = 24;
   localparam OUT_FP_S    = 23;
   localparam OUT_LR_S    = 22;
   localparam OUT_ASR     = 21;
   localparam OUT_LD_GR   = 20;
   localparam OUT_MATH_E  = 19;
   localparam OUT_PLUS1_E = 18;
   localparam OUT_PC_E    = 17;
   localparam OUT_MEM_E   = 16;
   localparam OUT_ACC_E   = 15;
   localparam OUT_SP_E    = 14;
   localparam OUT_LR_ID   = 13;
   localparam OUT_OP0     = 12;
   localparam OUT_OP1     = 11;
   localparam OUT_OP2     = 10;
   localparam OUT_IR_S    =  9;
   localparam OUT_MAR_S   =  8;
   localparam OUT_PC_S    =  7;
   localparam OUT_ACC_S   =  6;
   localparam OUT_MEM_S   =  5;
   localparam OUT_TMP_S   =  4;
   localparam OUT_FLAGS_S =  3;
   localparam OUT_SP_S    =  2;
   localparam OUT_SP_ID   =  1;
   localparam OUT_END     =  0;

   // Control word bits from the microcode ROM
   localparam CW_RST      = 29;
   localparam CW_LD_GR    = 28;
   localparam CW_NA_1     = 27;
   localparam CW_NA_2     = 26;
   localparam CW_NA_3     = 25;
   localparam CW_MATH_E   = 24;
   localparam CW_NA_4     = 23;
   localparam CW_PLUS1_E  = 22;
   localparam CW_PC_E     = 21;
   localparam CW_MEM_E    = 20;
   localparam CW_REG_E_1  = 19;
   localparam CW_REG_E_0  = 18;
   localparam CW_ACC_E    = 17;
   localparam CW_SP_E     = 16;
   localparam CW_LR_ID    = 15;
   localparam CW_OP0      = 14;
   localparam CW_OP1      = 13;
   localparam CW_OP2      = 12;
   localparam CW_IR_S     = 11;
   localparam CW_MAR_S    = 10;
   localparam CW_PC_S     =  9;
   localparam CW_ACC_S    =  8;
   localparam CW_MEM_S    =  7;
   localparam CW_TMP_S    =  6;
   localparam CW_REG_S_1  =  5;
   localparam CW_REG_S_0  =  4;
   localparam CW_FLAGS_S  =  3;
   localparam CW_SP_S     =  2;
   localparam CW_SP_ID    =  1;
   localparam CW_END      =  0;

   // Stage numbers
   localparam STG_SIX = 4'b0101;   
   localparam STG_RESET = 4'b1111;

   JmpDecode jmp_dec(.cond(ir[3:0]), .c(c), .a(a), .e(e), 
                     .z(z), .n(n), .v(v), .jmp(jmp));

   reg[6:0] uCode_LUT[0:31];
   reg[29:0] uCode_ROM[0:127];

   reg[3:0] stage;

   reg[37:0] rOut;
   reg[29:0] rCW;

   reg[37:0] clr_sets = {8'hff, 8'h0, 12'hfff, 8'h0, 2'b11};
   reg[37:0] clr_ens = {8'h0, 11'h7ff, 5'h0, 14'h3fff};

   wire[4:0] opcode = ir[15:11];
   wire[2:0] regA = ir[10:8];
   wire[2:0] regB = ir[7:5];
   wire[2:0] regC = ir[4:2];

   reg[1:0] regE, regS;

   initial begin
      $readmemh("MicrocodeLUT.uc", uCode_LUT);
      $readmemh("Microcode.uc", uCode_ROM);
   end

   always @(posedge rst, negedge clk) begin
      // Reset (posedge rst)
      if (rst) begin
         stage = STG_RESET;
         rOut = 38'b0;
         end

      // Set the next stage (negedge clk)
      else begin
         stage = stage + 1;
         rOut = 38'b0;

         case (stage)
            0: begin
               // Fetch stage 1
               rOut[OUT_PLUS1_E] = 1'b1;
               rOut[OUT_PC_E] = 1'b1;
               rOut[OUT_MAR_S] = 1'b1;
               rOut[OUT_ACC_S] = 1'b1;
               end
            1: begin
               // Fetch stage 2
               rOut[OUT_MEM_E] = 1'b1;
               rOut[OUT_IR_S] = 1'b1;
               end
            2: begin
               // Fetch stage 3
               rOut[OUT_ACC_E] = 1'b1;
               rOut[OUT_PC_S] = 1'b1;
               end
            default: begin
               // Execute stages
               rCW = uCode_ROM[uCode_LUT[opcode] + stage - 3];  // Get control word
               if (rCW[CW_RST]) stage = STG_RESET;  // Test for the end of the command
               else begin
                  // Form the output
                  rOut = {17'b0, rCW[CW_LD_GR], rCW[CW_MATH_E], rCW[CW_PLUS1_E:CW_MEM_E], 
                        rCW[CW_ACC_E:CW_TMP_S], rCW[CW_FLAGS_S:CW_END]};

                  // Set asr line
                  if ((ir[15:11] == 5'b10011) && ir[0]) rOut[OUT_ASR] = 1'b1;

                  // Set the register lines
                  regE = rCW[CW_REG_E_1:CW_REG_E_0];
                  case (regE)
                     2'b00: begin
                        // Nothing to do
                        end
                     2'b01: begin
                        rOut[OUT_R0_E - regA] = 1'b1;
                        end
                     2'b10: begin
                        rOut[OUT_R0_E - regB] = 1'b1;
                        end
                     2'b11: begin
                        rOut[OUT_R0_E - regC] = 1'b1;
                        end
                  endcase

                  regS = rCW[CW_REG_S_1:CW_REG_S_0];
                  case (regS)
                     2'b00: begin
                        // Nothing to do
                        end
                     2'b01: begin
                        rOut[OUT_R0_S - regA] = 1'b1;
                        end
                     2'b10: begin
                        rOut[OUT_R0_S - regB] = 1'b1;
                        end
                     2'b11: begin
                        rOut[OUT_R0_S - regC] = 1'b1;
                        end
                  endcase
                  
                  // Adjust for Jumps
                  if (stage == STG_SIX) begin
                     if ((ir[15:11] == 5'b00011) && jmp) rOut[OUT_PC_S] = 1'b1;
                     end
                  end
               end
         endcase
         end
   end

   always @(clk_e, clk_s) begin
      if (clk_s) out <= rOut;
      else if (clk_e) out <= (rOut & clr_sets);
      else out <= (rOut & clr_sets & clr_ens);
   end

endmodule


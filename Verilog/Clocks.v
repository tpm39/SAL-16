
// The SAL-16 Clocks Generator

`timescale 1ns/100ps

module Clocks (
   input clk_in, rst, done,
   output reg clk, clk_e, clk_s
);
   reg[1:0] stage;

   always @(posedge clk_in, posedge rst, posedge done) begin
      if (rst || done) begin
         stage <= 0;
         clk   <= 1'b0;
         clk_e <= 1'b0;
         clk_s <= 1'b0;
         end
      else begin
         if (stage == 3) stage <= 0;
         else stage <= stage + 1;

         case (stage) 
            0: begin
               clk   <= 1'b0;
               clk_e <= 1'b0;
               clk_s <= 1'b0;
               end
            1: begin
               clk   <= 1'b0;
               clk_e <= 1'b1;
               clk_s <= 1'b0;
               end
            2: begin
               clk   <= 1'b1;
               clk_e <= 1'b1;
               clk_s <= 1'b1;
               end
            3: begin
               clk   <= 1'b1;
               clk_e <= 1'b1;
               clk_s <= 1'b0;
               end
         endcase
      end
   end

endmodule


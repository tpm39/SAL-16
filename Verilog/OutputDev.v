
// A SAL-16 Output Device

`timescale 1ns/100ps

module OutputDev (
   input rst, clk, en,
   input[3:0] id,
   input[15:0] addr, in,
   output reg[15:0] out
);
   reg write;

   always @(*) begin
      if (id == addr[3:0]) write <= (en & clk);
      else write <= 1'b0;
   end

   always @(posedge write, posedge rst) begin
      if (rst) out <= 16'b0;
      else out <= in;
   end

endmodule


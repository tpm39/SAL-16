
// A SAL-16 Input Device

`timescale 1ns/100ps

module InputDev (
   input rst, clk, en,
   input[3:0] id,
   input[15:0] addr, in,
   output[15:0] out
);
   reg[15:0] conts;
   reg read;

   always @(posedge clk, posedge rst) begin
      if (rst) conts <= 16'b0;
      else conts <= in;
   end

   always @(*) begin
      if (id == addr[3:0]) read <= (en & clk);
      else read <= 1'b0;
   end

   assign out = read ? conts : 16'bz;

endmodule


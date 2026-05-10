
// SAL-16 Maths Unit Testing

`timescale 1ns/100ps

module Maths_test (
   input sys_clk, rst_in, ent_in,
   input[15:0] sw,
   output[15:0] led,
   output[6:0] seg,
   output[3:0] an,
   output dp
);
   reg[15:0] a, b;
   reg[1:0] opcode;
   wire[15:0] c;
   
   Maths dut(.a(a), .b(b), .opcode(opcode),
             .c(c), .co(co), .z(z), .n(n), .v(v));

   Clock #(40) clk40(.clk_in(sys_clk), .clk_out(clk_40Hz));
   Debouncer dbent(.sw_in(ent_in), .clk(clk_40Hz), .sw_out(ent));
   Debouncer dbrst(.sw_in(rst_in), .clk(clk_40Hz), .sw_out(rst));

   SevenSegHex display(.clk(sys_clk), .num(c), .seg(seg), .an(an), .dp(dp));

   always @(posedge ent) begin
      a <= {9'b0, sw[15:9]};
      b <= {9'b0, sw[6:0]};
      opcode <= sw[8:7];
   end

   assign led = {co, z, n, v, 12'b0};

endmodule


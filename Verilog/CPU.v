
// The SAL-16 CPU

`timescale 1ns/100ps

module CPU (
   input clk_in, rst,
   output mem_e, mem_s, done,
   output[15:0] addr,
   inout[15:0] bus
);
   wire[15:0] tmp_out, alu_b, alu_c, maths_c, acc_in, ir_out;
   wire[5:0] flags;

   Clocks clocks(.clk_in(clk_in), .rst(rst), .done(done),
            .clk(clk), .clk_e(clk_e), .clk_s(clk_s));

   Register #(16) r0(.rst(rst), .write(r0_s), .read(r0_e), .in(bus), .out(bus));

   Register #(16) r1(.rst(rst), .write(r1_s), .read(r1_e), .in(bus), .out(bus));

   Register #(16) r2(.rst(rst), .write(r2_s), .read(r2_e), .in(bus), .out(bus));

   Register #(16) r3(.rst(rst), .write(r3_s), .read(r3_e), .in(bus), .out(bus));

   Register #(16) r4(.rst(rst), .write(r4_s), .read(r4_e), .in(bus), .out(bus));

   Register #(16) idx(.rst(rst), .write(idx_s), .read(idx_e), .in(bus), .out(bus));

   Register #(16) fp(.rst(rst), .write(fp_s), .read(fp_e), .in(bus), .out(bus));

   Register #(16) lr(.rst(rst), .write(lr_s), .read(lr_e), .in(bus), .out(bus));

   Register #(16) mar(.rst(rst), .write(mar_s), .read(1'b1), .in(bus), .out(addr));

   StackPtr sp(.rst(rst), .set(sp_s), .read(sp_e), .i_d(sp_id), .bus_out(bus));

   Register #(16) ir(.rst(rst), .write(ir_s), .read(1'b1), .in(bus), .out(ir_out));

   Register #(16) pc(.rst(rst), .write(pc_s), .read(pc_e), .in(bus), .out(bus));

   Register #(16) acc(.rst(rst), .write(acc_s), .read(acc_e), .in(acc_in), .out(bus));

   Register #(16) tmp(.rst(rst), .write(tmp_s), .read(1'b1), .in(bus), .out(tmp_out));

   SetOne set_one(.set(plus1_e), .in(tmp_out), .out(alu_b));

   ALU alu(.a(bus), .b(alu_b), .opcode({op2, op1, op0}), .lr_id(lr_id), .asr(asr), .c(alu_c),
           .co(alu_co), .gt(alu_gt), .eq(alu_eq), .z(alu_z), .n(alu_n), .v(alu_v));

   Maths maths(.a(bus), .b(tmp_out), .opcode(ir_out[1:0]), .c(maths_c),
               .co(maths_co), .z(maths_z), .n(maths_n), .v(maths_v));

   Register #(6) flags_reg(.rst(rst), .write(flags_s), .read(1'b1), .in(flags),
                           .out({flag_c, flag_a, flag_e, flag_z, flag_n, flag_v}));

   Control control(.rst(rst), .clk(clk), .clk_e(clk_e), .clk_s(clk_s),
                  .c(flag_c), .a(flag_a), .e(flag_e), .z(flag_z),
                  .n(flag_n), .v(flag_v), .ir(ir_out), 
                  .out({r0_e, r1_e, r2_e, r3_e, r4_e, idx_e, fp_e, lr_e, r0_s, r1_s,
                  r2_s, r3_s, r4_s, idx_s, fp_s, lr_s, asr, ld_gr, math_e, plus1_e,
                  pc_e, mem_e, acc_e, sp_e, lr_id, op0, op1, op2, ir_s, mar_s, 
                  pc_s, acc_s, mem_s, tmp_s, flags_s, sp_s, sp_id, done}));

   assign acc_in = math_e ? maths_c : alu_c;

   assign flags = math_e ? {maths_co, alu_gt, alu_eq, maths_z, maths_n, maths_v} : 
                           {alu_co, alu_gt, alu_eq, alu_z, alu_n, alu_v};

endmodule


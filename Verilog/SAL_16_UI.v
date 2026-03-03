
// The SAL-16 User Interface

`timescale 1ns/100ps

module SAL_16_UI (
   input sys_clk, rst_in, ent_in,
   input[15:0] sw,
   output[15:0] led,
   output[6:0] seg,
   output[3:0] an,
   output dp
);
   // Set DISP_SW = 1 to ensure that the switch settings are
   // displayed during data input, otherwise set DISP_SW = 0.
   localparam DISP_SW = 1;

   wire[15:0] res;
   
   reg[15:0] status;
   reg[15:0] disp;
   
   // SAL-16 Clock = 4Mz -> clk_e/clk_s = 1Mhz
   Clock #(4_000_000) clk4M(.clk_in(sys_clk), .clk_out(clk_4MHz));

   // SAL-16 Computer
   SAL_16 sal(.clk_in(clk_4MHz), .rst(rst), .done(done), .IN(sw), 
              .OUT(res), .ENT(ent), .WAIT(wt_data), .ERR(err_data));

   // Switch debouncing
   Clock #(40) clk40(.clk_in(sys_clk), .clk_out(clk_40Hz));
   Debouncer dbent(.sw_in(ent_in), .clk(clk_40Hz), .sw_out(ent));
   Debouncer dbrst(.sw_in(rst_in), .clk(clk_40Hz), .sw_out(rst));

   // Display - Comment out the unused ones ...
   SevenSegDec display(.clk(sys_clk), .num(disp), .seg(seg), .an(an), .dp(dp));
   //SevenSegHex display(.clk(sys_clk), .num(disp), .seg(seg), .an(an), .dp(dp));
   //SevenSegTime display(.clk(sys_clk), .num(disp), .seg(seg), .an(an), .dp(dp));
   
   assign led = status;
   
   always @(posedge sys_clk) begin
      if (err_data) begin
         status <= 16'h03c0;
         disp <= res;
         end         
      else if (done) begin
         status <= 16'hf000;
         disp <= res;
         end         
      else if (wt_data) begin
         status <= 16'h000f;
         if (DISP_SW == 1) disp <= sw;
         else disp <= res;
         end
      else begin
         status <= 16'h0000;
         disp <= res;
         end
   end

endmodule


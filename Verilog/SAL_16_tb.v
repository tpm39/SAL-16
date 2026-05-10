
// Testbench for the SAL-16 Computer

`timescale 1ns/100ps

module SAL_16_tb;
   reg clk_in, rst, ENT;
   reg[15:0] IN;

   wire[15:0] OUT;

   SAL_16 dut(.clk_in(clk_in), .rst(rst), .done(done), .IN(IN), 
              .OUT(OUT), .ENT(ENT), .WAIT(WAIT), .ERR(ERR));

   always #(5) begin
      clk_in <= ~clk_in;
   end

   initial begin
      clk_in = 1'b0;
      
      IN = 16'h0;
      ENT = 1'b0;

      #50 rst = 1'b1;
      #50 rst = 1'b0;

      // SumToN: sum(28) = 406
      #2000 IN = 16'd28;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      // Average: av(1276,391) = 833
      /*#2000 IN = 16'd2;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      #2000 IN = 16'd1276;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      #2000 IN = 16'd391;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      // Calculator: 20 x 3 = 60
      #2000 IN = 16'd20;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      #2000 IN = 16'h2000;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      #2000 IN = 16'd3;
      #5000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      // Stopwatch
      // NB: In the Simulator version of TimmiOS.asm change 'DELAY_MS' to '1',
      //     and in Stopwatch.asm also change 'DELAY_SEC' to '1' so that things
      //     can be seen in the Simulator Output window ...
      #50000 ENT = 1'b1;
      #2000 ENT = 1'b0;

      #100000 ENT = 1'b1;
      #2000 ENT = 1'b0;*/

      while (~done) begin
         #10;
      end

      #250 $finish;
   end

endmodule


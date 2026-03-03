
// Testbench for the SAL-16 Address Decoder

`timescale 1ns/100ps

module AddrDecode_tb;
   reg[15:0] addr;
   wire i_o, ram, rom;

   AddrDecode dut(.addr(addr), .i_o(i_o), .ram(ram), .rom(rom));
   
   initial begin
      addr = 16'hffff;
      #10 addr = 16'hffef;
      #10 addr = 16'h7fff;
      #10 addr = 16'hfff5;
      #10 addr = 16'haaaa;
      #10 addr = 16'h5555;
      #10 addr = 16'hfff0;
      #10 addr = 16'h8000;
      #10 addr = 16'h0000;
      #10 $finish;
   end

endmodule


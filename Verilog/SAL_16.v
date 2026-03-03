
// The SAL-16 Computer

`timescale 1ns/100ps

module SAL_16 (
   input clk_in, rst, ENT,
   input[15:0] IN,
   output done, WAIT, ERR,
   output[15:0] OUT
);
   wire[15:0] bus, addr, inp_out, wt_data, err_data;
   reg[15:0] mem_conts;

   CPU cpu(.clk_in(clk_in), .rst(rst), .mem_e(mem_e), .mem_s(mem_s), .done(done), .addr(addr), .bus(bus));

   AddrDecode addrdec(.addr(addr), .i_o(i_o_en), .ram(ram_en), .rom(rom_en));

   InputDev in3(.rst(rst), .clk(mem_e), .en(i_o_en), .id(4'h3), .addr(addr), .in(IN), .out(inp_out));

   InputDev in5(.rst(rst), .clk(mem_e), .en(i_o_en), .id(4'h5), .addr(addr), .in({15'b0, dff_out}), .out(inp_out));

   DFF dff(.D(1'b1), .clk(ENT), .rst(~wt_data[0]), .Q(dff_out));

   OutputDev out0(.rst(rst), .clk(mem_s), .en(i_o_en), .id(4'h0), .addr(addr), .in(bus), .out(err_data));

   OutputDev out4(.rst(rst), .clk(mem_s), .en(i_o_en), .id(4'h4), .addr(addr), .in(bus), .out(wt_data));

   OutputDev out6(.rst(rst), .clk(mem_s), .en(i_o_en), .id(4'h6), .addr(addr), .in(bus), .out(OUT));

   reg[15:0] ROM[0:4095];

   reg[15:0] RAM[0:2047];

   reg[15:0] IO[0:15];

   initial begin
      $readmemh("TimmiOS.mc", ROM);
      $readmemh("Calculator.mc", RAM);
   end

   assign WAIT = wt_data[0];
   assign ERR = err_data[0];

   always @(posedge mem_e) begin
      if (rom_en) mem_conts <= ROM[addr[14:0]];
      if (ram_en) mem_conts <= RAM[addr[14:0]];
   end

   always @(posedge mem_s) begin
      if (ram_en) RAM[addr[14:0]] = bus;
   end

   assign bus = i_o_en ? inp_out : 
               mem_e ? mem_conts : 16'bz;

endmodule



// The SAL-16 Address Decoder

`timescale 1ns/100ps

module AddrDecode (
   input[15:0] addr,
   output i_o, ram, rom
);

   assign i_o = &(addr[15:4]);

   assign ram = (~i_o) & addr[15];

   assign rom = ~addr[15];

endmodule


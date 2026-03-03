
// To Display a Hex Number on the 7-Segment Display

`timescale 1ns/100ps

module SevenSegHex (
   input clk,
   input[15:0] num,
   output reg[6:0] seg,
   output reg[3:0] an,
   output reg dp
);
   reg [19:0] count;
   wire [1:0] digit;
   reg [3:0] dig_val;

   assign digit = count[19:18];

   always @(posedge clk) begin
      count <= count + 1;
   end
      
   always @(digit, num) begin
      case(digit)
         2'b00: begin
            an = 4'b0111; 
            dig_val = num[15:12];
            end
         2'b01: begin
            an = 4'b1011; 
            dig_val = num[11:8];
            end
         2'b10: begin
            an = 4'b1101; 
            dig_val = num[7:4];
            end
         2'b11: begin
            an = 4'b1110; 
            dig_val = num[3:0];
            end
      endcase
   end        

   always @(*) begin
      dp = 1'b1;
      case(dig_val)
         'h00: seg = 7'b1000000; 
         'h01: seg = 7'b1111001; 
         'h02: seg = 7'b0100100;
         'h03: seg = 7'b0110000;
         'h04: seg = 7'b0011001;
         'h05: seg = 7'b0010010;
         'h06: seg = 7'b0000010;
         'h07: seg = 7'b1111000;
         'h08: seg = 7'b0000000;
         'h09: seg = 7'b0010000; 
         'h0a: seg = 7'b0100000; 
         'h0b: seg = 7'b0000011;
         'h0c: seg = 7'b0100111; 
         'h0d: seg = 7'b0100001; 
         'h0e: seg = 7'b0000110; 
         'h0f: seg = 7'b0001110;
         default:
               seg = 7'b1111111;
      endcase
   end

endmodule 


// To Display a Decmal Number on the 7-Segment Display

module SevenSegDec (
   input clk,
   input[15:0] num,
   output reg[6:0] seg,
   output reg[3:0] an,
   output reg dp
);
   reg[19:0] count;
   wire[1:0] digit;
   reg[3:0] dig_val;
   reg too_big;

   assign digit = count[19:18];

   always @(posedge clk) begin
      count <= count + 1;
   end
    
   always @(*) begin
      case(digit)
         2'b00: begin
            an = 4'b0111; 
            if (num > 16'd9999) begin
               too_big = 1'b1;
               end
            else begin
               dig_val = num / 1000;
               too_big = 1'b0;
               end
            end
         2'b01: begin
            an = 4'b1011; 
            dig_val = (num % 1000) / 100;
            end
         2'b10: begin
            an = 4'b1101; 
            dig_val = (num % 100) / 10;
            end
         2'b11: begin
            an = 4'b1110; 
            dig_val = num % 10;
            end
      endcase
      
      if (too_big == 1'b1) dig_val = 4'd10;
   end        

   always @(*) begin
      dp = 1'b1;
      case(dig_val)
         0:  seg = 7'b1000000; 
         1:  seg = 7'b1111001; 
         2:  seg = 7'b0100100;
         3:  seg = 7'b0110000;
         4:  seg = 7'b0011001;
         5:  seg = 7'b0010010;
         6:  seg = 7'b0000010;
         7:  seg = 7'b1111000;
         8:  seg = 7'b0000000;
         9:  seg = 7'b0010000; 
         10: seg = 7'b0111111; 
         default:
             seg = 7'b1111111;
      endcase
   end

endmodule 


// To Display a 'Time' Number on the 7-Segment Display ('hh.mm' or 'mm.ss')

module SevenSegTime (
   input clk,
   input[15:0] num,
   output reg[6:0] seg,
   output reg[3:0] an,
   output reg dp
);
   reg[19:0] count;
   wire[1:0] digit;
   reg[3:0] dig_val;
   reg[6:0] hm_val;
   reg[5:0] ms_val;
   reg too_big;

   assign digit = count[19:18];

   always @(posedge clk) begin
      count <= count + 1;
   end
    
   always @(*) begin
      dig_val = 4'b0;
      too_big = 1'b0;
      hm_val = num / 60;
      ms_val = num % 60;
      
      case(digit)
         2'b00: begin
            an = 4'b0111; 
            if (num > 16'd5999) begin
               too_big = 1'b1;
               end
            else begin
               dig_val = hm_val / 10;
               end
            end
         2'b01: begin
            an = 4'b1011; 
            dig_val = hm_val % 10;
            end
         2'b10: begin
            an = 4'b1101; 
            dig_val =  ms_val / 10;
            end
         2'b11: begin
            an = 4'b1110; 
            dig_val = ms_val % 10;
            end
      endcase
      
      if (too_big == 1'b1) dig_val = 4'd10;
   end        

   always @(*) begin
      if (an == 4'b1011) dp = 1'b0;
      else dp = 1'b1;
      
      case(dig_val)
         0:  seg = 7'b1000000; 
         1:  seg = 7'b1111001; 
         2:  seg = 7'b0100100;
         3:  seg = 7'b0110000;
         4:  seg = 7'b0011001;
         5:  seg = 7'b0010010;
         6:  seg = 7'b0000010;
         7:  seg = 7'b1111000;
         8:  seg = 7'b0000000;
         9:  seg = 7'b0010000; 
         10: seg = 7'b0111111; 
         default:
             seg = 7'b1111111;
      endcase
   end

endmodule 


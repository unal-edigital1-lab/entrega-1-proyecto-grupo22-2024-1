`timescale 1ns / 1ps
module display_hex(
    input [39:0] num,
    input clk,
    output [0:6] sseg,
    output reg [7:0] an,
	 input rst
    );



reg [4:0]bcd = 0;
//wire [15:0] num=16'h4321;

BCDtoSSeg bcdtosseg(.BCD(bcd), .SSeg(sseg));

reg [26:0] cfreq = 0;
wire enable;

// Divisor de frecuecia

assign enable = cfreq[16];
always @(posedge clk or negedge rst) begin
  if(!rst) begin
		cfreq <= 0;
	end else begin
		cfreq <=cfreq+1;
	end
end

reg [2:0] count = 0;
always @(posedge enable) begin
		if(!rst) begin
			count<= 0;
			an<=8'b11111111;
		end else begin 
			count<= count + 1;
			case (count) 
				3'h0: begin bcd <= num[4:0];   	an<=8'b11111110; end 
				3'h1: begin bcd <= num[9:5];   	an<=8'b11111101; end 
				3'h2: begin bcd <= num[14:10];  	an<=8'b11111011; end 
				3'h3: begin bcd <= num[19:15]; 	an<=8'b11110111; end 
				3'h4: begin bcd <= num[24:20];   an<=8'b11101111; end 
				3'h5: begin bcd <= num[29:25];   an<=8'b11011111; end 
				3'h6: begin bcd <= num[34:30];  	an<=8'b10111111; end 
				3'h7: begin bcd <= num[39:35]; 	an<=8'b01111111; end 
			endcase
		end
end

endmodule


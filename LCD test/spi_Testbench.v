`timescale 1ns / 1ps

module spi_Testbench;

	 reg clk;
    reg reset;
    wire mosi;

    // Outputs
    wire dc;
    wire sclk;
    wire cs;
	 wire lcd_rst;
    wire [7:0] data_in;
	 
	 FSM_pet uut(
		.clk(clk),
		.reset(reset),
		.mosi(mosi),
		.sclk(sclk),
		.cs(cs),
		.dc(dc),
		.lcd_rst(lcd_rst)
	);
	
	initial begin
        clk = 0;
        forever #1 clk = ~clk; //500Mhz
   	end
	 
	initial begin
		reset=0; //se presiona reset primero para reinicializar todo
		#200;
		reset=1;
	end
	
endmodule
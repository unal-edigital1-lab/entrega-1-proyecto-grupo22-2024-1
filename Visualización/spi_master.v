module spi_master(
   input clk,                	// sys clk
   input reset,              	// rst in
   input [7:0] data_in,      	// data column
   input start,              	// begin transmission
   input [15:0] div_factor,   // sclk div
   input  miso,          		// master in slave out
   output reg mosi,           // master out slave in
   output reg sclk,          	// spi clk
   output reg cs,            	// chip Select
   output reg [7:0] data_out, // data received
   output reg busy,          	// busy
   output reg avail,  			// go ahead
	output reg lcd_rst			// rst out
);

   reg [7:0] shift_reg;
   reg [3:0] bit_count;
   reg [15:0] clk_count;
	reg active;
   
	

	always @(posedge clk or posedge reset) begin
	  if (reset) begin
			sclk <= 0;
			cs <= 1;
			shift_reg <= 0;
			bit_count <= 0;
			clk_count <= 0;
			active <= 0;
			busy <= 0;
			avail <= 0;
			lcd_rst <= 0;
	  end else if (start && !active) begin
			lcd_rst <= 1;
			active <= 1;
			busy <= 1;
			avail <= 0;
			cs <= 0;
			shift_reg <= data_in;
			bit_count <= 7;
	  end else if (active) begin
			if (clk_count < div_factor - 1) begin
				 clk_count <= clk_count + 1;
			end else begin
				 clk_count <= 0;
				 sclk <= !sclk;

				 if (sclk) begin
						mosi <= shift_reg[7];
				 end else begin
					  if (bit_count > 0) begin
							bit_count <= bit_count - 1;
							shift_reg <= {shift_reg[6:0], miso};
					  end else begin
							data_out <= shift_reg;
							cs <= 1;
							active <= 0;
							busy <= 0;
							avail <= 1;
					  end
				 end
			end
	  end
	end
endmodule
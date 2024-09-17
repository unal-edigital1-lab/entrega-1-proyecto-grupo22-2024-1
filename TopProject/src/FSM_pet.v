module FSM_pet (
	input clk,                	// sys. clk
   input reset,              	// rst in
	input enable,
	input [2:0] face,
	input [2:0] icon,
	output mosi,               // master out slave in
   output sclk,          		// spi clk
   output ce,           		// chip Select
	output dc,					// data/command
	output lcd_rst
);

   reg [7:0] data_in;
	reg start;
	reg cmd;
	
	wire [25:0] div_factor = 25000000; 
	
	reg [7:0] initline[5];
	reg [7:0] cmdline[6];
	reg [7:0] dataline[16];
	reg [7:0] iconline[8];
	reg [5:0] initindex = 0;
	reg [5:0] cmdindex = 0;
	reg [5:0] dataindex = 0;
	reg [5:0] iconindex = 0;
	
	reg [8:0] count;
	reg [8:0] line;
	reg [3:0] state = 0;

   wire busy;
   wire avail;
	
	parameter INIT = 4'h0, WIPE = 4'h1, WAIT = 4'h2, DRAWPET = 4'h3, DRAWICON = 4'h4;

	spi_master spi (
       .clk(clk),
       .reset(~reset),
       .data_in(data_in),
       .start(start),
       .div_factor(div_factor),
		 .cmd(cmd),
       .mosi(mosi),
       .sclk(sclk),
       .ce(ce),
       .data_out(data_out),
       .busy(busy),
       .avail(avail),
		 .dc(dc),
		 .lcd_rst(lcd_rst)
   );

   always @(posedge clk) begin
		 if (~reset) begin
           start <= 0;
			  cmdindex <= 0;
			  dataindex <= 0;	  
			  initindex <= 0;
			  iconindex <= 0;
			  state <= 0;
			  count <= 0;
			  
			  initline[0] <= 8'h21;
			  initline[1] <= 8'h90;
			  initline[2] <= 8'h20;
			  initline[3] <= 8'h0C;
			  initline[4] <= 8'h80;
			  
			  cmdline[0] <= 8'hA0;			
			  cmdline[1] <= 8'h42;
			  cmdline[2] <= 8'hA0;	
			  cmdline[3] <= 8'h41;
			  cmdline[4] <= 8'hA4;	
			  cmdline[5] <= 8'h44;
		
       end else begin
			case(state)
				INIT: begin //Initial commands
							case(count)
								0:	begin  
										start <= 1; 
										cmd <= 0;
										if (avail) begin
											count <= 1;
										end
									end
									
								1: begin
										data_in <= initline[initindex];
										if (avail) begin
											if (initindex < 5) begin
												initindex <= initindex + 1;
											end else begin
												state <= 1;
												initindex <= 0;
												count <= 0;
											end
										end
									end
								endcase
							end

		WIPE: begin //Clear screen
					case(count)
						0: begin
								cmd <= 1;
								data_in <= 8'h0; 
								if (avail) begin
									if (line <= 510) begin 
										line <= line + 1;
									end else begin 
										state <= 2;
										line <= 0;
									end
								end
							end			
					endcase
				end
		
		WAIT: begin
					if (enable) begin
						case (face)
							0: begin
										  dataline[0] <= 8'b00001110;
										  dataline[1] <= 8'b00010001;
									  	  dataline[2] <= 8'b01100000;
										  dataline[3] <= 8'b10000100;
										  dataline[4] <= 8'b10110010;
										  dataline[5] <= 8'b10000010;	
										  dataline[6] <= 8'b01100011; 
										  dataline[7] <= 8'b00100011; 
										  
										  dataline[8] <= 8'b00001111; 
										  dataline[9] <= 8'b00010001;	
										  dataline[10] <= 8'b10100001;
										  dataline[11] <= 8'b10101110;
										  dataline[12] <= 8'b01000001;
										  dataline[13] <= 8'b00001001; 
										  dataline[14] <= 8'b00000110;	 
										  dataline[15] <= 8'b00000010; 
										end
							
							1: 	begin
										  dataline[0] <= 8'b00001110;
										  dataline[1] <= 8'b00010001;
									  	  dataline[2] <= 8'b01100000;
										  dataline[3] <= 8'b10000100;
										  dataline[4] <= 8'b10110110;
										  dataline[5] <= 8'b10000101;	
										  dataline[6] <= 8'b01100101; 
										  dataline[7] <= 8'b00100101;
										  
										  dataline[8] <= 8'b00001111; 
										  dataline[9] <= 8'b00010001;	
										  dataline[10] <= 8'b10100001;
										  dataline[11] <= 8'b10101110;
										  dataline[12] <= 8'b01000001;
										  dataline[13] <= 8'b00001001; 
										  dataline[14] <= 8'b00000110;	 
										  dataline[15] <= 8'b00000010; 
										end
										
							2: 		begin
										  dataline[0] <= 8'b00001110;
										  dataline[1] <= 8'b00010001;
									  	  dataline[2] <= 8'b01100000;
										  dataline[3] <= 8'b10010010;
										  dataline[4] <= 8'b10110100;
										  dataline[5] <= 8'b10000100;	
										  dataline[6] <= 8'b01100111; 
										  dataline[7] <= 8'b00100101; 
										  
										  dataline[8] <= 8'b00001111; 
										  dataline[9] <= 8'b00010001;	
										  dataline[10] <= 8'b10100001;
										  dataline[11] <= 8'b10101110;
										  dataline[12] <= 8'b01000001;
										  dataline[13] <= 8'b00001001; 
										  dataline[14] <= 8'b00000110;	 
										  dataline[15] <= 8'b00000010; 
										end
										
							3: 	begin
										  dataline[0] <= 8'b00001110;
										  dataline[1] <= 8'b00010001;
									  	  dataline[2] <= 8'b01100000;
										  dataline[3] <= 8'b10010000;
										  dataline[4] <= 8'b10001000;
										  dataline[5] <= 8'b10010000;	
										  dataline[6] <= 8'b01100000; 
										  dataline[7] <= 8'b00100001; 
										  
										  dataline[8] <= 8'b00001111; 
										  dataline[9] <= 8'b00010001;	
										  dataline[10] <= 8'b10100001;
										  dataline[11] <= 8'b10101110;
										  dataline[12] <= 8'b01000001;
										  dataline[13] <= 8'b00001001; 
										  dataline[14] <= 8'b00000110;	 
										  dataline[15] <= 8'b00000010;
										end
										
							4: 	begin
										  dataline[0] <= 8'b00001110;
										  dataline[1] <= 8'b00010001;
									  	  dataline[2] <= 8'b01100000;
										  dataline[3] <= 8'b10010000;
										  dataline[4] <= 8'b10111000;
										  dataline[5] <= 8'b10010000;	
										  dataline[6] <= 8'b01100011; 
										  dataline[7] <= 8'b00100100; 
										  
										  dataline[8] <= 8'b00001111; 
										  dataline[9] <= 8'b00010001;	
										  dataline[10] <= 8'b10100001;
										  dataline[11] <= 8'b10101110;
										  dataline[12] <= 8'b01000001;
										  dataline[13] <= 8'b00001001; 
										  dataline[14] <= 8'b00000110;	 
										  dataline[15] <= 8'b00000010; 
										end
							
							5: 	begin
										  dataline[0] <= 8'b00000000;
										  dataline[1] <= 8'b00000000;
										  dataline[2] <= 8'b00000011;	
										  dataline[3] <= 8'b00001100;
										  dataline[4] <= 8'b00010010;
										  dataline[5] <= 8'b00100001;	
										  dataline[6] <= 8'b00100010; 
										  dataline[7] <= 8'b00100000; 

										  dataline[8] <= 8'b00000111; 
										  dataline[9] <= 8'b00001001;	
										  dataline[10] <= 8'b11111111;
										  dataline[11] <= 8'b00000001;
										  dataline[12] <= 8'b10000001;
										  dataline[13] <= 8'b00011001; 
										  dataline[14] <= 8'b10100001;	 
										  dataline[15] <= 8'b00100001; 
										end
						endcase
						case (icon)			
							0: 	begin
										  iconline[0] <= 8'b00000000; 
										  iconline[1] <= 8'b00110010;	
										  iconline[2] <= 8'b00101010;
										  iconline[3] <= 8'b00100110;
										  iconline[4] <= 8'b00000000;
										  iconline[5] <= 8'b11001000; 
										  iconline[6] <= 8'b10101000;	 
										  iconline[7] <= 8'b10011000;  
										end
										
							1: 	begin
										  iconline[7] <= 8'b00011100; 
										  iconline[6] <= 8'b00100010;	
										  iconline[5] <= 8'b00100001;
										  iconline[4] <= 8'b01110001;
										  iconline[3] <= 8'b10010001;
										  iconline[2] <= 8'b10100001; 
										  iconline[1] <= 8'b00100010;	 
										  iconline[0] <= 8'b00011100; 
										end
							
							2: 	begin
										  iconline[7] <= 8'b01111100; 
										  iconline[6] <= 8'b10010010;	
										  iconline[5] <= 8'b01010001;
										  iconline[4] <= 8'b00010001;
										  iconline[3] <= 8'b00010001;
										  iconline[2] <= 8'b00010001; 
										  iconline[1] <= 8'b00010010;	 
										  iconline[0] <= 8'b00011100;  
										end
										
							3: 	begin
										  iconline[7] <= 8'b00000010; 
										  iconline[6] <= 8'b00000111;	
										  iconline[5] <= 8'b11111110;
										  iconline[4] <= 8'b10000000;
										  iconline[3] <= 8'b10000000;
										  iconline[2] <= 8'b10000010; 
										  iconline[1] <= 8'b10000111;	 
										  iconline[0] <= 8'b11111110;
										end
										
							4: 	begin
										  iconline[7] <= 8'b01111110; 
										  iconline[6] <= 8'b10000001;	
										  iconline[5] <= 8'b11111111;
										  iconline[4] <= 8'b00011000;
										  iconline[3] <= 8'b00011000;
										  iconline[2] <= 8'b11111111; 
										  iconline[1] <= 8'b10000001;	 
										  iconline[0] <= 8'b01111110; 
										end
							
							5: 	begin
										  iconline[7] <= 8'b00000000; 
										  iconline[6] <= 8'b00000000;	
										  iconline[5] <= 8'b00000000;
										  iconline[4] <= 8'b00000000;
										  iconline[3] <= 8'b00000000;
										  iconline[2] <= 8'b00000000; 
										  iconline[1] <= 8'b00000000;	 
										  iconline[0] <= 8'b00000000; 
										end
						endcase
						state <= 3;
					end else begin
					state <= 2;
					end
				end
			
		DRAWPET: begin //Draw pet
						case(count)
							0:	begin
									cmd <= 0;
									cmdindex <= 0;
									if (avail) begin
										count <= 1;
									end
								end
									
							1: begin
									data_in <= cmdline[cmdindex];
									if (avail) begin
										if (cmdindex < 1) begin
											cmdindex <= cmdindex + 1;
										end else begin
											count <= 2;
											dataindex <= 0;
											cmd <= 1;
										end
									end
								end
									
							2: begin
									data_in <= dataline[dataindex];
									if (avail) begin
										if (dataindex < 7) begin
											dataindex <= dataindex + 1;
										end else begin
											count <= 3;
											cmd <= 1;
											dataindex <= 7;
										end
									end
								end
								
							3: begin
									data_in <= dataline[dataindex];
									if (avail) begin
										if (dataindex > 0) begin
											dataindex <= dataindex - 1;
										end else begin
											count <= 4;
											cmd <= 0;
											cmdindex <= 2;
										end
									end
								end
									
							4: begin
									data_in <= cmdline[cmdindex];
									if (avail) begin
										if (cmdindex < 3) begin
											cmdindex <= cmdindex + 1;
										end else begin
											count <= 5;
											dataindex <= 8;
											cmd <= 1;
										end
									end
								end
									
							5: begin
									data_in <= dataline[dataindex];
									if (avail) begin
										if (dataindex < 15) begin
											dataindex <= dataindex + 1;
										end else begin
											count <= 6;
											cmd <= 1;
											dataindex <= 15;
										end
									end
								end
								
							6: begin
									data_in <= dataline[dataindex];
									if (avail) begin
										if (dataindex > 8) begin
											dataindex <= dataindex - 1;
										end else begin
											state <= 4;
											count <= 0;
											cmd <= 0;
										end
									end
								end
							endcase
						end
					
		DRAWICON: 	begin //Draw top icon
							case(count)
							0:	begin
									cmd <= 0;
									cmdindex <= 4;
									iconindex <= 0;
									if (avail) begin
										count <= 1;
									end
								end
									
							1: begin
									data_in <= cmdline[cmdindex];
									if (avail) begin
										if (cmdindex < 5) begin
											cmdindex <= cmdindex + 1;
										end else begin
											count <= 2;
											cmd <= 1;
										end
									end
								end
									
							2: begin
									data_in <= iconline[iconindex];
									if (avail) begin
										if (iconindex < 7) begin
											iconindex <= iconindex + 1;
										end else begin
											count <= 0;
											cmd <= 0;
											state <= 2;
										end
									end
								end
							endcase
						end
					
			endcase
       end
   end
endmodule
module FSM_pet (
	input clk,                	// sys. clk
   input reset,              	// rst in
	output mosi,               // master out slave in
   output sclk,          		// spi clk
   output cs,           		// chip Select
	output reg dc,					// data/command
	output lcd_rst
);

   reg [7:0] data_in;
   wire [7:0] data_out;

   reg start;
   wire busy;
   wire avail;

   wire [25:0] div_factor = 25000000;  // Factor de división fijo

	spi_master spi (
       .clk(clk),
       .reset(~reset),
       .data_in(data_in),
       .start(start),
       .div_factor(div_factor),
       .mosi(mosi),
       .sclk(sclk),
       .cs(cs),
       .data_out(data_out),
       .busy(busy),
       .avail(avail),
		 .lcd_rst(lcd_rst)
   );


	reg [7:0] memory4CommandSend [0:40];

	reg [5:0] mem_index = 0;
	
	reg [8:0] count = 0;
	
	reg [3:0] state = 0;
	
	reg [3:0] state_send = 0;
	
	reg row = 0;
	
	parameter INIT = 4'h0, WIPE = 4'h1, DRAWPET = 4'h2, DRAWICON = 4'h3, IDLE = 4'h4;

	initial begin
        memory4CommandSend[0] = 8'h21;
        memory4CommandSend[1] = 8'h90;
		  memory4CommandSend[3] = 8'h20;
		  memory4CommandSend[4] = 8'h0C;

        memory4CommandSend[8] = 8'hA6;			//37-45
		  memory4CommandSend[9] = 8'h42;	
		  memory4CommandSend[10] = 8'b00001110;
        memory4CommandSend[11] = 8'b00010001;
		  memory4CommandSend[12] = 8'b01100000;	
		  memory4CommandSend[13] = 8'b10000100;
        memory4CommandSend[14] = 8'b10110110;
		  memory4CommandSend[15] = 8'b10000101;	
        memory4CommandSend[16] = 8'b01100100; 
        memory4CommandSend[17] = 8'b00100100; 
		  memory4CommandSend[18] = 8'hA6;	
        memory4CommandSend[19] = 8'h43; 
        memory4CommandSend[20] = 8'b00001111; 
		  memory4CommandSend[21] = 8'b00010001;	
        memory4CommandSend[22] = 8'b10100001;
		  memory4CommandSend[23] = 8'b10101110;
		  memory4CommandSend[24] = 8'b01000001;
        memory4CommandSend[25] = 8'b00001001; 
		  memory4CommandSend[26] = 8'b10000110;	 
        memory4CommandSend[27] = 8'b10000010; 

    end

   always @(posedge clk) begin
		 if (~reset) begin
           start <= 0;
			  dc <= 0;
			  state_send <= 0;
       end else begin
			case(state)
				INIT: begin
							start <= 1;
							dc <= 0;
							state_send <= 0;
							mem_index <= 0;
							case (state_send)
								0:		begin
										data_in <= memory4CommandSend[mem_index];
										state_send <= 1;
										end
								1:		begin
										if (avail) begin
											mem_index <= mem_index + 1;
												if (mem_index > 4) begin
													state_send <= 2;
												end else begin
													state_send <= 0;
												end
										end
										end
								2:		begin
										state <= 4'h1;
										end
							endcase
						end
					
				WIPE: begin
							state_send <= 0;
							dc <= 1;
							case (state_send)
								0:		begin
										data_in <= 8'h0;
										state_send <= 1;
										end
								1:		begin
										if (avail) begin
											count <= count + 1;
												if (count > 504) begin
													state_send <= 2;
												end else begin
													state_send <= 0;
												end
										end
										end
								2:		begin
										state <= 4'h2;
										end
							endcase
						end
				
				DRAWPET:	begin
								state_send <= 0;
								dc <= 0;
								case (dc)
									0:	begin
										case (state_send)
											0:		begin
													if (row) begin	
														mem_index <= 18;
													end else begin
														mem_index <= 8;
													end
													data_in <= memory4CommandSend[mem_index];
													state_send <= 1;
													end
											1:		begin
													if (avail) begin
														mem_index <= mem_index + 1;
														if (row) begin	
															if (mem_index > 19) begin
																state_send <= 2;
															end else begin
																state_send <= 0;
															end
														end else begin
															if (mem_index > 9) begin
																state_send <= 2;
															end else begin
																state_send <= 0;
															end
														end
													end
													end
											2:		begin
													dc <= 1;
													end
										endcase
										end
									1:	begin
										state_send <= 0;
										count <= 0;
										case (state_send)
											0:		begin
													data_in <= memory4CommandSend[mem_index];
													if (count < 8) begin
													state_send <= 1;
													end else begin
													state_send <= 2;
													end
													end
											1:		begin
													if (avail) begin
														mem_index <= mem_index + 1;
														count <= count + 1;
														if (count > 7) begin
															state_send <= 2;
														end else begin
															state_send <= 0;
														end
													end
													end
											2:		begin
													if (avail) begin
														mem_index <= mem_index - 1;
														if (mem_index < 10) begin
															mem_index <= 18;
															state_send <= 0;
															row <= 1;
														end else begin
															if (row && mem_index < 20) begin
																mem_index <= 28;
																state_send <= 3;
															end else begin
																state_send <= 0;
															end
														end
													end
													end
											3:		begin
											start = 0;
													end
										endcase
										end
								endcase
							end
			endcase	
       end
   end
endmodule
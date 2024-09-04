module FSM_pet (
	input clk,                // Reloj del sistema
   input reset,              // Señal de reset
   input [1:0] state,      // Datos de entrada para enviar
	output mosi,               // Master Out Slave In
   output sclk,          // Reloj SPI
   output cs,           // Chip Select
	output reg dc,
	output reg lcd_rst
);
/*TODO: VALIDAR  QUE EL CS SE ACIVE PARA LOS 16 BITS  Y NO SOO OCHO */

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
       .avail(avail)
   );


	reg [7:0] memory4CommandSend [0:40];

	reg [5:0] mem_index = 0;

	reg sendByte;
	reg [10:0]state_send = 0;


	initial begin
        memory4CommandSend[0] = 8'h21;
        memory4CommandSend[1] = 8'hC0;
        memory4CommandSend[2] = 8'h06;
        memory4CommandSend[3] = 8'h13;
		  memory4CommandSend[4] = 8'h20;
		  memory4CommandSend[5] = 8'h0C;
		  memory4CommandSend[6] = 8'h22;
        memory4CommandSend[7] = 8'hB3; 


        memory4CommandSend[8] = 8'h12;			//37-45
		  memory4CommandSend[9] = 8'h05;	
		  memory4CommandSend[10] = 8'b00000001;
        memory4CommandSend[11] = 8'h12;
		  memory4CommandSend[12] = 8'h06;	
		  memory4CommandSend[13] = 8'b00000011;
        memory4CommandSend[14] = 8'h12;
		  memory4CommandSend[15] = 8'h07;	
        memory4CommandSend[16] = 8'b00000111; 
        memory4CommandSend[17] = 8'h12; 
		  memory4CommandSend[18] = 8'h08;	
        memory4CommandSend[19] = 8'b00001111; 
        memory4CommandSend[20] = 8'h12; 
		  memory4CommandSend[21] = 8'h09;	
        memory4CommandSend[22] = 8'b00011111;  
        memory4CommandSend[23] = 8'h12; 
		  memory4CommandSend[24] = 8'h0A;	 
        memory4CommandSend[25] = 8'b00111111;  
        memory4CommandSend[26] = 8'h12;
		  memory4CommandSend[27] = 8'h0B;	
        memory4CommandSend[28] = 8'b01111111; 
        memory4CommandSend[29] = 8'h12; 
		  memory4CommandSend[30] = 8'h0D;	
        memory4CommandSend[31] = 8'b11111111; 

    end

	reg [1:0] c2=0;
   always @(posedge clk) begin
		 if (~reset) begin
			  lcd_rst <= 0;
           state_send <= 0;
           sendByte <= 0;
			  mem_index <= 0;
       end else begin
			  lcd_rst <= 1;
		 case (state_send)
			0:	begin
				data_in <= memory4CommandSend[mem_index]; 
				sendByte <=1; 
				state_send <= 1;
				end
			1: begin
				state_send <= 2;
				end
			2: begin
				sendByte <= 0; 
				if (avail) begin
					state_send <= 0;	
   				mem_index <= mem_index + 1;
					if (mem_index > 21)begin
						  mem_index <= 7;	
						 state_send <= 3;	

					end
				end
				end
			3: begin 
				  mem_index <= 0;			
			end 
			endcase
			end
	end


	// para enviar un byte por spi
   always @(negedge clk) begin
		 if (~reset) begin
           start <= 0;
       end else begin
           case(start)
               0: begin  // IDLE
                   if (!busy && sendByte) begin
							if ((mem_index > 8) && ((mem_index - 10) % 3 == 0)) begin
								dc <= 1;
							end else begin
								dc <= 0;
							end
                       start <= 1;
                   end
               end
               1: begin  // SEND
                   if (avail) begin
                       start <= 0;
                   end
               end
           endcase
       end
   end
endmodule
module BCDtoSSeg (BCD, SSeg);

  input [4:0] BCD;
  output reg [0:6] SSeg;
always @ ( * ) begin
  case (BCD)
   5'd0: SSeg = 7'b0000001; 	// "0"  
	5'd1: SSeg = 7'b1001111; 	// "1" 
	5'd2: SSeg = 7'b0010010; 	// "2" 
	5'd3: SSeg = 7'b0000110; 	// "3" 
	5'd4: SSeg = 7'b1001100; 	// "4" 
	5'd5: SSeg = 7'b0100100; 	// "5" 
	5'd6: SSeg = 7'b0100000; 	// "6" 
	5'd7: SSeg = 7'b0001111; 	// "7" 
	5'd8: SSeg = 7'b0000000; 	// "8"  
	5'd9: SSeg = 7'b0001100; 	// "9" 
   5'd10: SSeg = 7'b1001000;  // "H" 
   5'd11: SSeg = 7'b0001001;	// "N" 
   5'd12: SSeg = 7'b0000100;	// "G"
   5'd13: SSeg = 7'b0100100;	// "S"
   5'd14: SSeg = 7'b1110001;	// "L"
   5'd15: SSeg = 7'b0011000;	// "P"
   5'd16: SSeg = 7'b1100000;  // "B" 
   5'd17: SSeg = 7'b1110000;	// "T" 
   5'd18: SSeg = 7'b0111000;	// "F"
   5'd19: SSeg = 7'b1000001;	// "U"
   5'd20: SSeg = 7'b1001111;	// "I"
   5'd21: SSeg = 7'b1000010;	// "D"
   5'd22: SSeg = 7'b0110000;	// "E"
   5'd23: SSeg = 7'b0001000;	// "A"
   default:
   SSeg = 7'b1111110;
  endcase
end

endmodule

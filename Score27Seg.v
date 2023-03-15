module Score27Seg(Score, Leds, adrive);
	output reg [0:6] Leds = 0;
	output reg [3:0] adrive = 4'b1110;
	input  [2:0] Score;
	
	always@(Score)
	begin
		case(Score)
			3'b000: begin Leds = 7'b000_0001; end//Zero
			3'b001: begin Leds = 7'b100_1111; end//One
			3'b010: begin Leds = 7'b001_0010; end//Two
			3'b011: begin Leds = 7'b000_0110; end//Three
			3'b100: begin Leds = 7'b100_1100; end//Four 
			3'b101: begin Leds = 7'b010_0100; end//Five
			3'b110: begin Leds = 7'b010_0000; end//Six
			3'b111: begin Leds = 7'b000_1111; end//Seven
			default: begin Leds = 7'b111_1111; end//Default: blank if not 0-9 value
		endcase
    end
endmodule 
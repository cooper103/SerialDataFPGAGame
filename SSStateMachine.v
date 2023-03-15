// SSStateMachine.v
// Allows user to reset system with SW0 or say "Go" with center button
//   as defined in xdc file
// Input Done comes from GRBStateMachine when it's sent all the bits
//   but not RESET yet 
// Input allDone comes from GRBStateMachine when it's sent the RESET code
// Incorporates debouncing delay for the button
// Output shipGRB tells GRBStateMachine to keep sending data bits 
// Updated to support new WS2812B reset code of > 280 us

module SSStateMachine(shipGRB,Done,Go,clk,reset,allDone,Ready2Go,Game,Auto,GRBAuto,sw[15:14], col, Score);
	output	shipGRB, Ready2Go;
	input	allDone, Done, Go;
	input	clk, reset, Game, Auto;
	input [15:14] sw;
	
    //Main
    reg [31:0] Store;
	reg [1:0]	S, nS;
	parameter	SWAIT=2'b00, SSHIP=2'b01, SRET=2'b10, SDBOUNCE=2'b11;
	
	//Auto
	output reg [11:0] GRBAuto; //this specifies the GRB values on Auto setting
	reg [31:0] change;
	reg pulse = 0;
	
	//Game
	reg pulse2 = 0;
	reg [31:0] GStore;
	parameter t = 50000000, x = 3024, GREEN = 12'b1000_0000_0000, BLUE = 12'b0000_0000_1000, RED = 12'b0000_1000_0000, YELLOW = 12'b1000_1000_0000, BLANK = 12'b0000_0000_0000, WHITE = 12'b1111_1111_1111_1111;
	reg [31:0] GChange = 50000000;
	reg GS, GnS;
	reg [11:0] random;
	output reg [11:0] col;
	output reg [2:0] Score = 0;
	wire taps;

	reg [1:3] nQ;
	reg [1:3] Q = 3'b011;
	wire GoDB;
	
	debouncing db(clk,Go,GoDB);
	
	always@(posedge pulse2) Q <= nQ;
	always@(taps, Q) nQ = {taps, Q[1:2]};
	assign taps =Q[3] ^ Q[2];
	
	always@(negedge GoDB)
	   if(Game) begin
	       if(col == GREEN) begin
	           Score <= Score + 1;
	       end
	       else
	           Score <= 0; 
	   end
	
	always@(Score) begin
	   case(Score)
	       3'b000: GChange = 50000000;
	       3'b001: GChange = 45000000;
	       3'b010: GChange = 40000000;
	       3'b011: GChange = 35000000;
	       3'b100: GChange = 30000000;
	       3'b101: GChange = 25000000;
	       3'b110: GChange = 10000000;
	       3'b111: GChange = 1000000;
	   endcase
    end
	
	always @(posedge clk)
		if(reset)
			S <= SWAIT;
		else begin
			S <= nS;
			if(Auto)
                if(Store >= change) begin
                     Store <= 0;
                     pulse <= 1;
                     GRBAuto <= GRBAuto + 1;
                end
                else begin
                     Store <= Store + 1;
                     pulse <= 0;
                end
            else if(Game)
                if(GStore >= GChange) begin
                    pulse2 <= ~pulse2;
                    GStore <= 0;
                end
            else begin
                GStore <= GStore + 1;
            end
	end	
		
    always@(posedge pulse2) begin
        if (Q<3'd2)random = YELLOW;
        else if (Q < 3'd4) random = BLUE;
        else if (Q < 3'd6) random = RED;
        else random = GREEN;
        if(reset)
            GS <= 1'b0;
        else begin
            GS <= GnS;
            case(GS)
                1'b0: col = BLANK;
                1'b1: col = random;
            endcase
        end
    end
    
	always@(S, Go, Done, allDone, Game, Auto, pulse, sw[15:14], GS, GoDB) 
	   if(Auto) begin
	       //Adjustable Speed Settings
	       case(sw[15:14])
		      2'b00: change = 10000000;
		      2'b01: change = 20000000;
		      2'b10: change = 50000000;
		      2'b11: change = 100000000;
		   endcase
		   case(pulse)
		      1'b0: nS = SWAIT;
		      1'b1: nS = SSHIP;
	       endcase 
	    end 
	    else if(Game) begin
	       case(S)
			SWAIT: 		nS = pulse2      ? SSHIP    : SWAIT;
			SSHIP:		nS = Done    ? SRET     : SSHIP;
            SRET:		nS = allDone ? SDBOUNCE : SRET;
			SDBOUNCE:	nS = pulse2      ? SDBOUNCE : SWAIT;
			default:	nS = SWAIT;
		endcase
	       if(pulse2) GnS = GS + 1;
	    end
	    else begin
		case(S)
			SWAIT: 		nS = Go      ? SSHIP    : SWAIT;
			SSHIP:		nS = Done    ? SRET     : SSHIP;
            SRET:		nS = allDone ? SDBOUNCE : SRET;
			SDBOUNCE:	nS = Go      ? SDBOUNCE : SWAIT;
			default:	nS = SWAIT;
		endcase
    end

  assign Ready2Go = (S==SWAIT);  // okay to press Go
  assign shipGRB  = (S==SSHIP);  // send data bits
  
endmodule

`timescale 1ns / 1ps

module debouncing #(parameter threshold = 100000)
(input clk,
input btn,
output reg dbsig);

reg button_ff1 = 0;
reg button_ff2 = 0; 
reg [20:0]count = 0;

always @(posedge clk)begin
button_ff1 <= btn;
button_ff2 <= button_ff1;
end

always @(posedge clk) begin

if (button_ff2) begin
    if (~&count)
        count <= count+1;
end 
else begin
    if (|count)
        count <= count-1;
end

if (count > threshold)
    dbsig <= 1;
else
    dbsig <= 0;
end

endmodule

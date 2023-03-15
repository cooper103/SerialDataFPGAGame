// SimpleSend.v
// top-level module for WS2812B LED strip
// VERY basic design, sends same color to all modules
// Updated to support new WS2812B reset code of > 280 us

module SimpleSend(dataOut,sw,NumLEDs,Go,clk,reset,Ready2Go, Leds, adrive);
	output	dataOut, Ready2Go;
	input   [15:4] sw;
	input   [3:1]  NumLEDs;
	input	Go, clk, reset;
	output [0:6] Leds;
	output [3:0] adrive;
    
    wire [2:0] Score;
    wire [11:0] GRBAuto, col;
    wire        Game, Auto, Win;
	wire		shipGRB, Done, allDone;
	wire [1:0]	qmode;
	wire		LoadGRBPattern, ShiftPattern, StartCoding, ClrCounter, IncCounter, theBit, bdone;
	wire [7:0]	Count;

	SSStateMachine	sssm(shipGRB,Done,Go,clk,reset,allDone,Ready2Go,Game,Auto,GRBAuto,sw[15:14], col, Score);
	GRBStateMachine grbsm(qmode,Done,LoadGRBPattern,ShiftPattern,StartCoding,ClrCounter,IncCounter,
                              shipGRB,theBit,bdone,Count,NumLEDs,clk,reset,allDone, Game, Auto);
	ShiftRegister   shftr(theBit,sw,LoadGRBPattern,ShiftPattern,clk,reset, Game, Auto, GRBAuto, col);
	BitCounter	btcnt(Count,ClrCounter,IncCounter,clk,reset);
	NZRbitGEN	nzrgn(dataOut,bdone,qmode,StartCoding,clk,reset);
	Score27Seg scoreleds(Score, Leds, adrive);
endmodule

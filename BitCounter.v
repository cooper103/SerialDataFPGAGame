// BitCounter.v
// Just a simple 8-bit synchronous counter
// Main inputs and outputs connect to GRBStateMachine
// Value of output Count keeps track of how many bits have been sent
// This implies a max of 10 LED modules could be used (240 bits)
// For longer LED strips, increase the bit width of the counter

module BitCounter(Count,ClearCounter,IncCounter,clk,reset);
  output  [7:0] Count;
  input   ClearCounter, IncCounter;
  input   clk, reset;

  reg [7:0] Count, nCount;

  always @(posedge clk)
    if(reset) Count <= 0;
    else Count <= nCount;

  always @(reset, Count, ClearCounter, IncCounter)
    if(reset || ClearCounter)
      nCount = 0;
    else if(IncCounter)
      nCount = Count+1;
    else
      nCount = Count;
endmodule

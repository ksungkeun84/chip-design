`timescale 1ns/100ps
module board;
wire [3:0] cnt;
wire clk;

m16 counter(cnt,clk);
m555 clockGen(clk);

initial begin
  $dumpfile("board.vcd");
  $dumpvars(0, board);
  #500 $finish;
end
endmodule

module m16(output reg[3:0] ctr = 1, input clk);
always @(posedge clk) ctr <= ctr + 1;
endmodule

module m555(output reg clk);

initial #1 clk = 1;

always begin
  #60 clk = ~clk;
  #60 clk = ~clk;
  #15 clk = ~clk;
  #15 clk = ~clk;
end
endmodule

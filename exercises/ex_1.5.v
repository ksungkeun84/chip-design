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

module m555(output clk);
wire one;
assign one = 1;
//or #1 o(clk, clk, one);
not #50 n(clk, clk);
endmodule

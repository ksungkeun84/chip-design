`include "../util/clock_gen.v"
`include "lfsr.v"

module lfsr_tb;

// Clock
reg clk_enable;
wire clk;
clock_gen #(.FREQ(200000)) clk_gen(clk_enable, clk);
initial begin
  clk_enable <= 1;
end

// dump waveform
initial begin
  $dumpfile("lfsr_tb.vcd");
  $dumpvars(0, lfsr_tb);
end

// lfsr
reg rst;
reg   [3:0] seed;
wire  [3:0] out;

LFSR #(.WIDTH(4)) uut (.clk(clk), .rst(rst), .seed(seed), .out(out));

initial begin
  seed    <= 4'b1111;
  #5 rst  <= 0;
  #5 rst  <= 1;

  #100 $finish;
end

endmodule

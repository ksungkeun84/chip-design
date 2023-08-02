
module serialAdder_tb;

// clk
reg clk;
initial begin
  $dumpfile("serialAdder.vcd");
  $dumpvars(0, serialAdder_tb);
  #1 clk = 1;
end
always #5 clk = ~clk;

reg start;
reg [3:0] A, B;
reg a, b;
wire s;
reg sum;
serialAdder sa(clk, start, a, b, s);

initial begin
  #1
  start = 1;
  A = 4'b1111;
  B = 4'b0001;
  a = A[0];
  b = B[0];

  @(posedge clk);
  a <= A[1];
  b <= B[1];

  @(posedge clk);
  a <= A[2];
  b <= B[2];

  @(posedge clk);
  a <= A[3];
  b <= B[3];

  #10 $finish;
end

always @(negedge clk) sum <= s;
endmodule


module serialAdder(
  input clk, start, a, b,
  output sum);

reg cin;
initial cin = 0;

reg nextCin;
always @(start, cout) begin
  nextCin = 0;
  if (start) nextCin = cout;
end

always @(negedge clk) cin <= nextCin;

wire cout;
fullAdder fa(a, b, cin, sum, cout);

endmodule

module fullAdder(
  input a, b, cin,
  output reg sum, cout);

always @(a, b, cin) begin
  {cout, sum} <= a + b + cin;
end
endmodule

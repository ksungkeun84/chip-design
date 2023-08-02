
module counter_2bit_tb;

reg clk;
always #50 clk = ~clk;

reg rst, up;
wire [1:0] counter;
counter_2bit uut(clk, rst, up, counter);

initial  begin

  $dumpfile("counter_2bit.vcd");
  $dumpvars(0, counter_2bit_tb);
  //$monitor ($time,, "Counter %d up %d", counter, up);
  #5 up = 1;
  #5 clk = 1;
  #5 rst = 0;
  #5 rst = 1;

  //#5 up = 0;
  //#5 up = 0;
  //#5 up = 1;
  //#5 up = 0;
  //#5 up = 1;
  //#5 up = 1;
  //#5 up = 1;
  //#5 up = 1;
  //#5 up = 0;
  //#5 up = 0;
  #500 $finish;
end



endmodule

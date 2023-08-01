module DW01_addsub_oper(in1,in2,ctl,sum);
  parameter wordlength = 8;

  input [wordlength-1:0] in1,in2;
  input ctl;
  output [wordlength-1:0] sum;
  reg [wordlength-1:0] sum;

  always @(in1 or in2 or ctl)
  begin
    if (ctl == 0) 
      sum = in1 + in2;
    else
      sum = in1 - in2;
  end
endmodule

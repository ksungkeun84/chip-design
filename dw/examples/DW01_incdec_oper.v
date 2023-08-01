module DW01_incdec_oper(in1,inc_dec,sum);
  parameter wordlength = 8;

  input [wordlength-1:0] in1;
  input inc_dec;
  output [wordlength-1:0] sum;
  reg [wordlength-1:0] sum;

always @(in1 or inc_dec)
begin
  if (inc_dec == 1)
    sum = in1 - 1;
  else
    sum = in1 + 1;
  end
endmodule

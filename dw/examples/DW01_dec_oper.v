module DW01_dec_oper(in,sum);
  parameter wordlength = 8;

  input [wordlength-1:0] in;
  output [wordlength-1:0] sum;
 
  assign  sum = in - 1;
endmodule

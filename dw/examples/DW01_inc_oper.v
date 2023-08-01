module DW01_inc_oper(in1,sum);
  parameter wordlength = 8;

  input [wordlength-1:0] in1;
  output [wordlength-1:0] sum;
 
  assign  sum = in1 + 1;
endmodule


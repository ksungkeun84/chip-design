module DW01_sub_oper(in1,in2,diff);
  parameter wordlength = 8;

  input [wordlength-1:0] in1,in2;
  output [wordlength-1:0] diff;
 
  assign  diff = in1 - in2;
endmodule


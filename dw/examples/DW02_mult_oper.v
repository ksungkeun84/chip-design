module DW02_mult_oper (in1, in2, control, product);
  parameter wordlength1 = 8, wordlength2 = 8;
  input [wordlength1-1:0] in1; 
  input [wordlength2-1:0] in2; 
  input control; 

  output [wordlength1+wordlength2-1:0] product;
  wire signed [wordlength1+wordlength2-1:0] product_sig; 
  wire [wordlength1+wordlength2-1:0] product_usig;

  assign product_sig = $signed(in1) * $signed(in2); 
  assign product_usig = in1 * in2;
  assign product = (control == 1'b1) ? $unsigned(product_sig) : product_usig;
endmodule

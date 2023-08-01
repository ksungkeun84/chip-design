module DW_div_oper (a, b, quotient_uns, quotient_tc, remainder_uns,
                    remainder_tc);
  parameter width = 8;

  input [width-1 : 0] a, b; 
  output [width-1 : 0] quotient_uns, remainder_uns; 
  output signed [width-1 : 0] quotient_tc, remainder_tc;
  // operators for unsigned/signed quotient and remainder 
  assign quotient_uns = a / b; 
  assign quotient_tc = $signed(a) / $signed(b); 
  assign remainder_uns = a % b; 
  assign remainder_tc = $signed(a) % $signed(b);
endmodule

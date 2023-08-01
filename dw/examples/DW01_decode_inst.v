module DW01_decode_inst( inst_A, B_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  output [(1<<width)-1 : 0] B_inst;

  // Instance of DW01_decode
  DW01_decode #(width)
    U1 ( .A(inst_A), .B(B_inst) );

endmodule

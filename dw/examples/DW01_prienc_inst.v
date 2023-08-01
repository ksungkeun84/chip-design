module DW01_prienc_inst( inst_A, INDEX_inst );

  parameter A_width = 8;
  parameter INDEX_width = 4;

  input [A_width-1 : 0] inst_A;
  output [INDEX_width-1 : 0] INDEX_inst;

  // Instance of DW01_prienc
  DW01_prienc #(A_width, INDEX_width)
    U1 ( .A(inst_A), .INDEX(INDEX_inst) );

endmodule


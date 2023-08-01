module DW01_incdec_inst( inst_A, inst_INC_DEC, SUM_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  input inst_INC_DEC;
  output [width-1 : 0] SUM_inst;

  // Instance of DW01_incdec
  DW01_incdec #(width)
    U1 ( .A(inst_A), .INC_DEC(inst_INC_DEC), .SUM(SUM_inst) );
endmodule

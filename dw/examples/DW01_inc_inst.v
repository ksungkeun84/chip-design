module DW01_inc_inst( inst_A, SUM_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  output [width-1 : 0] SUM_inst;

  // Instance of DW01_inc
  DW01_inc #(width)
    U1 ( .A(inst_A), .SUM(SUM_inst) );

endmodule

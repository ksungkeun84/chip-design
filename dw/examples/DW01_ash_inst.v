module DW01_ash_inst( inst_A, inst_DATA_TC, inst_SH, inst_SH_TC, B_inst );

  parameter A_width = 8;
  parameter SH_width = 8;

  input [A_width-1 : 0] inst_A;
  input inst_DATA_TC;
  input [SH_width-1 : 0] inst_SH;
  input inst_SH_TC;
  output [A_width-1 : 0] B_inst;

  // Instance of DW01_ash
  DW01_ash #(A_width, SH_width)
    U1 (.A(inst_A), .DATA_TC(inst_DATA_TC), .SH(inst_SH), 
        .SH_TC(inst_SH_TC), .B(B_inst) );

endmodule

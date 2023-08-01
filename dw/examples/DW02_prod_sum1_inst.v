module DW02_prod_sum1_inst( inst_A, inst_B, inst_C, inst_TC, SUM_inst );

  parameter A_width = 5;
  parameter B_width = 5;
  parameter SUM_width = 11;

  input [A_width-1 : 0] inst_A;
  input [B_width-1 : 0] inst_B;
  input [SUM_width-1 : 0] inst_C;
  input inst_TC;
  output [SUM_width-1 : 0] SUM_inst;

  // Instance of DW02_prod_sum1
  DW02_prod_sum1 #(A_width, B_width, SUM_width)
    U1 ( .A(inst_A), .B(inst_B), .C(inst_C), .TC(inst_TC), .SUM(SUM_inst) );

endmodule


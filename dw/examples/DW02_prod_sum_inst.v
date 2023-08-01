module DW02_prod_sum_inst( inst_A, inst_B, inst_TC, SUM_inst );

  parameter A_width = 5;
  parameter B_width = 5;
  parameter num_inputs = 3;
  parameter SUM_width = 12;

  input [num_inputs*A_width-1 : 0] inst_A;
  input [num_inputs*B_width-1 : 0] inst_B;
  input inst_TC;
  output [SUM_width-1 : 0] SUM_inst;

  // Instance of DW02_prod_sum
  DW02_prod_sum #(A_width, B_width, num_inputs, SUM_width)
    U1 ( .A(inst_A), .B(inst_B), .TC(inst_TC), .SUM(SUM_inst) );

endmodule


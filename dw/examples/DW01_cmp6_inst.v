module DW01_cmp6_inst( inst_A, inst_B, inst_TC, LT_inst, GT_inst, 
                       EQ_inst, LE_inst, GE_inst, NE_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  input [width-1 : 0] inst_B;
  input inst_TC;
  output LT_inst;
  output GT_inst;
  output EQ_inst;
  output LE_inst;
  output GE_inst;
  output NE_inst;

  // Instance of DW01_cmp6
  DW01_cmp6 #(width)
    U1 ( .A(inst_A), .B(inst_B), .TC(inst_TC), .LT(LT_inst), .GT(GT_inst),
         .EQ(EQ_inst), .LE(LE_inst), .GE(GE_inst), .NE(NE_inst) );

endmodule


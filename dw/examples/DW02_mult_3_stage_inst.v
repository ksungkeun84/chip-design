module DW02_mult_3_stage_inst( inst_A, inst_B, inst_TC, 
                               inst_CLK, PRODUCT_inst );

  parameter A_width = 8;
  parameter B_width = 8;

  input [A_width-1 : 0] inst_A;
  input [B_width-1 : 0] inst_B;
  input inst_TC;
  input inst_CLK;
  output [A_width+B_width-1 : 0] PRODUCT_inst;

  // Instance of DW02_mult_3_stage
  DW02_mult_3_stage #(A_width, B_width)
    U1 ( .A(inst_A), .B(inst_B), .TC(inst_TC), 
         .CLK(inst_CLK), .PRODUCT(PRODUCT_inst) );

endmodule


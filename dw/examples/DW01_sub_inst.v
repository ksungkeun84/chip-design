module DW01_sub_inst( inst_A, inst_B, inst_CI, DIFF_inst, CO_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  input [width-1 : 0] inst_B;
  input inst_CI;
  output [width-1 : 0] DIFF_inst;
  output CO_inst;

  // Instance of DW01_sub
  DW01_sub #(width)
    U1 ( .A(inst_A),   .B(inst_B),   .CI(inst_CI), 
         .DIFF(DIFF_inst),   .CO(CO_inst) );

endmodule


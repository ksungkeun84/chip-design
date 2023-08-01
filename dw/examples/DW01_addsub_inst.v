module DW01_addsub_inst( inst_A, inst_B, inst_CI, inst_ADD_SUB, 
                         SUM_inst, CO_inst );

  parameter width = 8;

  input [width-1 : 0] inst_A;
  input [width-1 : 0] inst_B;
  input inst_CI;
  input inst_ADD_SUB;
  output [width-1 : 0] SUM_inst;
  output CO_inst;

  // Instance of DW01_addsub
  DW01_addsub #(width)
    U1 ( .A(inst_A), .B(inst_B), .CI(inst_CI), .ADD_SUB(inst_ADD_SUB), 
         .SUM(SUM_inst), .CO(CO_inst) );

endmodule


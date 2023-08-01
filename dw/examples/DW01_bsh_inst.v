module DW01_bsh_inst( inst_A, inst_SH, B_inst );

  parameter A_width = 8;
  parameter SH_width = 3;

  input [A_width-1 : 0] inst_A;
  input [SH_width-1 : 0] inst_SH;
  output [A_width-1 : 0] B_inst;

    // Instance of DW01_bsh
  DW01_bsh #(A_width, SH_width)
    U1 ( .A(inst_A), .SH(inst_SH), .B(B_inst) );

endmodule


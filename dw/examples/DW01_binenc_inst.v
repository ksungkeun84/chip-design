module DW01_binenc_inst( inst_A, ADDR_inst );
  parameter A_width = 8;
  parameter ADDR_width = 4;

  input [A_width-1 : 0] inst_A;
  output [ADDR_width-1 : 0] ADDR_inst;

  // Instance of DW01_binenc
  DW01_binenc #(A_width, ADDR_width)
    U1 ( .A(inst_A), .ADDR(ADDR_inst) );

endmodule


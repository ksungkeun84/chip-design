module DW01_mux_any_inst( inst_A, inst_SEL, MUX_inst );

  parameter A_width = 8;
  parameter SEL_width = 8;
parameter MUX_width = 8;

  input [A_width-1 : 0] inst_A;
  input [SEL_width-1 : 0] inst_SEL;
  output [MUX_width-1 : 0] MUX_inst;

    // Instance of DW01_mux_any
    DW01_mux_any #(A_width, SEL_width, MUX_width)
      U1 ( .A(inst_A), .SEL(inst_SEL), .MUX(MUX_inst) );

endmodule

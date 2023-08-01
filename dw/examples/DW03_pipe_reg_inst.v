module DW03_pipe_reg_inst( inst_A, inst_clk, B_inst );

  parameter depth = 8;
  parameter width = 8;

  input [width-1 : 0] inst_A;
  input inst_clk;
  output [width-1 : 0] B_inst;

  // Instance of DW03_pipe_reg
  DW03_pipe_reg #(depth, width)
    U1 ( .A(inst_A), .clk(inst_clk), .B(B_inst) );
endmodule

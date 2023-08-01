module DW03_reg_s_pl_inst( inst_d, inst_clk, inst_reset_N, 
                           inst_enable, q_inst );

  parameter width = 8;
  parameter reset_value = 0;

  input [width-1 : 0] inst_d;
  input inst_clk;
  input inst_reset_N;
  input inst_enable;
  output [width-1 : 0] q_inst;

  // Instance of DW03_reg_s_pl
  DW03_reg_s_pl #(width, reset_value)
    U1 ( .d(inst_d), .clk(inst_clk), .reset_N(inst_reset_N),
         .enable(inst_enable), .q(q_inst) );

endmodule


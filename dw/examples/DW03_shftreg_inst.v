module DW03_shftreg_inst( inst_clk, inst_s_in, inst_p_in, 
                          inst_shift_n, inst_load_n,  p_out_inst );

  parameter length = 4;

  input inst_clk;
  input inst_s_in;
  input [length-1 : 0] inst_p_in;
  input inst_shift_n;
  input inst_load_n;
  output [length-1 : 0] p_out_inst;

  // Instance of DW03_shftreg
  DW03_shftreg #(length)
    U1 (.clk(inst_clk),   .s_in(inst_s_in),   .p_in(inst_p_in),
        .shift_n(inst_shift_n),   .load_n(inst_load_n),  .p_out(p_out_inst));

endmodule


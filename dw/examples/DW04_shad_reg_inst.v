module DW04_shad_reg_inst( inst_datain, inst_sys_clk, inst_shad_clk,
                           inst_reset, inst_SI, inst_SE, sys_out_inst,
                           shad_out_inst, SO_inst );

  parameter width = 8;
  parameter bld_shad_reg = 1;

  input [width-1 : 0] inst_datain;
  input inst_sys_clk;
  input inst_shad_clk;
  input inst_reset;
  input inst_SI;
  input inst_SE;
  output [width-1 : 0] sys_out_inst;
  output [width-1 : 0] shad_out_inst;
  output SO_inst;

  // Instance of DW04_shad_reg
  DW04_shad_reg #(width, bld_shad_reg)
    U1 ( .datain(inst_datain),   .sys_clk(inst_sys_clk),
         .shad_clk(inst_shad_clk),   .reset(inst_reset),   .SI(inst_SI),
         .SE(inst_SE),   .sys_out(sys_out_inst),   .shad_out(shad_out_inst),
         .SO(SO_inst) );

endmodule


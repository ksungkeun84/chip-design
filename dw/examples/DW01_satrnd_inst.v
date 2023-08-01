module DW01_satrnd_inst( inst_din, inst_tc, inst_sat, inst_rnd, 
                         ov_inst, dout_inst );

  parameter width = 8;
  parameter msb_out = 7;
  parameter lsb_out = 1;

  input [width-1 : 0] inst_din;
  input inst_tc;
  input inst_sat;
  input inst_rnd;
  output ov_inst;
  output [msb_out-lsb_out : 0] dout_inst;

  // Instance of DW01_satrnd
  DW01_satrnd #(width, msb_out, lsb_out)
    U1 ( .din(inst_din),   .tc(inst_tc),   .sat(inst_sat),
         .rnd(inst_rnd),   .ov(ov_inst),   .dout(dout_inst) );

endmodule


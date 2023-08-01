module DW_fp_sqrt_inst( inst_a, inst_rnd, z_inst, status_inst );

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;


input [inst_sig_width+inst_exp_width : 0] inst_a;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;

  // Instance of DW_fp_sqrt
  DW_fp_sqrt #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U1 (
                      .a(inst_a),
                      .rnd(inst_rnd),
                      .z(z_inst),
                      .status(status_inst) );

endmodule

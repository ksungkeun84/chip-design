module DW_lp_fp_multifunc_inst( inst_a, inst_func, inst_rnd, z_inst, status_inst );

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_func_select = 127;
parameter inst_faithful_round = 1;
parameter inst_pi_multiple = 1;


input [inst_sig_width+inst_exp_width : 0] inst_a;
input [15 : 0] inst_func;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_lp_fp_multifunc
    DW_lp_fp_multifunc #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_func_select, inst_faithful_round, inst_pi_multiple) U1 (
			.a(inst_a),
			.func(inst_func),
			.rnd(inst_rnd),
			.z(z_inst),
			.status(status_inst) );

endmodule

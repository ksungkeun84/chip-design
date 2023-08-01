module DW_lp_fp_multifunc_DG_inst( inst_a, inst_func, inst_rnd, inst_DG_ctrl, z_inst, status_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;
parameter func_select = 127;
parameter faithful_round = 1;
parameter pi_multiple = 1;

input [sig_width+exp_width : 0] inst_a;
input [15 : 0] inst_func;
input [2 : 0] inst_rnd;
input inst_DG_ctrl;
output [sig_width+exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_lp_fp_multifunc_DG
    DW_lp_fp_multifunc_DG #(sig_width, exp_width, ieee_compliance, func_select, faithful_round, pi_multiple) U1 (
			.a(inst_a),
			.func(inst_func),
			.rnd(inst_rnd),
			.DG_ctrl(inst_DG_ctrl),
			.z(z_inst),
			.status(status_inst) );

endmodule

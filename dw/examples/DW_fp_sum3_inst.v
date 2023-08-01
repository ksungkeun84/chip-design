module DW_fp_sum3_inst( inst_a, inst_b, inst_c, inst_rnd, z_inst, 
		status_inst );

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;


input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [inst_sig_width+inst_exp_width : 0] inst_c;
input [2 : 0] inst_rnd;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_fp_sum3
    DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type) U1 (
			.a(inst_a),
			.b(inst_b),
			.c(inst_c),
			.rnd(inst_rnd),
			.z(z_inst),
			.status(status_inst) );

endmodule

module DW_fp_sum3_DG_inst( inst_a, inst_b, inst_c, inst_rnd, inst_DG_ctrl, 
		z_inst, status_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;
parameter arch_type = 0;


input [sig_width+exp_width : 0] inst_a;
input [sig_width+exp_width : 0] inst_b;
input [sig_width+exp_width : 0] inst_c;
input [2 : 0] inst_rnd;
input inst_DG_ctrl;
output [sig_width+exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_fp_sum3_DG
    DW_fp_sum3_DG #(sig_width, exp_width, ieee_compliance, arch_type)
	  U1 ( .a(inst_a), .b(inst_b), .c(inst_c), .rnd(inst_rnd), .DG_ctrl(inst_DG_ctrl), .z(z_inst), .status(status_inst) );

endmodule

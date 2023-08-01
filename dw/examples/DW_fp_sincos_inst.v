module DW_fp_sincos_inst( inst_a, inst_sin_cos, z_inst, status_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;
parameter pi_multiple = 1;
parameter arch = 0;
parameter err_range = 1;

input [sig_width+exp_width : 0] inst_a;
input inst_sin_cos;
output [sig_width+exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_fp_sincos
    DW_fp_sincos #(sig_width, exp_width, ieee_compliance, pi_multiple, arch, err_range)
	  U1 ( .a(inst_a), .sin_cos(inst_sin_cos), .z(z_inst), .status(status_inst) );

endmodule

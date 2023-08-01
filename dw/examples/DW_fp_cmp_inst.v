module DW_fp_cmp_inst( inst_a, inst_b, inst_zctr, aeqb_inst, altb_inst, 
		agtb_inst, unordered_inst, z0_inst, z1_inst, status0_inst, 
		status1_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;


input [sig_width+exp_width : 0] inst_a;
input [sig_width+exp_width : 0] inst_b;
input inst_zctr;
output aeqb_inst;
output altb_inst;
output agtb_inst;
output unordered_inst;
output [sig_width+exp_width : 0] z0_inst;
output [sig_width+exp_width : 0] z1_inst;
output [7 : 0] status0_inst;
output [7 : 0] status1_inst;

    // Instance of DW_fp_cmp
    DW_fp_cmp #(sig_width, exp_width, ieee_compliance)
	  U1 ( .a(inst_a), .b(inst_b), .zctr(inst_zctr), .aeqb(aeqb_inst), 
		.altb(altb_inst), .agtb(agtb_inst), .unordered(unordered_inst), 
		.z0(z0_inst), .z1(z1_inst), .status0(status0_inst), 
		.status1(status1_inst) );

endmodule

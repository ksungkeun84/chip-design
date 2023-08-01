module DW_norm_inst( inst_a, inst_exp_offset, no_detect_inst, ovfl_inst, b_inst, 
		exp_adj_inst );

parameter a_width = 8;
parameter srch_wind = 8;
parameter exp_width = 4;


input [a_width-1 : 0] inst_a;
input [exp_width-1 : 0] inst_exp_offset;
output no_detect_inst;
output ovfl_inst;
output [a_width-1 : 0] b_inst;
output [exp_width-1 : 0] exp_adj_inst;

    // Instance of DW_norm
    DW_norm #(a_width, srch_wind, exp_width)
	  U1 ( .a(inst_a), .exp_offset(inst_exp_offset), .no_detect(no_detect_inst), .ovfl(ovfl_inst), .b(b_inst), .exp_adj(exp_adj_inst) );

endmodule


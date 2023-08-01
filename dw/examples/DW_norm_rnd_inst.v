module DW_norm_rnd_inst( inst_a_mag, inst_pos_offset, inst_sticky_bit, inst_a_sign, inst_rnd_mode, 
		pos_err_inst, no_detect_inst, b_inst, pos_inst );

parameter a_width = 16;
parameter srch_wind = 4;
parameter exp_width = 4;
parameter b_width = 10;
parameter exp_ctr = 0;


input [a_width-1 : 0] inst_a_mag;
input [exp_width-1 : 0] inst_pos_offset;
input inst_sticky_bit;
input inst_a_sign;
input [2 : 0] inst_rnd_mode;
output pos_err_inst;
output no_detect_inst;
output [b_width-1 : 0] b_inst;
output [exp_width-1 : 0] pos_inst;

    // Instance of DW_norm_rnd
    DW_norm_rnd #(a_width, srch_wind, exp_width, b_width, exp_ctr)
	  U1 ( .a_mag(inst_a_mag), .pos_offset(inst_pos_offset), .sticky_bit(inst_sticky_bit), .a_sign(inst_a_sign), .rnd_mode(inst_rnd_mode), .pos_err(pos_err_inst), .no_detect(no_detect_inst), .b(b_inst), .pos(pos_inst) );

endmodule

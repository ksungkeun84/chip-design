module DW_lsd_inst( inst_a, enc_inst, dec_inst );

parameter inst_a_width = 8;

`define bit_width_a_width 3	// set to ceil(log2(a_width))

input [inst_a_width-1 : 0] inst_a;
output [`bit_width_a_width-1 : 0] enc_inst;
output [inst_a_width-1 : 0] dec_inst;

    // Instance of DW_lsd
    DW_lsd #(inst_a_width) U1 (
			.a(inst_a),
			.enc(enc_inst),
			.dec(dec_inst) );

endmodule

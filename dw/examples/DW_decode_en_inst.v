module DW_decode_en_inst( inst_en, inst_a, b_inst );

parameter inst_width = 8;


input inst_en;
input [inst_width-1 : 0] inst_a;
output [(1<<inst_width)-1 : 0] b_inst;

    // Instance of DW_decode_en
    DW_decode_en #(inst_width) U1 (
			.en(inst_en),
			.a(inst_a),
			.b(b_inst) );

endmodule

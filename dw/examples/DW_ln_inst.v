module DW_ln_inst( inst_a, z_inst );

parameter inst_op_width = 8;
parameter inst_arch = 1;
parameter inst_err_range = 1;

input [inst_op_width-1 : 0] inst_a;
output [inst_op_width-1 : 0] z_inst;

    // Instance of DW_ln
    DW_ln #(inst_op_width, inst_arch, inst_err_range) U1 (
			.a(inst_a),
			.z(z_inst) );

endmodule

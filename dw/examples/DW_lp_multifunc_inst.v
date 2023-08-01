module DW_lp_multifunc_inst( inst_a, inst_func, z_inst, status_inst );

parameter inst_op_width = 24;
parameter inst_func_select = 127;


input [inst_op_width : 0] inst_a;
input [15 : 0] inst_func;
output [inst_op_width+1 : 0] z_inst;
output status_inst;

    // Instance of DW_lp_multifunc
    DW_lp_multifunc #(inst_op_width, inst_func_select) U1 (
			.a(inst_a),
			.func(inst_func),
			.z(z_inst),
			.status(status_inst) );

endmodule


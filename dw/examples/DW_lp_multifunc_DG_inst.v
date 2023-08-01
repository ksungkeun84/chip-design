module DW_lp_multifunc_DG_inst( inst_a, inst_func, inst_DG_ctrl, z_inst, status_inst );

parameter inst_op_width = 24;
parameter inst_func_select = 127;

input [inst_op_width : 0] inst_a;
input [15 : 0] inst_func;
input inst_DG_ctrl;
output [inst_op_width+1 : 0] z_inst;
output status_inst;

    // Instance of DW_lp_multifunc_DG
    DW_lp_multifunc_DG #(inst_op_width, inst_func_select) U1 (
			.a(inst_a),
			.func(inst_func),
			.DG_ctrl(inst_DG_ctrl),
			.z(z_inst),
			.status(status_inst) );

endmodule

module DW_fp_div_seq_inst( inst_a, inst_b, inst_rnd, inst_clk, inst_rst_n, 
		inst_start, z_inst, status_inst, complete_inst );

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_num_cyc = 4;
parameter inst_rst_mode = 0;
parameter inst_input_mode = 1;
parameter inst_output_mode = 1;
parameter inst_early_start = 0;
parameter inst_internal_reg = 1;


input [inst_sig_width+inst_exp_width : 0] inst_a;
input [inst_sig_width+inst_exp_width : 0] inst_b;
input [2 : 0] inst_rnd;
input inst_clk;
input inst_rst_n;
input inst_start;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;
output complete_inst;

    // Instance of DW_fp_div_seq
    DW_fp_div_seq #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_num_cyc, inst_rst_mode, inst_input_mode, inst_output_mode, inst_early_start, inst_internal_reg) U1 (
		.a(inst_a),
		.b(inst_b),
		.rnd(inst_rnd),
		.clk(inst_clk),
		.rst_n(inst_rst_n),
		.start(inst_start),
		.z(z_inst),
		.status(status_inst),
		.complete(complete_inst) );

endmodule

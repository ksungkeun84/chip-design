module DW_lp_piped_fp_sum3_inst( inst_clk, inst_rst_n, inst_a, inst_b, inst_c, 
		inst_rnd, z_inst, status_inst, inst_launch, inst_launch_id, 
		pipe_full_inst, pipe_ovf_inst, inst_accept_n, arrive_inst, arrive_id_inst, 
		push_out_n_inst, pipe_census_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;
parameter arch_type = 0;
parameter op_iso_mode = 0;
parameter id_width = 8;
parameter in_reg = 0;
parameter stages = 4;
parameter out_reg = 0;
parameter no_pm = 1;
parameter rst_mode = 0;


`define bit_width_MX_1__in_reg_P_stages_M_1_P_out_reg_P_1 2

input inst_clk;
input inst_rst_n;
input [sig_width+exp_width : 0] inst_a;
input [sig_width+exp_width : 0] inst_b;
input [sig_width+exp_width : 0] inst_c;
input [2 : 0] inst_rnd;
output [sig_width+exp_width : 0] z_inst;
output [7 : 0] status_inst;
input inst_launch;
input [id_width-1 : 0] inst_launch_id;
output pipe_full_inst;
output pipe_ovf_inst;
input inst_accept_n;
output arrive_inst;
output [id_width-1 : 0] arrive_id_inst;
output push_out_n_inst;
output [(`bit_width_MX_1__in_reg_P_stages_M_1_P_out_reg_P_1)-1 : 0] pipe_census_inst;

    // Instance of DW_lp_piped_fp_sum3
    DW_lp_piped_fp_sum3 #(sig_width, exp_width, ieee_compliance, arch_type, op_iso_mode, id_width, in_reg, stages, out_reg, no_pm, rst_mode)
	  U1 ( .clk(inst_clk), .rst_n(inst_rst_n), .a(inst_a), .b(inst_b), .c(inst_c), .rnd(inst_rnd), .z(z_inst), .status(status_inst), .launch(inst_launch), .launch_id(inst_launch_id), .pipe_full(pipe_full_inst), .pipe_ovf(pipe_ovf_inst), .accept_n(inst_accept_n), .arrive(arrive_inst), .arrive_id(arrive_id_inst), .push_out_n(push_out_n_inst), .pipe_census(pipe_census_inst) );

endmodule

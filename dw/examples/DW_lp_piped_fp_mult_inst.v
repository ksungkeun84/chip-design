module DW_lp_piped_fp_mult_inst( inst_clk, inst_rst_n, inst_a, inst_b, inst_rnd, 
		z_inst, status_inst, inst_launch, inst_launch_id, pipe_full_inst, 
		pipe_ovf_inst, inst_accept_n, arrive_inst, arrive_id_inst, push_out_n_inst, 
		pipe_census_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;
parameter op_iso_mode = 0;
parameter id_width = 8;
parameter in_reg = 0;
parameter stages = 4;
parameter out_reg = 0;
parameter no_pm = 1;
parameter rst_mode = 0;

`define t1 ((((1>in_reg+(stages-1)+out_reg)?1:in_reg+(stages-1)+out_reg))+1)
`define bit_width_MX_1__in_reg_P_stages_M_1_P_out_reg_P_1 ((`t1>4096)? ((`t1>262144)? ((`t1>2097152)? ((`t1>8388608)? 24 : ((`t1> 4194304)? 23 : 22)) : ((`t1>1048576)? 21 : ((`t1>524288)? 20 : 19))) : ((`t1>32768)? ((`t1>131072)?  18 : ((`t1>65536)? 17 : 16)) : ((`t1>16384)? 15 : ((`t1>8192)? 14 : 13)))) : ((`t1>64)? ((`t1>512)?  ((`t1>2048)? 12 : ((`t1>1024)? 11 : 10)) : ((`t1>256)? 9 : ((`t1>128)? 8 : 7))) : ((`t1>8)? ((`t1> 32)? 6 : ((`t1>16)? 5 : 4)) : ((`t1>4)? 3 : ((`t1>2)? 2 : 1)))))

input inst_clk;
input inst_rst_n;
input [sig_width+exp_width : 0] inst_a;
input [sig_width+exp_width : 0] inst_b;
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

    // Instance of DW_lp_piped_fp_mult
    DW_lp_piped_fp_mult #(sig_width, exp_width, ieee_compliance, op_iso_mode, id_width, in_reg, stages, out_reg, no_pm, rst_mode)
	  U1 ( .clk(inst_clk), .rst_n(inst_rst_n), .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst), .launch(inst_launch), .launch_id(inst_launch_id), .pipe_full(pipe_full_inst), .pipe_ovf(pipe_ovf_inst), .accept_n(inst_accept_n), .arrive(arrive_inst), .arrive_id(arrive_id_inst), .push_out_n(push_out_n_inst), .pipe_census(pipe_census_inst) );

endmodule

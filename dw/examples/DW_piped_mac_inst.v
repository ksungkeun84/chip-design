module DW_piped_mac_inst( inst_clk, inst_rst_n, inst_init_n, 
	inst_clr_acc_n, inst_a, inst_b, acc_inst, inst_launch, inst_launch_id, 
	pipe_full_inst, pipe_ovf_inst, inst_accept_n, arrive_inst, 
	arrive_id_inst, push_out_n_inst, pipe_census_inst );

parameter inst_a_width = 8;
parameter inst_b_width = 8;
parameter inst_acc_width = 16;
parameter inst_tc = 0;
parameter inst_pipe_reg = 0;
parameter inst_id_width = 1;
parameter inst_no_pm = 0;
parameter inst_op_iso_mode = 0;

input inst_clk;
input inst_rst_n;
input inst_init_n;
input inst_clr_acc_n;
input [inst_a_width-1 : 0] inst_a;
input [inst_b_width-1 : 0] inst_b;
output [inst_acc_width-1 : 0] acc_inst;
input inst_launch;
input [inst_id_width-1 : 0] inst_launch_id;
output pipe_full_inst;
output pipe_ovf_inst;
input inst_accept_n;
output arrive_inst;
output [inst_id_width-1 : 0] arrive_id_inst;
output push_out_n_inst;
output [2 : 0] pipe_census_inst;

 // Instance of DW_piped_mac  
 DW_piped_mac #(inst_a_width, inst_b_width, inst_acc_width,
		inst_tc, inst_pipe_reg, inst_id_width, inst_no_pm)
	  U1 ( .clk(inst_clk), 
               .rst_n(inst_rst_n), 
               .init_n(inst_init_n), 
               .clr_acc_n(inst_clr_acc_n), 
               .a(inst_a), 
               .b(inst_b), 
               .acc(acc_inst), 
               .launch(inst_launch), 
               .launch_id(inst_launch_id), 
               .pipe_full(pipe_full_inst), 
               .pipe_ovf(pipe_ovf_inst), 
               .accept_n(inst_accept_n), 
               .arrive(arrive_inst), 
               .arrive_id(arrive_id_inst), 
               .push_out_n(push_out_n_inst), 
               .pipe_census(pipe_census_inst) );

endmodule

module DW_lp_piped_mult_inst( inst_clk, inst_rst_n, inst_a, inst_b, product_inst, inst_launch, inst_launch_id, 
		inst_accept_n, arrive_inst, arrive_id_inst, pipe_full_inst, 
		pipe_ovf_inst, push_out_n_inst, pipe_census_inst );

parameter a_width = 8;
parameter b_width = 8;
parameter id_width = 8;
parameter in_reg = 0;
parameter stages = 3;
parameter out_reg = 0;
parameter tc_mode = 0;
parameter rst_mode = 0;
parameter op_iso_mode = 0;


`define census_width 2  // ceil(log2(max(1, in_reg+(stages-1)+out_reg)+1))

input inst_clk;
input inst_rst_n;
input [a_width-1:0] inst_a;
input [b_width-1:0] inst_b;
output [a_width+b_width-1:0] product_inst;
input inst_launch;
input [id_width-1 : 0] inst_launch_id;
input inst_accept_n;
output arrive_inst;
output [id_width-1 : 0] arrive_id_inst;
output pipe_full_inst;
output pipe_ovf_inst;
output push_out_n_inst;
output [`census_width-1 : 0] pipe_census_inst;

    // Instance of DW_lp_piped_mult
    DW_lp_piped_mult #(a_width, b_width, id_width, in_reg, stages, out_reg, tc_mode, rst_mode, op_iso_mode)
	  U1 ( .clk(inst_clk), 
               .rst_n(inst_rst_n), 
               .a(inst_a), .b(inst_b), 
               .product(product_inst), 
               .launch(inst_launch), 
               .launch_id(inst_launch_id), 
               .accept_n(inst_accept_n), 
               .arrive(arrive_inst), 
               .arrive_id(arrive_id_inst), 
               .pipe_full(pipe_full_inst), 
               .pipe_ovf(pipe_ovf_inst), 
               .push_out_n(push_out_n_inst), 
               .pipe_census(pipe_census_inst) 
               );

endmodule

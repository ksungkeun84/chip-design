module DW_lp_piped_div_inst( inst_clk,
                             inst_rst_n,
                             inst_a,
                             inst_b,
                             quotient_inst,
                             
		             remainder_inst,
                             div_by_0_inst,
                             inst_launch,
                             inst_launch_id,
                             pipe_full_inst,
                             
		             pipe_ovf_inst,
                             inst_accept_n,
                             arrive_inst,
                             arrive_id_inst,
                             push_out_n_inst,
                             
		             pipe_census_inst );
parameter a_width = 4;
parameter b_width = 2;
parameter id_width = 4;
parameter in_reg = 0;
parameter stages = 1;
parameter out_reg = 0;
parameter tc_mode = 1;
parameter rst_mode = 0;
parameter rem_mode = 1;
parameter op_iso_mode = 0;



`define m 1
`define bit_width_m 1

input inst_clk;
input inst_rst_n;
input [a_width-1 : 0] inst_a;
input [b_width-1 : 0] inst_b;
output [a_width-1 : 0] quotient_inst;
output [b_width-1 : 0] remainder_inst;
output div_by_0_inst;
input inst_launch;
input [id_width-1 : 0] inst_launch_id;
output pipe_full_inst;
output pipe_ovf_inst;
input inst_accept_n;
output arrive_inst;
output [id_width-1 : 0] arrive_id_inst;
output push_out_n_inst;
output [`bit_width_m-1 : 0] pipe_census_inst;

    // Instance of DW_lp_piped_div
    DW_lp_piped_div #(a_width,
                      b_width,
                      id_width,
                      in_reg,
                      stages,
                      out_reg,
                      tc_mode,
                      rst_mode,
                      rem_mode,
                      op_iso_mode)
	  U1 ( .clk(inst_clk),
               .rst_n(inst_rst_n),
               .a(inst_a),
               .b(inst_b),
               .quotient(quotient_inst),
               .remainder(remainder_inst),
               .div_by_0(div_by_0_inst),
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

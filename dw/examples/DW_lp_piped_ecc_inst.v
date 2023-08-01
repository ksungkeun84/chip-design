module DW_lp_piped_ecc_inst( inst_clk, inst_rst_n, inst_datain, inst_chkin, 
    err_detect_inst, err_multiple_inst, dataout_inst, chkout_inst, syndout_inst, 
    inst_launch, inst_launch_id, inst_accept_n, arrive_inst, arrive_id_inst,
    pipe_full_inst, pipe_ovf_inst, push_out_n_inst, pipe_census_inst );

parameter data_width = 27;
parameter chk_width = 7;
parameter rw_mode = 0;
parameter op_iso_mode = 0;
parameter id_width = 1;
parameter in_reg = 0;
parameter stages = 2;
parameter out_reg = 1;
parameter no_pm = 1;
parameter rst_mode = 0;


`define census_width 2  // ceil(log2(max(1, in_reg+(stages-1)+out_reg)+1))

input inst_clk;
input inst_rst_n;
input [data_width-1:0] inst_datain;
input [chk_width-1:0] inst_chkin;
output err_detect_inst;
output err_multiple_inst;
output [data_width-1:0] dataout_inst;
output [chk_width-1:0] chkout_inst;
output [chk_width-1:0] syndout_inst;
input inst_launch;
input [id_width-1 : 0] inst_launch_id;
input inst_accept_n;
output arrive_inst;
output [id_width-1 : 0] arrive_id_inst;
output pipe_full_inst;
output pipe_ovf_inst;
output push_out_n_inst;
output [`census_width-1 : 0] pipe_census_inst;

    // Instance of DW_lp_piped_ecc
    DW_lp_piped_ecc #(data_width, chk_width, rw_mode, op_iso_mode, id_width, in_reg,
      stages, out_reg, no_pm, rst_mode)
	  U1 ( .clk(inst_clk), 
               .rst_n(inst_rst_n), 
               .datain(inst_datain),
               .chkin(inst_chkin), 
               .err_detect(err_detect_inst), 
               .err_multiple(err_multiple_inst), 
               .dataout(dataout_inst), 
               .chkout(chkout_inst), 
               .syndout(syndout_inst), 
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

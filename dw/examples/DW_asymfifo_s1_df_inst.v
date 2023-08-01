module DW_asymfifo_s1_df_inst(inst_clk, inst_rst_n, inst_push_req_n,
                              inst_flush_n, inst_pop_req_n, 
                              inst_diag_n, inst_data_in, inst_ae_level,
                              inst_af_thresh, empty_inst, almost_empty_inst,
                              half_full_inst, almost_full_inst, full_inst,
                              ram_full_inst, error_inst, part_wd_inst,
                              data_out_inst );
  parameter data_in_width = 8;
  parameter data_out_width = 16;
  parameter depth = 8;
  parameter err_mode = 1;
  parameter rst_mode = 1;
  parameter byte_order = 0;
  `define bit_width_depth 3 // ceil(log2(depth)) 

  input inst_clk;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_flush_n;
  input inst_pop_req_n;
  input inst_diag_n;
  input [data_in_width-1 : 0] inst_data_in;
  input [`bit_width_depth-1 : 0] inst_ae_level;
  input [`bit_width_depth-1 : 0] inst_af_thresh;
  output empty_inst;
  output almost_empty_inst;
  output half_full_inst;
  output almost_full_inst;
  output full_inst;
  output ram_full_inst;
  output error_inst;
  output part_wd_inst;
  output [data_out_width-1 : 0] data_out_inst;

  // Instance of DW_asymfifo_s1_df
  DW_asymfifo_s1_df #(data_in_width, data_out_width, depth, err_mode,
                      rst_mode, byte_order)
  U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .push_req_n(inst_push_req_n),
      .flush_n(inst_flush_n),   .pop_req_n(inst_pop_req_n),
      .diag_n(inst_diag_n),   .data_in(inst_data_in),
      .ae_level(inst_ae_level),   .af_thresh(inst_af_thresh),
      .empty(empty_inst),   .almost_empty(almost_empty_inst),
      .half_full(half_full_inst),   .almost_full(almost_full_inst),
      .full(full_inst),   .ram_full(ram_full_inst),   .error(error_inst),
      .part_wd(part_wd_inst),   .data_out(data_out_inst) );
endmodule

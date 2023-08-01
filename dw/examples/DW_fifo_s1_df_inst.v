module DW_fifo_s1_df_inst(inst_clk, inst_rst_n, inst_push_req_n,
                          inst_pop_req_n, inst_diag_n, inst_ae_level,
                          inst_af_thresh, inst_data_in, empty_inst,
                          almost_empty_inst, half_full_inst,
                          almost_full_inst, full_inst, error_inst,
                          data_out_inst );
  parameter width = 8;
  parameter depth = 4;
  parameter err_mode = 0;
  parameter rst_mode = 0;
  `define bit_width_depth 2 // ceil(log2(depth)) 

  input inst_clk;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_pop_req_n;
  input inst_diag_n;
  input [`bit_width_depth-1 : 0] inst_ae_level;
  input [`bit_width_depth-1 : 0] inst_af_thresh;
  input [width-1 : 0] inst_data_in;
  output empty_inst;
  output almost_empty_inst;
  output half_full_inst;
  output almost_full_inst;
  output full_inst;
  output error_inst;
  output [width-1 : 0] data_out_inst;

  // Instance of DW_fifo_s1_df
  DW_fifo_s1_df #(width, depth, err_mode, rst_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .push_req_n(inst_push_req_n),
        .pop_req_n(inst_pop_req_n),   .diag_n(inst_diag_n),
        .ae_level(inst_ae_level),   .af_thresh(inst_af_thresh),
        .data_in(inst_data_in),   .empty(empty_inst),
        .almost_empty(almost_empty_inst),   .half_full(half_full_inst),
        .almost_full(almost_full_inst),   .full(full_inst),
        .error(error_inst),   .data_out(data_out_inst) );
endmodule

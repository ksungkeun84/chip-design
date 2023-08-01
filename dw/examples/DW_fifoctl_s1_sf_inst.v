module DW_fifoctl_s1_sf_inst(inst_clk, inst_rst_n, inst_push_req_n,
                             inst_pop_req_n, inst_diag_n, we_n_inst,
                             empty_inst, almost_empty_inst, half_full_inst,
                             almost_full_inst, full_inst, error_inst,
                             wr_addr_inst, rd_addr_inst );
  parameter depth = 4;
  parameter ae_level = 1;
  parameter af_level = 1;
  parameter err_mode = 0;
  parameter rst_mode = 0;
  `define bit_width_depth 2 // ceil(log2(depth)) 

  input inst_clk;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_pop_req_n;
  input inst_diag_n;
  output we_n_inst;
  output empty_inst;
  output almost_empty_inst;
  output half_full_inst;
  output almost_full_inst;
  output full_inst;
  output error_inst;
  output [`bit_width_depth-1 : 0] wr_addr_inst;
  output [`bit_width_depth-1 : 0] rd_addr_inst;

  // Instance of DW_fifoctl_s1_sf
  DW_fifoctl_s1_sf #(depth,   ae_level,   af_level,   err_mode,   rst_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),
        .push_req_n(inst_push_req_n),   .pop_req_n(inst_pop_req_n),
        .diag_n(inst_diag_n),   .we_n(we_n_inst),   .empty(empty_inst),
        .almost_empty(almost_empty_inst),   .half_full(half_full_inst),
        .almost_full(almost_full_inst),   .full(full_inst),
        .error(error_inst),   .wr_addr(wr_addr_inst),
        .rd_addr(rd_addr_inst) );
endmodule


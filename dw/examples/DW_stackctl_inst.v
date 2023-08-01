module DW_stackctl_inst(inst_clk, inst_rst_n, inst_push_req_n,
                        inst_pop_req_n, we_n_inst, empty_inst, full_inst,
                        error_inst, wr_addr_inst, rd_addr_inst );

  parameter depth = 8;
  parameter err_mode = 0;
  parameter rst_mode = 0;
  `define bit_width_depth 3 // ceil(log2(depth))  

  input inst_clk;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_pop_req_n;
  output we_n_inst;
  output empty_inst;
  output full_inst;
  output error_inst;
  output [`bit_width_depth-1 : 0] wr_addr_inst;
  output [`bit_width_depth-1 : 0] rd_addr_inst;

  // Instance of DW_stackctl
  DW_stackctl #(depth, err_mode, rst_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .push_req_n(inst_push_req_n),
        .pop_req_n(inst_pop_req_n),   .we_n(we_n_inst),   .empty(empty_inst),
        .full(full_inst),   .error(error_inst),   .wr_addr(wr_addr_inst),
        .rd_addr(rd_addr_inst) );
endmodule


module DW_stack_inst(inst_clk, inst_rst_n, inst_push_req_n, inst_pop_req_n,
                     inst_data_in, empty_inst, full_inst, error_inst,
                     data_out_inst );
  parameter width = 8;
  parameter depth = 8;
  parameter err_mode = 0;
  parameter rst_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_pop_req_n;
  input [width-1 : 0] inst_data_in;
  output empty_inst;
  output full_inst;
  output error_inst;
  output [width-1 : 0] data_out_inst;

  // Instance of DW_stack
  DW_stack #(width, depth, err_mode, rst_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .push_req_n(inst_push_req_n),
        .pop_req_n(inst_pop_req_n),   .data_in(inst_data_in),
        .empty(empty_inst),   .full(full_inst),   .error(error_inst),
        .data_out(data_out_inst) );

endmodule


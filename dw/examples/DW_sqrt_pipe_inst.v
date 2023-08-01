module DW_sqrt_pipe_inst( inst_clk, inst_rst_n, inst_en, inst_a, root_inst );
  parameter inst_width = 2;
  parameter inst_tc_mode = 0;
  parameter inst_num_stages = 2;
  parameter inst_stall_mode = 1;
  parameter inst_rst_mode = 1;
  parameter inst_op_iso_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_en;
  input [inst_width-1 : 0] inst_a;
  output [(inst_width+1)/2-1 : 0] root_inst;

  // Instance of DW_sqrt_pipe
  DW_sqrt_pipe #(inst_width, inst_tc_mode, inst_num_stages, 
                 inst_stall_mode, inst_rst_mode, inst_op_iso_mode) 
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),
        .en(inst_en),   .a(inst_a),   .root(root_inst) );
endmodule

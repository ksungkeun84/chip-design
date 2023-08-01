module DW_prod_sum_pipe_inst( inst_clk, inst_rst_n, inst_en, inst_tc,
                              inst_a, inst_b, sum_inst );

  parameter inst_a_width = 2;
  parameter inst_b_width = 2;
  parameter inst_num_inputs = 2;
  parameter inst_sum_width = 4;
  parameter inst_num_stages = 2;
  parameter inst_stall_mode = 1;
  parameter inst_rst_mode = 1;
  parameter inst_op_iso_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_en;
  input inst_tc;
  input [inst_a_width*inst_num_inputs-1 : 0] inst_a;
  input [inst_b_width*inst_num_inputs-1 : 0] inst_b;
  output [inst_sum_width-1 : 0] sum_inst;

  // Instance of DW_prod_sum_pipe
  DW_prod_sum_pipe #(inst_a_width, inst_b_width, inst_num_inputs,
                     inst_sum_width, inst_num_stages, inst_stall_mode,
                     inst_rst_mode, inst_op_iso_mode) 
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),
        .en(inst_en),     .tc(inst_tc),
        .a(inst_a),       .b(inst_b), 
        .sum(sum_inst) );
endmodule

module DW_div_pipe_inst(inst_clk, inst_rst_n, inst_en, inst_a, inst_b,
                        quotient_inst, remainder_inst, divide_by_0_inst );

  parameter inst_a_width = 8;
  parameter inst_b_width = 8;
  parameter inst_tc_mode = 0;
  parameter inst_rem_mode = 1;
  parameter inst_num_stages = 2;
  parameter inst_stall_mode = 1;
  parameter inst_rst_mode = 1;
  parameter inst_op_iso_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_en;
  input [inst_a_width-1 : 0] inst_a;
  input [inst_b_width-1 : 0] inst_b;
  output [inst_a_width-1 : 0] quotient_inst;
  output [inst_b_width-1 : 0] remainder_inst;
  output divide_by_0_inst;

  // Instance of DW_div_pipe
  DW_div_pipe #(inst_a_width,   inst_b_width,   inst_tc_mode,  inst_rem_mode,
                inst_num_stages,   inst_stall_mode,   inst_rst_mode,   inst_op_iso_mode) 
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .en(inst_en),
        .a(inst_a),   .b(inst_b),   .quotient(quotient_inst),
        .remainder(remainder_inst),   .divide_by_0(divide_by_0_inst) );
endmodule

module DW_div_seq_inst(inst_clk, inst_rst_n, inst_hold, inst_start, inst_a, 
   inst_b, complete_inst, divide_by_0_inst, quotient_inst, remainder_inst);

  parameter inst_a_width = 8; 
  parameter inst_b_width = 8; 
  parameter inst_tc_mode = 0; 
  parameter inst_num_cyc = 3; 
  parameter inst_rst_mode = 0; 
  parameter inst_input_mode = 1; 
  parameter inst_output_mode = 1; 
  parameter inst_early_start = 0; 
  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator 
  // command line (for simulation).
  input inst_clk; 
  input inst_rst_n; 
  input inst_hold; 
  input inst_start; 
  input [inst_a_width-1 : 0] inst_a; 
  input [inst_b_width-1 : 0] inst_b; 
  output complete_inst; 
  output divide_by_0_inst; 
  output [inst_a_width-1 : 0] quotient_inst; 
  output [inst_b_width-1 : 0] remainder_inst;
  // Instance of DW_div_seq 
  DW_div_seq #(inst_a_width, inst_b_width, inst_tc_mode, inst_num_cyc,
               inst_rst_mode, inst_input_mode, inst_output_mode,
               inst_early_start) 
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .hold(inst_hold), 
        .start(inst_start),   .a(inst_a),   .b(inst_b), 
        .complete(complete_inst),   .divide_by_0(divide_by_0_inst), 
        .quotient(quotient_inst),   .remainder(remainder_inst) );
endmodule

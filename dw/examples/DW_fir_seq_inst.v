module DW_fir_seq_inst(inst_clk, inst_rst_n, inst_coef_shift_en, inst_tc,
                       inst_run, inst_data_in, inst_coef_in,
                       inst_init_acc_val, start_inst, hold_inst, 
                       data_out_inst );

  parameter data_in_width = 8;
  parameter coef_width = 8;
  parameter data_out_width = 18;
  parameter order = 6;

  input inst_clk;
  input inst_rst_n;
  input inst_coef_shift_en;
  input inst_tc;
  input inst_run;
  input [data_in_width-1 : 0] inst_data_in;
  input [coef_width-1 : 0] inst_coef_in;
  input [data_out_width-1 : 0] inst_init_acc_val;
  output start_inst;
  output hold_inst;
  output [data_out_width-1 : 0] data_out_inst;

  // Instance of DW_fir_seq
  DW_fir_seq #(data_in_width, coef_width, data_out_width, order)
    U1 ( .clk(inst_clk),   .rst_n(inst_rst_n), 
         .coef_shift_en(inst_coef_shift_en),   .tc(inst_tc), 
         .run(inst_run),   .data_in(inst_data_in),   .coef_in(inst_coef_in),
         .init_acc_val(inst_init_acc_val),   .start(start_inst),
         .hold(hold_inst),   .data_out(data_out_inst) );
endmodule

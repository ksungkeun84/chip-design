module DW_fir_inst( inst_clk, inst_rst_n, inst_coef_shift_en, inst_tc,
                    inst_data_in, inst_coef_in, inst_init_acc_val,
                    data_out_inst, coef_out_inst );
  parameter data_in_width = 8;
  parameter coef_width = 8;
  parameter data_out_width = 18;
  parameter order = 6;

  input inst_clk;
  input inst_rst_n;
  input inst_coef_shift_en;
  input inst_tc;
  input [data_in_width-1 : 0] inst_data_in;
  input [coef_width-1 : 0] inst_coef_in;
  input [data_out_width-1 : 0] inst_init_acc_val;
  output [data_out_width-1 : 0] data_out_inst;
  output [coef_width-1 : 0] coef_out_inst;

  // Instance of DW_fir
  DW_fir #(data_in_width, coef_width, data_out_width, order)
    U1 ( .clk(inst_clk),   .rst_n(inst_rst_n),
         .coef_shift_en(inst_coef_shift_en),   .tc(inst_tc),
         .data_in(inst_data_in),   .coef_in(inst_coef_in),
         .init_acc_val(inst_init_acc_val),   .data_out(data_out_inst),
         .coef_out(coef_out_inst) );
endmodule

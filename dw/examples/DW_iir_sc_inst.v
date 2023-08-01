module DW_iir_sc_inst(inst_clk, inst_rst_n, inst_init_n, inst_enable,
                      inst_data_in, data_out_inst, saturation_inst );

  parameter data_in_width = 4;
  parameter data_out_width = 6;
  parameter frac_data_out_width = 0;
  parameter feedback_width = 8;
  parameter max_coef_width = 4;
  parameter frac_coef_width = 0;
  parameter saturation_mode = 1;
  parameter out_reg = 1;
  parameter A1_coef = -2;
  parameter A2_coef =  3;
  parameter B0_coef =  5;
  parameter B1_coef = -6;
  parameter B2_coef = -2;

  input inst_clk;
  input inst_rst_n;
  input inst_init_n;
  input inst_enable;
  input [data_in_width-1 : 0] inst_data_in;
  output [data_out_width-1 : 0] data_out_inst;
  output saturation_inst;

  // Instance of DW_iir_sc
  DW_iir_sc #(data_in_width, data_out_width, frac_data_out_width,
              feedback_width, max_coef_width, frac_coef_width,
              saturation_mode, out_reg, A1_coef, A2_coef, B0_coef,
              B1_coef, B2_coef)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .init_n(inst_init_n),
        .enable(inst_enable),   .data_in(inst_data_in),
        .data_out(data_out_inst),   .saturation(saturation_inst) );
endmodule

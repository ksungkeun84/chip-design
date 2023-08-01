module DW_iir_dc_inst( inst_clk, inst_rst_n, inst_init_n, 
                       inst_enable, inst_A1_coef, inst_A2_coef,
                       inst_B0_coef, inst_B1_coef, inst_B2_coef,
                         inst_data_in, data_out_inst, saturation_inst );

  parameter data_in_width = 8;
  parameter data_out_width = 16;
  parameter frac_data_out_width = 4;
  parameter feedback_width = 12;
  parameter max_coef_width = 8;
  parameter frac_coef_width = 4;
  parameter saturation_mode = 0;
  parameter out_reg = 1;

  input inst_clk;
  input inst_rst_n;
  input inst_init_n;
  input inst_enable;
  input [max_coef_width-1 : 0] inst_A1_coef;
  input [max_coef_width-1 : 0] inst_A2_coef;
  input [max_coef_width-1 : 0] inst_B0_coef;
  input [max_coef_width-1 : 0] inst_B1_coef;
  input [max_coef_width-1 : 0] inst_B2_coef;
  input [data_in_width-1 : 0] inst_data_in;
  output [data_out_width-1 : 0] data_out_inst;
  output saturation_inst;

  // Instance of DW_iir_dc
  DW_iir_dc #(data_in_width, data_out_width, frac_data_out_width,
              feedback_width, max_coef_width, frac_coef_width,
              saturation_mode, out_reg)
    U1 ( .clk(inst_clk),   .rst_n(inst_rst_n),   .init_n(inst_init_n),
         .enable(inst_enable),   .A1_coef(inst_A1_coef),
         .A2_coef(inst_A2_coef),   .B0_coef(inst_B0_coef),
          .B1_coef(inst_B1_coef),   .B2_coef(inst_B2_coef),
          .data_in(inst_data_in),   .data_out(data_out_inst),
          .saturation(saturation_inst) );
endmodule

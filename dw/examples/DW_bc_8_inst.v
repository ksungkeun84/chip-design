module DW_bc_8_inst(inst_capture_clk, inst_update_clk, inst_capture_en,
                    inst_update_en, inst_shift_dr, inst_mode, inst_si, 
                    inst_pin_input, inst_output_data, ic_input_inst, 
                    data_out_inst, so_inst );

  input inst_capture_clk;
  input inst_update_clk;
  input inst_capture_en;
  input inst_update_en;
  input inst_shift_dr;
  input inst_mode;
  input inst_si;
  input inst_pin_input;
  input inst_output_data;
  output ic_input_inst;
  output data_out_inst;
  output so_inst;

  // Instance of DW_bc_8
  DW_bc_8 
    U1 (.capture_clk(inst_capture_clk),
        .update_clk(inst_update_clk),
        .capture_en(inst_capture_en),
        .update_en(inst_update_en),
        .shift_dr(inst_shift_dr),
        .mode(inst_mode),
        .si(inst_si),
        .pin_input(inst_pin_input),
        .output_data(inst_output_data),
        .ic_input(ic_input_inst),
        .data_out(data_out_inst),
        .so(so_inst) );
endmodule


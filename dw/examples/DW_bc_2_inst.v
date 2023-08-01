module DW_bc_2_inst(inst_capture_clk, inst_update_clk, inst_capture_en,
                    inst_update_en, inst_shift_dr, inst_mode, inst_si,
                    inst_data_in, data_out_inst, so_inst );
  input inst_capture_clk;
  input inst_update_clk;
  input inst_capture_en;
  input inst_update_en;
  input inst_shift_dr;
  input inst_mode;
  input inst_si;
  input inst_data_in;
  output data_out_inst;
  output so_inst;

  // Instance of DW_bc_2
  DW_bc_2 
    U1 (.capture_clk(inst_capture_clk),   .update_clk(inst_update_clk),
        .capture_en(inst_capture_en),   .update_en(inst_update_en),
        .shift_dr(inst_shift_dr),   .mode(inst_mode),   .si(inst_si),
        .data_in(inst_data_in),   .data_out(data_out_inst),   .so(so_inst) );
endmodule


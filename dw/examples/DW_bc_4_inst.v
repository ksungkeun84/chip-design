module DW_bc_4_inst(inst_capture_clk, inst_capture_en, inst_shift_dr,
                    inst_si, inst_data_in, so_inst, data_out_inst );

  input inst_capture_clk;
  input inst_capture_en;
  input inst_shift_dr;
  input inst_si;
  input inst_data_in;
  output so_inst;
  output data_out_inst;

  // Instance of DW_bc_4
  DW_bc_4 
    U1 (.capture_clk(inst_capture_clk),   .capture_en(inst_capture_en),
        .shift_dr(inst_shift_dr),   .si(inst_si),   .data_in(inst_data_in),
        .so(so_inst),   .data_out(data_out_inst) );
endmodule


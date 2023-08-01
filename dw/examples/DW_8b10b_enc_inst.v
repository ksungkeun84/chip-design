module DW_8b10b_enc_inst(inst_clk, inst_rst_n, inst_init_rd_n,
                         inst_init_rd_val, inst_k_char, 
                         inst_data_in, rd_inst, data_out_inst, inst_enable );
  parameter inst_bytes = 2;
  parameter inst_k28_5_only = 0;
  parameter inst_en_mode = 1;
  parameter inst_init_mode = 1;
  parameter inst_rst_mode = 0;
  parameter inst_op_iso_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_init_rd_n;
  input inst_init_rd_val;
  input [inst_bytes-1 : 0] inst_k_char;
  input [inst_bytes*8-1 : 0] inst_data_in;
  output rd_inst;
  output [inst_bytes*10-1 : 0] data_out_inst;
  input inst_enable;

  // Instance of DW_8b10b_enc
  DW_8b10b_enc #(inst_bytes, inst_k28_5_only, inst_en_mode, 
                 inst_init_mode, inst_rst_mode, inst_op_iso_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .init_rd_n(inst_init_rd_n),
        .init_rd_val(inst_init_rd_val),   .k_char(inst_k_char),
        .data_in(inst_data_in),   .rd(rd_inst),   .data_out(data_out_inst),
        .enable(inst_enable)  );
endmodule

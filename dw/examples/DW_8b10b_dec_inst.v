module DW_8b10b_dec_inst(inst_clk, inst_rst_n, inst_init_rd_n,
                         inst_init_rd_val, inst_data_in, error_inst, 
                         rd_inst, k_char_inst, data_out_inst, 
                         rd_err_inst, code_err_inst, inst_enable,
			 rd_err_bus_inst, code_err_bus_inst );
  parameter inst_bytes = 2;
  parameter inst_k28_5_only = 0;
  parameter inst_en_mode = 0;
  parameter inst_init_mode = 1;
  parameter inst_rst_mode = 0;
  parameter inst_op_iso_mode = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_init_rd_n;
  input inst_init_rd_val;
  input [inst_bytes*10-1 : 0] inst_data_in;
  output error_inst;
  output rd_inst;
  output [inst_bytes-1 : 0] k_char_inst;
  output [inst_bytes*8-1 : 0] data_out_inst;
  output rd_err_inst;
  output code_err_inst;
  input inst_enable;
  output [inst_bytes-1 : 0] rd_err_bus_inst;
  output [inst_bytes-1 : 0] code_err_bus_inst;

  // Instance of DW_8b10b_dec
  DW_8b10b_dec #(inst_bytes, inst_k28_5_only, inst_en_mode, 
                 inst_init_mode, inst_rst_mode, inst_op_iso_mode)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .init_rd_n(inst_init_rd_n),
        .init_rd_val(inst_init_rd_val),   .data_in(inst_data_in),
        .error(error_inst),   .rd(rd_inst),   .k_char(k_char_inst),
        .data_out(data_out_inst),   .rd_err(rd_err_inst),
        .code_err(code_err_inst),   .enable(inst_enable),
	.rd_err_bus(rd_err_bus_inst), .code_err_bus(code_err_bus_inst) );
endmodule

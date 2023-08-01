module DW_crc_s_inst(inst_clk, inst_rst_n, inst_init_n, inst_enable,
                     inst_drain, inst_ld_crc_n, inst_data_in, inst_crc_in,
                     draining_inst, drain_done_inst, crc_ok_inst,
                     data_out_inst, crc_out_inst );

  parameter data_width = 16;
  parameter poly_size = 16;
  parameter crc_cfg = 7;
  parameter bit_order = 3;
  parameter poly_coef0 = 4129;
  parameter poly_coef1 = 0;
  parameter poly_coef2 = 0;
  parameter poly_coef3 = 0;

  input inst_clk;
  input inst_rst_n;
  input inst_init_n;
  input inst_enable;
  input inst_drain;
  input inst_ld_crc_n;
  input [data_width-1 : 0] inst_data_in;
  input [poly_size-1 : 0] inst_crc_in;
  output draining_inst;
  output drain_done_inst;
  output crc_ok_inst;
  output [data_width-1 : 0] data_out_inst;
  output [poly_size-1 : 0] crc_out_inst;

  // Instance of DW_crc_s
  DW_crc_s #(data_width,   poly_size,   crc_cfg,   bit_order,
              poly_coef0,   poly_coef1,   poly_coef2,   poly_coef3)
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .init_n(inst_init_n),
        .enable(inst_enable),   .drain(inst_drain),
        .ld_crc_n(inst_ld_crc_n),   .data_in(inst_data_in),
        .crc_in(inst_crc_in),   .draining(draining_inst),
        .drain_done(drain_done_inst),   .crc_ok(crc_ok_inst),
        .data_out(data_out_inst),   .crc_out(crc_out_inst)  );
endmodule


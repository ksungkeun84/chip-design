module DW_crc_p_inst( inst_data_in, inst_crc_in, crc_ok_inst, crc_out_inst );

  parameter data_width = 16;
  parameter poly_size = 16;
  parameter crc_cfg = 7;
  parameter bit_order = 3;
  parameter poly_coef0 = 4129;
  parameter poly_coef1 = 0;
  parameter poly_coef2 = 0;
  parameter poly_coef3 = 0;

  input [data_width-1 : 0] inst_data_in;
  input [poly_size-1 : 0] inst_crc_in;
  output crc_ok_inst;
  output [poly_size-1 : 0] crc_out_inst;

  // Instance of DW_crc_p
  DW_crc_p #(data_width,   poly_size,   crc_cfg,   bit_order,   poly_coef0,
              poly_coef1,   poly_coef2,  poly_coef3)
    U1 (.data_in(inst_data_in),   .crc_in(inst_crc_in),         .crc_ok(crc_ok_inst),     .crc_out(crc_out_inst) );
endmodule


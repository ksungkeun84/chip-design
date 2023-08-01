module DW_ram_2r_w_a_lat_inst( inst_rst_n, inst_cs_n, inst_wr_n,
               inst_rd1_addr, inst_rd2_addr, inst_wr_addr, inst_data_in,
               data_rd1_out_inst, data_rd2_out_inst );
  parameter data_width = 8;
  parameter depth = 8;
  parameter rst_mode = 1;
  `define bit_width_depth 3 // ceil(log2(depth)) 

  input inst_rst_n;
  input inst_cs_n;
  input inst_wr_n;
  input [`bit_width_depth-1 : 0] inst_rd1_addr;
  input [`bit_width_depth-1 : 0] inst_rd2_addr;
  input [`bit_width_depth-1 : 0] inst_wr_addr;
  input [data_width-1 : 0] inst_data_in;
  output [data_width-1 : 0] data_rd1_out_inst;
  output [data_width-1 : 0] data_rd2_out_inst;

  // Instance of DW_ram_2r_w_a_lat
  DW_ram_2r_w_a_lat #(data_width,   depth,   rst_mode)
    U1 (.rst_n(inst_rst_n),   .cs_n(inst_cs_n),   .wr_n(inst_wr_n),
        .rd1_addr(inst_rd1_addr),   .rd2_addr(inst_rd2_addr),
        .wr_addr(inst_wr_addr),   .data_in(inst_data_in),
        .data_rd1_out(data_rd1_out_inst), 
        .data_rd2_out(data_rd2_out_inst) );
endmodule


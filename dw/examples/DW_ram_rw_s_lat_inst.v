module DW_ram_rw_s_lat_inst(inst_clk, inst_cs_n, inst_wr_n, inst_rw_addr,
                            inst_data_in, data_out_inst );

  parameter data_width = 8;
  parameter depth = 8;
  `define bit_width_depth 3 // ceil(log2(depth)) 

  input inst_clk;
  input inst_cs_n;
  input inst_wr_n;
  input [`bit_width_depth-1 : 0] inst_rw_addr;
  input [data_width-1 : 0] inst_data_in;
  output [data_width-1 : 0] data_out_inst;

  // Instance of DW_ram_rw_s_lat
  DW_ram_rw_s_lat #(data_width, depth)
  U1 (.clk(inst_clk),   .cs_n(inst_cs_n),   .wr_n(inst_wr_n),
      .rw_addr(inst_rw_addr),   .data_in(inst_data_in),
      .data_out(data_out_inst) );
endmodule


module DW_ram_r_w_a_dff_inst(inst_rst_n, inst_cs_n, inst_wr_n,
                             inst_test_mode, inst_test_clk, inst_rd_addr,
                             inst_wr_addr, inst_data_in, data_out_inst );
  parameter data_width = 8;
  parameter depth = 8;
  parameter rst_mode = 0;
  `define bit_width_depth 3 // ceil(log2(depth)) 

  input inst_rst_n;
  input inst_cs_n;
  input inst_wr_n;
  input inst_test_mode;
  input inst_test_clk;
  input [`bit_width_depth-1 : 0] inst_rd_addr;
  input [`bit_width_depth-1 : 0] inst_wr_addr;
  input [data_width-1 : 0] inst_data_in;
  output [data_width-1 : 0] data_out_inst;

  // Instance of DW_ram_r_w_a_dff
  DW_ram_r_w_a_dff #(data_width,   depth,   rst_mode)
    U1 (.rst_n(inst_rst_n),   .cs_n(inst_cs_n),   .wr_n(inst_wr_n),
        .test_mode(inst_test_mode),   .test_clk(inst_test_clk),
        .rd_addr(inst_rd_addr),   .wr_addr(inst_wr_addr),
        .data_in(inst_data_in),   .data_out(data_out_inst) );
endmodule


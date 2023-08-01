module DW_asymfifoctl_s2_sf_inst(inst_clk_push, inst_clk_pop, inst_rst_n,
   inst_push_req_n, inst_flush_n, inst_pop_req_n, inst_data_in, inst_rd_data,
   we_n_inst, push_empty_inst, push_ae_inst, push_hf_inst, push_af_inst,
   push_full_inst, ram_full_inst, part_wd_inst, push_error_inst,
   pop_empty_inst, pop_ae_inst, pop_hf_inst, pop_af_inst, pop_full_inst,
   pop_error_inst, wr_data_inst, wr_addr_inst, rd_addr_inst, data_out_inst 
   );
  parameter data_in_width = 8;
  parameter data_out_width = 24;
  parameter depth = 8;
  parameter push_ae_lvl = 2;
  parameter push_af_lvl = 2;
  parameter pop_ae_lvl = 2;
  parameter pop_af_lvl = 2;
  parameter err_mode = 0;
  parameter push_sync = 2;
  parameter pop_sync = 2;
  parameter rst_mode = 1;
  parameter byte_order = 0;
  `define bit_width_depth 3 // ceil(log2(depth)) 

  input inst_clk_push;
  input inst_clk_pop;
  input inst_rst_n;
  input inst_push_req_n;
  input inst_flush_n;
  input inst_pop_req_n;
  input [data_in_width-1 : 0] inst_data_in;
  input [((data_in_width > data_out_width)? 
           data_in_width : data_out_width)-1 : 0] inst_rd_data;
  output we_n_inst;
  output push_empty_inst;
  output push_ae_inst;
  output push_hf_inst;
  output push_af_inst;
  output push_full_inst;
  output ram_full_inst;
  output part_wd_inst;
  output push_error_inst;
  output pop_empty_inst;
  output pop_ae_inst;
  output pop_hf_inst;
  output pop_af_inst;
  output pop_full_inst;
  output pop_error_inst;
  output [((data_in_width > data_out_width)? 
            data_in_width : data_out_width)-1 : 0] wr_data_inst;
  output [`bit_width_depth-1 : 0] wr_addr_inst;
  output [`bit_width_depth-1 : 0] rd_addr_inst;
  output [data_out_width-1 : 0] data_out_inst;

  // Instance of DW_asymfifoctl_s2_sf
  DW_asymfifoctl_s2_sf #(data_in_width, data_out_width, depth, push_ae_lvl,
                         push_af_lvl, pop_ae_lvl, pop_af_lvl, err_mode,
                         push_sync, pop_sync, rst_mode, byte_order)
  U1 (.clk_push(inst_clk_push),   .clk_pop(inst_clk_pop),
      .rst_n(inst_rst_n),   .push_req_n(inst_push_req_n),
      .flush_n(inst_flush_n),   .pop_req_n(inst_pop_req_n),
      .data_in(inst_data_in),   .rd_data(inst_rd_data),
      .we_n(we_n_inst),   .push_empty(push_empty_inst),
      .push_ae(push_ae_inst),   .push_hf(push_hf_inst),
      .push_af(push_af_inst),   .push_full(push_full_inst),
      .ram_full(ram_full_inst),   .part_wd(part_wd_inst),
      .push_error(push_error_inst),   .pop_empty(pop_empty_inst),
      .pop_ae(pop_ae_inst),   .pop_hf(pop_hf_inst),
      .pop_af(pop_af_inst),   .pop_full(pop_full_inst),
      .pop_error(pop_error_inst),   .wr_data(wr_data_inst),
      .wr_addr(wr_addr_inst),   .rd_addr(rd_addr_inst),
      .data_out(data_out_inst)  );
endmodule

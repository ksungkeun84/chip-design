module DW03_lfsr_dcnto_inst( inst_data, inst_count_to, 
                             inst_load, inst_cen, inst_clk, 
                             inst_reset, count_inst, tercnt_inst );

  parameter width = 8;

  input [width-1 : 0] inst_data;
  input [width-1 : 0] inst_count_to;
  input inst_load;
  input inst_cen;
  input inst_clk;
  input inst_reset;
  output [width-1 : 0] count_inst;
  output tercnt_inst;

  // Instance of DW03_lfsr_dcnto
  DW03_lfsr_dcnto #(width)
    U1 ( .data(inst_data), .count_to(inst_count_to), 
         .load(inst_load), .cen(inst_cen), .clk(inst_clk), 
         .reset(inst_reset), .count(count_inst), .tercnt(tercnt_inst) );

endmodule

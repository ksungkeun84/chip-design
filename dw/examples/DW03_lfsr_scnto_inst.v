module DW03_lfsr_scnto_inst( inst_data, inst_load, inst_cen, inst_clk, 
                             inst_reset, count_inst, tercnt_inst );

  parameter width = 8;
  parameter count_to = 8;

  input [width-1 : 0] inst_data;
  input inst_load;
  input inst_cen;
  input inst_clk;
  input inst_reset;
  output [width-1 : 0] count_inst;
  output tercnt_inst;

  // Instance of DW03_lfsr_scnto
  DW03_lfsr_scnto #(width, count_to)
    U1 ( .data(inst_data), .load(inst_load), .cen(inst_cen), .clk(inst_clk),
         .reset(inst_reset), .count(count_inst), .tercnt(tercnt_inst) );

endmodule


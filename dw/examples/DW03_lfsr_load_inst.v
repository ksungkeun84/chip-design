module DW03_lfsr_load_inst( inst_data, inst_load, inst_cen, 
                            inst_clk, inst_reset, count_inst );

  parameter width = 8;

  input [width-1 : 0] inst_data;
  input inst_load;
  input inst_cen;
  input inst_clk;
  input inst_reset;
  output [width-1 : 0] count_inst;

  // Instance of DW03_lfsr_load
  DW03_lfsr_load #(width)
    U1 ( .data(inst_data), .load(inst_load), .cen(inst_cen), .clk(inst_clk),
         .reset(inst_reset), .count(count_inst) );

endmodule

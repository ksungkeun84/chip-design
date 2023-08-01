module DW03_lfsr_updn_inst( inst_updn, inst_cen, inst_clk, 
                            inst_reset, count_inst, tercnt_inst );

  parameter width = 8;

  input inst_updn;
  input inst_cen;
  input inst_clk;
  input inst_reset;
  output [width-1 : 0] count_inst;
  output tercnt_inst;

  // Instance of DW03_lfsr_updn
  DW03_lfsr_updn #(width)
    U1 ( .updn(inst_updn), .cen(inst_cen), .clk(inst_clk), 
         .reset(inst_reset), .count(count_inst), .tercnt(tercnt_inst) );

endmodule


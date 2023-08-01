module DW04_par_gen_inst( inst_datain, parity_inst );

  parameter width = 8;
  parameter par_type = 1;

  input [width-1 : 0] inst_datain;
  output parity_inst;

  // Instance of DW04_par_gen
  DW04_par_gen #(width, par_type)
    U1 ( .datain(inst_datain),   .parity(parity_inst) );
endmodule


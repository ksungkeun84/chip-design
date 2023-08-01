module DW_pricod_inst (inst_a, cod_inst, zero_inst);

  parameter inst_a_width = 8;


  input  [inst_a_width-1 : 0] inst_a;
  output [inst_a_width-1 : 0] cod_inst;
  output zero_inst;

  // Instance of DW_pricod
  DW_pricod #(inst_a_width) 
    U1 ( .a(inst_a), .cod(cod_inst), .zero(zero_inst) );

endmodule

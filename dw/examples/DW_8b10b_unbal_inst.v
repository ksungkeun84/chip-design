module DW_8b10b_unbal_inst( inst_k_char, inst_data_in, unbal_inst );

  parameter k28_5_only = 0;

  input inst_k_char;
  input [7 : 0] inst_data_in;
  output unbal_inst;

  // Instance of DW_8b10b_unbal
  DW_8b10b_unbal #(k28_5_only)
    U1 (.k_char(inst_k_char),  .data_in(inst_data_in),  .unbal(unbal_inst) );
endmodule


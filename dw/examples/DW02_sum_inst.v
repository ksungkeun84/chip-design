module DW02_sum_inst( inst_INPUT, SUM_inst );

  parameter num_inputs = 8;
  parameter input_width = 8;

  input [num_inputs*input_width-1 : 0] inst_INPUT;
  output [input_width-1 : 0] SUM_inst;

  // Instance of DW02_sum
  DW02_sum #(num_inputs,  input_width)
    U1 ( .INPUT(inst_INPUT),  .SUM(SUM_inst) );

endmodule


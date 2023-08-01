module DW02_sum_func(SUM_func,func_INPUT);
  parameter func_num_inputs = 8;
  parameter func_input_width = 8;

  // Passes the widths to the vector adder function
  parameter num_inputs = func_num_inputs;
  parameter input_width = func_input_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW02_sum_function.inc"

  input [func_input_width*func_num_inputs-1:0] func_INPUT;

  output [func_input_width*func_num_inputs-1:0] SUM_func;

  wire [func_input_width*func_num_inputs-1:0] SUM_func;

  // infer DW02_sum
  assign SUM_func = DWF_sum(func_INPUT);
endmodule


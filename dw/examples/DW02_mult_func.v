module DW02_mult_func (in1, in2, prod1, prod2);
  parameter func_A_width = 8, func_B_width = 8;

  // Pass the widths to the DWF_mult functions
  parameter A_width = func_A_width, B_width = func_B_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW02_mult_function.inc"

  input [func_A_width-1 : 0] in1;
  input [func_B_width-1 : 0] in2;
  output [func_A_width-1 : 0] prod1, prod2;

  assign prod1 =  DWF_mult_tc(in1, in2);
  assign prod2 =  DWF_mult_uns(in1, in2);

endmodule


module DW_gray2bin_func (func_g, b_func);

  parameter func_width = 8;

  input  [func_width-1 : 0] func_g;
  output [func_width-1 : 0] b_func;

  // pass "width" parameters to the inference functions
  parameter width = func_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_gray2bin_function.inc"

  // function inference of DW_gray2bin
  assign b_func = DWF_gray2bin (func_g);
endmodule


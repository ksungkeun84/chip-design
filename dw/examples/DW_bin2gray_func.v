module DW_bin2gray_func (func_b, g_func);

  parameter func_width = 8;

  input  [func_width-1 : 0] func_b;
  output [func_width-1 : 0] g_func;

  // pass "width" parameters to the inference functions
  parameter width = func_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_bin2gray_function.inc"

  // function inference of DW_bin2gray
  assign g_func = DWF_bin2gray (func_b);
endmodule

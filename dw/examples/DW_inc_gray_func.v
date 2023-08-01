module DW_inc_gray_func (func_a, func_ci, z_func);

  parameter func_width = 8;

  input  [func_width-1 : 0] func_a;
  input                     func_ci;
  output [func_width-1 : 0] z_func;

  // pass "width" parameters to the inference functions
  parameter width = func_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_inc_gray_function.inc"

  // function inference of DW_inc_gray
  assign z_func = DWF_inc_gray (func_a, func_ci);
endmodule


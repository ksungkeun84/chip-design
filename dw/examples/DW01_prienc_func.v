module DW01_prienc_func (func_A,INDEX_func);
  parameter func_A_width = 8;
  parameter func_INDEX_width = 4;

  // Passes the widths to the prienc function
  parameter A_width = func_A_width;
  parameter INDEX_width = func_INDEX_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW01_prienc_function.inc"

  input [func_A_width-1:0] func_A;
  output [func_INDEX_width-1:0] INDEX_func;
  assign INDEX_func = DWF_prienc(func_A);

endmodule

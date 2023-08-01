module DW01_binenc_func (func_A,ADDR_func);
  parameter func_A_width = 8;
  parameter func_ADDR_width = 4;

  // Passes the widths to the binary encoder function
  parameter A_width = func_A_width;
  parameter ADDR_width = func_ADDR_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW01_binenc_function.inc"

  input [func_A_width-1:0] func_A;
  output [func_ADDR_width-1:0] ADDR_func;
  assign ADDR_func = DWF_binenc(func_A);
endmodule

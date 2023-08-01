module DW01_decode_func (func_A,B_func);
  parameter func_width = 4;

  // Passes the width to the decode function
  parameter width = func_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW01_decode_function.inc"

  input [func_width-1:0] func_A;

  output [(1 << func_width)-1:0] B_func;

  assign B_func = DWF_decode(func_A);

endmodule


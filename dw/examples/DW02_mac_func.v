module DW02_mac_func (func_A, func_B, func_C, func_TC, MAC_func);
  parameter func_A_width = 8;
  parameter func_B_width = 8;

  // Passes the widths to the multiplier-accumulator function
  parameter A_width = func_A_width;
  parameter B_width = func_B_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW02_mac_function.inc"

  input [func_A_width-1 : 0]              func_A;
  input [func_B_width-1 : 0]              func_B;
  input [func_A_width+func_B_width-1 : 0] func_C;
  input                                   func_TC;

  output [func_A_width+func_B_width-1 : 0] MAC_func; 

  assign MAC_func = (func_TC) ? DWF_mac_tc(func_A, func_B, func_C) :                                 DWF_mac_uns(func_A, func_B, func_C);

endmodule


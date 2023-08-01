module DW_lza_func( func_a, func_b, count_func );

  parameter func_width = 7;

  // Passes widths to lza function with specific paramters
  parameter width       = func_width;
  parameter addr_width  = 3;    // NEEDS TO BE ceil(log2(func_width))

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_lza_function.inc"

  input [func_width-1 : 0] func_a;
  input [func_width-1 : 0] func_b;
  output [addr_width-1 : 0] count_func;

   // Function inference of DW_lz
  assign count_func = DWF_lza(func_a,func_b);

endmodule

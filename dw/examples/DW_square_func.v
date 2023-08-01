module DW_square_func( func_a, func_tc, square_func );

  parameter func_width = 8;
  // Pass the width to the function
  parameter width = func_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"} 
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_square_function.inc"

  input [func_width-1 : 0] func_a;
  input func_tc;
  output [(2*func_width)-1 : 0] square_func;

  // Funtional inference of DW_square
  assign square_func = (func_tc == 1'b0)?
    DWF_square_uns(func_a) : // for unsigned input
    DWF_square_tc(func_a);   // for signed input
endmodule


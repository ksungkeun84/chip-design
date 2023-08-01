module DW_sqrt_func (radicand, square_root_uns, square_root_tc);

  parameter radicand_width = 8;

  input  [radicand_width-1 : 0]       radicand;
  output [(radicand_width+1)/2-1 : 0] square_root_uns;
  output [(radicand_width+1)/2-1 : 0] square_root_tc;

  // pass the "func_width" parameter to the inference functions
  parameter width = radicand_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_sqrt_function.inc"

  // function calls for unsigned/signed square root
  assign square_root_uns = DWF_sqrt_uns (radicand);
  assign square_root_tc  = DWF_sqrt_tc (radicand);

endmodule


module DW_div_sat_func (a, b, quotient_uns, quotient_tc);

  parameter width = 8;

  input  [2*width-1 : 0] a;
  input    [width-1 : 0] b;
  output   [width-1 : 0] quotient_uns;
  output   [width-1 : 0] quotient_tc;

  // pass "a_width", "b_width", "q_width" parameters to the inference functions
  parameter a_width = 2*width;
  parameter b_width = width;
  parameter q_width = width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_div_sat_function.inc"

  // function calls for unsigned/signed quotient
  assign quotient_uns = DWF_div_sat_uns (a, b);
  assign quotient_tc  = DWF_div_sat_tc (a, b);

endmodule

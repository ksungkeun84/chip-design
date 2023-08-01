module DW_div_func (a, b, quotient_uns, quotient_tc, remainder_uns,
                    remainder_tc, modulus_uns, modulus_tc);

  parameter width = 8;

  input  [width-1 : 0] a;
  input  [width-1 : 0] b;
  output [width-1 : 0] quotient_uns;
  output [width-1 : 0] quotient_tc;
  output [width-1 : 0] remainder_uns;
  output [width-1 : 0] remainder_tc;
  output [width-1 : 0] modulus_uns;
  output [width-1 : 0] modulus_tc;

  // pass "a_width" and "b_width" parameters to the inference functions
  parameter a_width = width;
  parameter b_width = width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_div_function.inc"

  // function calls for unsigned/signed quotient, remainder and modulus
  assign quotient_uns  = DWF_div_uns (a, b);
  assign quotient_tc   = DWF_div_tc (a, b);
  assign remainder_uns = DWF_rem_uns (a, b); // corresponds to "%" in Verilog
  assign remainder_tc  = DWF_rem_tc (a, b);  // corresponds to "%" in Verilog
  assign modulus_uns   = DWF_mod_uns (a, b); // corresponds to "mod" in VHDL
  assign modulus_tc    = DWF_mod_tc (a, b);  // corresponds to "mod" in VHDL

endmodule


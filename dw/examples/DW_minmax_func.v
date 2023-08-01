// example: functional inference of 4-input minimum/maximum component
module DW_minmax_func (a0, a1, a2, a3, tc, max, val);

  parameter wordlength = 8;

  input  [wordlength-1 : 0] a0, a1, a2, a3;
  input  tc, max;
  output [wordlength-1 : 0] val;

  // pass "width" and "num_inputs" parameters to the inference functions
  parameter width = wordlength;
  parameter num_inputs = 4;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_minmax_function.inc"

  // function calls for unsigned/signed minimum/maximum
  // inputs are concatenated into the function call operand
  assign val = 
    (max == 1'b0) ? ((tc == 1'b0) ? DWF_min_uns({a3, a2, a1, a0}) :
                                    DWF_min_tc ({a3, a2, a1, a0})) :
                    ((tc == 1'b0) ? DWF_max_uns({a3, a2, a1, a0}) : 
                                    DWF_max_tc ({a3, a2, a1, a0}));
endmodule


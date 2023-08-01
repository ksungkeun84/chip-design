module DWF_dp_mult_comb_test (a, b, c, a_tc, b_tc, z);

  input   [7:0] a, b, c;
  input         a_tc, b_tc;
  output [15:0] z;

  // Passes the parameters to the function
  parameter a_width = 8;
  parameter b_width = 8;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_mult_comb_function.inc"

  assign z = DWF_dp_mult_comb (a, a_tc, b, b_tc) + c;

endmodule

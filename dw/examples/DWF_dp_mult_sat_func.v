module DWF_dp_mult_sat_test (a, b, c, z);

  input  signed [7:0] a, b, c;
  output signed [7:0] z;

  // Passes the parameters to the function
  parameter a_width = 8;
  parameter b_width = 8;
  parameter p_width = 8;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_mult_sat_function.inc"

  assign z = DWF_dp_mult_sat_tc (a, b) + c;

endmodule

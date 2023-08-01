module DWF_dp_sub_abs_test (a, b, c, d, z);

  input  signed  [7:0] a, b, c, d;
  output signed [15:0] z;

  // Passes the parameter to the function
  parameter width = 16;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_sub_abs_function.inc"

  assign z = DWF_dp_sub_abs_tc (a * b, c) + d;

endmodule

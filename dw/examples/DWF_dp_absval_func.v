module DWF_dp_absval_test (a, b, c, z);

  input  signed  [7:0] a, b, c;
  output signed [15:0] z;

  // Passes the parameter to the function
  parameter width = 16;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_absval_function.inc"

  assign z = DWF_dp_absval (a * b) + c;

endmodule

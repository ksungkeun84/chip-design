module DWF_dp_sign_select_test (a, b, c, s, z);

  input  signed  [7:0] a, b, c;
  input                s;
  output signed [15:0] z;

  // Passes the parameter to the function
  parameter width = 16;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_sign_select_function.inc"

  assign z = DWF_dp_sign_select_tc (a * b, s) + c;

endmodule

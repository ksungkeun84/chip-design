module DWF_dp_count_ones_test (a, b, z);

  input  [7:0] a;
  input  [3:0] b;
  output       z;

  // Passes the parameters to the function
  parameter width = 8;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_count_ones_function.inc"

  assign z = (DWF_dp_count_ones (a) >= b) ? 1'b1 : 1'b0;

endmodule

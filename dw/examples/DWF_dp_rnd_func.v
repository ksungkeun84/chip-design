module DWF_dp_rnd_test (a, b, c, z);

  input  signed [7:0] a, b, c;
  output signed [7:0] z;

  // Passes the parameters to the function
  parameter width = 16;
  parameter lsb   = 8;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_rnd_function.inc"

  assign z = DWF_dp_rnd_tc (a * b, DW_dp_rnd_near_even) + c;

endmodule

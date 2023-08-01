module DWF_dp_simd_mult_test (op1, op2, config_no, product);

  input  signed [31:0] op1, op2;
  input         [1:0]  config_no;
  output signed [63:0] product;

  // Passes the parameters to the function
  parameter width    = 32;
  parameter no_confs = 3;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_simd_mult_function.inc"

  assign product = DWF_dp_simd_mult_tc (op1, op2, config_no);

endmodule

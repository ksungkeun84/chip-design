module DWF_dp_simd_add_test (op1, op2, config_no, sum);

  input  signed [31:0] op1, op2;
  input         [1:0]  config_no;
  output signed [31:0] sum;

  // Passes the parameters to the function
  parameter width    = 32;
  parameter no_confs = 3;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_simd_add_function.inc"

  assign sum = DWF_dp_simd_add_tc (op1, op2, config_no);

endmodule

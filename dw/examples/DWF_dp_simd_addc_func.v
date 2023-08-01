module DWF_dp_simd_addc_test (op1, op2, c_in, config_no, sum, c_out);

  input  signed [31:0] op1, op2;
  input         [3:0]  c_in;
  input         [1:0]  config_no;
  output signed [31:0] sum;
  output        [3:0]  c_out;
  reg    signed [31:0] sum;
  reg           [3:0]  c_out;

  // Passes the parameters to the function
  parameter width    = 32;
  parameter no_confs = 3;

  // add "$SYNOPSYS/dw/sim_ver" to the search path for simulation
  `include "DW_dp_simd_addc_function.inc"

  always @* begin
    DWF_dp_simd_addc_tc (op1, op2, c_in, config_no, sum, c_out);
  end

endmodule

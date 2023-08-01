module DW_lsd_func (func_a, enc_func, dec_func);

  parameter func_a_width = 8;

`define enc_width 3	// enc_width is set to ceil(log2(a_width))

  // Passes the widths to DW_lsd_function
  parameter a_width     = func_a_width;
  parameter addr_width  = `enc_width;

`include "DW_lsd_function.inc"

  input  [func_a_width-1 : 0] func_a;
  output   [`enc_width-1 : 0] enc_func;
  output [func_a_width-1 : 0] dec_func;

  // Function inference of DW_lsd_enc and DW_lsd
  assign enc_func = DWF_lsd_enc (func_a);
  assign dec_func = DWF_lsd (func_a);

endmodule

module DW_pricod_func (func_a, cod_func);

  parameter func_a_width = 8;

  // Passes the width to DW_pricod_function
  parameter a_width = func_a_width;

`include "DW_pricod_function.inc"

  input  [func_a_width-1 : 0] func_a;
  output [func_a_width-1 : 0] cod_func;

  // Function inference of DW_pricod
  assign cod_func = DWF_pricod (func_a);

endmodule


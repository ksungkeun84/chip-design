module DW_lod_func( func_a, dec_func, enc_func );

parameter func_a_width = 8;

`define enc_width 4  // ceil(log2(func_a_width))+1

// Passes the widths to DW_lod_function
parameter a_width     = func_a_width;
parameter addr_width  = `enc_width;
`include "DW_lod_function.inc"

input  [func_a_width-1 : 0] func_a;
output [func_a_width-1 : 0] dec_func;
output [`enc_width-1 : 0] enc_func;

    // Function inference of DW_lod and DW_lod_enc
    assign dec_func = DWF_lod(func_a);
    assign enc_func = DWF_lod_enc(func_a);

endmodule



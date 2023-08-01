module DW_lbsh_func( func_A, func_SH, func_SH_TC, B_func );

parameter func_A_width = 8;
parameter func_SH_width = 3;

// secondary parameters used to pass parameters to function
// when parameter names differ

parameter A_width = func_A_width;
parameter SH_width = func_SH_width;

// Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
// to your .synopsys_dc.setup file (for synthesis) and add
// +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
// (for simulation).
`include "DW_lbsh_function.inc"


input [func_A_width-1 : 0] func_A;
input [func_SH_width-1 : 0] func_SH;
input func_SH_TC;
output [func_A_width-1 : 0] B_func;


    // Infer DW_lbsh

     assign B_func = DWF_lbsh_uns(func_A,func_SH);

endmodule


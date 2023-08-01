module DW01_ash_func (func_A, func_DATA_TC, func_SH, func_SH_TC, B_func);
  parameter func_A_width = 8;
  parameter func_SH_width = 3;

  // Passes the widths to the arithmetic shifter function
  parameter A_width = func_A_width;
  parameter SH_width = func_SH_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW01_ash_function.inc"

  input [func_A_width-1:0] func_A;
  input [func_SH_width-1:0] func_SH;
  input func_DATA_TC, func_SH_TC;
  output [func_A_width-1:0] B_func;
  reg [func_A_width-1:0] B_func;

  // infer DW01_ash
  always @ (func_A or func_DATA_TC or func_SH or func_SH_TC)
  begin
    casex({func_DATA_TC,func_SH_TC}) // synopsys full_case
      2'b00: B_func = DWF_ash_uns_uns(func_A,func_SH);
      2'b10: B_func = DWF_ash_tc_uns(func_A,func_SH);
      2'b01: B_func = DWF_ash_uns_tc(func_A,func_SH);
      2'b11: B_func = DWF_ash_tc_tc(func_A,func_SH);
    endcase
  end 
endmodule


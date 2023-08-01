module DW_shifter_func (func_data_in, func_data_tc, func_sh, 
                        func_sh_tc, func_sh_mode, data_out_func);
  parameter func_data_width = 8;
  parameter func_sh_width = 3;

  // Passes the widths to the shifter function
  parameter data_width = func_data_width;
  parameter sh_width = func_sh_width;

  // Please add search_path = search_path + {synopsys_root + "/dw/sim_ver"}
  // to your .synopsys_dc.setup file (for synthesis) and add
  // +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator command line
  // (for simulation).
  `include "DW_shifter_function.inc"

  input [func_data_width-1:0] func_data_in;
  input [func_sh_width-1:0] func_sh;
  input func_data_tc, func_sh_tc, func_sh_mode;

  output [func_data_width-1:0] data_out_func;

  reg [func_data_width-1:0] data_out_func;
 
  // infer DW_shifter

  always @ (func_data_in or func_data_tc or func_sh 
            or func_sh_tc or func_sh_mode)
  begin
    casex({func_data_tc,func_sh_tc}) // synopsys full_case
      2'b00: data_out_func =         DWF_shifter_uns_uns(func_data_in,func_sh,func_sh_mode);
      2'b10: data_out_func =         DWF_shifter_tc_uns(func_data_in,func_sh,func_sh_mode);
      2'b01: data_out_func =         DWF_shifter_uns_tc(func_data_in,func_sh,func_sh_mode);
      2'b11: data_out_func =         DWF_shifter_tc_tc(func_data_in,func_sh,func_sh_mode);
    endcase
  end 

endmodule


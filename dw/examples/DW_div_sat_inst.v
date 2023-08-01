module DW_div_sat_inst (a, b, quotient, divide_by_0);

  parameter width   = 8;
  parameter tc_mode = 0;

  input  [2*width-1 : 0] a;
  input    [width-1 : 0] b;
  output   [width-1 : 0] quotient;
  output                 divide_by_0;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).

  // instance of DW_div_sat
  DW_div_sat #(2*width, width, width, tc_mode)
    U1 (.a(a), .b(b),
        .quotient(quotient), .divide_by_0(divide_by_0));
endmodule

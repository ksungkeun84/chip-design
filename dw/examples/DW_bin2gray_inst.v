module DW_bin2gray_inst (inst_b, g_inst);

  parameter inst_width = 8;

  input  [inst_width-1 : 0] inst_b;
  output [inst_width-1 : 0] g_inst;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).

  // instance of DW_bin2gray
  DW_bin2gray #(inst_width) 
    U1 (.b(inst_b),.g(g_inst));
endmodule


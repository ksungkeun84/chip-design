module DW_gray2bin_inst (inst_g, b_inst);

  parameter inst_width = 8;

  input  [inst_width-1 : 0] inst_g;
  output [inst_width-1 : 0] b_inst;
  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).
  // instance of DW_gray2bin
  DW_gray2bin #(inst_width) 
    U1 (.g(inst_g),
        .b(b_inst));
endmodule

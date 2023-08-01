module DW_sqrt_inst (radicand, square_root);
  parameter radicand_width = 8;
  parameter tc_mode        = 0;

  input  [radicand_width-1 : 0]       radicand;
  output [(radicand_width+1)/2-1 : 0] square_root;
  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator 
  // command line (for simulation).

  // instance of DW_sqrt
  DW_sqrt #(radicand_width, tc_mode) 
    U1 (.a(radicand), .root(square_root));
endmodule

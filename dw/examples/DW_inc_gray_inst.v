module DW_inc_gray_inst (inst_a, inst_ci, z_inst);

  parameter inst_width = 8;

  input  [inst_width-1 : 0] inst_a;
  input                     inst_ci;
  output [inst_width-1 : 0] z_inst;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).

  // instance of DW_inc_gray
  DW_inc_gray #(inst_width) 
    U1 (.a(inst_a),
        .ci(inst_ci),
        .z(z_inst));
endmodule


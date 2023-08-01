module DW_fp_square_inst( inst_a, inst_rnd, z_inst, status_inst );

parameter sig_width = 23;
parameter exp_width = 8;
parameter ieee_compliance = 0;

input [sig_width+exp_width : 0] inst_a;
input [2 : 0] inst_rnd;
output [sig_width+exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_fp_square
    DW_fp_square #(sig_width, exp_width, ieee_compliance)
          U1 ( .a(inst_a), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );

endmodule

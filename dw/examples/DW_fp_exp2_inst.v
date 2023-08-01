module DW_fp_exp2_inst( inst_a, z_inst, status_inst );

parameter inst_sig_width = 10;
parameter inst_exp_width = 5;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;


input [inst_sig_width+inst_exp_width : 0] inst_a;
output [inst_sig_width+inst_exp_width : 0] z_inst;
output [7 : 0] status_inst;

    // Instance of DW_fp_exp2
    DW_fp_exp2 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) U1 (
                        .a(inst_a),
                        .z(z_inst),
                        .status(status_inst) );

endmodule

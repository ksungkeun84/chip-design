module DW_lbsh_inst( inst_A, inst_SH, inst_SH_TC, B_inst );

parameter A_width = 8;
parameter SH_width = 3;


input [A_width-1 : 0] inst_A;
input [SH_width-1 : 0] inst_SH;
input inst_SH_TC;
output [A_width-1 : 0] B_inst;

    // Instance of DW_lbsh
    DW_lbsh #(A_width, SH_width) U1 (
			.A(inst_A),
			.SH(inst_SH),
			.SH_TC(inst_SH_TC),
			.B(B_inst) );

endmodule


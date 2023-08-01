module DW_sincos_inst( inst_A, inst_SIN_COS, WAVE_inst );

parameter inst_A_width = 24;
parameter inst_WAVE_width = 25;
parameter inst_arch = 0;
parameter inst_err_range = 1;


input [inst_A_width-1 : 0] inst_A;
input inst_SIN_COS;
output [inst_WAVE_width-1 : 0] WAVE_inst;

    // Instance of DW_sincos
    DW_sincos #(inst_A_width, inst_WAVE_width, inst_arch, inst_err_range) U1 (
			.A(inst_A),
			.SIN_COS(inst_SIN_COS),
			.WAVE(WAVE_inst) );

endmodule

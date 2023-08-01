module DW_reset_sync_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, inst_clr_s, 
                clr_sync_s_inst, clr_in_prog_s_inst, clr_cmplt_s_inst,
		inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_clr_d, clr_in_prog_d_inst,
		clr_sync_d_inst, clr_cmplt_d_inst, inst_test );

parameter f_sync_type = 2;
parameter r_sync_type  = 2;
parameter clk_d_faster = 1;
parameter reg_in_prog = 1;
parameter tst_mode = 0;
parameter verif_en = 1;


input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_clr_s;
output clr_sync_s_inst;
output clr_in_prog_s_inst;
output clr_cmplt_s_inst;

input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input inst_clr_d;
output clr_in_prog_d_inst;
output clr_sync_d_inst;
output clr_cmplt_d_inst;

input inst_test;

    // Instance of DW_reset_sync
    DW_reset_sync #(f_sync_type, r_sync_type, clk_d_faster, reg_in_prog, tst_mode, verif_en)
	  U1 ( .clk_s(inst_clk_s), .rst_s_n(inst_rst_s_n), .init_s_n(inst_init_s_n), .clr_s(inst_clr_s), .clr_sync_s(clr_sync_s_inst), .clr_in_prog_s(clr_in_prog_s_inst), .clr_cmplt_s(clr_cmplt_s_inst), .clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), .clr_d(inst_clr_d), .clr_in_prog_d(clr_in_prog_d_inst), .clr_sync_d( clr_sync_d_inst), .clr_cmplt_d(clr_cmplt_d_inst), .test(inst_test) );

endmodule

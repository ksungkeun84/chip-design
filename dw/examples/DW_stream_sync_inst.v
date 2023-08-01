module DW_stream_sync_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, 
	inst_clr_s, inst_send_s, inst_data_s,
	clr_sync_s_inst, clr_in_prog_s_inst, clr_cmplt_s_inst,
	inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_clr_d, inst_prefill_d,
	clr_in_prog_d_inst, clr_sync_d_inst, clr_cmplt_d_inst, 
	data_avail_d_inst, data_d_inst, prefilling_d_inst, inst_test );

parameter width        = 8;  // RANGE 1 to 1024
parameter depth        = 4;  // RANGE 2 to 256
parameter prefill_lvl  = 0;  // RANGE 0 to 255
parameter f_sync_type  = 2;  // RANGE 0 to 3
parameter reg_stat     = 1;  // RANGE 0 to 1
parameter tst_mode     = 0;  // RANGE 0 to 1
parameter verif_en     = 2;  // RANGE 0 to 2
parameter r_sync_type  = 2;  // RANGE 0 to 3
parameter clk_d_faster = 1;  // RANGE 0 to 15
parameter reg_in_prog  = 1;  // RANGE 0 to 1



input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_clr_s;
input inst_send_s;
input [width-1 : 0] inst_data_s;
output clr_sync_s_inst;
output clr_in_prog_s_inst;
output clr_cmplt_s_inst;

input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input inst_clr_d;
input inst_prefill_d;
output clr_in_prog_d_inst;
output clr_sync_d_inst;
output clr_cmplt_d_inst;
output data_avail_d_inst;
output [width-1 : 0] data_d_inst;
output prefilling_d_inst;

input inst_test;


// Instance of DW_stream_sync
DW_stream_sync #(width, depth, prefill_lvl, f_sync_type, reg_stat, tst_mode, verif_en, r_sync_type, clk_d_faster, reg_in_prog) U1 (
            .clk_s(inst_clk_s),
            .rst_s_n(inst_rst_s_n),
            .init_s_n(inst_init_s_n),
            .clr_s(inst_clr_s),
            .send_s(inst_send_s),
            .data_s(inst_data_s),
            .clr_sync_s(clr_sync_s_inst),
            .clr_in_prog_s(clr_in_prog_s_inst),
            .clr_cmplt_s(clr_cmplt_s_inst),

            .clk_d(inst_clk_d),
            .rst_d_n(inst_rst_d_n),
            .init_d_n(inst_init_d_n),
            .clr_d(inst_clr_d),
            .prefill_d(inst_prefill_d),
            .clr_in_prog_d(clr_in_prog_d_inst),
            .clr_sync_d(clr_sync_d_inst),
            .clr_cmplt_d(clr_cmplt_d_inst),
            .data_avail_d(data_avail_d_inst),
            .data_d(data_d_inst),
            .prefilling_d(prefilling_d_inst),

            .test(inst_test)
            );

endmodule


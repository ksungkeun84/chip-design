module DW_fifo_2c_df_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, inst_clr_s, inst_ae_level_s, 
		inst_af_level_s, inst_push_s_n, inst_data_s, clr_sync_s_inst, clr_in_prog_s_inst, clr_cmplt_s_inst, 
		fifo_word_cnt_s_inst, word_cnt_s_inst, fifo_empty_s_inst, 
		empty_s_inst, almost_empty_s_inst, half_full_s_inst, almost_full_s_inst, full_s_inst, 
		error_s_inst, inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_clr_d, 
		inst_ae_level_d, inst_af_level_d, inst_pop_d_n, clr_sync_d_inst, clr_in_prog_d_inst, 
		clr_cmplt_d_inst, data_d_inst, word_cnt_d_inst, empty_d_inst, almost_empty_d_inst, 
                half_full_d_inst, almost_full_d_inst, full_d_inst, error_d_inst, inst_test );

parameter width = 8;
parameter ram_depth = 8;
parameter mem_mode = 5;
parameter f_sync_type = 2;
parameter r_sync_type = 2;
parameter clk_ratio = 3;
parameter rst_mode = 1;
parameter err_mode = 1;
parameter tst_mode = 0;
parameter verif_en = 1;
parameter clr_dual_domain = 1;
`define ram_cnt_width  4 // ceil(log2(ram_depth+1))
`define fifo_cnt_width 4 // ceil(log2((ram_depth+1+(mem_mode % 2)+((mem_mode/2) % 2))+1))


input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_clr_s;
input [`ram_cnt_width-1:0] inst_ae_level_s;
input [`ram_cnt_width-1:0] inst_af_level_s;
input inst_push_s_n;
input [width-1:0] inst_data_s;

output clr_sync_s_inst;
output clr_in_prog_s_inst;
output clr_cmplt_s_inst;
output [`fifo_cnt_width-1:0] fifo_word_cnt_s_inst;
output [`ram_cnt_width-1:0] word_cnt_s_inst;
output fifo_empty_s_inst;
output empty_s_inst;
output almost_empty_s_inst;
output half_full_s_inst;
output almost_full_s_inst;
output full_s_inst;
output error_s_inst;

input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input inst_clr_d;
input [`fifo_cnt_width-1:0] inst_ae_level_d;
input [`fifo_cnt_width-1:0] inst_af_level_d;
input inst_pop_d_n;

output clr_sync_d_inst;
output clr_in_prog_d_inst;
output clr_cmplt_d_inst;
output [width-1:0] data_d_inst;
output [`fifo_cnt_width-1:0] word_cnt_d_inst;
output empty_d_inst;
output almost_empty_d_inst;
output half_full_d_inst;
output almost_full_d_inst;
output full_d_inst;
output error_d_inst;

input inst_test;

    // Instance of DW_fifo_2c_df
    DW_fifo_2c_df #(width, ram_depth, mem_mode, f_sync_type, r_sync_type, clk_ratio, rst_mode, err_mode, tst_mode, verif_en, clr_dual_domain)
	  U1 ( .clk_s(inst_clk_s), .rst_s_n(inst_rst_s_n), 
.init_s_n(inst_init_s_n), .clr_s(inst_clr_s), .ae_level_s(inst_ae_level_s), 


.af_level_s(inst_af_level_s), .push_s_n(inst_push_s_n), .data_s(inst_data_s), 
.clr_sync_s(clr_sync_s_inst), .clr_in_prog_s(clr_in_prog_s_inst), 
.clr_cmplt_s(clr_cmplt_s_inst), .fifo_word_cnt_s(fifo_word_cnt_s_inst), 
.word_cnt_s(word_cnt_s_inst), .fifo_empty_s(fifo_empty_s_inst), 
.empty_s(empty_s_inst), .almost_empty_s(almost_empty_s_inst), 
.half_full_s(half_full_s_inst), .almost_full_s(almost_full_s_inst), 
.full_s(full_s_inst), .error_s(error_s_inst), .clk_d(inst_clk_d), 
.rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), .clr_d(inst_clr_d), 
.ae_level_d(inst_ae_level_d), .af_level_d(inst_af_level_d), 
.pop_d_n(inst_pop_d_n), .clr_sync_d(clr_sync_d_inst), 
.clr_in_prog_d(clr_in_prog_d_inst), .clr_cmplt_d(clr_cmplt_d_inst), 
.data_d(data_d_inst), .word_cnt_d(word_cnt_d_inst), .empty_d(empty_d_inst), 
.almost_empty_d(almost_empty_d_inst), .half_full_d(half_full_d_inst), 
.almost_full_d(almost_full_d_inst), .full_d(full_d_inst), 
.error_d(error_d_inst), .test(inst_test) );

endmodule

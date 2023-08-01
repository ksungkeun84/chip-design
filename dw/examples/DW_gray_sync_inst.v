module DW_gray_sync_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, inst_en_s, 
			  count_s_inst, offset_count_s_inst, inst_clk_d, inst_rst_d_n, 
			  inst_init_d_n, count_d_inst, inst_test );

parameter width = 8;
parameter offset = 0;
parameter reg_count_d = 1;
parameter f_sync_type = 2;
parameter tst_mode = 0;
parameter verif_en = 2;
parameter pipe_delay = 0;
parameter reg_count_s = 1;
parameter reg_offset_count_s = 1;


input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_en_s;
output [width-1 : 0] count_s_inst;
output [width-1 : 0] offset_count_s_inst;

input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
output [width-1 : 0] count_d_inst;

input inst_test;

    // Instance of DW_gray_sync
    DW_gray_sync #(width, offset, reg_count_d, f_sync_type, tst_mode, verif_en, pipe_delay, reg_count_s, reg_offset_count_s) 
         U1 ( .clk_s(inst_clk_s), .rst_s_n(inst_rst_s_n), .init_s_n(inst_init_s_n), 
              .en_s(inst_en_s), .count_s(count_s_inst), .offset_count_s(offset_count_s_inst), 
              .clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), 
              .count_d(count_d_inst), .test(inst_test) );

endmodule

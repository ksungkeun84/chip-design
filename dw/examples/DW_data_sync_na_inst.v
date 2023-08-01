module DW_data_sync_na_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, inst_send_s, inst_data_s, 
		inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_test, data_avail_d_inst, 
		data_d_inst );

parameter width = 8;
parameter f_sync_type = 2;
parameter tst_mode = 0;
parameter verif_en = 2;


input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_send_s;
input [width-1 : 0] inst_data_s;
input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input inst_test;
output data_avail_d_inst;
output [width-1 : 0] data_d_inst;

    // Instance of DW_data_sync_na
    DW_data_sync_na #(width, f_sync_type, tst_mode, verif_en)
	  U1 ( .clk_s(inst_clk_s), .rst_s_n(inst_rst_s_n), 
.init_s_n(inst_init_s_n), .send_s(inst_send_s), .data_s(inst_data_s), 
.clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), 
.test(inst_test), .data_avail_d(data_avail_d_inst), .data_d(data_d_inst) );

endmodule


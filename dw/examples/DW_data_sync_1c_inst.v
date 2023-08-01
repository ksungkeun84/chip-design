module DW_data_sync_1c_inst( inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_data_s, inst_filt_d, 
                                                      inst_test,  data_avail_d_inst, data_d_inst, max_skew_d_inst );

parameter width = 8;
parameter f_sync_type = 2;
parameter filt_size = 1;
parameter tst_mode = 0;
parameter verif_en = 1;


input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input [width-1 : 0]     inst_data_s;
input [filt_size-1 : 0] inst_filt_d;
input inst_test;
output                      data_avail_d_inst;
output [width-1 : 0] data_d_inst;
output [filt_size : 0] max_skew_d_inst;

    // Instance of DW_data_sync_1c
    DW_data_sync_1c #(width, f_sync_type, filt_size, tst_mode, verif_en)
          U1 ( .clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n),  .init_d_n(inst_init_d_n),
                  .data_s(inst_data_s), .filt_d(inst_filt_d), .test(inst_test), 
                  .data_avail_d(data_avail_d_inst), .data_d(data_d_inst),
                  .max_skew_d(max_skew_d_inst) );

endmodule


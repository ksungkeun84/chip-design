module DW_sync_inst( inst_clk_d, inst_rst_d_n, inst_init_d_n, inst_data_s, inst_test, data_d_inst );

parameter width = 8;
parameter f_sync_type = 2;
parameter tst_mode = 0;
parameter verif_en = 1;


input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input [width-1 : 0] inst_data_s;
input inst_test;
output [width-1 : 0] data_d_inst;

    // Instance of DW_sync
    DW_sync #(width, f_sync_type, tst_mode, verif_en)
          U1 ( .clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), .data_s(inst_data_s), .test(inst_test), .data_d(data_d_inst) );

endmodule


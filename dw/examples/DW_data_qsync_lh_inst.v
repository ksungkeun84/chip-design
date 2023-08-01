module DW_data_qsync_lh_inst( inst_clk_s,
                              inst_rst_s_n,
                              inst_init_s_n,
                              inst_send_s,
                              inst_data_s,
                 
		              inst_clk_d,
                              inst_rst_d_n,
                              inst_init_d_n,
                              data_avail_d_inst,
                              data_d_inst,
                 
		              inst_test );

parameter width      = 8;
parameter clk_ratio  = 2;
parameter reg_data_s = 1;
parameter reg_data_d = 1;
parameter tst_mode   = 0;


input               inst_clk_s;
input               inst_rst_s_n;
input               inst_init_s_n;
input               inst_send_s;
input [width-1 : 0] inst_data_s;
input               inst_clk_d;
input               inst_rst_d_n;
input               inst_init_d_n;

output               data_avail_d_inst;
output [width-1 : 0] data_d_inst;
input                inst_test;

    // Instance of DW_data_qsync_lh
    DW_data_qsync_lh #(width,
                       clk_ratio,
                       reg_data_s,
                       reg_data_d,
                       tst_mode)
	  U1 ( .clk_s(inst_clk_s),
               .rst_s_n(inst_rst_s_n),
               .init_s_n(inst_init_s_n),
               .send_s(inst_send_s),
               .data_s(inst_data_s),
               .clk_d(inst_clk_d),
               .rst_d_n(inst_rst_d_n),
               .init_d_n(inst_init_d_n),
               .data_avail_d(data_avail_d_inst),
               .data_d(data_d_inst),
               .test(inst_test) );

endmodule


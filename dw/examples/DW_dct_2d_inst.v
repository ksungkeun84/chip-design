module DW_dct_2d_inst( inst_clk,
                     inst_rst_n,
                     inst_init_n,
                     inst_enable,
                     inst_start,

		          inst_dct_rd_data,
                     inst_tp_rd_data,

                     tp_rd_add_inst,
                     tp_wr_add_inst,
                     tp_wr_data_inst,
		          tp_wr_n_inst,

                     dct_rd_add_inst,
                     dct_wr_add_inst,
                     dct_wr_n_inst,

                     done_inst,
		          ready_inst,
                     dct_wr_data_inst );

parameter bpp = 8;
parameter n = 8;
parameter reg_out = 1;
parameter tc_mode = 0;
parameter rt_mode = 1;
parameter idct_mode = 1;
parameter co_a = 23170;
parameter co_b = 32138;
parameter co_c = 30274;
parameter co_d = 27245;
parameter co_e = 18205;
parameter co_f = 12541;
parameter co_g = 6393;
parameter co_h = 35355;
parameter co_i = 49039;
parameter co_j = 46194;
parameter co_k = 41573;
parameter co_l = 27779;
parameter co_m = 19134;
parameter co_n = 9755;
parameter co_o = 35355;
parameter co_p = 49039;



`define addr_width 6  // addr_width is ceil(log2(n * n))

input inst_clk;
input inst_rst_n;
input inst_init_n;
input inst_enable;
input inst_start;
input [bpp+(n/2*idct_mode)-1 : 0] inst_dct_rd_data;
input [bpp/2+bpp+3+((1-tc_mode)*(1-idct_mode)) : 0] inst_tp_rd_data;
output [`addr_width-1 : 0] tp_rd_add_inst;
output [`addr_width-1 : 0] tp_wr_add_inst;
output [bpp/2+bpp+3+((1-tc_mode)*(1-idct_mode)) : 0] tp_wr_data_inst;
output tp_wr_n_inst;
output [`addr_width-1 : 0] dct_rd_add_inst;
output [`addr_width-1 : 0] dct_wr_add_inst;
output dct_wr_n_inst;
output done_inst;
output ready_inst;
output [bpp-1+(n/2*(1-idct_mode)) : 0] dct_wr_data_inst;

    // Instance of DW_dct_2d
DW_dct_2d #(bpp, n, reg_out, tc_mode, rt_mode, idct_mode,
            co_a, co_b, co_c, co_d, co_e, co_f, co_g, co_h, co_i, co_j,
            co_k, co_l, co_m, co_n, co_o, co_p)
 	  U1 ( .clk(inst_clk),
               .rst_n(inst_rst_n),
               .init_n(inst_init_n),
               .enable(inst_enable),
               .start(inst_start),
               .dct_rd_data(inst_dct_rd_data),
               .tp_rd_data(inst_tp_rd_data),
               .tp_rd_add(tp_rd_add_inst),
               .tp_wr_add(tp_wr_add_inst),
               .tp_wr_data(tp_wr_data_inst),
               .tp_wr_n(tp_wr_n_inst),
               .dct_rd_add(dct_rd_add_inst),
               .dct_wr_add(dct_wr_add_inst),
               .dct_wr_n(dct_wr_n_inst),
               .done(done_inst),
               .ready(ready_inst),
               .dct_wr_data(dct_wr_data_inst) );

endmodule

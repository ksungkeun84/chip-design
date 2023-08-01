module DW_lp_fifoctl_1c_df_inst ( inst_clk, inst_rst_n, inst_init_n,
           inst_ae_level, inst_af_level, inst_level_change, inst_push_n,
           inst_data_in, inst_pop_n, inst_rd_data, ram_we_n_inst,
           wr_addr_inst, wr_data_inst, ram_re_n_inst, rd_addr_inst,
           data_out_inst, word_cnt_inst, empty_inst, almost_empty_inst,
            half_full_inst, almost_full_inst, full_inst, error_inst
                             );

parameter width       = 8;
parameter depth       = 8;
parameter mem_mode    = 3;
parameter arch_type   = 1;
parameter af_from_top = 1;
parameter ram_re_ext  = 0;
parameter err_mode    = 0;

`define cnt_width   4  // log2(depth+1)
`define addr_width  3  // log2(ram_depth), ram_depth = 5


input                            inst_clk;
input                            inst_rst_n;
input                            inst_init_n;
input  [`cnt_width-1:0]          inst_ae_level;
input  [`cnt_width-1:0]          inst_af_level;
input                            inst_level_change;
input                            inst_push_n;
input  [width-1:0]               inst_data_in;
input                            inst_pop_n;
input  [width-1:0]               inst_rd_data;

output                           ram_we_n_inst;
output [`addr_width-1:0]         wr_addr_inst;
output [width-1:0]               wr_data_inst;
output                           ram_re_n_inst;
output [`addr_width-1:0]         rd_addr_inst;
output [width-1:0]               data_out_inst;
output [`cnt_width-1:0]          word_cnt_inst;
output                           empty_inst;
output                           almost_empty_inst;
output                           half_full_inst;
output                           almost_full_inst;
output                           full_inst;
output                           error_inst;



DW_lp_fifoctl_1c_df #(width, depth, mem_mode, arch_type, af_from_top, ram_re_ext, err_mode) U1 (
            .clk(inst_clk),
            .rst_n(inst_rst_n),
            .init_n(inst_init_n),
            .ae_level(inst_ae_level),
            .af_level(inst_af_level),
            .level_change(inst_level_change),
            .push_n(inst_push_n),
            .data_in(inst_data_in),
            .pop_n(inst_pop_n),
            .rd_data(inst_rd_data),
            .ram_we_n(ram_we_n_inst),
            .wr_addr(wr_addr_inst),
            .wr_data(wr_data_inst),
            .ram_re_n(ram_re_n_inst),
            .rd_addr(rd_addr_inst),
            .data_out(data_out_inst),
            .word_cnt(word_cnt_inst),
            .empty(empty_inst),
            .almost_empty(almost_empty_inst),
            .half_full(half_full_inst),
            .almost_full(almost_full_inst),
            .full(full_inst),
            .error(error_inst)
            ); 

endmodule

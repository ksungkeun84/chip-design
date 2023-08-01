module DW_lp_cntr_up_df_inst(
		inst_clk, inst_rst_n,
		inst_enable, inst_ld_n,
		inst_ld_count, inst_term_val,
		count_inst, term_count_n_inst );

parameter width = 8;
parameter rst_mode = 0;
parameter reg_trmcnt = 0;


input inst_clk;
input inst_rst_n;
input inst_enable;
input inst_ld_n;
input [width-1 : 0] inst_ld_count;
input [width-1 : 0] inst_term_val;
output [width-1 : 0] count_inst;
output term_count_n_inst;

    // Instance of DW_lp_cntr_up_df
    DW_lp_cntr_up_df #(width, rst_mode, reg_trmcnt)
	  U1 ( .clk(inst_clk), .rst_n(inst_rst_n),
	       .enable(inst_enable), .ld_n(inst_ld_n),
	       .ld_count(inst_ld_count), .term_val(inst_term_val),
	       .count(count_inst), .term_count_n(term_count_n_inst) );

endmodule

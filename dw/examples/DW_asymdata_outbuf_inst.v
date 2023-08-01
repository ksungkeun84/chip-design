module DW_asymdata_outbuf_inst( inst_clk_pop, inst_rst_pop_n, 
	inst_init_pop_n, inst_pop_req_n, inst_data_in, inst_fifo_empty,
	pop_wd_n_inst, data_out_inst, part_wd_inst, pop_error_inst );

parameter inst_in_width = 16;
parameter inst_out_width = 8;
parameter inst_err_mode = 0;
parameter inst_byte_order = 0;


input inst_clk_pop;
input inst_rst_pop_n;
input inst_init_pop_n;
input inst_pop_req_n;
input [inst_in_width-1 : 0] inst_data_in;
input inst_fifo_empty;
output pop_wd_n_inst;
output [inst_out_width-1 : 0] data_out_inst;
output part_wd_inst;
output pop_error_inst;

    // Instance of DW_asymdata_outbuf
    DW_asymdata_outbuf #(inst_in_width, inst_out_width, inst_err_mode, inst_byte_order) U1 (
			.clk_pop(inst_clk_pop),
			.rst_pop_n(inst_rst_pop_n),
			.init_pop_n(inst_init_pop_n),
			.pop_req_n(inst_pop_req_n),
			.data_in(inst_data_in),
			.fifo_empty(inst_fifo_empty),
			.pop_wd_n(pop_wd_n_inst),
			.data_out(data_out_inst),
			.part_wd(part_wd_inst),
			.pop_error(pop_error_inst) );

endmodule

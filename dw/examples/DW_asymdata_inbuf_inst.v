module DW_asymdata_inbuf_inst( inst_clk_push, inst_rst_push_n, 
	inst_init_push_n, inst_push_req_n, inst_data_in,
	inst_flush_n, inst_fifo_full, push_wd_n_inst, data_out_inst, 
	inbuf_full_inst, part_wd_inst, push_error_inst );

parameter inst_in_width = 8;
parameter inst_out_width = 16;
parameter inst_err_mode = 0;
parameter inst_byte_order = 0;
parameter inst_flush_value = 0;


input inst_clk_push;
input inst_rst_push_n;
input inst_init_push_n;
input inst_push_req_n;
input [inst_in_width-1 : 0] inst_data_in;
input inst_flush_n;
input inst_fifo_full;

output push_wd_n_inst;
output [inst_out_width-1 : 0] data_out_inst;
output inbuf_full_inst;
output part_wd_inst;
output push_error_inst;

    // Instance of DW_asymdata_inbuf
    DW_asymdata_inbuf #(inst_in_width, inst_out_width, inst_err_mode, inst_byte_order, inst_flush_value) U1 (
			.clk_push(inst_clk_push),
			.rst_push_n(inst_rst_push_n),
			.init_push_n(inst_init_push_n),
			.push_req_n(inst_push_req_n),
			.data_in(inst_data_in),
			.flush_n(inst_flush_n),
			.fifo_full(inst_fifo_full),
			.push_wd_n(push_wd_n_inst),
			.data_out(data_out_inst),
			.inbuf_full(inbuf_full_inst),
			.part_wd(part_wd_inst),
			.push_error(push_error_inst) );

endmodule

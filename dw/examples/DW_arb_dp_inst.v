module DW_arb_dp_inst( inst_clk, inst_rst_n, inst_init_n, inst_enable, inst_request,
		inst_prior, inst_lock, inst_mask, parked_inst, granted_inst,
		locked_inst, grant_inst, grant_index_inst );

parameter inst_n = 4;
parameter inst_park_mode = 1;
parameter inst_park_index = 0;
parameter inst_output_mode = 1;

`define bit_width_n 2	// bit_width_n is set to ceil(log2(n))

input inst_clk;
input inst_rst_n;
input inst_init_n;
input inst_enable;
input [inst_n-1 : 0] inst_request;
input [(`bit_width_n*inst_n-1) : 0] inst_prior;
input [inst_n-1 : 0] inst_lock;
input [inst_n-1 : 0] inst_mask;
output parked_inst;
output granted_inst;
output locked_inst;
output [inst_n-1 : 0] grant_inst;
output [`bit_width_n-1 : 0] grant_index_inst;

    // Instance of DW_arb_dp
    DW_arb_dp #(inst_n, inst_park_mode, inst_park_index, inst_output_mode) U1 (
			.clk(inst_clk),
			.rst_n(inst_rst_n),
			.init_n(inst_init_n),
			.enable(inst_enable),
			.request(inst_request),
			.prior(inst_prior),
			.lock(inst_lock),
			.mask(inst_mask),
			.parked(parked_inst),
			.granted(granted_inst),
			.locked(locked_inst),
			.grant(grant_inst),
			.grant_index(grant_index_inst) );

endmodule

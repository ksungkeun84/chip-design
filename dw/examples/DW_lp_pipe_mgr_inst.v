////////////////////////////////////////////////////////////////////////////////
//
//  This example uses an instance of DW_lp_pipe_mgr along with an instance
//  of DW_pl_reg to pipeline an unsigned multiplication operation.
//
////////////////////////////////////////////////////////////////////////////////

module DW_lp_pipe_mgr_inst( inst_clk, inst_rst_n,

		pipe_full_inst, pipe_ovf_inst,	// upstream (input) status

		inst_launch, inst_launch_id,	// upstream (input) interface
		inst_a, inst_b,			// (request, ID & data)

		arrive_inst, arrive_id_inst,	// downstream (outptu) interface
		product_inst,		 	// (output indication, ID & data)

		inst_accept_n, push_out_n_inst,	// downstream (output) FIFO flow control

		pipe_census_inst 		// pipe content status

// Embedded script causes registers to be balanced
//
// synopsys dc_script_begin
// set_optimize_registers "true"
// synopsys dc_script_end

		);


parameter inst_a_width = 8;
parameter inst_b_width = 8;
parameter inst_id_width = 3;
parameter inst_stages = 4;


//  For this application, the census bus will need to be
//  wide enough to carry a value equal to 'inst_stages'
//  So, define it to be ceil(log2(inst_stages+1))
`define census_width 3

`define prod_width  (inst_a_width+inst_b_width)

input					inst_clk;
input					inst_rst_n;

output					pipe_full_inst;
output					pipe_ovf_inst;

input					inst_launch;
input [inst_id_width-1 : 0]		inst_launch_id;
input [inst_a_width-1 : 0]		inst_a;
input [inst_b_width-1 : 0]		inst_b;

output arrive_inst;
output [inst_id_width-1 : 0]		arrive_id_inst;
output [`prod_width-1 : 0]		product_inst;

input inst_accept_n;
output push_out_n_inst;

output [(`census_width)-1 : 0]		pipe_census_inst;



wire [`prod_width-1 : 0]		a_times_b;

// DW_lp_pipe_mgr will control register enables to pipe
//
wire [inst_stages-1 : 0]		local_enables;


    // operation to be pipelined is just "a * b"
    //
    assign a_times_b = inst_a * inst_b;


    // Instance of DW_lp_pipe_mgr
    DW_lp_pipe_mgr #(inst_stages, inst_id_width) U1 (
			.clk(inst_clk),
			.rst_n(inst_rst_n),
			.init_n(1'b1),
			.launch(inst_launch),
			.launch_id(inst_launch_id),
			.pipe_full(pipe_full_inst),
			.pipe_ovf(pipe_ovf_inst),
			.pipe_en_bus(local_enables),
			.accept_n(inst_accept_n),
			.arrive(arrive_inst),
			.arrive_id(arrive_id_inst),
			.push_out_n(push_out_n_inst),
			.pipe_census(pipe_census_inst) );

    // An instance of DW_pl_reg is used to get the data registers
    // in the pipe (initially stacked all at the output - but DC
    // will balance them)  Note that DW_pl_reg will ungroup itself
    // automatically so that its registers will be free to be
    // balanced into the datapath logic.
    //
    DW_pl_reg #(`prod_width, 0, inst_stages, 1, 0) U2 (
			.clk(inst_clk),
			.rst_n(inst_rst_n),
			.enable(local_enables),
			.data_in(a_times_b),
			.data_out(product_inst) );

endmodule

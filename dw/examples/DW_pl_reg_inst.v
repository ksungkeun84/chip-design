module DW_pl_reg_inst( inst_clk, inst_rst_n, inst_enable, inst_data_in, data_out_inst );

parameter width = 12;
parameter in_reg = 0;	// ignored in this design (pipe at output)
parameter stages = 4;
parameter out_reg = 0;
parameter rst_mode = 0;


input inst_clk;
input inst_rst_n;
input [stages+out_reg-2 : 0] inst_enable;
input [width-1 : 0] inst_data_in;
output [width-1 : 0] data_out_inst;

wire [(width/2)-1 : 0] left_side, right_side;
wire [width-1 : 0]     product;

  // split the input bus, inst_data_in into equal size
  // multiply operands
  //
  assign left_side  = inst_data_in[width-2 : width/2];
  assign right_side = inst_data_in[(width/2)-1 : 0];

  // perform the unsigned multiply
  //
  assign product = left_side * right_side;

  // Then, pipeline the module using an instance of DW_pl_reg
  //
  DW_pl_reg #(width, 0, stages, out_reg, rst_mode)
	  U1 ( 
	      .clk(inst_clk),
	      .rst_n(inst_rst_n),
	      .enable(inst_enable),
	      .data_in(product),
	      .data_out(data_out_inst) );

endmodule

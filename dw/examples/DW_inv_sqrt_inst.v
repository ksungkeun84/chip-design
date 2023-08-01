module DW_inv_sqrt_inst( inst_a, b_inst, t_inst );

parameter a_width = 8;


input [a_width-1 : 0] inst_a;
output [a_width-1 : 0] b_inst;
output t_inst;

    // Instance of DW_inv_sqrt
    DW_inv_sqrt #(a_width)
	  U1 ( .a(inst_a), .b(b_inst), .t(t_inst) );

endmodule


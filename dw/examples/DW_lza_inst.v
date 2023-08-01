module DW_lza_inst( inst_a, inst_b, count_inst );

parameter width = 7;


`define w (width)
`define bit_width_width 3

input [width-1 : 0] inst_a;
input [width-1 : 0] inst_b;
output [`bit_width_width-1 : 0] count_inst;

    // Instance of DW_lza
    DW_lza #(width)
	  U1 ( .a(inst_a), 
	       .b(inst_b), 
	       .count(count_inst) );

endmodule

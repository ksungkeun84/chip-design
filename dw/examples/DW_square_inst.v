module DW_square_inst( inst_a, inst_tc, square_inst );

  parameter width = 8;

  input [width-1 : 0] inst_a;
  input inst_tc;
  output [(2*width)-1 : 0] square_inst;

  // Instance of DW_square
  DW_square #(width)
    U1 ( .a(inst_a),   .tc(inst_tc),   .square(square_inst) );

endmodule


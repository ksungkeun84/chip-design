module DW_mult_dx_inst(inst_a, inst_b, inst_tc, inst_dplx, product_inst);

  parameter width = 16;
  parameter p1_width = 8;

  input [width-1 : 0] inst_a;
  input [width-1 : 0] inst_b;
  input inst_tc;
  input inst_dplx;
  output [2*width-1 : 0] product_inst;

  // Instance of DW_mult_dx
  DW_mult_dx #(width, p1_width)
    U1 ( .a(inst_a),   .b(inst_b),   .tc(inst_tc),   .dplx(inst_dplx),
         .product(product_inst));

endmodule


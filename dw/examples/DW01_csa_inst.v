module DW01_csa_inst( inst_a, inst_b, inst_c, inst_ci, carry_inst, 
                      sum_inst, co_inst );

  parameter width = 8;

  input [width-1 : 0] inst_a;
  input [width-1 : 0] inst_b;
  input [width-1 : 0] inst_c;
  input inst_ci;
  output [width-1 : 0] carry_inst;
  output [width-1 : 0] sum_inst;
  output co_inst;

  // Instance of DW01_csa
  DW01_csa #(width)
    U1 ( .a(inst_a), .b(inst_b), .c(inst_c), .ci(inst_ci), 
         .carry(carry_inst), .sum(sum_inst), .co(co_inst) );

endmodule


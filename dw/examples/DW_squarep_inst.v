module DW_squarep_inst( inst_a, inst_b, inst_tc, accum_inst );

  parameter inst_width = 8;
  parameter inst_verif_en = 3; // level 3 is the most aggressive
                               // verification mode for simulation

  // Square and accumulate using DW_squarep
  input [inst_width-1 : 0] inst_a;
  input [2*inst_width-1 : 0] inst_b;
  input inst_tc;
  output [2*inst_width-1 : 0] accum_inst;

  wire [2*inst_width-1 : 0] part_prod1, part_prod2, part_sum1, part_sum2;

  // Instance of DW_squarep
  DW_squarep #(inst_width,inst_verif_en) U1 ( .a(inst_a), .tc(inst_tc),
                                .out0(part_prod1), .out1(part_prod2) );

  // Instance of DW01_csa
  DW01_csa #(2*inst_width) U2 ( .a(part_prod1), .b(part_prod2),
                                .c(inst_b), .ci(1'b0),
                                .sum(part_sum1), .carry(part_sum2) );

  // Instance of DW01_add
  DW01_add #(2*inst_width) U3 ( .A(part_sum1), .B(part_sum2),
                                .CI(1'b0), .SUM(accum_inst) );

endmodule

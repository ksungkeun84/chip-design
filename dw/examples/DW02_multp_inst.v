// Multiply & ACcumulate performed by instances of
// DW02_multp, DW01_csa & DW01_add

module DW02_multp_inst( inst_a, inst_b, inst_c, inst_tc,
                        accum_inst);
  parameter a_width = 6;
  parameter b_width = 8;
  parameter out_width = 18;
  parameter verif_en = 3; // value 3 is the most aggressive 
                          // verification mode

  input [a_width-1 : 0] inst_a;
  input [b_width-1 : 0] inst_b;
  input [out_width-1 : 0] inst_c;
  input inst_tc;
  output [out_width-1:0] accum_inst;

  wire [out_width-1 : 0] part_prod1, part_prod2;
  wire [out_width-1 : 0] part_sum1, part_sum2;
  wire tied_low, no_connect1, no_connect2;

  // Instance of DW02_multp to perform the partial
  // multiply of inst_a by inst_b with partial product
  // results at part_prod1 & part_prod2
  // The value of verif_en does not affect the synthesis result
  DW02_multp #(a_width, b_width, out_width, verif_en) U1 
              ( .a(inst_a), .b(inst_b),.tc(inst_tc),
                .out0(part_prod1), .out1(part_prod2) );

  // Instance of DW01_csa used to add the partial products
  // from inst_a times inst_b (part_prod1 & part_prod2) to
  // the input inst_c in carry-save form yielding the two
  // vectors, part_sum1 & part_sum2.
  DW01_csa #(out_width) U2 (.a(part_prod1), .b(part_prod2), .c(inst_c),
                            .ci(tied_low), .sum(part_sum1),
                            .carry(part_sum2), .co(no_connect1) );

  // Finally, an instance of DW01_add is used to add the carry-save
  // partial results together forming the final binary output
  DW01_add #(out_width) U3 (.A(part_sum1), .B(part_sum2),
                            .CI(tied_low), .SUM(accum_inst),
                            .CO(no_connect2) );

  assign tied_low = 1'b0;

endmodule

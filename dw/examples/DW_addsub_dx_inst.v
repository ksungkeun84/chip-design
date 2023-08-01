module DW_addsub_dx_inst( inst_a, inst_b, inst_ci1, inst_ci2, inst_addsub, 
                          inst_tc, inst_sat, inst_avg, inst_dplx, sum_inst, 
                          co1_inst, co2_inst );

  parameter width = 24;
  parameter p1_width = 8;

  input [width-1 : 0] inst_a;
  input [width-1 : 0] inst_b;
  input inst_ci1;
  input inst_ci2;
  input inst_addsub;
  input inst_tc;
  input inst_sat;
  input inst_avg;
  input inst_dplx;
  output [width-1 : 0] sum_inst;
  output co1_inst;
  output co2_inst;

  // Instance of DW_addsub_dx
  DW_addsub_dx #(width, p1_width)
    U1 ( .a(inst_a), .b(inst_b), .ci1(inst_ci1), .ci2(inst_ci2),
         .addsub(inst_addsub), .tc(inst_tc), .sat(inst_sat),
         .avg(inst_avg), .dplx(inst_dplx),
         .sum(sum_inst), .co1(co1_inst), .co2(co2_inst) );

endmodule


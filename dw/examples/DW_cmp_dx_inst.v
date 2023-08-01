module DW_cmp_dx_inst( inst_a, inst_b, inst_tc, inst_dplx, lt1_inst, 
                        eq1_inst, gt1_inst, lt2_inst, eq2_inst, gt2_inst );

  parameter width = 24;
  parameter p1_width = 16;

  input [width-1 : 0] inst_a;
  input [width-1 : 0] inst_b;
  input inst_tc;
  input inst_dplx;
  output lt1_inst;
  output eq1_inst;
  output gt1_inst;
  output lt2_inst;
  output eq2_inst;
  output gt2_inst;

  // Instance of DW_cmp_dx
  DW_cmp_dx #(width, p1_width)
    U1 ( .a(inst_a), .b(inst_b), .tc(inst_tc), .dplx(inst_dplx),
         .lt1(lt1_inst), .eq1(eq1_inst), .gt1(gt1_inst),
         .lt2(lt2_inst), .eq2(eq2_inst), .gt2(gt2_inst) );
endmodule

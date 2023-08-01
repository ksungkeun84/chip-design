module DW_sqrt_seq_inst(inst_clk, inst_rst_n, inst_hold, inst_start, inst_a, 
                        complete_inst, root_inst );

  parameter inst_width = 8;
  parameter inst_tc_mode = 0;
  parameter inst_num_cyc = 3;
  parameter inst_rst_mode = 0;
  parameter inst_input_mode = 1;
  parameter inst_output_mode = 1;
  parameter inst_early_start = 0;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).

  input inst_clk;
  input inst_rst_n;
  input inst_hold;
  input inst_start;
  input [inst_width-1 : 0] inst_a;
  output complete_inst;
  output [(inst_width+1)/2-1 : 0] root_inst;

  // Instance of DW_sqrt_seq
  DW_sqrt_seq #(inst_width, inst_tc_mode, inst_num_cyc, inst_rst_mode, 
                inst_input_mode, inst_output_mode, inst_early_start) 
    U1 (.clk(inst_clk),   .rst_n(inst_rst_n),   .hold(inst_hold),
        .start(inst_start),   .a(inst_a),   .complete(complete_inst),
        .root(root_inst) );
endmodule


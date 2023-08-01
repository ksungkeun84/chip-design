module DW_dpll_sd_inst( inst_clk, inst_rst_n, inst_stall, 
                        inst_squelch, inst_window, inst_data_in,
                        clk_out_inst, bit_ready_inst, data_out_inst );

  parameter inst_width = 1;
  parameter inst_divisor = 5;
  parameter inst_gain = 1;
  parameter inst_filter = 2;
  parameter inst_windows = 3;
  `define bit_width_windows 2 // ceil(log2(inst_windows)

  input inst_clk;
  input inst_rst_n;
  input inst_stall;
  input inst_squelch;
  input [`bit_width_windows-1 : 0] inst_window;
  input [inst_width-1 : 0] inst_data_in;
  output clk_out_inst;
  output bit_ready_inst;
  output [inst_width-1 : 0] data_out_inst;

  // Instance of DW_dpll_sd
  DW_dpll_sd #(inst_width, inst_divisor, inst_gain, 
               inst_filter, inst_windows) 
    U1 ( .clk(inst_clk), .rst_n(inst_rst_n), .stall(inst_stall),
         .squelch(inst_squelch), .window(inst_window),
         .data_in(inst_data_in), .clk_out(clk_out_inst),
         .bit_ready(bit_ready_inst), .data_out(data_out_inst) );
endmodule


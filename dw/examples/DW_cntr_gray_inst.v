module DW_cntr_gray_inst (inst_clk, inst_rst_n, inst_init_n, inst_load_n,
                          inst_data, inst_cen, count_inst);
  parameter inst_width = 8;

  input  inst_clk;
  input  inst_rst_n;
  input  inst_init_n;
  input  inst_load_n;
  input  [inst_width-1 : 0] inst_data;
  input  inst_cen;
  output [inst_width-1 : 0] count_inst;

  // Please add +incdir+$SYNOPSYS/dw/sim_ver+ to your verilog simulator
  // command line (for simulation).

  // instance of DW_cntr_gray
  DW_cntr_gray #(inst_width)
    U1 (.clk(inst_clk),
        .rst_n(inst_rst_n),
        .init_n(inst_init_n),
        .load_n(inst_load_n),
        .data(inst_data),
        .cen(inst_cen),
        .count(count_inst));
endmodule


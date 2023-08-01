module DW_ram_r_w_2c_dff_inst( inst_clk_w, inst_rst_w_n, inst_init_w_n, inst_en_w_n, inst_addr_w, 
		inst_data_w, inst_clk_r, inst_rst_r_n, inst_init_r_n, inst_en_r_n, 
		inst_addr_r, data_r_a_inst, data_r_inst );

parameter width = 8;
parameter depth = 8;
parameter addr_width = 3;  // set to ceil( log2( depth ) )
parameter mem_mode = 5;
parameter rst_mode = 1;


input inst_clk_w;
input inst_rst_w_n;
input inst_init_w_n;
input inst_en_w_n;
input [(addr_width)-1 : 0] inst_addr_w;
input [width-1 : 0] inst_data_w;
input inst_clk_r;
input inst_rst_r_n;
input inst_init_r_n;
input inst_en_r_n;
input [(addr_width)-1 : 0] inst_addr_r;
output data_r_a_inst;
output [width-1 : 0] data_r_inst;

    // Instance of DW_ram_r_w_2c_dff
    DW_ram_r_w_2c_dff #(width, depth, addr_width, mem_mode, rst_mode)
	  U1 ( .clk_w(inst_clk_w), .rst_w_n(inst_rst_w_n), .init_w_n(inst_init_w_n), .en_w_n(inst_en_w_n), .addr_w(inst_addr_w), .data_w(inst_data_w), .clk_r(inst_clk_r), .rst_r_n(inst_rst_r_n), .init_r_n(inst_init_r_n), .en_r_n(inst_en_r_n), .addr_r(inst_addr_r), .data_r_a(data_r_a_inst), .data_r(data_r_inst) );

endmodule

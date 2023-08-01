module DW_pulseack_sync_inst( inst_clk_s, inst_rst_s_n, inst_init_s_n, inst_event_s, inst_clk_d, 
		inst_rst_d_n, inst_init_d_n, inst_test, busy_s_inst, ack_s_inst, 
		event_d_inst );

parameter reg_event = 1;
parameter reg_ack = 1;
parameter ack_delay = 0;
parameter f_sync_type = 2;
parameter r_sync_type = 2;
parameter tst_mode = 0;
parameter verif_en = 1;
parameter pulse_mode = 0;


input inst_clk_s;
input inst_rst_s_n;
input inst_init_s_n;
input inst_event_s;
input inst_clk_d;
input inst_rst_d_n;
input inst_init_d_n;
input inst_test;
output busy_s_inst;
output ack_s_inst;
output event_d_inst;

    // Instance of DW_pulseack_sync
    DW_pulseack_sync #(reg_event, reg_ack, ack_delay, f_sync_type, r_sync_type, tst_mode, verif_en, pulse_mode)
	  U1 ( .clk_s(inst_clk_s), .rst_s_n(inst_rst_s_n), .init_s_n(inst_init_s_n), .event_s(inst_event_s), .clk_d(inst_clk_d), .rst_d_n(inst_rst_d_n), .init_d_n(inst_init_d_n), .test(inst_test), .busy_s(busy_s_inst), .ack_s(ack_s_inst), .event_d(event_d_inst) );

endmodule

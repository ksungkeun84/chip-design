module DW_tap_inst( inst_tck,
                    inst_trst_n,
                    inst_tms,
                    inst_tdi,
                    inst_so,
                    
    		    inst_bypass_sel,
                    inst_sentinel_val,
                    clock_dr_inst,
                    shift_dr_inst,
                    update_dr_inst,
                    
    		    tdo_inst,
                    tdo_en_inst,
                    tap_state_inst,
                    extest_inst,
                    samp_load_inst,
                    
    		    instructions_inst,
                    sync_capture_en_inst,
                    sync_update_dr_inst,
                    inst_test );

parameter width = 8;
parameter id = 0;
parameter version = 0;
parameter part = 0;
parameter man_num = 0;
parameter sync_mode = 0;
parameter tst_mode = 1;


input inst_tck;
input inst_trst_n;
input inst_tms;
input inst_tdi;
input inst_so;
input inst_bypass_sel;
input [width-2 : 0] inst_sentinel_val;
output clock_dr_inst;
output shift_dr_inst;
output update_dr_inst;
output tdo_inst;
output tdo_en_inst;
output [15 : 0] tap_state_inst;
output extest_inst;
output samp_load_inst;
output [width-1 : 0] instructions_inst;
output sync_capture_en_inst;
output sync_update_dr_inst;
input inst_test;

    // Instance of DW_tap
    DW_tap #(width,
             id,
             version,
             part,
             man_num,
             sync_mode,
	     tst_mode)
	  U1 (  .tck(inst_tck),
                .trst_n(inst_trst_n),
                .tms(inst_tms),
                .tdi(inst_tdi),
                .so(inst_so),
                .bypass_sel(inst_bypass_sel),
                .sentinel_val(inst_sentinel_val),
                .clock_dr(clock_dr_inst),
                .shift_dr(shift_dr_inst),
                .update_dr(update_dr_inst),
                .tdo(tdo_inst),
                .tdo_en(tdo_en_inst),
                .tap_state(tap_state_inst),
                .extest(extest_inst),
                .samp_load(samp_load_inst),
                .instructions(instructions_inst),
                .sync_capture_en(sync_capture_en_inst),
                .sync_update_dr(sync_update_dr_inst),
                .test(inst_test) );

endmodule

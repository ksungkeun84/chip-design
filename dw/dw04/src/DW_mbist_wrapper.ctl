////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 2003 - 2018 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Ray B. & Martin B.,  May 1, 2003
//
// VERSION:   CTL file for DW_mbist_wrapper
//
// DFT IP ID: 2f597e5d
// DFT_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////

STIL 1.0 {
  CTL P2001.10;
  Design P2001.1;
  TCL P2001.1;
}
Header {
  Title "MBIST_wrapper";
}

Pragma TCL {*

  set mem_cs_en_0 [expr $mem_csoe_en_0>1]
  set mem_cs_en_1 [expr $mem_csoe_en_1>1]
  set mem_cs_en_2 [expr $mem_csoe_en_2>1]
  set mem_cs_en_3 [expr $mem_csoe_en_3>1]

  set mem_oe_en_0 [expr $mem_csoe_en_0&1]
  set mem_oe_en_1 [expr $mem_csoe_en_0&1]
  set mem_oe_en_2 [expr $mem_csoe_en_0&1]
  set mem_oe_en_3 [expr $mem_csoe_en_0&1]

  set registeredInput [expr $registered_io>1]
  set inPipeDepth [expr [expr $registeredInput + $in_sys_depth] + 1]

  set registeredOutput [expr $registered_io&1]
  set outPipeDepth [expr [expr ($registeredOutput + $out_sys_depth)] + 1]

  set sumOfPipeDepths [expr $inPipeDepth + $outPipeDepth]

  set logOfPipeDepths [expr {int(ceil(log(abs(double($sumOfPipeDepths)))/log(2)))}]

  puts " Variables { "
  puts [format "  IntegerConstant data_msb=%d;" [expr ($data_width - 1)]]
  puts [format "  IntegerConstant address_msb=%d;" [expr ($addr_width - 1)]]
  puts [format "  IntegerConstant debug_reg_length=%d;" [expr ($data_width + $addr_width)]]
  puts [format "  IntegerConstant debug_addr_lsb=%d;" $data_width]
  puts [format "  IntegerConstant num_ports_msb=%d;" [expr ($num_ports - 1)]]

  puts [format "  IntegerConstant tot_pipe_depth_width=%d;" [expr ($logOfPipeDepths + 1)]]
  puts [format "  IntegerConstant tot_pipe_depth_width_msb=%d;" $logOfPipeDepths]

  puts [format "  IntegerConstant mem_cs_width_0_msb=%d;" [expr ($mem_cs_width_0 - 1)]]
  puts [format "  IntegerConstant mem_cs_width_1_msb=%d;" [expr ($mem_cs_width_1 - 1)]]
  puts [format "  IntegerConstant mem_cs_width_2_msb=%d;" [expr ($mem_cs_width_2 - 1)]]
  puts [format "  IntegerConstant mem_cs_width_3_msb=%d;" [expr ($mem_cs_width_3 - 1)]]

  puts [format "  IntegerConstant mem_we_width_0_msb=%d;" [expr ($mem_we_width_0 - 1)]]
  puts [format "  IntegerConstant mem_we_width_1_msb=%d;" [expr ($mem_we_width_1 - 1)]]
  puts [format "  IntegerConstant mem_we_width_2_msb=%d;" [expr ($mem_we_width_2 - 1)]]
  puts [format "  IntegerConstant mem_we_width_3_msb=%d;" [expr ($mem_we_width_3 - 1)]]

  puts [format "  IntegerConstant mem_oe_width_0_msb=%d;" [expr ($mem_oe_width_0 - 1)]]
  puts [format "  IntegerConstant mem_oe_width_1_msb=%d;" [expr ($mem_oe_width_1 - 1)]]
  puts [format "  IntegerConstant mem_oe_width_2_msb=%d;" [expr ($mem_oe_width_2 - 1)]]
  puts [format "  IntegerConstant mem_oe_width_3_msb=%d;" [expr ($mem_oe_width_3 - 1)]]

  if {$memory_full == 1} {
    eval set addr_depth [expr (1 << $addr_width)]
  } else {
    eval set addr_depth [expr [expr ($mem_end_addr - $mem_start_addr)] + 1]
  }
  puts [format "  IntegerConstant depth=%d;" $addr_depth]
  puts "
  SignalVariableEnum vector_constants {
    Values {
      diagnose_reload \\rdebug_reg_length N;
  "
  puts [format "  diagnose_sample \\r%d L \\r%d X ;" $data_width $addr_width]
  puts "
    }
  }
} "
*}

Signals {
  // Outputs
  segment_active       Out;
  mem_fail_n           Out;
  

// debug_out is parallel access to data compare.
Pragma TCL {* puts [format " debug_out\[%d..0\]      Out;" \
                   [expr ($data_width - 1)]] *}
  debug_so             Out;
Pragma TCL {*
  puts "cap_mem_cs_0_nc"
  if {$mem_cs_width_0>1} {
    puts "\[mem_cs_width_0_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_cs_1_nc"
  if {$mem_cs_width_1>1} {
    puts "\[mem_cs_width_1_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_cs_2_nc"
  if {$mem_cs_width_2>1} {
    puts "\[mem_cs_width_2_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_cs_3_nc"
  if {$mem_cs_width_3>1} {
    puts "\[mem_cs_width_3_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_oe_0_nc"
  if {$mem_oe_width_0>1} {
    puts "\[mem_oe_width_0_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_oe_1_nc"
  if {$mem_oe_width_1>1} {
    puts "\[mem_oe_width_1_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_oe_2_nc"
  if {$mem_oe_width_2>1} {
    puts "\[mem_oe_width_2_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_oe_3_nc"
  if {$mem_oe_width_3>1} {
    puts "\[mem_oe_width_3_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_we_0_nc"
  if {$mem_we_width_0>1} {
    puts "\[mem_we_width_0_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_we_1_nc"
  if {$mem_we_width_1>1} {
    puts "\[mem_we_width_1_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_we_2_nc"
  if {$mem_we_width_2>1} {
    puts "\[mem_we_width_2_msb..0\]";
  }
  puts " Out;"
 
  puts "cap_mem_we_3_nc"
  if {$mem_we_width_3>1} {
    puts "\[mem_we_width_3_msb..0\]";
  }
  puts " Out;"
*} 
  // Inputs
  bist_clk              In;
  rst_n_a               In;
  simulation_mode       In;
  bist_mode             In;
  segment_en            In;
  segment_descr[4..0]   In;
  continue_test         In;
  load_parallel_pattern In;
  load_serial_pattern   In;
  serial_pattern_out    In;
  port_no[3..0]         In;
  cont_pause_on_error   In;
  bist_clk_t            In;
  rst_t_n_a             In;
  debug_en              In;
  debug_si              In;
  atpg_1                In;
  dbist_mode            In;
Pragma TCL {* puts [format " custom_pattern\[%d..0\]      In;" \
                   [expr ($data_width - 1)]] *}
}

// ###### Area Reduction Change
Pragma TCL {*
  if {$disable_pause_on_error==0} {
puts "
ScanStructures diagnose {
  ScanChain debug_reg {
   // Debug register has data MSB nearest SO, followed by address MSB.
    ScanCells \"U_apg_0/scan_addr_internal_reg\"\[0..address_msb\]
              \"U_apg_0/data_reg_mir_int_reg\"\[0..data_msb\];
    ScanIn debug_si;
    ScanOut debug_so;
    ScanMasterClock bist_clk_t;
    ScanEnable debug_en;
  }
}
"
}
*} // Pragma TCL

// ############
Pragma TCL {* if {$SNPS_IP_SCAN==1} {
  puts " ScanStructures Internal_scan { ScanChain unstitched {
    ScanCells"
  if {$sep_addr_ports == 0} {
    puts "     \"U_apg_0/port_no_reg_reg\"\[num_ports_msb..0\]"
  } else {
    switch $num_ports {
      1 {puts "     \"U_apg_0/port_no_reg_reg\"\[1..0\]"}
      2 {puts "     \"U_apg_0/port_no_reg_reg\"\[3..0\]"}
      3 {puts "     \"U_apg_0/port_no_reg_reg\"\[3..0\]"
         puts "     \"U_apg_0/port_no_reg_reg_reg\"\[1..0\]"}
      4 {puts "     \"U_apg_0/port_no_reg_reg\"\[3..0\]"
         puts "     \"U_apg_0/port_no_reg_reg_reg\[3..0\]"}
    }
  }
puts "     \"U_apg_0/bist_addr_reg_reg\"\[address_msb..0\]
      \"U_apg_0/bist_wr_data_reg_reg\"\[data_msb..0\]
      \"U_apg_0/bist_we_bus_reg_reg\"\[num_ports_msb..0\]
      \"U_apg_0/bist_rd_data_reg\"\[data_msb..0\]
      \"U_apg_0/delayed_tc_reg\" "
  if {(($mem_cs_en_0 == 1) || ($mem_oe_en_0==1))} {
    puts "      \"U_apg_0/bist_cs_bus_reg_reg\[0\]\""
  }
  if {($num_ports > 1) && (($mem_cs_en_1==1) || ($mem_oe_en_1==1))} {
    puts "      \"U_apg_0/bist_cs_bus_reg_reg\[1\]\""
  }
  if {($num_ports > 2) && (($mem_cs_en_2==1) || ($mem_oe_en_2==1))} {
    puts "      \"U_apg_0/bist_cs_bus_reg_reg\[2\]\""
  }
  if {($num_ports > 3) && (($mem_cs_en_3==1) || ($mem_oe_en_3==1))} {
    puts "      \"U_apg_0/bist_cs_bus_reg_reg\[3\]\""
  }

  if {$memory_full==1} {
    puts "      \"U_apg_0/state_reg_reg\"\[address_msb..0\]"
  }
  if {$memory_full==0} {
    for {set i 0} {$i < $addr_width} {incr i} {
      puts [format " \"U_apg_0/U_UP_DOWN_CTR/R4_%d\" " $i]
    }
  }
  if {$registeredInput==1} {
    puts "
        \"U_apg_0/wr2la_flag_reg\"
        \"U_apg_0/wr4la_flag_reg\"
         "
  } else {
    puts "\"U_apg_0/async_wr_cyc_ext_reg\""
  }
  if {$remove_debug_out_port==0} {
    puts "
      \"U_apg_0/debug_out_int_reg\"\[data_msb..0\]
       "
  }
  puts "
      \"U_apg_0/mem_fail_n_r_reg\"
      \"U_apg_0/bist_mode_clk_d1_reg\"
      \"U_apg_0/data_reg_reg\"\[data_msb..0\]
      \"U_apg_0/async_wr_cycle_cnt_reg\"\[2..0\]
      \"U_apg_0/bist_we_n_reg\"
      \"U_apg_0/agen_inc_en_reg\"
      \"U_apg_0/en_pipe_end_cnt_reg\"
      \"U_apg_0/en_pipe_start_cnt_reg\"
      \"U_apg_0/fore_back_wr_reg\"
      \"U_apg_0/retrieve_addr_reg\"
      \"U_apg_0/rd3la_flag_reg\"
      \"U_apg_0/segment_active_reg\"
      \"U_apg_0/state_rwt_reg\"\[3..0\]
      \"U_apg_0/state_cmp_reg\"\[2..0\]
      \"U_apg_0/compare_dgen_en_n_reg\"
      \"U_apg_0/fore_back_rd_reg\"
      \"U_apg_0/cycle_4_flag_reg\"
      \"U_apg_0/p_start_cnt_tcval_reg\"\[3..0\]
      \"U_apg_0/segment_delay_cnt_reg\"\[2..0\]
      \"U_apg_0/agen_tc_sampled_reg\"
      \"U_apg_0/error_during_tc_flag_reg\"
      \"U_apg_0/pipe_start_cnt_reg\"\[tot_pipe_depth_width_msb..0\]
      \"U_apg_0/pipe_end_cnt_reg\"\[tot_pipe_depth_width_msb..0\]
      ;
    ScanMasterClock bist_clk;
  } "
  if {($shadow_disable==0) || ($disable_pause_on_error==0)} {
    puts "
      ScanChain unstitched_clk_t_flops {
        ScanCells "
  if {($disable_pause_on_error==0)} {
     puts "
              \"U_apg_0/mem_fail_n_r_tclk_d1_reg\"
              \"U_apg_0/mem_fail_n_r_tclk_d2_reg\"
              \"U_apg_0/meta_mem_fail_n_r_reg\"
              \"U_apg_0/meta_load_scan_addr_reg\""
  }
  if {($shadow_disable==0)} {
    if {($mem_cs_en_0 == 1)} {
      puts "      \"U_apg_0/cap_mem_cs_0_nc_reg\"\[mem_cs_width_0_msb..0\]"
    }
    if {($mem_cs_en_1 == 1) && ($num_ports > 1)} {
      puts "      \"U_apg_0/cap_mem_cs_1_nc_reg\"\[mem_cs_width_1_msb..0\]"
    }
    if {($mem_cs_en_2 == 1) && ($num_ports > 2)} {
      puts "      \"U_apg_0/cap_mem_cs_2_nc_reg\"\[mem_cs_width_2_msb..0\]"
    }
    if {($mem_cs_en_3 == 1) && ($num_ports > 3)} {
      puts "      \"U_apg_0/cap_mem_cs_3_nc_reg\"\[mem_cs_width_3_msb..0\]"
    }
    if {($mem_oe_en_0 == 1)} {
      puts "      \"U_apg_0/cap_mem_oe_0_nc_reg\"\[mem_oe_width_0_msb..0\]"
    }
    if {($mem_oe_en_1 == 1) && ($num_ports > 1)} {
      puts "      \"U_apg_0/cap_mem_oe_1_nc_reg\"\[mem_oe_width_1_msb..0\]"
    }
    if {($mem_oe_en_2 == 1) && ($num_ports > 2)} {
      puts "      \"U_apg_0/cap_mem_oe_2_nc_reg\"\[mem_oe_width_2_msb..0\]"
    }
    if {($mem_oe_en_3 == 1) && ($num_ports > 3)} {
      puts "      \"U_apg_0/cap_mem_oe_3_nc_reg\"\[mem_oe_width_3_msb..0\]"
    }
    puts "      \"U_apg_0/cap_mem_we_0_nc_reg\"\[mem_we_width_0_msb..0\]"
    if {($num_ports > 1)} {
      puts "      \"U_apg_0/cap_mem_we_1_nc_reg\"\[mem_we_width_1_msb..0\]"
    }
    if {($num_ports > 2)} {
      puts "      \"U_apg_0/cap_mem_we_2_nc_reg\"\[mem_we_width_2_msb..0\]"
    }
    if {($num_ports > 3)} {
      puts "      \"U_apg_0/cap_mem_we_3_nc_reg\"\[mem_we_width_3_msb..0\]"
    }
  }
  if {($disable_pause_on_error==0)} {
    puts "      \"U_apg_0/load_scan_addr_reg\""
  }
  puts " ; 
        ScanMasterClock bist_clk_t;
      } "
  }
 puts " } "
} *}

MacroDefs diagnose {
  "unload_mem" {
    ScanChain debug_reg;
    C { debug_en=1; }
    V { bist_clk_t=0; debug_so=#;}
    Shift { V { bist_clk_t=P; debug_so=#;} }
    //@@ This could be C to save a vector, but there appears to be a bug.
    V { debug_en=0; debug_so=X; }
  }
}

Environment {
  CTL {
    Family SNPS_MBIST_wrapper;
    External {
      atpg_1 {
        ConnectTo{
          Symbolic "stitch_atpg_1";
        }
      }
      bist_mode {
        ConnectTo{
          Symbolic "stitch_bist_mode";
        }
      }
Pragma TCL {* for {set i 0} {$i <= 4} {incr i} {
  puts [format " segment_descr\[%d\] {ConnectTo{Symbolic \"stitch_segment_descr\[%d\]\";}}" $i $i]
} *}
Pragma TCL {* for {set i 0} {$i <= 3} {incr i} {
  puts [format " port_no\[%d\] {ConnectTo{Symbolic \"stitch_port_no\[%d\]\";}}" $i $i]
} *}
      continue_test {
        ConnectTo{
          Symbolic "stitch_continue_test";
        }
      }
      cont_pause_on_error {
        ConnectTo{
          Symbolic "stitch_cont_pause_on_error";
        }
      }
      load_parallel_pattern {
        ConnectTo{
          Symbolic "stitch_load_parallel_pattern";
        }
      }
      load_serial_pattern {
        ConnectTo{
          Symbolic "stitch_load_serial_pattern";
        }
      }
      serial_pattern_out {
        ConnectTo{
          Symbolic "stitch_serial_pattern_out";
        }
      }
      segment_en {
        ConnectTo{
          Symbolic "stitch_segment_en";
        }
      }
      segment_active {
        ConnectTo{
          Symbolic "stitch_segment_active";
        }
      }
      mem_fail_n {
        ConnectTo{
          Symbolic "stitch_mem_fail_n";
        }
      }
Pragma TCL {* for {set i 0} {$i < $data_width} {incr i} {
  puts [format " custom_pattern\[%d\] {ConnectTo{Symbolic \"param_const_custom_pattern\";}}" $i]
} *}
    }
Pragma TCL {*
  puts "
    Relation {
      Port 'segment_en + segment_active + mem_fail_n' 0;

      Corresponding 'segment_active + mem_fail_n + bist_mode
        + segment_en + segment_descr\[4..0\] + continue_test
        + load_parallel_pattern + load_serial_pattern
        + serial_pattern_out + port_no\[3..0\] + cont_pause_on_error
        + atpg_1 + "
  puts [format " custom_pattern\[%d..0\] " [expr ($data_width - 1)]]
  puts "' ; } "
*}

    Internal {
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu 
                   { ActiveState ForceUp;} }
      bist_clk { DataType TestClock User snps_bist_clk { ActiveState ForceUp;} }
      rst_n_a { DataType Asynchronous Reset User snps_bist_reset { ActiveState ForceDown;} }
      rst_t_n_a { DataType Asynchronous Reset User snps_bist_reset { ActiveState ForceDown;} }
      debug_en { DataType ScanEnable { ActiveState ForceUp;} }
      debug_si {
        CaptureClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataIn {
          ScanDataType Internal;
        }
      }
      debug_so {
        LaunchClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataOut {
          ScanDataType Internal;
        }
      }
      dbist_mode {
        DataType TestMode { ActiveState ForceDown; }
      }
    }
  } // anonymous CTL

  CTL Mission_mode { 
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_wrapper;
    TestMode Normal; }

Pragma TCL {* if {$SNPS_IP_SCAN==1} { puts "
  CTL Internal_scan {
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_wrapper;
    TestMode InternalTest;
    DomainReferences { ScanStructures
  "
  if {$disable_pause_on_error==0} {
    puts " diagnose "
  }
  puts "
    Internal_scan; }
//@@ This should have been propagated from anonymous mode
    Internal {
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu 
                   { ActiveState ForceUp;} }
      bist_clk   { DataType ScanMasterClock User snps_bist_clk 
                   { ActiveState ForceUp;} }
  "
if {$dbist_ready==1} {
  puts " dbist_mode { DataType TestMode { ActiveState ForceUp; } } "
}
  puts "
    }
  }
"} *}

  CTL go_nogo { 
    Family SNPS_MBIST_wrapper;
    TestMode InternalTest; }

// ###Area reduction change    
Pragma TCL {*
if {$disable_pause_on_error==0} {
puts "
  CTL diagnose {
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_wrapper;
    TestMode Debug;
    DomainReferences {
      ScanStructures diagnose;
      MacroDefs diagnose;
    }
    Internal {
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu 
                   { ActiveState ForceUp;} }
    }
    ScanInternal {
      \"U_apg_0/data_reg_mir_int_reg\"\[data_msb..0\] { DataType MemoryData; }
      \"U_apg_0/scan_addr_internal_reg\"\[address_msb..0\]
        { DataType MemoryAddress; }
    }
    PatternInformation {
      Macro \"unload_mem\" {
        Purpose Observe;
//@@ ScanChain not supported?  Parser barfs.
//        ScanChain debug_reg;
      }
    }
  } // CTL diagnose
"
} 
*} // Pragma TCL
//###########
}

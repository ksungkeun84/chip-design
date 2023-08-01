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
// VERSION:   CTL file for DW_mbist_ctrl
//
// DFT IP ID: b6464d60
// DFT_release: O-2018.06-DWBB_201806.3
//
////////////////////////////////////////////////////////////////////////////////


STIL 1.0 {
  CTL P2001.10;
  Design P2001.1;
  TCL P2001.1;
}
Header {
  Title "MBIST_controller";
}

Pragma TCL {*
  for {set i 0} {$i < $num_mem} {incr i} {
    eval set registered_input_${i} [expr \$registered_io_${i}>1]
    eval set registered_output_${i} [expr \$registered_io_${i}&1]

    eval set in_pipe_depth_${i} [expr \$registered_input_${i} + \$in_sys_depth_${i}]
    eval incr in_pipe_depth_${i}

    eval set out_pipe_depth_${i} [expr \$registered_output_${i} + \$out_sys_depth_${i}]
    eval incr out_pipe_depth_${i}

    eval set argument \$data_width_${i}
    eval set data_width_count_${i} [expr {int(ceil(log(abs(double($argument)))/log(2)))}]
  }

  set max_in_pipe_depth 0
  set max_out_pipe_depth 0
  set max_data_width_count 0
  for {set i 0} {$i < $num_mem} {incr i} {
    eval set current_in_pipe_depth \$in_pipe_depth_${i}
    eval set current_out_pipe_depth \$out_pipe_depth_${i}
    eval set current_data_width_count \$data_width_count_${i}
    if {$current_in_pipe_depth > $max_in_pipe_depth} {
      set max_in_pipe_depth $current_in_pipe_depth
    }
    if {$current_out_pipe_depth > $max_out_pipe_depth} {
      set max_out_pipe_depth $current_out_pipe_depth
    }
    if {$current_data_width_count > $max_data_width_count} {
      set max_data_width_count $current_data_width_count
    }
  }

  set mode_reg_del [expr [expr $max_in_pipe_depth + $max_out_pipe_depth] * 3]
  set mode_reg_del [expr $mode_reg_del + 2]
  set mode_reg_del_width [expr {int(ceil(log(abs(double($mode_reg_del)))/log(2)))}]

  puts " Variables { "
  puts [format "  IntegerConstant num_mems=%d;" $num_mem]
  puts " IntegerConstant num_mems_msb='num_mems-1'; "

  puts [format "  IntegerConstant mode_reg_length=%d;" [expr ($num_mem + 15)]]
  puts "
  IntegerConstant mode_reg_msb='mode_reg_length-1';
  IntegerConstant mem_en_msb='mode_reg_msb';
  IntegerConstant mem_en_lsb='mem_en_msb + 1 - num_mems';

  SignalVariableEnum vector_constants {
    Values {
      // This is the reset value of the mode register. The values for bits
      // 8,5..1 are selected by the user during generation. These correspond
      // to chip select, pause-on-error mode and algo selection.
      // Bit 0 is on the right. "
  puts " instruction_reset \\rnum_mems 1 000000100111110;"
#@@ Reset values are now determined externally.
#  puts [format " instruction_reset 01%d%d%d%d00%d000000\\rnum_mems 1;" \
#        $MR_MARCHLR_RST $MR_MARCHC_RST $MR_MATS_RST $MR_RETN_RST \
#        $MR_DEBUG_MODE_RST]
  puts "
      // This tests the done bit, the global fail bit, and local fail bits.
      test_fail_bits    \\rnum_mems H XXXXXXXLXXXXXXH;
      mask_fail_bits    \\rmode_reg_length X;
      // Same as test_fail_bits, but samples the data pattern and port number
      // register segments to see what MBIST was doing at the time of failure.
      //@@ S not supported WFC
      //@@ diagnose_fail_bits \\rnum_mems H SSSSSSXLXXXXXXH;
      diagnose_fail_bits \\rnum_mems H XXXXXXXLXXXXXXH;
    }
  }

  SignalVariable instruction\[mode_reg_msb..0\]{ InitialValue 'instruction_reset';}
  SignalVariable status\[mode_reg_msb..0\] { InitialValue 'mask_fail_bits'; }

  IntegerConstant AlgoMarchLRBit=2;
  IntegerConstant AlgoMarchCBit=3;
  IntegerConstant AlgoMatsBit=4;
  IntegerConstant AlgoRetnBit=5;
  SignalVariable marchlr;
  SignalVariable marchc;
  SignalVariable mats;
  SignalVariable mem_en\[num_mems_msb..0\];
  SignalVariable mem_cmp_en\[num_mems_msb..0\];
  SignalVariable debug_mode;
  IntegerConstant PauseOnErrorBit=8;

  Integer num_clock_cycles;
  // Upper limit for all values of test length equation. May be used in cases
  // where we don't have complete info, or don't want to take time to evaluate
  // the equation.
  IntegerConstant max_clock_cycles=50000000;
  Integer fail_limit;

  // These constants are needed for the test length equation.
"
  puts [format "  IntegerConstant a_5=%d;" $a_5]
  puts [format "  IntegerConstant zero_one=%d;" $zero_one]
  puts [format "  IntegerConstant pair_sep=%d;" $pair_sep]
  puts [format "  IntegerConstant custom_pattern_en=%d;" $custom_pattern_en]
for {set i 0} {$i < $num_mem} {incr i} {
# Martin Bell 2005/01/13 STAR 9000046292 - Workaround a TCL interpretter bug
# that causes a failure on sparc64 when int or ceil is used before format.
#  eval set argument \$data_width_${i}
#  puts [format "  IntegerConstant mem%d_data_width=%d;" $i $argument]
#  eval set argument \$num_ports_${i}
#  puts [format "  IntegerConstant mem%d_num_ports=%d;" $i $argument]
#  eval set argument \$registered_input_${i}
#  puts [format "  IntegerConstant mem%d_registered_input=%d;" $i $argument]
#  eval set argument \$registered_output_${i}
#  puts [format "  IntegerConstant mem%d_registered_output=%d;" $i $argument]
#  eval set argument [expr \$in_sys_depth_${i}+\$out_sys_depth_${i}>0]
#  puts [format "  IntegerConstant mem%d_pipelined=%d;" $i $argument]
  eval set argument \$data_width_${i}
  puts "  IntegerConstant mem${i}_data_width=${argument}; "
  eval set argument \$num_ports_${i}
  puts "  IntegerConstant mem${i}_num_ports=${argument}; "
  eval set argument \$registered_input_${i}
  puts "  IntegerConstant mem${i}_registered_input=${argument}; "
  eval set argument \$registered_output_${i}
  puts "  IntegerConstant mem${i}_registered_output=${argument}; "
  eval set argument [expr \$in_sys_depth_${i}+\$out_sys_depth_${i}>0]
  puts "  IntegerConstant mem${i}_pipelined=${argument}; "
}
puts "
} "
*}

Signals {
  // Outputs
  mode_reg_so           Out;
  mode_reg_out[mode_reg_msb..0]   Out;
  atpg_1                Out;
  bist_mode             Out;
  segment_descr[4..0]   Out;
  port_no[3..0]         Out;
  continue_test         Out;
  cont_pause_on_error   Out;
  load_parallel_pattern Out;
  load_serial_pattern   Out;
  serial_pattern_out    Out;

  // Inputs
  rst_n_a               In;
  bist_clk_t            In;
  rst_t_n_a             In;
  mbrun                 In;
  shift_dr              In;
  mode_reg_si           In;
  parallel_dr           In;
  mode_reg_in[mode_reg_msb..0]   In;
  bist_clk              In;
  mr_ctrl_sel_rst       In;
  mr_marchlr_rst        In;
  mr_marchc_rst         In;
  mr_mats_rst           In;
  mr_retn_rst           In;
  mr_debug_mode_rst     In;
Pragma TCL {*
  if {$num_mem > 1} {
    puts "
      mr_mem_sel_stat_rst\[num_mems_msb..0\] In;
      segment_en\[num_mems_msb..0\]          Out;
      segment_active\[num_mems_msb..0\]      In;
      mem_fail_n\[num_mems_msb..0\]          In;
    "
  } else {
    puts "
      mr_mem_sel_stat_rst In;
      segment_en          Out;
      segment_active      In;
      mem_fail_n          In;
    "
  }
*}
}

ScanStructures {
  ScanChain mode_reg {
    ScanIn mode_reg_si;
    ScanOut mode_reg_so;
    ScanCells mode_reg_mir_reg[0..mode_reg_msb];
    ScanMasterClock bist_clk_t;
    ScanEnable shift_dr;
  }
}

Pragma TCL {*
  puts "
ScanStructures Internal_scan {
  ScanChain unstitched_1 {
    ScanCells mbrun_d1_reg
              mbrun_d2_reg
              meta_mbrun_reg
              bist_mode_reg
              delayed_error_reg
              cen_state_reg
              all_apgs_stopped_d1_reg
              mode_reg_reg\[0..mode_reg_msb\]
  "
  for {set i 0} {$i < $mode_reg_del_width} {incr i} {
    puts [format " \"U_PIPELINE_DELAY_COUNTER/R4_%d\" " $i]
  }
  puts "
              topfsm_state_reg\[2..0\]
              alg_state_reg\[3..0\]
              alg_no_reg\[3..0\]
              pattern_no_reg\[3..0\]
              port_sel_reg\[1..0\]
              load_pattern_reg
              all_done_reg
              alg_run_en_reg
              fail_proc_done_reg
              load_parallel_pattern_reg
  "
  puts [format " mem_width_ctr_reg\[%d..0\] " [expr ($max_data_width_count - 1)]]
  puts [format " pairsep_width_ctr_reg\[%d..0\] " [expr ($max_data_width_count -1)]]
  puts "
              serial_pattern_out_reg
              alg_segment_reg\[2..0\]
              wait_counter_reg\[1..0\]
              alg_done_reg
              pause_retention_reg
              run_segment_reg
              segment_descr_reg\[4..0\]
              bist_mode_d1_reg
              mem_sel_r_reg\[num_mems_msb..0\]
              segment_en_reg\[num_mems_msb..0\]
              continue_test_reg
              memsel_state_reg;
    ScanMasterClock bist_clk;
  }
  ScanChain unstitched_clk_t_flops {
    ScanCells e_p_d_d1_reg
              e_p_d_d2_reg
              meta_error_pause_done_reg
              meta_mem_fail_any_reg
              memfailany_d1_clk_t_reg
              memfailany_d2_clk_t_reg
              atpg_1_reg;
    ScanMasterClock bist_clk_t;
  }
} "
*}

MacroDefs go_nogo {
  "test_setup" {
// We may have to add all signals (including wrapper interface sigs) to
// make STIL binding work
    V { rst_n_a=0; rst_t_n_a=0; mbrun=0; bist_clk=0; bist_clk_t=0;
        shift_dr=0; mode_reg_si=N; mode_reg_so=X; }
    V { rst_n_a=1; rst_t_n_a=1; }
  }
  "load_unload" {
    ScanChain mode_reg;
    C { shift_dr=1; mbrun=0;}
    V { bist_clk_t=0; mode_reg_si= N; mode_reg_so=#;}
    Shift { V { bist_clk_t=P; mode_reg_si= #; mode_reg_so=#;} }
    //@@ This could be C to save a vector, but there appears to be a bug.
    V { shift_dr=0; mode_reg_si=N; mode_reg_so=X; }
  }
  "clock_bist" {
    C { num_clock_cycles=#; }
    V { mbrun=1; }
    Loop 'num_clock_cycles' { V { bist_clk=B; } }
  }
  "run_mbist" {
    C { marchlr=#; marchc=#; mats=#; mem_en=#; mem_cmp_en=#; status=#;
        num_clock_cycles=#; }
    C { instruction='instruction_reset'; }
    C { instruction[AlgoMarchLRBit]='marchlr';
        instruction[AlgoMarchCBit]='marchc';
        instruction[AlgoMatsBit]='mats';
        instruction[AlgoRetnBit]=0;
        instruction[mem_en_msb..mem_en_lsb]='mem_en';
        instruction[PauseOnErrorBit]=1;
        status[mem_en_msb..mem_en_lsb]='mem_cmp_en'; }
    Macro "test_setup";
    Macro "load_unload" {
      mode_reg_si='instruction';	
      mode_reg_so='mask_fail_bits'; }
    Macro "clock_bist" { num_clock_cycles='num_clock_cycles'; }
    Macro "load_unload" { mode_reg_si='instruction'; mode_reg_so='status'; }
  }
}
MacroDefs diagnose {
  "test_setup" {
    V { rst_n_a=0; rst_t_n_a=0; mbrun=0; bist_clk=0; bist_clk_t=0;
        shift_dr=0; mode_reg_si=N; mode_reg_so=X; }
    V { rst_n_a=1; rst_t_n_a=1; }
  }
  "load_unload" {
    ScanChain mode_reg;
    C { shift_dr=1; mbrun=0; }
    V { bist_clk_t=0; mode_reg_si=N; mode_reg_so=#;}
    Shift { V { bist_clk_t=P; mode_reg_si=#; mode_reg_so=#;} }
    //@@ This could be C to save a vector, but there appears to be a bug.
    V { shift_dr=0; mode_reg_si=N; mode_reg_so=X; }
   }
  "clock_bist" {
    C { num_clock_cycles=#; }
    V { mbrun=1; }
    Loop 'num_clock_cycles' { V { bist_clk=B; } }
  }
  "run_mbist" {
    C { marchlr=#; marchc=#; mats=#; mem_en=#; mem_cmp_en=#; debug_mode=#;
        status=#; num_clock_cycles=#; fail_limit=#;}
    C { instruction='instruction_reset'; }
    C { instruction[AlgoMarchLRBit]='marchlr';
        instruction[AlgoMarchCBit]='marchc';
        instruction[AlgoMatsBit]='mats';
        instruction[AlgoRetnBit]=0;
        instruction[mem_en_msb..mem_en_lsb]='mem_en';
        instruction[PauseOnErrorBit]='debug_mode';
        status[mem_en_msb..mem_en_lsb]='mem_cmp_en'; }
    Macro "test_setup";
    Macro "load_unload" {
      mode_reg_si='instruction';	
      mode_reg_so='mask_fail_bits'; }
    Loop 'fail_limit' {
      Macro "clock_bist" { num_clock_cycles='num_clock_cycles'; }
      Macro "load_unload" { mode_reg_si='instruction'; mode_reg_so='status'; }
      // Encapsulated model needs to call unload_mem (from the MBIST wrapper
      // model) with the appropriate ScanStructures for the concatenated debug
      // registers from all wrappers.
      // We don't want the cntrl model to reference a macro in the wrapper
      // model, and we REALLY don't want to reference pins on the wrapper
      // from here.  Model update will add the call.
      // Macro "unload_mem" { debug_so='diagnose_sample'; }
    }
  }
}

Environment {
  CTL {
    Family SNPS_MBIST_controller;
    Relation {
Pragma TCL {*
  if {$num_mem > 1} {
    for {set i 0} {$i < $num_mem} {incr i} {
      puts [format "      Port 'segment_en\[%d\] + segment_active\[%d\] + mem_fail_n\[%d\]' %d;" $i $i $i $i]
    }
  } else {
    puts " Port 'segment_en + segment_active + mem_fail_n' 0; "
  }
  puts "
      Corresponding 'mr_marchlr_rst + mr_marchc_rst + mr_mats_rst
        + mr_ctrl_sel_rst + mr_retn_rst + mr_debug_mode_rst
        + mr_mem_sel_stat_rst"
  if {$num_mem > 1} {
    puts "\[num_mems_msb..0\]"
  }
  puts "' ; "
*}
    }

    External {

      mr_marchlr_rst {
        ConnectTo{
          Symbolic "param_const_mr_marchlr_rst";
        }
      }
      mr_marchc_rst {
        ConnectTo{
          Symbolic "param_const_mr_marchc_rst";
        }
      }
      mr_mats_rst {
        ConnectTo{
          Symbolic "param_const_mr_mats_rst";
        }
      }
      mr_ctrl_sel_rst {
        ConnectTo{
          Symbolic "param_const_mr_ctrl_sel_rst";
        }
      }
      mr_retn_rst {
        ConnectTo{
          Symbolic "param_const_mr_retn_rst";
        }
      }
      mr_debug_mode_rst {
        ConnectTo{
          Symbolic "param_const_mr_debug_mode_rst";
        }
      }
Pragma TCL {*
  puts " mr_mem_sel_stat_rst"
  if {$num_mem > 1} {
    puts "\[num_mems_msb..0\]"
  }
  puts " {
        ConnectTo{
          Symbolic \"param_const_mr_mem_en_rst\";
        }
      } "
*}
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
Pragma TCL {*
  if {$num_mem > 1} {
    for {set i 0} {$i < $num_mem} {incr i} {
      puts [format " segment_en\[%d\] {ConnectTo{Symbolic \"stitch_segment_en\";}}" $i]
      puts [format " segment_active\[%d\] {ConnectTo{Symbolic \"stitch_segment_active\";}}" $i]
      puts [format " mem_fail_n\[%d\] {ConnectTo{Symbolic \"stitch_mem_fail_n\";}}" $i]
    }
  } else {
    puts "
      segment_en {ConnectTo{Symbolic \"stitch_segment_en\";}}
      segment_active {ConnectTo{Symbolic \"stitch_segment_active\";}}
      mem_fail_n {ConnectTo{Symbolic \"stitch_mem_fail_n\";}}
    "
  }
*}
    }
  } // anonymous CTL

  CTL Internal_scan {
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_controller;
    TestMode InternalTest;
    DomainReferences { ScanStructures Internal_scan; }
    Internal {
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu
                   { ActiveState ForceUp;} }
      bist_clk { DataType ScanMasterClock User snps_bist_clk
                 { ActiveState ForceUp;}}
      mode_reg_si {
        CaptureClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataIn {
          ScanDataType Internal;
        }
      }
      mode_reg_so {
        LaunchClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataOut {
          ScanDataType Internal;
        }
      }
      shift_dr { DataType ScanEnable {ActiveState ForceUp;} }
    }
  }
  CTL passive { // Shut off unused controller
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_controller;
    TestMode Bypass;
    // We drive TestRun signals from a global source (mbrun is a TestRun
    // signal in "active modes").  Since we don't gate this signal, we
    // can't just force it off to disable.  Instead, we just rely on the
    // fact that the controller select bit of the mode_reg resets to disable.
    // Internal {
    //   mbrun { DataType TestMode { ActiveState ForceDown;}}
    // }
  } // CTL passive
  CTL go_nogo { // Test to identify failing memories
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_controller;
    TestMode ExternalTest;
    DomainReferences {
      MacroDefs go_nogo;
    }
Pragma TCL {*
  puts "
    Internal {
      mbrun { DataType TestRun User snps_bist_run { ActiveState ForceUp;} }
      rst_n_a { DataType Asynchronous Reset User snps_bist_reset
                { ActiveState ForceDown;} }
      rst_t_n_a { DataType Asynchronous Reset User snps_bist_reset
                { ActiveState ForceDown;} }
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu
                   { ActiveState ForceUp;} }
      bist_clk { DataType TestClock User snps_bist_clk { ActiveState ForceUp;}}
      mode_reg_si {
        CaptureClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataIn {
          ScanDataType Internal;
        }
      }
      mode_reg_so {
        LaunchClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataOut {
          ScanDataType Internal;
        }
      }
      shift_dr { DataType ScanEnable {ActiveState ForceUp;} }
      // We do not support mode_reg parallel input. Force it disabled.
      // DataType Constant on an input signal is an integration directive to
      // tie the pin to a constant value.
      parallel_dr { DataType Constant { ActiveState ForceDown;} }"
  if {$num_mem > 1} {
    for {set i 0} {$i < $num_mem} {incr i} {
      puts [format " mem_fail_n\[%d\] {
        DataType TestFail { ActiveState ExpectHigh; }
        IsConnected In { StateElement Scan mode_reg_mir_reg\[%d\]; } } " $i [expr ($i + 15)]]
    }
  } else {
    puts " mem_fail_n {
        DataType TestFail { ActiveState ExpectHigh; }
        IsConnected In { StateElement Scan mode_reg_mir_reg\[15\]; } } "
  }
  puts " 'mode_reg_in\[mode_reg_msb..0\]' {
            DataType Constant { ActiveState ForceDown; } }
      'mode_reg_out\[mode_reg_msb..0\]' {  IsConnected Out { StateElement Scan mode_reg_reg\[mode_reg_msb..0\]; } }
    } "
*}
Pragma TCL {* puts "
    ScanInternal {
      mode_reg_mir_reg\[0\] {
        DataType CoreSelect { ActiveState ForceDown; }
        DataType TestDone { ActiveState ExpectHigh; }}
      mode_reg_mir_reg\[1\] {
        DataType TestControl CoreSelect {ActiveState ForceUp;}}
      // Algo bits use multi-hot encoding. All enabled algos run in sequence
      // (MarchLR first/Retention last).
      mode_reg_mir_reg\[2\] {
        DataType TestAlgorithm User \"TestAlgoMarchLR\" { ActiveState ForceUp;}}
      mode_reg_mir_reg\[3\] {
        DataType TestAlgorithm User \"TestAlgoMarchC\" { ActiveState ForceUp; }}
      mode_reg_mir_reg\[4\] {
        DataType TestAlgorithm User \"TestAlgoMats\" { ActiveState ForceUp; }}
      mode_reg_mir_reg\[5\] {
        DataType TestAlgorithm User \"TestAlgoRetention\"{ActiveState ForceUp;}}
      // Retention bit set by algo to start wait. Clear to continue.
      mode_reg_mir_reg\[6\] {
        DataType TestControl TestInterrupt { ActiveState ForceUp; }}
      // Mem fail flag.
      mode_reg_mir_reg\[7\] {
        DataType TestFail { ActiveState ExpectLow; } }
      // Disable pause-on-error mode.
      mode_reg_mir_reg\[8\] {
        DataType CoreSelect { ActiveState ForceUp; }}
      // In retention pause, these bits encode the data pattern.
      // Need a table to lookup pattern.
      mode_reg_mir_reg\[12..9\] {
        DataType TestData TestAlgorithm User \"testPatternSelect\"; }
      // In pause-on-error mode, these bits encode the port pairs under test.
      // Need a table to lookup pairs. Ignore for go-nogo mode.
      mode_reg_mir_reg\[14..13\] { DataType Unused; }
      // These double as memory enable bits (initialize to 1 to test memory).
      // They are also fail bits. Enable transitions to zero to indicate
      // failure.
  "
  for {set i 0} {$i < $num_mem} {incr i} {
    puts [format " mode_reg_mir_reg\[%d\] {
        DataType CoreSelect { ActiveState ForceUp; }
        DataType TestFail { ActiveState ExpectHigh; } } " [expr ($i + 15)]]
  }
  puts "
    }
  "
*}
    PatternInformation {
      Macro "run_mbist" {
        Purpose DoTest;
//@@ not supported
//      UseByPattern MemoryBIST;
      }
    }
  } // CTL go_nogo

Pragma TCL {*
if {$disable_pause_on_error==0} {
puts "
  CTL diagnose { // Test to diagnose failing memories
    //@@ Anonymous family not propagated.
    Family SNPS_MBIST_controller;
    TestMode Debug;
    DomainReferences {
      MacroDefs diagnose;
    }
    Internal {
      mbrun { DataType TestRun User snps_bist_run { ActiveState ForceUp;} }
      rst_n_a { DataType Asynchronous Reset User snps_bist_reset
                { ActiveState ForceDown;} }
      rst_t_n_a { DataType Asynchronous Reset User snps_bist_reset
                { ActiveState ForceDown;} }
      bist_clk_t { DataType ScanMasterClock User snps_bist_clk_lu
                   { ActiveState ForceUp;} }
      bist_clk { DataType TestClock User snps_bist_clk { ActiveState ForceUp;}}
      mode_reg_si {
        CaptureClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataIn {
          ScanDataType Internal;
        }
      }
      mode_reg_so {
        LaunchClock bist_clk_t {
          LeadingEdge;
        }
        DataType ScanDataOut {
          ScanDataType Internal;
        }
      }
      shift_dr { DataType ScanEnable {ActiveState ForceUp;} }
      // We do not support mode_reg parallel input. Force it disabled.
      // DataType Constant on an input signal is an integration directive to
      // tie the pin to a constant value.
      parallel_dr { DataType Constant { ActiveState ForceDown;} }
  "
  if {$num_mem > 1} {
    for {set i 0} {$i < $num_mem} {incr i} {
      puts [format " mem_fail_n\[%d\] {
        DataType TestFail { ActiveState ExpectHigh; }
        IsConnected In { StateElement Scan mode_reg_mir_reg\[%d\]; } } " $i [expr ($i + 15)]]
    }
  } else {
    puts " mem_fail_n {
        DataType TestFail { ActiveState ExpectHigh; }
        IsConnected In { StateElement Scan mode_reg_mir_reg\[15\]; } } "
  }
  puts "
      'mode_reg_in\[mode_reg_msb..0\]' { DataType Constant { ActiveState ForceDown;}}
      'mode_reg_out\[mode_reg_msb..0\]' {  IsConnected Out { StateElement Scan mode_reg_reg\[mode_reg_msb..0\]; } }
    }
    ScanInternal {
      mode_reg_mir_reg\[0\] {
        DataType CoreSelect { ActiveState ForceDown; }
        DataType TestDone { ActiveState ExpectHigh; }}
      mode_reg_mir_reg\[1\] {
        DataType TestControl CoreSelect { ActiveState ForceUp; }}
      // Algo bits use multi-hot encoding. All enabled algos run in sequence
      // (MarchLR first/Retention last).
      mode_reg_mir_reg\[2\] {
        DataType TestAlgorithm User \"TestAlgoMarchLR\" { ActiveState ForceUp;}}
      mode_reg_mir_reg\[3\] {
        DataType TestAlgorithm User \"TestAlgoMarchC\" { ActiveState ForceUp; }}
      mode_reg_mir_reg\[4\] {
        DataType TestAlgorithm User \"TestAlgoMats\" { ActiveState ForceUp; }}
      mode_reg_mir_reg\[5\] {
        DataType TestAlgorithm User \"TestAlgoRetention\"{ActiveState ForceUp;}}
      // Retention bit set by algo to start wait. Clear to continue.
      mode_reg_mir_reg\[6\] {
        DataType TestControl TestInterrupt { ActiveState ForceUp; }}
      // Mem fail flag. In pause-on-error mode,
      // flag must be cleared to continue.
      mode_reg_mir_reg\[7\] {
        DataType CoreSelect { ActiveState ForceDown; }
        DataType TestFail { ActiveState ExpectLow; }}
      // 0 Enables pause_on_error mode.
      mode_reg_mir_reg\[8\] {
        DataType CoreSelect {ActiveState ForceDown;}}
      // In retention pause, these bits encode the data pattern.
      // Need a table to lookup pattern.
      mode_reg_mir_reg\[12..9\] {
        DataType TestData TestAlgorithm User \"testPatternSelect\"; }
      // In pause-on-error mode, these bits encode the port pairs under test.
      // Need a table to lookup pairs.
      mode_reg_mir_reg\[14..13\] {
 //@@ Not supported by CTL: DataType TestPortSelect;
      }
      // These double as memory enable bits (initialize to 1 to test memory).
      // They are also fail bits. Enable transitions to zero to indicate
      // failure.
  "
  for {set i 0} {$i < $num_mem} {incr i} {
    puts [format " mode_reg_mir_reg\[%d\] {
        DataType CoreSelect { ActiveState ForceUp; }
        DataType TestFail { ActiveState ExpectHigh; } } " [expr ($i + 15)]]
  }
  puts "
    }
    PatternInformation {
      Macro \"run_mbist\" {
        Purpose DoTest;
//@@ not supported
//        UseByPattern MemoryBIST;
      }
    }
  } // CTL diagnose
  "
}
 *}
}

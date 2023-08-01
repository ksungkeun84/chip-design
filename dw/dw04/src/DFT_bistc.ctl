STIL 1.0 {
    CTL P2001.10;
    Design P2001.01;
    TCL P2001.01;
}
Header {
    Title "CTL template for DBIST controller";
}
Signals {
  "bist_clk" In;
  "bist_reset" In;
  "bist_mode" In;
  "auto_mode" In;
  "bist_run" In;
  "bist_diag" In;
  "fast_clock_enable" Out;
  "diag_data_valid" Out;
  "lfsr_se" In;
  "reuse_seed" In;
  "top_se" In;
  "core_se" Out;
  "core_se_i" Out;
  "bist_bypass" In;
  "bist_se" In;
  "bist_si" In;
  "bist_done" Out ;
  "bist_so" Out ;
  "reuse_seed_gated" Out;
  "prpg_clk" Out;
  "misr_clk" Out;
  "misr_scb[0]" Out;
  "misr_scb[1]" Out;
  "misr_scb[2]" Out;
  "misr_scb[3]" Out;
  Pragma TCL {* 
   if {$pattern_ctr_width>1} {
     for {set i [expr $pattern_ctr_width-1]} {$i>=0} {incr i -1} {
        puts "  \"pattern_ctr_data\[$i\]\" In;";
     }
   } else {
     puts "  \"pattern_ctr_data\" In;";
   }
   if {$cycle_ctr_width>1} {
     for {set i [expr $cycle_ctr_width-1]} {$i>=0} {incr i -1} {
        puts "  \"cycle_ctr_data\[$i\]\" In;";
     }
   } else {
     puts "  \"cycle_ctr_data\" In;";
   }
  *}
}
ScanStructures Internal_scan {
  Pragma TCL {* 
    puts [ format "\tScanChain \"unstitched_1\" {"]
    switch  $diag_output { 
      1 { set diag_count 7}
      2 { set diag_count 6}
      4 { set diag_count 5}
      8 { set diag_count 4}
      16 { set diag_count 3} }

          puts [ format "\t\tScanLength %s;" [expr $width + $diag_count+6]]
          puts [ format "\t\tScanCells \"first_pat_reg\""] 
          for {set i 0} {$i<4} {incr i} {
            puts [ format "\t\t\t\"U_diag_i/curr_state_reg\[$i\]\""] 
          }
          for {set i 0} {$i<$diag_count} {incr i} {
            puts [ format "\t\t\t\"U_diag_i/U_counter_i/count_reg\[$i\]\"" ]
          } 
          for {set i 0} {$i<$width} {incr i} {
            puts [format "\t\t\t\"U_counter_i/U1_3_$i\""] 
          } 
          puts [format "\t\t\t\"U_counter_i/U2_1\";" ]
         puts [ format "\t\tScanIn \"bist_si\";" ]
         puts [ format "\t\tScanOut \"bist_so\";" ]
         puts [ format "\t\tScanEnable \"bist_se\";" ]
         puts [ format "\t\tScanMasterClock \"bist_clk\";" ]
         puts [ format "\t}"] *} 
}
Environment DFT_bistc {
   CTL {
      Family SNPS_DBIST_controller;
      Pragma TCL {*
      puts "      Internal {  
	\"bist_clk\" { DataType MasterClock; }
  	\"bist_run\" { DataType TestRun User snps_bist_run { ActiveState ForceUp;}}
  	\"bist_done\" { DataType TestDone User snps_bist_done; } ";
      if {$pattern_ctr_width>1} {
        for {set i [expr $pattern_ctr_width-1]} {$i>=0} {incr i -1} {
           puts "\t\"pattern_ctr_data\[$i\]\" {DataType User snps_bist_patctr_data; }";
        }
      } else {
        puts "\t\"pattern_ctr_data\" {DataType User snps_bist_patctr_data; }";
      }
      if {$cycle_ctr_width>1} {
        for {set i [expr $cycle_ctr_width-1]} {$i>=0} {incr i -1} {
           puts "\t\"cycle_ctr_data\[$i\]\" {DataType User snps_bist_cyclctr_data;}";
        }
      } else {
        puts "\t\"cycle_ctr_data\" {DataType User snps_bist_cyclctr_data;}";
      }
      puts "
      }";
   *}
   }
   CTL Internal_scan {
      TestMode InternalTest; 
      Family SNPS_DBIST_controller;
      DomainReferences {
	ScanStructures Internal_scan;
      }
      Internal {  
	"bist_clk" { DataType ScanMasterClock User snps_bist_clk {
		ActiveState ForceUp;
		}
	}
  	"bist_reset" { 
		DataType Asynchronous User snps_bist_reset {
			ActiveState ForceUp;
		}
	}		
  	"bist_mode" { DataType Functional; }
  	"auto_mode" { DataType Functional; }
  	"bist_run" { DataType TestRun User snps_bist_run { ActiveState ForceUp;}}
  	"bist_diag" { DataType User snps_bist_diag; }
  	"fast_clock_enable" { DataType User snps_bist_fast_clock_enable; }
  	"diag_data_valid" { DataType User snps_bist_diag_valid; }
  	"lfsr_se" { DataType User snps_bist_se; }
  	"reuse_seed" { DataType User snps_bist_reuse_seed; }
  	"top_se" { DataType User snps_bist_se; }
  	"bist_bypass" { DataType User snps_bist_bypass; }
        "bist_se" { DataType ScanEnable {ActiveState ForceUp;} }
        "bist_si" { CaptureClock "bist_clk" {LeadingEdge;} DataType ScanDataIn {ScanDataType Internal;} }
        "bist_so" { LaunchClock "bist_clk" {LeadingEdge;} DataType ScanDataOut {ScanDataType Internal;} }
  	"bist_done" { DataType TestDone User snps_bist_done; }
  	"reuse_seed_gated" { DataType User snps_bist_reuse_seed_gated; }
  	"prpg_clk" { DataType User snps_bist_prpg_clk; IsConnected Out {Signal "bist_clk";}}
  	"misr_clk" { DataType User snps_bist_misr_clk; IsConnected Out {Signal "bist_clk";}}
  	"misr_scb[0]" { DataType User snps_bist_misr_scb_0;}
  	"misr_scb[1]" { DataType User snps_bist_misr_scb_1;}
  	"misr_scb[2]" { DataType User snps_bist_misr_scb_2;}
  	"misr_scb[3]" { DataType User snps_bist_misr_scb_3;}
      }
   }
   CTL Mission_mode {
      TestMode Normal; 
      Family SNPS_DBIST_controller;
      Internal {  
	"bist_clk" { DataType MasterClock User snps_bist_clk { ActiveState ForceUp;} }
  	"bist_run" { DataType TestRun User snps_bist_run { ActiveState ForceUp;}}
  	"bist_done" { DataType TestDone User snps_bist_done; }
  	"bist_reset" { 
		DataType Asynchronous User snps_bist_reset {
			ActiveState ForceUp;
		}
 	}
      }
   }
}

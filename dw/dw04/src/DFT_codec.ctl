STIL 1.0 {
    CTL P2001.10;
    Design P2001.01;
    TCL P2001.01;
}
Header {
    Title "Minimal STIL for design `TOP'";
    Date "Tue Feb 25 10:24:19 2003";
    Source "DFT Compiler U-2003.06-HO2";
}
Signals {
   "bist_reset" In; 
   "bist_mode" In;
   "auto_mode" In;
   "bist_diag"  In ;
   "fast_clock_enable" Out;
   "diag_data_valid" Out;
   "bist_fail" Out;
   "lfsr_se"  In;
   "bist_bypass" In ;
   "reuse_seed_gated" In ;
   "prpg_clk" In;
   "misr_clk" In;
   "misr_scb[0]" In ;
   "misr_scb[1]" In ;
   "misr_scb[2]" In ;
   "misr_scb[3]" In ;
   Pragma TCL {* 
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"lfsr_si\[$i\]\" In;\n"];
       } else {
         puts [format "\"lfsr_si\" In;\n"];
       }
     } 
     for {set i 0} {$i<[expr $codec_count*$diag_output]} {incr i} {
       if {[expr $codec_count*$diag_output]>1} {
         puts [format "\"lfsr_so\[$i\]\" Out;\n"];
       } else {
         puts [format "\"lfsr_so\" Out;\n"];
       }
     } 
      if {[expr $codec_count*$shadow_width] > 1} {
        for {set i 0} {$i<[expr $codec_count*$shadow_width]} {incr i} {
	  puts [format "\"shadow_si\[$i\]\" In;\n"]
        } 
      } else {
	puts [format "\"shadow_si\" In;\n"]
      }
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"shadow_so\[$i\]\" Out;\n"];
       } else {
         puts [format "\"shadow_so\" Out;\n"];
       }
     } 
     if { [expr $codec_count*$chain_count] > 1} {
  	for {set i 0} {$i<[expr $codec_count*$chain_count]} {incr i} {
	  puts [format "\"core_so\[$i\]\" In;\n"]
	} 
  	for {set i 0} {$i<[expr $codec_count*$chain_count]} {incr i} {
	  puts [format "\"core_si\[$i\]\" Out;\n"]
	} 
     } else {
       puts [format "\"core_so\" In;\n"]
       puts [format "\"core_si\" Out;\n"]
     }
  *}
}
ScanStructures Bist_Mode {
   Pragma TCL {* 
      for {set i 0} {$i<$codec_count} {incr i} {
	puts [format "ScanChain \"lfsr_$i\" {\n"]  
	puts [format "  ScanLength %d; \n" [expr $prpg_length+128]];
	if {$codec_count>1} {
	  puts [format "  ScanIn \"lfsr_si\[$i\]\" ;\n"] ;
	} else {
	  puts [format "  ScanIn \"lfsr_si\" ;\n"] ;
	}
	if {[expr $codec_count*$diag_output]>1} {
	  puts [format "  ScanOut \"lfsr_so\[%d\]\" ;\n" [expr $i*$diag_output]] ;
	} else {
	  puts [format "  ScanOut \"lfsr_so\" ;\n" [expr $i]] ;
	}
	puts [format "  ScanEnable \"lfsr_se\"; \n"];
	puts [format "  ScanMasterClock \"misr_clk\"; \n"]
	puts [format "  ScanCells\n"];
	for {set j 0} {$j<$prpg_length} {incr j} {
	  puts [format "\"U_prpg_i_$i/U_lfsr_i/lfsrout_reg\[$j\]\"\n"];
	} 
	for {set j 0} {$j<128} {incr j} {
	  puts [format "\"U_prpg_i_$i/U_misr_i/o_reg\[$j\]\"\n"];
	}
	puts [format ";\n"];
	puts [format "}\n"]
      }
      for {set i 0} {$i<$codec_count} {incr i} {
	for {set j 0} {$j<$shadow_width} {incr j} {
	  set scan_length [expr $prpg_length/$shadow_width + 1];
          if {$scan_length > $prpg_length} {
	    set scan_length $prpg_length;
          }
	  if {$j <= [expr $shadow_width-1]} {
	    if {$codec_count>1} {
	      puts [format "ScanChain \"shadow_%d_%d\"" $i $j ]; 
            } else {
	      puts [format "ScanChain \"shadow_$j\"" ];
	    }
	    puts [format " {\n"];
	    puts [format "   ScanLength %d ;\n" [expr $scan_length]];
            if {[expr $codec_count*$shadow_width] > 1} {
	      puts [format "   ScanIn \"shadow_si\[%d\]\" ;\n" [expr $i*$shadow_width+$j]];
	    } else {
	      puts [format "   ScanIn \"shadow_si\" ;\n" ];
	    }
	    puts [format "   ScanMasterClock  \"prpg_clk\";\n"];
	    puts [format "   ScanCells\n"];
	    for {set k 0} {$k< $scan_length} {incr k} {
	      puts [format "\"U_prpg_i_$i/U_shadow_i/lfsrin_i_reg\[%d\]\"\n" [expr $j*$scan_length + $k]];
	    } 
	    puts [format ";\n"];
	    puts [format "}\n"];
	  } else {
	    if {$codec_count>1} {
	      puts [format "ScanChain \"shadow_%d_%d\"" $i $j ]; 
            } else {
	      puts [format "ScanChain \"shadow_$j\"" ];
	    }
	    puts [format " {\n"];
	    puts [format "   ScanLength %d ;\n" [expr $prpg_length -[expr $scan_length*$shadow_width]]];
            if {[expr $codec_count*$shadow_width] > 1} {
	      puts [format "   ScanIn \"shadow_si\[%d\]\" ;\n" [expr $i*$shadow_width+$j]];
	    } else {
	      puts [format "   ScanIn \"shadow_si" ;\n"];
	    }
	    puts [format "   ScanMasterClock  \"prpg_clk\";\n"];
	    puts [format "   ScanCells\n"];
	    set last_cell [expr $prpg_length - $scan_length*[expr $shadow_width-1]];
	    for {set k 0} {$k< $last_cell} {incr k} {
	      puts [format "\"U_prpg_i_$i/U_shadow_i/lfsrin_i_reg\[%d\]\"\n" [expr $j*$scan_length + $k]];
	    } 
	    puts [format ";\n"];
	    puts [format "}\n"];
	  }
	}  
      }
      if {$diag_output > 1} {
	for {set i 0} {$i < $codec_count} {incr i} {
	  for {set j 1} {$j < $diag_output} {incr j } {
	      puts [format "ScanChain \"misr_%d\" {" [expr $i*$diag_output+$j]]; 
	      puts [format "ScanLength 1;\n" $i]; 
	      puts [format "ScanCells \"U_prpg_i_$i/U_misr_i/o_reg\" ;\n" $i]; 
	      puts [format "ScanOut \"lfsr_so\[%d\]\";\n" [expr $i*$diag_output+$j]]; 
	      puts [format "ScanEnable \"lfsr_se\";\n"]; 
	      puts [format "ScanMasterClock \"misr_clk\";\n"]; 
	      puts [format "}\n"]; 
	  }
	}
      }
      puts [format "ScanChainGroups {\n"];
      for {set i 0} {$i<$codec_count} {incr i} {
         puts [format "   lfsr_group_%d {\n" $i];
         puts [format "      \"lfsr_%d\";\n" $i];
         puts [format "   }\n"];
         puts [format "   shadow_lfsr_%d {\n" $i];
	 for {set j [expr $shadow_width-1]} {$j >= 0} {incr j -1} {
	    if {$codec_count>1} {
              puts [format "      \"shadow_%d_%d\";\n" $i $j];
	    } else {
              puts [format "      \"shadow_%d\";\n" $j];
	    }
	 }
         puts [format "   }\n"];
      }
      if {$diag_output > 1} {
	for {set i 0} {$i<$codec_count} {incr i} {
          puts [format "   partial_compactor_$i {\n"];
	  for {set j 1} {$j<$diag_output} {incr j} {
	    puts [format "      \"misr_%d\";" [expr $i*$diag_output+$j]];
	  }
          puts [format "   }\n"];
	}
      }
      puts [format "   all_lfsrs {\n"];
      for {set i 0} {$i<$codec_count} {incr i} {
        puts [format "   lfsr_group_%d;\n" $i];
      }
      puts [format "   }\n"];
      puts [format "   all_shadows {\n"];
      for {set i 0} {$i<$codec_count} {incr i} {
        puts [format "   shadow_lfsr_%d;\n" $i];
      }
      puts [format "   }\n"];

      if {$diag_output > 1} {
        for {set i 0} {$i < $codec_count} {incr i} {
 	  puts [format "   compactor_$i {\n"];
 	  puts [format "      lfsr_group_$i;\n"];
 	  puts [format "      partial_compactor_$i;\n"];
 	  puts [format "   }\n"];
        }
 	puts [format "   all_compactors {\n"];
        for {set i 0} {$i < $codec_count} {incr i} {
 	  puts [format "     compactor_$i;\n"];
	}
 	puts [format "   }\n"];
      }
      puts [format "}\n"];
   *}
}
ScanStructures Internal_scan {
   Pragma TCL {* 
          for {set i 0} {$i<$codec_count} {incr i} {
            puts [format "ScanChain \"scan_lfsr_$i\" {\n"];  
            puts [format "  ScanLength %d; \n" [expr $prpg_length+128]];
            if {$codec_count>1} {
              puts [format "  ScanIn \"lfsr_si\[$i\]\" ;\n"] ;
            } else {
              puts [format "  ScanIn \"lfsr_si\" ;\n"] ;
  	    }
            if {[expr $codec_count*$diag_output]>1} {
              puts [format "  ScanOut \"lfsr_so\[%d\]\" ;\n" [expr $i]] ;
	    } else {
              puts [format "  ScanOut \"lfsr_so\" ;\n" [expr $i]] ;
	    }
            puts [format "  ScanEnable \"lfsr_se\"; \n"];
            puts [format "  ScanMasterClock \"misr_clk\"; \n"];
            puts [format "  ScanCells\n"];
            for {set j 0} {$j<$prpg_length} {incr j} {
	      puts [format "\"U_prpg_i_$i/U_lfsr_i/lfsrout_reg\[$j\]\"\n"];
	    } 
            for {set j 0} {$j<128} {incr j} {
	      puts [format "\"U_prpg_i_$i/U_misr_i/o_reg\[$j\]\"\n"];
  	    }
	    puts [format ";\n"];
            puts [format "}\n"];
            puts [format "ScanChain \"scan_shadow_$i\"  {\n"];
            puts [format "   ScanLength $prpg_length ;\n"];
            if {[expr $codec_count*$shadow_width] > 1} {
              puts [format "   ScanIn \"shadow_si\[%d\]\" ;\n" [expr $i*$shadow_width]];
	    } else {
              puts [format "   ScanIn \"shadow_si\" ;\n"];
	    }
            if {$codec_count>1} {
              puts [format "   ScanOut \"shadow_so\[$i\]\" ;\n"];
	    } else {
              puts [format "   ScanOut \"shadow_so\" ;\n"];
	    }
            puts [format "  ScanEnable \"lfsr_se\"; \n"];
            puts [format "   ScanMasterClock  \"prpg_clk\";\n"];
            puts [format "  ScanCells\n"];
            for {set j 0} {$j<$prpg_length} {incr j} {
	      puts [format "\"U_prpg_i_$i/U_shadow_i/lfsrin_i_reg0\[$j\]\"\n"];
	    } 
	    puts [format ";\n"];
            puts [format "}\n"];
          } *}
} 

Environment DFT_codec {
  CTL {
      Family SNPS_DBIST_CODEC;
      Internal {  
	"prpg_clk" { DataType ScanMasterClock MasterClock; }
	"misr_clk" { DataType ScanMasterClock MasterClock; }
      }
  }
  CTL Mission_mode {
      Family SNPS_DBIST_CODEC;
      TestMode Normal; 
      Internal {  
	"prpg_clk" { DataType ScanMasterClock MasterClock; }
	"misr_clk" { DataType ScanMasterClock MasterClock; }
      }
  }
  CTL Bist_Mode {
      Family SNPS_DBIST_CODEC;
      TestMode InternalTest; 
      DomainReferences {
	ScanStructures Bist_Mode;
      }
      Pragma TCL {* 
	puts [format " Internal { \n"]; 

	puts [format "\"bist_reset\" { \n"];  
	puts [format "    DataType Asynchronous User snps_bist_reset {
				ActiveState ForceUp;
			  }"];
	puts [format "  }\n"];

	puts [format "\"bist_mode\" { \n"];  
	puts [format "    DataType Functional;"];
	puts [format "  }\n"];

	puts [format "\"auto_mode\" { \n"];  
	puts [format "    DataType Functional;"];
	puts [format "  }\n"];

	puts [format "\"bist_fail\" { \n"];  
	puts [format "    DataType TestFail User snps_bist_fail;"];
	puts [format "  }\n"];

	puts [format "\"bist_diag\" { \n"];  
	puts [format "    DataType User snps_bist_diag;"];
	puts [format "  }\n"];

	puts [format "\"fast_clock_enable\" { \n"];  
	puts [format "    DataType User snps_bist_fast_clock_enable;"];
	puts [format "  }\n"];

	puts [format "\"diag_data_valid\" { \n"];  
	puts [format "    DataType User snps_bist_diag_data_valid;"];
	puts [format "  }\n"];

	puts [format "\"bist_bypass\" { \n"];  
	puts [format "    DataType User snps_bist_bypass;"];
	puts [format "  }\n"];

	puts [format "\"reuse_seed_gated\" { \n"];  
	puts [format "    DataType User snps_bist_reuse_seed_gated;"];
	puts [format "  }\n"];

	#puts [format "\"lfsr_se\" { DataType ScanEnable; }\n"];
	puts [format "\"lfsr_se\" { DataType User snps_lfsr_se {ActiveState ForceUp;} }\n"];

	puts [format "\"prpg_clk\" { \n"];  
	puts [format "    DataType ScanMasterClock User snps_bist_prpg_clk User snps_bist_clk {\n"];
        puts [format "      ActiveState ForceUp; \n"];
        puts [format "    }\n"];  
        puts [format "  }\n"];  

	puts [format "\"misr_clk\" { \n"];  
	puts [format "    DataType ScanMasterClock User snps_bist_misr_clk User snps_bist_clk {\n"];
        puts [format "      ActiveState ForceUp; \n"];
        puts [format "    }\n"];  
        puts [format "  }\n"];  

	puts [format "\"misr_scb\[0\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_0;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[1\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_1;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[2\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_2;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[3\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_3;"];
	puts [format "  }\n"];

	for {set i 0} {$i<$codec_count} {incr i} {
	   if {$codec_count>1} {
	     puts [format "\"lfsr_si\[$i\]\" { \n"];  
	     puts [format "    CaptureClock \"misr_clk\" {\n"];
	     puts [format "        LeadingEdge;\n"];
	     puts [format "    }\n"];
	     puts [format "    DataType ScanDataIn User snps_lfsr_si {ScanDataType Internal;}\n"];
	     puts [format "}\n"];
	   } else {
	     puts [format "\"lfsr_si\" { \n"];  
	     puts [format "    CaptureClock \"misr_clk\" {\n"];
	     puts [format "        LeadingEdge;\n"];
	     puts [format "    }\n"];
	     puts [format "    DataType ScanDataIn User snps_lfsr_si {ScanDataType Internal;}\n"];
	     puts [format "}\n"];
	   }
	} 
	for {set i 0} {$i<[expr $codec_count*$diag_output]} {incr i} {
	  if {[expr $codec_count*$diag_output]>1} {
	    puts [format "\"lfsr_so\[$i\]\" { \n"];  
	    puts [format "    LaunchClock  \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut User snps_lfsr_so {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
	  } else {
	    puts [format "\"lfsr_so\" { \n"];  
	    puts [format "    LaunchClock \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut User snps_lfsr_so {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
	  }
	} 
	for {set i 0} {$i<[expr $codec_count*$shadow_width]} {incr i} {
          if {[expr $codec_count*$shadow_width] > 1} {
	    puts [format "\"shadow_si\[$i\]\" \{ \n"];  
	  } else {
	    puts [format "\"shadow_si\" \{ \n"];  
	  }
	  puts [format "    CaptureClock \"prpg_clk\" {LeadingEdge;}\n"];
	  puts [format "    DataType ScanDataIn {ScanDataType Internal;}\n"];
	  puts [format "\}\n"];
	}
	puts [format "  }\n"]; 
     *}	 
   }
   CTL Internal_scan {
      Family SNPS_DBIST_CODEC;
      TestMode InternalTest; 
      DomainReferences {
	ScanStructures Internal_scan;
      }
      Pragma TCL {* 
	puts [format " Internal { \n"]; 

	puts [format "\"bist_reset\" { \n"];  
	puts [format "    DataType Asynchronous User snps_bist_reset {
				ActiveState ForceUp;
			  }"];
	puts [format "  }\n"];

	puts [format "\"bist_mode\" { \n"];  
	puts [format "    DataType Functional;"];
	puts [format "  }\n"];

	puts [format "\"auto_mode\" { \n"];  
	puts [format "    DataType Functional;"];
	puts [format "  }\n"];

	puts [format "\"bist_fail\" { \n"];  
	puts [format "    DataType TestFail User snps_bist_fail;"];
	puts [format "  }\n"];

	puts [format "\"bist_diag\" { \n"];  
	puts [format "    DataType User snps_bist_diag;"];
	puts [format "  }\n"];

	puts [format "\"fast_clock_enable\" { \n"];  
	puts [format "    DataType User snps_bist_fast_clock_enable;"];
	puts [format "  }\n"];

	puts [format "\"diag_data_valid\" { \n"];  
	puts [format "    DataType User snps_bist_diag_data_valid;"];
	puts [format "  }\n"];

	puts [format "\"bist_bypass\" { \n"];  
	puts [format "    DataType User snps_bist_bypass;"];
	puts [format "  }\n"];

	puts [format "\"reuse_seed_gated\" { \n"];  
	puts [format "    DataType User snps_bist_reuse_seed_gated;"];
	puts [format "  }\n"];

	#puts [format "\"lfsr_se\" { DataType ScanEnable; }\n"];
	puts [format "\"lfsr_se\" { DataType User snps_lfsr_se {ActiveState ForceUp;} }\n"];

	puts [format "\"prpg_clk\" { \n"];  
	puts [format "    DataType ScanMasterClock User snps_bist_prpg_clk User snps_bist_clk {\n"];
        puts [format "      ActiveState ForceUp; \n"];
        puts [format "    }\n"];  
        puts [format "  }\n"];  

	puts [format "\"misr_clk\" { \n"];  
	puts [format "    DataType ScanMasterClock User snps_bist_misr_clk User snps_bist_clk {\n"];
        puts [format "      ActiveState ForceUp; \n"];
        puts [format "    }\n"];  
        puts [format "  }\n"];  

	puts [format "\"misr_scb\[0\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_0;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[1\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_1;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[2\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_2;"];
	puts [format "  }\n"];

	puts [format "\"misr_scb\[3\]\" { \n"];  
	puts [format "    DataType User snps_bist_misr_scb_3;"];
	puts [format "  }\n"];
	for {set i 0} {$i<$codec_count} {incr i} {
          if {$codec_count>1} {
            puts [format "\"lfsr_si\[$i\]\" { \n"];
	    puts [format "    CaptureClock \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataIn {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          } else {
            puts [format "\"lfsr_si\" { \n"];
	    puts [format "    CaptureClock \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataIn {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          }

          if {[expr $codec_count*$diag_output]>1} {
            puts [format "\"lfsr_so\[$i\]\" { \n"];
	    puts [format "    LaunchClock \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          } else {
            puts [format "\"lfsr_so\" { \n"];
	    puts [format "    LaunchClock \"misr_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          }
	
          if {[expr $codec_count*$shadow_width] > 1} {
	    puts [format "\"shadow_si\[%d\]\" \{ \n" [expr $i*$shadow_width]];  
	  } else {
	    puts [format "\"shadow_si\" \{ \n" ];  
	  }
          puts [format "    CaptureClock \"prpg_clk\" {LeadingEdge;}\n"];
          puts [format "    DataType ScanDataIn {ScanDataType Internal;}\n"];
          puts [format "\}\n"];

          if {$codec_count>1} {
            puts [format "\"shadow_so\[$i\]\" {\n"];
	    puts [format "    LaunchClock \"prpg_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          } else {
            puts [format "\"shadow_so\" { \n"];
	    puts [format "    LaunchClock \"prpg_clk\" {\n"];
	    puts [format "        LeadingEdge;\n"];
	    puts [format "    }\n"];
	    puts [format "    DataType ScanDataOut {ScanDataType Internal;}\n"];
	    puts [format "}\n"];
          }

	}
	puts [format "  }\n"]; 
     *}	 
  }
}

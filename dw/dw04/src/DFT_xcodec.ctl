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
   "bist_clk" In; 
   "bist_mode" In;
   "fast_clock_enable" Out;
   "lfsr_se"  In;
   "bist_bypass" In ;
   "reuse_seed_gated" In ;
   Pragma TCL {* 
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"lfsr_si\[$i\]\" In;"];
       } else {
         puts [format "\"lfsr_si\" In;"];
       }
     } 
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"lfsr_so\[$i\]\" Out;"];
       } else {
         puts [format "\"lfsr_so\" Out;"];
       }
     } 
     if {[expr $codec_count*$shadow_width] > 1} {
       for {set i 0} {$i < [expr $codec_count*$shadow_width]} {incr i} { 
	 puts [format "\"shadow_si\[$i\]\" In;"]
       }
     } else {
       puts [format "\"shadow_si\" In;"]
     }
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"shadow_so\[$i\]\" Out;"];
       } else {
         puts [format "\"shadow_so\" Out;"];
       }
     } 
     for {set i 0} {$i<[expr $codec_count*$xshadow_width]} {incr i} {
       if {$codec_count*$xshadow_width>1} {
         puts [format "\"x_shadow_si\[$i\]\" In;"];
       } else {
         puts [format "\"x_shadow_si\" In;"];
       }
     }
     for {set i 0} {$i<$codec_count} {incr i} {
       if {$codec_count>1} {
         puts [format "\"x_shadow_so\[$i\]\" Out;"];
       } else {
         puts [format "\"x_shadow_so\" Out;"];
       }
     }
     for {set i 0} {$i<[expr $codec_count*$x_out_count]} {incr i} {
       if  {$codec_count*$x_out_count>1} {
         puts [format "\"x_so\[$i\]\" Out;"];
       } else {
         puts [format "\"x_so\" Out;"]; 
       }
     }
     if {[expr $codec_count*$chain_count] > 1} {
       for {set i 0} {$i<[expr $codec_count*$chain_count]} {incr i} {
	 puts [format "\"core_so\[$i\]\" In;"]
       }
       for {set i 0} {$i<[expr $codec_count*$chain_count]} {incr i} {
	 puts [format "\"core_si\[$i\]\" Out;"]
       } 
     } else {
       puts [format "\"core_so\" In;"]
       puts [format "\"core_si\" Out;"]
     }
   *}
}
ScanStructures Bist_Mode {
  Pragma TCL {* 
    for {set i 0} {$i<$codec_count} {incr i} {
      puts [format "ScanChain \"lfsr_$i\" {"]  
      puts [format "  ScanLength %s; " [expr $prpg_length+8*$sel_count]]
      if {$codec_count>1} {
	puts [format "  ScanIn \"lfsr_si\[$i\]\" ;"] ;
      } else {
	puts [format "  ScanIn \"lfsr_si\" ;"] ;
      }
      if {$codec_count>1} {
	puts [format "  ScanOut \"lfsr_so\[%d\]\" ;" [expr $i]] ;
      } else {
	puts [format "  ScanOut \"lfsr_so\" ;"];
      }
      puts [format "  ScanMasterClock \"bist_clk\"; "]
      puts [format "  ScanCells"];
      for {set j 0} {$j<$prpg_length} {incr j} {
	puts [format "\"U_prpg_i_%d/U_lfsr_i/lfsrout_reg\[$j\]\"" $i];
      } 
      for {set j 0} {$j<8*$sel_count} {incr j} {
	puts [format "\"U_xbist_i_%d/selcontrol_mod/lfsrout_reg\[$j\]\"" $i];
      }
      puts [format ";"];
      puts [format "}"]
    }
    for {set i 0} {$i<$codec_count} {incr i} {
      for {set j 0} {$j<$shadow_width} {incr j} {
	set scan_length [expr $prpg_length/$shadow_width + 1];
        if {$scan_length > $prpg_length} {
          set scan_length $prpg_length;
        }
	if {$j< [expr $shadow_width-1]} {
	  if {$codec_count>1} {
	    puts [format "ScanChain \"shadow_%d_%d\"" $i $j ]; 
	  } else {
	    puts [format "ScanChain \"shadow_$j\"" ];
	  }
	  puts [format " {"];
	  puts [format "   ScanLength %d ;" [expr $scan_length]];
	  if {[expr $codec_count*$shadow_width] > 1} {
	    puts [format "   ScanIn \"shadow_si\[%d\]\" ;" [expr $i*$shadow_width+$j]];
	  } else {
	    puts [format "   ScanIn \"shadow_si\" ;"];
	  }
	  puts [format "   ScanMasterClock  \"bist_clk\";"];
	  puts [format "   ScanCells"];
	  set start_len [expr $i*$shadow_width + $j];
	  for {set k 0} {$k< $scan_length} {incr k} {
	    puts [format "\"U_prpg_i_%d/U_shadow_i/lfsrin_i_reg\[%d\]\"" $i [expr $j*$scan_length + $k]];
	  } 
	  puts [format ";"];
	  puts [format "}"];
	} else {
	  set start_len [expr $i*$shadow_width + $j];
	  set last_cell [expr $prpg_length - $scan_length*[expr $shadow_width-1]];
	  if {$codec_count>1} {
	    puts [format "ScanChain \"shadow_%d_%d\"" $i $j ]; 
	  } else {
	    puts [format "ScanChain \"shadow_$j\"" ];
	  }
	  puts [format " {"];
	  puts [format "   ScanLength %d ;" $last_cell];
	  if {[expr $codec_count*$shadow_width] > 1} {
	    puts [format "   ScanIn \"shadow_si\[%d\]\" ;" [expr $i*$shadow_width+$j]];
	  } else {
	    puts [format "   ScanIn \"shadow_si\" ;" ];
	  }
	  puts [format "   ScanEnable \"lfsr_se\"; "];
	  puts [format "   ScanMasterClock  \"bist_clk\";"];
	  puts [format "   ScanCells"];
	  for {set k 0} {$k< $last_cell} {incr k} {
	    puts [format "\"U_prpg_i_%d/U_shadow_i/lfsrin_i_reg\[%d\]\"" $i [expr $j*$scan_length + $k]];
	  } 
	  puts [format ";"];
	  puts [format "}"];
	}
      }
    }
  *}
  Pragma TCL {* 
    set xshadow_init [expr ($sel_count+$xshadow_width-1)/$xshadow_width];
    set scan_length [expr 8*$xshadow_init];
    if {$codec_count*$xshadow_width>1} {
      for {set i 0} {$i<$codec_count} {incr i} {
	for {set j 0} {$j<$xshadow_width} {incr j} {
	  if {$j< [expr $xshadow_width-1]} {
	    puts [format "ScanChain \"selshadow_%d_%d\"" $i $j ];
	    puts [format " {"];
	    puts [format "   ScanLength %d ;" [expr $scan_length]];
	    puts [format "   ScanIn \"x_shadow_si\[%d\]\" ;" [expr $i*$xshadow_width+$j]];
	    puts [format "   ScanMasterClock  \"bist_clk\";"];
	    puts [format "   ScanCells"];
	    for {set k 0} {$k< $scan_length} {incr k} {
	      puts [format "\"U_xbist_i_%d/selshadow_mod/lfsrin_reg\[%d\]\"" $i [expr $j*$scan_length + $k]];
            }
	    puts [format ";"];
	    puts [format "}"];

          } else {
            set start_len [expr $j*$scan_length];
            set last_cell [expr 8*$sel_count - $scan_length*[expr $xshadow_width-1]];
            puts [format "ScanChain \"selshadow_%d_%d\"" $i $j ];
            puts [format " {"];
            puts [format "   ScanLength %d ;" $last_cell];
            puts [format "   ScanIn \"x_shadow_si\[%d\]\" ;" [expr $i*$xshadow_width+$j]];
            puts [format "   ScanMasterClock  \"bist_clk\";"];
            puts [format "   ScanCells"];
            for {set k 0} {$k< $last_cell} {incr k} {
              puts [format "\"U_xbist_i_%d/selshadow_mod/lfsrin_reg\[%d\]\"" $i [expr $start_len + $k]];
            }
            puts [format ";"];
            puts [format "}"];

          }
        }
      }
    } else {
      puts [format "ScanChain \"selshadow_0\"  {"];
      puts [format "   ScanLength $scan_length ;"];
      puts [format "   ScanIn \"x_shadow_si\" ;" ] ;
      puts [format "   ScanEnable \"lfsr_se\"; "];
      puts [format "   ScanMasterClock  \"bist_clk\";"];
      puts [format "  ScanCells "];
      for {set j 0} {$j<$scan_length} {incr j} {
        puts [format "\"U_xbist_i_0/selshadow_mod/lfsrin_reg\[$j\]\""];
      } 
      puts [format ";"];
      puts [format "}"];
    }
    for {set i 0} {$i < [expr $codec_count*$x_out_count]} {incr i} {
      puts [format "ScanChain \"xtatr_%d\" {" $i];
      puts [format "   ScanLength 1;"];
      puts [format "   ScanCells \"xtatr\";"];
      if {[expr $codec_count*$x_out_count] > 1} {
        puts [format "   ScanOut \"x_so\[%d\]\";" $i];
      } else {
        puts [format "   ScanOut \"x_so\";"];
      }
      puts [format "}"];
    }
  *}
  Pragma TCL {* 
    puts [format "ScanChainGroups {"];
    for {set i 0} {$i<$codec_count} {incr i} {
         puts [format "   lfsr_group_%d {" $i];
         puts [format "      \"lfsr_%d\";" $i];
         puts [format "   }"];

         puts [format "   x_shadow_%d {" $i];
	 for {set j 0} {$j<$xshadow_width} {incr j} {
	   if {$codec_count*$xshadow_width>1} {
             puts [format "      \"selshadow_%d_%d\";" $i $j];
	   } else {
             puts [format "      \"selshadow_0\";"];
	   }
	 }
         puts [format "   }"];
         puts [format "   shadow_lfsr_%d {" $i];
         for {set j [expr $shadow_width-1]} {$j >= 0} {incr j -1} {
            if {$codec_count>1} {
              puts [format "      \"shadow_%d_%d\";" $i $j];
            } else {
              puts [format "      \"shadow_%d\";" $j];
            }
         }
         puts [format "   }"];
         puts [format "   selector_group_%d {" $i];
         for {set j 0} {$j<$x_out_count} {incr j} {
           if {[expr $codec_count*$x_out_count]>1} {
             puts [format "      \"xtatr_%d\";" [expr $i*$x_out_count+$j]];
           } else {
             puts [format "      \"xtatr_0\";"];
           }
         }
         puts [format "   }"];
    }
    puts [format "   all_lfsrs {"];
    for {set i 0} {$i<$codec_count} {incr i} {
        puts [format "   lfsr_group_%d;" $i];
    }
    puts [format "   }"];
    puts [format "   all_selectors {"];
    for {set i 0} {$i<$codec_count} {incr i} {
        puts [format "   selector_group_%d;" $i];
    }
    puts [format "   }"];
    puts [format "   all_shadows {"];
    for {set i 0} {$i<$codec_count} {incr i} {
        puts [format "   x_shadow_%d;" $i];
        puts [format "   shadow_lfsr_%d;" $i];
    }
    puts [format "   }"];
    puts [format "}"];
  *}
}
ScanStructures Internal_scan {
  Pragma TCL {* 
    for {set i 0} {$i<$codec_count} {incr i} {
      puts [format "ScanChain \"scan_lfsr_$i\" {"];  
      puts [format "  ScanLength %s; " [expr $prpg_length+8*$sel_count]]
      if {$codec_count>1} {
	puts [format "  ScanIn \"lfsr_si\[$i\]\" ;"] ;
      } else {
	puts [format "  ScanIn \"lfsr_si\" ;"] ;
      }
      if {$codec_count>1} {
	puts [format "  ScanOut \"lfsr_so\[%d\]\" ;" [expr $i]] ;
      } else {
	puts [format "  ScanOut \"lfsr_so\" ;" [expr $i]] ;
      } 
      puts [format "  ScanEnable \"lfsr_se\"; "];
      puts [format "  ScanMasterClock \"bist_clk\"; "];
      puts [format "  ScanCells "];
      for {set j 0} {$j<$prpg_length} {incr j} {
	puts [format "\"U_prpg_i_%d/U_lfsr_i/lfsrout_reg\[$j\]\"" $i];
      } 
      for {set j 0} {$j<8*$sel_count} {incr j} {
	puts [format "\"U_xbist_i_%d/selcontrol_mod/lfsrout_reg\[$j\]\"" $i];
      }
      puts [format ";"];
      puts [format "}"];

      puts [format "ScanChain \"scan_shadow_$i\"  {"];
      puts [format "   ScanLength %s; " [expr $prpg_length]];
      if {$shadow_width>1} {
        puts [format "   ScanIn \"shadow_si\[%d\]\" ;" [expr $i*$shadow_width]];
      } else {
        puts [format "   ScanIn \"shadow_si\" ;"];
      }
      if {$codec_count>1} {
	puts [format "   ScanOut \"shadow_so\[$i\]\" ;"];
      } else {
	puts [format "   ScanOut \"shadow_so\" ;"];
      }
      puts [format "  ScanEnable \"lfsr_se\"; "];
      puts [format "  ScanMasterClock  \"bist_clk\";"];
      puts [format "  ScanCells"];
      for {set j 0} {$j<$prpg_length} {incr j} {
	puts [format "\"U_prpg_i_%d/U_shadow_i/lfsrin_i_reg0\[$j\]\"" $i];
      } 
      puts [format ";"];
      puts [format "}"];

      puts [format "ScanChain \"scan_x_shadow_$i\"  {"];
      puts [format "   ScanLength %d; " [expr 8*$sel_count]];
      if {$codec_count*$xshadow_width>1} {
	puts [format "   ScanIn \"x_shadow_si\[%d\]\" ;" [expr $i*$xshadow_width]];
	if {$codec_count > 1} {
          puts [format "   ScanOut \"x_shadow_so\[$i\]\" ;"];
	} else {
          puts [format "   ScanOut \"x_shadow_so\" ;"];
	}
      } else {
	puts [format "   ScanIn \"x_shadow_si\" ;"];
        puts [format "   ScanOut \"x_shadow_so\" ;"];
      }
      puts [format "   ScanEnable \"lfsr_se\"; "];
      puts [format "   ScanMasterClock  \"bist_clk\";"];
      puts [format "   ScanCells"];
      for {set j 0} {$j<[expr 8*$sel_count]} {incr j} {
	puts [format "\"U_xbist_i_%d/selshadow_mod/lfsrin_reg\[$j\]\"" $i];
      } 
      puts [format ";"];
      puts [format "}"];
    } 
  *}
} 

Environment DFT_xcodec {
   CTL {
      Family SNPS_XDBIST_CODEC;
      Internal {  
	"bist_clk" { DataType MasterClock; }
      }
   }
   CTL Mission_mode {
      Family SNPS_XDBIST_CODEC;
      TestMode Normal; 
      Internal {  
	"bist_clk" { DataType MasterClock; }
      }
   }
   CTL Bist_Mode {
      Family SNPS_XDBIST_CODEC;
      TestMode InternalTest; 
      DomainReferences {
	ScanStructures Bist_Mode;
      }
      Pragma TCL {* 
        puts [format "Internal {"];
        puts [format "\"bist_clk\" { DataType ScanMasterClock User snps_bist_clk; }"];
        puts [format "\"bist_mode\" { DataType Functional; }"];
        puts [format "\"fast_clock_enable\" { DataType User snps_bist_fast_clock_enable; }"];
        puts [format "\"lfsr_se\" { DataType ScanEnable;}"];
        puts [format "\"bist_bypass\" { DataType User snps_bist_bypass; }"];
        puts [format "\"reuse_seed_gated\" { DataType User snps_bist_reuse_seed_gated; }"];
	for {set i 0} {$i<$codec_count} {incr i} {
	   if {$codec_count>1} {
	     puts [format "\"lfsr_si\[%d\]\" { " $i];  
	     puts [format "    CaptureClock \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	     puts [format "} "];
	     puts [format "\"lfsr_so\[%d\]\" { " $i];  
	     puts [format "    LaunchClock  \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	     puts [format "\"x_shadow_so\[%d\]\" { " $i];  
	     puts [format "    LaunchClock  \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   } else {
	     puts [format "\"lfsr_si\" { "];  
	     puts [format "    CaptureClock \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	     puts [format "}"];
	     puts [format "\"lfsr_so\" { "];  
	     puts [format "    LaunchClock \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	     puts [format "\"x_shadow_so\" { "];  
	     puts [format "    LaunchClock \"bist_clk\" {LeadingEdge;}"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   }
	} 
	for {set i 0} {$i<[expr $codec_count*$xshadow_width]} {incr i} {
	   if {$codec_count*$xshadow_width>1} {
	     puts [format "\"x_shadow_si\[%d\]\" { " $i];
	     puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
             puts [format "}"];
	   } else {
	     puts [format "\"x_shadow_si\" { "];  
 	     puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
             puts [format "}"];
 	   }
	} 
	for {set i 0} {$i<[expr $codec_count*$x_out_count]} {incr i} {
	   if {$codec_count*$x_out_count>1} {
             puts [format "\"x_so\[%d\]\" {" $i];
	     puts [format "    LaunchClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
             puts [format "}"];
	   } else {
             puts [format "\"x_so\" {"];
	     puts [format "    LaunchClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
             puts [format "}"];
	   }
	}
        if {[expr $codec_count*$shadow_width] > 1} {
	  for {set i 0} {$i<[expr $codec_count*$shadow_width]} {incr i} {
	    puts [format "\"shadow_si\[%d\]\" { " $i]; 
	    puts [format "    CaptureClock \"bist_clk\" {"];
	    puts [format "        LeadingEdge;"];
	    puts [format "    }"];
	    puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	    puts [format "}"];
	  }
        } else {
	  puts [format "\"shadow_si\" { " $i]; 
	  puts [format "    CaptureClock \"bist_clk\" {"];
	  puts [format "        LeadingEdge;"];
	  puts [format "    }"];
	  puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	  puts [format "}"];
	}
	puts [format "  }"]; 
     *}
   }
   CTL Internal_scan {
      Family SNPS_XDBIST_CODEC;
      TestMode InternalTest;
      DomainReferences {
        ScanStructures Internal_scan;
      }
      Pragma TCL {*
        puts [format " Internal { "];

        puts [format "\"bist_clk\" { "];  
	puts [format "    DataType ScanMasterClock User snps_bist_clk;"];
	puts [format "  }"];

        puts [format "\"bist_mode\" { "];
        puts [format "    DataType Functional;"];
        puts [format "  }"];

        puts [format "\"fast_clock_enable\" { "];
        puts [format "    DataType User snps_bist_fast_clock_enable;"];
        puts [format "  }"];

        puts [format "\"lfsr_se\" { DataType ScanEnable;} "];

        puts [format "\"bist_bypass\" { "];
        puts [format "    DataType User snps_bist_bypass;"];
        puts [format "  }"];

        puts [format "\"reuse_seed_gated\" { "];
        puts [format "    DataType User snps_bist_reuse_seed_gated;"];
        puts [format "  }"];

	for {set i 0} {$i<$codec_count} {incr i} {
	   if {$codec_count>1} {
	     puts [format "\"lfsr_si\[%d\]\" { " $i];
	     puts [format "    CaptureClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	     puts [format "}"];
	   } else {
	     puts [format "\"lfsr_si\" { "];
	     puts [format "    CaptureClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
	     puts [format "}"];
	   }	
	   if {$codec_count>1} {
	     puts [format "\"lfsr_so\[%d\]\" { " $i];
	     puts [format "    LaunchClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   } else {
	     puts [format "\"lfsr_so\" { "];
	     puts [format "    LaunchClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   }
	}
	for {set i 0} {$i<$codec_count} {incr i} {
	   if {$codec_count*$shadow_width>1} {
	     puts [format "\"shadow_si\[%d\]\" \{ " [expr $i*$shadow_width]];  
   	   } else {
	     puts [format "\"shadow_si\" \{"];  
	   }
           puts [format "    CaptureClock \"bist_clk\" {LeadingEdge;}"];
           puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
           puts [format "\}"];
	}
	for {set i 0} {$i<$codec_count} {incr i} {
	   if {$codec_count>1} {
	     puts [format "\"shadow_so\[%d\]\" {" $i];
	     puts [format "    LaunchClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   } else {
	     puts [format "\"shadow_so\" { "];
	     puts [format "    LaunchClock \"bist_clk\" {"];
	     puts [format "        LeadingEdge;"];
	     puts [format "    }"];
	     puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
	     puts [format "}"];
	   }
	   if {$codec_count*$xshadow_width>1} {
	     puts [format "\"x_shadow_si\[%d\]\" { " [expr $i*$xshadow_width]];
             puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataIn {ScanDataType Internal;}"]; 
             puts [format "}"];
	   } else {
	     puts [format "\"x_shadow_si\" { "];
             puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataIn {ScanDataType Internal;}"];
             puts [format "}"];
	   }
	   if {$codec_count>1} {
	     puts [format "\"x_shadow_so\[%d\]\" { " $i];
             puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
             puts [format "}"];
	   } else {
	     puts [format "\"x_shadow_so\" { "];
             puts [format "    CaptureClock \"bist_clk\" {"];
             puts [format "        LeadingEdge;"];
             puts [format "    }"];
             puts [format "    DataType ScanDataOut {ScanDataType Internal;}"];
             puts [format "}"];
	   }
           puts [format "\"lfsr_se\" { DataType ScanEnable;} "];
	   puts [format "\"bist_clk\" { DataType ScanMasterClock; }"];  
	} 
	puts [format "  }"]; 
     *}	 
   }
}

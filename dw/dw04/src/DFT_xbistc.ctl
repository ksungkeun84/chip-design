STIL 1.0 {
    CTL P2001.10;
    Design P2001.01;
    TCL P2001.01;
}
Header {
    Title "CTL template for XDBIST controller";
}
Signals {
   "bist_clk" In;
   "bist_reset" In;
   "bist_mode" In;
   "fast_clock_enable" Out;
   "lfsr_se" In;
   "top_se" In;
   "core_se" Out;
   "core_se_i" Out;
   "bist_bypass" In;
   "bist_se" In;
   "bist_si" In;
   "bist_so" Out ;
   "reuse_seed" In;
   "reuse_seed_gated" Out;
}
ScanStructures Internal_scan {
   Pragma TCL {* 
         puts [ format "ScanChain \"unstitched_1\" {\n"];
         puts [ format "ScanLength %s;\n" [expr $width + 1 ]];
	 puts [ format "ScanCells" \n"];
         for {set i 0} {$i<$width} {incr i} {
           puts [format "\"U_counter_i/U1_3_$i\"\n"] ;
         } 
         puts [format "\"U_counter_i/U2_1\";\n" ];
         #for {set i 0} {$i<$width-1} {incr i} {
         #  puts [format "\"U_counter_i/count_reg\[$i\]\"\n"] ;
         #} 
         #puts [format "\"U_counter_i/count_reg\[%s\]\";\n" [expr $width-1]];
         puts [ format "ScanIn \"bist_si\";\n" ];
         puts [ format "ScanOut \"bist_so\";\n" ];
         puts [ format "ScanEnable \"bist_se\";\n" ];
         puts [ format "ScanMasterClock \"bist_clk\";\n" ];
         puts [ format "}\n"] ;
   *} 
}
Environment DFT_xbistc {
   CTL {
      Family SNPS_XDBIST_controller;
      Internal {  
	"bist_clk" { DataType MasterClock; }
      }
   }
   CTL Internal_scan {
      TestMode InternalTest;
      Family SNPS_XDBIST_controller;
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
  	"fast_clock_enable" { DataType User snps_bist_fast_clock_enable; }
  	"lfsr_se" { DataType User snps_bist_se; }
  	"top_se" { DataType User snps_bist_se; }
  	"bist_bypass" { DataType User snps_bist_bypass; }
        "bist_se" { DataType ScanEnable {ActiveState ForceUp;} }
        "bist_si" { CaptureClock "bist_clk" {LeadingEdge;} DataType ScanDataIn { ScanDataType Internal;} }
        "bist_so" { LaunchClock "bist_clk" {LeadingEdge;} DataType ScanDataOut {ScanDataType Internal;} }
  	"reuse_seed" { DataType User snps_bist_reuse_seed; }
  	"reuse_seed_gated" { DataType User snps_bist_reuse_seed_gated; }
      }
   }
   CTL Mission_mode {
        TestMode Normal;
	Family SNPS_XDBIST_controller;
	Internal {  
	  "bist_clk" { DataType MasterClock; }
	}
   }
}

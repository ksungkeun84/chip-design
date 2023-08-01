#! /bin/csh -f
 
###############################################################################
#                  Copyright (c) 1999-2018 by Synopsys, Inc.
#                            ALL RIGHTS RESERVED
#         This program is proprietary and confidential information
#         of  Synopsys, Inc. and may be used and disclosed only as
#         authorized in a  license agreement controlling such use
#         and disclosure.
###############################################################################
# WARNING: This script is designed for analyzing DesignWare Building Blocks
# version O-2018.06-DWBB_201806.3 with Synopsys' VCS-MX simulator only.
# USING THIS SCRIPT FOR OTHER VERSIONS OR OTHER PURPOSES MAY CAUSE ERROR.
###############################################################################
# Script generation date: Thu Oct 18 21:00:43 PDT 2018
###############################################################################
 
onintr interr
 
set dwf_make_version = O-2018.06-DWBB_201806.3
 

## VCS-MX analysis of DesignWare Building Block Library from its DC tree


## NOTE: By default, this script analyzes only the DW BB library,
#        analyzes the 'cpa' architecture of the DW_div_seq component
#        and the 'mult' architecture of the DW_iir_sc component
#
#  By default, the GTECH Library will be analyzed.  If the GTECH
#  library is not desired, then use the command line option, -nogtech
#
#  By default, the DW BB Library only is analyzed.  If the minPower
#  library is also desired, then use the command line option, -minpower
#
#  By default, the DW BB Library includes the default 'cpa' architecture of
#  the DW_div_seq component.  If the 'cpa2' architecture is desired, then
#  use the command line option, -cpa2_div_seq
#
#  By default, the DW BB Library includes the default 'mult' architecture of
#  the DW_iir_sc component.  If the 'vsim' architecture is desired, then
#  use the command line option, -vsum_iir_sc
#

set minpwrlib = 0
set an_log_file  = an_without_minpower.log
set include_cpa2_div_seq = 0
set include_vsum_iir_sc  = 0
set nogtech = 0

while ( $#argv )
  if ( "$argv[1]" == "-minpower" ) then
    set minpwrlib = 1
    set an_log_file  = an_with_minpower.log
  else if ( "$argv[1]" == "-nogtech" ) then
    set nogtech = 1
  else if ( "$argv[1]" == "-cpa2_div_seq" ) then
    set include_cpa2_div_seq = 1
  else if ( "$argv[1]" == "-vsum_iir_sc" ) then
    set include_vsum_iir_sc  = 1
  else if ( "$argv[1]" == "-here" ) then
    setenv VCSMX_DW_LIB `pwd`
  else
    echo ""
    echo " $0:t : Error : Unknown option, '$argv[1]'"
    echo ""
    echo " USAGE:"
    echo ""
    echo " $0:t [ -minpower ]  [ -cpa2_div_seq ]  [ -vsum_iir_sc ]"
    echo ""
    exit 1
  endif
  shift
end

set pgm = "$0:t"

if ($?VCSMX_DW_LIB) then
  echo " DW Library will be analyzed into the directory, $VCSMX_DW_LIB"
else
  echo "$pgm : Error: Environment variable, VCSMX_DW_LIB, is not defined."
  echo ""
  echo "    Please define the environment variable VCSMX_DW_LIB as the"
  echo "    path to a directory in which the DesignWare Building Block"
  echo "    Library synthesis models are to be analyzed for use with"
  echo "    VCS-MX or use the '-here' option to analyze into the"
  echo "    current working directory."
  exit 2
endif


## If env variable VHD_AN_OPT is defined it will be used
#  as command lin option(s) for vhdlan calls
#
if ($?VHD_AN_OPT) then
  set vhd_an_opt = $VHD_AN_OPT
else
  set vhd_an_opt = " "
endif

## If env variable VER_AN_OPT is defined it will be used
#  as command lin option(s) for vhdlan calls
#
if ($?VER_AN_OPT) then
  set ver_an_opt = $VER_AN_OPT
else
  set ver_an_opt = " "
endif

if ($nogtech == 0) then
  set gtech_map = "gtech : $VCSMX_DW_LIB/gtech"
else
  set gtech_map = ""
endif

if ($?VCS_HOME) then
  if (-x $VCS_HOME/bin/vhdlan) then
    if ($?SYNOPSYS) then

      set target_version = `cat $SYNOPSYS/dw/version`
      if ($target_version != $dwf_make_version) then
        echo ""
	echo " *** WARNING : DW BB Library version MISMATCH ***"
	echo ""
	echo " *** DW BB version from the SYNOPSYS environment variable ($target_version)"
	echo " *** does NOT match the version this script was built for ($dwf_make_version)"
	echo ""
	echo " *** No guarantee analysis will be valid. ***"
	echo ""
      endif

        ## ensure logical library directories are in place in $VCSMX_DW_LIB
        #
        foreach f ( gtech dware dw01 dw02 dw03 dw04 dw06 )
          if (-e $VCSMX_DW_LIB/$f) then
            if (-d $VCSMX_DW_LIB/$f) then
              if (! -w $VCSMX_DW_LIB/$f) then
                echo "$pgm : Error: Logical library '$f' mapped directory"
                echo "     $VCSMX_DW_LIB/$f is not writable."
                echo "     So, analysis cannot be done."
                exit 7
              endif
            else
              echo "$pgm : Error: Logical Lirary '$f' should be mapped to"
              echo "     a directory, but $VCSMX_DW_LIB/$f is not"
              echo "     a directory."
              exit 6
            endif
          else
            mkdir -p $VCSMX_DW_LIB/$f
          endif
        end

        ## Create the synopsys_sim.setup file for access to the
        #  anallyzed files in this location
        #
        rm -f $VCSMX_DW_LIB/synopsys_sim.setup
        cat > $VCSMX_DW_LIB/synopsys_sim.setup << EOF
WORK > DEFAULT
DEFAULT : ./work
$gtech_map
dware : $VCSMX_DW_LIB/dware
dw01  : $VCSMX_DW_LIB/dw01
dw02  : $VCSMX_DW_LIB/dw02
dw03  : $VCSMX_DW_LIB/dw03
dw04  : $VCSMX_DW_LIB/dw04
dw05  : $VCSMX_DW_LIB/dw05
dw06  : $VCSMX_DW_LIB/dw06
EOF

        ## analyze
        #
        cd $VCSMX_DW_LIB
        foreach dir ( gtech dware dw01 dw02 dw03 dw04 dw05 dw06 )
          rm -rf $dir   ## remove any previous analyzed content
          mkdir $dir
        end

        /bin/rm -f version an_with_minpower.log an_without_minpower.log
        cp $SYNOPSYS/dw/version .

        date > $an_log_file
        echo "SYNOPSYS = $SYNOPSYS" >> $an_log_file

        if ($include_cpa2_div_seq == 0) then
          echo "Using standard 'cpa' architecture for DW_div_seq" >> $an_log_file
        else
          echo "Using 'cpa2' architecture for DW_div_seq" >> $an_log_file
        endif

        if ($include_vsum_iir_sc == 0) then
          echo "Using standard 'mult' architecture for DW_iir_sc" >> $an_log_file
        else
          echo "Using 'vsum' architecture for DW_iir_sc" >> $an_log_file
        endif

        ## analysis of gtech and dware libraries go first and are independent of use of options


        if ( ! $nogtech ) then
          set dw_lib_src = $SYNOPSYS/packages/gtech/src
          echo "#### Analyzing gtech library ..." |& tee -a $an_log_file 
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_components.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ADD_AB.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ADD_ABC.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND5.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND8.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND_NOT.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AO21.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AO22.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI21.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI22.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI222.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI2N2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_BUF.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD14.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD18.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD1S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD24.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD28.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD2S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD34.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD38.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD3S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD44.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD48.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD4S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK1S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK2S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK3S.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_INBUF.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_INOUTBUF.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO0_EN0.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO1_EN0.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO0_EN1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO1_EN1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISOLATCH_EN0.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISOLATCH_EN1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD2_1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD4_1.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LSR0.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MAJ23.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUXI2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX8.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND5.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND8.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR5.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR8.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOT.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OA21.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OA22.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI21.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI22.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI2N2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ONE.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR5.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR8.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR_NOT.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OUTBUF.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_TBUF.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR2.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR3.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR4.vhd >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ZERO.vhd >>& $an_log_file

          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ADD_AB_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ADD_ABC_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND5_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND8_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AND_NOT_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AO21_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AO22_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI21_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI22_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI222_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_AOI2N2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_BUF_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD14_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD18_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD1S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD24_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD28_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD2S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD34_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD38_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD3S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD44_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD48_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FD4S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK1S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK2S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_FJK3S_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_INBUF_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_INOUTBUF_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO0_EN0_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO1_EN0_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO0_EN1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISO1_EN1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISOLATCH_EN0_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ISOLATCH_EN1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD2_1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LD4_1_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_LSR0_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MAJ23_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUXI2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_MUX8_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND5_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NAND8_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR5_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOR8_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_NOT_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OA21_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OA22_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI21_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI22_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OAI2N2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ONE_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR5_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR8_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OR_NOT_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_OUTBUF_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_TBUF_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR2_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR3_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XOR4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_XNOR4_fpga.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work gtech  $dw_lib_src/GTECH_ZERO_fpga.vhd.e >>& $an_log_file

        endif

        set dw_lib_src = $SYNOPSYS/packages/dware/src
        echo "#### Analyzing dware library ..." |& tee -a $an_log_file 
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DWpackages_n.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DWpackages.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_Foundation.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_Foundation_arith.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_Foundation_comp.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_Foundation_comp_arith.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DWmath.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_dp_functions_syn.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dware $dw_lib_src/DW_dp_functions_arith_syn.vhd.e >>& $an_log_file


        ## The dw01 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw01/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw01/src

        echo "#### Analyzing dw01 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_components.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_decode_en.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_csa.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_decode.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_dec.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_inc.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_incdec.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_cmp2.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_cmp6.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_add.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_addsub.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_sub.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_satrnd.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_absval.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_ash.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_binenc.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_prienc.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_bsh.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_mux_any.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_cmp_dx.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_addsub_dx.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_shifter.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_bin2gray.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_gray2bin.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_inc_gray.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_norm.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_norm_rnd.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lod.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lzd.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_rash.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_rbsh.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lbsh.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_sla.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_sra.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lsd.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_thermdec.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_pricod.vhd >>& $an_log_file

        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_decode_en_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_XOR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_XOR_sk.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_OR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_OR_sk.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_ANDOR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_ANDOR_sk.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_AND.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PREFIX_AND_sk.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PRIORITY_CODER.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_PRIORITY_CODER_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_or_tree.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_or_tree_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_and_tree.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_and_tree_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_inc.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_incdec.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_dec.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_ne.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_ne_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_eq.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_eq_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_bit_order.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_bit_order_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lzod.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lzod_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_csa_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_decode_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_satrnd_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_ash_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_binenc_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_prienc_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_bsh_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_mux_any_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_cmp_dx_fpga.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_addsub_dx_fpga.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_shifter_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_bin2gray_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_gray2bin_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_inc_gray_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_norm_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_norm_rnd_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lod_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lzd_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_rash_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_rbsh_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lbsh_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_sla_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_sra_mx2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_lsd_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_thermdec_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_pricod_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_inc_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_incdec_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW_dec_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_dec_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_inc_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_incdec_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_cmp2_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_cmp6_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_add_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_addsub_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_sub_verif.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_lib_src/DW01_absval_verif.vhd.e >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw01 $dw_lib_src/DW_minmax__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw01 $dw_lib_src/DW_lza__rtl.v.e >>& $an_log_file

        ## dw01 minPower content
        if ($minpwrlib != 0) then
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_mp_lib_src/DWsc_opiso_vh.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw01 $dw_mp_lib_src/DWsc_opiso_vh_noop.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw01 $dw_mp_lib_src/DWsc_opiso_ve__noop.v.e >>& $an_log_file
        endif



        ## The dw02 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw02/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw02/src

        echo "#### Analyzing dw02 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_components.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_tree.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_sum.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mac.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_2_stage.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_3_stage.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_4_stage.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_5_stage.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_6_stage.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_square.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_sat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_mult_pipe.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt_pipe.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_prod_sum_pipe.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_inv_sqrt.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt_rem.vhd >>& $an_log_file

        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_booth.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_bthenc.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_mtree.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_bthenc_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_booth_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_mtree_wall.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_tree_wallace.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_sum_wallace.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_fpga.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mac_fpga.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_2_stage_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_3_stage_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_4_stage_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_5_stage_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW02_mult_6_stage_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_square_fpga.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_tc.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_tc_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_uns.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_uns_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_sat_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_inv_sqrt_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt_rem_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_pipe.vhd >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW02_multp__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_mult_tc__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_mult_uns__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW02_prod_sum__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW02_prod_sum1__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_squarep__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_mult_dx__fpga.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_flt2i__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_i2flt__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_addsub__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_add__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_sub__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_mult__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_div__str.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_cmp__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_recip__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_ifp_conv__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_ifp_fp_conv__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_ifp_addsub__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_FP_ALIGN__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_ifp_mult__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_sum3__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_sum4__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_dp2__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_dp3__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_dp4__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_invsqrt__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_log2__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_log2__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_exp2__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_exp2__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_exp__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_ln__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_ln__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_square__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_div_seq__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_sqrt__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_mac__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_sincos__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_lib_src/DW_fp_sincos__rtl.v.e >>& $an_log_file

        ## dw02 minPower content
        if ($minpwrlib == 0) then
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_div_pipe_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_mult_pipe_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_sqrt_pipe_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_lib_src/DW_prod_sum_pipe_str.vhd.e >>& $an_log_file
        else
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_mp_lib_src/DW_div_pipe_lpwr.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_mp_lib_src/DW_mult_pipe_lpwr.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_mp_lib_src/DW_sqrt_pipe_lpwr.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw02 $dw_mp_lib_src/DW_prod_sum_pipe_lpwr.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_addsub_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_add_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_sub_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_mult_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_mac_DG__str.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_cmp_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_sum3_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_div_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_fp_recip_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_lp_multifunc__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_lp_fp_multifunc__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_lp_multifunc_DG__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw02 $dw_mp_lib_src/DW_lp_fp_multifunc_DG__rtl.v.e >>& $an_log_file
        endif



        ## The dw03 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw03/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw03/src

        echo "#### Analyzing dw03 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_components.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_decode.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_scnto.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_dcnto.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_updn.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_load.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_scnto.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_dcnto.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_pipe_reg.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_reg_s_pl.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_shftreg.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_dpll_sd.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_stackctl.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_updn_ctr.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s1_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s1_df.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s2dr_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s2_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s2_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_gray.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_mult_seq.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_div_seq.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_sqrt_seq.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fir.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fir_seq.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_iir_dc.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_iir_sc.vhd >>& $an_log_file

        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s1r.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_pipe_reg.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_dcnto.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_scnto.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_smod.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_IN_WRAPPER.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_OUT_WRAPPER.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIFOCTL_IF.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_S2SF_INWRP.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_S2SF_OUTWRP.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_AU.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_CSR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_CTL.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_DSR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_pipe_reg_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_pipe_reg_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s1r_cla.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_decode_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_IN_WRAPPER_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_OUT_WRAPPER_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s1_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s1_df_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_dpll_sd_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_stackctl_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_updn_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_load_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_scnto_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_lfsr_dcnto_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_shftreg_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_reg_s_pl_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIFOCTL_IF_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s2_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_S2SF_INWRP_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_ASYMFIFOCTL_S2SF_OUTWRP_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_s2_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_mult_seq_cpa.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_div_seq_cpa.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_sqrt_seq_cpa.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fir_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_AU_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_CSR_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_CTL_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_FIR_SEQ_DSR_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fir_seq_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_iir_dc_mult.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s2dr_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_updn_ctr_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_iir_sc_mult.vhd.e >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_data_sync_1c__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_pulse_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_pulseack_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_data_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_data_sync_na__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_reset_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_stream_sync__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_asymdata_inbuf__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_asymdata_outbuf__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DWsc_fifoctl_sif__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_data_qsync_lh__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_data_qsync_hl__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_dct_2d__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_pl_reg__rtl.v.e >>& $an_log_file

        ## dw03 minPower content
        if ($minpwrlib == 0) then
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_dcnto_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW03_bictr_scnto_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_dcnto_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_scnto_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_smod_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_cntr_gray_str.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_asymfifoctl_2c_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_fifoctl_2c_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s1_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_fifoctl_s1_sf__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_gray_sync__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DW_piped_mac__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DWsc_fifoctl_dif__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_lib_src/DWsc_fifoctl_s1_df__rtl.v.e >>& $an_log_file
        else
          $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_mp_lib_src/DW_cntr_gray_lpwr.vhd.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW03_bictr_dcnto__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW03_bictr_scnto__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_asymfifoctl_2c_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_cntr_dcnto__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_cntr_scnto__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_cntr_smod__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_fifoctl_2c_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_fifoctl_s1_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_fifoctl_s1_sf__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_gray_sync__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_piped_mac__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DWsc_fifoctl_dif__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DWsc_fifoctl_s1_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DWsc_fifoctl_s1_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_fifoctl_1c_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_pipe_mgr__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_mult__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_prod_sum__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_div__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_sqrt__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_fp_add__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_fp_sum3__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_fp_div__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_fp_mult__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_piped_fp_recip__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_cntr_updn_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DWsc_lp_cntr_updn_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DW_lp_cntr_up_df__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw03 $dw_mp_lib_src/DWsc_lp_cntr_up_df__rtl.v.e >>& $an_log_file
        endif


	## if the cpa2 option for DW_div_seq is set, then analyze that
	#  alternate architecture after the former cpa architecture
	#  so cpa2 will become the default bound architecture
	#
	if ($include_cpa2_div_seq != 0) then
	  $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_div_seq_cpa2.vhd.e >>& $an_log_file
	endif


	## if the vsum option for DW_iir_sc is set, then analyze that
	#  alternate architecture after the former mult architecture
	#  so vsum will become the default bound architecture
	#
	if ($include_vsum_iir_sc != 0) then
	  $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw03 $dw_lib_src/DW_iir_sc_vsum.vhd.e >>& $an_log_file
	endif



        ## The dw04 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw04/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw04/src

        echo "#### Analyzing dw04 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW04_components.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_1.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_2.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_3.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_4.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_5.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_7.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_8.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_9.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_10.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_wc_d1_s.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_wc_s1_s.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_s.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_p.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW04_par_gen.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW04_shad_reg.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap_uc.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_control_force.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_Z_control_force.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_observ_dgen.vhd >>& $an_log_file

        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_BYPASS.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_CAPTURE.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_CAPUP.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_IDREG.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_IDREGUC.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_INSTRREG.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_INSTRREGID.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_TAPFSM.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap_uc2.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_spm.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_spm_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_s_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_crc_p_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW04_par_gen_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW04_shad_reg_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_CAPTURE_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_CAPUP_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_1_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_2_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_3_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_4_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_5_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_7_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_8_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_9_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_bc_10_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_wc_d1_s_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_wc_s1_s_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_BYPASS_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_IDREG_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_IDREGUC_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_INSTRREG_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_INSTRREGID_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_TAPFSM_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap_uc_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_tap_uc2_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_control_force_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_Z_control_force_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw04 $dw_lib_src/DW_observ_dgen_str.vhd.e >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_lib_src/DW_8b10b_unbal__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_lib_src/DW_ecc__rtl.v.e >>& $an_log_file

        ## dw04 minPower content
        if ($minpwrlib == 0) then
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_lib_src/DW_8b10b_dec__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_lib_src/DW_8b10b_enc__rtl.v.e >>& $an_log_file
        else
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_mp_lib_src/DW_8b10b_dec__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_mp_lib_src/DW_8b10b_enc__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw04 $dw_mp_lib_src/DW_lp_piped_ecc__rtl.v.e >>& $an_log_file
        endif



        ## The dw05 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw05/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw05/src

        echo "#### Analyzing dw05 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw05 $dw_lib_src/DW05_components.vhd >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_lib_src/DW_arb_2t__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_lib_src/DW_arb_fcfs__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_lib_src/DW_arb_rr__rtl.v.e >>& $an_log_file

        ## dw05 minPower content
        if ($minpwrlib == 0) then
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_lib_src/DW_arb_dp__rtl.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_lib_src/DW_arb_sp__rtl.v.e >>& $an_log_file
        else
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_mp_lib_src/DW_arb_dp__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw05 $dw_mp_lib_src/DW_arb_sp__lpwr.v.e >>& $an_log_file
        endif



        ## The dw06 library
        #
        set dw_lib_src = $SYNOPSYS/dw/dw06/src
        set dw_mp_lib_src = $SYNOPSYS/minpower/dw06/src

        echo "#### Analyzing dw06 library ..." | tee -a $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW06_components.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_rw_s_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_rw_a_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_s_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_a_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_s_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_a_lat.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s1_df.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s1_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s2_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s1_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s1_df.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s2_sf.vhd >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_stack.vhd >>& $an_log_file

        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_RW_A_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_RW_S_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_2R_W_A_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_2R_W_S_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_R_W_A_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_R_W_S_LAT.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_RW_A_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_RW_S_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_2R_W_A_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_2R_W_S_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_R_W_A_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_MEM_R_W_S_LAT_STR.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_rw_s_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_rw_a_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_s_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_a_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_s_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_a_lat_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s1_df_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s1_sf_rtl.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_fifo_s2_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s1_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s1_df_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_asymfifo_s2_sf_str.vhd.e >>& $an_log_file
        $VCS_HOME/bin/vhdlan -kdb -full64 $vhd_an_opt -work dw06 $dw_lib_src/DW_stack_str.vhd.e >>& $an_log_file

        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_rw_s_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_s_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_s_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_rw_a_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_a_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_2r_w_a_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_r_w_2c_dff__rtl.v.e >>& $an_log_file
        $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_ram_2r_2w_s_dff__rtl.v.e >>& $an_log_file

        ## dw06 minPower content
        if ($minpwrlib == 0) then
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_lib_src/DW_fifo_2c_df__rtl.v.e >>& $an_log_file
        else
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_mp_lib_src/DW_fifo_2c_df__lpwr.v.e >>& $an_log_file
          $VCS_HOME/bin/vlogan +define+_DWBB_MN_LDM_LPMS_ESU_+ -kdb -full64 $ver_an_opt -work dw06 $dw_mp_lib_src/DW_lp_fifo_1c_df__rtl.v.e >>& $an_log_file
        endif


	set err_count = `egrep -i '^Error|errors: [1-9]' $an_log_file | wc -l`
	set wrn_count = `egrep -i '^Warning|warnings: [1-9]' $an_log_file | wc -l`

	echo "" | tee -a $an_log_file
	echo "$pgm : $err_count errors during analysis." | tee -a $an_log_file
	echo "$pgm : $wrn_count warnings during analysis." | tee -a $an_log_file
	echo "" | tee -a $an_log_file

        echo "#### Analysis complete" | tee -a $an_log_file

	echo " "
	echo " "
	echo "The build log file is $an_log_file."

	echo "Done." |& tee -a $an_log_file

	exit 0

    else
      echo "$pgm : Error: Environment variable, SYNOPSYS, is not defined."
      echo ""
      echo "    Please define the environment variable SYNOPSYS as the"
      echo "    path to the Design Compiler software from which DesignWare
      echo "    Building Block IP is to be accessed."
      exit 3
    endif

  else
    echo "$pgm : Error: VCS-MX does not appear to be porperly setup since"
    echo "      "vhdlan" command is not present in the directory, \$VCS_HOME/bin."
    exit 2
  endif
else
  echo "$pgm : Error: VCS-MX needs to be setup before running this script, but"
  echo "    the envrionmet variable, VCS_HOME, is not defined.  Please"
  echo "    set up the VCS-MX tool and rerun this script"
  echo 1
endif


interr:
   echo "" |& tee -a $an_log_file
   echo "Abort (interrupted by user)." |& tee -a $an_log_file
   echo "" |& tee -a $an_log_file
   exit 5


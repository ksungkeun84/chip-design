#! /bin/csh -f
 
###############################################################################
#                  Copyright (c) 1990-2000 by Synopsys, Inc.
#                            ALL RIGHTS RESERVED
#         This program is proprietary and confidential information
#         of  Synopsys, Inc. and may be used and disclosed only as
#         authorized in a  license agreement controlling such use
#         and disclosure.
###############################################################################
# WARNING: This script is designed for re-analyzing DesignWare Building Blocks
# version O-2018.06-DWBB_201806.3 with VCS-MX and other Synopsys simulators only.
# USING THIS SCRIPT FOR OTHER VERSIONS OR OTHER PURPOSES MAY CAUSE ERROR.
###############################################################################
# Script generated in /remote/sweifs/PE/products/spf/o2018.06_sp_dev/clientstore/spf_o2018.06_sp_dev_build2
# Script generation date: Thu Oct 18 21:00:43 PDT 2018
###############################################################################
 
onintr interr
 
set dwf_make_version = O-2018.06
 
set install_gtech_flag = 0 ## default: not copy gtech until DWF/SIM gtech merge
set an_encrypted_flag = 1 ## default: analyze encrypted files
set interp_flag = 0   ## VCS-MX interpret 
set full64 = "" ## default to 32bit
set sixtyfour = ""

if ( $#argv >= 1 ) then
   foreach option ($argv)
     switch ($option)
     #case -nc:
     #  set copy_flag = 0 ## not copy source files
     #  breaksw
     case -gtech:
       set install_gtech_flag = 1
       breaksw
     case -encrypted:
       set an_encrypted_flag = 0 ## not analyze encrypted files
       breaksw
     case -i:
       set interp_flag = 1 ## Interpret
       breaksw
     case -full64:
       set full64 = "-full64"
       set sixtyfour = "64"
       setenv USE_FULL_64VCS 1
       breaksw
     default:
       breaksw
     endsw
   end
endif 

set abso_path = `dirname $0`
cd $abso_path
if ( ! -f verify_SYNSIMARCH ) then
   echo "Can not find [verify_SYNSIMARCH]."
   exit 1
endif
./verify_SYNSIMARCH junk.$$ sim
if( $status > 0 ) then
   echo "Re-analyze is aborted."
   rm -f junk.$$
   exit 1
endif
source junk.$$
rm -f junk.$$

set SIM_CMD = "$EXECUTABLE_BIN_4_EST" 
set an_log = ${VCS_HOME}/dw_analyze_sim${sixtyfour}.log
if (-e ${an_log}) rm -fr $an_log

echo "$0 : Installing DesignWare Building Blocks to $VCS_HOME..." |& tee -a $an_log
echo "Ran on " >>& $an_log
date >>& $an_log

setenv ARCH `$VCS_HOME/bin/vcs -platform $full64`

set Date = `date '+%Y-%b-%d-%T'`
echo "" |& tee -a $an_log
set FLAG = "-nc -event -w "
if ( $interp_flag ) set FLAG = "-interp $FLAG"
set SIM = "$SIM_CMD $full64 $FLAG"

set dwf_in_sim_version = "NONE"
set dwf_in_syn_v_str  = `cat ${VCS_HOME}/dw/version`
set dwf_in_syn_version  = `echo ${dwf_in_syn_v_str} | sed -e 's/\(.*\)-DW[FB]*_\(.*\)/\1/'`

if ( "$dwf_in_syn_version" !~ "$dwf_make_version" ) then
   echo "Error: This script ($0) was designed for re-analyzing DesignWare " |& tee -a $an_log
   echo "DWBB version $dwf_make_version.  But it is used for the source files" |& tee -a $an_log
   echo "on VCS_HOME tree version $dwf_in_syn_version. Please use the reanalyze" |& tee -a $an_log
   echo "script in VCS_HOME tree $dwf_in_syn_version. Bye now." |& tee -a $an_log
   exit 1
endif

if ( -e ${VCS_HOME}/dw/version ) then
  set dwf_in_sim_v_str  = `cat ${VCS_HOME}/dw/version`
  set dwf_in_sim_version  = `echo ${dwf_in_sim_v_str} | sed -e 's/.*-DWF/DWF/'`
endif

if ( "$dwf_in_syn_version" == "$dwf_in_sim_version" ) then
   echo "DesignWare Building Blocks source files are found previously installed in VCS_HOME($VCS_HOME) directory." |& tee -a $an_log
endif

echo "" |& tee -a $an_log
echo "Start Re-analyzing files for VCS-MX ....." |& tee -a $an_log
echo "" |& tee -a $an_log
echo "Building packages ..." |& tee -a $an_log


cd $VCS_HOME/packages/dware/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dware/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dware/lib
endif
echo "Building dware ..." |& tee -a $an_log 
$SIM dware \
$VCS_HOME/packages/dware/src/DWpackages_n.vhd  \
$VCS_HOME/packages/dware/src/DWpackages.vhd  \
$VCS_HOME/packages/dware/src/DW_Foundation.vhd  \
$VCS_HOME/packages/dware/src/DW_Foundation_arith.vhd  \
$VCS_HOME/packages/dware/src/DW_Foundation_comp.vhd  \
$VCS_HOME/packages/dware/src/DW_Foundation_comp_arith.vhd  \
$VCS_HOME/packages/dware/src/DWmath.vhd  \
|& tee -a $an_log
$SIM dware \
$VCS_HOME/packages/dware/src/DW_dp_functions_sim.vhd  \
$VCS_HOME/packages/dware/src/DW_dp_functions_arith_sim.vhd  \
|& tee -a $an_log

if ($install_gtech_flag == 1) then 
  ## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
  if ( ! -e $VCS_HOME/$ARCH/packages/gtech/lib ) then
     mkdir -p $VCS_HOME/$ARCH/packages/gtech/lib
  endif
  cd $VCS_HOME/packages/gtech/src
echo "Building gtech ..." |& tee -a $an_log 
  $SIM gtech \
  $VCS_HOME/packages/gtech/src/GTECH_components.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ADD_AB.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ADD_ABC.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND5.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND8.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND_NOT.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AO21.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AO22.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI21.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI22.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI222.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI2N2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_BUF.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD14.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD18.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD1S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD24.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD28.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD2S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD34.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD38.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD3S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD44.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD48.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD4S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK1S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK2S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK3S.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_INBUF.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_INOUTBUF.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO0_EN0.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO1_EN0.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO0_EN1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO1_EN1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISOLATCH_EN0.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISOLATCH_EN1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD2_1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD4_1.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LSR0.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MAJ23.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUXI2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX8.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND5.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND8.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR5.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR8.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOT.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OA21.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OA22.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI21.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI22.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI2N2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ONE.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR5.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR8.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR_NOT.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OUTBUF.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_TBUF.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR2.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR3.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR4.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ZERO.vhd \
  |& tee -a $an_log
  $SIM gtech \
  $VCS_HOME/packages/gtech/src/GTECH_ADD_AB_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ADD_ABC_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND5_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND8_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AND_NOT_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AO21_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AO22_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI21_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI22_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI222_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_AOI2N2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_BUF_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD14_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD18_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD1S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD24_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD28_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD2S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD34_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD38_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD3S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD44_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD48_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FD4S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK1S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK2S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_FJK3S_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_INBUF_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_INOUTBUF_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO0_EN0_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO1_EN0_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO0_EN1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISO1_EN1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISOLATCH_EN0_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ISOLATCH_EN1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD2_1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LD4_1_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_LSR0_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MAJ23_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUXI2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_MUX8_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND5_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NAND8_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR5_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOR8_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_NOT_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OA21_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OA22_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI21_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI22_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OAI2N2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ONE_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR5_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR8_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OR_NOT_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_OUTBUF_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_TBUF_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR2_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR3_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XOR4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_XNOR4_sim.vhd \
  $VCS_HOME/packages/gtech/src/GTECH_ZERO_sim.vhd \
  |& tee -a $an_log
endif

cd $VCS_HOME/dw/dw01/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw01/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw01/lib
endif
echo "Building dw01 ..." |& tee -a $an_log 
$SIM dw01 \
$VCS_HOME/dw/dw01/src/DW01_components.vhd \
$VCS_HOME/dw/dw01/src/DW_decode_en.vhd \
$VCS_HOME/dw/dw01/src/DW01_csa.vhd \
$VCS_HOME/dw/dw01/src/DW01_decode.vhd \
$VCS_HOME/dw/dw01/src/DW01_dec.vhd \
$VCS_HOME/dw/dw01/src/DW01_inc.vhd \
$VCS_HOME/dw/dw01/src/DW01_incdec.vhd \
$VCS_HOME/dw/dw01/src/DW01_cmp2.vhd \
$VCS_HOME/dw/dw01/src/DW01_cmp6.vhd \
$VCS_HOME/dw/dw01/src/DW01_add.vhd \
$VCS_HOME/dw/dw01/src/DW01_addsub.vhd \
$VCS_HOME/dw/dw01/src/DW01_sub.vhd \
$VCS_HOME/dw/dw01/src/DW01_satrnd.vhd \
$VCS_HOME/dw/dw01/src/DW01_absval.vhd \
$VCS_HOME/dw/dw01/src/DW01_ash.vhd \
$VCS_HOME/dw/dw01/src/DW01_binenc.vhd \
$VCS_HOME/dw/dw01/src/DW01_prienc.vhd \
$VCS_HOME/dw/dw01/src/DW01_bsh.vhd \
$VCS_HOME/dw/dw01/src/DW01_mux_any.vhd \
$VCS_HOME/dw/dw01/src/DW_cmp_dx.vhd \
$VCS_HOME/dw/dw01/src/DW_addsub_dx.vhd \
$VCS_HOME/dw/dw01/src/DW_shifter.vhd \
$VCS_HOME/dw/dw01/src/DW_minmax.vhd \
$VCS_HOME/dw/dw01/src/DW_bin2gray.vhd \
$VCS_HOME/dw/dw01/src/DW_gray2bin.vhd \
$VCS_HOME/dw/dw01/src/DW_inc_gray.vhd \
$VCS_HOME/dw/dw01/src/DW_norm.vhd \
$VCS_HOME/dw/dw01/src/DW_norm_rnd.vhd \
$VCS_HOME/dw/dw01/src/DW_lod.vhd \
$VCS_HOME/dw/dw01/src/DW_lzd.vhd \
$VCS_HOME/dw/dw01/src/DW_rash.vhd \
$VCS_HOME/dw/dw01/src/DW_rbsh.vhd \
$VCS_HOME/dw/dw01/src/DW_lbsh.vhd \
$VCS_HOME/dw/dw01/src/DW_sla.vhd \
$VCS_HOME/dw/dw01/src/DW_sra.vhd \
$VCS_HOME/dw/dw01/src/DW_lsd.vhd \
$VCS_HOME/dw/dw01/src/DW_thermdec.vhd \
$VCS_HOME/dw/dw01/src/DW_pricod.vhd \
$VCS_HOME/dw/dw01/src/DW_lza.vhd \
|& tee -a $an_log

if ($an_encrypted_flag == 1) then
  $SIM dw01 \
  $VCS_HOME/dw/dw01/src/DW01_ADD_AB.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ADD_AB1.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ADD_ABC.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AND2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AND_NOT.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AO21.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_CL_DEC.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_DEC.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_SUM.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_MUX.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_MMUX.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_NAND2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_NOT.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_OR2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_OR_NOT.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_SUB_ABC.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_XOR2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_LE_REG.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_NODE.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_decode_DG.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_XOR.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_OR.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_ANDOR.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_AND.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PRIORITY_CODER.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_or_tree.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_and_tree.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_inc.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_incdec.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_dec.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_ne.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_eq.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_bit_order.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax4.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lzod.vhd.e \
  $VCS_HOME/dw/dw01/src/DWsc_opiso_ve.vhd.e \
  $VCS_HOME/dw/dw01/src/DWsc_opiso_vh.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_decode_en_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_inc_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_incdec_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_dec_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_decode_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_dec_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_inc_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_incdec_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_cmp2_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_cmp6_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_add_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_addsub_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_sub_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_absval_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ash_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_bsh_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_rash_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_rbsh_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lbsh_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_thermdec_verif.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ADD_AB_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ADD_AB1_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ADD_ABC_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AND2_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AND_NOT_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_AO21_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_CL_DEC_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_DEC_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_SUM_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_MUX_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_MMUX_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_NAND2_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_NOT_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_OR2_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_OR_NOT_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_SUB_ABC_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_XOR2_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_LE_REG_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_GP_NODE_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_XOR_sk.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_OR_sk.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_ANDOR_sk.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_AND_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PREFIX_AND_sk.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PRIORITY_CODER_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_PRIORITY_CODER_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_or_tree_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_and_tree_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_ne_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_eq_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_bit_order_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax4_clas.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax2_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lzod_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lzod_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_csa_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_decode_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_dec_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_dec_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_inc_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_inc_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_incdec_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_incdec_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_cmp2_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_cmp6_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_add_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_add_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_addsub_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_addsub_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_sub_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_sub_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_satrnd_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_absval_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_absval_clf.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_absval_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_ash_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_binenc_aot.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_binenc_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_binenc_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_prienc_aot.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_prienc_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_prienc_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_mux_any_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW01_mux_any_fmx.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_cmp_dx_bk.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_cmp_dx_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_addsub_dx_csm.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_addsub_dx_rpcs.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_addsub_dx_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_shifter_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_shifter_mx2i.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_shifter_mx4.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_shifter_mx8.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_minmax_clas.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_bin2gray_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_gray2bin_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_gray2bin_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_inc_gray_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_inc_gray_rpl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_norm_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_norm_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_norm_rnd_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_norm_rnd_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lod_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lod_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lzd_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lzd_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_rash_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_rbsh_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lbsh_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_sla_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_sra_mx2.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_lsd_str.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_pricod_cla.vhd.e \
  $VCS_HOME/dw/dw01/src/DW_pricod_rtl.vhd.e \
  $VCS_HOME/dw/dw01/src/DWsc_opiso_vh_noop.vhd.e \
  $VCS_HOME/dw/dw01/src/DWsc_opiso_vh_andgate.vhd.e \
  $VCS_HOME/dw/dw01/src/DWsc_opiso_vh_orgate.vhd.e \
  |& tee -a $an_log
endif

$SIM dw01 \
$VCS_HOME/dw/dw01/src/DW_decode_en_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_csa_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_decode_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_dec_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_inc_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_incdec_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_cmp2_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_cmp6_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_add_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_addsub_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_sub_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_satrnd_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_absval_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_ash_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_binenc_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_prienc_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_bsh_sim.vhd \
$VCS_HOME/dw/dw01/src/DW01_mux_any_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_cmp_dx_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_addsub_dx_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_shifter_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_minmax_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_bin2gray_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_gray2bin_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_inc_gray_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_norm_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_norm_rnd_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_lod_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_lzd_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_rash_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_rbsh_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_lbsh_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_sla_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_sra_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_lsd_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_thermdec_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_pricod_sim.vhd \
$VCS_HOME/dw/dw01/src/DW_lza_sim.vhd \
|& tee -a $an_log

cd $VCS_HOME/dw/dw02/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw02/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw02/lib
endif
echo "Building dw02 ..." |& tee -a $an_log 
$SIM dw02 \
$VCS_HOME/dw/dw02/src/DW02_components.vhd \
$VCS_HOME/dw/dw02/src/DW02_tree.vhd \
$VCS_HOME/dw/dw02/src/DW02_multp.vhd \
$VCS_HOME/dw/dw02/src/DW02_sum.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult.vhd \
$VCS_HOME/dw/dw02/src/DW02_mac.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_2_stage.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_3_stage.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_4_stage.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_5_stage.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_6_stage.vhd \
$VCS_HOME/dw/dw02/src/DW02_prod_sum.vhd \
$VCS_HOME/dw/dw02/src/DW02_prod_sum1.vhd \
$VCS_HOME/dw/dw02/src/DW_squarep.vhd \
$VCS_HOME/dw/dw02/src/DW_square.vhd \
$VCS_HOME/dw/dw02/src/DW_mult_dx.vhd \
$VCS_HOME/dw/dw02/src/DW_div.vhd \
$VCS_HOME/dw/dw02/src/DW_div_sat.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt.vhd \
$VCS_HOME/dw/dw02/src/DW_mult_pipe.vhd \
$VCS_HOME/dw/dw02/src/DW_div_pipe.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt_pipe.vhd \
$VCS_HOME/dw/dw02/src/DW_prod_sum_pipe.vhd \
$VCS_HOME/dw/dw02/src/DW_inv_sqrt.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_flt2i.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_i2flt.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_addsub.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_add.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sub.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mult.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_cmp.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_recip.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_ifp_conv.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_fp_conv.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_addsub.vhd \
$VCS_HOME/dw/dw02/src/DW_FP_ALIGN.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_mult.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum3.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum4.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp2.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp3.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp4.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_invsqrt.vhd \
$VCS_HOME/dw/dw02/src/DW_log2.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_log2.vhd \
$VCS_HOME/dw/dw02/src/DW_exp2.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_exp2.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_exp.vhd \
$VCS_HOME/dw/dw02/src/DW_ln.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_ln.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_addsub_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_add_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sub_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mult_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mac_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_cmp_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum3_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_recip_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_square.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div_seq.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt_rem.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sqrt.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mac.vhd \
$VCS_HOME/dw/dw02/src/DW_sincos.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sincos.vhd \
$VCS_HOME/dw/dw02/src/DW_lp_multifunc.vhd \
$VCS_HOME/dw/dw02/src/DW_lp_fp_multifunc.vhd \
$VCS_HOME/dw/dw02/src/DW_lp_multifunc_DG.vhd \
$VCS_HOME/dw/dw02/src/DW_lp_fp_multifunc_DG.vhd \
|& tee -a $an_log

if ($an_encrypted_flag == 1) then
  $SIM dw02 \
  $VCS_HOME/dw/dw02/src/DW02_booth.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_bthenc.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mtree.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_MULTP_SC.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_uns.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_tc.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_DG.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_sum_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_DG_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mac_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_prod_sum_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_prod_sum1_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_FP_ALIGN_verif.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_bthenc_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_booth_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mtree_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_tree_wallace.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_MULTP_SC_nbw.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_MULTP_SC_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_multp_nbw.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_multp_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_sum_csa.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_sum_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_sum_wallace.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_csa.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_2_stage_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_3_stage_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_4_stage_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_5_stage_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW02_mult_6_stage_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_squarep_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_square_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mult_dx_wall.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_mlt.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_mlt.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_mlt.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_mlt.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_mlt.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_sat_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_sat_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_sat_cla3.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_uns_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_uns_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_tc_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_tc_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mult_pipe_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_pipe_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_pipe_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_prod_sum_pipe_str.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_inv_sqrt_rtl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_rem_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_DG_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_DG_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_DG_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_DG_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_DG_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_tc_DG_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_DG_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_DG_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_uns_DG_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_DG_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_DG_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_tc_DG_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_DG_cla.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_DG_rpl.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mod_uns_DG_cla2.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_mult_pipe_lpwr.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_div_pipe_lpwr.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_sqrt_pipe_lpwr.vhd.e \
  $VCS_HOME/dw/dw02/src/DW_prod_sum_pipe_lpwr.vhd.e \
  |& tee -a $an_log
endif

$SIM dw02 \
$VCS_HOME/dw/dw02/src/DW02_sum_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mac_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_2_stage_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_3_stage_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_4_stage_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_5_stage_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_mult_6_stage_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_prod_sum_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_prod_sum1_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_square_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_mult_dx_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_div_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_div_sat_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_mult_pipe_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_div_pipe_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt_pipe_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_prod_sum_pipe_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_inv_sqrt_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_flt2i_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_i2flt_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_addsub_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_add_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sub_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mult_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_cmp_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_recip_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_ifp_conv_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_fp_conv_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_addsub_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_FP_ALIGN_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_ifp_mult_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum3_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum4_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp2_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp3_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_dp4_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_invsqrt_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_log2_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_log2_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_exp2_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_exp2_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_exp_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_ln_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_ln_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_addsub_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_add_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sub_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mult_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mac_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_cmp_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sum3_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_recip_DG_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_square_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_div_seq_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_sqrt_rem_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sqrt_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_mac_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_sincos_sim.vhd \
$VCS_HOME/dw/dw02/src/DW_fp_sincos_sim.vhd \
$VCS_HOME/dw/dw02/src/DW02_tree_sim_vcsmx.vhd.e \
$VCS_HOME/dw/dw02/src/DW02_multp_sim_vcsmx.vhd.e \
$VCS_HOME/dw/dw02/src/DW_squarep_sim_vcsmx.vhd.e \
|& tee -a $an_log

cd $VCS_HOME/dw/dw03/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw03/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw03/lib
endif
echo "Building dw03 ..." |& tee -a $an_log 
$SIM dw03 \
$VCS_HOME/dw/dw03/src/DW03_components.vhd \
$VCS_HOME/dw/dw03/src/DW03_bictr_decode.vhd \
$VCS_HOME/dw/dw03/src/DW03_bictr_scnto.vhd \
$VCS_HOME/dw/dw03/src/DW03_bictr_dcnto.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s1_df.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_updn.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_load.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_scnto.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_dcnto.vhd \
$VCS_HOME/dw/dw03/src/DW03_pipe_reg.vhd \
$VCS_HOME/dw/dw03/src/DW03_reg_s_pl.vhd \
$VCS_HOME/dw/dw03/src/DW03_shftreg.vhd \
$VCS_HOME/dw/dw03/src/DW_dpll_sd.vhd \
$VCS_HOME/dw/dw03/src/DW_stackctl.vhd \
$VCS_HOME/dw/dw03/src/DW03_updn_ctr.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_sf.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_df.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s2dr_sf.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s2_sf.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s2_sf.vhd \
$VCS_HOME/dw/dw03/src/DW_cntr_gray.vhd \
$VCS_HOME/dw/dw03/src/DW_mult_seq.vhd \
$VCS_HOME/dw/dw03/src/DW_div_seq.vhd \
$VCS_HOME/dw/dw03/src/DW_sqrt_seq.vhd \
$VCS_HOME/dw/dw03/src/DW_fir.vhd \
$VCS_HOME/dw/dw03/src/DW_fir_seq.vhd \
$VCS_HOME/dw/dw03/src/DW_iir_dc.vhd \
$VCS_HOME/dw/dw03/src/DW_iir_sc.vhd \
$VCS_HOME/dw/dw03/src/DW_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync_1c.vhd \
$VCS_HOME/dw/dw03/src/DW_pulse_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_pulseack_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync_na.vhd \
$VCS_HOME/dw/dw03/src/DW_gray_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_reset_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_stream_sync.vhd \
$VCS_HOME/dw/dw03/src/DW_piped_mac.vhd \
$VCS_HOME/dw/dw03/src/DW_asymdata_inbuf.vhd \
$VCS_HOME/dw/dw03/src/DW_asymdata_outbuf.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_2c_df.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_2c_df.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_fifoctl_1c_df.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_pipe_mgr.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_mult.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_prod_sum.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s1_sf.vhd \
$VCS_HOME/dw/dw03/src/DW_data_qsync_lh.vhd \
$VCS_HOME/dw/dw03/src/DW_data_qsync_hl.vhd \
$VCS_HOME/dw/dw03/src/DW_dct_2d.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_div.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_sqrt.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_add.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_sum3.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_div.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_mult.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_recip.vhd \
$VCS_HOME/dw/dw03/src/DW_pl_reg.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_cntr_updn_df.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_cntr_up_df.vhd \
|& tee -a $an_log

if ($an_encrypted_flag == 1) then
  $SIM dw03 \
  $VCS_HOME/dw/dw03/src/DW_fifoctl_s1r.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_pipe_reg.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_dcnto.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_scnto.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_smod.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_IN_WRAPPER.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_OUT_WRAPPER.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIFOCTL_IF.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_S2SF_INWRP.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_S2SF_OUTWRP.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_AU.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_CSR.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_CTL.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_DSR.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_pipe_reg_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_pipe_reg_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fifoctl_s1r_rpl.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fifoctl_s1r_cla.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_bictr_decode_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_bictr_scnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_bictr_dcnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_dcnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_scnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_smod_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_IN_WRAPPER_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_OUT_WRAPPER_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_sf_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_df_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_dpll_sd_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_stackctl_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_lfsr_updn_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_lfsr_load_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_lfsr_scnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_lfsr_dcnto_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_shftreg_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_reg_s_pl_mbstr.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_reg_s_pl_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIFOCTL_IF_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fifoctl_s2_sf_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_S2SF_INWRP_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_ASYMFIFOCTL_S2SF_OUTWRP_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_asymfifoctl_s2_sf_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_gray_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_mult_seq_cpa.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_div_seq_cpa.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_div_seq_cpa2.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_sqrt_seq_cpa.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fir_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_AU_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_CSR_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_CTL_rtl.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_FIR_SEQ_DSR_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fir_seq_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_iir_dc_mult.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_iir_sc_mult.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_iir_sc_vsum.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_fifoctl_s2dr_sf_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW03_updn_ctr_str.vhd.e \
  $VCS_HOME/dw/dw03/src/DW_cntr_gray_lpwr.vhd.e \
  |& tee -a $an_log
endif

$SIM dw03 \
$VCS_HOME/dw/dw03/src/DW_sync_sim_ms.vhd \
|& tee -a $an_log

$SIM dw03 \
$VCS_HOME/dw/dw03/src/DW03_bictr_decode_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_bictr_scnto_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_bictr_dcnto_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s1_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_updn_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_load_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_scnto_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_lfsr_dcnto_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_pipe_reg_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_reg_s_pl_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_shftreg_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_dpll_sd_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_stackctl_sim.vhd \
$VCS_HOME/dw/dw03/src/DW03_updn_ctr_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_sf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s1_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s2dr_sf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s2_sf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_s2_sf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_cntr_gray_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_mult_seq_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_div_seq_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_sqrt_seq_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fir_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fir_seq_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_iir_dc_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_iir_sc_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync_1c_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_pulse_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_pulseack_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_data_sync_na_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_gray_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_reset_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_stream_sync_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_piped_mac_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymdata_inbuf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymdata_outbuf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_2c_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_asymfifoctl_2c_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_fifoctl_1c_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_pipe_mgr_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_mult_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_prod_sum_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_fifoctl_s1_sf_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_data_qsync_lh_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_data_qsync_hl_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_dct_2d_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_div_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_sqrt_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_add_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_sum3_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_div_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_mult_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_piped_fp_recip_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_pl_reg_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_cntr_updn_df_sim.vhd \
$VCS_HOME/dw/dw03/src/DW_lp_cntr_up_df_sim.vhd \
|& tee -a $an_log

cd $VCS_HOME/dw/dw04/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw04/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw04/lib
endif
echo "Building dw04 ..." |& tee -a $an_log 
$SIM dw04 \
$VCS_HOME/dw/dw04/src/DW04_components.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_1.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_2.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_3.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_4.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_5.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_7.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_8.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_9.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_10.vhd \
$VCS_HOME/dw/dw04/src/DW_wc_d1_s.vhd \
$VCS_HOME/dw/dw04/src/DW_wc_s1_s.vhd \
$VCS_HOME/dw/dw04/src/DW_crc_s.vhd \
$VCS_HOME/dw/dw04/src/DW_crc_p.vhd \
$VCS_HOME/dw/dw04/src/DW_ecc.vhd \
$VCS_HOME/dw/dw04/src/DW04_par_gen.vhd \
$VCS_HOME/dw/dw04/src/DW04_shad_reg.vhd \
$VCS_HOME/dw/dw04/src/DW_tap.vhd \
$VCS_HOME/dw/dw04/src/DW_tap_uc.vhd \
$VCS_HOME/dw/dw04/src/DW_control_force.vhd \
$VCS_HOME/dw/dw04/src/DW_Z_control_force.vhd \
$VCS_HOME/dw/dw04/src/DW_observ_dgen.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_dec.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_enc.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_unbal.vhd \
$VCS_HOME/dw/dw04/src/DW_lp_piped_ecc.vhd \
|& tee -a $an_log

if ($an_encrypted_flag == 1) then
  $SIM dw04 \
  $VCS_HOME/dw/dw04/src/DW_BYPASS.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_CAPTURE.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_CAPUP.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_IDREG.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_IDREGUC.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_INSTRREG.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_INSTRREGID.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_TAPFSM.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_tap_uc2.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_crc_spm.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_apg.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_ctrl.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_memory.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_mux.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_wrapper.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bistc.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_codec.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_shadow.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_sign.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_xbistc.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_xcodec.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_tap.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_BYPASS.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_IDREG.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_IDREGUC.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_INSTRREG.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_INSTRREGID.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_TAPFSM.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_1.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_10.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_2.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_7.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_8.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_9.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_selu.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_selx.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_1.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_10.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_2.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_3.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_4.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_5.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_7.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_8.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_9.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_crc_spm_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_crc_s_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_crc_p_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW04_par_gen_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW04_shad_reg_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_CAPTURE_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_CAPUP_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_1_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_2_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_3_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_4_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_5_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_7_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_8_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_9_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_bc_10_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_wc_d1_s_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_wc_s1_s_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_BYPASS_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_IDREG_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_IDREGUC_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_INSTRREG_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_INSTRREGID_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_TAPFSM_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_tap_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_tap_uc_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_tap_uc2_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_control_force_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_Z_control_force_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_observ_dgen_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_apg_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_ctrl_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_memory_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_mux_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DW_mbist_wrapper_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_shadow_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_sign_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_codec_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_xcodec_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bistc_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_xbistc_rtl.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_BYPASS_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_IDREG_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_IDREGUC_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_INSTRREGID_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_INSTRREG_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_TAPFSM_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_tap_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_1_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_10_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_2_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_7_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_8_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_9_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_selu_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_ac_selx_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_1_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_10_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_2_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_3_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_4_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_5_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_7_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_8_str.vhd.e \
  $VCS_HOME/dw/dw04/src/DFT_bc_9_str.vhd.e \
  |& tee -a $an_log
endif

$SIM dw04 \
$VCS_HOME/dw/dw04/src/DW_bc_1_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_2_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_3_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_4_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_5_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_7_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_8_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_9_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_bc_10_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_wc_d1_s_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_wc_s1_s_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_crc_s_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_crc_p_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_ecc_sim.vhd \
$VCS_HOME/dw/dw04/src/DW04_par_gen_sim.vhd \
$VCS_HOME/dw/dw04/src/DW04_shad_reg_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_tap_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_tap_uc_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_control_force_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_Z_control_force_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_observ_dgen_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_dec_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_enc_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_8b10b_unbal_sim.vhd \
$VCS_HOME/dw/dw04/src/DW_lp_piped_ecc_sim.vhd \
|& tee -a $an_log

cd $VCS_HOME/dw/dw05/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw05/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw05/lib
endif
echo "Building dw05 ..." |& tee -a $an_log 
$SIM dw05 \
$VCS_HOME/dw/dw05/src/DW05_components.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_2t.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_dp.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_fcfs.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_rr.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_sp.vhd \
|& tee -a $an_log

$SIM dw05 \
$VCS_HOME/dw/dw05/src/DW_arb_2t_sim.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_dp_sim.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_fcfs_sim.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_rr_sim.vhd \
$VCS_HOME/dw/dw05/src/DW_arb_sp_sim.vhd \
|& tee -a $an_log

cd $VCS_HOME/dw/dw06/src
## NOTE: ARCH is set by sourcing $VCS_HOME/bin/environ.csh
if ( ! -e $VCS_HOME/$ARCH/packages/dw/dw06/lib ) then
   mkdir -p $VCS_HOME/$ARCH/packages/dw/dw06/lib
endif
echo "Building dw06 ..." |& tee -a $an_log 
$SIM dw06 \
$VCS_HOME/dw/dw06/src/DW06_components.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_s_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_s_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_a_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_a_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_s_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_s_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_a_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_a_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_s_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_s_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_a_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_a_lat.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s1_df.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s1_sf.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s2_sf.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s1_sf.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s1_df.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s2_sf.vhd \
$VCS_HOME/dw/dw06/src/DW_stack.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_2c_dff.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_2c_df.vhd \
$VCS_HOME/dw/dw06/src/DW_lp_fifo_1c_df.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_2w_s_dff.vhd \
|& tee -a $an_log

if ($an_encrypted_flag == 1) then
  $SIM dw06 \
  $VCS_HOME/dw/dw06/src/DW_MEM_RW_A_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_RW_S_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_2R_W_A_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_2R_W_S_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_R_W_A_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_R_W_S_LAT.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_RW_A_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_RW_S_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_2R_W_A_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_2R_W_S_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_R_W_A_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_MEM_R_W_S_LAT_STR.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_rw_s_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_rw_a_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_r_w_s_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_r_w_a_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_2r_w_s_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_ram_2r_w_a_lat_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_fifo_s1_df_rtl.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_fifo_s1_sf_rtl.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_fifo_s2_sf_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_asymfifo_s1_sf_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_asymfifo_s1_df_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_asymfifo_s2_sf_str.vhd.e \
  $VCS_HOME/dw/dw06/src/DW_stack_str.vhd.e \
  |& tee -a $an_log
endif

$SIM dw06 \
$VCS_HOME/dw/dw06/src/DW_ram_rw_s_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_s_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_a_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_rw_a_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_s_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_s_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_a_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_a_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_s_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_s_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_a_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_w_a_lat_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s1_df_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s1_sf_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_s2_sf_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s1_sf_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s1_df_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_asymfifo_s2_sf_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_stack_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_r_w_2c_dff_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_fifo_2c_df_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_lp_fifo_1c_df_sim.vhd \
$VCS_HOME/dw/dw06/src/DW_ram_2r_2w_s_dff_sim.vhd \
|& tee -a $an_log

egrep -i 'warning|error' $an_log

echo " "
echo " "
echo "The build log file is $an_log."

echo "Done." |& tee -a $an_log

exit 0


interr:
   echo "" |& tee -a $an_log
   echo "Abort. Recovering from the original ...." |& tee -a $an_log
   echo "" |& tee -a $an_log

   ## clean up
   cd $VCS_HOME
   if ( -d ${VCS_HOME}/dw.$Date ) then
      rm -rf ${VCS_HOME}/dw.$Date 
   endif
   if ( -d ${VCS_HOME}/packages/dware.$Date ) then
      rm -rf ${VCS_HOME}/packages/dware.$Date 
   endif
   #### Remember to remove the following codes for SI2 and Prodution handoff
   if ( -d ${VCS_HOME}/packages/gtech.$Date ) then
      rm -rf ${VCS_HOME}/packages/gtech.$Date 
   endif
   #### Remember to remove the above codes for SI2 and Prodution handoff

   exit 1

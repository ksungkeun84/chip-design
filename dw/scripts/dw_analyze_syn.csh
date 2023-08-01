#! /bin/csh -f

# Script generated in /remote/sweifs/PE/products/spf/o2018.06_sp_dev/clientstore/spf_o2018.06_sp_dev_build2
# Script generation date: Thu Oct 18 21:00:43 PDT 2018
#
set dwbb_make_version = O-2018.06
 
# The current default Verilog Standard for DC is 2005.
# If required to use an earlier standard with the DesignWare
# Building Block Library, then modifying the value used in
# the following variable setting command will allow this
# script to re-analyze the DesignWare Library for DC with
# the newly specified Verilog Standard version (allowed
# values are 2001 and 2005)
#
set dw_vrlg_std = 2005


set abso_path = `dirname $0`
cd $abso_path
if ( ! -f verify_SYNSIMARCH ) then
   echo "Can not find [verify_SYNSIMARCH]."
   exit 1
endif
./verify_SYNSIMARCH junk.$$ syn
if( $status > 0 ) then
   echo "Re-analyze is aborted."
   rm -f junk.$$
   exit 1
endif
source junk.$$
rm -f junk.$$

set dc_shell = "$EXECUTABLE_BIN_4_EST" 
if ( $dc_shell:t == "fpga_shell" ) then
    set synlib = "tmg.sldb"
else
    set synlib = "dw_foundation.sldb"
    set dc_shell = "$dc_shell "
endif


set install_gtech_flag = 0
if ( $#argv >= 1 ) then
   foreach option ($argv)
     switch ($option)
        case -gtech:
          set install_gtech_flag = 1
        breaksw
        default:
        breaksw
     endsw
   end
endif

set dwbb_in_syn_v_str  = `cat ${SYNOPSYS}/dw/version`
set dwbb_in_syn_version  = `echo ${dwbb_in_syn_v_str} | sed -e 's/\(.*\)-DW[FB]*_\(.*\)/\1/'`
set LOG = "${SYNOPSYS}/dw_analyze_syn.dware.log"

if ( "$dwbb_in_syn_version" !~ "$dwbb_make_version" ) then
   echo "Error: This script ($0) was designed for re-analyzing DesignWare " |& tee -a $LOG
   echo "DWBB version $dwbb_make_version,  but it is being used for the source files" |& tee -a $LOG
   echo "on SYNOPSYS tree version $dwbb_in_syn_version. Please use the reanalyze" |& tee -a $LOG
   echo "script in SYNOPSYS tree $dwbb_in_syn_version. Bye now." |& tee -a $LOG
   exit 1
endif

cd $SYNOPSYS
cd $SYNOPSYS/packages/dware/src
/bin/rm -rf $SYNOPSYS/packages/dware/lib $SYNOPSYS/packages/dware/lib87
/bin/mkdir -p $SYNOPSYS/packages/dware/lib/DWARE
/bin/mkdir -p $SYNOPSYS/packages/dware/lib87/DWARE
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dware.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors [concat \$suppress_errors { VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dware DWpackages_n.vhd
analyze -update -format VHDL -lib dware DWpackages.vhd
analyze -update -format VHDL -lib dware DW_Foundation.vhd
analyze -update -format VHDL -lib dware DW_Foundation_arith.vhd
analyze -update -format VHDL -lib dware DW_Foundation_comp.vhd
analyze -update -format VHDL -lib dware DW_Foundation_comp_arith.vhd
analyze -update -format VHDL -lib dware DWmath.vhd
analyze -update -format VHDL -lib dware DW_dp_functions_syn.vhd.e
analyze -update -format VHDL -lib dware DW_dp_functions_arith_syn.vhd.e
quit
++
/bin/rm -f command.log

if ($install_gtech_flag == 1) then 
cd $SYNOPSYS/packages/gtech/src
set bug_mes = 'Error: Usage of parameters or variables declared in parent subprogram is not supported on line XXX  (VHDL-2162)'
set bug_mes1 = 'Error: Usage of parameters or variables declared in parent subprogram is not supported  on line XXX  (VHDL-2162)'

set count = 0

set LOG = "${SYNOPSYS}/dw_analyze_syn.gtech.log"

set retval = 1
set gostbug = 0
while ( $retval > 0 && $gostbug == 0 )
   if ($count == 10) then
       echo "Error: After 10 times re-analyze, the VHDL-2161 problem still occure." >> $LOG
       exit 9
   endif 
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.gtech.log
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors [concat \$suppress_errors { VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -work gtech GTECH_ADD_AB.vhd
analyze -update -format VHDL -work gtech GTECH_ADD_ABC.vhd
analyze -update -format VHDL -work gtech GTECH_AND2.vhd
analyze -update -format VHDL -work gtech GTECH_AND3.vhd
analyze -update -format VHDL -work gtech GTECH_AND4.vhd
analyze -update -format VHDL -work gtech GTECH_AND5.vhd
analyze -update -format VHDL -work gtech GTECH_AND8.vhd
analyze -update -format VHDL -work gtech GTECH_AND_NOT.vhd
analyze -update -format VHDL -work gtech GTECH_AO21.vhd
analyze -update -format VHDL -work gtech GTECH_AO22.vhd
analyze -update -format VHDL -work gtech GTECH_AOI21.vhd
analyze -update -format VHDL -work gtech GTECH_AOI22.vhd
analyze -update -format VHDL -work gtech GTECH_AOI222.vhd
analyze -update -format VHDL -work gtech GTECH_AOI2N2.vhd
analyze -update -format VHDL -work gtech GTECH_BUF.vhd
analyze -update -format VHDL -work gtech GTECH_FD1.vhd
analyze -update -format VHDL -work gtech GTECH_FD14.vhd
analyze -update -format VHDL -work gtech GTECH_FD18.vhd
analyze -update -format VHDL -work gtech GTECH_FD1S.vhd
analyze -update -format VHDL -work gtech GTECH_FD2.vhd
analyze -update -format VHDL -work gtech GTECH_FD24.vhd
analyze -update -format VHDL -work gtech GTECH_FD28.vhd
analyze -update -format VHDL -work gtech GTECH_FD2S.vhd
analyze -update -format VHDL -work gtech GTECH_FD3.vhd
analyze -update -format VHDL -work gtech GTECH_FD34.vhd
analyze -update -format VHDL -work gtech GTECH_FD38.vhd
analyze -update -format VHDL -work gtech GTECH_FD3S.vhd
analyze -update -format VHDL -work gtech GTECH_FD4.vhd
analyze -update -format VHDL -work gtech GTECH_FD44.vhd
analyze -update -format VHDL -work gtech GTECH_FD48.vhd
analyze -update -format VHDL -work gtech GTECH_FD4S.vhd
analyze -update -format VHDL -work gtech GTECH_FJK1.vhd
analyze -update -format VHDL -work gtech GTECH_FJK1S.vhd
analyze -update -format VHDL -work gtech GTECH_FJK2.vhd
analyze -update -format VHDL -work gtech GTECH_FJK2S.vhd
analyze -update -format VHDL -work gtech GTECH_FJK3.vhd
analyze -update -format VHDL -work gtech GTECH_FJK3S.vhd
analyze -update -format VHDL -work gtech GTECH_INBUF.vhd
analyze -update -format VHDL -work gtech GTECH_INOUTBUF.vhd
analyze -update -format VHDL -work gtech GTECH_ISO0_EN0.vhd
analyze -update -format VHDL -work gtech GTECH_ISO1_EN0.vhd
analyze -update -format VHDL -work gtech GTECH_ISO0_EN1.vhd
analyze -update -format VHDL -work gtech GTECH_ISO1_EN1.vhd
analyze -update -format VHDL -work gtech GTECH_ISOLATCH_EN0.vhd
analyze -update -format VHDL -work gtech GTECH_ISOLATCH_EN1.vhd
analyze -update -format VHDL -work gtech GTECH_LD1.vhd
analyze -update -format VHDL -work gtech GTECH_LD2.vhd
analyze -update -format VHDL -work gtech GTECH_LD2_1.vhd
analyze -update -format VHDL -work gtech GTECH_LD3.vhd
analyze -update -format VHDL -work gtech GTECH_LD4.vhd
analyze -update -format VHDL -work gtech GTECH_LD4_1.vhd
analyze -update -format VHDL -work gtech GTECH_LSR0.vhd
analyze -update -format VHDL -work gtech GTECH_MAJ23.vhd
analyze -update -format VHDL -work gtech GTECH_MUX2.vhd
analyze -update -format VHDL -work gtech GTECH_MUXI2.vhd
analyze -update -format VHDL -work gtech GTECH_MUX4.vhd
analyze -update -format VHDL -work gtech GTECH_MUX8.vhd
analyze -update -format VHDL -work gtech GTECH_NAND2.vhd
analyze -update -format VHDL -work gtech GTECH_NAND3.vhd
analyze -update -format VHDL -work gtech GTECH_NAND4.vhd
analyze -update -format VHDL -work gtech GTECH_NAND5.vhd
analyze -update -format VHDL -work gtech GTECH_NAND8.vhd
analyze -update -format VHDL -work gtech GTECH_NOR2.vhd
analyze -update -format VHDL -work gtech GTECH_NOR3.vhd
analyze -update -format VHDL -work gtech GTECH_NOR4.vhd
analyze -update -format VHDL -work gtech GTECH_NOR5.vhd
analyze -update -format VHDL -work gtech GTECH_NOR8.vhd
analyze -update -format VHDL -work gtech GTECH_NOT.vhd
analyze -update -format VHDL -work gtech GTECH_OA21.vhd
analyze -update -format VHDL -work gtech GTECH_OA22.vhd
analyze -update -format VHDL -work gtech GTECH_OAI21.vhd
analyze -update -format VHDL -work gtech GTECH_OAI22.vhd
analyze -update -format VHDL -work gtech GTECH_OAI2N2.vhd
analyze -update -format VHDL -work gtech GTECH_ONE.vhd
analyze -update -format VHDL -work gtech GTECH_OR2.vhd
analyze -update -format VHDL -work gtech GTECH_OR3.vhd
analyze -update -format VHDL -work gtech GTECH_OR4.vhd
analyze -update -format VHDL -work gtech GTECH_OR5.vhd
analyze -update -format VHDL -work gtech GTECH_OR8.vhd
analyze -update -format VHDL -work gtech GTECH_OR_NOT.vhd
analyze -update -format VHDL -work gtech GTECH_OUTBUF.vhd
analyze -update -format VHDL -work gtech GTECH_TBUF.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR2.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR3.vhd
analyze -update -format VHDL -work gtech GTECH_XOR2.vhd
analyze -update -format VHDL -work gtech GTECH_XOR3.vhd
analyze -update -format VHDL -work gtech GTECH_XOR4.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR4.vhd
analyze -update -format VHDL -work gtech GTECH_ZERO.vhd
analyze -update -format VHDL -work gtech GTECH_ADD_AB_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ADD_ABC_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND5_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND8_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AND_NOT_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AO21_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AO22_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AOI21_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AOI22_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AOI222_sim.vhd
analyze -update -format VHDL -work gtech GTECH_AOI2N2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_BUF_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD14_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD18_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD1S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD24_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD28_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD2S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD34_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD38_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD3S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD44_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD48_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FD4S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK1S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK2S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_FJK3S_sim.vhd
analyze -update -format VHDL -work gtech GTECH_INBUF_sim.vhd
analyze -update -format VHDL -work gtech GTECH_INOUTBUF_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISO0_EN0_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISO1_EN0_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISO0_EN1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISO1_EN1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISOLATCH_EN0_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ISOLATCH_EN1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD2_1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LD4_1_sim.vhd
analyze -update -format VHDL -work gtech GTECH_LSR0_sim.vhd
analyze -update -format VHDL -work gtech GTECH_MAJ23_sim.vhd
analyze -update -format VHDL -work gtech GTECH_MUX2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_MUXI2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_MUX4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_MUX8_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NAND2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NAND3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NAND4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NAND5_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NAND8_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOR2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOR3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOR4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOR5_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOR8_sim.vhd
analyze -update -format VHDL -work gtech GTECH_NOT_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OA21_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OA22_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OAI21_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OAI22_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OAI2N2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ONE_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR5_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR8_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OR_NOT_sim.vhd
analyze -update -format VHDL -work gtech GTECH_OUTBUF_sim.vhd
analyze -update -format VHDL -work gtech GTECH_TBUF_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XOR2_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XOR3_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XOR4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_XNOR4_sim.vhd
analyze -update -format VHDL -work gtech GTECH_ZERO_sim.vhd
quit
++
/bin/rm -f command.log
   set retval = `egrep -i 'error' $LOG | wc -l`
   set gostbug = `egrep -i 'error' $LOG | sed 's/^\(.*\)Error: \(.*\)/Error: \2/' | sed 's/ [0-9][0-9]* / XXX /g' | sed 's/'"$bug_mes"'//g' | sed 's/'"$bug_mes1"'//g' | wc -l`
   @ count += 1
end

if ( $retval > 0 ) then
   echo "Error: please check $LOG"
   exit 9
endif
endif

cd $SYNOPSYS/dw/dw01/src
/bin/rm -rf $SYNOPSYS/dw/dw01/lib $SYNOPSYS/dw/dw01/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw01/lib/dw01
/bin/mkdir -p $SYNOPSYS/dw/dw01/lib87/dw01
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw01.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw01 DW01_components.vhd
analyze -update -format VHDL -lib dw01 DW_decode_en.vhd
analyze -update -format VHDL -lib dw01 DW01_csa.vhd
analyze -update -format VHDL -lib dw01 DW01_decode.vhd
analyze -update -format VHDL -lib dw01 DW01_dec.vhd
analyze -update -format VHDL -lib dw01 DW01_inc.vhd
analyze -update -format VHDL -lib dw01 DW01_incdec.vhd
analyze -update -format VHDL -lib dw01 DW01_cmp2.vhd
analyze -update -format VHDL -lib dw01 DW01_cmp6.vhd
analyze -update -format VHDL -lib dw01 DW01_add.vhd
analyze -update -format VHDL -lib dw01 DW01_addsub.vhd
analyze -update -format VHDL -lib dw01 DW01_sub.vhd
analyze -update -format VHDL -lib dw01 DW01_satrnd.vhd
analyze -update -format VHDL -lib dw01 DW01_absval.vhd
analyze -update -format VHDL -lib dw01 DW01_ash.vhd
analyze -update -format VHDL -lib dw01 DW01_binenc.vhd
analyze -update -format VHDL -lib dw01 DW01_prienc.vhd
analyze -update -format VHDL -lib dw01 DW01_bsh.vhd
analyze -update -format VHDL -lib dw01 DW01_mux_any.vhd
analyze -update -format VHDL -lib dw01 DW_cmp_dx.vhd
analyze -update -format VHDL -lib dw01 DW_addsub_dx.vhd
analyze -update -format VHDL -lib dw01 DW_shifter.vhd
analyze -update -format VHDL -lib dw01 DW_minmax.vhd
analyze -update -format VHDL -lib dw01 DW_bin2gray.vhd
analyze -update -format VHDL -lib dw01 DW_gray2bin.vhd
analyze -update -format VHDL -lib dw01 DW_inc_gray.vhd
analyze -update -format VHDL -lib dw01 DW_norm.vhd
analyze -update -format VHDL -lib dw01 DW_norm_rnd.vhd
analyze -update -format VHDL -lib dw01 DW_lod.vhd
analyze -update -format VHDL -lib dw01 DW_lzd.vhd
analyze -update -format VHDL -lib dw01 DW_rash.vhd
analyze -update -format VHDL -lib dw01 DW_rbsh.vhd
analyze -update -format VHDL -lib dw01 DW_lbsh.vhd
analyze -update -format VHDL -lib dw01 DW_sla.vhd
analyze -update -format VHDL -lib dw01 DW_sra.vhd
analyze -update -format VHDL -lib dw01 DW_lsd.vhd
analyze -update -format VHDL -lib dw01 DW_thermdec.vhd
analyze -update -format VHDL -lib dw01 DW_pricod.vhd
analyze -update -format VHDL -lib dw01 DW_lza.vhd
analyze -update -format VHDL -lib dw01 DW01_ADD_AB.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ADD_AB1.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ADD_ABC.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AND2.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AND_NOT.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AO21.vhd.e
analyze -update -format VHDL -lib dw01 DW01_CL_DEC.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_DEC.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_SUM.vhd.e
analyze -update -format VHDL -lib dw01 DW01_MUX.vhd.e
analyze -update -format VHDL -lib dw01 DW01_MMUX.vhd.e
analyze -update -format VHDL -lib dw01 DW01_NAND2.vhd.e
analyze -update -format VHDL -lib dw01 DW01_NOT.vhd.e
analyze -update -format VHDL -lib dw01 DW01_OR2.vhd.e
analyze -update -format VHDL -lib dw01 DW01_OR_NOT.vhd.e
analyze -update -format VHDL -lib dw01 DW01_SUB_ABC.vhd.e
analyze -update -format VHDL -lib dw01 DW01_XOR2.vhd.e
analyze -update -format VHDL -lib dw01 DW01_LE_REG.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_NODE.vhd.e
analyze -update -format VHDL -lib dw01 DW01_decode_DG.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_XOR.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_OR.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_ANDOR.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_AND.vhd.e
analyze -update -format VHDL -lib dw01 DW_PRIORITY_CODER.vhd.e
analyze -update -format VHDL -lib dw01 DW_or_tree.vhd.e
analyze -update -format VHDL -lib dw01 DW_and_tree.vhd.e
analyze -update -format VHDL -lib dw01 DW_inc.vhd.e
analyze -update -format VHDL -lib dw01 DW_incdec.vhd.e
analyze -update -format VHDL -lib dw01 DW_dec.vhd.e
analyze -update -format VHDL -lib dw01 DW_ne.vhd.e
analyze -update -format VHDL -lib dw01 DW_eq.vhd.e
analyze -update -format VHDL -lib dw01 DW_bit_order.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax4.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax2.vhd.e
analyze -update -format VHDL -lib dw01 DW_lzod.vhd.e
analyze -update -format VHDL -lib dw01 DW_decode_en_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_inc_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_incdec_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_dec_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_decode_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_dec_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_inc_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_incdec_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_cmp2_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_cmp6_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_add_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_addsub_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_sub_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_absval_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ash_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_bsh_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_rash_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_rbsh_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_lbsh_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW_thermdec_verif.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ADD_AB_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ADD_AB1_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ADD_ABC_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AND2_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AND_NOT_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_AO21_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_CL_DEC_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_DEC_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_SUM_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_MUX_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_MMUX_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_NAND2_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_NOT_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_OR2_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_OR_NOT_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_SUB_ABC_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_XOR2_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_LE_REG_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_GP_NODE_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_XOR_sk.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_OR_sk.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_ANDOR_sk.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_AND_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_PREFIX_AND_sk.vhd.e
analyze -update -format VHDL -lib dw01 DW_PRIORITY_CODER_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_PRIORITY_CODER_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_or_tree_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_and_tree_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_ne_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_eq_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_bit_order_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax4_clas.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax2_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_lzod_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_lzod_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_csa_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_decode_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_dec_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_dec_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_inc_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_inc_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_incdec_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_incdec_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_cmp2_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_cmp6_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_add_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_add_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_addsub_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_addsub_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_sub_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_sub_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_satrnd_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_absval_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_absval_clf.vhd.e
analyze -update -format VHDL -lib dw01 DW01_absval_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW01_ash_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW01_binenc_aot.vhd.e
analyze -update -format VHDL -lib dw01 DW01_binenc_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_binenc_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_prienc_aot.vhd.e
analyze -update -format VHDL -lib dw01 DW01_prienc_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW01_prienc_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_mux_any_str.vhd.e
analyze -update -format VHDL -lib dw01 DW01_mux_any_fmx.vhd.e
analyze -update -format VHDL -lib dw01 DW_cmp_dx_bk.vhd.e
analyze -update -format VHDL -lib dw01 DW_cmp_dx_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW_addsub_dx_csm.vhd.e
analyze -update -format VHDL -lib dw01 DW_addsub_dx_rpcs.vhd.e
analyze -update -format VHDL -lib dw01 DW_addsub_dx_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW_shifter_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_shifter_mx2i.vhd.e
analyze -update -format VHDL -lib dw01 DW_shifter_mx4.vhd.e
analyze -update -format VHDL -lib dw01 DW_shifter_mx8.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_minmax_clas.vhd.e
analyze -update -format VHDL -lib dw01 DW_bin2gray_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_gray2bin_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_gray2bin_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW_inc_gray_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_inc_gray_rpl.vhd.e
analyze -update -format VHDL -lib dw01 DW_norm_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_norm_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_norm_rnd_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_norm_rnd_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_lod_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_lod_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_lzd_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_lzd_rtl.vhd.e
analyze -update -format VHDL -lib dw01 DW_rash_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_rbsh_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_lbsh_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_sla_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_sra_mx2.vhd.e
analyze -update -format VHDL -lib dw01 DW_lsd_str.vhd.e
analyze -update -format VHDL -lib dw01 DW_pricod_cla.vhd.e
analyze -update -format VHDL -lib dw01 DW_pricod_rtl.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw01 DW_lza__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw01/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw01.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw01 DWsc_opiso_ve.vhd.e
analyze -update -format VHDL -lib dw01 DWsc_opiso_vh.vhd.e
analyze -update -format VHDL -lib dw01 DWsc_opiso_vh_noop.vhd.e
analyze -update -format VHDL -lib dw01 DWsc_opiso_vh_andgate.vhd.e
analyze -update -format VHDL -lib dw01 DWsc_opiso_vh_orgate.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw01 DW01_decode_DG__str.v.e
analyze -update -format Verilog -lib dw01 DWsc_opiso_ve__noop.v.e
analyze -update -format Verilog -lib dw01 DWsc_opiso_ve__and.v.e
analyze -update -format Verilog -lib dw01 DWsc_opiso_ve__or.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/dw/dw02/src
/bin/rm -rf $SYNOPSYS/dw/dw02/lib $SYNOPSYS/dw/dw02/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw02/lib/dw02
/bin/mkdir -p $SYNOPSYS/dw/dw02/lib87/dw02
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw02.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw02 DW02_components.vhd
analyze -update -format VHDL -lib dw02 DW02_tree.vhd
analyze -update -format VHDL -lib dw02 DW02_multp.vhd
analyze -update -format VHDL -lib dw02 DW02_sum.vhd
analyze -update -format VHDL -lib dw02 DW02_mult.vhd
analyze -update -format VHDL -lib dw02 DW02_mac.vhd
analyze -update -format VHDL -lib dw02 DW02_mult_2_stage.vhd
analyze -update -format VHDL -lib dw02 DW02_mult_3_stage.vhd
analyze -update -format VHDL -lib dw02 DW02_mult_4_stage.vhd
analyze -update -format VHDL -lib dw02 DW02_mult_5_stage.vhd
analyze -update -format VHDL -lib dw02 DW02_mult_6_stage.vhd
analyze -update -format VHDL -lib dw02 DW02_prod_sum.vhd
analyze -update -format VHDL -lib dw02 DW02_prod_sum1.vhd
analyze -update -format VHDL -lib dw02 DW_squarep.vhd
analyze -update -format VHDL -lib dw02 DW_square.vhd
analyze -update -format VHDL -lib dw02 DW_mult_dx.vhd
analyze -update -format VHDL -lib dw02 DW_div.vhd
analyze -update -format VHDL -lib dw02 DW_div_sat.vhd
analyze -update -format VHDL -lib dw02 DW_sqrt.vhd
analyze -update -format VHDL -lib dw02 DW_mult_pipe.vhd
analyze -update -format VHDL -lib dw02 DW_div_pipe.vhd
analyze -update -format VHDL -lib dw02 DW_sqrt_pipe.vhd
analyze -update -format VHDL -lib dw02 DW_prod_sum_pipe.vhd
analyze -update -format VHDL -lib dw02 DW_inv_sqrt.vhd
analyze -update -format VHDL -lib dw02 DW_fp_flt2i.vhd
analyze -update -format VHDL -lib dw02 DW_fp_i2flt.vhd
analyze -update -format VHDL -lib dw02 DW_fp_addsub.vhd
analyze -update -format VHDL -lib dw02 DW_fp_add.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sub.vhd
analyze -update -format VHDL -lib dw02 DW_fp_mult.vhd
analyze -update -format VHDL -lib dw02 DW_fp_div.vhd
analyze -update -format VHDL -lib dw02 DW_fp_cmp.vhd
analyze -update -format VHDL -lib dw02 DW_fp_recip.vhd
analyze -update -format VHDL -lib dw02 DW_fp_ifp_conv.vhd
analyze -update -format VHDL -lib dw02 DW_ifp_fp_conv.vhd
analyze -update -format VHDL -lib dw02 DW_ifp_addsub.vhd
analyze -update -format VHDL -lib dw02 DW_FP_ALIGN.vhd
analyze -update -format VHDL -lib dw02 DW_ifp_mult.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sum3.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sum4.vhd
analyze -update -format VHDL -lib dw02 DW_fp_dp2.vhd
analyze -update -format VHDL -lib dw02 DW_fp_dp3.vhd
analyze -update -format VHDL -lib dw02 DW_fp_dp4.vhd
analyze -update -format VHDL -lib dw02 DW_fp_invsqrt.vhd
analyze -update -format VHDL -lib dw02 DW_log2.vhd
analyze -update -format VHDL -lib dw02 DW_fp_log2.vhd
analyze -update -format VHDL -lib dw02 DW_exp2.vhd
analyze -update -format VHDL -lib dw02 DW_fp_exp2.vhd
analyze -update -format VHDL -lib dw02 DW_fp_exp.vhd
analyze -update -format VHDL -lib dw02 DW_ln.vhd
analyze -update -format VHDL -lib dw02 DW_fp_ln.vhd
analyze -update -format VHDL -lib dw02 DW_fp_addsub_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_add_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sub_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_mult_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_mac_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_cmp_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sum3_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_div_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_recip_DG.vhd
analyze -update -format VHDL -lib dw02 DW_fp_square.vhd
analyze -update -format VHDL -lib dw02 DW_fp_div_seq.vhd
analyze -update -format VHDL -lib dw02 DW_sqrt_rem.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sqrt.vhd
analyze -update -format VHDL -lib dw02 DW_fp_mac.vhd
analyze -update -format VHDL -lib dw02 DW_sincos.vhd
analyze -update -format VHDL -lib dw02 DW_fp_sincos.vhd
analyze -update -format VHDL -lib dw02 DW_lp_multifunc.vhd
analyze -update -format VHDL -lib dw02 DW_lp_fp_multifunc.vhd
analyze -update -format VHDL -lib dw02 DW_lp_multifunc_DG.vhd
analyze -update -format VHDL -lib dw02 DW_lp_fp_multifunc_DG.vhd
analyze -update -format VHDL -lib dw02 DW02_booth.vhd.e
analyze -update -format VHDL -lib dw02 DW_bthenc.vhd.e
analyze -update -format VHDL -lib dw02 DW_mtree.vhd.e
analyze -update -format VHDL -lib dw02 DW_MULTP_SC.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_uns.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_tc.vhd.e
analyze -update -format VHDL -lib dw02 DW02_sum_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_DG_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mac_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW02_prod_sum_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW02_prod_sum1_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW_FP_ALIGN_verif.vhd.e
analyze -update -format VHDL -lib dw02 DW_bthenc_str.vhd.e
analyze -update -format VHDL -lib dw02 DW02_booth_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_mtree_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW02_tree_wallace.vhd.e
analyze -update -format VHDL -lib dw02 DW_MULTP_SC_nbw.vhd.e
analyze -update -format VHDL -lib dw02 DW_MULTP_SC_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW02_multp_nbw.vhd.e
analyze -update -format VHDL -lib dw02 DW02_multp_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW02_sum_csa.vhd.e
analyze -update -format VHDL -lib dw02 DW02_sum_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW02_sum_wallace.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_csa.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_2_stage_str.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_3_stage_str.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_4_stage_str.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_5_stage_str.vhd.e
analyze -update -format VHDL -lib dw02 DW02_mult_6_stage_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_squarep_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW_square_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW_mult_dx_wall.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_mlt.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_mlt.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_mlt.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_mlt.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_mlt.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_sat_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_sat_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_sat_cla3.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_uns_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_uns_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_tc_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_tc_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_mult_pipe_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_pipe_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_pipe_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_prod_sum_pipe_str.vhd.e
analyze -update -format VHDL -lib dw02 DW_inv_sqrt_rtl.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_rem_cla.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw02 DW_fp_flt2i__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_i2flt__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_i2flt__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_addsub__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_addsub__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_add__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sub__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mult__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mult__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_cmp__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_recip__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_ifp_conv__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_ifp_fp_conv__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_ifp_addsub__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_FP_ALIGN__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_FP_ALIGN__rtl1.v.e
analyze -update -format Verilog -lib dw02 DW_ifp_mult__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sum3__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sum4__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_dp2__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_dp3__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_dp4__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_invsqrt__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_log2__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_log2__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_exp2__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_exp2__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_exp2__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_exp__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_ln__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_ln__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_square__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div_seq__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sqrt__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mac__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mac__str.v.e
analyze -update -format Verilog -lib dw02 DW_sincos__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sincos__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw02/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw02.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw02 DW_div_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_DG.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_DG_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_DG_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_DG_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_DG_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_DG_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_tc_DG_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_DG_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_DG_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_uns_DG_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_DG_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_DG_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_tc_DG_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_DG_cla.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_DG_rpl.vhd.e
analyze -update -format VHDL -lib dw02 DW_mod_uns_DG_cla2.vhd.e
analyze -update -format VHDL -lib dw02 DW_mult_pipe_lpwr.vhd.e
analyze -update -format VHDL -lib dw02 DW_div_pipe_lpwr.vhd.e
analyze -update -format VHDL -lib dw02 DW_sqrt_pipe_lpwr.vhd.e
analyze -update -format VHDL -lib dw02 DW_prod_sum_pipe_lpwr.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw02 DW_fp_addsub_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_addsub_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_add_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_add_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sub_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sub_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mult_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mult_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mac_DG__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_mac_DG__str2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_cmp_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sum3_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_sum3_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div_DG__str.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div_DG__str2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_div_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_fp_recip_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_fp_recip_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_lp_multifunc__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_lp_fp_multifunc__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_lp_multifunc_DG__rtl.v.e
analyze -update -format Verilog -lib dw02 DW_lp_multifunc_DG__rtl2.v.e
analyze -update -format Verilog -lib dw02 DW_lp_fp_multifunc_DG__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/dw/dw03/src
/bin/rm -rf $SYNOPSYS/dw/dw03/lib $SYNOPSYS/dw/dw03/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw03/lib/dw03
/bin/mkdir -p $SYNOPSYS/dw/dw03/lib87/dw03
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw03.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw03 DW03_components.vhd
analyze -update -format VHDL -lib dw03 DW03_bictr_decode.vhd
analyze -update -format VHDL -lib dw03 DW03_bictr_scnto.vhd
analyze -update -format VHDL -lib dw03 DW03_bictr_dcnto.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_s1_df.vhd
analyze -update -format VHDL -lib dw03 DW03_lfsr_updn.vhd
analyze -update -format VHDL -lib dw03 DW03_lfsr_load.vhd
analyze -update -format VHDL -lib dw03 DW03_lfsr_scnto.vhd
analyze -update -format VHDL -lib dw03 DW03_lfsr_dcnto.vhd
analyze -update -format VHDL -lib dw03 DW03_pipe_reg.vhd
analyze -update -format VHDL -lib dw03 DW03_reg_s_pl.vhd
analyze -update -format VHDL -lib dw03 DW03_shftreg.vhd
analyze -update -format VHDL -lib dw03 DW_dpll_sd.vhd
analyze -update -format VHDL -lib dw03 DW_stackctl.vhd
analyze -update -format VHDL -lib dw03 DW03_updn_ctr.vhd
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s1_sf.vhd
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s1_df.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_s2dr_sf.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_s2_sf.vhd
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s2_sf.vhd
analyze -update -format VHDL -lib dw03 DW_cntr_gray.vhd
analyze -update -format VHDL -lib dw03 DW_mult_seq.vhd
analyze -update -format VHDL -lib dw03 DW_div_seq.vhd
analyze -update -format VHDL -lib dw03 DW_sqrt_seq.vhd
analyze -update -format VHDL -lib dw03 DW_fir.vhd
analyze -update -format VHDL -lib dw03 DW_fir_seq.vhd
analyze -update -format VHDL -lib dw03 DW_iir_dc.vhd
analyze -update -format VHDL -lib dw03 DW_iir_sc.vhd
analyze -update -format VHDL -lib dw03 DW_sync.vhd
analyze -update -format VHDL -lib dw03 DW_data_sync_1c.vhd
analyze -update -format VHDL -lib dw03 DW_pulse_sync.vhd
analyze -update -format VHDL -lib dw03 DW_pulseack_sync.vhd
analyze -update -format VHDL -lib dw03 DW_data_sync.vhd
analyze -update -format VHDL -lib dw03 DW_data_sync_na.vhd
analyze -update -format VHDL -lib dw03 DW_gray_sync.vhd
analyze -update -format VHDL -lib dw03 DW_reset_sync.vhd
analyze -update -format VHDL -lib dw03 DW_stream_sync.vhd
analyze -update -format VHDL -lib dw03 DW_piped_mac.vhd
analyze -update -format VHDL -lib dw03 DW_asymdata_inbuf.vhd
analyze -update -format VHDL -lib dw03 DW_asymdata_outbuf.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_2c_df.vhd
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_2c_df.vhd
analyze -update -format VHDL -lib dw03 DW_lp_fifoctl_1c_df.vhd
analyze -update -format VHDL -lib dw03 DW_lp_pipe_mgr.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_mult.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_prod_sum.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_s1_sf.vhd
analyze -update -format VHDL -lib dw03 DW_data_qsync_lh.vhd
analyze -update -format VHDL -lib dw03 DW_data_qsync_hl.vhd
analyze -update -format VHDL -lib dw03 DW_dct_2d.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_div.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_sqrt.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_fp_add.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_fp_sum3.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_fp_div.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_fp_mult.vhd
analyze -update -format VHDL -lib dw03 DW_lp_piped_fp_recip.vhd
analyze -update -format VHDL -lib dw03 DW_pl_reg.vhd
analyze -update -format VHDL -lib dw03 DW_lp_cntr_updn_df.vhd
analyze -update -format VHDL -lib dw03 DW_lp_cntr_up_df.vhd
analyze -update -format VHDL -lib dw03 DW_fifoctl_s1r.vhd.e
analyze -update -format VHDL -lib dw03 DW_pipe_reg.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_dcnto.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_scnto.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_smod.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_IN_WRAPPER.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_OUT_WRAPPER.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIFOCTL_IF.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_S2SF_INWRP.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_S2SF_OUTWRP.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_AU.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_CSR.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_CTL.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_DSR.vhd.e
analyze -update -format VHDL -lib dw03 DW03_pipe_reg_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_pipe_reg_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_fifoctl_s1r_rpl.vhd.e
analyze -update -format VHDL -lib dw03 DW_fifoctl_s1r_cla.vhd.e
analyze -update -format VHDL -lib dw03 DW03_bictr_decode_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_bictr_scnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_bictr_dcnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_dcnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_scnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_smod_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_IN_WRAPPER_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_OUT_WRAPPER_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s1_sf_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s1_df_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_dpll_sd_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_stackctl_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_lfsr_updn_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_lfsr_load_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_lfsr_scnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_lfsr_dcnto_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_shftreg_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_reg_s_pl_mbstr.vhd.e
analyze -update -format VHDL -lib dw03 DW03_reg_s_pl_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIFOCTL_IF_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_fifoctl_s2_sf_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_S2SF_INWRP_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_ASYMFIFOCTL_S2SF_OUTWRP_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_asymfifoctl_s2_sf_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_cntr_gray_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_mult_seq_cpa.vhd.e
analyze -update -format VHDL -lib dw03 DW_div_seq_cpa.vhd.e
analyze -update -format VHDL -lib dw03 DW_div_seq_cpa2.vhd.e
analyze -update -format VHDL -lib dw03 DW_sqrt_seq_cpa.vhd.e
analyze -update -format VHDL -lib dw03 DW_fir_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_AU_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_CSR_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_CTL_rtl.vhd.e
analyze -update -format VHDL -lib dw03 DW_FIR_SEQ_DSR_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_fir_seq_str.vhd.e
analyze -update -format VHDL -lib dw03 DW_iir_dc_mult.vhd.e
analyze -update -format VHDL -lib dw03 DW_iir_sc_mult.vhd.e
analyze -update -format VHDL -lib dw03 DW_iir_sc_vsum.vhd.e
analyze -update -format VHDL -lib dw03 DW_fifoctl_s2dr_sf_str.vhd.e
analyze -update -format VHDL -lib dw03 DW03_updn_ctr_str.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw03 DWsc_fifoctl_s1_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_data_sync_1c__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_pulse_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_pulseack_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_data_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_data_sync_na__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_gray_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_reset_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_stream_sync__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_piped_mac__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_asymdata_inbuf__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_asymdata_outbuf__rtl.v.e
analyze -update -format Verilog -lib dw03 DWsc_fifoctl_sif__rtl.v.e
analyze -update -format Verilog -lib dw03 DWsc_fifoctl_dif__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_2c_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_asymfifoctl_2c_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_s1_sf__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_s1_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_data_qsync_lh__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_data_qsync_hl__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_dct_2d__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_pl_reg__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw03/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw03.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw03 DW_cntr_gray_lpwr.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw03 DW_cntr_dcnto__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_cntr_scnto__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_cntr_smod__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW03_bictr_scnto__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW03_bictr_dcnto__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_piped_mac__lpwr.v.e
analyze -update -format Verilog -lib dw03 DWsc_fifoctl_dif__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_2c_df__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_asymfifoctl_2c_df__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_gray_sync__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_lp_fifoctl_1c_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_pipe_mgr__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_mult__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_prod_sum__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_s1_sf__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_fifoctl_s1_df__lpwr.v.e
analyze -update -format Verilog -lib dw03 DWsc_fifoctl_s1_df__lpwr.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_div__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_sqrt__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_add__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_add__ig.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_sum3__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_div__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_mult__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_piped_fp_recip__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_cntr_updn_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DWsc_lp_cntr_updn_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DW_lp_cntr_up_df__rtl.v.e
analyze -update -format Verilog -lib dw03 DWsc_lp_cntr_up_df__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/dw/dw04/src
/bin/rm -rf $SYNOPSYS/dw/dw04/lib $SYNOPSYS/dw/dw04/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw04/lib/dw04
/bin/mkdir -p $SYNOPSYS/dw/dw04/lib87/dw04
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw04.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw04 DW04_components.vhd
analyze -update -format VHDL -lib dw04 DW_bc_1.vhd
analyze -update -format VHDL -lib dw04 DW_bc_2.vhd
analyze -update -format VHDL -lib dw04 DW_bc_3.vhd
analyze -update -format VHDL -lib dw04 DW_bc_4.vhd
analyze -update -format VHDL -lib dw04 DW_bc_5.vhd
analyze -update -format VHDL -lib dw04 DW_bc_7.vhd
analyze -update -format VHDL -lib dw04 DW_bc_8.vhd
analyze -update -format VHDL -lib dw04 DW_bc_9.vhd
analyze -update -format VHDL -lib dw04 DW_bc_10.vhd
analyze -update -format VHDL -lib dw04 DW_wc_d1_s.vhd
analyze -update -format VHDL -lib dw04 DW_wc_s1_s.vhd
analyze -update -format VHDL -lib dw04 DW_crc_s.vhd
analyze -update -format VHDL -lib dw04 DW_crc_p.vhd
analyze -update -format VHDL -lib dw04 DW_ecc.vhd
analyze -update -format VHDL -lib dw04 DW04_par_gen.vhd
analyze -update -format VHDL -lib dw04 DW04_shad_reg.vhd
analyze -update -format VHDL -lib dw04 DW_tap.vhd
analyze -update -format VHDL -lib dw04 DW_tap_uc.vhd
analyze -update -format VHDL -lib dw04 DW_control_force.vhd
analyze -update -format VHDL -lib dw04 DW_Z_control_force.vhd
analyze -update -format VHDL -lib dw04 DW_observ_dgen.vhd
analyze -update -format VHDL -lib dw04 DW_8b10b_dec.vhd
analyze -update -format VHDL -lib dw04 DW_8b10b_enc.vhd
analyze -update -format VHDL -lib dw04 DW_8b10b_unbal.vhd
analyze -update -format VHDL -lib dw04 DW_lp_piped_ecc.vhd
analyze -update -format VHDL -lib dw04 DW_BYPASS.vhd.e
analyze -update -format VHDL -lib dw04 DW_CAPTURE.vhd.e
analyze -update -format VHDL -lib dw04 DW_CAPUP.vhd.e
analyze -update -format VHDL -lib dw04 DW_IDREG.vhd.e
analyze -update -format VHDL -lib dw04 DW_IDREGUC.vhd.e
analyze -update -format VHDL -lib dw04 DW_INSTRREG.vhd.e
analyze -update -format VHDL -lib dw04 DW_INSTRREGID.vhd.e
analyze -update -format VHDL -lib dw04 DW_TAPFSM.vhd.e
analyze -update -format VHDL -lib dw04 DW_tap_uc2.vhd.e
analyze -update -format VHDL -lib dw04 DW_crc_spm.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_apg.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_ctrl.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_memory.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_mux.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_wrapper.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bistc.vhd.e
analyze -update -format VHDL -lib dw04 DFT_codec.vhd.e
analyze -update -format VHDL -lib dw04 DFT_shadow.vhd.e
analyze -update -format VHDL -lib dw04 DFT_sign.vhd.e
analyze -update -format VHDL -lib dw04 DFT_xbistc.vhd.e
analyze -update -format VHDL -lib dw04 DFT_xcodec.vhd.e
analyze -update -format VHDL -lib dw04 DFT_tap.vhd.e
analyze -update -format VHDL -lib dw04 DFT_BYPASS.vhd.e
analyze -update -format VHDL -lib dw04 DFT_IDREG.vhd.e
analyze -update -format VHDL -lib dw04 DFT_IDREGUC.vhd.e
analyze -update -format VHDL -lib dw04 DFT_INSTRREG.vhd.e
analyze -update -format VHDL -lib dw04 DFT_INSTRREGID.vhd.e
analyze -update -format VHDL -lib dw04 DFT_TAPFSM.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_1.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_10.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_2.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_7.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_8.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_9.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_selu.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_selx.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_1.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_10.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_2.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_3.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_4.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_5.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_7.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_8.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_9.vhd.e
analyze -update -format VHDL -lib dw04 DW_crc_spm_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_crc_s_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_crc_p_str.vhd.e
analyze -update -format VHDL -lib dw04 DW04_par_gen_str.vhd.e
analyze -update -format VHDL -lib dw04 DW04_shad_reg_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_CAPTURE_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_CAPUP_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_1_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_2_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_3_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_4_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_5_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_7_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_8_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_9_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_bc_10_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_wc_d1_s_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_wc_s1_s_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_BYPASS_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_IDREG_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_IDREGUC_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_INSTRREG_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_INSTRREGID_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_TAPFSM_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_tap_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_tap_uc_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_tap_uc2_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_control_force_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_Z_control_force_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_observ_dgen_str.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_apg_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_ctrl_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_memory_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_mux_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DW_mbist_wrapper_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_shadow_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_sign_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_codec_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_xcodec_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bistc_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_xbistc_rtl.vhd.e
analyze -update -format VHDL -lib dw04 DFT_BYPASS_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_IDREG_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_IDREGUC_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_INSTRREGID_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_INSTRREG_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_TAPFSM_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_tap_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_1_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_10_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_2_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_7_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_8_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_9_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_selu_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_ac_selx_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_1_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_10_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_2_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_3_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_4_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_5_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_7_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_8_str.vhd.e
analyze -update -format VHDL -lib dw04 DFT_bc_9_str.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw04 DW_8b10b_unbal__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_ecc__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_acnt__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_agen__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_cfsr__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_dgen__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_lcnt__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_muxif__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_apg_rwt__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_ctrl_alg__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_ctrl_memsel__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_ctrl_modereg__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_ctrl_pgen__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_ctrl_topfsm__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_mbist_muxport__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_shifter__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_shifter__257to512.v.e
analyze -update -format Verilog -lib dw04 DFT_shifter__257to2048.v.e
analyze -update -format Verilog -lib dw04 DFT_ctr__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_prpg__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_misr__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_lfsr__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_lfsr__257.v.e
analyze -update -format Verilog -lib dw04 DFT_compact__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_outcompact__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_diag__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_mux4to1__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_mux4to1__str.v.e
analyze -update -format Verilog -lib dw04 DFT_mux8to1__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_mux16to1__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_mux16to1__tri.v.e
analyze -update -format Verilog -lib dw04 DFT_sel48to16__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_sel64to16__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_sel512to64__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selcontrol__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selshadow__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selshifter__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selshifters__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selxbist__rtl.v.e
analyze -update -format Verilog -lib dw04 DFT_selxbists__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_8b10b_dec__rtl.v.e
analyze -update -format Verilog -lib dw04 DW_8b10b_enc__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw04/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw04.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw04 DW_8b10b_enc__lpwr.v.e
analyze -update -format Verilog -lib dw04 DW_8b10b_dec__lpwr.v.e
analyze -update -format Verilog -lib dw04 DW_lp_piped_ecc__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/dw/dw05/src
/bin/rm -rf $SYNOPSYS/dw/dw05/lib $SYNOPSYS/dw/dw05/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw05/lib/dw05
/bin/mkdir -p $SYNOPSYS/dw/dw05/lib87/dw05
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw05.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw05 DW05_components.vhd
analyze -update -format VHDL -lib dw05 DW_arb_2t.vhd
analyze -update -format VHDL -lib dw05 DW_arb_dp.vhd
analyze -update -format VHDL -lib dw05 DW_arb_fcfs.vhd
analyze -update -format VHDL -lib dw05 DW_arb_rr.vhd
analyze -update -format VHDL -lib dw05 DW_arb_sp.vhd
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw05 DW_arb_2t__rtl.v.e
analyze -update -format Verilog -lib dw05 DW_arb_dp__rtl.v.e
analyze -update -format Verilog -lib dw05 DW_arb_fcfs__rtl.v.e
analyze -update -format Verilog -lib dw05 DW_arb_rr__rtl.v.e
analyze -update -format Verilog -lib dw05 DW_arb_sp__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw05/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw05.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw05 DW_arb_dp__lpwr.v.e
analyze -update -format Verilog -lib dw05 DW_arb_sp__lpwr.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/dw/dw06/src
/bin/rm -rf $SYNOPSYS/dw/dw06/lib $SYNOPSYS/dw/dw06/lib87
/bin/mkdir -p $SYNOPSYS/dw/dw06/lib/dw06
/bin/mkdir -p $SYNOPSYS/dw/dw06/lib87/dw06
$dc_shell <<++ |& tee $SYNOPSYS/dw_analyze_syn.dw06.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
analyze -update -format VHDL -lib dw06 DW06_components.vhd
analyze -update -format VHDL -lib dw06 DW_ram_rw_s_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_rw_s_lat.vhd
analyze -update -format VHDL -lib dw06 DW_ram_rw_a_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_rw_a_lat.vhd
analyze -update -format VHDL -lib dw06 DW_ram_r_w_s_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_r_w_s_lat.vhd
analyze -update -format VHDL -lib dw06 DW_ram_r_w_a_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_r_w_a_lat.vhd
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_s_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_s_lat.vhd
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_a_dff.vhd
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_a_lat.vhd
analyze -update -format VHDL -lib dw06 DW_fifo_s1_df.vhd
analyze -update -format VHDL -lib dw06 DW_fifo_s1_sf.vhd
analyze -update -format VHDL -lib dw06 DW_fifo_s2_sf.vhd
analyze -update -format VHDL -lib dw06 DW_asymfifo_s1_sf.vhd
analyze -update -format VHDL -lib dw06 DW_asymfifo_s1_df.vhd
analyze -update -format VHDL -lib dw06 DW_asymfifo_s2_sf.vhd
analyze -update -format VHDL -lib dw06 DW_stack.vhd
analyze -update -format VHDL -lib dw06 DW_ram_r_w_2c_dff.vhd
analyze -update -format VHDL -lib dw06 DW_fifo_2c_df.vhd
analyze -update -format VHDL -lib dw06 DW_lp_fifo_1c_df.vhd
analyze -update -format VHDL -lib dw06 DW_ram_2r_2w_s_dff.vhd
analyze -update -format VHDL -lib dw06 DW_MEM_RW_A_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_RW_S_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_2R_W_A_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_2R_W_S_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_R_W_A_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_R_W_S_LAT.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_RW_A_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_RW_S_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_2R_W_A_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_2R_W_S_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_R_W_A_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_MEM_R_W_S_LAT_STR.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_rw_s_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_rw_a_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_r_w_s_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_r_w_a_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_s_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_ram_2r_w_a_lat_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_fifo_s1_df_rtl.vhd.e
analyze -update -format VHDL -lib dw06 DW_fifo_s1_sf_rtl.vhd.e
analyze -update -format VHDL -lib dw06 DW_fifo_s2_sf_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_asymfifo_s1_sf_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_asymfifo_s1_df_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_asymfifo_s2_sf_str.vhd.e
analyze -update -format VHDL -lib dw06 DW_stack_str.vhd.e
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw06 DW_ram_rw_s_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_rw_a_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_r_w_s_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_r_w_a_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_2r_w_s_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_2r_w_a_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_r_w_2c_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_ram_2r_2w_s_dff__rtl.v.e
analyze -update -format Verilog -lib dw06 DW_fifo_2c_df__rtl.v.e
quit
++
/bin/rm -f command.log

cd $SYNOPSYS/minpower/dw06/src
$dc_shell <<++ |& tee -a $SYNOPSYS/dw_analyze_syn.dw06.log
set hdlin_enable_presto_for_dw true
set hdlin_enable_presto_for_vhdl true
set hdlin_vhdl_std 1993
set hdlin_module_arch_name_splitting true
set synthetic_library { $synlib }
set link_library \$synthetic_library
set suppress_errors  [concat \$suppress_errors {VER-315 VER-225 VER-540 VHD-6 VHDL-2022 VHDL-2023 VHDL-2099 HDL-178 UIO-3}]
set hdlin_vrlg_std $dw_vrlg_std ;
analyze -update -format Verilog -lib dw06 DW_fifo_2c_df__lpwr.v.e
analyze -update -format Verilog -lib dw06 DW_lp_fifo_1c_df__rtl.v.e
quit
++
/bin/rm -f command.log

egrep -i 'warning|error' $SYNOPSYS/dw_analyze_syn.*.log

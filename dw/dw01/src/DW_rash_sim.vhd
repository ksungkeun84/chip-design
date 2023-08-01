--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: a5fd941f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--
-- ABSTRACT:  Arithmetic Shifter - Prefers right direction - DW_rash
--            The DW01_ash components prefers to shift to the left when the
--            shifting distance is positive. This component prefers to shift
--            to the right. The functionality of both components, besides the
--            preferred direction, is basically the same.
--
-- MODIFIED:
--
------------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_rash is
	

begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (A_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter A_width (lower bound: 2)"
        severity warning;
    end if;
    
    if (SH_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter SH_width (lower bound: 1)"
        severity warning;
    end if;     
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

  B <= (others => 'X')  when (Is_x(SH_TC) or Is_x(SH) or (Is_x(DATA_TC) and (A(A_width-1) = '1') )) else
       std_logic_vector(DWF_rash(UNSIGNED(A), UNSIGNED(SH))) when ((DATA_TC = '0') and (SH_TC = '0' or (SH(SH_width-1) = '0'))) else
       std_logic_vector(DWF_rash(SIGNED(A), UNSIGNED(SH))) when ((DATA_TC = '1') and (SH_TC = '0' or (SH(SH_width-1) = '0'))) else
       std_logic_vector(DWF_rash(UNSIGNED(A), SIGNED(SH)))   when (DATA_TC = '0' and SH_TC = '1') else
       std_logic_vector(DWF_rash(SIGNED(A), SIGNED(SH)));
 
-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_rash_cfg_sim of DW_rash is
 for sim
 end for; -- sim
end DW_rash_cfg_sim;
-- pragma translate_on

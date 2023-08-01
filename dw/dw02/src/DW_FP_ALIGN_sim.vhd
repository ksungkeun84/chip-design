--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2007 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca	May 31, 2007
--
-- VERSION:   VHDL Simulation Model - DW_FP_ALIGN
--
-- DesignWare_version: 5e3a9380
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT:  Right logical shift with sticky bit computation
--            This file contains a verification model for an alignment
--            unit (used in floating-point operations) that consists 
--            in a shifter and a logic to detect non-zero bits that 
--            are shifted out of range. 
--
-- MODIFIED:
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_FP_ALIGN is
	

begin

-- pragma translate_off

    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 1)"
        severity warning;
    end if;
    
    if (sh_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter sh_width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  SHFT_STK: process (a, sh)
    variable a_shifted : std_logic_vector(a_width-1 downto 0);
    variable stk_int : std_logic;
    variable sh_dist : integer;
  begin  -- process SHFT_STK
    a_shifted := a;
    sh_dist := CONV_INTEGER(unsigned(sh));
    stk_int := '0';
    if (sh_dist /= 0) then
      for i in 0 to sh_dist-1 loop
        stk_int := stk_int or a_shifted(0);
        a_shifted := '0' & a_shifted(a_width-1 downto 1);
      end loop;
    end if;
    stk <= stk_int;
    b <= a_shifted;
  end process SHFT_STK;

  
-- pragma translate_on

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_FP_ALIGN_cfg_sim of DW_FP_ALIGN is
 for sim
 end for; -- sim
end DW_FP_ALIGN_cfg_sim;
-- pragma translate_on

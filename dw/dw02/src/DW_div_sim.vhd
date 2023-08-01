--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2000 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann         April 4, 2000
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: cf0779fc
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Divider
--            - Uses modeling functions from DW_Foundation package.
-- 
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
--
-- Reto Zimmermann, July 25, 2005
--            - Eliminate operand width restrictions
--
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_div is
	

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
    
    if (b_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter b_width (lower bound: 1)"
        severity warning;
    end if;
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
        severity warning;
    end if;
    
    if ( (rem_mode < 0) OR (rem_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter rem_mode (legal range: 0 to 1)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    
  div: process (a, b)
  begin
    if tc_mode = 0 then
      quotient <= std_logic_vector(DWF_div (unsigned(a), unsigned(b)));
      if rem_mode = 1 then
        remainder <= std_logic_vector(DWF_rem (unsigned(a), unsigned(b)));
      else
        remainder <= std_logic_vector(DWF_mod (unsigned(a), unsigned(b)));
      end if;
    else
      quotient <= std_logic_vector(DWF_div (signed(a), signed(b)));
      if rem_mode = 1 then
        remainder <= std_logic_vector(DWF_rem (signed(a), signed(b)));
      else
        remainder <= std_logic_vector(DWF_mod (signed(a), signed(b)));
      end if;
    end if;
    if Is_X (b) then
      divide_by_0 <= 'X';
    elsif unsigned(b) = 0 then
      divide_by_0 <= '1';
    else
      divide_by_0 <= '0';
    end if;
  end process div;

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_div_cfg_sim of DW_div is
 for sim
 end for; -- sim
end DW_div_cfg_sim;
-- pragma translate_on

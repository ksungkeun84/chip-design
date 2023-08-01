--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2013 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann         Sep 25, 2013
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 5470988d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Combinational Divider with Saturation
--            - Uses modeling functions from DW_Foundation package.
-- 
-- MODIFIED:
--
--  11/04/15  RJK  Change pkg use from individual DW02 pkg to unified DWARE pkg
------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_div_sat is
	

begin

  -- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 2)"
        severity warning;
    end if;
    
    if (b_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter b_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (q_width < 2) OR (q_width > a_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter q_width (legal range: 2 to a_width)"
        severity warning;
    end if;
    
    if ( (tc_mode < 0) OR (tc_mode > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter tc_mode (legal range: 0 to 1)"
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
      quotient <= std_logic_vector(DWF_div_sat (unsigned(a), unsigned(b), q_width));
    else
      quotient <= std_logic_vector(DWF_div_sat (signed(a), signed(b), q_width));
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

configuration DW_div_sat_cfg_sim of DW_div_sat is
 for sim
 end for; -- sim
end DW_div_sat_cfg_sim;
-- pragma translate_on

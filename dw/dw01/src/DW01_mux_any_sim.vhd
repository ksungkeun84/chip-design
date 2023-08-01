--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1992 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Paul Sheit/Rajeev Huralikoppi
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 0f68dc51
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Universal Multiplexer
--
-- MODIFIED: SH		8/19/97
--	Added any_unknown function on SEL input.
-- 08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines	
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW01_mux_any is
	
begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if (A_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter A_width (lower bound: 1)"
        severity warning;
    end if;
     
    if (SEL_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter SEL_width (lower bound: 1)"
        severity warning;
    end if;
     
    if (MUX_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter MUX_width (lower bound: 1)"
        severity warning;
    end if;
     
    if ( (bal_str < 0) OR (bal_str > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter bal_str (legal range: 0 to 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
    
  MUX(MUX_width-1 downto 0) <= (others => 'X') when Is_x(SEL) else
    A( ((CONV_INTEGER(UNSIGNED(SEL))+1)*MUX_width)-1 downto (CONV_INTEGER(UNSIGNED(SEL))*MUX_width) )
  when ((CONV_INTEGER(UNSIGNED(SEL))*MUX_width) < A_width) else
    (others => '0');
-- pragma translate_on 
end sim; 
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_mux_any_cfg_sim of DW01_mux_any is
 for sim
 end for; -- sim
end DW01_mux_any_cfg_sim;
-- pragma translate_on

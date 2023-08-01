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
-- AUTHOR:    Paul Scheidt/Rajeev Huralikoppi
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 561d0f1f
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--
-- ABSTRACT:  Incrementer
--
-- MODIFIED:
-- 08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW01_inc is
	
  signal tmp_out : std_logic_vector(width-1 downto 0);
begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if (width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

    tmp_out <= (others => 'X') when (Is_X(A)) else (UNSIGNED(A)) + 1;
    SUM <= tmp_out;
  -- pragma translate_on
end sim;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_inc_cfg_sim of DW01_inc is
 for sim
 end for; -- sim
end DW01_inc_cfg_sim;
-- pragma translate_on

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
-- DesignWare_version: 20c31107
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

 
-----------------------------------------------------------------------------------
--
-- ABSTRACT:    Adder
--
-- MODIFIED:
-- 08/28/2002   RPH     Rewrote the model according to the new coding
--                      Guidelines
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW01_add is
	
-- pragma translate_off
  signal tmp_out : std_logic_vector(width downto 0);
-- pragma translate_on
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

    tmp_out <= (others => 'X') when (Is_X(A) or Is_X(B)) else
               ((UNSIGNED('0' & A)) + (UNSIGNED('0' & B)) + CI);
    CO  <= tmp_out(width);
    SUM <= tmp_out(width-1 downto 0);
    
-- pragma translate_on
end sim; 
-----------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_add_cfg_sim of DW01_add is
 for sim
 end for; -- sim
end DW01_add_cfg_sim;
-- pragma translate_on

--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2001 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann    11/14/01
--
-- VERSION:   VHDL Simulation Model for DW_gray2bin
--
-- DesignWare_version: 6ccf55ef
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Gray to Binary Code Converter
--
-- MODIFIED:
--
--  08/28/2002  RPH             Added X-processing
--   
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_gray2bin is
	

begin

  -- pragma translate_off
  -----------------------------------------------------------------------------
  -- Parameter legality check
  -----------------------------------------------------------------------------

  
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
    
  -----------------------------------------------------------------------------
  -- Behavioral model
  -----------------------------------------------------------------------------

  b <= (others => 'X') when Is_x(g) else DWF_gray2bin (g);

  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_gray2bin_cfg_sim of DW_gray2bin is
 for sim
 end for; -- sim
end DW_gray2bin_cfg_sim;
-- pragma translate_on

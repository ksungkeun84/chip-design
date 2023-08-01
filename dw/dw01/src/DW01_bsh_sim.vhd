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
-- AUTHOR:    Rajeev Huralikoppi
--
-- VERSION:   VHDL Simulation Model  
--
-- DesignWare_version: b0ac9e2b
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT:  Barrel Shifter
--
-- MODIFIED: SS  April 8, 1996
--   Fixed simulation bug for parameters A_width = 17 SH_width = 5 
--					         = 9           = 4
--						 = 5	       = 3
--
-- MODIFIED:          
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines------
---------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW01_bsh is
	
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
    
  B <= (others => 'X') when Is_X(SH) else DWF_bsh(A, SH);

  -- pragma translate_on
end sim ;
------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_bsh_cfg_sim of DW01_bsh is
 for sim
 end for; -- sim
end DW01_bsh_cfg_sim;
-- pragma translate_on

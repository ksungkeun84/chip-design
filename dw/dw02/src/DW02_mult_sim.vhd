--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1994 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    RPH	    Dec. 21, 1994
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: d71508cf
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
-- ABSTRACT:  Multiplier
--
-- HISTORY: Jay Zhu 08/25/98	STAR 56715 work-around
--				(The final fixing should be done
--				by DWS.  After the formal fixing,
--				this work around should be backed off).
--
--	    RJK  11/24/98	Enhance the handling of non '0', non '1' inputs
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW02_mult is
	

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
       
    if (B_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter B_width (lower bound: 1)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    PRODUCT <= (others => 'X') when (Is_X(A) or Is_X(B) or Is_X(TC)) else
               ((SIGNED(A)) * (SIGNED(B))) when TC = '1' else
               ((UNSIGNED(A)) * (UNSIGNED(B)));
  
-- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW02_mult_cfg_sim of DW02_mult is
 for sim
 end for; -- sim
end DW02_mult_cfg_sim;
-- pragma translate_on

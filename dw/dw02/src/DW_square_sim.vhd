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
-- AUTHOR:    RJK/RPH	Dec. 21, 1994/Aug 22, 2002
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: bff6557d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Integer square
--
-- HISTORY:  RJK	Initial model derived from sim model of DW02_mult
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_square is
	

begin  -- sim
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

    square <= (others => 'X') when (Is_X(A) or Is_X(TC)) else
    (SIGNED(A) * SIGNED(A)) when TC = '1' else
    ((UNSIGNED(A)) * (UNSIGNED(A)));  
-- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_square_cfg_sim of DW_square is
 for sim
 end for; -- sim
end DW_square_cfg_sim;
-- pragma translate_on

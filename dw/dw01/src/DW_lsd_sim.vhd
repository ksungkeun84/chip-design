--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann	Mar. 22, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: fd95d39d
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Leading Signs Detector
--           - Uses modeling functions from DW_Foundation package.
--
--           Note: Only for the simulation model, X's will be handled in
--                 the following manner.  If an X is in a sign or the first
--                 non-sign bit position, then the outputs enc and dec get
--                 all X's.  If an X is after the first non-sign bit position,
--                 the outputs enc and dec get the expected non-X values.
--
-- MODIFIED:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation.all;

architecture sim of DW_lsd is
	

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
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  enc <= DWF_lsd_enc (a);
  dec <= DWF_lsd (a);

  -- pragma translate_on 

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_lsd_cfg_sim of DW_lsd is
 for sim
 end for; -- sim
end DW_lsd_cfg_sim;
-- pragma translate_on

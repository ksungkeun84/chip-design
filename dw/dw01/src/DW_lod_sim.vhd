--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2005 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Doug Lee    Jul. 8, 2005
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 7c03c545
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Leading Ones Detector
--           Returns the number of bit position from the 
--           left where the first "0" is found as the 'encoded'
--           value.  And returns a one-hot 'decoded' value
--           from the input vector.
--
--           Note: Only for the simulation model, x's will be handled in
--                 the following manner.  If an "x" is the first non-zero
--                 bit value found, then the outputs enc & dec get all x's.
--                 If an "x", is in the "a" input, but a "0" is encountered
--                 at a higher bit position, then the outputs enc & dec get
--                 the expected non-X values.
--
-- MODIFIED:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DW_foundation.all;

architecture sim of DW_lod is
	

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

   dec <= DWF_lod(a);
   enc <= DWF_lod_enc(a);
  -- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_lod_cfg_sim of DW_lod is
 for sim
 end for; -- sim
end DW_lod_cfg_sim;
-- pragma translate_on

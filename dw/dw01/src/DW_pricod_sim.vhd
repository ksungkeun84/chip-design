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
-- AUTHOR:    Reto Zimmermann    Sept. 15, 2006
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 28a5efa5
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Priority Coder
--           Returns a one-hot coded output that indicates the highest
--           non-zero bit position.  An extra bit (MSB) indicates whether all
--           input bits are zero.
--
--           Note: Only for the simulation model, x's will be handled in
--                 the following manner.  If an "x" is the first non-zero
--                 bit value found, then the output cod gets all x's.
--                 If an "x", is in the "a" input, but a "1" is encountered
--                 at a higher bit position, then the output cod gets
--                 the expected non-x values.
--
-- MODIFIED:
--
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_foundation.all;

architecture sim of DW_pricod is
	

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

  cod <= DWF_pricod (a);
  zero <= not or_reduce (a);

  -- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_pricod_cfg_sim of DW_pricod is
 for sim
 end for; -- sim
end DW_pricod_cfg_sim;
-- pragma translate_on

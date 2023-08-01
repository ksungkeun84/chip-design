----------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2004 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Bruce Dean Aug 15 2007
--
-- VERSION:   Entity
--
-- DesignWare_version: ea3282ff
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--
--  ABSTRACT: Leading zero anticipator (LZA) for addition
--           The LZA - leading zero anticipation module works under
--           some basic conditions:
--           1. B is subtracted from A, and the result is expected to have 2
--              or more zeros. The case when only 1 zero happens, will require 
--              normalization.
--           2. The output is maximum when the vector should have all its bit 
--              positions shifted to the left during normalization. No 1-bit
--              is detected by the anticipator in the bit-vector
--           3. The estimation is not exact, and may have a value that is 1
--              less than the exact value. From the original algorithm, the
--              result may be 2 less than the exact, but a filtering process
--              was put in place to correct the error to only 1.
--              because Alex is so damn smart.  
--
--             Parameters:     Valid Values
--             ==========      ============
--             width           2-256 (?)
--
--             Input Ports:    Size      Description
--             ===========     ====      ===========
--             a               width-1:0 a input
--             b               width-1:0 b input
--
--             Output Ports    Size                Description
--             ============    ====                ===========
--             count           ceil(log2(width))   number of leading zero's
--
--
--
--
--  MODIFIED:
--           JBD 9/07 Original simulation model
--
-------------------------------------------------------------------------------
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_foundation.all;
--
architecture sim of DW_lza is
	
begin
  -- pragma translate_off
  
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if ( (width < 2) OR (width > 256) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter width (legal range: 2 to 256)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
  count <= (others => 'X') when (Is_X(a) or Is_X(b)) else DWF_lza(a,b);
  -- pragma translate_on
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_lza_cfg_sim of DW_lza is
 for sim
 end for; -- sim
end DW_lza_cfg_sim;
-- pragma translate_on

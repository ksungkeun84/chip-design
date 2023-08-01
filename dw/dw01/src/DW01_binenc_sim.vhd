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
-- DesignWare_version: 1e5631a8
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Binary Encoder
--
-- MODIFIED:    Suzanne Skracic	May, 13 1996
--                              added configuration
--              RPH             Jan 22, 1998
--                              Modified to handle 'X' at the inputs.
--
--              Rick Kelly      STAR 103007
--              RPH             Removed bus_01X and DWARE libraries
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines----
--
--  01/12/2005  Doug Lee        Changed lower bound check for ADDR_width
--------------------------------------------------------------------------
 
library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW01_binenc is
	
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
     
    if (ADDR_width < bit_width(A_width)) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter ADDR_width (lower bound: bit_width(A_width))"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;
         
  ADDR <= DWF_binenc(A,ADDR_width);
                                             
  -- pragma translate_on 
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_binenc_cfg_sim of DW01_binenc is
 for sim
 end for; -- sim
end DW01_binenc_cfg_sim;
-- pragma translate_on

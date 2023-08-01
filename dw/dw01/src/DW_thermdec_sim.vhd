--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2008 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Alexandre Tenca   Feb 2008
--
-- VERSION:   VHDL Simulation Model - DW_thermdec
--
-- DesignWare_version: ad2d3770
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT: Binary Thermometer decoder 
--           A binary thermometer decoder of an n-bit input has 2^n outputs.
--           Each output corresponds to one value of the binary input, and 
--           for an input value i, all the outputs corresponding to j<=i area
--           active.
--           eg. n=3 
--           A(2:0) en     B(7:0)
--           000    1   -> 00000001
--           001    1   -> 00000011
--           010    1   -> 00000111
--           011    1   -> 00001111
--           100    1   -> 00011111
--           101    1   -> 00111111
--           110    1   -> 01111111
--           111    1   -> 11111111
--           xxx    0   -> 00000000
-- 
--              parameters      valid values (defined in the DW manual)
--              ==========      ============
--              width           input size
--
--              Input ports     Size & Description
--              ===========     ==================
--              a               width bits
--                              Input to be decoded
--              en              bit
--                              Enable 
--
--              Output ports    Size & Description
--              ===========     ==================
--              b               2**width bits
--                              Decoded output for value in port a
--
-- MODIFIED:
--
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_thermdec is
	

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

  THERMDEC: process (a, en)
    variable a_val : integer;
    variable temp_out : std_logic_vector(2**width-1 downto 0);
    variable i : integer;
  begin  -- process BINDEC
    temp_out := (others => '0');
    a_val := CONV_INTEGER(unsigned(a));
    for i in 0 to a_val loop
      temp_out(i) := '1';
    end loop;
    if (Is_X(a) or Is_X(en)) then
      b <= (others => 'X');
    else
      if (en = '0') then
        b <= (others => '0');
      else
        b <= temp_out;
      end if;
    end if;
  end process THERMDEC;

  
-- pragma translate_on

end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_thermdec_cfg_sim of DW_thermdec is
 for sim
 end for; -- sim
end DW_thermdec_cfg_sim;
-- pragma translate_on

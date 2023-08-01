--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1999 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann    July 21, 1999
--
-- VERSION:   VHDL Simulation Model for DW_minmax
--
-- DesignWare_version: e0b0dee4
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Behavioral model of minimum/maximum value detector/selector
--
-- MODIFIED:
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;


architecture sim of DW_minmax is
	

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
    
    if (num_inputs < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter num_inputs (lower bound: 2)"
        severity warning;
    end if;
  
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

  minmax: process (a, tc, min_max)
    variable tc_v, min_max_v : std_logic;
    variable a_v : std_logic_vector(num_inputs*width-1 downto 0);
    variable value_v : std_logic_vector(width-1 downto 0);
    variable value_uns_v : unsigned(width-1 downto 0);
    variable value_sgn_v : signed(width-1 downto 0);
    variable index_v : std_logic_vector(bit_width(num_inputs)-1 downto 0);  
  begin
    a_v := a;
    tc_v := To_X01(tc);
    min_max_v := To_X01(min_max);
    value_v := (others => 'X');
    index_v := (others => 'X');
    if tc_v = '0' then
      if min_max_v = '0' then
        MIN_UNSIGNED (unsigned(a_v), value_uns_v, index_v);
        value_v := std_logic_vector(value_uns_v);
      elsif min_max_v = '1' then
        MAX_UNSIGNED (unsigned(a_v), value_uns_v, index_v);
        value_v := std_logic_vector(value_uns_v);
      end if;
    elsif tc_v = '1' then
      if min_max_v = '0' then
        MIN_SIGNED (signed(a_v), value_sgn_v, index_v);
        value_v := std_logic_vector(value_sgn_v);
      elsif min_max_v = '1' then
        MAX_SIGNED (signed(a_v), value_sgn_v, index_v);
        value_v := std_logic_vector(value_sgn_v);
      end if;
    end if;
    value <= value_v;
    index <= index_v;
  end process minmax;
  -- pragma translate_on

end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_minmax_cfg_sim of DW_minmax is
 for sim
 end for; -- sim
end DW_minmax_cfg_sim;
-- pragma translate_on

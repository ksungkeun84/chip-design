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
-- DesignWare_version: 1335a2c6
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--
-- ABSTRACT:  6-Function Comparator
--           GT: A > B  
--           LT: A < B 
--           EQ: A = B 
--           LE: A =< B 
--           GE: A >= B
--           NE: A /= B
--
-- MODIFIED: Sourabh    Dec. 1998              Modified for X handling
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW01_cmp6 is
	
  -- purpose: determines if the input A is equal to, less than or greater than B
  function eq_lt_gt (
    A, B : std_logic_vector;
    TC   : std_logic)
    return integer is 
      variable result : integer range -1 to 2;
    begin  -- eq_lt_gt

      if (TC = '0') then
        if (unsigned(A) = unsigned(B)) then
          result := 0;
        elsif (unsigned(A) < unsigned(B)) then
          result := 1;
        else
          result := 2;
        end if;
      else
        if (signed(A) = signed(B)) then
          result := 0;
        elsif (signed(A) < signed(B)) then
          result := 1;
        else
          result := 2;
        end if;          
      end if;
      return(result);
    end eq_lt_gt;
  
  signal result : integer range -1 to 2;
  
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

  
  result <= -1 when (Is_x(TC) or Is_x(A) or Is_x(B) ) else
    eq_lt_gt(A, B, TC);

  GT <=
    'X' when result = -1 else
    '0' when (result = 0 or result = 1) else
    '1';
  LT <=
    'X' when result = -1 else
    '0' when (result = 0 or result = 2) else
    '1';
  EQ <=
    'X' when result = -1 else
    '0' when (result = 1 or result = 2) else
    '1';
  LE <=
    'X' when result = -1 else
    '1' when (result = 0 or result = 1) else
    '0';
  GE <=
    'X' when result = -1 else
    '1' when (result = 0 or result = 2) else
    '0';
  NE <=
    'X' when result = -1 else
    '1' when (result = 1 or result = 2) else
    '0';
  -- pragma translate_on
end sim;

---------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_cmp6_cfg_sim of DW01_cmp6 is
 for sim
 end for; -- sim
end DW01_cmp6_cfg_sim;
-- pragma translate_on

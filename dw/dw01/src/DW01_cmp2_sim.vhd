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
-- DesignWare_version: 27008746
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-- 
-- ABSTRACT:  2-Function Comparator
--           When LEQ = '1'   LT_LE: A =< B
--                            GE_GT: A > B
--           When LEQ = '0'   LT_LE: A < B
--                            GE_GT: A >= B
--
-- MODIFIED:   Sourabh    Dec. 1998
--             Modified for X handling
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW01_cmp2 is
	
  -- pragma translate_off
  -- purpose: Determines if the input A is less than or equal to  B
  function num_less (
    A, B : std_logic_vector;
    TC   : std_logic)
    return integer is 
      variable result : integer range 0 to 1;
    begin  -- eq_lt
      if (TC = '0') then
        if (unsigned(A) < unsigned(B)) then
          result := 1;
        else
          result := 0;
        end if;
      else
        if (signed(A) < signed(B)) then
          result := 1;
        else
          result := 0;
        end if;          
      end if; 
      return(result);
    end num_less;

  function num_equal (
    A, B : std_logic_vector;
    TC   : std_logic)
    return integer is 
      variable result : integer range 0 to 1;
    begin  -- eq_lt
      if (TC = '0') then
        if (unsigned(A) = unsigned(B)) then
          result := 1;
        else
          result := 0;
        end if;
      else
        if (signed(A) = signed(B)) then
          result := 1;
        else
          result := 0;
        end if;          
      end if; 
      return(result);
    end num_equal;
  
  signal is_less : integer range 0 to 1;
  signal is_equal : integer range 0 to 1;
  -- pragma translate_on
  
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

    is_less  <= num_less(A, B, TC);
    is_equal <= num_equal(A, B, TC);
  
    GE_GT <= 
    'X' when (Is_x(TC) or Is_X(LEQ) or Is_x(A) or Is_x(B) ) else
    '0' when ((LEQ = '1') and (is_less = 1 or is_equal = 1)) else
    '0' when ((LEQ = '0') and (is_less = 1 and is_equal = 0)) else
    '1';
  
    LT_LE <= 
    'X' when (Is_x(TC) or Is_X(LEQ) or Is_x(A) or Is_x(B) ) else
    '1' when ((LEQ = '1') and (is_less = 1 or is_equal = 1)) else
    '1' when ((LEQ = '0') and (is_less = 1 and is_equal = 0)) else
    '0';


-- pragma translate_on
  
end sim;
---------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW01_cmp2_cfg_sim of DW01_cmp2 is
 for sim
 end for; -- sim
end DW01_cmp2_cfg_sim;
-- pragma translate_on

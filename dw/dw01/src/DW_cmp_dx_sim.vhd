--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 1998 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Sourabh Tandon		Oct. 1998
--
-- VERSION:   VHDL Simulation Model
--
-- DesignWare_version: 2a0d6b84
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT:  Duplex Comparator
--  08/28/2002  RPH             Rewrote the model according to the new coding
--                              Guidelines
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture sim of DW_cmp_dx is
	

  -- purpose: Determines if the input A is less than or equal to  B
  function num_less (
    A, B : std_logic_vector;
    TC   : std_logic)
    return integer is 
      variable result : integer range 0 to 1;
    begin
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
    begin
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
  
  signal is_less_1  : integer range 0 to 1;
  signal is_equal_1 : integer range 0 to 1;
  signal is_less_2  : integer range 0 to 1;
  signal is_equal_2 : integer range 0 to 1;
    
begin
  -- pragma translate_off
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
     
    if (width < 4) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter width (lower bound: 4)"
        severity warning;
    end if;
     
    if ( (p1_width < 2) OR (p1_width > width-2) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter p1_width (legal range: 2 to width-2)"
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;

    is_less_1  <= num_less(A(p1_width-1 downto 0), B(p1_width-1 downto 0), '0') when dplx = '0' else
                  num_less(A(p1_width-1 downto 0), B(p1_width-1 downto 0), TC);
    is_equal_1 <= num_equal(A(p1_width-1 downto 0), B(p1_width-1 downto 0), '0') when dplx = '0' else
                  num_equal(A(p1_width-1 downto 0), B(p1_width-1 downto 0), TC);
    
    is_less_2  <= num_less(A, B, TC) when dplx = '0' else
                  num_less(A(width-1 downto p1_width), B(width-1 downto p1_width), TC);
    is_equal_2 <= num_equal(A, B, TC) when dplx = '0' else
                  num_equal(A(width-1 downto p1_width), B(width-1 downto p1_width), TC);

    lt1 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_less_1 = 1 and is_equal_1 = 0) else
     '0';
    eq1 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_equal_1 = 1 and is_less_1 = 0) else
     '0';
    gt1 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_less_1 = 0 and is_equal_1 = 0) else
     '0';

    lt2 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_less_2 = 1 and is_equal_2 = 0 ) else
     '0';
    eq2 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_less_2 = 0 and is_equal_2 = 1) else
     '0';
    gt2 <=
     'X' when (Is_x(tc) or Is_X(dplx) or Is_x(a) or Is_x(b) ) else
     '1' when (is_less_2 = 0 and is_equal_2 = 0 ) else
     '0';

    -- pragma translate_on
end sim;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_cmp_dx_cfg_sim of DW_cmp_dx is
 for sim
 end for; -- sim
end DW_cmp_dx_cfg_sim;
-- pragma translate_on

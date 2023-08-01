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
-- AUTHOR:    Alexandre F. Tenca
--
-- VERSION:   VHDL Simulation Model for DW_norm
--
-- DesignWare_version: 0585e708
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--
-- ABSTRACT:  Normalization unit
--           This component shifts the input bit vector to the left till
--           the resulting vector has a 1 in the MS bit position. Parameters
--	     control the size of the input and output and the search limit
--           for the MS 1 bit. The input and output must be of the same   
--           size. 
--
-- MODIFIED:  1/09/2006 - AFT - index stays at the maximum value when there is no value
--                         1 in the search window.
--           09/30/2008 - AFT - modified to include a parameter that controls if the 
--                         number of bit positions shifted to the left during 
--                         normalization is added (exp_ctr=0) or subtracted 
--                         (exp_ctr=1) from the exp_offset input.
--           06/19/2012 - RJK - Added parameter checking for exp_width as it relates
--                         to srch_wind (STAR 9000541092)
--
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_norm is
	
-- pragma translate_off
-- function that detects the MS 1 bit in the window given by Search_limit
-- returns the number of bits that are zeros on the MS bit positions
-- The exp_width must be at least log2(search_window)+1
 function ms_one_index (arg: std_logic_vector) return integer is
   variable index: integer range 0 to a_width-1;
 begin -- search for the MS 1 in the search window...

   index := 0;
   while (arg(a_width-1-index) = '0' and 
	  index < a_width-1 and 
          index < srch_wind-1) loop
      index := index + 1;
   end loop;
   return (index);

 end ms_one_index;

signal Index: integer range 0 to a_width-1;
signal unsigned_index: unsigned (exp_width-1 downto 0);
signal unsigned_search_limit: unsigned (a_width-1 downto 0);
signal adjusted_offset: unsigned (exp_width-1 downto 0);
signal ovfl_int : std_logic;
-- pragma translate_on  
begin
-- pragma translate_off
  
    
  parameter_check : process
    variable param_err_flg : integer := 0;
  begin
    
    
    if (a_width < 2) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter a_width (lower bound: 2)"
        severity warning;
    end if;
    
    if ( (srch_wind < 2) OR (srch_wind > a_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter srch_wind (legal range: 2 to a_width)"
        severity warning;
    end if;     
    
    if (exp_width < 1) then
      param_err_flg := 1;
      assert false 
        report "ERROR: Invalid value for parameter exp_width (lower bound: 1)"
        severity warning;
    end if;     
    
    if ( (exp_ctr < 0) OR (exp_ctr > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_ctr (legal range: 0 to 1)"
        severity warning;
    end if;     
    
    if ( (2**exp_width) < srch_wind ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid combination of srch_wind and exp_width values.  The srch_wind value cannot exeed 2**exp_width value."
        severity warning;
    end if;
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  
  Index <= ms_one_index (a);
  unsigned_index <= conv_unsigned(Index, exp_width);
  adjusted_offset <= unsigned(exp_offset) - unsigned_index when (exp_ctr=1) else
                     unsigned(exp_offset) + unsigned_index;  
  exp_adj <= (others => 'X') when (Is_x(a) or Is_x(exp_offset) ) else
             dw_conv_std_logic_vector (adjusted_offset,exp_width); 
  b <= (others => 'X') when (Is_x(a) or Is_x(exp_offset) ) else 
       dw_conv_std_logic_vector( SHL(UNSIGNED(a),unsigned_index ), a_width );
  no_detect <= 'X' when (Is_x(a) or Is_x(exp_offset) ) else
	    	  '1' when a(a_width-1-Index) = '0' else
                  '0';
  ovfl_int <= '1' when ((adjusted_offset > unsigned(exp_offset)) and (exp_ctr=1)) else
              '1' when ((adjusted_offset < unsigned(exp_offset)) and 
                        (adjusted_offset < unsigned_index) and (exp_ctr=0))  else
              '0';
  ovfl <= 'X' when (Is_x(a) or Is_x(exp_offset) ) else ovfl_int;

-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_norm_cfg_sim of DW_norm is
 for sim
 end for; -- sim
end DW_norm_cfg_sim;
-- pragma translate_on

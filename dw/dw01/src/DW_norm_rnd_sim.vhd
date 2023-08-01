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
-- VERSION:   VHDL Simulation Model for DW_norm_rnd
--
-- DesignWare_version: a93834af
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- ABSTRACT:  Normalization and Rounding unit
--           This component generates a normalized and rounded value from an 
--           initial input in the form x.xxxxxxx (1 integer bit and k fractional
--           bits). The module has the following inputs:
--            * Main input (a_mag) to be normalized and rounded to n < k-1 fractional bits
--            * pos_offset: number of bit positions that the binary point in the input
--              had to be adjusted in order to be in the appropriate format.
--            * sticky_bit: 1 when some bit after the LS bit in the main input has 
--              a 1 (in the infinite precision representation of the input A).
--            * a_sign: Sign of the number being rounded (0 - positive, 1 - negative)
--            * Rnd_mode: Type of rounding to be performed. The options are:
--               - RNE - Round to the nearest even
--               - Rzero - Round toward zero
--               - Rposinf - Round toward positive infinity
--               - Rneginf - Round toward negative infinity
--               - Rup - Round to the nearest up
--               - Raway - Round away from zero.
--           The module has the following parameters:
--            * Input width (number of fractional bits) = a_width
--            * Output width (number of fractional bits) = b_width
--            * srch_wind: number of bits that the unit should look for the MS 1
--            * exp_widht: number of bits used in the pos_offset input and the pos output
--           It is imposed that b_width < a_width - srch_wind - 1 for proper 
--           rounding. It is also assumed that all the bits applied as input are
--           correct (correspond to the same bits in an infinite precision 
--           representation of the Main input (a_mag))  
--           The module outpus are:
--            * b - normalized and rounded result
--            * pos - Exponent correction value. This output accounts for the 
--                    Offset input and any changes in the value during normalization
--                    and rounding.
--            * no_detect - 1 when the normalization was not possible with the
--                    search window provided as parameter. Input is unexpected or
--                    the input represents a denormal value.
--            * pos_err - 1 when there is an overflow in the computation of the
--                    exponent adjustment value. Overflow may happen during 
--                    normalization or during rounding phase.
--
-- MODIFIED:
--           10/25: depending on the new parameter exp_ctr, the output pos will
--           have the value: pos_pffset+shifted_norm-1_bit_post_round when
--           when exp_ctr=0 (previous bahavior) or will have the value:
--           pos_offset-shifted_norm-1_bit_post_round when exp_ctr=1
--           Where shifter_pos_norm corresponds to the number of bit positions
--           shifted during normalization and 1_bit_post_round corresponds
--           to the correction of 1 when post-round normalization is required
--           10/3/2016 - AFT : added code to avoid an error when parameter
--           a_width == b_width or when a_width == (b_width-1) (out of bounds)
--           described on STAR 9001102004 (and previous star 9000999112).
--
---------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use DWARE.DW_Foundation_arith.all;

architecture sim of DW_norm_rnd is
	
-- pragma translate_off
-- function that detects the number of zeros at the left of the MS 1 bit in the 
-- window given by srch_wind.
-- Returns srch_wind-1 when a MS 1 was not found
-- The exp_width must be at least log2(srch_wind)+1
 function num_MS_zeros (A: std_logic_vector) return integer is
   variable index: integer range 0 to A_width-1;
 begin -- search for the MS 1 in the search window...

   index := 0;
   while (A(a_width-1-index) = '0' and 
	  index < a_width-1 and 
          index < srch_wind-1) loop
      index := index + 1;
   end loop;
   return (index);

 end num_MS_zeros;
-- function that detects when the input is negative and returns 0 in this
-- case. When the input is positive or zero, the value is returned without
-- modification.
function bound_index(a: in integer) return integer is
  begin
    if (a < 0) then
      return 0;
    else
      return a;
    end if;
  end function;

signal Index: integer range 0 to a_width-1;
signal unsigned_index: unsigned (exp_width-1 downto 0);
signal unsigned_search_limit: unsigned (a_width-1 downto 0);
signal adjusted_offset: unsigned (exp_width-1 downto 0);
signal A_norm: unsigned (a_width-1 downto 0);
signal A_norm_std: std_logic_vector (a_width-1 downto 0);
signal overflow_norm, overflow_norm_int: std_logic;
signal overflow_rounding: std_logic;
signal overflow_expo_incrementer: std_logic;
signal Exp_adjustment: std_logic_vector (exp_width-1 downto 0);
signal corrected_expo: std_logic_vector (exp_width downto 0);
signal zero_vector_e, one_vector_e: std_logic_vector (exp_width downto 0);
signal zero_vector_b, one_vector_b: std_logic_vector (b_width downto 0);
signal rnd: std_logic;
signal R, L, T: std_logic; -- bits used in the rounding procedure
signal A_rounded: unsigned (b_width downto 0);

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
    
    if ( (b_width < 2) OR (b_width > a_width) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter b_width (legal range: 2 to a_width)"
        severity warning;
    end if;
    
    if ( (exp_ctr < 0) OR (exp_ctr > 1) ) then
      param_err_flg := 1;
      assert false
        report "ERROR: Invalid value for parameter exp_ctr (legal range: 0 to 1)"
        severity warning;
    end if;     
    
    assert param_err_flg = 0
      report "Simulation aborted due to invalid parameter value(s)" 
      severity failure;

    wait;

  end process parameter_check;  

-- reproduce the behavior of the normalization block
  Index <= num_MS_zeros (a_mag);
  unsigned_index <= conv_unsigned(Index, exp_width);
  adjusted_offset <= unsigned(pos_offset) - unsigned_index when (exp_ctr=1) else
                     unsigned(pos_offset) + unsigned_index;  
  Exp_adjustment <= (others => 'X') when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) ) else
         dw_conv_std_logic_vector (adjusted_offset,exp_width); 
  A_norm <=  SHL(UNSIGNED(a_mag), unsigned_index);
--  probe <= dw_conv_std_logic_vector (Index, probe'length);
  no_detect <= 'X' when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) ) else
	    	  '1' when a_mag(a_width-1-Index) = '0' else
                  '0';
  overflow_norm_int <= '1' when ((adjusted_offset > unsigned(pos_offset)) and (exp_ctr=1)) else
                       '1' when ((adjusted_offset < unsigned(pos_offset)) and 
                        (adjusted_offset < unsigned_index) and (exp_ctr=0))  else
                       '0';
  overflow_norm <= 'X' when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) ) else
	           overflow_norm_int;
-- include the rouding logic
  zero_vector_e <= (others => '0');
  zero_vector_b <= (others => '0');
  one_vector_e <= zero_vector_e(one_vector_e'length-2 downto 0) & '1';
  one_vector_b <= zero_vector_b(one_vector_b'length-2 downto 0) & '1';
  corrected_expo <=  '0'&Exp_adjustment when overflow_rounding = '0' else
                     dw_conv_std_logic_vector(unsigned('0'&Exp_adjustment) + unsigned(one_vector_e),exp_width+1) when ((overflow_rounding = '1') and (exp_ctr=1)) else
                     dw_conv_std_logic_vector(unsigned('0'&Exp_adjustment) - unsigned(one_vector_e),exp_width+1);
  pos <= (others => 'X') when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) ) else corrected_expo(exp_width-1 downto 0);
  overflow_expo_incrementer <=  corrected_expo(exp_width);
  pos_err <= overflow_norm xor overflow_expo_incrementer;
--  if any other bits are left in the LS bit positions after normalization, 
--  combine then with the sticky bit.
  A_norm_std <= std_logic_vector (A_norm);
  T <= sticky_bit or or_reduce(A_norm_std(a_width-b_width-2 downto 0)) when (a_width > b_width+1) else
       sticky_bit;
  R <= A_norm_std(bound_index(a_width-b_width-1)) when (a_width > b_width) else '0'; 
  L <= A_norm_std(bound_index(a_width-b_width)) when (a_width > b_width-1) else '0';
  rnd <= 'X' when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) or Is_x(Sticky_bit) or Is_x(a_sign)) else 
         R and (L or T)          when rnd_mode = "000"  else
         '0'                     when rnd_mode = "001"  else
         not a_sign and (R or T) when rnd_mode = "010"  else
         a_sign and (R or T)     when rnd_mode = "011"  else
         R                       when rnd_mode = "100"  else
         R or T                  when rnd_mode = "101"  else
         'X'; -- undefined rounding mode...
  A_rounded <= unsigned('0'& A_norm_std(a_width-1 downto a_width-b_width)) when rnd = '0' else
               unsigned('0'& A_norm_std(a_width-1 downto a_width-b_width)) + unsigned(one_vector_b);
  b <= (others => 'X') when (Is_x(a_mag) or Is_x(a_sign) or Is_x(pos_offset) or Is_x(Sticky_bit) or Is_x(a_sign)) else  
       dw_conv_std_logic_vector(A_rounded(b_width-1 downto 0), b_width) when overflow_rounding = '0' else
       '1'& dw_conv_std_logic_vector(0,b_width-1); -- detects the special case of post-normalization 
  overflow_rounding <= A_rounded(b_width);
      
-- pragma translate_on  
end sim ;
--------------------------------------------------------------------------------
-- auto generated configuration
-- pragma translate_off

configuration DW_norm_rnd_cfg_sim of DW_norm_rnd is
 for sim
 end for; -- sim
end DW_norm_rnd_cfg_sim;
-- pragma translate_on

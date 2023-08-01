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
-- AUTHOR:    Alexandre Tenca   February 2005
--
-- VERSION:   VHDL Entity File for DW_norm_rnd
--
-- DesignWare_version: 1d3fcea3
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
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_norm_rnd is
   generic(a_width : POSITIVE := 16;
           srch_wind : POSITIVE := 4;
           exp_width : POSITIVE := 4;
           b_width : POSITIVE := 10;
           exp_ctr : INTEGER  := 0);
   port(a_mag : in std_logic_vector(a_width-1 downto 0);	-- input data
        pos_offset: in std_logic_vector(exp_width-1 downto 0);
	sticky_bit: in std_logic;
	a_sign: in std_logic;
        rnd_mode: in std_logic_vector (2 downto 0);
        pos_err : out std_logic;  	                -- wrong exponent value
	no_detect : out std_logic;
        b : out std_logic_vector(b_width-1 downto 0); -- shifted data
        pos: out std_logic_vector(exp_width-1 downto 0));
end DW_norm_rnd;
 

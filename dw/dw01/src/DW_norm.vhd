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
-- VERSION:   VHDL Entity File for DW_norm
--
-- DesignWare_version: 0fb38148
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
-- MODIFIED: 10/25:  Included the exp_ctr input which controls if the exp_adj 
--           output has the addition of exp_offset and shifted bit positions (0) 
--           or the subtraction of these values (1).
--
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DW_norm is
   generic(a_width : POSITIVE := 8; 
           srch_wind: POSITIVE := 8; 
           exp_width : POSITIVE := 4;
           exp_ctr : INTEGER  := 0);
   port(a : in std_logic_vector(a_width-1 downto 0);	-- input data
        exp_offset : in std_logic_vector(exp_width-1 downto 0);
        no_detect : out std_logic;  	        -- all zeros case
        ovfl : out std_logic;  	        -- overflow on Exp_adjustment calculation
        b : out std_logic_vector(a_width-1 downto 0); -- shifted data
        exp_adj : out std_logic_vector(exp_width-1 downto 0));
end DW_norm;
 

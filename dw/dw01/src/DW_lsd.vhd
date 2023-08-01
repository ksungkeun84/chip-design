--------------------------------------------------------------------------------
--
--       This confidential and proprietary software may be used only
--     as authorized by a licensing agreement from Synopsys Inc.
--     In the event of publication, the following notice is applicable:
--
--                    (C) COPYRIGHT 2006 - 2018 SYNOPSYS INC.
--                           ALL RIGHTS RESERVED
--
--       The entire notice above must be reproduced on all authorized
--     copies.
--
-- AUTHOR:    Reto Zimmermann    Mar. 22, 2006
--
-- VERSION:   Entity
--
-- DesignWare_version: 6aba4365
-- DesignWare_release: O-2018.06-DWBB_201806.3
--
--------------------------------------------------------------------------------
--
-- ABSTRACT: Leading Signs Detector
--           - Outputs an 'encoded' value that is the number of sign bits 
--             (from the left) before the first non-sign bit is found in the 
--             input vector. 
--           - Outputs a one-hot 'decoded' value that indicates the position 
--             of the right-most sign bit in the input vector.
--
--           Note: Only for the simulation model, X's will be handled in
--                 the following manner.  If an X is in a sign or the first
--                 non-sign bit position, then the outputs enc and dec get
--                 all X's.  If an X is after the first non-sign bit position,
--                 the outputs enc and dec get the expected non-X values.
--
--           Parameters  Legal Range  Default  Description
--           ----------  -----------  -------  -----------
--           a_width     >= 1         8        word length of a, dec
--              
--           Inputs   Size                 Description
--           ------   ----                 -----------
--           a        a_width              input vector
--
--           Outputs  Size                 Description
--           -------  ----                 -----------
--           enc      ceil(log2(a_width))  encoded output (number of sign bits)
--           dec      a_width              decoded output (position of sign bit)
--
-- MODIFIED: 
--
-------------------------------------------------------------------------------

library IEEE, DWARE;
use IEEE.std_logic_1164.all;
use DWARE.DWpackages.all;


entity DW_lsd is

  generic (
     a_width  : POSITIVE := 8);   -- input width

   port (
     a   : in  std_logic_vector(a_width-1 downto 0);             -- input
     enc : out std_logic_vector(bit_width(a_width)-1 downto 0);  -- encoded output
     dec : out std_logic_vector(a_width-1 downto 0));            -- decoded output

end DW_lsd ;

-------------------------------------------------------------------------------
